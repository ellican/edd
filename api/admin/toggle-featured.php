<?php
/**
 * API Endpoint: Toggle Product Featured Status
 * Admin-only endpoint for toggling product featured status
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

try {
    // Verify admin access
    Session::requireLogin();
    RoleMiddleware::requireAdmin();
    
    // Validate CSRF token
    $headers = getallheaders();
    $csrfToken = $headers['X-Csrf-Token'] ?? $_POST['csrf_token'] ?? '';
    if (!verifyCsrfToken($csrfToken)) {
        throw new Exception('Invalid CSRF token');
    }
    
    // Get product ID
    $productId = (int)($_POST['product_id'] ?? 0);
    if ($productId <= 0) {
        throw new Exception('Invalid product ID');
    }
    
    $db = db();
    
    // Check if product exists and get current featured status
    $stmt = $db->prepare("SELECT id, featured FROM products WHERE id = ?");
    $stmt->execute([$productId]);
    $product = $stmt->fetch();
    
    if (!$product) {
        throw new Exception('Product not found');
    }
    
    // Toggle featured status
    $newFeaturedStatus = empty($product['featured']) ? 1 : 0;
    
    $updateStmt = $db->prepare("UPDATE products SET featured = ?, updated_at = NOW() WHERE id = ?");
    $updateStmt->execute([$newFeaturedStatus, $productId]);
    
    echo json_encode([
        'success' => true,
        'is_featured' => (bool)$newFeaturedStatus,
        'message' => $newFeaturedStatus ? 'Product is now featured' : 'Product is no longer featured'
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
