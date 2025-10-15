<?php
/**
 * Migration: Fix Maintenance Page Column Issues
 * Date: 2025-10-15
 * 
 * This migration adds missing columns to support the maintenance page functionality
 * - Adds attempts, max_attempts, and queue columns to jobs table
 * - Adds filepath and description columns to backups table  
 * - Creates system_events table if it doesn't exist
 * - Creates triggers to keep columns in sync
 */

return [
    'up' => function($pdo) {
        echo "Running migration: Fix Maintenance Page Columns\n";
        
        try {
            // Check if columns exist before adding them
            $stmt = $pdo->query("SHOW COLUMNS FROM jobs LIKE 'attempts'");
            if ($stmt->rowCount() == 0) {
                echo "Adding 'attempts' column to jobs table...\n";
                $pdo->exec("ALTER TABLE `jobs` ADD COLUMN `attempts` INT(11) NOT NULL DEFAULT 0 COMMENT 'Alias for retry_count, used by maintenance page'");
                echo "✓ Added 'attempts' column\n";
            } else {
                echo "✓ 'attempts' column already exists\n";
            }
            
            $stmt = $pdo->query("SHOW COLUMNS FROM jobs LIKE 'max_attempts'");
            if ($stmt->rowCount() == 0) {
                echo "Adding 'max_attempts' column to jobs table...\n";
                $pdo->exec("ALTER TABLE `jobs` ADD COLUMN `max_attempts` INT(11) NOT NULL DEFAULT 3 COMMENT 'Alias for max_retries, used by maintenance page'");
                echo "✓ Added 'max_attempts' column\n";
            } else {
                echo "✓ 'max_attempts' column already exists\n";
            }
            
            $stmt = $pdo->query("SHOW COLUMNS FROM jobs LIKE 'queue'");
            if ($stmt->rowCount() == 0) {
                echo "Adding 'queue' column to jobs table...\n";
                $pdo->exec("ALTER TABLE `jobs` ADD COLUMN `queue` VARCHAR(100) DEFAULT 'default' COMMENT 'Queue name for job processing'");
                echo "✓ Added 'queue' column\n";
            } else {
                echo "✓ 'queue' column already exists\n";
            }
            
            // Sync existing values
            echo "Syncing retry_count and max_retries to new columns...\n";
            $pdo->exec("UPDATE `jobs` SET `attempts` = `retry_count`, `max_attempts` = `max_retries` WHERE `attempts` = 0");
            echo "✓ Synced existing values\n";
            
            // Add indexes
            try {
                echo "Adding indexes...\n";
                $pdo->exec("CREATE INDEX `idx_jobs_queue` ON `jobs` (`queue`)");
                echo "✓ Added idx_jobs_queue index\n";
            } catch (PDOException $e) {
                if (strpos($e->getMessage(), 'Duplicate key name') !== false) {
                    echo "✓ idx_jobs_queue index already exists\n";
                } else {
                    throw $e;
                }
            }
            
            try {
                $pdo->exec("CREATE INDEX `idx_jobs_attempts` ON `jobs` (`attempts`)");
                echo "✓ Added idx_jobs_attempts index\n";
            } catch (PDOException $e) {
                if (strpos($e->getMessage(), 'Duplicate key name') !== false) {
                    echo "✓ idx_jobs_attempts index already exists\n";
                } else {
                    throw $e;
                }
            }
            
            // Add columns to backups table
            $stmt = $pdo->query("SHOW COLUMNS FROM backups LIKE 'filepath'");
            if ($stmt->rowCount() == 0) {
                echo "Adding 'filepath' column to backups table...\n";
                $pdo->exec("ALTER TABLE `backups` ADD COLUMN `filepath` VARCHAR(500) NULL COMMENT 'Alias for file_path, used by maintenance page'");
                echo "✓ Added 'filepath' column\n";
            } else {
                echo "✓ 'filepath' column already exists\n";
            }
            
            $stmt = $pdo->query("SHOW COLUMNS FROM backups LIKE 'description'");
            if ($stmt->rowCount() == 0) {
                echo "Adding 'description' column to backups table...\n";
                $pdo->exec("ALTER TABLE `backups` ADD COLUMN `description` TEXT NULL COMMENT 'Backup description for maintenance page'");
                echo "✓ Added 'description' column\n";
            } else {
                echo "✓ 'description' column already exists\n";
            }
            
            // Sync file_path to filepath
            echo "Syncing file_path to filepath...\n";
            $pdo->exec("UPDATE `backups` SET `filepath` = `file_path` WHERE `filepath` IS NULL");
            echo "✓ Synced file_path values\n";
            
            // Create system_events table
            echo "Creating system_events table...\n";
            $pdo->exec("
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
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
            ");
            echo "✓ system_events table created\n";
            
            // Create triggers to keep columns in sync
            echo "Creating triggers...\n";
            
            // Drop triggers if they exist
            $pdo->exec("DROP TRIGGER IF EXISTS `jobs_sync_attempts_on_insert`");
            $pdo->exec("DROP TRIGGER IF EXISTS `jobs_sync_attempts_on_update`");
            $pdo->exec("DROP TRIGGER IF EXISTS `backups_sync_filepath_on_insert`");
            $pdo->exec("DROP TRIGGER IF EXISTS `backups_sync_filepath_on_update`");
            
            // Create triggers
            $pdo->exec("
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
                END
            ");
            
            $pdo->exec("
                CREATE TRIGGER `jobs_sync_attempts_on_update` BEFORE UPDATE ON `jobs`
                FOR EACH ROW
                BEGIN
                  IF NEW.retry_count != OLD.retry_count THEN
                    SET NEW.attempts = NEW.retry_count;
                  END IF;
                  IF NEW.attempts != OLD.attempts THEN
                    SET NEW.retry_count = NEW.attempts;
                  END IF;
                  IF NEW.max_retries != OLD.max_retries THEN
                    SET NEW.max_attempts = NEW.max_retries;
                  END IF;
                  IF NEW.max_attempts != OLD.max_attempts THEN
                    SET NEW.max_retries = NEW.max_attempts;
                  END IF;
                END
            ");
            
            $pdo->exec("
                CREATE TRIGGER `backups_sync_filepath_on_insert` BEFORE INSERT ON `backups`
                FOR EACH ROW
                BEGIN
                  IF NEW.filepath IS NULL AND NEW.file_path IS NOT NULL THEN
                    SET NEW.filepath = NEW.file_path;
                  ELSEIF NEW.file_path IS NULL AND NEW.filepath IS NOT NULL THEN
                    SET NEW.file_path = NEW.filepath;
                  END IF;
                END
            ");
            
            $pdo->exec("
                CREATE TRIGGER `backups_sync_filepath_on_update` BEFORE UPDATE ON `backups`
                FOR EACH ROW
                BEGIN
                  IF NEW.file_path != OLD.file_path THEN
                    SET NEW.filepath = NEW.file_path;
                  ELSEIF NEW.filepath != OLD.filepath THEN
                    SET NEW.file_path = NEW.filepath;
                  END IF;
                END
            ");
            
            echo "✓ All triggers created successfully\n";
            
            echo "\n✅ Migration completed successfully!\n";
            
        } catch (PDOException $e) {
            echo "❌ Migration failed: " . $e->getMessage() . "\n";
            throw $e;
        }
    },
    
    'down' => function($pdo) {
        echo "Rolling back migration: Fix Maintenance Page Columns\n";
        
        try {
            // Drop triggers
            $pdo->exec("DROP TRIGGER IF EXISTS `jobs_sync_attempts_on_insert`");
            $pdo->exec("DROP TRIGGER IF EXISTS `jobs_sync_attempts_on_update`");
            $pdo->exec("DROP TRIGGER IF EXISTS `backups_sync_filepath_on_insert`");
            $pdo->exec("DROP TRIGGER IF EXISTS `backups_sync_filepath_on_update`");
            
            // Drop columns from jobs
            $pdo->exec("ALTER TABLE `jobs` DROP COLUMN IF EXISTS `attempts`");
            $pdo->exec("ALTER TABLE `jobs` DROP COLUMN IF EXISTS `max_attempts`");
            $pdo->exec("ALTER TABLE `jobs` DROP COLUMN IF EXISTS `queue`");
            
            // Drop indexes
            try {
                $pdo->exec("DROP INDEX `idx_jobs_queue` ON `jobs`");
            } catch (PDOException $e) {
                // Index might not exist
            }
            try {
                $pdo->exec("DROP INDEX `idx_jobs_attempts` ON `jobs`");
            } catch (PDOException $e) {
                // Index might not exist
            }
            
            // Drop columns from backups
            $pdo->exec("ALTER TABLE `backups` DROP COLUMN IF EXISTS `filepath`");
            $pdo->exec("ALTER TABLE `backups` DROP COLUMN IF EXISTS `description`");
            
            // Note: We don't drop system_events table as it might have data
            
            echo "✅ Rollback completed successfully!\n";
            
        } catch (PDOException $e) {
            echo "❌ Rollback failed: " . $e->getMessage() . "\n";
            throw $e;
        }
    }
];
