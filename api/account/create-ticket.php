<?php
/**
 * API: Create Support Ticket
 * Creates a new support ticket for the user
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

// Require authentication
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Authentication required']);
    exit;
}

try {
    $userId = Session::getUserId();
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Verify CSRF token
    if (!verifyCsrfToken($input['csrf_token'] ?? '')) {
        http_response_code(403);
        echo json_encode(['success' => false, 'error' => 'Invalid CSRF token']);
        exit;
    }
    
    // Validate required fields
    $subject = trim($input['subject'] ?? '');
    $message = trim($input['message'] ?? '');
    $category = $input['category'] ?? 'other';
    $priority = $input['priority'] ?? 'medium';
    
    if (empty($subject)) {
        throw new Exception('Subject is required');
    }
    
    if (empty($message)) {
        throw new Exception('Message is required');
    }
    
    // Validate category
    $validCategories = ['technical', 'billing', 'product', 'shipping', 'account', 'other'];
    if (!in_array($category, $validCategories)) {
        $category = 'other';
    }
    
    // Validate priority
    $validPriorities = ['low', 'medium', 'high', 'urgent'];
    if (!in_array($priority, $validPriorities)) {
        $priority = 'medium';
    }
    
    $db = db();
    
    // Generate unique ticket number
    $ticketNumber = 'TKT-' . strtoupper(substr(uniqid(), -8));
    
    // Check if ticket number already exists (very unlikely, but good practice)
    $stmt = $db->prepare("SELECT id FROM support_tickets WHERE ticket_number = ?");
    $stmt->execute([$ticketNumber]);
    if ($stmt->fetch()) {
        // If it exists, add timestamp to make it unique
        $ticketNumber = 'TKT-' . strtoupper(substr(uniqid(), -8)) . time();
    }
    
    // Begin transaction
    $db->beginTransaction();
    
    try {
        // Create the support ticket
        $stmt = $db->prepare("
            INSERT INTO support_tickets 
            (user_id, ticket_number, subject, category, priority, status, created_at) 
            VALUES (?, ?, ?, ?, ?, 'open', NOW())
        ");
        $stmt->execute([$userId, $ticketNumber, $subject, $category, $priority]);
        
        $ticketId = $db->lastInsertId();
        
        // Add the initial message
        $stmt = $db->prepare("
            INSERT INTO support_ticket_messages 
            (ticket_id, user_id, message, is_staff, created_at) 
            VALUES (?, ?, ?, 0, NOW())
        ");
        $stmt->execute([$ticketId, $userId, $message]);
        
        // Commit transaction
        $db->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Support ticket created successfully',
            'data' => [
                'ticket_id' => $ticketId,
                'ticket_number' => $ticketNumber,
                'subject' => $subject,
                'category' => $category,
                'priority' => $priority,
                'status' => 'open'
            ]
        ]);
        
    } catch (Exception $e) {
        $db->rollBack();
        throw $e;
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
