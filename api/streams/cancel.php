<?php
/**
 * Cancel Scheduled Stream API
 * Cancels a scheduled stream event
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
    
    // Verify the stream belongs to this vendor and is scheduled
    $stmt = $db->prepare("
        SELECT id, status, title 
        FROM live_streams 
        WHERE id = ? AND vendor_id = ? AND status = 'scheduled'
    ");
    $stmt->execute([$streamId, $vendorInfo['id']]);
    $stream = $stmt->fetch();
    
    if (!$stream) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'error' => 'Scheduled stream not found or access denied'
        ]);
        exit;
    }
    
    // Update stream status to cancelled
    $stmt = $db->prepare("
        UPDATE live_streams 
        SET status = 'cancelled',
            updated_at = NOW()
        WHERE id = ?
    ");
    $stmt->execute([$streamId]);
    
    // TODO: Send notification to followers that stream was cancelled
    // This could be implemented later
    
    echo json_encode([
        'success' => true,
        'message' => 'Stream cancelled successfully'
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
