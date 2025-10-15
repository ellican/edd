<?php
/**
 * Flag/Report Message API
 * Allows users to flag inappropriate messages
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
    
    $messageId = $input['message_id'] ?? null;
    $reason = trim($input['reason'] ?? '');
    
    if (!$messageId || empty($reason)) {
        http_response_code(400);
        echo json_encode(['error' => 'Message ID and reason are required']);
        exit;
    }
    
    $db = Database::getInstance()->getConnection();
    
    // Verify message exists and user has access to the thread
    $messageStmt = $db->prepare("
        SELECT pim.*, ct.buyer_id, ct.seller_id 
        FROM product_inquiry_messages pim
        INNER JOIN conversation_threads ct ON pim.thread_id = ct.id
        WHERE pim.id = ?
    ");
    $messageStmt->execute([$messageId]);
    $message = $messageStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$message) {
        http_response_code(404);
        echo json_encode(['error' => 'Message not found']);
        exit;
    }
    
    // Verify user is part of the conversation
    if ($message['buyer_id'] != $userId && $message['seller_id'] != $userId) {
        http_response_code(403);
        echo json_encode(['error' => 'Access denied']);
        exit;
    }
    
    // Flag the message
    $flagStmt = $db->prepare("
        UPDATE product_inquiry_messages 
        SET flagged = 1, flagged_reason = ?, flagged_by = ?
        WHERE id = ?
    ");
    $flagStmt->execute([$reason, $userId, $messageId]);
    
    // Log the flag action
    error_log("Message {$messageId} flagged by user {$userId}: {$reason}");
    
    echo json_encode([
        'success' => true,
        'message' => 'Message flagged for review'
    ]);
    
} catch (Exception $e) {
    error_log("Flag message error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Failed to flag message']);
}
