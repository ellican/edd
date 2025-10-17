<?php
/**
 * Email Queue Processor
 * E-Commerce Platform
 * 
 * This script processes the email queue and should be run via cron job
 * Usage: php process_email_queue.php
 * Recommended cron: */5 * * * * /usr/bin/php /path/to/process_email_queue.php
 */

require_once __DIR__ . '/includes/init.php';
require_once __DIR__ . '/includes/RobustEmailService.php';

echo "Email Queue Processor Starting...\n";
echo "Timestamp: " . date('Y-m-d H:i:s') . "\n";

try {
    $emailService = new RobustEmailService();
    
    // Test SMTP connection first
    if (!$emailService->testConnection()) {
        echo "WARNING: SMTP connection test failed!\n";
        echo "Error: " . $emailService->getLastError() . "\n";
        echo "Emails will still be attempted but may fail.\n";
    }
    
    // Process up to 50 emails per run
    $processed = $emailService->processQueue(50);
    
    echo "Processed {$processed} emails from queue.\n";
    
    if ($processed > 0) {
        // Log to database if available
        try {
            $db = db();
            $stmt = $db->prepare("
                INSERT INTO system_logs (log_type, message, created_at)
                VALUES ('email_queue', ?, NOW())
            ");
            $stmt->execute(["Email queue processed: {$processed} emails"]);
        } catch (Exception $e) {
            // Silently fail if logging fails
        }
    }
    
    echo "Email Queue Processor Complete.\n";
    exit(0);
    
} catch (Exception $e) {
    echo "Error processing email queue: " . $e->getMessage() . "\n";
    error_log("Email queue processing failed: " . $e->getMessage());
    exit(1);
}
?>