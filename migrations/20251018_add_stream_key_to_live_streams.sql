-- Migration: Add stream_key column to live_streams table
-- This fixes the SQL error: "Field 'stream_key' doesn't have a default value"
-- Date: 2025-10-18

-- Add stream_key column if it doesn't exist
ALTER TABLE `live_streams` 
ADD COLUMN IF NOT EXISTS `stream_key` VARCHAR(128) NULL AFTER `vendor_id`;

-- Generate unique stream keys for existing streams that don't have one
UPDATE `live_streams` 
SET `stream_key` = CONCAT('stream_', id, '_', UNIX_TIMESTAMP(), '_', SUBSTRING(MD5(RAND()), 1, 16))
WHERE `stream_key` IS NULL OR `stream_key` = '';

-- Now make stream_key NOT NULL and UNIQUE after populating existing rows
ALTER TABLE `live_streams` 
MODIFY COLUMN `stream_key` VARCHAR(128) NOT NULL,
ADD UNIQUE KEY IF NOT EXISTS `idx_stream_key` (`stream_key`);
