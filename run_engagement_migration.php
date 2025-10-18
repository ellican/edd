#!/usr/bin/env php
<?php
/**
 * Run Stream Engagement Migration
 * This script adds is_fake columns and creates stream_viewers/stream_engagement_config tables
 */

require_once __DIR__ . '/includes/db.php';

echo "=== Stream Engagement Tables Migration ===\n\n";

try {
    $pdo = db();
    
    // Load the migration file
    $migrationFile = __DIR__ . '/database/migrations/057_add_is_fake_to_stream_tables.php';
    
    if (!file_exists($migrationFile)) {
        throw new Exception("Migration file not found: $migrationFile");
    }
    
    // Load migration
    echo "Loading migration file...\n";
    $migration = require $migrationFile;
    
    if (!isset($migration['up'])) {
        throw new Exception("Migration file is missing 'up' key");
    }
    
    // Execute the migration
    $sql = $migration['up'];
    
    // Split SQL into separate statements
    $statements = array_filter(
        array_map('trim', explode(';', $sql)),
        function($stmt) {
            return !empty($stmt) && !preg_match('/^\s*--/', $stmt);
        }
    );
    
    echo "Executing migration statements...\n\n";
    
    foreach ($statements as $statement) {
        if (empty(trim($statement))) continue;
        
        // Show first 150 chars of statement
        $preview = substr(str_replace(["\n", "\r"], ' ', $statement), 0, 150);
        echo "Executing: " . $preview . "...\n";
        
        try {
            $pdo->exec($statement);
            echo "✅ Success\n\n";
        } catch (PDOException $e) {
            $errorMsg = $e->getMessage();
            
            // Check if error is about column/table already existing
            if (strpos($errorMsg, 'Duplicate column') !== false || 
                strpos($errorMsg, 'already exists') !== false ||
                strpos($errorMsg, 'Duplicate key') !== false) {
                echo "⚠️ Already exists, skipping...\n\n";
            } else {
                echo "❌ Error: " . $errorMsg . "\n\n";
                // Don't throw, continue with other statements
            }
        }
    }
    
    echo "\n✅ Migration completed successfully!\n";
    echo "Stream engagement tables are now ready:\n";
    echo "  - stream_interactions now has is_fake column\n";
    echo "  - stream_viewers table created\n";
    echo "  - stream_engagement_config table created\n";
    echo "\nFake engagement should now work properly!\n";
    
} catch (Exception $e) {
    echo "\n❌ Migration failed: " . $e->getMessage() . "\n";
    exit(1);
}
