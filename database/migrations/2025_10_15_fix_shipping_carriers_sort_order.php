<?php
/**
 * Fix Shipping Carriers Sort Order Column
 * Date: 2025-10-15
 * 
 * This migration ensures the shipping_carriers table has the sort_order column
 * to fix the error: "Column not found: 1054 Unknown column 'sort_order' in 'ORDER BY'"
 */

function up_2025_10_15_fix_shipping_carriers_sort_order($pdo) {
    try {
        echo "Fixing shipping_carriers table sort_order column...\n";
        
        // First, ensure the shipping_carriers table exists
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS `shipping_carriers` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
              `name` varchar(100) NOT NULL,
              `code` varchar(50) NOT NULL,
              `tracking_url` varchar(500) DEFAULT NULL,
              `api_url` varchar(500) DEFAULT NULL,
              `api_key` varchar(255) DEFAULT NULL,
              `api_secret` varchar(255) DEFAULT NULL,
              `webhook_url` varchar(500) DEFAULT NULL,
              `is_active` tinyint(1) NOT NULL DEFAULT 1,
              `supports_live_rates` tinyint(1) NOT NULL DEFAULT 0,
              `enabled_for_sellers` tinyint(1) NOT NULL DEFAULT 0,
              `sort_order` int(11) DEFAULT 0,
              `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
              `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
              PRIMARY KEY (`id`),
              UNIQUE KEY `code` (`code`),
              KEY `idx_is_active` (`is_active`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ");
        echo "✓ Shipping carriers table structure verified\n";
        
        // Check if sort_order column exists
        $result = $pdo->query("
            SELECT COUNT(*) as count 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = DATABASE() 
            AND TABLE_NAME = 'shipping_carriers' 
            AND COLUMN_NAME = 'sort_order'
        ")->fetch();
        
        if ($result['count'] == 0) {
            echo "Adding sort_order column to shipping_carriers table...\n";
            $pdo->exec("ALTER TABLE shipping_carriers ADD COLUMN sort_order INT(11) DEFAULT 0 AFTER enabled_for_sellers");
            echo "✓ sort_order column added successfully\n";
        } else {
            echo "✓ sort_order column already exists\n";
        }
        
        // Ensure all required API fields exist
        $requiredFields = [
            'api_url' => "VARCHAR(500) DEFAULT NULL",
            'api_key' => "VARCHAR(255) DEFAULT NULL",
            'api_secret' => "VARCHAR(255) DEFAULT NULL",
            'webhook_url' => "VARCHAR(500) DEFAULT NULL",
            'supports_live_rates' => "TINYINT(1) NOT NULL DEFAULT 0",
            'enabled_for_sellers' => "TINYINT(1) NOT NULL DEFAULT 0"
        ];
        
        foreach ($requiredFields as $column => $definition) {
            $result = $pdo->query("
                SELECT COUNT(*) as count 
                FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_SCHEMA = DATABASE() 
                AND TABLE_NAME = 'shipping_carriers' 
                AND COLUMN_NAME = '$column'
            ")->fetch();
            
            if ($result['count'] == 0) {
                echo "Adding $column to shipping_carriers table...\n";
                $pdo->exec("ALTER TABLE shipping_carriers ADD COLUMN $column $definition");
                echo "✓ $column column added successfully\n";
            }
        }
        
        echo "✓ Shipping carriers migration completed successfully\n";
        return true;
    } catch (Exception $e) {
        echo "✗ Error in shipping carriers migration: " . $e->getMessage() . "\n";
        throw $e;
    }
}

function down_2025_10_15_fix_shipping_carriers_sort_order($pdo) {
    try {
        echo "Rolling back shipping_carriers sort_order fix...\n";
        // We don't remove the column in rollback as it may contain data
        // and the table structure should remain consistent
        echo "✓ Rollback completed (columns preserved for data safety)\n";
        return true;
    } catch (Exception $e) {
        echo "✗ Error in rollback: " . $e->getMessage() . "\n";
        throw $e;
    }
}
