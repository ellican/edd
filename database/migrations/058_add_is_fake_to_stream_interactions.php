<?php
/**
 * Migration: Add is_fake column to stream_interactions table
 * This is a separate migration to handle the ALTER TABLE statement properly
 */

return [
    'up' => "
        -- Add is_fake column to stream_interactions (MySQL doesn't support IF NOT EXISTS in ALTER TABLE)
        -- This will fail if column already exists, but that's ok - we'll catch and skip
        ALTER TABLE `stream_interactions` 
        ADD COLUMN `is_fake` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Whether this is a fake/simulated interaction' AFTER `comment_text`;
        
        -- Add indexes
        ALTER TABLE `stream_interactions` 
        ADD INDEX `idx_is_fake` (`is_fake`);
        
        ALTER TABLE `stream_interactions` 
        ADD INDEX `idx_stream_fake` (`stream_id`, `is_fake`);
        
        -- Update existing interactions to have is_fake = 0 (real)
        UPDATE `stream_interactions` SET `is_fake` = 0 WHERE `is_fake` IS NULL;
    ",
    
    'down' => "
        -- Remove indexes
        ALTER TABLE `stream_interactions` 
        DROP INDEX IF EXISTS `idx_stream_fake`;
        
        ALTER TABLE `stream_interactions` 
        DROP INDEX IF EXISTS `idx_is_fake`;
        
        -- Remove is_fake column
        ALTER TABLE `stream_interactions` 
        DROP COLUMN IF EXISTS `is_fake`;
    "
];
