<?php
/**
 * Admin API: Adjust User Wallet Balance
 * Manually adjust user wallet with full audit trail
 */

require_once __DIR__ . '/../../../includes/init.php';
require_once __DIR__ . '/../../../includes/rbac.php';
require_once __DIR__ . '/../../../includes/wallet_service.php';

header('Content-Type: application/json');

// Require admin authentication
if (!Session::isLoggedIn() || !isAdmin()) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => 'Access denied']);
    exit;
}

checkPermission('wallet.admin');

// Only POST allowed
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

$postData = json_decode(file_get_contents('php://input'), true);

// Verify CSRF token
if (!verifyCsrfToken($postData['csrf_token'] ?? '')) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => 'Invalid CSRF token']);
    exit;
}

$userId = (int)($postData['user_id'] ?? 0);
$amount = (float)($postData['amount'] ?? 0);
$reason = sanitizeInput($postData['reason'] ?? '');

// Validation
if ($userId <= 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid user ID']);
    exit;
}

if ($amount == 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Amount must be non-zero']);
    exit;
}

if (empty($reason)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Reason is required']);
    exit;
}

try {
    $walletService = new WalletService();
    $adminId = Session::getUserId();
    
    // Adjust wallet balance
    if ($amount > 0) {
        $result = $walletService->credit($userId, $amount, $reason, [
            'admin_id' => $adminId,
            'admin_adjustment' => true
        ]);
    } else {
        $result = $walletService->debit($userId, abs($amount), $reason, [
            'admin_id' => $adminId,
            'admin_adjustment' => true
        ]);
    }
    
    // Log admin activity
    $db = Database::getInstance()->getConnection();
    $stmt = $db->prepare("
        INSERT INTO admin_activity_logs 
        (admin_id, action_type, target_type, target_id, description, old_value, new_value, ip_address, user_agent, created_at)
        VALUES (?, 'wallet_adjustment', 'user', ?, ?, NULL, ?, ?, ?, NOW())
    ");
    
    $stmt->execute([
        $adminId,
        $userId,
        $reason,
        json_encode(['amount' => $amount, 'new_balance' => $result['balance']]),
        $_SERVER['REMOTE_ADDR'] ?? 'unknown',
        $_SERVER['HTTP_USER_AGENT'] ?? 'unknown'
    ]);
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Wallet balance adjusted successfully',
        'new_balance' => $result['balance']
    ]);
    
} catch (Exception $e) {
    error_log("Admin Wallet Adjustment Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to adjust wallet balance: ' . $e->getMessage()
    ]);
}
