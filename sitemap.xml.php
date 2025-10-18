<?php
/**
 * Dynamic Sitemap Generator
 * Automatically generates sitemap.xml with all products, streams, and pages
 */

require_once __DIR__ . '/includes/init.php';

// Set XML header
header('Content-Type: application/xml; charset=utf-8');

// Get database connection
$db = db();

// Start XML output
echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' . "\n";

// Base URL
$baseUrl = 'https://' . ($_SERVER['HTTP_HOST'] ?? 'fezamarket.com');

// Add homepage
addUrl($baseUrl . '/', '1.0', 'daily', date('Y-m-d'));

// Add static pages
$staticPages = [
    '/about.php' => ['priority' => '0.8', 'changefreq' => 'monthly'],
    '/help.php' => ['priority' => '0.7', 'changefreq' => 'monthly'],
    '/contact.php' => ['priority' => '0.7', 'changefreq' => 'monthly'],
    '/live.php' => ['priority' => '0.9', 'changefreq' => 'hourly'],
    '/products.php' => ['priority' => '0.9', 'changefreq' => 'daily'],
    '/deals.php' => ['priority' => '0.8', 'changefreq' => 'daily'],
];

foreach ($staticPages as $page => $config) {
    addUrl($baseUrl . $page, $config['priority'], $config['changefreq']);
}

// Add products
try {
    $stmt = $db->query("
        SELECT id, slug, updated_at, created_at
        FROM products 
        WHERE status = 'active'
        ORDER BY updated_at DESC
        LIMIT 5000
    ");
    
    while ($product = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $url = $baseUrl . '/product/' . ($product['slug'] ?? $product['id']);
        $lastmod = $product['updated_at'] ?? $product['created_at'];
        addUrl($url, '0.8', 'weekly', $lastmod);
    }
} catch (Exception $e) {
    error_log('Sitemap products error: ' . $e->getMessage());
}

// Add archived live streams (replays)
try {
    $stmt = $db->query("
        SELECT id, slug, updated_at, created_at
        FROM live_streams 
        WHERE status = 'archived' 
        AND video_path IS NOT NULL
        ORDER BY ended_at DESC
        LIMIT 1000
    ");
    
    while ($stream = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $url = $baseUrl . '/live.php?stream=' . $stream['id'] . '&replay=1';
        $lastmod = $stream['updated_at'] ?? $stream['created_at'];
        addUrl($url, '0.7', 'monthly', $lastmod);
    }
} catch (Exception $e) {
    error_log('Sitemap streams error: ' . $e->getMessage());
}

// Add categories
try {
    $stmt = $db->query("
        SELECT id, slug, name, updated_at
        FROM categories 
        WHERE status = 'active'
        ORDER BY name
    ");
    
    while ($category = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $url = $baseUrl . '/category.php?name=' . urlencode($category['slug'] ?? $category['name']);
        $lastmod = $category['updated_at'] ?? date('Y-m-d');
        addUrl($url, '0.7', 'weekly', $lastmod);
    }
} catch (Exception $e) {
    error_log('Sitemap categories error: ' . $e->getMessage());
}

// Add vendor/seller stores
try {
    $stmt = $db->query("
        SELECT id, slug, business_name, updated_at
        FROM vendors 
        WHERE status = 'approved'
        ORDER BY business_name
        LIMIT 1000
    ");
    
    while ($vendor = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $url = $baseUrl . '/stores.php?vendor=' . ($vendor['slug'] ?? $vendor['id']);
        $lastmod = $vendor['updated_at'] ?? date('Y-m-d');
        addUrl($url, '0.6', 'weekly', $lastmod);
    }
} catch (Exception $e) {
    error_log('Sitemap vendors error: ' . $e->getMessage());
}

// Close XML
echo '</urlset>';

/**
 * Helper function to add URL to sitemap
 */
function addUrl($url, $priority = '0.5', $changefreq = 'monthly', $lastmod = null) {
    echo "  <url>\n";
    echo "    <loc>" . htmlspecialchars($url) . "</loc>\n";
    
    if ($lastmod) {
        $date = date('Y-m-d', strtotime($lastmod));
        echo "    <lastmod>" . $date . "</lastmod>\n";
    }
    
    echo "    <changefreq>" . $changefreq . "</changefreq>\n";
    echo "    <priority>" . $priority . "</priority>\n";
    echo "  </url>\n";
}
