// controllers/disputeController.ts
import { Request, Response } from 'express';
import { DisputeModel } from '../models/disputeModel';
import OrderModel from '../models/orderModel';
import { pool } from '../config/db';
import logger from '../utils/logger';
import escrowService from '../services/escrowService';
import NotificationService from '../services/notificationService';

interface AuthRequest extends Request {
  user?: any;
}

// ─────────────────────────────────────────────
// 1. Create a dispute (Buyer)
// ─────────────────────────────────────────────
const createDispute = async (req: AuthRequest, res: Response): Promise<any> => {
  const conn: any = await pool.getConnection();
  try {
    await conn.beginTransaction();

    const { orderId, reason, evidenceUrls } = req.body;
    const buyerId = req.user.id;

    // Verify order exists and belongs to the buyer
    const order: any = await OrderModel.findById(orderId as string);
    if (!order) {
      await conn.rollback();
      return res.status(404).json({ success: false, message: 'Order not found.' });
    }

    if (order.buyer_id !== buyerId) {
      await conn.rollback();
      return res.status(403).json({ success: false, message: 'You can only dispute your own orders.' });
    }

    // Check if order is eligible for dispute (e.g., paid/shipped)
    if (order.status === 'completed' || order.status === 'cancelled') {
      await conn.rollback();
      return res.status(400).json({ success: false, message: 'Cannot dispute a completed or cancelled order.' });
    }

    // 1. Create the dispute record
    const disputeId = await DisputeModel.create({
      order_id: orderId as string,
      complainant_id: buyerId,
      reason: reason as string,
      evidence_urls: evidenceUrls ? (evidenceUrls as string[]) : undefined
    }, conn);

    // 2. Move escrow to disputed status (compatible with current enum)
    await conn.execute(
      `UPDATE escrow_transactions SET status = 'disputed' WHERE order_id = ?`,
      [orderId as string]
    );

    // 3. Keep orders table status model unchanged (pending/paid/shipped/completed/...)
    // We do not force-set a non-enum order status here.

    await conn.commit();
    res.status(201).json({
      success: true,
      message: 'Dispute submitted successfully. Funds have been frozen pending admin review.',
      data: { disputeId }
    });
  } catch (error: any) {
    await conn.rollback();
    logger.error('createDispute error:', error);
    res.status(500).json({ success: false, message: 'System error while creating dispute.' });
  } finally {
    conn.release();
  }
};

// ─────────────────────────────────────────────
// 2. Get my disputes (Buyer)
// ─────────────────────────────────────────────
const getMyDisputes = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const { page = '1', limit = '20' } = req.query;
    const offset = (parseInt(page as string) - 1) * parseInt(limit as string);

    // Backfill: older escrow/dispute flow only updated `escrow_transactions.status = disputed`
    // but did not create rows in `disputes`. Create missing rows so buyer/seller UIs can render.
    await pool.execute(
      `INSERT INTO disputes
         (id, order_id, complainant_id, reason, evidence_urls, status)
       SELECT
         e.id,
         e.order_id,
         e.buyer_id,
         'Khiếu nại (đồng bộ từ escrow)' AS reason,
         NULL,
         'pending'
       FROM escrow_transactions e
       WHERE e.buyer_id = ?
         AND e.status = 'disputed'
         AND NOT EXISTS (
           SELECT 1 FROM disputes d WHERE d.id = e.id
         )`,
      [req.user.id]
    );

    const disputes = await DisputeModel.findByUser(req.user.id, parseInt(limit as string), offset);
    res.status(200).json({ success: true, data: disputes });
  } catch (error: any) {
    logger.error('getMyDisputes error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch your disputes.' });
  }
};

// ─────────────────────────────────────────────
// 2.5 Get dispute detail by ID (Buyer/Seller/Admin)
// ─────────────────────────────────────────────
const getDisputeById = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const disputeId = req.params.id as string;
    const requesterId = req.user.id;
    const requesterRole = req.user.role;

    const dispute = await DisputeModel.findById(disputeId);
    if (!dispute) return res.status(404).json({ success: false, message: 'Dispute not found.' });

    // Access control: buyer (complainant) or seller (order.seller_id) or admin
    if (requesterRole !== 'admin' && dispute.complainant_id !== requesterId && dispute.seller_id !== requesterId) {
      return res.status(403).json({ success: false, message: 'Access denied.' });
    }

    // Attach order summary so dispute detail page can render products + totals.
    const [[order]]: any = await pool.execute(
      `SELECT id, total_amount, shipping_fee FROM orders WHERE id = ? LIMIT 1`,
      [dispute.order_id]
    );

    const [items]: any = await pool.execute(
      `SELECT
          oi.quantity,
          oi.unit_price AS price,
          p.name AS product_name
        FROM order_items oi
        JOIN products p ON p.id = oi.product_id
        WHERE oi.order_id = ?`,
      [dispute.order_id]
    );

    dispute.order = {
      subtotal: order?.total_amount ?? dispute.total_amount ?? 0,
      shipping_fee: order?.shipping_fee ?? 0,
      items: (items || []).map((it: any) => ({
        product_name: it.product_name,
        quantity: it.quantity,
        price: it.price,
      })),
    };

    res.status(200).json({ success: true, data: dispute });
  } catch (error: any) {
    logger.error('getDisputeById error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch dispute detail.' });
  }
};

// ─────────────────────────────────────────────
// 3. Get all disputes (Admin)
// ─────────────────────────────────────────────
const getAllDisputes = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const { status, page = '1', limit = '20' } = req.query;
    const offset = (parseInt(page as string) - 1) * parseInt(limit as string);
    
    const disputes = await DisputeModel.adminListAll(status as string, parseInt(limit as string), offset);
    res.status(200).json({ success: true, data: disputes });
  } catch (error: any) {
    logger.error('getAllDisputes error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch disputes.' });
  }
};

// ─────────────────────────────────────────────
// 4. Resolve a dispute (Admin)
// ─────────────────────────────────────────────
const resolveDispute = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const disputeId = req.params.id as string;
    const { resolution, reason = 'Admin resolved dispute' } = req.body; 

    const dispute = await DisputeModel.findById(disputeId);
    if (!dispute) {
      return res.status(404).json({ success: false, message: 'Dispute not found.' });
    }

    if (dispute.status !== 'pending') {
      return res.status(400).json({ success: false, message: 'Dispute has already been resolved.' });
    }

    // Trường hợp 1: Admin bác bỏ khiếu nại (Không dính tới tiền bạc thực tế, chỉ đổi trạng thái DB)
    if (resolution === 'reject') {
      const conn: any = await pool.getConnection();
      try {
        await conn.beginTransaction();
        await DisputeModel.updateStatus(disputeId, 'rejected', conn);
        // Trả escrow về trạng thái held, order về trạng thái paid (hoặc shipped)
        await conn.execute(`UPDATE escrow_transactions SET status = 'held' WHERE order_id = ?`, [dispute.order_id]);
        await conn.execute(`UPDATE orders SET status = 'shipped' WHERE id = ?`, [dispute.order_id]);
        await conn.commit();
        return res.status(200).json({ success: true, message: 'Dispute rejected. Funds returned to held status.' });
      } catch (err) {
        await conn.rollback();
        throw err;
      } finally {
        conn.release();
      }
    } 
    
    // Trường hợp 2: Bồi thường hoặc Giải ngân (Liên quan đến tiền bạc -> Đẩy qua EscrowService + Outbox)
    else if (resolution === 'refund_buyer' || resolution === 'release_seller') {
      const action = resolution === 'refund_buyer' ? 'refund' : 'release';
      
      const result = await escrowService.resolveDispute({
        orderId: dispute.order_id,
        disputeId: disputeId,
        adminId: req.user.id,
        resolution: action,
        reason: reason,
        ipAddress: req.ip
      });

      if (!result.success) {
        return res.status(400).json(result);
      }
      return res.status(200).json(result);
    } 
    
    else {
      return res.status(400).json({ success: false, message: 'Invalid resolution action.' });
    }

  } catch (error: any) {
    logger.error('resolveDispute error:', error);
    res.status(500).json({ success: false, message: 'System error while resolving dispute.' });
  }
};

// ─────────────────────────────────────────────
// 5. Submit Evidence (Seller/Buyer nộp bằng chứng)
// ─────────────────────────────────────────────
const submitEvidence = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const disputeId = req.params.id as string;
    let { evidenceUrl, description } = req.body;
    const userId = req.user.id;

    evidenceUrl = String(evidenceUrl || '').trim();
    if (evidenceUrl && !/^https?:\/\//i.test(evidenceUrl)) {
      evidenceUrl = `https://${evidenceUrl}`;
    }

    const dispute = await DisputeModel.findById(disputeId);
    if (!dispute) return res.status(404).json({ success: false, message: 'Không tìm thấy khiếu nại.' });

    const order: any = await OrderModel.findById(dispute.order_id);
    if (!order) return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng.' });

    // Chỉ buyer hoặc seller của đơn mới được nộp bằng chứng
    if (order.seller_id !== userId && order.buyer_id !== userId) {
      return res.status(403).json({ success: false, message: 'Từ chối truy cập.' });
    }

    // Schema hiện tại chỉ có `evidence_urls` (JSON array), không có buyer_evidence/seller_evidence.
    // Vì vậy append URL vào evidence_urls để cả buyer/seller/admin đều xem được.
    const ok = await DisputeModel.addEvidenceUrl(disputeId, evidenceUrl);
    if (!ok) {
      return res.status(404).json({ success: false, message: 'Không thể cập nhật bằng chứng.' });
    }

    res.status(200).json({ success: true, message: 'Nộp bằng chứng thành công.' });
  } catch (error: any) {
    logger.error('submitEvidence error:', error);
    res.status(500).json({ success: false, message: 'Lỗi hệ thống khi nộp bằng chứng.' });
  }
};

// ─────────────────────────────────────────────
// 6. Send chat message in dispute
// ─────────────────────────────────────────────
const sendChatMessage = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const disputeId = req.params.disputeId as string;
    const { message, attachments } = req.body;
    const userId = req.user.id;

    if (!message || message.trim().length === 0) {
      return res.status(400).json({ success: false, message: 'Message cannot be empty.' });
    }

    const DisputeChatService = (await import('../services/disputeChatService')).default;
    const result = await DisputeChatService.sendMessage(disputeId, userId, message, attachments);

    if (!result.success) {
      return res.status(400).json(result);
    }

    // Notify the other party in the dispute
    try {
      const dispute: any = await DisputeModel.findById(disputeId);
      if (dispute) {
        const otherUserId = userId === dispute.complainant_id ? dispute.seller_id : dispute.complainant_id;
        
        if (otherUserId) {
          NotificationService.notifyChatMessage({
            disputeId,
            otherUserId,
            senderId: userId,
            senderName: req.user?.username || 'User',
            message: message.substring(0, 100), // Preview
            orderId: dispute.order_id
          }).catch(err => logger.error('Notification error:', err));
        }
      }
    } catch (notifyErr) {
      logger.error('Failed to send chat notification:', notifyErr);
    }

    res.status(201).json({
      success: true,
      message: 'Message sent successfully.',
      data: { messageId: result.id }
    });
  } catch (error: any) {
    logger.error('sendChatMessage error:', error);
    res.status(500).json({ success: false, message: 'Failed to send message.' });
  }
};

// ─────────────────────────────────────────────
// 7. Get dispute chat history
// ─────────────────────────────────────────────
const getDisputeChat = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const disputeId = req.params.disputeId as string;
    const { page = '1', limit = '20' } = req.query;

    const DisputeChatService = (await import('../services/disputeChatService')).default;
    const messages = await DisputeChatService.getDisputeChat(
      disputeId,
      parseInt(page as string),
      parseInt(limit as string)
    );

    res.status(200).json({ success: true, data: messages });
  } catch (error: any) {
    logger.error('getDisputeChat error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch chat history.' });
  }
};

// ─────────────────────────────────────────────
// 8. Mark chat as read
// ─────────────────────────────────────────────
const markChatAsRead = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const disputeId = req.params.disputeId as string;
    const userId = req.user.id;

    const DisputeChatService = (await import('../services/disputeChatService')).default;
    await DisputeChatService.markMessagesAsRead(disputeId, userId);

    res.status(200).json({ success: true, message: 'Messages marked as read.' });
  } catch (error: any) {
    logger.error('markChatAsRead error:', error);
    res.status(500).json({ success: false, message: 'Failed to mark messages as read.' });
  }
};

export = {
  createDispute,
  getMyDisputes,
  getDisputeById,
  getAllDisputes,
  resolveDispute,
  submitEvidence,
  sendChatMessage,
  getDisputeChat,
  markChatAsRead
};