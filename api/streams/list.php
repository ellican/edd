<?php
/**
 * List Streams API
 * Returns active, scheduled, and recent streams
 */

require_once __DIR__ . '/../../includes/init.php';

header('Content-Type: application/json');

try {
    $db = db();
    $type = $_GET['type'] ?? 'all'; // 'active', 'scheduled', 'recent', 'archived', 'live', or 'all'
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
    $offset = isset($_GET['offset']) ? (int)$_GET['offset'] : 0;
    
    // Check if filtering by vendor
    $vendorId = null;
    if (Session::isLoggedIn()) {
        $vendor = new Vendor();
        $vendorInfo = $vendor->findByUserId(Session::getUserId());
        if ($vendorInfo) {
            $vendorId = $vendorInfo['id'];
        }
    }
    
    $response = ['success' => true];
    
    // Map 'live' type to 'active' for backward compatibility
    if ($type === 'live') {
        $type = 'active';
    }
    
    if ($type === 'active' || $type === 'all') {
        // Get active (live) streams
        $whereClauses = ["ls.status = 'live'"];
        $params = [];
        
        if ($vendorId) {
            $whereClauses[] = "ls.vendor_id = ?";
            $params[] = $vendorId;
        }
        
        $whereSQL = implode(' AND ', $whereClauses);
        $params[] = $limit;
        $params[] = $offset;
        
        $stmt = $db->prepare("
            SELECT ls.*, 
                   v.business_name as vendor_name,
                   v.id as vendor_id,
                   ls.viewer_count as current_viewers,
                   TIMESTAMPDIFF(SECOND, ls.started_at, NOW()) as duration_seconds
            FROM live_streams ls
            JOIN vendors v ON ls.vendor_id = v.id
            WHERE {$whereSQL}
            ORDER BY ls.viewer_count DESC, ls.started_at DESC
            LIMIT ? OFFSET ?
        ");
        $stmt->execute($params);
        $response['active'] = $stmt->fetchAll();
        
        // For single type requests, return streams array directly
        if ($type === 'active') {
            $response['streams'] = $response['active'];
        }
    }
    
    if ($type === 'scheduled' || $type === 'all') {
        // Get scheduled streams (future only)
        $whereClauses = ["ls.status = 'scheduled'", "ls.scheduled_at > NOW()"];
        $params = [];
        
        if ($vendorId) {
            $whereClauses[] = "ls.vendor_id = ?";
            $params[] = $vendorId;
        }
        
        $whereSQL = implode(' AND ', $whereClauses);
        $params[] = $limit;
        $params[] = $offset;
        
        $stmt = $db->prepare("
            SELECT ls.*,
                   v.business_name as vendor_name,
                   v.id as vendor_id,
                   TIMESTAMPDIFF(SECOND, NOW(), ls.scheduled_at) as seconds_until_start
            FROM live_streams ls
            JOIN vendors v ON ls.vendor_id = v.id
            WHERE {$whereSQL}
            ORDER BY ls.scheduled_at ASC
            LIMIT ? OFFSET ?
        ");
        $stmt->execute($params);
        $response['scheduled'] = $stmt->fetchAll();
        
        // For single type requests, return streams array directly
        if ($type === 'scheduled') {
            $response['streams'] = $response['scheduled'];
        }
    }
    
    if ($type === 'recent' || $type === 'archived' || $type === 'all') {
        // Get recent archived streams
        $whereClauses = ["ls.status = 'archived'", "ls.ended_at IS NOT NULL"];
        $params = [];
        
        if ($vendorId) {
            $whereClauses[] = "ls.vendor_id = ?";
            $params[] = $vendorId;
        }
        
        $whereSQL = implode(' AND ', $whereClauses);
        $params[] = $limit;
        $params[] = $offset;
        
        $stmt = $db->prepare("
            SELECT ls.*,
                   v.business_name as vendor_name,
                   v.id as vendor_id,
                   TIMESTAMPDIFF(SECOND, ls.started_at, ls.ended_at) as duration_seconds
            FROM live_streams ls
            JOIN vendors v ON ls.vendor_id = v.id
            WHERE {$whereSQL}
            ORDER BY ls.ended_at DESC
            LIMIT ? OFFSET ?
        ");
        $stmt->execute($params);
        $response['recent'] = $stmt->fetchAll();
        
        // For single type requests, return streams array directly
        if ($type === 'recent' || $type === 'archived') {
            $response['streams'] = $response['recent'];
        }
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
