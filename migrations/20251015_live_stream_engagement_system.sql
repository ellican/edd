-- Live Stream Engagement Enhancement System
-- Migration for fake viewer and engagement generation

-- Live Streams Table (if not exists - enhanced)
CREATE TABLE IF NOT EXISTS `live_streams` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `vendor_id` INT UNSIGNED NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `thumbnail_url` VARCHAR(500) NULL,
  `stream_url` VARCHAR(500) NULL,
  `status` ENUM('scheduled', 'live', 'ended', 'cancelled') NOT NULL DEFAULT 'scheduled',
  `chat_enabled` TINYINT(1) DEFAULT 1,
  `viewer_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `max_viewers` INT UNSIGNED NOT NULL DEFAULT 0,
  `scheduled_at` TIMESTAMP NULL,
  `started_at` TIMESTAMP NULL,
  `ended_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_vendor_id` (`vendor_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_started_at` (`started_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stream Viewers Table (if not exists)
CREATE TABLE IF NOT EXISTS `stream_viewers` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `stream_id` BIGINT UNSIGNED NOT NULL,
  `user_id` INT UNSIGNED NULL,
  `session_id` VARCHAR(255) NULL,
  `is_fake` TINYINT(1) NOT NULL DEFAULT 0,
  `joined_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `left_at` TIMESTAMP NULL,
  `watch_duration` INT UNSIGNED NULL COMMENT 'Duration in seconds',
  INDEX `idx_stream_id` (`stream_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_session_id` (`session_id`),
  INDEX `idx_is_fake` (`is_fake`),
  INDEX `idx_active_viewers` (`stream_id`, `left_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stream Interactions Table (if not exists)
CREATE TABLE IF NOT EXISTS `stream_interactions` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `stream_id` BIGINT UNSIGNED NOT NULL,
  `user_id` INT UNSIGNED NULL,
  `interaction_type` ENUM('like', 'dislike', 'comment', 'share') NOT NULL,
  `comment_text` TEXT NULL,
  `is_fake` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_stream_id` (`stream_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_interaction_type` (`interaction_type`),
  INDEX `idx_is_fake` (`is_fake`),
  INDEX `idx_stream_type` (`stream_id`, `interaction_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stream Products Table (if not exists)
CREATE TABLE IF NOT EXISTS `live_stream_products` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `stream_id` BIGINT UNSIGNED NOT NULL,
  `product_id` INT UNSIGNED NOT NULL,
  `special_price` DECIMAL(10,2) NULL,
  `discount_percentage` DECIMAL(5,2) NULL,
  `display_order` INT NOT NULL DEFAULT 0,
  `is_featured` TINYINT(1) DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_stream_id` (`stream_id`),
  INDEX `idx_product_id` (`product_id`),
  UNIQUE KEY `unique_stream_product` (`stream_id`, `product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Fake Engagement Configuration Table
CREATE TABLE IF NOT EXISTS `stream_engagement_config` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `stream_id` BIGINT UNSIGNED NOT NULL,
  `fake_viewers_enabled` TINYINT(1) DEFAULT 1,
  `fake_likes_enabled` TINYINT(1) DEFAULT 1,
  `min_fake_viewers` INT UNSIGNED NOT NULL DEFAULT 10,
  `max_fake_viewers` INT UNSIGNED NOT NULL DEFAULT 50,
  `viewer_increase_rate` INT UNSIGNED NOT NULL DEFAULT 5 COMMENT 'Viewers per minute',
  `viewer_decrease_rate` INT UNSIGNED NOT NULL DEFAULT 3 COMMENT 'Viewers per minute',
  `like_rate` INT UNSIGNED NOT NULL DEFAULT 2 COMMENT 'Likes per minute',
  `engagement_multiplier` DECIMAL(3,2) NOT NULL DEFAULT 1.00 COMMENT 'Multiplier for engagement',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_stream_config` (`stream_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stream Orders Table (if not exists)
CREATE TABLE IF NOT EXISTS `stream_orders` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `stream_id` BIGINT UNSIGNED NOT NULL,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_stream_id` (`stream_id`),
  INDEX `idx_order_id` (`order_id`),
  UNIQUE KEY `unique_stream_order` (`stream_id`, `order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
