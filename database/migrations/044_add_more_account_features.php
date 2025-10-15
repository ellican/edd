<?php
/**
 * Migration: Add More Account Features
 * 
 * Adds support for:
 * - Two-Factor Authentication (2FA) for users
 * - Login History tracking
 * - Support Tickets system
 * - Support Ticket Messages
 */

return [
    'up' => "
        -- Add two-factor authentication fields to users table
        ALTER TABLE users 
            ADD COLUMN IF NOT EXISTS two_factor_secret VARCHAR(255) NULL AFTER password,
            ADD COLUMN IF NOT EXISTS two_factor_enabled TINYINT(1) DEFAULT 0 AFTER two_factor_secret;
        
        -- Create login_history table to track user logins
        CREATE TABLE IF NOT EXISTS login_history (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            ip_address VARCHAR(45) NOT NULL,
            user_agent TEXT,
            login_time DATETIME DEFAULT CURRENT_TIMESTAMP,
            location VARCHAR(255) NULL,
            device_type VARCHAR(50) NULL,
            browser VARCHAR(50) NULL,
            os VARCHAR(50) NULL,
            status ENUM('success', 'failed', 'blocked') DEFAULT 'success',
            INDEX idx_user_id (user_id),
            INDEX idx_login_time (login_time),
            INDEX idx_status (status),
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        
        -- Create support_tickets table
        CREATE TABLE IF NOT EXISTS support_tickets (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            ticket_number VARCHAR(20) UNIQUE NOT NULL,
            subject VARCHAR(255) NOT NULL,
            category ENUM('technical', 'billing', 'product', 'shipping', 'account', 'other') DEFAULT 'other',
            priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
            status ENUM('open', 'in_progress', 'waiting_customer', 'resolved', 'closed') DEFAULT 'open',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            closed_at DATETIME NULL,
            assigned_to INT NULL,
            INDEX idx_user_id (user_id),
            INDEX idx_ticket_number (ticket_number),
            INDEX idx_status (status),
            INDEX idx_created_at (created_at),
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        
        -- Create support_ticket_messages table
        CREATE TABLE IF NOT EXISTS support_ticket_messages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            ticket_id INT NOT NULL,
            user_id INT NOT NULL,
            message TEXT NOT NULL,
            is_staff TINYINT(1) DEFAULT 0,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_ticket_id (ticket_id),
            INDEX idx_user_id (user_id),
            INDEX idx_created_at (created_at),
            FOREIGN KEY (ticket_id) REFERENCES support_tickets(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ",
    'down' => "
        -- Drop support ticket tables
        DROP TABLE IF EXISTS support_ticket_messages;
        DROP TABLE IF EXISTS support_tickets;
        DROP TABLE IF EXISTS login_history;
        
        -- Remove two-factor authentication fields from users table
        ALTER TABLE users 
            DROP COLUMN IF EXISTS two_factor_enabled,
            DROP COLUMN IF EXISTS two_factor_secret;
    "
];
