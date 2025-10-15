<?php
/**
 * Get User Sessions API
 * List all active sessions for the user
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

try {
    $db = Database::getInstance()->getConnection();
    
    // Get active sessions
    $stmt = $db->prepare("
        SELECT id, session_token, ip_address, user_agent, created_at, expires_at, is_active,
               CASE 
                   WHEN session_token = ? THEN 1
                   ELSE 0
               END as is_current
        FROM user_sessions
        WHERE user_id = ? AND is_active = 1 AND expires_at > NOW()
        ORDER BY created_at DESC
    ");
    $stmt->execute([session_id(), $userId]);
    $sessions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Parse user agent and add device info
    foreach ($sessions as &$session) {
        $userAgent = $session['user_agent'];
        $session['device_info'] = parseUserAgent($userAgent);
        $session['location'] = getLocationFromIP($session['ip_address']);
        $session['formatted_date'] = timeAgo($session['created_at']);
        // Don't expose full session token
        unset($session['session_token']);
    }
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'sessions' => $sessions
    ]);
    
} catch (Exception $e) {
    error_log("Get Sessions Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to fetch sessions'
    ]);
}

function parseUserAgent($userAgent) {
    $browser = 'Unknown Browser';
    $os = 'Unknown OS';
    $deviceType = 'desktop';
    
    // Detect browser
    if (strpos($userAgent, 'Chrome') !== false && strpos($userAgent, 'Edge') === false) {
        $browser = 'Chrome';
    } elseif (strpos($userAgent, 'Firefox') !== false) {
        $browser = 'Firefox';
    } elseif (strpos($userAgent, 'Safari') !== false && strpos($userAgent, 'Chrome') === false) {
        $browser = 'Safari';
    } elseif (strpos($userAgent, 'Edge') !== false) {
        $browser = 'Edge';
    }
    
    // Detect OS
    if (strpos($userAgent, 'Windows') !== false) {
        $os = 'Windows';
    } elseif (strpos($userAgent, 'Mac') !== false) {
        $os = 'macOS';
    } elseif (strpos($userAgent, 'Linux') !== false) {
        $os = 'Linux';
    } elseif (strpos($userAgent, 'Android') !== false) {
        $os = 'Android';
        $deviceType = 'mobile';
    } elseif (strpos($userAgent, 'iOS') !== false || strpos($userAgent, 'iPhone') !== false) {
        $os = 'iOS';
        $deviceType = 'mobile';
    }
    
    // Detect tablet
    if (strpos($userAgent, 'iPad') !== false || strpos($userAgent, 'Tablet') !== false) {
        $deviceType = 'tablet';
    }
    
    return [
        'browser' => $browser,
        'os' => $os,
        'device_type' => $deviceType,
        'description' => "$browser on $os"
    ];
}

function getLocationFromIP($ip) {
    // Basic location detection - can be enhanced with GeoIP service
    if ($ip === '127.0.0.1' || $ip === '::1') {
        return 'Local';
    }
    return 'Unknown Location';
}

function timeAgo($datetime) {
    $time = strtotime($datetime);
    $now = time();
    $diff = $now - $time;
    
    if ($diff < 60) return 'just now';
    if ($diff < 3600) return floor($diff / 60) . ' minutes ago';
    if ($diff < 86400) return floor($diff / 3600) . ' hours ago';
    if ($diff < 604800) return floor($diff / 86400) . ' days ago';
    return date('M j, Y', $time);
}
