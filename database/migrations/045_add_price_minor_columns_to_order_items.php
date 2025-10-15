<?php
/**
 * Migration: Add price_minor and subtotal_minor columns to order_items table
 * 
 * This migration adds columns to store prices in minor currency units (cents)
 * which is required by the Stripe integration and checkout process.
 */

return [
    'up' => "
        -- Add price_minor column to order_items if it doesn't exist
        SET @dbname = DATABASE();
        SET @tablename = 'order_items';
        SET @columnname = 'price_minor';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            'SELECT 1',
            CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' INT NOT NULL DEFAULT 0 COMMENT ''Price in minor currency units (cents)'' AFTER price')
        ));
        PREPARE alterIfNotExists FROM @preparedStatement;
        EXECUTE alterIfNotExists;
        DEALLOCATE PREPARE alterIfNotExists;
        
        -- Add subtotal_minor column to order_items if it doesn't exist
        SET @columnname = 'subtotal_minor';
        SET @preparedStatement = (SELECT IF(
            (
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE
                    (table_name = @tablename)
                    AND (table_schema = @dbname)
                    AND (column_name = @columnname)
            ) > 0,
            'SELECT 1',
            CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' INT NOT NULL DEFAULT 0 COMMENT ''Subtotal in minor currency units (cents)'' AFTER subtotal')
        ));
        PREPARE alterIfNotExists FROM @preparedStatement;
        EXECUTE alterIfNotExists;
        DEALLOCATE PREPARE alterIfNotExists;
    ",
    'down' => "
        -- Remove price_minor and subtotal_minor columns if they exist
        SET @dbname = DATABASE();
        SET @tablename = 'order_items';
        SET @columnname = 'price_minor';
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
        
        SET @columnname = 'subtotal_minor';
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
