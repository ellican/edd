-- Marketing Campaigns Table
-- Migration for campaigns management system

CREATE TABLE IF NOT EXISTS `campaigns` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `type` ENUM('email', 'sms', 'push', 'banner', 'social') NOT NULL DEFAULT 'email',
  `description` TEXT NULL,
  `content` TEXT NOT NULL COMMENT 'Campaign content with HTML formatting',
  `status` ENUM('draft', 'scheduled', 'active', 'paused', 'completed', 'cancelled') NOT NULL DEFAULT 'draft',
  `start_date` DATETIME NULL,
  `end_date` DATETIME NULL,
  `budget` DECIMAL(10,2) NULL,
  `target_audience` VARCHAR(50) NOT NULL DEFAULT 'all',
  `created_by` INT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_status` (`status`),
  INDEX `idx_type` (`type`),
  INDEX `idx_start_date` (`start_date`),
  INDEX `idx_end_date` (`end_date`),
  INDEX `idx_created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Campaign Analytics Table
CREATE TABLE IF NOT EXISTS `campaign_analytics` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `campaign_id` INT UNSIGNED NOT NULL,
  `metric_type` ENUM('impression', 'click', 'conversion', 'open', 'bounce') NOT NULL,
  `metric_value` INT UNSIGNED NOT NULL DEFAULT 1,
  `user_id` INT UNSIGNED NULL,
  `session_id` VARCHAR(255) NULL,
  `ip_address` VARCHAR(45) NULL,
  `user_agent` TEXT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_campaign_id` (`campaign_id`),
  INDEX `idx_metric_type` (`metric_type`),
  INDEX `idx_created_at` (`created_at`),
  FOREIGN KEY (`campaign_id`) REFERENCES `campaigns`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
