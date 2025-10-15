<?php
/**
 * Migration: Create/update coupons table for full coupon management
 * 
 * This migration ensures the coupons table has all necessary fields
 */

return [
    'up' => "
        CREATE TABLE IF NOT EXISTS coupons (
            id INT AUTO_INCREMENT PRIMARY KEY,
            seller_id INT NOT NULL,
            code VARCHAR(80) NOT NULL UNIQUE,
            name VARCHAR(150) NULL,
            type ENUM('percentage','fixed') NOT NULL DEFAULT 'percentage',
            value DECIMAL(10,2) NOT NULL,
            min_purchase_amount DECIMAL(10,2) DEFAULT 0,
            max_discount_amount DECIMAL(10,2) NULL,
            usage_limit INT NULL,
            usage_count INT DEFAULT 0,
            applies_to ENUM('all','specific') DEFAULT 'all',
            applicable_products JSON NULL,
            start_date DATETIME NULL,
            end_date DATETIME NULL,
            status ENUM('active','inactive','expired') DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_seller_id (seller_id),
            INDEX idx_code (code),
            INDEX idx_status (status),
            INDEX idx_start_date (start_date),
            INDEX idx_end_date (end_date)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        
        -- Coupon usage tracking
        CREATE TABLE IF NOT EXISTS coupon_usage (
            id INT AUTO_INCREMENT PRIMARY KEY,
            coupon_id INT NOT NULL,
            user_id INT NOT NULL,
            order_id INT NULL,
            discount_amount DECIMAL(10,2) NOT NULL,
            used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_coupon_id (coupon_id),
            INDEX idx_user_id (user_id),
            INDEX idx_order_id (order_id),
            FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ",
    'down' => "
        DROP TABLE IF EXISTS coupon_usage;
        DROP TABLE IF EXISTS coupons;
    "
];
