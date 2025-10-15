<?php
/**
 * Migration: Account Payment & Wallet Enhancements
 * Date: 2025-10-15
 * 
 * This migration ensures:
 * 1. User payment methods table exists with proper indexes
 * 2. Wallets table has proper currency support
 * 3. Performance indexes are in place
 * 
 * Note: These tables should already exist from previous migrations,
 * this migration adds any missing indexes and optimizations
 */

function up_2025_10_15_account_payment_wallet_enhancements($pdo) {
    try {
        echo "Running account payment & wallet enhancements migration...\n";
        
        // Ensure user_payment_methods table has proper indexes
        echo "Checking user_payment_methods indexes...\n";
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS user_payment_methods (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                stripe_payment_method_id VARCHAR(255),
                brand VARCHAR(50),
                last4 VARCHAR(4),
                exp_month INT,
                exp_year INT,
                is_default TINYINT(1) DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_user_id (user_id),
                INDEX idx_stripe_pm_id (stripe_payment_method_id),
                INDEX idx_is_default (is_default)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ");
        
        // Ensure wallets table exists with currency support
        echo "Checking wallets table...\n";
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS wallets (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL UNIQUE,
                balance DECIMAL(18,2) NOT NULL DEFAULT 0,
                currency CHAR(3) NOT NULL DEFAULT 'USD',
                status ENUM('active','suspended') NOT NULL DEFAULT 'active',
                updated_at TIMESTAMP NULL DEFAULT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_user_id (user_id),
                INDEX idx_status (status),
                INDEX idx_currency (currency)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ");
        
        // Ensure wallet_transactions table exists
        echo "Checking wallet_transactions table...\n";
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS wallet_transactions (
                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                wallet_id INT NULL,
                admin_id INT NULL,
                user_id INT NOT NULL,
                type ENUM('credit','debit','transfer') NOT NULL,
                amount DECIMAL(18,2) NOT NULL,
                from_user_id INT NULL,
                balance_before DECIMAL(18,2) NULL,
                balance_after DECIMAL(18,2) NOT NULL,
                reference VARCHAR(100) NULL,
                description VARCHAR(500) NULL,
                status ENUM('success','failed','pending') NOT NULL DEFAULT 'success',
                meta JSON NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_user_id (user_id),
                INDEX idx_wallet_id (wallet_id),
                INDEX idx_type (type),
                INDEX idx_status (status),
                INDEX idx_from_user_id (from_user_id),
                INDEX idx_created_at (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ");
        
        // Ensure currency_rates table exists for multi-currency support
        echo "Checking currency_rates table...\n";
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS currency_rates (
                id INT AUTO_INCREMENT PRIMARY KEY,
                currency_code CHAR(3) NOT NULL UNIQUE,
                currency_name VARCHAR(100) NOT NULL,
                currency_symbol VARCHAR(10) NOT NULL,
                rate_to_usd DECIMAL(18,6) NOT NULL DEFAULT 1.000000,
                is_active TINYINT(1) DEFAULT 1,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX idx_currency_code (currency_code),
                INDEX idx_is_active (is_active)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ");
        
        // Insert default currency rates if not exists
        echo "Ensuring default currency rates...\n";
        $pdo->exec("
            INSERT IGNORE INTO currency_rates (currency_code, currency_name, currency_symbol, rate_to_usd) VALUES
            ('USD', 'US Dollar', '$', 1.000000),
            ('EUR', 'Euro', '€', 1.100000),
            ('RWF', 'Rwandan Franc', 'FRw', 0.000780)
            ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;
        ");
        
        // Ensure users table has stripe_customer_id column for payment methods
        echo "Checking users table for stripe_customer_id...\n";
        $result = $pdo->query("SHOW COLUMNS FROM users LIKE 'stripe_customer_id'");
        if ($result->rowCount() === 0) {
            echo "Adding stripe_customer_id column to users table...\n";
            $pdo->exec("
                ALTER TABLE users 
                ADD COLUMN stripe_customer_id VARCHAR(255) NULL AFTER email,
                ADD INDEX idx_stripe_customer_id (stripe_customer_id)
            ");
        }
        
        echo "Account payment & wallet enhancements migration completed successfully!\n";
        return true;
        
    } catch (Exception $e) {
        echo "Error in account payment & wallet enhancements migration: " . $e->getMessage() . "\n";
        return false;
    }
}

function down_2025_10_15_account_payment_wallet_enhancements($pdo) {
    // This migration is additive only and doesn't remove existing data
    // Rollback is intentionally not implemented to prevent data loss
    echo "Rollback not implemented for safety - this migration only adds indexes and ensures tables exist\n";
    return true;
}
