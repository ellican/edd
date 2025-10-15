<?php
/**
 * Live Chat API
 * Handles live chat messages and sessions
 */

require_once __DIR__ . '/../includes/init.php';

header('Content-Type: application/json');

// Get request method
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

try {
    $db = db();
    
    switch ($action) {
        case 'start':
            // Start a new chat session
            $userId = Session::isLoggedIn() ? Session::getUserId() : null;
            $name = sanitizeInput($_POST['name'] ?? '');
            $email = sanitizeInput($_POST['email'] ?? '');
            
            if (!$userId && (empty($name) || empty($email))) {
                errorResponse('Name and email required for guests', 400);
            }
            
            // Create chat session
            $stmt = $db->prepare("
                INSERT INTO chats (user_id, name, email, type, status, created_at)
                VALUES (?, ?, ?, 'support', 'active', NOW())
            ");
            $stmt->execute([$userId, $name, $email]);
            $chatId = $db->lastInsertId();
            
            // Send welcome message
            $stmt = $db->prepare("
                INSERT INTO chat_messages (chat_id, sender, message, created_at)
                VALUES (?, 'system', ?, NOW())
            ");
            $welcomeMsg = "Welcome to FezaMarket Support! How can we help you today?";
            $stmt->execute([$chatId, $welcomeMsg]);
            
            successResponse([
                'chat_id' => $chatId,
                'message' => 'Chat session started'
            ]);
            break;
            
        case 'send':
            // Send a message
            $chatId = (int)($_POST['chat_id'] ?? 0);
            $message = sanitizeInput($_POST['message'] ?? '');
            
            if (!$chatId || empty($message)) {
                errorResponse('Chat ID and message required', 400);
            }
            
            // Verify chat exists
            $stmt = $db->prepare("SELECT id FROM chats WHERE id = ?");
            $stmt->execute([$chatId]);
            if (!$stmt->fetch()) {
                errorResponse('Chat not found', 404);
            }
            
            // Insert message
            $stmt = $db->prepare("
                INSERT INTO chat_messages (chat_id, sender, sender_id, message, created_at)
                VALUES (?, 'user', ?, ?, NOW())
            ");
            $userId = Session::isLoggedIn() ? Session::getUserId() : null;
            $stmt->execute([$chatId, $userId, $message]);
            
            // Update chat timestamp
            $stmt = $db->prepare("UPDATE chats SET updated_at = NOW() WHERE id = ?");
            $stmt->execute([$chatId]);
            
            successResponse([
                'message_id' => $db->lastInsertId(),
                'message' => 'Message sent'
            ]);
            break;
            
        case 'messages':
            // Get messages for a chat
            $chatId = (int)($_GET['chat_id'] ?? 0);
            $since = (int)($_GET['since'] ?? 0);
            
            if (!$chatId) {
                errorResponse('Chat ID required', 400);
            }
            
            // Get messages
            $query = "
                SELECT id, sender, message, created_at, is_read
                FROM chat_messages
                WHERE chat_id = ?
            ";
            
            if ($since > 0) {
                $query .= " AND id > ?";
                $stmt = $db->prepare($query . " ORDER BY created_at ASC");
                $stmt->execute([$chatId, $since]);
            } else {
                $stmt = $db->prepare($query . " ORDER BY created_at ASC");
                $stmt->execute([$chatId]);
            }
            
            $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            successResponse([
                'messages' => $messages,
                'count' => count($messages)
            ]);
            break;
            
        case 'close':
            // Close a chat session
            $chatId = (int)($_POST['chat_id'] ?? 0);
            
            if (!$chatId) {
                errorResponse('Chat ID required', 400);
            }
            
            $stmt = $db->prepare("
                UPDATE chats 
                SET status = 'closed', closed_at = NOW()
                WHERE id = ?
            ");
            $stmt->execute([$chatId]);
            
            successResponse(['message' => 'Chat closed']);
            break;
            
        case 'status':
            // Check if support is available
            $stmt = $db->query("
                SELECT COUNT(*) as online_agents
                FROM agent_presence
                WHERE status IN ('online', 'away')
                AND last_seen > DATE_SUB(NOW(), INTERVAL 5 MINUTE)
            ");
            $result = $stmt->fetch(PDO::FETCH_ASSOC);
            
            successResponse([
                'available' => $result['online_agents'] > 0,
                'online_agents' => (int)$result['online_agents']
            ]);
            break;
            
        default:
            errorResponse('Invalid action', 400);
    }
    
} catch (Exception $e) {
    Logger::error('Live chat API error: ' . $e->getMessage());
    errorResponse('An error occurred', 500);
}
