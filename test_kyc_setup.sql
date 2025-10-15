-- Minimal database setup for KYC testing
-- This creates just the essential tables needed for KYC functionality testing

-- Create users table
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'customer',
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create vendors table
CREATE TABLE IF NOT EXISTS `vendors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `business_name` varchar(100) DEFAULT NULL,
  `business_email` varchar(100) DEFAULT NULL,
  `business_phone` varchar(20) DEFAULT NULL,
  `status` enum('pending','approved','active','suspended') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `fk_vendor_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create KYC documents table
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
  KEY `idx_reviewed_by` (`reviewed_by`),
  CONSTRAINT `fk_kyc_doc_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create KYC verifications table
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
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_kyc_verification_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert test data
INSERT IGNORE INTO `users` (`id`, `username`, `email`, `password`, `first_name`, `last_name`, `role`, `status`) VALUES
(1, 'admin', 'admin@example.com', '$2y$12$test', 'Admin', 'User', 'admin', 'active'),
(2, 'seller1', 'seller1@example.com', '$2y$12$test', 'John', 'Seller', 'seller', 'active'),
(3, 'seller2', 'seller2@example.com', '$2y$12$test', 'Jane', 'Vendor', 'seller', 'active'),
(4, 'customer', 'customer@example.com', '$2y$12$test', 'Regular', 'Customer', 'customer', 'active');

INSERT IGNORE INTO `vendors` (`id`, `user_id`, `business_name`, `status`) VALUES
(1, 2, 'John\'s Store', 'approved'),
(2, 3, 'Jane\'s Shop', 'pending');

INSERT IGNORE INTO `kyc_documents` (`user_id`, `document_type`, `file_path`, `file_name`, `file_size`, `mime_type`, `status`) VALUES
(2, 'id_card', '/uploads/kyc/2/id.jpg', 'id.jpg', 123456, 'image/jpeg', 'approved'),
(3, 'id_card', '/uploads/kyc/3/id.jpg', 'id.jpg', 123456, 'image/jpeg', 'pending');

INSERT IGNORE INTO `kyc_verifications` (`user_id`, `status`, `verification_level`) VALUES
(2, 'approved', 'standard'),
(3, 'pending', 'basic');
