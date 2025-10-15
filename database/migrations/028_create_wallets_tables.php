<?php
/**
 * Migration: Create wallets and wallet_transactions tables
 * 
 * This creates tables for user wallet balances and transaction history
 */

return [
    'up' => "
        CREATE TABLE IF NOT EXISTS wallets (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL UNIQUE,
            balance DECIMAL(18,2) NOT NULL DEFAULT 0,
            currency CHAR(3) NOT NULL DEFAULT 'USD',
            status ENUM('active','suspended') NOT NULL DEFAULT 'active',
            updated_at TIMESTAMP NULL DEFAULT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_user_id (user_id),
            INDEX idx_status (status)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
    ",
    'down' => "
        DROP TABLE IF EXISTS wallet_transactions;
        DROP TABLE IF EXISTS wallets;
    "
];
