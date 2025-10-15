#!/usr/bin/env php
<?php
/**
 * Run Shipping Carriers Sort Order Fix Migration
 * This script applies the fix for the shipping_carriers sort_order column issue
 */

require_once __DIR__ . '/includes/db.php';

echo "=== Shipping Carriers Sort Order Fix Migration ===\n\n";

try {
    $pdo = db();
    
    // Load the migration file
    $migrationFile = __DIR__ . '/database/migrations/2025_10_15_fix_shipping_carriers_sort_order.php';
    
    if (!file_exists($migrationFile)) {
        throw new Exception("Migration file not found: $migrationFile");
    }
    
    require_once $migrationFile;
    
    // Run the up migration
    echo "Executing migration...\n\n";
    $result = up_2025_10_15_fix_shipping_carriers_sort_order($pdo);
    
    if ($result) {
        echo "\n✅ Migration completed successfully!\n";
        echo "The shipping_carriers table now has the sort_order column.\n";
        echo "The shipping dashboard should now work correctly.\n";
    } else {
        echo "\n⚠️ Migration completed with warnings. Please check the output above.\n";
    }
    
} catch (Exception $e) {
    echo "\n❌ Migration failed: " . $e->getMessage() . "\n";
    exit(1);
}
