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
    $videoUrl = $data['video_url'] ?? null;
    
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
               (SELECT COUNT(*) FROM stream_orders WHERE stream_id = ls.id) as orders_count
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
    
    // Calculate duration
    $duration = time() - strtotime($stream['started_at']);
    
    // Update final engagement counts before ending
    $stmt = $db->prepare("
        UPDATE live_streams
        SET 
            viewer_count = ?,
            like_count = ?,
            dislike_count = ?,
            comment_count = ?,
            total_revenue = ?
        WHERE id = ?
    ");
    $stmt->execute([
        $stream['total_viewers'],
        $stream['total_likes'],
        $stream['total_dislikes'],
        $stream['total_comments'],
        $stream['total_revenue'],
        $streamId
    ]);
    
    if ($action === 'save') {
        // Mark stream as archived (saved for replay)
        $stmt = $db->prepare("
            UPDATE live_streams 
            SET status = 'archived', 
                ended_at = NOW(),
                video_path = ?
            WHERE id = ?
        ");
        $stmt->execute([$videoUrl, $streamId]);
        
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
