#!/usr/bin/env php
<?php
/**
 * Run is_fake Columns Migration
 * This script adds the is_fake columns to stream_viewers and stream_interactions tables
 */

require_once __DIR__ . '/includes/db.php';

echo "=== is_fake Columns Migration ===\n\n";

try {
    $pdo = db();
    
    // Check MariaDB version
    $version = $pdo->query('SELECT VERSION()')->fetchColumn();
    echo "Database version: $version\n\n";
    
    // Load the migration file
    $migrationFile = __DIR__ . '/migrations/20251018_add_is_fake_columns.sql';
    
    if (!file_exists($migrationFile)) {
        throw new Exception("Migration file not found: $migrationFile");
    }
    
    // Read and execute the SQL file
    echo "Reading migration file...\n";
    $sql = file_get_contents($migrationFile);
    
    // Split SQL into separate statements
    $statements = array_filter(
        array_map('trim', explode(';', $sql)),
        function($stmt) {
            return !empty($stmt) && !preg_match('/^\s*--/', $stmt);
        }
    );
    
    echo "Executing migration statements...\n\n";
    
    $successCount = 0;
    $skipCount = 0;
    
    foreach ($statements as $statement) {
        if (empty(trim($statement))) continue;
        
        // Extract table and operation info for better logging
        $shortDesc = substr($statement, 0, 80);
        echo "Executing: " . $shortDesc . "...\n";
        
        try {
            $pdo->exec($statement);
            echo "✅ Success\n\n";
            $successCount++;
        } catch (PDOException $e) {
            $errorMsg = $e->getMessage();
            
            // Check if error is about column/index already existing
            if (strpos($errorMsg, 'Duplicate column') !== false || 
                strpos($errorMsg, 'already exists') !== false ||
                strpos($errorMsg, 'Duplicate key') !== false) {
                echo "⚠️ Already exists, skipping...\n\n";
                $skipCount++;
            } else {
                echo "❌ Error: " . $errorMsg . "\n\n";
                throw $e;
            }
        }
    }
    
    echo "\n✅ Migration completed successfully!\n";
    echo "Operations executed: $successCount successful, $skipCount skipped\n\n";
    echo "The following columns have been added:\n";
    echo "  - stream_viewers.is_fake\n";
    echo "  - stream_viewers.left_at\n";
    echo "  - stream_viewers.watch_duration\n";
    echo "  - stream_interactions.is_fake\n\n";
    echo "Fake engagement tracking should now work correctly.\n";
    
} catch (Exception $e) {
    echo "\n❌ Migration failed: " . $e->getMessage() . "\n";
    echo "\nIf you see 'IF NOT EXISTS' errors, your MariaDB version may not support this syntax.\n";
    echo "Please upgrade to MariaDB 10.5+ or contact support.\n";
    exit(1);
}
