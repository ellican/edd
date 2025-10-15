<?php
/**
 * Bulk Product Actions API
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
    
    $productIds = $input['product_ids'] ?? [];
    $action = $input['action'] ?? '';
    
    if (empty($productIds) || !is_array($productIds)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Product IDs are required']);
        exit;
    }
    
    if (!in_array($action, ['active', 'inactive', 'delete'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
        exit;
    }
    
    $db = Database::getInstance()->getConnection();
    $userId = Session::getUserId();
    
    // Verify ownership (unless admin)
    $placeholders = implode(',', array_fill(0, count($productIds), '?'));
    
    if ($userRole !== 'admin') {
        $checkStmt = $db->prepare("SELECT id FROM products WHERE id IN ($placeholders) AND vendor_id = ?");
        $checkStmt->execute(array_merge($productIds, [$userId]));
        $ownedProducts = $checkStmt->fetchAll(PDO::FETCH_COLUMN);
        
        if (count($ownedProducts) !== count($productIds)) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'You do not own all selected products']);
            exit;
        }
    }
    
    // Perform action
    if ($action === 'delete') {
        $stmt = $db->prepare("DELETE FROM products WHERE id IN ($placeholders)");
        $stmt->execute($productIds);
        $message = count($productIds) . ' product(s) deleted successfully';
    } else {
        $stmt = $db->prepare("UPDATE products SET status = ? WHERE id IN ($placeholders)");
        $stmt->execute(array_merge([$action], $productIds));
        $message = count($productIds) . ' product(s) updated successfully';
    }
    
    echo json_encode([
        'success' => true,
        'message' => $message,
        'count' => count($productIds)
    ]);
    
} catch (Exception $e) {
    error_log("Bulk action error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Server error']);
}
