# Stream Management System

## Overview

A comprehensive stream management system for sellers to manage their live streams, scheduled events, and archived recordings.

## Features

### 1. Active Streams Section
- **View Live Streams**: Real-time display of currently active streams
- **Stream Statistics**: 
  - Current viewer count
  - Total likes
  - Comment count
  - Duration
- **Actions**:
  - View Stream: Access the live stream interface
  - Stop Stream: End the stream with save/delete options

### 2. Scheduled Streams Section
- **View Upcoming Streams**: List of all scheduled future streams
- **Stream Details**:
  - Stream title and description
  - Scheduled date and time
  - Time until start
- **Actions**:
  - Start Now: Begin a scheduled stream early
  - Edit: Modify stream details (to be implemented)
  - Cancel: Cancel a scheduled stream

### 3. Recent Streams Section
- **View Past Streams**: List of archived streams
- **Stream Metrics**:
  - Total viewers
  - Likes and comments
  - Revenue generated
  - Duration
- **Actions**:
  - Watch Recording: View saved stream video
  - View Stats: See detailed analytics
  - Delete: Remove stream recording

## Files Created

### Dashboard
- **`/seller/streams.php`**: Main stream management dashboard
  - Displays active, scheduled, and recent streams
  - Provides actions for each stream type
  - Auto-refreshes active streams every 10 seconds

### API Endpoints

#### `/api/streams/list.php`
Lists streams filtered by type and vendor

**Parameters:**
- `type`: `live`, `scheduled`, `archived`, or `all` (default: `all`)
- `limit`: Number of results (default: 10)
- `offset`: Pagination offset (default: 0)

**Response:**
```json
{
  "success": true,
  "streams": [...],
  "active": [...],
  "scheduled": [...],
  "recent": [...]
}
```

#### `/api/streams/delete.php`
Deletes a stream recording

**Method:** POST

**Body:**
```json
{
  "stream_id": 123
}
```

**Response:**
```json
{
  "success": true,
  "message": "Stream recording deleted successfully"
}
```

**Notes:**
- Only archived or ended streams can be deleted
- Performs soft delete (removes video_path, changes status to 'ended')
- Verifies vendor ownership before deletion

#### `/api/streams/cancel.php`
Cancels a scheduled stream

**Method:** POST

**Body:**
```json
{
  "stream_id": 123
}
```

**Response:**
```json
{
  "success": true,
  "message": "Stream cancelled successfully"
}
```

**Notes:**
- Only scheduled streams can be cancelled
- Changes status to 'cancelled'
- Verifies vendor ownership

## Database Schema

### live_streams Table
Required columns:
- `id`: Primary key
- `vendor_id`: Foreign key to vendors table
- `status`: ENUM('scheduled', 'live', 'ended', 'archived', 'cancelled')
- `title`: Stream title
- `description`: Stream description
- `video_path`: Path to saved video recording
- `viewer_count`: Current/total viewer count
- `like_count`: Total likes
- `comment_count`: Total comments
- `total_revenue`: Revenue generated
- `started_at`: Stream start timestamp
- `ended_at`: Stream end timestamp
- `scheduled_at`: Scheduled start time

## User Flow

### Starting a Stream
1. Seller navigates to `/seller/live.php` or `/seller/streams.php`
2. Clicks "Go Live Now" or "Start Stream"
3. Selects products to feature
4. Sets stream title
5. Clicks "Start Stream" in `/seller/stream-interface.php`
6. Stream goes live with status 'live'

### Stopping a Stream
1. While streaming, seller clicks "Stop Stream" button
2. Modal appears showing final statistics:
   - Duration
   - Total viewers
   - Likes
   - Orders
   - Revenue
3. Seller chooses:
   - **Save Stream**: Status changes to 'archived', video saved
   - **Delete Stream**: Status changes to 'ended', no video saved
4. Redirects to `/seller/streams.php` dashboard

### Managing Streams
1. Seller navigates to `/seller/streams.php`
2. Views three sections:
   - **Active Streams**: Can stop any live stream
   - **Scheduled Streams**: Can start, edit, or cancel
   - **Recent Streams**: Can watch, view stats, or delete

## Integration Points

### Navigation Updates
- Added "Manage Streams" button to `/seller/live.php`
- Updated stream end redirect to point to `/seller/streams.php`

### Stop Stream Flow
- Removed duplicate `stopStreaming()` function
- Single implementation shows end stream modal
- Modal fetches final stats from `/api/live/stats.php`
- Calls `/api/streams/end.php` with action (save/delete)

## Security

### Authentication
- All pages require vendor login via `Session::requireLogin()`
- API endpoints verify user is authenticated vendor

### Authorization
- Vendor ID verification for all operations
- Can only view/manage own streams
- SQL injection prevention via prepared statements

### Input Validation
- Stream ID validation (integer casting)
- Status verification before operations
- Ownership checks on all actions

## Error Handling

### Common Errors
- **401 Unauthorized**: User not logged in
- **403 Forbidden**: Not a vendor or wrong vendor
- **400 Bad Request**: Invalid parameters or operation not allowed

### User-Facing Messages
- Success notifications for all actions
- Clear error messages for failures
- Confirmation modals for destructive actions

## Testing

### Syntax Validation
All PHP files pass syntax check:
```bash
php -l /home/runner/work/edd/edd/seller/streams.php
php -l /home/runner/work/edd/edd/api/streams/list.php
php -l /home/runner/work/edd/edd/api/streams/delete.php
php -l /home/runner/work/edd/edd/api/streams/cancel.php
```

### Manual Testing Checklist
- [ ] Start a new live stream
- [ ] View stream in streams dashboard
- [ ] Stop stream and save recording
- [ ] Watch saved recording
- [ ] Delete archived stream
- [ ] Schedule a future stream
- [ ] Cancel scheduled stream
- [ ] Start scheduled stream early
- [ ] Verify vendor isolation (can't see other vendor streams)

## Future Enhancements

### Planned Features
1. **Edit Scheduled Streams**: Modal to modify stream details
2. **Advanced Analytics**: Detailed metrics and graphs
3. **Download Recordings**: Export stream videos
4. **Share Recordings**: Social media integration
5. **Stream Highlights**: Create clips from recordings
6. **Notification System**: Alert followers of cancellations

### Technical Improvements
1. **WebSocket Integration**: Real-time updates without polling
2. **Video Transcoding**: Multiple quality options
3. **CDN Integration**: Faster video delivery
4. **Search and Filter**: Find streams by date, revenue, etc.
5. **Bulk Actions**: Manage multiple streams at once

## Performance Considerations

### Auto-Refresh
- Active streams refresh every 10 seconds
- Minimal impact on server load
- Can be adjusted based on needs

### Database Queries
- Indexed columns: `vendor_id`, `status`, `started_at`, `ended_at`
- Efficient pagination support
- Prepared statements prevent SQL injection

### Client-Side
- Minimal JavaScript dependencies
- Progressive enhancement
- Mobile-responsive design

## Support

### Common Issues

**Issue**: Stream doesn't appear in dashboard
- **Solution**: Check stream status is 'live', 'scheduled', or 'archived'

**Issue**: Can't delete stream
- **Solution**: Only archived/ended streams can be deleted

**Issue**: Stats not updating
- **Solution**: Wait 10 seconds for auto-refresh or reload page

### Debug Mode
Enable debug mode to see detailed error messages:
```php
define('DEBUG_MODE', true);
```

## Changelog

### Version 1.0.0 (Initial Release)
- Created stream management dashboard
- Implemented list, delete, and cancel APIs
- Updated navigation and redirect flows
- Fixed duplicate stopStreaming function
- Added comprehensive documentation
