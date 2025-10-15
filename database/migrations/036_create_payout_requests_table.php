<?php
/**
 * Migration: Create payout_requests table
 * 
 * This table tracks payout requests from users wanting to withdraw wallet funds
 */

return [
    'up' => "
        CREATE TABLE IF NOT EXISTS payout_requests (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            amount DECIMAL(18,2) NOT NULL,
            currency CHAR(3) NOT NULL DEFAULT 'USD',
            status ENUM('pending', 'approved', 'processing', 'completed', 'rejected', 'cancelled') NOT NULL DEFAULT 'pending',
            payout_method VARCHAR(50) NOT NULL,
            payout_details JSON NULL,
            admin_notes TEXT NULL,
            processed_by INT NULL,
            processed_at TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NULL DEFAULT NULL,
            INDEX idx_user_id (user_id),
            INDEX idx_status (status),
            INDEX idx_created_at (created_at),
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (processed_by) REFERENCES users(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ",
    'down' => "
        DROP TABLE IF EXISTS payout_requests;
    "
];
