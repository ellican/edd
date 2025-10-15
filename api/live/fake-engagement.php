<?php
/**
 * Live Stream Fake Engagement Generator
 * Randomly increases viewers and likes during live streams
 */

require_once __DIR__ . '/../../includes/init.php';

class FakeEngagementGenerator {
    private $pdo;
    
    public function __construct() {
        $this->pdo = db();
    }
    
    /**
     * Generate fake viewers for an active stream
     */
    public function generateFakeViewers($streamId) {
        try {
            // Get stream config
            $config = $this->getStreamConfig($streamId);
            if (!$config || !$config['fake_viewers_enabled']) {
                return 0;
            }
            
            // Get current fake viewer count
            $stmt = $this->pdo->prepare("
                SELECT COUNT(*) as count 
                FROM stream_viewers 
                WHERE stream_id = ? AND is_fake = 1 AND left_at IS NULL
            ");
            $stmt->execute([$streamId]);
            $currentFake = $stmt->fetch()['count'];
            
            // Get real viewer count
            $stmt = $this->pdo->prepare("
                SELECT COUNT(*) as count 
                FROM stream_viewers 
                WHERE stream_id = ? AND is_fake = 0 AND left_at IS NULL
            ");
            $stmt->execute([$streamId]);
            $currentReal = $stmt->fetch()['count'];
            
            // Calculate target fake viewers (should be 2-5x real viewers)
            $multiplier = $config['engagement_multiplier'];
            $targetFake = max(
                $config['min_fake_viewers'],
                min($config['max_fake_viewers'], (int)($currentReal * $multiplier))
            );
            
            // Add some randomness to the increase/decrease
            $change = 0;
            if ($currentFake < $targetFake) {
                // Add viewers
                $maxIncrease = $config['viewer_increase_rate'];
                $change = rand(1, $maxIncrease);
                $this->addFakeViewers($streamId, min($change, $targetFake - $currentFake));
            } elseif ($currentFake > $targetFake) {
                // Remove some viewers (natural churn)
                $maxDecrease = $config['viewer_decrease_rate'];
                $change = -rand(1, $maxDecrease);
                $this->removeFakeViewers($streamId, min(abs($change), $currentFake - $targetFake));
            }
            
            return $change;
            
        } catch (Exception $e) {
            error_log("Fake viewer generation error: " . $e->getMessage());
            return 0;
        }
    }
    
    /**
     * Generate fake likes for an active stream
     */
    public function generateFakeLikes($streamId) {
        try {
            // Get stream config
            $config = $this->getStreamConfig($streamId);
            if (!$config || !$config['fake_likes_enabled']) {
                return 0;
            }
            
            // Get current viewer count (real + fake)
            $stmt = $this->pdo->prepare("
                SELECT COUNT(*) as count 
                FROM stream_viewers 
                WHERE stream_id = ? AND left_at IS NULL
            ");
            $stmt->execute([$streamId]);
            $viewerCount = $stmt->fetch()['count'];
            
            if ($viewerCount == 0) {
                return 0;
            }
            
            // Calculate like probability based on engagement rate
            // Typically 5-15% of viewers like during a stream
            $likeProbability = 0.10 * $config['engagement_multiplier'];
            
            // Random chance to add likes
            $likeRate = $config['like_rate'];
            $likesToAdd = 0;
            
            for ($i = 0; $i < $likeRate; $i++) {
                if (rand(1, 100) / 100 < $likeProbability) {
                    $likesToAdd++;
                }
            }
            
            if ($likesToAdd > 0) {
                $this->addFakeLikes($streamId, $likesToAdd);
            }
            
            return $likesToAdd;
            
        } catch (Exception $e) {
            error_log("Fake like generation error: " . $e->getMessage());
            return 0;
        }
    }
    
    /**
     * Process engagement for all active streams
     */
    public function processAllActiveStreams() {
        try {
            $stmt = $this->pdo->query("
                SELECT id FROM live_streams 
                WHERE status = 'live'
            ");
            $streams = $stmt->fetchAll(PDO::FETCH_COLUMN);
            
            $results = [];
            foreach ($streams as $streamId) {
                $viewersAdded = $this->generateFakeViewers($streamId);
                $likesAdded = $this->generateFakeLikes($streamId);
                
                $results[] = [
                    'stream_id' => $streamId,
                    'viewers_change' => $viewersAdded,
                    'likes_added' => $likesAdded
                ];
            }
            
            return $results;
            
        } catch (Exception $e) {
            error_log("Process active streams error: " . $e->getMessage());
            return [];
        }
    }
    
    /**
     * Get stream engagement configuration
     */
    private function getStreamConfig($streamId) {
        $stmt = $this->pdo->prepare("
            SELECT * FROM stream_engagement_config 
            WHERE stream_id = ?
        ");
        $stmt->execute([$streamId]);
        $config = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // If no config exists, create default
        if (!$config) {
            $this->createDefaultConfig($streamId);
            return $this->getStreamConfig($streamId);
        }
        
        return $config;
    }
    
    /**
     * Create default engagement config for a stream
     */
    private function createDefaultConfig($streamId) {
        $stmt = $this->pdo->prepare("
            INSERT INTO stream_engagement_config 
            (stream_id, fake_viewers_enabled, fake_likes_enabled, 
             min_fake_viewers, max_fake_viewers, viewer_increase_rate, 
             viewer_decrease_rate, like_rate, engagement_multiplier)
            VALUES (?, 1, 1, 10, 50, 5, 3, 2, 1.50)
        ");
        $stmt->execute([$streamId]);
    }
    
    /**
     * Add fake viewers to a stream
     */
    private function addFakeViewers($streamId, $count) {
        $stmt = $this->pdo->prepare("
            INSERT INTO stream_viewers 
            (stream_id, user_id, session_id, is_fake, joined_at)
            VALUES (?, NULL, ?, 1, NOW())
        ");
        
        for ($i = 0; $i < $count; $i++) {
            $fakeSessionId = 'fake_' . $streamId . '_' . uniqid() . '_' . rand(1000, 9999);
            $stmt->execute([$streamId, $fakeSessionId]);
        }
    }
    
    /**
     * Remove some fake viewers (simulate natural churn)
     */
    private function removeFakeViewers($streamId, $count) {
        $stmt = $this->pdo->prepare("
            UPDATE stream_viewers 
            SET left_at = NOW(), 
                watch_duration = TIMESTAMPDIFF(SECOND, joined_at, NOW())
            WHERE stream_id = ? AND is_fake = 1 AND left_at IS NULL
            ORDER BY joined_at ASC
            LIMIT ?
        ");
        $stmt->execute([$streamId, $count]);
    }
    
    /**
     * Add fake likes to a stream
     */
    private function addFakeLikes($streamId, $count) {
        $stmt = $this->pdo->prepare("
            INSERT INTO stream_interactions 
            (stream_id, user_id, interaction_type, is_fake, created_at)
            VALUES (?, NULL, 'like', 1, NOW())
        ");
        
        for ($i = 0; $i < $count; $i++) {
            try {
                $stmt->execute([$streamId]);
            } catch (Exception $e) {
                // Ignore duplicate errors
            }
        }
    }
}

// If called directly (e.g., via cron job)
if (php_sapi_name() === 'cli') {
    $generator = new FakeEngagementGenerator();
    $results = $generator->processAllActiveStreams();
    
    echo "Fake Engagement Generator Results:\n";
    foreach ($results as $result) {
        echo "Stream {$result['stream_id']}: ";
        echo "Viewers change: {$result['viewers_change']}, ";
        echo "Likes added: {$result['likes_added']}\n";
    }
}
