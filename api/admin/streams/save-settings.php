<?php
/**
 * Save Stream Settings API
 * Handles saving stream configuration including engagement settings
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
    // Get request data
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data) {
        throw new Exception('No settings data provided');
    }
    
    $db = db();
    
    // Save global engagement settings to a config table or file
    // For now, we'll store them in a settings table
    
    // Create settings table if it doesn't exist
    $db->exec("
        CREATE TABLE IF NOT EXISTS global_stream_settings (
            id INT PRIMARY KEY AUTO_INCREMENT,
            setting_key VARCHAR(255) UNIQUE NOT NULL,
            setting_value TEXT,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ");
    
    // Prepare settings to save
    $settingsToSave = [
        'rtmp_server_url' => $data['rtmp_server_url'] ?? 'rtmp://localhost/live',
        'rtmp_server_key' => $data['rtmp_server_key'] ?? '',
        'stream_max_bitrate' => $data['stream_max_bitrate'] ?? 4000,
        'stream_max_resolution' => $data['stream_max_resolution'] ?? '1920x1080',
        'stream_max_duration' => $data['stream_max_duration'] ?? 14400,
        'stream_enable_recording' => $data['stream_enable_recording'] ?? 1,
        'fake_viewers_enabled' => $data['fake_viewers_enabled'] ?? 1,
        'fake_likes_enabled' => $data['fake_likes_enabled'] ?? 1,
        'min_fake_viewers' => $data['min_fake_viewers'] ?? 15,
        'max_fake_viewers' => $data['max_fake_viewers'] ?? 100,
        'viewer_increase_rate' => $data['viewer_increase_rate'] ?? 5,
        'viewer_decrease_rate' => $data['viewer_decrease_rate'] ?? 3,
        'like_rate' => $data['like_rate'] ?? 3,
        'engagement_multiplier' => $data['engagement_multiplier'] ?? 2.0
    ];
    
    // Save each setting
    $stmt = $db->prepare("
        INSERT INTO global_stream_settings (setting_key, setting_value)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)
    ");
    
    foreach ($settingsToSave as $key => $value) {
        $stmt->execute([$key, $value]);
    }
    
    // Update default values in stream_engagement_config for future streams
    // This won't affect existing streams, only new ones created after this change
    try {
        $db->exec("
            ALTER TABLE stream_engagement_config 
            ALTER COLUMN fake_viewers_enabled SET DEFAULT " . (int)$settingsToSave['fake_viewers_enabled'] . ",
            ALTER COLUMN fake_likes_enabled SET DEFAULT " . (int)$settingsToSave['fake_likes_enabled'] . ",
            ALTER COLUMN min_fake_viewers SET DEFAULT " . (int)$settingsToSave['min_fake_viewers'] . ",
            ALTER COLUMN max_fake_viewers SET DEFAULT " . (int)$settingsToSave['max_fake_viewers'] . ",
            ALTER COLUMN viewer_increase_rate SET DEFAULT " . (int)$settingsToSave['viewer_increase_rate'] . ",
            ALTER COLUMN viewer_decrease_rate SET DEFAULT " . (int)$settingsToSave['viewer_decrease_rate'] . ",
            ALTER COLUMN like_rate SET DEFAULT " . (int)$settingsToSave['like_rate'] . ",
            ALTER COLUMN engagement_multiplier SET DEFAULT " . (float)$settingsToSave['engagement_multiplier'] . "
        ");
    } catch (Exception $e) {
        // Ignore errors on default value updates (MariaDB vs MySQL compatibility)
        error_log("Could not update defaults: " . $e->getMessage());
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Settings saved successfully',
        'settings' => $settingsToSave
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
