<?php
/**
 * List Streams API
 * Returns active, scheduled, and recent streams
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

try {
    $db = db();
    $type = $_GET['type'] ?? 'all'; // 'active', 'scheduled', 'recent', or 'all'
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $offset = isset($_GET['offset']) ? (int)$_GET['offset'] : 0;
    
    $response = ['success' => true];
    
    if ($type === 'active' || $type === 'all') {
        // Get active (live) streams
        $stmt = $db->prepare("
            SELECT ls.*, 
                   v.business_name as vendor_name,
                   v.id as vendor_id,
                   ls.viewer_count as current_viewers,
                   TIMESTAMPDIFF(SECOND, ls.started_at, NOW()) as duration_seconds
            FROM live_streams ls
            JOIN vendors v ON ls.vendor_id = v.id
            WHERE ls.status = 'live'
            ORDER BY ls.viewer_count DESC, ls.started_at DESC
            LIMIT ? OFFSET ?
        ");
        $stmt->execute([$limit, $offset]);
        $response['active'] = $stmt->fetchAll();
    }
    
    if ($type === 'scheduled' || $type === 'all') {
        // Get scheduled streams (future only)
        $stmt = $db->prepare("
            SELECT ls.*,
                   v.business_name as vendor_name,
                   v.id as vendor_id,
                   TIMESTAMPDIFF(SECOND, NOW(), ls.scheduled_at) as seconds_until_start
            FROM live_streams ls
            JOIN vendors v ON ls.vendor_id = v.id
            WHERE ls.status = 'scheduled' 
              AND ls.scheduled_at > NOW()
            ORDER BY ls.scheduled_at ASC
            LIMIT ? OFFSET ?
        ");
        $stmt->execute([$limit, $offset]);
        $response['scheduled'] = $stmt->fetchAll();
    }
    
    if ($type === 'recent' || $type === 'all') {
        // Get recent archived streams
        $stmt = $db->prepare("
            SELECT ls.*,
                   v.business_name as vendor_name,
                   v.id as vendor_id,
                   TIMESTAMPDIFF(SECOND, ls.started_at, ls.ended_at) as duration_seconds
            FROM live_streams ls
            JOIN vendors v ON ls.vendor_id = v.id
            WHERE ls.status = 'archived'
              AND ls.ended_at IS NOT NULL
            ORDER BY ls.ended_at DESC
            LIMIT ? OFFSET ?
        ");
        $stmt->execute([$limit, $offset]);
        $response['recent'] = $stmt->fetchAll();
    }
    
    // Get counts for each type
    if ($type === 'all') {
        $stmt = $db->query("SELECT COUNT(*) FROM live_streams WHERE status = 'live'");
        $response['counts'] = [
            'active' => (int)$stmt->fetchColumn(),
        ];
        
        $stmt = $db->query("SELECT COUNT(*) FROM live_streams WHERE status = 'scheduled' AND scheduled_at > NOW()");
        $response['counts']['scheduled'] = (int)$stmt->fetchColumn();
        
        $stmt = $db->query("SELECT COUNT(*) FROM live_streams WHERE status = 'archived' AND ended_at IS NOT NULL");
        $response['counts']['recent'] = (int)$stmt->fetchColumn();
    }
    
    echo json_encode($response);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
