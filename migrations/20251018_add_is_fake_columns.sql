-- Add is_fake columns to stream_viewers and stream_interactions tables
-- This migration adds missing columns needed for fake engagement tracking
-- MariaDB 10.5+ supports IF NOT EXISTS in ALTER TABLE

-- Add is_fake column to stream_viewers if it doesn't exist
ALTER TABLE `stream_viewers` 
ADD COLUMN IF NOT EXISTS `is_fake` TINYINT(1) NOT NULL DEFAULT 0 AFTER `session_id`;

-- Add index for is_fake in stream_viewers
ALTER TABLE `stream_viewers`
ADD INDEX IF NOT EXISTS `idx_is_fake` (`is_fake`);

-- Add is_fake column to stream_interactions if it doesn't exist
ALTER TABLE `stream_interactions` 
ADD COLUMN IF NOT EXISTS `is_fake` TINYINT(1) NOT NULL DEFAULT 0 AFTER `comment_text`;

-- Add index for is_fake in stream_interactions
ALTER TABLE `stream_interactions`
ADD INDEX IF NOT EXISTS `idx_is_fake` (`is_fake`);

-- Add left_at column to stream_viewers if it doesn't exist (needed for fake engagement cleanup)
ALTER TABLE `stream_viewers` 
ADD COLUMN IF NOT EXISTS `left_at` TIMESTAMP NULL AFTER `joined_at`;

-- Add watch_duration column to stream_viewers if it doesn't exist
ALTER TABLE `stream_viewers` 
ADD COLUMN IF NOT EXISTS `watch_duration` INT UNSIGNED NULL COMMENT 'Duration in seconds' AFTER `left_at`;

-- Add composite index for active viewers
ALTER TABLE `stream_viewers`
ADD INDEX IF NOT EXISTS `idx_active_viewers` (`stream_id`, `left_at`);
