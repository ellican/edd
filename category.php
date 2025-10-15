<?php
/**
 * Category Products Listing
 * E-Commerce Platform
 */

require_once __DIR__ . '/includes/init.php';

// Currency Detection and Initialization
try {
    $currency = Currency::getInstance();
    
    // Auto-detect and set currency on first visit
    if (!Session::get('currency_code')) {
        $currency->detectAndSetCurrency();
    }
} catch (Exception $e) {
    error_log("Currency initialization error on category page: " . $e->getMessage());
}

$category = new Category();
$product = new Product();

// Get category name from URL parameter
$categoryName = $_GET['name'] ?? '';
$categoryId = $_GET['id'] ?? '';
$onSale = isset($_GET['on_sale']) ? (bool)$_GET['on_sale'] : false;

// Handle pagination
$page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
$limit = PRODUCTS_PER_PAGE;
$offset = ($page - 1) * $limit;

// Handle sorting
$validSorts = ['name', 'price_asc', 'price_desc', 'newest', 'rating'];
$sort = isset($_GET['sort']) && in_array($_GET['sort'], $validSorts) ? $_GET['sort'] : 'name';

// Handle price filter
$minPrice = isset($_GET['min_price']) ? floatval($_GET['min_price']) : null;
$maxPrice = isset($_GET['max_price']) ? floatval($_GET['max_price']) : null;

// Get category info
$currentCategory = null;
if ($categoryId) {
    $currentCategory = $category->find($categoryId);
} elseif ($categoryName) {
    $currentCategory = $category->findBySlug($categoryName);
}

if (!$currentCategory) {
    // Try to find by name if slug lookup failed
    $categories = $category->getParents();
    foreach ($categories as $cat) {
        if (strtolower($cat['name']) === strtolower($categoryName) || 
            slugify($cat['name']) === $categoryName) {
            $currentCategory = $cat;
            break;
        }
    }
}

// If still no category found, create a default category view
if (!$currentCategory) {
    $currentCategory = [
        'id' => 0,
        'name' => ucfirst(str_replace('-', ' ', $categoryName)),
        'description' => 'Browse products in ' . ucfirst(str_replace('-', ' ', $categoryName))
    ];
}

// Get products for category
$filters = [];
if ($currentCategory['id'] > 0) {
    $filters['category_id'] = $currentCategory['id'];
}
if ($onSale) {
    $filters['on_sale'] = true;
}
if ($minPrice !== null) {
    $filters['min_price'] = $minPrice;
}
if ($maxPrice !== null) {
    $filters['max_price'] = $maxPrice;
}

$products = $product->findByFilters($filters, $sort, $limit, $offset);
$totalProducts = $product->countByFilters($filters);

// Get subcategories
$subcategories = [];
if ($currentCategory['id'] > 0) {
    $subcategories = $category->getChildren($currentCategory['id']);
}

// Calculate pagination
$totalPages = ceil($totalProducts / $limit);

$page_title = $currentCategory['name'] . ' - Shop by Category';
includeHeader($page_title);
?>

<div class="container">
    <!-- Category Header -->
    <div class="category-header">
        <nav class="breadcrumb">
            <a href="/">Home</a>
            <span class="separator">></span>
            <span class="current"><?php echo htmlspecialchars($currentCategory['name']); ?></span>
        </nav>
        
        <div class="category-info">
            <h1><?php echo htmlspecialchars($currentCategory['name']); ?></h1>
            <?php if (!empty($currentCategory['description'])): ?>
                <p class="category-description"><?php echo htmlspecialchars($currentCategory['description']); ?></p>
            <?php endif; ?>
            <div class="category-stats">
                <span class="product-count"><?php echo number_format($totalProducts); ?> items</span>
                <?php if ($onSale): ?>
                    <span class="sale-badge">🔥 On Sale</span>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <!-- Subcategories (if any) -->
    <?php if (!empty($subcategories)): ?>
    <div class="subcategories-section">
        <h2>Shop by Subcategory</h2>
        <div class="subcategories-grid">
            <?php foreach ($subcategories as $subcat): ?>
                <a href="/category.php?id=<?php echo $subcat['id']; ?>" class="subcategory-card">
                    <div class="subcategory-icon">📦</div>
                    <h3><?php echo htmlspecialchars($subcat['name']); ?></h3>
                    <p><?php echo number_format($product->countByCategory($subcat['id'])); ?> items</p>
                </a>
            <?php endforeach; ?>
        </div>
    </div>
    <?php endif; ?>

    <div class="category-content">
        <!-- Filters Sidebar -->
        <aside class="filters-sidebar">
            <div class="filters-card">
                <div class="filters-header">
                    <h3>Filters</h3>
                    <button type="button" class="clear-all-filters" onclick="clearAllFilters()" style="display: none;">
                        Clear All
                    </button>
                </div>
                
                <!-- Active Filters Chips -->
                <div id="activeFiltersChips" class="active-filters-chips"></div>
                
                <form id="filtersForm" method="GET" class="filters-form">
                    <input type="hidden" name="name" value="<?php echo htmlspecialchars($categoryName); ?>">
                    <input type="hidden" name="id" value="<?php echo htmlspecialchars($categoryId); ?>">
                    
                    <!-- Price Range Filter -->
                    <div class="filter-group collapsible active">
                        <h4 class="filter-group-header" onclick="toggleFilterGroup(this)">
                            <i class="fas fa-chevron-down"></i>
                            Price Range
                        </h4>
                        <div class="filter-group-content">
                            <div class="price-inputs">
                                <input type="number" name="min_price" id="min_price" placeholder="Min" 
                                       value="<?php echo $minPrice; ?>" min="0" step="0.01">
                                <span>to</span>
                                <input type="number" name="max_price" id="max_price" placeholder="Max" 
                                       value="<?php echo $maxPrice; ?>" min="0" step="0.01">
                            </div>
                            <div class="price-range-slider" id="priceRangeSlider"></div>
                        </div>
                    </div>
                    
                    <!-- Brand Filter -->
                    <div class="filter-group collapsible">
                        <h4 class="filter-group-header" onclick="toggleFilterGroup(this)">
                            <i class="fas fa-chevron-down"></i>
                            Brand
                        </h4>
                        <div class="filter-group-content">
                            <div class="filter-search-box">
                                <input type="text" placeholder="Search brands..." onkeyup="filterBrandList(this)">
                            </div>
                            <div id="brandFilters" class="filter-options-list">
                                <p class="text-muted">Loading brands...</p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Customer Ratings Filter -->
                    <div class="filter-group collapsible">
                        <h4 class="filter-group-header" onclick="toggleFilterGroup(this)">
                            <i class="fas fa-chevron-down"></i>
                            Customer Ratings
                        </h4>
                        <div class="filter-group-content">
                            <label class="filter-checkbox">
                                <input type="radio" name="rating" value="4">
                                <span>★★★★☆ 4 Stars & Up</span>
                            </label>
                            <label class="filter-checkbox">
                                <input type="radio" name="rating" value="3">
                                <span>★★★☆☆ 3 Stars & Up</span>
                            </label>
                            <label class="filter-checkbox">
                                <input type="radio" name="rating" value="2">
                                <span>★★☆☆☆ 2 Stars & Up</span>
                            </label>
                        </div>
                    </div>
                    
                    <!-- Availability Filter -->
                    <div class="filter-group collapsible">
                        <h4 class="filter-group-header" onclick="toggleFilterGroup(this)">
                            <i class="fas fa-chevron-down"></i>
                            Availability
                        </h4>
                        <div class="filter-group-content">
                            <label class="filter-checkbox">
                                <input type="checkbox" name="availability[]" value="in_stock">
                                <span>In Stock</span>
                            </label>
                            <label class="filter-checkbox">
                                <input type="checkbox" name="availability[]" value="pre_order">
                                <span>Pre-order</span>
                            </label>
                        </div>
                    </div>
                    
                    <!-- Special Offers Filter -->
                    <div class="filter-group collapsible active">
                        <h4 class="filter-group-header" onclick="toggleFilterGroup(this)">
                            <i class="fas fa-chevron-down"></i>
                            Discounts & Deals
                        </h4>
                        <div class="filter-group-content">
                            <label class="filter-checkbox">
                                <input type="checkbox" name="on_sale" value="1" <?php echo $onSale ? 'checked' : ''; ?>>
                                <span>On Sale</span>
                            </label>
                            <label class="filter-checkbox">
                                <input type="checkbox" name="new_arrival" value="1">
                                <span>New Arrivals</span>
                            </label>
                            <label class="filter-checkbox">
                                <input type="checkbox" name="featured" value="1">
                                <span>Featured Products</span>
                            </label>
                            <label class="filter-checkbox">
                                <input type="checkbox" name="clearance" value="1">
                                <span>Clearance</span>
                            </label>
                        </div>
                    </div>
                    
                    <!-- Color Filter -->
                    <div class="filter-group collapsible">
                        <h4 class="filter-group-header" onclick="toggleFilterGroup(this)">
                            <i class="fas fa-chevron-down"></i>
                            Color
                        </h4>
                        <div class="filter-group-content">
                            <div id="colorFilters" class="color-filter-grid">
                                <p class="text-muted">Loading colors...</p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Size Filter -->
                    <div class="filter-group collapsible">
                        <h4 class="filter-group-header" onclick="toggleFilterGroup(this)">
                            <i class="fas fa-chevron-down"></i>
                            Size
                        </h4>
                        <div class="filter-group-content">
                            <div id="sizeFilters" class="size-filter-grid">
                                <p class="text-muted">Loading sizes...</p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Material Filter -->
                    <div class="filter-group collapsible">
                        <h4 class="filter-group-header" onclick="toggleFilterGroup(this)">
                            <i class="fas fa-chevron-down"></i>
                            Material
                        </h4>
                        <div class="filter-group-content">
                            <div id="materialFilters" class="filter-options-list">
                                <p class="text-muted">Loading materials...</p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Shipping Options Filter -->
                    <div class="filter-group collapsible">
                        <h4 class="filter-group-header" onclick="toggleFilterGroup(this)">
                            <i class="fas fa-chevron-down"></i>
                            Shipping Options
                        </h4>
                        <div class="filter-group-content">
                            <label class="filter-checkbox">
                                <input type="checkbox" name="free_shipping" value="1">
                                <span>Free Shipping</span>
                            </label>
                            <label class="filter-checkbox">
                                <input type="checkbox" name="fast_delivery" value="1">
                                <span>Fast Delivery</span>
                            </label>
                        </div>
                    </div>
                    
                    <div class="filter-actions">
                        <button type="button" class="btn btn-primary btn-block" onclick="applyFilters()">
                            Apply Filters
                        </button>
                    </div>
                </form>
            </div>
        </aside>

        <!-- Products Section -->
        <main class="products-section">
            <!-- Sort and View Options -->
            <div class="products-toolbar">
                <div class="toolbar-left">
                    <div class="results-info">
                        Showing <span id="resultsStart">1</span>-<span id="resultsEnd"><?php echo min($limit, $totalProducts); ?></span> 
                        of <span id="resultsTotal"><?php echo number_format($totalProducts); ?></span> results
                    </div>
                </div>
                
                <div class="toolbar-right">
                    <div class="items-per-page">
                        <label for="items-per-page-select">Show:</label>
                        <select id="items-per-page-select" name="per_page" onchange="updateItemsPerPage(this.value)">
                            <option value="20" <?php echo $limit === 20 ? 'selected' : ''; ?>>20</option>
                            <option value="40" <?php echo $limit === 40 ? 'selected' : ''; ?>>40</option>
                            <option value="60" <?php echo $limit === 60 ? 'selected' : ''; ?>>60</option>
                        </select>
                    </div>
                    
                    <div class="sort-options">
                        <label for="sort-select">Sort by:</label>
                        <select id="sort-select" name="sort" onchange="updateSort(this.value)">
                            <option value="name" <?php echo $sort === 'name' ? 'selected' : ''; ?>>Name A-Z</option>
                            <option value="price_asc" <?php echo $sort === 'price_asc' ? 'selected' : ''; ?>>Price: Low to High</option>
                            <option value="price_desc" <?php echo $sort === 'price_desc' ? 'selected' : ''; ?>>Price: High to Low</option>
                            <option value="newest" <?php echo $sort === 'newest' ? 'selected' : ''; ?>>Newest First</option>
                            <option value="rating" <?php echo $sort === 'rating' ? 'selected' : ''; ?>>Best Rating</option>
                            <option value="best_selling" <?php echo $sort === 'best_selling' ? 'selected' : ''; ?>>Best Selling</option>
                            <option value="discount" <?php echo $sort === 'discount' ? 'selected' : ''; ?>>Highest Discount</option>
                        </select>
                    </div>
                    
                    <div class="view-options">
                        <button class="view-btn active" data-view="grid" title="Grid View">⊞</button>
                        <button class="view-btn" data-view="list" title="List View">☰</button>
                    </div>
                </div>
            </div>

            <!-- Products Grid -->
            <?php if (!empty($products)): ?>
                <div class="products-grid" id="productsGrid">
                    <?php foreach ($products as $prod): ?>
                        <div class="product-card">
                            <div class="product-image">
                                <img src="<?php echo getSafeProductImageUrl($prod); ?>" 
                                     alt="<?php echo htmlspecialchars($prod['name']); ?>">
                                <?php if ($prod['price'] < $prod['price'] * 1.2): ?>
                                    <div class="sale-badge">Sale</div>
                                <?php endif; ?>
                                <div class="product-overlay">
                                    <button class="quick-view-btn" onclick="quickView(<?php echo $prod['id']; ?>)">
                                        Quick View
                                    </button>
                                </div>
                            </div>
                            <div class="product-info">
                                <h3 class="product-title">
                                    <a href="/product.php?id=<?php echo $prod['id']; ?>">
                                        <?php echo htmlspecialchars($prod['name']); ?>
                                    </a>
                                </h3>
                                <p class="product-vendor">by <?php echo htmlspecialchars($prod['vendor_name'] ?? 'FezaMarket'); ?></p>
                                <div class="product-rating">
                                    <span class="stars">★★★★☆</span>
                                    <span class="rating-count">(<?php echo rand(10, 200); ?>)</span>
                                </div>
                                <p class="product-price"><?php echo formatPrice($prod['price']); ?></p>
                                <div class="product-actions">
                                    <button class="btn add-to-cart" onclick="addToCart(<?php echo $prod['id']; ?>)">
                                        Add to Cart
                                    </button>
                                    <?php if (Session::isLoggedIn()): ?>
                                        <button class="btn btn-outline add-to-wishlist" onclick="addToWishlist(<?php echo $prod['id']; ?>)">
                                            ❤️
                                        </button>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>

                <!-- Pagination -->
                <?php if ($totalPages > 1): ?>
                    <div class="pagination">
                        <?php if ($page > 1): ?>
                            <a href="?<?php echo http_build_query(array_merge($_GET, ['page' => $page - 1])); ?>" 
                               class="pagination-btn">← Previous</a>
                        <?php endif; ?>
                        
                        <?php for ($i = max(1, $page - 2); $i <= min($totalPages, $page + 2); $i++): ?>
                            <a href="?<?php echo http_build_query(array_merge($_GET, ['page' => $i])); ?>" 
                               class="pagination-btn <?php echo $i === $page ? 'active' : ''; ?>">
                                <?php echo $i; ?>
                            </a>
                        <?php endfor; ?>
                        
                        <?php if ($page < $totalPages): ?>
                            <a href="?<?php echo http_build_query(array_merge($_GET, ['page' => $page + 1])); ?>" 
                               class="pagination-btn">Next →</a>
                        <?php endif; ?>
                    </div>
                <?php endif; ?>

            <?php else: ?>
                <div class="empty-category">
                    <div class="empty-icon">🔍</div>
                    <h2>No products found</h2>
                    <p>Try adjusting your filters or browse other categories.</p>
                    <a href="/products.php" class="btn">Browse All Products</a>
                </div>
            <?php endif; ?>
        </main>
    </div>
</div>

<style>
/* Category page specific container spacing - prevent overlap with sticky header */
body .container {
    padding-top: 20px;
    padding-left: 20px;
    padding-right: 20px;
}

.category-header {
    margin-bottom: 30px;
}

.breadcrumb {
    margin-bottom: 15px;
    color: #6b7280;
}

.breadcrumb a {
    color: #0654ba;
    text-decoration: none;
}

.separator {
    margin: 0 10px;
}

.current {
    font-weight: 600;
}

.category-info h1 {
    font-size: 32px;
    color: #1f2937;
    margin-bottom: 10px;
}

.category-description {
    color: #6b7280;
    margin-bottom: 15px;
    font-size: 16px;
}

.category-stats {
    display: flex;
    gap: 15px;
    align-items: center;
}

.product-count {
    color: #374151;
    font-weight: 600;
}

.sale-badge {
    background: #dc2626;
    color: white;
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: bold;
}

.subcategories-section {
    margin-bottom: 40px;
}

.subcategories-section h2 {
    color: #1f2937;
    margin-bottom: 20px;
}

.subcategories-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
}

.subcategory-card {
    background: white;
    padding: 20px;
    text-align: center;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    text-decoration: none;
    color: inherit;
    transition: transform 0.3s ease;
}

.subcategory-card:hover {
    transform: translateY(-3px);
}

.subcategory-icon {
    font-size: 36px;
    margin-bottom: 10px;
}

.subcategory-card h3 {
    color: #1f2937;
    margin-bottom: 5px;
}

.subcategory-card p {
    color: #6b7280;
    font-size: 14px;
}

/* Override global styles for category page - use specific selector */
.container > .category-content {
    display: grid !important;
    grid-template-columns: 250px 1fr !important;
    gap: 30px !important;
    position: static !important;
    margin-top: 0 !important;
    z-index: auto !important;
}

.filters-sidebar {
    position: sticky;
    top: 100px; /* Adjusted to account for header height */
    height: fit-content;
    max-height: calc(100vh - 120px);
    overflow-y: auto;
    z-index: 10; /* Below header but above regular content */
}

.filters-card {
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.filters-card h3 {
    color: #1f2937;
    margin-bottom: 20px;
    border-bottom: 1px solid #e5e7eb;
    padding-bottom: 10px;
}

.filter-group {
    margin-bottom: 25px;
}

.filter-group h4 {
    color: #374151;
    margin-bottom: 10px;
    font-size: 16px;
}

.price-inputs {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 10px;
}

.price-inputs input {
    flex: 1;
    padding: 8px;
    border: 1px solid #d1d5db;
    border-radius: 4px;
    font-size: 14px;
}

.filter-checkbox {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
}

.filter-checkbox input {
    margin: 0;
}

.clear-filters {
    color: #dc2626;
    text-decoration: none;
    font-size: 14px;
}

.products-toolbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 25px;
    padding: 15px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.sort-options {
    display: flex;
    align-items: center;
    gap: 10px;
}

.sort-options select {
    padding: 8px 12px;
    border: 1px solid #d1d5db;
    border-radius: 4px;
}

.view-options {
    display: flex;
    gap: 5px;
}

.view-btn {
    background: white;
    border: 1px solid #d1d5db;
    padding: 8px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 16px;
}

.view-btn.active {
    background: #0654ba;
    color: white;
    border-color: #0654ba;
}

.products-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
    margin-bottom: 40px;
}

.product-card {
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transition: transform 0.3s ease;
}

.product-card:hover {
    transform: translateY(-5px);
}

.product-image {
    position: relative;
    height: 200px;
}

.product-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.product-overlay {
    position: absolute;
    inset: 0;
    background: rgba(0,0,0,0.7);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    transition: opacity 0.3s ease;
}

.product-card:hover .product-overlay {
    opacity: 1;
}

.quick-view-btn {
    background: white;
    border: none;
    padding: 10px 20px;
    border-radius: 6px;
    cursor: pointer;
    font-weight: 600;
}

.product-info {
    padding: 15px;
}

.product-title a {
    color: #1f2937;
    text-decoration: none;
    font-size: 16px;
    font-weight: 600;
}

.product-vendor {
    color: #6b7280;
    font-size: 14px;
    margin: 5px 0;
}

.product-rating {
    margin: 8px 0;
}

.stars {
    color: #fbbf24;
    margin-right: 5px;
}

.rating-count {
    color: #6b7280;
    font-size: 14px;
}

.product-price {
    font-size: 18px;
    font-weight: bold;
    color: #dc2626;
    margin: 10px 0;
}

.product-actions {
    display: flex;
    gap: 8px;
}

.pagination {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin: 40px 0;
}

.pagination-btn {
    padding: 10px 15px;
    border: 1px solid #d1d5db;
    background: white;
    color: #374151;
    text-decoration: none;
    border-radius: 6px;
    transition: all 0.3s ease;
}

.pagination-btn:hover,
.pagination-btn.active {
    background: #0654ba;
    color: white;
    border-color: #0654ba;
}

.empty-category {
    text-align: center;
    padding: 60px 20px;
}

.empty-icon {
    font-size: 64px;
    margin-bottom: 20px;
}

.empty-category h2 {
    color: #1f2937;
    margin-bottom: 10px;
}

.empty-category p {
    color: #6b7280;
    margin-bottom: 30px;
}

@media (max-width: 768px) {
    /* Adjust container padding for mobile */
    body .container {
        padding-top: 15px;
        padding-left: 15px;
        padding-right: 15px;
    }
    
    .container > .category-content {
        grid-template-columns: 1fr !important;
    }
    
    .filters-sidebar {
        order: 2;
        position: relative !important;
        top: 0 !important;
        max-height: none !important;
        z-index: 1;
    }
    
    .products-section {
        order: 1;
        z-index: 2;
    }
    
    .products-toolbar {
        flex-direction: column;
        gap: 15px;
    }
}

/* Enhanced Filter Styles */
.filters-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.clear-all-filters {
    background: none;
    border: none;
    color: #dc2626;
    cursor: pointer;
    font-size: 0.875rem;
    padding: 5px 10px;
}

.clear-all-filters:hover {
    text-decoration: underline;
}

.active-filters-chips {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 15px;
}

.filter-chip {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: #eff6ff;
    color: #1e40af;
    padding: 6px 12px;
    border-radius: 16px;
    font-size: 0.875rem;
}

.filter-chip button {
    background: none;
    border: none;
    color: #1e40af;
    cursor: pointer;
    font-size: 1.2rem;
    line-height: 1;
    padding: 0;
    margin-left: 4px;
}

.filter-chip button:hover {
    color: #dc2626;
}

.filter-group.collapsible {
    border-bottom: 1px solid #e5e7eb;
}

.filter-group.collapsible:last-child {
    border-bottom: none;
}

.filter-group-header {
    display: flex;
    align-items: center;
    gap: 10px;
    cursor: pointer;
    padding: 12px 0;
    user-select: none;
}

.filter-group-header i {
    transition: transform 0.3s ease;
    font-size: 0.75rem;
}

.filter-group.collapsible:not(.active) .filter-group-header i {
    transform: rotate(-90deg);
}

.filter-group-content {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease;
}

.filter-group.active .filter-group-content {
    max-height: 500px;
    padding-bottom: 15px;
}

.filter-search-box {
    margin-bottom: 10px;
}

.filter-search-box input {
    width: 100%;
    padding: 8px;
    border: 1px solid #d1d5db;
    border-radius: 4px;
    font-size: 14px;
}

.filter-options-list {
    max-height: 200px;
    overflow-y: auto;
}

.color-filter-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
    gap: 10px;
}

.color-filter-option {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 5px;
    cursor: pointer;
    padding: 8px;
    border: 2px solid transparent;
    border-radius: 6px;
    transition: all 0.2s;
}

.color-filter-option:hover {
    background: #f9fafb;
}

.color-filter-option input[type="checkbox"] {
    display: none;
}

.color-filter-option input[type="checkbox"]:checked + .color-swatch {
    border-color: #3b82f6;
    box-shadow: 0 0 0 2px #dbeafe;
}

.color-swatch {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    border: 2px solid #d1d5db;
    transition: all 0.2s;
}

.color-name {
    font-size: 0.75rem;
    color: #6b7280;
    text-align: center;
}

.size-filter-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(50px, 1fr));
    gap: 8px;
}

.size-filter-option {
    display: inline-block;
    cursor: pointer;
}

.size-filter-option input[type="checkbox"] {
    display: none;
}

.size-filter-option span {
    display: block;
    padding: 8px 12px;
    border: 1px solid #d1d5db;
    border-radius: 4px;
    text-align: center;
    transition: all 0.2s;
}

.size-filter-option:hover span {
    background: #f9fafb;
}

.size-filter-option input[type="checkbox"]:checked + span {
    background: #3b82f6;
    color: white;
    border-color: #3b82f6;
}

.toolbar-left, .toolbar-right {
    display: flex;
    align-items: center;
    gap: 20px;
}

.results-info {
    color: #6b7280;
    font-size: 0.875rem;
}

.items-per-page {
    display: flex;
    align-items: center;
    gap: 8px;
}

.items-per-page label {
    color: #6b7280;
    font-size: 0.875rem;
    margin: 0;
}

.items-per-page select {
    padding: 6px 10px;
    border: 1px solid #d1d5db;
    border-radius: 4px;
}

.products-grid.list-view {
    grid-template-columns: 1fr;
}

.products-grid.list-view .product-card {
    display: grid;
    grid-template-columns: 200px 1fr;
    gap: 20px;
}

.products-grid.list-view .product-image {
    height: 200px;
}

.loading-spinner {
    text-align: center;
    padding: 60px 20px;
    color: #6b7280;
}
</style>

<script>
// Load filter options on page load
document.addEventListener('DOMContentLoaded', function() {
    loadFilterOptions();
    updateActiveFiltersDisplay();
});

function loadFilterOptions() {
    const categoryId = '<?php echo $categoryId; ?>';
    
    fetch(`/api/filter-options.php?category_id=${categoryId}`)
    .then(response => response.json())
    .then(result => {
        if (result.success && result.data) {
            populateBrandFilters(result.data.brands);
            populateColorFilters(result.data.colors);
            populateSizeFilters(result.data.sizes);
            populateMaterialFilters(result.data.materials);
        }
    })
    .catch(error => {
        console.error('Error loading filter options:', error);
    });
}

function populateBrandFilters(brands) {
    if (!brands || brands.length === 0) {
        document.getElementById('brandFilters').innerHTML = '<p class="text-muted">No brands available</p>';
        return;
    }
    
    const html = brands.map(brand => `
        <label class="filter-checkbox">
            <input type="checkbox" name="brands[]" value="${brand.id}">
            <span>${brand.name} (${brand.product_count})</span>
        </label>
    `).join('');
    
    document.getElementById('brandFilters').innerHTML = html;
}

function populateColorFilters(colors) {
    if (!colors || colors.length === 0) {
        document.getElementById('colorFilters').innerHTML = '<p class="text-muted">No colors available</p>';
        return;
    }
    
    const html = colors.map(color => `
        <label class="color-filter-option" title="${color.color}">
            <input type="checkbox" name="colors[]" value="${color.color}">
            <span class="color-swatch" style="background-color: ${color.color.toLowerCase()}"></span>
            <span class="color-name">${color.color}</span>
        </label>
    `).join('');
    
    document.getElementById('colorFilters').innerHTML = html;
}

function populateSizeFilters(sizes) {
    if (!sizes || sizes.length === 0) {
        document.getElementById('sizeFilters').innerHTML = '<p class="text-muted">No sizes available</p>';
        return;
    }
    
    const html = sizes.map(size => `
        <label class="size-filter-option">
            <input type="checkbox" name="sizes[]" value="${size.size}">
            <span>${size.size}</span>
        </label>
    `).join('');
    
    document.getElementById('sizeFilters').innerHTML = html;
}

function populateMaterialFilters(materials) {
    if (!materials || materials.length === 0) {
        document.getElementById('materialFilters').innerHTML = '<p class="text-muted">No materials available</p>';
        return;
    }
    
    const html = materials.map(material => `
        <label class="filter-checkbox">
            <input type="checkbox" name="materials[]" value="${material.material}">
            <span>${material.material} (${material.count})</span>
        </label>
    `).join('');
    
    document.getElementById('materialFilters').innerHTML = html;
}

function toggleFilterGroup(header) {
    const filterGroup = header.parentElement;
    filterGroup.classList.toggle('active');
}

function filterBrandList(input) {
    const filter = input.value.toLowerCase();
    const brandFilters = document.getElementById('brandFilters');
    const labels = brandFilters.getElementsByTagName('label');
    
    for (let label of labels) {
        const text = label.textContent.toLowerCase();
        label.style.display = text.includes(filter) ? '' : 'none';
    }
}

function applyFilters() {
    const form = document.getElementById('filtersForm');
    const formData = new FormData(form);
    const params = new URLSearchParams();
    
    // Add all form values to params
    for (let [key, value] of formData.entries()) {
        if (value) {
            params.append(key, value);
        }
    }
    
    // Build URL with filters
    const url = window.location.pathname + '?' + params.toString();
    
    // Use AJAX to load products without page reload
    loadProductsAjax(params);
    
    // Update URL without reload
    history.pushState({}, '', url);
    
    // Update active filters display
    updateActiveFiltersDisplay();
}

function loadProductsAjax(params) {
    const productsGrid = document.getElementById('productsGrid');
    productsGrid.innerHTML = '<div class="loading-spinner">Loading products...</div>';
    
    fetch('/api/advanced-filters.php?' + params.toString())
    .then(response => response.json())
    .then(result => {
        if (result.success && result.data) {
            displayProducts(result.data.products);
            updatePagination(result.data.pagination);
        } else {
            productsGrid.innerHTML = '<p class="text-center text-muted">No products found</p>';
        }
    })
    .catch(error => {
        console.error('Error loading products:', error);
        productsGrid.innerHTML = '<p class="text-center text-danger">Error loading products</p>';
    });
}

function displayProducts(products) {
    const productsGrid = document.getElementById('productsGrid');
    
    if (!products || products.length === 0) {
        productsGrid.innerHTML = '<p class="text-center text-muted">No products found</p>';
        return;
    }
    
    const html = products.map(product => `
        <div class="product-card">
            <div class="product-image">
                <img src="${product.image_url}" alt="${product.name}">
                ${product.is_on_sale ? '<div class="sale-badge">Sale</div>' : ''}
                <div class="product-overlay">
                    <button class="quick-view-btn" onclick="quickView(${product.id})">
                        Quick View
                    </button>
                </div>
            </div>
            <div class="product-info">
                <h3 class="product-title">
                    <a href="/product.php?id=${product.id}">
                        ${product.name}
                    </a>
                </h3>
                <p class="product-vendor">by ${product.vendor_name || 'FezaMarket'}</p>
                <div class="product-rating">
                    <span class="stars">${'★'.repeat(product.rating_stars)}${'☆'.repeat(5 - product.rating_stars)}</span>
                    <span class="rating-count">(${product.rating_count || 0})</span>
                </div>
                <p class="product-price">${product.formatted_price}</p>
                <div class="product-actions">
                    <button class="btn add-to-cart" onclick="addToCart(${product.id})">
                        Add to Cart
                    </button>
                    <?php if (Session::isLoggedIn()): ?>
                        <button class="btn btn-outline add-to-wishlist" onclick="addToWishlist(${product.id})">
                            ❤️
                        </button>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    `).join('');
    
    productsGrid.innerHTML = html;
}

function updateActiveFiltersDisplay() {
    const form = document.getElementById('filtersForm');
    const formData = new FormData(form);
    const chips = [];
    
    // Check all form inputs and create chips
    for (let [key, value] of formData.entries()) {
        if (value && key !== 'name' && key !== 'id') {
            const label = getFilterLabel(key, value);
            if (label) {
                chips.push({key, value, label});
            }
        }
    }
    
    const chipsContainer = document.getElementById('activeFiltersChips');
    
    if (chips.length === 0) {
        chipsContainer.innerHTML = '';
        document.querySelector('.clear-all-filters').style.display = 'none';
        return;
    }
    
    const html = chips.map(chip => `
        <div class="filter-chip">
            <span>${chip.label}</span>
            <button onclick="removeFilter('${chip.key}', '${chip.value}')">&times;</button>
        </div>
    `).join('');
    
    chipsContainer.innerHTML = html;
    document.querySelector('.clear-all-filters').style.display = 'inline-block';
}

function getFilterLabel(key, value) {
    const labelMap = {
        'min_price': `Min: $${value}`,
        'max_price': `Max: $${value}`,
        'on_sale': 'On Sale',
        'new_arrival': 'New Arrivals',
        'featured': 'Featured',
        'free_shipping': 'Free Shipping',
        'fast_delivery': 'Fast Delivery',
        'rating': `${value}+ Stars`
    };
    
    if (labelMap[key]) {
        return labelMap[key];
    }
    
    if (key.includes('[]')) {
        const baseKey = key.replace('[]', '');
        return `${baseKey}: ${value}`;
    }
    
    return null;
}

function removeFilter(key, value) {
    const form = document.getElementById('filtersForm');
    const inputs = form.querySelectorAll(`[name="${key}"]`);
    
    inputs.forEach(input => {
        if (input.value === value || input.type === 'checkbox' || input.type === 'radio') {
            input.checked = false;
            input.value = '';
        }
    });
    
    applyFilters();
}

function clearAllFilters() {
    const form = document.getElementById('filtersForm');
    form.reset();
    
    // Keep category info
    const categoryName = '<?php echo htmlspecialchars($categoryName); ?>';
    const categoryId = '<?php echo htmlspecialchars($categoryId); ?>';
    
    window.location.href = `/category.php?name=${encodeURIComponent(categoryName)}&id=${categoryId}`;
}

function updateItemsPerPage(value) {
    const url = new URL(window.location);
    url.searchParams.set('per_page', value);
    url.searchParams.set('page', '1'); // Reset to first page
    window.location.href = url.toString();
}

function updateSort(sortValue) {
    const url = new URL(window.location);
    url.searchParams.set('sort', sortValue);
    window.location.href = url.toString();
}

function updatePagination(pagination) {
    // Update results info
    const start = (pagination.page - 1) * pagination.per_page + 1;
    const end = Math.min(pagination.page * pagination.per_page, pagination.total);
    
    document.getElementById('resultsStart').textContent = start;
    document.getElementById('resultsEnd').textContent = end;
    document.getElementById('resultsTotal').textContent = pagination.total.toLocaleString();
}

function quickView(productId) {
    window.location.href = '/product.php?id=' + productId;
}

function addToCart(productId) {
    fetch('/api/cart.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            action: 'add',
            product_id: productId,
            quantity: 1
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            const button = event.target;
            const originalText = button.textContent;
            button.textContent = 'Added!';
            button.classList.add('btn-success');
            
            setTimeout(() => {
                button.textContent = originalText;
                button.classList.remove('btn-success');
            }, 2000);
        } else {
            alert('Error adding to cart: ' + data.error);
        }
    })
    .catch(error => {
        console.error('Error:', error);
    });
}

function addToWishlist(productId) {
    fetch('/api/wishlist.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            action: 'add',
            product_id: productId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            const button = event.target;
            button.textContent = '💖';
            button.disabled = true;
        } else {
            alert('Error adding to wishlist: ' + data.error);
        }
    })
    .catch(error => {
        console.error('Error:', error);
    });
}

// View toggle functionality
document.querySelectorAll('.view-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.view-btn').forEach(b => b.classList.remove('active'));
        this.classList.add('active');
        
        const view = this.dataset.view;
        const grid = document.getElementById('productsGrid');
        
        if (view === 'list') {
            grid.classList.add('list-view');
        } else {
            grid.classList.remove('list-view');
        }
    });
});
</script>

<?php includeFooter(); ?>