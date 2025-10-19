<?php
/**
 * End Stream API
 * Ends a live stream and optionally saves it for replay
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
    
    if (!$vendorInfo) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'error' => 'Vendor access required'
        ]);
        exit;
    }
    
    // Get request data
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['stream_id'])) {
        throw new Exception('Stream ID is required');
    }
    
    $streamId = (int)$data['stream_id'];
    $action = $data['action'] ?? 'save'; // 'save' or 'delete'
    $videoUrl = null;
    
    $db = db();
    
    // Verify the stream belongs to this vendor and get user_id
    $stmt = $db->prepare("
        SELECT ls.*,
               v.user_id as seller_user_id,
               (SELECT COUNT(*) FROM stream_viewers WHERE stream_id = ls.id) as total_viewers,
               (SELECT COUNT(*) FROM stream_interactions WHERE stream_id = ls.id AND interaction_type = 'like') as total_likes,
               (SELECT COUNT(*) FROM stream_interactions WHERE stream_id = ls.id AND interaction_type = 'dislike') as total_dislikes,
               (SELECT COUNT(*) FROM stream_interactions WHERE stream_id = ls.id AND interaction_type = 'comment') as total_comments,
               (SELECT COALESCE(SUM(amount), 0) FROM stream_orders WHERE stream_id = ls.id) as total_revenue,
               (SELECT COUNT(*) FROM stream_orders WHERE stream_id = ls.id) as orders_count,
               (SELECT MAX(viewer_count) FROM live_streams WHERE id = ls.id) as peak_viewers
        FROM live_streams ls
        JOIN vendors v ON ls.vendor_id = v.id
        WHERE ls.id = ? AND ls.vendor_id = ?
    ");
    $stmt->execute([$streamId, $vendorInfo['id']]);
    $stream = $stmt->fetch();
    
    if (!$stream) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'error' => 'Stream not found or access denied'
        ]);
        exit;
    }
    
    // Verify stream is live
    if ($stream['status'] !== 'live') {
        throw new Exception('Stream is not currently live');
    }
    
    // Calculate duration safely - ensure non-negative and within bounds
    $startTime = strtotime($stream['started_at']);
    $endTime = time();
    $duration = max(0, $endTime - $startTime);
    
    // Clamp duration to reasonable maximum (e.g., 48 hours = 172800 seconds)
    // This prevents overflow and ensures data integrity
    $maxDuration = 172800; // 48 hours in seconds
    if ($duration > $maxDuration) {
        error_log("Stream {$streamId} duration exceeded maximum: {$duration} seconds, clamping to {$maxDuration}");
        $duration = $maxDuration;
    }
    
    // Cast to int to ensure proper type
    $duration = (int)$duration;
    
    // Update final engagement counts before ending
    $stmt = $db->prepare("
        UPDATE live_streams
        SET 
            viewer_count = ?,
            like_count = ?,
            dislike_count = ?,
            comment_count = ?,
            total_revenue = ?,
            max_viewers = ?
        WHERE id = ?
    ");
    $stmt->execute([
        $stream['total_viewers'],
        $stream['total_likes'],
        $stream['total_dislikes'],
        $stream['total_comments'],
        $stream['total_revenue'],
        $stream['peak_viewers'],
        $streamId
    ]);
    
    if ($action === 'save') {
        // Check if stream uses Mux - if so, the replay will be available via Mux automatically
        if (!empty($stream['mux_stream_id']) && !empty($stream['mux_playback_id'])) {
            // Mux automatically creates an asset for replay
            // The same playback URL will serve the replay after the stream ends
            $videoUrl = $stream['stream_url']; // Keep the same Mux HLS URL
            
            // Optionally, we could call Mux API to get asset details
            if (file_exists(__DIR__ . '/../../includes/MuxStreamService.php')) {
                require_once __DIR__ . '/../../includes/MuxStreamService.php';
                try {
                    $muxService = new MuxStreamService();
                    // Get updated stream details from Mux
                    $muxDetails = $muxService->getStreamDetails($stream['mux_stream_id']);
                    if ($muxDetails && isset($muxDetails['recent_asset_ids']) && !empty($muxDetails['recent_asset_ids'])) {
                        // Asset was created - replay is available
                        error_log("Mux asset created for stream {$streamId}: " . $muxDetails['recent_asset_ids'][0]);
                    }
                } catch (Exception $e) {
                    error_log("Failed to get Mux stream details: " . $e->getMessage());
                }
            }
        } else {
            // Non-Mux stream: Generate video path for local storage
            $uploadsBase = $_SERVER['DOCUMENT_ROOT'] . '/uploads/streams';
            $sellerDir = $uploadsBase . '/' . $vendorInfo['id'];
            
            if (!file_exists($uploadsBase)) {
                mkdir($uploadsBase, 0755, true);
            }
            if (!file_exists($sellerDir)) {
                mkdir($sellerDir, 0755, true);
            }
            
            // Generate the video file path (web-accessible path)
            $videoUrl = '/uploads/streams/' . $vendorInfo['id'] . '/' . $streamId . '.mp4';
            
            // Note: Actual video recording/encoding would happen here in production
            // This would involve:
            // 1. Capturing the WebRTC stream to server
            // 2. Encoding to H.264/AAC MP4 format
            // 3. Optionally generating HLS variants
        }
        
        // Mark stream as archived (saved for replay)
        try {
            $stmt = $db->prepare("
                UPDATE live_streams 
                SET status = 'archived', 
                    ended_at = NOW(),
                    video_path = ?,
                    duration_seconds = ?,
                    max_viewers = ?
                WHERE id = ?
            ");
            $stmt->execute([
                $videoUrl, 
                $duration,
                $stream['peak_viewers'],
                $streamId
            ]);
        } catch (PDOException $e) {
            error_log("Failed to save stream {$streamId}: " . $e->getMessage());
            error_log("Duration value: {$duration} seconds");
            throw new Exception('Failed to save stream: Database error');
        }
        
        // Also save to saved_streams table for backward compatibility
        // Note: saved_streams uses different column names (seller_id, stream_title, etc.)
        $stmt = $db->prepare("
            INSERT INTO saved_streams 
            (seller_id, stream_title, stream_description, video_url, thumbnail_url, 
             duration, views, likes, dislikes, streamed_at, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ");
        $stmt->execute([
            $stream['seller_user_id'], // saved_streams references users.id, not vendors.id
            $stream['title'],
            $stream['description'],
            $videoUrl ?? $stream['stream_url'],
            $stream['thumbnail_url'],
            $duration,
            $stream['total_viewers'],
            $stream['total_likes'],
            $stream['total_dislikes'],
            $stream['started_at']
        ]);
        
        $message = 'Stream ended and saved successfully';
        
    } else if ($action === 'delete') {
        // Just mark as ended (not archived, won't show in recent)
        $stmt = $db->prepare("
            UPDATE live_streams 
            SET status = 'ended', 
                ended_at = NOW()
            WHERE id = ?
        ");
        $stmt->execute([$streamId]);
        
        $message = 'Stream ended successfully';
        
    } else {
        throw new Exception('Invalid action. Use "save" or "delete"');
    }
    
    echo json_encode([
        'success' => true,
        'message' => $message,
        'action' => $action,
        'stats' => [
            'duration' => $duration,
            'viewers' => $stream['total_viewers'],
            'likes' => $stream['total_likes'],
            'dislikes' => $stream['total_dislikes'],
            'comments' => $stream['total_comments'],
            'orders' => $stream['orders_count'],
            'revenue' => (float)$stream['total_revenue']
        ]
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
