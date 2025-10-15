<?php
/**
 * Migration: Add additional columns to orders table for enhanced tracking
 */

return [
    'up' => "
        -- Add tracking number if it doesn't exist
        ALTER TABLE orders 
        ADD COLUMN IF NOT EXISTS tracking_number VARCHAR(100) NULL AFTER order_number,
        ADD COLUMN IF NOT EXISTS tracking_url VARCHAR(500) NULL AFTER tracking_number,
        ADD COLUMN IF NOT EXISTS shipped_at TIMESTAMP NULL AFTER status,
        ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMP NULL AFTER shipped_at,
        ADD INDEX IF NOT EXISTS idx_tracking_number (tracking_number);
        
        -- Add payment transaction ID for Stripe
        ALTER TABLE orders
        ADD COLUMN IF NOT EXISTS payment_transaction_id VARCHAR(255) NULL AFTER payment_method,
        ADD INDEX IF NOT EXISTS idx_payment_transaction_id (payment_transaction_id);
    ",
    'down' => "
        ALTER TABLE orders
        DROP COLUMN IF EXISTS tracking_number,
        DROP COLUMN IF EXISTS tracking_url,
        DROP COLUMN IF EXISTS shipped_at,
        DROP COLUMN IF EXISTS delivered_at,
        DROP COLUMN IF EXISTS payment_transaction_id;
    "
];
