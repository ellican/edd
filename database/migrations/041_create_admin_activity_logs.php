<?php
/**
 * Migration: Create admin activity logs table
 * 
 * Track all administrative actions for audit trails
 */

return [
    'up' => "
        CREATE TABLE IF NOT EXISTS admin_activity_logs (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            admin_id INT NOT NULL,
            action_type VARCHAR(100) NOT NULL,
            target_type VARCHAR(50) NULL,
            target_id INT NULL,
            description TEXT NULL,
            old_value JSON NULL,
            new_value JSON NULL,
            ip_address VARCHAR(45) NULL,
            user_agent VARCHAR(500) NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_admin_id (admin_id),
            INDEX idx_action_type (action_type),
            INDEX idx_target (target_type, target_id),
            INDEX idx_created_at (created_at),
            FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ",
    'down' => "
        DROP TABLE IF EXISTS admin_activity_logs;
    "
];
