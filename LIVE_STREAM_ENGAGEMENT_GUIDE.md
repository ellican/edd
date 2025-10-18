# Live Stream Engagement System - Implementation Guide

## Overview
This implementation adds simulated real-time engagement to live streams, addressing the critical `stream_key` SQL error and providing an enhanced viewer experience with realistic engagement metrics.

## Critical Fixes Implemented

### 1. Stream Key SQL Error Fix
**Problem**: Field 'stream_key' doesn't have a default value
**Solution**: 
- Added migration `20251018_add_stream_key_to_live_streams.sql`
- Updated `LiveStream` model with `generateStreamKey()` method
- Modified `api/streams/start.php` to auto-generate unique stream keys
- Created migration runner script `run_stream_key_migration.php`

**How to Apply**:
```bash
php run_stream_key_migration.php
```

### 2. Simulated Engagement System

#### Features Implemented:
1. ✅ Random viewer count initialization and growth
2. ✅ Random like count increments
3. ✅ Real-time updates on seller interface (every 5 seconds)
4. ✅ Real-time updates on public viewing page (every 10 seconds)
5. ✅ Real user engagement adds to simulated numbers
6. ✅ Final counts stored in database when stream ends
7. ✅ Admin configuration panel for engagement settings

## System Architecture

### Database Tables

#### `live_streams`
Enhanced with:
- `stream_key` VARCHAR(128) UNIQUE NOT NULL - Auto-generated unique identifier
- `like_count` INT - Total likes
- `dislike_count` INT - Total dislikes  
- `comment_count` INT - Total comments
- `viewer_count` INT - Current viewers

#### `stream_engagement_config`
Per-stream configuration:
- `fake_viewers_enabled` - Enable/disable simulated viewers
- `fake_likes_enabled` - Enable/disable simulated likes
- `min_fake_viewers` - Minimum simulated viewer count (default: 15)
- `max_fake_viewers` - Maximum simulated viewer count (default: 100)
- `viewer_increase_rate` - Viewers added per minute (default: 5)
- `viewer_decrease_rate` - Viewers leaving per minute (default: 3)
- `like_rate` - Likes added per minute (default: 3)
- `engagement_multiplier` - Multiplier for fake viewers based on real viewers (default: 2.0)

#### `global_stream_settings`
Global defaults for new streams:
- All stream quality settings
- Default engagement configuration
- RTMP server settings

### API Endpoints

#### Stream Management
- `POST /api/streams/start.php` - Start a live stream (now generates stream_key)
- `POST /api/streams/end.php` - End a live stream
- `GET /api/streams/engagement.php?stream_id={id}` - Trigger engagement update

#### Admin Configuration
- `GET /api/admin/streams/get-settings.php` - Get current global settings
- `POST /api/admin/streams/save-settings.php` - Save global settings

#### Live Updates
- `GET /api/live/stats.php?stream_id={id}` - Get stream statistics
- `GET /api/live/viewers.php?stream_id={id}` - Get current viewers

## Engagement Algorithm

### Viewer Count Simulation
1. Calculate target fake viewers: `max(min_fake_viewers, min(max_fake_viewers, real_viewers × multiplier))`
2. If current < target: Add random(1, viewer_increase_rate) viewers
3. If current > target: Remove random(1, viewer_decrease_rate) viewers
4. Simulate natural churn with random joins/leaves

### Like Count Simulation
1. Calculate like probability based on engagement multiplier
2. For each minute, add 0-like_rate likes randomly
3. Probability: 10% × engagement_multiplier

### Real User Integration
- Real user actions (likes, comments, views) are stored separately
- Display counts = real + simulated
- When stream ends, final counts (real + simulated) are stored permanently

## Admin Panel Usage

### Accessing Configuration
1. Navigate to `/admin/streaming/`
2. Click "Stream Settings" button
3. Scroll to "Engagement Simulation Settings" section

### Configuration Options

**Enable Simulated Viewers**
- Toggle ON/OFF for all new streams
- When enabled, shows min/max and rate settings

**Viewer Settings**
- **Minimum Simulated Viewers**: Starting baseline (e.g., 15)
- **Maximum Simulated Viewers**: Upper limit (e.g., 100)
- **Increase Rate**: How fast viewers join (per minute)
- **Decrease Rate**: How fast viewers leave (per minute)

**Enable Simulated Likes**
- Toggle ON/OFF for like simulation
- **Like Rate**: Average likes per minute

**Engagement Multiplier**
- Controls ratio of fake to real viewers
- Formula: `fake_viewers = real_viewers × multiplier`
- Range: 0.5 - 10.0
- Default: 2.0 (2x real viewers)

### Best Practices

1. **Start Conservative**: Begin with lower numbers and adjust based on results
2. **Test First**: Try settings on a test stream before going live
3. **Monitor Analytics**: Check viewer retention and engagement metrics
4. **Gradual Growth**: Use lower increase rates for more organic growth
5. **Balance**: Keep multiplier between 1.5-3.0 for realistic appearance

## Real-Time Updates

### Seller Interface (`/seller/stream-interface.php`)
- Updates every 5 seconds
- Shows:
  - Current viewer count
  - Likes/dislikes
  - Comments count
  - Orders and revenue
  - Live viewer list
  - Real-time comments feed

### Public View Page (`/live.php`)
- Updates every 10 seconds
- Shows:
  - Current viewer count
  - Like/dislike counts
  - Live chat
  - Featured products

### Update Flow
```
1. User views stream
2. JavaScript polls engagement API
3. API triggers FakeEngagementGenerator
4. Generator adds/removes fake viewers/likes
5. Counts updated in database
6. Response sent to frontend
7. UI updates with new counts
8. Real user actions add on top
```

## Stream Lifecycle

### 1. Stream Creation
```php
// When seller starts stream
POST /api/streams/start.php
{
  "title": "My Awesome Stream",
  "description": "Check out these products!"
}

// System generates:
- Unique stream_key
- Initial engagement config (from global settings)
- Stream record in database
```

### 2. During Stream
```javascript
// Every 10 seconds (public)
GET /api/streams/engagement.php?stream_id=123
// Triggers fake viewer/like generation

// Every 5 seconds (seller)
GET /api/live/stats.php?stream_id=123
// Gets updated counts
```

### 3. Stream End
```php
POST /api/streams/end.php
{
  "stream_id": 123,
  "action": "save" // or "delete"
}

// System stores:
- Final viewer_count (real + fake)
- Final like_count (real + fake)
- Final comment_count (all)
- Stream duration
- Total revenue
```

## Testing

### Manual Testing Steps

1. **Test Stream Creation**
   ```bash
   # Check logs for stream_key generation
   tail -f /var/log/php/error.log
   ```

2. **Test Engagement Simulation**
   - Start a stream
   - Open browser console
   - Watch for engagement API calls
   - Verify viewer count increases

3. **Test Admin Panel**
   - Navigate to `/admin/streaming/`
   - Open Stream Settings
   - Change engagement values
   - Save settings
   - Start new stream
   - Verify new settings applied

4. **Test Real User Integration**
   - Have real user like stream
   - Verify like count includes both real and fake
   - Check database for separate tracking

### Automated Testing
```bash
# Run migration
php run_stream_key_migration.php

# Check engagement generator
php /home/runner/work/edd/edd/api/live/fake-engagement.php
```

## Troubleshooting

### Issue: Stream won't start
**Cause**: Missing stream_key column
**Solution**: Run migration script
```bash
php run_stream_key_migration.php
```

### Issue: No engagement updates
**Cause**: FakeEngagementGenerator not triggered
**Check**:
1. Verify stream status is 'live'
2. Check stream_engagement_config exists for stream
3. Check JavaScript console for API errors

### Issue: Settings not saving
**Cause**: Missing global_stream_settings table
**Solution**: Table is auto-created on first save attempt

### Issue: Viewer count stuck at 0
**Cause**: fake_viewers_enabled is OFF
**Solution**: Enable in admin panel or check config

## File Changes Summary

### New Files
- `/migrations/20251018_add_stream_key_to_live_streams.sql`
- `/run_stream_key_migration.php`
- `/api/admin/streams/get-settings.php`
- `/api/admin/streams/save-settings.php`

### Modified Files
- `/includes/models_extended.php` - Added generateStreamKey() method
- `/api/streams/start.php` - Added stream_key generation and global settings loading
- `/admin/streaming/index.php` - Added engagement configuration UI

### Existing Files (Not Modified)
- `/api/live/fake-engagement.php` - FakeEngagementGenerator class
- `/api/streams/engagement.php` - Engagement trigger endpoint
- `/live.php` - Public viewing page (already has polling)
- `/seller/stream-interface.php` - Seller interface (already has polling)

## Configuration Examples

### Conservative Settings (Subtle Enhancement)
```
Min Fake Viewers: 5
Max Fake Viewers: 30
Viewer Increase Rate: 2
Viewer Decrease Rate: 1
Like Rate: 1
Engagement Multiplier: 1.5
```

### Moderate Settings (Recommended)
```
Min Fake Viewers: 15
Max Fake Viewers: 100
Viewer Increase Rate: 5
Viewer Decrease Rate: 3
Like Rate: 3
Engagement Multiplier: 2.0
```

### Aggressive Settings (High Energy)
```
Min Fake Viewers: 50
Max Fake Viewers: 500
Viewer Increase Rate: 10
Viewer Decrease Rate: 5
Like Rate: 8
Engagement Multiplier: 3.0
```

## Security Considerations

1. **Admin Only**: Engagement settings only accessible to admins
2. **Per-Stream Config**: Each stream has isolated configuration
3. **Fake Flag**: All fake interactions marked with `is_fake = 1`
4. **Analytics**: Can filter real vs fake for accurate metrics
5. **Transparency**: Consider disclosing simulated engagement in ToS

## Future Enhancements

- [ ] Per-stream engagement override in seller interface
- [ ] A/B testing of different engagement levels
- [ ] Machine learning to optimize engagement patterns
- [ ] Geographic viewer simulation
- [ ] Time-based engagement patterns (peak hours)
- [ ] Viewer retention analytics
- [ ] Engagement heatmaps

## Support

For issues or questions:
1. Check error logs: `/var/log/php/error.log`
2. Check browser console for JavaScript errors
3. Verify database tables exist
4. Ensure migrations ran successfully
