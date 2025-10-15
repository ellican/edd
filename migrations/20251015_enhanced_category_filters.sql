-- Migration: Enhanced Category Filters and Product Attributes
-- Date: 2025-10-15
-- Description: Adds comprehensive filtering system for category pages

-- =======================
-- 1. Product Attributes Table
-- =======================
CREATE TABLE IF NOT EXISTS `product_attributes` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `product_id` INT(11) NOT NULL,
  `attribute_name` VARCHAR(100) NOT NULL,
  `attribute_value` VARCHAR(255) NOT NULL,
  `attribute_type` ENUM('text', 'number', 'boolean', 'date') DEFAULT 'text',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_attribute_name` (`attribute_name`),
  KEY `idx_attribute_value` (`attribute_value`),
  CONSTRAINT `fk_product_attr_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================
-- 2. Brands Table
-- =======================
CREATE TABLE IF NOT EXISTS `brands` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT NULL,
  `logo_url` VARCHAR(500) NULL,
  `is_featured` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_name` (`name`),
  KEY `idx_slug` (`slug`),
  KEY `idx_is_featured` (`is_featured`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================
-- 3. Add brand_id to products table
-- =======================
ALTER TABLE `products`
ADD COLUMN IF NOT EXISTS `brand_id` INT(11) NULL COMMENT 'Reference to brands table',
ADD COLUMN IF NOT EXISTS `rating_avg` DECIMAL(3,2) DEFAULT 0.0 COMMENT 'Average rating (0-5)',
ADD COLUMN IF NOT EXISTS `rating_count` INT(11) DEFAULT 0 COMMENT 'Number of ratings',
ADD COLUMN IF NOT EXISTS `availability_status` ENUM('in_stock', 'out_of_stock', 'pre_order', 'discontinued') DEFAULT 'in_stock',
ADD COLUMN IF NOT EXISTS `discount_percentage` DECIMAL(5,2) DEFAULT 0.0 COMMENT 'Discount percentage',
ADD COLUMN IF NOT EXISTS `is_new_arrival` BOOLEAN DEFAULT FALSE COMMENT 'New arrival flag',
ADD COLUMN IF NOT EXISTS `is_featured` BOOLEAN DEFAULT FALSE COMMENT 'Featured product flag',
ADD COLUMN IF NOT EXISTS `is_on_sale` BOOLEAN DEFAULT FALSE COMMENT 'On sale flag',
ADD COLUMN IF NOT EXISTS `weight` DECIMAL(10,2) NULL COMMENT 'Product weight in kg',
ADD COLUMN IF NOT EXISTS `dimensions` VARCHAR(100) NULL COMMENT 'Product dimensions (LxWxH)',
ADD COLUMN IF NOT EXISTS `material` VARCHAR(100) NULL COMMENT 'Product material',
ADD COLUMN IF NOT EXISTS `color` VARCHAR(50) NULL COMMENT 'Product color',
ADD COLUMN IF NOT EXISTS `size` VARCHAR(50) NULL COMMENT 'Product size',
ADD COLUMN IF NOT EXISTS `country_of_origin` VARCHAR(100) NULL COMMENT 'Country where product is made',
ADD COLUMN IF NOT EXISTS `free_shipping` BOOLEAN DEFAULT FALSE COMMENT 'Free shipping flag',
ADD COLUMN IF NOT EXISTS `fast_delivery` BOOLEAN DEFAULT FALSE COMMENT 'Fast delivery available',
ADD COLUMN IF NOT EXISTS `return_policy_days` INT DEFAULT 7 COMMENT 'Return policy in days',
ADD INDEX IF NOT EXISTS `idx_brand_id` (`brand_id`),
ADD INDEX IF NOT EXISTS `idx_rating_avg` (`rating_avg`),
ADD INDEX IF NOT EXISTS `idx_availability` (`availability_status`),
ADD INDEX IF NOT EXISTS `idx_is_new_arrival` (`is_new_arrival`),
ADD INDEX IF NOT EXISTS `idx_is_featured` (`is_featured`),
ADD INDEX IF NOT EXISTS `idx_is_on_sale` (`is_on_sale`),
ADD INDEX IF NOT EXISTS `idx_free_shipping` (`free_shipping`);

-- =======================
-- 4. Product Reviews Table (if not exists)
-- =======================
CREATE TABLE IF NOT EXISTS `product_reviews` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `product_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `rating` INT NOT NULL CHECK (`rating` >= 1 AND `rating` <= 5),
  `title` VARCHAR(255) NULL,
  `review` TEXT NULL,
  `verified_purchase` BOOLEAN DEFAULT FALSE,
  `helpful_count` INT DEFAULT 0,
  `status` ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_rating` (`rating`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_review_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_review_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================
-- 5. Shipping Carriers Table
-- =======================
CREATE TABLE IF NOT EXISTS `shipping_carriers` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `code` VARCHAR(50) NOT NULL UNIQUE,
  `tracking_url_template` VARCHAR(500) NULL COMMENT 'URL template with {tracking_number} placeholder',
  `is_active` BOOLEAN DEFAULT TRUE,
  PRIMARY KEY (`id`),
  KEY `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================
-- 6. Insert common brands
-- =======================
INSERT INTO `brands` (`name`, `slug`, `is_featured`) VALUES
('Generic', 'generic', FALSE),
('FezaMarket', 'fezamarket', TRUE),
('Apple', 'apple', TRUE),
('Samsung', 'samsung', TRUE),
('Nike', 'nike', TRUE),
('Adidas', 'adidas', TRUE)
ON DUPLICATE KEY UPDATE name=name;

-- =======================
-- 7. Insert common shipping carriers
-- =======================
INSERT INTO `shipping_carriers` (`name`, `code`, `tracking_url_template`) VALUES
('DHL', 'dhl', 'https://www.dhl.com/en/express/tracking.html?AWB={tracking_number}'),
('FedEx', 'fedex', 'https://www.fedex.com/fedextrack/?trknbr={tracking_number}'),
('UPS', 'ups', 'https://www.ups.com/track?tracknum={tracking_number}'),
('USPS', 'usps', 'https://tools.usps.com/go/TrackConfirmAction?tLabels={tracking_number}'),
('Rwanda Post', 'rwanda-post', NULL)
ON DUPLICATE KEY UPDATE name=name;

-- =======================
-- 8. Update existing products with default values
-- =======================
UPDATE products 
SET availability_status = 'in_stock' 
WHERE availability_status IS NULL OR availability_status = '';

UPDATE products 
SET is_on_sale = TRUE 
WHERE price < price * 1.2;

UPDATE products 
SET is_new_arrival = TRUE 
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY);

-- =======================
-- 9. Trigger to update product rating average
-- =======================
DELIMITER //

DROP TRIGGER IF EXISTS `update_product_rating_avg`//

CREATE TRIGGER `update_product_rating_avg` 
AFTER INSERT ON `product_reviews`
FOR EACH ROW
BEGIN
    UPDATE products 
    SET 
        rating_avg = (SELECT AVG(rating) FROM product_reviews WHERE product_id = NEW.product_id AND status = 'approved'),
        rating_count = (SELECT COUNT(*) FROM product_reviews WHERE product_id = NEW.product_id AND status = 'approved')
    WHERE id = NEW.product_id;
END//

DELIMITER ;
