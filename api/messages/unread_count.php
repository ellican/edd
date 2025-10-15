<?php
/**
 * Get Unread Message Count API
 * Returns the count of unread messages for the logged-in user
 */

header('Content-Type: application/json');
require_once __DIR__ . '/../../includes/init.php';

// Require login
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized']);
    exit;
}

$userId = Session::getUserId();

try {
    $db = Database::getInstance()->getConnection();
    
    // Get unread count
    $stmt = $db->prepare("
        SELECT COUNT(*) as unread_count
        FROM product_inquiry_messages
        WHERE receiver_id = ? AND is_read = 0
    ");
    $stmt->execute([$userId]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'unread_count' => (int)$result['unread_count']
    ]);
    
} catch (Exception $e) {
    error_log("Get unread count error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Failed to get unread count']);
}
