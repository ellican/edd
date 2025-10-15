-- Migration to fix maintenance page database column issues
-- This migration adds missing columns to support the maintenance page functionality
-- Date: 2025-10-15
-- Description: Fixes issues with jobs and backups tables for maintenance page

-- Add missing columns to jobs table for maintenance page compatibility
ALTER TABLE `jobs` 
  ADD COLUMN IF NOT EXISTS `attempts` INT(11) NOT NULL DEFAULT 0 COMMENT 'Alias for retry_count, used by maintenance page',
  ADD COLUMN IF NOT EXISTS `max_attempts` INT(11) NOT NULL DEFAULT 3 COMMENT 'Alias for max_retries, used by maintenance page',
  ADD COLUMN IF NOT EXISTS `queue` VARCHAR(100) DEFAULT 'default' COMMENT 'Queue name for job processing';

-- Sync existing retry_count and max_retries values to new columns
UPDATE `jobs` SET `attempts` = `retry_count`, `max_attempts` = `max_retries` WHERE 1=1;

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS `idx_jobs_queue` ON `jobs` (`queue`);
CREATE INDEX IF NOT EXISTS `idx_jobs_attempts` ON `jobs` (`attempts`);

-- Add missing columns to backups table for maintenance page compatibility
ALTER TABLE `backups` 
  ADD COLUMN IF NOT EXISTS `filepath` VARCHAR(500) NULL COMMENT 'Alias for file_path, used by maintenance page',
  ADD COLUMN IF NOT EXISTS `description` TEXT NULL COMMENT 'Backup description for maintenance page';

-- Sync existing file_path values to filepath
UPDATE `backups` SET `filepath` = `file_path` WHERE 1=1;

-- Ensure system_events table exists for maintenance page logging
CREATE TABLE IF NOT EXISTS `system_events` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `event_type` VARCHAR(100) NOT NULL COMMENT 'Type of system event',
  `description` TEXT NULL COMMENT 'Event description',
  `metadata` LONGTEXT NULL COMMENT 'Additional event metadata (JSON)',
  `severity` ENUM('info','warning','error','critical') NOT NULL DEFAULT 'info',
  `created_by` INT(11) NULL COMMENT 'User who triggered the event',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_severity` (`severity`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_system_events_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Add triggers to keep attempts and retry_count in sync
DELIMITER //

DROP TRIGGER IF EXISTS `jobs_sync_attempts_on_insert` //
CREATE TRIGGER `jobs_sync_attempts_on_insert` BEFORE INSERT ON `jobs`
FOR EACH ROW
BEGIN
  IF NEW.attempts IS NULL OR NEW.attempts = 0 THEN
    SET NEW.attempts = NEW.retry_count;
  END IF;
  IF NEW.max_attempts IS NULL OR NEW.max_attempts = 0 THEN
    SET NEW.max_attempts = NEW.max_retries;
  END IF;
  IF NEW.queue IS NULL THEN
    SET NEW.queue = 'default';
  END IF;
END//

DROP TRIGGER IF EXISTS `jobs_sync_attempts_on_update` //
CREATE TRIGGER `jobs_sync_attempts_on_update` BEFORE UPDATE ON `jobs`
FOR EACH ROW
BEGIN
  -- If retry_count is updated, sync to attempts
  IF NEW.retry_count != OLD.retry_count THEN
    SET NEW.attempts = NEW.retry_count;
  END IF;
  -- If attempts is updated, sync to retry_count
  IF NEW.attempts != OLD.attempts THEN
    SET NEW.retry_count = NEW.attempts;
  END IF;
  -- If max_retries is updated, sync to max_attempts
  IF NEW.max_retries != OLD.max_retries THEN
    SET NEW.max_attempts = NEW.max_retries;
  END IF;
  -- If max_attempts is updated, sync to max_retries
  IF NEW.max_attempts != OLD.max_attempts THEN
    SET NEW.max_retries = NEW.max_attempts;
  END IF;
END//

DROP TRIGGER IF EXISTS `backups_sync_filepath_on_insert` //
CREATE TRIGGER `backups_sync_filepath_on_insert` BEFORE INSERT ON `backups`
FOR EACH ROW
BEGIN
  IF NEW.filepath IS NULL AND NEW.file_path IS NOT NULL THEN
    SET NEW.filepath = NEW.file_path;
  ELSEIF NEW.file_path IS NULL AND NEW.filepath IS NOT NULL THEN
    SET NEW.file_path = NEW.filepath;
  END IF;
END//

DROP TRIGGER IF EXISTS `backups_sync_filepath_on_update` //
CREATE TRIGGER `backups_sync_filepath_on_update` BEFORE UPDATE ON `backups`
FOR EACH ROW
BEGIN
  IF NEW.file_path != OLD.file_path THEN
    SET NEW.filepath = NEW.file_path;
  ELSEIF NEW.filepath != OLD.filepath THEN
    SET NEW.file_path = NEW.filepath;
  END IF;
END//

DELIMITER ;

-- Insert migration record
INSERT INTO migrations (filename, batch, executed_at)
VALUES ('2025_10_15_fix_maintenance_page_columns.sql', 
        (SELECT COALESCE(MAX(batch), 0) + 1 FROM (SELECT batch FROM migrations) AS m), 
        NOW())
ON DUPLICATE KEY UPDATE executed_at = NOW();
