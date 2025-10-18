#!/usr/bin/env php
<?php
/**
 * Run Stream Key Migration
 * This script adds the stream_key column to live_streams table
 */

require_once __DIR__ . '/includes/db.php';

echo "=== Stream Key Migration ===\n\n";

try {
    $pdo = db();
    
    // Load the migration file
    $migrationFile = __DIR__ . '/migrations/20251018_add_stream_key_to_live_streams.sql';
    
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
    
    foreach ($statements as $statement) {
        if (empty(trim($statement))) continue;
        
        echo "Executing: " . substr($statement, 0, 100) . "...\n";
        try {
            $pdo->exec($statement);
            echo "✅ Success\n\n";
        } catch (PDOException $e) {
            // Check if error is about column already existing
            if (strpos($e->getMessage(), 'Duplicate column') !== false || 
                strpos($e->getMessage(), 'already exists') !== false) {
                echo "⚠️ Column already exists, skipping...\n\n";
            } else {
                throw $e;
            }
        }
    }
    
    echo "\n✅ Migration completed successfully!\n";
    echo "The live_streams table now has the stream_key column.\n";
    echo "Stream creation should now work without SQL errors.\n";
    
} catch (Exception $e) {
    echo "\n❌ Migration failed: " . $e->getMessage() . "\n";
    exit(1);
}
