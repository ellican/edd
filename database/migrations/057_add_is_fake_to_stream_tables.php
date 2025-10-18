<?php
/**
 * Migration: Add is_fake column to stream tables
 * Adds is_fake column to stream_interactions and creates stream_viewers table if needed
 */

return [
    'up' => "
        -- Create stream_viewers table if it doesn't exist
        CREATE TABLE IF NOT EXISTS `stream_viewers` (
            `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            `stream_id` INT NOT NULL,
            `user_id` INT NULL,
            `session_id` VARCHAR(255) NULL,
            `is_fake` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Whether this is a fake/simulated viewer',
            `joined_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `left_at` TIMESTAMP NULL,
            `watch_duration` INT UNSIGNED NULL COMMENT 'Duration in seconds',
            INDEX `idx_stream_id` (`stream_id`),
            INDEX `idx_user_id` (`user_id`),
            INDEX `idx_session_id` (`session_id`),
            INDEX `idx_is_fake` (`is_fake`),
            INDEX `idx_active_viewers` (`stream_id`, `left_at`),
            FOREIGN KEY (`stream_id`) REFERENCES `live_streams`(`id`) ON DELETE CASCADE,
            FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        
        -- Create stream_engagement_config table if it doesn't exist
        CREATE TABLE IF NOT EXISTS `stream_engagement_config` (
            `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            `stream_id` INT NOT NULL,
            `fake_viewers_enabled` TINYINT(1) DEFAULT 1,
            `fake_likes_enabled` TINYINT(1) DEFAULT 1,
            `min_fake_viewers` INT UNSIGNED NOT NULL DEFAULT 10,
            `max_fake_viewers` INT UNSIGNED NOT NULL DEFAULT 50,
            `viewer_increase_rate` INT UNSIGNED NOT NULL DEFAULT 5 COMMENT 'Viewers added per increment',
            `viewer_decrease_rate` INT UNSIGNED NOT NULL DEFAULT 3 COMMENT 'Viewers removed per increment',
            `like_rate` INT UNSIGNED NOT NULL DEFAULT 2 COMMENT 'Likes added per increment',
            `engagement_multiplier` DECIMAL(3,2) NOT NULL DEFAULT 1.50 COMMENT 'Multiplier for engagement',
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY `unique_stream_config` (`stream_id`),
            FOREIGN KEY (`stream_id`) REFERENCES `live_streams`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ",
    
    'down' => "
        -- Drop stream_viewers table
        DROP TABLE IF EXISTS `stream_viewers`;
        
        -- Drop stream_engagement_config table
        DROP TABLE IF EXISTS `stream_engagement_config`;
    "
];
