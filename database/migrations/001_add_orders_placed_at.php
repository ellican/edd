<?php
/**
 * Migration: Add placed_at column to orders table
 * 
 * This migration adds the missing placed_at column that is referenced
 * in models_extended.php:467 for the trending products query.
 * 
 * Uses INFORMATION_SCHEMA checks to prevent duplicate column errors.
 */

return [
    'up' => "
        SET @dbname = DATABASE();
        SET @tablename = 'orders';
        SET @columnname = 'placed_at';
        
        -- Add placed_at column if it doesn't exist
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            'SELECT 1',
            'ALTER TABLE orders ADD COLUMN placed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER payment_transaction_id'
        ));
        PREPARE alterIfNotExists FROM @preparedStatement;
        EXECUTE alterIfNotExists;
        DEALLOCATE PREPARE alterIfNotExists;
        
        -- Update existing orders to set placed_at based on created_at
        UPDATE orders 
        SET placed_at = created_at 
        WHERE placed_at IS NULL OR placed_at = '0000-00-00 00:00:00';
        
        -- Add index for performance on the trending products query if it doesn't exist
        SET @indexname = 'idx_orders_placed_at_status';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (index_name = @indexname)
            ) > 0,
            'SELECT 1',
            'CREATE INDEX idx_orders_placed_at_status ON orders (placed_at, status)'
        ));
        PREPARE alterIfNotExists FROM @preparedStatement;
        EXECUTE alterIfNotExists;
        DEALLOCATE PREPARE alterIfNotExists;
    ",
    'down' => "
        SET @dbname = DATABASE();
        SET @tablename = 'orders';
        
        -- Drop index if it exists
        SET @indexname = 'idx_orders_placed_at_status';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (index_name = @indexname)
            ) > 0,
            'DROP INDEX idx_orders_placed_at_status ON orders',
            'SELECT 1'
        ));
        PREPARE alterIfExists FROM @preparedStatement;
        EXECUTE alterIfExists;
        DEALLOCATE PREPARE alterIfExists;
        
        -- Drop column if it exists
        SET @columnname = 'placed_at';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            'ALTER TABLE orders DROP COLUMN placed_at',
            'SELECT 1'
        ));
        PREPARE alterIfExists FROM @preparedStatement;
        EXECUTE alterIfExists;
        DEALLOCATE PREPARE alterIfExists;
    "
];