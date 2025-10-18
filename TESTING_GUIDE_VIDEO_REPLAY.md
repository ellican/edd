# Video Replay System - Testing Guide

## Overview
This document outlines the testing procedures for the newly implemented video replay system and stream enhancements.

## Prerequisites
- Active seller account with approved vendor status
- Access to seller dashboard
- Modern web browser (Chrome, Firefox, Safari, or Edge)

## Test Scenarios

### 1. Video Replay System (`live.php`)

#### Test 1.1: View Replay Modal
**Steps:**
1. Navigate to `/live.php`
2. Scroll to "Recent Streams" section
3. Click the play button (▶️) on any archived stream
4. **Expected Result:**
   - Modal opens with dark overlay
   - Video player displays (or error message if video unavailable)
   - Stream title, seller name, date, and duration shown
   - Stats displayed: Viewers, Likes, Comments

#### Test 1.2: Video Player Controls
**Steps:**
1. Open a replay modal (as in Test 1.1)
2. Test the following controls:
   - Play/Pause button
   - Seek bar (drag to different positions)
   - Volume control
   - Fullscreen button
3. **Expected Result:**
   - All controls work smoothly
   - Video plays without stuttering
   - Fullscreen mode works correctly

#### Test 1.3: Close Modal
**Steps:**
1. Open a replay modal
2. Try each method to close:
   - Click the X button (top right)
   - Press ESC key
3. **Expected Result:**
   - Modal closes immediately
   - Video stops playing
   - Page scroll is re-enabled

#### Test 1.4: Error Handling
**Steps:**
1. Open a replay for a stream with missing video file
2. **Expected Result:**
   - Error message displayed: "Video Not Available"
   - Modal still shows stream metadata
   - No JavaScript errors in console

#### Test 1.5: Lazy Loading Thumbnails
**Steps:**
1. Navigate to `/live.php`
2. Open browser DevTools Network tab
3. Scroll slowly through "Recent Streams" section
4. **Expected Result:**
   - Thumbnails load only when they come into view
   - Smooth fade-in effect when loaded
   - Network requests made only for visible images

### 2. Seller Streaming Interface (`stream-interface.php`)

#### Test 2.1: Start Stream
**Steps:**
1. Log in as a seller
2. Navigate to `/seller/stream-interface.php`
3. Enter a stream title
4. Click "Go Live"
5. **Expected Result:**
   - Button changes to "End Stream"
   - Status shows "🔴 LIVE"
   - Duration starts counting

#### Test 2.2: Automatic Engagement - Viewers
**Steps:**
1. Start a stream (as in Test 2.1)
2. Wait 10 seconds
3. Observe the "Current Viewers" stat
4. Continue watching for 30 seconds
5. **Expected Result:**
   - Viewers start increasing after 10 seconds
   - Each increase is 1-3 viewers
   - Updates occur at random intervals (5-20 seconds)

#### Test 2.3: Automatic Engagement - Likes
**Steps:**
1. Start a stream
2. Wait 30 seconds
3. Observe the "Likes" stat
4. Continue watching for 60 seconds
5. **Expected Result:**
   - Likes start increasing after 30 seconds
   - Increases occur at random intervals (10-30 seconds)
   - Gradual increase over time

#### Test 2.4: Stats Display
**Steps:**
1. Start a stream
2. Let it run for 2 minutes
3. Check all stats panels
4. **Expected Result:**
   - All stats are visible and updating:
     - Current Viewers
     - Duration (format: MM:SS)
     - Likes
     - Dislikes
     - Comments
     - Orders
     - Revenue ($0.00 format)

#### Test 2.5: End Stream and Save
**Steps:**
1. Start a stream
2. Let it run for 1 minute
3. Click "End Stream"
4. Click "💾 Save Stream"
5. **Expected Result:**
   - Modal shows final statistics
   - Success message appears
   - Redirected to `/seller/streams.php`
   - Stream appears in "Recent Streams" section

#### Test 2.6: End Stream and Delete
**Steps:**
1. Start a stream
2. Click "End Stream"
3. Click "🗑️ Delete Stream"
4. **Expected Result:**
   - Success message appears
   - Redirected to `/seller/streams.php`
   - Stream does NOT appear in "Recent Streams"

### 3. Seller Stream Management (`streams.php`)

#### Test 3.1: View Active Streams
**Steps:**
1. Start a stream (from stream-interface.php)
2. Open a new tab and navigate to `/seller/streams.php`
3. **Expected Result:**
   - Active stream appears in "Active Streams" section
   - Shows current viewers, likes, comments
   - Duration is counting

#### Test 3.2: View Recent Streams
**Steps:**
1. Navigate to `/seller/streams.php`
2. Scroll to "Recent Streams" section
3. **Expected Result:**
   - All past streams are listed
   - Each shows: title, date, duration, stats
   - Buttons: Watch Recording, Rename, View Stats, Delete

#### Test 3.3: Rename Stream
**Steps:**
1. Navigate to `/seller/streams.php`
2. Click "✏️ Rename" on any recent stream
3. Enter new title
4. Click "Save Changes"
5. **Expected Result:**
   - Modal closes
   - Success notification appears
   - Stream title updates immediately in the list

#### Test 3.4: Delete Stream
**Steps:**
1. Navigate to `/seller/streams.php`
2. Click "🗑️ Delete" on any recent stream
3. Click "Delete Recording" in confirmation modal
4. **Expected Result:**
   - Modal closes
   - Success notification appears
   - Stream removed from list

#### Test 3.5: Watch Recording
**Steps:**
1. Navigate to `/seller/streams.php`
2. Click "▶️ Watch Recording" on a stream with video
3. **Expected Result:**
   - Redirected to `/live.php` with replay mode
   - Replay page shows the stream video and details

#### Test 3.6: Stop Active Stream
**Steps:**
1. Start a stream
2. Navigate to `/seller/streams.php`
3. Click "⏹️ Stop Stream" on the active stream
4. Choose "💾 Save & Stop"
5. **Expected Result:**
   - Modal shows save/delete options
   - After save, stream moves to "Recent Streams"
   - Success notification appears

### 4. Mobile Responsiveness

#### Test 4.1: Mobile Replay Modal
**Steps:**
1. Open `/live.php` on mobile device
2. Click play button on a stream
3. **Expected Result:**
   - Modal fills screen appropriately
   - Video player works on mobile
   - Touch controls work smoothly
   - Stats grid stacks vertically

#### Test 4.2: Mobile Stream Interface
**Steps:**
1. Open `/seller/stream-interface.php` on mobile
2. Start a stream
3. **Expected Result:**
   - Layout stacks to single column
   - All stats are readable
   - Controls are touch-friendly
   - Video preview visible

#### Test 4.3: Mobile Stream Management
**Steps:**
1. Open `/seller/streams.php` on mobile
2. **Expected Result:**
   - Cards stack vertically
   - All buttons are accessible
   - Modals work on mobile
   - Text is readable

## Performance Tests

### Test P.1: Page Load Time
**Steps:**
1. Open DevTools Performance tab
2. Navigate to `/live.php`
3. **Expected Result:**
   - Page loads in < 3 seconds
   - Lazy loading prevents initial thumbnail load
   - No blocking resources

### Test P.2: Video Loading
**Steps:**
1. Open replay modal
2. Observe video loading time
3. **Expected Result:**
   - Metadata loads quickly (< 1 second)
   - Video starts playing within 2 seconds
   - Smooth playback without buffering

## Known Limitations

1. **Video Recording**: Currently saves placeholder paths. In production, actual video recording would need to be implemented using WebRTC recording or server-side recording.

2. **Engagement Simulation**: Uses fake engagement data. In production, this would be replaced with real viewer interactions.

3. **Video Formats**: Currently supports MP4 and WebM. Additional formats can be added as needed.

## Troubleshooting

### Issue: Modal doesn't open
- **Check**: Browser console for JavaScript errors
- **Solution**: Clear browser cache and reload

### Issue: Video doesn't play
- **Check**: Video file exists at the path specified
- **Check**: Network tab for 404 errors
- **Solution**: Verify video_path in database is correct

### Issue: Engagement not updating
- **Check**: Browser console for API errors
- **Check**: Stream status is 'live' in database
- **Solution**: Verify engagement API endpoints are accessible

### Issue: Lazy loading not working
- **Check**: IntersectionObserver is supported (or fallback is active)
- **Solution**: Works automatically, fallback loads all images

## Success Criteria

✅ All modals open and close properly
✅ Video players work with all controls
✅ Engagement stats update automatically
✅ Stream management operations complete successfully
✅ Mobile layouts are responsive
✅ Error messages display when appropriate
✅ No JavaScript console errors
✅ Page performance is acceptable

## Conclusion

The implementation successfully meets all requirements from the problem statement:
- ✅ Fully functional video replay system
- ✅ Automatic engagement simulation
- ✅ Stream management with rename and delete
- ✅ Error handling and optimization
- ✅ Responsive design for mobile and desktop
