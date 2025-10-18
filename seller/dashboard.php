<?php
/**
 * Seller Dashboard - Comprehensive KPIs and Analytics
 * E-Commerce Platform
 */

require_once __DIR__ . '/../includes/init.php';

// Require vendor login
Session::requireLogin();

// Load models
$vendor = new Vendor();
$product = new Product();
$order = new Order();

// Check if user is a vendor
$vendorInfo = $vendor->findByUserId(Session::getUserId());
if (!$vendorInfo || $vendorInfo['status'] !== 'approved') {
    redirect('/seller-onboarding.php');
}

$vendorId = $vendorInfo['id'];

// Get wallet information
$walletQuery = "SELECT * FROM seller_wallets WHERE vendor_id = ?";
$walletStmt = db()->prepare($walletQuery);
$walletStmt->execute([$vendorId]);
$wallet = $walletStmt->fetch();

// Get recent analytics
$analyticsQuery = "
    SELECT * FROM seller_analytics 
    WHERE vendor_id = ? 
    ORDER BY metric_date DESC 
    LIMIT 30
";
$analyticsStmt = db()->prepare($analyticsQuery);
$analyticsStmt->execute([$vendorId]);
$analytics = $analyticsStmt->fetchAll();

// Get current month stats
$currentMonth = date('Y-m');
$monthlyStatsQuery = "
    SELECT 
        SUM(commission_amount) as monthly_commission,
        COUNT(*) as monthly_orders,
        AVG(sale_amount) as avg_order_value
    FROM seller_commissions 
    WHERE vendor_id = ? 
    AND DATE_FORMAT(created_at, '%Y-%m') = ?
    AND status IN ('approved', 'paid')
";
$monthlyStatsStmt = db()->prepare($monthlyStatsQuery);
$monthlyStatsStmt->execute([$vendorId, $currentMonth]);
$monthlyStats = $monthlyStatsStmt->fetch();

// Get product stats
$productStatsQuery = "
    SELECT 
        COUNT(*) as total_products,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_products,
        SUM(CASE WHEN stock_quantity <= min_stock_level THEN 1 ELSE 0 END) as low_stock_products,
        SUM(view_count) as total_views,
        SUM(purchase_count) as total_sales
    FROM products 
    WHERE vendor_id = ?
";
$productStatsStmt = db()->prepare($productStatsQuery);
$productStatsStmt->execute([$vendorId]);
$productStats = $productStatsStmt->fetch();

// Get recent orders
$recentOrdersQuery = "
    SELECT 
        o.id, o.order_number, o.status, o.total, o.created_at,
        u.first_name, u.last_name, u.email,
        oi.product_name, oi.qty, oi.price
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN users u ON o.user_id = u.id
    WHERE oi.vendor_id = ?
    ORDER BY o.created_at DESC
    LIMIT 10
";
$recentOrdersStmt = db()->prepare($recentOrdersQuery);
$recentOrdersStmt->execute([$vendorId]);
$recentOrders = $recentOrdersStmt->fetchAll();

// Get top performing products
$topProductsQuery = "
    SELECT 
        p.id, p.name, p.price, p.stock_quantity,
        p.view_count, p.purchase_count, p.average_rating,
        SUM(sc.commission_amount) as total_commission
    FROM products p
    LEFT JOIN seller_commissions sc ON p.id = sc.product_id AND sc.vendor_id = ?
    WHERE p.vendor_id = ? AND p.status = 'active'
    GROUP BY p.id
    ORDER BY p.purchase_count DESC, p.view_count DESC
    LIMIT 5
";
$topProductsStmt = db()->prepare($topProductsQuery);
$topProductsStmt->execute([$vendorId, $vendorId]);
$topProducts = $topProductsStmt->fetchAll();

// Get total product views for vendor's products
$totalViewsQuery = "
    SELECT COUNT(*) as total_views
    FROM product_views pv
    INNER JOIN products p ON pv.product_id = p.id
    WHERE p.vendor_id = ?
";
$totalViewsStmt = db()->prepare($totalViewsQuery);
$totalViewsStmt->execute([$vendorId]);
$totalViews = $totalViewsStmt->fetchColumn();

// Get 24-hour product views
$views24hQuery = "
    SELECT COUNT(*) as views_24h
    FROM product_views pv
    INNER JOIN products p ON pv.product_id = p.id
    WHERE p.vendor_id = ?
    AND pv.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
";
$views24hStmt = db()->prepare($views24hQuery);
$views24hStmt->execute([$vendorId]);
$views24h = $views24hStmt->fetchColumn();

// Get top viewed products
$topViewedQuery = "
    SELECT 
        p.id, p.name, p.price,
        COUNT(pv.id) as view_count_24h
    FROM products p
    LEFT JOIN product_views pv ON p.id = pv.product_id 
        AND pv.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
    WHERE p.vendor_id = ?
    GROUP BY p.id
    ORDER BY view_count_24h DESC
    LIMIT 5
";
$topViewedStmt = db()->prepare($topViewedQuery);
$topViewedStmt->execute([$vendorId]);
$topViewedProducts = $topViewedStmt->fetchAll();

// Get pending notifications
$notificationsQuery = "
    SELECT * FROM notifications 
    WHERE user_id = ? AND read_at IS NULL 
    ORDER BY created_at DESC 
    LIMIT 5
";
$notificationsStmt = db()->prepare($notificationsQuery);
$notificationsStmt->execute([Session::getUserId()]);
$notifications = $notificationsStmt->fetchAll();

// Get recent saved streams for this vendor
$recentStreamsQuery = "
    SELECT 
        ss.*,
        TIMESTAMPDIFF(SECOND, ss.streamed_at, NOW()) as time_ago_seconds
    FROM saved_streams ss
    WHERE ss.seller_id = ?
    ORDER BY ss.created_at DESC
    LIMIT 20
";
$recentStreamsStmt = db()->prepare($recentStreamsQuery);
$recentStreamsStmt->execute([Session::getUserId()]);
$recentStreams = $recentStreamsStmt->fetchAll();

$page_title = 'Seller Dashboard - ' . htmlspecialchars($vendorInfo['business_name']);
includeHeader($page_title);
?>

<div class="seller-dashboard">
    <!-- Header -->
    <div class="dashboard-header">
        <div class="header-content">
            <div class="seller-info">
                <h1>Welcome back, <?php echo htmlspecialchars($vendorInfo['business_name']); ?>!</h1>
                <p class="subtitle">Track your performance and manage your store</p>
            </div>
            <div class="quick-actions">
                <a href="/seller/products/add.php" class="btn btn-primary">+ Add Product</a>
                <a href="/seller/orders.php" class="btn btn-outline">View Orders</a>
            </div>
        </div>
    </div>

    <?php
    // Check KYC verification status
    if (function_exists('canSellerListProducts')) {
        $kycStatus = canSellerListProducts(Session::getUserId());
        if (!$kycStatus['can_sell'] && $kycStatus['kyc_status'] !== 'vendor_pending'):
    ?>
    <!-- KYC Warning Banner -->
    <div class="alert alert-warning d-flex align-items-center mb-4" role="alert" style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 1rem; border-radius: 0.5rem;">
        <div style="flex-shrink: 0; margin-right: 1rem;">
            <svg style="width: 32px; height: 32px; color: #856404;" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
            </svg>
        </div>
        <div style="flex-grow: 1;">
            <h6 style="margin: 0 0 0.5rem 0; font-weight: 600; color: #856404;">KYC Verification Required</h6>
            <p style="margin: 0; color: #856404;"><?php echo htmlspecialchars($kycStatus['message']); ?></p>
            <?php if ($kycStatus['kyc_status'] === 'not_submitted'): ?>
            <a href="/seller/kyc.php" class="btn btn-sm" style="margin-top: 0.75rem; background-color: #ffc107; color: #000; border: none; padding: 0.375rem 0.75rem; border-radius: 0.25rem; text-decoration: none; display: inline-block;">
                Complete KYC Verification →
            </a>
            <?php endif; ?>
        </div>
    </div>
    <?php 
        elseif ($kycStatus['kyc_status'] === 'pending' || $kycStatus['kyc_status'] === 'under_review'):
    ?>
    <!-- KYC Pending Banner -->
    <div class="alert alert-info d-flex align-items-center mb-4" role="alert" style="background-color: #d1ecf1; border-left: 4px solid #0dcaf0; padding: 1rem; border-radius: 0.5rem;">
        <div style="flex-shrink: 0; margin-right: 1rem;">
            <svg style="width: 32px; height: 32px; color: #055160;" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
            </svg>
        </div>
        <div style="flex-grow: 1;">
            <h6 style="margin: 0 0 0.5rem 0; font-weight: 600; color: #055160;">KYC Verification Pending</h6>
            <p style="margin: 0; color: #055160;">Your KYC verification is under review. You'll be able to list products once approved.</p>
        </div>
    </div>
    <?php 
        endif;
    }
    ?>

    <!-- KPI Cards -->
    <div class="kpi-grid">
        <!-- Revenue Card -->
        <div class="kpi-card revenue">
            <div class="kpi-icon">💰</div>
            <div class="kpi-content">
                <h3>Total Revenue</h3>
                <div class="kpi-value">$<?php echo number_format($wallet['total_earned'] ?? 0, 2); ?></div>
                <div class="kpi-change positive">
                    <span>+<?php echo number_format($monthlyStats['monthly_commission'] ?? 0, 2); ?></span>
                    <span class="period">this month</span>
                </div>
            </div>
        </div>

        <!-- Orders Card -->
        <div class="kpi-card orders">
            <div class="kpi-icon">📦</div>
            <div class="kpi-content">
                <h3>Total Orders</h3>
                <div class="kpi-value"><?php echo number_format($monthlyStats['monthly_orders'] ?? 0); ?></div>
                <div class="kpi-change">
                    <span class="period">this month</span>
                </div>
            </div>
        </div>

        <!-- Products Card -->
        <div class="kpi-card products">
            <div class="kpi-icon">🛍️</div>
            <div class="kpi-content">
                <h3>Active Products</h3>
                <div class="kpi-value"><?php echo $productStats['active_products']; ?></div>
                <div class="kpi-meta">
                    <span><?php echo $productStats['total_products']; ?> total</span>
                    <?php if ($productStats['low_stock_products'] > 0): ?>
                        <span class="warning"><?php echo $productStats['low_stock_products']; ?> low stock</span>
                    <?php endif; ?>
                </div>
            </div>
        </div>

        <!-- Wallet Card -->
        <div class="kpi-card wallet">
            <div class="kpi-icon">💳</div>
            <div class="kpi-content">
                <h3>Available Balance</h3>
                <div class="kpi-value">$<?php echo number_format($wallet['balance'] ?? 0, 2); ?></div>
                <div class="kpi-meta">
                    <span>$<?php echo number_format($wallet['pending_balance'] ?? 0, 2); ?> pending</span>
                    <a href="/seller/finance.php" class="withdraw-link">Withdraw</a>
                </div>
            </div>
        </div>

        <!-- Product Views Card -->
        <div class="kpi-card views">
            <div class="kpi-icon">👁️</div>
            <div class="kpi-content">
                <h3>Product Views</h3>
                <div class="kpi-value"><?php echo number_format($totalViews); ?></div>
                <div class="kpi-change positive">
                    <span>+<?php echo number_format($views24h); ?></span>
                    <span class="period">last 24 hours</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Analytics Section -->
    <div class="analytics-section" style="margin: 30px 0;">
        <div class="dashboard-widget analytics-widget">
            <div class="widget-header">
                <h3>📊 Product Analytics</h3>
            </div>
            <div class="widget-content">
                <div class="analytics-grid">
                    <div class="analytics-stat">
                        <div class="stat-value"><?php echo number_format($totalViews); ?></div>
                        <div class="stat-label">Total Views</div>
                    </div>
                    <div class="analytics-stat">
                        <div class="stat-value"><?php echo number_format($views24h); ?></div>
                        <div class="stat-label">Views (24h)</div>
                    </div>
                    <div class="analytics-stat">
                        <div class="stat-value"><?php echo number_format($productStats['total_sales'] ?? 0); ?></div>
                        <div class="stat-label">Total Sales</div>
                    </div>
                    <div class="analytics-stat">
                        <div class="stat-value"><?php echo $productStats['active_products']; ?></div>
                        <div class="stat-label">Active Products</div>
                    </div>
                </div>
                
                <?php if (!empty($topViewedProducts)): ?>
                <div class="top-viewed-products" style="margin-top: 20px;">
                    <h4 style="margin-bottom: 15px;">Top Viewed Products (24h)</h4>
                    <table class="analytics-table">
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>Price</th>
                                <th>Views (24h)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($topViewedProducts as $viewedProd): ?>
                            <tr>
                                <td>
                                    <a href="/product.php?id=<?php echo $viewedProd['id']; ?>">
                                        <?php echo htmlspecialchars($viewedProd['name']); ?>
                                    </a>
                                </td>
                                <td>$<?php echo number_format($viewedProd['price'], 2); ?></td>
                                <td><strong><?php echo number_format($viewedProd['view_count_24h']); ?></strong></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <!-- Main Content Grid -->
    <div class="dashboard-grid">
        <!-- Recent Orders -->
        <div class="dashboard-widget orders-widget">
            <div class="widget-header">
                <h3>Recent Orders</h3>
                <a href="/seller/orders.php" class="view-all">View All</a>
            </div>
            <div class="widget-content">
                <?php if (!empty($recentOrders)): ?>
                    <div class="orders-list">
                        <?php foreach ($recentOrders as $order): ?>
                            <div class="order-item">
                                <div class="order-info">
                                    <div class="order-number">#<?php echo $order['order_number']; ?></div>
                                    <div class="customer-name"><?php echo htmlspecialchars($order['first_name'] . ' ' . $order['last_name']); ?></div>
                                    <div class="product-info"><?php echo htmlspecialchars($order['product_name']); ?> (×<?php echo $order['qty']; ?>)</div>
                                </div>
                                <div class="order-meta">
                                    <div class="order-status status-<?php echo strtolower($order['status']); ?>">
                                        <?php echo ucfirst($order['status']); ?>
                                    </div>
                                    <div class="order-amount">$<?php echo number_format($order['price'] * $order['qty'], 2); ?></div>
                                    <div class="order-date"><?php echo formatTimeAgo($order['created_at']); ?></div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    </div>
                <?php else: ?>
                    <div class="empty-state">
                        <p>No orders yet. Start promoting your products!</p>
                    </div>
                <?php endif; ?>
            </div>
        </div>

        <!-- Top Products -->
        <div class="dashboard-widget products-widget">
            <div class="widget-header">
                <h3>Top Performing Products</h3>
                <a href="/seller/products.php" class="view-all">Manage Products</a>
            </div>
            <div class="widget-content">
                <?php if (!empty($topProducts)): ?>
                    <div class="products-list">
                        <?php foreach ($topProducts as $product): ?>
                            <div class="product-item">
                                <div class="product-info">
                                    <div class="product-name">
                                        <a href="/product.php?id=<?php echo $product['id']; ?>" target="_blank" style="color: inherit; text-decoration: none;">
                                            <?php echo htmlspecialchars($product['name']); ?>
                                        </a>
                                    </div>
                                    <div class="product-price">$<?php echo number_format($product['price'], 2); ?></div>
                                </div>
                                <div class="product-stats">
                                    <span class="stat">
                                        <span class="value"><?php echo $product['purchase_count']; ?></span>
                                        <span class="label">sold</span>
                                    </span>
                                    <span class="stat">
                                        <span class="value"><?php echo $product['view_count']; ?></span>
                                        <span class="label">views</span>
                                    </span>
                                    <?php if ($product['average_rating'] > 0): ?>
                                        <span class="stat">
                                            <span class="value">⭐ <?php echo number_format($product['average_rating'], 1); ?></span>
                                        </span>
                                    <?php endif; ?>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    </div>
                <?php else: ?>
                    <div class="empty-state">
                        <p>Add products to see performance data.</p>
                        <a href="/seller/products/add.php" class="btn btn-sm btn-primary">Add Product</a>
                    </div>
                <?php endif; ?>
            </div>
        </div>

        <!-- Recent Streams Section -->
        <?php if (!empty($recentStreams)): ?>
        <div class="dashboard-widget recent-streams-widget">
            <div class="widget-header">
                <h3>📼 Recent Streams</h3>
                <a href="/seller/streams.php" class="view-all">View All</a>
            </div>
            <div class="widget-content">
                <div class="recent-streams-scroll-container">
                    <div class="recent-streams-grid">
                        <?php foreach ($recentStreams as $stream): 
                            $durationMinutes = floor($stream['duration'] / 60);
                            $durationHours = floor($durationMinutes / 60);
                            $durationDisplay = $durationHours > 0 
                                ? sprintf('%dh %dm', $durationHours, $durationMinutes % 60)
                                : sprintf('%dm', $durationMinutes);
                            
                            $timeAgo = formatTimeAgo($stream['streamed_at']);
                        ?>
                        <div class="stream-card">
                            <div class="stream-thumbnail">
                                <?php if ($stream['thumbnail_url']): ?>
                                    <img src="<?php echo htmlspecialchars($stream['thumbnail_url']); ?>" 
                                         alt="<?php echo htmlspecialchars($stream['stream_title']); ?>">
                                <?php else: ?>
                                    <div class="thumbnail-placeholder">
                                        <span class="placeholder-icon">📹</span>
                                    </div>
                                <?php endif; ?>
                                <div class="stream-duration"><?php echo $durationDisplay; ?></div>
                                <div class="stream-overlay">
                                    <button class="play-btn" onclick="replayStream(<?php echo $stream['id']; ?>)" title="Replay Stream">
                                        <svg width="40" height="40" viewBox="0 0 40 40" fill="white">
                                            <circle cx="20" cy="20" r="18" fill="rgba(0,0,0,0.7)" />
                                            <path d="M16 12l12 8-12 8z" />
                                        </svg>
                                    </button>
                                </div>
                            </div>
                            <div class="stream-info">
                                <h4 class="stream-title" title="<?php echo htmlspecialchars($stream['stream_title']); ?>">
                                    <?php echo htmlspecialchars(substr($stream['stream_title'], 0, 50)); ?>
                                    <?php if (strlen($stream['stream_title']) > 50) echo '...'; ?>
                                </h4>
                                <div class="stream-stats">
                                    <span class="stat-item">
                                        <span class="stat-icon">👁️</span>
                                        <span class="stat-value"><?php echo number_format($stream['views']); ?></span>
                                    </span>
                                    <span class="stat-item">
                                        <span class="stat-icon">👍</span>
                                        <span class="stat-value"><?php echo number_format($stream['likes']); ?></span>
                                    </span>
                                </div>
                                <div class="stream-time"><?php echo $timeAgo; ?></div>
                                <div class="stream-actions">
                                    <button class="btn-action btn-replay" onclick="replayStream(<?php echo $stream['id']; ?>)" title="Replay">
                                        ▶️ Replay
                                    </button>
                                    <button class="btn-action btn-delete" onclick="deleteStream(<?php echo $stream['id']; ?>)" title="Delete">
                                        🗑️ Delete
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

        <!-- Analytics Chart -->
        <div class="dashboard-widget analytics-widget">
            <div class="widget-header">
                <h3>Revenue Trend (Last 30 Days)</h3>
                <div class="chart-controls">
                    <button class="chart-period active" data-period="30">30D</button>
                    <button class="chart-period" data-period="7">7D</button>
                </div>
            </div>
            <div class="widget-content">
                <div class="chart-container">
                    <canvas id="revenueChart" width="400" height="200"></canvas>
                </div>
            </div>
        </div>

        <!-- Notifications -->
        <div class="dashboard-widget notifications-widget">
            <div class="widget-header">
                <h3>Notifications</h3>
                <a href="/notifications.php" class="view-all">View All</a>
            </div>
            <div class="widget-content">
                <?php if (!empty($notifications)): ?>
                    <div class="notifications-list">
                        <?php foreach ($notifications as $notification): ?>
                            <div class="notification-item priority-<?php echo $notification['priority']; ?>">
                                <div class="notification-icon"><?php echo $notification['icon'] ?? '🔔'; ?></div>
                                <div class="notification-content">
                                    <div class="notification-title"><?php echo htmlspecialchars($notification['title']); ?></div>
                                    <div class="notification-message"><?php echo htmlspecialchars($notification['message']); ?></div>
                                    <div class="notification-time"><?php echo formatTimeAgo($notification['created_at']); ?></div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    </div>
                <?php else: ?>
                    <div class="empty-state">
                        <p>No new notifications.</p>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<style>
.seller-dashboard {
    max-width: 1400px;
    margin: 0 auto;
    padding: 20px;
}

.dashboard-header {
    margin-bottom: 30px;
    padding: 30px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 12px;
    color: white;
}

.header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.seller-info h1 {
    margin: 0 0 8px 0;
    font-size: 28px;
    font-weight: 700;
}

.subtitle {
    margin: 0;
    opacity: 0.9;
    font-size: 16px;
}

.quick-actions {
    display: flex;
    gap: 12px;
}

.kpi-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 24px;
    margin-bottom: 30px;
}

.kpi-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    border: 1px solid #e5e7eb;
    display: flex;
    align-items: center;
    gap: 20px;
}

.kpi-icon {
    font-size: 32px;
    width: 64px;
    height: 64px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
    background: #f8fafc;
}

.kpi-content h3 {
    margin: 0 0 8px 0;
    font-size: 14px;
    font-weight: 600;
    color: #6b7280;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}

.kpi-value {
    font-size: 28px;
    font-weight: 700;
    color: #1f2937;
    margin-bottom: 4px;
}

.kpi-change {
    font-size: 14px;
    display: flex;
    align-items: center;
    gap: 8px;
}

.kpi-change.positive {
    color: #059669;
}

.kpi-change.negative {
    color: #dc2626;
}

.kpi-meta {
    font-size: 12px;
    color: #6b7280;
    display: flex;
    align-items: center;
    gap: 12px;
}

.warning {
    color: #f59e0b !important;
    font-weight: 600;
}

.withdraw-link {
    color: #3b82f6;
    text-decoration: none;
    font-weight: 600;
}

.dashboard-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: 24px;
}

.dashboard-widget {
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    border: 1px solid #e5e7eb;
    overflow: hidden;
}

.widget-header {
    padding: 20px 24px;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.widget-header h3 {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
    color: #1f2937;
}

.view-all {
    color: #3b82f6;
    text-decoration: none;
    font-size: 14px;
    font-weight: 500;
}

.widget-content {
    padding: 24px;
}

.orders-list, .products-list, .notifications-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.order-item, .product-item, .notification-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    transition: all 0.2s ease;
}

.order-item:hover, .product-item:hover, .notification-item:hover {
    border-color: #d1d5db;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.order-info, .product-info, .notification-content {
    flex: 1;
}

.order-number, .product-name, .notification-title {
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 4px;
}

.customer-name, .product-price, .notification-message {
    color: #6b7280;
    font-size: 14px;
    margin-bottom: 4px;
}

.product-info, .order-meta {
    text-align: right;
}

.order-status {
    display: inline-block;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
    margin-bottom: 4px;
}

.status-pending { background: #fef3c7; color: #92400e; }
.status-processing { background: #dbeafe; color: #1e40af; }
.status-shipped { background: #dcfce7; color: #166534; }
.status-delivered { background: #dcfce7; color: #166534; }
.status-cancelled { background: #fee2e2; color: #dc2626; }

.product-stats {
    display: flex;
    gap: 12px;
    align-items: center;
}

.stat {
    display: flex;
    flex-direction: column;
    align-items: center;
    font-size: 12px;
}

.stat .value {
    font-weight: 600;
    color: #1f2937;
}

.stat .label {
    color: #6b7280;
}

.empty-state {
    text-align: center;
    padding: 40px 20px;
    color: #6b7280;
}

.chart-controls {
    display: flex;
    gap: 8px;
}

.chart-period {
    padding: 4px 12px;
    border: 1px solid #d1d5db;
    background: white;
    border-radius: 4px;
    font-size: 12px;
    cursor: pointer;
}

.chart-period.active {
    background: #3b82f6;
    color: white;
    border-color: #3b82f6;
}

.chart-container {
    height: 200px;
    position: relative;
}

.notification-item {
    display: flex;
    gap: 12px;
    align-items: flex-start;
}

.notification-icon {
    font-size: 20px;
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 8px;
    background: #f3f4f6;
    flex-shrink: 0;
}

.priority-high .notification-icon {
    background: #fee2e2;
}

.priority-urgent .notification-icon {
    background: #fef2f2;
}

.notification-time {
    font-size: 12px;
    color: #9ca3af;
    margin-top: 4px;
}

/* Recent Streams Section */
.recent-streams-widget {
    grid-column: 1 / -1;
}

.recent-streams-scroll-container {
    overflow-x: auto;
    overflow-y: hidden;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: thin;
    scrollbar-color: #cbd5e0 #f7fafc;
}

.recent-streams-scroll-container::-webkit-scrollbar {
    height: 8px;
}

.recent-streams-scroll-container::-webkit-scrollbar-track {
    background: #f7fafc;
    border-radius: 4px;
}

.recent-streams-scroll-container::-webkit-scrollbar-thumb {
    background: #cbd5e0;
    border-radius: 4px;
}

.recent-streams-scroll-container::-webkit-scrollbar-thumb:hover {
    background: #a0aec0;
}

.recent-streams-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 20px;
    padding: 4px 0;
    min-width: min-content;
}

@media (min-width: 1280px) {
    .recent-streams-grid {
        grid-template-columns: repeat(5, 1fr);
    }
}

.stream-card {
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    transition: all 0.3s ease;
    cursor: pointer;
    min-width: 240px;
}

.stream-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 16px rgba(0,0,0,0.12);
}

.stream-thumbnail {
    position: relative;
    width: 100%;
    aspect-ratio: 16/9;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    overflow: hidden;
}

.stream-thumbnail img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.thumbnail-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
}

.placeholder-icon {
    font-size: 48px;
    opacity: 0.8;
}

.stream-duration {
    position: absolute;
    bottom: 8px;
    right: 8px;
    background: rgba(0, 0, 0, 0.85);
    color: white;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 600;
}

.stream-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.4);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    transition: opacity 0.3s ease;
}

.stream-card:hover .stream-overlay {
    opacity: 1;
}

.play-btn {
    background: none;
    border: none;
    cursor: pointer;
    transform: scale(1);
    transition: transform 0.2s ease;
}

.play-btn:hover {
    transform: scale(1.1);
}

.stream-info {
    padding: 12px;
}

.stream-title {
    font-size: 14px;
    font-weight: 600;
    color: #1f2937;
    margin: 0 0 8px 0;
    line-height: 1.4;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.stream-stats {
    display: flex;
    gap: 12px;
    margin-bottom: 8px;
}

.stat-item {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 12px;
    color: #6b7280;
}

.stat-icon {
    font-size: 14px;
}

.stat-value {
    font-weight: 500;
}

.stream-time {
    font-size: 11px;
    color: #9ca3af;
    margin-bottom: 8px;
}

.stream-actions {
    display: flex;
    gap: 6px;
}

.btn-action {
    flex: 1;
    padding: 6px 10px;
    border: none;
    border-radius: 6px;
    font-size: 11px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
    text-align: center;
}

.btn-replay {
    background: #10b981;
    color: white;
}

.btn-replay:hover {
    background: #059669;
}

.btn-delete {
    background: #ef4444;
    color: white;
}

.btn-delete:hover {
    background: #dc2626;
}

@media (max-width: 768px) {
    .seller-dashboard {
        padding: 16px;
    }
    
    .header-content {
        flex-direction: column;
        gap: 16px;
        align-items: flex-start;
    }
    
    .kpi-grid {
        grid-template-columns: 1fr;
    }
    
    .dashboard-grid {
        grid-template-columns: 1fr;
    }
    
    .order-item, .product-item {
        flex-direction: column;
        align-items: flex-start;
        gap: 12px;
    }
    
    .order-meta, .product-info {
        text-align: left;
    }
}
</style>

<script>
// Simple chart for revenue trend
document.addEventListener('DOMContentLoaded', function() {
    const canvas = document.getElementById('revenueChart');
    if (canvas) {
        const ctx = canvas.getContext('2d');
        
        // Sample data - in production, this would come from PHP
        const analytics = <?php echo json_encode($analytics); ?>;
        
        // Simple line chart implementation
        drawRevenueChart(ctx, analytics);
    }
});

function drawRevenueChart(ctx, data) {
    // Basic implementation - replace with Chart.js or similar in production
    ctx.strokeStyle = '#3b82f6';
    ctx.lineWidth = 2;
    ctx.beginPath();
    
    const width = ctx.canvas.width;
    const height = ctx.canvas.height;
    const padding = 40;
    
    if (data.length > 0) {
        data.forEach((point, index) => {
            const x = padding + (index / (data.length - 1)) * (width - 2 * padding);
            const y = height - padding - (parseFloat(point.total_revenue) / 1000) * (height - 2 * padding);
            
            if (index === 0) {
                ctx.moveTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
        });
        
        ctx.stroke();
    }
}

// Chart period switching
document.querySelectorAll('.chart-period').forEach(button => {
    button.addEventListener('click', function() {
        document.querySelectorAll('.chart-period').forEach(b => b.classList.remove('active'));
        this.classList.add('active');
        
        // In production, reload chart data via AJAX
        console.log('Load data for period:', this.dataset.period);
    });
});

// Recent Streams Functions
function replayStream(streamId) {
    // Redirect to stream replay page or open modal
    window.location.href = `/watch?stream_id=${streamId}`;
}

function deleteStream(streamId) {
    if (!confirm('Are you sure you want to delete this stream? This action cannot be undone.')) {
        return;
    }
    
    // Send delete request
    fetch(`/api/streams/delete-saved.php`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ stream_id: streamId })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Show success message
            showNotification('Stream deleted successfully', 'success');
            // Reload page after a short delay
            setTimeout(() => {
                window.location.reload();
            }, 1000);
        } else {
            showNotification('Error: ' + data.error, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Failed to delete stream', 'error');
    });
}

function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'error' ? '#ef4444' : type === 'success' ? '#10b981' : '#3b82f6'};
        color: white;
        padding: 16px 24px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 10000;
        max-width: 400px;
        font-weight: 600;
    `;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.transition = 'opacity 0.3s';
        notification.style.opacity = '0';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}
</script>

<?php includeFooter(); ?>