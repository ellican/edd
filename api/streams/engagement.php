<?php
/**
 * Stream Engagement API
 * Auto-increments engagement (viewers, likes) for active streams
 */

require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../live/fake-engagement.php';

header('Content-Type: application/json');

try {
    $db = db();
    $generator = new FakeEngagementGenerator();
    
    // Check if specific stream ID is provided
    if (isset($_GET['stream_id']) || isset($_POST['stream_id'])) {
        $streamId = (int)($_GET['stream_id'] ?? $_POST['stream_id']);
        
        // Verify stream is live
        $stmt = $db->prepare("SELECT status FROM live_streams WHERE id = ?");
        $stmt->execute([$streamId]);
        $stream = $stmt->fetch();
        
        if (!$stream) {
            throw new Exception('Stream not found');
        }
        
        if ($stream['status'] !== 'live') {
            throw new Exception('Stream is not live');
        }
        
        // Generate engagement
        $viewersChange = $generator->generateFakeViewers($streamId);
        $likesAdded = $generator->generateFakeLikes($streamId);
        
        // Update engagement counts in live_streams table
        $stmt = $db->prepare("
            UPDATE live_streams ls
            SET 
                ls.viewer_count = (
                    SELECT COUNT(*) FROM stream_viewers 
                    WHERE stream_id = ls.id AND left_at IS NULL
                ),
                ls.like_count = (
                    SELECT COUNT(*) FROM stream_interactions 
                    WHERE stream_id = ls.id AND interaction_type = 'like'
                ),
                ls.dislike_count = (
                    SELECT COUNT(*) FROM stream_interactions 
                    WHERE stream_id = ls.id AND interaction_type = 'dislike'
                ),
                ls.comment_count = (
                    SELECT COUNT(*) FROM stream_interactions 
                    WHERE stream_id = ls.id AND interaction_type = 'comment'
                ),
                ls.max_viewers = GREATEST(ls.max_viewers, ls.viewer_count)
            WHERE id = ?
        ");
        $stmt->execute([$streamId]);
        
        // Get updated stats
        $stmt = $db->prepare("
            SELECT viewer_count, like_count, dislike_count, comment_count, max_viewers
            FROM live_streams 
            WHERE id = ?
        ");
        $stmt->execute([$streamId]);
        $stats = $stmt->fetch();
        
        echo json_encode([
            'success' => true,
            'stream_id' => $streamId,
            'engagement' => [
                'viewers_change' => $viewersChange,
                'likes_added' => $likesAdded
            ],
            'current_stats' => $stats
        ]);
        
    } else {
        // Process all active streams
        $results = $generator->processAllActiveStreams();
        
        // Update all stream stats
        foreach ($results as $result) {
            $stmt = $db->prepare("
                UPDATE live_streams ls
                SET 
                    ls.viewer_count = (
                        SELECT COUNT(*) FROM stream_viewers 
                        WHERE stream_id = ls.id AND left_at IS NULL
                    ),
                    ls.like_count = (
                        SELECT COUNT(*) FROM stream_interactions 
                        WHERE stream_id = ls.id AND interaction_type = 'like'
                    ),
                    ls.dislike_count = (
                        SELECT COUNT(*) FROM stream_interactions 
                        WHERE stream_id = ls.id AND interaction_type = 'dislike'
                    ),
                    ls.comment_count = (
                        SELECT COUNT(*) FROM stream_interactions 
                        WHERE stream_id = ls.id AND interaction_type = 'comment'
                    ),
                    ls.max_viewers = GREATEST(ls.max_viewers, ls.viewer_count)
                WHERE id = ?
            ");
            $stmt->execute([$result['stream_id']]);
        }
        
        echo json_encode([
            'success' => true,
            'streams_processed' => count($results),
            'results' => $results
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
