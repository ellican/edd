<?php
/**
 * Add Address API
 * Handle adding new addresses
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

// Require login
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Unauthorized']);
    exit;
}

// Only accept POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

try {
    // Get JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Verify CSRF token
    if (!verifyCsrfToken($input['csrf_token'] ?? '')) {
        throw new Exception('Invalid CSRF token');
    }
    
    $db = db();
    $userId = Session::getUserId();
    
    // Validate and sanitize inputs
    $type = $input['type'] ?? $input['address_type'] ?? 'both';
    $fullName = trim($input['full_name'] ?? '');
    $firstName = trim($input['first_name'] ?? '');
    $lastName = trim($input['last_name'] ?? '');
    $company = trim($input['company'] ?? '');
    $phone = trim($input['phone'] ?? '');
    $addressLine1 = trim($input['address_line1'] ?? '');
    $addressLine2 = trim($input['address_line2'] ?? '');
    $city = trim($input['city'] ?? '');
    $state = trim($input['state'] ?? '');
    $postalCode = trim($input['postal_code'] ?? '');
    $country = trim($input['country'] ?? 'US');
    $isDefault = isset($input['is_default']) && $input['is_default'] ? 1 : 0;
    
    // Split full_name if provided but first/last not
    if (!empty($fullName) && empty($firstName) && empty($lastName)) {
        $nameParts = explode(' ', $fullName, 2);
        $firstName = $nameParts[0];
        $lastName = $nameParts[1] ?? '';
    }
    
    // Validation
    if (empty($addressLine1) || empty($city) || empty($state) || empty($postalCode)) {
        throw new Exception('Address line 1, city, state, and postal code are required');
    }
    
    if (!in_array($type, ['billing', 'shipping', 'both'])) {
        throw new Exception('Invalid address type');
    }
    
    // Begin transaction
    $db->beginTransaction();
    
    try {
        // If setting as default, remove default from other addresses
        if ($isDefault) {
            $removeDefaultStmt = $db->prepare("UPDATE addresses SET is_default = 0 WHERE user_id = ?");
            $removeDefaultStmt->execute([$userId]);
        }
        
        // Insert new address into addresses table (aligned with UI)
        $insertStmt = $db->prepare("
            INSERT INTO addresses (
                user_id, type, first_name, last_name, company, phone, 
                address_line1, address_line2, city, state, postal_code, country, 
                is_default, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
        ");
        
        $insertStmt->execute([
            $userId, $type, $firstName, $lastName, $company, $phone,
            $addressLine1, $addressLine2, $city, $state, $postalCode, $country, $isDefault
        ]);
        
        $addressId = $db->lastInsertId();
        
        $db->commit();
        
        // Log the action
        logSecurityEvent($userId, 'address_added', 'address', $addressId);
        
        echo json_encode([
            'success' => true,
            'message' => 'Address added successfully',
            'data' => [
                'id' => $addressId,
                'type' => $type,
                'first_name' => $firstName,
                'last_name' => $lastName,
                'is_default' => $isDefault
            ]
        ]);
        
    } catch (Exception $e) {
        $db->rollBack();
        throw $e;
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
