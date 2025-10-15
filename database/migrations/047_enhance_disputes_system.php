<?php
/**
 * Migration: Enhance Disputes System
 * 
 * Creates comprehensive tables for dispute resolution with live chat integration
 */

return [
    'up' => "
        -- Disputes table with full tracking
        CREATE TABLE IF NOT EXISTS disputes (
            id INT AUTO_INCREMENT PRIMARY KEY,
            order_id INT NULL,
            user_id INT NOT NULL,
            vendor_id INT NULL,
            subject VARCHAR(255) NOT NULL,
            description TEXT NULL,
            status ENUM('pending','in_progress','escalated','resolved','closed') NOT NULL DEFAULT 'pending',
            priority ENUM('low','normal','high','critical') NOT NULL DEFAULT 'normal',
            assigned_to INT NULL,
            resolution_notes TEXT NULL,
            sla_deadline DATETIME NULL,
            resolved_at DATETIME NULL,
            closed_at DATETIME NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_order_id (order_id),
            INDEX idx_user_id (user_id),
            INDEX idx_vendor_id (vendor_id),
            INDEX idx_status (status),
            INDEX idx_priority (priority),
            INDEX idx_assigned_to (assigned_to),
            INDEX idx_sla_deadline (sla_deadline),
            INDEX idx_created_at (created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

        -- Dispute messages for chat history
        CREATE TABLE IF NOT EXISTS dispute_messages (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            dispute_id INT NOT NULL,
            sender_id INT NOT NULL,
            sender_type ENUM('user','admin','system') NOT NULL,
            message TEXT NOT NULL,
            attachments JSON NULL,
            is_internal TINYINT(1) DEFAULT 0,
            is_read TINYINT(1) DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_dispute_id (dispute_id),
            INDEX idx_sender_id (sender_id),
            INDEX idx_created_at (created_at),
            INDEX idx_is_read (is_read),
            FOREIGN KEY (dispute_id) REFERENCES disputes(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

        -- Dispute attachments
        CREATE TABLE IF NOT EXISTS dispute_attachments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            dispute_id INT NOT NULL,
            message_id BIGINT NULL,
            file_name VARCHAR(255) NOT NULL,
            file_path VARCHAR(500) NOT NULL,
            file_size INT NOT NULL,
            mime_type VARCHAR(100) NOT NULL,
            uploaded_by INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_dispute_id (dispute_id),
            INDEX idx_message_id (message_id),
            FOREIGN KEY (dispute_id) REFERENCES disputes(id) ON DELETE CASCADE,
            FOREIGN KEY (message_id) REFERENCES dispute_messages(id) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

        -- Dispute activity log for audit trail
        CREATE TABLE IF NOT EXISTS dispute_activity (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            dispute_id INT NOT NULL,
            actor_id INT NOT NULL,
            actor_type ENUM('user','admin','system') NOT NULL,
            action VARCHAR(100) NOT NULL,
            details JSON NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_dispute_id (dispute_id),
            INDEX idx_actor_id (actor_id),
            INDEX idx_created_at (created_at),
            FOREIGN KEY (dispute_id) REFERENCES disputes(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ",
    'down' => "
        DROP TABLE IF EXISTS dispute_activity;
        DROP TABLE IF EXISTS dispute_attachments;
        DROP TABLE IF EXISTS dispute_messages;
        DROP TABLE IF EXISTS disputes;
    "
];
