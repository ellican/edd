<?php
/**
 * FezaMarket Live - Live Shopping Experience
 * E-Commerce Platform
 */

require_once __DIR__ . '/includes/init.php';

// Load SEO helper
require_once __DIR__ . '/includes/seo.php';

$product = new Product();
$liveStream = new LiveStream();

// Check if we're in replay mode
$isReplay = isset($_GET['replay']) && $_GET['replay'] == '1';
$replayStreamId = isset($_GET['stream']) ? (int)$_GET['stream'] : null;

if ($isReplay && $replayStreamId) {
    // Replay mode - load archived stream
    $replayStream = $liveStream->getStreamById($replayStreamId);
    
    if (!$replayStream || $replayStream['status'] !== 'archived') {
        // Stream not found or not archived, redirect to main live page
        header('Location: /live.php');
        exit;
    }
    
    // Get stream products
    $streamProducts = $liveStream->getStreamProducts($replayStreamId);
    
    $page_title = 'Watch Replay: ' . htmlspecialchars($replayStream['title']) . ' - FezaMarket Live';
    includeHeader($page_title);
    
    // Include replay template
    include __DIR__ . '/templates/stream-replay.php';
    includeFooter();
    exit;
}

// Get active live streams from database
$activeStreams = $liveStream->getActiveStreams(10);

// Get scheduled streams (upcoming)
$db = db();
$stmt = $db->prepare("
    SELECT ls.*,
           v.business_name as vendor_name,
           v.id as vendor_id,
           TIMESTAMPDIFF(SECOND, NOW(), ls.scheduled_at) as seconds_until_start
    FROM live_streams ls
    JOIN vendors v ON ls.vendor_id = v.id
    WHERE ls.status = 'scheduled' 
      AND ls.scheduled_at > NOW()
    ORDER BY ls.scheduled_at ASC
    LIMIT 6
");
$stmt->execute();
$scheduledStreams = $stmt->fetchAll();

// Get recent archived streams
$stmt = $db->prepare("
    SELECT ls.*,
           v.business_name as vendor_name,
           v.id as vendor_id,
           TIMESTAMPDIFF(SECOND, ls.started_at, ls.ended_at) as duration_seconds
    FROM live_streams ls
    JOIN vendors v ON ls.vendor_id = v.id
    WHERE ls.status = 'archived'
      AND ls.ended_at IS NOT NULL
    ORDER BY ls.ended_at DESC
    LIMIT 12
");
$stmt->execute();
$recentStreams = $stmt->fetchAll();

// Get products for live shopping events
$liveProducts = $product->findAll(8);
$featuredProducts = $product->getFeatured(4);

// Generate SEO meta tags for live page
$seoConfig = [];
if ($isReplay && $replayStreamId && $replayStream) {
    // Replay mode SEO
    $seoConfig = [
        'title' => 'Watch Replay: ' . htmlspecialchars($replayStream['title']) . ' - FezaMarket Live',
        'description' => htmlspecialchars($replayStream['description'] ?? 'Watch this exciting live shopping stream replay on FezaMarket'),
        'keywords' => 'live shopping replay, video shopping, ' . htmlspecialchars($replayStream['title']),
        'image' => $replayStream['thumbnail_url'] ?? '/assets/images/live-default.jpg',
        'type' => 'video.other',
        'canonical' => 'https://' . ($_SERVER['HTTP_HOST'] ?? 'fezamarket.com') . '/live.php?stream=' . $replayStreamId . '&replay=1'
    ];
    $videoSchema = SEO::generateVideoSchema($replayStream, null);
} else {
    // Live page SEO
    $seoConfig = [
        'title' => 'FezaMarket Live - Shop Live Events & Exclusive Deals',
        'description' => 'Join interactive live shopping events on FezaMarket. Get exclusive deals, ask questions in real-time, and shop directly from live product showcases.',
        'keywords' => 'live shopping, live stream shopping, interactive shopping, exclusive deals, real-time shopping, video shopping',
        'image' => '/assets/images/live-banner.jpg',
        'type' => 'website',
        'canonical' => 'https://' . ($_SERVER['HTTP_HOST'] ?? 'fezamarket.com') . '/live.php'
    ];
    $videoSchema = '';
}

$page_title = $seoConfig['title'];
includeHeader($page_title);

// Output SEO meta tags and structured data
if (!empty($seoConfig)) {
    echo "\n<!-- SEO Meta Tags -->\n";
    echo SEO::generateMetaTags($seoConfig);
    if (!empty($videoSchema)) {
        echo "\n" . $videoSchema . "\n";
    }
    echo SEO::generateOrganizationSchema() . "\n";
}
?>

<div class="container">
    <!-- Live Shopping Header -->
    <div class="live-header">
        <h1>🔴 FezaMarket Live</h1>
        <p>Shop live events, exclusive deals, and interactive product showcases</p>
    </div>

    <!-- Live Now Section -->
    <section class="live-now-section">
        <div class="section-header">
            <h2>🔴 Live Now</h2>
            <span class="live-count"><?php echo count($activeStreams); ?> live events</span>
        </div>
        
        <?php if (count($activeStreams) > 0): ?>
        <div class="live-streams-grid">
            <!-- Main Live Stream -->
            <?php 
            $mainStream = $activeStreams[0] ?? null;
            if ($mainStream):
                $streamProducts = $liveStream->getStreamProducts($mainStream['id']);
                $streamStats = $liveStream->getStreamStats($mainStream['id']);
            ?>
            <div class="main-live-stream" data-stream-id="<?php echo $mainStream['id']; ?>">
                <div class="stream-container">
                    <div class="stream-video">
                        <div class="live-badge">🔴 LIVE</div>
                        
                        <!-- Live Video Player (replaces static thumbnail) -->
                        <div id="liveVideoPlayer-<?php echo $mainStream['id']; ?>" class="live-video-player" style="width: 100%; aspect-ratio: 16/9; background: #000; position: relative;">
                            <!-- Video player will be initialized here via JavaScript -->
                            <div class="stream-placeholder" style="position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; color: white;">
                                <div style="font-size: 48px; margin-bottom: 15px;">📹</div>
                                <h3 style="font-size: 20px;"><?php echo htmlspecialchars($mainStream['title']); ?></h3>
                                <p style="opacity: 0.8;"><?php echo htmlspecialchars($mainStream['description'] ?? 'Loading stream...'); ?></p>
                            </div>
                        </div>
                        
                        <div class="stream-stats">
                            <span class="viewer-count" id="viewer-count-<?php echo $mainStream['id']; ?>">
                                👥 <span class="count"><?php echo $mainStream['current_viewers'] ?? 0; ?></span> watching
                            </span>
                            <span class="live-timer" id="live-timer-<?php echo $mainStream['id']; ?>">⏰ 00:00</span>
                        </div>
                        
                        <!-- Interaction Buttons -->
                        <div class="stream-actions" style="position: absolute; bottom: 20px; right: 20px; display: flex; gap: 10px;">
                            <button class="btn-icon like-btn" data-stream-id="<?php echo $mainStream['id']; ?>" onclick="handleLike(this)">
                                👍 <span class="count"><?php echo $streamStats['likes_count'] ?? 0; ?></span>
                            </button>
                            <button class="btn-icon dislike-btn" data-stream-id="<?php echo $mainStream['id']; ?>" onclick="handleDislike(this)">
                                👎 <span class="count"><?php echo $streamStats['dislikes_count'] ?? 0; ?></span>
                            </button>
                        </div>
                    </div>
                    
                    <div class="stream-interaction">
                        <div class="chat-section">
                            <h4>Live Chat</h4>
                            <div class="chat-messages" id="chatMessages">
                                <!-- Comments will be loaded here -->
                            </div>
                            
                            <?php if (Session::isLoggedIn()): ?>
                                <div class="chat-input">
                                    <input type="text" placeholder="Join the conversation..." id="chatInput">
                                    <button onclick="sendMessage(<?php echo $mainStream['id']; ?>)" class="btn btn-sm">Send</button>
                                </div>
                            <?php else: ?>
                                <div class="chat-login">
                                    <a href="/login.php?return=/live.php" class="btn btn-sm">Sign In to Chat</a>
                                </div>
                            <?php endif; ?>
                        </div>
                        
                        <div class="featured-products">
                            <h4>Featured in Stream</h4>
                            <?php foreach (array_slice($streamProducts, 0, 2) as $streamProduct): 
                                // Get full product details
                                $productDetails = $product->findById($streamProduct['product_id']);
                                if (!$productDetails) continue;
                            ?>
                                <div class="stream-product">
                                    <img src="<?php echo getSafeProductImageUrl($productDetails); ?>" 
                                         alt="<?php echo htmlspecialchars($productDetails['name']); ?>">
                                    <div class="product-info">
                                        <h5><?php echo htmlspecialchars(substr($productDetails['name'], 0, 30)); ?>...</h5>
                                        <div class="live-price">
                                            <span class="current-price"><?php echo formatPrice($streamProduct['special_price'] ?? $productDetails['price']); ?></span>
                                            <?php if ($streamProduct['special_price']): ?>
                                            <span class="original-price"><?php echo formatPrice($productDetails['price']); ?></span>
                                            <?php endif; ?>
                                        </div>
                                        <div class="product-buttons" style="display: flex; gap: 5px; margin-top: 10px;">
                                            <button class="btn btn-sm btn-primary live-buy-btn" onclick="buyNow(<?php echo $productDetails['id']; ?>)">
                                                Buy Now
                                            </button>
                                            <button class="btn btn-sm btn-outline live-cart-btn" onclick="addToCart(<?php echo $productDetails['id']; ?>)">
                                                Add to Cart
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    </div>
                </div>
            </div>
            <?php endif; ?>

            <!-- Other Live Streams -->
            <div class="other-streams">
                <?php foreach (array_slice($activeStreams, 1, 2) as $stream): ?>
                <div class="mini-stream" data-stream-id="<?php echo $stream['id']; ?>">
                    <a href="#" onclick="switchStream(<?php echo $stream['id']; ?>); return false;">
                        <div class="mini-stream-video">
                            <div class="live-badge">🔴 LIVE</div>
                            <div class="mini-stream-content">
                                <span class="stream-emoji">🛍️</span>
                                <h4><?php echo htmlspecialchars($stream['title']); ?></h4>
                                <p><?php echo htmlspecialchars(substr($stream['description'] ?? '', 0, 40)); ?>...</p>
                                <span class="mini-viewers">👥 <?php echo $stream['current_viewers'] ?? 0; ?> watching</span>
                            </div>
                        </div>
                    </a>
                </div>
                <?php endforeach; ?>
            </div>
        </div>
        <?php else: ?>
        <div style="text-align: center; padding: 60px 20px; background: white; border-radius: 12px;">
            <h3 style="color: #6b7280; margin-bottom: 10px;">No Live Streams Right Now</h3>
            <p style="color: #9ca3af;">Check back soon for exciting live shopping events!</p>
        </div>
        <?php endif; ?>
    </section>

    <!-- Upcoming Events -->
    <section class="upcoming-events">
        <h2>📅 Upcoming Live Events</h2>
        <?php if (count($scheduledStreams) > 0): ?>
        <div class="events-grid">
            <?php foreach ($scheduledStreams as $scheduled): 
                $secondsUntil = $scheduled['seconds_until_start'];
                $hoursUntil = floor($secondsUntil / 3600);
                $minutesUntil = floor(($secondsUntil % 3600) / 60);
                
                if ($hoursUntil < 24) {
                    $timeDisplay = $hoursUntil > 0 ? "In {$hoursUntil}h {$minutesUntil}m" : "In {$minutesUntil}m";
                } else {
                    $daysUntil = floor($hoursUntil / 24);
                    $timeDisplay = "In {$daysUntil} day" . ($daysUntil > 1 ? 's' : '');
                }
            ?>
            <div class="event-card" data-stream-id="<?php echo $scheduled['id']; ?>">
                <div class="event-time">
                    <div class="time-badge"><?php echo $timeDisplay; ?></div>
                </div>
                <div class="event-content">
                    <h3><?php echo htmlspecialchars($scheduled['title']); ?></h3>
                    <p><?php echo htmlspecialchars($scheduled['description'] ?? 'Join us for exclusive deals and products!'); ?></p>
                    <div class="event-details">
                        <span class="host">👤 <?php echo htmlspecialchars($scheduled['vendor_name']); ?></span>
                        <span class="category">📅 <?php echo date('M j, g:i A', strtotime($scheduled['scheduled_at'])); ?></span>
                    </div>
                    <button class="btn btn-outline notify-btn" onclick="setReminder(<?php echo $scheduled['id']; ?>)">
                        🔔 Set Reminder
                    </button>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
        <?php else: ?>
        <div style="text-align: center; padding: 40px 20px; background: white; border-radius: 12px;">
            <p style="color: #6b7280;">No upcoming streams scheduled. Check back soon!</p>
        </div>
        <?php endif; ?>
    </section>

    <!-- Recent Streams -->
    <section class="recent-streams">
        <h2>📼 Recent Streams</h2>
        <?php if (count($recentStreams) > 0): ?>
        <div class="recent-streams-grid">
            <?php foreach ($recentStreams as $recent): 
                $durationMinutes = floor($recent['duration_seconds'] / 60);
                $durationHours = floor($durationMinutes / 60);
                $durationDisplay = $durationHours > 0 
                    ? sprintf('%dh %dm', $durationHours, $durationMinutes % 60)
                    : sprintf('%dm', $durationMinutes);
            ?>
            <div class="recent-stream-card" data-stream-id="<?php echo $recent['id']; ?>">
                <div class="recent-stream-thumbnail">
                    <?php if ($recent['thumbnail_url']): ?>
                        <img data-src="<?php echo htmlspecialchars($recent['thumbnail_url']); ?>" 
                             alt="<?php echo htmlspecialchars($recent['title']); ?>"
                             class="lazy-thumbnail">
                    <?php else: ?>
                        <div class="thumbnail-placeholder">📹</div>
                    <?php endif; ?>
                    <div class="replay-badge">🔴 REPLAY</div>
                    <div class="duration-badge"><?php echo $durationDisplay; ?></div>
                    <?php if ($recent['video_path']): ?>
                        <button class="play-button" onclick="playStream(<?php echo $recent['id']; ?>)">
                            ▶️
                        </button>
                    <?php endif; ?>
                </div>
                <div class="recent-stream-info">
                    <h4><?php echo htmlspecialchars($recent['title']); ?></h4>
                    <p class="vendor-name">👤 <?php echo htmlspecialchars($recent['vendor_name']); ?></p>
                    <div class="stream-stats">
                        <span class="stat">👥 <?php echo number_format($recent['viewer_count']); ?> viewers</span>
                        <span class="stat">👍 <?php echo number_format($recent['like_count']); ?> likes</span>
                    </div>
                    <p class="stream-time">🕒 <?php echo date('M j, Y', strtotime($recent['ended_at'])); ?></p>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
        <?php else: ?>
        <div style="text-align: center; padding: 40px 20px; background: white; border-radius: 12px;">
            <p style="color: #6b7280;">No recent streams available. Check back after sellers go live!</p>
        </div>
        <?php endif; ?>
    </section>

    <!-- Live Shopping Benefits -->
    <section class="live-benefits">
        <h2>Why Shop Live?</h2>
        <div class="benefits-grid">
            <div class="benefit-card">
                <div class="benefit-icon">💰</div>
                <h3>Exclusive Deals</h3>
                <p>Get special pricing only available during live events</p>
            </div>
            <div class="benefit-card">
                <div class="benefit-icon">🎯</div>
                <h3>Expert Advice</h3>
                <p>Ask questions and get real-time answers from experts</p>
            </div>
            <div class="benefit-card">
                <div class="benefit-icon">👥</div>
                <h3>Community</h3>
                <p>Shop with others and share experiences in live chat</p>
            </div>
            <div class="benefit-card">
                <div class="benefit-icon">📦</div>
                <h3>Product Showcases</h3>
                <p>See products in action before you buy</p>
            </div>
        </div>
    </section>

    <!-- Popular Categories -->
    <section class="live-categories">
        <h2>Popular Live Shopping Categories</h2>
        <div class="categories-grid">
            <div class="category-card" onclick="window.location.href='/category.php?name=electronics'">
                <span class="category-emoji">📱</span>
                <h3>Electronics</h3>
                <p>Tech demos and launches</p>
            </div>
            <div class="category-card" onclick="window.location.href='/category.php?name=fashion'">
                <span class="category-emoji">👗</span>
                <h3>Fashion</h3>
                <p>Style shows and trends</p>
            </div>
            <div class="category-card" onclick="window.location.href='/category.php?name=home-garden'">
                <span class="category-emoji">🏠</span>
                <h3>Home & Garden</h3>
                <p>Decorating and DIY</p>
            </div>
            <div class="category-card" onclick="window.location.href='/category.php?name=sports'">
                <span class="category-emoji">⚽</span>
                <h3>Sports</h3>
                <p>Fitness and outdoor gear</p>
            </div>
        </div>
    </section>

    <!-- Become a Host -->
    <section class="become-host">
        <div class="host-banner">
            <div class="host-content">
                <h2>Want to Host Your Own Live Shopping Event?</h2>
                <p>Reach thousands of buyers and showcase your products in real-time</p>
                <div class="host-benefits">
                    <span>📈 Increase sales</span>
                    <span>👥 Build community</span>
                    <span>🎯 Direct engagement</span>
                </div>
                <a href="/seller-center.php" class="btn btn-large">Apply to Host</a>
            </div>
            <div class="host-graphic">
                <div class="host-illustration">📹</div>
            </div>
        </div>
    </section>
</div>

<style>
.live-header {
    text-align: center;
    margin-bottom: 40px;
    padding: 40px 0;
    background: linear-gradient(135deg, #dc2626, #ef4444);
    color: white;
    border-radius: 12px;
}

.live-header h1 {
    font-size: 36px;
    margin-bottom: 10px;
}

.live-header p {
    font-size: 18px;
    opacity: 0.9;
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
}

.section-header h2 {
    color: #1f2937;
    font-size: 24px;
}

.live-count {
    background: #dc2626;
    color: white;
    padding: 5px 15px;
    border-radius: 20px;
    font-size: 14px;
    font-weight: 600;
}

.live-streams-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 30px;
    margin-bottom: 60px;
}

.main-live-stream {
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
}

.stream-video {
    background: linear-gradient(135deg, #1f2937, #374151);
    color: white;
    padding: 30px;
    position: relative;
    min-height: 300px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    text-align: center;
}

.live-badge {
    position: absolute;
    top: 15px;
    left: 15px;
    background: #dc2626;
    color: white;
    padding: 5px 15px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { opacity: 1; }
    50% { opacity: 0.7; }
    100% { opacity: 1; }
}

.stream-thumbnail {
    font-size: 64px;
    margin-bottom: 20px;
}

.stream-content h3 {
    font-size: 24px;
    margin-bottom: 10px;
}

.stream-stats {
    position: absolute;
    bottom: 15px;
    left: 15px;
    right: 15px;
    display: flex;
    justify-content: space-between;
    font-size: 14px;
}

.stream-interaction {
    padding: 20px;
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}

.chat-section h4,
.featured-products h4 {
    color: #1f2937;
    margin-bottom: 15px;
}

.chat-messages {
    background: #f9fafb;
    border-radius: 8px;
    padding: 15px;
    height: 200px;
    overflow-y: auto;
    margin-bottom: 15px;
}

.chat-message {
    margin-bottom: 10px;
    font-size: 14px;
}

.chat-message strong {
    color: #0654ba;
}

.chat-input {
    display: flex;
    gap: 10px;
}

.chat-input input {
    flex: 1;
    padding: 8px 12px;
    border: 1px solid #d1d5db;
    border-radius: 6px;
}

.chat-login {
    text-align: center;
}

.btn-icon {
    background: rgba(255, 255, 255, 0.9);
    border: none;
    padding: 8px 15px;
    border-radius: 20px;
    cursor: pointer;
    font-size: 14px;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    gap: 5px;
}

.btn-icon:hover {
    background: white;
    transform: scale(1.05);
}

.btn-icon.active {
    background: #dc2626;
    color: white;
}

.btn-outline {
    border: 1px solid #d1d5db;
    background: white;
}

.btn-outline:hover {
    background: #f3f4f6;
}

.product-buttons {
    display: flex;
    gap: 5px;
    margin-top: 10px;
}

.stream-product {
    display: flex;
    gap: 10px;
    margin-bottom: 15px;
    padding: 10px;
    background: #f9fafb;
    border-radius: 6px;
}

.stream-product img {
    width: 60px;
    height: 60px;
    object-fit: cover;
    border-radius: 4px;
}

.stream-product .product-info {
    flex: 1;
}

.stream-product h5 {
    font-size: 14px;
    color: #1f2937;
    margin-bottom: 5px;
}

.live-price {
    margin-bottom: 8px;
}

.current-price {
    color: #dc2626;
    font-weight: 600;
    margin-right: 10px;
}

.original-price {
    color: #6b7280;
    text-decoration: line-through;
    font-size: 14px;
}

.live-buy-btn {
    background: #dc2626 !important;
    color: white !important;
}

.other-streams {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.mini-stream {
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    cursor: pointer;
    transition: transform 0.3s ease;
}

.mini-stream:hover {
    transform: translateY(-3px);
}

.mini-stream-video {
    background: linear-gradient(135deg, #6366f1, #8b5cf6);
    color: white;
    padding: 20px;
    position: relative;
    text-align: center;
}

.mini-stream-content {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.stream-emoji {
    font-size: 32px;
}

.mini-stream h4 {
    font-size: 16px;
    margin: 0;
}

.mini-stream p {
    font-size: 14px;
    margin: 0;
    opacity: 0.9;
}

.mini-viewers {
    font-size: 12px;
    opacity: 0.8;
}

.upcoming-events {
    margin-bottom: 60px;
}

.upcoming-events h2 {
    color: #1f2937;
    margin-bottom: 30px;
    text-align: center;
}

.events-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 25px;
}

.event-card {
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transition: transform 0.3s ease;
}

.event-card:hover {
    transform: translateY(-3px);
}

.event-time {
    background: #0654ba;
    color: white;
    padding: 15px;
    text-align: center;
}

.time-badge {
    font-weight: 600;
}

.event-content {
    padding: 20px;
}

.event-content h3 {
    color: #1f2937;
    margin-bottom: 10px;
}

.event-content p {
    color: #6b7280;
    margin-bottom: 15px;
    line-height: 1.5;
}

.event-details {
    display: flex;
    gap: 15px;
    margin-bottom: 15px;
    font-size: 14px;
    color: #374151;
}

.recent-streams {
    margin-bottom: 60px;
}

.recent-streams h2 {
    color: #1f2937;
    margin-bottom: 30px;
    text-align: center;
}

.recent-streams-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 25px;
}

.recent-stream-card {
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transition: transform 0.3s ease;
    cursor: pointer;
}

.recent-stream-card:hover {
    transform: translateY(-3px);
}

.recent-stream-thumbnail {
    position: relative;
    width: 100%;
    aspect-ratio: 16/9;
    background: linear-gradient(135deg, #1f2937, #374151);
    overflow: hidden;
}

.recent-stream-thumbnail img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.lazy-thumbnail {
    opacity: 0;
    transition: opacity 0.3s ease;
}

.lazy-thumbnail.loaded {
    opacity: 1;
}

.thumbnail-placeholder {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    font-size: 48px;
    color: white;
}

.replay-badge {
    position: absolute;
    top: 10px;
    left: 10px;
    background: rgba(220, 38, 38, 0.9);
    color: white;
    padding: 4px 12px;
    border-radius: 15px;
    font-size: 11px;
    font-weight: bold;
}

.duration-badge {
    position: absolute;
    bottom: 10px;
    right: 10px;
    background: rgba(0, 0, 0, 0.8);
    color: white;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 600;
}

.play-button {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: rgba(255, 255, 255, 0.95);
    border: none;
    width: 60px;
    height: 60px;
    border-radius: 50%;
    font-size: 24px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s ease;
    opacity: 0;
}

.recent-stream-card:hover .play-button {
    opacity: 1;
}

.play-button:hover {
    transform: translate(-50%, -50%) scale(1.1);
}

.recent-stream-info {
    padding: 15px;
}

.recent-stream-info h4 {
    color: #1f2937;
    font-size: 16px;
    margin-bottom: 8px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.vendor-name {
    color: #6b7280;
    font-size: 13px;
    margin-bottom: 10px;
}

.stream-stats {
    display: flex;
    gap: 15px;
    margin-bottom: 8px;
    font-size: 13px;
    color: #374151;
}

.stream-stats .stat {
    display: flex;
    align-items: center;
    gap: 4px;
}

.stream-time {
    color: #9ca3af;
    font-size: 12px;
}

.live-benefits {
    margin-bottom: 60px;
}

.live-benefits h2 {
    color: #1f2937;
    margin-bottom: 40px;
    text-align: center;
}

.benefits-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 25px;
}

.benefit-card {
    background: white;
    padding: 25px;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    text-align: center;
}

.benefit-icon {
    font-size: 36px;
    margin-bottom: 15px;
}

.benefit-card h3 {
    color: #1f2937;
    margin-bottom: 10px;
}

.benefit-card p {
    color: #6b7280;
    font-size: 14px;
}

.live-categories h2 {
    color: #1f2937;
    margin-bottom: 30px;
    text-align: center;
}

.categories-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-bottom: 60px;
}

.category-card {
    background: white;
    padding: 25px;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    text-align: center;
    cursor: pointer;
    transition: transform 0.3s ease;
}

.category-card:hover {
    transform: translateY(-3px);
}

.category-emoji {
    font-size: 36px;
    margin-bottom: 15px;
}

.category-card h3 {
    color: #1f2937;
    margin-bottom: 8px;
}

.category-card p {
    color: #6b7280;
    font-size: 14px;
}

.become-host {
    background: linear-gradient(135deg, #fbbf24, #f59e0b);
    border-radius: 12px;
    overflow: hidden;
}

.host-banner {
    display: grid;
    grid-template-columns: 2fr 1fr;
    align-items: center;
    padding: 40px;
}

.host-content h2 {
    color: #1f2937;
    margin-bottom: 15px;
}

.host-content p {
    color: #374151;
    margin-bottom: 20px;
}

.host-benefits {
    display: flex;
    gap: 20px;
    margin-bottom: 25px;
    flex-wrap: wrap;
}

.host-benefits span {
    background: rgba(255,255,255,0.8);
    color: #1f2937;
    padding: 8px 15px;
    border-radius: 20px;
    font-size: 14px;
    font-weight: 600;
}

.host-illustration {
    font-size: 120px;
    text-align: center;
    opacity: 0.8;
}

@media (max-width: 768px) {
    .live-streams-grid {
        grid-template-columns: 1fr;
    }
    
    .stream-interaction {
        grid-template-columns: 1fr;
    }
    
    .host-banner {
        grid-template-columns: 1fr;
        text-align: center;
    }
    
    .host-benefits {
        justify-content: center;
    }
}
</style>

<!-- Include HLS.js for adaptive streaming -->
<script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>

<!-- Include Live Stream Player -->
<script src="/js/live-stream-player.js"></script>

<!-- Include purchase flows JS -->
<script src="/assets/js/purchase-flows.js"></script>

<script>
// Current stream ID (for main stream)
let currentStreamId = null;
let viewerId = null;
let isLoggedIn = <?php echo Session::isLoggedIn() ? 'true' : 'false'; ?>;
let livePlayer = null;

// Initialize stream when page loads
document.addEventListener('DOMContentLoaded', function() {
    const mainStream = document.querySelector('.main-live-stream');
    if (mainStream) {
        currentStreamId = parseInt(mainStream.dataset.streamId);
        
        // Initialize live video player
        console.log('🎬 Initializing live video player for stream:', currentStreamId);
        livePlayer = new LiveStreamPlayer('liveVideoPlayer-' + currentStreamId, currentStreamId);
        livePlayer.init();
        livePlayer.monitorStreamStatus();
        
        joinStream(currentStreamId);
        loadComments(currentStreamId);
        
        // Note: Engagement (viewers/likes) will be started automatically by the LiveStreamPlayer
        // after MANIFEST_PARSED event confirms the stream is playable.
        // This ensures engagement only starts when the stream is actually playing.
        
        // Update viewer count and comments periodically with random intervals (5-15 seconds)
        function scheduleNextUpdate() {
            const randomDelay = (5 + Math.random() * 10) * 1000; // 5-15 seconds in milliseconds
            setTimeout(() => {
                updateViewerCount(currentStreamId);
                loadComments(currentStreamId);
                // Engagement is now handled by LiveStreamPlayer after stream is confirmed playable
                scheduleNextUpdate(); // Schedule next update
            }, randomDelay);
        }
        scheduleNextUpdate();
        
        // Update stream timer every second
        updateStreamTimer(currentStreamId);
        setInterval(() => updateStreamTimer(currentStreamId), 1000);
    }
});

// Before leaving page, mark viewer as left and cleanup player
window.addEventListener('beforeunload', function() {
    if (viewerId && currentStreamId) {
        leaveStream(currentStreamId, viewerId);
    }
    
    // Cleanup video player
    if (livePlayer) {
        livePlayer.destroy();
    }
});

function joinStream(streamId) {
    fetch('/api/live/viewers.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            action: 'join',
            stream_id: streamId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            viewerId = data.viewer_id;
            updateViewerCountDisplay(streamId, data.viewer_count);
        }
    })
    .catch(error => console.error('Error joining stream:', error));
}

function leaveStream(streamId, viewerId) {
    navigator.sendBeacon('/api/live/viewers.php', JSON.stringify({
        action: 'leave',
        stream_id: streamId,
        viewer_id: viewerId
    }));
}

function updateViewerCount(streamId) {
    fetch(`/api/live/viewers.php?action=count&stream_id=${streamId}`)
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            updateViewerCountDisplay(streamId, data.count);
        }
    })
    .catch(error => console.error('Error updating viewer count:', error));
}

function updateViewerCountDisplay(streamId, count) {
    const countElement = document.querySelector(`#viewer-count-${streamId} .count`);
    if (countElement) {
        countElement.textContent = count;
    }
}

function updateStreamTimer(streamId) {
    // This would be calculated from stream start time
    // For now, just incrementing
    const timerElement = document.getElementById(`live-timer-${streamId}`);
    if (timerElement && timerElement.dataset.startTime) {
        const startTime = new Date(timerElement.dataset.startTime);
        const now = new Date();
        const diff = Math.floor((now - startTime) / 1000);
        const hours = Math.floor(diff / 3600);
        const minutes = Math.floor((diff % 3600) / 60);
        const seconds = diff % 60;
        timerElement.textContent = `⏰ ${hours > 0 ? hours + ':' : ''}${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    }
}

function handleLike(button) {
    if (!isLoggedIn) {
        window.location.href = '/login.php?return=/live.php';
        return;
    }
    
    const streamId = parseInt(button.dataset.streamId);
    const isActive = button.classList.contains('active');
    const action = isActive ? 'unlike' : 'like';
    
    fetch('/api/live/interact.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            action: action,
            stream_id: streamId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            if (isActive) {
                button.classList.remove('active');
                const count = parseInt(button.querySelector('.count').textContent);
                button.querySelector('.count').textContent = Math.max(0, count - 1);
            } else {
                button.classList.add('active');
                const count = parseInt(button.querySelector('.count').textContent);
                button.querySelector('.count').textContent = count + 1;
                
                // Remove dislike if present
                const dislikeBtn = document.querySelector(`.dislike-btn[data-stream-id="${streamId}"]`);
                if (dislikeBtn && dislikeBtn.classList.contains('active')) {
                    dislikeBtn.classList.remove('active');
                    const dislikeCount = parseInt(dislikeBtn.querySelector('.count').textContent);
                    dislikeBtn.querySelector('.count').textContent = Math.max(0, dislikeCount - 1);
                }
            }
        } else if (data.error === 'Authentication required') {
            window.location.href = data.redirect;
        }
    })
    .catch(error => console.error('Error:', error));
}

function handleDislike(button) {
    if (!isLoggedIn) {
        window.location.href = '/login.php?return=/live.php';
        return;
    }
    
    const streamId = parseInt(button.dataset.streamId);
    const isActive = button.classList.contains('active');
    const action = isActive ? 'undislike' : 'dislike';
    
    fetch('/api/live/interact.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            action: action,
            stream_id: streamId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            if (isActive) {
                button.classList.remove('active');
                const count = parseInt(button.querySelector('.count').textContent);
                button.querySelector('.count').textContent = Math.max(0, count - 1);
            } else {
                button.classList.add('active');
                const count = parseInt(button.querySelector('.count').textContent);
                button.querySelector('.count').textContent = count + 1;
                
                // Remove like if present
                const likeBtn = document.querySelector(`.like-btn[data-stream-id="${streamId}"]`);
                if (likeBtn && likeBtn.classList.contains('active')) {
                    likeBtn.classList.remove('active');
                    const likeCount = parseInt(likeBtn.querySelector('.count').textContent);
                    likeBtn.querySelector('.count').textContent = Math.max(0, likeCount - 1);
                }
            }
        } else if (data.error === 'Authentication required') {
            window.location.href = data.redirect;
        }
    })
    .catch(error => console.error('Error:', error));
}

function sendMessage(streamId) {
    const input = document.getElementById('chatInput');
    const message = input.value.trim();
    
    if (!message) return;
    
    fetch('/api/live/interact.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            action: 'comment',
            stream_id: streamId,
            comment: message
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            input.value = '';
            loadComments(streamId);
        } else {
            alert('Error posting comment: ' + data.error);
        }
    })
    .catch(error => console.error('Error:', error));
}

function loadComments(streamId) {
    fetch('/api/live/interact.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            action: 'get_comments',
            stream_id: streamId,
            limit: 50
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success && data.comments) {
            const chatMessages = document.getElementById('chatMessages');
            if (chatMessages) {
                chatMessages.innerHTML = data.comments.map(comment => `
                    <div class="chat-message">
                        <strong>${escapeHtml(comment.username || 'Guest')}:</strong> 
                        ${escapeHtml(comment.comment_text)}
                    </div>
                `).join('');
                chatMessages.scrollTop = chatMessages.scrollHeight;
            }
        }
    })
    .catch(error => console.error('Error loading comments:', error));
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function switchStream(streamId) {
    // This would switch the main stream to another stream
    window.location.href = `/live.php?stream=${streamId}`;
}

function setReminder(eventId) {
    if (confirm('Set a reminder for this live event?')) {
        // In a real implementation, this would save the reminder
        const button = event.target;
        button.textContent = '✅ Reminder Set';
        button.disabled = true;
        button.style.background = '#10b981';
    }
}

function playStream(streamId) {
    // Open replay in modal instead of redirecting
    showReplayModal(streamId);
}

function showReplayModal(streamId) {
    // Fetch stream details
    fetch(`/api/streams/get.php?stream_id=${streamId}`)
        .then(response => response.json())
        .then(data => {
            if (data.success && data.stream) {
                const stream = data.stream;
                
                // Create modal HTML
                const modal = document.createElement('div');
                modal.id = 'replayModal';
                modal.style.cssText = 'display: flex; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.95); z-index: 10000; align-items: center; justify-content: center; padding: 20px;';
                
                const videoPath = stream.video_path || stream.stream_url;
                
                modal.innerHTML = `
                    <div style="max-width: 1200px; width: 100%; background: #1f2937; border-radius: 12px; overflow: hidden; position: relative;">
                        <button onclick="closeReplayModal()" style="position: absolute; top: 15px; right: 15px; width: 40px; height: 40px; border-radius: 50%; background: rgba(0,0,0,0.7); color: white; border: none; font-size: 20px; cursor: pointer; z-index: 1;">✕</button>
                        
                        <div style="position: relative; background: #000;">
                            ${videoPath ? `
                                <video controls autoplay controlsList="nodownload" preload="metadata" style="width: 100%; display: block; max-height: 70vh;" onerror="handleVideoError(this)">
                                    <source src="${escapeHtml(videoPath)}" type="video/mp4">
                                    <source src="${escapeHtml(videoPath)}" type="video/webm">
                                    Your browser does not support the video tag.
                                </video>
                            ` : `
                                <div style="aspect-ratio: 16/9; display: flex; flex-direction: column; align-items: center; justify-content: center; color: white; padding: 40px; text-align: center;">
                                    <div style="font-size: 64px; margin-bottom: 20px;">📹</div>
                                    <h3 style="font-size: 24px; margin-bottom: 10px;">Video Not Available</h3>
                                    <p style="font-size: 16px; opacity: 0.8;">This stream recording is currently unavailable.</p>
                                </div>
                            `}
                        </div>
                        
                        <div style="padding: 25px; color: white;">
                            <h2 style="font-size: 24px; margin-bottom: 15px;">${escapeHtml(stream.title)}</h2>
                            <div style="display: flex; gap: 20px; margin-bottom: 15px; flex-wrap: wrap; font-size: 14px; opacity: 0.8;">
                                <span>👤 ${escapeHtml(stream.vendor_name || 'Seller')}</span>
                                <span>🕒 ${formatStreamDate(stream.started_at)}</span>
                                <span>⏱️ ${formatStreamDuration(stream.started_at, stream.ended_at)}</span>
                            </div>
                            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; padding: 20px; background: rgba(0,0,0,0.3); border-radius: 8px;">
                                <div style="text-align: center;">
                                    <div style="font-size: 32px;">👥</div>
                                    <div style="font-size: 20px; font-weight: 600; margin: 5px 0;">${numberFormat(stream.viewer_count || 0)}</div>
                                    <div style="font-size: 13px; opacity: 0.7;">Viewers</div>
                                </div>
                                <div style="text-align: center;">
                                    <div style="font-size: 32px;">👍</div>
                                    <div style="font-size: 20px; font-weight: 600; margin: 5px 0;">${numberFormat(stream.like_count || 0)}</div>
                                    <div style="font-size: 13px; opacity: 0.7;">Likes</div>
                                </div>
                                <div style="text-align: center;">
                                    <div style="font-size: 32px;">💬</div>
                                    <div style="font-size: 20px; font-weight: 600; margin: 5px 0;">${numberFormat(stream.comment_count || 0)}</div>
                                    <div style="font-size: 13px; opacity: 0.7;">Comments</div>
                                </div>
                            </div>
                        </div>
                    </div>
                `;
                
                document.body.appendChild(modal);
                
                // Prevent body scroll
                document.body.style.overflow = 'hidden';
            } else {
                alert('Failed to load stream details');
            }
        })
        .catch(error => {
            console.error('Error loading stream:', error);
            alert('Failed to load stream replay');
        });
}

function closeReplayModal() {
    const modal = document.getElementById('replayModal');
    if (modal) {
        // Stop video if playing
        const video = modal.querySelector('video');
        if (video) {
            video.pause();
        }
        modal.remove();
        document.body.style.overflow = '';
    }
}

// Allow ESC key to close modal
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeReplayModal();
    }
});

function formatStreamDate(dateStr) {
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function formatStreamDuration(startStr, endStr) {
    if (!startStr || !endStr) return 'N/A';
    const start = new Date(startStr);
    const end = new Date(endStr);
    const diffSeconds = Math.floor((end - start) / 1000);
    const hours = Math.floor(diffSeconds / 3600);
    const minutes = Math.floor((diffSeconds % 3600) / 60);
    
    if (hours > 0) {
        return `${hours}h ${minutes}m`;
    }
    return `${minutes}m`;
}

function numberFormat(num) {
    return new Intl.NumberFormat().format(num);
}

function handleVideoError(videoElement) {
    // Replace video with error message
    const errorDiv = document.createElement('div');
    errorDiv.style.cssText = 'aspect-ratio: 16/9; display: flex; flex-direction: column; align-items: center; justify-content: center; color: white; padding: 40px; text-align: center; background: #000;';
    errorDiv.innerHTML = `
        <div style="font-size: 64px; margin-bottom: 20px;">⚠️</div>
        <h3 style="font-size: 24px; margin-bottom: 10px;">Unable to Load Video</h3>
        <p style="font-size: 16px; opacity: 0.8;">The stream recording could not be loaded. It may have been removed or is temporarily unavailable.</p>
    `;
    videoElement.parentElement.replaceChild(errorDiv, videoElement);
}

// Poll for live stream status updates every 30 seconds
function checkLiveStreamStatus() {
    fetch('/api/streams/list.php?type=all&limit=10')
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Check if page needs update based on counts
                const currentActive = document.querySelectorAll('.main-live-stream, .mini-stream').length;
                const actualActive = data.counts?.active || 0;
                
                // If count changed significantly, reload to show updated streams
                if (Math.abs(currentActive - actualActive) > 0) {
                    console.log('Stream status changed, reloading...');
                    location.reload();
                }
            }
        })
        .catch(error => console.error('Error checking stream status:', error));
}

// Trigger fake engagement for a stream
function triggerFakeEngagement(streamId) {
    fetch(`/api/streams/engagement.php?stream_id=${streamId}`)
        .then(response => response.json())
        .then(data => {
            if (data.success && data.current_stats) {
                // Update viewer count display
                updateViewerCountDisplay(streamId, data.current_stats.viewer_count);
                
                // Update like count display
                const likeBtn = document.querySelector(`.like-btn[data-stream-id="${streamId}"]`);
                if (likeBtn && data.current_stats.like_count) {
                    likeBtn.querySelector('.count').textContent = data.current_stats.like_count;
                }
            }
        })
        .catch(error => console.error('Error triggering fake engagement:', error));
}

function updateLiveStreamUI(liveStreams) {
    // Update live count
    const liveCount = document.querySelector('.live-count');
    if (liveCount) {
        liveCount.textContent = `${liveStreams.length} live events`;
    }
    
    // If no streams are live but page shows streams, reload to update
    if (liveStreams.length === 0 && document.querySelector('.main-live-stream')) {
        location.reload();
    }
    
    // If streams are live but page shows "no live streams", reload to update
    if (liveStreams.length > 0 && !document.querySelector('.main-live-stream')) {
        location.reload();
    }
    
    // Update viewer counts for visible streams
    liveStreams.forEach(stream => {
        const viewerCountEl = document.getElementById(`viewer-count-${stream.id}`);
        if (viewerCountEl) {
            const countSpan = viewerCountEl.querySelector('.count');
            if (countSpan) {
                countSpan.textContent = stream.viewer_count;
            }
        }
    });
}

// Start polling when page loads
if (document.querySelector('.live-now-section')) {
    // Check immediately
    checkLiveStreamStatus();
    
    // Then check every 30 seconds
    setInterval(checkLiveStreamStatus, 30000);
}

// Simulate live chat activity
setInterval(() => {
    const messages = [
        '<strong>LiveShopper99:</strong> This is amazing! 😍',
        '<strong>DealHunter:</strong> How much is shipping?',
        '<strong>TechReviewer:</strong> Great product showcase!',
        '<strong>BargainFinder:</strong> Is this the best price?'
    ];
    
    const chatMessages = document.getElementById('chatMessages');
    const randomMessage = messages[Math.floor(Math.random() * messages.length)];
    
    const messageDiv = document.createElement('div');
    messageDiv.className = 'chat-message';
    messageDiv.innerHTML = randomMessage;
    
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
    
    // Remove old messages to prevent overflow
    if (chatMessages.children.length > 10) {
        chatMessages.removeChild(chatMessages.firstChild);
    }
}, 8000);

// Allow Enter key to send messages
document.getElementById('chatInput')?.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        sendMessage();
    }
});

// Lazy load thumbnails using Intersection Observer
document.addEventListener('DOMContentLoaded', function() {
    const lazyImages = document.querySelectorAll('.lazy-thumbnail');
    
    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src;
                    img.classList.add('loaded');
                    img.removeAttribute('data-src');
                    imageObserver.unobserve(img);
                }
            });
        }, {
            rootMargin: '50px' // Start loading 50px before entering viewport
        });
        
        lazyImages.forEach(img => imageObserver.observe(img));
    } else {
        // Fallback for browsers without IntersectionObserver
        lazyImages.forEach(img => {
            img.src = img.dataset.src;
            img.classList.add('loaded');
        });
    }
});
</script>

<?php includeFooter(); ?>