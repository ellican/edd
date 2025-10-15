<?php
declare(strict_types=1);

/**
 * Create Setup Intent API
 * Create a Stripe Setup Intent for adding payment methods
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
    
    // Initialize Stripe
    $stripe = initStripe();
    
    // Get user's Stripe customer ID or create one
    $db = db();
    $stmt = $db->prepare("SELECT stripe_customer_id, email FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    
    if (!$user) {
        throw new Exception('User not found');
    }
    
    $customerId = $user['stripe_customer_id'];
    
    // Create Stripe customer if doesn't exist
    if (empty($customerId)) {
        $customer = \Stripe\Customer::create([
            'email' => $user['email'],
            'metadata' => [
                'user_id' => $userId
            ]
        ]);
        
        $customerId = $customer->id;
        
        // Save customer ID
        $stmt = $db->prepare("UPDATE users SET stripe_customer_id = ? WHERE id = ?");
        $stmt->execute([$customerId, $userId]);
        
        error_log("[SETUP_INTENT] Created Stripe customer {$customerId} for user {$userId}");
    }
    
    // Create Setup Intent
    $setupIntent = \Stripe\SetupIntent::create([
        'customer' => $customerId,
        'payment_method_types' => ['card'],
        'usage' => 'off_session',
        'metadata' => [
            'user_id' => $userId
        ]
    ]);
    
    error_log("[SETUP_INTENT] Created setup intent {$setupIntent->id} for user {$userId}");
    
    echo json_encode([
        'success' => true,
        'client_secret' => $setupIntent->client_secret,
        'setup_intent_id' => $setupIntent->id
    ]);
    
} catch (Exception $e) {
    error_log("[SETUP_INTENT] Error: " . $e->getMessage());
    http_response_code(400);
    echo json_encode([
        'error' => $e->getMessage()
    ]);
}
