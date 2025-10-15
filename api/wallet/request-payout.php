<?php
declare(strict_types=1);

/**
 * Wallet Payout Request API
 * Request a payout from wallet to external account
 */

require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../../includes/wallet_service.php';

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
    
    $amount = floatval($data['amount'] ?? 0);
    $payoutMethod = $data['payout_method'] ?? 'bank';
    $payoutDetails = $data['payout_details'] ?? [];
    
    // Validate amount
    if ($amount < 20) {
        throw new Exception('Minimum payout amount is $20.00');
    }
    
    // Check wallet balance
    $walletService = new WalletService();
    $wallet = $walletService->getWallet($userId);
    
    if ($wallet['balance'] < $amount) {
        throw new Exception('Insufficient wallet balance');
    }
    
    // Validate payout method
    $validMethods = ['bank', 'paypal', 'stripe'];
    if (!in_array($payoutMethod, $validMethods)) {
        throw new Exception('Invalid payout method');
    }
    
    // Validate payout details based on method
    if ($payoutMethod === 'bank') {
        if (empty($payoutDetails['account_number']) || empty($payoutDetails['routing_number'])) {
            throw new Exception('Bank account details are required');
        }
    } elseif ($payoutMethod === 'paypal') {
        if (empty($payoutDetails['email'])) {
            throw new Exception('PayPal email is required');
        }
    }
    
    // Reserve funds in wallet (debit)
    $reference = 'payout_request_' . time() . '_' . $userId;
    $walletService->debit(
        $userId,
        $amount,
        $reference,
        "Payout request - {$payoutMethod}",
        [
            'type' => 'payout_request',
            'payout_method' => $payoutMethod,
            'status' => 'pending'
        ]
    );
    
    // Create payout request
    $db = db();
    $stmt = $db->prepare("
        INSERT INTO payout_requests 
        (user_id, amount, currency, status, payout_method, payout_details, created_at)
        VALUES (?, ?, 'USD', 'pending', ?, ?, NOW())
    ");
    
    $stmt->execute([
        $userId,
        $amount,
        $payoutMethod,
        json_encode($payoutDetails)
    ]);
    
    $payoutRequestId = $db->lastInsertId();
    
    // Log the request
    error_log("[PAYOUT] Request created: ID={$payoutRequestId}, User={$userId}, Amount=\${$amount}, Method={$payoutMethod}");
    
    // Get updated balance
    $wallet = $walletService->getWallet($userId);
    
    echo json_encode([
        'success' => true,
        'message' => 'Payout request submitted successfully. It will be reviewed by our team.',
        'payout_request_id' => $payoutRequestId,
        'balance' => $wallet['balance']
    ]);
    
} catch (Exception $e) {
    error_log("[PAYOUT] Request failed: " . $e->getMessage());
    http_response_code(400);
    echo json_encode([
        'error' => $e->getMessage()
    ]);
}
