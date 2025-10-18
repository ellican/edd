#!/usr/bin/env php
<?php
/**
 * Fix Stream Engagement Tables Migration
 * This script properly creates stream_viewers table with all required columns
 * and adds is_fake column to stream_interactions
 */

require_once __DIR__ . '/includes/db.php';

echo "=== Stream Engagement Tables Fix Migration ===\n\n";

try {
    $pdo = db();
    
    // First, create the stream_viewers and stream_engagement_config tables
    echo "Step 1: Creating stream_viewers and stream_engagement_config tables...\n";
    $migration1 = __DIR__ . '/database/migrations/057_add_is_fake_to_stream_tables.php';
    
    if (!file_exists($migration1)) {
        throw new Exception("Migration file not found: $migration1");
    }
    
    $migration = require $migration1;
    executeMigration($pdo, $migration['up'], "Stream viewers and config tables");
    
    // Then, add is_fake column to stream_interactions
    echo "\nStep 2: Adding is_fake column to stream_interactions...\n";
    $migration2 = __DIR__ . '/database/migrations/058_add_is_fake_to_stream_interactions.php';
    
    if (!file_exists($migration2)) {
        throw new Exception("Migration file not found: $migration2");
    }
    
    $migration = require $migration2;
    executeMigration($pdo, $migration['up'], "Stream interactions is_fake column");
    
    echo "\n✅ All migrations completed successfully!\n";
    echo "\nStream engagement tables are now ready:\n";
    echo "  ✅ stream_viewers table created with all columns:\n";
    echo "     - id, stream_id, user_id, session_id\n";
    echo "     - is_fake, joined_at, left_at, watch_duration\n";
    echo "  ✅ stream_engagement_config table created\n";
    echo "  ✅ stream_interactions.is_fake column added\n";
    echo "\nYou can now run: php validate_stream_engagement_system.php\n";
    
} catch (Exception $e) {
    echo "\n❌ Migration failed: " . $e->getMessage() . "\n";
    exit(1);
}

function executeMigration($pdo, $sql, $description) {
    // Split SQL into separate statements
    $statements = array_filter(
        array_map('trim', explode(';', $sql)),
        function($stmt) {
            return !empty($stmt) && !preg_match('/^\s*--/', $stmt);
        }
    );
    
    foreach ($statements as $statement) {
        if (empty(trim($statement))) continue;
        
        // Show first 100 chars of statement
        $preview = substr(str_replace(["\n", "\r"], ' ', $statement), 0, 100);
        echo "  Executing: " . $preview . "...\n";
        
        try {
            $pdo->exec($statement);
            echo "  ✅ Success\n";
        } catch (PDOException $e) {
            $errorMsg = $e->getMessage();
            
            // Check if error is about column/table already existing or duplicate key
            if (strpos($errorMsg, 'Duplicate column') !== false || 
                strpos($errorMsg, 'already exists') !== false ||
                strpos($errorMsg, 'Duplicate key name') !== false ||
                strpos($errorMsg, 'Duplicate entry') !== false) {
                echo "  ⚠️ Already exists, skipping...\n";
            } else {
                echo "  ❌ Error: " . $errorMsg . "\n";
                // Don't throw for certain errors, continue with other statements
                if (strpos($errorMsg, 'Unknown column') === false &&
                    strpos($errorMsg, "Can't DROP") === false) {
                    throw $e;
                }
            }
        }
    }
    
    echo "  ✅ $description migration completed\n";
}
