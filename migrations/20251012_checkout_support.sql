-- Migration: Add Checkout Support (Coupons & Gift Cards enhancements)
-- Date: 2025-10-12
-- Description: Creates coupons table and enhances gift cards for checkout flow

-- Create coupons table if not exists
CREATE TABLE IF NOT EXISTS `coupons` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Unique coupon code (e.g., SAVE20)',
  `type` ENUM('percentage', 'fixed') NOT NULL DEFAULT 'percentage' COMMENT 'Discount type',
  `value` DECIMAL(10,2) NOT NULL COMMENT 'Discount value (% or fixed amount)',
  `minimum_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Minimum order amount to apply',
  `maximum_discount` DECIMAL(10,2) DEFAULT NULL COMMENT 'Maximum discount cap for percentage',
  `status` ENUM('active', 'inactive', 'expired') NOT NULL DEFAULT 'active',
  `usage_limit` INT DEFAULT NULL COMMENT 'Maximum number of uses (NULL = unlimited)',
  `usage_count` INT NOT NULL DEFAULT 0 COMMENT 'Number of times used',
  `valid_from` TIMESTAMP NULL DEFAULT NULL COMMENT 'Coupon valid from date',
  `valid_to` TIMESTAMP NULL DEFAULT NULL COMMENT 'Coupon expiration date',
  `description` TEXT NULL COMMENT 'Internal description',
  `created_by` INT NULL COMMENT 'Admin user who created it',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_code` (`code`),
  INDEX `idx_status` (`status`),
  INDEX `idx_valid_dates` (`valid_from`, `valid_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create coupon_usage table to track usage per user
CREATE TABLE IF NOT EXISTS `coupon_usage` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `coupon_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `order_id` INT NOT NULL,
  `discount_amount` DECIMAL(10,2) NOT NULL,
  `used_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_coupon_id` (`coupon_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_order_id` (`order_id`),
  FOREIGN KEY (`coupon_id`) REFERENCES `coupons`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add amount_used column to gift_cards if not exists
ALTER TABLE `gift_cards` 
ADD COLUMN IF NOT EXISTS `amount_used` DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Amount already used' AFTER `balance`,
ADD COLUMN IF NOT EXISTS `redeemed_by` INT NULL COMMENT 'User ID who redeemed' AFTER `status`;

-- Update gift_cards to have balance = amount - amount_used for existing records
UPDATE `gift_cards` SET `amount_used` = `amount` - `balance` WHERE `amount_used` = 0;

-- Add index for redeemed_by
ALTER TABLE `gift_cards` ADD INDEX IF NOT EXISTS `idx_redeemed_by` (`redeemed_by`);

-- Create shipping_methods table if not exists
CREATE TABLE IF NOT EXISTS `shipping_methods` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL COMMENT 'e.g., Standard Shipping',
  `code` VARCHAR(50) NOT NULL UNIQUE COMMENT 'e.g., standard, express, overnight',
  `description` TEXT NULL,
  `base_cost` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `free_shipping_threshold` DECIMAL(10,2) DEFAULT NULL COMMENT 'Free if order >= this amount',
  `delivery_days_min` INT DEFAULT NULL COMMENT 'Minimum delivery days',
  `delivery_days_max` INT DEFAULT NULL COMMENT 'Maximum delivery days',
  `status` ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_code` (`code`),
  INDEX `idx_status` (`status`),
  INDEX `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default shipping methods
INSERT IGNORE INTO `shipping_methods` (`name`, `code`, `description`, `base_cost`, `free_shipping_threshold`, `delivery_days_min`, `delivery_days_max`, `sort_order`) VALUES
('Standard Shipping', 'standard', 'Delivery in 5-7 business days', 5.99, 50.00, 5, 7, 1),
('Express Shipping', 'express', 'Faster delivery in 2-3 business days', 12.99, NULL, 2, 3, 2),
('Overnight Shipping', 'overnight', 'Next business day delivery', 24.99, NULL, 1, 1, 3);

-- Add shipping_method to orders if not exists
ALTER TABLE `orders`
ADD COLUMN IF NOT EXISTS `shipping_method` VARCHAR(100) NULL AFTER `shipping_address`,
ADD COLUMN IF NOT EXISTS `coupon_id` INT NULL COMMENT 'Applied coupon ID' AFTER `discount_amount`,
ADD COLUMN IF NOT EXISTS `coupon_code` VARCHAR(50) NULL COMMENT 'Applied coupon code' AFTER `coupon_id`,
ADD COLUMN IF NOT EXISTS `gift_card_id` INT NULL COMMENT 'Applied gift card ID' AFTER `coupon_code`,
ADD COLUMN IF NOT EXISTS `gift_card_code` VARCHAR(50) NULL COMMENT 'Applied gift card code' AFTER `gift_card_id`,
ADD COLUMN IF NOT EXISTS `gift_card_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Gift card amount applied' AFTER `gift_card_code`;

-- Add indexes for new order columns
ALTER TABLE `orders` 
ADD INDEX IF NOT EXISTS `idx_coupon_id` (`coupon_id`),
ADD INDEX IF NOT EXISTS `idx_gift_card_id` (`gift_card_id`);
