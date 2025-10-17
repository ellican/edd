-- Enhanced Live Streaming System Migration
-- Adds fields for archived streams, video replays, and persistent engagement

-- Alter live_streams table to add new fields
ALTER TABLE `live_streams` 
ADD COLUMN IF NOT EXISTS `video_path` VARCHAR(500) NULL COMMENT 'Path to saved stream video/replay' AFTER `stream_url`,
ADD COLUMN IF NOT EXISTS `like_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Total likes for the stream' AFTER `max_viewers`,
ADD COLUMN IF NOT EXISTS `dislike_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Total dislikes for the stream' AFTER `like_count`,
ADD COLUMN IF NOT EXISTS `comment_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Total comments for the stream' AFTER `dislike_count`,
MODIFY COLUMN `status` ENUM('scheduled', 'live', 'ended', 'archived', 'cancelled') NOT NULL DEFAULT 'scheduled';

-- Create index for archived streams
ALTER TABLE `live_streams` ADD INDEX IF NOT EXISTS `idx_status_ended` (`status`, `ended_at`);

-- Add saved_streams table if it doesn't exist (for backward compatibility)
CREATE TABLE IF NOT EXISTS `saved_streams` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `stream_id` BIGINT UNSIGNED NOT NULL,
  `vendor_id` INT UNSIGNED NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `video_url` VARCHAR(500) NULL,
  `thumbnail_url` VARCHAR(500) NULL,
  `duration` INT UNSIGNED NOT NULL COMMENT 'Duration in seconds',
  `viewer_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `like_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `total_revenue` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `streamed_at` TIMESTAMP NOT NULL,
  `saved_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `views_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Views after stream ended',
  INDEX `idx_vendor_id` (`vendor_id`),
  INDEX `idx_streamed_at` (`streamed_at`),
  UNIQUE KEY `unique_stream` (`stream_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Update stream_engagement_config with better defaults
INSERT INTO `stream_engagement_config` 
  (`stream_id`, `fake_viewers_enabled`, `fake_likes_enabled`, 
   `min_fake_viewers`, `max_fake_viewers`, `viewer_increase_rate`, 
   `viewer_decrease_rate`, `like_rate`, `engagement_multiplier`)
SELECT 
  ls.id,
  1, -- fake_viewers_enabled
  1, -- fake_likes_enabled
  15, -- min_fake_viewers (increased from 10)
  100, -- max_fake_viewers (increased from 50)
  5, -- viewer_increase_rate (viewers added per minute)
  3, -- viewer_decrease_rate (viewers leaving per minute)
  3, -- like_rate (likes per minute)
  2.00 -- engagement_multiplier (fake viewers = real viewers * 2)
FROM `live_streams` ls
LEFT JOIN `stream_engagement_config` sec ON ls.id = sec.stream_id
WHERE sec.id IS NULL;

-- Create scheduled_streams view for easier querying
CREATE OR REPLACE VIEW `scheduled_streams_view` AS
SELECT 
  ls.*,
  v.business_name as vendor_name,
  v.id as vendor_id,
  TIMESTAMPDIFF(SECOND, NOW(), ls.scheduled_at) as seconds_until_start
FROM `live_streams` ls
JOIN `vendors` v ON ls.vendor_id = v.id
WHERE ls.status = 'scheduled' 
  AND ls.scheduled_at > NOW()
ORDER BY ls.scheduled_at ASC;

-- Create recent_streams view
CREATE OR REPLACE VIEW `recent_streams_view` AS
SELECT 
  ls.*,
  v.business_name as vendor_name,
  v.id as vendor_id,
  TIMESTAMPDIFF(SECOND, ls.started_at, ls.ended_at) as duration_seconds
FROM `live_streams` ls
JOIN `vendors` v ON ls.vendor_id = v.id
WHERE ls.status IN ('ended', 'archived')
  AND ls.ended_at IS NOT NULL
ORDER BY ls.ended_at DESC;
