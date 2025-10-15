<?php
/**
 * Get Product Inquiry Conversations API
 * Returns list of conversation threads for the logged-in user
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
$userRole = Session::getUserRole();

try {
    $db = Database::getInstance()->getConnection();
    
    // Get filter from query params
    $filter = $_GET['filter'] ?? 'all'; // all, unread, sellers, buyers
    $page = max(1, (int)($_GET['page'] ?? 1));
    $limit = 20;
    $offset = ($page - 1) * $limit;
    
    // Build query based on user role
    $whereConditions = [];
    $params = [];
    
    if ($userRole === 'seller' || $userRole === 'vendor') {
        // Seller sees conversations where they are the seller
        $whereConditions[] = 'ct.seller_id = ?';
        $params[] = $userId;
        
        if ($filter === 'buyers') {
            // No additional filter needed, all are from buyers
        }
    } else {
        // Buyer sees conversations where they are the buyer
        $whereConditions[] = 'ct.buyer_id = ?';
        $params[] = $userId;
        
        if ($filter === 'sellers') {
            // No additional filter needed, all are to sellers
        }
    }
    
    if ($filter === 'unread') {
        $whereConditions[] = 'EXISTS (
            SELECT 1 FROM product_inquiry_messages pim 
            WHERE pim.thread_id = ct.id 
            AND pim.receiver_id = ? 
            AND pim.is_read = 0
        )';
        $params[] = $userId;
    }
    
    $whereClause = !empty($whereConditions) ? 'WHERE ' . implode(' AND ', $whereConditions) : '';
    
    // Get conversations with product and user info
    $query = "
        SELECT 
            ct.id as thread_id,
            ct.product_id,
            ct.buyer_id,
            ct.seller_id,
            ct.status,
            ct.last_message_at,
            ct.created_at,
            p.name as product_name,
            p.image as product_image,
            p.price as product_price,
            p.slug as product_slug,
            buyer.first_name as buyer_first_name,
            buyer.last_name as buyer_last_name,
            buyer.username as buyer_username,
            seller.first_name as seller_first_name,
            seller.last_name as seller_last_name,
            seller.username as seller_username,
            (SELECT COUNT(*) FROM product_inquiry_messages 
             WHERE thread_id = ct.id AND receiver_id = ? AND is_read = 0) as unread_count,
            (SELECT message_text FROM product_inquiry_messages 
             WHERE thread_id = ct.id ORDER BY created_at DESC LIMIT 1) as last_message,
            (SELECT sender_role FROM product_inquiry_messages 
             WHERE thread_id = ct.id ORDER BY created_at DESC LIMIT 1) as last_message_sender
        FROM conversation_threads ct
        INNER JOIN products p ON ct.product_id = p.id
        INNER JOIN users buyer ON ct.buyer_id = buyer.id
        INNER JOIN users seller ON ct.seller_id = seller.id
        $whereClause
        ORDER BY ct.last_message_at DESC
        LIMIT $limit OFFSET $offset
    ";
    
    $allParams = array_merge([$userId], $params);
    $stmt = $db->prepare($query);
    $stmt->execute($allParams);
    $conversations = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get total count
    $countQuery = "SELECT COUNT(*) FROM conversation_threads ct $whereClause";
    $countStmt = $db->prepare($countQuery);
    $countStmt->execute($params);
    $totalCount = $countStmt->fetchColumn();
    
    echo json_encode([
        'success' => true,
        'conversations' => $conversations,
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total' => $totalCount,
            'total_pages' => ceil($totalCount / $limit)
        ]
    ]);
    
} catch (Exception $e) {
    error_log("Get conversations error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Failed to fetch conversations']);
}
