<?php
/**
 * Toggle Product Feature Status API
 */

header('Content-Type: application/json');
require_once __DIR__ . '/../../../includes/init.php';

Session::requireLogin();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$userRole = Session::getUserRole();
if ($userRole !== 'seller' && $userRole !== 'vendor' && $userRole !== 'admin') {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Access denied']);
    exit;
}

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $productId = $input['product_id'] ?? null;
    $featured = $input['featured'] ?? false;
    
    if (!$productId) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Product ID is required']);
        exit;
    }
    
    $db = Database::getInstance()->getConnection();
    $userId = Session::getUserId();
    
    // Verify ownership (unless admin)
    if ($userRole !== 'admin') {
        $checkStmt = $db->prepare("SELECT vendor_id FROM products WHERE id = ?");
        $checkStmt->execute([$productId]);
        $product = $checkStmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$product || $product['vendor_id'] != $userId) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'You do not own this product']);
            exit;
        }
    }
    
    // Update feature status
    $stmt = $db->prepare("UPDATE products SET is_featured = ? WHERE id = ?");
    $stmt->execute([$featured ? 1 : 0, $productId]);
    
    echo json_encode([
        'success' => true,
        'message' => $featured ? 'Product featured successfully' : 'Product unfeatured successfully'
    ]);
    
} catch (Exception $e) {
    error_log("Feature product error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Server error']);
}
