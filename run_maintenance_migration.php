#!/usr/bin/env php
<?php
/**
 * Run Maintenance Page Migration
 * This script applies the database changes needed for the maintenance page to work correctly
 */

echo "======================================\n";
echo "Maintenance Page Migration Script\n";
echo "======================================\n\n";

// Load database connection
require_once __DIR__ . '/includes/init.php';

try {
    $pdo = db();
    echo "✓ Database connection established\n\n";
    
    // Load and execute the migration
    $migrationFile = __DIR__ . '/database/migrations/2025_10_15_fix_maintenance_page_columns.php';
    
    if (!file_exists($migrationFile)) {
        echo "❌ Migration file not found: $migrationFile\n";
        exit(1);
    }
    
    echo "Loading migration...\n";
    $migration = require $migrationFile;
    
    if (!isset($migration['up']) || !is_callable($migration['up'])) {
        echo "❌ Invalid migration file format\n";
        exit(1);
    }
    
    echo "Executing migration...\n\n";
    $migration['up']($pdo);
    
    echo "\n======================================\n";
    echo "Migration completed successfully!\n";
    echo "======================================\n";
    echo "\nYou can now:\n";
    echo "1. Access the maintenance page at /admin/maintenance/\n";
    echo "2. Toggle maintenance mode on/off\n";
    echo "3. Create database backups\n";
    echo "4. Monitor and retry failed jobs\n";
    
} catch (Exception $e) {
    echo "\n❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
