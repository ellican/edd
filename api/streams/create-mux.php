<?php
/**
 * Create Mux Live Stream API
 * Handles seller request to create a new live stream via Mux
 */

require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../../includes/MuxStreamService.php';

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
    
    if (!isset($data['title']) || empty(trim($data['title']))) {
        throw new Exception('Stream title is required');
    }
    
    $db = db();
    $vendorId = $vendorInfo['id'];
    
    // Check if there's already an active stream for this vendor
    $stmt = $db->prepare("
        SELECT id, title FROM live_streams 
        WHERE vendor_id = ? AND status IN ('live', 'scheduled')
        LIMIT 1
    ");
    $stmt->execute([$vendorId]);
    $existingStream = $stmt->fetch();
    
    if ($existingStream) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error' => 'You already have an active or scheduled stream. Please end or cancel it before creating a new one.',
            'existing_stream' => $existingStream
        ]);
        exit;
    }
    
    // Initialize Mux service
    $muxService = new MuxStreamService();
    
    // Create live stream in Mux
    $muxOptions = [
        'playback_policy' => ['public'],
        'new_asset_settings' => [
            'playback_policy' => ['public']
        ],
        'reconnect_window' => 60,
        'reduced_latency' => true
    ];
    
    $muxData = $muxService->createLiveStream($muxOptions);
    
    // Create stream record in database
    $stmt = $db->prepare("
        INSERT INTO live_streams 
        (vendor_id, stream_key, mux_stream_id, mux_playback_id, title, description, 
         thumbnail_url, stream_url, status, chat_enabled, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'scheduled', ?, NOW())
    ");
    
    $stmt->execute([
        $vendorId,
        $muxData['stream_key'],
        $muxData['mux_stream_id'],
        $muxData['playback_id'],
        trim($data['title']),
        $data['description'] ?? null,
        $data['thumbnail_url'] ?? null,
        $muxData['stream_url'],
        isset($data['chat_enabled']) ? (int)$data['chat_enabled'] : 1
    ]);
    
    $streamId = $db->lastInsertId();
    
    // Get the created stream details
    $liveStream = new LiveStream();
    $stream = $liveStream->getStreamById($streamId);
    
    // Prepare response with RTMP credentials
    echo json_encode([
        'success' => true,
        'message' => 'Live stream created successfully',
        'stream_id' => $streamId,
        'stream' => $stream,
        'rtmp_credentials' => [
            'rtmp_url' => $muxData['rtmp_url'],
            'stream_key' => $muxData['stream_key']
        ],
        'playback_url' => $muxData['stream_url'],
        'instructions' => [
            'obs' => [
                'server' => $muxData['rtmp_url'],
                'stream_key' => $muxData['stream_key']
            ],
            'notes' => 'Use these credentials in OBS or your streaming software. The stream will be available at the playback URL once you start broadcasting.'
        ]
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
