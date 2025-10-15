<?php
declare(strict_types=1);

/**
 * Wallet Add Funds API
 * Add funds to user wallet via Stripe Payment Intent
 * 
 * This endpoint:
 * 1. Validates user session and amount
 * 2. Creates a Stripe PaymentIntent for the wallet top-up
 * 3. Returns client_secret for frontend confirmation
 * 4. On payment success (via webhook), credits wallet balance
 */

// CRITICAL: Load environment variables FIRST
if (file_exists(__DIR__ . '/../../vendor/autoload.php')) {
    require_once __DIR__ . '/../../vendor/autoload.php';
}
require_once __DIR__ . '/../../bootstrap/simple_env_loader.php';

// Load application initialization
require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../../includes/stripe/init_stripe.php';
require_once __DIR__ . '/../../includes/wallet_service.php';

header('Content-Type: application/json');

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

// Require authenticated user
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['error' => 'Authentication required']);
    exit;
}

// Enforce LIVE mode for wallet operations
$stripeMode = getStripeMode();
if ($stripeMode !== 'live') {
    error_log("[WALLET][ERROR] Attempted wallet operation in {$stripeMode} mode. Wallet requires LIVE mode.");
    http_response_code(403);
    echo json_encode(['error' => 'Wallet operations require live payment processing. Please contact support.']);
    exit;
}

try {
    $userId = Session::getUserId();
    
    // Parse request body
    $requestBody = file_get_contents('php://input');
    $requestData = json_decode($requestBody, true) ?? [];
    
    $amount = floatval($requestData['amount'] ?? 0);
    $savePaymentMethod = isset($requestData['save_payment_method']) && $requestData['save_payment_method'] === true;
    
    // Validate amount
    if ($amount < 10) {
        throw new Exception('Minimum wallet top-up amount is $10.00');
    }
    
    if ($amount > 5000) {
        throw new Exception('Maximum wallet top-up amount is $5,000.00');
    }
    
    // Convert to minor units (cents)
    $amountMinor = (int)round($amount * 100);
    
    // Get user info
    $user = new User();
    $userData = $user->find($userId);
    $customerEmail = $userData['email'] ?? Session::get('user_email') ?? '';
    $customerName = $userData['username'] ?? $userData['first_name'] ?? 'Customer';
    
    // Find or create Stripe customer
    $db = db();
    $stmt = $db->prepare("SELECT stripe_customer_id FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $customerId = $result['stripe_customer_id'] ?? null;
    
    // Create customer if doesn't exist
    if (empty($customerId)) {
        $stripe = initStripe();
        $customer = $stripe->customers->create([
            'email' => $customerEmail,
            'name' => $customerName,
            'metadata' => [
                'user_id' => (string)$userId
            ]
        ]);
        
        $customerId = $customer->id;
        
        // Save customer ID to database
        $stmt = $db->prepare("UPDATE users SET stripe_customer_id = ? WHERE id = ?");
        $stmt->execute([$customerId, $userId]);
    }
    
    // Generate unique reference for this wallet top-up
    $reference = 'wallet_topup_' . time() . '_' . $userId;
    
    // Create PaymentIntent via Stripe API
    $stripe = initStripe();
    
    $piParams = [
        'amount' => $amountMinor,
        'currency' => 'usd',
        'customer' => $customerId,
        'description' => "Wallet Top-up - \${$amount}",
        'statement_descriptor' => 'WALLET TOP-UP',
        'metadata' => [
            'type' => 'wallet_topup',
            'user_id' => (string)$userId,
            'reference' => $reference,
            'amount_usd' => (string)$amount
        ],
        'automatic_payment_methods' => [
            'enabled' => true,
        ]
    ];
    
    // If saving payment method, set setup_future_usage
    if ($savePaymentMethod) {
        $piParams['setup_future_usage'] = 'off_session';
    }
    
    $paymentIntent = $stripe->paymentIntents->create($piParams);
    
    // Log the payment intent creation
    error_log("[WALLET] Created PaymentIntent {$paymentIntent->id} for user {$userId}, amount: \${$amount}");
    
    // Store pending wallet transaction (will be confirmed by webhook)
    $stmt = $db->prepare("
        INSERT INTO wallet_transactions 
        (user_id, type, amount, balance_after, reference, description, meta, created_at)
        VALUES (?, 'pending', ?, 0, ?, ?, ?, NOW())
    ");
    $stmt->execute([
        $userId,
        $amount,
        $reference,
        'Pending wallet top-up',
        json_encode([
            'payment_intent_id' => $paymentIntent->id,
            'status' => 'pending'
        ])
    ]);
    
    // Return success response
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'clientSecret' => $paymentIntent->client_secret,
        'paymentIntentId' => $paymentIntent->id,
        'amount' => $amount,
        'reference' => $reference
    ]);
    
} catch (Exception $e) {
    error_log("[WALLET] Add funds failed: " . $e->getMessage());
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
