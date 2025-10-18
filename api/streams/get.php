<?php
/**
 * Get Stream Details API
 * Retrieves detailed information about a specific stream
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

try {
    if (!isset($_GET['stream_id'])) {
        throw new Exception('Stream ID is required');
    }
    
    $streamId = (int)$_GET['stream_id'];
    
    $db = db();
    
    // Get stream details with vendor info
    $stmt = $db->prepare("
        SELECT ls.*,
               v.business_name as vendor_name,
               v.id as vendor_id,
               TIMESTAMPDIFF(SECOND, ls.started_at, ls.ended_at) as duration_seconds
        FROM live_streams ls
        JOIN vendors v ON ls.vendor_id = v.id
        WHERE ls.id = ?
    ");
    $stmt->execute([$streamId]);
    $stream = $stmt->fetch();
    
    if (!$stream) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'error' => 'Stream not found'
        ]);
        exit;
    }
    
    // Generate stream URL based on status
    $streamUrl = null;
    $isLive = $stream['status'] === 'live';
    
    if ($isLive && !empty($stream['stream_key'])) {
        // For live streams, use HLS endpoint (assuming HLS streaming is set up)
        // Format: /streams/hls/{stream_key}/playlist.m3u8
        $streamUrl = '/streams/hls/' . $stream['stream_key'] . '/playlist.m3u8';
    } elseif ($stream['status'] === 'archived' && !empty($stream['video_path'])) {
        // For archived streams, use the recorded video path
        $streamUrl = $stream['video_path'];
    }
    
    // Add stream URL and live status to response
    $stream['stream_url'] = $streamUrl;
    $stream['is_live'] = $isLive;
    
    echo json_encode([
        'success' => true,
        'stream' => $stream,
        'stream_url' => $streamUrl,
        'is_live' => $isLive
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
