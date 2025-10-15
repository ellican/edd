-- Migration: Admin Dashboard Enhancements
-- Date: 2025-10-15
-- Description: Ensures all necessary tables and columns exist for admin dashboards

-- =======================
-- 1. Roles and Permissions Tables
-- =======================
-- Ensure roles table exists with all necessary columns
CREATE TABLE IF NOT EXISTS `roles` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Internal role identifier (lowercase, underscores)',
  `display_name` VARCHAR(100) NOT NULL COMMENT 'Human-readable role name',
  `slug` VARCHAR(50) NOT NULL COMMENT 'URL-safe identifier',
  `description` TEXT DEFAULT NULL COMMENT 'Role description',
  `level` INT(11) NOT NULL DEFAULT 1 COMMENT 'Role hierarchy level',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Whether role is active',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`),
  UNIQUE KEY `idx_slug` (`slug`),
  KEY `idx_level` (`level`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User roles for RBAC system';

-- Ensure permissions table exists
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL UNIQUE COMMENT 'Permission identifier (e.g. products.create)',
  `display_name` VARCHAR(150) NOT NULL COMMENT 'Human-readable permission name',
  `description` TEXT DEFAULT NULL COMMENT 'Permission description',
  `module` VARCHAR(50) NOT NULL COMMENT 'Module/feature this permission belongs to',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`),
  KEY `idx_module` (`module`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Available permissions in the system';

-- Ensure role_permissions junction table exists
CREATE TABLE IF NOT EXISTS `role_permissions` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `role_id` INT(11) NOT NULL COMMENT 'Foreign key to roles table',
  `permission_id` INT(11) NOT NULL COMMENT 'Foreign key to permissions table',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_role_permission` (`role_id`, `permission_id`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_permission_id` (`permission_id`),
  CONSTRAINT `fk_role_permissions_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_role_permissions_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Maps permissions to roles';

-- Ensure user_roles junction table exists
CREATE TABLE IF NOT EXISTS `user_roles` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL COMMENT 'Foreign key to users table',
  `role_id` INT(11) NOT NULL COMMENT 'Foreign key to roles table',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_role` (`user_id`, `role_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_role_id` (`role_id`),
  CONSTRAINT `fk_user_roles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_roles_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Maps users to roles';

-- =======================
-- 2. KYC Tables Enhancement
-- =======================
-- Ensure kyc_documents table has all necessary fields
-- Note: This uses CREATE TABLE IF NOT EXISTS and ALTER TABLE to ensure compatibility
CREATE TABLE IF NOT EXISTS `kyc_documents` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL COMMENT 'Foreign key to users table',
  `document_type` ENUM('id_card','passport','drivers_license','proof_of_address','business_registration','tax_certificate') NOT NULL,
  `document_number` VARCHAR(100) DEFAULT NULL COMMENT 'Document identification number',
  `file_path` VARCHAR(500) NOT NULL COMMENT 'Path to uploaded document file',
  `original_filename` VARCHAR(255) NOT NULL COMMENT 'Original uploaded file name',
  `file_name` VARCHAR(255) NOT NULL COMMENT 'Stored file name',
  `file_size` INT(11) NOT NULL COMMENT 'File size in bytes',
  `mime_type` VARCHAR(100) NOT NULL COMMENT 'MIME type of uploaded file',
  `status` ENUM('pending','approved','rejected','expired') NOT NULL DEFAULT 'pending',
  `rejection_reason` TEXT DEFAULT NULL COMMENT 'Reason for rejection if applicable',
  `reviewed_by` INT(11) DEFAULT NULL COMMENT 'Admin user ID who reviewed',
  `reviewed_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'When document was reviewed',
  `review_notes` TEXT DEFAULT NULL COMMENT 'Admin notes from review',
  `expiry_date` DATE DEFAULT NULL COMMENT 'Document expiry date if applicable',
  `uploaded_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_reviewed_by` (`reviewed_by`),
  KEY `idx_uploaded_at` (`uploaded_at`),
  CONSTRAINT `fk_kyc_documents_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='KYC document submissions from users';

-- Add original_filename column if it doesn't exist
SET @dbname = DATABASE();
SET @tablename = 'kyc_documents';
SET @columnname = 'original_filename';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' VARCHAR(255) NOT NULL DEFAULT '''' AFTER file_path')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Ensure kyc_verifications table exists for overall user verification status
CREATE TABLE IF NOT EXISTS `kyc_verifications` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL COMMENT 'Foreign key to users table',
  `status` ENUM('pending','approved','rejected','under_review') NOT NULL DEFAULT 'pending',
  `verification_level` ENUM('basic','standard','enhanced') DEFAULT 'basic' COMMENT 'Level of verification completed',
  `verified_by` INT(11) DEFAULT NULL COMMENT 'Admin user ID who verified',
  `verified_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'When user was verified',
  `notes` TEXT DEFAULT NULL COMMENT 'Verification notes',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_verification_level` (`verification_level`),
  CONSTRAINT `fk_kyc_verifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Overall KYC verification status per user';

-- =======================
-- 3. Payment Tracking Enhancement
-- =======================
-- Ensure payments table has all necessary fields for tracking
-- This enhances the existing payments table with additional tracking columns

-- Add gateway column if missing
SET @columnname = 'gateway';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = DATABASE())
      AND (TABLE_NAME = 'payments')
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  'ALTER TABLE payments ADD COLUMN gateway VARCHAR(50) DEFAULT ''stripe'' COMMENT ''Payment gateway used'' AFTER stripe_customer_id'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add transaction_id column if missing (for gateway-specific transaction IDs)
SET @columnname = 'transaction_id';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = DATABASE())
      AND (TABLE_NAME = 'payments')
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  'ALTER TABLE payments ADD COLUMN transaction_id VARCHAR(255) DEFAULT NULL COMMENT ''Gateway transaction ID'' AFTER stripe_payment_intent_id'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Create payment_reconciliations table for tracking payment reconciliation
CREATE TABLE IF NOT EXISTS `payment_reconciliations` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `gateway` VARCHAR(50) NOT NULL COMMENT 'Payment gateway (stripe, paypal, etc)',
  `batch_id` VARCHAR(100) NOT NULL COMMENT 'Batch/settlement ID from gateway',
  `settlement_date` DATE NOT NULL COMMENT 'Date of settlement',
  `expected_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Expected settlement amount',
  `actual_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Actual settled amount',
  `fee_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Gateway fees',
  `transaction_count` INT(11) NOT NULL DEFAULT 0 COMMENT 'Number of transactions in batch',
  `status` ENUM('pending','matched','discrepancy','resolved') NOT NULL DEFAULT 'pending',
  `reconciled_by` INT(11) DEFAULT NULL COMMENT 'Admin user who reconciled',
  `reconciled_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'When reconciliation was done',
  `notes` TEXT DEFAULT NULL COMMENT 'Reconciliation notes',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_gateway` (`gateway`),
  KEY `idx_settlement_date` (`settlement_date`),
  KEY `idx_status` (`status`),
  KEY `idx_batch_id` (`batch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Payment reconciliation records';

-- =======================
-- 4. Product Management Enhancement
-- =======================
-- Add featured column to products table if missing
SET @tablename = 'products';
SET @columnname = 'featured';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = DATABASE())
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  'ALTER TABLE products ADD COLUMN featured TINYINT(1) NOT NULL DEFAULT 0 COMMENT ''Is product featured'' AFTER is_featured'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add is_featured column if missing (for backward compatibility)
SET @columnname = 'is_featured';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = DATABASE())
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  'ALTER TABLE products ADD COLUMN is_featured TINYINT(1) NOT NULL DEFAULT 0 COMMENT ''Is product featured'''
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add track_inventory column if missing
SET @columnname = 'track_inventory';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = DATABASE())
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  'ALTER TABLE products ADD COLUMN track_inventory TINYINT(1) NOT NULL DEFAULT 1 COMMENT ''Track inventory for this product'''
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- =======================
-- Usage Instructions
-- =======================
-- To apply this migration:
-- mysql -u [username] -p [database_name] < migrations/2025_10_15_admin_dashboard_enhancements.sql
--
-- This migration is idempotent - it can be run multiple times safely.
-- It uses CREATE TABLE IF NOT EXISTS and conditional ALTER TABLE statements.
