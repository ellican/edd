# Live Stream Fix - Quick Start Guide

## What This PR Does

This PR fixes two critical issues with live streaming:

1. **SQL Error Fix**: Resolves "Field 'stream_key' doesn't have a default value" 
2. **Engagement System**: Adds simulated real-time engagement with admin controls

## Quick Installation

### Step 1: Apply Migration (Required)
```bash
cd /path/to/edd
php run_stream_key_migration.php
```

### Step 2: Validate Setup (Optional)
```bash
php validate_stream_engagement.php
```

### Step 3: Configure Settings (Optional)
1. Login to admin panel
2. Go to `/admin/streaming/`
3. Click "Stream Settings"
4. Adjust engagement parameters
5. Click "Save Settings"

## That's It! 🎉

Your live streaming system is now ready with:
- ✅ No more SQL errors
- ✅ Automatic engagement simulation
- ✅ Real-time viewer/like counts
- ✅ Admin configuration panel

## Default Settings

If you skip Step 3, these defaults apply:
- **Min Viewers**: 15
- **Max Viewers**: 100
- **Increase Rate**: 5 per minute
- **Like Rate**: 3 per minute
- **Multiplier**: 2.0x

## Need More Info?

- **Full Guide**: See `LIVE_STREAM_ENGAGEMENT_GUIDE.md`
- **PR Summary**: See `PR_SUMMARY_LIVE_STREAMING.md`
- **Flow Diagram**: See `ENGAGEMENT_SYSTEM_FLOW.md`

## Troubleshooting

**Problem**: Migration fails
```bash
# Check MySQL is running
sudo systemctl status mysql

# Check permissions
ls -la migrations/
```

**Problem**: Settings won't save
```bash
# Check you're logged in as admin
# Check browser console for errors
```

**Problem**: Engagement not working
```bash
# Validate setup
php validate_stream_engagement.php

# Check stream status is 'live'
# Verify JavaScript console for errors
```

## Support

Run the validation script to diagnose issues:
```bash
php validate_stream_engagement.php
```

This will check all components and tell you exactly what's wrong.
