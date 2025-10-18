<?php
/**
 * Migration: Add duration_seconds to live_streams table
 * Adds duration_seconds column to store the total stream duration
 */

return [
    'up' => "
        -- Add duration_seconds column for stream duration tracking
        ALTER TABLE `live_streams` 
        ADD COLUMN IF NOT EXISTS `duration_seconds` INT UNSIGNED NULL COMMENT 'Total stream duration in seconds' AFTER `ended_at`;
        
        -- Create index for duration-based queries
        CREATE INDEX IF NOT EXISTS `idx_duration` ON `live_streams` (`duration_seconds`);
    ",
    
    'down' => "
        -- Remove duration_seconds column
        ALTER TABLE `live_streams` 
        DROP COLUMN IF EXISTS `duration_seconds`;
        
        -- Remove the index
        DROP INDEX IF EXISTS `idx_duration` ON `live_streams`;
    "
];
