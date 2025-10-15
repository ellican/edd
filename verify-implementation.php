#!/usr/bin/php
<?php
/**
 * Quick Verification Script
 * Tests that all new API endpoints are accessible
 */

echo "========================================\n";
echo "API Endpoints Verification\n";
echo "========================================\n\n";

$baseDir = __DIR__;
$endpoints = [
    // User Account APIs
    'User Account APIs' => [
        'api/account/get-orders.php',
        'api/account/get-order-receipt.php',
        'api/account/change-password.php',
        'api/account/get-sessions.php',
        'api/account/logout-session.php',
        'api/account/get-security-logs.php',
    ],
    // Admin APIs
    'Admin APIs' => [
        'api/admin/users/activate.php',
        'api/admin/users/deactivate.php',
        'api/admin/wallet/adjust.php',
        'api/admin/orders/refund.php',
    ],
    // Admin Panel
    'Admin Panel' => [
        'admin/accounts/index.php',
    ],
    // JavaScript Files
    'Frontend Assets' => [
        'js/account-enhanced.js',
    ],
    // Database Migrations
    'Database Migrations' => [
        'database/migrations/041_create_admin_activity_logs.php',
        'database/migrations/042_enhance_orders_table.php',
        'database/migrations/043_create_order_tracking_updates.php',
    ],
];

$totalFiles = 0;
$existingFiles = 0;

foreach ($endpoints as $category => $files) {
    echo "$category:\n";
    echo str_repeat('-', 40) . "\n";
    
    foreach ($files as $file) {
        $totalFiles++;
        $fullPath = $baseDir . '/' . $file;
        
        if (file_exists($fullPath)) {
            $existingFiles++;
            $size = filesize($fullPath);
            echo "  ✓ $file (" . number_format($size) . " bytes)\n";
        } else {
            echo "  ✗ $file (NOT FOUND)\n";
        }
    }
    
    echo "\n";
}

echo "========================================\n";
echo "Summary\n";
echo "========================================\n";
echo "Files Found: $existingFiles / $totalFiles\n";

if ($existingFiles === $totalFiles) {
    echo "\n✓ All files present!\n";
    exit(0);
} else {
    echo "\n✗ Some files are missing!\n";
    exit(1);
}
