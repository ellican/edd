<?php
/**
 * Delete Saved Stream API
 * Deletes a saved stream recording for a seller
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
    
    // Get request data
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['stream_id'])) {
        throw new Exception('Stream ID is required');
    }
    
    $streamId = (int)$data['stream_id'];
    
    $db = db();
    
    // Verify the stream belongs to this user
    $stmt = $db->prepare("
        SELECT id FROM saved_streams 
        WHERE id = ? AND seller_id = ?
    ");
    $stmt->execute([$streamId, $userId]);
    $stream = $stmt->fetch();
    
    if (!$stream) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'error' => 'Stream not found or access denied'
        ]);
        exit;
    }
    
    // Delete the stream
    $stmt = $db->prepare("DELETE FROM saved_streams WHERE id = ?");
    $stmt->execute([$streamId]);
    
    echo json_encode([
        'success' => true,
        'message' => 'Stream deleted successfully'
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
