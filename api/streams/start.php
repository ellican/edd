<?php
/**
 * Start Live Stream API
 * Creates a new stream record or starts a scheduled stream
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

try {
    // Check if user is logged in
    if (!Session::isLoggedIn()) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'error' => 'Authentication required'
        ]);
        exit;
    }
    
    $userId = Session::getUserId();
    
    // Check if user is a vendor
    $vendor = new Vendor();
    $vendorInfo = $vendor->findByUserId($userId);
    
    if (!$vendorInfo || $vendorInfo['status'] !== 'approved') {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'error' => 'Approved vendor access required'
        ]);
        exit;
    }
    
    // Get request data
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['title'])) {
        throw new Exception('Stream title is required');
    }
    
    $db = db();
    $vendorId = $vendorInfo['id'];
    
    // Check if there's already an active stream for this vendor
    $stmt = $db->prepare("
        SELECT id FROM live_streams 
        WHERE vendor_id = ? AND status = 'live'
        LIMIT 1
    ");
    $stmt->execute([$vendorId]);
    $existingStream = $stmt->fetch();
    
    if ($existingStream) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error' => 'You already have an active stream. Please end it before starting a new one.'
        ]);
        exit;
    }
    
    // Check if starting a scheduled stream
    $streamId = $data['stream_id'] ?? null;
    
    if ($streamId) {
        // Start a scheduled stream
        $stmt = $db->prepare("
            SELECT * FROM live_streams 
            WHERE id = ? AND vendor_id = ? AND status = 'scheduled'
        ");
        $stmt->execute([$streamId, $vendorId]);
        $stream = $stmt->fetch();
        
        if (!$stream) {
            throw new Exception('Scheduled stream not found or already started');
        }
        
        // Update stream to live
        $stmt = $db->prepare("
            UPDATE live_streams 
            SET status = 'live', 
                started_at = NOW(),
                stream_url = ?
            WHERE id = ?
        ");
        $stmt->execute([
            $data['stream_url'] ?? null,
            $streamId
        ]);
        
    } else {
        // Create a new stream
        $stmt = $db->prepare("
            INSERT INTO live_streams 
            (vendor_id, title, description, thumbnail_url, stream_url, 
             status, chat_enabled, started_at, created_at)
            VALUES (?, ?, ?, ?, ?, 'live', ?, NOW(), NOW())
        ");
        
        $stmt->execute([
            $vendorId,
            $data['title'],
            $data['description'] ?? null,
            $data['thumbnail_url'] ?? null,
            $data['stream_url'] ?? null,
            isset($data['chat_enabled']) ? (int)$data['chat_enabled'] : 1
        ]);
        
        $streamId = $db->lastInsertId();
    }
    
    // Initialize engagement config for this stream if it doesn't exist
    $stmt = $db->prepare("
        INSERT IGNORE INTO stream_engagement_config 
        (stream_id, fake_viewers_enabled, fake_likes_enabled, 
         min_fake_viewers, max_fake_viewers, viewer_increase_rate, 
         viewer_decrease_rate, like_rate, engagement_multiplier)
        VALUES (?, 1, 1, 15, 100, 5, 3, 3, 2.00)
    ");
    $stmt->execute([$streamId]);
    
    // Get the stream details
    $liveStream = new LiveStream();
    $stream = $liveStream->getStreamById($streamId);
    
    // Trigger initial fake engagement
    require_once __DIR__ . '/../live/fake-engagement.php';
    $generator = new FakeEngagementGenerator();
    $generator->generateFakeViewers($streamId);
    $generator->generateFakeLikes($streamId);
    
    echo json_encode([
        'success' => true,
        'message' => 'Stream started successfully',
        'stream_id' => $streamId,
        'stream' => $stream
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
