# Live Streaming Features - Quick Reference Guide

## 🎯 Quick Access Points

### For Sellers
1. **Dashboard**: View Recent Streams section
   - URL: `/seller/dashboard.php`
   - Location: Below "Top Performing Products" section

2. **Start Stream**: Begin live streaming
   - URL: `/seller/stream-interface.php`
   - Access: Seller Dashboard → "Go Live" button

3. **Manage Streams**: View all streams (active, scheduled, recent)
   - URL: `/seller/streams.php`
   - Access: Seller Dashboard → "Streams" menu

### For Administrators
1. **Stream Management**: View and manage all streams
   - URL: `/admin/streaming/index.php`
   - Access: Admin Panel → Streaming

2. **Configure Engagement**: Adjust simulated engagement settings
   - URL: `/admin/streaming/index.php` → "Stream Settings" button
   - Settings saved to database for all new streams

### For Buyers
1. **Watch Live Streams**: View active live streams
   - URL: `/live.php`
   - Shows all currently live streams

2. **Replay Saved Streams**: Watch past streams
   - URL: `/watch?stream_id=X`
   - Accessible via Recent Streams or stream links

---

## 🐛 Bug Fixes

### 1. Save & Stop Stream Error (FIXED ✅)
**Before**: Error when clicking "Save & Stop Stream"
```
SQLSTATE[42S22]: Column not found: 1054 Unknown column 'stream_id' in 'INSERT INTO'
```

**After**: Streams save successfully to `saved_streams` table

**What was fixed**:
- Corrected column names in INSERT query
- Added proper vendor-to-user mapping
- Stream now appears in Recent Streams section

### 2. Start New Stream Error (FIXED ✅)
**Before**: Error when starting a new stream
```
SQLSTATE[42S22]: Column not found: 1054 Unknown column 'setting_key' in 'SELECT'
```

**After**: Streams start without errors

**What was fixed**:
- Added automatic table creation for `global_stream_settings`
- Added error handling with fallback to defaults
- Stream starts with proper engagement configuration

---

## 📺 Recent Streams Section

### Location
Seller Dashboard → Scroll down to "Recent Streams" section

### Features
```
┌─────────────────────────────────────────────────────────────────┐
│ 📼 Recent Streams                              [View All →]     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ←scroll→   │
│  │📹    │  │📹    │  │📹    │  │📹    │  │📹    │             │
│  │      │  │      │  │      │  │      │  │      │             │
│  │ 45m  │  │ 1h2m │  │ 32m  │  │ 28m  │  │ 53m  │             │
│  └──────┘  └──────┘  └──────┘  └──────┘  └──────┘             │
│  My Stream  Weekend  Product   Tech      Gaming                │
│  👁️ 156    👁️ 243   👁️ 89     👁️ 312   👁️ 178               │
│  👍 42     👍 67     👍 23     👍 89     👍 54                 │
│  2h ago    5h ago   1d ago    2d ago   3d ago                  │
│  [▶️ Replay][🗑️ Delete]                                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Actions
1. **Replay**: Click ▶️ button or thumbnail to watch recording
2. **Delete**: Click 🗑️ button to delete stream (with confirmation)
3. **Scroll**: Drag horizontally to view more streams (if > 5)

### Visual Features
- Hover effect: Cards lift slightly on hover
- Play button: Appears on thumbnail hover
- Responsive: Adapts to screen size
- Custom scrollbar: Styled for better UX

---

## 🎭 Simulated Live Stream Engagement

### How It Works

#### On Stream Start
```
1. Stream begins
2. System adds initial engagement:
   - Viewers: Random 5-20
   - Likes: Random 0-10
3. Display updates immediately
```

#### During Stream (Every 5-15 seconds randomly)
```
1. Timer triggers (random interval)
2. System adds increment:
   - Viewers: +1 to +5 (random)
   - Likes: +1 to +2 (random)
3. AJAX updates display
4. Schedule next update (new random interval)
```

#### On Stream End
```
1. Final counts calculated:
   - Total Viewers = Real + Fake
   - Total Likes = Real + Fake
2. Saved to database
3. Displayed in Recent Streams
```

### Visual Indicators

#### Seller Interface (`/seller/stream-interface.php`)
```
┌──────────────────────────────────────────────┐
│ 🔴 LIVE                    [End Stream]      │
├──────────────────────────────────────────────┤
│                                              │
│         [VIDEO PREVIEW]                      │
│                                              │
├──────────────────────────────────────────────┤
│ 📊 Stream Stats                              │
│                                              │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐     │
│  │   247   │  │   00:15  │  │   127   │     │
│  │ Viewers │  │ Duration │  │  Likes  │     │
│  └─────────┘  └─────────┘  └─────────┘     │
│                                              │
│  Numbers update every 5-15 seconds ↻        │
└──────────────────────────────────────────────┘
```

#### Public View (`/live.php`)
```
┌──────────────────────────────────────────────┐
│ 🔴 LIVE                                      │
├──────────────────────────────────────────────┤
│                                              │
│         [LIVE STREAM VIDEO]                  │
│                                              │
│  👥 247 watching    ⏰ 00:15:32             │
│                                              │
│  [👍 127]  [👎 12]                          │
│                                              │
└──────────────────────────────────────────────┘
│ 💬 Live Chat                                │
│ ─────────────────────────────────────        │
│ User123: Great product! 😍                   │
│ Shopper99: How much is shipping?            │
│ BuyerX: This is amazing!                     │
└──────────────────────────────────────────────┘
```

---

## ⚙️ Admin Configuration

### Access
Admin Panel → Streaming → "Stream Settings" button

### Settings Interface
```
┌────────────────────────────────────────────────────┐
│ ⚙️ RTMP & Stream Settings                         │
├────────────────────────────────────────────────────┤
│                                                     │
│ 📡 RTMP Server Configuration                       │
│ ┌───────────────────────────────────────────┐     │
│ │ RTMP Server URL: rtmp://localhost/live    │     │
│ │ Server Key: [optional]                     │     │
│ └───────────────────────────────────────────┘     │
│                                                     │
│ 🎬 Stream Quality Settings                         │
│ ┌───────────────────────────────────────────┐     │
│ │ Max Bitrate: [4000] kbps                   │     │
│ │ Max Resolution: [1920x1080 ▼]             │     │
│ │ Max Duration: [14400] seconds              │     │
│ │ ☑ Enable automatic recording               │     │
│ └───────────────────────────────────────────┘     │
│                                                     │
│ 🎭 Engagement Simulation Settings                  │
│ ┌───────────────────────────────────────────┐     │
│ │ ⓘ Simulated engagement creates a lively   │     │
│ │   atmosphere. Real engagement is added     │     │
│ │   on top of these numbers.                 │     │
│ │                                             │     │
│ │ ☑ Enable Simulated Viewers                │     │
│ │   Min: [15]   Max: [100]                   │     │
│ │   Increase Rate: [5] /min                  │     │
│ │   Decrease Rate: [3] /min                  │     │
│ │                                             │     │
│ │ ☑ Enable Simulated Likes                  │     │
│ │   Like Rate: [3] /min                      │     │
│ │                                             │     │
│ │ Engagement Multiplier: [2.0]               │     │
│ │ (Fake = Real × Multiplier)                 │     │
│ │                                             │     │
│ │ ⚠️ Settings apply to new streams only      │     │
│ └───────────────────────────────────────────┘     │
│                                                     │
│            [Cancel]  [💾 Save Settings]            │
└────────────────────────────────────────────────────┘
```

### Configuration Options

#### Simulated Viewers
- **Enable/Disable**: Toggle on/off
- **Min Fake Viewers**: 0-500 (default: 15)
- **Max Fake Viewers**: 0-1000 (default: 100)
- **Increase Rate**: 1-50 per minute (default: 5)
- **Decrease Rate**: 1-50 per minute (default: 3)

#### Simulated Likes
- **Enable/Disable**: Toggle on/off
- **Like Rate**: 1-50 per minute (default: 3)

#### Advanced
- **Engagement Multiplier**: 0.5-10.0x (default: 2.0)
  - Controls ratio of fake to real engagement
  - Example: 2.0x means 2 fake viewers per real viewer
  - Constrained by min/max settings

---

## 🔄 Data Flow

### Stream Lifecycle
```
1. START STREAM
   ↓
   [Create live_streams record]
   ↓
   [Initialize engagement config]
   ↓
   [Add initial fake viewers (5-20)]
   ↓
   [Add initial fake likes (0-10)]
   ↓
2. DURING STREAM (Every 5-15 seconds)
   ↓
   [Trigger engagement API]
   ↓
   [Add 1-5 viewers OR remove 1-3 viewers]
   ↓
   [Add 0-2 likes]
   ↓
   [Update live_streams counts]
   ↓
   [Return new counts to client]
   ↓
   [Update UI displays]
   ↓
3. END STREAM
   ↓
   [Calculate final totals]
   ↓
   [Update live_streams table]
   ↓
   [Save to saved_streams table]
   ↓
   [Show in Recent Streams section]
```

### Database Tables
```
live_streams
├── id
├── vendor_id
├── title
├── status (live/archived/ended)
├── viewer_count (real + fake)
├── like_count (real + fake)
└── ...

saved_streams
├── id
├── seller_id (references users.id)
├── stream_title
├── video_url
├── views
├── likes
└── ...

global_stream_settings
├── setting_key
└── setting_value
```

---

## 📝 Testing Steps

### 1. Test Bug Fixes
```bash
# Test starting a stream
1. Login as seller
2. Navigate to /seller/stream-interface.php
3. Enter stream title
4. Click "Go Live"
5. ✓ Should start without errors

# Test stopping a stream
1. While streaming, click "End Stream"
2. Choose "Save Stream"
3. ✓ Should save without errors
4. ✓ Stream appears in Recent Streams
```

### 2. Test Recent Streams Section
```bash
1. Login as seller
2. Navigate to /seller/dashboard.php
3. Scroll to "Recent Streams" section
4. ✓ Should see saved streams in horizontal grid
5. ✓ Scroll horizontally if > 5 streams
6. Click "Replay" button
7. ✓ Should redirect to watch page
8. Click "Delete" button
9. ✓ Should show confirmation
10. Confirm deletion
11. ✓ Stream should disappear
```

### 3. Test Engagement System
```bash
1. Login as seller
2. Start a new stream
3. ✓ Initial viewers: 5-20 range
4. ✓ Initial likes: 0-10 range
5. Watch for 60 seconds
6. ✓ Viewers increase randomly
7. ✓ Likes increase randomly
8. ✓ Updates at 5-15 second intervals
9. Stop stream
10. ✓ Final counts saved
```

### 4. Test Admin Configuration
```bash
1. Login as admin
2. Navigate to /admin/streaming/index.php
3. Click "Stream Settings"
4. ✓ Current settings load
5. Toggle "Enable Simulated Viewers" off
6. Save settings
7. ✓ Settings save successfully
8. Start new stream as seller
9. ✓ No fake viewers added
10. Re-enable in admin settings
```

---

## 🚀 Deployment Checklist

- [ ] Backup database before deployment
- [ ] Run PHP syntax checks on all modified files
- [ ] Test on staging environment first
- [ ] Verify database migrations (global_stream_settings table)
- [ ] Test with real users (seller, buyer, admin)
- [ ] Monitor error logs for first 24 hours
- [ ] Check performance metrics
- [ ] Verify AJAX endpoints respond quickly
- [ ] Test on different browsers (Chrome, Firefox, Safari)
- [ ] Test on mobile devices

---

## 📞 Support

### Common Issues

**Q: Streams not saving**
A: Check database connection and verify `saved_streams` table exists

**Q: Engagement not increasing**
A: Verify `global_stream_settings` table exists and has data

**Q: Recent Streams not showing**
A: Check that stream was saved (not deleted) and seller_id matches

**Q: Random intervals not working**
A: Check browser console for JavaScript errors

### Debug Mode
Enable debug logging in `/api/streams/start.php`:
```php
error_reporting(E_ALL);
ini_set('display_errors', 1);
```

### Performance Monitoring
Monitor these queries:
- Stream viewer counts: Should use index on `stream_id`
- Recent streams: Should use index on `seller_id`
- Engagement updates: Should be < 100ms

---

## 📚 Additional Resources

- Full Implementation Guide: `LIVE_STREAMING_IMPLEMENTATION.md`
- Database Schema: `/database/schema.sql`
- API Documentation: See individual API files
- Admin Guide: See admin panel help section

---

**Version**: 1.0  
**Last Updated**: 2025-10-18  
**Status**: Production Ready ✅
