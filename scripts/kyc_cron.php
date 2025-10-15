<?php
/**
 * KYC Automated Tasks Cron Job
 * Run this script daily to process:
 * - Expiry reminders
 * - Mark expired records
 * - Incomplete KYC reminders
 * 
 * Setup cron: 0 2 * * * /usr/bin/php /path/to/kyc_cron.php
 */

require_once __DIR__ . '/includes/init.php';
require_once __DIR__ . '/includes/models/KYCRecord.php';
require_once __DIR__ . '/includes/services/KYCNotificationService.php';

echo "=== KYC Automated Tasks Starting ===\n";
echo "Date: " . date('Y-m-d H:i:s') . "\n\n";

try {
    $kycModel = new KYCRecord();
    $notificationService = new KYCNotificationService();
    
    // Task 1: Mark expired records
    echo "Task 1: Marking expired records...\n";
    $expiredCount = $kycModel->markExpiredRecords();
    echo "  Marked {$expiredCount} records as expired\n\n";
    
    // Task 2: Send expiry reminders
    echo "Task 2: Sending expiry reminders...\n";
    KYCNotificationService::processExpiryReminders();
    echo "  Expiry reminders processed\n\n";
    
    // Task 3: Send incomplete KYC reminders (for records older than 7 days)
    echo "Task 3: Sending incomplete KYC reminders...\n";
    $stmt = db()->prepare("
        SELECT id FROM kyc_records 
        WHERE status = 'incomplete'
        AND created_at < DATE_SUB(NOW(), INTERVAL 7 DAY)
        AND id NOT IN (
            SELECT kyc_record_id FROM kyc_notifications 
            WHERE notification_type = 'incomplete' 
            AND DATE(sent_at) = CURDATE()
        )
        LIMIT 100
    ");
    $stmt->execute();
    $incompleteRecords = $stmt->fetchAll();
    
    $incompleteCount = 0;
    foreach ($incompleteRecords as $record) {
        if ($notificationService->sendIncompleteReminder($record['id'])) {
            $incompleteCount++;
        }
    }
    echo "  Sent {$incompleteCount} incomplete KYC reminders\n\n";
    
    echo "=== KYC Automated Tasks Completed Successfully ===\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    error_log("KYC Cron Job Error: " . $e->getMessage());
    exit(1);
}

exit(0);
