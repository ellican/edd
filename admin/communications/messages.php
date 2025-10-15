<?php
/**
 * Admin Product Inquiry Messages Panel
 * View and manage all product inquiry conversations
 */

require_once __DIR__ . '/../../includes/init.php';

// Require admin authentication
Session::requireLogin();
Session::requireRole('admin');

$db = Database::getInstance()->getConnection();

// Get filter parameters
$filter = $_GET['filter'] ?? 'all'; // all, active, archived, flagged
$searchProduct = $_GET['search_product'] ?? '';
$searchBuyer = $_GET['search_buyer'] ?? '';
$searchSeller = $_GET['search_seller'] ?? '';
$dateFrom = $_GET['date_from'] ?? '';
$dateTo = $_GET['date_to'] ?? '';
$page = max(1, (int)($_GET['page'] ?? 1));
$limit = 20;
$offset = ($page - 1) * $limit;

// Build query
$whereConditions = [];
$params = [];

if ($filter === 'active') {
    $whereConditions[] = "ct.status = 'active'";
} elseif ($filter === 'archived') {
    $whereConditions[] = "ct.status = 'archived'";
} elseif ($filter === 'flagged') {
    $whereConditions[] = "ct.status = 'flagged' OR EXISTS (
        SELECT 1 FROM product_inquiry_messages pim 
        WHERE pim.thread_id = ct.id AND pim.flagged = 1
    )";
}

if ($searchProduct) {
    $whereConditions[] = "p.name LIKE ?";
    $params[] = "%{$searchProduct}%";
}

if ($searchBuyer) {
    $whereConditions[] = "(buyer.username LIKE ? OR buyer.email LIKE ?)";
    $params[] = "%{$searchBuyer}%";
    $params[] = "%{$searchBuyer}%";
}

if ($searchSeller) {
    $whereConditions[] = "(seller.username LIKE ? OR seller.email LIKE ?)";
    $params[] = "%{$searchSeller}%";
    $params[] = "%{$searchSeller}%";
}

if ($dateFrom) {
    $whereConditions[] = "ct.created_at >= ?";
    $params[] = $dateFrom . ' 00:00:00';
}

if ($dateTo) {
    $whereConditions[] = "ct.created_at <= ?";
    $params[] = $dateTo . ' 23:59:59';
}

$whereClause = !empty($whereConditions) ? 'WHERE ' . implode(' AND ', $whereConditions) : '';

// Get conversations
$query = "
    SELECT 
        ct.id as thread_id,
        ct.product_id,
        ct.buyer_id,
        ct.seller_id,
        ct.status,
        ct.last_message_at,
        ct.created_at,
        p.name as product_name,
        p.image as product_image,
        buyer.username as buyer_username,
        buyer.email as buyer_email,
        seller.username as seller_username,
        seller.email as seller_email,
        (SELECT COUNT(*) FROM product_inquiry_messages WHERE thread_id = ct.id) as message_count,
        (SELECT COUNT(*) FROM product_inquiry_messages WHERE thread_id = ct.id AND flagged = 1) as flagged_count
    FROM conversation_threads ct
    INNER JOIN products p ON ct.product_id = p.id
    INNER JOIN users buyer ON ct.buyer_id = buyer.id
    INNER JOIN users seller ON ct.seller_id = seller.id
    $whereClause
    ORDER BY ct.last_message_at DESC
    LIMIT $limit OFFSET $offset
";

$stmt = $db->prepare($query);
$stmt->execute($params);
$conversations = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Get total count
$countQuery = "SELECT COUNT(*) FROM conversation_threads ct
    INNER JOIN products p ON ct.product_id = p.id
    INNER JOIN users buyer ON ct.buyer_id = buyer.id
    INNER JOIN users seller ON ct.seller_id = seller.id
    $whereClause";
$countStmt = $db->prepare($countQuery);
$countStmt->execute($params);
$totalCount = $countStmt->fetchColumn();
$totalPages = ceil($totalCount / $limit);

// Get statistics
$statsQuery = "
    SELECT 
        COUNT(*) as total_threads,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_threads,
        SUM(CASE WHEN status = 'flagged' THEN 1 ELSE 0 END) as flagged_threads,
        (SELECT COUNT(*) FROM product_inquiry_messages WHERE flagged = 1) as flagged_messages
    FROM conversation_threads
";
$statsStmt = $db->query($statsQuery);
$stats = $statsStmt->fetch(PDO::FETCH_ASSOC);

$page_title = 'Product Inquiry Messages';
include __DIR__ . '/../includes/admin_header.php';
?>

<div class="admin-content">
    <div class="page-header">
        <h1>📬 Product Inquiry Messages</h1>
        <p>Monitor and manage buyer-seller product conversations</p>
    </div>
    
    <!-- Statistics Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon">💬</div>
            <div class="stat-info">
                <h3><?= number_format($stats['total_threads']) ?></h3>
                <p>Total Conversations</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon">✅</div>
            <div class="stat-info">
                <h3><?= number_format($stats['active_threads']) ?></h3>
                <p>Active Threads</p>
            </div>
        </div>
        <div class="stat-card warning">
            <div class="stat-icon">🚩</div>
            <div class="stat-info">
                <h3><?= number_format($stats['flagged_threads']) ?></h3>
                <p>Flagged Threads</p>
            </div>
        </div>
        <div class="stat-card danger">
            <div class="stat-icon">⚠️</div>
            <div class="stat-info">
                <h3><?= number_format($stats['flagged_messages']) ?></h3>
                <p>Flagged Messages</p>
            </div>
        </div>
    </div>
    
    <!-- Filters -->
    <div class="filters-panel">
        <form method="GET" class="filters-form">
            <div class="filter-row">
                <div class="filter-group">
                    <label>Status</label>
                    <select name="filter" onchange="this.form.submit()">
                        <option value="all" <?= $filter === 'all' ? 'selected' : '' ?>>All</option>
                        <option value="active" <?= $filter === 'active' ? 'selected' : '' ?>>Active</option>
                        <option value="archived" <?= $filter === 'archived' ? 'selected' : '' ?>>Archived</option>
                        <option value="flagged" <?= $filter === 'flagged' ? 'selected' : '' ?>>Flagged</option>
                    </select>
                </div>
                
                <div class="filter-group">
                    <label>Product</label>
                    <input type="text" name="search_product" placeholder="Search product..." value="<?= htmlspecialchars($searchProduct) ?>">
                </div>
                
                <div class="filter-group">
                    <label>Buyer</label>
                    <input type="text" name="search_buyer" placeholder="Search buyer..." value="<?= htmlspecialchars($searchBuyer) ?>">
                </div>
                
                <div class="filter-group">
                    <label>Seller</label>
                    <input type="text" name="search_seller" placeholder="Search seller..." value="<?= htmlspecialchars($searchSeller) ?>">
                </div>
                
                <div class="filter-group">
                    <label>Date From</label>
                    <input type="date" name="date_from" value="<?= htmlspecialchars($dateFrom) ?>">
                </div>
                
                <div class="filter-group">
                    <label>Date To</label>
                    <input type="date" name="date_to" value="<?= htmlspecialchars($dateTo) ?>">
                </div>
                
                <div class="filter-actions">
                    <button type="submit" class="btn btn-primary">Apply</button>
                    <a href="messages.php" class="btn btn-secondary">Reset</a>
                </div>
            </div>
        </form>
    </div>
    
    <!-- Conversations Table -->
    <div class="data-table-container">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Buyer</th>
                    <th>Seller</th>
                    <th>Messages</th>
                    <th>Status</th>
                    <th>Last Activity</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($conversations)): ?>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 40px;">
                        <i class="fas fa-inbox" style="font-size: 3rem; color: #ccc;"></i>
                        <p style="margin-top: 15px; color: #666;">No conversations found</p>
                    </td>
                </tr>
                <?php else: ?>
                <?php foreach ($conversations as $conv): ?>
                <tr>
                    <td>
                        <div class="product-cell">
                            <img src="<?= htmlspecialchars($conv['product_image'] ?: '/assets/images/placeholder.png') ?>" alt="Product">
                            <span><?= htmlspecialchars($conv['product_name']) ?></span>
                        </div>
                    </td>
                    <td>
                        <strong><?= htmlspecialchars($conv['buyer_username']) ?></strong><br>
                        <small><?= htmlspecialchars($conv['buyer_email']) ?></small>
                    </td>
                    <td>
                        <strong><?= htmlspecialchars($conv['seller_username']) ?></strong><br>
                        <small><?= htmlspecialchars($conv['seller_email']) ?></small>
                    </td>
                    <td>
                        <?= $conv['message_count'] ?>
                        <?php if ($conv['flagged_count'] > 0): ?>
                        <span class="badge badge-danger"><?= $conv['flagged_count'] ?> flagged</span>
                        <?php endif; ?>
                    </td>
                    <td>
                        <?php
                        $statusClass = $conv['status'] === 'active' ? 'success' : ($conv['status'] === 'flagged' ? 'danger' : 'secondary');
                        ?>
                        <span class="badge badge-<?= $statusClass ?>"><?= ucfirst($conv['status']) ?></span>
                    </td>
                    <td><?= date('M j, Y g:i A', strtotime($conv['last_message_at'] ?: $conv['created_at'])) ?></td>
                    <td>
                        <a href="message-detail.php?thread_id=<?= $conv['thread_id'] ?>" class="btn btn-sm btn-primary">View</a>
                    </td>
                </tr>
                <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
    
    <!-- Pagination -->
    <?php if ($totalPages > 1): ?>
    <div class="pagination">
        <?php if ($page > 1): ?>
        <a href="?page=<?= $page - 1 ?>&filter=<?= urlencode($filter) ?>" class="page-link">Previous</a>
        <?php endif; ?>
        
        <?php for ($i = max(1, $page - 2); $i <= min($totalPages, $page + 2); $i++): ?>
        <a href="?page=<?= $i ?>&filter=<?= urlencode($filter) ?>" class="page-link <?= $i === $page ? 'active' : '' ?>"><?= $i ?></a>
        <?php endfor; ?>
        
        <?php if ($page < $totalPages): ?>
        <a href="?page=<?= $page + 1 ?>&filter=<?= urlencode($filter) ?>" class="page-link">Next</a>
        <?php endif; ?>
    </div>
    <?php endif; ?>
</div>

<style>
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.stat-card {
    background: white;
    border-radius: 8px;
    padding: 20px;
    display: flex;
    align-items: center;
    gap: 15px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.stat-card.warning {
    background: #fff3cd;
}

.stat-card.danger {
    background: #f8d7da;
}

.stat-icon {
    font-size: 2.5rem;
}

.stat-info h3 {
    font-size: 2rem;
    font-weight: bold;
    margin: 0;
}

.stat-info p {
    margin: 0;
    color: #666;
}

.filters-panel {
    background: white;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
}

.filter-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 15px;
}

.filter-group label {
    display: block;
    font-weight: 600;
    margin-bottom: 5px;
    font-size: 0.9rem;
}

.filter-group input,
.filter-group select {
    width: 100%;
    padding: 8px;
    border: 1px solid #ddd;
    border-radius: 4px;
}

.filter-actions {
    display: flex;
    gap: 10px;
    align-items: flex-end;
}

.product-cell {
    display: flex;
    align-items: center;
    gap: 10px;
}

.product-cell img {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 4px;
}

.badge {
    display: inline-block;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 0.75rem;
    font-weight: 600;
}

.badge-success {
    background: #d4edda;
    color: #155724;
}

.badge-danger {
    background: #f8d7da;
    color: #721c24;
}

.badge-secondary {
    background: #e2e3e5;
    color: #383d41;
}
</style>

<?php include __DIR__ . '/../includes/admin_footer.php'; ?>
