<?php
/**
 * Migration: Ensure email_logs table exists for email tracking
 * Adds comprehensive logging for email delivery monitoring
 */

return [
    'up' => "
        -- Create email_logs table if it doesn't exist
        CREATE TABLE IF NOT EXISTS `email_logs` (
            `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            `user_id` INT UNSIGNED NULL,
            `to_email` VARCHAR(255) NOT NULL,
            `subject` VARCHAR(500) NOT NULL,
            `status` ENUM('sent', 'failed', 'error', 'bounced') NOT NULL,
            `error_message` TEXT NULL,
            `sent_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX `idx_user_id` (`user_id`),
            INDEX `idx_to_email` (`to_email`),
            INDEX `idx_status` (`status`),
            INDEX `idx_sent_at` (`sent_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        
        -- Add bounce tracking table
        CREATE TABLE IF NOT EXISTS `email_bounces` (
            `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            `email` VARCHAR(255) NOT NULL,
            `bounce_type` ENUM('hard', 'soft', 'complaint') NOT NULL,
            `bounce_reason` TEXT NULL,
            `bounced_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX `idx_email` (`email`),
            INDEX `idx_bounce_type` (`bounce_type`),
            INDEX `idx_bounced_at` (`bounced_at`),
            UNIQUE KEY `unique_email_bounce` (`email`, `bounce_type`, `bounced_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ",
    
    'down' => "
        -- Remove email logging tables
        DROP TABLE IF EXISTS `email_bounces`;
        DROP TABLE IF EXISTS `email_logs`;
    "
];
