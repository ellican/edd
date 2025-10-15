<?php
/**
 * Cron Job: Expire Sponsored Products
 * 
 * This script should be run daily to automatically expire sponsored products
 * that have passed their sponsorship period.
 * 
 * Setup: Add to crontab:
 * 0 0 * * * cd /path/to/edd && php scripts/expire_sponsored_products.php
 */

require_once __DIR__ . '/../includes/init.php';
require_once __DIR__ . '/../includes/notifications.php';

$db = db();
$notificationService = new NotificationService();

try {
    // Start transaction
    $db->beginTransaction();
    
    // Find all active sponsored products that have expired
    $findExpiredQuery = "
        SELECT sp.id, sp.product_id, sp.seller_id, p.name as product_name
        FROM sponsored_products sp
        INNER JOIN products p ON sp.product_id = p.id
        WHERE sp.status = 'active' 
        AND sp.sponsored_until <= NOW()
    ";
    $stmt = $db->prepare($findExpiredQuery);
    $stmt->execute();
    $expiredAds = $stmt->fetchAll();
    
    // Update status to expired
    $expireQuery = "
        UPDATE sponsored_products 
        SET status = 'expired', updated_at = NOW()
        WHERE status = 'active' 
        AND sponsored_until <= NOW()
    ";
    $stmt = $db->prepare($expireQuery);
    $stmt->execute();
    $expiredCount = $stmt->rowCount();
    
    // Send notifications to sellers
    foreach ($expiredAds as $ad) {
        try {
            $notificationService->send(
                'sponsored_ad_expired',
                $ad['seller_id'],
                [
                    'product_name' => $ad['product_name'],
                    'action_url' => '/seller/marketing.php'
                ],
                true,
                true
            );
        } catch (Exception $e) {
            error_log("Failed to send expiration notification for ad {$ad['id']}: " . $e->getMessage());
        }
    }
    
    // Log the expiration
    error_log("Sponsored Products Cron: Expired {$expiredCount} sponsored products and sent notifications");
    
    // Commit transaction
    $db->commit();
    
    echo "Successfully expired {$expiredCount} sponsored products and sent notifications.\n";
    
} catch (Exception $e) {
    // Rollback on error
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    
    error_log("Sponsored Products Cron Error: " . $e->getMessage());
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}

exit(0);
