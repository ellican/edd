<?php
/**
 * Migration: Add Mux-specific fields to live_streams table
 * This migration adds fields needed for Mux API integration
 */

require_once __DIR__ . '/../../includes/init.php';

try {
    $db = db();
    
    echo "Adding Mux-specific fields to live_streams table...\n";
    
    // Check if columns already exist to make migration idempotent
    $stmt = $db->query("SHOW COLUMNS FROM live_streams LIKE 'mux_stream_id'");
    $columnExists = $stmt->fetch();
    
    if (!$columnExists) {
        // Add mux_stream_id column
        $db->exec("
            ALTER TABLE live_streams 
            ADD COLUMN mux_stream_id VARCHAR(128) NULL DEFAULT NULL 
            COMMENT 'Mux API live stream ID' 
            AFTER stream_key
        ");
        echo "✓ Added mux_stream_id column\n";
        
        // Add mux_playback_id column
        $db->exec("
            ALTER TABLE live_streams 
            ADD COLUMN mux_playback_id VARCHAR(128) NULL DEFAULT NULL 
            COMMENT 'Mux playback ID for HLS streaming' 
            AFTER mux_stream_id
        ");
        echo "✓ Added mux_playback_id column\n";
        
        // Add index for mux_stream_id
        $db->exec("
            ALTER TABLE live_streams 
            ADD INDEX idx_mux_stream_id (mux_stream_id)
        ");
        echo "✓ Added index on mux_stream_id\n";
        
        echo "\n✅ Migration completed successfully!\n";
    } else {
        echo "⚠️ Columns already exist. Skipping migration.\n";
    }
    
} catch (Exception $e) {
    echo "❌ Migration failed: " . $e->getMessage() . "\n";
    exit(1);
}
