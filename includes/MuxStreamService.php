<?php
/**
 * Mux Live Streaming Service
 * Handles integration with Mux API for live streaming
 * Documentation: https://docs.mux.com/api-reference/video
 */

class MuxStreamService {
    private $tokenId;
    private $tokenSecret;
    private $apiBase = 'https://api.mux.com';
    private $db;
    
    public function __construct() {
        $this->tokenId = getenv('MUX_TOKEN_ID');
        $this->tokenSecret = getenv('MUX_TOKEN_SECRET');
        $this->db = db();
        
        if (empty($this->tokenId) || empty($this->tokenSecret)) {
            throw new Exception('Mux API credentials not configured. Please set MUX_TOKEN_ID and MUX_TOKEN_SECRET in your .env file.');
        }
    }
    
    /**
     * Create a new live stream in Mux
     * @param array $options Stream options (playback_policy, reconnect_window, etc.)
     * @return array Stream details including stream_key and playback_id
     */
    public function createLiveStream($options = []) {
        $defaultOptions = [
            'playback_policy' => ['public'],
            'new_asset_settings' => [
                'playback_policy' => ['public']
            ],
            'reconnect_window' => 60, // Allow reconnection within 60 seconds
            'reduced_latency' => true // Enable low latency streaming
        ];
        
        $streamData = array_merge($defaultOptions, $options);
        
        $response = $this->makeRequest('POST', '/video/v1/live-streams', $streamData);
        
        if (!$response || !isset($response['data'])) {
            throw new Exception('Failed to create Mux live stream');
        }
        
        $data = $response['data'];
        
        return [
            'mux_stream_id' => $data['id'],
            'stream_key' => $data['stream_key'],
            'playback_id' => $data['playback_ids'][0]['id'] ?? null,
            'status' => $data['status'],
            'rtmp_url' => 'rtmps://global-live.mux.com:443/app',
            'stream_url' => isset($data['playback_ids'][0]['id']) 
                ? "https://stream.mux.com/{$data['playback_ids'][0]['id']}.m3u8" 
                : null
        ];
    }
    
    /**
     * Get live stream details from Mux
     * @param string $muxStreamId Mux stream ID
     * @return array|null Stream details
     */
    public function getStreamDetails($muxStreamId) {
        try {
            $response = $this->makeRequest('GET', "/video/v1/live-streams/{$muxStreamId}");
            return $response['data'] ?? null;
        } catch (Exception $e) {
            error_log("Error fetching Mux stream details: " . $e->getMessage());
            return null;
        }
    }
    
    /**
     * Delete a live stream from Mux
     * @param string $muxStreamId Mux stream ID
     * @return bool Success status
     */
    public function deleteLiveStream($muxStreamId) {
        try {
            $this->makeRequest('DELETE', "/video/v1/live-streams/{$muxStreamId}");
            return true;
        } catch (Exception $e) {
            error_log("Error deleting Mux stream: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Create a simulcast target for multi-destination streaming
     * @param string $muxStreamId Mux stream ID
     * @param array $targetData Target configuration
     * @return array|null Target details
     */
    public function createSimulcastTarget($muxStreamId, $targetData) {
        try {
            $response = $this->makeRequest(
                'POST', 
                "/video/v1/live-streams/{$muxStreamId}/simulcast-targets",
                $targetData
            );
            return $response['data'] ?? null;
        } catch (Exception $e) {
            error_log("Error creating simulcast target: " . $e->getMessage());
            return null;
        }
    }
    
    /**
     * Disable a live stream (prevent new connections)
     * @param string $muxStreamId Mux stream ID
     * @return bool Success status
     */
    public function disableStream($muxStreamId) {
        try {
            $this->makeRequest('PUT', "/video/v1/live-streams/{$muxStreamId}/disable");
            return true;
        } catch (Exception $e) {
            error_log("Error disabling Mux stream: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Enable a previously disabled live stream
     * @param string $muxStreamId Mux stream ID
     * @return bool Success status
     */
    public function enableStream($muxStreamId) {
        try {
            $this->makeRequest('PUT', "/video/v1/live-streams/{$muxStreamId}/enable");
            return true;
        } catch (Exception $e) {
            error_log("Error enabling Mux stream: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Create a Mux asset (for VOD/replay) from a live stream
     * @param string $muxStreamId Mux stream ID
     * @return array|null Asset details
     */
    public function createAssetFromStream($muxStreamId) {
        try {
            $response = $this->makeRequest(
                'POST',
                "/video/v1/live-streams/{$muxStreamId}/complete"
            );
            return $response['data'] ?? null;
        } catch (Exception $e) {
            error_log("Error creating asset from stream: " . $e->getMessage());
            return null;
        }
    }
    
    /**
     * Get playback URL for a stream or asset
     * @param string $playbackId Mux playback ID
     * @param string $type Type: 'hls' or 'thumbnail'
     * @return string Playback URL
     */
    public function getPlaybackUrl($playbackId, $type = 'hls') {
        if ($type === 'thumbnail') {
            return "https://image.mux.com/{$playbackId}/thumbnail.jpg?width=1280&height=720&time=0";
        }
        return "https://stream.mux.com/{$playbackId}.m3u8";
    }
    
    /**
     * Verify Mux webhook signature
     * @param string $payload Request body
     * @param string $signature Mux-Signature header value
     * @return bool Valid signature
     */
    public function verifyWebhookSignature($payload, $signature) {
        $secret = getenv('MUX_WEBHOOK_SECRET');
        if (empty($secret)) {
            error_log('MUX_WEBHOOK_SECRET not configured');
            return false;
        }
        
        // Parse signature header: t=timestamp,v1=signature
        $parts = [];
        foreach (explode(',', $signature) as $part) {
            list($key, $value) = explode('=', $part, 2);
            $parts[$key] = $value;
        }
        
        if (!isset($parts['t']) || !isset($parts['v1'])) {
            return false;
        }
        
        $timestamp = $parts['t'];
        $signedPayload = "{$timestamp}.{$payload}";
        $expectedSignature = hash_hmac('sha256', $signedPayload, $secret);
        
        return hash_equals($expectedSignature, $parts['v1']);
    }
    
    /**
     * Make HTTP request to Mux API
     * @param string $method HTTP method
     * @param string $endpoint API endpoint
     * @param array|null $data Request data
     * @return array Response data
     */
    private function makeRequest($method, $endpoint, $data = null) {
        $url = $this->apiBase . $endpoint;
        $auth = base64_encode("{$this->tokenId}:{$this->tokenSecret}");
        
        $headers = [
            "Authorization: Basic {$auth}",
            "Content-Type: application/json"
        ];
        
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
        
        if ($data !== null && in_array($method, ['POST', 'PUT', 'PATCH'])) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        
        if ($error) {
            throw new Exception("cURL error: {$error}");
        }
        
        if ($httpCode >= 400) {
            $errorData = json_decode($response, true);
            $errorMessage = $errorData['error']['message'] ?? 'Unknown Mux API error';
            throw new Exception("Mux API error ({$httpCode}): {$errorMessage}");
        }
        
        return json_decode($response, true);
    }
    
    /**
     * Save Mux stream data to database
     * @param int $streamId Local stream ID
     * @param array $muxData Mux stream data
     * @return bool Success status
     */
    public function saveMuxStreamData($streamId, $muxData) {
        try {
            $stmt = $this->db->prepare("
                UPDATE live_streams 
                SET mux_stream_id = ?,
                    mux_playback_id = ?,
                    stream_key = ?,
                    stream_url = ?,
                    updated_at = NOW()
                WHERE id = ?
            ");
            
            return $stmt->execute([
                $muxData['mux_stream_id'],
                $muxData['playback_id'],
                $muxData['stream_key'],
                $muxData['stream_url'],
                $streamId
            ]);
        } catch (Exception $e) {
            error_log("Error saving Mux stream data: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Get Mux stream data from database
     * @param int $streamId Local stream ID
     * @return array|null Mux stream data
     */
    public function getMuxStreamData($streamId) {
        try {
            $stmt = $this->db->prepare("
                SELECT mux_stream_id, mux_playback_id, stream_key, stream_url
                FROM live_streams
                WHERE id = ?
            ");
            $stmt->execute([$streamId]);
            return $stmt->fetch();
        } catch (Exception $e) {
            error_log("Error getting Mux stream data: " . $e->getMessage());
            return null;
        }
    }
}
