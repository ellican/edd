<?php
/**
 * SEO Helper Functions
 * Comprehensive SEO optimization for the entire platform
 */

class SEO {
    /**
     * Generate meta tags for a page
     */
    public static function generateMetaTags($config = []) {
        $defaults = [
            'title' => 'FezaMarket - Online Marketplace',
            'description' => 'Shop the best deals on FezaMarket',
            'keywords' => 'marketplace, shopping, deals',
            'image' => '/assets/images/og-default.jpg',
            'url' => self::getCurrentUrl(),
            'type' => 'website',
            'site_name' => 'FezaMarket',
            'twitter_card' => 'summary_large_image',
            'twitter_site' => '@FezaMarket'
        ];
        
        $meta = array_merge($defaults, $config);
        
        // Basic meta tags
        $tags = [];
        $tags[] = '<meta charset="UTF-8">';
        $tags[] = '<meta name="viewport" content="width=device-width, initial-scale=1.0">';
        $tags[] = '<title>' . htmlspecialchars($meta['title']) . '</title>';
        $tags[] = '<meta name="description" content="' . htmlspecialchars($meta['description']) . '">';
        $tags[] = '<meta name="keywords" content="' . htmlspecialchars($meta['keywords']) . '">';
        
        // Canonical URL
        if (isset($meta['canonical'])) {
            $tags[] = '<link rel="canonical" href="' . htmlspecialchars($meta['canonical']) . '">';
        } else {
            $tags[] = '<link rel="canonical" href="' . htmlspecialchars($meta['url']) . '">';
        }
        
        // Open Graph tags
        $tags[] = '<meta property="og:title" content="' . htmlspecialchars($meta['title']) . '">';
        $tags[] = '<meta property="og:description" content="' . htmlspecialchars($meta['description']) . '">';
        $tags[] = '<meta property="og:image" content="' . htmlspecialchars($meta['image']) . '">';
        $tags[] = '<meta property="og:url" content="' . htmlspecialchars($meta['url']) . '">';
        $tags[] = '<meta property="og:type" content="' . htmlspecialchars($meta['type']) . '">';
        $tags[] = '<meta property="og:site_name" content="' . htmlspecialchars($meta['site_name']) . '">';
        
        // Twitter Card tags
        $tags[] = '<meta name="twitter:card" content="' . htmlspecialchars($meta['twitter_card']) . '">';
        $tags[] = '<meta name="twitter:site" content="' . htmlspecialchars($meta['twitter_site']) . '">';
        $tags[] = '<meta name="twitter:title" content="' . htmlspecialchars($meta['title']) . '">';
        $tags[] = '<meta name="twitter:description" content="' . htmlspecialchars($meta['description']) . '">';
        $tags[] = '<meta name="twitter:image" content="' . htmlspecialchars($meta['image']) . '">';
        
        return implode("\n    ", $tags);
    }
    
    /**
     * Generate JSON-LD structured data for products
     */
    public static function generateProductSchema($product, $vendor = null) {
        $schema = [
            '@context' => 'https://schema.org',
            '@type' => 'Product',
            'name' => $product['name'],
            'description' => $product['description'] ?? '',
            'image' => self::getAbsoluteUrl($product['image'] ?? '/assets/images/no-image.png'),
            'sku' => $product['id'],
            'offers' => [
                '@type' => 'Offer',
                'url' => self::getAbsoluteUrl('/product/' . ($product['slug'] ?? $product['id'])),
                'priceCurrency' => 'USD',
                'price' => $product['price'],
                'availability' => $product['stock_quantity'] > 0 ? 'https://schema.org/InStock' : 'https://schema.org/OutOfStock',
                'priceValidUntil' => date('Y-m-d', strtotime('+1 year'))
            ]
        ];
        
        // Add brand/seller information
        if ($vendor) {
            $schema['brand'] = [
                '@type' => 'Brand',
                'name' => $vendor['business_name'] ?? 'FezaMarket Seller'
            ];
        }
        
        // Add ratings if available
        if (isset($product['average_rating']) && $product['average_rating'] > 0) {
            $schema['aggregateRating'] = [
                '@type' => 'AggregateRating',
                'ratingValue' => $product['average_rating'],
                'reviewCount' => $product['review_count'] ?? 1
            ];
        }
        
        return '<script type="application/ld+json">' . json_encode($schema, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT) . '</script>';
    }
    
    /**
     * Generate JSON-LD structured data for live streams
     */
    public static function generateVideoSchema($stream, $vendor = null) {
        $schema = [
            '@context' => 'https://schema.org',
            '@type' => 'VideoObject',
            'name' => $stream['title'],
            'description' => $stream['description'] ?? 'Live shopping stream',
            'thumbnailUrl' => self::getAbsoluteUrl($stream['thumbnail_url'] ?? '/assets/images/live-default.jpg'),
            'uploadDate' => date('c', strtotime($stream['started_at'])),
            'duration' => self::calculateDuration($stream['started_at'], $stream['ended_at'] ?? null)
        ];
        
        // Add video URL if available (for replays)
        if (isset($stream['video_path']) && !empty($stream['video_path'])) {
            $schema['contentUrl'] = self::getAbsoluteUrl($stream['video_path']);
        }
        
        // Add publisher information
        if ($vendor) {
            $schema['publisher'] = [
                '@type' => 'Organization',
                'name' => $vendor['business_name'] ?? 'FezaMarket Seller'
            ];
        }
        
        // Add interaction statistics
        if (isset($stream['viewer_count'])) {
            $schema['interactionStatistic'] = [
                '@type' => 'InteractionCounter',
                'interactionType' => 'https://schema.org/WatchAction',
                'userInteractionCount' => $stream['viewer_count']
            ];
        }
        
        return '<script type="application/ld+json">' . json_encode($schema, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT) . '</script>';
    }
    
    /**
     * Generate JSON-LD structured data for organization
     */
    public static function generateOrganizationSchema() {
        $schema = [
            '@context' => 'https://schema.org',
            '@type' => 'Organization',
            'name' => 'FezaMarket',
            'url' => self::getAbsoluteUrl('/'),
            'logo' => self::getAbsoluteUrl('/assets/images/logo.png'),
            'sameAs' => [
                'https://www.facebook.com/fezamarket',
                'https://twitter.com/fezamarket',
                'https://www.instagram.com/fezamarket'
            ],
            'contactPoint' => [
                '@type' => 'ContactPoint',
                'telephone' => '+1-800-FEZA-MKT',
                'contactType' => 'customer service'
            ]
        ];
        
        return '<script type="application/ld+json">' . json_encode($schema, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT) . '</script>';
    }
    
    /**
     * Generate JSON-LD breadcrumb list
     */
    public static function generateBreadcrumbSchema($breadcrumbs) {
        $itemList = [];
        $position = 1;
        
        foreach ($breadcrumbs as $breadcrumb) {
            $itemList[] = [
                '@type' => 'ListItem',
                'position' => $position++,
                'name' => $breadcrumb['name'],
                'item' => self::getAbsoluteUrl($breadcrumb['url'])
            ];
        }
        
        $schema = [
            '@context' => 'https://schema.org',
            '@type' => 'BreadcrumbList',
            'itemListElement' => $itemList
        ];
        
        return '<script type="application/ld+json">' . json_encode($schema, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT) . '</script>';
    }
    
    /**
     * Generate URL slug from string
     */
    public static function generateSlug($string) {
        // Convert to lowercase
        $slug = strtolower($string);
        
        // Replace non-alphanumeric characters with hyphens
        $slug = preg_replace('/[^a-z0-9]+/', '-', $slug);
        
        // Remove leading/trailing hyphens
        $slug = trim($slug, '-');
        
        return $slug;
    }
    
    /**
     * Ensure slug is unique in database
     */
    public static function ensureUniqueSlug($table, $slug, $excludeId = null) {
        $db = db();
        $originalSlug = $slug;
        $counter = 1;
        
        while (true) {
            $query = "SELECT id FROM $table WHERE slug = ?";
            $params = [$slug];
            
            if ($excludeId) {
                $query .= " AND id != ?";
                $params[] = $excludeId;
            }
            
            $stmt = $db->prepare($query);
            $stmt->execute($params);
            
            if ($stmt->rowCount() === 0) {
                break;
            }
            
            $slug = $originalSlug . '-' . $counter++;
        }
        
        return $slug;
    }
    
    /**
     * Get current URL
     */
    private static function getCurrentUrl() {
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
        $uri = $_SERVER['REQUEST_URI'] ?? '/';
        
        return $protocol . '://' . $host . $uri;
    }
    
    /**
     * Get absolute URL from relative path
     */
    private static function getAbsoluteUrl($path) {
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
        
        // Remove leading slash if present
        $path = ltrim($path, '/');
        
        return $protocol . '://' . $host . '/' . $path;
    }
    
    /**
     * Calculate video duration in ISO 8601 format
     */
    private static function calculateDuration($start, $end = null) {
        if (!$end) {
            return 'PT0S'; // No duration if stream is still live or no end time
        }
        
        $startTime = strtotime($start);
        $endTime = strtotime($end);
        $seconds = $endTime - $startTime;
        
        if ($seconds <= 0) {
            return 'PT0S';
        }
        
        $hours = floor($seconds / 3600);
        $minutes = floor(($seconds % 3600) / 60);
        $secs = $seconds % 60;
        
        $duration = 'PT';
        if ($hours > 0) $duration .= $hours . 'H';
        if ($minutes > 0) $duration .= $minutes . 'M';
        if ($secs > 0 || ($hours === 0 && $minutes === 0)) $duration .= $secs . 'S';
        
        return $duration;
    }
    
    /**
     * Add lazy loading attribute to image tags
     */
    public static function addLazyLoading($html) {
        // Add loading="lazy" to all img tags that don't already have it
        $html = preg_replace('/<img(?![^>]*loading=)([^>]*)>/', '<img loading="lazy"$1>', $html);
        
        return $html;
    }
    
    /**
     * Create optimized image tag with lazy loading and alt text
     */
    public static function createImageTag($src, $alt = '', $attributes = []) {
        $attrs = [
            'src' => htmlspecialchars($src),
            'alt' => htmlspecialchars($alt),
            'loading' => 'lazy'
        ];
        
        // Merge with custom attributes
        $attrs = array_merge($attrs, $attributes);
        
        // Build attribute string
        $attrString = '';
        foreach ($attrs as $key => $value) {
            $attrString .= ' ' . htmlspecialchars($key) . '="' . htmlspecialchars($value) . '"';
        }
        
        return '<img' . $attrString . '>';
    }
    
    /**
     * Optimize images by adding width and height attributes
     */
    public static function optimizeImageDimensions($html) {
        // This would require image dimension detection
        // For now, we'll just ensure images have proper attributes
        return $html;
    }
    
    /**
     * Generate robots.txt content
     */
    public static function generateRobotsTxt() {
        $content = "# robots.txt for FezaMarket\n\n";
        $content .= "User-agent: *\n";
        $content .= "Allow: /\n";
        $content .= "Disallow: /admin/\n";
        $content .= "Disallow: /api/\n";
        $content .= "Disallow: /includes/\n";
        $content .= "Disallow: /cart.php\n";
        $content .= "Disallow: /checkout.php\n";
        $content .= "Disallow: /login.php\n";
        $content .= "Disallow: /register.php\n";
        $content .= "\n";
        $content .= "Sitemap: " . self::getAbsoluteUrl('/sitemap.xml') . "\n";
        
        return $content;
    }
}
