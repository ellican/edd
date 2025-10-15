<?php
/**
 * Get Thread Messages API
 * Returns messages for a specific conversation thread
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
$threadId = $_GET['thread_id'] ?? null;

if (!$threadId) {
    http_response_code(400);
    echo json_encode(['error' => 'Thread ID is required']);
    exit;
}

try {
    $db = Database::getInstance()->getConnection();
    
    // Verify user has access to this thread
    $threadStmt = $db->prepare("
        SELECT * FROM conversation_threads 
        WHERE id = ? AND (buyer_id = ? OR seller_id = ?)
    ");
    $threadStmt->execute([$threadId, $userId, $userId]);
    $thread = $threadStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$thread) {
        http_response_code(403);
        echo json_encode(['error' => 'Access denied']);
        exit;
    }
    
    // Get pagination params
    $page = max(1, (int)($_GET['page'] ?? 1));
    $limit = 50;
    $offset = ($page - 1) * $limit;
    
    // Get messages
    $query = "
        SELECT 
            pim.id,
            pim.thread_id,
            pim.sender_id,
            pim.receiver_id,
            pim.sender_role,
            pim.message_text,
            pim.attachment_path,
            pim.attachment_type,
            pim.attachment_size,
            pim.is_read,
            pim.flagged,
            pim.created_at,
            sender.first_name as sender_first_name,
            sender.last_name as sender_last_name,
            sender.username as sender_username
        FROM product_inquiry_messages pim
        INNER JOIN users sender ON pim.sender_id = sender.id
        WHERE pim.thread_id = ?
        ORDER BY pim.created_at ASC
        LIMIT $limit OFFSET $offset
    ";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$threadId]);
    $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Mark messages as read
    $markReadStmt = $db->prepare("
        UPDATE product_inquiry_messages 
        SET is_read = 1 
        WHERE thread_id = ? AND receiver_id = ? AND is_read = 0
    ");
    $markReadStmt->execute([$threadId, $userId]);
    
    // Get product info
    $productStmt = $db->prepare("
        SELECT p.id, p.name, p.image, p.price, p.slug, p.vendor_id
        FROM products p
        WHERE p.id = ?
    ");
    $productStmt->execute([$thread['product_id']]);
    $product = $productStmt->fetch(PDO::FETCH_ASSOC);
    
    // Get total count
    $countStmt = $db->prepare("SELECT COUNT(*) FROM product_inquiry_messages WHERE thread_id = ?");
    $countStmt->execute([$threadId]);
    $totalCount = $countStmt->fetchColumn();
    
    echo json_encode([
        'success' => true,
        'thread' => $thread,
        'product' => $product,
        'messages' => $messages,
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total' => $totalCount,
            'total_pages' => ceil($totalCount / $limit)
        ]
    ]);
    
} catch (Exception $e) {
    error_log("Get thread messages error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Failed to fetch messages']);
}
