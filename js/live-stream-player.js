/**
 * Live Stream Video Player Component
 * Implements HLS.js for low-latency live streaming
 */

class LiveStreamPlayer {
    constructor(containerId, streamId) {
        this.container = document.getElementById(containerId);
        this.streamId = streamId;
        this.video = null;
        this.hls = null;
        this.isLive = false;
        this.streamUrl = null;
    }

    /**
     * Initialize the video player
     */
    async init() {
        try {
            // Fetch stream information
            const streamData = await this.fetchStreamData();
            
            if (!streamData || !streamData.success) {
                this.showError('Stream not available');
                return;
            }

            this.streamUrl = streamData.stream_url;
            this.isLive = streamData.is_live;

            // Create video element
            this.createVideoElement();

            // Initialize HLS if supported and URL is m3u8
            if (this.streamUrl && this.streamUrl.includes('.m3u8')) {
                this.initHLS();
            } else if (this.streamUrl) {
                // Direct video source (MP4, WebM, etc.)
                this.video.src = this.streamUrl;
            } else {
                this.showPlaceholder();
            }

        } catch (error) {
            console.error('❌ Failed to initialize player:', error);
            this.showError('Failed to load stream');
        }
    }

    /**
     * Fetch stream data from API
     */
    async fetchStreamData() {
        const response = await fetch(`/api/streams/get.php?stream_id=${this.streamId}`);
        return await response.json();
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
                liveBackBufferLength: 0
            });

            this.hls.loadSource(this.streamUrl);
            this.hls.attachMedia(this.video);

            this.hls.on(Hls.Events.MANIFEST_PARSED, () => {
                console.log('✅ HLS manifest parsed, starting playback');
                this.video.play().catch(error => {
                    console.log('⚠️ Autoplay prevented, user interaction required');
                });
            });

            this.hls.on(Hls.Events.ERROR, (event, data) => {
                console.error('❌ HLS error:', data);
                
                if (data.fatal) {
                    switch (data.type) {
                        case Hls.ErrorTypes.NETWORK_ERROR:
                            console.log('🔄 Fatal network error, trying to recover...');
                            this.hls.startLoad();
                            break;
                        case Hls.ErrorTypes.MEDIA_ERROR:
                            console.log('🔄 Fatal media error, trying to recover...');
                            this.hls.recoverMediaError();
                            break;
                        default:
                            console.error('❌ Unrecoverable error, destroying HLS');
                            this.hls.destroy();
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
                this.video.play().catch(error => {
                    console.log('⚠️ Autoplay prevented, user interaction required');
                });
            });
        } else {
            this.showError('Your browser does not support HLS streaming');
        }
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
        if (this.hls) {
            this.hls.destroy();
            this.hls = null;
        }
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
                        console.log('📡 Stream has ended');
                        this.destroy();
                        this.showStreamEnded();
                        return; // Stop monitoring
                    }
                }
            } catch (error) {
                console.error('Error checking stream status:', error);
            }
            
            // Check again in 10 seconds
            setTimeout(checkStatus, 10000);
        };
        
        // Start monitoring after initial delay
        setTimeout(checkStatus, 10000);
    }
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = LiveStreamPlayer;
}
