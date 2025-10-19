/**
 * Live Stream Video Player Component
 * Implements HLS.js for low-latency live streaming
 */

class LiveStreamPlayer {
    constructor(containerId, streamId) {
        this.container = document.getElementById(containerId);
        this.streamId = streamId;
        this.video = null;
        this.videoJsPlayer = null; // Video.js player instance
        this.hls = null;
        this.isLive = false;
        this.streamUrl = null;
        this.playbackId = null;
        this.useMux = false;
        this.retryCount = 0;
        this.maxRetries = 12; // Retry for up to 1 minute (12 * 5 seconds)
        this.retryInterval = 5000; // 5 seconds
        this.streamPlayable = false; // Track if stream is playable
        this.engagementStarted = false; // Track if engagement has started
        this.viewerTimer = null; // Timer for viewer count updates
        this.likeTimer = null; // Timer for like count updates
        this.statusTimer = null; // Timer for stream status monitoring
    }

    /**
     * Initialize the video player
     */
    async init() {
        try {
            console.log('🎬 Initializing live stream player for stream ID:', this.streamId);
            
            // Fetch stream information
            const streamData = await this.fetchStreamData();
            
            if (!streamData || !streamData.success) {
                console.log('⚠️ Stream data not available, starting retry mechanism');
                this.showWaitingMessage();
                this.retryStreamLoad();
                return;
            }

            this.streamUrl = streamData.stream_url;
            this.playbackId = streamData.playback_id || streamData.mux_playback_id;
            this.isLive = streamData.is_live;
            
            // Check if this is a Mux stream
            this.useMux = this.streamUrl && this.streamUrl.includes('stream.mux.com');
            
            console.log('📡 Stream URL:', this.streamUrl);
            console.log('🔴 Is Live:', this.isLive);
            console.log('🎬 Playback ID:', this.playbackId);
            console.log('🔧 Use Mux:', this.useMux);

            // Create video element
            if (this.useMux && typeof videojs !== 'undefined') {
                // Use Video.js for Mux streams
                console.log('🎥 Initializing Video.js player with Mux');
                this.initVideoJs();
            } else {
                // Use HLS.js or native player for non-Mux streams
                this.createVideoElement();

                // Initialize HLS if supported and URL is m3u8
                if (this.streamUrl && this.streamUrl.includes('.m3u8')) {
                    console.log('🎥 Initializing HLS player for .m3u8 stream');
                    this.initHLS();
                } else if (this.streamUrl) {
                    // Direct video source (MP4, WebM, etc.)
                    console.log('📹 Loading direct video source');
                    this.video.src = this.streamUrl;
                } else {
                    console.log('⏳ No stream URL available, showing waiting message');
                    this.showWaitingMessage();
                    this.retryStreamLoad();
                }
            }

        } catch (error) {
            console.error('❌ Failed to initialize player:', error);
            this.showError('Failed to load stream');
        }
    }
    
    /**
     * Retry loading the stream
     */
    async retryStreamLoad() {
        if (this.retryCount >= this.maxRetries) {
            console.log('❌ Max retries reached, giving up');
            this.showError('Stream is not available. Please check back later.');
            return;
        }
        
        this.retryCount++;
        console.log(`🔄 Retry attempt ${this.retryCount}/${this.maxRetries} in ${this.retryInterval/1000} seconds...`);
        
        setTimeout(async () => {
            try {
                const streamData = await this.fetchStreamData();
                
                if (streamData && streamData.success && streamData.stream_url) {
                    console.log('✅ Stream is now available, initializing player');
                    this.streamUrl = streamData.stream_url;
                    this.isLive = streamData.is_live;
                    this.createVideoElement();
                    
                    if (this.streamUrl.includes('.m3u8')) {
                        this.initHLS();
                    } else {
                        this.video.src = this.streamUrl;
                    }
                } else {
                    // Continue retrying
                    this.retryStreamLoad();
                }
            } catch (error) {
                console.error('❌ Error during retry:', error);
                this.retryStreamLoad();
            }
        }, this.retryInterval);
    }

    /**
     * Fetch stream data from API
     */
    async fetchStreamData() {
        const response = await fetch(`/api/streams/get.php?stream_id=${this.streamId}`);
        return await response.json();
    }

    /**
     * Initialize Video.js player with Mux integration
     */
    initVideoJs() {
        // Clear container
        this.container.innerHTML = '';
        
        // Create video element with Video.js classes
        this.video = document.createElement('video');
        this.video.id = 'liveStreamVideo';
        this.video.className = 'video-js vjs-default-skin vjs-big-play-centered';
        this.video.controls = true;
        this.video.autoplay = true;
        this.video.muted = true; // Required for autoplay
        this.video.playsInline = true;
        this.video.style.width = '100%';
        this.video.style.height = '100%';
        
        // Add source
        const source = document.createElement('source');
        source.src = this.streamUrl;
        source.type = 'application/x-mpegURL';
        this.video.appendChild(source);
        
        this.container.appendChild(this.video);
        
        // Initialize Video.js
        this.videoJsPlayer = videojs('liveStreamVideo', {
            controls: true,
            autoplay: 'muted',
            preload: 'auto',
            fluid: true,
            responsive: true,
            liveui: true,
            html5: {
                vhs: {
                    overrideNative: true
                },
                nativeAudioTracks: false,
                nativeVideoTracks: false
            }
        });
        
        // Initialize Mux Data SDK if available and environment key is set
        const muxEnvKey = this.getMuxEnvKey();
        if (typeof window.initVideoJsMux !== 'undefined' && muxEnvKey) {
            console.log('📊 Initializing Mux Data SDK for analytics');
            window.initVideoJsMux(this.videoJsPlayer, {
                debug: false,
                data: {
                    env_key: muxEnvKey,
                    player_name: 'FezaMarket Live Player',
                    player_init_time: Date.now(),
                    video_id: `stream-${this.streamId}`,
                    video_title: document.title,
                    video_stream_type: 'live',
                    viewer_user_id: this.getViewerId(),
                    page_type: 'livestream',
                    // Custom dimensions for tracking
                    custom_1: `stream-${this.streamId}`,
                    custom_2: this.playbackId
                }
            });
        }
        
        // Set up event listeners
        this.videoJsPlayer.on('loadedmetadata', () => {
            console.log('✅ Video.js: Metadata loaded');
        });
        
        this.videoJsPlayer.on('playing', () => {
            console.log('✅ Video.js: Stream is playing');
            this.streamPlayable = true;
            
            // Unmute after first play
            if (this.videoJsPlayer.muted()) {
                this.videoJsPlayer.muted(false);
            }
            
            // Start engagement
            this.startEngagement();
        });
        
        this.videoJsPlayer.on('error', () => {
            const error = this.videoJsPlayer.error();
            console.error('❌ Video.js error:', error);
            
            if (!this.streamPlayable && this.retryCount < this.maxRetries) {
                console.log('📡 Stream not yet available, will retry...');
                this.destroy();
                this.showWaitingMessage();
                this.retryStreamLoad();
            } else {
                this.showError('Error loading video stream');
            }
        });
        
        this.videoJsPlayer.on('waiting', () => {
            console.log('⏳ Video.js: Buffering...');
        });
        
        this.videoJsPlayer.on('stalled', () => {
            console.log('⚠️ Video.js: Stream stalled');
        });
        
        // Retry logic for failed loads
        this.videoJsPlayer.on('loadstart', () => {
            console.log('📥 Video.js: Starting to load stream');
        });
    }
    
    /**
     * Get Mux environment key from page or configuration
     */
    getMuxEnvKey() {
        // Check if defined globally
        if (typeof MUX_ENV_KEY !== 'undefined') {
            return MUX_ENV_KEY;
        }
        
        // Check meta tag
        const metaTag = document.querySelector('meta[name="mux-env-key"]');
        if (metaTag) {
            return metaTag.getAttribute('content');
        }
        
        // Return null if not found - analytics won't be initialized
        return null;
    }
    
    /**
     * Get viewer ID for analytics
     */
    getViewerId() {
        // Try to get from session or generate anonymous ID
        let viewerId = sessionStorage.getItem('viewerId');
        if (!viewerId) {
            viewerId = 'anon-' + Math.random().toString(36).substr(2, 9);
            sessionStorage.setItem('viewerId', viewerId);
        }
        return viewerId;
    }
    
    /**
     * Create video element in container
     */
    createVideoElement() {
        this.video = document.createElement('video');
        this.video.id = 'liveStreamVideo';
        this.video.controls = true;
        this.video.autoplay = true;
        this.video.muted = true; // Autoplay requires muted
        this.video.playsinline = true;
        this.video.style.width = '100%';
        this.video.style.height = '100%';
        this.video.style.objectFit = 'cover';

        // Add event listeners
        this.video.addEventListener('error', (e) => {
            console.error('❌ Video error:', e);
            this.showError('Error loading video stream');
        });

        this.video.addEventListener('loadedmetadata', () => {
            console.log('✅ Video metadata loaded');
        });

        this.video.addEventListener('canplay', () => {
            console.log('✅ Video can play');
            // Unmute after first play if user interacts
            this.video.muted = false;
        });

        // Clear container and add video
        this.container.innerHTML = '';
        this.container.appendChild(this.video);
    }

    /**
     * Initialize HLS.js for adaptive streaming
     */
    initHLS() {
        if (Hls.isSupported()) {
            console.log('🎬 Initializing HLS.js...');
            
            this.hls = new Hls({
                debug: false,
                enableWorker: true,
                lowLatencyMode: true,
                backBufferLength: 90,
                maxBufferLength: 30,
                maxMaxBufferLength: 60,
                maxBufferSize: 60 * 1000 * 1000,
                maxBufferHole: 0.5,
                highBufferWatchdogPeriod: 2,
                nudgeOffset: 0.1,
                nudgeMaxRetry: 3,
                maxFragLookUpTolerance: 0.25,
                liveSyncDurationCount: 3,
                liveMaxLatencyDurationCount: 10,
                liveDurationInfinity: false,
                liveBackBufferLength: 0,
                xhrSetup: function(xhr, url) {
                    // Add CORS headers for cross-origin requests
                    xhr.withCredentials = false;
                }
            });

            console.log('📥 Loading HLS source:', this.streamUrl);
            this.hls.loadSource(this.streamUrl);
            this.hls.attachMedia(this.video);

            this.hls.on(Hls.Events.MANIFEST_PARSED, () => {
                console.log('✅ HLS manifest parsed successfully, stream is playable');
                this.streamPlayable = true;
                
                // Start video playback
                this.video.play().catch(error => {
                    console.log('⚠️ Autoplay prevented, user interaction required');
                });
                
                // Start engagement logic ONLY after stream is confirmed playable
                this.startEngagement();
            });

            this.hls.on(Hls.Events.ERROR, (event, data) => {
                console.error('❌ HLS error:', data);
                
                if (data.fatal) {
                    switch (data.type) {
                        case Hls.ErrorTypes.NETWORK_ERROR:
                            console.log('🔄 Fatal network error, trying to recover...');
                            // If manifest not loaded yet, retry loading stream
                            if (!this.streamPlayable && this.retryCount < this.maxRetries) {
                                console.log('📡 Stream not yet available, will retry...');
                                this.destroy(); // Clean up properly before retry
                                this.showWaitingMessage();
                                this.retryStreamLoad();
                            } else if (this.streamPlayable) {
                                // Stream was playing, try to recover
                                console.log('🔄 Attempting to recover network error...');
                                this.hls.startLoad();
                            } else {
                                // Max retries reached
                                console.error('❌ Max retries reached for network error');
                                this.destroy();
                                this.showError('Unable to load stream. Please try again later.');
                            }
                            break;
                        case Hls.ErrorTypes.MEDIA_ERROR:
                            console.log('🔄 Fatal media error, trying to recover...');
                            this.hls.recoverMediaError();
                            break;
                        default:
                            console.error('❌ Unrecoverable error, destroying HLS');
                            this.destroy();
                            this.showError('Stream playback failed');
                            break;
                    }
                }
            });

        } else if (this.video.canPlayType('application/vnd.apple.mpegurl')) {
            // Native HLS support (Safari)
            console.log('🎬 Using native HLS support...');
            this.video.src = this.streamUrl;
            this.video.addEventListener('loadedmetadata', () => {
                console.log('✅ Native HLS stream is playable');
                this.streamPlayable = true;
                this.video.play().catch(error => {
                    console.log('⚠️ Autoplay prevented, user interaction required');
                });
                // Start engagement after native HLS is ready
                this.startEngagement();
            });
        } else {
            this.showError('Your browser does not support HLS streaming');
        }
    }
    
    /**
     * Start engagement logic (viewers and likes)
     * Only called after stream is confirmed playable
     */
    startEngagement() {
        if (this.engagementStarted) {
            console.log('⚠️ Engagement already started, skipping');
            return;
        }
        
        this.engagementStarted = true;
        console.log('🎯 Starting engagement timers (after stream is playable)');
        
        // Start viewer count increment after 10 seconds with randomized intervals
        setTimeout(() => {
            console.log('👥 Viewer engagement started (10 seconds after playback)');
            this.scheduleViewerUpdates();
        }, 10000);
        
        // Start like count increment after 30 seconds with randomized intervals
        setTimeout(() => {
            console.log('👍 Like engagement started (30 seconds after playback)');
            this.scheduleLikeUpdates();
        }, 30000);
    }
    
    /**
     * Schedule randomized viewer count updates
     */
    scheduleViewerUpdates() {
        if (!this.engagementStarted || !this.streamPlayable) {
            console.log('⚠️ Stopping viewer updates - stream not playable');
            return;
        }
        
        // Random interval between 5-13 seconds
        const randomInterval = (5 + Math.random() * 8) * 1000;
        
        // Random increment value (1-3)
        const randomIncrement = Math.floor(1 + Math.random() * 3);
        
        // Trigger engagement update
        if (typeof triggerFakeEngagement === 'function') {
            triggerFakeEngagement(this.streamId);
        }
        
        // Schedule next update
        this.viewerTimer = setTimeout(() => this.scheduleViewerUpdates(), randomInterval);
    }
    
    /**
     * Schedule randomized like count updates
     */
    scheduleLikeUpdates() {
        if (!this.engagementStarted || !this.streamPlayable) {
            console.log('⚠️ Stopping like updates - stream not playable');
            return;
        }
        
        // Random interval between 5-13 seconds
        const randomInterval = (5 + Math.random() * 8) * 1000;
        
        // Random increment value (1-3)
        const randomIncrement = Math.floor(1 + Math.random() * 3);
        
        // Trigger engagement update
        if (typeof triggerFakeEngagement === 'function') {
            triggerFakeEngagement(this.streamId);
        }
        
        // Schedule next update
        this.likeTimer = setTimeout(() => this.scheduleLikeUpdates(), randomInterval);
    }

    /**
     * Show placeholder when no stream is available
     */
    showPlaceholder() {
        this.container.innerHTML = `
            <div style="width: 100%; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; background: linear-gradient(135deg, #1f2937, #374151); color: white;">
                <div style="font-size: 64px; margin-bottom: 20px;">📹</div>
                <h3 style="font-size: 24px; margin-bottom: 10px;">Stream Not Available</h3>
                <p style="font-size: 16px; opacity: 0.8;">The live stream will begin shortly</p>
            </div>
        `;
    }
    
    /**
     * Show waiting message with retry info
     */
    showWaitingMessage() {
        this.container.innerHTML = `
            <div style="width: 100%; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; background: linear-gradient(135deg, #1f2937, #374151); color: white;">
                <div style="font-size: 64px; margin-bottom: 20px;">⏳</div>
                <h3 style="font-size: 24px; margin-bottom: 10px;">Waiting for stream to start...</h3>
                <p style="font-size: 16px; opacity: 0.8;">Checking every 5 seconds (Attempt ${this.retryCount}/${this.maxRetries})</p>
                <div style="margin-top: 20px;">
                    <div class="spinner" style="border: 4px solid rgba(255,255,255,0.3); border-top: 4px solid white; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite;"></div>
                </div>
            </div>
            <style>
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
            </style>
        `;
    }

    /**
     * Show error message
     */
    showError(message) {
        this.container.innerHTML = `
            <div style="width: 100%; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; background: #1f2937; color: white;">
                <div style="font-size: 64px; margin-bottom: 20px;">⚠️</div>
                <h3 style="font-size: 24px; margin-bottom: 10px;">Unable to Load Stream</h3>
                <p style="font-size: 16px; opacity: 0.8;">${message}</p>
            </div>
        `;
    }

    /**
     * Show "stream ended" message
     */
    showStreamEnded() {
        this.container.innerHTML = `
            <div style="width: 100%; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; background: linear-gradient(135deg, #1f2937, #374151); color: white; padding: 40px; text-align: center;">
                <div style="font-size: 64px; margin-bottom: 20px;">🎬</div>
                <h3 style="font-size: 28px; margin-bottom: 15px;">Stream Has Ended</h3>
                <p style="font-size: 16px; opacity: 0.8; margin-bottom: 30px;">Thank you for watching! Check back soon for more live events.</p>
                <button onclick="location.reload()" style="padding: 12px 30px; background: #dc2626; color: white; border: none; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer;">
                    Back to Live Events
                </button>
            </div>
        `;
    }

    /**
     * Destroy player and cleanup resources
     */
    destroy() {
        console.log('🧹 Cleaning up player resources');
        
        // Stop engagement timers
        if (this.viewerTimer) {
            clearTimeout(this.viewerTimer);
            this.viewerTimer = null;
        }
        if (this.likeTimer) {
            clearTimeout(this.likeTimer);
            this.likeTimer = null;
        }
        if (this.statusTimer) {
            clearTimeout(this.statusTimer);
            this.statusTimer = null;
        }
        
        // Mark engagement as stopped
        this.engagementStarted = false;
        this.streamPlayable = false;
        
        // Destroy Video.js player
        if (this.videoJsPlayer) {
            try {
                this.videoJsPlayer.dispose();
            } catch (e) {
                console.error('Error disposing Video.js player:', e);
            }
            this.videoJsPlayer = null;
        }
        
        // Destroy HLS instance
        if (this.hls) {
            this.hls.destroy();
            this.hls = null;
        }
        
        // Cleanup video element
        if (this.video) {
            this.video.pause();
            this.video.src = '';
            this.video = null;
        }
    }

    /**
     * Monitor stream status and show ended message if stream stops
     */
    async monitorStreamStatus() {
        const checkStatus = async () => {
            try {
                const response = await fetch(`/api/streams/get.php?stream_id=${this.streamId}`);
                const data = await response.json();
                
                if (data.success && data.stream) {
                    if (data.stream.status !== 'live') {
                        console.log('📡 Stream has ended, stopping engagement and playback');
                        this.destroy(); // This will stop all timers
                        this.showStreamEnded();
                        return; // Stop monitoring
                    }
                }
            } catch (error) {
                console.error('Error checking stream status:', error);
            }
            
            // Check again in 10 seconds
            this.statusTimer = setTimeout(checkStatus, 10000);
        };
        
        // Start monitoring after initial delay
        setTimeout(checkStatus, 10000);
    }
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = LiveStreamPlayer;
}
