<?php
/**
 * Migration Script: Add Slugs to Existing Products and Streams
 * Automatically generates SEO-friendly slugs for existing database records
 */

require_once __DIR__ . '/includes/init.php';
require_once __DIR__ . '/includes/seo.php';

echo "Starting slug migration...\n\n";

$db = db();
$updated = 0;
$skipped = 0;

// Check if slug column exists in products table
try {
    $stmt = $db->query("SHOW COLUMNS FROM products LIKE 'slug'");
    if ($stmt->rowCount() === 0) {
        echo "Adding 'slug' column to products table...\n";
        $db->exec("ALTER TABLE products ADD COLUMN slug VARCHAR(255) NULL UNIQUE AFTER name");
        echo "✓ Column added successfully\n\n";
    }
} catch (Exception $e) {
    echo "Note: " . $e->getMessage() . "\n\n";
}

// Update products
echo "Processing products...\n";
try {
    $stmt = $db->query("SELECT id, name, slug FROM products WHERE status = 'active'");
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($products as $product) {
        if (empty($product['slug'])) {
            $slug = SEO::generateSlug($product['name']);
            $slug = SEO::ensureUniqueSlug('products', $slug, $product['id']);
            
            $updateStmt = $db->prepare("UPDATE products SET slug = ? WHERE id = ?");
            $updateStmt->execute([$slug, $product['id']]);
            
            echo "  ✓ Product #{$product['id']}: {$product['name']} -> {$slug}\n";
            $updated++;
        } else {
            $skipped++;
        }
    }
    
    echo "\n✓ Products: {$updated} updated, {$skipped} skipped\n\n";
    
} catch (Exception $e) {
    echo "Error processing products: " . $e->getMessage() . "\n\n";
}

// Check if slug column exists in live_streams table
$updated = 0;
$skipped = 0;

try {
    $stmt = $db->query("SHOW COLUMNS FROM live_streams LIKE 'slug'");
    if ($stmt->rowCount() === 0) {
        echo "Adding 'slug' column to live_streams table...\n";
        $db->exec("ALTER TABLE live_streams ADD COLUMN slug VARCHAR(255) NULL UNIQUE AFTER title");
        echo "✓ Column added successfully\n\n";
    }
} catch (Exception $e) {
    echo "Note: " . $e->getMessage() . "\n\n";
}

// Update live streams
echo "Processing live streams...\n";
try {
    $stmt = $db->query("SELECT id, title, slug FROM live_streams");
    $streams = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($streams as $stream) {
        if (empty($stream['slug'])) {
            $slug = SEO::generateSlug($stream['title']);
            $slug = SEO::ensureUniqueSlug('live_streams', $slug, $stream['id']);
            
            $updateStmt = $db->prepare("UPDATE live_streams SET slug = ? WHERE id = ?");
            $updateStmt->execute([$slug, $stream['id']]);
            
            echo "  ✓ Stream #{$stream['id']}: {$stream['title']} -> {$slug}\n";
            $updated++;
        } else {
            $skipped++;
        }
    }
    
    echo "\n✓ Live Streams: {$updated} updated, {$skipped} skipped\n\n";
    
} catch (Exception $e) {
    echo "Error processing live streams: " . $e->getMessage() . "\n\n";
}

// Check if slug column exists in categories table
$updated = 0;
$skipped = 0;

try {
    $stmt = $db->query("SHOW COLUMNS FROM categories LIKE 'slug'");
    if ($stmt->rowCount() === 0) {
        echo "Adding 'slug' column to categories table...\n";
        $db->exec("ALTER TABLE categories ADD COLUMN slug VARCHAR(255) NULL UNIQUE AFTER name");
        echo "✓ Column added successfully\n\n";
    }
} catch (Exception $e) {
    echo "Note: " . $e->getMessage() . "\n\n";
}

// Update categories
echo "Processing categories...\n";
try {
    $stmt = $db->query("SELECT id, name, slug FROM categories WHERE status = 'active'");
    $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($categories as $category) {
        if (empty($category['slug'])) {
            $slug = SEO::generateSlug($category['name']);
            $slug = SEO::ensureUniqueSlug('categories', $slug, $category['id']);
            
            $updateStmt = $db->prepare("UPDATE categories SET slug = ? WHERE id = ?");
            $updateStmt->execute([$slug, $category['id']]);
            
            echo "  ✓ Category #{$category['id']}: {$category['name']} -> {$slug}\n";
            $updated++;
        } else {
            $skipped++;
        }
    }
    
    echo "\n✓ Categories: {$updated} updated, {$skipped} skipped\n\n";
    
} catch (Exception $e) {
    echo "Error processing categories: " . $e->getMessage() . "\n\n";
}

// Check if slug column exists in vendors table
$updated = 0;
$skipped = 0;

try {
    $stmt = $db->query("SHOW COLUMNS FROM vendors LIKE 'slug'");
    if ($stmt->rowCount() === 0) {
        echo "Adding 'slug' column to vendors table...\n";
        $db->exec("ALTER TABLE vendors ADD COLUMN slug VARCHAR(255) NULL UNIQUE AFTER business_name");
        echo "✓ Column added successfully\n\n";
    }
} catch (Exception $e) {
    echo "Note: " . $e->getMessage() . "\n\n";
}

// Update vendors
echo "Processing vendors...\n";
try {
    $stmt = $db->query("SELECT id, business_name, slug FROM vendors WHERE status = 'approved'");
    $vendors = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($vendors as $vendor) {
        if (empty($vendor['slug'])) {
            $slug = SEO::generateSlug($vendor['business_name']);
            $slug = SEO::ensureUniqueSlug('vendors', $slug, $vendor['id']);
            
            $updateStmt = $db->prepare("UPDATE vendors SET slug = ? WHERE id = ?");
            $updateStmt->execute([$slug, $vendor['id']]);
            
            echo "  ✓ Vendor #{$vendor['id']}: {$vendor['business_name']} -> {$slug}\n";
            $updated++;
        } else {
            $skipped++;
        }
    }
    
    echo "\n✓ Vendors: {$updated} updated, {$skipped} skipped\n\n";
    
} catch (Exception $e) {
    echo "Error processing vendors: " . $e->getMessage() . "\n\n";
}

echo "✅ Slug migration complete!\n";
echo "Run this script again if you add new records without slugs.\n";
