<?php
/**
 * Stream Replay Template
 * Displays a recorded/archived live stream
 */

// Calculate duration display
$durationSeconds = 0;
if ($replayStream['started_at'] && $replayStream['ended_at']) {
    $durationSeconds = strtotime($replayStream['ended_at']) - strtotime($replayStream['started_at']);
}
$durationMinutes = floor($durationSeconds / 60);
$durationHours = floor($durationMinutes / 60);
$durationDisplay = $durationHours > 0 
    ? sprintf('%dh %dm', $durationHours, $durationMinutes % 60)
    : sprintf('%dm', $durationMinutes);
?>

<div class="container">
    <div class="replay-header">
        <a href="/live.php" class="back-link">← Back to Live</a>
        <h1>📼 Stream Replay</h1>
    </div>

    <div class="replay-container">
        <!-- Video Player Section -->
        <div class="replay-main">
            <div class="video-player-wrapper">
                <?php if (!empty($replayStream['video_path'])): ?>
                    <video controls autoplay class="replay-video">
                        <source src="<?php echo htmlspecialchars($replayStream['video_path']); ?>" type="video/mp4">
                        Your browser does not support the video tag.
                    </video>
                <?php elseif (!empty($replayStream['stream_url'])): ?>
                    <video controls autoplay class="replay-video">
                        <source src="<?php echo htmlspecialchars($replayStream['stream_url']); ?>" type="video/mp4">
                        Your browser does not support the video tag.
                    </video>
                <?php else: ?>
                    <div class="no-video-message">
                        <div class="placeholder-icon">📹</div>
                        <h3>Video Not Available</h3>
                        <p>This stream recording is currently unavailable.</p>
                    </div>
                <?php endif; ?>
                
                <div class="replay-badge-overlay">🔴 REPLAY</div>
            </div>
            
            <div class="stream-info">
                <h2><?php echo htmlspecialchars($replayStream['title']); ?></h2>
                <div class="stream-meta">
                    <span class="meta-item">
                        👤 <?php echo htmlspecialchars($replayStream['vendor_name'] ?? 'Seller'); ?>
                    </span>
                    <span class="meta-item">
                        🕒 <?php echo date('M j, Y g:i A', strtotime($replayStream['started_at'])); ?>
                    </span>
                    <span class="meta-item">
                        ⏱️ <?php echo $durationDisplay; ?>
                    </span>
                </div>
                
                <?php if (!empty($replayStream['description'])): ?>
                <div class="stream-description">
                    <p><?php echo nl2br(htmlspecialchars($replayStream['description'])); ?></p>
                </div>
                <?php endif; ?>
                
                <div class="stream-stats-box">
                    <div class="stat-item">
                        <span class="stat-icon">👥</span>
                        <span class="stat-label">Viewers</span>
                        <span class="stat-value"><?php echo number_format($replayStream['viewer_count'] ?? 0); ?></span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-icon">👍</span>
                        <span class="stat-label">Likes</span>
                        <span class="stat-value"><?php echo number_format($replayStream['like_count'] ?? 0); ?></span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-icon">💬</span>
                        <span class="stat-label">Comments</span>
                        <span class="stat-value"><?php echo number_format($replayStream['comment_count'] ?? 0); ?></span>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Sidebar with Products -->
        <div class="replay-sidebar">
            <h3>Featured Products</h3>
            
            <?php if (!empty($streamProducts)): ?>
                <div class="replay-products">
                    <?php foreach ($streamProducts as $streamProduct): 
                        // Get full product details
                        $productDetails = $product->findById($streamProduct['product_id']);
                        if (!$productDetails) continue;
                    ?>
                        <div class="replay-product-card">
                            <div class="product-image">
                                <img src="<?php echo getSafeProductImageUrl($productDetails); ?>" 
                                     alt="<?php echo htmlspecialchars($productDetails['name']); ?>">
                            </div>
                            <div class="product-details">
                                <h4><?php echo htmlspecialchars($productDetails['name']); ?></h4>
                                <div class="product-price">
                                    <?php if (!empty($streamProduct['special_price'])): ?>
                                        <span class="special-price"><?php echo formatPrice($streamProduct['special_price']); ?></span>
                                        <span class="original-price"><?php echo formatPrice($productDetails['price']); ?></span>
                                    <?php else: ?>
                                        <span class="current-price"><?php echo formatPrice($productDetails['price']); ?></span>
                                    <?php endif; ?>
                                </div>
                                <div class="product-actions">
                                    <a href="/product.php?id=<?php echo $productDetails['id']; ?>" class="btn btn-sm btn-primary">
                                        View Product
                                    </a>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            <?php else: ?>
                <p class="no-products">No products featured in this stream.</p>
            <?php endif; ?>
        </div>
    </div>
</div>

<style>
.replay-header {
    text-align: center;
    margin-bottom: 30px;
    padding: 20px 0;
}

.back-link {
    display: inline-block;
    margin-bottom: 15px;
    color: #0654ba;
    text-decoration: none;
    font-weight: 500;
}

.back-link:hover {
    text-decoration: underline;
}

.replay-header h1 {
    color: #1f2937;
    font-size: 32px;
    margin: 0;
}

.replay-container {
    display: grid;
    grid-template-columns: 1fr 400px;
    gap: 30px;
    margin-bottom: 60px;
}

.replay-main {
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
}

.video-player-wrapper {
    position: relative;
    background: #000;
    aspect-ratio: 16/9;
}

.replay-video {
    width: 100%;
    height: 100%;
    display: block;
}

.no-video-message {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    color: white;
    text-align: center;
    padding: 40px;
}

.placeholder-icon {
    font-size: 64px;
    margin-bottom: 20px;
}

.no-video-message h3 {
    font-size: 24px;
    margin-bottom: 10px;
}

.no-video-message p {
    font-size: 16px;
    opacity: 0.8;
}

.replay-badge-overlay {
    position: absolute;
    top: 15px;
    left: 15px;
    background: rgba(220, 38, 38, 0.9);
    color: white;
    padding: 6px 16px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
}

.stream-info {
    padding: 25px;
}

.stream-info h2 {
    color: #1f2937;
    font-size: 24px;
    margin-bottom: 15px;
}

.stream-meta {
    display: flex;
    gap: 20px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}

.meta-item {
    color: #6b7280;
    font-size: 14px;
}

.stream-description {
    background: #f9fafb;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 20px;
}

.stream-description p {
    color: #374151;
    line-height: 1.6;
    margin: 0;
}

.stream-stats-box {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
    padding: 20px;
    background: #f9fafb;
    border-radius: 8px;
}

.stat-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
}

.stat-icon {
    font-size: 32px;
    margin-bottom: 8px;
}

.stat-label {
    color: #6b7280;
    font-size: 13px;
    margin-bottom: 4px;
}

.stat-value {
    color: #1f2937;
    font-size: 20px;
    font-weight: 600;
}

.replay-sidebar {
    background: white;
    border-radius: 12px;
    padding: 25px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    height: fit-content;
}

.replay-sidebar h3 {
    color: #1f2937;
    font-size: 20px;
    margin-bottom: 20px;
}

.replay-products {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.replay-product-card {
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    overflow: hidden;
    transition: transform 0.3s ease;
}

.replay-product-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.product-image {
    width: 100%;
    aspect-ratio: 1;
    overflow: hidden;
    background: #f3f4f6;
}

.product-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.product-details {
    padding: 15px;
}

.product-details h4 {
    color: #1f2937;
    font-size: 16px;
    margin-bottom: 10px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.product-price {
    margin-bottom: 12px;
}

.special-price {
    color: #dc2626;
    font-weight: 600;
    font-size: 18px;
    margin-right: 8px;
}

.original-price {
    color: #6b7280;
    text-decoration: line-through;
    font-size: 14px;
}

.current-price {
    color: #1f2937;
    font-weight: 600;
    font-size: 18px;
}

.product-actions {
    margin-top: 12px;
}

.no-products {
    color: #6b7280;
    text-align: center;
    padding: 20px;
}

@media (max-width: 1024px) {
    .replay-container {
        grid-template-columns: 1fr;
    }
    
    .replay-sidebar {
        order: 2;
    }
    
    .replay-products {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 15px;
    }
}

@media (max-width: 768px) {
    .stream-stats-box {
        grid-template-columns: repeat(3, 1fr);
        gap: 10px;
        padding: 15px;
    }
    
    .stat-icon {
        font-size: 24px;
    }
    
    .stat-value {
        font-size: 16px;
    }
}
</style>
