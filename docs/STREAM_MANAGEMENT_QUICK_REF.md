# Stream Management Quick Reference

## URLs

- **Dashboard**: `/seller/streams.php`
- **Go Live**: `/seller/live.php`
- **Stream Interface**: `/seller/stream-interface.php`

## API Endpoints

### List Streams
```
GET /api/streams/list.php?type=live
GET /api/streams/list.php?type=scheduled
GET /api/streams/list.php?type=archived
```

### Delete Stream
```
POST /api/streams/delete.php
Body: {"stream_id": 123}
```

### Cancel Stream
```
POST /api/streams/cancel.php
Body: {"stream_id": 123}
```

### Start Stream
```
POST /api/streams/start.php
Body: {"title": "My Stream", "description": "..."}
```

### End Stream
```
POST /api/streams/end.php
Body: {"stream_id": 123, "action": "save"}
Body: {"stream_id": 123, "action": "delete"}
```

## Stream Status Values

- `scheduled`: Future stream
- `live`: Currently streaming
- `ended`: Completed (no recording)
- `archived`: Completed (with recording)
- `cancelled`: Scheduled but cancelled

## Database Tables

### live_streams
Main table for all streams
```sql
SELECT * FROM live_streams 
WHERE vendor_id = ? AND status = 'live';
```

### saved_streams (backward compatibility)
Legacy table for archived streams
```sql
SELECT * FROM saved_streams 
WHERE vendor_id = ?
ORDER BY saved_at DESC;
```

## JavaScript Functions (streams.php)

### Load Data
```javascript
loadActiveStreams()    // Fetch live streams
loadScheduledStreams() // Fetch scheduled streams
loadRecentStreams()    // Fetch archived streams
```

### Actions
```javascript
stopStream(streamId)           // Stop a live stream
startScheduledStream(streamId) // Start scheduled stream early
cancelStream(streamId)         // Cancel scheduled stream
deleteStream(streamId)         // Delete archived stream
watchRecording(streamId)       // Watch saved video
viewStats(streamId)            // View analytics
```

### Helpers
```javascript
calculateDuration(startTime)             // Format duration from start
calculateDurationBetween(start, end)     // Calculate duration
getTimeUntil(futureDate)                 // Time until scheduled
formatDate(date)                         // Format date string
escapeHtml(text)                         // Sanitize HTML
showNotification(message, type)          // Show toast message
```

## CSS Classes

### Stream Cards
```css
.stream-card          /* Individual stream container */
.stream-title         /* Stream title */
.stream-status        /* Status badge */
.stream-stats         /* Statistics grid */
.stream-actions       /* Action buttons */
```

### Status Badges
```css
.stream-status.live       /* Red badge for live */
.stream-status.scheduled  /* Blue badge for scheduled */
.stream-status.archived   /* Green badge for archived */
```

### Buttons
```css
.btn-primary    /* Red button (primary actions) */
.btn-secondary  /* Gray button (secondary actions) */
.btn-success    /* Green button (positive actions) */
.btn-info       /* Blue button (info actions) */
.btn-danger     /* Red button (destructive actions) */
.btn-outline    /* Outlined button (neutral actions) */
```

## Common Workflows

### Start Stream
1. Select products on `/seller/live.php`
2. Click "Start Stream"
3. Enter title in `/seller/stream-interface.php`
4. Click "Go Live"

### Stop Stream
1. Click "Stop Stream" in interface
2. Review final stats in modal
3. Choose "Save Stream" or "Delete Stream"
4. Redirects to dashboard

### Schedule Stream
1. Click "Schedule" on `/seller/live.php`
2. Fill in title, date, time, duration
3. Select products
4. Submit form

### Cancel Scheduled Stream
1. Go to `/seller/streams.php`
2. Find stream in "Scheduled Streams"
3. Click "Cancel"
4. Confirm in modal

### Delete Recording
1. Go to `/seller/streams.php`
2. Find stream in "Recent Streams"
3. Click "Delete"
4. Confirm in modal

## Error Messages

### Authentication Errors
- `Authentication required` - User not logged in
- `Vendor access required` - User is not a vendor
- `Approved vendor access required` - Vendor not approved

### Authorization Errors
- `Access denied` - Stream doesn't belong to vendor
- `Stream not found or access denied` - Invalid stream ID

### Operation Errors
- `You already have an active stream` - Can't start multiple streams
- `Only archived or ended streams can be deleted` - Wrong status
- `Scheduled stream not found` - Stream not scheduled
- `Stream is not currently live` - Can't end non-live stream

## Troubleshooting

### Stream doesn't appear in dashboard
```sql
-- Check stream status
SELECT id, title, status, vendor_id 
FROM live_streams 
WHERE id = ?;
```

### Can't stop stream
- Verify stream is in 'live' status
- Check console for JavaScript errors
- Verify `/api/streams/end.php` is accessible

### Stats not updating
- Check browser console for fetch errors
- Verify 10-second auto-refresh is working
- Manually refresh page

### Video not playing
- Verify `video_path` is set in database
- Check video file exists on server
- Verify video URL is accessible

## Performance Tips

1. **Limit Results**: Use `limit` parameter in API calls
2. **Pagination**: Use `offset` for large lists
3. **Caching**: Consider caching archived stream lists
4. **CDN**: Use CDN for video delivery
5. **Indexes**: Ensure database indexes exist

## Security Checklist

- [x] Vendor authentication required
- [x] Ownership verification on all actions
- [x] SQL injection prevention (prepared statements)
- [x] XSS prevention (escapeHtml function)
- [x] CSRF protection (via init.php)
- [ ] Rate limiting (recommended)
- [ ] Input validation (recommended enhancement)

## Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Mobile Support

- Responsive design for all screen sizes
- Touch-friendly buttons
- Optimized layouts for tablets

## Dependencies

### PHP
- PHP 7.4 or higher
- PDO extension
- Session support

### Database
- MariaDB 10.5+ or MySQL 8.0+
- Required tables: `live_streams`, `vendors`, `users`

### JavaScript
- No external libraries required
- Modern browser with Fetch API support

## Related Files

- `/seller/live.php` - Stream setup page
- `/seller/stream-interface.php` - Live streaming interface
- `/api/live/stats.php` - Real-time statistics
- `/includes/models_extended.php` - LiveStream model
