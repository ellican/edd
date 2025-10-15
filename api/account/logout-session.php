<?php
/**
 * Logout Session API
 * Terminate a specific session remotely
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

// Check if user is logged in
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Authentication required']);
    exit;
}

// Only POST allowed
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

// Verify CSRF token
if (!verifyCsrfToken($_POST['csrf_token'] ?? '')) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => 'Invalid CSRF token']);
    exit;
}

$userId = Session::getUserId();
$sessionId = (int)($_POST['session_id'] ?? 0);

if (empty($sessionId)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Session ID is required']);
    exit;
}

try {
    $db = Database::getInstance()->getConnection();
    
    // Verify session belongs to user
    $stmt = $db->prepare("SELECT id, session_token FROM user_sessions WHERE id = ? AND user_id = ?");
    $stmt->execute([$sessionId, $userId]);
    $session = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$session) {
        http_response_code(404);
        echo json_encode(['success' => false, 'error' => 'Session not found']);
        exit;
    }
    
    // Deactivate session
    $stmt = $db->prepare("UPDATE user_sessions SET is_active = 0, updated_at = NOW() WHERE id = ?");
    $stmt->execute([$sessionId]);
    
    // Log security event
    $stmt = $db->prepare("
        INSERT INTO security_logs (user_id, event_type, severity, ip_address, user_agent, details, created_at)
        VALUES (?, 'session_terminated', 'info', ?, ?, ?, NOW())
    ");
    $stmt->execute([
        $userId,
        $_SERVER['REMOTE_ADDR'] ?? 'unknown',
        $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
        "Session #{$sessionId} was manually terminated"
    ]);
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Session terminated successfully'
    ]);
    
} catch (Exception $e) {
    error_log("Logout Session Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to terminate session'
    ]);
}
