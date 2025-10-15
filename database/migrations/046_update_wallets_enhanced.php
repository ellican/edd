<?php
/**
 * Migration: Update wallets and wallet_transactions tables for enhanced functionality
 * 
 * This adds missing columns for status tracking, P2P transfers, and transaction metadata
 */

return [
    'up' => "
        -- Add status column to wallets table if it doesn't exist
        ALTER TABLE wallets 
        ADD COLUMN IF NOT EXISTS status ENUM('active','suspended') NOT NULL DEFAULT 'active' AFTER currency,
        ADD INDEX IF NOT EXISTS idx_status (status);
        
        -- Update wallet_transactions table structure
        ALTER TABLE wallet_transactions
        ADD COLUMN IF NOT EXISTS wallet_id INT NULL AFTER id,
        ADD COLUMN IF NOT EXISTS admin_id INT NULL AFTER wallet_id,
        ADD COLUMN IF NOT EXISTS from_user_id INT NULL AFTER amount,
        ADD COLUMN IF NOT EXISTS balance_before DECIMAL(18,2) NULL AFTER from_user_id,
        ADD COLUMN IF NOT EXISTS status ENUM('success','failed','pending') NOT NULL DEFAULT 'success' AFTER description,
        MODIFY COLUMN type ENUM('credit','debit','transfer') NOT NULL,
        ADD INDEX IF NOT EXISTS idx_wallet_id (wallet_id),
        ADD INDEX IF NOT EXISTS idx_status (status),
        ADD INDEX IF NOT EXISTS idx_from_user_id (from_user_id);
    ",
    'down' => "
        -- Revert wallet_transactions changes
        ALTER TABLE wallet_transactions
        DROP COLUMN IF EXISTS wallet_id,
        DROP COLUMN IF EXISTS admin_id,
        DROP COLUMN IF EXISTS from_user_id,
        DROP COLUMN IF EXISTS balance_before,
        DROP COLUMN IF EXISTS status,
        MODIFY COLUMN type ENUM('credit','debit') NOT NULL,
        DROP INDEX IF EXISTS idx_wallet_id,
        DROP INDEX IF EXISTS idx_status,
        DROP INDEX IF EXISTS idx_from_user_id;
        
        -- Revert wallets changes
        ALTER TABLE wallets
        DROP COLUMN IF EXISTS status,
        DROP INDEX IF EXISTS idx_status;
    "
];
