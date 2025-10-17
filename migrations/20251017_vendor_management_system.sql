-- ========================================
-- Vendor Management System Migration
-- Creates tables for comprehensive vendor management
-- ========================================

-- Vendor KYC Documents Table
-- DEPRECATED: This table is no longer used. Use seller_kyc table instead.
-- seller_kyc provides a more comprehensive KYC system with JSON document storage
-- This table is kept for backward compatibility only
CREATE TABLE IF NOT EXISTS `vendor_kyc` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `document_type` enum('business_license','tax_certificate','bank_statement','id_verification','proof_of_address','other') NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_size` int(11) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `status` enum('pending','in_review','approved','rejected','resubmission_required') NOT NULL DEFAULT 'pending',
  `verified_by` int(11) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_verified_by` (`verified_by`),
  CONSTRAINT `fk_vendor_kyc_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vendor_kyc_verifier` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Vendor Audit Logs Table
CREATE TABLE IF NOT EXISTS `vendor_audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `action` varchar(100) NOT NULL,
  `action_type` enum('status_change','kyc_verification','profile_update','account_suspension','bulk_action','other') NOT NULL DEFAULT 'other',
  `old_value` text DEFAULT NULL,
  `new_value` text DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_action_type` (`action_type`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_vendor_audit_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vendor_audit_admin` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Add missing columns to vendors table (if not exists)
ALTER TABLE `vendors` 
  ADD COLUMN IF NOT EXISTS `category` varchar(100) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `subcategory` varchar(100) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `kyc_status` enum('not_submitted','pending','in_review','approved','rejected') DEFAULT 'not_submitted',
  ADD COLUMN IF NOT EXISTS `kyc_verified_at` timestamp NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `last_activity_at` timestamp NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `total_products` int(11) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `total_sales` decimal(15,2) NOT NULL DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS `total_orders` int(11) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `rating` decimal(3,2) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `suspension_reason` text DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `suspended_at` timestamp NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `suspended_by` int(11) DEFAULT NULL;

-- Add indexes for vendor filtering and sorting
ALTER TABLE `vendors`
  ADD INDEX IF NOT EXISTS `idx_category` (`category`),
  ADD INDEX IF NOT EXISTS `idx_kyc_status` (`kyc_status`),
  ADD INDEX IF NOT EXISTS `idx_created_at` (`created_at`),
  ADD INDEX IF NOT EXISTS `idx_total_sales` (`total_sales`);

-- Create vendor activity tracking table
CREATE TABLE IF NOT EXISTS `vendor_activity_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `activity_type` enum('login','product_added','product_updated','order_processed','payout_requested','profile_updated','other') NOT NULL,
  `description` varchar(500) NOT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_activity_type` (`activity_type`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_vendor_activity_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Create feature flags table if not exists
CREATE TABLE IF NOT EXISTS `feature_flags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `flag_name` varchar(100) NOT NULL,
  `is_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_flag_name` (`flag_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Insert vendor management feature flag
INSERT INTO `feature_flags` (`flag_name`, `is_enabled`, `description`)
VALUES ('VENDOR_MGMT', 1, 'Enable comprehensive vendor management system with KYC, approval workflows, and audit logs')
ON DUPLICATE KEY UPDATE `description` = VALUES(`description`);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS `idx_vendor_status_kyc` ON `vendors` (`status`, `kyc_status`);
CREATE INDEX IF NOT EXISTS `idx_vendor_created_status` ON `vendors` (`created_at`, `status`);
