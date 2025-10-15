<?php
/**
 * Start Product Inquiry Conversation API
 * Creates a new conversation thread for a product inquiry
 */

header('Content-Type: application/json');
require_once __DIR__ . '/../../includes/init.php';

// Require login
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$userId = Session::getUserId();

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $productId = $input['product_id'] ?? null;
    
    if (!$productId) {
        http_response_code(400);
        echo json_encode(['error' => 'Product ID is required']);
        exit;
    }
    
    $db = Database::getInstance()->getConnection();
    
    // Get product and seller info
    $productStmt = $db->prepare("SELECT id, vendor_id FROM products WHERE id = ? AND status = 'active'");
    $productStmt->execute([$productId]);
    $product = $productStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$product) {
        http_response_code(404);
        echo json_encode(['error' => 'Product not found']);
        exit;
    }
    
    $sellerId = $product['vendor_id'];
    
    // Can't message yourself
    if ($sellerId == $userId) {
        http_response_code(400);
        echo json_encode(['error' => 'You cannot message yourself']);
        exit;
    }
    
    // Check if thread already exists
    $threadCheckStmt = $db->prepare("
        SELECT id FROM conversation_threads 
        WHERE product_id = ? AND buyer_id = ? AND seller_id = ?
    ");
    $threadCheckStmt->execute([$productId, $userId, $sellerId]);
    $existingThread = $threadCheckStmt->fetch(PDO::FETCH_ASSOC);
    
    if ($existingThread) {
        echo json_encode([
            'success' => true,
            'thread_id' => $existingThread['id'],
            'existing' => true
        ]);
        exit;
    }
    
    // Create new thread
    $createThreadStmt = $db->prepare("
        INSERT INTO conversation_threads 
        (product_id, buyer_id, seller_id, last_message_at, created_at)
        VALUES (?, ?, ?, NOW(), NOW())
    ");
    $createThreadStmt->execute([$productId, $userId, $sellerId]);
    $threadId = $db->lastInsertId();
    
    echo json_encode([
        'success' => true,
        'thread_id' => $threadId,
        'product_id' => $productId,
        'seller_id' => $sellerId,
        'existing' => false
    ]);
    
} catch (Exception $e) {
    error_log("Start conversation error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Failed to start conversation']);
}
