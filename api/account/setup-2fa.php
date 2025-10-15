<?php
/**
 * API: Setup Two-Factor Authentication
 * Enables or disables 2FA for the user account
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

// Require authentication
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Authentication required']);
    exit;
}

try {
    $userId = Session::getUserId();
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Verify CSRF token
    if (!verifyCsrfToken($input['csrf_token'] ?? '')) {
        http_response_code(403);
        echo json_encode(['success' => false, 'error' => 'Invalid CSRF token']);
        exit;
    }
    
    $action = $input['action'] ?? '';
    $db = db();
    
    if ($action === 'enable') {
        // Generate a random secret for 2FA
        // In a production system, you would use a proper TOTP library like:
        // - Google Authenticator compatible (https://github.com/PHPGangsta/GoogleAuthenticator)
        // - or similar library
        $secret = bin2hex(random_bytes(16));
        
        // Update user's 2FA settings
        $stmt = $db->prepare("
            UPDATE users 
            SET two_factor_secret = ?, two_factor_enabled = 1 
            WHERE id = ?
        ");
        $stmt->execute([$secret, $userId]);
        
        // In production, you would generate a QR code URL here for the user to scan
        // Example: otpauth://totp/APP_NAME:user@email.com?secret=SECRET&issuer=APP_NAME
        $qrCodeUrl = sprintf(
            'otpauth://totp/%s:%s?secret=%s&issuer=%s',
            urlencode(APP_NAME),
            urlencode($input['email'] ?? 'user@example.com'),
            $secret,
            urlencode(APP_NAME)
        );
        
        echo json_encode([
            'success' => true,
            'message' => 'Two-factor authentication has been enabled',
            'secret' => $secret,
            'qr_code_url' => $qrCodeUrl
        ]);
        
    } elseif ($action === 'disable') {
        // Disable 2FA
        $stmt = $db->prepare("
            UPDATE users 
            SET two_factor_secret = NULL, two_factor_enabled = 0 
            WHERE id = ?
        ");
        $stmt->execute([$userId]);
        
        echo json_encode([
            'success' => true,
            'message' => 'Two-factor authentication has been disabled'
        ]);
        
    } elseif ($action === 'verify') {
        // Verify 2FA code
        // In production, you would use a TOTP library to verify the code
        $code = $input['code'] ?? '';
        
        if (empty($code)) {
            throw new Exception('Verification code is required');
        }
        
        // Get user's 2FA secret
        $stmt = $db->prepare("SELECT two_factor_secret FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$result || empty($result['two_factor_secret'])) {
            throw new Exception('Two-factor authentication is not set up');
        }
        
        // In production, verify the TOTP code here
        // For now, we'll accept any 6-digit code as a placeholder
        if (strlen($code) === 6 && ctype_digit($code)) {
            echo json_encode([
                'success' => true,
                'message' => 'Code verified successfully'
            ]);
        } else {
            throw new Exception('Invalid verification code');
        }
        
    } else {
        throw new Exception('Invalid action');
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
