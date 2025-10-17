#!/usr/bin/env php
<?php
/**
 * Email Configuration Test Script
 * Tests direct email sending from server
 */

// Load configuration
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/includes/db.php';
require_once __DIR__ . '/vendor/autoload.php';
require_once __DIR__ . '/includes/RobustEmailService.php';

echo "========================================\n";
echo "Email Configuration Test\n";
echo "========================================\n\n";

// Test 1: Check configuration
echo "1. Checking Email Configuration...\n";
echo "   - MAIL_METHOD: " . (defined('MAIL_METHOD') ? MAIL_METHOD : 'smtp (default)') . "\n";
echo "   - SMTP_HOST: " . SMTP_HOST . "\n";
echo "   - SMTP_PORT: " . SMTP_PORT . "\n";
echo "   - SMTP_ENCRYPTION: " . SMTP_ENCRYPTION . "\n";
echo "   - FROM_EMAIL: " . FROM_EMAIL . "\n";
echo "   - FROM_NAME: " . FROM_NAME . "\n";

if (defined('DKIM_DOMAIN') && !empty(DKIM_DOMAIN)) {
    echo "   - DKIM_DOMAIN: " . DKIM_DOMAIN . "\n";
    echo "   - DKIM_SELECTOR: " . DKIM_SELECTOR . "\n";
    
    if (defined('DKIM_PRIVATE_KEY') && !empty(DKIM_PRIVATE_KEY)) {
        if (file_exists(DKIM_PRIVATE_KEY)) {
            echo "   - DKIM_PRIVATE_KEY: ✓ Found at " . DKIM_PRIVATE_KEY . "\n";
        } else {
            echo "   - DKIM_PRIVATE_KEY: ✗ File not found: " . DKIM_PRIVATE_KEY . "\n";
        }
    } else {
        echo "   - DKIM_PRIVATE_KEY: Not configured\n";
    }
} else {
    echo "   - DKIM: Not configured (optional but recommended)\n";
}
echo "\n";

// Test 2: Check Postfix/MTA status (if using localhost)
if (SMTP_HOST === 'localhost' || SMTP_HOST === '127.0.0.1') {
    echo "2. Checking Local Mail Server...\n";
    
    // Try to connect to port 25
    $connection = @fsockopen(SMTP_HOST, 25, $errno, $errstr, 5);
    if ($connection) {
        echo "   ✓ SMTP server is running on " . SMTP_HOST . ":25\n";
        fclose($connection);
    } else {
        echo "   ✗ Cannot connect to SMTP server on " . SMTP_HOST . ":25\n";
        echo "   Error: $errstr ($errno)\n";
        echo "   Please install and configure Postfix (see DIRECT_EMAIL_SETUP.md)\n";
    }
    echo "\n";
}

// Test 3: Check database connection
echo "3. Checking Database Connection...\n";
try {
    $db = db();
    echo "   ✓ Database connection successful\n";
    
    // Check email tables
    $tables = ['email_queue', 'email_logs', 'email_bounces'];
    foreach ($tables as $table) {
        $result = $db->query("SHOW TABLES LIKE '$table'");
        if ($result && $result->rowCount() > 0) {
            echo "   ✓ Table '$table' exists\n";
        } else {
            echo "   ✗ Table '$table' not found (may need migration)\n";
        }
    }
} catch (Exception $e) {
    echo "   ✗ Database connection failed: " . $e->getMessage() . "\n";
}
echo "\n";

// Test 4: Initialize email service
echo "4. Initializing Email Service...\n";
try {
    $emailService = new RobustEmailService();
    echo "   ✓ RobustEmailService initialized successfully\n";
} catch (Exception $e) {
    echo "   ✗ Failed to initialize email service: " . $e->getMessage() . "\n";
    exit(1);
}
echo "\n";

// Test 5: DNS checks (optional)
echo "5. Checking DNS Configuration (optional)...\n";
$domain = 'fezamarket.com';

// Check MX record
$mxRecords = [];
if (getmxrr($domain, $mxRecords)) {
    echo "   ✓ MX records found:\n";
    foreach ($mxRecords as $mx) {
        echo "     - $mx\n";
    }
} else {
    echo "   ⚠ No MX records found for $domain\n";
}

// Check SPF record
$spfRecord = dns_get_record($domain, DNS_TXT);
$spfFound = false;
foreach ($spfRecord as $record) {
    if (isset($record['txt']) && strpos($record['txt'], 'v=spf1') === 0) {
        echo "   ✓ SPF record found: " . $record['txt'] . "\n";
        $spfFound = true;
        break;
    }
}
if (!$spfFound) {
    echo "   ⚠ No SPF record found (see DNS_CONFIGURATION.md)\n";
}

// Check DKIM record
$dkimRecord = dns_get_record('default._domainkey.' . $domain, DNS_TXT);
if (!empty($dkimRecord)) {
    echo "   ✓ DKIM record found\n";
} else {
    echo "   ⚠ No DKIM record found (see DNS_CONFIGURATION.md)\n";
}

// Check DMARC record
$dmarcRecord = dns_get_record('_dmarc.' . $domain, DNS_TXT);
if (!empty($dmarcRecord)) {
    echo "   ✓ DMARC record found\n";
} else {
    echo "   ⚠ No DMARC record found (see DNS_CONFIGURATION.md)\n";
}

echo "\n";

// Test 6: Offer to send test email
echo "6. Email Sending Test\n";
echo "   Do you want to send a test email? (y/n): ";
$handle = fopen("php://stdin", "r");
$response = trim(fgets($handle));

if (strtolower($response) === 'y' || strtolower($response) === 'yes') {
    echo "   Enter recipient email address: ";
    $testEmail = trim(fgets($handle));
    
    if (filter_var($testEmail, FILTER_VALIDATE_EMAIL)) {
        echo "\n   Sending test email to $testEmail...\n";
        
        $subject = "FezaMarket Email Test - " . date('Y-m-d H:i:s');
        $body = "
            <html>
            <head>
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: #4CAF50; color: white; padding: 20px; text-align: center; }
                    .content { background: #f9f9f9; padding: 20px; margin: 20px 0; }
                    .footer { text-align: center; color: #666; font-size: 12px; }
                    .success { color: #4CAF50; font-weight: bold; }
                </style>
            </head>
            <body>
                <div class='container'>
                    <div class='header'>
                        <h1>✓ Email Test Successful!</h1>
                    </div>
                    <div class='content'>
                        <h2>FezaMarket Email System</h2>
                        <p class='success'>This test email confirms that your email system is working correctly!</p>
                        <p><strong>Configuration Details:</strong></p>
                        <ul>
                            <li>Mail Method: " . (defined('MAIL_METHOD') ? MAIL_METHOD : 'smtp') . "</li>
                            <li>SMTP Host: " . SMTP_HOST . "</li>
                            <li>SMTP Port: " . SMTP_PORT . "</li>
                            <li>From: " . FROM_EMAIL . "</li>
                            <li>Sent: " . date('Y-m-d H:i:s T') . "</li>
                        </ul>
                        <p>Your email configuration for direct server sending is now active.</p>
                    </div>
                    <div class='footer'>
                        <p>FezaMarket - Direct Email System<br>
                        Server IP: 5.189.180.149<br>
                        Domain: fezamarket.com</p>
                    </div>
                </div>
            </body>
            </html>
        ";
        
        $result = $emailService->sendEmail(
            $testEmail,
            $subject,
            $body,
            [
                'to_name' => 'Test User',
                'priority' => 1,
                'alt_body' => "Email Test Successful!\n\nThis test email confirms that your FezaMarket email system is working correctly.\n\nConfiguration:\n- Mail Method: " . (defined('MAIL_METHOD') ? MAIL_METHOD : 'smtp') . "\n- SMTP Host: " . SMTP_HOST . "\n- From: " . FROM_EMAIL . "\n- Sent: " . date('Y-m-d H:i:s T')
            ]
        );
        
        if ($result) {
            echo "   ✓ Test email sent successfully!\n";
            echo "   Check your inbox (and spam folder) at: $testEmail\n";
            echo "\n   Note: Check the following:\n";
            echo "   1. Email arrived in inbox (not spam)\n";
            echo "   2. Sender shows as: " . FROM_NAME . " <" . FROM_EMAIL . ">\n";
            echo "   3. Email is properly formatted with HTML\n";
            echo "   4. Use https://www.mail-tester.com for deliverability score\n";
        } else {
            echo "   ✗ Failed to send test email\n";
            echo "   Check error logs for details\n";
        }
    } else {
        echo "   ✗ Invalid email address\n";
    }
} else {
    echo "   Skipping email sending test\n";
}

fclose($handle);
echo "\n";

// Summary
echo "========================================\n";
echo "Test Summary\n";
echo "========================================\n";
echo "Configuration: " . (defined('MAIL_METHOD') ? MAIL_METHOD : 'smtp') . " via " . SMTP_HOST . ":" . SMTP_PORT . "\n";
echo "\nNext Steps:\n";
echo "1. If using localhost, install Postfix (see DIRECT_EMAIL_SETUP.md)\n";
echo "2. Configure DNS records (see DNS_CONFIGURATION.md)\n";
echo "3. Generate DKIM keys and add to DNS\n";
echo "4. Test deliverability with https://www.mail-tester.com\n";
echo "5. Set up email queue cron job\n";
echo "\nDocumentation:\n";
echo "- Server Setup: DIRECT_EMAIL_SETUP.md\n";
echo "- DNS Config: DNS_CONFIGURATION.md\n";
echo "========================================\n";
