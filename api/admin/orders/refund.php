<?php
/**
 * Admin API: Refund Order
 */

require_once __DIR__ . '/../../../includes/init.php';
require_once __DIR__ . '/../../../includes/rbac.php';

header('Content-Type: application/json');

if (!Session::isLoggedIn() || !isAdmin()) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => 'Access denied']);
    exit;
}

checkPermission('orders.edit');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$postData = json_decode(file_get_contents('php://input'), true);

if (!verifyCsrfToken($postData['csrf_token'] ?? '')) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => 'Invalid CSRF token']);
    exit;
}

$orderId = (int)($postData['order_id'] ?? 0);
$reason = sanitizeInput($postData['reason'] ?? '');

if ($orderId <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid order ID']);
    exit;
}

try {
    $db = Database::getInstance()->getConnection();
    $stmt = $db->prepare("UPDATE orders SET status = 'refunded', refund_reason = ? WHERE id = ?");
    $stmt->execute([$reason, $orderId]);
    
    echo json_encode(['success' => true, 'message' => 'Order refunded']);
} catch (Exception $e) {
    error_log("Refund Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Failed to refund order']);
}
