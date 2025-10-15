<?php
/**
 * Migration: Create product inquiry messaging system
 * 
 * This migration creates tables for buyer-seller product inquiry conversations
 */

return [
    'up' => "
        -- Conversation threads (one per product per buyer-seller pair)
        CREATE TABLE IF NOT EXISTS conversation_threads (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            buyer_id INT NOT NULL,
            seller_id INT NOT NULL,
            status ENUM('active','archived','flagged') DEFAULT 'active',
            last_message_at TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY unique_thread (product_id, buyer_id, seller_id),
            INDEX idx_product_id (product_id),
            INDEX idx_buyer_id (buyer_id),
            INDEX idx_seller_id (seller_id),
            INDEX idx_status (status),
            INDEX idx_last_message_at (last_message_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        
        -- Product inquiry messages
        CREATE TABLE IF NOT EXISTS product_inquiry_messages (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            thread_id BIGINT NOT NULL,
            sender_id INT NOT NULL,
            receiver_id INT NOT NULL,
            sender_role ENUM('buyer','seller','admin') NOT NULL,
            message_text TEXT NOT NULL,
            attachment_path VARCHAR(500) NULL,
            attachment_type VARCHAR(50) NULL,
            attachment_size INT NULL,
            is_read TINYINT(1) DEFAULT 0,
            flagged TINYINT(1) DEFAULT 0,
            flagged_reason TEXT NULL,
            flagged_by INT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_thread_id (thread_id),
            INDEX idx_sender_id (sender_id),
            INDEX idx_receiver_id (receiver_id),
            INDEX idx_is_read (is_read),
            INDEX idx_flagged (flagged),
            INDEX idx_created_at (created_at),
            FOREIGN KEY (thread_id) REFERENCES conversation_threads(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        
        -- Message read receipts (track when messages are read)
        CREATE TABLE IF NOT EXISTS message_read_receipts (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            message_id BIGINT NOT NULL,
            user_id INT NOT NULL,
            read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_message_id (message_id),
            INDEX idx_user_id (user_id),
            FOREIGN KEY (message_id) REFERENCES product_inquiry_messages(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ",
    'down' => "
        DROP TABLE IF EXISTS message_read_receipts;
        DROP TABLE IF EXISTS product_inquiry_messages;
        DROP TABLE IF EXISTS conversation_threads;
    "
];
