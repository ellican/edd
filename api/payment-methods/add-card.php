<?php
declare(strict_types=1);

/**
 * Add Payment Method API
 * Save a Stripe payment method to user's account
 */

// CRITICAL: Load environment variables FIRST
if (file_exists(__DIR__ . '/../../vendor/autoload.php')) {
    require_once __DIR__ . '/../../vendor/autoload.php';
}
require_once __DIR__ . '/../../bootstrap/simple_env_loader.php';

// Load application initialization
require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../../includes/stripe/init_stripe.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['error' => 'Authentication required']);
    exit;
}

try {
    $userId = Session::getUserId();
    $data = json_decode(file_get_contents('php://input'), true);
    
    $paymentMethodId = $data['payment_method_id'] ?? '';
    $isDefault = isset($data['is_default']) && $data['is_default'] === true;
    
    if (empty($paymentMethodId)) {
        throw new Exception('Payment method ID is required');
    }
    
    // Initialize Stripe
    $stripe = initStripe();
    
    // Get user's Stripe customer ID
    $db = db();
    $stmt = $db->prepare("SELECT stripe_customer_id FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $customerId = $result['stripe_customer_id'] ?? null;
    
    // Create Stripe customer if doesn't exist
    if (empty($customerId)) {
        $user = new User();
        $userData = $user->find($userId);
        
        $customer = $stripe->customers->create([
            'email' => $userData['email'] ?? '',
            'name' => $userData['username'] ?? $userData['first_name'] ?? '',
            'metadata' => [
                'user_id' => (string)$userId
            ]
        ]);
        
        $customerId = $customer->id;
        
        // Save customer ID
        $stmt = $db->prepare("UPDATE users SET stripe_customer_id = ? WHERE id = ?");
        $stmt->execute([$customerId, $userId]);
    }
    
    // Attach payment method to customer
    $stripe->paymentMethods->attach($paymentMethodId, [
        'customer' => $customerId
    ]);
    
    // Retrieve payment method details
    $paymentMethod = $stripe->paymentMethods->retrieve($paymentMethodId);
    
    // Check if this should be default
    if ($isDefault) {
        // Set as default payment method
        $stripe->customers->update($customerId, [
            'invoice_settings' => [
                'default_payment_method' => $paymentMethodId
            ]
        ]);
        
        // Unset other defaults
        $stmt = $db->prepare("UPDATE user_payment_methods SET is_default = 0 WHERE user_id = ?");
        $stmt->execute([$userId]);
    }
    
    // Check if payment method already exists
    $stmt = $db->prepare("SELECT id FROM user_payment_methods WHERE user_id = ? AND stripe_payment_method_id = ?");
    $stmt->execute([$userId, $paymentMethodId]);
    
    if ($stmt->fetch()) {
        throw new Exception('Payment method already exists');
    }
    
    // Save to database
    $stmt = $db->prepare("
        INSERT INTO user_payment_methods 
        (user_id, stripe_payment_method_id, brand, last4, exp_month, exp_year, is_default, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
    ");
    
    $stmt->execute([
        $userId,
        $paymentMethodId,
        $paymentMethod->card->brand,
        $paymentMethod->card->last4,
        $paymentMethod->card->exp_month,
        $paymentMethod->card->exp_year,
        $isDefault ? 1 : 0
    ]);
    
    error_log("[PAYMENT_METHOD] Added card for user {$userId}: {$paymentMethod->card->brand} ****{$paymentMethod->card->last4}");
    
    echo json_encode([
        'success' => true,
        'message' => 'Payment method added successfully',
        'payment_method' => [
            'id' => $db->lastInsertId(),
            'brand' => $paymentMethod->card->brand,
            'last4' => $paymentMethod->card->last4,
            'exp_month' => $paymentMethod->card->exp_month,
            'exp_year' => $paymentMethod->card->exp_year,
            'is_default' => $isDefault
        ]
    ]);
    
} catch (Exception $e) {
    error_log("[PAYMENT_METHOD] Add failed: " . $e->getMessage());
    http_response_code(400);
    echo json_encode([
        'error' => $e->getMessage()
    ]);
}
