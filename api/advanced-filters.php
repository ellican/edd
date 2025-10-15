<?php
/**
 * Advanced Product Filters API
 * Returns filter options and products based on multiple criteria
 */

require_once __DIR__ . '/../includes/init.php';

header('Content-Type: application/json');

try {
    $db = db();
    
    // Get filter parameters
    $categoryId = isset($_GET['category_id']) ? (int)$_GET['category_id'] : 0;
    $minPrice = isset($_GET['min_price']) ? (float)$_GET['min_price'] : null;
    $maxPrice = isset($_GET['max_price']) ? (float)$_GET['max_price'] : null;
    $brands = isset($_GET['brands']) ? explode(',', $_GET['brands']) : [];
    $ratings = isset($_GET['ratings']) ? (int)$_GET['ratings'] : 0;
    $availability = isset($_GET['availability']) ? $_GET['availability'] : '';
    $onSale = isset($_GET['on_sale']) ? (bool)$_GET['on_sale'] : false;
    $newArrival = isset($_GET['new_arrival']) ? (bool)$_GET['new_arrival'] : false;
    $freeShipping = isset($_GET['free_shipping']) ? (bool)$_GET['free_shipping'] : false;
    $colors = isset($_GET['colors']) ? explode(',', $_GET['colors']) : [];
    $sizes = isset($_GET['sizes']) ? explode(',', $_GET['sizes']) : [];
    $materials = isset($_GET['materials']) ? explode(',', $_GET['materials']) : [];
    $sort = isset($_GET['sort']) ? $_GET['sort'] : 'name';
    $page = max(1, (int)($_GET['page'] ?? 1));
    $perPage = min(60, max(20, (int)($_GET['per_page'] ?? 20)));
    $offset = ($page - 1) * $perPage;
    
    // Build query
    $where = ["p.status = 'active'"];
    $params = [];
    
    if ($categoryId > 0) {
        $where[] = "p.category_id = ?";
        $params[] = $categoryId;
    }
    
    if ($minPrice !== null) {
        $where[] = "p.price >= ?";
        $params[] = $minPrice;
    }
    
    if ($maxPrice !== null) {
        $where[] = "p.price <= ?";
        $params[] = $maxPrice;
    }
    
    if (!empty($brands)) {
        $placeholders = str_repeat('?,', count($brands) - 1) . '?';
        $where[] = "p.brand_id IN ($placeholders)";
        $params = array_merge($params, $brands);
    }
    
    if ($ratings > 0) {
        $where[] = "p.rating_avg >= ?";
        $params[] = $ratings;
    }
    
    if (!empty($availability)) {
        $where[] = "p.availability_status = ?";
        $params[] = $availability;
    }
    
    if ($onSale) {
        $where[] = "p.is_on_sale = 1";
    }
    
    if ($newArrival) {
        $where[] = "p.is_new_arrival = 1";
    }
    
    if ($freeShipping) {
        $where[] = "p.free_shipping = 1";
    }
    
    if (!empty($colors)) {
        $placeholders = str_repeat('?,', count($colors) - 1) . '?';
        $where[] = "p.color IN ($placeholders)";
        $params = array_merge($params, $colors);
    }
    
    if (!empty($sizes)) {
        $placeholders = str_repeat('?,', count($sizes) - 1) . '?';
        $where[] = "p.size IN ($placeholders)";
        $params = array_merge($params, $sizes);
    }
    
    if (!empty($materials)) {
        $placeholders = str_repeat('?,', count($materials) - 1) . '?';
        $where[] = "p.material IN ($placeholders)";
        $params = array_merge($params, $materials);
    }
    
    $whereClause = implode(' AND ', $where);
    
    // Determine sort order
    $orderBy = match($sort) {
        'price_asc' => 'p.price ASC',
        'price_desc' => 'p.price DESC',
        'newest' => 'p.created_at DESC',
        'rating' => 'p.rating_avg DESC, p.rating_count DESC',
        'best_selling' => 'p.sales_count DESC',
        'discount' => 'p.discount_percentage DESC',
        default => 'p.name ASC'
    };
    
    // Get total count
    $countStmt = $db->prepare("
        SELECT COUNT(*) 
        FROM products p 
        WHERE $whereClause
    ");
    $countStmt->execute($params);
    $total = $countStmt->fetchColumn();
    
    // Get products
    $stmt = $db->prepare("
        SELECT 
            p.*,
            b.name as brand_name,
            c.name as category_name,
            u.username as vendor_name
        FROM products p
        LEFT JOIN brands b ON p.brand_id = b.id
        LEFT JOIN categories c ON p.category_id = c.id
        LEFT JOIN users u ON p.vendor_id = u.id
        WHERE $whereClause
        ORDER BY $orderBy
        LIMIT ? OFFSET ?
    ");
    
    $params[] = $perPage;
    $params[] = $offset;
    $stmt->execute($params);
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format products
    foreach ($products as &$product) {
        $product['formatted_price'] = formatPrice($product['price']);
        $product['image_url'] = getSafeProductImageUrl($product);
        $product['rating_stars'] = round($product['rating_avg']);
    }
    
    successResponse([
        'products' => $products,
        'pagination' => [
            'page' => $page,
            'per_page' => $perPage,
            'total' => $total,
            'total_pages' => ceil($total / $perPage)
        ]
    ]);
    
} catch (Exception $e) {
    Logger::error('Advanced filters error: ' . $e->getMessage());
    errorResponse('An error occurred while filtering products', 500);
}
