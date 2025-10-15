<?php
/**
 * Comprehensive Platform Fixes Migration
 * Date: 2025-10-14
 * 
 * This migration addresses:
 * 1. Ensures webhook_deliveries table has webhook_id column
 * 2. Ensures order amount columns exist and are properly set
 * 3. Ensures KYC tables exist with proper structure
 * 4. Ensures shipping_carriers table exists with API fields
 * 5. Adds any missing indexes for performance
 */

function up_2025_10_14_comprehensive_fixes($pdo) {
    try {
        echo "Running comprehensive platform fixes migration...\n";
        
        // 1. Ensure webhook_deliveries table exists with webhook_id
        echo "Checking webhook_deliveries table...\n";
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS `webhook_deliveries` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
              `webhook_id` int(11) NOT NULL,
              `integration_id` int(11) DEFAULT NULL,
              `webhook_url` varchar(500) NOT NULL,
              `event_type` varchar(100) NOT NULL,
              `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
              `response_status` int(11) DEFAULT NULL,
              `response_headers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
              `response_body` longtext DEFAULT NULL,
              `delivery_attempts` int(11) NOT NULL DEFAULT 1,
              `last_attempt` timestamp NOT NULL DEFAULT current_timestamp(),
              `next_attempt` timestamp NULL DEFAULT NULL,
              `status` enum('pending','delivered','failed','abandoned') NOT NULL DEFAULT 'pending',
              `success` tinyint(1) DEFAULT 0,
              `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
              PRIMARY KEY (`id`),
              KEY `idx_webhook_id` (`webhook_id`),
              KEY `idx_webhook_integration` (`integration_id`),
              KEY `idx_webhook_status` (`status`),
              KEY `idx_webhook_event` (`event_type`),
              KEY `idx_webhook_next_attempt` (`next_attempt`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ");
        
        // Check if webhook_id column exists, add if missing
        $result = $pdo->query("
            SELECT COUNT(*) as count 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = DATABASE() 
            AND TABLE_NAME = 'webhook_deliveries' 
            AND COLUMN_NAME = 'webhook_id'
        ")->fetch();
        
        if ($result['count'] == 0) {
            echo "Adding webhook_id column to webhook_deliveries...\n";
            $pdo->exec("ALTER TABLE webhook_deliveries ADD COLUMN webhook_id INT(11) NOT NULL AFTER id");
            $pdo->exec("ALTER TABLE webhook_deliveries ADD KEY idx_webhook_id (webhook_id)");
        }
        
        // 2. Ensure orders table has amount columns
        echo "Checking orders table amount columns...\n";
        $orderColumns = [
            'subtotal_amount' => "DECIMAL(10,2) DEFAULT 0.00",
            'tax_amount' => "DECIMAL(10,2) DEFAULT 0.00",
            'shipping_amount' => "DECIMAL(10,2) DEFAULT 0.00",
            'discount_amount' => "DECIMAL(10,2) DEFAULT 0.00",
            'total_amount' => "DECIMAL(10,2) DEFAULT 0.00"
        ];
        
        foreach ($orderColumns as $column => $definition) {
            $result = $pdo->query("
                SELECT COUNT(*) as count 
                FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_SCHEMA = DATABASE() 
                AND TABLE_NAME = 'orders' 
                AND COLUMN_NAME = '$column'
            ")->fetch();
            
            if ($result['count'] == 0) {
                echo "Adding $column to orders table...\n";
                $pdo->exec("ALTER TABLE orders ADD COLUMN $column $definition");
            }
        }
        
        // 3. Ensure KYC tables exist
        echo "Checking KYC tables...\n";
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS `kyc_documents` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
              `user_id` int(11) NOT NULL,
              `document_type` enum('id_card','passport','drivers_license','proof_of_address','business_registration','tax_certificate') NOT NULL,
              `document_number` varchar(100) DEFAULT NULL,
              `file_path` varchar(500) NOT NULL,
              `file_name` varchar(255) NOT NULL,
              `file_size` int(11) NOT NULL,
              `mime_type` varchar(100) NOT NULL,
              `status` enum('pending','approved','rejected','expired') NOT NULL DEFAULT 'pending',
              `rejection_reason` text DEFAULT NULL,
              `reviewed_by` int(11) DEFAULT NULL,
              `reviewed_at` timestamp NULL DEFAULT NULL,
              `review_notes` text DEFAULT NULL,
              `expiry_date` date DEFAULT NULL,
              `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
              `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
              PRIMARY KEY (`id`),
              KEY `idx_user_id` (`user_id`),
              KEY `idx_status` (`status`),
              KEY `idx_document_type` (`document_type`),
              KEY `idx_reviewed_by` (`reviewed_by`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ");
        
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS `kyc_verifications` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
              `user_id` int(11) NOT NULL,
              `status` enum('pending','approved','rejected','under_review') NOT NULL DEFAULT 'pending',
              `verification_level` enum('basic','standard','enhanced') DEFAULT 'basic',
              `verified_by` int(11) DEFAULT NULL,
              `verified_at` timestamp NULL DEFAULT NULL,
              `notes` text DEFAULT NULL,
              `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
              `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
              PRIMARY KEY (`id`),
              UNIQUE KEY `user_id` (`user_id`),
              KEY `idx_status` (`status`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ");
        
        // 4. Ensure shipping_carriers table exists with API fields
        echo "Checking shipping_carriers table...\n";
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS `shipping_carriers` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
              `name` varchar(100) NOT NULL,
              `code` varchar(50) NOT NULL,
              `tracking_url` varchar(500) DEFAULT NULL,
              `api_url` varchar(500) DEFAULT NULL,
              `api_key` varchar(255) DEFAULT NULL,
              `api_secret` varchar(255) DEFAULT NULL,
              `webhook_url` varchar(500) DEFAULT NULL,
              `is_active` tinyint(1) NOT NULL DEFAULT 1,
              `supports_live_rates` tinyint(1) NOT NULL DEFAULT 0,
              `enabled_for_sellers` tinyint(1) NOT NULL DEFAULT 0,
              `sort_order` int(11) DEFAULT 0,
              `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
              `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
              PRIMARY KEY (`id`),
              UNIQUE KEY `code` (`code`),
              KEY `idx_is_active` (`is_active`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ");
        
        // Add API fields to shipping_carriers if they don't exist
        $carrierApiFields = [
            'api_url' => "VARCHAR(500) DEFAULT NULL",
            'api_key' => "VARCHAR(255) DEFAULT NULL",
            'api_secret' => "VARCHAR(255) DEFAULT NULL",
            'webhook_url' => "VARCHAR(500) DEFAULT NULL",
            'enabled_for_sellers' => "TINYINT(1) NOT NULL DEFAULT 0"
        ];
        
        foreach ($carrierApiFields as $column => $definition) {
            $result = $pdo->query("
                SELECT COUNT(*) as count 
                FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_SCHEMA = DATABASE() 
                AND TABLE_NAME = 'shipping_carriers' 
                AND COLUMN_NAME = '$column'
            ")->fetch();
            
            if ($result['count'] == 0) {
                echo "Adding $column to shipping_carriers table...\n";
                $pdo->exec("ALTER TABLE shipping_carriers ADD COLUMN $column $definition");
            }
        }
        
        // 5. Ensure roles and permissions tables exist
        echo "Checking roles and permissions tables...\n";
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS `roles` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
              `name` varchar(50) NOT NULL,
              `slug` varchar(50) NOT NULL,
              `description` text DEFAULT NULL,
              `level` int(11) NOT NULL DEFAULT 0,
              `is_system` tinyint(1) NOT NULL DEFAULT 0,
              `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
              `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
              PRIMARY KEY (`id`),
              UNIQUE KEY `slug` (`slug`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ");
        
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS `permissions` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
              `name` varchar(100) NOT NULL,
              `slug` varchar(100) NOT NULL,
              `module` varchar(50) NOT NULL,
              `description` text DEFAULT NULL,
              `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
              PRIMARY KEY (`id`),
              UNIQUE KEY `slug` (`slug`),
              KEY `idx_module` (`module`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ");
        
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS `role_permissions` (
              `id` int(11) NOT NULL AUTO_INCREMENT,
              `role_id` int(11) NOT NULL,
              `permission_id` int(11) NOT NULL,
              `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
              PRIMARY KEY (`id`),
              UNIQUE KEY `role_permission` (`role_id`,`permission_id`),
              KEY `idx_role_id` (`role_id`),
              KEY `idx_permission_id` (`permission_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
        ");
        
        echo "Comprehensive platform fixes migration completed successfully!\n";
        return true;
        
    } catch (Exception $e) {
        echo "Error in migration: " . $e->getMessage() . "\n";
        return false;
    }
}

function down_2025_10_14_comprehensive_fixes($pdo) {
    // This migration is additive only and doesn't remove existing data
    // Rollback is intentionally not implemented to prevent data loss
    echo "Rollback not implemented for safety - this migration only adds missing columns/tables\n";
    return true;
}
