-- Migration: Order Tracking Enhancements
-- Date: 2025-10-15
-- Description: Adds order tracking features and status history

-- =======================
-- 1. Order Tracking Updates Table
-- =======================
CREATE TABLE IF NOT EXISTS `order_tracking_updates` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `order_id` INT(11) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `location` VARCHAR(255) NULL,
  `description` TEXT NULL,
  `updated_by` INT(11) NULL COMMENT 'Admin/seller user who updated',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_tracking_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================
-- 2. Add tracking fields to orders table
-- =======================
ALTER TABLE `orders`
ADD COLUMN IF NOT EXISTS `tracking_number` VARCHAR(100) NULL COMMENT 'Shipping tracking number',
ADD COLUMN IF NOT EXISTS `tracking_url` VARCHAR(500) NULL COMMENT 'Tracking URL from carrier',
ADD COLUMN IF NOT EXISTS `carrier` VARCHAR(100) NULL COMMENT 'Shipping carrier name',
ADD COLUMN IF NOT EXISTS `estimated_delivery` DATE NULL COMMENT 'Estimated delivery date',
ADD INDEX IF NOT EXISTS `idx_tracking_number` (`tracking_number`);

-- =======================
-- 3. Add status history trigger
-- =======================
-- This trigger automatically logs status changes to tracking_updates table
DELIMITER //

DROP TRIGGER IF EXISTS `orders_status_change_trigger`//

CREATE TRIGGER `orders_status_change_trigger` 
AFTER UPDATE ON `orders`
FOR EACH ROW
BEGIN
    IF NEW.status != OLD.status THEN
        INSERT INTO order_tracking_updates (order_id, status, description, created_at)
        VALUES (NEW.id, NEW.status, CONCAT('Order status changed from ', OLD.status, ' to ', NEW.status), NOW());
    END IF;
END//

DELIMITER ;

-- =======================
-- 4. Insert initial tracking records for existing orders
-- =======================
INSERT INTO order_tracking_updates (order_id, status, description, created_at)
SELECT 
    id, 
    status, 
    CONCAT('Order ', status), 
    created_at
FROM orders
WHERE id NOT IN (SELECT DISTINCT order_id FROM order_tracking_updates)
ON DUPLICATE KEY UPDATE id=id;

-- =======================
-- 5. Support tickets table (if not exists)
-- =======================
CREATE TABLE IF NOT EXISTS `support_tickets` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `ticket_number` VARCHAR(50) NOT NULL UNIQUE,
  `user_id` INT(11) NOT NULL,
  `subject` VARCHAR(255) NOT NULL,
  `category` VARCHAR(50) NOT NULL DEFAULT 'general',
  `priority` ENUM('low', 'medium', 'high', 'urgent') NOT NULL DEFAULT 'medium',
  `status` ENUM('open', 'in_progress', 'waiting', 'resolved', 'closed') NOT NULL DEFAULT 'open',
  `assigned_to` INT(11) NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `resolved_at` TIMESTAMP NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_ticket_number` (`ticket_number`),
  KEY `idx_status` (`status`),
  KEY `idx_assigned_to` (`assigned_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================
-- 6. Support ticket messages table
-- =======================
CREATE TABLE IF NOT EXISTS `support_ticket_messages` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `ticket_id` INT(11) NOT NULL,
  `user_id` INT(11) NOT NULL,
  `message` TEXT NOT NULL,
  `is_staff_reply` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_id` (`ticket_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_ticket_message_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================
-- 7. Live chat tables
-- =======================
CREATE TABLE IF NOT EXISTS `chats` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NULL,
  `name` VARCHAR(100) NULL COMMENT 'Guest name if not logged in',
  `email` VARCHAR(255) NULL COMMENT 'Guest email if not logged in',
  `type` ENUM('support', 'sales', 'general') NOT NULL DEFAULT 'support',
  `status` ENUM('active', 'waiting', 'closed') NOT NULL DEFAULT 'active',
  `assigned_agent_id` INT(11) NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `closed_at` TIMESTAMP NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_assigned_agent` (`assigned_agent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `chat_messages` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `chat_id` INT(11) NOT NULL,
  `sender` ENUM('user', 'agent', 'system') NOT NULL,
  `sender_id` INT(11) NULL COMMENT 'User or agent ID',
  `message` TEXT NOT NULL,
  `is_read` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_chat_id` (`chat_id`),
  KEY `idx_sender_id` (`sender_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_chat_message_chat` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================
-- 8. Agent presence table for live chat
-- =======================
CREATE TABLE IF NOT EXISTS `agent_presence` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `agent_id` INT(11) NOT NULL,
  `status` ENUM('online', 'away', 'offline') NOT NULL DEFAULT 'offline',
  `last_seen` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_agent` (`agent_id`),
  KEY `idx_status` (`status`),
  KEY `idx_last_seen` (`last_seen`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
