# Mux Live Streaming Integration Guide

This guide explains how to set up and use the Mux live streaming integration for the FezaMarket e-commerce platform.

## Overview

The platform integrates with [Mux](https://mux.com) to provide professional live streaming capabilities with:
- **RTMP Ingestion**: Sellers can stream using OBS Studio or any RTMP-compatible software
- **HLS Playback**: Viewers watch streams via adaptive HLS streaming
- **Low Latency**: Reduced latency mode for real-time interaction
- **Automatic Replay**: Streams are automatically saved for on-demand viewing
- **Analytics**: Mux Data SDK tracks viewer engagement and video quality

## Setup Instructions

### 1. Create a Mux Account

1. Sign up at [https://dashboard.mux.com/signup](https://dashboard.mux.com/signup)
2. Complete your account setup

### 2. Get API Credentials

1. Go to [https://dashboard.mux.com/settings/access-tokens](https://dashboard.mux.com/settings/access-tokens)
2. Click "Generate new token"
3. Select permissions:
   - ✅ Mux Video: Full Access
   - ✅ Mux Data: Read
4. Copy your **Token ID** and **Token Secret**
5. Keep these credentials secure - never commit them to version control

### 3. Get Environment Key for Analytics

1. Go to [https://dashboard.mux.com/environments](https://dashboard.mux.com/environments)
2. Select your environment (or create a new one)
3. Copy the **Environment Key** (starts with `env_`)

### 4. Get Webhook Secret (Optional)

1. Go to [https://dashboard.mux.com/settings/webhooks](https://dashboard.mux.com/settings/webhooks)
2. Create a new webhook pointing to `https://yourdomain.com/api/webhooks/mux.php`
3. Copy the **Signing Secret**

### 5. Configure Environment Variables

Add the following to your `.env` file:

```env
# Mux Live Streaming Configuration
MUX_TOKEN_ID=your_token_id_here
MUX_TOKEN_SECRET=your_token_secret_here
MUX_ENVIRONMENT_KEY=your_environment_key_here
MUX_WEBHOOK_SECRET=your_webhook_secret_here
```

### 6. Run Database Migration

Execute the migration to add Mux-specific fields to the database:

```bash
php database/migrations/add_mux_fields_to_live_streams.php
```

This adds:
- `mux_stream_id` - Mux live stream ID
- `mux_playback_id` - Mux playback ID for HLS URLs

## How It Works

### For Sellers (Stream Creation)

1. **Create Stream**
   - Seller goes to `/seller/live.php`
   - Clicks "Go Live Now"
   - Enters stream title and description
   - System calls Mux API to create a live stream
   - Seller receives RTMP credentials

2. **Stream Configuration**
   - RTMP Server: `rtmps://global-live.mux.com:443/app`
   - Stream Key: Unique key from Mux API
   - These credentials are used in OBS Studio or other streaming software

3. **Broadcasting**
   - Seller configures OBS with RTMP credentials
   - Clicks "Start Streaming" in OBS
   - Stream becomes available to viewers within seconds

4. **Ending Stream**
   - Seller stops streaming in OBS
   - System marks stream as archived
   - Mux automatically creates a replay asset

### For Viewers (Stream Playback)

1. **Live Viewing**
   - Viewers visit `/live.php`
   - Video.js player loads with Mux HLS URL
   - Format: `https://stream.mux.com/{playback_id}.m3u8`
   - Adaptive streaming adjusts quality based on connection

2. **Analytics Tracking**
   - Mux Data SDK tracks:
     - Viewer engagement
     - Video quality metrics
     - Buffering events
     - Playback errors
   - Data available in Mux dashboard

3. **Replay Viewing**
   - After stream ends, same URL serves replay
   - No configuration needed - automatic
   - Replay available immediately

## API Endpoints

### Create Mux Live Stream
```
POST /api/streams/create-mux.php
```

**Request Body:**
```json
{
  "title": "Product Launch Event",
  "description": "Join us for exclusive deals!",
  "chat_enabled": 1
}
```

**Response:**
```json
{
  "success": true,
  "stream_id": 123,
  "rtmp_credentials": {
    "rtmp_url": "rtmps://global-live.mux.com:443/app",
    "stream_key": "abc123..."
  },
  "playback_url": "https://stream.mux.com/xyz789.m3u8"
}
```

### Start Stream
```
POST /api/streams/start.php
```

### End Stream
```
POST /api/streams/end.php
```

**Request Body:**
```json
{
  "stream_id": 123,
  "action": "save"
}
```

### Delete Stream
```
POST /api/streams/delete.php
```

**Request Body:**
```json
{
  "stream_id": 123
}
```

## OBS Studio Setup

1. **Install OBS Studio**
   - Download from [https://obsproject.com/](https://obsproject.com/)
   - Install and launch

2. **Configure Stream Settings**
   - Go to Settings → Stream
   - Service: Custom
   - Server: `rtmps://global-live.mux.com:443/app`
   - Stream Key: [Your stream key from the platform]

3. **Configure Output Settings**
   - Go to Settings → Output
   - Output Mode: Advanced
   - Encoder: x264 (CPU) or NVENC (GPU)
   - Rate Control: CBR
   - Bitrate: 3000-6000 Kbps (depending on upload speed)

4. **Configure Video Settings**
   - Go to Settings → Video
   - Base Resolution: 1920x1080
   - Output Resolution: 1280x720 or 1920x1080
   - FPS: 30 or 60

5. **Start Streaming**
   - Click "Start Streaming"
   - Stream will be live within 5-10 seconds

## Video.js Integration

The platform uses Video.js for HLS playback with Mux integration:

```javascript
// Initialize Video.js player
const player = videojs('liveStreamVideo', {
    controls: true,
    autoplay: 'muted',
    preload: 'auto',
    fluid: true,
    responsive: true,
    liveui: true
});

// Initialize Mux Data SDK
window.initVideoJsMux(player, {
    data: {
        env_key: 'YOUR_MUX_ENV_KEY',
        player_name: 'FezaMarket Live Player',
        video_id: 'stream-123',
        video_title: 'Product Launch Event',
        video_stream_type: 'live'
    }
});
```

## Mux Data SDK Analytics

Events tracked by Mux Data SDK:

- **Playback Events**: play, pause, ended
- **Quality Metrics**: video startup time, rebuffering ratio
- **Engagement**: watch time, completion rate
- **Errors**: playback errors, network issues

View analytics at: [https://dashboard.mux.com/data](https://dashboard.mux.com/data)

## Security Best Practices

1. **Protect API Credentials**
   - Never commit `.env` file to version control
   - Use environment variables in production
   - Rotate credentials periodically

2. **Secure Stream Keys**
   - Stream keys are sensitive - treat like passwords
   - Only show to authorized sellers
   - Implement rate limiting on API endpoints

3. **Validate Input**
   - Sanitize all user inputs
   - Validate stream ownership before operations
   - Use prepared statements for database queries

4. **HTTPS Only**
   - All API calls use HTTPS
   - RTMPS (RTMP over TLS) for streaming
   - Secure cookie flags enabled

## Troubleshooting

### Stream Not Appearing
- Check if stream key is correct in OBS
- Verify RTMP URL is `rtmps://global-live.mux.com:443/app`
- Check Mux dashboard for stream status
- Review browser console for errors

### Playback Issues
- Check HLS URL is accessible: `https://stream.mux.com/{playback_id}.m3u8`
- Verify Video.js is loaded correctly
- Check browser console for errors
- Test in multiple browsers

### Analytics Not Working
- Verify `MUX_ENVIRONMENT_KEY` is set in `.env`
- Check meta tag is present: `<meta name="mux-env-key" content="...">`
- Ensure Mux Data SDK script is loaded
- Review Mux dashboard for data

### API Errors
- Check API credentials in `.env`
- Verify database migration was run
- Review PHP error logs
- Test with Mux API directly using curl

## Cost Considerations

Mux pricing (as of 2024):
- **Live Streaming**: ~$0.015 per delivered GB
- **Video Storage**: ~$0.05 per GB per month
- **Mux Data**: Free tier available, paid plans for advanced features

Monitor usage at: [https://dashboard.mux.com/usage](https://dashboard.mux.com/usage)

## Additional Resources

- [Mux Documentation](https://docs.mux.com/)
- [Mux API Reference](https://docs.mux.com/api-reference)
- [Video.js Documentation](https://docs.videojs.com/)
- [OBS Studio Documentation](https://obsproject.com/wiki/)
- [Mux Data SDK](https://docs.mux.com/guides/data/monitor-videojs)

## Support

For issues or questions:
- Check Mux documentation
- Review error logs in PHP and browser console
- Contact Mux support: [https://mux.com/support](https://mux.com/support)
- Open an issue in the repository

## License

This integration is part of the FezaMarket platform and follows the same license terms.
