#!/usr/bin/env php
<?php
/**
 * Migration: Add missing columns to currency_rates table
 * Date: 2025-10-13
 * 
 * This migration adds missing columns required by currency.php:
 * - currency_code (instead of just base/quote)
 * - rate_to_usd (conversion rate to USD)
 * - currency_symbol (e.g., $, €, FRw)
 * - currency_name (e.g., US Dollar, Euro, Rwandan Franc)
 * - last_updated (timestamp for cache invalidation)
 * 
 * Usage: php migrations/2025_10_13_000002_add_currency_rate_columns.php [up|down]
 */

// If running as a standalone script
if (basename(__FILE__) === basename($_SERVER['SCRIPT_FILENAME'])) {
    // Load database connection
    require_once __DIR__ . '/../includes/db.php';
    
    // Get command (up or down)
    $command = $argv[1] ?? 'up';
    
    // Load migration config
    $migration = include(__FILE__);
    
    try {
        $pdo = db();
        $pdo->beginTransaction();
        
        if ($command === 'up') {
            echo "Running migration: Add currency rate columns\n";
            $pdo->exec($migration['up']);
            echo "✓ Migration completed successfully\n";
        } elseif ($command === 'down') {
            echo "Rolling back migration: Add currency rate columns\n";
            $pdo->exec($migration['down']);
            echo "✓ Migration rolled back successfully\n";
        } else {
            echo "Usage: php migrations/2025_10_13_000002_add_currency_rate_columns.php [up|down]\n";
            exit(1);
        }
        
        $pdo->commit();
    } catch (Exception $e) {
        if (isset($pdo)) {
            $pdo->rollBack();
        }
        echo "✗ Migration failed: " . $e->getMessage() . "\n";
        exit(1);
    }
    
    exit(0);
}

// Otherwise, return migration config for use by migration runner
return [
    'up' => "
        -- Add currency_code column if it doesn't exist
        SET @dbname = DATABASE();
        SET @tablename = 'currency_rates';
        
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'currency_code');
        SET @query = IF(@col_exists = 0,
            'ALTER TABLE currency_rates ADD COLUMN currency_code CHAR(3) NULL AFTER id',
            'SELECT \"Column currency_code already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Add rate_to_usd column if it doesn't exist
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'rate_to_usd');
        SET @query = IF(@col_exists = 0,
            'ALTER TABLE currency_rates ADD COLUMN rate_to_usd DECIMAL(18,8) NULL COMMENT \"Exchange rate to USD\" AFTER rate',
            'SELECT \"Column rate_to_usd already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Add currency_symbol column if it doesn't exist
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'currency_symbol');
        SET @query = IF(@col_exists = 0,
            'ALTER TABLE currency_rates ADD COLUMN currency_symbol VARCHAR(10) NULL AFTER rate_to_usd',
            'SELECT \"Column currency_symbol already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Add currency_name column if it doesn't exist
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'currency_name');
        SET @query = IF(@col_exists = 0,
            'ALTER TABLE currency_rates ADD COLUMN currency_name VARCHAR(100) NULL AFTER currency_symbol',
            'SELECT \"Column currency_name already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Add last_updated column if it doesn't exist (alternative to updated_at)
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'last_updated');
        SET @query = IF(@col_exists = 0,
            'ALTER TABLE currency_rates ADD COLUMN last_updated TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER currency_name',
            'SELECT \"Column last_updated already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Insert default currency rates if table is empty or doesn't have currency_code entries
        -- Use base='USD' for all default entries to satisfy NOT NULL constraint
        INSERT INTO currency_rates (base, quote, rate, currency_code, rate_to_usd, currency_symbol, currency_name, last_updated)
        VALUES 
            ('USD', 'USD', 1.0, 'USD', 1.0, '$', 'US Dollar', CURRENT_TIMESTAMP),
            ('USD', 'EUR', 0.92, 'EUR', 0.92, '€', 'Euro', CURRENT_TIMESTAMP),
            ('USD', 'RWF', 1320.0, 'RWF', 1320.0, 'FRw', 'Rwandan Franc', CURRENT_TIMESTAMP)
        ON DUPLICATE KEY UPDATE 
            currency_code = VALUES(currency_code),
            rate_to_usd = VALUES(rate_to_usd),
            currency_symbol = VALUES(currency_symbol),
            currency_name = VALUES(currency_name);
        
        -- Create index on currency_code if it doesn't exist
        SET @index_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND INDEX_NAME = 'idx_currency_code');
        SET @query = IF(@index_exists = 0,
            'ALTER TABLE currency_rates ADD INDEX idx_currency_code (currency_code)',
            'SELECT \"Index idx_currency_code already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ",
    'down' => "
        -- Remove added columns if they exist
        SET @dbname = DATABASE();
        SET @tablename = 'currency_rates';
        
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'currency_code');
        SET @query = IF(@col_exists > 0,
            'ALTER TABLE currency_rates DROP COLUMN currency_code',
            'SELECT \"Column currency_code does not exist\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'rate_to_usd');
        SET @query = IF(@col_exists > 0,
            'ALTER TABLE currency_rates DROP COLUMN rate_to_usd',
            'SELECT \"Column rate_to_usd does not exist\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'currency_symbol');
        SET @query = IF(@col_exists > 0,
            'ALTER TABLE currency_rates DROP COLUMN currency_symbol',
            'SELECT \"Column currency_symbol does not exist\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'currency_name');
        SET @query = IF(@col_exists > 0,
            'ALTER TABLE currency_rates DROP COLUMN currency_name',
            'SELECT \"Column currency_name does not exist\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'last_updated');
        SET @query = IF(@col_exists > 0,
            'ALTER TABLE currency_rates DROP COLUMN last_updated',
            'SELECT \"Column last_updated does not exist\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    "
];
