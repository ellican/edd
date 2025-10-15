<?php
/**
 * API Endpoint: Toggle Product Sponsored Status
 * Admin-only endpoint for toggling product sponsored status
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

try {
    // Verify admin access
    Session::requireLogin();
    RoleMiddleware::requireAdmin();
    
    // Validate CSRF token
    $headers = getallheaders();
    $csrfToken = $headers['X-Csrf-Token'] ?? $_POST['csrf_token'] ?? '';
    if (!verifyCsrfToken($csrfToken)) {
        throw new Exception('Invalid CSRF token');
    }
    
    // Get product ID
    $productId = (int)($_POST['product_id'] ?? 0);
    if ($productId <= 0) {
        throw new Exception('Invalid product ID');
    }
    
    $db = db();
    
    // Check if product exists
    $stmt = $db->prepare("SELECT id FROM products WHERE id = ?");
    $stmt->execute([$productId]);
    $product = $stmt->fetch();
    
    if (!$product) {
        throw new Exception('Product not found');
    }
    
    // Check if sponsored_products table exists
    $tableCheckStmt = $db->query("SHOW TABLES LIKE 'sponsored_products'");
    $sponsoredTableExists = $tableCheckStmt->rowCount() > 0;
    
    if (!$sponsoredTableExists) {
        throw new Exception('Sponsored products feature is not configured. Please run database migrations.');
    }
    
    // Check if product is currently sponsored
    $checkStmt = $db->prepare("
        SELECT id, status 
        FROM sponsored_products 
        WHERE product_id = ? 
        AND status = 'active' 
        AND sponsored_until > NOW()
        LIMIT 1
    ");
    $checkStmt->execute([$productId]);
    $existingSponsorship = $checkStmt->fetch();
    
    if ($existingSponsorship) {
        // Deactivate sponsorship
        $updateStmt = $db->prepare("
            UPDATE sponsored_products 
            SET status = 'cancelled', updated_at = NOW() 
            WHERE id = ?
        ");
        $updateStmt->execute([$existingSponsorship['id']]);
        
        $isSponsored = false;
        $message = 'Product sponsorship removed';
    } else {
        // Create new sponsorship (7 days)
        $vendorId = Session::getUserId(); // Using admin user as vendor for now
        $sellerId = Session::getUserId();
        $sponsoredFrom = date('Y-m-d H:i:s');
        $sponsoredUntil = date('Y-m-d H:i:s', strtotime('+7 days'));
        
        $insertStmt = $db->prepare("
            INSERT INTO sponsored_products 
            (product_id, vendor_id, seller_id, cost, currency, payment_status, status, sponsored_from, sponsored_until, approved_by, approved_at)
            VALUES (?, ?, ?, 0.00, 'USD', 'paid', 'active', ?, ?, ?, NOW())
        ");
        $insertStmt->execute([
            $productId,
            $vendorId,
            $sellerId,
            $sponsoredFrom,
            $sponsoredUntil,
            Session::getUserId()
        ]);
        
        $isSponsored = true;
        $message = 'Product is now sponsored for 7 days';
    }
    
    echo json_encode([
        'success' => true,
        'is_sponsored' => $isSponsored,
        'message' => $message
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
