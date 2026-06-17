-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th4 16, 2026 lúc 05:32 PM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `ofuture_db`
--

CREATE DATABASE IF NOT EXISTS ofuture_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE ofuture_db;
-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `categories`
--

CREATE TABLE `categories` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `parent_id` char(36) DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `display_order` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chat_messages`
--

CREATE TABLE `chat_messages` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `session_id` char(36) NOT NULL,
  `sender_type` enum('user','ai','admin') NOT NULL,
  `message_text` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `chat_messages`
--

INSERT INTO `chat_messages` (`id`, `session_id`, `sender_type`, `message_text`, `created_at`) VALUES
('6b04f41d-3996-11f1-8d04-10ffe08c8627', '16373f7d-ba11-4f82-8462-702fa27bd6ec', 'user', 'chào', '2026-04-16 20:16:02'),
('6b2b972d-3996-11f1-8d04-10ffe08c8627', '16373f7d-ba11-4f82-8462-702fa27bd6ec', 'ai', 'I am currently experiencing technical difficulties connecting to my brain. Please try again later or request human support.', '2026-04-16 20:16:03'),
('c9535355-399e-11f1-8d04-10ffe08c8627', '16373f7d-ba11-4f82-8462-702fa27bd6ec', 'user', 'dsfsdfds', '2026-04-16 21:15:57'),
('c97ea4dd-399e-11f1-8d04-10ffe08c8627', '16373f7d-ba11-4f82-8462-702fa27bd6ec', 'ai', 'I am currently experiencing technical difficulties connecting to my brain. Please try again later or request human support.', '2026-04-16 21:15:57');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chat_sessions`
--

CREATE TABLE `chat_sessions` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `user_id` char(36) NOT NULL,
  `status` enum('active','resolved','handoff_to_admin') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `chat_sessions`
--

INSERT INTO `chat_sessions` (`id`, `user_id`, `status`, `created_at`, `updated_at`) VALUES
('16373f7d-ba11-4f82-8462-702fa27bd6ec', '23d79b21-3990-11f1-8d04-10ffe08c8627', 'active', '2026-04-16 20:16:02', '2026-04-16 20:16:02');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `disputes`
--

CREATE TABLE `disputes` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `order_id` char(36) NOT NULL,
  `complainant_id` char(36) NOT NULL,
  `reason` text NOT NULL,
  `evidence_urls` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`evidence_urls`)),
  `status` enum('pending','resolved_refunded','resolved_released','rejected') NOT NULL DEFAULT 'pending',
  `resolved_at` datetime DEFAULT NULL,
  `resolved_by` char(36) DEFAULT NULL,
  `resolution_note` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `disputes`
--

INSERT INTO `disputes` (`id`, `order_id`, `complainant_id`, `reason`, `evidence_urls`, `status`, `resolved_at`, `resolved_by`, `resolution_note`, `created_at`, `updated_at`) VALUES
('62131c46-399a-11f1-8d04-10ffe08c8627', 'd31251a0-676c-4372-a67a-c795293e1ca9', '23d79b21-3990-11f1-8d04-10ffe08c8627', 'Khiếu nại (đồng bộ từ escrow)', '[\"https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/378110/ss_3ffb50f27aec104fd5b56bcfb046d8b8dba875bd.1920x1080.jpg?t=1736944143\"]', 'pending', NULL, NULL, NULL, '2026-04-16 21:13:12', '2026-04-16 21:22:06'),
('7a29d9a3-399e-11f1-8d04-10ffe08c8627', '7df05642-eb04-4470-8905-d962e0ee40f3', '23d79b21-3990-11f1-8d04-10ffe08c8627', 'sdfgsdfsfdsfsdsdf', '[\"https://ádadadsadsad\"]', 'pending', NULL, NULL, NULL, '2026-04-16 21:14:16', '2026-04-16 21:21:30');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dispute_chats`
--

CREATE TABLE `dispute_chats` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `dispute_id` char(36) NOT NULL,
  `sender_id` char(36) NOT NULL,
  `message` text NOT NULL,
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `dispute_chats`
--

INSERT INTO `dispute_chats` (`id`, `dispute_id`, `sender_id`, `message`, `attachments`, `is_read`, `created_at`, `updated_at`) VALUES
('34eaa6fb-39a2-11f1-8d04-10ffe08c8627', '7a29d9a3-399e-11f1-8d04-10ffe08c8627', '5ca5f6da-398f-11f1-8d04-10ffe08c8627', 'hi', NULL, 1, '2026-04-16 21:40:26', '2026-04-16 21:40:45'),
('57394f16-39a1-11f1-8d04-10ffe08c8627', '7a29d9a3-399e-11f1-8d04-10ffe08c8627', '23d79b21-3990-11f1-8d04-10ffe08c8627', 'hi', NULL, 1, '2026-04-16 21:34:14', '2026-04-16 21:39:57'),
('8f33d000-39a1-11f1-8d04-10ffe08c8627', '7a29d9a3-399e-11f1-8d04-10ffe08c8627', '23d79b21-3990-11f1-8d04-10ffe08c8627', 'aa', NULL, 1, '2026-04-16 21:35:48', '2026-04-16 21:39:57');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `escrow_transactions`
--

CREATE TABLE `escrow_transactions` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `order_id` char(36) NOT NULL,
  `buyer_id` char(36) NOT NULL,
  `seller_id` char(36) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `platform_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `net_amount` decimal(12,2) NOT NULL,
  `charge_id` varchar(64) DEFAULT NULL,
  `transfer_id` varchar(64) DEFAULT NULL,
  `refund_id` varchar(64) DEFAULT NULL,
  `gateway` varchar(50) DEFAULT NULL,
  `status` enum('pending','processing','held','releasing','refunding','released','refunded','disputed') NOT NULL DEFAULT 'pending',
  `held_at` datetime DEFAULT NULL,
  `released_at` datetime DEFAULT NULL,
  `refunded_at` datetime DEFAULT NULL,
  `release_reason` varchar(255) DEFAULT NULL,
  `refund_reason` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `escrow_transactions`
--

INSERT INTO `escrow_transactions` (`id`, `order_id`, `buyer_id`, `seller_id`, `amount`, `platform_fee`, `net_amount`, `charge_id`, `transfer_id`, `refund_id`, `gateway`, `status`, `held_at`, `released_at`, `refunded_at`, `release_reason`, `refund_reason`, `created_at`, `updated_at`) VALUES
('3bd09a55-3999-11f1-8d04-10ffe08c8627', 'cfd4d325-8eda-495a-bdc7-b594cfbcc25b', '23d79b21-3990-11f1-8d04-10ffe08c8627', '5ca5f6da-398f-11f1-8d04-10ffe08c8627', 3750000.00, 93750.00, 3656250.00, NULL, NULL, NULL, NULL, 'released', '2026-04-16 20:36:12', '2026-04-16 20:39:19', NULL, 'Buyer confirmed delivery', NULL, '2026-04-16 20:36:12', '2026-04-16 20:39:19'),
('62131c46-399a-11f1-8d04-10ffe08c8627', 'd31251a0-676c-4372-a67a-c795293e1ca9', '23d79b21-3990-11f1-8d04-10ffe08c8627', '5ca5f6da-398f-11f1-8d04-10ffe08c8627', 3825000.00, 95625.00, 3729375.00, NULL, NULL, NULL, NULL, 'disputed', '2026-04-16 20:44:25', NULL, NULL, NULL, NULL, '2026-04-16 20:44:25', '2026-04-16 20:50:45'),
('7a29d9a3-399e-11f1-8d04-10ffe08c8627', '7df05642-eb04-4470-8905-d962e0ee40f3', '23d79b21-3990-11f1-8d04-10ffe08c8627', '5ca5f6da-398f-11f1-8d04-10ffe08c8627', 4125000.00, 103125.00, 4021875.00, NULL, NULL, NULL, NULL, 'disputed', '2026-04-16 21:13:44', NULL, NULL, NULL, NULL, '2026-04-16 21:13:44', '2026-04-16 21:14:16'),
('a09ed586-3994-11f1-8d04-10ffe08c8627', '7958f13d-48a0-4609-8c38-a412fd999b6b', '23d79b21-3990-11f1-8d04-10ffe08c8627', '5ca5f6da-398f-11f1-8d04-10ffe08c8627', 375000.00, 9375.00, 365625.00, NULL, NULL, NULL, NULL, 'releasing', '2026-04-16 20:26:19', NULL, NULL, NULL, NULL, '2026-04-16 20:03:13', '2026-04-16 20:27:07'),
('a7241359-3991-11f1-8d04-10ffe08c8627', 'd7b47fd5-efb3-4e3e-a0f3-d1edab9fbc3c', '5ca5f6da-398f-11f1-8d04-10ffe08c8627', '23d79b21-3990-11f1-8d04-10ffe08c8627', 100000.00, 2500.00, 97500.00, NULL, NULL, NULL, NULL, 'pending', NULL, NULL, NULL, NULL, NULL, '2026-04-16 19:41:56', '2026-04-16 19:41:56'),
('e6854511-3999-11f1-8d04-10ffe08c8627', '0475bfef-5268-4d4f-9084-f0c3a8191ee5', '23d79b21-3990-11f1-8d04-10ffe08c8627', '5ca5f6da-398f-11f1-8d04-10ffe08c8627', 3750000.00, 93750.00, 3656250.00, NULL, NULL, NULL, NULL, 'released', '2026-04-16 20:40:58', '2026-04-16 20:41:43', NULL, 'Buyer confirmed delivery', NULL, '2026-04-16 20:40:58', '2026-04-16 20:41:43');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `knowledge_base`
--

CREATE TABLE `knowledge_base` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `topic` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `knowledge_base`
--

INSERT INTO `knowledge_base` (`id`, `topic`, `content`, `is_active`, `created_at`, `updated_at`) VALUES
('da4f2ac7-398d-11f1-8d04-10ffe08c8627', 'platform_fee', 'O\'Future charges a 2.5% platform fee on all successful transactions.', 1, '2026-04-16 19:14:44', '2026-04-16 19:14:44'),
('da4f31b1-398d-11f1-8d04-10ffe08c8627', 'escrow_policy', 'Funds are held in Escrow until the buyer confirms delivery. If no dispute is filed within 3 days of delivery, funds are automatically released to the seller.', 1, '2026-04-16 19:14:44', '2026-04-16 19:14:44'),
('da4f321c-398d-11f1-8d04-10ffe08c8627', 'dispute_process', 'If a buyer receives damaged goods, they can open a dispute. Admin will review evidence before refunding.', 1, '2026-04-16 19:14:44', '2026-04-16 19:14:44');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `logs`
--

CREATE TABLE `logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` char(36) DEFAULT NULL,
  `event_type` varchar(80) NOT NULL,
  `severity` enum('info','warn','error','critical') NOT NULL DEFAULT 'info',
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(300) DEFAULT NULL,
  `endpoint` varchar(200) DEFAULT NULL,
  `method` varchar(10) DEFAULT NULL,
  `status_code` smallint(6) DEFAULT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payload`)),
  `message` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


--
-- Cấu trúc bảng cho bảng `notifications`
--

CREATE TABLE `notifications` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `user_id` char(36) NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orders`
--

CREATE TABLE `orders` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `buyer_id` char(36) NOT NULL,
  `seller_id` char(36) NOT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `shipping_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(12,2) NOT NULL DEFAULT 0.00,
  `final_total_amount` decimal(12,2) NOT NULL,
  `status` enum('pending','paid','shipped','completed','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `shipping_address` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`shipping_address`)),
  `carrier` varchar(100) DEFAULT NULL,
  `tracking_number` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_histories`
--

CREATE TABLE `order_histories` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `order_id` char(36) NOT NULL,
  `status` enum('pending','paid','shipped','completed','cancelled','refunded') NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `created_by` char(36) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_items`
--

CREATE TABLE `order_items` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `order_id` char(36) NOT NULL,
  `product_id` char(36) NOT NULL,
  `quantity` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `unit_price` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `otp_codes`
--

CREATE TABLE `otp_codes` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `user_id` char(36) NOT NULL,
  `code_hash` varchar(255) NOT NULL,
  `purpose` enum('email_verify','mfa_login','password_reset') NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `outbox_events`
--

CREATE TABLE `outbox_events` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `aggregate_type` varchar(50) NOT NULL,
  `aggregate_id` char(36) NOT NULL,
  `event_type` varchar(50) NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`payload`)),
  `attempt_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `next_run_at` datetime NOT NULL DEFAULT current_timestamp(),
  `locked_by` varchar(100) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `status` enum('pending','in_progress','succeeded','failed') NOT NULL DEFAULT 'pending',
  `result` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`result`)),
  `last_error` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `payments`
--

CREATE TABLE `payments` (
  `id` varchar(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `order_id` varchar(36) NOT NULL,
  `method` enum('cod','momo','qr') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('pending','success','failed','expired') DEFAULT 'pending',
  `transaction_id` varchar(100) DEFAULT NULL,
  `payment_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payment_data`)),
  `expires_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `products`
--

CREATE TABLE `products` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `seller_id` char(36) NOT NULL,
  `category_id` char(36) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(300) NOT NULL,
  `description` text DEFAULT NULL,
  `category` varchar(100) NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `wholesale_price` decimal(12,2) DEFAULT NULL,
  `minimum_quantity` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `stock_quantity` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `image_urls` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`image_urls`)),
  `status` enum('active','inactive','deleted') NOT NULL DEFAULT 'active',
  `avg_rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `review_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_variants`
--

CREATE TABLE `product_variants` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `product_id` char(36) NOT NULL,
  `attribute_name` varchar(50) NOT NULL,
  `attribute_value` varchar(100) NOT NULL,
  `sku` varchar(100) NOT NULL,
  `stock_quantity` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `price_adjustment` decimal(12,2) NOT NULL DEFAULT 0.00,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `refresh_tokens`
--

CREATE TABLE `refresh_tokens` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `user_id` char(36) NOT NULL,
  `token_hash` varchar(255) NOT NULL,
  `device_fingerprint` varchar(128) DEFAULT NULL,
  `device_info` varchar(300) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `last_used_ip` varchar(45) DEFAULT NULL,
  `last_used_at` datetime DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `revoked` tinyint(1) NOT NULL DEFAULT 0,
  `revoke_reason` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `reviews`
--

CREATE TABLE `reviews` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `product_id` char(36) NOT NULL,
  `buyer_id` char(36) NOT NULL,
  `order_id` char(36) NOT NULL,
  `rating` tinyint(3) UNSIGNED NOT NULL,
  `title` varchar(150) DEFAULT NULL,
  `body` text DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 1,
  `is_hidden` tinyint(1) NOT NULL DEFAULT 0,
  `seller_reply_text` text DEFAULT NULL,
  `seller_reply_at` datetime DEFAULT NULL,
  `is_reply_hidden` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `sample_requests`
--

CREATE TABLE `sample_requests` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `product_id` char(36) NOT NULL,
  `buyer_id` char(36) NOT NULL,
  `seller_id` char(36) NOT NULL,
  `deposit_amount` decimal(12,2) NOT NULL,
  `notes` text DEFAULT NULL,
  `status` enum('requested','approved','shipped','returned','cancelled','converted_to_order') NOT NULL DEFAULT 'requested',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `seller_profile_change_requests`
--

CREATE TABLE `seller_profile_change_requests` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `seller_id` char(36) NOT NULL,
  `requested_changes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`requested_changes`)),
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `admin_note` text DEFAULT NULL,
  `reviewed_by` char(36) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `trusted_devices`
--

CREATE TABLE `trusted_devices` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `user_id` char(36) NOT NULL,
  `device_fingerprint` varchar(128) NOT NULL,
  `device_name` varchar(150) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `remembered_until` datetime DEFAULT NULL,
  `last_used_at` datetime DEFAULT NULL,
  `revoked` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `email` varchar(255) NOT NULL,
  `username` varchar(80) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('buyer','seller','admin') NOT NULL DEFAULT 'buyer',
  `full_name` varchar(150) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `avatar_url` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `mfa_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `mfa_secret` varchar(100) DEFAULT NULL,
  `mfa_backup_codes` text DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(45) DEFAULT NULL,
  `failed_attempts` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `locked_until` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_profiles`
--

CREATE TABLE `user_profiles` (
  `user_id` char(36) NOT NULL,
  `store_name` varchar(150) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `scale` enum('small','medium','large','enterprise') DEFAULT 'small',
  `tax_code` varchar(50) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `zip_code` varchar(20) DEFAULT NULL,
  `country` varchar(100) DEFAULT 'Việt Nam',
  `bio` text DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc đóng vai cho view `v_order_summary`
-- (See below for the actual view)
--
CREATE TABLE `v_order_summary` (
`order_id` char(36)
,`order_status` enum('pending','paid','shipped','completed','cancelled','refunded')
,`quantity` decimal(32,0)
,`unit_price` decimal(12,2)
,`total_amount` decimal(12,2)
,`created_at` datetime
,`buyer_username` varchar(80)
,`buyer_email` varchar(255)
,`seller_username` varchar(80)
,`product_name` varchar(255)
,`product_id` varchar(36)
,`escrow_status` enum('pending','processing','held','releasing','refunding','released','refunded','disputed')
,`escrow_amount` decimal(12,2)
);

-- --------------------------------------------------------

--
-- Cấu trúc đóng vai cho view `v_product_listing`
-- (See below for the actual view)
--
CREATE TABLE `v_product_listing` (
`id` char(36)
,`name` varchar(255)
,`slug` varchar(300)
,`category` varchar(100)
,`price` decimal(12,2)
,`stock_quantity` int(10) unsigned
,`status` enum('active','inactive','deleted')
,`avg_rating` decimal(3,2)
,`review_count` int(10) unsigned
,`image_urls` longtext
,`created_at` datetime
,`seller_username` varchar(80)
,`seller_name` varchar(150)
);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wallets`
--

CREATE TABLE `wallets` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `user_id` char(36) NOT NULL,
  `balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `currency` varchar(3) NOT NULL DEFAULT 'VND',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wallet_transactions`
--

CREATE TABLE `wallet_transactions` (
  `id` char(36) NOT NULL DEFAULT uuid(),
  `wallet_id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `type` enum('deposit','withdrawal','transfer_in','transfer_out','platform_fee','adjustment') NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `reference_id` varchar(100) DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `status` enum('completed','pending','failed') NOT NULL DEFAULT 'completed',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc cho view `v_order_summary`
--
DROP TABLE IF EXISTS `v_order_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_order_summary`  AS SELECT `o`.`id` AS `order_id`, `o`.`status` AS `order_status`, (select sum(`order_items`.`quantity`) from `order_items` where `order_items`.`order_id` = `o`.`id`) AS `quantity`, (select `order_items`.`unit_price` from `order_items` where `order_items`.`order_id` = `o`.`id` limit 1) AS `unit_price`, `o`.`final_total_amount` AS `total_amount`, `o`.`created_at` AS `created_at`, `b`.`username` AS `buyer_username`, `b`.`email` AS `buyer_email`, `s`.`username` AS `seller_username`, (select `p`.`name` from (`order_items` `oi` join `products` `p` on(`oi`.`product_id` = `p`.`id`)) where `oi`.`order_id` = `o`.`id` order by `oi`.`created_at` limit 1) AS `product_name`, (select `order_items`.`product_id` from `order_items` where `order_items`.`order_id` = `o`.`id` order by `order_items`.`created_at` limit 1) AS `product_id`, `e`.`status` AS `escrow_status`, `e`.`amount` AS `escrow_amount` FROM (((`orders` `o` join `users` `b` on(`b`.`id` = `o`.`buyer_id`)) join `users` `s` on(`s`.`id` = `o`.`seller_id`)) left join `escrow_transactions` `e` on(`e`.`order_id` = `o`.`id`)) ;

-- --------------------------------------------------------

--
-- Cấu trúc cho view `v_product_listing`
--
DROP TABLE IF EXISTS `v_product_listing`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_product_listing`  AS SELECT `p`.`id` AS `id`, `p`.`name` AS `name`, `p`.`slug` AS `slug`, `p`.`category` AS `category`, `p`.`price` AS `price`, `p`.`stock_quantity` AS `stock_quantity`, `p`.`status` AS `status`, `p`.`avg_rating` AS `avg_rating`, `p`.`review_count` AS `review_count`, `p`.`image_urls` AS `image_urls`, `p`.`created_at` AS `created_at`, `u`.`username` AS `seller_username`, `u`.`full_name` AS `seller_name` FROM (`products` `p` join `users` `u` on(`u`.`id` = `p`.`seller_id`)) WHERE `p`.`status` = 'active' ;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_categories_slug` (`slug`),
  ADD KEY `idx_categories_parent_id` (`parent_id`),
  ADD KEY `idx_categories_is_active` (`is_active`);

--
-- Chỉ mục cho bảng `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_chat_message_session` (`session_id`);

--
-- Chỉ mục cho bảng `chat_sessions`
--
ALTER TABLE `chat_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_chat_session_user` (`user_id`);

--
-- Chỉ mục cho bảng `disputes`
--
ALTER TABLE `disputes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_disputes_order_id` (`order_id`),
  ADD KEY `idx_disputes_complainant_id` (`complainant_id`),
  ADD KEY `idx_disputes_status` (`status`),
  ADD KEY `fk_disputes_resolved_by` (`resolved_by`);

--
-- Chỉ mục cho bảng `dispute_chats`
--
ALTER TABLE `dispute_chats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_dc_dispute_id` (`dispute_id`),
  ADD KEY `idx_dc_sender_id` (`sender_id`),
  ADD KEY `idx_dc_created_at` (`created_at`);

--
-- Chỉ mục cho bảng `escrow_transactions`
--
ALTER TABLE `escrow_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_escrow_order_id` (`order_id`),
  ADD KEY `idx_escrow_buyer_id` (`buyer_id`),
  ADD KEY `idx_escrow_seller_id` (`seller_id`),
  ADD KEY `idx_escrow_status` (`status`);

--
-- Chỉ mục cho bảng `knowledge_base`
--
ALTER TABLE `knowledge_base`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_kb_topic` (`topic`);

--
-- Chỉ mục cho bảng `logs`
--
ALTER TABLE `logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_logs_user_id` (`user_id`),
  ADD KEY `idx_logs_event_type` (`event_type`),
  ADD KEY `idx_logs_severity` (`severity`),
  ADD KEY `idx_logs_created_at` (`created_at`),
  ADD KEY `idx_logs_ip_address` (`ip_address`);

--
-- Chỉ mục cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_read` (`user_id`,`is_read`),
  ADD KEY `idx_user_created` (`user_id`,`created_at`);

--
-- Chỉ mục cho bảng `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_orders_buyer_id` (`buyer_id`),
  ADD KEY `idx_orders_seller_id` (`seller_id`),
  ADD KEY `idx_orders_status` (`status`),
  ADD KEY `idx_orders_created_at` (`created_at`);

--
-- Chỉ mục cho bảng `order_histories`
--
ALTER TABLE `order_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_oh_order_id` (`order_id`),
  ADD KEY `idx_oh_status` (`status`),
  ADD KEY `idx_oh_created_at` (`created_at`),
  ADD KEY `fk_oh_created_by` (`created_by`);

--
-- Chỉ mục cho bảng `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_order_items_order_id` (`order_id`),
  ADD KEY `idx_order_items_product_id` (`product_id`);

--
-- Chỉ mục cho bảng `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_otp_user_id` (`user_id`),
  ADD KEY `idx_otp_purpose` (`purpose`),
  ADD KEY `idx_otp_expires` (`expires_at`);

--
-- Chỉ mục cho bảng `outbox_events`
--
ALTER TABLE `outbox_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_outbox_status_next` (`status`,`next_run_at`),
  ADD KEY `idx_outbox_aggregate` (`aggregate_type`,`aggregate_id`);

--
-- Chỉ mục cho bảng `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `status` (`status`);

--
-- Chỉ mục cho bảng `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_products_slug` (`slug`),
  ADD KEY `idx_products_seller_id` (`seller_id`),
  ADD KEY `idx_products_category_id` (`category_id`),
  ADD KEY `idx_products_category` (`category`),
  ADD KEY `idx_products_status` (`status`),
  ADD KEY `idx_products_price` (`price`),
  ADD KEY `idx_products_avg_rating` (`avg_rating`);
ALTER TABLE `products` ADD FULLTEXT KEY `ft_products_search` (`name`,`description`,`category`);

--
-- Chỉ mục cho bảng `product_variants`
--
ALTER TABLE `product_variants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pv_sku` (`sku`),
  ADD KEY `idx_pv_product_id` (`product_id`),
  ADD KEY `idx_pv_attribute` (`attribute_name`,`attribute_value`),
  ADD KEY `idx_pv_stock` (`stock_quantity`);

--
-- Chỉ mục cho bảng `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_rt_user_id` (`user_id`),
  ADD KEY `idx_rt_token_hash` (`token_hash`),
  ADD KEY `idx_rt_expires_at` (`expires_at`);

--
-- Chỉ mục cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_review_buyer_product` (`buyer_id`,`product_id`),
  ADD KEY `idx_reviews_product_id` (`product_id`),
  ADD KEY `idx_reviews_buyer_id` (`buyer_id`),
  ADD KEY `idx_reviews_rating` (`rating`),
  ADD KEY `fk_reviews_order` (`order_id`);

--
-- Chỉ mục cho bảng `sample_requests`
--
ALTER TABLE `sample_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sr_buyer_id` (`buyer_id`),
  ADD KEY `idx_sr_seller_id` (`seller_id`),
  ADD KEY `idx_sr_product_id` (`product_id`);

--
-- Chỉ mục cho bảng `seller_profile_change_requests`
--
ALTER TABLE `seller_profile_change_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_spcr_seller` (`seller_id`),
  ADD KEY `idx_spcr_status` (`status`),
  ADD KEY `fk_spcr_admin` (`reviewed_by`);

--
-- Chỉ mục cho bảng `trusted_devices`
--
ALTER TABLE `trusted_devices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_td_user_id` (`user_id`),
  ADD KEY `idx_td_fingerprint` (`device_fingerprint`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD UNIQUE KEY `uq_users_username` (`username`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_is_active` (`is_active`),
  ADD KEY `idx_users_created_at` (`created_at`);

--
-- Chỉ mục cho bảng `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`user_id`);

--
-- Chỉ mục cho bảng `wallets`
--
ALTER TABLE `wallets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_wallet_user_id` (`user_id`),
  ADD KEY `idx_wallet_user_id` (`user_id`);

--
-- Chỉ mục cho bảng `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_wt_wallet_id` (`wallet_id`),
  ADD KEY `idx_wt_user_id` (`user_id`),
  ADD KEY `idx_wt_type` (`type`),
  ADD KEY `idx_wt_status` (`status`),
  ADD KEY `idx_wt_reference` (`reference_type`,`reference_id`),
  ADD KEY `idx_wt_created_at` (`created_at`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `logs`
--
ALTER TABLE `logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD CONSTRAINT `fk_chat_message_session` FOREIGN KEY (`session_id`) REFERENCES `chat_sessions` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `chat_sessions`
--
ALTER TABLE `chat_sessions`
  ADD CONSTRAINT `fk_chat_session_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `disputes`
--
ALTER TABLE `disputes`
  ADD CONSTRAINT `fk_disputes_complainant` FOREIGN KEY (`complainant_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_disputes_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `fk_disputes_resolved_by` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `dispute_chats`
--
ALTER TABLE `dispute_chats`
  ADD CONSTRAINT `fk_dc_dispute` FOREIGN KEY (`dispute_id`) REFERENCES `disputes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dc_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `escrow_transactions`
--
ALTER TABLE `escrow_transactions`
  ADD CONSTRAINT `fk_escrow_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_escrow_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `fk_escrow_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `logs`
--
ALTER TABLE `logs`
  ADD CONSTRAINT `fk_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_orders_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `order_histories`
--
ALTER TABLE `order_histories`
  ADD CONSTRAINT `fk_oh_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_oh_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Các ràng buộc cho bảng `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD CONSTRAINT `fk_otp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_products_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `product_variants`
--
ALTER TABLE `product_variants`
  ADD CONSTRAINT `fk_pv_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD CONSTRAINT `fk_rt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `fk_reviews_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_reviews_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `fk_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `sample_requests`
--
ALTER TABLE `sample_requests`
  ADD CONSTRAINT `fk_sr_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_sr_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `fk_sr_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`);

--
-- Các ràng buộc cho bảng `seller_profile_change_requests`
--
ALTER TABLE `seller_profile_change_requests`
  ADD CONSTRAINT `fk_spcr_admin` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_spcr_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `trusted_devices`
--
ALTER TABLE `trusted_devices`
  ADD CONSTRAINT `fk_td_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `fk_profiles_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `wallets`
--
ALTER TABLE `wallets`
  ADD CONSTRAINT `fk_wallet_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD CONSTRAINT `fk_wt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_wt_wallet` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
