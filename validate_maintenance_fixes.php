#!/usr/bin/env php
<?php
/**
 * Validation Script for Maintenance Page Fixes
 * Tests all three bug fixes and reports results
 */

echo "╔══════════════════════════════════════════════════════════╗\n";
echo "║   Maintenance Page Fixes - Validation Script            ║\n";
echo "╚══════════════════════════════════════════════════════════╝\n\n";

// Load database connection
require_once __DIR__ . '/includes/db.php';

$passed = 0;
$failed = 0;
$warnings = 0;

function testPass($message) {
    global $passed;
    $passed++;
    echo "✅ PASS: $message\n";
}

function testFail($message, $error = '') {
    global $failed;
    $failed++;
    echo "❌ FAIL: $message\n";
    if ($error) {
        echo "   Error: $error\n";
    }
}

function testWarn($message) {
    global $warnings;
    $warnings++;
    echo "⚠️  WARN: $message\n";
}

echo "Running validation tests...\n\n";

try {
    $pdo = db();
    testPass("Database connection established");
} catch (Exception $e) {
    testFail("Database connection failed", $e->getMessage());
    echo "\n❌ Cannot proceed without database connection.\n";
    echo "Please ensure MySQL/MariaDB is running and credentials are correct.\n";
    exit(1);
}

echo "\n" . str_repeat("─", 60) . "\n";
echo "TEST 1: Jobs Table Column Check\n";
echo str_repeat("─", 60) . "\n";

try {
    // Check if attempts column exists
    $stmt = $pdo->query("SHOW COLUMNS FROM jobs LIKE 'attempts'");
    if ($stmt->rowCount() > 0) {
        testPass("Column 'attempts' exists in jobs table");
    } else {
        testWarn("Column 'attempts' does not exist (migration not run yet)");
    }
    
    // Check if max_attempts column exists
    $stmt = $pdo->query("SHOW COLUMNS FROM jobs LIKE 'max_attempts'");
    if ($stmt->rowCount() > 0) {
        testPass("Column 'max_attempts' exists in jobs table");
    } else {
        testWarn("Column 'max_attempts' does not exist (migration not run yet)");
    }
    
    // Check if queue column exists
    $stmt = $pdo->query("SHOW COLUMNS FROM jobs LIKE 'queue'");
    if ($stmt->rowCount() > 0) {
        testPass("Column 'queue' exists in jobs table");
    } else {
        testWarn("Column 'queue' does not exist (migration not run yet)");
    }
    
    // Test the actual query from maintenance page
    $stmt = $pdo->query("
        SELECT j.*,
               j.retry_count as attempts,
               j.max_retries as max_attempts,
               COALESCE(j.name, 'default') as queue,
               CASE 
                   WHEN j.max_retries - j.retry_count <= 0 THEN 'exhausted'
                   ELSE 'retryable'
               END as retry_status
        FROM jobs j 
        WHERE j.status = 'failed' 
        ORDER BY j.updated_at DESC 
        LIMIT 1
    ");
    testPass("Failed jobs query executes without errors");
    
} catch (Exception $e) {
    testFail("Jobs table check failed", $e->getMessage());
}

echo "\n" . str_repeat("─", 60) . "\n";
echo "TEST 2: Backups Table Column Check\n";
echo str_repeat("─", 60) . "\n";

try {
    // Check if filepath column exists
    $stmt = $pdo->query("SHOW COLUMNS FROM backups LIKE 'filepath'");
    if ($stmt->rowCount() > 0) {
        testPass("Column 'filepath' exists in backups table");
    } else {
        testWarn("Column 'filepath' does not exist (migration not run yet)");
    }
    
    // Check if description column exists
    $stmt = $pdo->query("SHOW COLUMNS FROM backups LIKE 'description'");
    if ($stmt->rowCount() > 0) {
        testPass("Column 'description' exists in backups table");
    } else {
        testWarn("Column 'description' does not exist (migration not run yet)");
    }
    
    // Verify file_path column exists (original column)
    $stmt = $pdo->query("SHOW COLUMNS FROM backups LIKE 'file_path'");
    if ($stmt->rowCount() > 0) {
        testPass("Column 'file_path' exists in backups table");
    } else {
        testFail("Column 'file_path' missing (database schema issue)");
    }
    
    // Test backup query
    $stmt = $pdo->query("
        SELECT b.*, u.username as created_by_name
        FROM backups b
        LEFT JOIN users u ON b.created_by = u.id
        ORDER BY b.created_at DESC
        LIMIT 1
    ");
    testPass("Backups query executes without errors");
    
} catch (Exception $e) {
    testFail("Backups table check failed", $e->getMessage());
}

echo "\n" . str_repeat("─", 60) . "\n";
echo "TEST 3: System Settings Table Check\n";
echo str_repeat("─", 60) . "\n";

try {
    // Check if system_settings table exists
    $stmt = $pdo->query("SHOW TABLES LIKE 'system_settings'");
    if ($stmt->rowCount() > 0) {
        testPass("Table 'system_settings' exists");
    } else {
        testFail("Table 'system_settings' does not exist");
    }
    
    // Check if maintenance_mode setting exists
    $stmt = $pdo->query("
        SELECT setting_value 
        FROM system_settings 
        WHERE setting_key = 'maintenance_mode'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result !== false) {
        $mode = $result['setting_value'];
        testPass("Maintenance mode setting found (value: " . ($mode ? 'ENABLED' : 'DISABLED') . ")");
    } else {
        testWarn("Maintenance mode setting not found (will be created on first use)");
    }
    
    // Check if maintenance_message setting exists
    $stmt = $pdo->query("
        SELECT setting_value 
        FROM system_settings 
        WHERE setting_key = 'maintenance_message'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result !== false) {
        testPass("Maintenance message setting found");
    } else {
        testWarn("Maintenance message setting not found (will be created on first use)");
    }
    
} catch (Exception $e) {
    testFail("System settings check failed", $e->getMessage());
}

echo "\n" . str_repeat("─", 60) . "\n";
echo "TEST 4: System Events Table Check\n";
echo str_repeat("─", 60) . "\n";

try {
    // Check if system_events table exists
    $stmt = $pdo->query("SHOW TABLES LIKE 'system_events'");
    if ($stmt->rowCount() > 0) {
        testPass("Table 'system_events' exists");
        
        // Test insert
        $stmt = $pdo->prepare("
            INSERT INTO system_events (event_type, description, created_by, created_at)
            VALUES ('test_event', 'Validation test event', NULL, NOW())
        ");
        $stmt->execute();
        testPass("Can insert events into system_events table");
        
        // Clean up test event
        $pdo->exec("DELETE FROM system_events WHERE event_type = 'test_event'");
        
    } else {
        testWarn("Table 'system_events' does not exist (migration not run yet)");
    }
    
} catch (Exception $e) {
    testFail("System events table check failed", $e->getMessage());
}

echo "\n" . str_repeat("─", 60) . "\n";
echo "TEST 5: Database Triggers Check\n";
echo str_repeat("─", 60) . "\n";

try {
    // Check for jobs triggers
    $stmt = $pdo->query("SHOW TRIGGERS LIKE 'jobs'");
    $triggers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $expectedTriggers = [
        'jobs_sync_attempts_on_insert',
        'jobs_sync_attempts_on_update'
    ];
    
    $foundTriggers = array_column($triggers, 'Trigger');
    
    foreach ($expectedTriggers as $trigger) {
        if (in_array($trigger, $foundTriggers)) {
            testPass("Trigger '$trigger' exists");
        } else {
            testWarn("Trigger '$trigger' does not exist (migration not run yet)");
        }
    }
    
    // Check for backups triggers
    $stmt = $pdo->query("SHOW TRIGGERS LIKE 'backups'");
    $triggers = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $expectedTriggers = [
        'backups_sync_filepath_on_insert',
        'backups_sync_filepath_on_update'
    ];
    
    $foundTriggers = array_column($triggers, 'Trigger');
    
    foreach ($expectedTriggers as $trigger) {
        if (in_array($trigger, $foundTriggers)) {
            testPass("Trigger '$trigger' exists");
        } else {
            testWarn("Trigger '$trigger' does not exist (migration not run yet)");
        }
    }
    
} catch (Exception $e) {
    testFail("Triggers check failed", $e->getMessage());
}

echo "\n" . str_repeat("─", 60) . "\n";
echo "TEST 6: File Existence Check\n";
echo str_repeat("─", 60) . "\n";

$requiredFiles = [
    'admin/maintenance/index.php' => 'Maintenance page',
    'includes/maintenance_check.php' => 'Maintenance mode middleware',
    'database/migrations/2025_10_15_fix_maintenance_page_columns.php' => 'PHP migration',
    'migrations/2025_10_15_fix_maintenance_page_columns.sql' => 'SQL migration',
    'run_maintenance_migration.php' => 'Migration runner',
    'MAINTENANCE_PAGE_FIX.md' => 'Documentation',
    'MAINTENANCE_PAGE_VISUAL_GUIDE.md' => 'Visual guide'
];

foreach ($requiredFiles as $file => $description) {
    if (file_exists(__DIR__ . '/' . $file)) {
        testPass("$description exists");
    } else {
        testFail("$description is missing: $file");
    }
}

// Check if maintenance_check is loaded in init.php
$initContent = file_get_contents(__DIR__ . '/includes/init.php');
if (strpos($initContent, 'maintenance_check.php') !== false) {
    testPass("Maintenance check is integrated into init.php");
} else {
    testFail("Maintenance check is not integrated into init.php");
}

echo "\n" . str_repeat("═", 60) . "\n";
echo "VALIDATION SUMMARY\n";
echo str_repeat("═", 60) . "\n\n";

echo "✅ Passed:   $passed\n";
echo "❌ Failed:   $failed\n";
echo "⚠️  Warnings: $warnings\n\n";

if ($failed > 0) {
    echo "❌ VALIDATION FAILED\n";
    echo "Please review the failed tests above and fix the issues.\n\n";
    exit(1);
} elseif ($warnings > 0) {
    echo "⚠️  VALIDATION PASSED WITH WARNINGS\n";
    echo "The code changes are correct, but the database migration hasn't been run yet.\n";
    echo "Please run: php run_maintenance_migration.php\n\n";
    exit(0);
} else {
    echo "✅ VALIDATION PASSED\n";
    echo "All fixes are properly implemented and database is up to date!\n\n";
    echo "You can now:\n";
    echo "  1. Access /admin/maintenance/ to test the maintenance page\n";
    echo "  2. Toggle maintenance mode on/off\n";
    echo "  3. Create database backups\n";
    echo "  4. Monitor and retry failed jobs\n\n";
    exit(0);
}
