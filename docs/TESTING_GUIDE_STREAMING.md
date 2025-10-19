# Live Streaming Testing Guide

This guide provides comprehensive testing procedures for the live streaming feature enhancements.

## Overview

Test the following components:
1. HLS Playback with retry logic
2. Engagement timing (after stream is playable)
3. Duration calculation and SQL storage
4. Seller stream management page
5. API endpoints

## Prerequisites

- PHP 7.4+
- MySQL/MariaDB database
- Modern web browser (Chrome, Firefox, or Safari)
- HLS streaming server configured (see HLS_STREAMING_SETUP.md)

## Test Environment Setup

1. **Database Setup**
   ```bash
   # Run migration to update duration_seconds column
   php /path/to/run_migration.php 059
   ```

2. **Verify Column Type**
   ```sql
   DESCRIBE live_streams;
   -- Verify duration_seconds is BIGINT UNSIGNED
   ```

3. **Create Test Data**
   ```sql
   -- Insert a test stream
   INSERT INTO live_streams (vendor_id, stream_key, title, status, started_at)
   VALUES (1, 'test_stream_key', 'Test Stream', 'live', NOW());
   ```

## Test Cases

### 1. HLS Playback - "Unable to Load Stream" Fix

#### Test 1.1: Stream Not Yet Available
**Steps:**
1. Navigate to `/live.php` when no stream is live
2. Observe the player behavior

**Expected Results:**
- ✅ Shows "Waiting for stream to start..." message
- ✅ Shows retry attempt counter (1/12, 2/12, etc.)
- ✅ Shows loading spinner
- ✅ Retries every 5 seconds
- ✅ After 12 attempts (1 minute), shows error message

**Console Output:**
```
🎬 Initializing live stream player for stream: 1
⚠️ Stream data not available, starting retry mechanism
🔄 Retry attempt 1/12 in 5 seconds...
```

#### Test 1.2: Stream Becomes Available During Retry
**Steps:**
1. Start with no stream available (shows waiting message)
2. Start a live stream with valid HLS URL
3. Wait for next retry (within 5 seconds)

**Expected Results:**
- ✅ Player detects stream is available
- ✅ Loads HLS manifest successfully
- ✅ Shows "HLS manifest parsed successfully"
- ✅ Video starts playing
- ✅ Waiting message is replaced with video player

**Console Output:**
```
✅ Stream is now available, initializing player
🎥 Initializing HLS player for .m3u8 stream
✅ HLS manifest parsed successfully, stream is playable
```

#### Test 1.3: Network Error During Playback
**Steps:**
1. Start playing a live stream
2. Temporarily disconnect network or block HLS URLs
3. Reconnect network

**Expected Results:**
- ✅ Shows "Fatal network error, trying to recover..."
- ✅ Attempts to recover automatically
- ✅ Resumes playback when network is restored
- ✅ Does NOT destroy player prematurely

#### Test 1.4: CORS Configuration
**Steps:**
1. Open browser DevTools Network tab
2. Start a live stream
3. Inspect .m3u8 and .ts file requests

**Expected Results:**
- ✅ Response headers include `Access-Control-Allow-Origin: *`
- ✅ No CORS errors in console
- ✅ All segments load successfully

**Test with curl:**
```bash
curl -I -H "Origin: https://yourdomain.com" \
  https://yourdomain.com/streams/hls/test_stream/playlist.m3u8
```

### 2. Engagement Timing Fix

#### Test 2.1: Engagement Starts ONLY After Playback
**Steps:**
1. Navigate to a live stream page
2. Monitor console for engagement messages
3. Note the timing of when engagement starts

**Expected Results:**
- ✅ Engagement does NOT start when page loads
- ✅ Engagement does NOT start during "Waiting for stream" state
- ✅ Engagement ONLY starts after "HLS manifest parsed successfully"
- ✅ Viewer engagement starts 10 seconds after playback begins
- ✅ Like engagement starts 30 seconds after playback begins

**Console Output:**
```
✅ HLS manifest parsed successfully, stream is playable
🎯 Starting engagement timers (after stream is playable)
👥 Viewer engagement started (10 seconds after playback)
👍 Like engagement started (30 seconds after playback)
```

#### Test 2.2: Randomized Intervals
**Steps:**
1. Start a live stream
2. Monitor engagement updates for 2 minutes
3. Note the intervals between updates

**Expected Results:**
- ✅ Intervals vary between 5-13 seconds
- ✅ Not all intervals are the same
- ✅ Average interval is around 9 seconds
- ✅ Updates appear natural, not robotic

#### Test 2.3: Engagement Stops on Stream End
**Steps:**
1. Start a live stream with engagement running
2. End the stream from seller interface
3. Monitor console for cleanup messages

**Expected Results:**
- ✅ Shows "Stream has ended, stopping engagement and playback"
- ✅ Shows "Cleaning up player resources"
- ✅ All timers are cleared
- ✅ Shows "Stream Has Ended" UI
- ✅ No more engagement updates occur

**Console Output:**
```
📡 Stream has ended, stopping engagement and playback
🧹 Cleaning up player resources
⚠️ Stopping viewer updates - stream not playable
⚠️ Stopping like updates - stream not playable
```

#### Test 2.4: Page Visibility
**Steps:**
1. Start a live stream with engagement
2. Switch to another tab
3. Switch back to stream tab
4. Close the tab

**Expected Results:**
- ✅ On tab switch: "Page hidden, pausing engagement updates"
- ✅ On tab return: "Page visible, resuming normal operation"
- ✅ On tab close: Player cleanup happens
- ✅ Viewer is marked as left

### 3. Duration Calculation and SQL Storage

#### Test 3.1: Normal Duration (< 1 hour)
**Steps:**
1. Start a live stream
2. Stream for 30 minutes
3. End and save the stream
4. Check database

**Expected Results:**
- ✅ Stream ends successfully
- ✅ Duration is calculated correctly (1800 seconds)
- ✅ No SQL errors
- ✅ duration_seconds column is populated

**SQL Check:**
```sql
SELECT id, title, duration_seconds, 
       TIMESTAMPDIFF(SECOND, started_at, ended_at) as calculated_duration
FROM live_streams 
WHERE id = ?;
```

#### Test 3.2: Long Duration (24+ hours)
**Steps:**
1. Manually update a stream's started_at to 25 hours ago
2. End the stream
3. Check the saved duration

**Expected Results:**
- ✅ Duration is clamped to max (48 hours = 172800 seconds)
- ✅ Warning logged: "Stream X duration exceeded maximum"
- ✅ No SQL overflow error
- ✅ Stream saves successfully

**Check Logs:**
```bash
tail -f /var/log/apache2/error.log | grep "duration exceeded"
```

#### Test 3.3: Negative Duration (Clock Skew)
**Steps:**
1. Create a stream with ended_at before started_at
2. Attempt to end the stream

**Expected Results:**
- ✅ Duration is clamped to 0 (minimum)
- ✅ No negative values stored
- ✅ Stream saves without error

#### Test 3.4: SQL Exception Handling
**Steps:**
1. Temporarily change duration_seconds to INT (to force overflow)
2. Try to save a very long stream
3. Check error handling

**Expected Results:**
- ✅ Proper error message returned
- ✅ Error logged with duration value
- ✅ No partial data saved
- ✅ User sees "Database error" message

### 4. Seller Stream Management Page

#### Test 4.1: Active Streams Section
**Steps:**
1. Login as a vendor
2. Navigate to `/seller/streams.php`
3. Start a live stream
4. Refresh the streams page

**Expected Results:**
- ✅ Active stream appears in "Active Streams" section
- ✅ Shows live badge (🔴 LIVE)
- ✅ Shows current viewer count
- ✅ Shows stream duration timer
- ✅ "View Stream" button works
- ✅ "Stop Stream" button shows modal with options

#### Test 4.2: Scheduled Streams Section
**Steps:**
1. Create a scheduled stream for future date
2. View streams management page

**Expected Results:**
- ✅ Scheduled stream appears in "Scheduled Streams"
- ✅ Shows scheduled badge (📅 SCHEDULED)
- ✅ Shows time until stream starts
- ✅ Shows scheduled date/time
- ✅ "Start Now" button works
- ✅ "Edit" button allows renaming
- ✅ "Cancel" button shows confirmation modal

#### Test 4.3: Archived Streams Section
**Steps:**
1. End a stream and save it
2. View streams management page

**Expected Results:**
- ✅ Archived stream appears in "Recent Streams"
- ✅ Shows archived badge (📼 ARCHIVED)
- ✅ Shows total viewers
- ✅ Shows total likes
- ✅ Shows total comments
- ✅ Shows revenue
- ✅ "Watch Recording" button works (if video_path exists)
- ✅ "Delete" button shows confirmation modal

#### Test 4.4: Stop Stream Modal
**Steps:**
1. Click "Stop Stream" on an active stream
2. Test both "Save & Stop" and "Delete & Stop" options

**Expected Results:**
- ✅ Modal appears with two options
- ✅ "Save & Stop" archives the stream with video_path
- ✅ "Delete & Stop" ends without archiving
- ✅ Success notification appears
- ✅ Page refreshes to show updated state
- ✅ Stream moves from Active to Archived (if saved)

#### Test 4.5: Delete Recording
**Steps:**
1. Click "Delete" on an archived stream
2. Confirm deletion
3. Check filesystem

**Expected Results:**
- ✅ Confirmation modal appears
- ✅ On confirm, stream is removed from database
- ✅ Video file is deleted from filesystem
- ✅ Success notification shows
- ✅ Stream is removed from list without page refresh
- ✅ Log entry shows deletion

**Check Deletion:**
```bash
# Before delete
ls -la /var/www/uploads/streams/1/

# After delete - file should be gone
ls -la /var/www/uploads/streams/1/
```

#### Test 4.6: Auto-Refresh Active Streams
**Steps:**
1. Keep streams page open
2. Start a stream from another browser/device
3. Wait 10 seconds

**Expected Results:**
- ✅ Active streams section updates automatically
- ✅ New stream appears without manual refresh
- ✅ Count badge updates

### 5. API Endpoint Testing

#### Test 5.1: GET /api/streams/get.php
```bash
# Test getting stream details
curl -H "Content-Type: application/json" \
  "http://localhost/api/streams/get.php?stream_id=1"
```

**Expected Response:**
```json
{
  "success": true,
  "stream": {
    "id": 1,
    "title": "Test Stream",
    "status": "live",
    "stream_url": "/streams/hls/stream_key/playlist.m3u8",
    "is_live": true,
    ...
  },
  "stream_url": "/streams/hls/stream_key/playlist.m3u8",
  "is_live": true
}
```

#### Test 5.2: POST /api/streams/end.php
```bash
# Test ending a stream
curl -X POST -H "Content-Type: application/json" \
  -d '{"stream_id": 1, "action": "save"}' \
  -b "session_cookie=..." \
  "http://localhost/api/streams/end.php"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Stream ended and saved successfully",
  "action": "save",
  "stats": {
    "duration": 1800,
    "viewers": 150,
    "likes": 45,
    ...
  }
}
```

#### Test 5.3: GET /api/streams/list.php
```bash
# Test listing streams by type
curl "http://localhost/api/streams/list.php?type=live&limit=10"
curl "http://localhost/api/streams/list.php?type=scheduled"
curl "http://localhost/api/streams/list.php?type=archived"
```

#### Test 5.4: POST /api/streams/update.php
```bash
# Test updating stream title
curl -X POST -H "Content-Type: application/json" \
  -d '{"stream_id": 1, "title": "New Title"}' \
  -b "session_cookie=..." \
  "http://localhost/api/streams/update.php"
```

#### Test 5.5: POST /api/streams/delete.php
```bash
# Test deleting archived stream
curl -X POST -H "Content-Type: application/json" \
  -d '{"stream_id": 1}' \
  -b "session_cookie=..." \
  "http://localhost/api/streams/delete.php"
```

## Browser Compatibility Testing

### Chrome
- [ ] HLS playback with hls.js
- [ ] Engagement timing
- [ ] Modal interactions
- [ ] Console messages

### Firefox
- [ ] HLS playback with hls.js
- [ ] Engagement timing
- [ ] Modal interactions
- [ ] Console messages

### Safari
- [ ] Native HLS playback
- [ ] Engagement timing (after native loadedmetadata)
- [ ] Modal interactions
- [ ] Console messages

## Performance Testing

### Load Testing
1. Simulate 100+ concurrent viewers
2. Monitor server resources (CPU, memory, disk I/O)
3. Check HLS segment delivery times
4. Monitor database query performance

### Stress Testing
1. Run a 12+ hour continuous stream
2. Monitor memory leaks in player
3. Check engagement update frequency
4. Verify no resource exhaustion

## Common Issues and Solutions

### Issue: Stream URL is null
**Cause:** Stream key not set or HLS directory not configured
**Solution:** Ensure stream has valid stream_key and HLS path exists

### Issue: Engagement starts before playback
**Cause:** Old code without MANIFEST_PARSED check
**Solution:** Verify using latest live-stream-player.js

### Issue: Duration overflow SQL error
**Cause:** duration_seconds column is INT instead of BIGINT
**Solution:** Run migration 059 to update column type

### Issue: Video file not deleted
**Cause:** Incorrect file path or permissions
**Solution:** Check error logs for file path and verify web server has write permissions

## Reporting Issues

When reporting issues, include:
1. Browser and version
2. Console output (full log)
3. Network tab (for HLS requests)
4. Steps to reproduce
5. Expected vs actual behavior
6. Database state (relevant tables)

## Success Criteria

All tests must pass:
- ✅ HLS playback works without "Unable to Load Stream" error
- ✅ Engagement starts ONLY after stream is playable
- ✅ Duration saves without SQL overflow errors
- ✅ Seller management page displays all sections correctly
- ✅ All API endpoints return expected responses
- ✅ Works across Chrome, Firefox, and Safari
- ✅ No console errors
- ✅ No memory leaks during long streams
- ✅ File deletion works correctly
