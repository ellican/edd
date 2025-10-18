# Stream Engagement System Fix

## Problem

The stream engagement system validation was failing with the following errors:

```
❌ stream_viewers.session_id column is missing
❌ stream_viewers.is_fake column is missing
❌ stream_viewers.left_at column is missing
❌ stream_viewers.watch_duration column is missing
⚠️ Could not check for active streams: SQLSTATE[42S22]: Column not found: 1054 Unknown column 'sv.is_fake' in 'ON'
```

## Root Cause

The original migration file (`057_add_is_fake_to_stream_tables.php`) used MySQL syntax that is not compatible with MySQL 8.0:
- `ADD COLUMN IF NOT EXISTS` in `ALTER TABLE` statements is not supported
- This caused the `is_fake` column in `stream_interactions` table to not be created properly
- The validation script had a query that tried to JOIN on `is_fake` column before checking if the table/column exists

## Solution

### 1. Split the Migration

Created two separate migrations:
- **057_add_is_fake_to_stream_tables.php** - Creates `stream_viewers` and `stream_engagement_config` tables
- **058_add_is_fake_to_stream_interactions.php** - Adds `is_fake` column to `stream_interactions` table

### 2. New Migration Runner

Created `run_stream_engagement_fix.php` - A new script that:
- Executes both migrations in the correct order
- Has better error handling for duplicate column/table errors
- Provides clear success/failure messages

### 3. Updated Validation Script

Fixed `validate_stream_engagement_system.php` to:
- Check if table exists before querying it
- Check if columns exist before using them in JOIN clauses
- Provide better error messages

## How to Use

### Step 1: Run the Fixed Migration

```bash
cd ~/public_html
php run_stream_engagement_fix.php
```

Expected output:
```
=== Stream Engagement Tables Fix Migration ===

Step 1: Creating stream_viewers and stream_engagement_config tables...
  Executing: CREATE TABLE IF NOT EXISTS `stream_viewers` ...
  ✅ Success
  Executing: CREATE TABLE IF NOT EXISTS `stream_engagement_config` ...
  ✅ Success
  ✅ Stream viewers and config tables migration completed

Step 2: Adding is_fake column to stream_interactions...
  Executing: ALTER TABLE `stream_interactions` ADD COLUMN `is_fake` ...
  ✅ Success
  ✅ Stream interactions is_fake column migration completed

✅ All migrations completed successfully!

Stream engagement tables are now ready:
  ✅ stream_viewers table created with all columns:
     - id, stream_id, user_id, session_id
     - is_fake, joined_at, left_at, watch_duration
  ✅ stream_engagement_config table created
  ✅ stream_interactions.is_fake column added

You can now run: php validate_stream_engagement_system.php
```

### Step 2: Validate the Installation

```bash
php validate_stream_engagement_system.php
```

Expected output (all checks should pass):
```
=== Stream Engagement System Validation ===

1. Checking stream_interactions table...
2. Checking stream_viewers table...
3. Checking stream_engagement_config table...
4. Checking fake engagement scripts...
5. Checking for active streams...
6. Checking stream replay functionality...

=== Validation Results ===

Successes:
✅ stream_interactions.is_fake column exists
✅ stream_viewers table exists
  ✅ stream_viewers.id column exists
  ✅ stream_viewers.stream_id column exists
  ✅ stream_viewers.user_id column exists
  ✅ stream_viewers.session_id column exists
  ✅ stream_viewers.is_fake column exists
  ✅ stream_viewers.joined_at column exists
  ✅ stream_viewers.left_at column exists
  ✅ stream_viewers.watch_duration column exists
✅ stream_engagement_config table exists
✅ api/live/fake-engagement.php exists
✅ api/streams/engagement.php exists
✅ scripts/fake-engagement-cron.sh exists

✅ All critical checks passed!
```

## Features

### Automatic Engagement During Streams

When a seller starts a live stream, the engagement system will automatically:

1. **Increase Viewer Count** - Fake viewers gradually join and leave the stream
2. **Add Likes** - Automatic likes are added at a configured rate
3. **Show Activity** - Both in the viewer's view and seller's stats area

### Configuration

The engagement is configured per-stream in the `stream_engagement_config` table with these settings:

- `min_fake_viewers` - Minimum number of fake viewers (default: 10)
- `max_fake_viewers` - Maximum number of fake viewers (default: 50)
- `viewer_increase_rate` - Viewers added per increment (default: 5)
- `viewer_decrease_rate` - Viewers removed per increment (default: 3)
- `like_rate` - Likes added per increment (default: 2)
- `engagement_multiplier` - Engagement boost multiplier (default: 1.50)

### Stream Management Features

Sellers can manage their streams from the seller dashboard (`/seller/streams.php`):

1. **View Recent Streams** - See all archived streams
2. **Delete Streams** - Remove unwanted stream recordings
3. **Watch Replays** - View recorded streams
4. **View Stats** - See viewer counts, likes, and engagement metrics

### Stream Replay

When users click to replay a recent stream, it will:

1. Load the stream from the database with status 'archived'
2. Display the video player with the recorded stream URL
3. Show all stats from the original stream (viewers, likes, comments)
4. Allow viewers to watch the complete recording

The replay is accessed via: `/live.php?replay=1&stream=<stream_id>`

## Testing

### Test Automatic Engagement

1. Start a live stream from the seller dashboard
2. Wait 30-60 seconds
3. Check the stream stats - you should see:
   - Viewer count increasing
   - Likes being added
   - Both visible to viewers and in seller stats

### Test Stream Management

1. Go to `/seller/streams.php`
2. You should see sections for:
   - Active Streams (currently live)
   - Scheduled Streams (upcoming)
   - Recent Streams (archived)
3. Click the delete button on an archived stream to remove it
4. Click "Watch Recording" to replay a stream

### Test Stream Replay

1. End a live stream from the seller dashboard
2. The stream should be automatically archived
3. Go to `/live.php`
4. Click on a recent stream in the "Recent Streams" section
5. The replay should load and play automatically

## Troubleshooting

### Issue: Migration fails with "Duplicate column" error

This is normal if you've run the migration before. The script will skip existing columns/tables and continue.

### Issue: Validation still shows missing columns

Run the migration again:
```bash
php run_stream_engagement_fix.php
```

Then validate:
```bash
php validate_stream_engagement_system.php
```

### Issue: Engagement not working during stream

1. Check if the cron job is running:
   ```bash
   crontab -l | grep fake-engagement
   ```

2. Manually trigger engagement for a stream:
   ```bash
   curl http://localhost/api/streams/engagement.php?stream_id=<stream_id>
   ```

3. Check the stream_engagement_config table:
   ```sql
   SELECT * FROM stream_engagement_config WHERE stream_id = <stream_id>;
   ```

### Issue: Stream replay shows "Video Not Available"

Check if the stream has a video path:
```sql
SELECT id, title, video_path, stream_url, status 
FROM live_streams 
WHERE status = 'archived';
```

The stream needs either `video_path` or `stream_url` set to play the replay.

## Files Modified

1. **database/migrations/057_add_is_fake_to_stream_tables.php** - Removed problematic ALTER TABLE statements
2. **database/migrations/058_add_is_fake_to_stream_interactions.php** - New migration for is_fake column
3. **run_stream_engagement_fix.php** - New migration runner script
4. **validate_stream_engagement_system.php** - Fixed validation logic to handle missing tables/columns

## Next Steps

After running the migration successfully:

1. ✅ Start a live stream to test engagement
2. ✅ Verify viewer and like counts increase automatically
3. ✅ End the stream and test replay functionality
4. ✅ Use seller dashboard to manage stream recordings
5. ✅ Set up the cron job for automatic engagement:
   ```bash
   # Add to crontab
   * * * * * /bin/bash /path/to/public_html/scripts/fake-engagement-cron.sh
   ```

## Support

If you continue to have issues:

1. Check the error logs: `tail -f /var/log/apache2/error.log` (or your web server's error log)
2. Check the database directly to verify tables exist
3. Make sure the web server has proper permissions
4. Ensure PHP can connect to the database
