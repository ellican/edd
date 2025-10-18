#!/usr/bin/env php
<?php
/**
 * Validate Stream Engagement System
 * This script checks if the engagement system is properly configured
 */

require_once __DIR__ . '/includes/init.php';

echo "=== Stream Engagement System Validation ===\n\n";

$errors = [];
$warnings = [];
$successes = [];

try {
    $db = db();
    
    // Check if stream_interactions has is_fake column
    echo "1. Checking stream_interactions table...\n";
    try {
        $stmt = $db->query("SHOW COLUMNS FROM stream_interactions LIKE 'is_fake'");
        $column = $stmt->fetch();
        if ($column) {
            $successes[] = "✅ stream_interactions.is_fake column exists";
        } else {
            $errors[] = "❌ stream_interactions.is_fake column is missing";
            $warnings[] = "  Run: php run_engagement_migration.php";
        }
    } catch (Exception $e) {
        $errors[] = "❌ Could not check stream_interactions table: " . $e->getMessage();
    }
    
    // Check if stream_viewers table exists
    echo "2. Checking stream_viewers table...\n";
    try {
        $stmt = $db->query("SHOW TABLES LIKE 'stream_viewers'");
        $table = $stmt->fetch();
        if ($table) {
            $successes[] = "✅ stream_viewers table exists";
            
            // Check columns
            $stmt = $db->query("SHOW COLUMNS FROM stream_viewers");
            $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
            $requiredColumns = ['id', 'stream_id', 'user_id', 'session_id', 'is_fake', 'joined_at', 'left_at', 'watch_duration'];
            foreach ($requiredColumns as $col) {
                if (in_array($col, $columns)) {
                    $successes[] = "  ✅ stream_viewers.$col column exists";
                } else {
                    $errors[] = "  ❌ stream_viewers.$col column is missing";
                }
            }
        } else {
            $errors[] = "❌ stream_viewers table does not exist";
            $warnings[] = "  Run: php run_engagement_migration.php";
        }
    } catch (Exception $e) {
        $errors[] = "❌ Could not check stream_viewers table: " . $e->getMessage();
    }
    
    // Check if stream_engagement_config table exists
    echo "3. Checking stream_engagement_config table...\n";
    try {
        $stmt = $db->query("SHOW TABLES LIKE 'stream_engagement_config'");
        $table = $stmt->fetch();
        if ($table) {
            $successes[] = "✅ stream_engagement_config table exists";
            
            // Count configurations
            $stmt = $db->query("SELECT COUNT(*) FROM stream_engagement_config");
            $count = $stmt->fetchColumn();
            if ($count > 0) {
                $successes[] = "  ✅ $count stream engagement configurations found";
            } else {
                $warnings[] = "  ⚠️ No stream engagement configurations found (will be created when stream starts)";
            }
        } else {
            $errors[] = "❌ stream_engagement_config table does not exist";
            $warnings[] = "  Run: php run_engagement_migration.php";
        }
    } catch (Exception $e) {
        $errors[] = "❌ Could not check stream_engagement_config table: " . $e->getMessage();
    }
    
    // Check if fake-engagement.php exists
    echo "4. Checking fake engagement scripts...\n";
    if (file_exists(__DIR__ . '/api/live/fake-engagement.php')) {
        $successes[] = "✅ api/live/fake-engagement.php exists";
    } else {
        $errors[] = "❌ api/live/fake-engagement.php is missing";
    }
    
    if (file_exists(__DIR__ . '/api/streams/engagement.php')) {
        $successes[] = "✅ api/streams/engagement.php exists";
    } else {
        $errors[] = "❌ api/streams/engagement.php is missing";
    }
    
    if (file_exists(__DIR__ . '/scripts/fake-engagement-cron.sh')) {
        $successes[] = "✅ scripts/fake-engagement-cron.sh exists";
    } else {
        $warnings[] = "⚠️ scripts/fake-engagement-cron.sh is missing (optional background job)";
    }
    
    // Check for active streams
    echo "5. Checking for active streams...\n";
    try {
        $stmt = $db->query("SELECT COUNT(*) FROM live_streams WHERE status = 'live'");
        $activeCount = $stmt->fetchColumn();
        if ($activeCount > 0) {
            $successes[] = "✅ $activeCount active stream(s) found";
            
            // Check if any have fake viewers
            $stmt = $db->query("
                SELECT ls.id, ls.title, 
                       COALESCE(COUNT(sv.id), 0) as fake_viewer_count
                FROM live_streams ls
                LEFT JOIN stream_viewers sv ON ls.id = sv.stream_id AND sv.is_fake = 1 AND sv.left_at IS NULL
                WHERE ls.status = 'live'
                GROUP BY ls.id
            ");
            $streams = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            foreach ($streams as $stream) {
                if ($stream['fake_viewer_count'] > 0) {
                    $successes[] = "  ✅ Stream '{$stream['title']}' has {$stream['fake_viewer_count']} fake viewers";
                } else {
                    $warnings[] = "  ⚠️ Stream '{$stream['title']}' has no fake viewers yet";
                    $warnings[] = "    Try: curl http://localhost/api/streams/engagement.php?stream_id={$stream['id']}";
                }
            }
        } else {
            $warnings[] = "⚠️ No active streams found (start a stream to test engagement)";
        }
    } catch (Exception $e) {
        $warnings[] = "⚠️ Could not check for active streams: " . $e->getMessage();
    }
    
    // Check stream replay functionality
    echo "6. Checking stream replay functionality...\n";
    if (file_exists(__DIR__ . '/templates/stream-replay.php')) {
        $successes[] = "✅ templates/stream-replay.php exists";
    } else {
        $errors[] = "❌ templates/stream-replay.php is missing";
    }
    
    // Check for archived streams
    try {
        $stmt = $db->query("SELECT COUNT(*) FROM live_streams WHERE status = 'archived'");
        $archivedCount = $stmt->fetchColumn();
        if ($archivedCount > 0) {
            $successes[] = "✅ $archivedCount archived stream(s) available for replay";
        } else {
            $warnings[] = "⚠️ No archived streams found (end and save a stream to test replay)";
        }
    } catch (Exception $e) {
        $warnings[] = "⚠️ Could not check for archived streams: " . $e->getMessage();
    }
    
    // Print results
    echo "\n=== Validation Results ===\n\n";
    
    if (!empty($successes)) {
        echo "Successes:\n";
        foreach ($successes as $success) {
            echo "$success\n";
        }
        echo "\n";
    }
    
    if (!empty($warnings)) {
        echo "Warnings:\n";
        foreach ($warnings as $warning) {
            echo "$warning\n";
        }
        echo "\n";
    }
    
    if (!empty($errors)) {
        echo "Errors:\n";
        foreach ($errors as $error) {
            echo "$error\n";
        }
        echo "\n";
        echo "❌ Validation failed. Please fix the errors above.\n";
        exit(1);
    } else {
        echo "✅ All critical checks passed!\n";
        echo "\nNext steps:\n";
        echo "1. Start a live stream from the seller dashboard\n";
        echo "2. Check that viewer and like counts increase automatically\n";
        echo "3. End the stream and verify replay functionality\n";
        exit(0);
    }
    
} catch (Exception $e) {
    echo "❌ Validation failed: " . $e->getMessage() . "\n";
    exit(1);
}
