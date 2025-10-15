<?php
declare(strict_types=1);

/**
 * Validate Gift Card API Endpoint
 * Validates a gift card code and returns available amount
 */

require_once __DIR__ . '/../includes/init.php';

header('Content-Type: application/json');

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

// Require authenticated user
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Authentication required']);
    exit;
}

// CSRF validation
$csrfToken = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
if (!verifyCsrfToken($csrfToken)) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => 'Invalid CSRF token']);
    exit;
}

try {
    $requestBody = file_get_contents('php://input');
    $requestData = json_decode($requestBody, true) ?? [];
    
    $giftCardCode = strtoupper(trim($requestData['code'] ?? ''));
    $orderTotal = (float)($requestData['total'] ?? 0);
    
    if (empty($giftCardCode)) {
        throw new Exception('Gift card code is required');
    }
    
    if ($orderTotal <= 0) {
        throw new Exception('Invalid order amount');
    }
    
    $db = db();
    
    // Check if gift_cards table exists
    $tableCheck = $db->query("SHOW TABLES LIKE 'gift_cards'");
    if ($tableCheck->rowCount() === 0) {
        throw new Exception('Gift card system not available');
    }
    
    // Find valid gift card (using 'gift_cards' table name)
    $stmt = $db->prepare("
        SELECT * FROM gift_cards 
        WHERE code = ? 
        AND status = 'active'
        AND (expires_at IS NULL OR expires_at >= NOW())
    ");
    $stmt->execute([$giftCardCode]);
    $giftCard = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$giftCard) {
        throw new Exception('Invalid or expired gift card code');
    }
    
    // Check if already fully redeemed (using 'balance' column)
    $remainingAmount = (float)$giftCard['balance'];
    if ($remainingAmount <= 0) {
        throw new Exception('This gift card has been fully redeemed');
    }
    
    // Calculate gift card amount to apply (cannot exceed order total or remaining balance)
    $giftCardAmount = min($remainingAmount, $orderTotal);
    
    echo json_encode([
        'success' => true,
        'gift_card_id' => $giftCard['id'],
        'gift_card_code' => $giftCard['code'],
        'gift_card_amount' => round($giftCardAmount, 2),
        'remaining_balance' => round($remainingAmount, 2)
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
