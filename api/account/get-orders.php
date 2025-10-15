<?php
/**
 * Get User Orders API
 * Fetch orders with filtering and pagination
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

// Check if user is logged in
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Authentication required']);
    exit;
}

$userId = Session::getUserId();
$status = sanitizeInput($_GET['status'] ?? '');
$page = max(1, (int)($_GET['page'] ?? 1));
$perPage = min(50, max(1, (int)($_GET['per_page'] ?? 10)));
$offset = ($page - 1) * $perPage;

try {
    $db = Database::getInstance()->getConnection();
    
    // Build query with optional status filter
    $where = "WHERE user_id = ?";
    $params = [$userId];
    
    if (!empty($status)) {
        $where .= " AND status = ?";
        $params[] = $status;
    }
    
    // Get total count
    $countStmt = $db->prepare("SELECT COUNT(*) FROM orders $where");
    $countStmt->execute($params);
    $total = $countStmt->fetchColumn();
    
    // Get orders
    $stmt = $db->prepare("
        SELECT 
            o.*,
            (SELECT COUNT(*) FROM order_items WHERE order_id = o.id) as item_count,
            (SELECT GROUP_CONCAT(p.name SEPARATOR ', ') 
             FROM order_items oi 
             JOIN products p ON oi.product_id = p.id 
             WHERE oi.order_id = o.id 
             LIMIT 3) as product_names
        FROM orders o
        $where
        ORDER BY o.created_at DESC
        LIMIT ? OFFSET ?
    ");
    
    $params[] = $perPage;
    $params[] = $offset;
    $stmt->execute($params);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format orders
    foreach ($orders as &$order) {
        $order['formatted_total'] = '$' . number_format($order['total'], 2);
        $order['formatted_date'] = date('M j, Y', strtotime($order['created_at']));
        $order['can_cancel'] = in_array($order['status'], ['pending', 'processing']);
        $order['can_reorder'] = in_array($order['status'], ['delivered', 'completed']);
    }
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => $orders,
        'orders' => $orders, // Keep for backward compatibility
        'pagination' => [
            'page' => $page,
            'per_page' => $perPage,
            'total' => $total,
            'total_pages' => ceil($total / $perPage)
        ]
    ]);
    
} catch (Exception $e) {
    error_log("Get Orders Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to fetch orders'
    ]);
}
