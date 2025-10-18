# Live Stream Engagement System - Visual Flow Diagram

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        LIVE STREAMING PLATFORM                           │
└─────────────────────────────────────────────────────────────────────────┘

┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│   SELLER STARTS   │────▶│  STREAM CREATION  │────▶│   STREAM LIVE     │
│      STREAM       │     │   (API CALL)      │     │   (STATUS=LIVE)   │
└───────────────────┘     └───────────────────┘     └───────────────────┘
                                   │                           │
                                   ▼                           ▼
                          ┌──────────────────┐      ┌──────────────────┐
                          │ Generate Unique  │      │ Initialize Fake  │
                          │   stream_key     │      │   Engagement     │
                          │                  │      │   Config         │
                          └──────────────────┘      └──────────────────┘
                                   │                           │
                                   ▼                           ▼
                          ┌──────────────────┐      ┌──────────────────┐
                          │ Store in DB:     │      │ Load Global      │
                          │ vendor_456_      │      │ Settings:        │
                          │ 1697623456_a3f   │      │ - min: 15        │
                          └──────────────────┘      │ - max: 100       │
                                                    │ - rate: 5/min    │
                                                    └──────────────────┘


┌─────────────────────────────────────────────────────────────────────────┐
│                     REAL-TIME ENGAGEMENT FLOW                            │
└─────────────────────────────────────────────────────────────────────────┘

  ┌──────────────┐                                        ┌──────────────┐
  │   SELLER     │                                        │   VIEWERS    │
  │  Interface   │                                        │  (Public)    │
  └──────┬───────┘                                        └──────┬───────┘
         │                                                       │
         │ Every 5 sec                                Every 10 sec │
         ▼                                                       ▼
  ┌──────────────────────────────────────────────────────────────────────┐
  │              GET /api/live/stats.php?stream_id=123                   │
  │              GET /api/streams/engagement.php?stream_id=123           │
  └──────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
         ┌──────────────────────────────────────────────────┐
         │      FakeEngagementGenerator::generateFake()     │
         │                                                  │
         │  1. Get current viewer count (real + fake)      │
         │  2. Calculate target based on multiplier         │
         │  3. Add/remove viewers to reach target           │
         │  4. Add random likes based on viewer count       │
         │  5. Update database counts                       │
         └──────────────────────────────────────────────────┘
                                   │
                  ┌────────────────┴────────────────┐
                  ▼                                 ▼
    ┌──────────────────────┐          ┌──────────────────────┐
    │  stream_viewers      │          │ stream_interactions  │
    │  ─────────────────   │          │  ──────────────────  │
    │  INSERT fake         │          │  INSERT fake likes   │
    │  viewers with        │          │  with is_fake=1      │
    │  is_fake=1           │          │                      │
    └──────────────────────┘          └──────────────────────┘
                  │                                 │
                  └────────────────┬────────────────┘
                                   ▼
                  ┌──────────────────────────────────┐
                  │   UPDATE live_streams SET:       │
                  │   viewer_count = COUNT(viewers)  │
                  │   like_count = COUNT(likes)      │
                  │   max_viewers = MAX(count)       │
                  └──────────────────────────────────┘
                                   │
                  ┌────────────────┴────────────────┐
                  ▼                                 ▼
         ┌────────────────┐               ┌────────────────┐
         │ Return to      │               │ Return to      │
         │ Seller:        │               │ Viewers:       │
         │ - Viewers: 47  │               │ - Viewers: 47  │
         │ - Likes: 23    │               │ - Likes: 23    │
         │ - Revenue: $0  │               │ - Duration     │
         └────────────────┘               └────────────────┘


┌─────────────────────────────────────────────────────────────────────────┐
│                     REAL USER ENGAGEMENT                                 │
└─────────────────────────────────────────────────────────────────────────┘

  User clicks "Like" on stream
          │
          ▼
  POST /api/live/interact.php
  { action: "like", stream_id: 123 }
          │
          ▼
  INSERT INTO stream_interactions
  (stream_id, user_id, interaction_type, is_fake)
  VALUES (123, 789, 'like', 0)  ◄── is_fake = 0 for REAL
          │
          ▼
  UPDATE live_streams
  SET like_count = (
    SELECT COUNT(*) 
    FROM stream_interactions
    WHERE stream_id = 123 
    AND interaction_type = 'like'
  )  ◄── Includes BOTH real (is_fake=0) AND fake (is_fake=1)
          │
          ▼
  Return { success: true, count: 24 }  ◄── 23 fake + 1 real = 24


┌─────────────────────────────────────────────────────────────────────────┐
│                     ENGAGEMENT CALCULATION                               │
└─────────────────────────────────────────────────────────────────────────┘

Real Viewers: 10 (actual users watching)
Multiplier: 2.0
Min: 15, Max: 100

Step 1: Calculate Target
  target = real_viewers × multiplier
  target = 10 × 2.0 = 20
  target = max(15, min(100, 20)) = 20

Step 2: Current State
  current_fake = 18 (from database)
  difference = 20 - 18 = 2

Step 3: Adjust Gradually
  increase_rate = 5 per minute
  actual_add = random(1, min(5, 2)) = 2
  
Step 4: Add Fake Viewers
  INSERT 2 fake viewers into stream_viewers
  
Step 5: Final Count
  Total viewers = 10 real + 20 fake = 30 DISPLAYED


┌─────────────────────────────────────────────────────────────────────────┐
│                     ADMIN CONFIGURATION                                  │
└─────────────────────────────────────────────────────────────────────────┘

  Admin opens /admin/streaming/
          │
          ▼
  Clicks "Stream Settings" button
          │
          ▼
  Modal loads GET /api/admin/streams/get-settings.php
          │
          ▼
  ┌────────────────────────────────────────────┐
  │  ENGAGEMENT SIMULATION SETTINGS            │
  │  ────────────────────────────────────────  │
  │                                            │
  │  [✓] Enable Simulated Viewers              │
  │      Min: [15]  Max: [100]                │
  │      Increase: [5/min]  Decrease: [3/min] │
  │                                            │
  │  [✓] Enable Simulated Likes                │
  │      Rate: [3/min]                         │
  │                                            │
  │  Engagement Multiplier: [2.0]              │
  │                                            │
  │  [ Cancel ]  [ Save Settings ]             │
  └────────────────────────────────────────────┘
          │
          ▼
  POST /api/admin/streams/save-settings.php
  { fake_viewers_enabled: 1, min_fake_viewers: 15, ... }
          │
          ▼
  INSERT/UPDATE global_stream_settings
  (setting_key, setting_value)
          │
          ▼
  Next stream created will use these settings!


┌─────────────────────────────────────────────────────────────────────────┐
│                     STREAM END FLOW                                      │
└─────────────────────────────────────────────────────────────────────────┘

  Seller clicks "End Stream"
          │
          ▼
  POST /api/streams/end.php
  { stream_id: 123, action: "save" }
          │
          ▼
  ┌────────────────────────────────────────────┐
  │  UPDATE live_streams SET:                  │
  │  - status = 'ended'                        │
  │  - ended_at = NOW()                        │
  │  - viewer_count = 47 (FINAL, real+fake)    │
  │  - like_count = 89 (FINAL, real+fake)      │
  │  - max_viewers = 52 (peak during stream)   │
  └────────────────────────────────────────────┘
          │
          ▼
  Optional: Copy to saved_streams for replay
          │
          ▼
  Stream available in analytics with final metrics!


┌─────────────────────────────────────────────────────────────────────────┐
│                     DATA SEPARATION                                      │
└─────────────────────────────────────────────────────────────────────────┘

DISPLAY TO USERS:
  SELECT viewer_count FROM live_streams
  ▶ Shows: 47 (real + fake combined)

ANALYTICS (Admin):
  Real Viewers:
    SELECT COUNT(*) FROM stream_viewers 
    WHERE stream_id=123 AND is_fake=0
    ▶ Shows: 10

  Fake Viewers:
    SELECT COUNT(*) FROM stream_viewers 
    WHERE stream_id=123 AND is_fake=1
    ▶ Shows: 37

  Real Likes:
    SELECT COUNT(*) FROM stream_interactions 
    WHERE stream_id=123 AND interaction_type='like' AND is_fake=0
    ▶ Shows: 12

  Fake Likes:
    SELECT COUNT(*) FROM stream_interactions 
    WHERE stream_id=123 AND interaction_type='like' AND is_fake=1
    ▶ Shows: 77


┌─────────────────────────────────────────────────────────────────────────┐
│                     KEY COMPONENTS                                       │
└─────────────────────────────────────────────────────────────────────────┘

1. FakeEngagementGenerator (api/live/fake-engagement.php)
   - Generates fake viewers and likes
   - Uses probabilistic algorithms
   - Respects min/max bounds

2. Stream Settings (admin/streaming/index.php)
   - Visual configuration interface
   - Save/load functionality
   - Real-time preview

3. Engagement Trigger (api/streams/engagement.php)
   - Called every 5-10 seconds
   - Updates all metrics
   - Returns current stats

4. Real-time Polling (live.php, seller/stream-interface.php)
   - JavaScript intervals
   - AJAX requests
   - DOM updates

5. Database Integration
   - Separate tracking (is_fake flag)
   - Combined display counts
   - Audit trail preserved
