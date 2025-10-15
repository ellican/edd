<?php
/**
 * Get User Support Tickets API
 * Returns all support tickets for the logged-in user
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

// Require login
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Unauthorized']);
    exit;
}

// Only accept GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

try {
    $db = db();
    $userId = Session::getUserId();
    
    // Get support tickets for the user
    $stmt = $db->prepare("
        SELECT * FROM support_tickets 
        WHERE user_id = ? 
        ORDER BY created_at DESC
        LIMIT 50
    ");
    $stmt->execute([$userId]);
    $tickets = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => $tickets
    ]);
    
} catch (Exception $e) {
    error_log("Get support tickets error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to retrieve support tickets'
    ]);
}
