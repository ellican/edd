# HLS Streaming Setup Guide

This document provides configuration details for setting up HLS (HTTP Live Streaming) for the FezaMarket live streaming feature.

## Overview

The live streaming system uses HLS (HTTP Live Streaming) to deliver video content to viewers. HLS requires proper server configuration to serve `.m3u8` playlist files and `.ts` segment files with appropriate CORS headers.

## Nginx Configuration

If you're using Nginx to serve HLS content, add the following configuration to your server block:

```nginx
# HLS streaming location
location /streams/hls/ {
    alias /var/www/hls/;
    
    # Add CORS headers for cross-origin requests
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, HEAD, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Range' always;
    add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;
    
    # Handle preflight requests
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, HEAD, OPTIONS';
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        return 204;
    }
    
    # HLS-specific settings
    types {
        application/vnd.apple.mpegurl m3u8;
        video/mp2t ts;
    }
    
    # Cache control
    add_header Cache-Control 'no-cache' always;
    
    # Enable gzip for m3u8 files
    gzip on;
    gzip_types application/vnd.apple.mpegurl;
}
```

## Apache Configuration

If you're using Apache with mod_headers, add the following to your `.htaccess` or virtual host configuration:

```apache
# Enable CORS for HLS streaming
<IfModule mod_headers.c>
    <FilesMatch "\.(m3u8|ts)$">
        Header set Access-Control-Allow-Origin "*"
        Header set Access-Control-Allow-Methods "GET, HEAD, OPTIONS"
        Header set Access-Control-Allow-Headers "Range"
        Header set Access-Control-Expose-Headers "Content-Length,Content-Range"
        Header set Cache-Control "no-cache"
    </FilesMatch>
</IfModule>

# Set correct MIME types
<IfModule mod_mime.c>
    AddType application/vnd.apple.mpegurl .m3u8
    AddType video/mp2t .ts
</IfModule>

# Handle OPTIONS requests
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} OPTIONS
    RewriteRule ^(.*)$ $1 [R=204,L]
</IfModule>
```

## Directory Structure

The HLS files should be organized as follows:

```
/var/www/hls/
├── stream_1_1234567890_abc123/
│   ├── playlist.m3u8          # Master playlist
│   ├── segment0000.ts         # Video segment 0
│   ├── segment0001.ts         # Video segment 1
│   └── ...
├── stream_2_1234567891_def456/
│   ├── playlist.m3u8
│   └── ...
```

Each stream has its own directory named after the `stream_key` from the database.

## Stream URL Format

The frontend expects stream URLs in the following format:

```
/streams/hls/{stream_key}/playlist.m3u8
```

For example:
```
/streams/hls/stream_1_1234567890_abc123/playlist.m3u8
```

## Testing CORS Configuration

You can test if CORS is properly configured using curl:

```bash
# Test a playlist file
curl -I -H "Origin: https://yourdomain.com" \
  https://yourdomain.com/streams/hls/stream_1_1234567890_abc123/playlist.m3u8

# Check for Access-Control-Allow-Origin header in response
```

Or use the browser console:

```javascript
fetch('/streams/hls/test_stream/playlist.m3u8', {
  method: 'GET',
  mode: 'cors'
})
.then(response => console.log('CORS OK:', response.headers.get('Access-Control-Allow-Origin')))
.catch(error => console.error('CORS Error:', error));
```

## Troubleshooting

### Issue: "Unable to Load Stream" Error

**Symptoms:** Video player shows "Unable to Load Stream" message.

**Solutions:**
1. Check that the stream URL is correct and accessible
2. Verify CORS headers are present in the response
3. Check browser console for detailed error messages
4. Ensure the `.m3u8` file and `.ts` segments exist on the server
5. Verify file permissions (should be readable by web server)

### Issue: Stream Plays for a Few Seconds Then Stops

**Symptoms:** Video starts playing but stops after a few seconds.

**Solutions:**
1. Check that all `.ts` segment files are accessible
2. Verify the playlist is being updated during live streaming
3. Check server logs for errors
4. Ensure sufficient disk space for HLS segments

### Issue: CORS Errors in Console

**Symptoms:** Browser console shows CORS-related errors.

**Solutions:**
1. Verify CORS headers are configured in web server
2. Check that headers are being sent for both `.m3u8` and `.ts` files
3. Ensure OPTIONS requests are handled correctly
4. Test with curl to verify headers

### Issue: High Latency / Delayed Stream

**Symptoms:** Live stream has significant delay from actual broadcast.

**Solutions:**
1. Reduce segment duration (default is 6 seconds)
2. Decrease the number of segments in the playlist
3. Use `liveSyncDuration` parameter in HLS.js configuration
4. Consider using LL-HLS (Low-Latency HLS) if supported

## Performance Optimization

### Segment Duration
- Default: 6 seconds
- For lower latency: 2-4 seconds
- For better bandwidth efficiency: 10 seconds

### Playlist Size
- Keep 3-5 segments for live streaming
- More segments = higher latency but better seeking

### CDN Integration
For production, consider using a CDN to distribute HLS content:
- CloudFront (AWS)
- CloudFlare Stream
- Fastly
- Akamai

## Security Considerations

### Token-Based Access
For private streams, implement token-based authentication:

```nginx
location /streams/hls/ {
    # Validate token from query parameter
    if ($arg_token = "") {
        return 403;
    }
    
    # Your HLS configuration here...
}
```

### Rate Limiting
Prevent abuse with rate limiting:

```nginx
limit_req_zone $binary_remote_addr zone=hls_limit:10m rate=10r/s;

location /streams/hls/ {
    limit_req zone=hls_limit burst=20;
    # Your HLS configuration here...
}
```

## Monitoring

Monitor the following metrics:
- Concurrent viewers per stream
- Bandwidth usage
- Error rates (404s, 5xxs)
- Average segment load time
- Buffer health

## References

- [HLS.js Documentation](https://github.com/video-dev/hls.js/)
- [Apple HLS Authoring Specification](https://developer.apple.com/documentation/http_live_streaming)
- [MDN Web Docs - CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

## Support

For issues or questions, please refer to:
- GitHub Issues
- Technical Documentation
- Support Team
