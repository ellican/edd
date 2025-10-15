<?php
/**
 * Get User Wishlist API
 * Returns all wishlist items for the logged-in user
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

// Require login
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Unauthorized']);
    exit;
}

// Only accept GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

try {
    $db = db();
    $userId = Session::getUserId();
    
    // Get wishlist items with product details
    $stmt = $db->prepare("
        SELECT w.*, p.name, p.price, p.image_url, p.stock_quantity, p.status as product_status
        FROM wishlists w
        JOIN products p ON w.product_id = p.id
        WHERE w.user_id = ?
        ORDER BY w.created_at DESC
    ");
    $stmt->execute([$userId]);
    $wishlist = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => $wishlist
    ]);
    
} catch (Exception $e) {
    error_log("Get wishlist error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to retrieve wishlist'
    ]);
}
