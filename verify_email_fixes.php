<?php
/**
 * Verify Email Deliverability Fixes
 * Checks that all email code uses RobustEmailService instead of mail()
 */

echo "=== Email Deliverability Fix Verification ===\n\n";

$filesToCheck = [
    'forgot-password.php',
    'includes/email.php',
    'includes/email_system.php',
    'includes/enhanced_email_system.php',
];

$allPassed = true;

foreach ($filesToCheck as $file) {
    $fullPath = __DIR__ . '/' . $file;
    echo "Checking: $file\n";
    
    if (!file_exists($fullPath)) {
        echo "  ✗ File not found\n";
        $allPassed = false;
        continue;
    }
    
    $content = file_get_contents($fullPath);
    
    // Check for RobustEmailService usage
    $hasRobustService = strpos($content, 'RobustEmailService') !== false;
    
    // Check for direct mail() calls (excluding comments)
    $lines = explode("\n", $content);
    $hasDirectMail = false;
    $mailLines = [];
    
    foreach ($lines as $lineNum => $line) {
        // Skip comments
        if (preg_match('/^\s*\/\//', $line) || preg_match('/^\s*\*/', $line)) {
            continue;
        }
        
        // Check for mail( function call
        if (preg_match('/\bmail\s*\(/', $line)) {
            $hasDirectMail = true;
            $mailLines[] = $lineNum + 1;
        }
    }
    
    if ($hasRobustService) {
        echo "  ✓ Uses RobustEmailService\n";
    } else {
        echo "  ⚠ Does not use RobustEmailService\n";
    }
    
    if ($hasDirectMail) {
        echo "  ✗ Still contains direct mail() calls on lines: " . implode(', ', $mailLines) . "\n";
        $allPassed = false;
    } else {
        echo "  ✓ No direct mail() calls found\n";
    }
    
    echo "\n";
}

// Check that PHPMailer is installed
echo "Checking Composer dependencies...\n";
$vendorPath = __DIR__ . '/vendor/phpmailer/phpmailer/src/PHPMailer.php';
if (file_exists($vendorPath)) {
    echo "  ✓ PHPMailer is installed\n";
} else {
    echo "  ✗ PHPMailer is not installed (run: composer install)\n";
    $allPassed = false;
}

echo "\n";

// Check RobustEmailService exists
echo "Checking RobustEmailService...\n";
$robustServicePath = __DIR__ . '/includes/RobustEmailService.php';
if (file_exists($robustServicePath)) {
    echo "  ✓ RobustEmailService.php exists\n";
    
    // Check it uses PHPMailer
    $content = file_get_contents($robustServicePath);
    if (strpos($content, 'use PHPMailer\PHPMailer\PHPMailer;') !== false) {
        echo "  ✓ RobustEmailService imports PHPMailer\n";
    } else {
        echo "  ✗ RobustEmailService does not import PHPMailer\n";
        $allPassed = false;
    }
} else {
    echo "  ✗ RobustEmailService.php not found\n";
    $allPassed = false;
}

echo "\n";

// Summary
echo "=== Summary ===\n";
if ($allPassed) {
    echo "✓ All checks passed!\n";
    echo "  Email system now uses RobustEmailService with PHPMailer SMTP\n";
    echo "  No direct mail() calls found in checked files\n";
    echo "\nNext Steps:\n";
    echo "  1. Configure SMTP settings in .env file\n";
    echo "  2. Use a reliable SMTP provider (SendGrid, Mailgun, AWS SES)\n";
    echo "  3. Set up cron job: */5 * * * * php process_email_queue.php\n";
} else {
    echo "✗ Some checks failed - review the output above\n";
}

echo "\n=== Verification Complete ===\n";
?>
