<?php
/**
 * API: Get Login History
 * Returns recent login history for the user
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

// Only accept GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
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
    $db = db();
    
    // Get login history for the user (last 50 entries)
    $stmt = $db->prepare("
        SELECT 
            id,
            ip_address,
            user_agent,
            login_time,
            location,
            device_type,
            browser,
            os,
            status
        FROM login_history 
        WHERE user_id = ? 
        ORDER BY login_time DESC
        LIMIT 50
    ");
    $stmt->execute([$userId]);
    $loginHistory = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => $loginHistory
    ]);
    
} catch (Exception $e) {
    error_log("Get login history error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to retrieve login history'
    ]);
}
