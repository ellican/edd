<?php
/**
 * Get Order Receipt API
 * Generate downloadable receipt for an order
 */

require_once __DIR__ . '/../../includes/init.php';

// Check if user is logged in
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Authentication required']);
    exit;
}

$userId = Session::getUserId();
$orderId = (int)($_GET['order_id'] ?? 0);

if (empty($orderId)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Order ID is required']);
    exit;
}

try {
    $db = Database::getInstance()->getConnection();
    
    // Get order details - ensure it belongs to the user
    $stmt = $db->prepare("
        SELECT o.*, u.email, u.first_name, u.last_name
        FROM orders o
        JOIN users u ON o.user_id = u.id
        WHERE o.id = ? AND o.user_id = ?
    ");
    $stmt->execute([$orderId, $userId]);
    $order = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$order) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Order not found']);
        exit;
    }
    
    // Get order items
    $stmt = $db->prepare("
        SELECT oi.*, p.name as product_name, p.image
        FROM order_items oi
        LEFT JOIN products p ON oi.product_id = p.id
        WHERE oi.order_id = ?
    ");
    $stmt->execute([$orderId]);
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // If format=html, generate HTML receipt
    if (isset($_GET['format']) && $_GET['format'] === 'html') {
        header('Content-Type: text/html');
        include __DIR__ . '/../../templates/receipt.php';
        exit;
    }
    
    // Default: return JSON
    header('Content-Type: application/json');
    echo json_encode([
        'success' => true,
        'order' => $order,
        'items' => $items
    ]);
    
} catch (Exception $e) {
    error_log("Get Receipt Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to generate receipt'
    ]);
}
