<?php
/**
 * Migration: Add missing columns to currency_rates table
 * 
 * This migration adds missing columns required by currency.php:
 * - currency_code (for single currency lookup)
 * - rate_to_usd (conversion rate to USD)
 * - currency_symbol (e.g., $, €, FRw)
 * - currency_name (e.g., US Dollar, Euro, Rwandan Franc)
 * - last_updated (timestamp for cache invalidation)
 */

return [
    'up' => "
        SET @dbname = DATABASE();
        SET @tablename = 'currency_rates';
        
        -- Add currency_code column if it doesn't exist
        SET @columnname = 'currency_code';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            'SELECT 1',
            CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' CHAR(3) NULL AFTER id')
        ));
        PREPARE alterIfNotExists FROM @preparedStatement;
        EXECUTE alterIfNotExists;
        DEALLOCATE PREPARE alterIfNotExists;
        
        -- Add rate_to_usd column if it doesn't exist
        SET @columnname = 'rate_to_usd';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            'SELECT 1',
            CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' DECIMAL(18,8) NULL COMMENT ''Exchange rate to USD'' AFTER rate')
        ));
        PREPARE alterIfNotExists FROM @preparedStatement;
        EXECUTE alterIfNotExists;
        DEALLOCATE PREPARE alterIfNotExists;
        
        -- Add currency_symbol column if it doesn't exist
        SET @columnname = 'currency_symbol';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            'SELECT 1',
            CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' VARCHAR(10) NULL AFTER rate_to_usd')
        ));
        PREPARE alterIfNotExists FROM @preparedStatement;
        EXECUTE alterIfNotExists;
        DEALLOCATE PREPARE alterIfNotExists;
        
        -- Add currency_name column if it doesn't exist
        SET @columnname = 'currency_name';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            'SELECT 1',
            CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' VARCHAR(100) NULL AFTER currency_symbol')
        ));
        PREPARE alterIfNotExists FROM @preparedStatement;
        EXECUTE alterIfNotExists;
        DEALLOCATE PREPARE alterIfNotExists;
        
        -- Add last_updated column if it doesn't exist
        SET @columnname = 'last_updated';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            'SELECT 1',
            CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER currency_name')
        ));
        PREPARE alterIfNotExists FROM @preparedStatement;
        EXECUTE alterIfNotExists;
        DEALLOCATE PREPARE alterIfNotExists;
        
        -- Insert default currency rates if they don't exist
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
        SET @indexname = 'idx_currency_code';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (index_name = @indexname)
            ) > 0,
            'SELECT 1',
            CONCAT('ALTER TABLE ', @tablename, ' ADD INDEX ', @indexname, ' (currency_code)')
        ));
        PREPARE alterIfNotExists FROM @preparedStatement;
        EXECUTE alterIfNotExists;
        DEALLOCATE PREPARE alterIfNotExists;
    ",
    'down' => "
        SET @dbname = DATABASE();
        SET @tablename = 'currency_rates';
        
        -- Remove currency_code column if it exists
        SET @columnname = 'currency_code';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            CONCAT('ALTER TABLE ', @tablename, ' DROP COLUMN ', @columnname),
            'SELECT 1'
        ));
        PREPARE alterIfExists FROM @preparedStatement;
        EXECUTE alterIfExists;
        DEALLOCATE PREPARE alterIfExists;
        
        -- Remove rate_to_usd column if it exists
        SET @columnname = 'rate_to_usd';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            CONCAT('ALTER TABLE ', @tablename, ' DROP COLUMN ', @columnname),
            'SELECT 1'
        ));
        PREPARE alterIfExists FROM @preparedStatement;
        EXECUTE alterIfExists;
        DEALLOCATE PREPARE alterIfExists;
        
        -- Remove currency_symbol column if it exists
        SET @columnname = 'currency_symbol';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            CONCAT('ALTER TABLE ', @tablename, ' DROP COLUMN ', @columnname),
            'SELECT 1'
        ));
        PREPARE alterIfExists FROM @preparedStatement;
        EXECUTE alterIfExists;
        DEALLOCATE PREPARE alterIfExists;
        
        -- Remove currency_name column if it exists
        SET @columnname = 'currency_name';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            CONCAT('ALTER TABLE ', @tablename, ' DROP COLUMN ', @columnname),
            'SELECT 1'
        ));
        PREPARE alterIfExists FROM @preparedStatement;
        EXECUTE alterIfExists;
        DEALLOCATE PREPARE alterIfExists;
        
        -- Remove last_updated column if it exists
        SET @columnname = 'last_updated';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            CONCAT('ALTER TABLE ', @tablename, ' DROP COLUMN ', @columnname),
            'SELECT 1'
        ));
        PREPARE alterIfExists FROM @preparedStatement;
        EXECUTE alterIfExists;
        DEALLOCATE PREPARE alterIfExists;
    "
];
