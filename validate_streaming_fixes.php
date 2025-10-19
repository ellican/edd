<?php
/**
 * Validation Script for Live Streaming Fixes
 * 
 * This script validates that all the required fixes are in place:
 * 1. duration_seconds is BIGINT UNSIGNED
 * 2. API endpoints exist and are accessible
 * 3. JavaScript files exist
 * 4. Documentation is in place
 */

require_once __DIR__ . '/includes/init.php';

echo "=== Live Streaming Fixes Validation ===\n\n";

$errors = [];
$warnings = [];
$passed = [];

// 1. Check Database Schema
echo "1. Checking database schema...\n";
try {
    $db = db();
    $stmt = $db->query("DESCRIBE live_streams");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $durationColumn = null;
    foreach ($columns as $column) {
        if ($column['Field'] === 'duration_seconds') {
            $durationColumn = $column;
            break;
        }
    }
    
    if (!$durationColumn) {
        $errors[] = "Column 'duration_seconds' not found in live_streams table";
    } else {
        // Check if it's BIGINT UNSIGNED
        $type = strtolower($durationColumn['Type']);
        if (strpos($type, 'bigint') !== false && strpos($type, 'unsigned') !== false) {
            $passed[] = "✅ duration_seconds is BIGINT UNSIGNED";
        } else {
            $errors[] = "❌ duration_seconds is {$durationColumn['Type']}, should be BIGINT UNSIGNED";
            echo "   Run migration 059 to fix this: php run_migration.php 059\n";
        }
    }
} catch (Exception $e) {
    $errors[] = "Database error: " . $e->getMessage();
}

// 2. Check API Endpoints
echo "\n2. Checking API endpoints...\n";
$apiEndpoints = [
    '/api/streams/get.php',
    '/api/streams/list.php',
    '/api/streams/end.php',
    '/api/streams/delete.php',
    '/api/streams/update.php',
    '/api/streams/cancel.php'
];

foreach ($apiEndpoints as $endpoint) {
    $path = __DIR__ . $endpoint;
    if (file_exists($path)) {
        // Check for syntax errors
        $output = [];
        $return = 0;
        exec("php -l " . escapeshellarg($path) . " 2>&1", $output, $return);
        if ($return === 0) {
            $passed[] = "✅ $endpoint exists and has valid syntax";
        } else {
            $errors[] = "❌ $endpoint has syntax errors";
        }
    } else {
        $errors[] = "❌ $endpoint not found";
    }
}

// 3. Check JavaScript Files
echo "\n3. Checking JavaScript files...\n";
$jsFiles = [
    '/js/live-stream-player.js'
];

foreach ($jsFiles as $jsFile) {
    $path = __DIR__ . $jsFile;
    if (file_exists($path)) {
        $content = file_get_contents($path);
        
        // Check for key features
        $features = [
            'MANIFEST_PARSED' => 'HLS manifest event handling',
            'startEngagement' => 'Engagement timing logic',
            'scheduleViewerUpdates' => 'Randomized viewer updates',
            'scheduleLikeUpdates' => 'Randomized like updates',
            'destroy' => 'Cleanup method',
            'viewerTimer' => 'Viewer timer tracking',
            'likeTimer' => 'Like timer tracking'
        ];
        
        $missing = [];
        foreach ($features as $feature => $description) {
            if (strpos($content, $feature) === false) {
                $missing[] = "$description ($feature)";
            }
        }
        
        if (empty($missing)) {
            $passed[] = "✅ $jsFile has all required features";
        } else {
            $warnings[] = "⚠️ $jsFile is missing: " . implode(', ', $missing);
        }
    } else {
        $errors[] = "❌ $jsFile not found";
    }
}

// 4. Check Documentation
echo "\n4. Checking documentation...\n";
$docs = [
    '/docs/HLS_STREAMING_SETUP.md' => 'HLS streaming setup guide',
    '/docs/TESTING_GUIDE_STREAMING.md' => 'Testing guide'
];

foreach ($docs as $docPath => $description) {
    $path = __DIR__ . $docPath;
    if (file_exists($path)) {
        $size = filesize($path);
        if ($size > 1000) { // At least 1KB
            $passed[] = "✅ $description exists ($size bytes)";
        } else {
            $warnings[] = "⚠️ $description is too small ($size bytes)";
        }
    } else {
        $warnings[] = "⚠️ $description not found";
    }
}

// 5. Check Key Files Modified
echo "\n5. Checking key files...\n";
$keyFiles = [
    '/api/streams/end.php' => 'duration clamping logic',
    '/api/streams/delete.php' => 'video file deletion',
    '/live.php' => 'page visibility handling',
    '/seller/streams.php' => 'seller management page'
];

foreach ($keyFiles as $filePath => $feature) {
    $path = __DIR__ . $filePath;
    if (file_exists($path)) {
        $passed[] = "✅ $feature file exists";
    } else {
        $errors[] = "❌ File for $feature not found: $filePath";
    }
}

// 6. Check Specific Implementation Details
echo "\n6. Checking implementation details...\n";

// Check end.php for duration clamping
$endPhpPath = __DIR__ . '/api/streams/end.php';
if (file_exists($endPhpPath)) {
    $content = file_get_contents($endPhpPath);
    if (strpos($content, 'max(0') !== false && strpos($content, '172800') !== false) {
        $passed[] = "✅ Duration clamping implemented (max 48 hours)";
    } else {
        $warnings[] = "⚠️ Duration clamping may not be implemented correctly";
    }
    
    if (strpos($content, 'try') !== false && strpos($content, 'PDOException') !== false) {
        $passed[] = "✅ SQL error handling implemented";
    } else {
        $warnings[] = "⚠️ SQL error handling may not be implemented";
    }
}

// Check delete.php for file deletion
$deletePhpPath = __DIR__ . '/api/streams/delete.php';
if (file_exists($deletePhpPath)) {
    $content = file_get_contents($deletePhpPath);
    if (strpos($content, 'DOCUMENT_ROOT') !== false && strpos($content, 'unlink') !== false) {
        $passed[] = "✅ Video file deletion implemented";
    } else {
        $warnings[] = "⚠️ Video file deletion may not be implemented correctly";
    }
    
    if (strpos($content, 'error_log') !== false) {
        $passed[] = "✅ File deletion logging implemented";
    } else {
        $warnings[] = "⚠️ File deletion logging may not be implemented";
    }
}

// Print Results
echo "\n=== VALIDATION RESULTS ===\n\n";

if (!empty($passed)) {
    echo "PASSED (" . count($passed) . "):\n";
    foreach ($passed as $item) {
        echo "  $item\n";
    }
    echo "\n";
}

if (!empty($warnings)) {
    echo "WARNINGS (" . count($warnings) . "):\n";
    foreach ($warnings as $item) {
        echo "  $item\n";
    }
    echo "\n";
}

if (!empty($errors)) {
    echo "ERRORS (" . count($errors) . "):\n";
    foreach ($errors as $item) {
        echo "  $item\n";
    }
    echo "\n";
}

// Overall Status
$totalChecks = count($passed) + count($warnings) + count($errors);
$criticalIssues = count($errors);

echo "=== SUMMARY ===\n";
echo "Total Checks: $totalChecks\n";
echo "Passed: " . count($passed) . "\n";
echo "Warnings: " . count($warnings) . "\n";
echo "Errors: " . count($errors) . "\n\n";

if ($criticalIssues === 0) {
    echo "✅ ALL CRITICAL FIXES ARE IN PLACE!\n";
    echo "\nNext steps:\n";
    echo "1. Run manual tests as described in docs/TESTING_GUIDE_STREAMING.md\n";
    echo "2. Test HLS playback in multiple browsers\n";
    echo "3. Test engagement timing with console logs\n";
    echo "4. Test seller streams management page\n";
    echo "5. Verify database operations with long-running streams\n";
    exit(0);
} else {
    echo "❌ CRITICAL ISSUES FOUND! Please fix before proceeding.\n";
    exit(1);
}
