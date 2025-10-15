-- Enhanced KYC Management System Migration
-- Implements comprehensive KYC/AML compliance features
-- Date: 2025-10-14

-- Create enhanced kyc_records table with full compliance features
CREATE TABLE IF NOT EXISTS `kyc_records` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `full_name` VARCHAR(255) NOT NULL,
  `id_type` VARCHAR(50) NOT NULL COMMENT 'passport, drivers_license, national_id, etc.',
  `id_number` VARCHAR(100) NOT NULL,
  `expiry_date` DATE NULL,
  `date_of_birth` DATE NULL,
  `nationality` VARCHAR(100) NULL,
  `address_line1` VARCHAR(255) NULL,
  `address_line2` VARCHAR(255) NULL,
  `city` VARCHAR(100) NULL,
  `state_province` VARCHAR(100) NULL,
  `postal_code` VARCHAR(20) NULL,
  `country` VARCHAR(100) NULL,
  `document_front` VARCHAR(255) NULL COMMENT 'Path to front of ID document',
  `document_back` VARCHAR(255) NULL COMMENT 'Path to back of ID document',
  `proof_of_address` VARCHAR(255) NULL COMMENT 'Path to proof of address document',
  `selfie_photo` VARCHAR(255) NULL COMMENT 'Path to selfie for face matching',
  `status` ENUM('pending','approved','rejected','expired','incomplete') DEFAULT 'pending',
  `risk_level` ENUM('low','medium','high','unknown') DEFAULT 'unknown',
  `verification_score` INT DEFAULT 0 COMMENT 'Automated verification score 0-100',
  `verified_by` BIGINT NULL COMMENT 'Admin user ID who verified',
  `verified_at` DATETIME NULL,
  `rejection_reason` TEXT NULL,
  `notes` TEXT NULL COMMENT 'Internal admin notes',
  `ip_address` VARCHAR(45) NULL,
  `user_agent` TEXT NULL,
  `metadata` JSON NULL COMMENT 'Additional metadata and custom fields',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME ON UPDATE CURRENT_TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_risk_level` (`risk_level`),
  INDEX `idx_verified_by` (`verified_by`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_expiry_date` (`expiry_date`),
  CONSTRAINT `fk_kyc_records_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_kyc_records_verifier` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create kyc_document_uploads table for multiple document tracking
CREATE TABLE IF NOT EXISTS `kyc_document_uploads` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `kyc_record_id` BIGINT NOT NULL,
  `document_category` VARCHAR(50) NOT NULL COMMENT 'identity, address, financial, business, etc.',
  `document_type` VARCHAR(50) NOT NULL,
  `file_path` VARCHAR(500) NOT NULL,
  `file_name` VARCHAR(255) NOT NULL,
  `file_size` BIGINT NOT NULL,
  `mime_type` VARCHAR(100) NOT NULL,
  `thumbnail_path` VARCHAR(500) NULL,
  `status` ENUM('pending','verified','rejected') DEFAULT 'pending',
  `uploaded_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_kyc_record_id` (`kyc_record_id`),
  INDEX `idx_document_category` (`document_category`),
  INDEX `idx_status` (`status`),
  CONSTRAINT `fk_kyc_documents_record` FOREIGN KEY (`kyc_record_id`) REFERENCES `kyc_records` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create kyc_verification_history table for audit trail
CREATE TABLE IF NOT EXISTS `kyc_verification_history` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `kyc_record_id` BIGINT NOT NULL,
  `action` VARCHAR(50) NOT NULL COMMENT 'submitted, approved, rejected, updated, expired',
  `old_status` VARCHAR(50) NULL,
  `new_status` VARCHAR(50) NULL,
  `performed_by` BIGINT NULL COMMENT 'User ID who performed the action',
  `notes` TEXT NULL,
  `metadata` JSON NULL,
  `ip_address` VARCHAR(45) NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_kyc_record_id` (`kyc_record_id`),
  INDEX `idx_action` (`action`),
  INDEX `idx_performed_by` (`performed_by`),
  INDEX `idx_created_at` (`created_at`),
  CONSTRAINT `fk_kyc_history_record` FOREIGN KEY (`kyc_record_id`) REFERENCES `kyc_records` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_kyc_history_user` FOREIGN KEY (`performed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create kyc_notifications table for tracking sent notifications
CREATE TABLE IF NOT EXISTS `kyc_notifications` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `kyc_record_id` BIGINT NOT NULL,
  `notification_type` VARCHAR(50) NOT NULL COMMENT 'approval, rejection, expiry_reminder, incomplete',
  `channel` ENUM('email','sms','in_app','push') NOT NULL,
  `recipient` VARCHAR(255) NOT NULL,
  `subject` VARCHAR(255) NULL,
  `message` TEXT NOT NULL,
  `status` ENUM('pending','sent','failed','delivered') DEFAULT 'pending',
  `sent_at` DATETIME NULL,
  `error_message` TEXT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_kyc_record_id` (`kyc_record_id`),
  INDEX `idx_notification_type` (`notification_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`),
  CONSTRAINT `fk_kyc_notifications_record` FOREIGN KEY (`kyc_record_id`) REFERENCES `kyc_records` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create kyc_automated_checks table for tracking automated verification checks
CREATE TABLE IF NOT EXISTS `kyc_automated_checks` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `kyc_record_id` BIGINT NOT NULL,
  `check_type` VARCHAR(50) NOT NULL COMMENT 'document_verification, face_match, address_validation, watchlist_screening',
  `provider` VARCHAR(100) NULL COMMENT 'API provider name if using external service',
  `status` ENUM('pending','passed','failed','error') DEFAULT 'pending',
  `score` DECIMAL(5,2) NULL COMMENT 'Confidence score 0-100',
  `result_data` JSON NULL COMMENT 'Full API response or check results',
  `error_message` TEXT NULL,
  `checked_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_kyc_record_id` (`kyc_record_id`),
  INDEX `idx_check_type` (`check_type`),
  INDEX `idx_status` (`status`),
  CONSTRAINT `fk_kyc_checks_record` FOREIGN KEY (`kyc_record_id`) REFERENCES `kyc_records` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create kyc_expiry_reminders table for scheduled reminders
CREATE TABLE IF NOT EXISTS `kyc_expiry_reminders` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `kyc_record_id` BIGINT NOT NULL,
  `reminder_date` DATE NOT NULL,
  `days_before_expiry` INT NOT NULL,
  `status` ENUM('pending','sent','failed') DEFAULT 'pending',
  `sent_at` DATETIME NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_kyc_record_id` (`kyc_record_id`),
  INDEX `idx_reminder_date` (`reminder_date`),
  INDEX `idx_status` (`status`),
  CONSTRAINT `fk_kyc_reminders_record` FOREIGN KEY (`kyc_record_id`) REFERENCES `kyc_records` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add indexes for seller_kyc table if not exists (for existing table)
ALTER TABLE `seller_kyc` ADD INDEX IF NOT EXISTS `idx_expires_at` (`expires_at`);
ALTER TABLE `seller_kyc` ADD INDEX IF NOT EXISTS `idx_updated_at` (`updated_at`);

-- Insert default admin permissions for KYC management
INSERT IGNORE INTO `permissions` (`name`, `description`, `category`) VALUES
('kyc.view', 'View KYC records', 'kyc'),
('kyc.create', 'Create KYC records', 'kyc'),
('kyc.edit', 'Edit KYC records', 'kyc'),
('kyc.approve', 'Approve KYC submissions', 'kyc'),
('kyc.reject', 'Reject KYC submissions', 'kyc'),
('kyc.delete', 'Delete KYC records', 'kyc'),
('kyc.export', 'Export KYC data', 'kyc'),
('kyc.bulk_actions', 'Perform bulk actions on KYC records', 'kyc');

-- Assign KYC permissions to admin role
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`)
SELECT r.id, p.id 
FROM `roles` r, `permissions` p 
WHERE r.name = 'admin' 
AND p.name LIKE 'kyc.%';
