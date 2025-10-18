<?php
/**
 * Get Stream Settings API
 * Retrieves current stream configuration including engagement settings
 */

require_once __DIR__ . '/../../../includes/init.php';

header('Content-Type: application/json');

// Check admin authentication
if (!isset($_SESSION['user_role']) || $_SESSION['user_role'] !== 'admin') {
    http_response_code(403);
    echo json_encode([
        'success' => false,
        'error' => 'Admin access required'
    ]);
    exit;
}

try {
    $db = db();
    
    // Create settings table if it doesn't exist
    $db->exec("
        CREATE TABLE IF NOT EXISTS global_stream_settings (
            id INT PRIMARY KEY AUTO_INCREMENT,
            setting_key VARCHAR(255) UNIQUE NOT NULL,
            setting_value TEXT,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ");
    
    // Load all settings
    $stmt = $db->query("SELECT setting_key, setting_value FROM global_stream_settings");
    $settingsData = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);
    
    // Default values
    $defaults = [
        'rtmp_server_url' => 'rtmp://localhost/live',
        'rtmp_server_key' => '',
        'stream_max_bitrate' => 4000,
        'stream_max_resolution' => '1920x1080',
        'stream_max_duration' => 14400,
        'stream_enable_recording' => 1,
        'fake_viewers_enabled' => 1,
        'fake_likes_enabled' => 1,
        'min_fake_viewers' => 15,
        'max_fake_viewers' => 100,
        'viewer_increase_rate' => 5,
        'viewer_decrease_rate' => 3,
        'like_rate' => 3,
        'engagement_multiplier' => 2.0
    ];
    
    // Merge with defaults
    $settings = array_merge($defaults, $settingsData);
    
    echo json_encode([
        'success' => true,
        'settings' => $settings
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
