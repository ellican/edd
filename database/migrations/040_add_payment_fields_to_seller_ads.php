<?php
/**
 * Migration: Add payment fields to seller_ads table
 * 
 * Adds payment tracking and product relationship to ads
 */

return [
    'up' => "
        ALTER TABLE seller_ads 
        ADD COLUMN IF NOT EXISTS product_ids JSON NULL AFTER target,
        ADD COLUMN IF NOT EXISTS duration_days INT DEFAULT 7 AFTER ends_at,
        ADD COLUMN IF NOT EXISTS cost DECIMAL(10,2) DEFAULT 0 AFTER budget,
        ADD COLUMN IF NOT EXISTS payment_status ENUM('pending','paid','failed','refunded') DEFAULT 'pending' AFTER status,
        ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50) NULL AFTER payment_status,
        ADD COLUMN IF NOT EXISTS payment_reference VARCHAR(255) NULL AFTER payment_method,
        ADD COLUMN IF NOT EXISTS payment_date TIMESTAMP NULL AFTER payment_reference,
        ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP NULL AFTER ends_at,
        ADD INDEX idx_payment_status (payment_status),
        ADD INDEX idx_expires_at (expires_at);
    ",
    'down' => "
        ALTER TABLE seller_ads 
        DROP COLUMN IF EXISTS expires_at,
        DROP COLUMN IF EXISTS payment_date,
        DROP COLUMN IF EXISTS payment_reference,
        DROP COLUMN IF EXISTS payment_method,
        DROP COLUMN IF EXISTS payment_status,
        DROP COLUMN IF EXISTS cost,
        DROP COLUMN IF EXISTS duration_days,
        DROP COLUMN IF EXISTS product_ids;
    "
];
