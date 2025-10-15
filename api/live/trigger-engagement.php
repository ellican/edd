<?php
/**
 * Trigger Fake Engagement for Active Streams
 * This endpoint should be called periodically (e.g., every minute via cron or client-side)
 */

require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/fake-engagement.php';

header('Content-Type: application/json');

try {
    // Optional: Require authentication for triggering
    // For now, allow anyone to trigger it (can be called from client-side)
    
    $generator = new FakeEngagementGenerator();
    
    // Check if specific stream ID is provided
    if (isset($_GET['stream_id']) || isset($_POST['stream_id'])) {
        $streamId = (int)($_GET['stream_id'] ?? $_POST['stream_id']);
        
        $viewersChange = $generator->generateFakeViewers($streamId);
        $likesAdded = $generator->generateFakeLikes($streamId);
        
        echo json_encode([
            'success' => true,
            'stream_id' => $streamId,
            'viewers_change' => $viewersChange,
            'likes_added' => $likesAdded,
            'message' => 'Fake engagement processed for stream ' . $streamId
        ]);
    } else {
        // Process all active streams
        $results = $generator->processAllActiveStreams();
        
        echo json_encode([
            'success' => true,
            'streams_processed' => count($results),
            'results' => $results,
            'message' => 'Fake engagement processed for all active streams'
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
