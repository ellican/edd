# Quick Start Guide - Stream Engagement & Replay Fixes

## 🚀 Installation (2 minutes)

### Step 1: Run the Migration
```bash
cd /home/runner/work/edd/edd
php run_engagement_migration.php
```

Expected output:
```
✅ Migration completed successfully!
Stream engagement tables are now ready
```

### Step 2: Validate Installation
```bash
php validate_stream_engagement_system.php
```

Expected output:
```
✅ All critical checks passed!
```

## ✅ That's it! The fixes are now active.

---

## 🧪 Quick Test

### Test Engagement (30 seconds)
1. Go to `/live.php` with an active stream
2. Watch the viewer count increase every few seconds
3. Should see: 0 → 5 → 12 → 18 → 25...

### Test Replay (15 seconds)
1. Go to `/live.php`
2. Scroll to "Recent Streams"
3. Click any archived stream
4. Video player should load

---

## 📖 What Changed?

### Problem 1: Engagement Stuck at 0
**Before:** Viewer/like counts stayed at 0
**After:** Counts increase automatically every 5-15 seconds

### Problem 2: Replay Broken
**Before:** Clicking replay just refreshed the page
**After:** Opens video player with stream details

---

## 🔧 Troubleshooting

### Engagement still shows 0?
```bash
# Check if migration ran
php validate_stream_engagement_system.php

# Try manual trigger
curl http://localhost/api/streams/engagement.php?stream_id=1
```

### Replay still not working?
1. Check stream has `status = 'archived'` in database
2. Check stream has `video_path` or `stream_url`
3. Try direct URL: `/live.php?stream=1&replay=1`

---

## 📚 Full Documentation

- **Complete Guide:** `STREAM_ENGAGEMENT_REPLAY_FIX.md`
- **Interactive Demo:** `test-stream-fixes.html`
- **Validation Script:** `validate_stream_engagement_system.php`

---

## 🎯 Key Files Modified

- `live.php` - Added replay mode
- `templates/stream-replay.php` - NEW (replay UI)
- `database/migrations/057_add_is_fake_to_stream_tables.php` - NEW (migration)

---

## 💡 Quick Facts

- ✅ Backward compatible (existing streams work)
- ✅ Auto-saves final counts when stream ends
- ✅ Works with real + fake engagement
- ✅ No changes needed to existing code
- ✅ Just run migration and go!

---

## 📞 Need Help?

1. Check validation: `php validate_stream_engagement_system.php`
2. Check logs: Browser console + server logs
3. Read full guide: `STREAM_ENGAGEMENT_REPLAY_FIX.md`
