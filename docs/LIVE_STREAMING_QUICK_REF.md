# Enhanced Live Streaming System - Quick Reference

## Quick Start

### For Sellers

1. **Go Live**:
   - Navigate to `/seller/stream-interface.php`
   - Enter stream title
   - Click "Go Live"
   - Stream appears immediately on `/live.php`

2. **During Stream**:
   - View real-time stats (viewers, likes, comments)
   - Monitor engagement automatically increasing
   - Chat with viewers
   - Feature products

3. **End Stream**:
   - Click "End Stream"
   - Choose "Save Stream" to make it available for replay
   - Choose "Delete Stream" to remove it

### For Viewers

1. **Watch Live**:
   - Visit `/live.php`
   - See active streams in "Live Now" section
   - Click to watch, chat, and like

2. **Schedule Reminders**:
   - Browse "Upcoming Events" section
   - Click "Set Reminder" for future streams

3. **Watch Replays**:
   - Scroll to "Recent Streams"
   - Click play button on any archived stream

## API Quick Reference

### Start Stream
```bash
POST /api/streams/start.php
Body: {"title": "My Stream", "description": "Optional"}
Auth: Required (Vendor)
```

### Trigger Engagement
```bash
GET /api/streams/engagement.php?stream_id=123
Auth: None (Public)
```

### End Stream
```bash
POST /api/streams/end.php
Body: {"stream_id": 123, "action": "save"}
Auth: Required (Vendor)
```

### List Streams
```bash
GET /api/streams/list.php?type=all&limit=10
Auth: None (Public)
Returns: {active: [...], scheduled: [...], recent: [...]}
```

## Database Tables

### Main Tables
- `live_streams`: Stream records with status (scheduled/live/ended/archived)
- `stream_viewers`: Viewer tracking (real and fake)
- `stream_interactions`: Likes, dislikes, comments
- `stream_engagement_config`: Engagement generation settings
- `saved_streams`: Backward compatibility for archived streams

### Key Fields
- `live_streams.status`: 'scheduled', 'live', 'ended', 'archived', 'cancelled'
- `live_streams.video_path`: Path to saved recording
- `live_streams.viewer_count`: Persistent viewer count
- `live_streams.like_count`: Persistent like count

## Configuration

### Default Engagement Settings
```
min_fake_viewers: 15
max_fake_viewers: 100
viewer_increase_rate: 5/minute
like_rate: 3/minute
engagement_multiplier: 2.0
```

### Auto-Engagement Timing
- Triggers every 15 seconds during stream
- Page polls every 30 seconds for status updates
- Real viewer data + fake engagement = total displayed

## Common Tasks

### Schedule a Stream (SQL)
```sql
INSERT INTO live_streams 
(vendor_id, title, description, status, scheduled_at)
VALUES (1, 'My Stream', 'Description', 'scheduled', '2024-10-20 14:00:00');
```

### Query Active Streams
```sql
SELECT * FROM live_streams WHERE status = 'live' ORDER BY viewer_count DESC;
```

### Get Recent Streams
```sql
SELECT * FROM live_streams 
WHERE status = 'archived' 
ORDER BY ended_at DESC LIMIT 10;
```

### Check Engagement Config
```sql
SELECT * FROM stream_engagement_config WHERE stream_id = 123;
```

## Troubleshooting

### Stream Not Visible
1. Check status is 'live': `SELECT status FROM live_streams WHERE id = X`
2. Verify vendor is approved: `SELECT status FROM vendors WHERE id = Y`
3. Clear browser cache and refresh

### No Engagement Increase
1. Check config exists: `SELECT * FROM stream_engagement_config WHERE stream_id = X`
2. Verify engagement API is called (browser console)
3. Check fake_viewers_enabled = 1

### Can't End Stream
1. Verify you own the stream
2. Check stream status is 'live'
3. Try refreshing the page

## File Locations

### API Endpoints
- `/api/streams/start.php` - Start stream
- `/api/streams/end.php` - End stream
- `/api/streams/engagement.php` - Auto-engagement
- `/api/streams/list.php` - List streams

### Frontend Files
- `/live.php` - Public live streaming page
- `/seller/stream-interface.php` - Seller streaming interface
- `/admin/index.php` - Admin dashboard (includes vendor link)

### Database
- `/migrations/20251017_enhance_live_streaming_system.sql` - Migration file
- `/docs/ENHANCED_LIVE_STREAMING_GUIDE.md` - Full documentation

## Key Features

✅ Auto-engagement simulation  
✅ Real-time stream visibility  
✅ Stream saving & replay  
✅ Scheduled streams  
✅ Persistent engagement data  
✅ Responsive UI with sections  
✅ Admin vendor management link  

## Testing Checklist

- [ ] Start stream as vendor
- [ ] Verify appears on /live.php
- [ ] Check engagement increases
- [ ] End and save stream
- [ ] Verify in Recent Streams
- [ ] Test scheduled stream display
- [ ] Check admin vendor link

## Support

For detailed documentation, see: `/docs/ENHANCED_LIVE_STREAMING_GUIDE.md`

For issues:
1. Check browser console for errors
2. Verify database connection
3. Review PHP error logs
4. Check network tab for failed API calls
