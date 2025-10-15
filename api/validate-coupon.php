<?php
declare(strict_types=1);

/**
 * Validate Coupon API Endpoint
 * Validates a coupon code and returns discount amount
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
    
    $couponCode = strtoupper(trim($requestData['code'] ?? ''));
    $subtotal = (float)($requestData['subtotal'] ?? 0);
    
    if (empty($couponCode)) {
        throw new Exception('Coupon code is required');
    }
    
    if ($subtotal <= 0) {
        throw new Exception('Invalid order amount');
    }
    
    $db = db();
    
    // Check if coupons table exists
    $tableCheck = $db->query("SHOW TABLES LIKE 'coupons'");
    if ($tableCheck->rowCount() === 0) {
        throw new Exception('Coupon system not available');
    }
    
    // Find valid coupon
    $stmt = $db->prepare("
        SELECT * FROM coupons 
        WHERE code = ? 
        AND status = 'active'
        AND (valid_from IS NULL OR valid_from <= NOW())
        AND (valid_to IS NULL OR valid_to >= NOW())
        AND (usage_limit IS NULL OR usage_count < usage_limit)
    ");
    $stmt->execute([$couponCode]);
    $coupon = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$coupon) {
        throw new Exception('Invalid or expired coupon code');
    }
    
    // Check minimum amount
    if (isset($coupon['minimum_amount']) && $coupon['minimum_amount'] > 0 && $subtotal < $coupon['minimum_amount']) {
        throw new Exception('Order amount does not meet minimum requirement of $' . number_format($coupon['minimum_amount'], 2));
    }
    
    // Calculate discount
    $discountAmount = 0;
    if ($coupon['type'] === 'percentage') {
        $discountAmount = ($subtotal * $coupon['value']) / 100;
    } else if ($coupon['type'] === 'fixed') {
        $discountAmount = $coupon['value'];
    }
    
    // Apply maximum discount cap if set
    if (isset($coupon['maximum_discount']) && $coupon['maximum_discount'] > 0 && $discountAmount > $coupon['maximum_discount']) {
        $discountAmount = $coupon['maximum_discount'];
    }
    
    // Discount cannot exceed subtotal
    if ($discountAmount > $subtotal) {
        $discountAmount = $subtotal;
    }
    
    echo json_encode([
        'success' => true,
        'coupon_id' => $coupon['id'],
        'coupon_code' => $coupon['code'],
        'discount_amount' => round($discountAmount, 2),
        'discount_type' => $coupon['type'],
        'discount_value' => $coupon['value']
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
