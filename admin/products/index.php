<?php
/**
 * Product Management - Admin Module
 * Comprehensive Product & Catalog Management System
 */

require_once __DIR__ . '/../../includes/init.php';

// Safe HTML escape helper (prevents null deprecation warnings in PHP 8.1+)
if (!function_exists('e')) {
    function e($value): string {
        return htmlspecialchars($value ?? '', ENT_QUOTES, 'UTF-8');
    }
}

// Initialize PDO global variable for this module
$pdo = db();
RoleMiddleware::requireAdmin();

$page_title = 'Product Management';
$action = $_GET['action'] ?? 'list';
$product_id = $_GET['id'] ?? null;

// Handle actions
if ($_POST && isset($_POST['action'])) {
    validateCsrfAndRateLimit();
    
    try {
        $product = new Product();
        
        switch ($_POST['action']) {
            case 'create_product':
                $productData = [
                    'name' => sanitizeInput($_POST['name']),
                    'description' => sanitizeInput($_POST['description']),
                    'short_description' => sanitizeInput($_POST['short_description'] ?? ''),
                    'sku' => sanitizeInput($_POST['sku']),
                    'price' => floatval($_POST['price']),
                    'compare_price' => !empty($_POST['compare_price']) ? floatval($_POST['compare_price']) : null,
                    'cost_price' => !empty($_POST['cost_price']) ? floatval($_POST['cost_price']) : null,
                    'category_id' => intval($_POST['category_id']),
                    'vendor_id' => intval($_POST['vendor_id']),
                    'weight' => !empty($_POST['weight']) ? floatval($_POST['weight']) : null,
                    'stock_quantity' => intval($_POST['stock_quantity']),
                    'low_stock_threshold' => intval($_POST['low_stock_threshold'] ?? 10),
                    'track_inventory' => isset($_POST['track_inventory']) ? 1 : 0,
                    'allow_backorders' => isset($_POST['allow_backorders']) ? 1 : 0,
                    'is_featured' => isset($_POST['is_featured']) ? 1 : 0,
                    'status' => sanitizeInput($_POST['status']),
                    'tags' => sanitizeInput($_POST['tags'] ?? ''),
                    'meta_title' => sanitizeInput($_POST['meta_title'] ?? ''),
                    'meta_description' => sanitizeInput($_POST['meta_description'] ?? ''),
                ];
                
                $newProductId = $product->create($productData);
                if ($newProductId) {
                    $_SESSION['success_message'] = 'Product created successfully.';
                    logAdminActivity(Session::getUserId(), 'product_created', 'product', $newProductId, null, $productData);
                } else {
                    throw new Exception('Failed to create product.');
                }
                break;
                
            case 'update_product':
                $productData = [
                    'name' => sanitizeInput($_POST['name']),
                    'description' => sanitizeInput($_POST['description']),
                    'short_description' => sanitizeInput($_POST['short_description'] ?? ''),
                    'sku' => sanitizeInput($_POST['sku']),
                    'price' => floatval($_POST['price']),
                    'compare_price' => !empty($_POST['compare_price']) ? floatval($_POST['compare_price']) : null,
                    'cost_price' => !empty($_POST['cost_price']) ? floatval($_POST['cost_price']) : null,
                    'category_id' => intval($_POST['category_id']),
                    'vendor_id' => intval($_POST['vendor_id']),
                    'weight' => !empty($_POST['weight']) ? floatval($_POST['weight']) : null,
                    'stock_quantity' => intval($_POST['stock_quantity']),
                    'low_stock_threshold' => intval($_POST['low_stock_threshold'] ?? 10),
                    'track_inventory' => isset($_POST['track_inventory']) ? 1 : 0,
                    'allow_backorders' => isset($_POST['allow_backorders']) ? 1 : 0,
                    'is_featured' => isset($_POST['is_featured']) ? 1 : 0,
                    'status' => sanitizeInput($_POST['status']),
                    'tags' => sanitizeInput($_POST['tags'] ?? ''),
                    'meta_title' => sanitizeInput($_POST['meta_title'] ?? ''),
                    'meta_description' => sanitizeInput($_POST['meta_description'] ?? ''),
                ];
                
                $success = $product->update(intval($_POST['product_id']), $productData);
                if ($success) {
                    $_SESSION['success_message'] = 'Product updated successfully.';
                    logAdminActivity(Session::getUserId(), 'product_updated', 'product', intval($_POST['product_id']), null, $productData);
                } else {
                    throw new Exception('Failed to update product.');
                }
                break;
                
            case 'delete_product':
                $success = $product->delete(intval($_POST['product_id']));
                if ($success) {
                    $_SESSION['success_message'] = 'Product deleted successfully.';
                    logAdminActivity(Session::getUserId(), 'product_deleted', 'product', intval($_POST['product_id']));
                } else {
                    throw new Exception('Failed to delete product.');
                }
                break;
                
            case 'bulk_update_status':
                $product_ids = $_POST['product_ids'] ?? [];
                $new_status = sanitizeInput($_POST['bulk_status']);
                
                $success_count = 0;
                foreach ($product_ids as $pid) {
                    if ($product->updateStatus(intval($pid), $new_status)) {
                        $success_count++;
                        logAdminActivity(Session::getUserId(), 'product_status_updated', 'product', intval($pid), null, ['status' => $new_status]);
                    }
                }
                
                $_SESSION['success_message'] = "$success_count product(s) updated successfully.";
                break;
                
            case 'bulk_delete':
                $product_ids = $_POST['product_ids'] ?? [];
                
                $success_count = 0;
                foreach ($product_ids as $pid) {
                    if ($product->delete(intval($pid))) {
                        $success_count++;
                        logAdminActivity(Session::getUserId(), 'product_deleted', 'product', intval($pid));
                    }
                }
                
                $_SESSION['success_message'] = "$success_count product(s) deleted successfully.";
                break;
        }
        
        redirect('/admin/products/');
        
    } catch (Exception $e) {
        $_SESSION['error_message'] = $e->getMessage();
        redirect('/admin/products/');
    }
}

// Get products for listing
$product = new Product();
$category = new Category();

// Initialize vendor variable
$vendor = null;
if (class_exists('Vendor')) {
    $vendor = new Vendor();
}

// Filters
$status_filter = $_GET['status'] ?? '';
$category_filter = $_GET['category_id'] ?? '';
$vendor_filter = $_GET['vendor_id'] ?? '';
$search_query = $_GET['search'] ?? '';

// Pagination
$page = max(1, intval($_GET['page'] ?? 1));
$per_page = 20;
$offset = ($page - 1) * $per_page;

// Build filter conditions
$filters = [];
$params = [];

if (!empty($status_filter)) {
    $filters[] = "p.status = :status";
    $params[':status'] = $status_filter;
}

if (!empty($category_filter)) {
    $filters[] = "p.category_id = :category_id";
    $params[':category_id'] = $category_filter;
}

if (!empty($vendor_filter)) {
    $filters[] = "p.vendor_id = :vendor_id";
    $params[':vendor_id'] = $vendor_filter;
}

if (!empty($search_query)) {
    $filters[] = "(p.name LIKE :search OR p.sku LIKE :search OR p.description LIKE :search)";
    $params[':search'] = '%' . $search_query . '%';
}

$where_clause = !empty($filters) ? 'WHERE ' . implode(' AND ', $filters) : '';

// Check if vendors table exists
$table_exists_sql = "SHOW TABLES LIKE 'vendors'";
$table_exists_stmt = $pdo->prepare($table_exists_sql);
$table_exists_stmt->execute();
$vendors_table_exists = $table_exists_stmt->fetchColumn();

// Check if sponsored_products table exists
$sponsored_table_exists_sql = "SHOW TABLES LIKE 'sponsored_products'";
$sponsored_table_exists_stmt = $pdo->prepare($sponsored_table_exists_sql);
$sponsored_table_exists_stmt->execute();
$sponsored_table_exists = $sponsored_table_exists_stmt->fetchColumn();

if ($vendors_table_exists && $sponsored_table_exists) {
    $sql = "SELECT p.*, c.name as category_name, v.business_name as vendor_name,
                   CASE WHEN sp.id IS NOT NULL THEN 1 ELSE 0 END as is_sponsored
            FROM products p 
            LEFT JOIN categories c ON p.category_id = c.id 
            LEFT JOIN vendors v ON p.vendor_id = v.id
            LEFT JOIN sponsored_products sp ON p.id = sp.product_id 
                AND sp.status = 'active' 
                AND sp.sponsored_until > NOW()
            $where_clause 
            ORDER BY p.created_at DESC 
            LIMIT :limit OFFSET :offset";
} elseif ($vendors_table_exists) {
    $sql = "SELECT p.*, c.name as category_name, v.business_name as vendor_name, 0 as is_sponsored
            FROM products p 
            LEFT JOIN categories c ON p.category_id = c.id 
            LEFT JOIN vendors v ON p.vendor_id = v.id 
            $where_clause 
            ORDER BY p.created_at DESC 
            LIMIT :limit OFFSET :offset";
} elseif ($sponsored_table_exists) {
    $sql = "SELECT p.*, c.name as category_name, 'No Vendor' as vendor_name,
                   CASE WHEN sp.id IS NOT NULL THEN 1 ELSE 0 END as is_sponsored
            FROM products p 
            LEFT JOIN categories c ON p.category_id = c.id
            LEFT JOIN sponsored_products sp ON p.id = sp.product_id 
                AND sp.status = 'active' 
                AND sp.sponsored_until > NOW()
            $where_clause 
            ORDER BY p.created_at DESC 
            LIMIT :limit OFFSET :offset";
} else {
    $sql = "SELECT p.*, c.name as category_name, 'No Vendor' as vendor_name, 0 as is_sponsored
            FROM products p 
            LEFT JOIN categories c ON p.category_id = c.id 
            $where_clause 
            ORDER BY p.created_at DESC 
            LIMIT :limit OFFSET :offset";
}

$params[':limit'] = $per_page;
$params[':offset'] = $offset;

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$products = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Get total count for pagination
$count_sql = "SELECT COUNT(*) FROM products p $where_clause";
$count_params = array_diff_key($params, [':limit' => '', ':offset' => '']);
$count_stmt = $pdo->prepare($count_sql);
$count_stmt->execute($count_params);
$total_products = $count_stmt->fetchColumn();
$total_pages = ceil($total_products / $per_page);

// Get categories and vendors for filters
$categories = $category->getAll();
$vendors = [];
if ($vendor && $vendors_table_exists) {
    $vendors = $vendor->getAll();
}

// Handle specific actions
if ($action === 'edit' && $product_id) {
    $current_product = $product->getById($product_id);
    if (!$current_product) {
        $_SESSION['error_message'] = 'Product not found.';
        redirect('/admin/products/');
    }
}

include_once __DIR__ . '/../../includes/admin_header.php';
?>

<div class="admin-container">
    <div class="admin-header">
        <div class="admin-header-left">
            <h1><?php echo e($page_title); ?></h1>
            <p class="admin-subtitle">Manage your product catalog</p>
        </div>
        <div class="admin-header-right">
            <?php if ($action === 'list'): ?>
                <a href="?action=create" class="btn btn-primary">
                    <i class="fas fa-plus"></i> Add Product
                </a>
                <button type="button" class="btn btn-secondary" onclick="toggleBulkActions()">
                    <i class="fas fa-list"></i> Bulk Actions
                </button>
            <?php endif; ?>
        </div>
    </div>

    <?php displaySessionMessages(); ?>

    <?php if ($action === 'list'): ?>
        <!-- Filters -->
        <div class="filters-card">
            <form method="GET" class="filters-form">
                <div class="filter-group">
                    <label>Status</label>
                    <select name="status" class="form-control">
                        <option value="">All Products</option>
                        <option value="active" <?php echo $status_filter === 'active' ? 'selected' : ''; ?>>Active</option>
                        <option value="draft" <?php echo $status_filter === 'draft' ? 'selected' : ''; ?>>Draft</option>
                        <option value="archived" <?php echo $status_filter === 'archived' ? 'selected' : ''; ?>>Archived</option>
                    </select>
                </div>
                
                <div class="filter-group">
                    <label>Category</label>
                    <select name="category_id" class="form-control">
                        <option value="">All Categories</option>
                        <?php foreach ($categories as $cat): ?>
                            <option value="<?php echo $cat['id']; ?>" 
                                    <?php echo $category_filter == $cat['id'] ? 'selected' : ''; ?>>
                                <?php echo e($cat['name']); ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                
                <?php if (!empty($vendors)): ?>
                <div class="filter-group">
                    <label>Vendor</label>
                    <select name="vendor_id" class="form-control">
                        <option value="">All Vendors</option>
                        <?php foreach ($vendors as $v): ?>
                            <option value="<?php echo $v['id']; ?>" 
                                    <?php echo $vendor_filter == $v['id'] ? 'selected' : ''; ?>>
                                <?php echo e($v['business_name'] ?? $v['name'] ?? 'Unknown Vendor'); ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <?php endif; ?>
                
                <div class="filter-group search-group">
                    <label>Search</label>
                    <input type="text" name="search" class="form-control" 
                           placeholder="Search products..." 
                           value="<?php echo e($search_query); ?>">
                </div>
                
                <div class="filter-actions">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i> Search
                    </button>
                    <a href="?" class="btn btn-secondary">Clear</a>
                </div>
            </form>
        </div>

        <!-- Bulk Actions (Hidden by default) -->
        <div id="bulk-actions" class="bulk-actions-card" style="display: none;">
            <form method="POST" id="bulk-form">
                <input type="hidden" name="csrf_token" value="<?php echo generateCsrfToken(); ?>">
                <div class="bulk-actions-content">
                    <div class="bulk-selection">
                        <label>
                            <input type="checkbox" id="select-all"> Select All
                        </label>
                        <span class="selected-count">0 selected</span>
                    </div>
                    
                    <div class="bulk-actions-buttons">
                        <select name="bulk_status" class="form-control">
                            <option value="">Change Status</option>
                            <option value="active">Active</option>
                            <option value="draft">Draft</option>
                            <option value="archived">Archived</option>
                        </select>
                        
                        <button type="submit" name="action" value="bulk_update_status" 
                                class="btn btn-secondary" onclick="return confirmBulkAction('update status')">
                            Update Status
                        </button>
                        
                        <button type="submit" name="action" value="bulk_delete" 
                                class="btn btn-danger" onclick="return confirmBulkAction('delete')">
                            <i class="fas fa-trash"></i> Delete Selected
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Products List -->
        <div class="products-grid-container">
            <div class="products-grid-header">
                <div>
                    <h3>Products (<?php echo $total_products; ?> total)</h3>
                </div>
                <div class="view-toggle-buttons">
                    <button type="button" class="view-toggle-btn active" data-view="grid" onclick="switchView('grid')">
                        <i class="fas fa-th"></i> Grid View
                    </button>
                    <button type="button" class="view-toggle-btn" data-view="list" onclick="switchView('list')">
                        <i class="fas fa-list"></i> List View
                    </button>
                </div>
            </div>
            
            <?php if (empty($products)): ?>
                <div class="no-products-found">
                    <i class="fas fa-box-open"></i>
                    <h4>No products found</h4>
                    <p>Get started by adding your first product.</p>
                    <a href="?action=create" class="btn btn-primary">Add Product</a>
                </div>
            <?php else: ?>
                <!-- Grid View -->
                <div class="admin-products-grid" id="grid-view">
                    <?php foreach ($products as $prod): ?>
                        <div class="admin-product-card">
                            <!-- Badges -->
                            <div class="product-badges">
                                <?php if (!empty($prod['is_sponsored'])): ?>
                                    <span class="product-badge badge-sponsored">
                                        <i class="fas fa-bullhorn"></i> Sponsored
                                    </span>
                                <?php endif; ?>
                                <?php if (!empty($prod['featured'])): ?>
                                    <span class="product-badge badge-featured">
                                        <i class="fas fa-star"></i> Featured
                                    </span>
                                <?php endif; ?>
                            </div>
                            
                            <!-- Bulk Checkbox (Hidden by default) -->
                            <div class="bulk-checkbox-overlay" style="display: none;">
                                <input type="checkbox" class="product-checkbox" 
                                       name="product_ids[]" value="<?php echo $prod['id']; ?>">
                            </div>
                            
                            <!-- Product Image -->
                            <div class="admin-product-image">
                                <?php if (!empty($prod['image_url'])): ?>
                                    <img src="<?php echo e($prod['image_url']); ?>" 
                                         alt="<?php echo e($prod['name'] ?? 'Product'); ?>">
                                <?php else: ?>
                                    <div class="no-image-placeholder">
                                        <i class="fas fa-image"></i>
                                        <span>No Image</span>
                                    </div>
                                <?php endif; ?>
                            </div>
                            
                            <!-- Product Info -->
                            <div class="admin-product-info">
                                <h4 class="admin-product-title" title="<?php echo e($prod['name'] ?? 'Unnamed'); ?>">
                                    <?php echo e($prod['name'] ?? 'Unnamed'); ?>
                                </h4>
                                
                                <div class="admin-product-meta">
                                    <span class="meta-item">
                                        <i class="fas fa-barcode"></i>
                                        <?php echo e($prod['sku'] ?? 'N/A'); ?>
                                    </span>
                                    <span class="meta-item price">
                                        <i class="fas fa-tag"></i>
                                        $<?php echo number_format((float)($prod['price'] ?? 0), 2); ?>
                                    </span>
                                    <span class="meta-item <?php echo ($prod['stock_quantity'] ?? 0) <= ($prod['low_stock_threshold'] ?? 10) ? 'low-stock' : ''; ?>">
                                        <i class="fas fa-boxes"></i>
                                        <?php 
                                        if (!empty($prod['track_inventory'])) {
                                            echo number_format((int)($prod['stock_quantity'] ?? 0));
                                            if (($prod['stock_quantity'] ?? 0) <= ($prod['low_stock_threshold'] ?? 10)) {
                                                echo ' <i class="fas fa-exclamation-triangle" style="color: #f59e0b;"></i>';
                                            }
                                        } else {
                                            echo 'Not tracked';
                                        }
                                        ?>
                                    </span>
                                </div>
                                
                                <div class="admin-product-details">
                                    <span class="detail-item">
                                        <strong>Category:</strong> 
                                        <?php echo e($prod['category_name'] ?? 'No Category'); ?>
                                    </span>
                                    <?php if ($vendors_table_exists): ?>
                                    <span class="detail-item">
                                        <strong>Vendor:</strong> 
                                        <?php echo e($prod['vendor_name'] ?? 'No Vendor'); ?>
                                    </span>
                                    <?php endif; ?>
                                    <span class="detail-item">
                                        <strong>Status:</strong>
                                        <span class="status-badge status-<?php echo e($prod['status'] ?? 'unknown'); ?>">
                                            <?php echo e(ucfirst($prod['status'] ?? 'unknown')); ?>
                                        </span>
                                    </span>
                                </div>
                            </div>
                            
                            <!-- Action Buttons -->
                            <div class="admin-product-actions">
                                <div class="action-row">
                                    <button type="button" 
                                            class="action-btn sponsor-btn <?php echo !empty($prod['is_sponsored']) ? 'active' : ''; ?>" 
                                            onclick="toggleSponsored(<?php echo $prod['id']; ?>, this)"
                                            title="<?php echo !empty($prod['is_sponsored']) ? 'Remove sponsorship' : 'Sponsor this product'; ?>">
                                        <i class="fas fa-bullhorn"></i>
                                        <?php echo !empty($prod['is_sponsored']) ? 'Sponsored' : 'Sponsor'; ?>
                                    </button>
                                    <button type="button" 
                                            class="action-btn feature-btn <?php echo !empty($prod['featured']) ? 'active' : ''; ?>" 
                                            onclick="toggleFeatured(<?php echo $prod['id']; ?>, this)"
                                            title="<?php echo !empty($prod['featured']) ? 'Remove from featured' : 'Mark as featured'; ?>">
                                        <i class="fas fa-star"></i>
                                        <?php echo !empty($prod['featured']) ? 'Featured' : 'Feature'; ?>
                                    </button>
                                </div>
                                <div class="action-row icon-actions">
                                    <a href="?action=edit&id=<?php echo $prod['id']; ?>" 
                                       class="icon-btn edit-btn" title="Edit">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <a href="?action=view&id=<?php echo $prod['id']; ?>" 
                                       class="icon-btn view-btn" title="View">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                    <button type="button" class="icon-btn delete-btn" 
                                            onclick="confirmDelete(<?php echo $prod['id']; ?>, '<?php echo e($prod['name'] ?? 'Unnamed'); ?>')" 
                                            title="Delete">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
                
                <!-- List View (Hidden by default) -->
                <div class="admin-products-list" id="list-view" style="display: none;">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th style="width: 40px;">
                                    <input type="checkbox" id="table-select-all" class="bulk-checkbox-control" style="display: none;">
                                </th>
                                <th style="width: 80px;">Image</th>
                                <th>Product Name</th>
                                <th>SKU</th>
                                <th>Category</th>
                                <?php if ($vendors_table_exists): ?>
                                <th>Vendor</th>
                                <?php endif; ?>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Status</th>
                                <th style="width: 180px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($products as $prod): ?>
                            <tr>
                                <td>
                                    <input type="checkbox" class="product-checkbox bulk-checkbox-control" 
                                           name="product_ids[]" value="<?php echo $prod['id']; ?>" style="display: none;">
                                </td>
                                <td>
                                    <div class="list-product-image">
                                        <?php if (!empty($prod['image_url'])): ?>
                                            <img src="<?php echo e($prod['image_url']); ?>" 
                                                 alt="<?php echo e($prod['name'] ?? 'Product'); ?>">
                                        <?php else: ?>
                                            <div class="no-image-icon">
                                                <i class="fas fa-image"></i>
                                            </div>
                                        <?php endif; ?>
                                    </div>
                                </td>
                                <td>
                                    <div class="list-product-name">
                                        <?php echo e($prod['name'] ?? 'Unnamed'); ?>
                                        <?php if (!empty($prod['is_sponsored'])): ?>
                                            <span class="badge badge-sm bg-warning"><i class="fas fa-bullhorn"></i></span>
                                        <?php endif; ?>
                                        <?php if (!empty($prod['featured'])): ?>
                                            <span class="badge badge-sm bg-info"><i class="fas fa-star"></i></span>
                                        <?php endif; ?>
                                    </div>
                                </td>
                                <td><code><?php echo e($prod['sku'] ?? 'N/A'); ?></code></td>
                                <td><?php echo e($prod['category_name'] ?? 'No Category'); ?></td>
                                <?php if ($vendors_table_exists): ?>
                                <td><?php echo e($prod['vendor_name'] ?? 'No Vendor'); ?></td>
                                <?php endif; ?>
                                <td class="text-success fw-bold">$<?php echo number_format((float)($prod['price'] ?? 0), 2); ?></td>
                                <td>
                                    <?php if (!empty($prod['track_inventory'])): ?>
                                        <span class="<?php echo ($prod['stock_quantity'] ?? 0) <= ($prod['low_stock_threshold'] ?? 10) ? 'text-danger' : ''; ?>">
                                            <?php echo number_format((int)($prod['stock_quantity'] ?? 0)); ?>
                                            <?php if (($prod['stock_quantity'] ?? 0) <= ($prod['low_stock_threshold'] ?? 10)): ?>
                                                <i class="fas fa-exclamation-triangle text-warning"></i>
                                            <?php endif; ?>
                                        </span>
                                    <?php else: ?>
                                        <span class="text-muted">Not tracked</span>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <span class="status-badge status-<?php echo e($prod['status'] ?? 'unknown'); ?>">
                                        <?php echo e(ucfirst($prod['status'] ?? 'unknown')); ?>
                                    </span>
                                </td>
                                <td>
                                    <div class="btn-group btn-group-sm" role="group">
                                        <a href="?action=edit&id=<?php echo $prod['id']; ?>" 
                                           class="btn btn-outline-primary btn-sm" title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <a href="?action=view&id=<?php echo $prod['id']; ?>" 
                                           class="btn btn-outline-info btn-sm" title="View">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <button type="button" class="btn btn-outline-danger btn-sm" 
                                                onclick="confirmDelete(<?php echo $prod['id']; ?>, '<?php echo e($prod['name'] ?? 'Unnamed'); ?>')" 
                                                title="Delete">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            <?php endif; ?>
            
            <?php if ($total_pages > 1): ?>
                <div class="pagination-wrapper">
                    <?php echo generatePagination($page, $total_pages, $_GET); ?>
                </div>
            <?php endif; ?>
        </div>

    <?php endif; ?>
</div>

<script>
// View switching functionality
function switchView(view) {
    const gridView = document.getElementById('grid-view');
    const listView = document.getElementById('list-view');
    const gridBtn = document.querySelector('.view-toggle-btn[data-view="grid"]');
    const listBtn = document.querySelector('.view-toggle-btn[data-view="list"]');
    
    if (view === 'grid') {
        gridView.style.display = 'grid';
        listView.style.display = 'none';
        gridBtn.classList.add('active');
        listBtn.classList.remove('active');
        localStorage.setItem('productsView', 'grid');
    } else {
        gridView.style.display = 'none';
        listView.style.display = 'block';
        gridBtn.classList.remove('active');
        listBtn.classList.add('active');
        localStorage.setItem('productsView', 'list');
    }
    
    // Show/hide bulk checkboxes based on bulk actions visibility
    const bulkActionsVisible = document.getElementById('bulk-actions').style.display !== 'none';
    updateBulkCheckboxVisibility(bulkActionsVisible);
}

// Restore last used view on page load
document.addEventListener('DOMContentLoaded', function() {
    const savedView = localStorage.getItem('productsView') || 'grid';
    if (savedView === 'list') {
        switchView('list');
    }
});

// Bulk actions functionality
function toggleBulkActions() {
    const bulkActions = document.getElementById('bulk-actions');
    const isVisible = bulkActions.style.display === 'none';
    
    bulkActions.style.display = isVisible ? 'block' : 'none';
    updateBulkCheckboxVisibility(isVisible);
}

function updateBulkCheckboxVisibility(show) {
    const checkboxOverlays = document.querySelectorAll('.bulk-checkbox-overlay');
    const bulkCheckboxControls = document.querySelectorAll('.bulk-checkbox-control');
    
    checkboxOverlays.forEach(overlay => overlay.style.display = show ? 'block' : 'none');
    bulkCheckboxControls.forEach(control => control.style.display = show ? 'block' : 'none');
}

// Select all functionality
document.addEventListener('DOMContentLoaded', function() {
    const selectAllCheckboxes = document.querySelectorAll('#select-all, #table-select-all');
    const productCheckboxes = document.querySelectorAll('.product-checkbox');
    const selectedCount = document.querySelector('.selected-count');
    
    selectAllCheckboxes.forEach(selectAll => {
        selectAll.addEventListener('change', function() {
            productCheckboxes.forEach(checkbox => {
                checkbox.checked = this.checked;
            });
            updateSelectedCount();
            
            // Sync other select all checkboxes
            selectAllCheckboxes.forEach(other => {
                if (other !== this) other.checked = this.checked;
            });
        });
    });
    
    productCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', updateSelectedCount);
    });
    
    function updateSelectedCount() {
        const checkedCount = document.querySelectorAll('.product-checkbox:checked').length;
        selectedCount.textContent = `${checkedCount} selected`;
        
        const allChecked = checkedCount === productCheckboxes.length;
        const someChecked = checkedCount > 0;
        
        selectAllCheckboxes.forEach(selectAll => {
            selectAll.checked = allChecked;
            selectAll.indeterminate = someChecked && !allChecked;
        });
    }
});

function confirmBulkAction(action) {
    const checkedCount = document.querySelectorAll('.product-checkbox:checked').length;
    if (checkedCount === 0) {
        alert('Please select at least one product.');
        return false;
    }
    return confirm(`Are you sure you want to ${action} ${checkedCount} product(s)?`);
}

function confirmDelete(productId, productName) {
    if (confirm(`Are you sure you want to delete "${productName}"? This action cannot be undone.`)) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.innerHTML = `
            <input type="hidden" name="csrf_token" value="<?php echo generateCsrfToken(); ?>">
            <input type="hidden" name="action" value="delete_product">
            <input type="hidden" name="product_id" value="${productId}">
        `;
        document.body.appendChild(form);
        form.submit();
    }
}

// Toggle sponsored status
async function toggleSponsored(productId, button) {
    const wasActive = button.classList.contains('active');
    const icon = button.querySelector('i');
    const originalHTML = button.innerHTML;
    
    // Disable button during request
    button.disabled = true;
    button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Loading...';
    
    try {
        const formData = new FormData();
        formData.append('product_id', productId);
        formData.append('csrf_token', '<?php echo generateCsrfToken(); ?>');
        
        const response = await fetch('/api/admin/toggle-sponsored.php', {
            method: 'POST',
            headers: {
                'X-Csrf-Token': '<?php echo generateCsrfToken(); ?>'
            },
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Update button state
            if (data.is_sponsored) {
                button.classList.add('active');
                button.innerHTML = '<i class="fas fa-bullhorn"></i> Sponsored';
                button.title = 'Remove sponsorship';
            } else {
                button.classList.remove('active');
                button.innerHTML = '<i class="fas fa-bullhorn"></i> Sponsor';
                button.title = 'Sponsor this product';
            }
            
            // Show success message
            showNotification(data.message, 'success');
        } else {
            // Revert on error
            button.innerHTML = originalHTML;
            showNotification(data.error || 'Failed to update sponsored status', 'error');
        }
    } catch (error) {
        // Revert on error
        button.innerHTML = originalHTML;
        showNotification('Network error: ' + error.message, 'error');
    } finally {
        button.disabled = false;
    }
}

// Toggle featured status
async function toggleFeatured(productId, button) {
    const wasActive = button.classList.contains('active');
    const originalHTML = button.innerHTML;
    
    // Disable button during request
    button.disabled = true;
    button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Loading...';
    
    try {
        const formData = new FormData();
        formData.append('product_id', productId);
        formData.append('csrf_token', '<?php echo generateCsrfToken(); ?>');
        
        const response = await fetch('/api/admin/toggle-featured.php', {
            method: 'POST',
            headers: {
                'X-Csrf-Token': '<?php echo generateCsrfToken(); ?>'
            },
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Update button state
            if (data.is_featured) {
                button.classList.add('active');
                button.innerHTML = '<i class="fas fa-star"></i> Featured';
                button.title = 'Remove from featured';
            } else {
                button.classList.remove('active');
                button.innerHTML = '<i class="fas fa-star"></i> Feature';
                button.title = 'Mark as featured';
            }
            
            // Show success message
            showNotification(data.message, 'success');
        } else {
            // Revert on error
            button.innerHTML = originalHTML;
            showNotification(data.error || 'Failed to update featured status', 'error');
        }
    } catch (error) {
        // Revert on error
        button.innerHTML = originalHTML;
        showNotification('Network error: ' + error.message, 'error');
    } finally {
        button.disabled = false;
    }
}

// Simple notification helper
function showNotification(message, type = 'info') {
    // Check if a notification container exists, if not create one
    let container = document.querySelector('.notification-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'notification-container';
        container.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999;';
        document.body.appendChild(container);
    }
    
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.style.cssText = `
        background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#3b82f6'};
        color: white;
        padding: 12px 20px;
        margin-bottom: 10px;
        border-radius: 6px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        max-width: 350px;
        animation: slideIn 0.3s ease-out;
    `;
    notification.textContent = message;
    
    container.appendChild(notification);
    
    // Auto remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// Add CSS animation for notifications
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    .toggle-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        border: 1px solid #d1d5db;
        background: white;
        color: #6b7280;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.2s;
        font-size: 13px;
    }
    .toggle-btn:hover:not(:disabled) {
        background: #f9fafb;
        border-color: #9ca3af;
    }
    .toggle-btn.active {
        background: #eff6ff;
        border-color: #3b82f6;
        color: #3b82f6;
    }
    .toggle-btn:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
    .toggle-cell {
        text-align: center;
        white-space: nowrap;
    }
    
    /* Product Grid Layout */
    .products-grid-container {
        background: white;
        border-radius: 12px;
        padding: 24px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }
    
    .products-grid-header {
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid #e5e7eb;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .products-grid-header h3 {
        margin: 0;
        font-size: 1.5rem;
        font-weight: 600;
        color: #111827;
    }
    
    .view-toggle-buttons {
        display: flex;
        gap: 8px;
    }
    
    .view-toggle-btn {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        border: 1px solid #d1d5db;
        background: white;
        color: #6b7280;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.2s;
        font-size: 0.875rem;
        font-weight: 500;
    }
    
    .view-toggle-btn:hover {
        background: #f9fafb;
        border-color: #9ca3af;
    }
    
    .view-toggle-btn.active {
        background: #3b82f6;
        border-color: #3b82f6;
        color: white;
    }
    
    .admin-products-list {
        width: 100%;
    }
    
    .admin-products-list table {
        width: 100%;
        border-collapse: collapse;
        background: white;
    }
    
    .admin-products-list th {
        background: #f9fafb;
        padding: 12px;
        text-align: left;
        font-weight: 600;
        color: #374151;
        font-size: 0.875rem;
        border-bottom: 2px solid #e5e7eb;
    }
    
    .admin-products-list td {
        padding: 12px;
        border-bottom: 1px solid #f3f4f6;
        vertical-align: middle;
    }
    
    .admin-products-list tr:hover {
        background: #f9fafb;
    }
    
    .list-product-image {
        width: 60px;
        height: 60px;
        border-radius: 6px;
        overflow: hidden;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #f3f4f6;
    }
    
    .list-product-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    
    .no-image-icon {
        color: #d1d5db;
        font-size: 1.5rem;
    }
    
    .list-product-name {
        font-weight: 500;
        color: #111827;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    .badge-sm {
        font-size: 0.625rem;
        padding: 2px 6px;
    }
    
    .no-products-found {
        text-align: center;
        padding: 60px 20px;
        color: #6b7280;
    }
    
    .no-products-found i {
        font-size: 4rem;
        color: #d1d5db;
        margin-bottom: 16px;
    }
    
    .no-products-found h4 {
        font-size: 1.5rem;
        margin-bottom: 8px;
        color: #374151;
    }
    
    .no-products-found p {
        margin-bottom: 20px;
        font-size: 1rem;
    }
    
    .admin-products-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 24px;
        margin-bottom: 24px;
    }
    
    .admin-product-card {
        position: relative;
        background: white;
        border: 1px solid #e5e7eb;
        border-radius: 12px;
        overflow: hidden;
        transition: all 0.3s ease;
        display: flex;
        flex-direction: column;
        height: 100%;
    }
    
    .admin-product-card:hover {
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
        transform: translateY(-4px);
        border-color: #d1d5db;
    }
    
    .product-badges {
        position: absolute;
        top: 12px;
        left: 12px;
        z-index: 10;
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    
    .product-badge {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 0.75rem;
        font-weight: 600;
        color: white;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }
    
    .badge-sponsored {
        background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
    }
    
    .badge-featured {
        background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
        color: #78350f;
    }
    
    .bulk-checkbox-overlay {
        position: absolute;
        top: 12px;
        right: 12px;
        z-index: 10;
        background: white;
        border-radius: 4px;
        padding: 4px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }
    
    .bulk-checkbox-overlay input[type="checkbox"] {
        width: 20px;
        height: 20px;
        cursor: pointer;
    }
    
    .admin-product-image {
        position: relative;
        height: 240px;
        background: #f9fafb;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
    }
    
    .admin-product-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.3s ease;
    }
    
    .admin-product-card:hover .admin-product-image img {
        transform: scale(1.05);
    }
    
    .no-image-placeholder {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: #d1d5db;
        height: 100%;
    }
    
    .no-image-placeholder i {
        font-size: 3rem;
        margin-bottom: 8px;
    }
    
    .no-image-placeholder span {
        font-size: 0.875rem;
        color: #9ca3af;
    }
    
    .admin-product-info {
        padding: 16px;
        flex-grow: 1;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }
    
    .admin-product-title {
        font-size: 1.125rem;
        font-weight: 600;
        color: #111827;
        margin: 0;
        line-height: 1.4;
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        min-height: 2.8em;
    }
    
    .admin-product-meta {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        padding-bottom: 12px;
        border-bottom: 1px solid #f3f4f6;
    }
    
    .meta-item {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        font-size: 0.875rem;
        color: #6b7280;
    }
    
    .meta-item i {
        color: #9ca3af;
        font-size: 0.875rem;
    }
    
    .meta-item.price {
        font-weight: 600;
        color: #059669;
        font-size: 1rem;
    }
    
    .meta-item.low-stock {
        color: #dc2626;
        font-weight: 500;
    }
    
    .admin-product-details {
        display: flex;
        flex-direction: column;
        gap: 8px;
        font-size: 0.875rem;
    }
    
    .detail-item {
        display: flex;
        align-items: center;
        color: #6b7280;
        line-height: 1.5;
    }
    
    .detail-item strong {
        color: #374151;
        margin-right: 6px;
        min-width: 70px;
    }
    
    .status-badge {
        display: inline-block;
        padding: 2px 8px;
        border-radius: 4px;
        font-size: 0.75rem;
        font-weight: 500;
        text-transform: uppercase;
    }
    
    .status-active {
        background: #d1fae5;
        color: #065f46;
    }
    
    .status-draft {
        background: #fef3c7;
        color: #92400e;
    }
    
    .status-archived {
        background: #f3f4f6;
        color: #6b7280;
    }
    
    .admin-product-actions {
        padding: 16px;
        background: #f9fafb;
        border-top: 1px solid #e5e7eb;
        display: flex;
        flex-direction: column;
        gap: 8px;
    }
    
    .action-row {
        display: flex;
        gap: 8px;
    }
    
    .action-btn {
        flex: 1;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        padding: 8px 12px;
        border: 1px solid #d1d5db;
        background: white;
        color: #6b7280;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.2s;
        font-size: 0.875rem;
        font-weight: 500;
        text-decoration: none;
    }
    
    .action-btn:hover:not(:disabled) {
        background: #f9fafb;
        border-color: #9ca3af;
        transform: translateY(-1px);
    }
    
    .action-btn.active {
        background: #eff6ff;
        border-color: #3b82f6;
        color: #3b82f6;
    }
    
    .action-btn.sponsor-btn.active {
        background: #fef3c7;
        border-color: #f59e0b;
        color: #d97706;
    }
    
    .action-btn.sponsor-btn:hover:not(:disabled) {
        background: #fef3c7;
        border-color: #f59e0b;
        color: #d97706;
        box-shadow: 0 4px 8px rgba(245, 158, 11, 0.3);
    }
    
    .action-btn.feature-btn.active {
        background: #fef3c7;
        border-color: #fbbf24;
        color: #f59e0b;
    }
    
    .action-btn.feature-btn:hover:not(:disabled) {
        background: #fef3c7;
        border-color: #fbbf24;
        color: #f59e0b;
        box-shadow: 0 4px 8px rgba(251, 191, 36, 0.3);
    }
    
    .action-btn:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
    
    .icon-actions {
        justify-content: center;
    }
    
    .icon-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 36px;
        height: 36px;
        border: 1px solid #d1d5db;
        background: white;
        color: #6b7280;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.2s;
        text-decoration: none;
    }
    
    .icon-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }
    
    .edit-btn:hover {
        background: #eff6ff;
        border-color: #3b82f6;
        color: #3b82f6;
        box-shadow: 0 4px 8px rgba(59, 130, 246, 0.3);
    }
    
    .view-btn:hover {
        background: #f0fdfa;
        border-color: #14b8a6;
        color: #14b8a6;
        box-shadow: 0 4px 8px rgba(20, 184, 166, 0.3);
    }
    
    .delete-btn:hover {
        background: #fef2f2;
        border-color: #ef4444;
        color: #ef4444;
        box-shadow: 0 4px 8px rgba(239, 68, 68, 0.3);
    }
    
    /* Responsive Design */
    @media (max-width: 1200px) {
        .admin-products-grid {
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        }
    }
    
    @media (max-width: 768px) {
        .admin-products-grid {
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 16px;
        }
        
        .admin-product-image {
            height: 200px;
        }
        
        .products-grid-container {
            padding: 16px;
        }
        
        .admin-product-title {
            font-size: 1rem;
        }
    }
    
    @media (max-width: 480px) {
        .admin-products-grid {
            grid-template-columns: 1fr;
            gap: 16px;
        }
        
        .admin-product-image {
            height: 180px;
        }
        
        .products-grid-container {
            padding: 12px;
        }
        
        .action-btn {
            font-size: 0.8rem;
            padding: 6px 10px;
        }
        
        .admin-product-meta {
            gap: 8px;
        }
    }
`;
document.head.appendChild(style);
</script>

<?php include_once __DIR__ . '/../../includes/admin_footer.php'; ?>