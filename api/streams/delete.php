<?php
/**
 * Delete Stream Recording API
 * Deletes a saved stream recording
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
    
    $db = db();
    
    // Verify the stream belongs to this vendor and is archived
    $stmt = $db->prepare("
        SELECT id, status, video_path 
        FROM live_streams 
        WHERE id = ? AND vendor_id = ?
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
    
    // Only allow deletion of archived or ended streams
    if (!in_array($stream['status'], ['archived', 'ended'])) {
        throw new Exception('Only archived or ended streams can be deleted');
    }
    
    // Delete the video file if it exists
    if ($stream['video_path'] && file_exists($stream['video_path'])) {
        @unlink($stream['video_path']);
    }
    
    // Delete related data
    $db->beginTransaction();
    
    try {
        // Delete from saved_streams table
        $stmt = $db->prepare("DELETE FROM saved_streams WHERE stream_id = ?");
        $stmt->execute([$streamId]);
        
        // Option 1: Soft delete - just remove video_path and mark as deleted
        $stmt = $db->prepare("
            UPDATE live_streams 
            SET video_path = NULL,
                status = 'ended'
            WHERE id = ?
        ");
        $stmt->execute([$streamId]);
        
        // Option 2: Hard delete (commented out - uncomment if you prefer hard delete)
        /*
        $stmt = $db->prepare("DELETE FROM stream_viewers WHERE stream_id = ?");
        $stmt->execute([$streamId]);
        
        $stmt = $db->prepare("DELETE FROM stream_interactions WHERE stream_id = ?");
        $stmt->execute([$streamId]);
        
        $stmt = $db->prepare("DELETE FROM stream_engagement_config WHERE stream_id = ?");
        $stmt->execute([$streamId]);
        
        $stmt = $db->prepare("DELETE FROM live_streams WHERE id = ?");
        $stmt->execute([$streamId]);
        */
        
        $db->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Stream recording deleted successfully'
        ]);
        
    } catch (Exception $e) {
        $db->rollBack();
        throw $e;
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
