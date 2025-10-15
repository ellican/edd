<?php
/**
 * Get Filter Options API
 * Returns available filter values for category
 */

require_once __DIR__ . '/../includes/init.php';

header('Content-Type: application/json');

try {
    $db = db();
    
    $categoryId = isset($_GET['category_id']) ? (int)$_GET['category_id'] : 0;
    
    // Build base query condition
    $where = "status = 'active'";
    $params = [];
    
    if ($categoryId > 0) {
        $where .= " AND category_id = ?";
        $params[] = $categoryId;
    }
    
    // Get brands
    $brandsStmt = $db->prepare("
        SELECT DISTINCT b.id, b.name, COUNT(p.id) as product_count
        FROM brands b
        INNER JOIN products p ON b.id = p.brand_id
        WHERE p.$where
        GROUP BY b.id, b.name
        ORDER BY product_count DESC, b.name ASC
    ");
    $brandsStmt->execute($params);
    $brands = $brandsStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get price range
    $priceStmt = $db->prepare("
        SELECT MIN(price) as min_price, MAX(price) as max_price
        FROM products
        WHERE $where
    ");
    $priceStmt->execute($params);
    $priceRange = $priceStmt->fetch(PDO::FETCH_ASSOC);
    
    // Get colors
    $colorsStmt = $db->prepare("
        SELECT DISTINCT color, COUNT(*) as count
        FROM products
        WHERE $where AND color IS NOT NULL AND color != ''
        GROUP BY color
        ORDER BY count DESC
    ");
    $colorsStmt->execute($params);
    $colors = $colorsStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get sizes
    $sizesStmt = $db->prepare("
        SELECT DISTINCT size, COUNT(*) as count
        FROM products
        WHERE $where AND size IS NOT NULL AND size != ''
        GROUP BY size
        ORDER BY count DESC
    ");
    $sizesStmt->execute($params);
    $sizes = $sizesStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get materials
    $materialsStmt = $db->prepare("
        SELECT DISTINCT material, COUNT(*) as count
        FROM products
        WHERE $where AND material IS NOT NULL AND material != ''
        GROUP BY material
        ORDER BY count DESC
    ");
    $materialsStmt->execute($params);
    $materials = $materialsStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get availability options
    $availabilityStmt = $db->prepare("
        SELECT availability_status, COUNT(*) as count
        FROM products
        WHERE $where
        GROUP BY availability_status
    ");
    $availabilityStmt->execute($params);
    $availability = $availabilityStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get counts for special filters
    $specialStmt = $db->prepare("
        SELECT 
            SUM(CASE WHEN is_on_sale = 1 THEN 1 ELSE 0 END) as on_sale_count,
            SUM(CASE WHEN is_new_arrival = 1 THEN 1 ELSE 0 END) as new_arrival_count,
            SUM(CASE WHEN is_featured = 1 THEN 1 ELSE 0 END) as featured_count,
            SUM(CASE WHEN free_shipping = 1 THEN 1 ELSE 0 END) as free_shipping_count,
            SUM(CASE WHEN discount_percentage > 0 THEN 1 ELSE 0 END) as discount_count
        FROM products
        WHERE $where
    ");
    $specialStmt->execute($params);
    $special = $specialStmt->fetch(PDO::FETCH_ASSOC);
    
    successResponse([
        'brands' => $brands,
        'price_range' => $priceRange,
        'colors' => $colors,
        'sizes' => $sizes,
        'materials' => $materials,
        'availability' => $availability,
        'special_filters' => $special
    ]);
    
} catch (Exception $e) {
    Logger::error('Get filter options error: ' . $e->getMessage());
    errorResponse('An error occurred while fetching filter options', 500);
}
