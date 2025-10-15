#!/usr/bin/env php
<?php
/**
 * Migration: Create account-related tables
 * Date: 2025-10-12
 * 
 * This migration ensures all necessary tables and columns exist for the comprehensive
 * user account management system. It performs checks before creating or altering
 * to avoid errors if tables already exist.
 * 
 * Usage: php migrations/2025_10_12_000000_create_account_related_tables.php [up|down]
 */

// If running as a standalone script
if (basename(__FILE__) === basename($_SERVER['SCRIPT_FILENAME'])) {
    // Load database connection
    require_once __DIR__ . '/../includes/db.php';
    
    // Get command (up or down)
    $command = $argv[1] ?? 'up';
    
    // Load migration config
    $migration = include(__FILE__);
    
    try {
        $pdo = db();
        $pdo->beginTransaction();
        
        if ($command === 'up') {
            echo "Running migration: Create account-related tables\n";
            $pdo->exec($migration['up']);
            echo "✓ Migration completed successfully\n";
        } elseif ($command === 'down') {
            echo "Rolling back migration: Create account-related tables\n";
            $pdo->exec($migration['down']);
            echo "✓ Migration rolled back successfully\n";
        } else {
            echo "Usage: php migrations/2025_10_12_000000_create_account_related_tables.php [up|down]\n";
            exit(1);
        }
        
        $pdo->commit();
    } catch (Exception $e) {
        if (isset($pdo)) {
            $pdo->rollBack();
        }
        echo "✗ Migration failed: " . $e->getMessage() . "\n";
        exit(1);
    }
    
    exit(0);
}

// Otherwise, return migration config for use by migration runner
return [
    'up' => "
        -- Ensure users table has required columns for account management
        -- These columns may already exist, using IF NOT EXISTS for safety
        SET @dbname = DATABASE();
        SET @tablename = 'users';
        
        -- Add first_name if not exists
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'first_name');
        SET @query = IF(@col_exists = 0,
            'ALTER TABLE users ADD COLUMN first_name VARCHAR(50) NOT NULL AFTER pass_hash',
            'SELECT \"Column first_name already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Add last_name if not exists
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'last_name');
        SET @query = IF(@col_exists = 0,
            'ALTER TABLE users ADD COLUMN last_name VARCHAR(50) NOT NULL AFTER first_name',
            'SELECT \"Column last_name already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Add phone_number if not exists (alternative name check)
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'phone');
        SET @query = IF(@col_exists = 0,
            'ALTER TABLE users ADD COLUMN phone VARCHAR(20) NULL AFTER last_name',
            'SELECT \"Column phone already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Add avatar if not exists
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'avatar');
        SET @query = IF(@col_exists = 0,
            'ALTER TABLE users ADD COLUMN avatar VARCHAR(255) NULL AFTER status',
            'SELECT \"Column avatar already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Create orders table if not exists
        CREATE TABLE IF NOT EXISTS orders (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            order_number VARCHAR(50) NOT NULL,
            order_reference VARCHAR(50) NULL COMMENT 'Human-readable order reference',
            status ENUM('pending_payment','pending','processing','shipped','delivered','cancelled','refunded','failed') NOT NULL DEFAULT 'pending_payment',
            payment_status ENUM('pending','paid','failed','refunded','partial_refund') NOT NULL DEFAULT 'pending',
            payment_method VARCHAR(50) NULL,
            payment_transaction_id VARCHAR(255) NULL,
            subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
            tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
            shipping_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
            discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
            total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
            currency VARCHAR(3) NOT NULL DEFAULT 'USD',
            billing_address JSON NULL,
            shipping_address JSON NULL,
            shipping_method VARCHAR(100) NULL,
            tracking_number VARCHAR(100) NULL,
            tracking_url VARCHAR(500) NULL,
            notes TEXT NULL,
            admin_notes TEXT NULL,
            shipped_at TIMESTAMP NULL,
            delivered_at TIMESTAMP NULL,
            cancelled_at TIMESTAMP NULL,
            refunded_at TIMESTAMP NULL,
            placed_at TIMESTAMP NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_user_id (user_id),
            INDEX idx_order_number (order_number),
            INDEX idx_status (status),
            INDEX idx_created_at (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        
        -- Create order_items table if not exists
        CREATE TABLE IF NOT EXISTS order_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            order_id INT NOT NULL,
            product_id INT NOT NULL,
            vendor_id INT NULL,
            product_name VARCHAR(255) NOT NULL,
            sku VARCHAR(100) NULL,
            qty INT NOT NULL DEFAULT 1,
            price DECIMAL(10,2) NOT NULL,
            subtotal DECIMAL(10,2) NOT NULL,
            tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
            discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
            options JSON NULL,
            status ENUM('pending','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
            tracking_number VARCHAR(100) NULL,
            shipped_at TIMESTAMP NULL,
            delivered_at TIMESTAMP NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_order_id (order_id),
            INDEX idx_product_id (product_id),
            INDEX idx_vendor_id (vendor_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        
        -- Create addresses table if not exists
        CREATE TABLE IF NOT EXISTS addresses (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            type ENUM('billing','shipping','both') NOT NULL DEFAULT 'both',
            first_name VARCHAR(50) NULL,
            last_name VARCHAR(50) NULL,
            company VARCHAR(100) NULL,
            address_line1 VARCHAR(255) NOT NULL,
            address_line2 VARCHAR(255) NULL,
            city VARCHAR(100) NOT NULL,
            state VARCHAR(100) NOT NULL,
            postal_code VARCHAR(20) NOT NULL,
            country VARCHAR(2) NOT NULL DEFAULT 'US',
            phone VARCHAR(20) NULL,
            is_default TINYINT(1) NOT NULL DEFAULT 0,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_user_id (user_id),
            INDEX idx_type (type),
            INDEX idx_is_default (is_default)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        
        -- Create wishlists table if not exists
        CREATE TABLE IF NOT EXISTS wishlists (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            product_id INT NOT NULL,
            priority TINYINT(1) NOT NULL DEFAULT 3,
            notes TEXT NULL,
            price_alert TINYINT(1) NOT NULL DEFAULT 0,
            alert_price DECIMAL(10,2) NULL,
            notify_on_restock TINYINT(1) NOT NULL DEFAULT 0,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY idx_user_product (user_id, product_id),
            INDEX idx_product_id (product_id),
            INDEX idx_priority (priority),
            INDEX idx_price_alert (price_alert),
            INDEX idx_created_at (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        
        -- Create support_tickets table if not exists
        CREATE TABLE IF NOT EXISTS support_tickets (
            id INT AUTO_INCREMENT PRIMARY KEY,
            ticket_number VARCHAR(20) NOT NULL,
            user_id INT NULL,
            guest_email VARCHAR(255) NULL,
            guest_name VARCHAR(100) NULL,
            subject VARCHAR(255) NOT NULL,
            category ENUM('general','technical','billing','shipping','returns','product','account','complaint','suggestion') NOT NULL DEFAULT 'general',
            priority ENUM('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
            status ENUM('open','in_progress','pending_customer','pending_vendor','escalated','resolved','closed') NOT NULL DEFAULT 'open',
            description TEXT NOT NULL,
            resolution TEXT NULL,
            assigned_to INT NULL,
            escalated_to INT NULL,
            related_order_id INT NULL,
            related_product_id INT NULL,
            satisfaction_rating TINYINT(1) NULL,
            satisfaction_feedback TEXT NULL,
            tags JSON NULL,
            first_response_at TIMESTAMP NULL,
            resolved_at TIMESTAMP NULL,
            closed_at TIMESTAMP NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY idx_ticket_number (ticket_number),
            INDEX idx_user_id (user_id),
            INDEX idx_status (status),
            INDEX idx_priority (priority),
            INDEX idx_category (category),
            INDEX idx_assigned_to (assigned_to),
            INDEX idx_created_at (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ",
    'down' => "
        -- Rollback: Remove added columns from users table
        -- Note: We don't drop tables that may have been created before this migration
        -- Only drop columns that were added by this specific migration
        
        -- We don't actually remove columns in the down migration as it could cause data loss
        -- and these are core columns that should remain
        -- Instead, we just provide a notice
        SELECT 'Migration rollback: Columns and tables created by this migration are not removed to prevent data loss' as notice;
    "
];
