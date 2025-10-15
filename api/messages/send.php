<?php
/**
 * Send Product Inquiry Message API
 * Sends a message in a product inquiry conversation
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
$userRole = Session::getUserRole();

try {
    // Handle both JSON and multipart/form-data (for file uploads)
    $contentType = $_SERVER['CONTENT_TYPE'] ?? '';
    
    if (strpos($contentType, 'application/json') !== false) {
        $input = json_decode(file_get_contents('php://input'), true);
    } else {
        $input = $_POST;
    }
    
    $threadId = $input['thread_id'] ?? null;
    $productId = $input['product_id'] ?? null;
    $receiverId = $input['receiver_id'] ?? null;
    $message = trim($input['message'] ?? '');
    
    // Validation
    if (empty($message) || strlen($message) > 5000) {
        http_response_code(400);
        echo json_encode(['error' => 'Message must be between 1 and 5000 characters']);
        exit;
    }
    
    $db = Database::getInstance()->getConnection();
    
    // If thread_id not provided, try to find or create thread
    if (!$threadId && $productId && $receiverId) {
        // Get product and seller info
        $productStmt = $db->prepare("SELECT vendor_id FROM products WHERE id = ?");
        $productStmt->execute([$productId]);
        $product = $productStmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$product) {
            http_response_code(404);
            echo json_encode(['error' => 'Product not found']);
            exit;
        }
        
        // Determine buyer and seller
        if ($userRole === 'seller' || $userRole === 'vendor') {
            $sellerId = $userId;
            $buyerId = $receiverId;
        } else {
            $buyerId = $userId;
            $sellerId = $receiverId;
        }
        
        // Check if thread exists
        $threadCheckStmt = $db->prepare("
            SELECT id FROM conversation_threads 
            WHERE product_id = ? AND buyer_id = ? AND seller_id = ?
        ");
        $threadCheckStmt->execute([$productId, $buyerId, $sellerId]);
        $existingThread = $threadCheckStmt->fetch(PDO::FETCH_ASSOC);
        
        if ($existingThread) {
            $threadId = $existingThread['id'];
        } else {
            // Create new thread
            $createThreadStmt = $db->prepare("
                INSERT INTO conversation_threads 
                (product_id, buyer_id, seller_id, last_message_at, created_at)
                VALUES (?, ?, ?, NOW(), NOW())
            ");
            $createThreadStmt->execute([$productId, $buyerId, $sellerId]);
            $threadId = $db->lastInsertId();
        }
    }
    
    if (!$threadId) {
        http_response_code(400);
        echo json_encode(['error' => 'Thread ID or product/receiver information required']);
        exit;
    }
    
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
    
    // Determine sender role and receiver
    if ($thread['buyer_id'] == $userId) {
        $senderRole = 'buyer';
        $receiverId = $thread['seller_id'];
    } else if ($thread['seller_id'] == $userId) {
        $senderRole = 'seller';
        $receiverId = $thread['buyer_id'];
    } else {
        $senderRole = 'admin';
        // Receiver will be determined by context
    }
    
    // Handle file upload if present
    $attachmentPath = null;
    $attachmentType = null;
    $attachmentSize = null;
    
    if (isset($_FILES['attachment']) && $_FILES['attachment']['error'] === UPLOAD_ERR_OK) {
        $file = $_FILES['attachment'];
        $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf'];
        $maxSize = 5 * 1024 * 1024; // 5MB
        
        if (!in_array($file['type'], $allowedTypes)) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid file type. Only images and PDFs allowed.']);
            exit;
        }
        
        if ($file['size'] > $maxSize) {
            http_response_code(400);
            echo json_encode(['error' => 'File too large. Maximum 5MB.']);
            exit;
        }
        
        // Create upload directory
        $uploadDir = __DIR__ . '/../../uploads/messages/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }
        
        // Generate unique filename
        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = uniqid('msg_') . '_' . time() . '.' . $extension;
        $uploadPath = $uploadDir . $filename;
        
        if (move_uploaded_file($file['tmp_name'], $uploadPath)) {
            $attachmentPath = '/uploads/messages/' . $filename;
            $attachmentType = $file['type'];
            $attachmentSize = $file['size'];
        }
    }
    
    // Insert message
    $insertStmt = $db->prepare("
        INSERT INTO product_inquiry_messages 
        (thread_id, sender_id, receiver_id, sender_role, message_text, attachment_path, attachment_type, attachment_size, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
    ");
    $insertStmt->execute([
        $threadId, 
        $userId, 
        $receiverId, 
        $senderRole, 
        $message,
        $attachmentPath,
        $attachmentType,
        $attachmentSize
    ]);
    $messageId = $db->lastInsertId();
    
    // Update thread last_message_at
    $updateThreadStmt = $db->prepare("
        UPDATE conversation_threads 
        SET last_message_at = NOW() 
        WHERE id = ?
    ");
    $updateThreadStmt->execute([$threadId]);
    
    // TODO: Send email notification to receiver
    
    echo json_encode([
        'success' => true,
        'message_id' => $messageId,
        'thread_id' => $threadId,
        'created_at' => date('Y-m-d H:i:s')
    ]);
    
} catch (Exception $e) {
    error_log("Send message error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Failed to send message']);
}
