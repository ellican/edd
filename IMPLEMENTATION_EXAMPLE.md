# Mux Live Streaming Implementation Example

This document provides code examples and usage patterns for the Mux live streaming integration.

## Table of Contents
1. [Environment Setup](#environment-setup)
2. [Seller Workflow](#seller-workflow)
3. [Viewer Experience](#viewer-experience)
4. [Stream Management](#stream-management)
5. [Testing](#testing)

## Environment Setup

### 1. Configure .env File

```env
# Mux Live Streaming Configuration
MUX_TOKEN_ID=7a3b9c4d-5e6f-4a8b-9c0d-1e2f3a4b5c6d
MUX_TOKEN_SECRET=S3cr3tK3yTh4tY0uG3tFr0mMux/D4shb04rd+K33pItS4f3
MUX_ENVIRONMENT_KEY=env_abc123xyz789
MUX_WEBHOOK_SECRET=whsec_abc123xyz789def456
```

### 2. Run Database Migration

```bash
php database/migrations/add_mux_fields_to_live_streams.php
```

Expected output:
```
Adding Mux-specific fields to live_streams table...
✓ Added mux_stream_id column
✓ Added mux_playback_id column
✓ Added index on mux_stream_id

✅ Migration completed successfully!
```

### 3. Verify Integration

Test Mux API connection:

```php
<?php
require_once 'includes/init.php';
require_once 'includes/MuxStreamService.php';

try {
    $muxService = new MuxStreamService();
    echo "✅ Mux service initialized successfully\n";
    
    // Test creating a stream (optional - will create a real stream)
    // $stream = $muxService->createLiveStream();
    // echo "Stream created: " . $stream['mux_stream_id'] . "\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
```

## Seller Workflow

### Step 1: Create Live Stream

**UI Flow** (`/seller/live.php`):
```javascript
// User clicks "Go Live"
function startLiveStream() {
    const title = prompt('Enter stream title:');
    const description = prompt('Enter description:');
    
    fetch('/api/streams/create-mux.php', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            title: title,
            description: description,
            chat_enabled: 1
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            showRTMPCredentials(result);
        }
    });
}
```

**API Response** (`/api/streams/create-mux.php`):
```json
{
  "success": true,
  "stream_id": 123,
  "stream": {
    "id": 123,
    "title": "Product Launch Event",
    "status": "scheduled",
    "mux_stream_id": "abc123xyz",
    "mux_playback_id": "def456uvw"
  },
  "rtmp_credentials": {
    "rtmp_url": "rtmps://global-live.mux.com:443/app",
    "stream_key": "9a8b7c6d5e4f3a2b1c0d"
  },
  "playback_url": "https://stream.mux.com/def456uvw.m3u8",
  "instructions": {
    "obs": {
      "server": "rtmps://global-live.mux.com:443/app",
      "stream_key": "9a8b7c6d5e4f3a2b1c0d"
    }
  }
}
```

### Step 2: Configure OBS Studio

**Settings → Stream:**
- Service: `Custom`
- Server: `rtmps://global-live.mux.com:443/app`
- Stream Key: `9a8b7c6d5e4f3a2b1c0d` (from API response)

**Settings → Output:**
- Output Mode: `Advanced`
- Encoder: `x264` or `NVENC H.264`
- Rate Control: `CBR`
- Bitrate: `3000-6000 Kbps`

**Settings → Video:**
- Base Resolution: `1920x1080`
- Output Resolution: `1280x720`
- FPS: `30`

### Step 3: Start Broadcasting

1. Click "Start Streaming" in OBS
2. Stream goes live within 5-10 seconds
3. Status in database updates to "live"
4. Viewers can now watch at `/live.php`

### Step 4: End Stream

```javascript
// Seller clicks "End Stream"
function endStream(streamId) {
    fetch('/api/streams/end.php', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            stream_id: streamId,
            action: 'save' // or 'delete'
        })
    })
    .then(response => response.json())
    .then(result => {
        console.log('Stream ended:', result.stats);
    });
}
```

## Viewer Experience

### Live Streaming Page (`/live.php`)

**HTML Structure:**
```html
<!-- Video.js CSS -->
<link href="https://vjs.zencdn.net/8.6.1/video-js.css" rel="stylesheet" />

<!-- Mux environment key for analytics -->
<meta name="mux-env-key" content="env_abc123xyz789">

<!-- Video container -->
<div id="liveVideoPlayer-123" class="live-video-player"></div>

<!-- Video.js and Mux Data SDK -->
<script src="https://vjs.zencdn.net/8.6.1/video.min.js"></script>
<script src="https://src.litix.io/videojs/3/videojs-mux.js"></script>
<script src="/js/live-stream-player.js"></script>
```

**JavaScript Initialization:**
```javascript
// Initialize player
const player = new LiveStreamPlayer('liveVideoPlayer-123', 123);
player.init();

// Monitor stream status
player.monitorStreamStatus();

// Cleanup on page unload
window.addEventListener('beforeunload', () => {
    player.destroy();
});
```

### Player Features

**Automatic Quality Adjustment:**
- HLS adaptive streaming
- Switches between quality levels based on bandwidth
- Smooth playback without buffering

**Mobile Support:**
- Responsive design
- Autoplay with muted attribute
- Picture-in-picture support
- iOS and Android compatible

**Analytics Tracking:**
```javascript
// Mux Data SDK automatically tracks:
{
  env_key: 'env_abc123xyz789',
  player_name: 'FezaMarket Live Player',
  video_id: 'stream-123',
  video_title: 'Product Launch Event',
  video_stream_type: 'live',
  viewer_user_id: 'user-456',
  
  // Tracked events:
  // - play, pause, ended
  // - buffering, rebuffering
  // - quality changes
  // - errors and warnings
  // - watch time and completion
}
```

## Stream Management

### List Streams (`/seller/streams.php`)

```php
<?php
$db = db();

// Get all streams for vendor
$stmt = $db->prepare("
    SELECT * FROM live_streams
    WHERE vendor_id = ?
    ORDER BY created_at DESC
");
$stmt->execute([$vendorId]);
$streams = $stmt->fetchAll();

foreach ($streams as $stream) {
    echo "Stream: " . $stream['title'] . "\n";
    echo "Status: " . $stream['status'] . "\n";
    
    if ($stream['mux_playback_id']) {
        echo "Playback URL: https://stream.mux.com/{$stream['mux_playback_id']}.m3u8\n";
    }
    
    if ($stream['status'] === 'archived') {
        echo "Replay available: Yes\n";
    }
}
?>
```

### Delete Stream

```javascript
function deleteStream(streamId) {
    if (!confirm('Delete this stream? This cannot be undone.')) {
        return;
    }
    
    fetch('/api/streams/delete.php', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({stream_id: streamId})
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            alert('Stream deleted successfully');
            location.reload();
        }
    });
}
```

### Update Stream Title

```javascript
function updateStreamTitle(streamId) {
    const newTitle = prompt('Enter new title:');
    if (!newTitle) return;
    
    fetch('/api/streams/update.php', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            stream_id: streamId,
            title: newTitle
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            alert('Title updated');
            location.reload();
        }
    });
}
```

## Testing

### 1. Test Stream Creation

```bash
curl -X POST https://yourdomain.com/api/streams/create-mux.php \
  -H "Content-Type: application/json" \
  -H "Cookie: PHPSESSID=your_session_id" \
  -d '{
    "title": "Test Stream",
    "description": "Testing Mux integration",
    "chat_enabled": 1
  }'
```

### 2. Test HLS Playback

Open in VLC or browser:
```
https://stream.mux.com/{playback_id}.m3u8
```

### 3. Test Analytics

Check Mux dashboard:
```
https://dashboard.mux.com/data
```

### 4. Test Stream End

```bash
curl -X POST https://yourdomain.com/api/streams/end.php \
  -H "Content-Type: application/json" \
  -H "Cookie: PHPSESSID=your_session_id" \
  -d '{
    "stream_id": 123,
    "action": "save"
  }'
```

### 5. Test Replay

After ending stream, open same playback URL:
```
https://stream.mux.com/{playback_id}.m3u8
```

Should now serve recorded stream.

## Common Scenarios

### Scenario 1: Seller Goes Live

1. Seller creates stream via `/seller/live.php`
2. Gets RTMP credentials
3. Configures OBS with credentials
4. Starts streaming in OBS
5. Stream appears live on `/live.php`
6. Viewers can watch and interact

### Scenario 2: Stream Replay

1. Seller ends stream
2. System marks as "archived"
3. Mux creates replay asset automatically
4. Same playback URL now serves replay
5. Viewers can watch on-demand

### Scenario 3: Stream Deletion

1. Seller views streams in `/seller/streams.php`
2. Clicks delete on archived stream
3. System calls Mux API to delete
4. Removes from database
5. Stream and replay no longer accessible

## Error Handling

### Stream Creation Fails

```javascript
fetch('/api/streams/create-mux.php', {...})
  .then(response => response.json())
  .then(result => {
    if (!result.success) {
      alert('Error: ' + result.error);
      // Common errors:
      // - "Mux API credentials not configured"
      // - "You already have an active stream"
      // - "Approved vendor access required"
    }
  })
  .catch(error => {
    alert('Network error. Please try again.');
  });
```

### Playback Fails

```javascript
player.on('error', () => {
  const error = player.error();
  console.error('Playback error:', error);
  
  if (error.code === 4) {
    // Media not supported or not found
    showError('Stream not available');
  } else {
    // Network or other error
    retryStream();
  }
});
```

## Performance Optimization

### Reduce Latency

```php
$muxService->createLiveStream([
    'reduced_latency' => true,  // Enable low-latency mode
    'reconnect_window' => 60     // 60 second reconnect window
]);
```

### Optimize Video Quality

**OBS Settings:**
- Bitrate: 3000-6000 Kbps (higher = better quality, requires more bandwidth)
- Resolution: 1280x720 (good balance of quality and performance)
- FPS: 30 (60 for fast-motion content)
- Keyframe interval: 2 seconds

### Optimize Player

```javascript
videojs('player', {
    liveui: true,              // Optimize for live content
    preload: 'auto',           // Preload video
    html5: {
        vhs: {
            overrideNative: true,  // Use VHS player
            enableLowInitialPlaylist: true
        }
    }
});
```

## Monitoring

### Check Stream Status

```php
$muxService = new MuxStreamService();
$details = $muxService->getStreamDetails($muxStreamId);

echo "Status: " . $details['status'] . "\n";
echo "Recent Assets: " . count($details['recent_asset_ids']) . "\n";
```

### View Analytics

Mux Dashboard: https://dashboard.mux.com/data

Metrics available:
- Total plays
- Unique viewers
- Average watch time
- Buffering ratio
- Video startup time
- Error rate

## Support

For issues:
1. Check browser console for errors
2. Check PHP error logs
3. Verify Mux credentials in `.env`
4. Test HLS URL in VLC player
5. Review Mux dashboard for stream status

Contact:
- Mux Support: https://mux.com/support
- Platform Issues: Open GitHub issue
