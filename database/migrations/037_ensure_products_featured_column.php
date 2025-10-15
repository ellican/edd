<?php
/**
 * Migration: Ensure featured column exists in products table (MySQL/MariaDB)
 * 
 * This migration ensures the featured column exists in the products table
 * for existing installations that might be missing it.
 */

return [
    'up' => "
        -- Add featured column if it doesn't exist
        SET @dbname = DATABASE();
        SET @tablename = 'products';
        SET @columnname = 'featured';
        SET @preparedStatement = (SELECT IF(
          (
            SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
            WHERE
              (table_name = @tablename)
              AND (table_schema = @dbname)
              AND (column_name = @columnname)
          ) > 0,
          'SELECT 1',
          CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' TINYINT(1) DEFAULT 0 AFTER status')
        ));
        PREPARE alterIfNotExists FROM @preparedStatement;
        EXECUTE alterIfNotExists;
        DEALLOCATE PREPARE alterIfNotExists;
    ",
    'down' => "
        -- Remove featured column if it exists
        SET @dbname = DATABASE();
        SET @tablename = 'products';
        SET @columnname = 'featured';
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
