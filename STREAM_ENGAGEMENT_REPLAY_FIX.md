# Stream Engagement and Replay Fix - Implementation Guide

## Overview
This implementation fixes two critical issues with the live streaming functionality:
1. **Simulated Engagement Not Working** - Viewer and like counts not increasing during live streams
2. **Stream Replay Not Working** - Clicking archived streams doesn't play the video

## Issues Fixed

### Issue 1: Simulated Live Stream Engagement

**Problem:**
- Simulated viewers and likes remained at 0 after streams started
- Database tables were missing required columns (`is_fake`, `stream_viewers`, `stream_engagement_config`)

**Solution:**
1. Created migration `057_add_is_fake_to_stream_tables.php` that adds:
   - `is_fake` column to `stream_interactions` table
   - New `stream_viewers` table for tracking viewers
   - New `stream_engagement_config` table for per-stream engagement settings

2. The engagement system works as follows:
   - When a stream starts (`/api/streams/start.php`), initial fake viewers and likes are generated
   - Frontend polls `/api/streams/engagement.php` every 5-15 seconds
   - Each poll triggers fake engagement generation (viewers +1-5, likes +1-2)
   - Counts are updated in real-time on the UI
   - When stream ends, final counts are saved to the database

### Issue 2: Stream Replay Functionality

**Problem:**
- Clicking archived streams redirected to `live.php?stream={id}&replay=1` but nothing happened
- live.php didn't handle the `replay` parameter
- No UI existed for playing archived streams

**Solution:**
1. Modified `live.php` to:
   - Check for `replay` and `stream` GET parameters
   - Load archived stream data if in replay mode
   - Include the replay template instead of the live stream UI

2. Created `templates/stream-replay.php` that:
   - Displays a video player with the archived stream
   - Shows stream metadata (title, description, duration, stats)
   - Displays featured products from the stream
   - Has a "Back to Live" link to return to the main page

## Installation Steps

### 1. Run the Database Migration

```bash
# Navigate to project directory
cd /home/runner/work/edd/edd

# Run the engagement migration
php run_engagement_migration.php
```

Expected output:
```
=== Stream Engagement Tables Migration ===

Loading migration file...
Executing migration statements...

Executing: ALTER TABLE `stream_interactions` ADD COLUMN IF NOT EXISTS `is_fake`...
✅ Success

Executing: CREATE TABLE IF NOT EXISTS `stream_viewers`...
✅ Success

Executing: CREATE TABLE IF NOT EXISTS `stream_engagement_config`...
✅ Success

✅ Migration completed successfully!
Stream engagement tables are now ready:
  - stream_interactions now has is_fake column
  - stream_viewers table created
  - stream_engagement_config table created

Fake engagement should now work properly!
```

### 2. Validate the Installation

```bash
php validate_stream_engagement_system.php
```

This script checks:
- Database tables and columns exist
- Required PHP files are present
- Active and archived streams (if any)
- Fake engagement is working

### 3. Optional: Set Up Background Job (Recommended)

For automatic engagement updates without relying on frontend polling:

```bash
# Make the cron script executable
chmod +x scripts/fake-engagement-cron.sh

# Add to crontab (run every minute)
crontab -e

# Add this line:
* * * * * /path/to/edd/scripts/fake-engagement-cron.sh >> /var/log/fake-engagement.log 2>&1
```

## Testing the Fixes

### Test Simulated Engagement

1. **Start a Live Stream:**
   - Log in as an approved vendor
   - Navigate to Seller Dashboard → Live Streaming
   - Create and start a new stream

2. **Watch Engagement Increase:**
   - Open `/live.php` in a browser
   - Watch the viewer count increase every 5-15 seconds
   - Watch the like count increase periodically
   - Numbers should NOT stay at 0

3. **Manual API Test:**
   ```bash
   # Replace {stream_id} with actual stream ID
   curl http://localhost/api/streams/engagement.php?stream_id={stream_id}
   ```
   
   Expected response:
   ```json
   {
     "success": true,
     "stream_id": 1,
     "engagement": {
       "viewers_change": 3,
       "likes_added": 1
     },
     "current_stats": {
       "viewer_count": 18,
       "like_count": 5,
       "dislike_count": 0,
       "comment_count": 0,
       "max_viewers": 18
     }
   }
   ```

4. **End the Stream:**
   - End the stream from seller dashboard
   - Choose to "Save" the stream (not delete)
   - Verify final viewer and like counts are saved

### Test Stream Replay

1. **Access Archived Stream:**
   - Go to `/live.php`
   - Scroll to "Recent Streams" section
   - Click on any archived stream

2. **Verify Replay Page:**
   - Should redirect to `live.php?stream={id}&replay=1`
   - Should see a video player (if video_path exists)
   - Should see stream title, description, and stats
   - Should see featured products in sidebar

3. **Manual URL Test:**
   ```
   http://localhost/live.php?stream=4&replay=1
   ```
   
   Should display the replay template, not refresh the page.

## Configuration

### Engagement Settings

Default settings in `stream_engagement_config`:
- `min_fake_viewers`: 10
- `max_fake_viewers`: 50
- `viewer_increase_rate`: 5 (viewers added per increment)
- `viewer_decrease_rate`: 3 (natural churn)
- `like_rate`: 2 (likes added per increment)
- `engagement_multiplier`: 1.50 (multiplier for engagement)

These can be customized per-stream or globally in the `global_stream_settings` table.

## Files Changed/Created

### Modified Files:
- `live.php` - Added replay mode handling

### New Files:
- `templates/stream-replay.php` - Replay UI template
- `database/migrations/057_add_is_fake_to_stream_tables.php` - Migration for engagement tables
- `run_engagement_migration.php` - Migration runner script
- `validate_stream_engagement_system.php` - Validation script
- `STREAM_ENGAGEMENT_REPLAY_FIX.md` - This documentation

### Existing Files (No Changes Required):
- `api/live/fake-engagement.php` - Fake engagement generator
- `api/streams/engagement.php` - Engagement API endpoint
- `api/streams/start.php` - Stream start handler (already triggers initial engagement)
- `api/streams/end.php` - Stream end handler (already saves final counts)
- `scripts/fake-engagement-cron.sh` - Background job script

## Troubleshooting

### Engagement Numbers Stay at 0

**Check:**
1. Run `php validate_stream_engagement_system.php`
2. Check browser console for JavaScript errors
3. Verify `/api/streams/engagement.php?stream_id={id}` returns success
4. Check if `stream_viewers` and `stream_engagement_config` tables exist

**Fix:**
```bash
php run_engagement_migration.php
```

### Replay Shows "Video Not Available"

**Check:**
1. Verify stream has `status = 'archived'`
2. Verify stream has a `video_path` or `stream_url`
3. Check that video file exists at the specified path

**SQL Query:**
```sql
SELECT id, title, status, video_path, stream_url 
FROM live_streams 
WHERE status = 'archived';
```

### Foreign Key Errors During Migration

If you get foreign key constraint errors, the `live_streams` table might have a different ID type.

**Fix:**
Edit `057_add_is_fake_to_stream_tables.php` and change:
```php
`stream_id` INT NOT NULL,
```
to match your `live_streams.id` type (e.g., `BIGINT UNSIGNED`).

## API Endpoints

### Trigger Engagement (GET/POST)
```
GET /api/streams/engagement.php?stream_id={id}
```
Generates fake viewers and likes for a specific stream.

### Get Stream Status (GET)
```
GET /api/stream-status.php?stream_id={id}
```
Returns current status and viewer count for streams.

## Next Steps

After installation:
1. Monitor engagement during live streams
2. Check that numbers increase naturally
3. Verify stream replays work correctly
4. Adjust engagement settings if needed
5. Set up cron job for background updates (optional)

## Support

If issues persist:
1. Check logs: `/var/log/fake-engagement.log`
2. Run validation: `php validate_stream_engagement_system.php`
3. Check browser console for JavaScript errors
4. Verify database tables exist with correct schema
