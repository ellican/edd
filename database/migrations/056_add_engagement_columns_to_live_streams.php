<?php
/**
 * Migration: Add engagement columns to live_streams table
 * Adds like_count, dislike_count, comment_count, and video_path columns
 * Also updates status enum to include 'archived' status
 */

return [
    'up' => "
        -- Add video_path column for archived stream videos
        ALTER TABLE `live_streams` 
        ADD COLUMN IF NOT EXISTS `video_path` VARCHAR(500) NULL COMMENT 'Path to saved stream video/replay' AFTER `stream_url`;
        
        -- Add engagement count columns
        ALTER TABLE `live_streams` 
        ADD COLUMN IF NOT EXISTS `like_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Total likes for the stream' AFTER `max_viewers`,
        ADD COLUMN IF NOT EXISTS `dislike_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Total dislikes for the stream' AFTER `like_count`,
        ADD COLUMN IF NOT EXISTS `comment_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Total comments for the stream' AFTER `dislike_count`;
        
        -- Update status enum to include 'archived'
        ALTER TABLE `live_streams` 
        MODIFY COLUMN `status` ENUM('scheduled', 'live', 'ended', 'archived', 'cancelled') NOT NULL DEFAULT 'scheduled';
        
        -- Create index for archived streams
        CREATE INDEX IF NOT EXISTS `idx_status_ended` ON `live_streams` (`status`, `ended_at`);
    ",
    
    'down' => "
        -- Remove engagement count columns
        ALTER TABLE `live_streams` 
        DROP COLUMN IF EXISTS `comment_count`,
        DROP COLUMN IF EXISTS `dislike_count`,
        DROP COLUMN IF EXISTS `like_count`,
        DROP COLUMN IF EXISTS `video_path`;
        
        -- Revert status enum to original values
        ALTER TABLE `live_streams` 
        MODIFY COLUMN `status` ENUM('scheduled', 'live', 'ended', 'cancelled') NOT NULL DEFAULT 'scheduled';
        
        -- Remove the index
        DROP INDEX IF EXISTS `idx_status_ended` ON `live_streams`;
    "
];
