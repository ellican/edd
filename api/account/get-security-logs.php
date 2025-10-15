<?php
/**
 * Get Security Logs API
 * Fetch recent security events for the user
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

// Check if user is logged in
if (!Session::isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Authentication required']);
    exit;
}

$userId = Session::getUserId();
$limit = min(100, max(1, (int)($_GET['limit'] ?? 20)));

try {
    $db = Database::getInstance()->getConnection();
    
    // Get security logs
    $stmt = $db->prepare("
        SELECT event_type, severity, ip_address, user_agent, details, created_at
        FROM security_logs
        WHERE user_id = ?
        ORDER BY created_at DESC
        LIMIT ?
    ");
    $stmt->execute([$userId, $limit]);
    $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format logs
    foreach ($logs as &$log) {
        $log['formatted_date'] = date('M j, Y g:i A', strtotime($log['created_at']));
        $log['event_label'] = formatEventType($log['event_type']);
        $log['icon'] = getEventIcon($log['event_type']);
    }
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'logs' => $logs
    ]);
    
} catch (Exception $e) {
    error_log("Get Security Logs Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to fetch security logs'
    ]);
}

function formatEventType($eventType) {
    $labels = [
        'login_success' => 'Successful Login',
        'login_failed' => 'Failed Login Attempt',
        'logout' => 'Logged Out',
        'password_changed' => 'Password Changed',
        'password_reset_requested' => 'Password Reset Requested',
        'password_reset_completed' => 'Password Reset Completed',
        'session_terminated' => 'Session Terminated',
        '2fa_enabled' => 'Two-Factor Authentication Enabled',
        '2fa_disabled' => 'Two-Factor Authentication Disabled',
        'email_changed' => 'Email Address Changed',
        'profile_updated' => 'Profile Updated',
        'suspicious_activity' => 'Suspicious Activity Detected'
    ];
    
    return $labels[$eventType] ?? ucwords(str_replace('_', ' ', $eventType));
}

function getEventIcon($eventType) {
    $icons = [
        'login_success' => '✅',
        'login_failed' => '❌',
        'logout' => '👋',
        'password_changed' => '🔑',
        'password_reset_requested' => '📧',
        'password_reset_completed' => '✅',
        'session_terminated' => '🚪',
        '2fa_enabled' => '🔐',
        '2fa_disabled' => '🔓',
        'email_changed' => '📧',
        'profile_updated' => '✏️',
        'suspicious_activity' => '⚠️'
    ];
    
    return $icons[$eventType] ?? '📋';
}
