# Enhanced Live Streaming System - Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     ENHANCED LIVE STREAMING SYSTEM                   │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐         ┌──────────────────────┐
│   SELLER INTERFACE   │         │   PUBLIC LIVE PAGE   │
│  /seller/stream-     │         │     /live.php        │
│   interface.php      │         │                      │
└──────────┬───────────┘         └──────────┬───────────┘
           │                                │
           │ POST start                     │ GET list (poll 30s)
           │ GET engagement (15s)           │ GET engagement
           │ POST end                       │
           │                                │
           ▼                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          API LAYER                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐    │
│  │  start.php      │  │ engagement.php  │  │   end.php       │    │
│  │ - Create stream │  │ - Fake viewers  │  │ - Save/Delete   │    │
│  │ - Mark as live  │  │ - Fake likes    │  │ - Update stats  │    │
│  │ - Init config   │  │ - Update counts │  │ - Archive       │    │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘    │
│                                                                       │
│  ┌─────────────────┐                                                 │
│  │   list.php      │                                                 │
│  │ - Active        │                                                 │
│  │ - Scheduled     │                                                 │
│  │ - Recent        │                                                 │
│  └─────────────────┘                                                 │
│                                                                       │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     DATABASE LAYER                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ live_streams                                                  │   │
│  ├───────────────────────────────────────────────────────────────┤  │
│  │ id, vendor_id, title, description, thumbnail_url             │   │
│  │ status: scheduled | live | ended | archived | cancelled       │   │
│  │ viewer_count, like_count, dislike_count, comment_count       │   │
│  │ video_path, stream_url                                        │   │
│  │ scheduled_at, started_at, ended_at                            │   │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ stream_viewers                                                │   │
│  ├───────────────────────────────────────────────────────────────┤  │
│  │ id, stream_id, user_id, session_id                           │   │
│  │ is_fake (0=real, 1=fake)                                     │   │
│  │ joined_at, left_at, watch_duration                           │   │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ stream_interactions                                           │   │
│  ├───────────────────────────────────────────────────────────────┤  │
│  │ id, stream_id, user_id                                       │   │
│  │ interaction_type: like | dislike | comment | share           │   │
│  │ comment_text, is_fake                                        │   │
│  │ created_at                                                    │   │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ stream_engagement_config                                      │   │
│  ├───────────────────────────────────────────────────────────────┤  │
│  │ stream_id, fake_viewers_enabled, fake_likes_enabled          │   │
│  │ min_fake_viewers, max_fake_viewers                           │   │
│  │ viewer_increase_rate, viewer_decrease_rate                   │   │
│  │ like_rate, engagement_multiplier                             │   │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ saved_streams                                                 │   │
│  ├───────────────────────────────────────────────────────────────┤  │
│  │ id, stream_id, vendor_id, title, description                 │   │
│  │ video_url, thumbnail_url, duration                           │   │
│  │ viewer_count, like_count, total_revenue                      │   │
│  │ streamed_at, saved_at, views_count                           │   │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                      ENGAGEMENT FLOW                                 │
└─────────────────────────────────────────────────────────────────────┘

  Seller Starts Stream
         │
         ▼
  Create live_streams record (status='live')
         │
         ▼
  Initialize stream_engagement_config
         │
         ▼
  Trigger Initial Engagement
         │
         ▼
  ┌──────────────────────────────────────┐
  │  Every 15 seconds during stream:     │
  │  1. Generate fake viewers            │
  │  2. Generate fake likes              │
  │  3. Update live_streams counts       │
  └──────────────────────────────────────┘
         │
         ▼
  Display on /live.php (auto-refresh 30s)
         │
         ▼
  Seller Ends Stream → Save or Delete?
         │
         ├─────────────┬─────────────┐
         │             │             │
         ▼             ▼             ▼
      SAVE         DELETE        CANCEL
         │             │
         ▼             ▼
  status='archived'  status='ended'
  Saved in          Hidden from
  saved_streams     public view
         │
         ▼
  Appears in Recent Streams
  (with preserved engagement)

┌─────────────────────────────────────────────────────────────────────┐
│                      STREAM LIFECYCLE                                │
└─────────────────────────────────────────────────────────────────────┘

  CREATE
    │
    ▼
┌──────────┐      Seller clicks      ┌──────────┐
│SCHEDULED │─────  "Go Live"  ────────▶│   LIVE   │
└──────────┘                           └──────────┘
                                            │
                                            │ Seller ends
                                            ▼
                                     ┌──────────────┐
                                     │   Choose:    │
                                     │ Save/Delete  │
                                     └──────┬───────┘
                                            │
                          ┌─────────────────┼─────────────────┐
                          │                 │                 │
                          ▼                 ▼                 ▼
                    ┌──────────┐      ┌──────────┐     ┌──────────┐
                    │ ARCHIVED │      │  ENDED   │     │CANCELLED │
                    │(w/replay)│      │ (hidden) │     │          │
                    └──────────┘      └──────────┘     └──────────┘
                          │
                          ▼
                  Recent Streams
                  (playable)

┌─────────────────────────────────────────────────────────────────────┐
│                    UI/UX STRUCTURE                                   │
└─────────────────────────────────────────────────────────────────────┘

/live.php Layout:
┌─────────────────────────────────────────────────────────────────────┐
│                        🔴 FezaMarket Live                            │
│              Shop live events, exclusive deals, and more             │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  🔴 Live Now                                  [3 live events]        │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────┐  ┌──────────┐  ┌──────────┐             │
│  │   Main Stream        │  │  Mini    │  │  Mini    │             │
│  │   [Video Preview]    │  │  Stream  │  │  Stream  │             │
│  │   👥 123 watching    │  │  👥 45   │  │  👥 67   │             │
│  │   👍 89  👎 2        │  └──────────┘  └──────────┘             │
│  │   [Chat] [Products]  │                                           │
│  └──────────────────────┘                                           │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  📅 Upcoming Live Events                                             │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │ In 2h 30m    │  │ Tomorrow 2PM │  │ Sat 10:00 AM │             │
│  │ Jewelry Show │  │ Gaming Gear  │  │ Kitchen Demo │             │
│  │ 👤 Maria R.  │  │ 👤 GameMaster│  │ 👤 Chef A.   │             │
│  │ [🔔 Remind]  │  │ [🔔 Remind]  │  │ [🔔 Remind]  │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  📼 Recent Streams                                                   │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │[Thumb]   │  │[Thumb]   │  │[Thumb]   │  │[Thumb]   │           │
│  │ 🔴 REPLAY│  │ 🔴 REPLAY│  │ 🔴 REPLAY│  │ 🔴 REPLAY│           │
│  │ [▶️ Play] │  │ [▶️ Play] │  │ [▶️ Play] │  │ [▶️ Play] │           │
│  │ Title    │  │ Title    │  │ Title    │  │ Title    │           │
│  │ 👥 156   │  │ 👥 234   │  │ 👥 189   │  │ 👥 345   │           │
│  │ 👍 89    │  │ 👍 123   │  │ 👍 91    │  │ 👍 167   │           │
│  │ 1h 23m   │  │ 45m      │  │ 2h 15m   │  │ 58m      │           │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘           │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                     KEY METRICS                                      │
└─────────────────────────────────────────────────────────────────────┘

Auto-Engagement:
  • Triggers every 15 seconds during live stream
  • Adds 1-5 fake viewers per cycle
  • Adds 0-3 likes per cycle
  • Based on configurable multipliers

Real-time Updates:
  • Page polls every 30 seconds for stream status
  • Engagement counts update in real-time
  • New streams appear without page refresh

Persistence:
  • All engagement data saved to database
  • Counts preserved after stream ends
  • Available for replay with same stats

Performance:
  • Indexed queries for fast lookups
  • Minimal database overhead
  • Efficient engagement generation
