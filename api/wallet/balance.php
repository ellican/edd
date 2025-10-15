<?php
/**
 * Wallet Balance API
 * Get user wallet balance and transactions
 */

require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../../includes/wallet_service.php';

header('Content-Type: application/json');

if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['error' => 'Authentication required']);
    exit;
}

try {
    $userId = Session::getUserId();
    $walletService = new WalletService();
    
    $wallet = $walletService->getWallet($userId);
    $transactions = $walletService->getTransactions($userId, 20);
    
    echo json_encode([
        'success' => true,
        'balance' => $wallet['balance'],
        'currency' => $wallet['currency'],
        'status' => $wallet['status'] ?? 'active',
        'transactions' => $transactions
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
