#!/usr/bin/env php
<?php
/**
 * Migration: Add price_minor and subtotal_minor columns to order_items table
 * Date: 2025-10-13
 * 
 * This migration adds columns to store prices in minor currency units (cents)
 * which is required by the Stripe integration and checkout process.
 * 
 * Usage: php migrations/2025_10_13_000001_add_price_minor_columns_to_order_items.php [up|down]
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
            echo "Running migration: Add price_minor and subtotal_minor to order_items\n";
            $pdo->exec($migration['up']);
            echo "✓ Migration completed successfully\n";
        } elseif ($command === 'down') {
            echo "Rolling back migration: Add price_minor and subtotal_minor to order_items\n";
            $pdo->exec($migration['down']);
            echo "✓ Migration rolled back successfully\n";
        } else {
            echo "Usage: php migrations/2025_10_13_000001_add_price_minor_columns_to_order_items.php [up|down]\n";
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
        -- Add price_minor column to order_items if it doesn't exist
        SET @dbname = DATABASE();
        SET @tablename = 'order_items';
        
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'price_minor');
        SET @query = IF(@col_exists = 0,
            'ALTER TABLE order_items ADD COLUMN price_minor INT NOT NULL DEFAULT 0 COMMENT \"Price in minor currency units (cents)\" AFTER price',
            'SELECT \"Column price_minor already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Add subtotal_minor column to order_items if it doesn't exist
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'subtotal_minor');
        SET @query = IF(@col_exists = 0,
            'ALTER TABLE order_items ADD COLUMN subtotal_minor INT NOT NULL DEFAULT 0 COMMENT \"Subtotal in minor currency units (cents)\" AFTER subtotal',
            'SELECT \"Column subtotal_minor already exists\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ",
    'down' => "
        -- Remove price_minor and subtotal_minor columns if they exist
        SET @dbname = DATABASE();
        SET @tablename = 'order_items';
        
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'price_minor');
        SET @query = IF(@col_exists > 0,
            'ALTER TABLE order_items DROP COLUMN price_minor',
            'SELECT \"Column price_minor does not exist\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = 'subtotal_minor');
        SET @query = IF(@col_exists > 0,
            'ALTER TABLE order_items DROP COLUMN subtotal_minor',
            'SELECT \"Column subtotal_minor does not exist\" as message');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    "
];
