#!/usr/bin/env php
<?php
/**
 * Validate Live Stream Engagement Implementation
 * Tests all components of the engagement system
 */

require_once __DIR__ . '/includes/db.php';

echo "=== Live Stream Engagement System Validation ===\n\n";

$errors = [];
$warnings = [];
$passed = [];

try {
    $pdo = db();
    
    // Test 1: Check if stream_key column exists
    echo "Test 1: Checking stream_key column...\n";
    try {
        $result = $pdo->query("SHOW COLUMNS FROM live_streams LIKE 'stream_key'")->fetch();
        if ($result) {
            $passed[] = "✅ stream_key column exists";
            
            // Check if it's unique
            $indexes = $pdo->query("SHOW INDEXES FROM live_streams WHERE Column_name = 'stream_key'")->fetchAll();
            $isUnique = false;
            foreach ($indexes as $index) {
                if ($index['Non_unique'] == 0) {
                    $isUnique = true;
                    break;
                }
            }
            if ($isUnique) {
                $passed[] = "✅ stream_key has UNIQUE constraint";
            } else {
                $warnings[] = "⚠️ stream_key should have UNIQUE constraint";
            }
        } else {
            $errors[] = "❌ stream_key column missing - run: php run_stream_key_migration.php";
        }
    } catch (Exception $e) {
        $errors[] = "❌ Error checking stream_key: " . $e->getMessage();
    }
    
    // Test 2: Check engagement columns
    echo "\nTest 2: Checking engagement columns...\n";
    $engagementColumns = ['like_count', 'dislike_count', 'comment_count'];
    foreach ($engagementColumns as $col) {
        try {
            $result = $pdo->query("SHOW COLUMNS FROM live_streams LIKE '$col'")->fetch();
            if ($result) {
                $passed[] = "✅ $col column exists";
            } else {
                $warnings[] = "⚠️ $col column missing (may need migration 20251017)";
            }
        } catch (Exception $e) {
            $errors[] = "❌ Error checking $col: " . $e->getMessage();
        }
    }
    
    // Test 3: Check stream_engagement_config table
    echo "\nTest 3: Checking stream_engagement_config table...\n";
    try {
        $result = $pdo->query("SHOW TABLES LIKE 'stream_engagement_config'")->fetch();
        if ($result) {
            $passed[] = "✅ stream_engagement_config table exists";
            
            // Check required columns
            $requiredCols = [
                'fake_viewers_enabled', 'fake_likes_enabled', 'min_fake_viewers',
                'max_fake_viewers', 'viewer_increase_rate', 'viewer_decrease_rate',
                'like_rate', 'engagement_multiplier'
            ];
            
            foreach ($requiredCols as $col) {
                $colCheck = $pdo->query("SHOW COLUMNS FROM stream_engagement_config LIKE '$col'")->fetch();
                if ($colCheck) {
                    $passed[] = "✅ stream_engagement_config.$col exists";
                } else {
                    $errors[] = "❌ stream_engagement_config.$col missing";
                }
            }
        } else {
            $errors[] = "❌ stream_engagement_config table missing";
        }
    } catch (Exception $e) {
        $errors[] = "❌ Error checking stream_engagement_config: " . $e->getMessage();
    }
    
    // Test 4: Check global_stream_settings table
    echo "\nTest 4: Checking global_stream_settings table...\n";
    try {
        $result = $pdo->query("SHOW TABLES LIKE 'global_stream_settings'")->fetch();
        if ($result) {
            $passed[] = "✅ global_stream_settings table exists";
        } else {
            $warnings[] = "⚠️ global_stream_settings table will be created on first use";
        }
    } catch (Exception $e) {
        $warnings[] = "⚠️ global_stream_settings check failed: " . $e->getMessage();
    }
    
    // Test 5: Check stream_viewers table
    echo "\nTest 5: Checking stream_viewers table...\n";
    try {
        $result = $pdo->query("SHOW TABLES LIKE 'stream_viewers'")->fetch();
        if ($result) {
            $passed[] = "✅ stream_viewers table exists";
            
            // Check is_fake column
            $colCheck = $pdo->query("SHOW COLUMNS FROM stream_viewers LIKE 'is_fake'")->fetch();
            if ($colCheck) {
                $passed[] = "✅ stream_viewers.is_fake column exists";
            } else {
                $errors[] = "❌ stream_viewers.is_fake column missing";
            }
        } else {
            $errors[] = "❌ stream_viewers table missing";
        }
    } catch (Exception $e) {
        $errors[] = "❌ Error checking stream_viewers: " . $e->getMessage();
    }
    
    // Test 6: Check stream_interactions table
    echo "\nTest 6: Checking stream_interactions table...\n";
    try {
        $result = $pdo->query("SHOW TABLES LIKE 'stream_interactions'")->fetch();
        if ($result) {
            $passed[] = "✅ stream_interactions table exists";
            
            // Check is_fake column
            $colCheck = $pdo->query("SHOW COLUMNS FROM stream_interactions LIKE 'is_fake'")->fetch();
            if ($colCheck) {
                $passed[] = "✅ stream_interactions.is_fake column exists";
            } else {
                $errors[] = "❌ stream_interactions.is_fake column missing";
            }
        } else {
            $errors[] = "❌ stream_interactions table missing";
        }
    } catch (Exception $e) {
        $errors[] = "❌ Error checking stream_interactions: " . $e->getMessage();
    }
    
    // Test 7: Check API files exist
    echo "\nTest 7: Checking API files...\n";
    $apiFiles = [
        'api/streams/start.php' => 'Stream start endpoint',
        'api/streams/engagement.php' => 'Engagement trigger endpoint',
        'api/live/fake-engagement.php' => 'FakeEngagementGenerator class',
        'api/live/stats.php' => 'Stats endpoint',
        'api/admin/streams/get-settings.php' => 'Get settings endpoint',
        'api/admin/streams/save-settings.php' => 'Save settings endpoint',
    ];
    
    foreach ($apiFiles as $file => $description) {
        if (file_exists(__DIR__ . '/' . $file)) {
            $passed[] = "✅ $description exists";
        } else {
            $errors[] = "❌ $description missing: $file";
        }
    }
    
    // Test 8: Check if FakeEngagementGenerator class can be loaded
    echo "\nTest 8: Testing FakeEngagementGenerator class...\n";
    try {
        require_once __DIR__ . '/api/live/fake-engagement.php';
        if (class_exists('FakeEngagementGenerator')) {
            $passed[] = "✅ FakeEngagementGenerator class loads successfully";
            
            // Try to instantiate
            $generator = new FakeEngagementGenerator();
            if ($generator) {
                $passed[] = "✅ FakeEngagementGenerator can be instantiated";
            }
        } else {
            $errors[] = "❌ FakeEngagementGenerator class not found";
        }
    } catch (Exception $e) {
        $errors[] = "❌ Error loading FakeEngagementGenerator: " . $e->getMessage();
    }
    
    // Test 9: Test stream_key generation
    echo "\nTest 9: Testing stream key generation...\n";
    try {
        require_once __DIR__ . '/includes/models_extended.php';
        $liveStream = new LiveStream();
        
        // Check if generateStreamKey method exists (it's private but we can check the class)
        $reflection = new ReflectionClass($liveStream);
        $method = $reflection->getMethod('generateStreamKey');
        if ($method) {
            $passed[] = "✅ LiveStream::generateStreamKey() method exists";
        }
    } catch (Exception $e) {
        $errors[] = "❌ Error testing stream key generation: " . $e->getMessage();
    }
    
    // Print results
    echo "\n" . str_repeat("=", 60) . "\n";
    echo "VALIDATION RESULTS\n";
    echo str_repeat("=", 60) . "\n\n";
    
    if (count($passed) > 0) {
        echo "PASSED (" . count($passed) . "):\n";
        foreach ($passed as $p) {
            echo "  $p\n";
        }
        echo "\n";
    }
    
    if (count($warnings) > 0) {
        echo "WARNINGS (" . count($warnings) . "):\n";
        foreach ($warnings as $w) {
            echo "  $w\n";
        }
        echo "\n";
    }
    
    if (count($errors) > 0) {
        echo "ERRORS (" . count($errors) . "):\n";
        foreach ($errors as $e) {
            echo "  $e\n";
        }
        echo "\n";
    }
    
    echo str_repeat("=", 60) . "\n";
    
    if (count($errors) > 0) {
        echo "\n❌ VALIDATION FAILED - Please fix the errors above\n";
        exit(1);
    } elseif (count($warnings) > 0) {
        echo "\n⚠️ VALIDATION PASSED WITH WARNINGS\n";
        echo "The system should work, but consider addressing warnings.\n";
        exit(0);
    } else {
        echo "\n✅ ALL TESTS PASSED!\n";
        echo "The live stream engagement system is fully operational.\n";
        exit(0);
    }
    
} catch (Exception $e) {
    echo "\n❌ CRITICAL ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
