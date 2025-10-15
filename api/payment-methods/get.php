<?php
/**
 * API: Get Payment Methods
 * Returns all saved payment methods for the user
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
    
    // Get all payment methods for the user
    $stmt = $db->prepare("
        SELECT 
            id,
            stripe_payment_method_id,
            brand,
            last4,
            exp_month,
            exp_year,
            is_default,
            created_at
        FROM user_payment_methods 
        WHERE user_id = ? 
        ORDER BY is_default DESC, created_at DESC
    ");
    $stmt->execute([$userId]);
    $paymentMethods = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'data' => $paymentMethods
    ]);
    
} catch (Exception $e) {
    error_log("Get payment methods error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to retrieve payment methods'
    ]);
}
