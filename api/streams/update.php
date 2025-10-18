<?php
/**
 * Update Stream API
 * Updates stream information (title, description, etc.)
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
    
    // Verify the stream belongs to this vendor
    $stmt = $db->prepare("
        SELECT id FROM live_streams 
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
    
    // Build update query based on provided fields
    $updates = [];
    $params = [];
    
    if (isset($data['title'])) {
        $updates[] = "title = ?";
        $params[] = $data['title'];
    }
    
    if (isset($data['description'])) {
        $updates[] = "description = ?";
        $params[] = $data['description'];
    }
    
    if (isset($data['thumbnail_url'])) {
        $updates[] = "thumbnail_url = ?";
        $params[] = $data['thumbnail_url'];
    }
    
    if (empty($updates)) {
        throw new Exception('No fields to update');
    }
    
    // Add stream ID to params
    $params[] = $streamId;
    
    // Execute update
    $sql = "UPDATE live_streams SET " . implode(', ', $updates) . " WHERE id = ?";
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    
    echo json_encode([
        'success' => true,
        'message' => 'Stream updated successfully'
    ]);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
