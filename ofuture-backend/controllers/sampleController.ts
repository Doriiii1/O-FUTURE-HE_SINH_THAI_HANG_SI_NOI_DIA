// controllers/sampleController.ts
import { Request, Response } from 'express';
import { SampleModel } from '../models/sampleModel';
import ProductModel from '../models/productModel';
import OrderModel from '../models/orderModel';
import logger from '../utils/logger';
import { pool } from '../config/db';

interface AuthRequest extends Request {
  user?: any;
}

// ─────────────────────────────────────────────
// 1. Request a sample (Buyer)
// ─────────────────────────────────────────────
const requestSample = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const { productId, notes } = req.body;
    const buyerId = req.user.id;

    // Fetch product to check stock and calculate deposit
    const product: any = await ProductModel.findById(productId as string);
    if (!product || product.status !== 'active') {
      return res.status(404).json({ success: false, message: 'Product not found or no longer active.' });
    }

    if (product.seller_id === buyerId) {
      return res.status(400).json({ success: false, message: 'You cannot request a sample of your own product.' });
    }

    // Calculate deposit amount: Assuming 100% of the wholesale price for 1 item
    const depositAmount = parseFloat(product.price);

    const sampleId = await SampleModel.create({
      product_id: productId as string,
      buyer_id: buyerId,
      seller_id: product.seller_id,
      deposit_amount: depositAmount,
      notes: notes as string
    });

    res.status(201).json({
      success: true,
      message: 'Sample request submitted successfully. Please wait for seller approval.',
      data: {
        sampleId,
        depositAmount,
        status: 'requested'
      }
    });
  } catch (error: any) {
    logger.error('requestSample error:', error);
    res.status(500).json({ success: false, message: 'System error while creating sample request.' });
  }
};

// ─────────────────────────────────────────────
// 2. Get my sample requests (Buyer)
// ─────────────────────────────────────────────
const getMySamples = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const { page = '1', limit = '20' } = req.query;
    const offset = (parseInt(page as string) - 1) * parseInt(limit as string);
    
    const samples = await SampleModel.findByBuyer(req.user.id, parseInt(limit as string), offset);
    res.status(200).json({ success: true, data: samples });
  } catch (error: any) {
    logger.error('getMySamples error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch sample requests.' });
  }
};

// ─────────────────────────────────────────────
// 3. Get requested samples (Seller)
// ─────────────────────────────────────────────
const getSellerSamples = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const { page = '1', limit = '20' } = req.query;
    const offset = (parseInt(page as string) - 1) * parseInt(limit as string);
    
    const samples = await SampleModel.findBySeller(req.user.id, parseInt(limit as string), offset);
    res.status(200).json({ success: true, data: samples });
  } catch (error: any) {
    logger.error('getSellerSamples error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch seller sample requests.' });
  }
};

// ─────────────────────────────────────────────
// 4. Update sample status (Seller)
// ─────────────────────────────────────────────
const updateSampleStatus = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const sampleId = req.params.id as string; // Fix TS error
    const { status } = req.body; // 'approved', 'shipped', 'cancelled', 'returned'
    const sellerId = req.user.id;

    const sample = await SampleModel.findById(sampleId);
    if (!sample) return res.status(404).json({ success: false, message: 'Sample request not found.' });

    if (sample.seller_id !== sellerId) {
      return res.status(403).json({ success: false, message: 'Access denied. You do not have permission to change this sample status.' });
    }

    const normalizedStatus = status === 'rejected' ? 'cancelled' : status;
    const validStatuses = ['approved', 'shipped', 'cancelled', 'returned'];
    if (!validStatuses.includes(normalizedStatus as string)) {
      return res.status(400).json({ success: false, message: 'Invalid status provided.' });
    }

    if (normalizedStatus === 'approved') {
      // Tự động tạo order mẫu theo schema orders/order_items hiện tại.
      const conn: any = await pool.getConnection();
      try {
        await conn.beginTransaction();

        const orderId = require('crypto').randomUUID();
        const amount = parseFloat(sample.deposit_amount as any) || 0;
        const platformFee = parseFloat((amount * 0.025).toFixed(2));
        const netAmount = parseFloat((amount - platformFee).toFixed(2));

        await conn.execute(
          `INSERT INTO orders
             (id, buyer_id, seller_id, total_amount, shipping_fee, discount_amount, final_total_amount, shipping_address, notes, status)
           VALUES (?, ?, ?, ?, 0, 0, ?, ?, ?, 'pending')`,
          [
            orderId,
            sample.buyer_id,
            sample.seller_id,
            amount,
            amount,
            JSON.stringify({ note: 'Dia chi mac dinh cho don hang mau' }),
            `[IS_SAMPLE] Don hang tu dong sinh tu Yeu cau Hang mau #${sampleId}`,
          ]
        );

        await conn.execute(
          `INSERT INTO order_items (id, order_id, product_id, quantity, unit_price, subtotal)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [require('crypto').randomUUID(), orderId, sample.product_id, 1, amount, amount]
        );

        await conn.execute(
          `INSERT INTO escrow_transactions
             (order_id, buyer_id, seller_id, amount, platform_fee, net_amount, status)
           VALUES (?, ?, ?, ?, ?, ?, 'pending')`,
          [orderId, sample.buyer_id, sample.seller_id, amount, platformFee, netAmount]
        );

        await conn.commit();
      } catch (createOrderErr) {
        await conn.rollback();
        throw createOrderErr;
      } finally {
        conn.release();
      }
    }

    await SampleModel.updateStatus(sampleId, normalizedStatus as string);
    res.status(200).json({ success: true, message: `Sample status updated to ${normalizedStatus}.` });
  } catch (error: any) {
    logger.error('updateSampleStatus error:', error);
    res.status(500).json({ success: false, message: 'Failed to update sample status.' });
  }
};

// ─────────────────────────────────────────────
// 5. Convert sample to official order (Buyer)
// ─────────────────────────────────────────────
const convertToOrder = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const sampleId = req.params.id as string; // Fix TS error
    const { quantity, shippingAddress } = req.body;
    const buyerId = req.user.id;

    const sample = await SampleModel.findById(sampleId);
    if (!sample) return res.status(404).json({ success: false, message: 'Sample request not found.' });

    if (sample.buyer_id !== buyerId) {
      return res.status(403).json({ success: false, message: 'Access denied. You do not have permission to access this sample.' });
    }

    if (sample.status !== 'shipped' && sample.status !== 'approved') {
      return res.status(400).json({ success: false, message: 'Can only convert to order when the sample is approved or shipped.' });
    }

    // 1. Update sample status to "converted_to_order"
    await SampleModel.updateStatus(sampleId, 'converted_to_order');

    // 2. Automatically create a new Order based on this sample
    const parsedQuantity = parseInt(quantity as string);
    const totalAmount = parseFloat(sample.wholesale_price) * parsedQuantity;
    
    const newOrderId = await OrderModel.create({
      buyerId: buyerId,
      sellerId: sample.seller_id,
      productId: sample.product_id,
      quantity: parsedQuantity,
      unitPrice: parseFloat(sample.wholesale_price),
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      notes: `Order converted from sample request #${sampleId}`
    });

    res.status(200).json({
      success: true,
      message: 'Successfully converted sample to official order!',
      data: {
        newOrderId,
        status: 'converted_to_order'
      }
    });

  } catch (error: any) {
    logger.error('convertToOrder error:', error);
    res.status(500).json({ success: false, message: 'Failed to convert sample to order.' });
  }
};

export = {
  requestSample,
  getMySamples,
  getSellerSamples,
  updateSampleStatus,
  convertToOrder
};