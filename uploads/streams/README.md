# Stream Recordings Directory

This directory stores recorded live streams for replay functionality.

## Directory Structure

```
/uploads/streams/
├── {seller_id}/
│   ├── {stream_id}.mp4
│   ├── {stream_id}_thumbnail.jpg (optional)
│   └── ...
└── ...
```

## Video Format

- **Container**: MP4
- **Video Codec**: H.264 (for broad compatibility)
- **Audio Codec**: AAC
- **Resolution**: 1080p or 720p (depending on stream quality)

## Permissions

Ensure this directory is writable by the web server:
```bash
chmod 755 /uploads/streams
```

## HLS Support (Optional)

For advanced streaming, HLS variants can be generated:
- `/uploads/streams/{seller_id}/{stream_id}/playlist.m3u8`
- `/uploads/streams/{seller_id}/{stream_id}/segments/*.ts`

## Cleanup

Old recordings can be cleaned up periodically based on retention policy.
