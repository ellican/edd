/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.13-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: ecommerce_platform
-- ------------------------------------------------------
-- Server version	10.11.13-MariaDB-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_closure_requests`
--

DROP TABLE IF EXISTS `account_closure_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_closure_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `reason` text DEFAULT NULL,
  `additional_comments` text DEFAULT NULL,
  `status` enum('pending','approved','rejected','completed') NOT NULL DEFAULT 'pending',
  `processed_by` int(11) DEFAULT NULL,
  `processed_at` timestamp NULL DEFAULT NULL,
  `admin_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_closure_request_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_closure_requests`
--

LOCK TABLES `account_closure_requests` WRITE;
/*!40000 ALTER TABLE `account_closure_requests` DISABLE KEYS */;
INSERT INTO `account_closure_requests` VALUES
(1,4,'Privacy concerns','','pending',NULL,NULL,NULL,'2025-10-07 08:17:25','2025-10-07 08:17:25');
/*!40000 ALTER TABLE `account_closure_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_feed`
--

DROP TABLE IF EXISTS `activity_feed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_feed` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `actor_id` int(11) DEFAULT NULL,
  `actor_type` enum('user','system','admin') NOT NULL DEFAULT 'user',
  `action` varchar(255) NOT NULL,
  `target_type` varchar(100) DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `description` text NOT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_actor_id` (`actor_id`),
  KEY `idx_actor_type` (`actor_type`),
  KEY `idx_action` (`action`),
  KEY `idx_target` (`target_type`,`target_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_activity_feed_actor_action` (`actor_id`,`action`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_feed`
--

LOCK TABLES `activity_feed` WRITE;
/*!40000 ALTER TABLE `activity_feed` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_feed` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` enum('billing','shipping','both') NOT NULL DEFAULT 'both',
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `company` varchar(100) DEFAULT NULL,
  `address_line1` varchar(255) NOT NULL,
  `address_line2` varchar(255) DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `country` varchar(2) NOT NULL DEFAULT 'US',
  `phone` varchar(20) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_is_default` (`is_default`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` VALUES
(1,4,'both','JOSEPH','NIYOGUSHIMWA','','KIGALI','RWANDA','KIGALI','KIGALI','0000','RW','+250 788827138',1,'2025-10-03 21:12:15','2025-10-12 23:13:21');
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_actions`
--

DROP TABLE IF EXISTS `admin_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `action` varchar(255) NOT NULL,
  `target_type` varchar(50) NOT NULL,
  `target_id` int(11) DEFAULT NULL,
  `old_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_data`)),
  `new_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_data`)),
  `notes` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_target` (`target_type`,`target_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_actions`
--

LOCK TABLES `admin_actions` WRITE;
/*!40000 ALTER TABLE `admin_actions` DISABLE KEYS */;
INSERT INTO `admin_actions` VALUES
(1,1,'update','category',1,NULL,'{\"name\":\"Electronics\",\"parent_id\":null,\"slug\":\"electronics\",\"is_active\":1}','',NULL,'2025-09-14 20:04:01'),
(2,4,'audit_logs_cleaned','system',NULL,NULL,'{\"retention_days\":365,\"deleted_count\":0}','Cleaned old audit logs (retention: 365 days)',NULL,'2025-10-15 19:32:08');
/*!40000 ALTER TABLE `admin_actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_activity_logs`
--

DROP TABLE IF EXISTS `admin_activity_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_activity_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `action` varchar(100) NOT NULL,
  `resource_type` varchar(50) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_action` (`action`),
  KEY `idx_resource_type` (`resource_type`),
  KEY `idx_resource_id` (`resource_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_admin_activity_logs_admin` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_activity_logs`
--

LOCK TABLES `admin_activity_logs` WRITE;
/*!40000 ALTER TABLE `admin_activity_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_analytics`
--

DROP TABLE IF EXISTS `admin_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_analytics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `metric_name` varchar(100) NOT NULL,
  `metric_value` decimal(15,2) NOT NULL DEFAULT 0.00,
  `metric_type` enum('sales','revenue','orders','users','products','views','clicks') NOT NULL,
  `period_type` enum('daily','weekly','monthly','yearly') NOT NULL DEFAULT 'daily',
  `date_recorded` date NOT NULL,
  `additional_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`additional_data`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_metric_period_date` (`metric_name`,`period_type`,`date_recorded`),
  KEY `idx_metric_type` (`metric_type`),
  KEY `idx_period_type` (`period_type`),
  KEY `idx_date_recorded` (`date_recorded`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_analytics`
--

LOCK TABLES `admin_analytics` WRITE;
/*!40000 ALTER TABLE `admin_analytics` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_dashboards`
--

DROP TABLE IF EXISTS `admin_dashboards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_dashboards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `layout_config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`layout_config`)),
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `is_shared` tinyint(1) NOT NULL DEFAULT 0,
  `shared_with` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`shared_with`)),
  `refresh_interval` int(11) NOT NULL DEFAULT 300,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_default` (`is_default`),
  KEY `idx_is_shared` (`is_shared`),
  CONSTRAINT `fk_admin_dashboards_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_dashboards`
--

LOCK TABLES `admin_dashboards` WRITE;
/*!40000 ALTER TABLE `admin_dashboards` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_dashboards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_roles`
--

DROP TABLE IF EXISTS `admin_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`permissions`)),
  `is_system_role` tinyint(1) NOT NULL DEFAULT 0,
  `hierarchy_level` int(11) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_slug` (`slug`),
  KEY `idx_name` (`name`),
  KEY `idx_is_system_role` (`is_system_role`),
  KEY `idx_hierarchy_level` (`hierarchy_level`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_admin_roles_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_roles`
--

LOCK TABLES `admin_roles` WRITE;
/*!40000 ALTER TABLE `admin_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_widgets`
--

DROP TABLE IF EXISTS `admin_widgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_widgets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dashboard_id` int(11) NOT NULL,
  `widget_type` enum('chart','table','counter','progress','list','map','calendar','custom') NOT NULL,
  `widget_name` varchar(255) NOT NULL,
  `data_source` varchar(255) NOT NULL,
  `configuration` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`configuration`)),
  `position_x` int(11) NOT NULL DEFAULT 0,
  `position_y` int(11) NOT NULL DEFAULT 0,
  `width` int(11) NOT NULL DEFAULT 6,
  `height` int(11) NOT NULL DEFAULT 4,
  `refresh_interval` int(11) NOT NULL DEFAULT 300,
  `is_visible` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dashboard_id` (`dashboard_id`),
  KEY `idx_widget_type` (`widget_type`),
  KEY `idx_is_visible` (`is_visible`),
  CONSTRAINT `fk_admin_widgets_dashboard` FOREIGN KEY (`dashboard_id`) REFERENCES `admin_dashboards` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_widgets`
--

LOCK TABLES `admin_widgets` WRITE;
/*!40000 ALTER TABLE `admin_widgets` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_widgets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_presence`
--

DROP TABLE IF EXISTS `agent_presence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `agent_presence` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_id` int(11) NOT NULL,
  `status` enum('online','away','busy','offline') DEFAULT 'offline',
  `last_seen` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `current_chats` int(11) DEFAULT 0,
  `max_chats` int(11) DEFAULT 5,
  PRIMARY KEY (`id`),
  UNIQUE KEY `agent_id` (`agent_id`),
  KEY `idx_status` (`status`),
  KEY `idx_last_seen` (`last_seen`),
  CONSTRAINT `agent_presence_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_presence`
--

LOCK TABLES `agent_presence` WRITE;
/*!40000 ALTER TABLE `agent_presence` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_presence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_interactions`
--

DROP TABLE IF EXISTS `ai_interactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_interactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `session_id` varchar(100) NOT NULL,
  `chat_id` int(11) DEFAULT NULL,
  `prompt` text NOT NULL,
  `response` text DEFAULT NULL,
  `provider` varchar(50) DEFAULT 'openai',
  `model` varchar(50) DEFAULT 'gpt-3.5-turbo',
  `tokens_used` int(11) DEFAULT 0,
  `response_time_ms` int(11) DEFAULT 0,
  `error` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_chat_id` (`chat_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `ai_interactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `ai_interactions_ibfk_2` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_interactions`
--

LOCK TABLES `ai_interactions` WRITE;
/*!40000 ALTER TABLE `ai_interactions` DISABLE KEYS */;
INSERT INTO `ai_interactions` VALUES
(1,4,'session_1759827252543_kl7fw0g27',NULL,'hi','I\'m here to help! I can assist you with:\n\n• Order tracking and status\n• Returns and refunds\n• Product information\n• Account and payment issues\n• Shipping details\n\nWhat would you like to know more about? Or I can connect you with our support team for personalized assistance.','fallback','faq',0,0,NULL,'2025-10-07 08:54:16'),
(2,4,'session_1759827252543_kl7fw0g27',NULL,'I need assistant','I\'m here to help! I can assist you with:\n\n• Order tracking and status\n• Returns and refunds\n• Product information\n• Account and payment issues\n• Shipping details\n\nWhat would you like to know more about? Or I can connect you with our support team for personalized assistance.','fallback','faq',0,0,NULL,'2025-10-07 08:54:35'),
(3,4,'session_1759827364949_q76q17em1',NULL,'How do I contact support?','I\'d be happy to connect you with our support team! You can reach them via email at support@fezamarket.com or use our live chat during business hours (Mon-Fri, 9AM-6PM). Would you like me to start a support chat for you?','fallback','faq',0,0,NULL,'2025-10-07 08:56:24'),
(4,4,'session_1759827772741_qjmykk083',NULL,'What is your return policy?','We have a 30-day return policy for most items. To initiate a return, go to your Order History, select the order, and click \'Request Return\'. You\'ll receive a prepaid shipping label. Refunds are processed within 5-7 business days after we receive your return.','fallback','faq',0,0,NULL,'2025-10-07 09:02:56'),
(5,NULL,'session_1759827896837_nk5acja9z',NULL,'How do I track my order?','We offer multiple shipping options! You can track your order from your account dashboard. Standard shipping takes 5-7 business days, while express shipping arrives in 2-3 days. For tracking help, visit your Orders page or contact our support team.','fallback','faq',0,0,NULL,'2025-10-07 09:05:01'),
(6,4,'session_1759848591071_vm520yzan',NULL,'How do I contact support?','I\'d be happy to connect you with our support team! You can reach them via email at support@fezamarket.com or use our live chat during business hours (Mon-Fri, 9AM-6PM). Would you like me to start a support chat for you?','fallback','faq',0,0,NULL,'2025-10-07 14:49:52'),
(7,NULL,'session_1759853810627_fgzx6p74c',NULL,'can I get a shoes','I\'m Feza AI, your shopping assistant! I can help you with:\n\n• Order tracking and status\n• Returns and refunds\n• Product information and availability\n• Account and payment issues\n• Shipping details\n• Making offers on products\n• Wishlist and watchlist features\n• Current deals and promotions\n\nWhat would you like to know more about? Or I can connect you with our support team for personalized assistance.','fallback','faq',0,0,NULL,'2025-10-07 16:17:36'),
(8,NULL,'session_1759853810627_fgzx6p74c',NULL,'Can I get a shoes','I\'m Feza AI, your shopping assistant! I can help you with:\n\n• Order tracking and status\n• Returns and refunds\n• Product information and availability\n• Account and payment issues\n• Shipping details\n• Making offers on products\n• Wishlist and watchlist features\n• Current deals and promotions\n\nWhat would you like to know more about? Or I can connect you with our support team for personalized assistance.','fallback','faq',0,0,NULL,'2025-10-07 16:18:11'),
(9,NULL,'session_1759853810627_fgzx6p74c',NULL,'delivery','We offer multiple shipping options! You can track your order from your account dashboard. Standard shipping takes 5-7 business days, while express shipping arrives in 2-3 days. For tracking help, visit your Orders page or contact our support team.','fallback','faq',0,0,NULL,'2025-10-07 16:18:29'),
(10,NULL,'session_1759853810627_fgzx6p74c',NULL,'how can I get my account','Having trouble with your account? You can reset your password from the login page. If you haven\'t verified your email yet, check your inbox for the verification link. For other account issues, please contact our support team.','fallback','faq',0,0,NULL,'2025-10-07 16:19:54'),
(11,4,'session_1759863734500_boompiw0l',NULL,'How do I contact support?','I\'d be happy to connect you with our support team! You can reach them via email at support@fezamarket.com or use our live chat during business hours (Mon-Fri, 9AM-6PM). Would you like me to start a support chat for you?','fallback','faq',0,0,NULL,'2025-10-07 19:02:16'),
(12,4,'session_1759864588280_ikmxygs9f',NULL,'How do I contact support?','I\'d be happy to connect you with our support team! You can reach them via email at support@fezamarket.com or use our live chat during business hours (Mon-Fri, 9AM-6PM). Would you like me to start a support chat for you?','fallback','faq',0,0,NULL,'2025-10-07 19:16:34'),
(13,NULL,'session_1759873168241_66dsvmslk',NULL,'How do I track my order?','We offer multiple shipping options! You can track your order from your account dashboard. Standard shipping takes 5-7 business days, while express shipping arrives in 2-3 days. For tracking help, visit your Orders page or contact our support team.','fallback','faq',0,0,NULL,'2025-10-07 21:39:34'),
(14,4,'session_1759907251258_20w0eoka5',NULL,'What is your return policy?','We have a 30-day return policy for most items. To initiate a return, go to your Order History, select the order, and click \'Request Return\'. You\'ll receive a prepaid shipping label. Refunds are processed within 5-7 business days after we receive your return.','fallback','faq',0,0,NULL,'2025-10-08 07:07:34'),
(15,NULL,'session_1759955927279_hygxbm7bl',NULL,'Kemie','I\'m Feza AI, your shopping assistant! I can help you with:\n\n• Order tracking and status\n• Returns and refunds\n• Product information and availability\n• Account and payment issues\n• Shipping details\n• Making offers on products\n• Wishlist and watchlist features\n• Current deals and promotions\n\nWhat would you like to know more about? Or I can connect you with our support team for personalized assistance.','fallback','faq',0,0,NULL,'2025-10-08 20:39:17'),
(16,4,'session_1760023336420_jp6ri9fwx',NULL,'What is your return policy?','We have a 30-day return policy for most items. To initiate a return, go to your Order History, select the order, and click \'Request Return\'. You\'ll receive a prepaid shipping label. Refunds are processed within 5-7 business days after we receive your return.','fallback','faq',0,0,NULL,'2025-10-09 15:22:18'),
(17,4,'session_1760037085069_j27wt7fb4',NULL,'How do I track my order?','We offer multiple shipping options! You can track your order from your account dashboard. Standard shipping takes 5-7 business days, while express shipping arrives in 2-3 days. For tracking help, visit your Orders page or contact our support team.','fallback','faq',0,0,NULL,'2025-10-09 19:11:29'),
(18,4,'session_1760050522653_dqbql6ul0',NULL,'hi','Hi there 👋! Welcome to FezaMarket. How can I help you today?','fallback','faq',0,5,NULL,'2025-10-09 22:55:33'),
(19,4,'session_1760050522653_dqbql6ul0',NULL,'i need help','I\\\'m here to help! What do you need assistance with?','fallback','faq',0,0,NULL,'2025-10-09 22:55:43'),
(20,4,'session_1760050522653_dqbql6ul0',NULL,'shipping','Standard shipping takes 2-5 business days. Express shipping arrives in 1-2 days. Delivery times depend on your location.','fallback','faq',0,0,NULL,'2025-10-09 22:56:00'),
(21,4,'session_1760050522653_dqbql6ul0',NULL,'thanks','You\'re welcome! 😊 Is there anything else I can help you with?','fallback','faq',0,0,NULL,'2025-10-09 22:56:13'),
(22,4,'session_1760050522653_dqbql6ul0',NULL,'yes','I may not know that yet, but I\'m here to help! Try asking about:\n• Order tracking\n• Returns & refunds\n• Shipping info\n• Payment methods\n• Account issues','fallback','faq',0,1,NULL,'2025-10-09 22:56:23'),
(23,4,'session_1760050522653_dqbql6ul0',NULL,'closing account','No, guest checkout is available. However, an account lets you track orders and save preferences.','fallback','faq',0,0,NULL,'2025-10-09 22:56:44'),
(24,4,'session_1760050522653_dqbql6ul0',NULL,'shopping','Click \'Continue Shopping\' from cart to browse while keeping items saved.','fallback','faq',0,1,NULL,'2025-10-09 22:57:12'),
(25,4,'session_1760050522653_dqbql6ul0',NULL,'thanks','You\'re welcome! 😊 Is there anything else I can help you with?','fallback','faq',0,0,NULL,'2025-10-09 22:57:23'),
(26,4,'session_1760050522653_dqbql6ul0',NULL,'none','I may not know that yet, but I\'m here to help! Try asking about:\n• Order tracking\n• Returns & refunds\n• Shipping info\n• Payment methods\n• Account issues','fallback','faq',0,2,NULL,'2025-10-09 22:57:27'),
(27,4,'session_1760050522653_dqbql6ul0',NULL,'nothing','I\'m not quite sure about that, but I can help with shopping, orders, shipping, and account questions!','fallback','faq',0,1,NULL,'2025-10-09 22:57:31'),
(28,4,'session_1760050806342_kf4uwhuwr',NULL,'good  morning','Good morning! ☀️ Ready to start shopping? How can I help you today?','fallback','faq',0,1,NULL,'2025-10-09 23:00:16'),
(29,4,'session_1760050806342_kf4uwhuwr',NULL,'good evenning','Good morning! ☀️ Ready to start shopping? How can I help you today?','fallback','faq',0,0,NULL,'2025-10-09 23:00:29'),
(30,4,'session_1760050806342_kf4uwhuwr',NULL,'what is fezamarket','FezaMarket is Rwanda\'s premier online marketplace connecting buyers and sellers across Africa!','fallback','faq',0,0,NULL,'2025-10-09 23:00:39'),
(31,4,'session_1760050806342_kf4uwhuwr',NULL,'When did fezamarket start?','FezaMarket is Rwanda\'s premier online marketplace connecting buyers and sellers across Africa!','fallback','faq',0,0,NULL,'2025-10-09 23:01:00'),
(32,NULL,'session_1760076853600_ijtaxxzoq',NULL,'Hi','Hi there 👋! Welcome to FezaMarket. How can I help you today?','fallback','faq',0,0,NULL,'2025-10-10 06:14:19'),
(33,NULL,'session_1760076853600_ijtaxxzoq',NULL,'I need help','I\\\'m here to help! What do you need assistance with?','fallback','faq',0,9,NULL,'2025-10-10 06:14:29'),
(34,4,'session_1760077721274_eynpvbssx',NULL,'Hi','Hi there 👋! Welcome to FezaMarket. How can I help you today?','fallback','faq',0,5,NULL,'2025-10-10 06:28:44'),
(35,4,'session_1760078536942_76bnsc9z6',NULL,'How do I contact support?','Reach support by email, live chat (Mon-Fri 9AM-6PM), or phone. We respond within 24 hours!','fallback','faq',0,1,NULL,'2025-10-10 06:42:20'),
(36,4,'session_1760104737854_hxcyc72oi',NULL,'What is your return policy?','We have a 30-day return policy! Items must be unused and in original packaging. Start returns from \'My Orders\'.','fallback','faq',0,20,NULL,'2025-10-10 13:59:13'),
(37,4,'session_1760189740693_ilauwb75w',NULL,'HI','Hi there 👋! Welcome to FezaMarket. How can I help you today?','fallback','faq',0,6,NULL,'2025-10-11 13:35:44'),
(38,4,'session_1760189740693_ilauwb75w',NULL,'i am joseph','I\'m not sure I understand that yet. Could you try asking differently? 🤔','fallback','faq',0,1,NULL,'2025-10-11 13:35:48'),
(39,4,'session_1760194856839_6b3knmjse',NULL,'Hi','Hi there 👋! Welcome to FezaMarket. How can I help you today?','fallback','faq',0,25,NULL,'2025-10-11 15:01:01'),
(40,4,'session_1760194856839_6b3knmjse',NULL,'I need support','No, guest checkout is available. However, an account lets you track orders and save preferences.','fallback','faq',0,0,NULL,'2025-10-11 15:01:10'),
(41,4,'session_1760194856839_6b3knmjse',NULL,'Education','Educational toys for learning and development! Age-appropriate options available.','fallback','faq',0,0,NULL,'2025-10-11 15:01:14'),
(42,4,'session_1760194856839_6b3knmjse',NULL,'Message','Add a personalized gift message during checkout when sending items as gifts.','fallback','faq',0,0,NULL,'2025-10-11 15:01:22'),
(43,4,'session_1760194856839_6b3knmjse',NULL,'Electronics','Shop electronics: phones, laptops, tablets, cameras, accessories, and more!','fallback','faq',0,0,NULL,'2025-10-11 15:01:38'),
(44,4,'session_1760194856839_6b3knmjse',NULL,'Where?','Let me think... Could you ask that another way? I\'m great at helping with orders, products, and account issues!','fallback','faq',0,1,NULL,'2025-10-11 15:01:50'),
(45,4,'session_1760201972900_faiffoxew',NULL,'How do I contact support?','Reach support by email, live chat (Mon-Fri 9AM-6PM), or phone. We respond within 24 hours!','fallback','faq',0,4,NULL,'2025-10-11 16:59:36'),
(46,4,'session_1760201972900_faiffoxew',NULL,'hi','Hi there 👋! Welcome to FezaMarket. How can I help you today?','fallback','faq',0,0,NULL,'2025-10-11 16:59:46'),
(47,4,'session_1760201972900_faiffoxew',NULL,'ubumenyibwag','Hmm... I\'m still learning about that. Try asking about orders, shipping, returns, or payments!','fallback','faq',0,1,NULL,'2025-10-11 17:00:39'),
(48,NULL,'session_1760207397037_0d863yccr',NULL,'What is your return policy?','We have a 30-day return policy! Items must be unused and in original packaging. Start returns from \'My Orders\'.','fallback','faq',0,11,NULL,'2025-10-11 18:30:04'),
(49,NULL,'session_1760207397037_0d863yccr',NULL,'How can I get compansed when my product damaged?','To buy a product: 1) Search or browse for items 2) Click \'Add to Cart\' 3) Review your cart 4) Proceed to checkout 5) Enter shipping details 6) Complete payment. Easy!','fallback','faq',0,1,NULL,'2025-10-11 18:31:06'),
(50,4,'session_1760207818372_r60i9j8pl',NULL,'What is your return policy?','We have a 30-day return policy! Items must be unused and in original packaging. Start returns from \'My Orders\'.','fallback','faq',0,1,NULL,'2025-10-11 18:37:11'),
(51,4,'session_1760207818372_r60i9j8pl',NULL,'Training','I may not know that yet, but I\'m here to help! Try asking about:\n• Order tracking\n• Returns & refunds\n• Shipping info\n• Payment methods\n• Account issues','fallback','faq',0,1,NULL,'2025-10-11 18:37:25'),
(52,NULL,'session_1760222610331_ccqm9khh0',NULL,'How do I contact support?','Reach support by email, live chat (Mon-Fri 9AM-6PM), or phone. We respond within 24 hours!','fallback','faq',0,7,NULL,'2025-10-11 22:43:36'),
(53,NULL,'session_1760307302062_gtjfi53s0',NULL,'What is your return policy?','We have a 30-day return policy! Items must be unused and in original packaging. Start returns from \'My Orders\'.','fallback','faq',0,10,NULL,'2025-10-12 22:15:27'),
(54,NULL,'session_1760307302062_gtjfi53s0',NULL,'Côte d\'Ivoire','I may not know that yet, but I\'m here to help! Try asking about:\n• Order tracking\n• Returns & refunds\n• Shipping info\n• Payment methods\n• Account issues','fallback','faq',0,8,NULL,'2025-10-12 22:15:51'),
(55,NULL,'session_1760474493617_2xcmjgcyl',NULL,'How do I track my order?','Track your order from your account dashboard under \'My Orders\' or use the tracking link in your email.','fallback','faq',0,12,NULL,'2025-10-14 20:41:46'),
(56,NULL,'session_1760516795229_7ba2w9ayj',NULL,'How do I contact support?','Reach support by email, live chat (Mon-Fri 9AM-6PM), or phone. We respond within 24 hours!','fallback','faq',0,19,NULL,'2025-10-15 08:26:52'),
(57,NULL,'session_1760537708315_5cfjcym96',NULL,'How do I track my order?','Track your order from your account dashboard under \'My Orders\' or use the tracking link in your email.','fallback','faq',0,14,NULL,'2025-10-15 14:15:15'),
(58,4,'session_1760561008308_e28umrqqt',NULL,'How do I track my order?','Track your order from your account dashboard under \'My Orders\' or use the tracking link in your email.','fallback','faq',0,9,NULL,'2025-10-15 20:43:33'),
(59,4,'session_1760561008308_e28umrqqt',NULL,'i','I\'m not sure I understand that yet. Could you try asking differently? 🤔','fallback','faq',0,1,NULL,'2025-10-15 20:43:36'),
(60,4,'session_1760561008308_e28umrqqt',NULL,'hi','Hi there 👋! Welcome to FezaMarket. How can I help you today?','fallback','faq',0,0,NULL,'2025-10-15 20:43:38'),
(61,4,'session_1760562886394_9zcu3ql9f',NULL,'How do I contact support?','Reach support by email, live chat (Mon-Fri 9AM-6PM), or phone. We respond within 24 hours!','fallback','faq',0,1,NULL,'2025-10-15 21:14:58'),
(62,NULL,'session_1760627746546_fd8xhyl2t',NULL,'How do I contact support?','Reach support by email, live chat (Mon-Fri 9AM-6PM), or phone. We respond within 24 hours!','fallback','faq',0,6,NULL,'2025-10-16 15:15:52');
/*!40000 ALTER TABLE `ai_interactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_recommendations`
--

DROP TABLE IF EXISTS `ai_recommendations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_recommendations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `recommendation_type` enum('product','category','vendor','content','promotion') NOT NULL,
  `algorithm_used` varchar(100) NOT NULL,
  `recommendation_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`recommendation_data`)),
  `confidence_score` decimal(5,4) NOT NULL DEFAULT 0.0000,
  `interaction_context` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`interaction_context`)),
  `is_clicked` tinyint(1) NOT NULL DEFAULT 0,
  `is_purchased` tinyint(1) NOT NULL DEFAULT 0,
  `clicked_at` timestamp NULL DEFAULT NULL,
  `purchased_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_recommendation_type` (`recommendation_type`),
  KEY `idx_algorithm_used` (`algorithm_used`),
  KEY `idx_confidence_score` (`confidence_score`),
  KEY `idx_is_clicked` (`is_clicked`),
  KEY `idx_is_purchased` (`is_purchased`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_ai_recommendations_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_recommendations`
--

LOCK TABLES `ai_recommendations` WRITE;
/*!40000 ALTER TABLE `ai_recommendations` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_recommendations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_endpoints`
--

DROP TABLE IF EXISTS `api_endpoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_endpoints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `endpoint_path` varchar(255) NOT NULL,
  `http_method` enum('GET','POST','PUT','PATCH','DELETE') NOT NULL DEFAULT 'GET',
  `description` text DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `requires_auth` tinyint(1) NOT NULL DEFAULT 1,
  `required_permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`required_permissions`)),
  `rate_limit_requests` int(11) NOT NULL DEFAULT 100,
  `rate_limit_window` int(11) NOT NULL DEFAULT 3600,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `version` varchar(10) NOT NULL DEFAULT 'v1',
  `documentation_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_endpoint_method_version` (`endpoint_path`,`http_method`,`version`),
  KEY `idx_is_public` (`is_public`),
  KEY `idx_requires_auth` (`requires_auth`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_version` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_endpoints`
--

LOCK TABLES `api_endpoints` WRITE;
/*!40000 ALTER TABLE `api_endpoints` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_endpoints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `subscription_id` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `environment` enum('sandbox','live') NOT NULL DEFAULT 'sandbox',
  `api_key` varchar(64) NOT NULL,
  `api_secret` varchar(128) NOT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `rate_limit` int(11) NOT NULL DEFAULT 100,
  `rate_window` int(11) NOT NULL DEFAULT 3600,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_api_key` (`api_key`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_last_used_at` (`last_used_at`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `idx_environment` (`environment`),
  KEY `idx_api_keys_subscription` (`subscription_id`),
  CONSTRAINT `fk_api_key_subscription` FOREIGN KEY (`subscription_id`) REFERENCES `api_subscriptions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_api_keys_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_keys`
--

LOCK TABLES `api_keys` WRITE;
/*!40000 ALTER TABLE `api_keys` DISABLE KEYS */;
INSERT INTO `api_keys` VALUES
(1,4,NULL,'models','live','feza_live_9127ce894cca9c12209fff978d2e080e17515b4a432f5c9a','041e0a14364d7a7d1c3204eef75a5478f3753f7bfe1edabb72d062aea0b80123',NULL,100,3600,1,NULL,NULL,'2025-10-05 13:12:22','2025-10-05 13:12:22'),
(2,4,NULL,'models','live','feza_live_630bc1a797a6b865c27270290941ac0cc846c0dbb482ff80','7cc39461075f3a16ecfc7861e1d6059be643049609eb6622d64b47e8b1559624',NULL,100,3600,1,NULL,NULL,'2025-10-05 13:12:22','2025-10-06 18:00:22');
/*!40000 ALTER TABLE `api_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_logs`
--

DROP TABLE IF EXISTS `api_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `api_key_id` int(11) DEFAULT NULL,
  `endpoint` varchar(255) NOT NULL,
  `method` varchar(10) NOT NULL,
  `request_headers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`request_headers`)),
  `request_body` longtext DEFAULT NULL,
  `response_status` int(11) NOT NULL,
  `response_headers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`response_headers`)),
  `response_body` longtext DEFAULT NULL,
  `response_time` int(11) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_api_key_id` (`api_key_id`),
  KEY `idx_endpoint` (`endpoint`),
  KEY `idx_method` (`method`),
  KEY `idx_response_status` (`response_status`),
  KEY `idx_ip_address` (`ip_address`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_api_logs_key_date` (`api_key_id`,`created_at`),
  KEY `idx_api_logs_ip` (`ip_address`),
  CONSTRAINT `fk_api_logs_api_key` FOREIGN KEY (`api_key_id`) REFERENCES `api_keys` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_logs`
--

LOCK TABLES `api_logs` WRITE;
/*!40000 ALTER TABLE `api_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_subscription_invoices`
--

DROP TABLE IF EXISTS `api_subscription_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_subscription_invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subscription_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('pending','paid','failed','refunded','cancelled') NOT NULL DEFAULT 'pending',
  `invoice_number` varchar(50) NOT NULL,
  `billing_period_start` timestamp NULL DEFAULT NULL,
  `billing_period_end` timestamp NULL DEFAULT NULL,
  `due_date` timestamp NULL DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `invoice_url` varchar(500) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_invoice_number` (`invoice_number`),
  KEY `subscription_id` (`subscription_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_invoice_status` (`status`),
  KEY `idx_due_date` (`due_date`),
  CONSTRAINT `fk_invoice_subscription` FOREIGN KEY (`subscription_id`) REFERENCES `api_subscriptions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Invoices for API subscription payments';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_subscription_invoices`
--

LOCK TABLES `api_subscription_invoices` WRITE;
/*!40000 ALTER TABLE `api_subscription_invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_subscription_invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_subscriptions`
--

DROP TABLE IF EXISTS `api_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `plan_id` varchar(50) NOT NULL,
  `payment_processor_subscription_id` varchar(255) NOT NULL,
  `status` enum('active','cancelled','past_due') NOT NULL,
  `start_date` timestamp NOT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id_unique` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='API subscription plans - sandbox (free), live ($150/month), government (special access)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_subscriptions`
--

LOCK TABLES `api_subscriptions` WRITE;
/*!40000 ALTER TABLE `api_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_usage_metrics`
--

DROP TABLE IF EXISTS `api_usage_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_usage_metrics` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `api_key_id` int(11) NOT NULL,
  `subscription_id` int(11) DEFAULT NULL,
  `endpoint` varchar(255) NOT NULL,
  `method` varchar(10) NOT NULL,
  `status_code` int(11) NOT NULL,
  `response_time_ms` int(11) DEFAULT NULL,
  `request_size_bytes` int(11) DEFAULT NULL,
  `response_size_bytes` int(11) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `api_key_id` (`api_key_id`),
  KEY `subscription_id` (`subscription_id`),
  KEY `idx_usage_date` (`created_at`),
  KEY `idx_usage_endpoint` (`endpoint`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='API usage tracking for analytics and billing';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_usage_metrics`
--

LOCK TABLES `api_usage_metrics` WRITE;
/*!40000 ALTER TABLE `api_usage_metrics` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_usage_metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `resource_type` varchar(100) DEFAULT NULL,
  `resource_id` varchar(100) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `new_values` longtext DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_action` (`action`)
) ENGINE=InnoDB AUTO_INCREMENT=237 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES
(1,1,'login_failed_inactive','user','1','105.178.104.198','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','[]','2025-09-11 18:55:47'),
(2,1,'login_success','user','1','105.178.104.198','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','[]','2025-09-11 19:11:33'),
(3,1,'login_success','user','1','105.178.104.198','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','[]','2025-09-11 19:27:53'),
(4,1,'login_success','user','1','105.178.104.198','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','[]','2025-09-11 19:33:28'),
(5,1,'login_success','user','1','105.178.104.198','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','[]','2025-09-11 19:36:42'),
(6,1,'login_success','user','1','105.178.104.198','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','[]','2025-09-11 19:39:47'),
(7,1,'login_success','user','1','105.178.104.198','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','[]','2025-09-11 19:41:07'),
(8,1,'login_success','user','1','105.178.104.198','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','[]','2025-09-11 19:41:10'),
(9,1,'login_success','user','1','197.157.155.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','[]','2025-09-11 21:46:44'),
(10,1,'login_success','user','1','197.157.155.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','[]','2025-09-11 21:50:31'),
(11,4,'login_failed_inactive','user','4','197.157.155.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','[]','2025-09-11 21:57:03'),
(12,1,'update','admin_action','1','197.157.145.25','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"action\":\"update\",\"target_type\":\"category\",\"notes\":\"\",\"new_data\":{\"name\":\"Electronics\",\"parent_id\":null,\"slug\":\"electronics\",\"is_active\":1}}','2025-09-15 00:04:01'),
(13,4,'login_failed_inactive','user','4','197.157.145.25','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-15 00:44:24'),
(14,4,'login_success','user','4','197.157.145.25','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-15 00:45:42'),
(15,4,'login_success','user','4','105.178.32.82','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-15 19:09:28'),
(16,4,'login_success','user','4','197.157.155.6','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-15 21:22:52'),
(17,4,'login_success','user','4','197.157.155.6','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-15 21:29:35'),
(18,4,'login_success','user','4','197.157.155.6','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-15 22:00:11'),
(19,4,'login_success','user','4','197.157.155.6','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-15 22:08:43'),
(20,4,'login_success','user','4','197.157.155.22','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-15 23:11:16'),
(21,4,'login_success','user','4','197.157.155.22','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-15 23:14:55'),
(22,4,'login_success','user','4','197.157.155.22','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-16 00:19:58'),
(23,4,'login_success','user','4','197.157.155.22','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-16 01:21:19'),
(24,4,'login_success','user','4','197.157.155.22','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-16 02:58:23'),
(25,4,'login_success','user','4','105.178.32.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-16 09:50:29'),
(26,4,'login_success','user','4','105.178.32.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-16 11:35:24'),
(27,4,'login_success','user','4','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-16 12:10:19'),
(28,4,'login_success','user','4','105.178.104.129','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-16 15:25:14'),
(29,4,'login_success','user','4','105.178.32.65','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-16 20:10:15'),
(30,4,'login_success','user','4','105.178.104.65','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-16 20:51:50'),
(31,4,'login_success','user','4','197.157.135.133','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-21 02:20:08'),
(32,4,'login_success','user','4','197.157.135.133','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-21 02:21:19'),
(33,NULL,'login_failed','user',NULL,'197.157.135.133','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"niyogushimwaj967@gmail.com\"}','2025-09-21 02:26:56'),
(34,5,'login_success','user','5','197.157.135.133','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-21 02:27:04'),
(35,4,'login_success','user','4','197.157.135.133','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-21 02:31:22'),
(36,NULL,'login_failed','user',NULL,'41.186.132.60','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-09-21 10:56:56'),
(37,4,'login_success','user','4','41.186.132.60','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-21 10:57:04'),
(38,4,'login_success','user','4','197.157.187.91','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-21 13:07:53'),
(39,4,'login_success','user','4','105.178.104.165','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-27 11:29:06'),
(40,4,'login_success','user','4','105.178.32.38','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-27 14:29:31'),
(41,4,'login_success','user','4','102.22.163.69','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-27 16:20:48'),
(42,4,'login_success','user','4','105.178.104.79','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-27 18:43:44'),
(43,NULL,'login_failed','user',NULL,'105.178.104.79','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-09-27 19:26:39'),
(44,4,'login_success','user','4','105.178.104.79','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-27 19:26:47'),
(45,4,'login_success','user','4','105.178.104.79','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-27 22:44:06'),
(46,4,'login_success','user','4','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-28 21:59:25'),
(47,4,'login_success','user','4','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-28 21:59:42'),
(48,4,'login_success','user','4','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-28 22:01:47'),
(49,4,'login_success','user','4','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-28 23:41:55'),
(50,5,'login_success','user','5','197.157.155.7','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','[]','2025-09-29 00:06:43'),
(51,4,'login_success','user','4','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-29 11:17:37'),
(52,4,'login_success','user','4','105.178.104.179','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-29 12:59:37'),
(53,4,'login_success','user','4','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-29 14:03:37'),
(54,4,'login_success','user','4','197.157.145.29','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-29 22:00:41'),
(55,NULL,'login_failed','user',NULL,'197.157.145.29','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-09-29 22:03:34'),
(56,4,'login_success','user','4','197.157.145.29','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-29 22:03:41'),
(57,4,'login_success','user','4','197.157.145.29','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-30 00:23:24'),
(58,4,'login_success','user','4','197.157.145.29','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-30 00:59:28'),
(59,4,'login_success','user','4','197.157.145.29','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-30 08:17:58'),
(60,NULL,'login_failed','user',NULL,'105.178.104.179','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-09-30 09:43:21'),
(61,4,'login_success','user','4','105.178.104.179','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-30 09:43:26'),
(62,4,'login_success','user','4','105.178.32.179','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-09-30 10:48:23'),
(63,4,'login_success','user','4','197.157.155.132','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-01 22:40:32'),
(64,4,'login_success','user','4','197.157.155.132','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-01 23:41:18'),
(65,NULL,'login_failed','user',NULL,'197.157.155.132','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-02 01:03:44'),
(66,4,'login_success','user','4','197.157.155.132','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-02 01:03:58'),
(67,4,'login_success','user','4','105.178.104.110','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-03 15:40:58'),
(68,4,'login_success','user','4','105.178.32.109','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-03 16:37:32'),
(69,NULL,'login_failed','user',NULL,'197.157.135.231','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-03 21:15:31'),
(70,4,'login_success','user','4','197.157.135.231','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-03 21:15:40'),
(71,4,'login_success','user','4','197.157.165.150','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-03 22:41:13'),
(72,NULL,'login_failed','user',NULL,'197.157.165.150','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-03 23:46:19'),
(73,4,'login_success','user','4','197.157.165.150','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-03 23:46:26'),
(74,4,'login_success','user','4','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-04 06:46:31'),
(75,4,'login_success','user','4','197.157.165.87','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','[]','2025-10-04 07:39:23'),
(76,4,'login_success','user','4','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-04 09:03:20'),
(77,4,'login_success','user','4','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-04 09:19:38'),
(78,4,'login_success','user','4','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-04 11:14:01'),
(79,4,'login_success','user','4','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-04 12:18:18'),
(80,5,'login_success','user','5','105.178.104.109','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','[]','2025-10-04 12:46:56'),
(81,NULL,'login_failed','user',NULL,'197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-04 15:04:04'),
(82,4,'login_success','user','4','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-04 15:04:11'),
(83,5,'login_success','user','5','197.157.165.87','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','[]','2025-10-04 16:05:17'),
(84,4,'login_success','user','4','102.22.139.51','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-04 18:14:43'),
(85,4,'login_success','user','4','197.157.165.35','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-05 00:54:31'),
(86,NULL,'login_failed','user',NULL,'197.157.135.63','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-05 12:39:47'),
(87,4,'login_success','user','4','197.157.135.63','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-05 12:39:55'),
(88,4,'login_success','user','4','197.157.135.63','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-05 14:45:41'),
(89,4,'login_success','user','4','197.157.135.63','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-05 14:48:44'),
(90,4,'login_success','user','4','197.157.135.63','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','[]','2025-10-05 16:29:25'),
(91,4,'login_success','user','4','197.157.135.63','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-06 00:46:08'),
(92,5,'login_success','user','5','197.157.135.63','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','[]','2025-10-06 01:00:13'),
(93,4,'login_success','user','4','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-06 10:44:07'),
(94,4,'login_success','user','4','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-06 11:55:14'),
(95,5,'login_success','user','5','105.178.32.56','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','[]','2025-10-06 12:52:09'),
(96,4,'login_success','user','4','105.178.32.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-06 12:58:02'),
(97,NULL,'login_failed','user',NULL,'41.186.139.85','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-06 13:14:53'),
(98,4,'login_success','user','4','41.186.139.85','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','[]','2025-10-06 13:15:05'),
(99,4,'login_success','user','4','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-06 15:22:44'),
(100,4,'login_success','user','4','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-06 16:00:25'),
(101,5,'login_success','user','5','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-06 16:01:49'),
(102,4,'login_success','user','4','197.157.155.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-06 19:57:17'),
(103,5,'login_success','user','5','197.157.155.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-06 20:01:21'),
(104,4,'login_success','user','4','197.157.155.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-06 22:55:51'),
(105,6,'login_failed_inactive','user','6','197.157.135.201','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-07 00:32:12'),
(106,4,'login_success','user','4','197.157.135.201','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-07 08:48:28'),
(107,4,'login_success','user','4','197.157.135.201','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-07 10:15:54'),
(108,4,'login_success','user','4','197.157.135.201','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-07 16:46:50'),
(109,12,'login_failed_inactive','user','12','105.178.32.123','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-07 18:27:36'),
(110,NULL,'login_failed','user',NULL,'105.178.104.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-07 18:59:38'),
(111,4,'login_success','user','4','105.178.104.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-07 18:59:45'),
(112,13,'login_failed_inactive','user','13','105.178.32.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-07 19:06:46'),
(113,13,'login_success','user','13','105.178.32.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-07 19:07:32'),
(114,4,'login_success','user','4','105.178.104.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-07 19:33:01'),
(115,NULL,'login_failed','user',NULL,'105.178.32.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-07 20:51:48'),
(116,4,'login_success','user','4','105.178.32.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-07 20:51:55'),
(117,4,'login_success','user','4','197.157.145.87','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','[]','2025-10-07 21:53:10'),
(118,4,'login_success','user','4','197.157.145.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-07 22:40:43'),
(119,4,'login_success','user','4','197.157.145.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-08 01:52:13'),
(120,4,'login_success','user','4','197.157.145.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-08 09:06:55'),
(121,4,'login_success','user','4','197.157.145.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-08 10:18:03'),
(122,4,'login_success','user','4','197.157.135.108','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-08 23:00:43'),
(123,4,'login_success','user','4','197.157.135.108','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-08 23:39:22'),
(124,NULL,'login_failed','user',NULL,'197.157.135.108','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-09 00:41:48'),
(125,NULL,'login_failed','user',NULL,'197.157.135.108','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-09 00:41:56'),
(126,NULL,'login_failed','user',NULL,'197.157.135.108','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-09 00:42:18'),
(127,4,'login_success','user','4','197.157.135.108','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 00:42:28'),
(128,4,'login_success','user','4','41.186.139.192','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 01:43:21'),
(129,4,'login_success','user','4','197.157.135.11','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 08:37:27'),
(130,4,'login_success','user','4','197.157.135.11','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 09:20:31'),
(131,NULL,'login_failed','user',NULL,'197.157.135.11','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-09 10:15:40'),
(132,4,'login_success','user','4','197.157.135.11','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 10:15:52'),
(133,4,'login_success','user','4','105.178.104.255','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 11:11:32'),
(134,NULL,'login_failed','user',NULL,'105.178.32.255','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-09 13:25:55'),
(135,4,'login_success','user','4','105.178.32.255','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 13:26:00'),
(136,NULL,'login_failed','user',NULL,'2401:4900:839b:85b7:211d:bd45:b205:7089','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"amarjit18000@gmail.com\"}','2025-10-09 15:18:24'),
(137,NULL,'login_failed','user',NULL,'2401:4900:839b:85b7:211d:bd45:b205:7089','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"amarjit18000@gmail.com\"}','2025-10-09 15:18:37'),
(138,NULL,'login_failed','user',NULL,'2401:4900:839b:85b7:211d:bd45:b205:7089','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"amarjit18000@gmail.com\"}','2025-10-09 15:21:51'),
(139,16,'login_failed_inactive','user','16','2401:4900:839b:85b7:211d:bd45:b205:7089','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 15:25:15'),
(140,16,'login_failed_inactive','user','16','27.59.68.147','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 15:26:55'),
(141,16,'password_reset_requested','user','16','2401:4900:839b:85b7:211d:bd45:b205:7089','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 15:34:40'),
(142,17,'login_success','user','17','2401:4900:839b:85b7:211d:bd45:b205:7089','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 15:42:04'),
(143,17,'login_success','user','17','2401:4900:839b:85b7:211d:bd45:b205:7089','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 15:53:48'),
(144,4,'login_success','user','4','105.178.32.255','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 16:28:28'),
(145,4,'login_success','user','4','105.178.32.255','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 18:12:36'),
(146,4,'login_success','user','4','197.157.135.155','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 18:33:59'),
(147,4,'login_success','user','4','197.157.135.155','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 20:05:18'),
(148,4,'login_success','user','4','197.157.165.125','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 21:26:00'),
(149,4,'login_success','user','4','197.157.165.125','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-09 23:24:26'),
(150,4,'login_success','user','4','197.157.165.125','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-10 00:37:22'),
(151,NULL,'login_failed','user',NULL,'197.157.155.94','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-10 08:15:10'),
(152,4,'login_success','user','4','197.157.155.94','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','[]','2025-10-10 08:15:19'),
(153,4,'login_success','user','4','197.157.155.94','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-10 08:24:55'),
(154,4,'login_success','user','4','197.157.155.94','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-10 08:53:59'),
(155,17,'login_success','user','17','2401:4900:a06e:7ded:9445:653:2877:4a56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-10 09:10:41'),
(156,NULL,'login_failed','user',NULL,'88.210.3.196','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Avast/131.0.0.0','{\"email\":\"st.i.l.tbtsb@web.de\"}','2025-10-10 10:13:25'),
(157,4,'login_success','user','4','197.157.155.94','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-10 11:15:06'),
(158,4,'login_success','user','4','197.157.155.159','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','[]','2025-10-10 15:59:43'),
(159,4,'login_success','user','4','105.178.104.166','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-10 20:04:22'),
(160,4,'login_success','user','4','105.178.32.47','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-11 15:16:53'),
(161,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','[]','2025-10-11 16:49:12'),
(162,NULL,'login_failed','user',NULL,'185.72.199.129','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Avast/131.0.0.0','{\"email\":\"Cog@prohabits.es\"}','2025-10-11 16:52:02'),
(163,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-11 17:13:49'),
(164,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-11 17:16:00'),
(165,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-11 17:56:33'),
(166,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-11 19:28:46'),
(167,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','[]','2025-10-11 19:45:58'),
(168,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-11 20:50:16'),
(169,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-11 22:06:16'),
(170,NULL,'login_failed','user',NULL,'197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-11 23:10:22'),
(171,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-11 23:10:49'),
(172,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-11 23:44:39'),
(173,18,'login_failed_inactive','user','18','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-11 23:47:36'),
(174,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-11 23:58:20'),
(175,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 01:02:33'),
(176,5,'login_failed_inactive','user','5','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 01:29:04'),
(177,19,'login_success','user','19','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 01:33:00'),
(178,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 02:06:03'),
(179,NULL,'login_failed','user',NULL,'197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-12 03:07:08'),
(180,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 03:07:18'),
(181,19,'login_success','user','19','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 03:19:53'),
(182,4,'login_success','user','4','197.157.145.187','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','[]','2025-10-12 03:32:25'),
(183,4,'login_success','user','4','197.157.135.137','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 11:47:48'),
(184,4,'login_success','user','4','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 14:01:00'),
(185,19,'login_success','user','19','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 15:48:26'),
(186,19,'login_success','user','19','197.157.145.53','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','[]','2025-10-12 16:32:22'),
(187,19,'login_success','user','19','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 18:00:31'),
(188,4,'login_success','user','4','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 18:21:11'),
(189,4,'login_success','user','4','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 19:26:39'),
(190,4,'login_success','user','4','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 20:29:20'),
(191,4,'login_success','user','4','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','[]','2025-10-12 23:01:34'),
(192,4,'login_success','user','4','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 00:31:16'),
(193,4,'login_success','user','4','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 01:11:56'),
(194,4,'address_updated','address','1','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 01:13:21'),
(195,4,'preferences_updated','user','4','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 01:14:29'),
(196,20,'login_failed_inactive','user','20','23.247.136.254','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36','[]','2025-10-13 01:20:19'),
(197,4,'preferences_updated','user','4','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 01:42:33'),
(198,4,'login_success','user','4','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 02:18:32'),
(199,19,'login_success','user','19','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 02:20:21'),
(200,4,'login_success','user','4','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 03:21:48'),
(201,19,'login_success','user','19','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 03:22:23'),
(202,19,'login_success','user','19','197.157.135.140','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 08:33:38'),
(203,19,'login_success','user','19','197.157.135.140','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 09:46:38'),
(204,NULL,'login_failed','user',NULL,'197.157.135.140','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-13 10:36:02'),
(205,4,'login_success','user','4','105.178.32.118','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-13 11:04:23'),
(206,NULL,'login_failed','user',NULL,'51.75.206.20','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36','{\"email\":\"user2025@123bv1.it.com\"}','2025-10-14 01:35:31'),
(207,4,'login_success','user','4','197.157.155.40','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-14 12:01:19'),
(208,4,'login_success','user','4','197.157.155.40','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-14 13:02:02'),
(209,4,'login_success','user','4','105.178.104.101','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-14 15:08:14'),
(210,4,'login_success','user','4','105.178.32.101','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-14 16:31:10'),
(211,4,'login_success','user','4','197.157.186.89','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','[]','2025-10-14 20:18:13'),
(212,4,'login_success','user','4','197.157.187.170','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-14 20:23:24'),
(213,4,'login_success','user','4','197.157.187.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-14 22:16:21'),
(214,4,'login_success','user','4','197.157.187.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-15 00:19:45'),
(215,4,'permission_denied','security',NULL,'197.157.187.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','{\"permission\":\"FINANCE_VIEW\",\"user_role\":\"admin\",\"url\":\"\\/admin\\/finance\\/\"}','2025-10-15 00:52:38'),
(216,4,'permission_denied','security',NULL,'197.157.187.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','{\"permission\":\"FINANCE_VIEW\",\"user_role\":\"admin\",\"url\":\"\\/admin\\/finance\\/\"}','2025-10-15 00:53:09'),
(217,4,'permission_denied','security',NULL,'197.157.187.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','{\"permission\":\"FINANCE_VIEW\",\"user_role\":\"admin\",\"url\":\"\\/admin\\/finance\\/\"}','2025-10-15 01:09:52'),
(218,4,'permission_denied','security',NULL,'197.157.187.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','{\"permission\":\"FINANCE_VIEW\",\"user_role\":\"admin\",\"url\":\"\\/admin\\/finance\\/\"}','2025-10-15 01:10:10'),
(219,4,'login_success','user','4','105.178.104.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-15 11:02:17'),
(220,4,'permission_denied','security',NULL,'105.178.32.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','{\"permission\":\"FINANCE_VIEW\",\"user_role\":\"admin\",\"url\":\"\\/admin\\/finance\\/\"}','2025-10-15 11:45:44'),
(221,4,'permission_denied','security',NULL,'105.178.104.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','{\"permission\":\"FINANCE_VIEW\",\"user_role\":\"admin\",\"url\":\"\\/admin\\/finance\\/\"}','2025-10-15 11:46:26'),
(222,4,'login_success','user','4','105.178.32.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-15 12:40:10'),
(223,4,'login_success','user','4','197.157.187.84','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','[]','2025-10-15 13:20:36'),
(224,4,'login_success','user','4','105.178.104.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-15 14:46:01'),
(225,4,'permission_denied','security',NULL,'105.178.32.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','{\"permission\":\"security.view\",\"user_role\":\"admin\",\"url\":\"\\/admin\\/security\\/\"}','2025-10-15 15:06:04'),
(226,4,'login_success','user','4','105.178.32.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-15 17:00:59'),
(227,4,'permission_denied','security',NULL,'105.178.32.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','{\"permission\":\"security.view\",\"user_role\":\"admin\",\"url\":\"\\/admin\\/security\\/\"}','2025-10-15 17:07:59'),
(228,4,'login_success','user','4','41.186.138.204','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-15 20:29:30'),
(229,4,'audit_logs_cleaned','admin_action',NULL,'197.157.187.139','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','{\"action\":\"audit_logs_cleaned\",\"target_type\":\"system\",\"notes\":\"Cleaned old audit logs (retention: 365 days)\",\"new_data\":{\"retention_days\":365,\"deleted_count\":0}}','2025-10-15 21:32:08'),
(230,4,'login_success','user','4','197.157.187.139','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-15 21:34:19'),
(231,NULL,'login_failed','user',NULL,'197.157.187.169','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','{\"email\":\"ellyj164@gmail.com\"}','2025-10-16 09:34:54'),
(232,4,'login_success','user','4','197.157.187.169','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-16 09:35:00'),
(233,4,'login_success','user','4','105.178.32.160','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-16 11:48:15'),
(234,4,'login_success','user','4','105.178.32.160','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-16 12:56:08'),
(235,4,'login_success','user','4','197.157.185.236','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-17 00:17:38'),
(236,4,'login_success','user','4','197.157.186.103','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','[]','2025-10-17 00:55:20');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `event` varchar(255) NOT NULL,
  `category` varchar(100) NOT NULL,
  `level` enum('info','warning','error','critical') NOT NULL DEFAULT 'info',
  `target_id` int(11) DEFAULT NULL,
  `target_type` varchar(50) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `url` varchar(500) DEFAULT NULL,
  `method` varchar(10) DEFAULT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_event` (`event`),
  KEY `idx_category` (`category`),
  KEY `idx_level` (`level`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_ip_address` (`ip_address`),
  KEY `idx_target` (`target_type`,`target_id`),
  KEY `idx_audit_logs_composite` (`user_id`,`category`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backups`
--

DROP TABLE IF EXISTS `backups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `backups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `backup_type` enum('database','files','full') NOT NULL,
  `filename` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint(20) NOT NULL,
  `compression` enum('none','gzip','zip') NOT NULL DEFAULT 'gzip',
  `status` enum('in_progress','completed','failed') NOT NULL DEFAULT 'in_progress',
  `tables_included` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tables_included`)),
  `paths_included` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`paths_included`)),
  `checksum` varchar(64) DEFAULT NULL,
  `retention_days` int(11) NOT NULL DEFAULT 30,
  `delete_after` date NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL,
  `filepath` varchar(500) DEFAULT NULL COMMENT 'Alias for file_path, used by maintenance page',
  `description` text DEFAULT NULL COMMENT 'Backup description for maintenance page',
  PRIMARY KEY (`id`),
  KEY `idx_backup_type` (`backup_type`),
  KEY `idx_status` (`status`),
  KEY `idx_delete_after` (`delete_after`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_backups_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backups`
--

LOCK TABLES `backups` WRITE;
/*!40000 ALTER TABLE `backups` DISABLE KEYS */;
/*!40000 ALTER TABLE `backups` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`fezamarket`@`localhost`*/ /*!50003 TRIGGER `backups_sync_filepath_on_insert` BEFORE INSERT ON `backups`
FOR EACH ROW
BEGIN
  IF NEW.filepath IS NULL AND NEW.file_path IS NOT NULL THEN
    SET NEW.filepath = NEW.file_path;
  ELSEIF NEW.file_path IS NULL AND NEW.filepath IS NOT NULL THEN
    SET NEW.file_path = NEW.filepath;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`fezamarket`@`localhost`*/ /*!50003 TRIGGER `backups_sync_filepath_on_update` BEFORE UPDATE ON `backups`
FOR EACH ROW
BEGIN
  IF NEW.file_path != OLD.file_path THEN
    SET NEW.filepath = NEW.file_path;
  ELSEIF NEW.filepath != OLD.filepath THEN
    SET NEW.file_path = NEW.filepath;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `banners`
--

DROP TABLE IF EXISTS `banners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `banners` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `slot_key` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `subtitle` varchar(500) DEFAULT NULL,
  `link_url` varchar(500) DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `bg_image_path` varchar(500) DEFAULT NULL,
  `fg_image_path` varchar(500) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slot_key` (`slot_key`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `banners`
--

LOCK TABLES `banners` WRITE;
/*!40000 ALTER TABLE `banners` DISABLE KEYS */;
INSERT INTO `banners` VALUES
(1,'shoes-banner','Buy socks','buy this today','https://fezamarket.com','https://fezalogistics.com','/uploads/banners/bnr_68ecc2fb61e60.webp','/uploads/banners/bnr_68e007f2a0ce7.webp',NULL,NULL,'2025-10-03 14:36:01','2025-10-13 09:14:35'),
(3,'trending-2','banner shop','shopd','https://fezamarket.com','https://fezamarket.com','/uploads/banners/bnr_68e0f41c8d5d8.jpg','/uploads/banners/bnr_68e008432f9d5.webp',NULL,NULL,'2025-10-03 17:30:43','2025-10-04 10:17:00'),
(5,'trending-1','Costway Ironmax 2400 PSI at 1.7 GPM 120 V Electric Cold Water Pressure Washer, High-Pressure Hose','','https://fezamarket.com','https://i5.walmartimages.com/seo/Costway-Ironmax-2400-PSI-at-1-7-GPM-120-V-Electric-Cold-Water-Pressure-Washer-High-Pressure-Hose_8c0efb8b-1360-483c-9ecd-b0031baedfcc.15578f92b671c265de0689a1194bb920.jpeg?odnHeight=2000&odnWidth=2000&odnBg=FFFFFF','/uploads/banners/bnr_68ebf46bcd63a.jpg',NULL,NULL,NULL,'2025-10-12 18:32:16','2025-10-12 18:33:15');
/*!40000 ALTER TABLE `banners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bounces`
--

DROP TABLE IF EXISTS `bounces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bounces` (
  `bounce_id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11) NOT NULL,
  `bounce_type` enum('hard','soft','complaint') NOT NULL,
  `reason` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `email_address` varchar(255) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `gateway_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`gateway_data`)),
  PRIMARY KEY (`bounce_id`),
  KEY `idx_message_id` (`message_id`),
  KEY `idx_bounce_type` (`bounce_type`),
  KEY `idx_email_address` (`email_address`),
  KEY `idx_timestamp` (`timestamp`),
  KEY `idx_bounces_email_type` (`email_address`,`bounce_type`,`timestamp`),
  CONSTRAINT `fk_bounces_message` FOREIGN KEY (`message_id`) REFERENCES `comm_messages` (`message_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bounces`
--

LOCK TABLES `bounces` WRITE;
/*!40000 ALTER TABLE `bounces` DISABLE KEYS */;
/*!40000 ALTER TABLE `bounces` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `brands`
--

DROP TABLE IF EXISTS `brands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `brands` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `slug` varchar(160) NOT NULL,
  `description` text DEFAULT NULL,
  `logo_path` varchar(255) DEFAULT NULL,
  `website_url` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `logo_url` varchar(500) DEFAULT NULL,
  `is_featured` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_brands_name` (`name`),
  UNIQUE KEY `uq_brands_slug` (`slug`),
  KEY `idx_brands_active` (`is_active`),
  KEY `idx_is_featured` (`is_featured`)
) ENGINE=InnoDB AUTO_INCREMENT=140 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `brands`
--

LOCK TABLES `brands` WRITE;
/*!40000 ALTER TABLE `brands` DISABLE KEYS */;
INSERT INTO `brands` VALUES
(1,'Generic Brand','generic-brand','Default brand placeholder',NULL,NULL,1,'2025-09-15 15:25:42','2025-09-15 15:25:42',NULL,0),
(4,'Apple','apple','Technology and consumer electronics',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(5,'Samsung','samsung','Electronics and mobile devices',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(6,'Sony','sony','Electronics and entertainment',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(7,'LG','lg','Electronics and appliances',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(8,'Dell','dell','Computers and technology',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(9,'HP','hp','Computers and printers',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(10,'Lenovo','lenovo','Computers and tablets',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(11,'Asus','asus','Computer hardware',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(12,'Acer','acer','Computers and monitors',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(13,'Microsoft','microsoft','Software and hardware',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(14,'Google','google','Technology and services',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(15,'Amazon','amazon','Technology and services',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(16,'Panasonic','panasonic','Electronics and appliances',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(17,'Philips','philips','Electronics and healthcare',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(18,'Canon','canon','Cameras and printers',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(19,'Nikon','nikon','Cameras and optics',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(20,'JBL','jbl','Audio equipment',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(21,'Bose','bose','Audio equipment',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(22,'Beats','beats','Headphones and audio',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(23,'Logitech','logitech','Computer peripherals',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(24,'Razer','razer','Gaming peripherals',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(25,'Corsair','corsair','Gaming and PC components',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(26,'Intel','intel','Processors and technology',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(27,'AMD','amd','Processors and graphics',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(28,'NVIDIA','nvidia','Graphics cards',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(29,'Nike','nike','Athletic wear and footwear',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(30,'Adidas','adidas','Sportswear and footwear',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(31,'Puma','puma','Athletic apparel',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(32,'Under Armour','under-armour','Athletic apparel',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(33,'Reebok','reebok','Athletic footwear and apparel',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(34,'New Balance','new-balance','Athletic footwear',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(35,'Levi\'s','levis','Denim and casual wear',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(36,'Gap','gap','Casual clothing',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(37,'H&M','hm','Fashion retailer',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(38,'Zara','zara','Fashion apparel',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(39,'Uniqlo','uniqlo','Casual wear',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(40,'Ralph Lauren','ralph-lauren','Fashion and lifestyle',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(41,'Tommy Hilfiger','tommy-hilfiger','Fashion apparel',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(42,'Calvin Klein','calvin-klein','Fashion and accessories',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(43,'Gucci','gucci','Luxury fashion',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(44,'Prada','prada','Luxury fashion',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(45,'Louis Vuitton','louis-vuitton','Luxury goods',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(46,'Versace','versace','Luxury fashion',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(47,'Burberry','burberry','Luxury fashion',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(48,'Coach','coach','Leather goods and accessories',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(49,'Michael Kors','michael-kors','Fashion accessories',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(50,'L\'Oréal','loreal','Beauty and cosmetics',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(51,'Estée Lauder','estee-lauder','Cosmetics and skincare',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(52,'MAC','mac','Cosmetics',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(53,'Clinique','clinique','Skincare and cosmetics',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(54,'Lancôme','lancome','Luxury beauty',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(55,'Maybelline','maybelline','Cosmetics',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(56,'Revlon','revlon','Beauty products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(57,'NYX','nyx','Cosmetics',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(58,'Dove','dove','Personal care',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(59,'Nivea','nivea','Skincare products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(60,'Olay','olay','Skincare',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(61,'Neutrogena','neutrogena','Skincare products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(62,'KitchenAid','kitchenaid','Kitchen appliances',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(63,'Cuisinart','cuisinart','Kitchen products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(64,'Ninja','ninja','Kitchen appliances',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(65,'Instant Pot','instant-pot','Pressure cookers',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(66,'Dyson','dyson','Vacuum cleaners and appliances',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(67,'Roomba','roomba','Robot vacuums',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(68,'Shark','shark','Cleaning products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(69,'Bissell','bissell','Cleaning equipment',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(70,'IKEA','ikea','Furniture and home goods',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(71,'Wayfair','wayfair','Home furnishings',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(72,'The North Face','the-north-face','Outdoor apparel',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(73,'Patagonia','patagonia','Outdoor clothing',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(74,'Columbia','columbia','Outdoor apparel',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(75,'REI','rei','Outdoor gear',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(76,'Yeti','yeti','Outdoor products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(77,'GoPro','gopro','Action cameras',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(78,'Garmin','garmin','GPS and fitness devices',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(79,'Fitbit','fitbit','Fitness trackers',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(80,'Peloton','peloton','Fitness equipment',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(81,'Wilson','wilson','Sports equipment',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(82,'Spalding','spalding','Sports balls',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(83,'Titleist','titleist','Golf equipment',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(84,'Callaway','callaway','Golf equipment',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(85,'Bosch','bosch','Auto parts and tools',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(86,'Michelin','michelin','Tires',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(87,'Goodyear','goodyear','Tires',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(88,'Bridgestone','bridgestone','Tires',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(89,'Castrol','castrol','Motor oil',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(90,'Mobil','mobil','Motor oil',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(91,'Fisher-Price','fisher-price','Toys and baby products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(92,'Lego','lego','Building toys',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(93,'Mattel','mattel','Toys',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(94,'Hasbro','hasbro','Toys and games',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(95,'Pampers','pampers','Baby care',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(96,'Huggies','huggies','Baby care',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(97,'Graco','graco','Baby products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(98,'Chicco','chicco','Baby products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(99,'Coca-Cola','coca-cola','Beverages',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(100,'Pepsi','pepsi','Beverages',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(101,'Nestlé','nestle','Food and beverages',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(102,'Kraft','kraft','Food products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(103,'Kellogg\'s','kelloggs','Cereals and snacks',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(104,'General Mills','general-mills','Food products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(105,'DeWalt','dewalt','Power tools',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(106,'Black & Decker','black-decker','Tools and appliances',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(107,'Makita','makita','Power tools',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(108,'Milwaukee','milwaukee','Power tools',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(109,'Stanley','stanley','Hand tools',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(110,'Craftsman','craftsman','Tools',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(111,'Pfizer','pfizer','Pharmaceuticals',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(112,'Johnson & Johnson','johnson-johnson','Healthcare products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(113,'Bayer','bayer','Pharmaceuticals',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(114,'Abbott','abbott','Healthcare',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(115,'GNC','gnc','Nutritional supplements',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(116,'Optimum Nutrition','optimum-nutrition','Sports nutrition',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(117,'Staples','staples','Office supplies',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(118,'Sharpie','sharpie','Markers and writing instruments',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(119,'Post-it','post-it','Sticky notes',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(120,'Scotch','scotch','Adhesive products',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(121,'Moleskine','moleskine','Notebooks',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(122,'Parker','parker','Pens',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(123,'Rolex','rolex','Luxury watches',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(124,'Omega','omega','Luxury watches',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(125,'Seiko','seiko','Watches',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(126,'Casio','casio','Watches and electronics',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(127,'Fossil','fossil','Watches and accessories',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(128,'Tiffany & Co.','tiffany-co','Luxury jewelry',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(129,'Pandora','pandora','Jewelry',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(130,'Swarovski','swarovski','Crystal jewelry',NULL,NULL,1,'2025-10-04 10:22:18','2025-10-04 10:22:18',NULL,0),
(131,'NA','na','Added by seller',NULL,NULL,1,'2025-10-13 09:08:27','2025-10-13 09:08:27',NULL,0),
(132,'AND1','and1','Added by seller',NULL,NULL,1,'2025-10-13 09:13:47','2025-10-13 09:13:47',NULL,0),
(133,'Generic','generic',NULL,NULL,NULL,1,'2025-10-15 19:18:24','2025-10-15 19:18:24',NULL,0),
(134,'FezaMarket','fezamarket',NULL,NULL,NULL,1,'2025-10-15 19:18:24','2025-10-15 19:18:24',NULL,1);
/*!40000 ALTER TABLE `brands` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_addresses`
--

DROP TABLE IF EXISTS `buyer_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `label` varchar(50) DEFAULT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `company` varchar(100) DEFAULT NULL,
  `address_line1` varchar(255) NOT NULL,
  `address_line2` varchar(255) DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `country` varchar(2) NOT NULL DEFAULT 'US',
  `phone` varchar(20) DEFAULT NULL,
  `is_default_billing` tinyint(1) NOT NULL DEFAULT 0,
  `is_default_shipping` tinyint(1) NOT NULL DEFAULT 0,
  `delivery_instructions` text DEFAULT NULL,
  `access_code` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_buyer` (`buyer_id`),
  KEY `idx_defaults` (`is_default_billing`,`is_default_shipping`),
  CONSTRAINT `fk_buyer_addresses_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_addresses`
--

LOCK TABLES `buyer_addresses` WRITE;
/*!40000 ALTER TABLE `buyer_addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_consents`
--

DROP TABLE IF EXISTS `buyer_consents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_consents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `consent_type` enum('marketing','analytics','functional','necessary','data_processing','third_party_sharing') NOT NULL,
  `consent_given` tinyint(1) NOT NULL,
  `consent_method` enum('checkbox','opt_in','opt_out','implicit','legal_basis') NOT NULL,
  `legal_basis` varchar(255) DEFAULT NULL,
  `consent_text` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `withdrawn_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_buyer_type` (`buyer_id`,`consent_type`),
  KEY `idx_consent_given` (`consent_given`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_buyer_consents_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_consents`
--

LOCK TABLES `buyer_consents` WRITE;
/*!40000 ALTER TABLE `buyer_consents` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_consents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_dispute_evidence`
--

DROP TABLE IF EXISTS `buyer_dispute_evidence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_dispute_evidence` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dispute_id` int(11) NOT NULL,
  `submitted_by` int(11) NOT NULL,
  `evidence_type` enum('document','image','email','communication','tracking','receipt','screenshot') NOT NULL,
  `file_path` varchar(500) DEFAULT NULL,
  `description` text NOT NULL,
  `submission_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dispute` (`dispute_id`),
  KEY `idx_submission_date` (`submission_date`),
  KEY `fk_buyer_dispute_evidence_user` (`submitted_by`),
  CONSTRAINT `fk_buyer_dispute_evidence_dispute` FOREIGN KEY (`dispute_id`) REFERENCES `buyer_disputes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_dispute_evidence_user` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_dispute_evidence`
--

LOCK TABLES `buyer_dispute_evidence` WRITE;
/*!40000 ALTER TABLE `buyer_dispute_evidence` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_dispute_evidence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_dispute_messages`
--

DROP TABLE IF EXISTS `buyer_dispute_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_dispute_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dispute_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `sender_type` enum('buyer','seller','admin','system') NOT NULL,
  `message` text NOT NULL,
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
  `is_internal` tinyint(1) NOT NULL DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dispute` (`dispute_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_buyer_dispute_messages_sender` (`sender_id`),
  CONSTRAINT `fk_buyer_dispute_messages_dispute` FOREIGN KEY (`dispute_id`) REFERENCES `buyer_disputes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_dispute_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_dispute_messages`
--

LOCK TABLES `buyer_dispute_messages` WRITE;
/*!40000 ALTER TABLE `buyer_dispute_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_dispute_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_disputes`
--

DROP TABLE IF EXISTS `buyer_disputes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_disputes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) NOT NULL,
  `dispute_number` varchar(50) NOT NULL,
  `type` enum('chargeback','refund_request','product_issue','service_issue','payment_issue','fraud') NOT NULL,
  `status` enum('open','under_review','awaiting_response','resolved','escalated','closed') NOT NULL DEFAULT 'open',
  `amount_disputed` decimal(10,2) NOT NULL,
  `claim_description` text NOT NULL,
  `desired_resolution` text DEFAULT NULL,
  `evidence_provided` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`evidence_provided`)),
  `resolution` text DEFAULT NULL,
  `resolved_by` int(11) DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `deadline` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `dispute_number` (`dispute_number`),
  KEY `idx_buyer_status` (`buyer_id`,`status`),
  KEY `idx_order` (`order_id`),
  KEY `idx_vendor` (`vendor_id`),
  KEY `idx_deadline` (`deadline`),
  KEY `fk_buyer_disputes_resolver` (`resolved_by`),
  CONSTRAINT `fk_buyer_disputes_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_disputes_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_buyer_disputes_resolver` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_buyer_disputes_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_disputes`
--

LOCK TABLES `buyer_disputes` WRITE;
/*!40000 ALTER TABLE `buyer_disputes` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_disputes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_dsr_requests`
--

DROP TABLE IF EXISTS `buyer_dsr_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_dsr_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `request_type` enum('access','portability','rectification','erasure','restrict_processing','object_processing') NOT NULL,
  `status` enum('received','in_progress','completed','rejected','cancelled') NOT NULL DEFAULT 'received',
  `request_details` text DEFAULT NULL,
  `verification_method` enum('email','phone','document','in_person') DEFAULT NULL,
  `verification_completed` tinyint(1) NOT NULL DEFAULT 0,
  `verification_date` timestamp NULL DEFAULT NULL,
  `completion_date` timestamp NULL DEFAULT NULL,
  `response_method` enum('email','download','mail','in_person') DEFAULT NULL,
  `response_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`response_data`)),
  `rejection_reason` text DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_buyer_status` (`buyer_id`,`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_processed_by` (`processed_by`),
  CONSTRAINT `fk_buyer_dsr_requests_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_dsr_requests_processor` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_dsr_requests`
--

LOCK TABLES `buyer_dsr_requests` WRITE;
/*!40000 ALTER TABLE `buyer_dsr_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_dsr_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_kpis`
--

DROP TABLE IF EXISTS `buyer_kpis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_kpis` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `metric_date` date NOT NULL,
  `orders_count` int(11) NOT NULL DEFAULT 0,
  `total_spent` decimal(15,2) NOT NULL DEFAULT 0.00,
  `avg_order_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `returns_count` int(11) NOT NULL DEFAULT 0,
  `loyalty_points_earned` int(11) NOT NULL DEFAULT 0,
  `loyalty_points_spent` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `buyer_date` (`buyer_id`,`metric_date`),
  KEY `idx_metric_date` (`metric_date`),
  CONSTRAINT `fk_buyer_kpis_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_kpis`
--

LOCK TABLES `buyer_kpis` WRITE;
/*!40000 ALTER TABLE `buyer_kpis` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_kpis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_loyalty_accounts`
--

DROP TABLE IF EXISTS `buyer_loyalty_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_loyalty_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `program_name` varchar(100) NOT NULL DEFAULT 'main',
  `current_points` int(11) NOT NULL DEFAULT 0,
  `lifetime_points` int(11) NOT NULL DEFAULT 0,
  `tier` enum('bronze','silver','gold','platinum','diamond') NOT NULL DEFAULT 'bronze',
  `tier_progress` decimal(5,2) NOT NULL DEFAULT 0.00,
  `next_tier_threshold` int(11) DEFAULT NULL,
  `tier_expiry` timestamp NULL DEFAULT NULL,
  `status` enum('active','inactive','suspended') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `buyer_program` (`buyer_id`,`program_name`),
  KEY `idx_tier` (`tier`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_buyer_loyalty_accounts_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_loyalty_accounts`
--

LOCK TABLES `buyer_loyalty_accounts` WRITE;
/*!40000 ALTER TABLE `buyer_loyalty_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_loyalty_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_loyalty_ledger`
--

DROP TABLE IF EXISTS `buyer_loyalty_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_loyalty_ledger` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `loyalty_account_id` int(11) NOT NULL,
  `transaction_type` enum('earned','redeemed','expired','adjusted','bonus','refund') NOT NULL,
  `points` int(11) NOT NULL,
  `balance_after` int(11) NOT NULL,
  `reference_type` enum('order','review','referral','birthday','bonus','redemption','expiration','adjustment') DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `description` varchar(500) NOT NULL,
  `expiry_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_loyalty_account` (`loyalty_account_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_expiry_date` (`expiry_date`),
  KEY `idx_reference` (`reference_type`,`reference_id`),
  CONSTRAINT `fk_buyer_loyalty_ledger_account` FOREIGN KEY (`loyalty_account_id`) REFERENCES `buyer_loyalty_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_loyalty_ledger`
--

LOCK TABLES `buyer_loyalty_ledger` WRITE;
/*!40000 ALTER TABLE `buyer_loyalty_ledger` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_loyalty_ledger` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_messages`
--

DROP TABLE IF EXISTS `buyer_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `conversation_id` varchar(50) NOT NULL,
  `sender_type` enum('buyer','seller','admin','system') NOT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `message_type` enum('text','image','file','system') NOT NULL DEFAULT 'text',
  `content` text NOT NULL,
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_buyer_conversation` (`buyer_id`,`conversation_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_read_at` (`read_at`),
  KEY `fk_buyer_messages_sender` (`sender_id`),
  CONSTRAINT `fk_buyer_messages_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_messages`
--

LOCK TABLES `buyer_messages` WRITE;
/*!40000 ALTER TABLE `buyer_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_notifications`
--

DROP TABLE IF EXISTS `buyer_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `type` enum('order','shipping','delivery','promotion','wishlist','loyalty','system') NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `read_at` timestamp NULL DEFAULT NULL,
  `action_url` varchar(500) DEFAULT NULL,
  `priority` enum('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_buyer_read` (`buyer_id`,`read_at`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_buyer_notifications_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_notifications`
--

LOCK TABLES `buyer_notifications` WRITE;
/*!40000 ALTER TABLE `buyer_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_orders`
--

DROP TABLE IF EXISTS `buyer_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `status` enum('pending','confirmed','processing','shipped','delivered','cancelled','refunded') NOT NULL,
  `tracking_preference` enum('email','sms','push','all') NOT NULL DEFAULT 'email',
  `delivery_instructions` text DEFAULT NULL,
  `special_requests` text DEFAULT NULL,
  `rating` tinyint(1) DEFAULT NULL,
  `review` text DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `can_cancel` tinyint(1) NOT NULL DEFAULT 1,
  `can_return` tinyint(1) NOT NULL DEFAULT 1,
  `return_deadline` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `buyer_order` (`buyer_id`,`order_id`),
  KEY `idx_status` (`status`),
  KEY `idx_rating` (`rating`),
  KEY `fk_buyer_orders_order` (`order_id`),
  CONSTRAINT `fk_buyer_orders_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_orders_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_orders`
--

LOCK TABLES `buyer_orders` WRITE;
/*!40000 ALTER TABLE `buyer_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_payment_methods`
--

DROP TABLE IF EXISTS `buyer_payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_payment_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `type` enum('card','paypal','bank_account','crypto','mobile_money','buy_now_pay_later') NOT NULL,
  `provider` varchar(50) NOT NULL,
  `last_four` varchar(4) DEFAULT NULL,
  `brand` varchar(50) DEFAULT NULL,
  `exp_month` tinyint(2) DEFAULT NULL,
  `exp_year` smallint(4) DEFAULT NULL,
  `billing_address_id` int(11) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `token` varchar(255) NOT NULL,
  `fingerprint` varchar(100) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_buyer` (`buyer_id`),
  KEY `idx_is_default` (`is_default`),
  KEY `idx_fingerprint` (`fingerprint`),
  KEY `fk_buyer_payment_methods_address` (`billing_address_id`),
  CONSTRAINT `fk_buyer_payment_methods_address` FOREIGN KEY (`billing_address_id`) REFERENCES `buyer_addresses` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_buyer_payment_methods_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_payment_methods`
--

LOCK TABLES `buyer_payment_methods` WRITE;
/*!40000 ALTER TABLE `buyer_payment_methods` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_preferences`
--

DROP TABLE IF EXISTS `buyer_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `category` varchar(100) NOT NULL,
  `preference_key` varchar(100) NOT NULL,
  `preference_value` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `buyer_category_key` (`buyer_id`,`category`,`preference_key`),
  CONSTRAINT `fk_buyer_preferences_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_preferences`
--

LOCK TABLES `buyer_preferences` WRITE;
/*!40000 ALTER TABLE `buyer_preferences` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_profiles`
--

DROP TABLE IF EXISTS `buyer_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `display_name` varchar(100) DEFAULT NULL,
  `avatar_url` varchar(500) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other','prefer_not_to_say') DEFAULT NULL,
  `phone_verified` tinyint(1) NOT NULL DEFAULT 0,
  `email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `two_factor_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `privacy_settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`privacy_settings`)),
  `notification_preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`notification_preferences`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `buyer_id` (`buyer_id`),
  CONSTRAINT `fk_buyer_profiles_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_profiles`
--

LOCK TABLES `buyer_profiles` WRITE;
/*!40000 ALTER TABLE `buyer_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_rma_messages`
--

DROP TABLE IF EXISTS `buyer_rma_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_rma_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rma_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `sender_type` enum('buyer','seller','admin','system') NOT NULL,
  `message` text NOT NULL,
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_rma` (`rma_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_buyer_rma_messages_sender` (`sender_id`),
  CONSTRAINT `fk_buyer_rma_messages_rma` FOREIGN KEY (`rma_id`) REFERENCES `buyer_rmas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_rma_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_rma_messages`
--

LOCK TABLES `buyer_rma_messages` WRITE;
/*!40000 ALTER TABLE `buyer_rma_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_rma_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_rmas`
--

DROP TABLE IF EXISTS `buyer_rmas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_rmas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `rma_number` varchar(50) NOT NULL,
  `reason` enum('defective','wrong_item','damaged','not_as_described','change_of_mind','warranty') NOT NULL,
  `status` enum('requested','approved','rejected','shipped','received','refunded','completed') NOT NULL DEFAULT 'requested',
  `return_value` decimal(10,2) NOT NULL,
  `refund_amount` decimal(10,2) DEFAULT NULL,
  `return_tracking` varchar(100) DEFAULT NULL,
  `return_label_url` varchar(500) DEFAULT NULL,
  `customer_notes` text DEFAULT NULL,
  `photos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`photos`)),
  `approved_at` timestamp NULL DEFAULT NULL,
  `shipped_at` timestamp NULL DEFAULT NULL,
  `received_at` timestamp NULL DEFAULT NULL,
  `refunded_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `rma_number` (`rma_number`),
  KEY `idx_buyer_status` (`buyer_id`,`status`),
  KEY `idx_order` (`order_id`),
  KEY `idx_vendor` (`vendor_id`),
  CONSTRAINT `fk_buyer_rmas_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_rmas_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_rmas_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_rmas`
--

LOCK TABLES `buyer_rmas` WRITE;
/*!40000 ALTER TABLE `buyer_rmas` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_rmas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_subscriptions`
--

DROP TABLE IF EXISTS `buyer_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `subscription_type` enum('newsletter','product_updates','price_alerts','promotions','order_updates','security_alerts') NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `status` enum('active','paused','unsubscribed') NOT NULL DEFAULT 'active',
  `preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`preferences`)),
  `subscribed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `buyer_type_category_vendor` (`buyer_id`,`subscription_type`,`category`,`vendor_id`),
  KEY `idx_status` (`status`),
  KEY `fk_buyer_subscriptions_vendor` (`vendor_id`),
  CONSTRAINT `fk_buyer_subscriptions_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_subscriptions_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_subscriptions`
--

LOCK TABLES `buyer_subscriptions` WRITE;
/*!40000 ALTER TABLE `buyer_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_ticket_replies`
--

DROP TABLE IF EXISTS `buyer_ticket_replies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_ticket_replies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ticket_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `sender_type` enum('buyer','agent','system') NOT NULL,
  `message` text NOT NULL,
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
  `is_internal` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_ticket` (`ticket_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_buyer_ticket_replies_sender` (`sender_id`),
  CONSTRAINT `fk_buyer_ticket_replies_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_ticket_replies_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `buyer_tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_ticket_replies`
--

LOCK TABLES `buyer_ticket_replies` WRITE;
/*!40000 ALTER TABLE `buyer_ticket_replies` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_ticket_replies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_tickets`
--

DROP TABLE IF EXISTS `buyer_tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `ticket_number` varchar(50) NOT NULL,
  `category` enum('order_issue','product_issue','payment_issue','account_issue','technical_issue','general_inquiry') NOT NULL,
  `priority` enum('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `status` enum('open','in_progress','waiting_customer','resolved','closed') NOT NULL DEFAULT 'open',
  `subject` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
  `assigned_to` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `first_response_at` timestamp NULL DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `satisfaction_rating` tinyint(1) DEFAULT NULL,
  `satisfaction_comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `ticket_number` (`ticket_number`),
  KEY `idx_buyer_status` (`buyer_id`,`status`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `idx_category` (`category`),
  KEY `fk_buyer_tickets_order` (`order_id`),
  KEY `fk_buyer_tickets_product` (`product_id`),
  CONSTRAINT `fk_buyer_tickets_assignee` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_buyer_tickets_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_tickets_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_buyer_tickets_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_tickets`
--

LOCK TABLES `buyer_tickets` WRITE;
/*!40000 ALTER TABLE `buyer_tickets` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_tracking`
--

DROP TABLE IF EXISTS `buyer_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_tracking` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_order_id` int(11) NOT NULL,
  `tracking_number` varchar(100) NOT NULL,
  `carrier` varchar(100) NOT NULL,
  `status` enum('label_created','picked_up','in_transit','out_for_delivery','delivered','exception','returned') NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `estimated_delivery` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `tracking_events` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tracking_events`)),
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_buyer_order` (`buyer_order_id`),
  KEY `idx_tracking_number` (`tracking_number`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_buyer_tracking_buyer_order` FOREIGN KEY (`buyer_order_id`) REFERENCES `buyer_orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_tracking`
--

LOCK TABLES `buyer_tracking` WRITE;
/*!40000 ALTER TABLE `buyer_tracking` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_tracking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_wallet_entries`
--

DROP TABLE IF EXISTS `buyer_wallet_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_wallet_entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wallet_id` int(11) NOT NULL,
  `transaction_type` enum('credit','debit','refund','cashback','loyalty_conversion','adjustment') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `balance_after` decimal(15,2) NOT NULL,
  `reference_type` enum('order','refund','cashback','loyalty','promotion','adjustment') DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `description` varchar(500) NOT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_wallet` (`wallet_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_reference` (`reference_type`,`reference_id`),
  CONSTRAINT `fk_buyer_wallet_entries_wallet` FOREIGN KEY (`wallet_id`) REFERENCES `buyer_wallets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_wallet_entries`
--

LOCK TABLES `buyer_wallet_entries` WRITE;
/*!40000 ALTER TABLE `buyer_wallet_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_wallet_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_wallets`
--

DROP TABLE IF EXISTS `buyer_wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_wallets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `currency` varchar(3) NOT NULL DEFAULT 'USD',
  `status` enum('active','suspended','frozen') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `buyer_currency` (`buyer_id`,`currency`),
  CONSTRAINT `fk_buyer_wallets_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_wallets`
--

LOCK TABLES `buyer_wallets` WRITE;
/*!40000 ALTER TABLE `buyer_wallets` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_wallets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_wishlist`
--

DROP TABLE IF EXISTS `buyer_wishlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_wishlist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `buyer_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `variant_info` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`variant_info`)),
  `list_name` varchar(100) NOT NULL DEFAULT 'default',
  `notes` text DEFAULT NULL,
  `privacy` enum('private','public','friends') NOT NULL DEFAULT 'private',
  `priority` enum('low','medium','high') NOT NULL DEFAULT 'medium',
  `price_alert_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `target_price` decimal(10,2) DEFAULT NULL,
  `stock_alert_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `added_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `buyer_product_list` (`buyer_id`,`product_id`,`list_name`),
  KEY `idx_list_name` (`list_name`),
  KEY `idx_privacy` (`privacy`),
  KEY `idx_price_alert` (`price_alert_enabled`,`target_price`),
  KEY `fk_buyer_wishlist_product` (`product_id`),
  CONSTRAINT `fk_buyer_wishlist_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `buyers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_buyer_wishlist_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_wishlist`
--

LOCK TABLES `buyer_wishlist` WRITE;
/*!40000 ALTER TABLE `buyer_wishlist` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_wishlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyer_wishlist_alerts`
--

DROP TABLE IF EXISTS `buyer_wishlist_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyer_wishlist_alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wishlist_id` int(11) NOT NULL,
  `alert_type` enum('price_drop','back_in_stock','sale','discontinued') NOT NULL,
  `triggered_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `old_value` varchar(255) DEFAULT NULL,
  `new_value` varchar(255) DEFAULT NULL,
  `notification_sent` tinyint(1) NOT NULL DEFAULT 0,
  `notification_sent_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_wishlist` (`wishlist_id`),
  KEY `idx_triggered_at` (`triggered_at`),
  CONSTRAINT `fk_buyer_wishlist_alerts_wishlist` FOREIGN KEY (`wishlist_id`) REFERENCES `buyer_wishlist` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyer_wishlist_alerts`
--

LOCK TABLES `buyer_wishlist_alerts` WRITE;
/*!40000 ALTER TABLE `buyer_wishlist_alerts` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyer_wishlist_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `buyers`
--

DROP TABLE IF EXISTS `buyers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `buyers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `tier` enum('bronze','silver','gold','platinum','diamond') NOT NULL DEFAULT 'bronze',
  `total_spent` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_orders` int(11) NOT NULL DEFAULT 0,
  `loyalty_points` int(11) NOT NULL DEFAULT 0,
  `preferred_language` varchar(5) DEFAULT 'en',
  `preferred_currency` varchar(3) DEFAULT 'USD',
  `marketing_consent` tinyint(1) NOT NULL DEFAULT 0,
  `data_processing_consent` tinyint(1) NOT NULL DEFAULT 0,
  `last_activity` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_tier` (`tier`),
  KEY `idx_last_activity` (`last_activity`),
  CONSTRAINT `fk_buyers_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `buyers`
--

LOCK TABLES `buyers` WRITE;
/*!40000 ALTER TABLE `buyers` DISABLE KEYS */;
/*!40000 ALTER TABLE `buyers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_assets`
--

DROP TABLE IF EXISTS `campaign_assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `campaign_assets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `asset_type` enum('image','video','html','text','banner') NOT NULL,
  `asset_name` varchar(255) NOT NULL,
  `file_path` varchar(500) DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `alt_text` varchar(255) DEFAULT NULL,
  `click_url` varchar(500) DEFAULT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT 0,
  `a_b_test_variant` varchar(50) DEFAULT NULL,
  `performance_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`performance_data`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_campaign_id` (`campaign_id`),
  KEY `idx_asset_type` (`asset_type`),
  KEY `idx_is_primary` (`is_primary`),
  CONSTRAINT `fk_campaign_assets_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `campaigns` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_assets`
--

LOCK TABLES `campaign_assets` WRITE;
/*!40000 ALTER TABLE `campaign_assets` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_messages`
--

DROP TABLE IF EXISTS `campaign_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `campaign_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `message_id` int(11) NOT NULL,
  `send_time` timestamp NULL DEFAULT NULL,
  `status` enum('scheduled','sent','failed','cancelled') NOT NULL DEFAULT 'scheduled',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_campaign_message` (`campaign_id`,`message_id`),
  KEY `idx_campaign_id` (`campaign_id`),
  KEY `idx_message_id` (`message_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_campaign_messages_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `campaigns` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_campaign_messages_message` FOREIGN KEY (`message_id`) REFERENCES `comm_messages` (`message_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_messages`
--

LOCK TABLES `campaign_messages` WRITE;
/*!40000 ALTER TABLE `campaign_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_products`
--

DROP TABLE IF EXISTS `campaign_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `campaign_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_campaign_product_vendor` (`campaign_id`,`product_id`,`vendor_id`),
  KEY `idx_campaign_id` (`campaign_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_joined_at` (`joined_at`),
  CONSTRAINT `fk_campaign_products_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `marketing_campaigns` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_campaign_products_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_campaign_products_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_products`
--

LOCK TABLES `campaign_products` WRITE;
/*!40000 ALTER TABLE `campaign_products` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_recipients`
--

DROP TABLE IF EXISTS `campaign_recipients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `campaign_recipients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `status` enum('sent','failed') NOT NULL DEFAULT 'sent',
  `opened_at` datetime DEFAULT NULL,
  `clicked_at` datetime DEFAULT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `campaign_user` (`campaign_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `campaign_recipients_ibfk_1` FOREIGN KEY (`campaign_id`) REFERENCES `marketing_campaigns` (`id`) ON DELETE CASCADE,
  CONSTRAINT `campaign_recipients_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_recipients`
--

LOCK TABLES `campaign_recipients` WRITE;
/*!40000 ALTER TABLE `campaign_recipients` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_recipients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_stats`
--

DROP TABLE IF EXISTS `campaign_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `campaign_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `metric_date` date NOT NULL,
  `impressions` int(11) NOT NULL DEFAULT 0,
  `clicks` int(11) NOT NULL DEFAULT 0,
  `conversions` int(11) NOT NULL DEFAULT 0,
  `revenue` decimal(10,2) NOT NULL DEFAULT 0.00,
  `cost` decimal(10,2) NOT NULL DEFAULT 0.00,
  `reach` int(11) NOT NULL DEFAULT 0,
  `engagement_rate` decimal(5,4) NOT NULL DEFAULT 0.0000,
  `click_through_rate` decimal(5,4) NOT NULL DEFAULT 0.0000,
  `conversion_rate` decimal(5,4) NOT NULL DEFAULT 0.0000,
  `return_on_ad_spend` decimal(8,4) NOT NULL DEFAULT 0.0000,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_campaign_date` (`campaign_id`,`metric_date`),
  KEY `idx_metric_date` (`metric_date`),
  CONSTRAINT `fk_campaign_stats_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `campaigns` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_stats`
--

LOCK TABLES `campaign_stats` WRITE;
/*!40000 ALTER TABLE `campaign_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaign_targets`
--

DROP TABLE IF EXISTS `campaign_targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `campaign_targets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `target_type` enum('user','segment','category','product','location') NOT NULL,
  `target_criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`target_criteria`)),
  `estimated_reach` int(11) DEFAULT NULL,
  `actual_reach` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_campaign_id` (`campaign_id`),
  KEY `idx_target_type` (`target_type`),
  CONSTRAINT `fk_campaign_targets_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `campaigns` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaign_targets`
--

LOCK TABLES `campaign_targets` WRITE;
/*!40000 ALTER TABLE `campaign_targets` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaign_targets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campaigns`
--

DROP TABLE IF EXISTS `campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `campaigns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `campaign_type` enum('email','social','banner','flash_sale','push','sms','affiliate') NOT NULL,
  `status` enum('draft','scheduled','active','paused','completed','cancelled') NOT NULL DEFAULT 'draft',
  `budget` decimal(10,2) DEFAULT NULL,
  `spent_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `target_audience` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`target_audience`)),
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `automation_rules` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`automation_rules`)),
  `tracking_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tracking_data`)),
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_campaign_type` (`campaign_type`),
  KEY `idx_status` (`status`),
  KEY `idx_start_date` (`start_date`),
  KEY `idx_end_date` (`end_date`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_campaigns_type_status_dates` (`campaign_type`,`status`,`start_date`,`end_date`),
  CONSTRAINT `fk_campaigns_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campaigns`
--

LOCK TABLES `campaigns` WRITE;
/*!40000 ALTER TABLE `campaigns` DISABLE KEYS */;
/*!40000 ALTER TABLE `campaigns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `canned_responses`
--

DROP TABLE IF EXISTS `canned_responses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `canned_responses` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `tags` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `usage_count` int(11) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_canned_responses_category` (`category`),
  KEY `idx_canned_responses_active` (`is_active`),
  KEY `idx_canned_responses_creator` (`created_by`),
  CONSTRAINT `fk_canned_responses_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `canned_responses`
--

LOCK TABLES `canned_responses` WRITE;
/*!40000 ALTER TABLE `canned_responses` DISABLE KEYS */;
/*!40000 ALTER TABLE `canned_responses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `price` decimal(10,2) NOT NULL,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
  `session_id` varchar(128) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_product` (`user_id`,`product_id`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_cart_product` (`product_id`),
  CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart`
--

LOCK TABLES `cart` WRITE;
/*!40000 ALTER TABLE `cart` DISABLE KEYS */;
INSERT INTO `cart` VALUES
(47,4,13,8,18.00,NULL,NULL,'2025-10-14 11:02:30','2025-10-15 22:39:54'),
(48,4,10,1,159.99,NULL,NULL,'2025-10-14 14:31:02','2025-10-14 14:31:02');
/*!40000 ALTER TABLE `cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `slug` varchar(120) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_slug` (`slug`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_status` (`status`),
  KEY `idx_sort_order` (`sort_order`),
  CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1504 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES
(1,'Electronics','Electronic devices and accessories',NULL,'electronics',NULL,1,1,'active','','','2025-09-14 19:54:24','2025-09-14 20:04:01'),
(2,'Clothing & Fashion','Apparel and fashion accessories',NULL,'clothing-fashion',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(3,'Home & Garden','Home improvement and garden supplies',NULL,'home-garden',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(4,'Sports & Outdoors','Sports equipment and outdoor gear',NULL,'sports-outdoors',NULL,4,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(5,'Books & Media','Books, movies, music and digital media',NULL,'books-media',NULL,5,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(6,'Health & Beauty','Health products and beauty supplies',NULL,'health-beauty',NULL,6,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(7,'Toys & Games','Toys, games and hobby supplies',NULL,'toys-games',NULL,7,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(8,'Automotive','Car parts and automotive accessories',NULL,'automotive',NULL,8,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(9,'Food & Beverages','Food items and beverages',NULL,'food-beverages',NULL,9,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(10,'Baby & Kids','Baby products and children supplies',NULL,'baby-kids',NULL,10,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(11,'Office & Business','Office supplies and business equipment',NULL,'office-business',NULL,11,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(12,'Pet Supplies','Pet food, toys and accessories',NULL,'pet-supplies',NULL,12,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(13,'Arts & Crafts','Art supplies and crafting materials',NULL,'arts-crafts',NULL,13,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(14,'Travel & Luggage','Travel accessories and luggage',NULL,'travel-luggage',NULL,14,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(15,'Music & Instruments','Musical instruments and equipment',NULL,'music-instruments',NULL,15,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(101,'Smartphones','Mobile phones and smartphones',1,'smartphones',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(102,'Laptops & Computers','Laptops, desktops and computer parts',1,'laptops-computers',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(103,'Tablets','Tablet computers and e-readers',1,'tablets',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(104,'TV & Audio','Televisions and audio equipment',1,'tv-audio',NULL,4,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(105,'Cameras','Digital cameras and photography equipment',1,'cameras',NULL,5,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(106,'Gaming','Video game consoles and accessories',1,'gaming',NULL,6,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(107,'Wearable Tech','Smartwatches and fitness trackers',1,'wearable-tech',NULL,7,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(108,'Home Electronics','Small appliances and home tech',1,'home-electronics',NULL,8,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(201,'Men\'s Clothing','Clothing for men',2,'mens-clothing',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(202,'Women\'s Clothing','Clothing for women',2,'womens-clothing',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(203,'Shoes','Footwear for all occasions',2,'shoes',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(204,'Accessories','Fashion accessories and jewelry',2,'accessories',NULL,4,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(205,'Bags & Luggage','Handbags, backpacks and travel bags',2,'bags-luggage',NULL,5,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(206,'Watches','Wristwatches and timepieces',2,'watches',NULL,6,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(207,'Sunglasses','Sunglasses and eyewear',2,'sunglasses',NULL,7,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(301,'Furniture','Home and office furniture',3,'furniture',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(302,'Kitchen & Dining','Kitchen appliances and dining ware',3,'kitchen-dining',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(303,'Bedding & Bath','Bedding, towels and bathroom accessories',3,'bedding-bath',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(304,'Home Decor','Decorative items and artwork',3,'home-decor',NULL,4,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(305,'Garden & Outdoor','Gardening tools and outdoor furniture',3,'garden-outdoor',NULL,5,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(306,'Lighting','Lamps and lighting fixtures',3,'lighting',NULL,6,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(307,'Storage & Organization','Storage solutions and organizers',3,'storage-organization',NULL,7,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(401,'Fitness Equipment','Exercise and fitness gear',4,'fitness-equipment',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(402,'Team Sports','Equipment for team sports',4,'team-sports',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(403,'Outdoor Recreation','Camping, hiking and outdoor gear',4,'outdoor-recreation',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(404,'Water Sports','Swimming and water activity gear',4,'water-sports',NULL,4,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(405,'Winter Sports','Skiing, snowboarding and winter gear',4,'winter-sports',NULL,5,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(406,'Athletic Wear','Sports clothing and footwear',4,'athletic-wear',NULL,6,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(501,'Books','Physical and digital books',5,'books',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(502,'Movies & TV','DVDs, Blu-rays and digital movies',5,'movies-tv',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(503,'Music','CDs, vinyl and digital music',5,'music',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(504,'Magazines','Magazine subscriptions and back issues',5,'magazines',NULL,4,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(505,'Video Games','Game software and digital downloads',5,'video-games',NULL,5,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(601,'Skincare','Facial care and skin treatments',6,'skincare',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(602,'Makeup','Cosmetics and beauty products',6,'makeup',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(603,'Hair Care','Shampoo, conditioner and styling products',6,'hair-care',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(604,'Personal Care','Personal hygiene and grooming products',6,'personal-care',NULL,4,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(605,'Vitamins & Supplements','Health supplements and vitamins',6,'vitamins-supplements',NULL,5,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(606,'Fragrances','Perfumes and colognes',6,'fragrances',NULL,6,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(701,'Action Figures','Action figures and collectibles',7,'action-figures',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(702,'Board Games','Board games and card games',7,'board-games',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(703,'Building Sets','LEGO and construction toys',7,'building-sets',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(704,'Dolls & Accessories','Dolls and doll accessories',7,'dolls-accessories',NULL,4,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(705,'Educational Toys','Learning and educational toys',7,'educational-toys',NULL,5,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(706,'Outdoor Toys','Outdoor play equipment',7,'outdoor-toys',NULL,6,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(801,'Car Parts','Replacement parts and accessories',8,'car-parts',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(802,'Car Electronics','GPS, stereos and car electronics',8,'car-electronics',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(803,'Motorcycles','Motorcycle parts and accessories',8,'motorcycles',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(901,'Snacks','Snack foods and treats',9,'snacks',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(902,'Beverages','Drinks and beverages',9,'beverages',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(903,'Gourmet Foods','Specialty and gourmet food items',9,'gourmet-foods',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1001,'Baby Clothing','Clothing for babies and toddlers',10,'baby-clothing',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1002,'Baby Gear','Strollers, car seats and baby equipment',10,'baby-gear',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1003,'Baby Feeding','Bottles, high chairs and feeding supplies',10,'baby-feeding',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1101,'Office Supplies','Pens, paper and office essentials',11,'office-supplies',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1102,'Office Furniture','Desks, chairs and office furniture',11,'office-furniture',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1201,'Dog Supplies','Food, toys and accessories for dogs',12,'dog-supplies',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1202,'Cat Supplies','Food, toys and accessories for cats',12,'cat-supplies',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1203,'Small Pet Supplies','Supplies for birds, fish and small pets',12,'small-pet-supplies',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1301,'Painting Supplies','Paints, brushes and canvases',13,'painting-supplies',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1302,'Crafting Materials','Fabric, yarn and crafting supplies',13,'crafting-materials',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1401,'Suitcases','Travel suitcases and carry-ons',14,'suitcases',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1402,'Travel Accessories','Travel pillows, adapters and accessories',14,'travel-accessories',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1501,'Guitars','Acoustic and electric guitars',15,'guitars',NULL,1,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1502,'Keyboards & Pianos','Digital pianos and keyboards',15,'keyboards-pianos',NULL,2,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24'),
(1503,'Drums','Drum sets and percussion',15,'drums',NULL,3,1,'active',NULL,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category_attributes`
--

DROP TABLE IF EXISTS `category_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `category_attributes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) NOT NULL,
  `attribute_name` varchar(100) NOT NULL,
  `attribute_type` enum('text','number','boolean','select','multiselect','date') NOT NULL,
  `attribute_options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attribute_options`)),
  `is_required` tinyint(1) NOT NULL DEFAULT 0,
  `is_filterable` tinyint(1) NOT NULL DEFAULT 0,
  `is_searchable` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_attribute_name` (`attribute_name`),
  KEY `idx_is_filterable` (`is_filterable`),
  KEY `idx_sort_order` (`sort_order`),
  CONSTRAINT `fk_category_attributes_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category_attributes`
--

LOCK TABLES `category_attributes` WRITE;
/*!40000 ALTER TABLE `category_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `category_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `message` text NOT NULL,
  `message_type` enum('text','emoji','system','product_link','moderation') NOT NULL DEFAULT 'text',
  `is_highlighted` tinyint(1) NOT NULL DEFAULT 0,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_by` int(11) DEFAULT NULL,
  `deleted_reason` varchar(255) DEFAULT NULL,
  `parent_message_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_stream_id` (`stream_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_message_type` (`message_type`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `idx_parent_message_id` (`parent_message_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_chat_messages_moderator` (`deleted_by`),
  CONSTRAINT `fk_chat_messages_moderator` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_chat_messages_stream` FOREIGN KEY (`stream_id`) REFERENCES `live_streams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_chat_messages_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_messages`
--

LOCK TABLES `chat_messages` WRITE;
/*!40000 ALTER TABLE `chat_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_metadata`
--

DROP TABLE IF EXISTS `chat_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_metadata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chat_id` int(11) NOT NULL,
  `meta_key` varchar(100) NOT NULL,
  `meta_value` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_chat_id` (`chat_id`),
  KEY `idx_meta_key` (`meta_key`),
  CONSTRAINT `chat_metadata_ibfk_1` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_metadata`
--

LOCK TABLES `chat_metadata` WRITE;
/*!40000 ALTER TABLE `chat_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chats`
--

DROP TABLE IF EXISTS `chats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `status` enum('active','closed','archived') DEFAULT 'active',
  `type` enum('support','ai','sales') DEFAULT 'support',
  `assigned_agent_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `closed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_type` (`type`),
  KEY `idx_created_at` (`created_at`),
  KEY `assigned_agent_id` (`assigned_agent_id`),
  CONSTRAINT `chats_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `chats_ibfk_2` FOREIGN KEY (`assigned_agent_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chats`
--

LOCK TABLES `chats` WRITE;
/*!40000 ALTER TABLE `chats` DISABLE KEYS */;
/*!40000 ALTER TABLE `chats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_media`
--

DROP TABLE IF EXISTS `cms_media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cms_media` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_url` varchar(500) NOT NULL,
  `file_size` bigint(20) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `media_type` enum('image','video','audio','document','other') NOT NULL,
  `alt_text` varchar(255) DEFAULT NULL,
  `caption` text DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `uploaded_by` int(11) NOT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_filename` (`filename`),
  KEY `idx_media_type` (`media_type`),
  KEY `idx_uploaded_by` (`uploaded_by`),
  KEY `idx_is_public` (`is_public`),
  CONSTRAINT `fk_cms_media_uploader` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_media`
--

LOCK TABLES `cms_media` WRITE;
/*!40000 ALTER TABLE `cms_media` DISABLE KEYS */;
/*!40000 ALTER TABLE `cms_media` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_pages`
--

DROP TABLE IF EXISTS `cms_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cms_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `meta_keywords` text DEFAULT NULL,
  `page_type` enum('static','policy','help','blog','custom') NOT NULL DEFAULT 'static',
  `template` varchar(100) DEFAULT 'default',
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `featured_image` varchar(500) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `requires_auth` tinyint(1) NOT NULL DEFAULT 0,
  `allowed_roles` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`allowed_roles`)),
  `custom_css` text DEFAULT NULL,
  `custom_js` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_slug` (`slug`),
  KEY `idx_page_type` (`page_type`),
  KEY `idx_status` (`status`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_updated_by` (`updated_by`),
  CONSTRAINT `fk_cms_pages_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cms_pages_parent` FOREIGN KEY (`parent_id`) REFERENCES `cms_pages` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_cms_pages_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_pages`
--

LOCK TABLES `cms_pages` WRITE;
/*!40000 ALTER TABLE `cms_pages` DISABLE KEYS */;
/*!40000 ALTER TABLE `cms_pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cms_posts`
--

DROP TABLE IF EXISTS `cms_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cms_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `excerpt` text DEFAULT NULL,
  `content` longtext NOT NULL,
  `post_type` enum('blog','news','announcement','tutorial','faq') NOT NULL DEFAULT 'blog',
  `status` enum('draft','published','scheduled','archived') NOT NULL DEFAULT 'draft',
  `featured_image` varchar(500) DEFAULT NULL,
  `author_id` int(11) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `view_count` int(11) NOT NULL DEFAULT 0,
  `comment_count` int(11) NOT NULL DEFAULT 0,
  `published_at` timestamp NULL DEFAULT NULL,
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_slug` (`slug`),
  KEY `idx_post_type` (`post_type`),
  KEY `idx_status` (`status`),
  KEY `idx_author_id` (`author_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_published_at` (`published_at`),
  KEY `idx_cms_posts_type_status_published` (`post_type`,`status`,`published_at`),
  CONSTRAINT `fk_cms_posts_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cms_posts_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cms_posts`
--

LOCK TABLES `cms_posts` WRITE;
/*!40000 ALTER TABLE `cms_posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `cms_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comm_messages`
--

DROP TABLE IF EXISTS `comm_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comm_messages` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `channel` enum('email','sms','push','in_app') NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `body` longtext NOT NULL,
  `status` enum('pending','sent','delivered','failed','bounced') NOT NULL DEFAULT 'pending',
  `sent_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `opened_at` timestamp NULL DEFAULT NULL,
  `clicked_at` timestamp NULL DEFAULT NULL,
  `template_id` int(11) DEFAULT NULL,
  `campaign_id` int(11) DEFAULT NULL,
  `personalization_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`personalization_data`)),
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`message_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_channel` (`channel`),
  KEY `idx_status` (`status`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_campaign_id` (`campaign_id`),
  KEY `idx_sent_at` (`sent_at`),
  KEY `idx_comm_messages_channel_status` (`channel`,`status`,`sent_at`),
  CONSTRAINT `fk_comm_messages_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comm_messages`
--

LOCK TABLES `comm_messages` WRITE;
/*!40000 ALTER TABLE `comm_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `comm_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_messages`
--

DROP TABLE IF EXISTS `contact_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `subject` varchar(500) NOT NULL,
  `message` text NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `status` enum('unread','read','replied','archived') NOT NULL DEFAULT 'unread',
  `admin_reply` text DEFAULT NULL,
  `replied_by` int(11) DEFAULT NULL,
  `replied_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_replied_by` (`replied_by`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_messages`
--

LOCK TABLES `contact_messages` WRITE;
/*!40000 ALTER TABLE `contact_messages` DISABLE KEYS */;
INSERT INTO `contact_messages` VALUES
(1,'Gerard Driskell','gerard.driskell@msn.com','Info about Doogee Smartphones','Hey,\r\n\r\nI wanted to share some general information about Doogee Android Smartphones. These devices are known for their reliable performance, durable battery life, and reasonable pricing.\r\n\r\nFor further details, you can check the information page here:\r\nhttps://www.quality.for.less.longislandservicesnet.com/product/doogee-smartphones-android-phones/\r\n\r\nIf this message is not relevant to you, please feel free to disregard.\r\n\r\nBest regards,','feedback','unread',NULL,NULL,NULL,'2025-10-08 00:09:41','2025-10-08 00:09:41'),
(2,'Leefok','dinanikolskaya99@gmail.com','Hallo  i writing about your   prices','Hola, volia saber el seu preu.','account_help','unread',NULL,NULL,NULL,'2025-10-08 00:55:51','2025-10-08 00:55:51'),
(3,'123bDup','123b1@123bv1.it.com','123B online is a all the rage online casino that provides jackpot, fish shooting, and tangible tradesman tables.','&lt;b&gt;&lt;a href=https://cheapjerseysfromchinaonline.us.com/&gt;123B&lt;/a&gt;&lt;/b&gt; stands as a top-ranking destination with a view players who pursue real performance in the vibrant realm of online gaming. This platform brings together thousands of enthusiasts from across the globe, sacrifice an savoir vivre that blends furore, literalism, and trust. Whether you are into &lt;b&gt;casino&lt;/b&gt; adventures, thrilling &lt;b&gt;x? s?&lt;/b&gt; draws, enthusiastic &lt;b&gt;th? thao&lt;/b&gt; matches, or immersive &lt;b&gt;trò choi&lt;/b&gt; challenges, &lt;b&gt;123B&lt;/b&gt; delivers an ecosystem where every half a mo counts. \r\n \r\nWithin its extensive portfolio, members can explore countless categories — from &lt;b&gt;game slots&lt;/b&gt; with large &lt;b&gt;jackpot&lt;/b&gt; rewards to competitive &lt;b&gt;b?n cá&lt;/b&gt; arenas and ritual titles like &lt;b&gt;tài x?u md5&lt;/b&gt;, &lt;b&gt;xóc dia&lt;/b&gt;, &lt;b&gt;baccarat&lt;/b&gt;, and &lt;b&gt;r?ng h?&lt;/b&gt;. Each misrepresent is optimized for suave about and fairness, ensuring that both stylish and established players can enjoy every whirl and wager with buxom confidence. \r\n \r\nBeyond the games themselves, &lt;b&gt;123B&lt;/b&gt; focuses on providing a thorough ecosystem — featuring diaphanous &lt;b&gt;khuy?n mãi&lt;/b&gt;, dedicated &lt;b&gt;cskh&lt;/b&gt; champion, and flexile &lt;b&gt;uu dãi&lt;/b&gt; programs that compensate loyalty. As a service to those who plan for to develop a occupation in this digital entertainment boundary, the &lt;b&gt;d?i lý&lt;/b&gt; system opens up opportunities to initiate consistent income finished with decision-making partnership models. \r\n \r\nFor esports lovers and strategic gamers, &lt;b&gt;123B&lt;/b&gt; has expanded its coverage into global &lt;b&gt;esports&lt;/b&gt; competitions, integrating real-time odds and analytics. This modernization bridges the thrill of gaming with competitive text, serving users space more informed decisions and bespeak deeper in their favorite titles. \r\n \r\nTo episode this growing universe of amusement, visit &lt;a href=https://cheapjerseysfromchinaonline.us.com/&gt;https://cheapjerseysfromchinaonline.us.com/&lt;/a&gt; — the pompous gateway where every click leads to limitless upset and the next big win.','feedback','unread',NULL,NULL,NULL,'2025-10-09 06:43:58','2025-10-09 06:43:58'),
(4,'Stevepal','xrumer23Cog@gmail.com','Best the best database for data leaks','Data-Leaks – Find what google can’t find \r\nGreat in data leak: With over 20 billion collected passwords \r\nSuper fast search speed: Allows easy and super fast search of any user or domain. \r\nMany options for buy, many discout. Just 2$ to experience all functions, Allows downloading clean data from your query. \r\nGo to : https://Data-Leaks.org','technical_issue','unread',NULL,NULL,NULL,'2025-10-10 00:51:08','2025-10-10 00:51:08'),
(5,'CharlesStype','st.i.l.tbtsb@web.de','blsm-at','Рабочие ссылки на bs2best at \r\n \r\nПривет! Нашел рабочие зеркала для bs2best at: \r\n \r\nСсылки для входа: \r\n• &lt;a href=https://blsa-at.bond&gt;bs2best at&lt;/a&gt; \r\n• &lt;a href=https://bs2best-at.lol&gt;вход&lt;/a&gt; \r\n• &lt;a href=https://blsp.quest&gt;обход блокировки&lt;/a&gt; \r\n \r\nВсе проверено, работает стабильно.','return_refund','unread',NULL,NULL,NULL,'2025-10-10 08:13:27','2025-10-10 08:13:27'),
(6,'BrianAppom','mrtommyk@gmail.com','In the latest loli porn','Unconversant with loli porn cp pthc \r\n \r\n \r\nhttps://afpo.eu/jk6Va \r\n \r\nhttps://go.euserv.org/17w','product_question','unread',NULL,NULL,NULL,'2025-10-10 16:48:15','2025-10-10 16:48:15'),
(7,'Stevenwap','veronika_s@gmx.com','websites for','&lt;a href=&quot;https://vbets-nl.com/&quot;&gt;ЩЉЩ…Щ† ШЄЩ€Щѓ 99098&lt;/a&gt;\r\n&lt;a href=&quot;https://vbets-nl.com/&quot;&gt;where to buy cialis online canada&lt;/a&gt;\r\n&lt;a href=&quot;https://vbets-nl.com/&quot;&gt;where can i buy cialis tadalafil in edmonton&lt;/a&gt;\r\n&lt;a href=&quot;https://vbets-nl.com/&quot;&gt;ЩЉЩ…Щ† ШЄЩ€Щѓ 99135&lt;/a&gt;\r\n&lt;a href=&quot;https://vbets-nl.com/&quot;&gt;where to buy cialis over the counter&lt;/a&gt;\r\n&lt;a href=&quot;https://vbets-nl.com/&quot;&gt;ЩЉЩ…Щ† ШЄЩ€Щѓ 99103&lt;/a&gt;\r\n&lt;a href=&quot;https://vbets-nl.com/&quot;&gt;ЩЃЫЊЩ„Щ… ШіЩ€ЩѕШ±&lt;/a&gt;\r\n&lt;a href=&quot;https://vbets-nl.com/&quot;&gt;what is tadalafil&lt;/a&gt;\r\n&lt;a href=&quot;https://vbets-nl.com/&quot;&gt;ЩЉЩ…Щ† ШЄЩ€Щѓ 98162&lt;/a&gt;\r\n&lt;a href=&quot;https://vbets-nl.com/&quot;&gt;ЩЉЩ…Щ† ШЄЩ€Щѓ 99099&lt;/a&gt;','other','unread',NULL,NULL,NULL,'2025-10-11 07:10:37','2025-10-11 07:10:37'),
(8,'Leefok','dinanikolskaya99@gmail.com','Hello  i am wrote about your the prices','Ndewo, achọrọ m ịmara ọnụahịa gị.','seller_inquiry','unread',NULL,NULL,NULL,'2025-10-11 08:44:40','2025-10-11 08:44:40'),
(9,'123bBlide','123bv2@123bv1.it.com','123B online is a famed online casino that offers sports, draw, casino, and slots.','&lt;p&gt;Welcome to &lt;a href=https://cheapjerseysfromchinaonline.us.com/&gt;&lt;b&gt;123B&lt;/b&gt;&lt;/a&gt;, the conclusive neutral in behalf of brilliant players seeking ïðîäâèæåíèå &lt;b&gt;casino&lt;/b&gt; power, &lt;b&gt;x? s?&lt;/b&gt; thrills, and high-stakes &lt;b&gt;th? thao&lt;/b&gt; wagering. From timeless &lt;b&gt;trò choi&lt;/b&gt; like &lt;b&gt;game slots&lt;/b&gt; and &lt;b&gt;b?n cá&lt;/b&gt; to burly wins in the &lt;b&gt;jackpot&lt;/b&gt; arena, our principles delivers next-level excitement. Honky-tonk into the power of &lt;b&gt;dá gà&lt;/b&gt;, the principles of &lt;b&gt;esports&lt;/b&gt;, or the politesse of &lt;b&gt;baccarat&lt;/b&gt; and &lt;b&gt;r?ng h?&lt;/b&gt;. Come by in on the fast-paced action of &lt;b&gt;tài x?u md5&lt;/b&gt; and &lt;b&gt;xóc dia&lt;/b&gt;, too. \r\n \r\nWe arrogate prize in our open-handed &lt;b&gt;khuy?n mãi&lt;/b&gt; and &lt;b&gt;uu dãi&lt;/b&gt; that recompense both ancillary and trusty players. Our &lt;b&gt;cskh&lt;/b&gt; tie is various times eager to assist you, and our network of trusted &lt;b&gt;d?i lý&lt;/b&gt; brings clannish offers closer to you. In the intervening point, our beloved &lt;b&gt;n? hu&lt;/b&gt; games kipper prolong the adrenaline pumping. \r\n \r\nCloudless to join? Know-how everything &lt;a href=https://cheapjerseysfromchinaonline.us.com/&gt;&lt;b&gt;123B&lt;/b&gt;&lt;/a&gt; has to cause dispatch—smite &lt;a href=https://cheapjerseysfromchinaonline.us.com/&gt;https://cheapjerseysfromchinaonline.us.com/&lt;/a&gt; and nosedive yourself in the highest betting universe.&lt;/p&gt;','feedback','unread',NULL,NULL,NULL,'2025-10-11 09:35:01','2025-10-11 09:35:01'),
(10,'Imamn','Cog@prohabits.es','2006). &quot;Lithium Isotopic Abundances in Metal-poor Halo Stars&quot;.','You can request to buy Ventolin inhalers online from our UK registered online pharmacy and doctor service. Or you might decide to choose a gel. PhytopharmвЂ™s Dr Richard Dixey explained how P57 actually works: вЂњThere is a part of your brain, the hypothalamus. Smarts, of course, the children we&#039;re raising in this country. In my 8 years in the pharmaceutical industry, Cephalon is a company that I simultaneously loathe and admire. sildigra softgel  \r\nhttps://ceiptiernogalvan.es &lt;a href=kalulopets.es&gt;&lt;/a&gt;ascorbic acid What are the contents of juice drink? Patients who received other treatment for hyponatremia or medicinal products which increase serum sodium concentration (see section 4.5) prior to initiation of treatment with Samsca must be managed very cautiously. Dangerously high levels of lithium in the body is called &#039;lithium toxicity&#039;. Enalapril overdose and the corrective effect of intravenous angiotensin II. To supplement requirements according to give patients with cheap retin a online benefit is making other facial nerve compression.','account_help','unread',NULL,NULL,NULL,'2025-10-11 14:52:02','2025-10-11 14:52:02'),
(11,'Jeremyfup','superbridge@gmail.com','Superbridge','Use Superbridge base for accurate, real-time execution  &lt;a href=https://super-brldge.net&gt;Visit super-brldge.net for the Superbridge app&lt;/a&gt;','return_refund','unread',NULL,NULL,NULL,'2025-10-12 11:36:08','2025-10-12 11:36:08'),
(12,'TimothySek','jolene.westcott@bk.ru','Printing Industrialist','Explore our &lt;a href=https://www.zxcprint.com/products/book-printing/&gt;book printing&lt;/a&gt; services on the &lt;a href=https://www.zxcprint.com/&gt;printing in China&lt;/a&gt; page.','account_help','unread',NULL,NULL,NULL,'2025-10-12 13:55:11','2025-10-12 13:55:11'),
(13,'Lanny Mccaffrey','mccaffrey.lanny@outlook.com','need info','Final hours: lock in 1M guaranteed sends for $49 today. Contact me directly at contact@bestaitools.my','feedback','unread',NULL,NULL,NULL,'2025-10-12 21:57:35','2025-10-12 21:57:35'),
(14,'Leefok','dinanikolskaya99@gmail.com','Hallo,   writing about your the price','Salut, ech wollt Äre Präis wëssen.','technical_issue','unread',NULL,NULL,NULL,'2025-10-12 23:11:55','2025-10-12 23:11:55'),
(15,'Simonfok','dinanikolskaya99@gmail.com','Hi    write about your   prices','Sveiki, es gribēju zināt savu cenu.','other','unread',NULL,NULL,NULL,'2025-10-12 23:37:45','2025-10-12 23:37:45'),
(16,'Emmapup','isabellaLami699@gmail.com','Your site got me curious','Hey, I just stumbled onto your site… are you always this good at catching attention, or did you make it just for me? Write to me on this website ---  rb.gy/3pma6x?pup  ---  my username is the same, I&#039;ll be waiting.','seller_inquiry','unread',NULL,NULL,NULL,'2025-10-13 00:35:39','2025-10-13 00:35:39'),
(17,'EE88Hex','botx9@123bv1.it.com','Introduction to EE88','&lt;b&gt;Welcome to &lt;a href=https://719.cn.com/&gt;&lt;b&gt;EE88&lt;/b&gt;&lt;/a&gt;&lt;/b&gt; – your conclusive goal quest of online entertainment. At &lt;b&gt;EE88&lt;/b&gt;, players can enjoy a extensive align of &lt;b&gt;casino&lt;/b&gt; games, &lt;b&gt;x? s?&lt;/b&gt; draws, and exhilarating &lt;b&gt;th? thao&lt;/b&gt; betting opportunities. Whether you love vital &lt;b&gt;baccarat&lt;/b&gt;, animating &lt;b&gt;game slots&lt;/b&gt;, or fast-paced &lt;b&gt;b?n cá&lt;/b&gt;, this policy brings entire lot together in unified place. Experience vibrant &lt;b&gt;jackpot&lt;/b&gt; rounds, action-packed &lt;b&gt;dá gà&lt;/b&gt; matches, and competitive &lt;b&gt;esports&lt;/b&gt; tournaments — all designed to maintain you entertained nearly the clock. Don’t girl loophole on the latest &lt;b&gt;khuy?n mãi&lt;/b&gt; and dear &lt;b&gt;uu dãi&lt;/b&gt; that sign every game unbroken more rewarding. With a talented &lt;b&gt;cskh&lt;/b&gt; conspire and stretchy &lt;b&gt;d?i lý&lt;/b&gt; partnerships, &lt;b&gt;EE88&lt;/b&gt; ensures a unobstructed and immovable participation someone is concerned every player. From &lt;b&gt;n? hu&lt;/b&gt; spins to &lt;b&gt;tài x?u md5&lt;/b&gt;, &lt;b&gt;xóc dia&lt;/b&gt;, &lt;b&gt;r?ng h?&lt;/b&gt;, and beyond – it’s all waiting for you. Explore the terra of gaming at &lt;a href=https://719.cn.com/&gt;https://719.cn.com/&lt;/a&gt; and start your feat today!&lt;/b&gt;','return_refund','unread',NULL,NULL,NULL,'2025-10-13 05:28:02','2025-10-13 05:28:02'),
(18,'EE88Jopay','contact45@123bv1.it.com','Reconcilement EE88','&lt;p&gt; \r\nDiscern the titillating world of &lt;b&gt;&lt;a href=https://719.cn.com/&gt;EE88&lt;/a&gt;&lt;/b&gt;, where unrest meets innovation. With a assorted lot of &lt;b&gt;casino&lt;/b&gt; games, endure &lt;b&gt;x? s?&lt;/b&gt; draws, and competitive &lt;b&gt;th? thao&lt;/b&gt; betting options, players can lift an unmatched event of entertainment and rewards. Whether you be inclined immersive &lt;b&gt;trò choi&lt;/b&gt; like &lt;b&gt;game slots&lt;/b&gt; and &lt;b&gt;b?n cá&lt;/b&gt;, or high-stakes &lt;b&gt;jackpot&lt;/b&gt; and &lt;b&gt;dá gà&lt;/b&gt; tournaments, &lt;b&gt;EE88&lt;/b&gt; ensures every moment is filled with action. Engage in renowned categories like &lt;b&gt;esports&lt;/b&gt;, study your fate with &lt;b&gt;n? hu&lt;/b&gt;, or inquire critical titles such as &lt;b&gt;tài x?u md5&lt;/b&gt;, &lt;b&gt;xóc dia&lt;/b&gt;, &lt;b&gt;baccarat&lt;/b&gt;, and &lt;b&gt;r?ng h?&lt;/b&gt;. Feel superiority of ungrudging &lt;b&gt;khuy?n mãi&lt;/b&gt;, select &lt;b&gt;uu dãi&lt;/b&gt;, and dedicated &lt;b&gt;cskh&lt;/b&gt; bankroll after a seamless experience. Participant with the &lt;b&gt;d?i lý&lt;/b&gt; network and unlock limitless opportunities with &lt;a href=https://719.cn.com/&gt;https://719.cn.com/&lt;/a&gt;. \r\n&lt;/p&gt;','seller_inquiry','unread',NULL,NULL,NULL,'2025-10-13 05:38:49','2025-10-13 05:38:49'),
(19,'EE88evale','info01@123bv1.it.com','EE88','&lt;p&gt; \r\nAt &lt;a href=https://719.cn.com/&gt;&lt;b&gt;EE88&lt;/b&gt;&lt;/a&gt;, players can submerge themselves in a the human race of thrilling &lt;b&gt;casino&lt;/b&gt; adventures, energizing &lt;b&gt;x? s?&lt;/b&gt; draws, and consuming &lt;b&gt;th? thao&lt;/b&gt; matches. This rostrum delivers a considerable file of &lt;b&gt;trò choi&lt;/b&gt; including &lt;b&gt;game slots&lt;/b&gt;, &lt;b&gt;b?n cá&lt;/b&gt;, &lt;b&gt;jackpot&lt;/b&gt; challenges, and competitive &lt;b&gt;dá gà&lt;/b&gt; and &lt;b&gt;esports&lt;/b&gt; tournaments. With generous &lt;b&gt;khuy?n mãi&lt;/b&gt; and private &lt;b&gt;uu dãi&lt;/b&gt;, &lt;b&gt;EE88&lt;/b&gt; ensures every associate enjoys a premium entertainment experience. Matchless &lt;b&gt;cskh&lt;/b&gt; service, reliable systems, and different &lt;b&gt;d?i lý&lt;/b&gt; programs gross it the preferred goal pro ardent gamers. From &lt;b&gt;tài x?u md5&lt;/b&gt; to &lt;b&gt;xóc dia&lt;/b&gt;, &lt;b&gt;baccarat&lt;/b&gt;, and &lt;b&gt;r?ng h?&lt;/b&gt;, every meeting offers passable undertake and rewarding excitement. Upon the proper put at &lt;a href=https://719.cn.com/&gt;https://719.cn.com/&lt;/a&gt; today to start your journey with &lt;b&gt;EE88&lt;/b&gt; and fancy constant online amusement! \r\n&lt;/p&gt;','technical_issue','unread',NULL,NULL,NULL,'2025-10-13 06:25:50','2025-10-13 06:25:50'),
(20,'EE88alorn','support01@123bv1.it.com','Introduction to EE88','&lt;p&gt;Join &lt;a href=https://719.cn.com/&gt;&lt;b&gt;EE88&lt;/b&gt;&lt;/a&gt; — the uttermost terminus fitted passionate players who partiality &lt;b&gt;casino&lt;/b&gt; thrills, overwhelming &lt;b&gt;x? s?&lt;/b&gt; draws, and competitive &lt;b&gt;th? thao&lt;/b&gt; matches. At &lt;b&gt;EE88&lt;/b&gt;, users can enjoy hundreds of &lt;b&gt;trò choi&lt;/b&gt; including &lt;b&gt;game slots&lt;/b&gt;, &lt;b&gt;b?n cá&lt;/b&gt;, &lt;b&gt;jackpot&lt;/b&gt;, and nervous &lt;b&gt;dá gà&lt;/b&gt; or &lt;b&gt;esports&lt;/b&gt; tournaments. The programme stands loose with incredible &lt;b&gt;khuy?n mãi&lt;/b&gt;, 24/7 &lt;b&gt;cskh&lt;/b&gt; support, and incompatible &lt;b&gt;uu dãi&lt;/b&gt; in behalf of reliable members. Whether you’re into &lt;b&gt;n? hu&lt;/b&gt;, &lt;b&gt;d?i lý&lt;/b&gt; programs, or traditional favorites like &lt;b&gt;tài x?u md5&lt;/b&gt;, &lt;b&gt;xóc dia&lt;/b&gt;, &lt;b&gt;baccarat&lt;/b&gt;, and &lt;b&gt;r?ng h?&lt;/b&gt;, there’s always something energizing waiting on the side of you. Catch sight now at &lt;a href=https://719.cn.com/&gt;https://719.cn.com/&lt;/a&gt; and experience the next straight with of production!&lt;/p&gt;','return_refund','unread',NULL,NULL,NULL,'2025-10-13 06:52:20','2025-10-13 06:52:20'),
(21,'EE88Ephex','mailer303@123bv1.it.com','EE88 COM','&lt;p&gt; \r\nMeet to the sensuous creation of &lt;a href=https://719.cn.com/&gt;&lt;b&gt;EE88&lt;/b&gt;&lt;/a&gt; – the leading objective for online entertainment and betting enthusiasts. Here, you can test a to one side kitchen range of &lt;b&gt;casino&lt;/b&gt; games, striking &lt;b&gt;x? s?&lt;/b&gt; draws, and competitive &lt;b&gt;th? thao&lt;/b&gt; events that shoot nonstop excitement. Whether you profit from principal &lt;b&gt;trò choi&lt;/b&gt; or vibrant &lt;b&gt;game slots&lt;/b&gt;, there’s something as a replacement for everyone. Club into enduring favorites like &lt;b&gt;b?n cá&lt;/b&gt;, &lt;b&gt;jackpot&lt;/b&gt;, and &lt;b&gt;dá gà&lt;/b&gt;, or invitation your skills with &lt;b&gt;esports&lt;/b&gt; tournaments. At EE88, players allowances from fashionable &lt;b&gt;khuy?n mãi&lt;/b&gt; offers, educated &lt;b&gt;cskh&lt;/b&gt; withstand, and consonant &lt;b&gt;uu dãi&lt;/b&gt; for every member. Become a trusted &lt;b&gt;d?i lý&lt;/b&gt; or reconnoitre favourite games like &lt;b&gt;tài x?u md5&lt;/b&gt;, &lt;b&gt;xóc dia&lt;/b&gt;, &lt;b&gt;baccarat&lt;/b&gt;, and &lt;b&gt;r?ng h?&lt;/b&gt; – all crafted to deliver unforgettable sport moments. For more details, visit &lt;a href=https://719.cn.com/&gt;https://719.cn.com/&lt;/a&gt; today and start your victorious journey with &lt;a href=https://719.cn.com/&gt;&lt;b&gt;EE88&lt;/b&gt;&lt;/a&gt;. \r\n&lt;/p&gt;','product_question','unread',NULL,NULL,NULL,'2025-10-13 07:55:57','2025-10-13 07:55:57'),
(22,'EE88UNoms','signup88@123bv1.it.com','EE88 COM','&lt;b&gt;&lt;a href=https://719.cn.com/&gt;EE88&lt;/a&gt;&lt;/b&gt; brings a world of nervousness to online players with its differing assortment of &lt;b&gt;casino&lt;/b&gt; games, &lt;b&gt;x? s?&lt;/b&gt; draws, and &lt;b&gt;th? thao&lt;/b&gt; betting options. From critical &lt;b&gt;baccarat&lt;/b&gt; sessions to galvanizing &lt;b&gt;game slots&lt;/b&gt; and &lt;b&gt;b?n cá&lt;/b&gt; tournaments, players can enjoy countless ways to attain big. The platform’s cutting-edge interface and firm process assemble every &lt;b&gt;trò choi&lt;/b&gt; peaceful and reliable. With handsome &lt;b&gt;khuy?n mãi&lt;/b&gt; programs, companionable &lt;b&gt;cskh&lt;/b&gt; aid, and lucrative &lt;b&gt;uu dãi&lt;/b&gt; in return &lt;b&gt;d?i lý&lt;/b&gt; partners, &lt;b&gt;&lt;a href=https://719.cn.com/&gt;EE88&lt;/a&gt;&lt;/b&gt; stands as a trusted goal for all enthusiasts of &lt;b&gt;jackpot&lt;/b&gt;, &lt;b&gt;r?ng h?&lt;/b&gt;, &lt;b&gt;xóc dia&lt;/b&gt;, &lt;b&gt;tài x?u md5&lt;/b&gt;, &lt;b&gt;esports&lt;/b&gt;, and more. Examine the ferment at the moment at &lt;a href=https://719.cn.com/&gt;https://719.cn.com/&lt;/a&gt; and experience ïðåìèóì show like not once!','seller_inquiry','unread',NULL,NULL,NULL,'2025-10-13 07:57:29','2025-10-13 07:57:29'),
(23,'ThomasFut','polyakovdanila19908366@mail.ru','Подборщики Заказа','https://energo-pole.ru/skladskaya-tekhnika/vilochnye-pogruzchiki/elektricheskie/elektricheskiy-pogruzchik-fe3r12n/\r\n  столы. \r\nПоставки столов Edmolift в Россию с 2000г! Оказываем сервисное обслуживание и ТО столов. Всегда в наличии запасные части для подъемных столов. \r\nГрузоподъемность от 750 до 3000 кг Высота подъема от 550 до 820 мм. \r\nТележка с подъемной платформой предназначена для работы в складских помещениях, производственных предприятий для транспортировки коробок, инструментов и других грузов. Способны поднимать и перемещать грузы весом до 0.8т на высоту до 1000мм. \r\nЕще -5% \r\nНадежность и бесперебойность работы гидравлических подъемных столов EdmoLift подтверждается более чем 20-ти летней историей их эксплуатации по всей территории России.','technical_issue','unread',NULL,NULL,NULL,'2025-10-13 16:27:58','2025-10-13 16:27:58'),
(24,'EE88toutt','tempreg7@123bv1.it.com','EE88','&lt;p&gt; \r\nAcquaintance the thrill of online distraction at &lt;a href=https://719.cn.com/&gt;&lt;b&gt;EE88&lt;/b&gt;&lt;/a&gt;, the ultimate destination for players who true-love excitement and rewards. From &lt;b&gt;casino&lt;/b&gt; games and &lt;b&gt;x? s?&lt;/b&gt; to powerful &lt;b&gt;th? thao&lt;/b&gt; betting and interactive &lt;b&gt;trò choi&lt;/b&gt;, this tenets offers unbounded opportunities to bring round big. Dive into glorious &lt;b&gt;game slots&lt;/b&gt;, action-packed &lt;b&gt;b?n cá&lt;/b&gt; arenas, and lucrative &lt;b&gt;jackpot&lt;/b&gt; rounds. Fans of &lt;b&gt;dá gà&lt;/b&gt; and &lt;b&gt;esports&lt;/b&gt; longing also determine top-tier tournaments and exclusive &lt;b&gt;khuy?n mãi&lt;/b&gt; deals waiting. Especial &lt;b&gt;cskh&lt;/b&gt; ensures temper play and fast support. Whether you infatuation &lt;b&gt;n? hu&lt;/b&gt;, individual &lt;b&gt;uu dãi&lt;/b&gt;, or becoming a trusted &lt;b&gt;d?i lý&lt;/b&gt;, &lt;b&gt;EE88&lt;/b&gt; is your trusted partner. Masterpiece titles like &lt;b&gt;tài x?u md5&lt;/b&gt;, &lt;b&gt;xóc dia&lt;/b&gt;, &lt;b&gt;baccarat&lt;/b&gt;, and &lt;b&gt;r?ng h?&lt;/b&gt; effect bona fide thrills untangle to your screen. Join today and survey all the delight at &lt;a href=https://719.cn.com/&gt;https://719.cn.com/&lt;/a&gt;. \r\n&lt;/p&gt;','feedback','unread',NULL,NULL,NULL,'2025-10-13 18:03:34','2025-10-13 18:03:34'),
(25,'EE88Wet','user2025@123bv1.it.com','EE88','&lt;p&gt;Discover the faction of &lt;a href=https://719.cn.com/&gt;&lt;b&gt;EE88&lt;/b&gt;&lt;/a&gt;, where endless ado meets cutting-edge technology in online entertainment. From thrilling &lt;b&gt;casino&lt;/b&gt; tables and vigorous &lt;b&gt;sports&lt;/b&gt; betting to likeable &lt;b&gt;lottery&lt;/b&gt; draws and fast-paced &lt;b&gt;game slots&lt;/b&gt;, every flash at EE88 is crafted because maximum fun. Sound into top-tier &lt;b&gt;b?n cá&lt;/b&gt; and &lt;b&gt;dá gà&lt;/b&gt; matches, or review &lt;b&gt;baccarat&lt;/b&gt;, &lt;b&gt;r?ng h?&lt;/b&gt;, and &lt;b&gt;xóc dia&lt;/b&gt; during factual gaming experiences. Players also derive pleasure benevolent &lt;b&gt;khuy?n mãi&lt;/b&gt;, closed &lt;b&gt;uu dãi&lt;/b&gt;, and authoritative &lt;b&gt;cskh&lt;/b&gt; services. Don’t miss in view — befall &lt;a href=https://719.cn.com/&gt;https://719.cn.com/&lt;/a&gt; today and start your journey through the in seventh heaven of &lt;b&gt;n? hu&lt;/b&gt;, &lt;b&gt;jackpot&lt;/b&gt;, and &lt;b&gt;tài x?u md5&lt;/b&gt; with the trusted &lt;b&gt;d?i lý&lt;/b&gt; network of EE88.&lt;/p&gt;','technical_issue','unread',NULL,NULL,NULL,'2025-10-13 23:35:32','2025-10-13 23:35:32'),
(26,'Samuelcoigh','karzhavinvenegard@mail.ru','Спортивное Оборудование Опт','При необходимости возможна сборка оборудования заказчика на месте нашим специалистом https://sport-i-slife.ru/shop/oborudovanie-dlya-fitnesa-i-jogi/gantel-v-vinilovoj-obolochke-2-kg/\r\n \r\nпн-пт 7:00 - 18:00 https://sport-i-slife.ru/shop/gimnastika/brevno-gimnasticheskoe-vysokoe/\r\n \r\nТренажеры успешно прошли в Германии TUV-тестирование https://sport-i-slife.ru/shop/gimnastika/brevno-gimnasticheskoe-napolnoe/\r\n  Работа тренажеров на полном стеке 100 000 циклов https://sport-i-slife.ru/shop/gimnastika/xoreograficheskij-stanok/\r\n \r\nЭксклюзивность https://sport-i-slife.ru/shop/izdeliya-iz-plastika/vtulka-dlya-konusa/\r\n \r\nНовости спорта https://sport-i-slife.ru/shop/konusy-dlya-razmetki/konus-razmetochnyj-fishka/\r\n \r\nРегулярные поступления https://sport-i-slife.ru/shop/kovriki-dlya-aerobiki-i-jogi/mat-dlya-jogi-8-mm-odnoslojnyj-oranzhevyj/','feedback','unread',NULL,NULL,NULL,'2025-10-14 03:57:13','2025-10-14 03:57:13'),
(27,'FrankSek','amabil.6002@mail.ru','Складские Оборудования','Телефоны: +7 495 797-42-48 +7 965 368-94-37 https://nblift.ru/product/vyshki-nozhnichnye-samokhodnye-sc12e\r\n \r\nИнтернет вещей (IoT) - Сенсоры и устройства IoT используются для мониторинга состояния оборудования и уровня запасов в реальном времени, что позволяет заранее выявлять и устранять проблемы https://nblift.ru/product/samohodnye-shtabelery-ps13rm16plus\r\n \r\nРоссийские производители складской техники становятся ярким примером качественного и инновационного подхода к созданию подъемно-погрузочного оборудования https://nblift.ru/product/gidravlicheskie-telezhki-acx-15m\r\n  Исследуйте уникальные материалы о ведущих предприятиях этой отрасли, предлагающих вилочные погрузчики, штабелеры, ричтраки, комплектовщики и электротележки, спроектированные с учетом особенностей российских условий эксплуатации https://nblift.ru/product/vyshki-nozhnichnye-samokhodnye-sc14e\r\n \r\nсамоходной https://nblift.ru/product/tyagachi-t-e10\r\n \r\nТележки / Штабелеры / Ричтраки / Сборщики заказов / Подъемники / Погрузчики / Клининговая техника https://nblift.ru/product/gidravlicheskie-telezhki-rohli-as50\r\n \r\nПриезжайте к нам в офис – с радостью ответим на все вопросы, поможем с выбором и продемонстрируем складскую технику в деле https://nblift.ru/blog','other','unread',NULL,NULL,NULL,'2025-10-14 04:17:07','2025-10-14 04:17:07'),
(28,'MichaelExabs','natulya.fedosova.96@mail.ru','Анимационный Станции','День рождения в лофте для 15 гостей https://shcherbinins.ru/uslugy\r\n \r\nЗаказывали детский фуршет на день рождения, дети и родители в полном восторге! Компания предложила удобное меню - мини-пиццы, фруктовые шашлычки, яркие капкейки и полезные смузи https://shcherbinins.ru/menu\r\n  Все было свежее, красочное и безопасное для малышей https://shcherbinins.ru/contacts\r\n  Сервис на высоте, привезли вовремя, помогли с расстановкой, убрали после праздника https://shcherbinins.ru/aboutus\r\n  Очень довольны, будем рекомендоват https://shcherbinins.ru/menu\r\n \r\nСвоевременная доставка, свежие продукты https://shcherbinins.ru/aboutus\r\n \r\nКакие дополнительные услуги можно заказать? \r\nКомфорт и удобство https://shcherbinins.ru/aboutus\r\n \r\nПрофессионализм и высокое качество https://shcherbinins.ru/aboutus','account_help','unread',NULL,NULL,NULL,'2025-10-14 04:27:59','2025-10-14 04:27:59'),
(29,'DavidBuife','tacusol-6816@mail.ru','Межкомнатная Дверь Купить Недорого Москва','Функциональность и безопасность https://www.legnostyle.ru/mezhkomnatnye-dveri-knizhka.html?PAGEN_2=10\r\n   Элитные изделия предназначены для эксплуатации, а не только для эстетики https://www.legnostyle.ru/catalog/mejkomnatnie-dveri/vhodnaa-dver-e30.html\r\n   Эргономика моделей проектируется также тщательно, как и безупречный вид https://www.legnostyle.ru/catalog/mebel/gostinnie/g-2.html\r\n   Поэтому при их производстве не допускаются упущения, выбираются только безопасные решения, в том числе и экологически безопасные https://www.legnostyle.ru/mezhkomnatnye-dveri-knizhka.html?PAGEN_2=16\r\n   Такие модели выбирают особо требовательные покупатели, ценящие своё здоровье https://www.legnostyle.ru/catalog/lestnici/na-vtoroy-etazh/lestnica-l1-12.html\r\n \r\nПри создании современного и уютного интерьера в квартире или коттедже главную роль играет мебель https://www.legnostyle.ru/catalog/nashi-raboty/inter-er-kvartiri-na-arbate-k10.html\r\n   Она регулирует степень комфорта и позволяет владельцу полноценно отдыхать после тяжелого трудового дня https://www.legnostyle.ru/catalog/mejkomnatnie-dveri/diverso/?PAGEN_1=5\r\n \r\nОриентация на изготовление кухонной мебели с таким расчетом, чтобы соединить воедино знаменитый итальянский стиль, качество и дизайн с современными требованиями эргономики и функциональности https://www.legnostyle.ru/catalog/mebel/scg-3.html\r\n \r\nС другой стороны отделка может производится как всей поверхности мебели, так и ее какой-то определенной части https://www.legnostyle.ru/catalog/mejkomnatnie-dveri/nestandarnye/model-i15.html\r\n   Дополненная современными материалами - стеклом, металлам или деревом, она становится очередным произведением искусства https://www.legnostyle.ru/catalog/inter-eri/stenovie-paneli/s44.html\r\n \r\nВ действительности перепродажа товаров из Китая выгодное дело, если знать правильных продавцов и особенности китайского рынка https://www.legnostyle.ru/catalog/kuhni/kuhna-10.html\r\n   Выбор товаров и производителей в \r\nДольше, чем мы ожидали, с выбранной тканью довольно дорого вышло https://www.legnostyle.ru/catalog/mejkomnatnie-dveri/iz-massiva/?PAGEN_1=7\r\n   Но, конечно, не дороже, чем купить новую подобную мебель https://www.legnostyle.ru/catalog/mejkomnatnie-dveri/d-peregorodki/arka-a21.html\r\n   В любом случае все сделано достойно https://www.legnostyle.ru/vnutrennyaya-otdelka-derevom.html','other','unread',NULL,NULL,NULL,'2025-10-14 04:41:35','2025-10-14 04:41:35'),
(30,'EE88evoli','secureacc@123bv1.it.com','Introduction to EE88','&lt;p&gt; \r\nUnearth the ultimate great of online entertainment with &lt;a href=https://719.cn.com/&gt;&lt;b&gt;EE88&lt;/b&gt;&lt;/a&gt; – your trusted destination looking for immersive &lt;b&gt;casino&lt;/b&gt; thrills, ravishing &lt;b&gt;x? s?&lt;/b&gt; draws, and competitive &lt;b&gt;th? thao&lt;/b&gt; betting. Whether you’re into dynamic &lt;b&gt;trò choi&lt;/b&gt;, thrilling &lt;b&gt;game slots&lt;/b&gt;, or action-packed &lt;b&gt;b?n cá&lt;/b&gt; tournaments, &lt;b&gt;EE88&lt;/b&gt; delivers a seamless and reliable judgement an eye to every player. Plummet into jackpot adventures, make use of &lt;b&gt;dá gà&lt;/b&gt; matches, or explore the vibrant crowd of &lt;b&gt;esports&lt;/b&gt; with unbeatable &lt;b&gt;khuy?n mãi&lt;/b&gt; and upper-class &lt;b&gt;uu dãi&lt;/b&gt;. At &lt;b&gt;EE88&lt;/b&gt;, players are supported by professional &lt;b&gt;cskh&lt;/b&gt; and a advantageous &lt;b&gt;d?i lý&lt;/b&gt; arrangement designed to elevate your gaming journey. Encounter excitement thoroughly top-tier &lt;b&gt;n? hu&lt;/b&gt;, &lt;b&gt;tài x?u md5&lt;/b&gt;, &lt;b&gt;xóc dia&lt;/b&gt;, &lt;b&gt;baccarat&lt;/b&gt;, and &lt;b&gt;r?ng h?&lt;/b&gt;. Join straight away occasionally at &lt;a href=https://719.cn.com/&gt;https://719.cn.com/&lt;/a&gt; to discover why countless players decide &lt;b&gt;EE88&lt;/b&gt; as a remedy for ïðåìèóì online recreation in 2025. \r\n&lt;/p&gt;','account_help','unread',NULL,NULL,NULL,'2025-10-14 08:04:53','2025-10-14 08:04:53'),
(31,'KennethTok','g.randikr.ust@gmail.com','Hello guys','Hello mates, \r\nif you are searching for a fresh online casino, \r\nI can share with you some cool options. \r\n \r\nThese casinos have bonuses, \r\nsecure payments, and many slots and tables. \r\n \r\nCheck them out:   https://letscuturl.com/ \r\n \r\nGood luck )','return_refund','unread',NULL,NULL,NULL,'2025-10-15 06:18:36','2025-10-15 06:18:36'),
(32,'Simonfok','dinanikolskaya99@gmail.com','Hallo  i am writing about     price','Salam, qiymətinizi bilmək istədim.','product_question','unread',NULL,NULL,NULL,'2025-10-16 12:09:02','2025-10-16 12:09:02'),
(33,'PassBancY','gugloff.444@gmail.com','Получение второго гражданства или ВНЖ в странах СНГ и Евросоюзе','Оформим второе гражданство, вид на жительство (ВНЖ) или резидентство в разных странах СНГ, Европы, Израиля и Америки. \r\n \r\nПрограммы представлены &lt;a href=https://libertyfintravel.ru/vnj-i-vtoroe-grajdanstvo&gt;&lt;b&gt;на нашем сайте&lt;/b&gt;&lt;/a&gt; \r\n \r\nВторое гражданство, практическая иммиграция, иммиграция, вид на жительство, ВНЖ, Зелёная карта (green card) США \r\nГражданство стран Евросоюза под ключ \r\nГражданство на основании корней \r\nГражданство Армении под ключ \r\nГражданство Кыргызстана под ключ \r\nГражданство Польши под ключ \r\nГражданство Болгарии под ключ \r\nГражданство Италии под ключ \r\nГражданство Греции под ключ \r\nГражданство Израиля под ключ \r\n \r\nПишите нам в &lt;a href=https://t.me/LibFinTravel&gt;&lt;b&gt;ТЕЛЕГРАМ&lt;/b&gt;&lt;/a&gt;: https://t.me/LibFinTravel \r\n \r\nИли заходите на &lt;a href=https://libertyfintravel.ru/vnj-i-vtoroe-grajdanstvo&gt;&lt;b&gt;сайт&lt;/b&gt;&lt;/a&gt;: https://libertyfintravel.ru/vnj-i-vtoroe-grajdanstvo','feedback','unread',NULL,NULL,NULL,'2025-10-16 18:56:44','2025-10-16 18:56:44'),
(34,'MarkusRek','profconbu_64@mail.ru','Потолки Натяжные Двухуровневый','Приходите к нам в гости и в живую оцените, как стильно это смотрится https://skyprofi.ru/stati/chto-luchshe-tkanevye-natyazhnye-potolki-ili-pvx/\r\n  Как обычный потолок может преобразиться с помощью современных технологий! \r\nСтоимость 20 000 руб Подробнее https://skyprofi.ru/faq/pochemu-u-menya-provislo-polotno-natyazhnogo-potolka-eto-brak/\r\n \r\n215 800 м2 потолков https://skyprofi.ru/natyazhnye-potolki-pvkh/matovye-natyazhnye-potolki/\r\n \r\nСПБ, Заячий пер, д https://skyprofi.ru/natyazhnoj-potolok-so-skrytym-karnizom/\r\n 4к1 Фотопечать на матовом потолке 21 м https://skyprofi.ru/stati/chernyj-natjazhnoj-potolok/\r\n кв https://skyprofi.ru/stati/natyazhnye-potolki-iz-belgii-evropejskoe-kachestvo/\r\n \r\nРаботы по установке https://skyprofi.ru/tenevye-natyazhnye-potolki/\r\n \r\nСредняя стоимость одного ПВХ потолка https://skyprofi.ru/stati/francuzskie-natyazhnye-potolki/','feedback','unread',NULL,NULL,NULL,'2025-10-16 19:07:37','2025-10-16 19:07:37'),
(35,'Edwardecore','dorofeyavinogradova199056@mail.ru','Воздушные Шары Оформление Воздушными','Хотите прежде изучить цены, и только потом заказать композицию https://zeelsharik.ru/catalog/product/nabor-37/\r\n  Выезд менеджера Big Happy к вам домой с полным каталогом студии — бесплатно! \r\nСтоимость зависит от метража, сложности узора, монтажа и доставки https://zeelsharik.ru/catalog/product/nabor-40/\r\n \r\nАрка из воздушных шаров (белый и голубой). \r\nСмешные и забавные фигуры из воздушных шариков, заказать которые вы можете в нашей студии воздушного дизайна, станут отличным украшением любого детского праздника, независимо от места его проведения – дома, в кафе или детском садике https://zeelsharik.ru/catalog/product/figura-disko-shar-golograficheskiy/\r\n \r\nАрка из шаров на открытие (зеленый https://zeelsharik.ru/catalog/product/shar-figura-lebed-s-dr/\r\n \r\nНаш ассортимент воздушных шаров настолько огромен, что вы без труда выберете именно тот вариант, от которого будут пищать от восторга не только дети, но и взрослые https://zeelsharik.ru/catalog/product/inercionnyy-motocikl/','technical_issue','unread',NULL,NULL,NULL,'2025-10-16 19:18:08','2025-10-16 19:18:08'),
(36,'Craigmab','valerakimuvo@mail.ru','Итальянские Мягкая Мебель','Внмание! Мы можем показать вам фабрики, мебель, а также выбрать материалы и отделки по видеосвязи! Вы останетесь дома или на работе, не теряя время и деньги, а мы съездим на фабрики за вас и всё вам покажем и расскажем! В общем, работаем ???, и ждем ваших новых заказов! \r\nБыстрый просмотр https://stosastudio.ru/top-10-idej-dlya-malenkoj-kuhni/\r\n \r\nБыстрый просмотр https://stosastudio.ru/gruppo-fox-italyanskaya-mebel-kak-forma-zhizni-a-ne-prosto-dizajn/\r\n \r\nГарантия лучшей цены https://stosastudio.ru/catalog/kuhni-marosi/\r\n \r\nС нами Вы можете приобрести мебель абсолютно любой фабрики! Мы активно сотрудничаем со всеми мебельными фабриками Италии, которых в настоящее время насчитывается более полутора тысяч https://stosastudio.ru/priglashenie-v-mir-uyuta-kuhnya-v-eko-stile/\r\n  Кроме этого, с нами Вы сможете приобрести итальянские люстры, плитку, сантехнику, бытовую технику, обои, шторы и аксессуары для дома https://stosastudio.ru/catalog/kuhni-city/\r\n \r\nСтрана: Италия Стиль: Классика https://stosastudio.ru/catalog/kuhni-capri/','technical_issue','unread',NULL,NULL,NULL,'2025-10-16 19:20:56','2025-10-16 19:20:56'),
(37,'RichardDyday','laisumake186@mail.ru','Молниезащиты Зданий','Основной вид испытаний в электроустановках до 1000В, производится при помощи мегаомметра или комплексных приборов ЭТЛ https://t-zamer.ru/\r\n  Позволяет выявить повреждение кабельных линий, как при прокладке, так и в процессе эксплуатации https://t-zamer.ru/uslugi/ispytanie-kabeley/\r\n  Произвести измерение возможно только при отключении электроэнергии, на проверяемой линии https://t-zamer.ru/v-pomosh-energetiku/kakie_izmereniya_provodyatsya_v_elektrolaboratorii/\r\n \r\n13 https://t-zamer.ru/aktsii/\r\n  Конфиденциальность персональных данных https://t-zamer.ru/uslugi/ispytaniya-siz/dielektricheskikh-perchatok/\r\n \r\nУслуги электроизмерительной лаборатории  можно заказать по телефону (495) 172-48-47 или по электронной почте info@elaba24 https://t-zamer.ru/uslugi/ispytaniya-siz/dielektricheskikh-bot/\r\n ru https://t-zamer.ru/v-pomosh-energetiku/akkreditovannaya_elektrolaboratoriya/\r\n  Наши специалисты помогут разобраться с поставленной задачей и оперативно определить стоимость испытаний https://t-zamer.ru/policy/\r\n \r\nТакже в нашей компании можно заказать независимую экспертизу электрики или технадзор электромонтажных работ, наши инженеры полностью обследуют ваш объект, по результатам вы получите полный список всех дефектов и нарушений https://t-zamer.ru/policy/\r\n \r\nЭлектроизмерительная лаборатория АО  проводит измерение паромеров качества электрической энергии на территории города Москвы и Московской области https://t-zamer.ru/contacts/\r\n  По результату выполненных измерений вы получите отчёт в соответствии с ГОСТ 32144-2013с копией свидетельства о регистрации электроизмерительной лаборатории, на основании которого сможете оптимизировать качество электроснабжения и работу оборудования, тем самым вы получите возможность сократить расходы, улучшить работу отдельных приборов и сократить количество поломок https://t-zamer.ru/uslugi/teplovizionnoe-obsledovanie/\r\n \r\nЦена от 7 500 руб https://t-zamer.ru/uslugi/teplovizionnoe-obsledovanie/','account_help','unread',NULL,NULL,NULL,'2025-10-16 19:26:51','2025-10-16 19:26:51'),
(38,'Dannyclate','guerfupe@mail.ru','Умная Холодильник','Полная загрузка стаканов: 600 шт https://vendavtomat.ru/index.php?route=product/category&amp;path=17_76\r\n \r\nАнтивандальный металлический корпус 600 одноразовых стаканчиков Тип используемых стаканчиков: 70,3 мм Загрузка воды – 76 литров (4 бутыли по 19 литров) Загрузка сиропов: до 40 литров Ассортимент: до 4 сиропов (в базовой комплектации 2 сиропа) Программируемая стоимость напитков - без необходимости подключать ноутбук LCD-дисплей Монетоприемник NRI Currenza Green с функцией выдачи сдачи 4 номиналами монет (опция) Купюроприемник ICT A7 (опция) Баллоны СО2 – до 2 шт https://vendavtomat.ru/konfety/juice_tutti_frutti\r\n  по 10 литров (в базовую стоимость не входят) Возможность подключения к водопроводу (опция) Климат-контроль (опция) Модуль выдачи горячих напитков (опция) GPRS-модуль (опция) Бесплатный Интернет-мониторинг (при наличии GPRS-модуля) Селектор бутыли - позволяет расходовать воду из бутылей поочередно (опция) Лайтбокс с ударопрочным стеклом и возможностью смены постеров Индивидуальная подсветка ценников https://vendavtomat.ru/index.php?route=product/manufacturer/info&amp;manufacturer_id=17\r\n \r\nАвтоматам газированной воды &quot;Дельта&quot; доверили свой бизнес сотни предпринимателей https://vendavtomat.ru/index.php?route=product/special\r\n  На то, чтобы завоевать это доверие, нам потребовалось 20 лет https://vendavtomat.ru/napolnitel_mekhanicheskih_avtomatov/zhevatelnaya_rezinka_22mm_molodilnye_yablochki\r\n  Сегодня Вы можете всего за 5 минут узнать, что представляет из себя модельный ряд и какие преимущества имеют автоматы газ-воды &quot;Дельта&quot; \r\n* Цена за 1 упаковку https://vendavtomat.ru/vopros_otvet\r\n \r\nИнгредиенты для автомата: \r\nДозированная выдача воды - 4300,00 руб https://vendavtomat.ru/ingredienty_kofejnyh_avtomatov_kofemashin','seller_inquiry','unread',NULL,NULL,NULL,'2025-10-16 19:28:49','2025-10-16 19:28:49');
/*!40000 ALTER TABLE `contact_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conversation_threads`
--

DROP TABLE IF EXISTS `conversation_threads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `conversation_threads` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `buyer_id` int(11) NOT NULL,
  `seller_id` int(11) NOT NULL,
  `status` enum('active','archived','flagged') DEFAULT 'active',
  `last_message_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_thread` (`product_id`,`buyer_id`,`seller_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_buyer_id` (`buyer_id`),
  KEY `idx_seller_id` (`seller_id`),
  KEY `idx_status` (`status`),
  KEY `idx_last_message_at` (`last_message_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conversation_threads`
--

LOCK TABLES `conversation_threads` WRITE;
/*!40000 ALTER TABLE `conversation_threads` DISABLE KEYS */;
INSERT INTO `conversation_threads` VALUES
(1,13,4,3,'active','2025-10-15 20:12:09','2025-10-15 20:12:09','2025-10-15 20:12:09');
/*!40000 ALTER TABLE `conversation_threads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `countries` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'Country name',
  `iso2` char(2) NOT NULL COMMENT 'ISO 3166-1 alpha-2 code',
  `iso3` char(3) NOT NULL COMMENT 'ISO 3166-1 alpha-3 code',
  `dial_code` varchar(10) NOT NULL COMMENT 'International dialing code with + prefix',
  `is_eu` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 if EU member state, 0 otherwise',
  `currency_code` char(3) NOT NULL DEFAULT 'USD' COMMENT 'ISO 4217 currency code',
  `currency_symbol` varchar(10) NOT NULL DEFAULT '$' COMMENT 'Currency symbol',
  `flag_emoji` varchar(10) NOT NULL COMMENT 'Flag emoji for display',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_iso2` (`iso2`),
  UNIQUE KEY `unique_iso3` (`iso3`),
  KEY `idx_name` (`name`),
  KEY `idx_is_eu` (`is_eu`),
  KEY `idx_currency_code` (`currency_code`)
) ENGINE=InnoDB AUTO_INCREMENT=194 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores comprehensive country data for checkout and localization';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `countries`
--

LOCK TABLES `countries` WRITE;
/*!40000 ALTER TABLE `countries` DISABLE KEYS */;
INSERT INTO `countries` VALUES
(1,'Afghanistan','AF','AFG','+93',0,'USD','$','🇦🇫','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(2,'Albania','AL','ALB','+355',0,'USD','$','🇦🇱','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(3,'Algeria','DZ','DZA','+213',0,'USD','$','🇩🇿','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(4,'Andorra','AD','AND','+376',0,'EUR','€','🇦🇩','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(5,'Angola','AO','AGO','+244',0,'USD','$','🇦🇴','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(6,'Antigua and Barbuda','AG','ATG','+1268',0,'USD','$','🇦🇬','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(7,'Argentina','AR','ARG','+54',0,'USD','$','🇦🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(8,'Armenia','AM','ARM','+374',0,'USD','$','🇦🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(9,'Australia','AU','AUS','+61',0,'USD','$','🇦🇺','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(10,'Austria','AT','AUT','+43',1,'EUR','€','🇦🇹','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(11,'Azerbaijan','AZ','AZE','+994',0,'USD','$','🇦🇿','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(12,'Bahamas','BS','BHS','+1242',0,'USD','$','🇧🇸','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(13,'Bahrain','BH','BHR','+973',0,'USD','$','🇧🇭','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(14,'Bangladesh','BD','BGD','+880',0,'USD','$','🇧🇩','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(15,'Barbados','BB','BRB','+1246',0,'USD','$','🇧🇧','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(16,'Belarus','BY','BLR','+375',0,'USD','$','🇧🇾','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(17,'Belgium','BE','BEL','+32',1,'EUR','€','🇧🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(18,'Belize','BZ','BLZ','+501',0,'USD','$','🇧🇿','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(19,'Benin','BJ','BEN','+229',0,'USD','$','🇧🇯','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(20,'Bhutan','BT','BTN','+975',0,'USD','$','🇧🇹','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(21,'Bolivia','BO','BOL','+591',0,'USD','$','🇧🇴','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(22,'Bosnia and Herzegovina','BA','BIH','+387',0,'USD','$','🇧🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(23,'Botswana','BW','BWA','+267',0,'USD','$','🇧🇼','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(24,'Brazil','BR','BRA','+55',0,'USD','$','🇧🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(25,'Brunei','BN','BRN','+673',0,'USD','$','🇧🇳','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(26,'Bulgaria','BG','BGR','+359',1,'EUR','€','🇧🇬','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(27,'Burkina Faso','BF','BFA','+226',0,'USD','$','🇧🇫','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(28,'Burundi','BI','BDI','+257',0,'USD','$','🇧🇮','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(29,'Cambodia','KH','KHM','+855',0,'USD','$','🇰🇭','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(30,'Cameroon','CM','CMR','+237',0,'USD','$','🇨🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(31,'Canada','CA','CAN','+1',0,'USD','$','🇨🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(32,'Cape Verde','CV','CPV','+238',0,'USD','$','🇨🇻','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(33,'Central African Republic','CF','CAF','+236',0,'USD','$','🇨🇫','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(34,'Chad','TD','TCD','+235',0,'USD','$','🇹🇩','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(35,'Chile','CL','CHL','+56',0,'USD','$','🇨🇱','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(36,'China','CN','CHN','+86',0,'USD','$','🇨🇳','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(37,'Colombia','CO','COL','+57',0,'USD','$','🇨🇴','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(38,'Comoros','KM','COM','+269',0,'USD','$','🇰🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(39,'Congo','CG','COG','+242',0,'USD','$','🇨🇬','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(40,'Costa Rica','CR','CRI','+506',0,'USD','$','🇨🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(41,'Croatia','HR','HRV','+385',1,'EUR','€','🇭🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(42,'Cuba','CU','CUB','+53',0,'USD','$','🇨🇺','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(43,'Cyprus','CY','CYP','+357',1,'EUR','€','🇨🇾','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(44,'Czech Republic','CZ','CZE','+420',1,'EUR','€','🇨🇿','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(45,'Denmark','DK','DNK','+45',1,'EUR','€','🇩🇰','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(46,'Djibouti','DJ','DJI','+253',0,'USD','$','🇩🇯','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(47,'Dominica','DM','DMA','+1767',0,'USD','$','🇩🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(48,'Dominican Republic','DO','DOM','+1',0,'USD','$','🇩🇴','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(49,'Ecuador','EC','ECU','+593',0,'USD','$','🇪🇨','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(50,'Egypt','EG','EGY','+20',0,'USD','$','🇪🇬','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(51,'El Salvador','SV','SLV','+503',0,'USD','$','🇸🇻','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(52,'Equatorial Guinea','GQ','GNQ','+240',0,'USD','$','🇬🇶','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(53,'Eritrea','ER','ERI','+291',0,'USD','$','🇪🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(54,'Estonia','EE','EST','+372',1,'EUR','€','🇪🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(55,'Ethiopia','ET','ETH','+251',0,'USD','$','🇪🇹','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(56,'Fiji','FJ','FJI','+679',0,'USD','$','🇫🇯','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(57,'Finland','FI','FIN','+358',1,'EUR','€','🇫🇮','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(58,'France','FR','FRA','+33',1,'EUR','€','🇫🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(59,'Gabon','GA','GAB','+241',0,'USD','$','🇬🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(60,'Gambia','GM','GMB','+220',0,'USD','$','🇬🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(61,'Georgia','GE','GEO','+995',0,'USD','$','🇬🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(62,'Germany','DE','DEU','+49',1,'EUR','€','🇩🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(63,'Ghana','GH','GHA','+233',0,'USD','$','🇬🇭','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(64,'Greece','GR','GRC','+30',1,'EUR','€','🇬🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(65,'Grenada','GD','GRD','+1473',0,'USD','$','🇬🇩','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(66,'Guatemala','GT','GTM','+502',0,'USD','$','🇬🇹','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(67,'Guinea','GN','GIN','+224',0,'USD','$','🇬🇳','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(68,'Guinea-Bissau','GW','GNB','+245',0,'USD','$','🇬🇼','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(69,'Guyana','GY','GUY','+592',0,'USD','$','🇬🇾','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(70,'Haiti','HT','HTI','+509',0,'USD','$','🇭🇹','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(71,'Honduras','HN','HND','+504',0,'USD','$','🇭🇳','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(72,'Hungary','HU','HUN','+36',1,'EUR','€','🇭🇺','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(73,'Iceland','IS','ISL','+354',0,'USD','$','🇮🇸','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(74,'India','IN','IND','+91',0,'USD','$','🇮🇳','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(75,'Indonesia','ID','IDN','+62',0,'USD','$','🇮🇩','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(76,'Iran','IR','IRN','+98',0,'USD','$','🇮🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(77,'Iraq','IQ','IRQ','+964',0,'USD','$','🇮🇶','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(78,'Ireland','IE','IRL','+353',1,'EUR','€','🇮🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(79,'Israel','IL','ISR','+972',0,'USD','$','🇮🇱','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(80,'Italy','IT','ITA','+39',1,'EUR','€','🇮🇹','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(81,'Jamaica','JM','JAM','+1876',0,'USD','$','🇯🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(82,'Japan','JP','JPN','+81',0,'USD','$','🇯🇵','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(83,'Jordan','JO','JOR','+962',0,'USD','$','🇯🇴','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(84,'Kazakhstan','KZ','KAZ','+7',0,'USD','$','🇰🇿','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(85,'Kenya','KE','KEN','+254',0,'USD','$','🇰🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(86,'Kiribati','KI','KIR','+686',0,'USD','$','🇰🇮','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(87,'Kuwait','KW','KWT','+965',0,'USD','$','🇰🇼','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(88,'Kyrgyzstan','KG','KGZ','+996',0,'USD','$','🇰🇬','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(89,'Laos','LA','LAO','+856',0,'USD','$','🇱🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(90,'Latvia','LV','LVA','+371',1,'EUR','€','🇱🇻','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(91,'Lebanon','LB','LBN','+961',0,'USD','$','🇱🇧','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(92,'Lesotho','LS','LSO','+266',0,'USD','$','🇱🇸','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(93,'Liberia','LR','LBR','+231',0,'USD','$','🇱🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(94,'Libya','LY','LBY','+218',0,'USD','$','🇱🇾','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(95,'Liechtenstein','LI','LIE','+423',0,'USD','$','🇱🇮','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(96,'Lithuania','LT','LTU','+370',1,'EUR','€','🇱🇹','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(97,'Luxembourg','LU','LUX','+352',1,'EUR','€','🇱🇺','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(98,'Macedonia','MK','MKD','+389',0,'USD','$','🇲🇰','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(99,'Madagascar','MG','MDG','+261',0,'USD','$','🇲🇬','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(100,'Malawi','MW','MWI','+265',0,'USD','$','🇲🇼','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(101,'Malaysia','MY','MYS','+60',0,'USD','$','🇲🇾','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(102,'Maldives','MV','MDV','+960',0,'USD','$','🇲🇻','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(103,'Mali','ML','MLI','+223',0,'USD','$','🇲🇱','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(104,'Malta','MT','MLT','+356',1,'EUR','€','🇲🇹','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(105,'Marshall Islands','MH','MHL','+692',0,'USD','$','🇲🇭','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(106,'Mauritania','MR','MRT','+222',0,'USD','$','🇲🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(107,'Mauritius','MU','MUS','+230',0,'USD','$','🇲🇺','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(108,'Mexico','MX','MEX','+52',0,'USD','$','🇲🇽','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(109,'Micronesia','FM','FSM','+691',0,'USD','$','🇫🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(110,'Moldova','MD','MDA','+373',0,'USD','$','🇲🇩','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(111,'Monaco','MC','MCO','+377',0,'EUR','€','🇲🇨','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(112,'Mongolia','MN','MNG','+976',0,'USD','$','🇲🇳','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(113,'Montenegro','ME','MNE','+382',0,'EUR','€','🇲🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(114,'Morocco','MA','MAR','+212',0,'USD','$','🇲🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(115,'Mozambique','MZ','MOZ','+258',0,'USD','$','🇲🇿','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(116,'Myanmar','MM','MMR','+95',0,'USD','$','🇲🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(117,'Namibia','NA','NAM','+264',0,'USD','$','🇳🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(118,'Nauru','NR','NRU','+674',0,'USD','$','🇳🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(119,'Nepal','NP','NPL','+977',0,'USD','$','🇳🇵','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(120,'Netherlands','NL','NLD','+31',1,'EUR','€','🇳🇱','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(121,'New Zealand','NZ','NZL','+64',0,'USD','$','🇳🇿','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(122,'Nicaragua','NI','NIC','+505',0,'USD','$','🇳🇮','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(123,'Niger','NE','NER','+227',0,'USD','$','🇳🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(124,'Nigeria','NG','NGA','+234',0,'USD','$','🇳🇬','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(125,'Norway','NO','NOR','+47',0,'USD','$','🇳🇴','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(126,'Oman','OM','OMN','+968',0,'USD','$','🇴🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(127,'Pakistan','PK','PAK','+92',0,'USD','$','🇵🇰','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(128,'Palau','PW','PLW','+680',0,'USD','$','🇵🇼','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(129,'Panama','PA','PAN','+507',0,'USD','$','🇵🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(130,'Papua New Guinea','PG','PNG','+675',0,'USD','$','🇵🇬','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(131,'Paraguay','PY','PRY','+595',0,'USD','$','🇵🇾','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(132,'Peru','PE','PER','+51',0,'USD','$','🇵🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(133,'Philippines','PH','PHL','+63',0,'USD','$','🇵🇭','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(134,'Poland','PL','POL','+48',1,'EUR','€','🇵🇱','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(135,'Portugal','PT','PRT','+351',1,'EUR','€','🇵🇹','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(136,'Qatar','QA','QAT','+974',0,'USD','$','🇶🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(137,'Romania','RO','ROU','+40',1,'EUR','€','🇷🇴','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(138,'Russia','RU','RUS','+7',0,'USD','$','🇷🇺','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(139,'Rwanda','RW','RWA','+250',0,'RWF','FRw','🇷🇼','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(140,'Saint Kitts and Nevis','KN','KNA','+1869',0,'USD','$','🇰🇳','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(141,'Saint Lucia','LC','LCA','+1758',0,'USD','$','🇱🇨','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(142,'Saint Vincent and the Grenadines','VC','VCT','+1784',0,'USD','$','🇻🇨','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(143,'Samoa','WS','WSM','+685',0,'USD','$','🇼🇸','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(144,'San Marino','SM','SMR','+378',0,'EUR','€','🇸🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(145,'Sao Tome and Principe','ST','STP','+239',0,'USD','$','🇸🇹','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(146,'Saudi Arabia','SA','SAU','+966',0,'USD','$','🇸🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(147,'Senegal','SN','SEN','+221',0,'USD','$','🇸🇳','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(148,'Serbia','RS','SRB','+381',0,'USD','$','🇷🇸','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(149,'Seychelles','SC','SYC','+248',0,'USD','$','🇸🇨','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(150,'Sierra Leone','SL','SLE','+232',0,'USD','$','🇸🇱','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(151,'Singapore','SG','SGP','+65',0,'USD','$','🇸🇬','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(152,'Slovakia','SK','SVK','+421',1,'EUR','€','🇸🇰','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(153,'Slovenia','SI','SVN','+386',1,'EUR','€','🇸🇮','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(154,'Solomon Islands','SB','SLB','+677',0,'USD','$','🇸🇧','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(155,'Somalia','SO','SOM','+252',0,'USD','$','🇸🇴','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(156,'South Africa','ZA','ZAF','+27',0,'USD','$','🇿🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(157,'South Korea','KR','KOR','+82',0,'USD','$','🇰🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(158,'South Sudan','SS','SSD','+211',0,'USD','$','🇸🇸','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(159,'Spain','ES','ESP','+34',1,'EUR','€','🇪🇸','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(160,'Sri Lanka','LK','LKA','+94',0,'USD','$','🇱🇰','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(161,'Sudan','SD','SDN','+249',0,'USD','$','🇸🇩','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(162,'Suriname','SR','SUR','+597',0,'USD','$','🇸🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(163,'Swaziland','SZ','SWZ','+268',0,'USD','$','🇸🇿','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(164,'Sweden','SE','SWE','+46',1,'EUR','€','🇸🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(165,'Switzerland','CH','CHE','+41',0,'USD','$','🇨🇭','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(166,'Syria','SY','SYR','+963',0,'USD','$','🇸🇾','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(167,'Taiwan','TW','TWN','+886',0,'USD','$','🇹🇼','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(168,'Tajikistan','TJ','TJK','+992',0,'USD','$','🇹🇯','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(169,'Tanzania','TZ','TZA','+255',0,'USD','$','🇹🇿','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(170,'Thailand','TH','THA','+66',0,'USD','$','🇹🇭','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(171,'Timor-Leste','TL','TLS','+670',0,'USD','$','🇹🇱','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(172,'Togo','TG','TGO','+228',0,'USD','$','🇹🇬','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(173,'Tonga','TO','TON','+676',0,'USD','$','🇹🇴','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(174,'Trinidad and Tobago','TT','TTO','+1868',0,'USD','$','🇹🇹','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(175,'Tunisia','TN','TUN','+216',0,'USD','$','🇹🇳','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(176,'Turkey','TR','TUR','+90',0,'USD','$','🇹🇷','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(177,'Turkmenistan','TM','TKM','+993',0,'USD','$','🇹🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(178,'Tuvalu','TV','TUV','+688',0,'USD','$','🇹🇻','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(179,'Uganda','UG','UGA','+256',0,'USD','$','🇺🇬','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(180,'Ukraine','UA','UKR','+380',0,'USD','$','🇺🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(181,'United Arab Emirates','AE','ARE','+971',0,'USD','$','🇦🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(182,'United Kingdom','GB','GBR','+44',0,'GBP','£','🇬🇧','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(183,'United States','US','USA','+1',0,'USD','$','🇺🇸','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(184,'Uruguay','UY','URY','+598',0,'USD','$','🇺🇾','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(185,'Uzbekistan','UZ','UZB','+998',0,'USD','$','🇺🇿','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(186,'Vanuatu','VU','VUT','+678',0,'USD','$','🇻🇺','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(187,'Vatican City','VA','VAT','+39',0,'EUR','€','🇻🇦','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(188,'Venezuela','VE','VEN','+58',0,'USD','$','🇻🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(189,'Vietnam','VN','VNM','+84',0,'USD','$','🇻🇳','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(190,'Yemen','YE','YEM','+967',0,'USD','$','🇾🇪','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(191,'Zambia','ZM','ZMB','+260',0,'USD','$','🇿🇲','2025-10-11 18:55:24','2025-10-14 19:56:29'),
(192,'Zimbabwe','ZW','ZWE','+263',0,'USD','$','🇿🇼','2025-10-11 18:55:24','2025-10-14 19:56:29');
/*!40000 ALTER TABLE `countries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon_redemptions`
--

DROP TABLE IF EXISTS `coupon_redemptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon_redemptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coupon_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `discount_amount` decimal(10,2) NOT NULL,
  `original_order_amount` decimal(10,2) NOT NULL,
  `final_order_amount` decimal(10,2) NOT NULL,
  `redeemed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `used_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_coupon_id` (`coupon_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_redeemed_at` (`redeemed_at`),
  CONSTRAINT `fk_coupon_redemptions_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_coupon_redemptions_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_coupon_redemptions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon_redemptions`
--

LOCK TABLES `coupon_redemptions` WRITE;
/*!40000 ALTER TABLE `coupon_redemptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `coupon_redemptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon_rules`
--

DROP TABLE IF EXISTS `coupon_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coupon_id` int(11) NOT NULL,
  `rule_type` enum('minimum_amount','product_category','user_segment','date_range','usage_limit','first_time_buyer') NOT NULL,
  `rule_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`rule_data`)),
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_coupon_id` (`coupon_id`),
  KEY `idx_rule_type` (`rule_type`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_coupon_rules_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon_rules`
--

LOCK TABLES `coupon_rules` WRITE;
/*!40000 ALTER TABLE `coupon_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `coupon_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon_usage`
--

DROP TABLE IF EXISTS `coupon_usage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon_usage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coupon_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `discount_amount` decimal(10,2) NOT NULL,
  `used_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_coupon_id` (`coupon_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_used_at` (`used_at`),
  CONSTRAINT `fk_coupon_usage_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_coupon_usage_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_coupon_usage_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon_usage`
--

LOCK TABLES `coupon_usage` WRITE;
/*!40000 ALTER TABLE `coupon_usage` DISABLE KEYS */;
/*!40000 ALTER TABLE `coupon_usage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupons`
--

DROP TABLE IF EXISTS `coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(80) DEFAULT NULL,
  `name` varchar(150) DEFAULT NULL,
  `type` enum('fixed','percentage') NOT NULL DEFAULT 'fixed',
  `value` decimal(10,2) NOT NULL,
  `minimum_amount` decimal(10,2) DEFAULT NULL,
  `maximum_discount` decimal(10,2) DEFAULT NULL,
  `usage_limit` int(11) DEFAULT NULL,
  `usage_count` int(11) NOT NULL DEFAULT 0,
  `user_usage_limit` int(11) DEFAULT NULL,
  `status` enum('active','inactive','expired') NOT NULL DEFAULT 'active',
  `valid_from` timestamp NULL DEFAULT NULL,
  `valid_to` timestamp NULL DEFAULT NULL,
  `applies_to` enum('all','categories','products','users') NOT NULL DEFAULT 'all',
  `applicable_items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`applicable_items`)),
  `description` text DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `expires_at` datetime DEFAULT NULL,
  `min_purchase_amount` decimal(10,2) DEFAULT NULL,
  `max_discount_amount` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_valid_from` (`valid_from`),
  KEY `idx_valid_to` (`valid_to`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_coupons_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupons`
--

LOCK TABLES `coupons` WRITE;
/*!40000 ALTER TABLE `coupons` DISABLE KEYS */;
INSERT INTO `coupons` VALUES
(1,'DDDD',NULL,'percentage',10.00,NULL,NULL,12,0,NULL,'active',NULL,NULL,'all',NULL,'',NULL,'2025-10-14 22:41:38','2025-10-14 22:41:38','2025-10-23 00:38:00',100.00,12.00);
/*!40000 ALTER TABLE `coupons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `currencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(3) NOT NULL,
  `name` varchar(100) NOT NULL,
  `symbol` varchar(10) NOT NULL,
  `decimal_places` tinyint(2) NOT NULL DEFAULT 2,
  `exchange_rate` decimal(10,6) NOT NULL DEFAULT 1.000000,
  `is_base_currency` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code` (`code`),
  KEY `idx_is_base_currency` (`is_base_currency`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currencies`
--

LOCK TABLES `currencies` WRITE;
/*!40000 ALTER TABLE `currencies` DISABLE KEYS */;
INSERT INTO `currencies` VALUES
(1,'USD','US Dollar','$',2,1.000000,1,1,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(2,'EUR','Euro','â‚¬',2,0.850000,0,1,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(3,'GBP','British Pound','Â£',2,0.750000,0,1,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(4,'JPY','Japanese Yen','Â¥',0,110.000000,0,1,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(5,'CAD','Canadian Dollar','C$',2,1.250000,0,1,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(6,'AUD','Australian Dollar','A$',2,1.350000,0,1,'2025-09-14 19:54:26','2025-09-14 19:54:26');
/*!40000 ALTER TABLE `currencies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currency_rates`
--

DROP TABLE IF EXISTS `currency_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `currency_rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `base` varchar(3) NOT NULL COMMENT 'Base currency code (e.g., USD)',
  `quote` varchar(3) NOT NULL COMMENT 'Quote currency code (e.g., EUR)',
  `rate` decimal(20,8) NOT NULL DEFAULT 1.00000000 COMMENT 'Exchange rate from base to quote',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last updated timestamp',
  `currency_code` varchar(3) DEFAULT NULL COMMENT 'Currency code for direct lookup',
  `rate_to_usd` decimal(18,6) DEFAULT NULL COMMENT 'Exchange rate to USD',
  `currency_symbol` varchar(10) DEFAULT NULL COMMENT 'Currency symbol',
  `currency_name` varchar(50) DEFAULT NULL COMMENT 'Currency name',
  `last_updated` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last updated timestamp for currency data',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pair` (`base`,`quote`),
  UNIQUE KEY `currency_code` (`currency_code`),
  KEY `idx_base` (`base`),
  KEY `idx_quote` (`quote`),
  KEY `last_updated` (`last_updated`),
  KEY `idx_currency_code` (`currency_code`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currency_rates`
--

LOCK TABLES `currency_rates` WRITE;
/*!40000 ALTER TABLE `currency_rates` DISABLE KEYS */;
INSERT INTO `currency_rates` VALUES
(1,'USD','USD',1.00000000,'2025-10-15 19:26:52','USD',1.000000,'$','US Dollar','2025-10-15 19:26:52'),
(2,'USD','EUR',0.86415094,'2025-10-16 21:29:18','EUR',1.164144,'€','Euro','2025-10-16 21:29:18'),
(3,'USD','RWF',1320.00000000,'2025-10-16 21:29:18','RWF',1453.950000,'FRw','Rwandan Franc','2025-10-16 21:29:18');
/*!40000 ALTER TABLE `currency_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_downloads`
--

DROP TABLE IF EXISTS `customer_downloads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_downloads` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `digital_product_id` bigint(20) unsigned NOT NULL,
  `download_token` varchar(255) NOT NULL,
  `download_count` int(11) NOT NULL DEFAULT 0,
  `download_limit` int(11) DEFAULT NULL COMMENT 'NULL = unlimited',
  `expires_at` timestamp NULL DEFAULT NULL,
  `last_downloaded_at` timestamp NULL DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_download_token` (`download_token`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_digital_product_id` (`digital_product_id`),
  KEY `idx_expires_at` (`expires_at`),
  CONSTRAINT `fk_cd_digital_product` FOREIGN KEY (`digital_product_id`) REFERENCES `digital_products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cd_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cd_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cd_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_downloads`
--

LOCK TABLES `customer_downloads` WRITE;
/*!40000 ALTER TABLE `customer_downloads` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_downloads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_order_feedback`
--

DROP TABLE IF EXISTS `customer_order_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_order_feedback` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `rating` tinyint(1) NOT NULL CHECK (`rating` between 1 and 5),
  `delivery_rating` tinyint(1) DEFAULT NULL CHECK (`delivery_rating` between 1 and 5),
  `communication_rating` tinyint(1) DEFAULT NULL CHECK (`communication_rating` between 1 and 5),
  `feedback_text` text DEFAULT NULL,
  `would_recommend` tinyint(1) DEFAULT NULL,
  `issues_encountered` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`issues_encountered`)),
  `seller_response` text DEFAULT NULL,
  `seller_responded_at` timestamp NULL DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 1,
  `helpful_count` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_order_customer` (`order_id`,`customer_id`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_rating` (`rating`),
  KEY `idx_is_public` (`is_public`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_customer_order_feedback_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_customer_order_feedback_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_customer_order_feedback_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_order_feedback`
--

LOCK TABLES `customer_order_feedback` WRITE;
/*!40000 ALTER TABLE `customer_order_feedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_order_feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_profiles`
--

DROP TABLE IF EXISTS `customer_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other','prefer_not_to_say') DEFAULT NULL,
  `interests` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`interests`)),
  `preferred_language` varchar(5) NOT NULL DEFAULT 'en',
  `preferred_currency` varchar(3) NOT NULL DEFAULT 'USD',
  `marketing_consent` tinyint(1) NOT NULL DEFAULT 0,
  `data_processing_consent` tinyint(1) NOT NULL DEFAULT 1,
  `newsletter_subscription` tinyint(1) NOT NULL DEFAULT 0,
  `sms_notifications` tinyint(1) NOT NULL DEFAULT 0,
  `loyalty_points` int(11) NOT NULL DEFAULT 0,
  `total_spent` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_orders` int(11) NOT NULL DEFAULT 0,
  `favorite_categories` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`favorite_categories`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_id` (`user_id`),
  KEY `idx_preferred_language` (`preferred_language`),
  KEY `idx_loyalty_points` (`loyalty_points`),
  KEY `idx_total_spent` (`total_spent`),
  CONSTRAINT `fk_customer_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_profiles`
--

LOCK TABLES `customer_profiles` WRITE;
/*!40000 ALTER TABLE `customer_profiles` DISABLE KEYS */;
INSERT INTO `customer_profiles` VALUES
(1,4,NULL,NULL,NULL,'en','USD',0,1,0,0,0,0.00,0,NULL,'2025-09-14 19:54:24','2025-09-14 19:54:24');
/*!40000 ALTER TABLE `customer_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_support_conversations`
--

DROP TABLE IF EXISTS `customer_support_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_support_conversations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ticket_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `message` longtext NOT NULL,
  `message_type` enum('customer','vendor','admin','system','auto') NOT NULL DEFAULT 'customer',
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
  `is_internal` tinyint(1) NOT NULL DEFAULT 0,
  `read_by_customer` tinyint(1) NOT NULL DEFAULT 0,
  `read_by_vendor` tinyint(1) NOT NULL DEFAULT 0,
  `read_by_admin` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_ticket_id` (`ticket_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_message_type` (`message_type`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_support_conversations_admin` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_support_conversations_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_support_conversations_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_support_conversations_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_support_conversations`
--

LOCK TABLES `customer_support_conversations` WRITE;
/*!40000 ALTER TABLE `customer_support_conversations` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_support_conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `stripe_customer_id` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_customer_email` (`email`),
  UNIQUE KEY `uniq_customer_stripe` (`stripe_customer_id`),
  KEY `idx_customer_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dashboard_widgets`
--

DROP TABLE IF EXISTS `dashboard_widgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dashboard_widgets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `widget_type` enum('kpi','chart','table','notification','counter','link','activity') NOT NULL,
  `widget_name` varchar(255) NOT NULL,
  `widget_config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`widget_config`)),
  `position_x` int(11) NOT NULL DEFAULT 0,
  `position_y` int(11) NOT NULL DEFAULT 0,
  `width` int(11) NOT NULL DEFAULT 4,
  `height` int(11) NOT NULL DEFAULT 4,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_widget_type` (`widget_type`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_dashboard_widgets_user_active` (`user_id`,`is_active`),
  CONSTRAINT `fk_dashboard_widgets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dashboard_widgets`
--

LOCK TABLES `dashboard_widgets` WRITE;
/*!40000 ALTER TABLE `dashboard_widgets` DISABLE KEYS */;
/*!40000 ALTER TABLE `dashboard_widgets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `digital_products`
--

DROP TABLE IF EXISTS `digital_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `digital_products` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint(20) NOT NULL COMMENT 'Size in bytes',
  `file_type` varchar(100) DEFAULT NULL,
  `version` varchar(50) DEFAULT '1.0',
  `download_limit` int(11) DEFAULT NULL COMMENT 'NULL = unlimited',
  `expiry_days` int(11) DEFAULT NULL COMMENT 'Days after purchase before link expires',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_product_version` (`product_id`,`version`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_dp_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digital_products`
--

LOCK TABLES `digital_products` WRITE;
/*!40000 ALTER TABLE `digital_products` DISABLE KEYS */;
/*!40000 ALTER TABLE `digital_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dispute_activity`
--

DROP TABLE IF EXISTS `dispute_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dispute_activity` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dispute_id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL,
  `actor_type` enum('user','admin','system') NOT NULL,
  `action` varchar(100) NOT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dispute_id` (`dispute_id`),
  KEY `idx_actor_id` (`actor_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `dispute_activity_ibfk_1` FOREIGN KEY (`dispute_id`) REFERENCES `disputes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dispute_activity`
--

LOCK TABLES `dispute_activity` WRITE;
/*!40000 ALTER TABLE `dispute_activity` DISABLE KEYS */;
/*!40000 ALTER TABLE `dispute_activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dispute_decisions`
--

DROP TABLE IF EXISTS `dispute_decisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dispute_decisions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dispute_id` int(11) NOT NULL,
  `decided_by` int(11) NOT NULL,
  `decision` enum('favor_customer','favor_vendor','split_decision','need_more_info','escalate') NOT NULL,
  `reasoning` text NOT NULL,
  `resolution_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`resolution_details`)),
  `financial_impact` decimal(10,2) DEFAULT NULL,
  `follow_up_required` tinyint(1) NOT NULL DEFAULT 0,
  `follow_up_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dispute_id` (`dispute_id`),
  KEY `idx_decided_by` (`decided_by`),
  KEY `idx_decision` (`decision`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_dispute_decisions_decider` FOREIGN KEY (`decided_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dispute_decisions_dispute` FOREIGN KEY (`dispute_id`) REFERENCES `disputes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dispute_decisions`
--

LOCK TABLES `dispute_decisions` WRITE;
/*!40000 ALTER TABLE `dispute_decisions` DISABLE KEYS */;
/*!40000 ALTER TABLE `dispute_decisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dispute_evidence`
--

DROP TABLE IF EXISTS `dispute_evidence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dispute_evidence` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dispute_id` int(11) NOT NULL,
  `uploaded_by` int(11) NOT NULL,
  `evidence_type` enum('image','document','video','other') NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `file_size` bigint(20) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dispute_id` (`dispute_id`),
  KEY `idx_uploaded_by` (`uploaded_by`),
  KEY `idx_evidence_type` (`evidence_type`),
  KEY `idx_is_public` (`is_public`),
  CONSTRAINT `fk_dispute_evidence_dispute` FOREIGN KEY (`dispute_id`) REFERENCES `disputes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dispute_evidence_uploader` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dispute_evidence`
--

LOCK TABLES `dispute_evidence` WRITE;
/*!40000 ALTER TABLE `dispute_evidence` DISABLE KEYS */;
/*!40000 ALTER TABLE `dispute_evidence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dispute_messages`
--

DROP TABLE IF EXISTS `dispute_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dispute_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dispute_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `sender_type` enum('customer','vendor','admin','system') NOT NULL,
  `message` text NOT NULL,
  `is_internal` tinyint(1) NOT NULL DEFAULT 0,
  `read_by_customer` tinyint(1) NOT NULL DEFAULT 0,
  `read_by_vendor` tinyint(1) NOT NULL DEFAULT 0,
  `read_by_admin` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dispute_id` (`dispute_id`),
  KEY `idx_sender_id` (`sender_id`),
  KEY `idx_sender_type` (`sender_type`),
  KEY `idx_is_internal` (`is_internal`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_dispute_messages_dispute` FOREIGN KEY (`dispute_id`) REFERENCES `disputes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dispute_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dispute_messages`
--

LOCK TABLES `dispute_messages` WRITE;
/*!40000 ALTER TABLE `dispute_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `dispute_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `disputes`
--

DROP TABLE IF EXISTS `disputes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `disputes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `dispute_number` varchar(50) NOT NULL,
  `type` enum('refund','return','quality','delivery','billing','other') NOT NULL,
  `category` enum('item_not_received','item_damaged','wrong_item','quality_issue','billing_error','shipping_issue','other') NOT NULL,
  `subject` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `amount_disputed` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` enum('open','investigating','pending_vendor','pending_customer','escalated','resolved','closed') NOT NULL DEFAULT 'open',
  `sla_deadline` datetime DEFAULT NULL,
  `priority` enum('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `assigned_to` int(11) DEFAULT NULL,
  `escalated_to` int(11) DEFAULT NULL,
  `sla_due_date` timestamp NULL DEFAULT NULL,
  `resolution_type` enum('refund','replacement','partial_refund','discount','no_action') DEFAULT NULL,
  `resolution_amount` decimal(10,2) DEFAULT NULL,
  `resolution_notes` text DEFAULT NULL,
  `customer_satisfaction` tinyint(1) DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_dispute_number` (`dispute_number`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_type` (`type`),
  KEY `idx_status` (`status`),
  KEY `idx_priority` (`priority`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `idx_sla_due_date` (`sla_due_date`),
  KEY `fk_disputes_escalated` (`escalated_to`),
  KEY `idx_disputes_status_priority` (`status`,`priority`,`sla_due_date`),
  CONSTRAINT `fk_disputes_assignee` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_disputes_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_disputes_escalated` FOREIGN KEY (`escalated_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_disputes_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_disputes_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `disputes`
--

LOCK TABLES `disputes` WRITE;
/*!40000 ALTER TABLE `disputes` DISABLE KEYS */;
/*!40000 ALTER TABLE `disputes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_attachments`
--

DROP TABLE IF EXISTS `email_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_attachments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `email_queue_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Reference to email_queue table',
  `notification_log_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Reference to notification_logs table',
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` int(10) unsigned NOT NULL COMMENT 'Size in bytes',
  `mime_type` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_email_queue_id` (`email_queue_id`),
  KEY `idx_notification_log_id` (`notification_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_attachments`
--

LOCK TABLES `email_attachments` WRITE;
/*!40000 ALTER TABLE `email_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_campaigns`
--

DROP TABLE IF EXISTS `email_campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_campaigns` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `subject` varchar(500) NOT NULL,
  `body` text NOT NULL,
  `recipient_type` enum('all','role','individual') NOT NULL,
  `recipient_filter` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`recipient_filter`)),
  `total_sent` int(10) unsigned NOT NULL DEFAULT 0,
  `total_opened` int(10) unsigned NOT NULL DEFAULT 0,
  `total_clicked` int(10) unsigned NOT NULL DEFAULT 0,
  `total_failed` int(10) unsigned NOT NULL DEFAULT 0,
  `status` enum('draft','scheduled','sending','sent','cancelled') NOT NULL DEFAULT 'draft',
  `sent_by` int(10) unsigned NOT NULL,
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_sent_by` (`sent_by`),
  KEY `idx_scheduled_at` (`scheduled_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_campaigns`
--

LOCK TABLES `email_campaigns` WRITE;
/*!40000 ALTER TABLE `email_campaigns` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_campaigns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_log`
--

DROP TABLE IF EXISTS `email_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_log` (
  `id` int(11) NOT NULL,
  `to_email` varchar(255) NOT NULL,
  `subject` varchar(500) NOT NULL,
  `template_name` varchar(100) DEFAULT NULL,
  `status` enum('sent','failed') NOT NULL,
  `error_message` text DEFAULT NULL,
  `sent_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_email_log_status` (`status`),
  KEY `idx_email_log_sent` (`sent_at`),
  KEY `idx_email_log_to_email` (`to_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_log`
--

LOCK TABLES `email_log` WRITE;
/*!40000 ALTER TABLE `email_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_logs`
--

DROP TABLE IF EXISTS `email_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recipient` varchar(255) NOT NULL,
  `subject` varchar(500) NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'general',
  `user_id` int(11) DEFAULT NULL,
  `status` enum('pending','sent','failed','error') NOT NULL DEFAULT 'pending',
  `error_message` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_recipient` (`recipient`),
  KEY `idx_status` (`status`),
  KEY `idx_type` (`type`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_logs`
--

LOCK TABLES `email_logs` WRITE;
/*!40000 ALTER TABLE `email_logs` DISABLE KEYS */;
INSERT INTO `email_logs` VALUES
(1,'fezamarketgroup@gmail.com','Verify your email address - FezaMarket','verification',13,'sent',NULL,'2025-10-07 17:04:44','2025-10-07 17:04:44'),
(2,'fezamarketgroup@gmail.com','Verify your email address - FezaMarket','verification',13,'sent',NULL,'2025-10-07 17:06:50','2025-10-07 17:06:50'),
(3,'fezalogistics@gmail.com','Verify your email address - FezaMarket','verification',14,'sent',NULL,'2025-10-07 18:17:13','2025-10-07 18:17:13'),
(4,'jumajumaa987@gmail.com','Verify your email address - FezaMarket','verification',15,'sent',NULL,'2025-10-07 21:40:33','2025-10-07 21:40:33'),
(5,'amarjit18000@gmail.com','Verify your email address - FezaMarket','verification',16,'sent',NULL,'2025-10-09 13:23:32','2025-10-09 13:23:32'),
(6,'amarjitfatehgarh05@gmail.com','Verify your email address - FezaMarket','verification',17,'sent',NULL,'2025-10-09 13:40:41','2025-10-09 13:40:41'),
(7,'k80341606@gmail.com','Verify your email address - FezaMarket','verification',18,'sent',NULL,'2025-10-11 21:46:45','2025-10-11 21:46:45'),
(8,'k80341606@gmail.com','Verify your email address - FezaMarket','verification',18,'sent',NULL,'2025-10-11 21:54:39','2025-10-11 21:54:39'),
(9,'fezamarketgroup@gmail.com','Verify your email address - FezaMarket','verification',19,'sent',NULL,'2025-10-11 23:32:09','2025-10-11 23:32:09'),
(10,'ayoka.l.us.oh.i55.5@gmail.com','Verify your email address - FezaMarket','verification',20,'sent',NULL,'2025-10-12 23:20:17','2025-10-12 23:20:17');
/*!40000 ALTER TABLE `email_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_queue`
--

DROP TABLE IF EXISTS `email_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `to_email` varchar(255) NOT NULL,
  `to_name` varchar(255) DEFAULT NULL,
  `subject` varchar(500) NOT NULL,
  `body` longtext NOT NULL,
  `template` varchar(100) DEFAULT NULL,
  `template_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`template_data`)),
  `priority` tinyint(1) NOT NULL DEFAULT 3,
  `status` enum('pending','sending','sent','failed','cancelled') NOT NULL DEFAULT 'pending',
  `attempts` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `max_attempts` tinyint(3) unsigned NOT NULL DEFAULT 3,
  `error_message` text DEFAULT NULL,
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Stores email metadata including attachments' CHECK (json_valid(`metadata`)),
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_priority` (`priority`),
  KEY `idx_scheduled_at` (`scheduled_at`),
  KEY `idx_attempts` (`attempts`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_queue`
--

LOCK TABLES `email_queue` WRITE;
/*!40000 ALTER TABLE `email_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_tokens`
--

DROP TABLE IF EXISTS `email_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `type` enum('email_verification','password_reset','email_change','two_fa_backup') NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `expires_at` timestamp NOT NULL,
  `used_at` timestamp NULL DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_token` (`token`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `idx_used_at` (`used_at`),
  CONSTRAINT `fk_email_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_tokens`
--

LOCK TABLES `email_tokens` WRITE;
/*!40000 ALTER TABLE `email_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_verifications`
--

DROP TABLE IF EXISTS `email_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_verifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `verified_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_token` (`token`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_email_verifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_verifications`
--

LOCK TABLES `email_verifications` WRITE;
/*!40000 ALTER TABLE `email_verifications` DISABLE KEYS */;
INSERT INTO `email_verifications` VALUES
(3,19,'40467c8ee15545423aac52e66385b8405d2b7bcfc18b1d19c7f9152faba5e547','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 01:32:09','2025-10-12 01:32:46'),
(4,20,'bbcd5aaabbc545563b0896538043edfcb2350cf162fbf7f7e44de674ea375440','104.23.251.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36','2025-10-13 01:20:17',NULL);
/*!40000 ALTER TABLE `email_verifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fact_campaigns`
--

DROP TABLE IF EXISTS `fact_campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `fact_campaigns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `date_key` int(11) NOT NULL,
  `impressions` int(11) NOT NULL DEFAULT 0,
  `clicks` int(11) NOT NULL DEFAULT 0,
  `conversions` int(11) NOT NULL DEFAULT 0,
  `revenue` decimal(10,2) NOT NULL DEFAULT 0.00,
  `cost` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_campaign_date` (`campaign_id`,`date_key`),
  KEY `idx_date_key` (`date_key`),
  CONSTRAINT `fk_fact_campaigns_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `campaigns` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fact_campaigns`
--

LOCK TABLES `fact_campaigns` WRITE;
/*!40000 ALTER TABLE `fact_campaigns` DISABLE KEYS */;
/*!40000 ALTER TABLE `fact_campaigns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fact_sales`
--

DROP TABLE IF EXISTS `fact_sales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `fact_sales` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `order_item_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `date_key` int(11) NOT NULL,
  `time_key` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `tax_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_amount` decimal(10,2) NOT NULL,
  `commission_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `payment_method` varchar(50) DEFAULT NULL,
  `order_status` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_date_key` (`date_key`),
  KEY `idx_time_key` (`time_key`),
  KEY `fk_fact_sales_order_item` (`order_item_id`),
  KEY `idx_fact_sales_date_vendor` (`date_key`,`vendor_id`,`total_amount`),
  CONSTRAINT `fk_fact_sales_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_fact_sales_order_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fact_sales`
--

LOCK TABLES `fact_sales` WRITE;
/*!40000 ALTER TABLE `fact_sales` DISABLE KEYS */;
/*!40000 ALTER TABLE `fact_sales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fact_users`
--

DROP TABLE IF EXISTS `fact_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `fact_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `date_key` int(11) NOT NULL,
  `registration_date` date DEFAULT NULL,
  `last_login_date` date DEFAULT NULL,
  `total_orders` int(11) NOT NULL DEFAULT 0,
  `total_spent` decimal(15,2) NOT NULL DEFAULT 0.00,
  `average_order_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `days_since_last_order` int(11) DEFAULT NULL,
  `user_segment` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_date` (`user_id`,`date_key`),
  KEY `idx_date_key` (`date_key`),
  KEY `idx_user_segment` (`user_segment`),
  CONSTRAINT `fk_fact_users_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fact_users`
--

LOCK TABLES `fact_users` WRITE;
/*!40000 ALTER TABLE `fact_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `fact_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_uploads`
--

DROP TABLE IF EXISTS `file_uploads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `file_uploads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint(20) unsigned NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `file_hash` varchar(64) DEFAULT NULL,
  `upload_type` enum('product_image','user_avatar','document','attachment','other') NOT NULL DEFAULT 'other',
  `reference_type` varchar(50) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `download_count` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_file_hash` (`file_hash`),
  KEY `idx_upload_type` (`upload_type`),
  KEY `idx_reference` (`reference_type`,`reference_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_file_uploads_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_uploads`
--

LOCK TABLES `file_uploads` WRITE;
/*!40000 ALTER TABLE `file_uploads` DISABLE KEYS */;
/*!40000 ALTER TABLE `file_uploads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gift_card_transactions`
--

DROP TABLE IF EXISTS `gift_card_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gift_card_transactions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `gift_card_id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL COMMENT 'Order where gift card was used',
  `transaction_type` enum('purchase','redemption','refund','adjustment') NOT NULL,
  `amount` decimal(10,2) NOT NULL COMMENT 'Amount added or deducted',
  `balance_before` decimal(10,2) NOT NULL,
  `balance_after` decimal(10,2) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_gift_card_id` (`gift_card_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_transaction_type` (`transaction_type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gift_card_transactions`
--

LOCK TABLES `gift_card_transactions` WRITE;
/*!40000 ALTER TABLE `gift_card_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `gift_card_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gift_cards`
--

DROP TABLE IF EXISTS `gift_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gift_cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL COMMENT 'Unique gift card code',
  `amount` decimal(10,2) NOT NULL COMMENT 'Original gift card value',
  `balance` decimal(10,2) NOT NULL COMMENT 'Current balance',
  `amount_used` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Amount already used',
  `card_type` enum('digital','physical') NOT NULL DEFAULT 'digital',
  `design` varchar(50) DEFAULT 'generic' COMMENT 'Card design theme',
  `recipient_name` varchar(255) NOT NULL,
  `recipient_email` varchar(255) NOT NULL,
  `sender_name` varchar(255) NOT NULL,
  `sender_email` varchar(255) NOT NULL,
  `personal_message` text DEFAULT NULL,
  `status` enum('pending','active','redeemed','expired','cancelled') NOT NULL DEFAULT 'pending',
  `redeemed_by` int(11) DEFAULT NULL COMMENT 'User ID who redeemed',
  `order_id` int(11) DEFAULT NULL COMMENT 'Order ID for purchase',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `activated_at` timestamp NULL DEFAULT NULL COMMENT 'When gift card was activated after payment',
  `expires_at` timestamp NULL DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `idx_code` (`code`),
  KEY `idx_recipient_email` (`recipient_email`),
  KEY `idx_sender_email` (`sender_email`),
  KEY `idx_status` (`status`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `idx_redeemed_by` (`redeemed_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gift_cards`
--

LOCK TABLES `gift_cards` WRITE;
/*!40000 ALTER TABLE `gift_cards` DISABLE KEYS */;
/*!40000 ALTER TABLE `gift_cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `giftcards`
--

DROP TABLE IF EXISTS `giftcards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `giftcards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(64) NOT NULL,
  `amount` decimal(18,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `sender_name` varchar(120) DEFAULT NULL,
  `sender_email` varchar(190) DEFAULT NULL,
  `receiver_name` varchar(120) DEFAULT NULL,
  `receiver_email` varchar(190) DEFAULT NULL,
  `message` varchar(500) DEFAULT NULL,
  `redeemed_by` int(11) DEFAULT NULL,
  `redeemed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_code` (`code`),
  KEY `idx_redeemed_by` (`redeemed_by`),
  KEY `idx_receiver_email` (`receiver_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `giftcards`
--

LOCK TABLES `giftcards` WRITE;
/*!40000 ALTER TABLE `giftcards` DISABLE KEYS */;
/*!40000 ALTER TABLE `giftcards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `government_api_access`
--

DROP TABLE IF EXISTS `government_api_access`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `government_api_access` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_name` varchar(255) NOT NULL,
  `contact_name` varchar(255) NOT NULL,
  `contact_email` varchar(255) NOT NULL,
  `contact_phone` varchar(50) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `api_key_id` int(11) NOT NULL,
  `access_level` enum('read_only','analytics_only','full') NOT NULL DEFAULT 'read_only',
  `allowed_endpoints` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`allowed_endpoints`)),
  `ip_whitelist` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`ip_whitelist`)),
  `status` enum('pending','approved','active','suspended','revoked') NOT NULL DEFAULT 'pending',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `api_key_id` (`api_key_id`),
  KEY `idx_gov_status` (`status`),
  CONSTRAINT `fk_gov_api_key` FOREIGN KEY (`api_key_id`) REFERENCES `api_keys` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_gov_api_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Special government API access with restricted permissions';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `government_api_access`
--

LOCK TABLES `government_api_access` WRITE;
/*!40000 ALTER TABLE `government_api_access` DISABLE KEYS */;
/*!40000 ALTER TABLE `government_api_access` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `homepage_banners`
--

DROP TABLE IF EXISTS `homepage_banners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `homepage_banners` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `subtitle` varchar(500) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(500) NOT NULL,
  `link_url` varchar(500) DEFAULT NULL,
  `button_text` varchar(100) DEFAULT NULL,
  `background_color` varchar(7) DEFAULT '#ffffff',
  `text_color` varchar(7) DEFAULT '#000000',
  `position` enum('hero','top','middle','bottom','sidebar') NOT NULL DEFAULT 'hero',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` enum('active','inactive','draft','scheduled') NOT NULL DEFAULT 'draft',
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `click_count` int(11) NOT NULL DEFAULT 0,
  `view_count` int(11) NOT NULL DEFAULT 0,
  `target_audience` enum('all','customers','vendors','new_users') NOT NULL DEFAULT 'all',
  `device_target` enum('all','desktop','mobile','tablet') NOT NULL DEFAULT 'all',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_position` (`position`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_start_date` (`start_date`),
  KEY `idx_end_date` (`end_date`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_status_position_sort` (`status`,`position`,`sort_order`),
  KEY `idx_status_start_end` (`status`,`start_date`,`end_date`),
  CONSTRAINT `fk_homepage_banners_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `homepage_banners`
--

LOCK TABLES `homepage_banners` WRITE;
/*!40000 ALTER TABLE `homepage_banners` DISABLE KEYS */;
INSERT INTO `homepage_banners` VALUES
(1,'The fall shoes to shop now','Shop and enjoy the discount','Shop and enjoy the discount','https://www.google.com/url?sa=i&amp;url=https%3A%2F%2Fwww.toyota.com.sg%2Fshowroom%2Fnew-models%2Fprius&amp;psig=AOvVaw2aZF5dfyd26HNpJaPoc7Hn&amp;ust=1759177830478000&amp;source=images&amp;cd=vfe&amp;opi=89978449&amp;ved=0CBUQjRxqFwoTCNC8iJ-m_I8DFQAAAAAdAAAAABAE','','shop now','#ffffff','#000000','top',0,'active',NULL,NULL,0,0,'all','all',4,'2025-09-28 20:30:52','2025-09-28 20:30:52'),
(2,'The fall shoes to shop now','Shop and enjoy the discount','Shop and enjoy the discount','https://www.google.com/url?sa=i&amp;url=https%3A%2F%2Fwww.toyota.com.sg%2Fshowroom%2Fnew-models%2Fprius&amp;psig=AOvVaw2aZF5dfyd26HNpJaPoc7Hn&amp;ust=1759177830478000&amp;source=images&amp;cd=vfe&amp;opi=89978449&amp;ved=0CBUQjRxqFwoTCNC8iJ-m_I8DFQAAAAAdAAAAABAE','','shop now','#ffffff','#000000','top',0,'active',NULL,NULL,0,0,'all','all',4,'2025-09-28 20:30:53','2025-09-28 20:30:53'),
(3,'SHOP THE FALL','SHOP THE FAILL','SHOP THE FAILL','https://www.google.com/url?sa=i&amp;url=https%3A%2F%2Fwww.amazon.com%2F2020-HP-Touchscreen-Premium-Laptop%2Fdp%2FB081SM57RY&amp;psig=AOvVaw3Ld7iMDpipLV0uLhuOmE2I&amp;ust=1759182259462000&amp;source=images&amp;cd=vfe&amp;opi=89978449&amp;ved=0CBUQjRxqFwoTCJDR3KK5_I8DFQAAAAAdAAAAABAE','https://www.google.com/url?sa=i&amp;url=https%3A%2F%2Fwww.amazon.com%2F2020-HP-Touchscreen-Premium-Laptop%2Fdp%2FB081SM57RY&amp;psig=AOvVaw3Ld7iMDpipLV0uLhuOmE2I&amp;ust=1759182259462000&amp;source=images&amp;cd=vfe&amp;opi=89978449&amp;ved=0CBUQjRxqFwoTCJDR3KK5_I8DFQAAAAAdAAAAABAE','SHOP NOW','#ffffff','#000000','top',0,'active',NULL,NULL,0,0,'all','all',4,'2025-09-28 21:58:13','2025-09-28 21:58:13'),
(4,'SHOPPING ONLINE','SHOP ONLINE TODAY','SHOP ONLINE TODAY','/uploads/banners/banner_1759176162_68dae5e209a27.jpg','https://duns1.fezalogistics.com/','SHOP NOW','#ffffff','#000000','hero',0,'active',NULL,NULL,0,0,'all','all',4,'2025-09-29 20:02:42','2025-09-29 20:02:42'),
(5,'shop Onlie','Online shopping destination','Online shopping destination','/uploads/banners/banner_1759176266_68dae64a0025c.jpg','https://duns1.fezalogistics.com/','shop now','#ffffff','#000000','top',0,'active',NULL,NULL,0,0,'all','all',4,'2025-09-29 20:04:26','2025-09-29 20:04:26');
/*!40000 ALTER TABLE `homepage_banners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `homepage_sections`
--

DROP TABLE IF EXISTS `homepage_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `homepage_sections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `section_key` varchar(100) NOT NULL,
  `section_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`section_data`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_section_key` (`section_key`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `homepage_sections`
--

LOCK TABLES `homepage_sections` WRITE;
/*!40000 ALTER TABLE `homepage_sections` DISABLE KEYS */;
INSERT INTO `homepage_sections` VALUES
(1,'layout_config','[{\"id\":\"hero\",\"type\":\"hero\",\"title\":\"Hero Banner\",\"enabled\":true},{\"id\":\"categories\",\"type\":\"categories\",\"title\":\"Featured Categories\",\"enabled\":true},{\"id\":\"deals\",\"type\":\"deals\",\"title\":\"Daily Deals\",\"enabled\":true},{\"id\":\"trending\",\"type\":\"products\",\"title\":\"Trending Products\",\"enabled\":true},{\"id\":\"brands\",\"type\":\"brands\",\"title\":\"Top Brands\",\"enabled\":true},{\"id\":\"featured\",\"type\":\"products\",\"title\":\"Featured Products\",\"enabled\":true},{\"id\":\"new-arrivals\",\"type\":\"products\",\"title\":\"New Arrivals\",\"enabled\":true},{\"id\":\"recommendations\",\"type\":\"products\",\"title\":\"Recommended for You\",\"enabled\":true}]','2025-09-27 18:28:52','2025-09-27 18:46:41');
/*!40000 ALTER TABLE `homepage_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `integrations`
--

DROP TABLE IF EXISTS `integrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `integrations` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `type` enum('payment','shipping','marketing','analytics','communication','storage','other') NOT NULL,
  `provider` varchar(100) NOT NULL,
  `status` enum('active','inactive','error','pending') NOT NULL DEFAULT 'inactive',
  `config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`config`)),
  `api_credentials` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`api_credentials`)),
  `webhook_url` varchar(500) DEFAULT NULL,
  `webhook_secret` varchar(255) DEFAULT NULL,
  `last_sync` timestamp NULL DEFAULT NULL,
  `sync_frequency` int(11) DEFAULT NULL,
  `error_count` int(11) NOT NULL DEFAULT 0,
  `last_error` text DEFAULT NULL,
  `installed_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_integration_name` (`name`),
  KEY `idx_integration_type` (`type`),
  KEY `idx_integration_status` (`status`),
  KEY `idx_integration_installer` (`installed_by`),
  CONSTRAINT `fk_integrations_installer` FOREIGN KEY (`installed_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `integrations`
--

LOCK TABLES `integrations` WRITE;
/*!40000 ALTER TABLE `integrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `integrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `warehouse_id` int(11) NOT NULL,
  `qty` int(11) NOT NULL DEFAULT 0,
  `safety_stock` int(11) NOT NULL DEFAULT 0,
  `min_stock_level` int(11) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_warehouse` (`product_id`,`warehouse_id`),
  KEY `warehouse_id` (`warehouse_id`),
  CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `inventory_ibfk_2` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_adjustments`
--

DROP TABLE IF EXISTS `inventory_adjustments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_adjustments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `warehouse_id` int(11) NOT NULL,
  `adjustment` int(11) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `adjusted_by` int(11) DEFAULT NULL,
  `adjusted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `warehouse_id` (`warehouse_id`),
  CONSTRAINT `inventory_adjustments_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `inventory_adjustments_ibfk_2` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_adjustments`
--

LOCK TABLES `inventory_adjustments` WRITE;
/*!40000 ALTER TABLE `inventory_adjustments` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_adjustments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_alerts`
--

DROP TABLE IF EXISTS `inventory_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `alert_type` enum('low_stock','out_of_stock','high_demand','slow_moving') NOT NULL,
  `threshold_value` int(11) NOT NULL,
  `current_value` int(11) NOT NULL,
  `priority` enum('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  `status` enum('active','acknowledged','resolved','dismissed') NOT NULL DEFAULT 'active',
  `acknowledged_by` int(11) DEFAULT NULL,
  `acknowledged_at` timestamp NULL DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_alert_type` (`alert_type`),
  KEY `idx_priority` (`priority`),
  KEY `idx_status` (`status`),
  KEY `idx_acknowledged_by` (`acknowledged_by`),
  CONSTRAINT `fk_inventory_alerts_acknowledger` FOREIGN KEY (`acknowledged_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_inventory_alerts_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_alerts`
--

LOCK TABLES `inventory_alerts` WRITE;
/*!40000 ALTER TABLE `inventory_alerts` DISABLE KEYS */;
/*!40000 ALTER TABLE `inventory_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `invoice_number` varchar(50) NOT NULL,
  `invoice_date` date NOT NULL,
  `due_date` date DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `tax_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `shipping_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'USD',
  `status` enum('draft','sent','paid','overdue','cancelled') NOT NULL DEFAULT 'draft',
  `pdf_path` varchar(500) DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_invoice_number` (`invoice_number`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_status` (`status`),
  KEY `idx_invoice_date` (`invoice_date`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_invoices_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_invoices_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `job_type` enum('scheduled','manual','automatic') NOT NULL DEFAULT 'scheduled',
  `command` varchar(500) NOT NULL,
  `parameters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`parameters`)),
  `schedule` varchar(100) DEFAULT NULL,
  `status` enum('pending','running','completed','failed','cancelled') NOT NULL DEFAULT 'pending',
  `priority` enum('low','normal','high','critical') NOT NULL DEFAULT 'normal',
  `progress` int(11) NOT NULL DEFAULT 0,
  `output` longtext DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `retry_count` int(11) NOT NULL DEFAULT 0,
  `max_retries` int(11) NOT NULL DEFAULT 3,
  `timeout` int(11) NOT NULL DEFAULT 3600,
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `next_run_at` timestamp NULL DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `attempts` int(11) NOT NULL DEFAULT 0 COMMENT 'Alias for retry_count, used by maintenance page',
  `max_attempts` int(11) NOT NULL DEFAULT 3 COMMENT 'Alias for max_retries, used by maintenance page',
  `queue` varchar(100) DEFAULT 'default' COMMENT 'Queue name for job processing',
  PRIMARY KEY (`id`),
  KEY `idx_job_type` (`job_type`),
  KEY `idx_status` (`status`),
  KEY `idx_priority` (`priority`),
  KEY `idx_next_run_at` (`next_run_at`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_jobs_status_priority_next_run` (`status`,`priority`,`next_run_at`),
  KEY `idx_jobs_queue` (`queue`),
  KEY `idx_jobs_attempts` (`attempts`),
  CONSTRAINT `fk_jobs_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`fezamarket`@`localhost`*/ /*!50003 TRIGGER `jobs_sync_attempts_on_insert` BEFORE INSERT ON `jobs`
FOR EACH ROW
BEGIN
  IF NEW.attempts IS NULL OR NEW.attempts = 0 THEN
    SET NEW.attempts = NEW.retry_count;
  END IF;
  IF NEW.max_attempts IS NULL OR NEW.max_attempts = 0 THEN
    SET NEW.max_attempts = NEW.max_retries;
  END IF;
  IF NEW.queue IS NULL THEN
    SET NEW.queue = 'default';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`fezamarket`@`localhost`*/ /*!50003 TRIGGER `jobs_sync_attempts_on_update` BEFORE UPDATE ON `jobs`
FOR EACH ROW
BEGIN
  -- If retry_count is updated, sync to attempts
  IF NEW.retry_count != OLD.retry_count THEN
    SET NEW.attempts = NEW.retry_count;
  END IF;
  -- If attempts is updated, sync to retry_count
  IF NEW.attempts != OLD.attempts THEN
    SET NEW.retry_count = NEW.attempts;
  END IF;
  -- If max_retries is updated, sync to max_attempts
  IF NEW.max_retries != OLD.max_retries THEN
    SET NEW.max_attempts = NEW.max_retries;
  END IF;
  -- If max_attempts is updated, sync to max_retries
  IF NEW.max_attempts != OLD.max_attempts THEN
    SET NEW.max_retries = NEW.max_attempts;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `kpi_daily`
--

DROP TABLE IF EXISTS `kpi_daily`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `kpi_daily` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `metric_date` date NOT NULL,
  `total_sales` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_orders` int(11) NOT NULL DEFAULT 0,
  `gmv` decimal(15,2) NOT NULL DEFAULT 0.00,
  `commission_revenue` decimal(15,2) NOT NULL DEFAULT 0.00,
  `active_users` int(11) NOT NULL DEFAULT 0,
  `active_buyers` int(11) NOT NULL DEFAULT 0,
  `active_sellers` int(11) NOT NULL DEFAULT 0,
  `guest_visitors` int(11) NOT NULL DEFAULT 0,
  `conversion_rate` decimal(5,4) NOT NULL DEFAULT 0.0000,
  `average_order_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_metric_date` (`metric_date`),
  KEY `idx_total_sales` (`total_sales`),
  KEY `idx_total_orders` (`total_orders`),
  KEY `idx_kpi_daily_date_sales` (`metric_date`,`total_sales`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kpi_daily`
--

LOCK TABLES `kpi_daily` WRITE;
/*!40000 ALTER TABLE `kpi_daily` DISABLE KEYS */;
/*!40000 ALTER TABLE `kpi_daily` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kyc_decisions`
--

DROP TABLE IF EXISTS `kyc_decisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `kyc_decisions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kyc_request_id` int(11) NOT NULL,
  `reviewer_id` int(11) NOT NULL,
  `decision` enum('approve','reject','request_more_info','escalate') NOT NULL,
  `reason` text NOT NULL,
  `risk_assessment` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`risk_assessment`)),
  `follow_up_required` tinyint(1) NOT NULL DEFAULT 0,
  `follow_up_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_kyc_request_id` (`kyc_request_id`),
  KEY `idx_reviewer_id` (`reviewer_id`),
  KEY `idx_decision` (`decision`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_kyc_decisions_request` FOREIGN KEY (`kyc_request_id`) REFERENCES `kyc_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_kyc_decisions_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kyc_decisions`
--

LOCK TABLES `kyc_decisions` WRITE;
/*!40000 ALTER TABLE `kyc_decisions` DISABLE KEYS */;
/*!40000 ALTER TABLE `kyc_decisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kyc_documents`
--

DROP TABLE IF EXISTS `kyc_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `kyc_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kyc_request_id` int(11) NOT NULL,
  `document_type` enum('passport','drivers_license','national_id','utility_bill','bank_statement','business_registration','other') NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `file_size` bigint(20) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `ocr_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`ocr_data`)),
  `verification_status` enum('pending','processing','verified','failed') NOT NULL DEFAULT 'pending',
  `verification_notes` text DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_kyc_request_id` (`kyc_request_id`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_verification_status` (`verification_status`),
  CONSTRAINT `fk_kyc_documents_request` FOREIGN KEY (`kyc_request_id`) REFERENCES `kyc_requests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kyc_documents`
--

LOCK TABLES `kyc_documents` WRITE;
/*!40000 ALTER TABLE `kyc_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `kyc_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kyc_flags`
--

DROP TABLE IF EXISTS `kyc_flags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `kyc_flags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kyc_request_id` int(11) NOT NULL,
  `flag_type` enum('duplicate_identity','suspicious_activity','high_risk_country','document_mismatch','other') NOT NULL,
  `severity` enum('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  `description` text NOT NULL,
  `flag_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`flag_data`)),
  `is_resolved` tinyint(1) NOT NULL DEFAULT 0,
  `resolved_by` int(11) DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_kyc_request_id` (`kyc_request_id`),
  KEY `idx_flag_type` (`flag_type`),
  KEY `idx_severity` (`severity`),
  KEY `idx_is_resolved` (`is_resolved`),
  KEY `fk_kyc_flags_resolver` (`resolved_by`),
  CONSTRAINT `fk_kyc_flags_request` FOREIGN KEY (`kyc_request_id`) REFERENCES `kyc_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_kyc_flags_resolver` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kyc_flags`
--

LOCK TABLES `kyc_flags` WRITE;
/*!40000 ALTER TABLE `kyc_flags` DISABLE KEYS */;
/*!40000 ALTER TABLE `kyc_flags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kyc_requests`
--

DROP TABLE IF EXISTS `kyc_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `kyc_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `request_type` enum('individual','business','enhanced') NOT NULL DEFAULT 'individual',
  `status` enum('pending','in_review','approved','rejected','requires_more_info') NOT NULL DEFAULT 'pending',
  `priority` enum('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `risk_score` int(11) DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `personal_info` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`personal_info`)),
  `business_info` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`business_info`)),
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_priority` (`priority`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `idx_submitted_at` (`submitted_at`),
  KEY `idx_kyc_requests_status_priority` (`status`,`priority`,`submitted_at`),
  CONSTRAINT `fk_kyc_requests_assignee` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_kyc_requests_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kyc_requests`
--

LOCK TABLES `kyc_requests` WRITE;
/*!40000 ALTER TABLE `kyc_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `kyc_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kyc_verifications`
--

DROP TABLE IF EXISTS `kyc_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `kyc_verifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `verification_type` enum('identity','address','business','financial') NOT NULL,
  `status` enum('pending','approved','rejected','expired') NOT NULL DEFAULT 'pending',
  `verification_level` enum('basic','intermediate','advanced') NOT NULL DEFAULT 'basic',
  `documents_provided` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`documents_provided`)),
  `verification_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`verification_data`)),
  `reviewer_id` int(11) DEFAULT NULL,
  `reviewer_notes` text DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_kyc_user` (`user_id`),
  KEY `idx_kyc_status` (`status`),
  KEY `idx_kyc_type` (`verification_type`),
  KEY `idx_kyc_reviewer` (`reviewer_id`),
  CONSTRAINT `fk_kyc_verifications_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_kyc_verifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kyc_verifications`
--

LOCK TABLES `kyc_verifications` WRITE;
/*!40000 ALTER TABLE `kyc_verifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `kyc_verifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_chat_messages`
--

DROP TABLE IF EXISTS `live_chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_chat_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `message` text NOT NULL,
  `message_type` enum('chat','system','product','reaction') NOT NULL DEFAULT 'chat',
  `is_highlighted` tinyint(1) NOT NULL DEFAULT 0,
  `is_moderated` tinyint(1) NOT NULL DEFAULT 0,
  `moderated_by` int(11) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_stream_id` (`stream_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_message_type` (`message_type`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_moderated` (`is_moderated`),
  KEY `fk_live_chat_messages_moderator` (`moderated_by`),
  CONSTRAINT `fk_live_chat_messages_moderator` FOREIGN KEY (`moderated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_live_chat_messages_stream` FOREIGN KEY (`stream_id`) REFERENCES `live_streams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_live_chat_messages_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_chat_messages`
--

LOCK TABLES `live_chat_messages` WRITE;
/*!40000 ALTER TABLE `live_chat_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `live_chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_stream_analytics`
--

DROP TABLE IF EXISTS `live_stream_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_stream_analytics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL,
  `metric_type` enum('viewer_join','viewer_leave','chat_message','product_click','purchase','share','like') NOT NULL,
  `metric_value` decimal(10,2) NOT NULL DEFAULT 1.00,
  `user_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `recorded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_stream_id` (`stream_id`),
  KEY `idx_metric_type` (`metric_type`),
  KEY `idx_recorded_at` (`recorded_at`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_stream_analytics_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_stream_analytics_stream` FOREIGN KEY (`stream_id`) REFERENCES `live_streams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_stream_analytics_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_stream_analytics`
--

LOCK TABLES `live_stream_analytics` WRITE;
/*!40000 ALTER TABLE `live_stream_analytics` DISABLE KEYS */;
/*!40000 ALTER TABLE `live_stream_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_stream_chat`
--

DROP TABLE IF EXISTS `live_stream_chat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_stream_chat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `username` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `message_type` enum('text','emoji','system','product') NOT NULL DEFAULT 'text',
  `product_id` int(11) DEFAULT NULL,
  `is_moderator` tinyint(1) NOT NULL DEFAULT 0,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_by` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_stream_id` (`stream_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_stream_chat_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_stream_chat_stream` FOREIGN KEY (`stream_id`) REFERENCES `live_streams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_stream_chat_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_stream_chat`
--

LOCK TABLES `live_stream_chat` WRITE;
/*!40000 ALTER TABLE `live_stream_chat` DISABLE KEYS */;
/*!40000 ALTER TABLE `live_stream_chat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_stream_moderators`
--

DROP TABLE IF EXISTS `live_stream_moderators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_stream_moderators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '["delete_messages", "timeout_users"]' CHECK (json_valid(`permissions`)),
  `assigned_by` int(11) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_stream_moderator` (`stream_id`,`user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_assigned_by` (`assigned_by`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_stream_moderators_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_stream_moderators_stream` FOREIGN KEY (`stream_id`) REFERENCES `live_streams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_stream_moderators_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_stream_moderators`
--

LOCK TABLES `live_stream_moderators` WRITE;
/*!40000 ALTER TABLE `live_stream_moderators` DISABLE KEYS */;
/*!40000 ALTER TABLE `live_stream_moderators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_stream_notifications`
--

DROP TABLE IF EXISTS `live_stream_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_stream_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `notification_type` enum('stream_starting','stream_live','stream_ended','new_product','special_offer') NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text DEFAULT NULL,
  `is_sent` tinyint(1) NOT NULL DEFAULT 0,
  `sent_at` datetime DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `read_at` datetime DEFAULT NULL,
  `delivery_method` enum('push','email','sms','in_app') NOT NULL DEFAULT 'in_app',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_stream_id` (`stream_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_notification_type` (`notification_type`),
  KEY `idx_is_sent` (`is_sent`),
  KEY `idx_is_read` (`is_read`),
  CONSTRAINT `fk_stream_notifications_stream` FOREIGN KEY (`stream_id`) REFERENCES `live_streams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_stream_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_stream_notifications`
--

LOCK TABLES `live_stream_notifications` WRITE;
/*!40000 ALTER TABLE `live_stream_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `live_stream_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_stream_products`
--

DROP TABLE IF EXISTS `live_stream_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_stream_products` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stream_id` bigint(20) unsigned NOT NULL,
  `product_id` int(10) unsigned NOT NULL,
  `special_price` decimal(10,2) DEFAULT NULL,
  `discount_percentage` decimal(5,2) DEFAULT NULL,
  `display_order` int(11) NOT NULL DEFAULT 0,
  `is_featured` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_stream_product` (`stream_id`,`product_id`),
  KEY `idx_stream_id` (`stream_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_stream_products`
--

LOCK TABLES `live_stream_products` WRITE;
/*!40000 ALTER TABLE `live_stream_products` DISABLE KEYS */;
/*!40000 ALTER TABLE `live_stream_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_stream_recordings`
--

DROP TABLE IF EXISTS `live_stream_recordings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_stream_recordings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint(20) DEFAULT NULL,
  `duration_seconds` int(11) DEFAULT NULL,
  `quality` enum('240p','360p','480p','720p','1080p') NOT NULL DEFAULT '720p',
  `format` enum('mp4','webm','hls') NOT NULL DEFAULT 'mp4',
  `status` enum('recording','processing','completed','failed') NOT NULL DEFAULT 'recording',
  `thumbnail_path` varchar(500) DEFAULT NULL,
  `download_count` int(11) NOT NULL DEFAULT 0,
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `processing_started_at` datetime DEFAULT NULL,
  `processing_completed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_stream_id` (`stream_id`),
  KEY `idx_status` (`status`),
  KEY `idx_is_public` (`is_public`),
  CONSTRAINT `fk_stream_recordings_stream` FOREIGN KEY (`stream_id`) REFERENCES `live_streams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_stream_recordings`
--

LOCK TABLES `live_stream_recordings` WRITE;
/*!40000 ALTER TABLE `live_stream_recordings` DISABLE KEYS */;
/*!40000 ALTER TABLE `live_stream_recordings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_stream_settings`
--

DROP TABLE IF EXISTS `live_stream_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_stream_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `setting_type` enum('string','integer','boolean','json') NOT NULL DEFAULT 'string',
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_vendor_setting` (`vendor_id`,`setting_key`),
  CONSTRAINT `fk_stream_settings_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_stream_settings`
--

LOCK TABLES `live_stream_settings` WRITE;
/*!40000 ALTER TABLE `live_stream_settings` DISABLE KEYS */;
INSERT INTO `live_stream_settings` VALUES
(2,3,'max_concurrent_streams','1','integer','Maximum number of concurrent live streams','2025-10-01 21:16:01','2025-10-01 21:16:01'),
(5,3,'auto_record_streams','true','boolean','Automatically record all live streams','2025-10-01 21:16:01','2025-10-01 21:16:01'),
(8,3,'chat_moderation_enabled','true','boolean','Enable chat moderation features','2025-10-01 21:16:01','2025-10-01 21:16:01'),
(11,3,'notification_settings','{\"email\": true, \"push\": true, \"sms\": false}','json','Notification preferences for streams','2025-10-01 21:16:01','2025-10-01 21:16:01');
/*!40000 ALTER TABLE `live_stream_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_stream_subscriptions`
--

DROP TABLE IF EXISTS `live_stream_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_stream_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `notification_types` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '["stream_starting", "stream_live"]' CHECK (json_valid(`notification_types`)),
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_vendor` (`user_id`,`vendor_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_stream_subscriptions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_stream_subscriptions_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_stream_subscriptions`
--

LOCK TABLES `live_stream_subscriptions` WRITE;
/*!40000 ALTER TABLE `live_stream_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `live_stream_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_stream_viewers`
--

DROP TABLE IF EXISTS `live_stream_viewers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_stream_viewers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `session_id` varchar(128) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `joined_at` datetime NOT NULL DEFAULT current_timestamp(),
  `left_at` datetime DEFAULT NULL,
  `duration_seconds` int(11) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `device_type` enum('desktop','mobile','tablet','tv') DEFAULT NULL,
  `location_country` varchar(2) DEFAULT NULL,
  `location_city` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_stream_id` (`stream_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_joined_at` (`joined_at`),
  CONSTRAINT `fk_stream_viewers_stream` FOREIGN KEY (`stream_id`) REFERENCES `live_streams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_stream_viewers_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_stream_viewers`
--

LOCK TABLES `live_stream_viewers` WRITE;
/*!40000 ALTER TABLE `live_stream_viewers` DISABLE KEYS */;
/*!40000 ALTER TABLE `live_stream_viewers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_streams`
--

DROP TABLE IF EXISTS `live_streams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_streams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `stream_key` varchar(128) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `thumbnail_url` varchar(255) DEFAULT NULL,
  `stream_url` varchar(500) DEFAULT NULL,
  `video_path` varchar(500) DEFAULT NULL COMMENT 'Path to saved stream video/replay',
  `chat_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `recording_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `recording_url` varchar(500) DEFAULT NULL,
  `featured` tinyint(1) NOT NULL DEFAULT 0,
  `category_id` int(11) DEFAULT NULL,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`settings`)),
  `status` enum('scheduled','live','ended','archived','cancelled') NOT NULL DEFAULT 'scheduled',
  `viewer_count` int(11) NOT NULL DEFAULT 0,
  `max_viewers` int(11) NOT NULL DEFAULT 0,
  `like_count` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'Total likes for the stream',
  `dislike_count` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'Total dislikes for the stream',
  `comment_count` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'Total comments for the stream',
  `revenue` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_revenue` decimal(10,2) NOT NULL DEFAULT 0.00,
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `ended_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `stream_key` (`stream_key`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_scheduled_at` (`scheduled_at`),
  KEY `idx_started_at` (`started_at`),
  KEY `idx_viewer_count` (`viewer_count`),
  KEY `idx_live_streams_status_scheduled` (`status`,`scheduled_at`),
  KEY `idx_status_ended` (`status`,`ended_at`),
  CONSTRAINT `fk_live_streams_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_streams`
--

LOCK TABLES `live_streams` WRITE;
/*!40000 ALTER TABLE `live_streams` DISABLE KEYS */;
/*!40000 ALTER TABLE `live_streams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_attempts`
--

DROP TABLE IF EXISTS `login_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_attempts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `success` tinyint(1) NOT NULL DEFAULT 0,
  `user_agent` text DEFAULT NULL,
  `attempted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_identifier` (`identifier`),
  KEY `idx_ip_address` (`ip_address`),
  KEY `idx_success` (`success`),
  KEY `idx_attempted_at` (`attempted_at`)
) ENGINE=InnoDB AUTO_INCREMENT=224 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_attempts`
--

LOCK TABLES `login_attempts` WRITE;
/*!40000 ALTER TABLE `login_attempts` DISABLE KEYS */;
INSERT INTO `login_attempts` VALUES
(3,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-11 15:11:33'),
(4,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-11 15:27:53'),
(5,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-11 15:33:28'),
(6,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-11 15:36:42'),
(7,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-09-11 15:39:47'),
(8,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-11 15:41:07'),
(9,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-11 15:41:10'),
(10,'ellyj164@gmail.com','172.68.42.185',1,NULL,'2025-09-11 17:46:44'),
(11,'ellyj164@gmail.com','197.234.242.181',1,NULL,'2025-09-11 17:50:31'),
(14,'ellyj164@gmail.com','197.234.242.180',1,NULL,'2025-09-14 20:45:42'),
(15,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-15 15:09:28'),
(16,'ellyj164@gmail.com','197.234.242.180',1,NULL,'2025-09-15 17:22:52'),
(17,'ellyj164@gmail.com','172.68.42.184',1,NULL,'2025-09-15 17:29:35'),
(18,'ellyj164@gmail.com','172.68.42.185',1,NULL,'2025-09-15 18:00:11'),
(19,'ellyj164@gmail.com','197.234.242.180',1,NULL,'2025-09-15 18:08:43'),
(20,'ellyj164@gmail.com','197.234.242.180',1,NULL,'2025-09-15 19:11:16'),
(21,'ellyj164@gmail.com','197.234.242.181',1,NULL,'2025-09-15 19:14:55'),
(22,'ellyj164@gmail.com','197.234.242.181',1,NULL,'2025-09-15 20:19:58'),
(23,'ellyj164@gmail.com','172.68.42.184',1,NULL,'2025-09-15 21:21:19'),
(24,'ellyj164@gmail.com','172.68.42.185',1,NULL,'2025-09-15 22:58:23'),
(25,'ellyj164@gmail.com','172.69.254.163',1,NULL,'2025-09-16 05:50:29'),
(26,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-09-16 07:35:24'),
(27,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-09-16 08:10:19'),
(28,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-16 11:25:14'),
(29,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-16 16:10:15'),
(30,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-16 16:51:50'),
(31,'ellyj164@gmail.com','172.68.42.185',1,NULL,'2025-09-20 22:20:08'),
(32,'ellyj164@gmail.com','172.68.42.185',1,NULL,'2025-09-20 22:21:19'),
(34,'niyogushimwaj967@gmail.com','197.234.242.180',1,NULL,'2025-09-20 22:27:04'),
(35,'ellyj164@gmail.com','172.68.42.185',1,NULL,'2025-09-20 22:31:22'),
(37,'ellyj164@gmail.com','197.234.242.154',1,NULL,'2025-09-21 06:57:04'),
(38,'ellyj164@gmail.com','172.68.42.184',1,NULL,'2025-09-21 09:07:53'),
(39,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-09-27 09:29:06'),
(40,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-09-27 12:29:31'),
(41,'ellyj164@gmail.com','172.68.42.184',1,NULL,'2025-09-27 14:20:48'),
(42,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-09-27 16:43:44'),
(44,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-09-27 17:26:47'),
(45,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-27 20:44:06'),
(46,'ellyj164@gmail.com','197.234.242.181',1,NULL,'2025-09-28 19:59:25'),
(47,'ellyj164@gmail.com','197.234.242.181',1,NULL,'2025-09-28 19:59:42'),
(48,'ellyj164@gmail.com','197.234.242.180',1,NULL,'2025-09-28 20:01:47'),
(49,'ellyj164@gmail.com','172.68.42.184',1,NULL,'2025-09-28 21:41:55'),
(50,'niyogushimwaj967@gmail.com','197.234.242.181',1,NULL,'2025-09-28 22:06:43'),
(51,'ellyj164@gmail.com','172.68.42.184',1,NULL,'2025-09-29 09:17:37'),
(52,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-29 10:59:37'),
(53,'ellyj164@gmail.com','172.68.103.104',1,NULL,'2025-09-29 12:03:37'),
(54,'ellyj164@gmail.com','197.234.242.181',1,NULL,'2025-09-29 20:00:41'),
(56,'ellyj164@gmail.com','197.234.242.181',1,NULL,'2025-09-29 20:03:41'),
(57,'ellyj164@gmail.com','172.68.42.185',1,NULL,'2025-09-29 22:23:24'),
(58,'ellyj164@gmail.com','197.234.242.180',1,NULL,'2025-09-29 22:59:28'),
(59,'ellyj164@gmail.com','197.234.242.107',1,NULL,'2025-09-30 06:17:58'),
(61,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-09-30 07:43:26'),
(62,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-09-30 08:48:23'),
(63,'ellyj164@gmail.com','172.68.42.185',1,NULL,'2025-10-01 20:40:32'),
(64,'ellyj164@gmail.com','197.234.242.106',1,NULL,'2025-10-01 21:41:18'),
(66,'ellyj164@gmail.com','197.234.242.162',1,NULL,'2025-10-01 23:03:58'),
(67,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-10-03 13:40:58'),
(68,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-10-03 14:37:32'),
(70,'ellyj164@gmail.com','197.234.243.90',1,NULL,'2025-10-03 19:15:40'),
(71,'ellyj164@gmail.com','197.234.243.90',1,NULL,'2025-10-03 20:41:13'),
(73,'ellyj164@gmail.com','197.234.243.90',1,NULL,'2025-10-03 21:46:26'),
(74,'ellyj164@gmail.com','172.68.42.185',1,NULL,'2025-10-04 04:46:31'),
(75,'ellyj164@gmail.com','197.234.243.90',1,NULL,'2025-10-04 05:39:23'),
(76,'ellyj164@gmail.com','172.68.42.184',1,NULL,'2025-10-04 07:03:20'),
(77,'ellyj164@gmail.com','197.234.243.90',1,NULL,'2025-10-04 07:19:38'),
(78,'ellyj164@gmail.com','172.68.42.184',1,NULL,'2025-10-04 09:14:01'),
(79,'ellyj164@gmail.com','197.234.243.89',1,NULL,'2025-10-04 10:18:18'),
(80,'niyogushimwaj967@gmail.com','172.69.254.165',1,NULL,'2025-10-04 10:46:56'),
(82,'ellyj164@gmail.com','197.234.243.90',1,NULL,'2025-10-04 13:04:11'),
(83,'niyogushimwaj967@gmail.com','197.234.243.90',1,NULL,'2025-10-04 14:05:17'),
(84,'ellyj164@gmail.com','197.234.243.89',1,NULL,'2025-10-04 16:14:43'),
(85,'ellyj164@gmail.com','172.68.42.184',1,NULL,'2025-10-04 22:54:31'),
(87,'ellyj164@gmail.com','197.234.243.90',1,NULL,'2025-10-05 10:39:55'),
(88,'ellyj164@gmail.com','172.68.42.185',1,NULL,'2025-10-05 12:45:41'),
(89,'ellyj164@gmail.com','197.234.243.89',1,NULL,'2025-10-05 12:48:44'),
(90,'ellyj164@gmail.com','172.68.42.184',1,NULL,'2025-10-05 14:29:25'),
(91,'ellyj164@gmail.com','172.68.42.10',1,NULL,'2025-10-05 22:46:08'),
(92,'niyogushimwaj967@gmail.com','197.234.243.88',1,NULL,'2025-10-05 23:00:13'),
(93,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-10-06 08:44:07'),
(94,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-10-06 09:55:14'),
(95,'niyogushimwaj967@gmail.com','172.69.254.164',1,NULL,'2025-10-06 10:52:09'),
(96,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-10-06 10:58:02'),
(98,'ellyj164@gmail.com','172.68.42.185',1,NULL,'2025-10-06 11:15:05'),
(99,'ellyj164@gmail.com','172.69.254.165',1,NULL,'2025-10-06 13:22:44'),
(100,'ellyj164@gmail.com','172.69.254.164',1,NULL,'2025-10-06 14:00:25'),
(101,'niyogushimwaj967@gmail.com','172.69.254.165',1,NULL,'2025-10-06 14:01:49'),
(102,'ellyj164@gmail.com','172.68.42.160',1,NULL,'2025-10-06 17:57:17'),
(103,'niyogushimwaj967@gmail.com','172.68.42.160',1,NULL,'2025-10-06 18:01:21'),
(104,'ellyj164@gmail.com','172.68.42.184',1,NULL,'2025-10-06 20:55:51'),
(105,'uninejacky@gmail.com','172.68.42.109',0,NULL,'2025-10-06 22:32:12'),
(106,'ellyj164@gmail.com','197.234.242.126',1,NULL,'2025-10-07 06:48:28'),
(107,'ellyj164@gmail.com','172.68.102.250',1,NULL,'2025-10-07 08:15:54'),
(108,'ellyj164@gmail.com','197.234.242.126',1,NULL,'2025-10-07 14:46:50'),
(111,'ellyj164@gmail.com','172.69.254.163',1,NULL,'2025-10-07 16:59:45'),
(113,'fezamarketgroup@gmail.com','172.69.254.163',1,NULL,'2025-10-07 17:07:32'),
(114,'ellyj164@gmail.com','172.69.254.162',1,NULL,'2025-10-07 17:33:01'),
(116,'ellyj164@gmail.com','172.69.254.162',1,NULL,'2025-10-07 18:51:55'),
(117,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-07 19:53:10'),
(118,'ellyj164@gmail.com','172.68.42.70',1,NULL,'2025-10-07 20:40:43'),
(119,'ellyj164@gmail.com','172.68.42.49',1,NULL,'2025-10-07 23:52:13'),
(120,'ellyj164@gmail.com','172.68.42.131',1,NULL,'2025-10-08 07:06:55'),
(121,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-08 08:18:03'),
(122,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-08 21:00:43'),
(123,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-08 21:39:22'),
(127,'ellyj164@gmail.com','172.68.42.129',1,NULL,'2025-10-08 22:42:28'),
(128,'ellyj164@gmail.com','197.234.242.96',1,NULL,'2025-10-08 23:43:21'),
(129,'ellyj164@gmail.com','172.68.42.47',1,NULL,'2025-10-09 06:37:27'),
(130,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-09 07:20:31'),
(132,'ellyj164@gmail.com','172.68.102.251',1,NULL,'2025-10-09 08:15:52'),
(133,'ellyj164@gmail.com','172.69.254.163',1,NULL,'2025-10-09 09:11:32'),
(135,'ellyj164@gmail.com','172.68.47.134',1,NULL,'2025-10-09 11:26:00'),
(136,'amarjit18000@gmail.com','172.68.234.150',0,NULL,'2025-10-09 13:18:24'),
(137,'amarjit18000@gmail.com','172.68.234.150',0,NULL,'2025-10-09 13:18:37'),
(138,'amarjit18000@gmail.com','172.68.234.150',0,NULL,'2025-10-09 13:21:51'),
(139,'amarjit18000@gmail.com','172.70.108.85',0,NULL,'2025-10-09 13:25:15'),
(140,'amarjit18000@gmail.com','162.158.22.160',0,NULL,'2025-10-09 13:26:55'),
(141,'amarjitfatehgarh05@gmail.com','162.158.22.160',1,NULL,'2025-10-09 13:42:04'),
(142,'amarjitfatehgarh05@gmail.com','162.158.22.160',1,NULL,'2025-10-09 13:53:48'),
(143,'ellyj164@gmail.com','172.68.47.140',1,NULL,'2025-10-09 14:28:28'),
(144,'ellyj164@gmail.com','172.68.47.140',1,NULL,'2025-10-09 16:12:36'),
(145,'ellyj164@gmail.com','172.68.102.13',1,NULL,'2025-10-09 16:33:59'),
(146,'ellyj164@gmail.com','172.68.134.59',1,NULL,'2025-10-09 18:05:18'),
(147,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-09 19:26:00'),
(148,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-09 21:24:26'),
(149,'ellyj164@gmail.com','197.234.242.97',1,NULL,'2025-10-09 22:37:22'),
(151,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-10 06:15:19'),
(152,'ellyj164@gmail.com','172.68.42.70',1,NULL,'2025-10-10 06:24:55'),
(153,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-10 06:53:59'),
(154,'amarjitfatehgarh05@gmail.com','172.68.234.127',1,NULL,'2025-10-10 07:10:41'),
(155,'st.i.l.tbtsb@web.de','104.23.166.59',0,NULL,'2025-10-10 08:13:25'),
(156,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-10 09:15:06'),
(157,'ellyj164@gmail.com','172.68.102.30',1,NULL,'2025-10-10 13:59:43'),
(158,'ellyj164@gmail.com','172.69.254.162',1,NULL,'2025-10-10 18:04:22'),
(159,'ellyj164@gmail.com','172.69.254.163',1,NULL,'2025-10-11 13:16:53'),
(160,'ellyj164@gmail.com','197.234.242.126',1,NULL,'2025-10-11 14:49:12'),
(161,'Cog@prohabits.es','172.64.198.70',0,NULL,'2025-10-11 14:52:02'),
(162,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-11 15:13:49'),
(163,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-11 15:16:00'),
(164,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-11 15:56:33'),
(165,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-11 17:28:46'),
(166,'ellyj164@gmail.com','197.234.242.126',1,NULL,'2025-10-11 17:45:58'),
(167,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-11 18:50:16'),
(168,'ellyj164@gmail.com','172.68.42.47',1,NULL,'2025-10-11 20:06:16'),
(170,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-11 21:10:49'),
(171,'ellyj164@gmail.com','172.68.42.70',1,NULL,'2025-10-11 21:44:39'),
(172,'k80341606@gmail.com','197.234.242.126',0,NULL,'2025-10-11 21:47:36'),
(173,'ellyj164@gmail.com','172.68.42.70',1,NULL,'2025-10-11 21:58:20'),
(174,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-11 23:02:33'),
(175,'niyogushimwaj967@gmail.com','197.234.242.126',0,NULL,'2025-10-11 23:29:04'),
(176,'fezamarketgroup@gmail.com','172.68.42.71',1,NULL,'2025-10-11 23:33:00'),
(177,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-12 00:06:03'),
(179,'ellyj164@gmail.com','172.68.42.70',1,NULL,'2025-10-12 01:07:18'),
(180,'fezamarketgroup@gmail.com','197.234.242.127',1,NULL,'2025-10-12 01:19:53'),
(181,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-12 01:32:25'),
(182,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-12 09:47:48'),
(183,'ellyj164@gmail.com','172.68.42.47',1,NULL,'2025-10-12 12:01:00'),
(184,'fezamarketgroup@gmail.com','172.68.42.71',1,NULL,'2025-10-12 13:48:26'),
(185,'fezamarketgroup@gmail.com','172.68.42.70',1,NULL,'2025-10-12 14:32:22'),
(186,'fezamarketgroup@gmail.com','197.234.242.126',1,NULL,'2025-10-12 16:00:31'),
(187,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-12 16:21:11'),
(188,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-12 17:26:39'),
(189,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-12 18:29:20'),
(190,'ellyj164@gmail.com','197.234.242.126',1,NULL,'2025-10-12 21:01:34'),
(191,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-12 22:31:16'),
(192,'ellyj164@gmail.com','197.234.242.167',1,NULL,'2025-10-12 23:11:56'),
(193,'ayoka.l.us.oh.i55.5@gmail.com','172.69.34.231',0,NULL,'2025-10-12 23:20:19'),
(194,'ellyj164@gmail.com','172.68.42.70',1,NULL,'2025-10-13 00:18:32'),
(195,'fezamarketgroup@gmail.com','172.68.42.71',1,NULL,'2025-10-13 00:20:21'),
(196,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-13 01:21:48'),
(197,'fezamarketgroup@gmail.com','197.234.242.126',1,NULL,'2025-10-13 01:22:23'),
(198,'fezamarketgroup@gmail.com','172.68.42.71',1,NULL,'2025-10-13 06:33:38'),
(199,'fezamarketgroup@gmail.com','197.234.242.127',1,NULL,'2025-10-13 07:46:38'),
(201,'ellyj164@gmail.com','172.69.254.162',1,NULL,'2025-10-13 09:04:23'),
(202,'user2025@123bv1.it.com','172.71.135.86',0,NULL,'2025-10-13 23:35:31'),
(203,'ellyj164@gmail.com','172.68.103.106',1,NULL,'2025-10-14 10:01:19'),
(204,'ellyj164@gmail.com','172.64.236.185',1,NULL,'2025-10-14 11:02:02'),
(205,'ellyj164@gmail.com','172.68.47.141',1,NULL,'2025-10-14 13:08:14'),
(206,'ellyj164@gmail.com','172.69.254.163',1,NULL,'2025-10-14 14:31:10'),
(207,'ellyj164@gmail.com','172.68.102.76',1,NULL,'2025-10-14 18:18:13'),
(208,'ellyj164@gmail.com','172.68.42.70',1,NULL,'2025-10-14 18:23:24'),
(209,'ellyj164@gmail.com','197.234.242.126',1,NULL,'2025-10-14 20:16:21'),
(210,'ellyj164@gmail.com','197.234.242.126',1,NULL,'2025-10-14 22:19:45'),
(211,'ellyj164@gmail.com','172.69.254.160',1,NULL,'2025-10-15 09:02:17'),
(212,'ellyj164@gmail.com','172.69.254.163',1,NULL,'2025-10-15 10:40:10'),
(213,'ellyj164@gmail.com','197.234.242.126',1,NULL,'2025-10-15 11:20:36'),
(214,'ellyj164@gmail.com','172.69.254.163',1,NULL,'2025-10-15 12:46:01'),
(215,'ellyj164@gmail.com','172.69.254.162',1,NULL,'2025-10-15 15:00:59'),
(216,'ellyj164@gmail.com','172.68.42.70',1,NULL,'2025-10-15 18:29:30'),
(217,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-15 19:34:19'),
(219,'ellyj164@gmail.com','197.234.242.127',1,NULL,'2025-10-16 07:35:00'),
(220,'ellyj164@gmail.com','172.69.254.162',1,NULL,'2025-10-16 09:48:15'),
(221,'ellyj164@gmail.com','172.69.254.162',1,NULL,'2025-10-16 10:56:08'),
(222,'ellyj164@gmail.com','197.234.242.126',1,NULL,'2025-10-16 22:17:38'),
(223,'ellyj164@gmail.com','172.68.42.71',1,NULL,'2025-10-16 22:55:20');
/*!40000 ALTER TABLE `login_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_history`
--

DROP TABLE IF EXISTS `login_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text DEFAULT NULL,
  `login_time` datetime DEFAULT current_timestamp(),
  `location` varchar(255) DEFAULT NULL,
  `device_type` varchar(50) DEFAULT NULL,
  `browser` varchar(50) DEFAULT NULL,
  `os` varchar(50) DEFAULT NULL,
  `status` enum('success','failed','blocked') DEFAULT 'success',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_login_time` (`login_time`),
  KEY `idx_status` (`status`),
  CONSTRAINT `login_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_history`
--

LOCK TABLES `login_history` WRITE;
/*!40000 ALTER TABLE `login_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `login_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loyalty_accounts`
--

DROP TABLE IF EXISTS `loyalty_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `loyalty_accounts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `program_name` varchar(100) NOT NULL DEFAULT 'main',
  `current_points` int(11) NOT NULL DEFAULT 0,
  `lifetime_points` int(11) NOT NULL DEFAULT 0,
  `tier` enum('bronze','silver','gold','platinum','diamond') NOT NULL DEFAULT 'bronze',
  `status` enum('active','inactive','suspended') NOT NULL DEFAULT 'active',
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_activity` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_program` (`user_id`,`program_name`),
  KEY `idx_loyalty_tier` (`tier`),
  KEY `idx_loyalty_status` (`status`),
  CONSTRAINT `fk_loyalty_accounts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loyalty_accounts`
--

LOCK TABLES `loyalty_accounts` WRITE;
/*!40000 ALTER TABLE `loyalty_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `loyalty_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loyalty_ledger`
--

DROP TABLE IF EXISTS `loyalty_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `loyalty_ledger` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `transaction_type` enum('earned','redeemed','expired','adjusted','bonus','penalty') NOT NULL,
  `points` int(11) NOT NULL,
  `balance_after` int(11) NOT NULL,
  `reference_type` enum('order','review','referral','birthday','adjustment','redemption','expiration') DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `description` varchar(500) NOT NULL,
  `expiry_date` timestamp NULL DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_loyalty_account` (`account_id`),
  KEY `idx_loyalty_type` (`transaction_type`),
  KEY `idx_loyalty_created` (`created_at`),
  KEY `idx_loyalty_ledger_processor` (`processed_by`),
  CONSTRAINT `fk_loyalty_ledger_account` FOREIGN KEY (`account_id`) REFERENCES `loyalty_accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_loyalty_ledger_processor` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loyalty_ledger`
--

LOCK TABLES `loyalty_ledger` WRITE;
/*!40000 ALTER TABLE `loyalty_ledger` DISABLE KEYS */;
/*!40000 ALTER TABLE `loyalty_ledger` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loyalty_redemptions`
--

DROP TABLE IF EXISTS `loyalty_redemptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `loyalty_redemptions` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `reward_id` int(11) NOT NULL,
  `points_used` int(11) NOT NULL,
  `redemption_value` decimal(10,2) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `status` enum('pending','applied','expired','cancelled') NOT NULL DEFAULT 'pending',
  `redemption_code` varchar(50) DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `redeemed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_loyalty_redemption_account` (`account_id`),
  KEY `idx_loyalty_redemption_reward` (`reward_id`),
  KEY `idx_loyalty_redemption_order` (`order_id`),
  KEY `idx_loyalty_redemption_status` (`status`),
  CONSTRAINT `fk_loyalty_redemptions_account` FOREIGN KEY (`account_id`) REFERENCES `loyalty_accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_loyalty_redemptions_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_loyalty_redemptions_reward` FOREIGN KEY (`reward_id`) REFERENCES `loyalty_rewards` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loyalty_redemptions`
--

LOCK TABLES `loyalty_redemptions` WRITE;
/*!40000 ALTER TABLE `loyalty_redemptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `loyalty_redemptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loyalty_rewards`
--

DROP TABLE IF EXISTS `loyalty_rewards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `loyalty_rewards` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `reward_type` enum('discount','free_shipping','product','cashback','custom') NOT NULL,
  `reward_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `points_required` int(11) NOT NULL,
  `max_redemptions` int(11) DEFAULT NULL,
  `current_redemptions` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `valid_from` timestamp NULL DEFAULT NULL,
  `valid_until` timestamp NULL DEFAULT NULL,
  `terms_conditions` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_loyalty_rewards_active` (`is_active`),
  KEY `idx_loyalty_rewards_points` (`points_required`),
  KEY `idx_loyalty_rewards_creator` (`created_by`),
  KEY `idx_loyalty_rewards_type` (`reward_type`),
  CONSTRAINT `fk_loyalty_rewards_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loyalty_rewards`
--

LOCK TABLES `loyalty_rewards` WRITE;
/*!40000 ALTER TABLE `loyalty_rewards` DISABLE KEYS */;
/*!40000 ALTER TABLE `loyalty_rewards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loyalty_settings`
--

DROP TABLE IF EXISTS `loyalty_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `loyalty_settings` (
  `id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `setting_type` enum('string','integer','boolean','json') NOT NULL DEFAULT 'string',
  `description` text DEFAULT NULL,
  `category` varchar(50) DEFAULT 'general',
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_loyalty_setting_key` (`setting_key`),
  KEY `idx_loyalty_settings_category` (`category`),
  KEY `idx_loyalty_settings_user` (`updated_by`),
  CONSTRAINT `fk_loyalty_settings_user` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loyalty_settings`
--

LOCK TABLES `loyalty_settings` WRITE;
/*!40000 ALTER TABLE `loyalty_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `loyalty_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loyalty_tiers`
--

DROP TABLE IF EXISTS `loyalty_tiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `loyalty_tiers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `min_points` int(11) NOT NULL DEFAULT 0,
  `max_points` int(11) DEFAULT NULL,
  `benefits` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`benefits`)),
  `point_multiplier` decimal(3,2) NOT NULL DEFAULT 1.00,
  `icon` varchar(255) DEFAULT NULL,
  `color` varchar(7) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_min_points` (`min_points`),
  KEY `idx_sort_order` (`sort_order`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loyalty_tiers`
--

LOCK TABLES `loyalty_tiers` WRITE;
/*!40000 ALTER TABLE `loyalty_tiers` DISABLE KEYS */;
INSERT INTO `loyalty_tiers` VALUES
(1,'Bronze','Entry level tier',0,999,'{\"free_shipping_threshold\": 100, \"birthday_bonus\": 50}',1.00,NULL,NULL,1,1,'2025-09-14 19:54:26'),
(2,'Silver','Intermediate tier',1000,4999,'{\"free_shipping_threshold\": 75, \"birthday_bonus\": 100, \"early_access\": true}',1.25,NULL,NULL,2,1,'2025-09-14 19:54:26'),
(3,'Gold','Premium tier',5000,14999,'{\"free_shipping\": true, \"birthday_bonus\": 200, \"early_access\": true, \"priority_support\": true}',1.50,NULL,NULL,3,1,'2025-09-14 19:54:26'),
(4,'Platinum','Elite tier',15000,NULL,'{\"free_shipping\": true, \"birthday_bonus\": 500, \"early_access\": true, \"priority_support\": true, \"exclusive_offers\": true}',2.00,NULL,NULL,4,1,'2025-09-14 19:54:26');
/*!40000 ALTER TABLE `loyalty_tiers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mail_queue`
--

DROP TABLE IF EXISTS `mail_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mail_queue` (
  `id` int(11) NOT NULL,
  `to_email` varchar(255) NOT NULL,
  `subject` varchar(500) NOT NULL,
  `template_name` varchar(100) NOT NULL,
  `template_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`template_data`)),
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
  `status` enum('pending','sent','failed','retry') NOT NULL DEFAULT 'pending',
  `attempts` int(11) NOT NULL DEFAULT 0,
  `last_attempt` timestamp NULL DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_mail_status` (`status`),
  KEY `idx_mail_created` (`created_at`),
  KEY `idx_mail_to_email` (`to_email`),
  KEY `idx_mail_template` (`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mail_queue`
--

LOCK TABLES `mail_queue` WRITE;
/*!40000 ALTER TABLE `mail_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `mail_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marketing_campaigns`
--

DROP TABLE IF EXISTS `marketing_campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `marketing_campaigns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `type` enum('email','sms') NOT NULL DEFAULT 'email',
  `description` text DEFAULT NULL,
  `campaign_type` enum('flash_sale','daily_deal','seasonal','promotion','affiliate','email','social') NOT NULL,
  `status` enum('draft','scheduled','active','paused','completed','cancelled') NOT NULL DEFAULT 'draft',
  `budget` decimal(10,2) DEFAULT NULL,
  `spent_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `target_audience` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`target_audience`)),
  `discount_type` enum('percentage','fixed','bogo','free_shipping') DEFAULT NULL,
  `discount_value` decimal(10,2) DEFAULT NULL,
  `minimum_order_amount` decimal(10,2) DEFAULT NULL,
  `usage_limit` int(11) DEFAULT NULL,
  `usage_limit_per_user` int(11) DEFAULT 1,
  `usage_count` int(11) NOT NULL DEFAULT 0,
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `applicable_products` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`applicable_products`)),
  `applicable_categories` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`applicable_categories`)),
  `tracking_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tracking_data`)),
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_campaign_type` (`campaign_type`),
  KEY `idx_status` (`status`),
  KEY `idx_start_date` (`start_date`),
  KEY `idx_end_date` (`end_date`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_marketing_campaigns_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marketing_campaigns`
--

LOCK TABLES `marketing_campaigns` WRITE;
/*!40000 ALTER TABLE `marketing_campaigns` DISABLE KEYS */;
/*!40000 ALTER TABLE `marketing_campaigns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menus`
--

DROP TABLE IF EXISTS `menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `menus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `location` varchar(50) NOT NULL,
  `items` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`items`)),
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_location` (`location`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menus`
--

LOCK TABLES `menus` WRITE;
/*!40000 ALTER TABLE `menus` DISABLE KEYS */;
/*!40000 ALTER TABLE `menus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_delivery_logs`
--

DROP TABLE IF EXISTS `message_delivery_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `message_delivery_logs` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11) NOT NULL,
  `event_type` enum('sent','delivered','opened','clicked','bounced','complained','unsubscribed') NOT NULL,
  `event_timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `gateway_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`gateway_response`)),
  `user_agent` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `additional_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`additional_data`)),
  PRIMARY KEY (`log_id`),
  KEY `idx_message_id` (`message_id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_event_timestamp` (`event_timestamp`),
  KEY `idx_delivery_logs_message_event` (`message_id`,`event_type`,`event_timestamp`),
  CONSTRAINT `fk_message_delivery_logs_message` FOREIGN KEY (`message_id`) REFERENCES `comm_messages` (`message_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_delivery_logs`
--

LOCK TABLES `message_delivery_logs` WRITE;
/*!40000 ALTER TABLE `message_delivery_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `message_delivery_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_read_receipts`
--

DROP TABLE IF EXISTS `message_read_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `message_read_receipts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `message_id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `read_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_message_id` (`message_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `message_read_receipts_ibfk_1` FOREIGN KEY (`message_id`) REFERENCES `product_inquiry_messages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_read_receipts`
--

LOCK TABLES `message_read_receipts` WRITE;
/*!40000 ALTER TABLE `message_read_receipts` DISABLE KEYS */;
/*!40000 ALTER TABLE `message_read_receipts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_templates`
--

DROP TABLE IF EXISTS `message_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `message_templates` (
  `template_id` int(11) NOT NULL AUTO_INCREMENT,
  `type` enum('email','sms','push','in_app') NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `content_html` longtext DEFAULT NULL,
  `content_text` longtext DEFAULT NULL,
  `variables` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`variables`)),
  `version` int(11) NOT NULL DEFAULT 1,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `category` varchar(100) DEFAULT NULL,
  `language` varchar(5) NOT NULL DEFAULT 'en',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`template_id`),
  KEY `idx_type` (`type`),
  KEY `idx_category` (`category`),
  KEY `idx_language` (`language`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_message_templates_type_active` (`type`,`is_active`,`category`),
  CONSTRAINT `fk_message_templates_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_templates`
--

LOCK TABLES `message_templates` WRITE;
/*!40000 ALTER TABLE `message_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `message_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `conversation_id` varchar(100) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `recipient_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `message_type` enum('text','image','file','system') NOT NULL DEFAULT 'text',
  `attachment_url` varchar(500) DEFAULT NULL,
  `attachment_type` varchar(50) DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `parent_message_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_conversation_id` (`conversation_id`),
  KEY `idx_sender_id` (`sender_id`),
  KEY `idx_recipient_id` (`recipient_id`),
  KEY `idx_read_at` (`read_at`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_parent_message_id` (`parent_message_id`),
  CONSTRAINT `fk_messages_parent` FOREIGN KEY (`parent_message_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_messages_recipient` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL DEFAULT 1,
  `executed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_filename` (`filename`),
  KEY `idx_batch` (`batch`),
  KEY `idx_executed_at` (`executed_at`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES
(1,'001_add_orders_placed_at.php',1,'2025-10-14 14:29:57'),
(2,'002_seed_admin_seller_users.php',2,'2025-10-14 19:55:26'),
(3,'006_create_live_streaming_tables.php',2,'2025-10-14 19:55:26'),
(4,'025_make_addresses_nullable.php',3,'2025-10-14 19:55:47'),
(5,'026_create_countries_table.php',4,'2025-10-14 19:56:04'),
(6,'026_create_user_addresses_table.php',5,'2025-10-14 19:56:16'),
(7,'027_create_user_payment_methods_table.php',6,'2025-10-14 19:56:23'),
(8,'027_seed_countries_data.php',7,'2025-10-14 19:56:29'),
(9,'028_create_wallets_tables.php',7,'2025-10-14 19:56:29'),
(10,'029_create_giftcards_table.php',8,'2025-10-14 19:56:34'),
(11,'030_create_live_chat_messages_table.php',9,'2025-10-14 19:56:46'),
(12,'031_create_seller_ads_table.php',10,'2025-10-14 19:57:00'),
(13,'032_create_product_files_table.php',11,'2025-10-14 19:57:08'),
(14,'033_create_currency_rates_table.php',12,'2025-10-14 19:57:13'),
(15,'034_update_users_and_coupons_tables.php',13,'2025-10-14 19:57:20'),
(16,'2025_10_15_fix_maintenance_page_columns.sql',14,'2025-10-15 19:23:28');
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `multi_language_content`
--

DROP TABLE IF EXISTS `multi_language_content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `multi_language_content` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_type` enum('product','category','cms_page','banner','notification') NOT NULL,
  `content_id` int(11) NOT NULL,
  `language_code` varchar(5) NOT NULL DEFAULT 'en',
  `field_name` varchar(100) NOT NULL,
  `translated_content` longtext NOT NULL,
  `is_auto_translated` tinyint(1) NOT NULL DEFAULT 0,
  `translator_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_content_language_field` (`content_type`,`content_id`,`language_code`,`field_name`),
  KEY `idx_content_type` (`content_type`),
  KEY `idx_content_id` (`content_id`),
  KEY `idx_language_code` (`language_code`),
  KEY `idx_translator_id` (`translator_id`),
  CONSTRAINT `fk_multi_language_content_translator` FOREIGN KEY (`translator_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `multi_language_content`
--

LOCK TABLES `multi_language_content` WRITE;
/*!40000 ALTER TABLE `multi_language_content` DISABLE KEYS */;
/*!40000 ALTER TABLE `multi_language_content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_logs`
--

DROP TABLE IF EXISTS `notification_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `template_type` varchar(100) NOT NULL,
  `category` varchar(50) NOT NULL,
  `subject` varchar(500) NOT NULL,
  `body` text NOT NULL,
  `channel` enum('email','in_app','sms','push') NOT NULL,
  `status` enum('pending','sent','failed','bounced') NOT NULL DEFAULT 'pending',
  `recipient` varchar(255) DEFAULT NULL COMMENT 'Email address, phone number, etc.',
  `error_message` text DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_template_type` (`template_type`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_logs`
--

LOCK TABLES `notification_logs` WRITE;
/*!40000 ALTER TABLE `notification_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_preferences`
--

DROP TABLE IF EXISTS `notification_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_preferences` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `category` enum('authentication','order','payment','security','marketing','seller','system') NOT NULL,
  `email_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `in_app_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `sms_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_category` (`user_id`,`category`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=185 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_preferences`
--

LOCK TABLES `notification_preferences` WRITE;
/*!40000 ALTER TABLE `notification_preferences` DISABLE KEYS */;
INSERT INTO `notification_preferences` VALUES
(1,4,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(2,19,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(3,21,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(4,22,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(5,23,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(6,24,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(7,25,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(8,26,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(9,27,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(10,28,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(11,29,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(12,30,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(13,31,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(14,32,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(15,33,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(16,34,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(17,35,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(18,36,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(19,37,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(20,38,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(21,39,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(22,40,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(23,41,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(24,42,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(25,43,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(26,44,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(27,1,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(28,20,'authentication',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(32,4,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(33,19,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(34,21,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(35,22,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(36,23,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(37,24,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(38,25,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(39,26,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(40,27,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(41,28,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(42,29,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(43,30,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(44,31,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(45,32,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(46,33,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(47,34,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(48,35,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(49,36,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(50,37,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(51,38,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(52,39,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(53,40,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(54,41,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(55,42,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(56,43,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(57,44,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(58,1,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(59,20,'order',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(63,4,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(64,19,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(65,21,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(66,22,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(67,23,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(68,24,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(69,25,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(70,26,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(71,27,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(72,28,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(73,29,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(74,30,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(75,31,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(76,32,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(77,33,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(78,34,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(79,35,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(80,36,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(81,37,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(82,38,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(83,39,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(84,40,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(85,41,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(86,42,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(87,43,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(88,44,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(89,1,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(90,20,'payment',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(94,4,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(95,19,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(96,21,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(97,22,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(98,23,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(99,24,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(100,25,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(101,26,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(102,27,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(103,28,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(104,29,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(105,30,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(106,31,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(107,32,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(108,33,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(109,34,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(110,35,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(111,36,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(112,37,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(113,38,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(114,39,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(115,40,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(116,41,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(117,42,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(118,43,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(119,44,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(120,1,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(121,20,'security',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(125,4,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(126,19,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(127,21,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(128,22,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(129,23,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(130,24,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(131,25,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(132,26,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(133,27,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(134,28,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(135,29,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(136,30,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(137,31,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(138,32,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(139,33,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(140,34,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(141,35,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(142,36,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(143,37,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(144,38,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(145,39,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(146,40,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(147,41,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(148,42,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(149,43,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(150,44,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(151,1,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(152,20,'marketing',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(156,24,'seller',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(157,4,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(158,19,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(159,21,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(160,22,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(161,23,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(162,24,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(163,25,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(164,26,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(165,27,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(166,28,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(167,29,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(168,30,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(169,31,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(170,32,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(171,33,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(172,34,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(173,35,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(174,36,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(175,37,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(176,38,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(177,39,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(178,40,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(179,41,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(180,42,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(181,43,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(182,44,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(183,1,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14'),
(184,20,'system',1,1,0,'2025-10-15 19:14:14','2025-10-15 19:14:14');
/*!40000 ALTER TABLE `notification_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_settings`
--

DROP TABLE IF EXISTS `notification_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `email_new_order` tinyint(1) NOT NULL DEFAULT 1,
  `email_order_shipped` tinyint(1) NOT NULL DEFAULT 1,
  `email_order_delivered` tinyint(1) NOT NULL DEFAULT 1,
  `email_customer_message` tinyint(1) NOT NULL DEFAULT 1,
  `email_product_review` tinyint(1) NOT NULL DEFAULT 1,
  `email_low_stock` tinyint(1) NOT NULL DEFAULT 1,
  `email_payout_completed` tinyint(1) NOT NULL DEFAULT 1,
  `email_weekly_summary` tinyint(1) NOT NULL DEFAULT 0,
  `email_monthly_report` tinyint(1) NOT NULL DEFAULT 0,
  `sms_new_order` tinyint(1) NOT NULL DEFAULT 0,
  `sms_urgent_alerts` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_vendor` (`vendor_id`),
  CONSTRAINT `fk_notification_settings_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_settings`
--

LOCK TABLES `notification_settings` WRITE;
/*!40000 ALTER TABLE `notification_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `notification_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_templates`
--

DROP TABLE IF EXISTS `notification_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(100) NOT NULL COMMENT 'Unique identifier for notification type',
  `category` enum('authentication','order','payment','security','marketing','seller','system') NOT NULL DEFAULT 'system',
  `name` varchar(255) NOT NULL COMMENT 'Human-readable name',
  `description` text DEFAULT NULL COMMENT 'Description of when this notification is used',
  `subject` varchar(500) NOT NULL COMMENT 'Email subject line with variables',
  `body_template` text NOT NULL COMMENT 'Email/notification body with variables',
  `variables` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'List of available variables for this template' CHECK (json_valid(`variables`)),
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  `send_email` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Send as email',
  `send_in_app` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Send as in-app notification',
  `send_sms` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Send as SMS (optional)',
  `priority` enum('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `type` (`type`),
  KEY `idx_type` (`type`),
  KEY `idx_category` (`category`),
  KEY `idx_enabled` (`enabled`)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_templates`
--

LOCK TABLES `notification_templates` WRITE;
/*!40000 ALTER TABLE `notification_templates` DISABLE KEYS */;
INSERT INTO `notification_templates` VALUES
(1,'login_success','authentication','Successful Login','Sent after successful login with device info','Successful login to your {app_name} account','Hello {customer_name},\n\nYou successfully logged in to your account.\n\nTimestamp: {login_time}\nDevice: {device_info}\nIP Address: {ip_address}\nLocation: {location}\n\nIf this was not you, please secure your account immediately: {security_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"login_time\",\"device_info\",\"ip_address\",\"location\",\"security_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(2,'login_failed','authentication','Failed Login Attempt','Sent after failed login attempts','Failed login attempt on your {app_name} account','Hello {customer_name},\n\nWe detected a failed login attempt on your account.\n\nTimestamp: {attempt_time}\nDevice: {device_info}\nIP Address: {ip_address}\nLocation: {location}\n\nIf this was you, please try again or reset your password: {reset_url}\n\nIf this was not you, your account may be at risk. Please secure it immediately: {security_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"attempt_time\",\"device_info\",\"ip_address\",\"location\",\"reset_url\",\"security_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(3,'new_device_login','authentication','New Device Login','Sent when login from new device/location detected','New device login detected - {app_name}','Hello {customer_name},\n\nWe detected a login from a new device or location:\n\nTimestamp: {login_time}\nDevice: {device_info}\nBrowser: {browser_info}\nLocation: {location}\nIP Address: {ip_address}\n\nIf this was you, you can safely ignore this message.\n\nIf this was not you, please secure your account immediately: {security_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"login_time\",\"device_info\",\"browser_info\",\"location\",\"ip_address\",\"security_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(4,'password_changed','authentication','Password Changed','Sent after successful password change','Your {app_name} password has been changed','Hello {customer_name},\n\nYour password was successfully changed.\n\nTimestamp: {change_time}\nDevice: {device_info}\nIP Address: {ip_address}\n\nIf you did not make this change, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"change_time\",\"device_info\",\"ip_address\",\"support_email\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(5,'password_reset_request','authentication','Password Reset Request','Sent when password reset is requested','Reset your {app_name} password','Hello {customer_name},\n\nWe received a request to reset your password.\n\nClick here to reset your password: {reset_url}\n\nThis link will expire in {expiry_time}.\n\nIf you did not request this, please ignore this email and your password will remain unchanged.\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"reset_url\",\"expiry_time\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(6,'profile_updated','authentication','Profile Updated','Sent when profile information is edited','Your {app_name} profile has been updated','Hello {customer_name},\n\nYour profile information has been updated.\n\nChanges made:\n{changes_list}\n\nTimestamp: {update_time}\n\nIf you did not make these changes, please contact support immediately: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"changes_list\",\"update_time\",\"support_email\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(7,'email_changed','authentication','Email Address Changed','Sent to both old and new email addresses','Your {app_name} email address has been changed','Hello {customer_name},\n\nYour email address has been changed from {old_email} to {new_email}.\n\nTimestamp: {change_time}\n\nIf you did not make this change, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"old_email\",\"new_email\",\"change_time\",\"support_email\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(8,'2fa_enabled','authentication','2FA Enabled','Sent when two-factor authentication is activated','Two-factor authentication enabled on your {app_name} account','Hello {customer_name},\n\nTwo-factor authentication has been successfully enabled on your account.\n\nTimestamp: {enable_time}\nDevice: {device_info}\n\nYour account is now more secure. You will need to enter a verification code when logging in from new devices.\n\nIf you did not enable this, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"enable_time\",\"device_info\",\"support_email\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(9,'2fa_disabled','authentication','2FA Disabled','Sent when two-factor authentication is deactivated','Two-factor authentication disabled on your {app_name} account','Hello {customer_name},\n\nTwo-factor authentication has been disabled on your account.\n\nTimestamp: {disable_time}\nDevice: {device_info}\n\nYour account is now less secure. We recommend keeping 2FA enabled.\n\nIf you did not disable this, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"disable_time\",\"device_info\",\"support_email\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(10,'account_deactivated','authentication','Account Deactivated','Sent when account is deactivated','Your {app_name} account has been deactivated','Hello {customer_name},\n\nYour account has been deactivated.\n\nTimestamp: {deactivation_time}\nReason: {reason}\n\nYou can reactivate your account at any time by logging in: {login_url}\n\nIf you did not request this, please contact us: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"deactivation_time\",\"reason\",\"login_url\",\"support_email\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(11,'account_reactivated','authentication','Account Reactivated','Sent when account is reactivated','Welcome back! Your {app_name} account has been reactivated','Hello {customer_name},\n\nYour account has been reactivated and you can now access all features.\n\nTimestamp: {reactivation_time}\n\nStart shopping: {shop_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"reactivation_time\",\"shop_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(12,'account_deletion_request','authentication','Account Deletion Request','Sent when account deletion is requested','Account deletion requested - {app_name}','Hello {customer_name},\n\nWe received a request to delete your account.\n\nYour account will be permanently deleted on: {deletion_date}\n\nTo cancel this request, log in to your account: {cancel_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"deletion_date\",\"cancel_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(13,'account_deleted','authentication','Account Deleted','Sent when account is permanently deleted','Your {app_name} account has been deleted','Hello {customer_name},\n\nYour account has been permanently deleted as requested.\n\nAll your data has been removed from our systems.\n\nThank you for being part of {app_name}.\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(14,'order_placed','order','Order Placed','Sent immediately after order is placed','Order confirmation #{order_number} - {app_name}','Hello {customer_name},\n\nThank you for your order!\n\nOrder Number: #{order_number}\nOrder Date: {order_date}\nTotal Amount: {total_amount}\n\nOrder Details:\n{order_items}\n\nShipping Address:\n{shipping_address}\n\nTracking Link: {tracking_url}\n\nView your order: {order_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"order_date\",\"total_amount\",\"order_items\",\"shipping_address\",\"tracking_url\",\"order_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(15,'order_confirmed','order','Order Confirmed','Sent when order is confirmed by seller','Order #{order_number} confirmed - {app_name}','Hello {customer_name},\n\nYour order has been confirmed and is being prepared for shipment.\n\nOrder Number: #{order_number}\nConfirmed: {confirmation_time}\nEstimated Delivery: {estimated_delivery}\n\nTrack your order: {tracking_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"confirmation_time\",\"estimated_delivery\",\"tracking_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(16,'order_processing','order','Order Processing','Sent when order is being processed','Order #{order_number} is being processed - {app_name}','Hello {customer_name},\n\nYour order is now being processed.\n\nOrder Number: #{order_number}\nStatus: Processing\n\nWe will notify you once it has been shipped.\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"order_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(17,'order_packed','order','Order Packed','Sent when order is packed and ready to ship','Order #{order_number} has been packed - {app_name}','Hello {customer_name},\n\nYour order has been packed and is ready for shipment.\n\nOrder Number: #{order_number}\nPacked: {packed_time}\n\nIt will be shipped soon!\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"packed_time\",\"order_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(18,'order_shipped','order','Order Shipped','Sent when order has shipped','Order #{order_number} has shipped - {app_name}','Hello {customer_name},\n\nGreat news! Your order has been shipped.\n\nOrder Number: #{order_number}\nShipped: {shipped_date}\nTracking Number: {tracking_number}\nCarrier: {carrier_name}\nEstimated Delivery: {estimated_delivery}\n\nTrack your shipment: {tracking_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"shipped_date\",\"tracking_number\",\"carrier_name\",\"estimated_delivery\",\"tracking_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(19,'order_in_transit','order','Order In Transit','Sent when order is out for delivery','Order #{order_number} is out for delivery - {app_name}','Hello {customer_name},\n\nYour order is out for delivery!\n\nOrder Number: #{order_number}\nExpected Delivery: {delivery_date}\n\nTrack your order: {tracking_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"delivery_date\",\"tracking_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(20,'order_delivered','order','Order Delivered','Sent when order is delivered','Order #{order_number} has been delivered - {app_name}','Hello {customer_name},\n\nYour order has been delivered!\n\nOrder Number: #{order_number}\nDelivered: {delivery_time}\n\nHow was your experience? Leave a review: {review_url}\n\nThank you for shopping with us!\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"delivery_time\",\"review_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(21,'order_delayed','order','Order Delayed','Sent when shipment is delayed','Order #{order_number} is delayed - {app_name}','Hello {customer_name},\n\nWe apologize, but your order has been delayed.\n\nOrder Number: #{order_number}\nOriginal Delivery: {original_date}\nNew Estimated Delivery: {new_date}\nReason: {delay_reason}\n\nWe apologize for any inconvenience.\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"original_date\",\"new_date\",\"delay_reason\",\"order_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(22,'order_backordered','order','Order Backordered','Sent when item is on backorder','Order #{order_number} - Item backordered - {app_name}','Hello {customer_name},\n\nOne or more items in your order are currently on backorder.\n\nOrder Number: #{order_number}\nBackordered Items:\n{backordered_items}\n\nExpected Restock Date: {restock_date}\n\nWe will ship your order as soon as items are available.\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"backordered_items\",\"restock_date\",\"order_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(23,'order_cancelled','order','Order Cancelled','Sent when order is cancelled','Order #{order_number} has been cancelled - {app_name}','Hello {customer_name},\n\nYour order has been cancelled.\n\nOrder Number: #{order_number}\nCancelled: {cancellation_time}\nReason: {cancellation_reason}\n\nRefund Status: {refund_status}\n\nIf you have any questions, please contact us: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"cancellation_time\",\"cancellation_reason\",\"refund_status\",\"support_email\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(24,'order_modified','order','Order Modified','Sent when order details are modified','Order #{order_number} has been modified - {app_name}','Hello {customer_name},\n\nYour order has been modified.\n\nOrder Number: #{order_number}\nModified: {modification_time}\n\nChanges:\n{changes_list}\n\nNew Total: {new_total}\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"modification_time\",\"changes_list\",\"new_total\",\"order_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(25,'review_request','order','Review Request','Sent after delivery to request product review','How was your order? - {app_name}','Hello {customer_name},\n\nWe hope you love your recent purchase!\n\nOrder Number: #{order_number}\n\nWould you mind leaving a review? Your feedback helps other customers and improves our service.\n\nLeave a review: {review_url}\n\nThank you for shopping with us!\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"review_url\",\"app_name\"]',1,1,1,0,'low','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(26,'payment_successful','payment','Payment Successful','Sent when payment is processed successfully','Payment received - {app_name}','Hello {customer_name},\n\nYour payment has been processed successfully.\n\nAmount: {amount}\nPayment Method: {payment_method}\nTransaction ID: {transaction_id}\nDate: {payment_date}\n\nOrder Number: #{order_number}\n\nView invoice: {invoice_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"amount\",\"payment_method\",\"transaction_id\",\"payment_date\",\"order_number\",\"invoice_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(27,'payment_failed','payment','Payment Failed','Sent when payment fails','Payment failed for order #{order_number} - {app_name}','Hello {customer_name},\n\nWe were unable to process your payment.\n\nOrder Number: #{order_number}\nAmount: {amount}\nReason: {failure_reason}\n\nPlease update your payment method and try again: {payment_url}\n\nIf you need assistance, contact us: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"order_number\",\"amount\",\"failure_reason\",\"payment_url\",\"support_email\",\"app_name\"]',1,1,1,0,'urgent','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(28,'invoice_issued','payment','Invoice Issued','Sent when new invoice is created','Invoice #{invoice_number} - {app_name}','Hello {customer_name},\n\nA new invoice has been issued.\n\nInvoice Number: #{invoice_number}\nIssue Date: {issue_date}\nDue Date: {due_date}\nAmount: {amount}\n\nView invoice: {invoice_url}\nMake payment: {payment_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"invoice_number\",\"issue_date\",\"due_date\",\"amount\",\"invoice_url\",\"payment_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(29,'refund_issued','payment','Refund Issued','Sent when refund is processed','Refund processed - {app_name}','Hello {customer_name},\n\nYour refund has been processed.\n\nRefund Amount: {refund_amount}\nOriginal Order: #{order_number}\nRefund Method: {refund_method}\nProcessing Time: {processing_time}\n\nYou should see the refund in your account within {refund_days} business days.\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"refund_amount\",\"order_number\",\"refund_method\",\"processing_time\",\"refund_days\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(30,'credit_issued','payment','Store Credit Issued','Sent when store credit is added','Store credit added to your account - {app_name}','Hello {customer_name},\n\nStore credit has been added to your account!\n\nCredit Amount: {credit_amount}\nReason: {credit_reason}\nExpires: {expiry_date}\n\nYour new balance: {new_balance}\n\nStart shopping: {shop_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"credit_amount\",\"credit_reason\",\"expiry_date\",\"new_balance\",\"shop_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(31,'payment_method_added','payment','Payment Method Added','Sent when new payment method is added','New payment method added - {app_name}','Hello {customer_name},\n\nA new payment method has been added to your account.\n\nPayment Method: {payment_method}\nAdded: {add_time}\nDevice: {device_info}\n\nIf you did not make this change, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"payment_method\",\"add_time\",\"device_info\",\"support_email\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(32,'payment_method_removed','payment','Payment Method Removed','Sent when payment method is removed','Payment method removed - {app_name}','Hello {customer_name},\n\nA payment method has been removed from your account.\n\nPayment Method: {payment_method}\nRemoved: {remove_time}\nDevice: {device_info}\n\nIf you did not make this change, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"payment_method\",\"remove_time\",\"device_info\",\"support_email\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(33,'low_balance_alert','payment','Low Balance Alert','Sent when wallet balance is low','Low balance alert - {app_name}','Hello {customer_name},\n\nYour wallet balance is running low.\n\nCurrent Balance: {current_balance}\nLow Balance Threshold: {threshold}\n\nAdd funds to your wallet: {add_funds_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"current_balance\",\"threshold\",\"add_funds_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(34,'suspicious_activity','security','Suspicious Activity Detected','Sent when suspicious activity is detected','Security alert - Suspicious activity detected - {app_name}','Hello {customer_name},\n\nWe detected suspicious activity on your account.\n\nActivity Type: {activity_type}\nDetected: {detection_time}\nLocation: {location}\nIP Address: {ip_address}\n\nWe have temporarily restricted some account functions for your protection.\n\nIf this was you, you can verify your identity here: {verify_url}\n\nIf this was not you, please secure your account immediately: {security_url}\n\nContact support: {support_email}\n\nBest regards,\n{app_name} Security Team','[\"customer_name\",\"activity_type\",\"detection_time\",\"location\",\"ip_address\",\"verify_url\",\"security_url\",\"support_email\",\"app_name\"]',1,1,1,0,'urgent','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(35,'multiple_failed_logins','security','Multiple Failed Login Attempts','Sent after multiple failed login attempts','Security alert - Multiple failed login attempts - {app_name}','Hello {customer_name},\n\nWe detected multiple failed login attempts on your account.\n\nAttempts: {attempt_count}\nTime Period: {time_period}\nLast Attempt: {last_attempt_time}\nLocation: {location}\n\nYour account has been temporarily locked for security.\n\nReset your password: {reset_url}\n\nIf you need help, contact us: {support_email}\n\nBest regards,\n{app_name} Security Team','[\"customer_name\",\"attempt_count\",\"time_period\",\"last_attempt_time\",\"location\",\"reset_url\",\"support_email\",\"app_name\"]',1,1,1,0,'urgent','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(36,'terms_updated','security','Terms of Service Updated','Sent when ToS is updated','Terms of Service updated - {app_name}','Hello {customer_name},\n\nWe have updated our Terms of Service.\n\nEffective Date: {effective_date}\n\nKey Changes:\n{changes_summary}\n\nRead the full terms: {terms_url}\n\nBy continuing to use our service after {effective_date}, you agree to the updated terms.\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"effective_date\",\"changes_summary\",\"terms_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(37,'privacy_policy_updated','security','Privacy Policy Updated','Sent when privacy policy is updated','Privacy Policy updated - {app_name}','Hello {customer_name},\n\nWe have updated our Privacy Policy.\n\nEffective Date: {effective_date}\n\nKey Changes:\n{changes_summary}\n\nRead the full policy: {privacy_url}\n\nIf you have questions, contact us: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"effective_date\",\"changes_summary\",\"privacy_url\",\"support_email\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(38,'account_suspended','security','Account Suspended','Sent when account is suspended','Your account has been suspended - {app_name}','Hello {customer_name},\n\nYour account has been suspended.\n\nSuspension Date: {suspension_date}\nReason: {suspension_reason}\nDuration: {duration}\n\nTo appeal this decision or get more information, contact us: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"suspension_date\",\"suspension_reason\",\"duration\",\"support_email\",\"app_name\"]',1,1,1,0,'urgent','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(39,'account_restriction','security','Account Restriction Notice','Sent when account has restrictions','Account restriction notice - {app_name}','Hello {customer_name},\n\nCertain features of your account have been restricted.\n\nRestricted Features:\n{restricted_features}\n\nReason: {restriction_reason}\nDuration: {duration}\n\nTo resolve this, please: {resolution_steps}\n\nContact support: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"restricted_features\",\"restriction_reason\",\"duration\",\"resolution_steps\",\"support_email\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(40,'kyc_approved','security','KYC Verification Approved','Sent when KYC is approved','KYC verification approved - {app_name}','Hello {customer_name},\n\nGreat news! Your identity verification has been approved.\n\nVerification Level: {verification_level}\nApproved: {approval_date}\n\nYou now have access to all features.\n\nStart using your account: {dashboard_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"verification_level\",\"approval_date\",\"dashboard_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(41,'kyc_rejected','security','KYC Verification Rejected','Sent when KYC is rejected','KYC verification needs attention - {app_name}','Hello {customer_name},\n\nWe were unable to verify your identity.\n\nReason: {rejection_reason}\n\nYou can resubmit your documents: {resubmit_url}\n\nIf you need assistance, contact us: {support_email}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"rejection_reason\",\"resubmit_url\",\"support_email\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(42,'kyc_pending','security','KYC Verification Pending','Sent when KYC is under review','KYC verification is being reviewed - {app_name}','Hello {customer_name},\n\nThank you for submitting your verification documents.\n\nStatus: Under Review\nExpected Processing Time: {processing_time}\n\nWe will notify you once the review is complete.\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"processing_time\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(43,'newsletter','marketing','Newsletter','Regular newsletter','{newsletter_title} - {app_name}','Hello {customer_name},\n\n{newsletter_content}\n\nRead more: {newsletter_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"newsletter_title\",\"newsletter_content\",\"newsletter_url\",\"app_name\"]',1,1,0,0,'low','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(44,'promotion','marketing','Promotional Offer','Special promotions and offers','{promotion_title} - {app_name}','Hello {customer_name},\n\n{promotion_message}\n\nDiscount Code: {discount_code}\nValid Until: {expiry_date}\n\nShop now: {promotion_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"promotion_title\",\"promotion_message\",\"discount_code\",\"expiry_date\",\"promotion_url\",\"app_name\"]',1,1,1,0,'low','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(45,'price_drop','marketing','Price Drop Alert','Sent when wishlist item price drops','Price drop alert! - {app_name}','Hello {customer_name},\n\nGreat news! An item on your wishlist has dropped in price.\n\nProduct: {product_name}\nOld Price: {old_price}\nNew Price: {new_price}\nYou save: {savings}\n\nBuy now: {product_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"product_name\",\"old_price\",\"new_price\",\"savings\",\"product_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(46,'back_in_stock','marketing','Back in Stock Alert','Sent when wishlist item is back in stock','Back in stock! - {app_name}','Hello {customer_name},\n\nGood news! An item you were waiting for is back in stock.\n\nProduct: {product_name}\nPrice: {price}\n\nGet it before it sells out: {product_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"product_name\",\"price\",\"product_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(47,'abandoned_cart','marketing','Abandoned Cart Reminder','Sent when cart is abandoned','You left items in your cart - {app_name}','Hello {customer_name},\n\nYou have {item_count} items waiting in your cart.\n\n{cart_items}\n\nTotal: {cart_total}\n\nComplete your purchase: {cart_url}\n\nUse code {discount_code} for {discount_percent}% off!\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"item_count\",\"cart_items\",\"cart_total\",\"cart_url\",\"discount_code\",\"discount_percent\",\"app_name\"]',1,1,1,0,'low','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(48,'new_product_alert','marketing','New Product Alert','Sent when new products match preferences','New products you might like - {app_name}','Hello {customer_name},\n\nWe added new products based on your interests:\n\n{products_list}\n\nExplore more: {shop_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"products_list\",\"shop_url\",\"app_name\"]',1,1,1,0,'low','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(49,'seller_new_order','seller','New Order Received','Sent when seller receives new order','New order received #{order_number} - {app_name}','Hello {seller_name},\n\nYou have received a new order!\n\nOrder Number: #{order_number}\nCustomer: {customer_name}\nAmount: {order_amount}\nItems: {item_count}\n\nView order details: {order_url}\n\nPlease process this order promptly.\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"order_number\",\"customer_name\",\"order_amount\",\"item_count\",\"order_url\",\"app_name\"]',1,1,1,0,'urgent','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(50,'seller_order_status_changed','seller','Order Status Changed','Sent when order status is updated','Order #{order_number} status updated - {app_name}','Hello {seller_name},\n\nOrder status has been updated.\n\nOrder Number: #{order_number}\nNew Status: {new_status}\nUpdated: {update_time}\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"order_number\",\"new_status\",\"update_time\",\"order_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(51,'seller_low_stock','seller','Low Stock Alert','Sent when product stock is low','Low stock alert - {product_name} - {app_name}','Hello {seller_name},\n\nYour product is running low on stock.\n\nProduct: {product_name}\nCurrent Stock: {current_stock}\nLow Stock Threshold: {threshold}\n\nRestock soon to avoid stockouts.\n\nUpdate inventory: {inventory_url}\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"product_name\",\"current_stock\",\"threshold\",\"inventory_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(52,'seller_out_of_stock','seller','Out of Stock Alert','Sent when product is out of stock','Product out of stock - {product_name} - {app_name}','Hello {seller_name},\n\nYour product is now out of stock.\n\nProduct: {product_name}\nLast Sold: {last_sold_time}\n\nRestock to continue selling.\n\nUpdate inventory: {inventory_url}\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"product_name\",\"last_sold_time\",\"inventory_url\",\"app_name\"]',1,1,1,0,'urgent','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(53,'seller_payout_issued','seller','Payout Issued','Sent when payout is processed','Payout issued - {app_name}','Hello {seller_name},\n\nYour payout has been processed!\n\nPayout Amount: {payout_amount}\nPeriod: {payout_period}\nPayment Method: {payment_method}\nTransfer Date: {transfer_date}\n\nView details: {payout_url}\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"payout_amount\",\"payout_period\",\"payment_method\",\"transfer_date\",\"payout_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(54,'seller_payout_failed','seller','Payout Failed','Sent when payout fails','Payout failed - Action required - {app_name}','Hello {seller_name},\n\nWe were unable to process your payout.\n\nPayout Amount: {payout_amount}\nReason: {failure_reason}\n\nPlease update your payment information: {payment_settings_url}\n\nContact support if you need help: {support_email}\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"payout_amount\",\"failure_reason\",\"payment_settings_url\",\"support_email\",\"app_name\"]',1,1,1,0,'urgent','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(55,'seller_message_received','seller','Customer Message','Sent when buyer sends message','New message from customer - {app_name}','Hello {seller_name},\n\nYou have received a new message from a customer.\n\nFrom: {customer_name}\nRegarding: Order #{order_number}\n\nMessage:\n{message_content}\n\nRespond to message: {message_url}\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"customer_name\",\"order_number\",\"message_content\",\"message_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(56,'seller_dispute_opened','seller','Dispute Opened','Sent when buyer opens dispute','Dispute opened - Order #{order_number} - {app_name}','Hello {seller_name},\n\nA customer has opened a dispute.\n\nOrder Number: #{order_number}\nCustomer: {customer_name}\nDispute Type: {dispute_type}\nReason: {dispute_reason}\n\nPlease respond within {response_time} to avoid auto-refund.\n\nView dispute: {dispute_url}\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"order_number\",\"customer_name\",\"dispute_type\",\"dispute_reason\",\"response_time\",\"dispute_url\",\"app_name\"]',1,1,1,0,'urgent','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(57,'seller_review_received','seller','New Review Received','Sent when seller receives review','New review received - {app_name}','Hello {seller_name},\n\nYou have received a new review!\n\nProduct: {product_name}\nRating: {rating} stars\nCustomer: {customer_name}\n\nReview:\n{review_text}\n\nView review: {review_url}\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"product_name\",\"rating\",\"customer_name\",\"review_text\",\"review_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(58,'seller_policy_violation','seller','Policy Violation Warning','Sent when seller violates policy','Policy violation warning - {app_name}','Hello {seller_name},\n\nWe detected a policy violation on your account.\n\nViolation Type: {violation_type}\nDate: {violation_date}\nDetails: {violation_details}\n\nAction Taken: {action_taken}\n\nPlease review our policies: {policies_url}\n\nRepeated violations may result in account suspension.\n\nContact support: {support_email}\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"violation_type\",\"violation_date\",\"violation_details\",\"action_taken\",\"policies_url\",\"support_email\",\"app_name\"]',1,1,1,0,'urgent','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(59,'seller_account_suspended','seller','Seller Account Suspended','Sent when seller account is suspended','Your seller account has been suspended - {app_name}','Hello {seller_name},\n\nYour seller account has been suspended.\n\nSuspension Date: {suspension_date}\nReason: {suspension_reason}\n\nDuring suspension, you cannot:\n- List new products\n- Process orders\n- Receive payouts\n\nTo appeal or resolve this: {appeal_url}\n\nContact support: {support_email}\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"suspension_date\",\"suspension_reason\",\"appeal_url\",\"support_email\",\"app_name\"]',1,1,1,0,'urgent','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(60,'seller_performance_summary','seller','Performance Summary','Monthly performance report','Your monthly performance summary - {app_name}','Hello {seller_name},\n\nHere is your performance summary for {period}:\n\nTotal Sales: {total_sales}\nOrders: {order_count}\nAverage Rating: {avg_rating} stars\nResponse Rate: {response_rate}%\n\nTop Products:\n{top_products}\n\nView full report: {report_url}\n\nBest regards,\n{app_name} Team','[\"seller_name\",\"period\",\"total_sales\",\"order_count\",\"avg_rating\",\"response_rate\",\"top_products\",\"report_url\",\"app_name\"]',1,1,1,0,'low','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(61,'system_feature_update','system','New Feature Available','Sent when new features are added','New features on {app_name}!','Hello {customer_name},\n\nWe have exciting new features for you!\n\n{features_list}\n\nCheck them out: {features_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"features_list\",\"features_url\",\"app_name\"]',1,1,1,0,'low','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(62,'system_maintenance','system','Scheduled Maintenance','Sent before scheduled maintenance','Scheduled maintenance - {app_name}','Hello {customer_name},\n\nWe will be performing scheduled maintenance.\n\nStart: {maintenance_start}\nEnd: {maintenance_end}\nDuration: {duration}\n\nDuring this time, {affected_services} may be unavailable.\n\nWe apologize for any inconvenience.\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"maintenance_start\",\"maintenance_end\",\"duration\",\"affected_services\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(63,'system_downtime','system','Unplanned Downtime','Sent after unplanned downtime','Service interruption notice - {app_name}','Hello {customer_name},\n\nWe experienced an unplanned service interruption.\n\nOccurred: {downtime_start}\nRestored: {downtime_end}\nAffected Services: {affected_services}\n\nAll systems are now operational. We apologize for any inconvenience.\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"downtime_start\",\"downtime_end\",\"affected_services\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(64,'api_key_activity','system','API Key Activity','Sent when API key is used','API key activity detected - {app_name}','Hello {customer_name},\n\nActivity detected on your API key:\n\nAPI Key: {api_key_name}\nActivity: {activity_type}\nTimestamp: {activity_time}\nIP Address: {ip_address}\n\nManage API keys: {api_settings_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"api_key_name\",\"activity_type\",\"activity_time\",\"ip_address\",\"api_settings_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(65,'webhook_failure','system','Webhook Failure','Sent when webhook fails','Webhook failure - {app_name}','Hello {customer_name},\n\nA webhook failed to deliver.\n\nWebhook: {webhook_name}\nEndpoint: {webhook_url}\nFailed At: {failure_time}\nError: {error_message}\n\nAttempts: {attempt_count}/{max_attempts}\n\nCheck your webhook configuration: {webhook_settings_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"webhook_name\",\"webhook_url\",\"failure_time\",\"error_message\",\"attempt_count\",\"max_attempts\",\"webhook_settings_url\",\"app_name\"]',1,1,1,0,'high','2025-10-15 19:10:40','2025-10-15 19:10:40'),
(66,'app_connection_update','system','App Connection Update','Sent when connected app is updated','App connection updated - {app_name}','Hello {customer_name},\n\nA connected application has been updated.\n\nApp: {connected_app_name}\nUpdate Type: {update_type}\nTimestamp: {update_time}\n\nManage connections: {connections_url}\n\nBest regards,\n{app_name} Team','[\"customer_name\",\"connected_app_name\",\"update_type\",\"update_time\",\"connections_url\",\"app_name\"]',1,1,1,0,'normal','2025-10-15 19:10:40','2025-10-15 19:10:40');
/*!40000 ALTER TABLE `notification_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` enum('order','promotion','wishlist','account','system','vendor','live_shopping','security') NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `action_url` varchar(500) DEFAULT NULL,
  `action_text` varchar(100) DEFAULT NULL,
  `icon` varchar(50) DEFAULT NULL,
  `priority` enum('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `read_at` timestamp NULL DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `expires_at` timestamp NULL DEFAULT NULL,
  `sent_via_email` tinyint(1) NOT NULL DEFAULT 0,
  `sent_via_push` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_read_at` (`read_at`),
  KEY `idx_priority` (`priority`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `offers`
--

DROP TABLE IF EXISTS `offers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `offers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `offer_price` decimal(12,2) NOT NULL,
  `status` enum('pending','accepted','rejected','countered') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `offers_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `offers_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `offers`
--

LOCK TABLES `offers` WRITE;
/*!40000 ALTER TABLE `offers` DISABLE KEYS */;
/*!40000 ALTER TABLE `offers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_disputes`
--

DROP TABLE IF EXISTS `order_disputes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_disputes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `order_item_id` int(11) DEFAULT NULL,
  `buyer_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `dispute_type` enum('product_not_received','product_not_as_described','quality_issue','shipping_damage','refund_request','warranty_claim') NOT NULL,
  `dispute_reason` text NOT NULL,
  `buyer_evidence` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`buyer_evidence`)),
  `vendor_response` text DEFAULT NULL,
  `vendor_evidence` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`vendor_evidence`)),
  `admin_notes` text DEFAULT NULL,
  `status` enum('open','under_review','pending_buyer_response','pending_vendor_response','escalated','resolved','closed') NOT NULL DEFAULT 'open',
  `resolution` enum('refund_full','refund_partial','replacement','repair','no_action','favor_vendor','favor_buyer') DEFAULT NULL,
  `resolution_amount` decimal(10,2) DEFAULT NULL,
  `resolved_by` int(11) DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `escalated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_item_id` (`order_item_id`),
  KEY `idx_buyer_id` (`buyer_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_dispute_type` (`dispute_type`),
  KEY `idx_resolved_by` (`resolved_by`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_order_disputes_buyer` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_disputes_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_disputes_order_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_disputes_resolver` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_order_disputes_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_disputes`
--

LOCK TABLES `order_disputes` WRITE;
/*!40000 ALTER TABLE `order_disputes` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_disputes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `qty` int(11) NOT NULL DEFAULT 1,
  `price` decimal(10,2) NOT NULL,
  `price_minor` int(11) NOT NULL DEFAULT 0 COMMENT 'Price in minor currency units (cents)',
  `subtotal` decimal(10,2) NOT NULL,
  `subtotal_minor` int(11) NOT NULL DEFAULT 0 COMMENT 'Subtotal in minor currency units (cents)',
  `tax_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
  `status` enum('pending','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `tracking_number` varchar(100) DEFAULT NULL,
  `shipped_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_orders_vendor_status` (`vendor_id`,`status`),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_order_items_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES
(1,10,13,3,'AND1 Men\'s Socks, Cushion Quarter Socks, Stocking Stuffers, 12 Pack','V3-AND1-3B3A53',1,18.00,1800,18.00,1800,0.00,0.00,NULL,'pending',NULL,NULL,NULL,'2025-10-14 11:07:06','2025-10-14 11:07:06'),
(2,11,13,3,'AND1 Men\'s Socks, Cushion Quarter Socks, Stocking Stuffers, 12 Pack','V3-AND1-3B3A53',2,18.00,1800,36.00,3600,0.00,0.00,NULL,'pending',NULL,NULL,NULL,'2025-10-14 13:27:31','2025-10-14 13:27:31'),
(3,12,13,3,'AND1 Men\'s Socks, Cushion Quarter Socks, Stocking Stuffers, 12 Pack','V3-AND1-3B3A53',2,18.00,1800,36.00,3600,0.00,0.00,NULL,'pending',NULL,NULL,NULL,'2025-10-14 13:34:18','2025-10-14 13:34:18'),
(4,16,10,3,'Samsung Galaxy A14 5G Factory Unlocked - 64GB US Version Black - Excellent','V3-SAMS-086012',1,159.99,15999,159.99,15999,0.00,0.00,NULL,'pending',NULL,NULL,NULL,'2025-10-14 18:16:44','2025-10-14 18:16:44'),
(5,16,13,3,'AND1 Men\'s Socks, Cushion Quarter Socks, Stocking Stuffers, 12 Pack','V3-AND1-3B3A53',3,18.00,1800,54.00,5400,0.00,0.00,NULL,'pending',NULL,NULL,NULL,'2025-10-14 18:16:44','2025-10-14 18:16:44'),
(6,17,10,3,'Samsung Galaxy A14 5G Factory Unlocked - 64GB US Version Black - Excellent','V3-SAMS-086012',1,159.99,15999,159.99,15999,0.00,0.00,NULL,'pending',NULL,NULL,NULL,'2025-10-14 20:39:03','2025-10-14 20:39:03'),
(7,17,13,3,'AND1 Men\'s Socks, Cushion Quarter Socks, Stocking Stuffers, 12 Pack','V3-AND1-3B3A53',4,18.00,1800,72.00,7200,0.00,0.00,NULL,'pending',NULL,NULL,NULL,'2025-10-14 20:39:03','2025-10-14 20:39:03');
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_status_history`
--

DROP TABLE IF EXISTS `order_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_status_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `from_status` varchar(50) DEFAULT NULL,
  `to_status` varchar(50) NOT NULL,
  `reason` text DEFAULT NULL,
  `changed_by` int(11) NOT NULL,
  `notes` text DEFAULT NULL,
  `notify_customer` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_to_status` (`to_status`),
  KEY `idx_changed_by` (`changed_by`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_order_status_history_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_status_history_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_status_history`
--

LOCK TABLES `order_status_history` WRITE;
/*!40000 ALTER TABLE `order_status_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_status_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_status_logs`
--

DROP TABLE IF EXISTS `order_status_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_status_logs` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) NOT NULL,
  `changed_by` int(11) DEFAULT NULL,
  `change_reason` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_order_status_order` (`order_id`),
  KEY `idx_order_status_changed_by` (`changed_by`),
  KEY `idx_order_status_created` (`created_at`),
  CONSTRAINT `fk_order_status_logs_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_order_status_logs_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_status_logs`
--

LOCK TABLES `order_status_logs` WRITE;
/*!40000 ALTER TABLE `order_status_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_status_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_tracking`
--

DROP TABLE IF EXISTS `order_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_tracking` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `tracking_number` varchar(100) NOT NULL,
  `carrier` varchar(100) NOT NULL,
  `status` enum('label_created','picked_up','in_transit','out_for_delivery','delivered','exception','returned') NOT NULL DEFAULT 'label_created',
  `location` varchar(255) DEFAULT NULL,
  `estimated_delivery` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `tracking_events` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tracking_events`)),
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_order_tracking_order` (`order_id`),
  KEY `idx_order_tracking_number` (`tracking_number`),
  KEY `idx_order_tracking_status` (`status`),
  CONSTRAINT `fk_order_tracking_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_tracking`
--

LOCK TABLES `order_tracking` WRITE;
/*!40000 ALTER TABLE `order_tracking` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_tracking` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_tracking_updates`
--

DROP TABLE IF EXISTS `order_tracking_updates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_tracking_updates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `status` varchar(100) NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `order_tracking_updates_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_tracking_updates`
--

LOCK TABLES `order_tracking_updates` WRITE;
/*!40000 ALTER TABLE `order_tracking_updates` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_tracking_updates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `order_number` varchar(50) NOT NULL DEFAULT 'ORD0001',
  `status` enum('pending_payment','pending','processing','shipped','delivered','cancelled','refunded','failed') NOT NULL DEFAULT 'pending_payment',
  `payment_status` enum('pending','paid','failed','refunded','partial_refund') NOT NULL DEFAULT 'pending',
  `payment_method` varchar(50) DEFAULT NULL,
  `payment_transaction_id` varchar(255) DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL DEFAULT 0.00,
  `tax_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `shipping_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `coupon_id` int(11) DEFAULT NULL COMMENT 'Applied coupon ID',
  `coupon_code` varchar(50) DEFAULT NULL COMMENT 'Applied coupon code',
  `gift_card_id` int(11) DEFAULT NULL COMMENT 'Applied gift card ID',
  `gift_card_code` varchar(50) DEFAULT NULL COMMENT 'Applied gift card code',
  `gift_card_amount` decimal(10,2) DEFAULT 0.00 COMMENT 'Gift card amount applied',
  `total` decimal(10,2) NOT NULL DEFAULT 0.00,
  `currency` varchar(3) NOT NULL DEFAULT 'USD',
  `billing_address` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `shipping_address` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `shipping_method` varchar(100) DEFAULT NULL,
  `tracking_number` varchar(100) DEFAULT NULL,
  `carrier` varchar(100) DEFAULT NULL,
  `tracking_url` varchar(500) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `admin_notes` text DEFAULT NULL,
  `shipped_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `refunded_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `order_reference` varchar(50) DEFAULT NULL COMMENT 'Human-readable order reference (ORD-YYYYMMDD-######)',
  `amount_minor` int(11) NOT NULL DEFAULT 0 COMMENT 'Total amount in minor units (cents)',
  `tax_minor` int(11) NOT NULL DEFAULT 0 COMMENT 'Tax amount in minor units',
  `shipping_minor` int(11) NOT NULL DEFAULT 0 COMMENT 'Shipping amount in minor units',
  `stripe_payment_intent_id` varchar(255) DEFAULT NULL,
  `stripe_customer_id` varchar(255) DEFAULT NULL,
  `customer_email` varchar(255) DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `placed_at` timestamp NULL DEFAULT NULL COMMENT 'When order was placed/paid',
  `stripe_checkout_session_id` varchar(255) DEFAULT NULL COMMENT 'Stripe Checkout Session ID (cs_...)',
  `courier` varchar(100) DEFAULT NULL,
  `expected_delivery` date DEFAULT NULL,
  `currency_code` varchar(3) NOT NULL DEFAULT 'USD',
  `subtotal_amount` decimal(10,2) DEFAULT 0.00,
  `total_amount` decimal(10,2) DEFAULT 0.00,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_order_number` (`order_number`),
  UNIQUE KEY `order_reference` (`order_reference`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_payment_transaction_id` (`payment_transaction_id`),
  KEY `idx_orders_status_created` (`status`,`created_at`),
  KEY `idx_tracking_number` (`tracking_number`),
  KEY `idx_order_reference` (`order_reference`),
  KEY `idx_stripe_payment_intent` (`stripe_payment_intent_id`),
  KEY `idx_stripe_customer` (`stripe_customer_id`),
  KEY `idx_customer_email` (`customer_email`),
  KEY `idx_stripe_checkout_session` (`stripe_checkout_session_id`),
  KEY `idx_user_status` (`user_id`,`status`),
  KEY `idx_coupon_id` (`coupon_id`),
  KEY `idx_gift_card_id` (`gift_card_id`),
  KEY `idx_orders_placed_at_status` (`placed_at`,`status`),
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES
(10,4,'ORD-20251014-A39CF4','pending_payment','pending',NULL,NULL,18.00,1.44,5.99,0.00,NULL,NULL,NULL,NULL,0.00,25.43,'USD','{\"name\":\"JOSEPH NIYOGUSHIMWA\",\"email\":\"ellyj164@gmail.com\",\"phone\":\"+250 788827138\",\"address\":{\"line1\":\"KIGALI\",\"line2\":\"RWANDA\",\"city\":\"KIGALI\",\"state\":\"KIGALI\",\"postal_code\":\"0000\",\"country\":\"US\"}}','{\"name\":\"JOSEPH NIYOGUSHIMWA\",\"phone\":\"+250 788827138\",\"address\":{\"line1\":\"KIGALI\",\"line2\":\"RWANDA\",\"city\":\"KIGALI\",\"state\":\"KIGALI\",\"postal_code\":\"0000\",\"country\":\"US\"}}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-10-14 11:07:06','2025-10-14 14:29:57','ORD-20251014-000010',2543,144,599,NULL,NULL,'ellyj164@gmail.com','Joseph','2025-10-14 11:07:06',NULL,NULL,NULL,'USD',0.00,0.00),
(11,4,'ORD-20251014-391A64','pending_payment','pending',NULL,NULL,36.00,2.88,5.99,0.00,NULL,NULL,NULL,NULL,0.00,44.87,'USD','{\"name\":\"JOSEPH NIYOGUSHIMWA\",\"email\":\"ellyj164@gmail.com\",\"phone\":\"+250 788827138\",\"address\":{\"line1\":\"KIGALI\",\"line2\":\"RWANDA\",\"city\":\"KIGALI\",\"state\":\"KIGALI\",\"postal_code\":\"0000\",\"country\":\"US\"}}','{\"name\":\"JOSEPH NIYOGUSHIMWA\",\"phone\":\"+250 788827138\",\"address\":{\"line1\":\"KIGALI\",\"line2\":\"RWANDA\",\"city\":\"KIGALI\",\"state\":\"KIGALI\",\"postal_code\":\"0000\",\"country\":\"US\"}}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-10-14 13:27:31','2025-10-14 14:29:57','ORD-20251014-000011',4487,288,599,NULL,NULL,'ellyj164@gmail.com','Joseph','2025-10-14 13:27:31',NULL,NULL,NULL,'USD',0.00,0.00),
(12,4,'ORD-20251014-A2B867','pending_payment','pending',NULL,NULL,36.00,2.88,5.99,0.00,NULL,NULL,NULL,NULL,0.00,44.87,'USD','{\"name\":\"JOSEPH NIYOGUSHIMWA\",\"email\":\"ellyj164@gmail.com\",\"phone\":\"+250 788827138\",\"address\":{\"line1\":\"KIGALI\",\"line2\":\"RWANDA\",\"city\":\"KIGALI\",\"state\":\"KIGALI\",\"postal_code\":\"0000\",\"country\":\"US\"}}','{\"name\":\"JOSEPH NIYOGUSHIMWA\",\"phone\":\"+250 788827138\",\"address\":{\"line1\":\"KIGALI\",\"line2\":\"RWANDA\",\"city\":\"KIGALI\",\"state\":\"KIGALI\",\"postal_code\":\"0000\",\"country\":\"US\"}}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-10-14 13:34:18','2025-10-14 14:29:57','ORD-20251014-000012',4487,288,599,NULL,NULL,'ellyj164@gmail.com','Joseph','2025-10-14 13:34:18',NULL,NULL,NULL,'USD',0.00,0.00),
(14,1,'ORD0002','pending_payment','pending',NULL,NULL,100.00,0.00,0.00,0.00,NULL,NULL,NULL,NULL,0.00,100.00,'USD',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-10-14 15:34:01','2025-10-14 15:34:01',NULL,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'USD',0.00,0.00),
(15,1,'ORD0001','pending_payment','pending',NULL,NULL,100.00,0.00,0.00,0.00,NULL,NULL,NULL,NULL,0.00,100.00,'USD',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-10-14 15:34:42','2025-10-14 15:34:42',NULL,0,0,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'USD',0.00,0.00),
(16,4,'ORD-20251014-CA743B','pending_payment','pending',NULL,NULL,2824.67,225.97,79.07,0.00,NULL,NULL,NULL,NULL,0.00,3129.71,'RWF','{\"name\":\"JOSEPH NIYOGUSHIMWA\",\"email\":\"ellyj164@gmail.com\",\"phone\":\"0788 827 138\",\"address\":{\"line1\":\"KIGALI\",\"line2\":\"RWANDA\",\"city\":\"KIGALI\",\"state\":\"KIGALI\",\"postal_code\":\"0000\",\"country\":\"RW\"}}','{\"name\":\"JOSEPH NIYOGUSHIMWA\",\"phone\":\"0788 827 138\",\"address\":{\"line1\":\"KIGALI\",\"line2\":\"RWANDA\",\"city\":\"KIGALI\",\"state\":\"KIGALI\",\"postal_code\":\"0000\",\"country\":\"RW\"}}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-10-14 18:16:44','2025-10-14 18:16:44','ORD-20251014-000016',312971,22597,7907,NULL,NULL,'ellyj164@gmail.com','Joseph',NULL,NULL,NULL,NULL,'USD',0.00,0.00),
(17,4,'ORD-20251014-78EB74','cancelled','pending',NULL,NULL,3062.27,244.98,79.07,0.00,NULL,NULL,NULL,NULL,0.00,3386.32,'RWF','{\"name\":\"JOSEPH NIYOGUSHIMWA\",\"email\":\"ellyj164@gmail.com\",\"phone\":\"+250 788827138\",\"address\":{\"line1\":\"KIGALI\",\"line2\":\"RWANDA\",\"city\":\"KIGALI\",\"state\":\"KIGALI\",\"postal_code\":\"0000\",\"country\":\"RW\"}}','{\"name\":\"JOSEPH NIYOGUSHIMWA\",\"phone\":\"+250 788827138\",\"address\":{\"line1\":\"KIGALI\",\"line2\":\"RWANDA\",\"city\":\"KIGALI\",\"state\":\"KIGALI\",\"postal_code\":\"0000\",\"country\":\"RW\"}}',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-10-14 20:39:03','2025-10-15 09:04:40','ORD-20251014-000017',338632,24498,7907,NULL,NULL,'ellyj164@gmail.com','Joseph',NULL,NULL,NULL,NULL,'USD',0.00,0.00);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`fezamarket`@`localhost`*/ /*!50003 TRIGGER before_insert_orders
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_number IS NULL THEN
        SET NEW.order_number = CONCAT('ORD', LPAD(IFNULL((SELECT MAX(id) + 1 FROM orders), 1), 6, '0'));
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `otp_attempts`
--

DROP TABLE IF EXISTS `otp_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `otp_attempts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `attempted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `success` tinyint(1) NOT NULL DEFAULT 0,
  `token_type` enum('email_verification','password_reset','email_change','two_fa_backup') NOT NULL DEFAULT 'email_verification',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_email` (`email`),
  KEY `idx_ip_address` (`ip_address`),
  KEY `idx_attempted_at` (`attempted_at`),
  KEY `idx_token_type` (`token_type`),
  CONSTRAINT `fk_otp_attempts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otp_attempts`
--

LOCK TABLES `otp_attempts` WRITE;
/*!40000 ALTER TABLE `otp_attempts` DISABLE KEYS */;
/*!40000 ALTER TABLE `otp_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_events`
--

DROP TABLE IF EXISTS `payment_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `payment_id` int(11) NOT NULL,
  `event_type` enum('created','processed','completed','failed','refunded','disputed','settled') NOT NULL,
  `event_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`event_data`)),
  `gateway_event_id` varchar(255) DEFAULT NULL,
  `webhook_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`webhook_data`)),
  `processed` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_payment_id` (`payment_id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_gateway_event_id` (`gateway_event_id`),
  KEY `idx_processed` (`processed`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_payment_events_payment` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_events`
--

LOCK TABLES `payment_events` WRITE;
/*!40000 ALTER TABLE `payment_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_gateways`
--

DROP TABLE IF EXISTS `payment_gateways`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_gateways` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `provider` enum('stripe','paypal','square','authorize_net','braintree','razorpay','custom') NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 0,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `supported_currencies` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`supported_currencies`)),
  `supported_countries` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`supported_countries`)),
  `configuration` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`configuration`)),
  `test_mode` tinyint(1) NOT NULL DEFAULT 1,
  `transaction_fee_percentage` decimal(5,4) NOT NULL DEFAULT 0.0000,
  `transaction_fee_fixed` decimal(10,2) NOT NULL DEFAULT 0.00,
  `min_amount` decimal(10,2) NOT NULL DEFAULT 0.01,
  `max_amount` decimal(10,2) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_slug` (`slug`),
  KEY `idx_provider` (`provider`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_is_default` (`is_default`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_gateways`
--

LOCK TABLES `payment_gateways` WRITE;
/*!40000 ALTER TABLE `payment_gateways` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_gateways` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` enum('credit_card','debit_card','paypal','bank_transfer','wallet') NOT NULL,
  `provider` varchar(50) DEFAULT NULL,
  `last_four` varchar(4) DEFAULT NULL,
  `exp_month` tinyint(2) DEFAULT NULL,
  `exp_year` smallint(4) DEFAULT NULL,
  `cardholder_name` varchar(100) DEFAULT NULL,
  `brand` varchar(20) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `fingerprint` varchar(255) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_is_default` (`is_default`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_payment_methods_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_reconciliations`
--

DROP TABLE IF EXISTS `payment_reconciliations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_reconciliations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `reconciled_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_reconciled_by_user` (`reconciled_by`),
  CONSTRAINT `fk_reconciled_by_user` FOREIGN KEY (`reconciled_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_reconciliations`
--

LOCK TABLES `payment_reconciliations` WRITE;
/*!40000 ALTER TABLE `payment_reconciliations` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_reconciliations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_tokens`
--

DROP TABLE IF EXISTS `payment_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL COMMENT 'Tokenized payment method identifier',
  `gateway` enum('stripe','paypal','flutterwave','mobile_momo','mock') NOT NULL DEFAULT 'stripe' COMMENT 'Payment gateway provider',
  `type` enum('card','bank_account','paypal','mobile_money','crypto') NOT NULL DEFAULT 'card' COMMENT 'Payment method type',
  `last_four` varchar(4) DEFAULT NULL COMMENT 'Last 4 digits for cards',
  `brand` varchar(50) DEFAULT NULL COMMENT 'Card brand or payment method brand',
  `exp_month` tinyint(2) DEFAULT NULL COMMENT 'Card expiration month',
  `exp_year` smallint(4) DEFAULT NULL COMMENT 'Card expiration year',
  `holder_name` varchar(100) DEFAULT NULL COMMENT 'Cardholder or account holder name',
  `is_default` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Default payment method for user',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Active status of the token',
  `metadata` text DEFAULT NULL COMMENT 'Additional payment method data (e.g., JSON)',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id_idx` (`user_id`),
  CONSTRAINT `fk_payment_tokens_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_tokens`
--

LOCK TABLES `payment_tokens` WRITE;
/*!40000 ALTER TABLE `payment_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `payment_method` varchar(50) NOT NULL,
  `gateway` varchar(50) NOT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `gateway_transaction_id` varchar(255) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'USD',
  `status` enum('pending','processing','completed','failed','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `gateway_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`gateway_response`)),
  `fees` decimal(10,2) NOT NULL DEFAULT 0.00,
  `net_amount` decimal(10,2) NOT NULL,
  `processed_at` timestamp NULL DEFAULT NULL,
  `refunded_at` timestamp NULL DEFAULT NULL,
  `refund_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_gateway_transaction_id` (`gateway_transaction_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_payments_status_gateway` (`status`,`gateway`,`created_at`),
  CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_payments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_payments_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payout_requests`
--

DROP TABLE IF EXISTS `payout_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payout_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `wallet_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `request_amount` decimal(10,2) NOT NULL,
  `processing_fee` decimal(10,2) NOT NULL DEFAULT 0.00,
  `final_amount` decimal(10,2) NOT NULL,
  `payout_method` enum('bank_transfer','paypal','stripe','wise','check','manual') NOT NULL,
  `payout_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`payout_details`)),
  `status` enum('pending','approved','processing','completed','failed','cancelled') NOT NULL DEFAULT 'pending',
  `approval_notes` text DEFAULT NULL,
  `failure_reason` text DEFAULT NULL,
  `external_transaction_id` varchar(255) DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `processed_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_wallet_id` (`wallet_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_payout_method` (`payout_method`),
  KEY `idx_processed_by` (`processed_by`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_payout_requests_processor` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_payout_requests_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_payout_requests_wallet` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payout_requests`
--

LOCK TABLES `payout_requests` WRITE;
/*!40000 ALTER TABLE `payout_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `payout_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payouts`
--

DROP TABLE IF EXISTS `payouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payouts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `payout_request_id` int(11) NOT NULL,
  `batch_id` varchar(100) DEFAULT NULL,
  `gateway_payout_id` varchar(255) DEFAULT NULL,
  `gateway_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`gateway_response`)),
  `fees_charged` decimal(10,2) NOT NULL DEFAULT 0.00,
  `exchange_rate` decimal(10,6) DEFAULT NULL,
  `final_amount` decimal(10,2) NOT NULL,
  `final_currency` varchar(3) NOT NULL DEFAULT 'USD',
  `status` enum('initiated','processing','completed','failed','returned') NOT NULL DEFAULT 'initiated',
  `tracking_reference` varchar(255) DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_payout_request_id` (`payout_request_id`),
  KEY `idx_batch_id` (`batch_id`),
  KEY `idx_gateway_payout_id` (`gateway_payout_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_payouts_request` FOREIGN KEY (`payout_request_id`) REFERENCES `payout_requests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payouts`
--

LOCK TABLES `payouts` WRITE;
/*!40000 ALTER TABLE `payouts` DISABLE KEYS */;
/*!40000 ALTER TABLE `payouts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_permission_name` (`name`),
  KEY `idx_permission_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform_notification_reads`
--

DROP TABLE IF EXISTS `platform_notification_reads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `platform_notification_reads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `read_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `clicked_at` timestamp NULL DEFAULT NULL,
  `dismissed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_notification_user` (`notification_id`,`user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_read_at` (`read_at`),
  CONSTRAINT `fk_platform_notification_reads_notification` FOREIGN KEY (`notification_id`) REFERENCES `platform_notifications` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_platform_notification_reads_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_notification_reads`
--

LOCK TABLES `platform_notification_reads` WRITE;
/*!40000 ALTER TABLE `platform_notification_reads` DISABLE KEYS */;
/*!40000 ALTER TABLE `platform_notification_reads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform_notifications`
--

DROP TABLE IF EXISTS `platform_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `platform_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('announcement','maintenance','promotion','warning','info') NOT NULL DEFAULT 'info',
  `priority` enum('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `target_audience` enum('all','customers','vendors','admins') NOT NULL DEFAULT 'all',
  `icon` varchar(50) DEFAULT NULL,
  `color` varchar(7) DEFAULT '#007bff',
  `action_url` varchar(500) DEFAULT NULL,
  `action_text` varchar(100) DEFAULT NULL,
  `is_dismissible` tinyint(1) NOT NULL DEFAULT 1,
  `auto_dismiss_after` int(11) DEFAULT NULL COMMENT 'Auto dismiss after X seconds',
  `status` enum('draft','active','paused','expired') NOT NULL DEFAULT 'draft',
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `total_sent` int(11) NOT NULL DEFAULT 0,
  `total_read` int(11) NOT NULL DEFAULT 0,
  `total_clicked` int(11) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_type` (`type`),
  KEY `idx_priority` (`priority`),
  KEY `idx_target_audience` (`target_audience`),
  KEY `idx_start_date` (`start_date`),
  KEY `idx_end_date` (`end_date`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_platform_notifications_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_notifications`
--

LOCK TABLES `platform_notifications` WRITE;
/*!40000 ALTER TABLE `platform_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `platform_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_analytics`
--

DROP TABLE IF EXISTS `product_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_analytics` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `metric_date` date NOT NULL,
  `views` int(11) NOT NULL DEFAULT 0,
  `clicks` int(11) NOT NULL DEFAULT 0,
  `conversions` int(11) NOT NULL DEFAULT 0,
  `revenue` decimal(15,2) NOT NULL DEFAULT 0.00,
  `profit_margin` decimal(5,2) DEFAULT NULL,
  `competitor_price` decimal(10,2) DEFAULT NULL,
  `search_ranking` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_analytics_product_date` (`product_id`,`metric_date`),
  CONSTRAINT `fk_product_analytics_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_analytics`
--

LOCK TABLES `product_analytics` WRITE;
/*!40000 ALTER TABLE `product_analytics` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_approvals`
--

DROP TABLE IF EXISTS `product_approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_approvals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `status` enum('pending','approved','rejected','revision_requested') NOT NULL DEFAULT 'pending',
  `reviewed_by` int(11) DEFAULT NULL,
  `review_notes` text DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejected_at` timestamp NULL DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_product_id` (`product_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_reviewed_by` (`reviewed_by`),
  KEY `idx_submitted_at` (`submitted_at`),
  CONSTRAINT `fk_product_approvals_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_approvals_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_product_approvals_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_approvals`
--

LOCK TABLES `product_approvals` WRITE;
/*!40000 ALTER TABLE `product_approvals` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_approvals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_attributes`
--

DROP TABLE IF EXISTS `product_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_attributes` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `value` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `attr_key` varchar(100) DEFAULT NULL,
  `attr_value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_product_attributes_product_id` (`product_id`),
  CONSTRAINT `fk_attributes_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_attributes`
--

LOCK TABLES `product_attributes` WRITE;
/*!40000 ALTER TABLE `product_attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_audit_logs`
--

DROP TABLE IF EXISTS `product_audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action` varchar(255) NOT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `reason` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_product_audit_logs_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_audit_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_audit_logs`
--

LOCK TABLES `product_audit_logs` WRITE;
/*!40000 ALTER TABLE `product_audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_autosaves`
--

DROP TABLE IF EXISTS `product_autosaves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_autosaves` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller_id` int(10) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `slug` varchar(275) DEFAULT NULL,
  `short_description` varchar(500) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `brand` varchar(160) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `compare_price` decimal(10,2) DEFAULT NULL,
  `cost_price` decimal(10,2) DEFAULT NULL,
  `currency_code` char(3) DEFAULT 'USD',
  `stock_qty` int(11) DEFAULT NULL,
  `low_stock_threshold` int(11) DEFAULT NULL,
  `track_inventory` tinyint(1) DEFAULT 1,
  `allow_backorder` tinyint(1) DEFAULT 0,
  `condition` enum('new','used','refurbished') DEFAULT 'new',
  `tags` text DEFAULT NULL,
  `weight_kg` decimal(10,3) DEFAULT NULL,
  `length_cm` decimal(10,2) DEFAULT NULL,
  `width_cm` decimal(10,2) DEFAULT NULL,
  `height_cm` decimal(10,2) DEFAULT NULL,
  `seo_title` varchar(70) DEFAULT NULL,
  `seo_description` varchar(170) DEFAULT NULL,
  `seo_keywords` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_seller_id` (`seller_id`),
  KEY `idx_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_autosaves`
--

LOCK TABLES `product_autosaves` WRITE;
/*!40000 ALTER TABLE `product_autosaves` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_autosaves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_bulk_operations`
--

DROP TABLE IF EXISTS `product_bulk_operations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_bulk_operations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `operation_type` varchar(20) NOT NULL COMMENT 'import | export | update | delete',
  `file_path` varchar(500) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending' COMMENT 'pending | processing | completed | failed',
  `total_records` int(11) NOT NULL DEFAULT 0,
  `processed_records` int(11) NOT NULL DEFAULT 0,
  `error_records` int(11) NOT NULL DEFAULT 0,
  `error_log` text DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_bulk_ops_user_id` (`user_id`),
  CONSTRAINT `fk_product_bulk_ops_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_bulk_operations`
--

LOCK TABLES `product_bulk_operations` WRITE;
/*!40000 ALTER TABLE `product_bulk_operations` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_bulk_operations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_bulk_uploads`
--

DROP TABLE IF EXISTS `product_bulk_uploads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_bulk_uploads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `total_rows` int(11) NOT NULL DEFAULT 0,
  `processed_rows` int(11) NOT NULL DEFAULT 0,
  `successful_rows` int(11) NOT NULL DEFAULT 0,
  `failed_rows` int(11) NOT NULL DEFAULT 0,
  `status` enum('pending','processing','completed','failed','cancelled') NOT NULL DEFAULT 'pending',
  `error_log` longtext DEFAULT NULL,
  `file_path` varchar(500) DEFAULT NULL,
  `processing_started_at` timestamp NULL DEFAULT NULL,
  `processing_completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_product_bulk_uploads_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_bulk_uploads`
--

LOCK TABLES `product_bulk_uploads` WRITE;
/*!40000 ALTER TABLE `product_bulk_uploads` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_bulk_uploads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_categories`
--

DROP TABLE IF EXISTS `product_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_categories` (
  `product_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`product_id`,`category_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_pc_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pc_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_categories`
--

LOCK TABLES `product_categories` WRITE;
/*!40000 ALTER TABLE `product_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_certificates`
--

DROP TABLE IF EXISTS `product_certificates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_certificates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `certificate_type` varchar(100) DEFAULT NULL,
  `certificate_name` varchar(255) DEFAULT NULL,
  `file_path` varchar(500) DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `issuing_authority` varchar(255) DEFAULT NULL,
  `certificate_number` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_certificates_product_id` (`product_id`),
  CONSTRAINT `fk_product_certificates_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_certificates`
--

LOCK TABLES `product_certificates` WRITE;
/*!40000 ALTER TABLE `product_certificates` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_certificates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_drafts`
--

DROP TABLE IF EXISTS `product_drafts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_drafts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `draft_name` varchar(255) DEFAULT NULL,
  `product_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`product_data`)),
  `auto_save` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_drafts_user_id` (`user_id`),
  CONSTRAINT `fk_product_drafts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_drafts`
--

LOCK TABLES `product_drafts` WRITE;
/*!40000 ALTER TABLE `product_drafts` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_drafts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_files`
--

DROP TABLE IF EXISTS `product_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_size` bigint(20) DEFAULT NULL,
  `download_count` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_files`
--

LOCK TABLES `product_files` WRITE;
/*!40000 ALTER TABLE `product_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_images`
--

DROP TABLE IF EXISTS `product_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `alt_text` varchar(255) DEFAULT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `file_path` varchar(500) DEFAULT NULL,
  `sort` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_product_images_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_images`
--

LOCK TABLES `product_images` WRITE;
/*!40000 ALTER TABLE `product_images` DISABLE KEYS */;
INSERT INTO `product_images` VALUES
(9,5,'/uploads/products/2025/10/img_1759572748_48954b57dc882d4c.jpg',NULL,1,'2025-10-04 10:12:28','2025-10-04 10:12:28','/uploads/products/2025/10/img_1759572748_48954b57dc882d4c.jpg',0),
(10,5,'/uploads/products/2025/10/img_1759572748_5f2ca0fe2875d7d7.jpg',NULL,0,'2025-10-04 10:12:28','2025-10-04 10:12:28','/uploads/products/2025/10/img_1759572748_5f2ca0fe2875d7d7.jpg',0),
(11,5,'/uploads/products/2025/10/img_1759572748_3647b7c6a5f60b30.jpg',NULL,0,'2025-10-04 10:12:28','2025-10-04 10:12:28','/uploads/products/2025/10/img_1759572748_3647b7c6a5f60b30.jpg',0),
(12,6,'/uploads/products/2025/10/img_1759573981_502b782b6f37f2ac.jpg',NULL,1,'2025-10-04 10:33:01','2025-10-04 10:33:01','/uploads/products/2025/10/img_1759573981_502b782b6f37f2ac.jpg',0),
(13,6,'/uploads/products/2025/10/img_1759573981_df60ec347386bb3d.webp',NULL,0,'2025-10-04 10:33:01','2025-10-04 10:33:01','/uploads/products/2025/10/img_1759573981_df60ec347386bb3d.webp',0),
(14,6,'/uploads/products/2025/10/img_1759573981_418c63c7d04cb91c.jpg',NULL,0,'2025-10-04 10:33:01','2025-10-04 10:33:01','/uploads/products/2025/10/img_1759573981_418c63c7d04cb91c.jpg',0),
(15,6,'/uploads/products/2025/10/img_1759573981_6c6205d2d6cbe659.jpg',NULL,0,'2025-10-04 10:33:01','2025-10-04 10:33:01','/uploads/products/2025/10/img_1759573981_6c6205d2d6cbe659.jpg',0),
(16,7,'/uploads/products/2025/10/img_1760190165_9b46e9753ff38874.webp',NULL,1,'2025-10-11 13:42:45','2025-10-11 13:42:45','/uploads/products/2025/10/img_1760190165_9b46e9753ff38874.webp',0),
(17,7,'/uploads/products/2025/10/img_1760190165_7cfa5a06d46e6653.webp',NULL,0,'2025-10-11 13:42:45','2025-10-11 13:42:45','/uploads/products/2025/10/img_1760190165_7cfa5a06d46e6653.webp',0),
(18,7,'/uploads/products/2025/10/img_1760190165_4057463e6a1ea4ab.webp',NULL,0,'2025-10-11 13:42:45','2025-10-11 13:42:45','/uploads/products/2025/10/img_1760190165_4057463e6a1ea4ab.webp',0),
(19,7,'/uploads/products/2025/10/img_1760190165_65090851ade11909.webp',NULL,0,'2025-10-11 13:42:45','2025-10-11 13:42:45','/uploads/products/2025/10/img_1760190165_65090851ade11909.webp',0),
(20,7,'/uploads/products/2025/10/img_1760190165_93756695ec08e7f5.webp',NULL,0,'2025-10-11 13:42:45','2025-10-11 13:42:45','/uploads/products/2025/10/img_1760190165_93756695ec08e7f5.webp',0),
(21,7,'/uploads/products/2025/10/img_1760190165_816939d1f126137a.webp',NULL,0,'2025-10-11 13:42:45','2025-10-11 13:42:45','/uploads/products/2025/10/img_1760190165_816939d1f126137a.webp',0),
(22,7,'/uploads/products/2025/10/img_1760190165_7768a8e92fb1f58e.webp',NULL,0,'2025-10-11 13:42:45','2025-10-11 13:42:45','/uploads/products/2025/10/img_1760190165_7768a8e92fb1f58e.webp',0),
(23,8,'/uploads/products/2025/10/img_1760190504_012f6b5a99bd873c.webp',NULL,1,'2025-10-11 13:48:24','2025-10-11 13:48:24','/uploads/products/2025/10/img_1760190504_012f6b5a99bd873c.webp',0),
(24,8,'/uploads/products/2025/10/img_1760190504_2f0ca4e85be5a13a.webp',NULL,0,'2025-10-11 13:48:24','2025-10-11 13:48:24','/uploads/products/2025/10/img_1760190504_2f0ca4e85be5a13a.webp',0),
(25,8,'/uploads/products/2025/10/img_1760190504_1c2ea669391637b4.webp',NULL,0,'2025-10-11 13:48:24','2025-10-11 13:48:24','/uploads/products/2025/10/img_1760190504_1c2ea669391637b4.webp',0),
(26,8,'/uploads/products/2025/10/img_1760190504_4aa3b90f9adfc3d7.webp',NULL,0,'2025-10-11 13:48:24','2025-10-11 13:48:24','/uploads/products/2025/10/img_1760190504_4aa3b90f9adfc3d7.webp',0),
(27,8,'/uploads/products/2025/10/img_1760190504_9d965ae18dfd5c5a.webp',NULL,0,'2025-10-11 13:48:24','2025-10-11 13:48:24','/uploads/products/2025/10/img_1760190504_9d965ae18dfd5c5a.webp',0),
(28,8,'/uploads/products/2025/10/img_1760190504_fb4a027a7aab8bb4.webp',NULL,0,'2025-10-11 13:48:24','2025-10-11 13:48:24','/uploads/products/2025/10/img_1760190504_fb4a027a7aab8bb4.webp',0),
(29,8,'/uploads/products/2025/10/img_1760190504_7d656b0a65c2b4d2.webp',NULL,0,'2025-10-11 13:48:24','2025-10-11 13:48:24','/uploads/products/2025/10/img_1760190504_7d656b0a65c2b4d2.webp',0),
(30,9,'/uploads/products/2025/10/img_1760198504_a84bd543eb0e78e5.webp',NULL,1,'2025-10-11 16:01:44','2025-10-11 16:01:44','/uploads/products/2025/10/img_1760198504_a84bd543eb0e78e5.webp',0),
(31,9,'/uploads/products/2025/10/img_1760198504_440cad849bac47da.webp',NULL,0,'2025-10-11 16:01:44','2025-10-11 16:01:44','/uploads/products/2025/10/img_1760198504_440cad849bac47da.webp',0),
(32,9,'/uploads/products/2025/10/img_1760198504_f8d37c81b31d6207.webp',NULL,0,'2025-10-11 16:01:44','2025-10-11 16:01:44','/uploads/products/2025/10/img_1760198504_f8d37c81b31d6207.webp',0),
(33,9,'/uploads/products/2025/10/img_1760198504_85abc18a58a8d124.webp',NULL,0,'2025-10-11 16:01:44','2025-10-11 16:01:44','/uploads/products/2025/10/img_1760198504_85abc18a58a8d124.webp',0),
(34,10,'/uploads/products/2025/10/img_1760216888_b22857a24f31d033.webp',NULL,1,'2025-10-11 21:08:08','2025-10-11 21:08:08','/uploads/products/2025/10/img_1760216888_b22857a24f31d033.webp',0),
(35,10,'/uploads/products/2025/10/img_1760216888_731ace658d92dfa1.webp',NULL,0,'2025-10-11 21:08:08','2025-10-11 21:08:08','/uploads/products/2025/10/img_1760216888_731ace658d92dfa1.webp',0),
(36,10,'/uploads/products/2025/10/img_1760216888_d7f728c944869fcb.webp',NULL,0,'2025-10-11 21:08:08','2025-10-11 21:08:08','/uploads/products/2025/10/img_1760216888_d7f728c944869fcb.webp',0),
(37,10,'/uploads/products/2025/10/img_1760216888_ecc607d7fa135035.webp',NULL,0,'2025-10-11 21:08:08','2025-10-11 21:08:08','/uploads/products/2025/10/img_1760216888_ecc607d7fa135035.webp',0),
(38,10,'/uploads/products/2025/10/img_1760216888_061858d7d035be5d.webp',NULL,0,'2025-10-11 21:08:08','2025-10-11 21:08:08','/uploads/products/2025/10/img_1760216888_061858d7d035be5d.webp',0);
/*!40000 ALTER TABLE `product_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_inquiry_messages`
--

DROP TABLE IF EXISTS `product_inquiry_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_inquiry_messages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `thread_id` bigint(20) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `sender_role` enum('buyer','seller','admin') NOT NULL,
  `message_text` text NOT NULL,
  `attachment_path` varchar(500) DEFAULT NULL,
  `attachment_type` varchar(50) DEFAULT NULL,
  `attachment_size` int(11) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `flagged` tinyint(1) DEFAULT 0,
  `flagged_reason` text DEFAULT NULL,
  `flagged_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_thread_id` (`thread_id`),
  KEY `idx_sender_id` (`sender_id`),
  KEY `idx_receiver_id` (`receiver_id`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_flagged` (`flagged`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `product_inquiry_messages_ibfk_1` FOREIGN KEY (`thread_id`) REFERENCES `conversation_threads` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_inquiry_messages`
--

LOCK TABLES `product_inquiry_messages` WRITE;
/*!40000 ALTER TABLE `product_inquiry_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_inquiry_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_inventory`
--

DROP TABLE IF EXISTS `product_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_inventory` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `stock_quantity` int(11) NOT NULL DEFAULT 0,
  `reserved_quantity` int(11) NOT NULL DEFAULT 0,
  `low_stock_threshold` int(11) NOT NULL DEFAULT 5,
  `out_of_stock_threshold` int(11) NOT NULL DEFAULT 0,
  `backorder_limit` int(11) DEFAULT NULL,
  `reorder_point` int(11) DEFAULT NULL,
  `reorder_quantity` int(11) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_inventory_product_id` (`product_id`),
  KEY `idx_product_inventory_sku` (`sku`),
  CONSTRAINT `fk_product_inventory_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_inventory`
--

LOCK TABLES `product_inventory` WRITE;
/*!40000 ALTER TABLE `product_inventory` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_media`
--

DROP TABLE IF EXISTS `product_media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_media` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `media_type` varchar(20) NOT NULL DEFAULT 'image' COMMENT 'image | video | 360_image',
  `file_path` varchar(500) DEFAULT NULL,
  `thumbnail_path` varchar(500) DEFAULT NULL,
  `alt_text` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `youtube_url` varchar(500) DEFAULT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT 0,
  `is_thumbnail` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(11) DEFAULT 0,
  `file_size` int(11) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_media_product_id` (`product_id`),
  KEY `idx_product_media_type` (`media_type`),
  CONSTRAINT `fk_product_media_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_media`
--

LOCK TABLES `product_media` WRITE;
/*!40000 ALTER TABLE `product_media` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_media` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_offers`
--

DROP TABLE IF EXISTS `product_offers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_offers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `offer_price` decimal(10,2) NOT NULL,
  `message` text DEFAULT NULL,
  `status` enum('pending','approved','countered','declined','expired') NOT NULL DEFAULT 'pending',
  `counter_price` decimal(10,2) DEFAULT NULL,
  `admin_message` text DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `processed_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_processed_by` (`processed_by`),
  CONSTRAINT `product_offers_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `product_offers_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_offers`
--

LOCK TABLES `product_offers` WRITE;
/*!40000 ALTER TABLE `product_offers` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_offers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_pricing`
--

DROP TABLE IF EXISTS `product_pricing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_pricing` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `sale_price` decimal(10,2) DEFAULT NULL,
  `sale_start_date` datetime DEFAULT NULL,
  `sale_end_date` datetime DEFAULT NULL,
  `bulk_pricing` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`bulk_pricing`)),
  `tier_pricing` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tier_pricing`)),
  `currency_code` char(3) NOT NULL DEFAULT 'USD',
  `tax_class` varchar(50) DEFAULT NULL,
  `margin_percentage` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_pricing_product_id` (`product_id`),
  CONSTRAINT `fk_product_pricing_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_pricing`
--

LOCK TABLES `product_pricing` WRITE;
/*!40000 ALTER TABLE `product_pricing` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_pricing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_recommendations`
--

DROP TABLE IF EXISTS `product_recommendations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_recommendations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `recommended_product_id` int(11) NOT NULL,
  `type` enum('viewed_together','bought_together','similar','complementary','trending') NOT NULL,
  `score` decimal(5,4) NOT NULL DEFAULT 0.0000,
  `algorithm` varchar(50) DEFAULT NULL,
  `context` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`context`)),
  `clicked` tinyint(1) NOT NULL DEFAULT 0,
  `purchased` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_product_recommended` (`user_id`,`product_id`,`recommended_product_id`,`type`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_recommended_product_id` (`recommended_product_id`),
  KEY `idx_type` (`type`),
  KEY `idx_score` (`score`),
  KEY `idx_expires_at` (`expires_at`),
  CONSTRAINT `fk_product_recommendations_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_recommendations_recommended` FOREIGN KEY (`recommended_product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_recommendations_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_recommendations`
--

LOCK TABLES `product_recommendations` WRITE;
/*!40000 ALTER TABLE `product_recommendations` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_recommendations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_related`
--

DROP TABLE IF EXISTS `product_related`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_related` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `related_product_id` int(11) NOT NULL,
  `relation_type` varchar(50) NOT NULL DEFAULT 'related',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_product_related_unique` (`product_id`,`related_product_id`,`relation_type`),
  KEY `idx_product_related_product` (`product_id`),
  KEY `idx_product_related_related` (`related_product_id`),
  KEY `idx_product_related_type` (`relation_type`),
  CONSTRAINT `fk_product_related_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_related_related_product` FOREIGN KEY (`related_product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_related`
--

LOCK TABLES `product_related` WRITE;
/*!40000 ALTER TABLE `product_related` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_related` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_relations`
--

DROP TABLE IF EXISTS `product_relations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_relations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `related_product_id` int(11) NOT NULL,
  `relation_type` varchar(20) NOT NULL COMMENT 'cross_sell | upsell | related | bundle',
  `priority` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_relations_product_id` (`product_id`),
  KEY `idx_product_relations_related_product_id` (`related_product_id`),
  KEY `idx_product_relations_type` (`relation_type`),
  CONSTRAINT `fk_product_relations_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_relations_related_product` FOREIGN KEY (`related_product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_relations`
--

LOCK TABLES `product_relations` WRITE;
/*!40000 ALTER TABLE `product_relations` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_relations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_reviews`
--

DROP TABLE IF EXISTS `product_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `rating` tinyint(1) NOT NULL CHECK (`rating` between 1 and 5),
  `title` varchar(255) DEFAULT NULL,
  `review_text` text DEFAULT NULL,
  `pros` text DEFAULT NULL,
  `cons` text DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `status` enum('pending','approved','rejected','spam') NOT NULL DEFAULT 'pending',
  `moderated_by` int(11) DEFAULT NULL,
  `moderation_notes` text DEFAULT NULL,
  `helpful_votes` int(11) NOT NULL DEFAULT 0,
  `verified_purchase` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_rating` (`rating`),
  KEY `idx_status` (`status`),
  KEY `fk_product_reviews_moderator` (`moderated_by`),
  CONSTRAINT `fk_product_reviews_moderator` FOREIGN KEY (`moderated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_product_reviews_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_product_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_reviews`
--

LOCK TABLES `product_reviews` WRITE;
/*!40000 ALTER TABLE `product_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_reviews` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`fezamarket`@`localhost`*/ /*!50003 TRIGGER `update_product_rating_avg` 
AFTER INSERT ON `product_reviews`
FOR EACH ROW
BEGIN
    UPDATE products 
    SET 
        rating_avg = (SELECT AVG(rating) FROM product_reviews WHERE product_id = NEW.product_id AND status = 'approved'),
        rating_count = (SELECT COUNT(*) FROM product_reviews WHERE product_id = NEW.product_id AND status = 'approved')
    WHERE id = NEW.product_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `product_seo`
--

DROP TABLE IF EXISTS `product_seo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_seo` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `meta_title` varchar(60) DEFAULT NULL,
  `meta_description` varchar(160) DEFAULT NULL,
  `meta_keywords` text DEFAULT NULL,
  `focus_keyword` varchar(100) DEFAULT NULL,
  `canonical_url` varchar(500) DEFAULT NULL,
  `og_title` varchar(60) DEFAULT NULL,
  `og_description` varchar(160) DEFAULT NULL,
  `og_image` varchar(500) DEFAULT NULL,
  `twitter_title` varchar(60) DEFAULT NULL,
  `twitter_description` varchar(160) DEFAULT NULL,
  `schema_markup` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`schema_markup`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_seo_product_id` (`product_id`),
  CONSTRAINT `fk_product_seo_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_seo`
--

LOCK TABLES `product_seo` WRITE;
/*!40000 ALTER TABLE `product_seo` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_seo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_shipping`
--

DROP TABLE IF EXISTS `product_shipping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_shipping` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `weight` decimal(10,3) DEFAULT NULL,
  `length` decimal(10,2) DEFAULT NULL,
  `width` decimal(10,2) DEFAULT NULL,
  `height` decimal(10,2) DEFAULT NULL,
  `shipping_class` varchar(50) DEFAULT NULL,
  `handling_time` int(11) NOT NULL DEFAULT 1,
  `free_shipping` tinyint(1) NOT NULL DEFAULT 0,
  `shipping_rules` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`shipping_rules`)),
  `hs_code` varchar(20) DEFAULT NULL,
  `country_of_origin` char(2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_product_shipping_product_id` (`product_id`),
  CONSTRAINT `fk_product_shipping_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_shipping`
--

LOCK TABLES `product_shipping` WRITE;
/*!40000 ALTER TABLE `product_shipping` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_shipping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_tag`
--

DROP TABLE IF EXISTS `product_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_tag` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_tag`
--

LOCK TABLES `product_tag` WRITE;
/*!40000 ALTER TABLE `product_tag` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_variants` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `stock_qty` int(11) DEFAULT NULL,
  `attributes_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attributes_json`)),
  `image_path` varchar(512) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `variant_options_json` longtext DEFAULT NULL,
  `option_name` varchar(100) DEFAULT NULL,
  `option_value` varchar(100) DEFAULT NULL,
  `price_delta` decimal(10,2) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku` (`sku`),
  KEY `idx_product_variants_product_id` (`product_id`),
  CONSTRAINT `fk_variants_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variants`
--

LOCK TABLES `product_variants` WRITE;
/*!40000 ALTER TABLE `product_variants` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_views`
--

DROP TABLE IF EXISTS `product_views`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_views` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `product_id` int(11) NOT NULL,
  `session_id` varchar(128) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `referrer` varchar(500) DEFAULT NULL,
  `view_duration` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_ip_address` (`ip_address`),
  CONSTRAINT `fk_product_views_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_product_views_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_views`
--

LOCK TABLES `product_views` WRITE;
/*!40000 ALTER TABLE `product_views` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_views` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_views_detailed`
--

DROP TABLE IF EXISTS `product_views_detailed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_views_detailed` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `referrer` text DEFAULT NULL,
  `viewed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_product_views_date` (`product_id`,`viewed_at`),
  KEY `idx_views_session` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Detailed product view tracking for analytics';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_views_detailed`
--

LOCK TABLES `product_views_detailed` WRITE;
/*!40000 ALTER TABLE `product_views_detailed` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_views_detailed` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller_id` int(10) unsigned DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `category_id` int(11) NOT NULL,
  `brand_id` bigint(20) unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(275) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `short_description` text DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `barcode` varchar(100) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `compare_price` decimal(12,2) DEFAULT NULL,
  `sale_price` decimal(10,2) DEFAULT NULL,
  `cost_price` decimal(10,2) DEFAULT NULL,
  `currency_code` char(3) NOT NULL DEFAULT 'USD',
  `stock_quantity` int(11) NOT NULL DEFAULT 0,
  `min_stock_level` int(11) NOT NULL DEFAULT 5,
  `max_stock_level` int(11) DEFAULT NULL,
  `weight` decimal(8,2) DEFAULT NULL,
  `dimensions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`dimensions`)),
  `status` enum('active','inactive','draft','archived') NOT NULL DEFAULT 'draft',
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `is_ai_recommended` tinyint(1) NOT NULL DEFAULT 0,
  `is_digital` tinyint(1) NOT NULL DEFAULT 0,
  `digital_delivery_info` text DEFAULT NULL,
  `visibility` enum('public','private','hidden') NOT NULL DEFAULT 'public',
  `track_inventory` tinyint(1) NOT NULL DEFAULT 1,
  `allow_backorder` tinyint(1) NOT NULL DEFAULT 0,
  `stock_qty` int(11) DEFAULT NULL,
  `low_stock_threshold` int(11) DEFAULT NULL,
  `featured` tinyint(1) NOT NULL DEFAULT 0,
  `digital` tinyint(1) NOT NULL DEFAULT 0,
  `downloadable` tinyint(1) NOT NULL DEFAULT 0,
  `virtual` tinyint(1) NOT NULL DEFAULT 0,
  `tags` text DEFAULT NULL,
  `attributes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attributes`)),
  `variations` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`variations`)),
  `shipping_class` varchar(50) DEFAULT NULL,
  `weight_kg` decimal(10,3) DEFAULT NULL,
  `length_cm` decimal(10,2) DEFAULT NULL,
  `width_cm` decimal(10,2) DEFAULT NULL,
  `height_cm` decimal(10,2) DEFAULT NULL,
  `seo_title` varchar(70) DEFAULT NULL,
  `seo_description` varchar(170) DEFAULT NULL,
  `seo_keywords` varchar(255) DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  `return_policy_text` text DEFAULT NULL,
  `warranty_text` text DEFAULT NULL,
  `compliance_notes` text DEFAULT NULL,
  `age_restriction` tinyint(1) NOT NULL DEFAULT 0,
  `digital_is` tinyint(1) NOT NULL DEFAULT 0,
  `digital_url` varchar(512) DEFAULT NULL,
  `digital_file_path` varchar(512) DEFAULT NULL,
  `thumbnail_path` varchar(512) DEFAULT NULL,
  `custom_barcode` varchar(64) DEFAULT NULL,
  `mpn` varchar(64) DEFAULT NULL,
  `gtin` varchar(64) DEFAULT NULL,
  `condition` enum('new','used','refurbished') NOT NULL DEFAULT 'new',
  `brand` varchar(160) DEFAULT NULL,
  `tax_status` enum('taxable','shipping','none') NOT NULL DEFAULT 'taxable',
  `tax_class` varchar(50) DEFAULT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `keywords` text DEFAULT NULL,
  `view_count` int(11) NOT NULL DEFAULT 0,
  `sales_count` int(11) NOT NULL DEFAULT 0,
  `purchase_count` int(11) NOT NULL DEFAULT 0,
  `average_rating` decimal(3,2) NOT NULL DEFAULT 0.00,
  `review_count` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `rating_avg` decimal(3,2) DEFAULT 0.00 COMMENT 'Average rating (0-5)',
  `rating_count` int(11) DEFAULT 0 COMMENT 'Number of ratings',
  `availability_status` enum('in_stock','out_of_stock','pre_order','discontinued') DEFAULT 'in_stock',
  `discount_percentage` decimal(5,2) DEFAULT 0.00 COMMENT 'Discount percentage',
  `is_new_arrival` tinyint(1) DEFAULT 0 COMMENT 'New arrival flag',
  `is_on_sale` tinyint(1) DEFAULT 0 COMMENT 'On sale flag',
  `material` varchar(100) DEFAULT NULL COMMENT 'Product material',
  `color` varchar(50) DEFAULT NULL COMMENT 'Product color',
  `size` varchar(50) DEFAULT NULL COMMENT 'Product size',
  `country_of_origin` varchar(100) DEFAULT NULL COMMENT 'Country where product is made',
  `free_shipping` tinyint(1) DEFAULT 0 COMMENT 'Free shipping flag',
  `fast_delivery` tinyint(1) DEFAULT 0 COMMENT 'Fast delivery available',
  `return_policy_days` int(11) DEFAULT 7 COMMENT 'Return policy in days',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_sku` (`sku`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_featured` (`featured`),
  KEY `idx_price` (`price`),
  KEY `idx_name` (`name`),
  KEY `idx_slug` (`slug`),
  KEY `idx_stock_quantity` (`stock_quantity`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_products_status_featured` (`status`,`featured`),
  KEY `idx_products_vendor_status` (`vendor_id`,`status`),
  KEY `idx_products_brand` (`brand_id`),
  KEY `idx_products_keywords` (`keywords`(255)),
  KEY `idx_is_digital` (`is_digital`),
  KEY `idx_is_ai_recommended` (`is_ai_recommended`,`status`),
  KEY `idx_view_count` (`view_count` DESC),
  KEY `idx_sales_count` (`sales_count` DESC),
  KEY `idx_brand_id` (`brand_id`),
  KEY `idx_rating_avg` (`rating_avg`),
  KEY `idx_availability` (`availability_status`),
  KEY `idx_is_new_arrival` (`is_new_arrival`),
  KEY `idx_is_featured` (`is_featured`),
  KEY `idx_is_on_sale` (`is_on_sale`),
  KEY `idx_free_shipping` (`free_shipping`),
  FULLTEXT KEY `idx_search` (`name`,`description`,`tags`),
  CONSTRAINT `fk_products_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `fk_products_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Products table with AI recommendations, view tracking, and sales tracking';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES
(5,NULL,3,5,NULL,'Iphone 16 Promax','iphone-16-promax-','this is iphone in the phones of the fnn','this is iphone in the phones of the fnn','/uploads/products/2025/10/img_1759572748_48954b57dc882d4c.jpg','Iphone sii',NULL,1700.00,NULL,NULL,NULL,'USD',1005,5,NULL,NULL,NULL,'active',0,0,0,NULL,'public',1,1,NULL,5,0,0,0,0,'',NULL,NULL,'standard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,NULL,'new',NULL,'taxable',NULL,'','',NULL,0,0,0,0.00,0,'2025-10-04 08:12:28','2025-10-15 19:20:48',0.00,0,'in_stock',0.00,1,1,NULL,NULL,NULL,NULL,0,0,7),
(6,NULL,3,1003,22,'TOYOTA HYBRID 2025','toyota-hybrid-2025','TOYOTA HYBRID 2025','TOYOTA HYBRID 2025','/uploads/products/2025/10/img_1759573981_502b782b6f37f2ac.jpg','XNN',NULL,5600.00,NULL,NULL,NULL,'USD',1000,5,NULL,NULL,NULL,'active',0,0,0,'','public',1,0,NULL,5,0,0,0,0,'',NULL,NULL,'express',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,NULL,'new',NULL,'taxable',NULL,'','',NULL,0,0,0,0.00,0,'2025-10-04 08:33:01','2025-10-15 19:20:48',0.00,0,'in_stock',0.00,1,1,NULL,NULL,NULL,NULL,0,0,7),
(7,NULL,3,1,28,'Acer Nitro 27\" Gaming Monitor LED 180Hz 2560x1440 250Nit Certified Refurbished','acer-nitro-27-gaming-monitor-led-180hz-2560x1440-250nit-certified-refurbished','This Acer monitor is a **certified refurbished** item in **excellent condition**, offering a high-quality viewing experience suitable for a variety of tasks including **casual computing**, **gaming**, and **graphic design**. The display features a **27-inch IPS LCD** screen with a **16:9 aspect ratio**, supporting **16.7 million colors** for vibrant and accurate visuals. It delivers a **brightness of 250 nits** and an impressive **dynamic contrast ratio of 100,000,000:1**, ensuring clear and vivid imagery. The monitor is designed for smooth and responsive performance, featuring a **refresh rate of up to 180Hz** and a **1ms (VRB)** response time, making it ideal for fast-paced action and immersive gaming.\r\n\r\nConnectivity options include **two HDMI 2.0 ports** and **one DisplayPort**, along with a **headphone jack** for enhanced audio convenience. It is also equipped with **two built-in speakers**, providing an all-in-one multimedia experience. The monitor supports **AMD FreeSync** technology, reducing screen tearing and stuttering for a more seamless visual flow. Its **VESA mount compatibility (100 x 100)** allows for flexible installation options, while the physical dimensions with the stand measure **24.2 inches in length**, **18.14 inches in height**, and **8.28 inches in width**. The elegant **black finish** adds a sleek, modern look that complements any setup.','This Acer monitor is a certified refurbished item in excellent condition, offering a high-quality viewing experience suitable for a variety of tasks including casual computing, gaming, and graphic design. The display features a 27-inch IPS LCD screen with a 16:9 aspect ratio, supporting 16.7 million colors for vibrant and accurate visuals. It delivers a brightness of 250 nits and an impressive dynamic contrast ratio of 100,000,000:1,','/uploads/products/2025/10/img_1760190165_9b46e9753ff38874.webp','XUFSSF',NULL,399.00,NULL,450.00,NULL,'USD',100,5,NULL,NULL,NULL,'draft',0,0,0,'','public',1,0,NULL,5,1,0,0,0,'',NULL,NULL,'standard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,NULL,'new',NULL,'taxable',NULL,'','',NULL,0,0,0,0.00,0,'2025-10-11 11:42:45','2025-10-15 19:20:48',0.00,0,'in_stock',0.00,1,1,NULL,NULL,NULL,NULL,0,0,7),
(8,NULL,3,1,19,'Acer Nitro 27\" Gaming Monitor LED 180Hz 2560x1440 250Nit Certified Refurbished','acer-nitro-27-gaming-monitor-led-180hz-2560x1440-250nit-certified-refurbished','This Acer monitor is a **certified refurbished** item in **excellent condition**, offering a high-quality viewing experience suitable for a variety of tasks including **casual computing**, **gaming**, and **graphic design**. The display features a **27-inch IPS LCD** screen with a **16:9 aspect ratio**, supporting **16.7 million colors** for vibrant and accurate visuals. It delivers a **brightness of 250 nits** and an impressive **dynamic contrast ratio of 100,000,000:1**, ensuring clear and vivid imagery. The monitor is designed for smooth and responsive performance, featuring a **refresh rate of up to 180Hz** and a **1ms (VRB)** response time, making it ideal for fast-paced action and immersive gaming.\r\n\r\nConnectivity options include **two HDMI 2.0 ports** and **one DisplayPort**, along with a **headphone jack** for enhanced audio convenience. It is also equipped with **two built-in speakers**, providing an all-in-one multimedia experience. The monitor supports **AMD FreeSync** technology, reducing screen tearing and stuttering for a more seamless visual flow. Its **VESA mount compatibility (100 x 100)** allows for flexible installation options, while the physical dimensions with the stand measure **24.2 inches in length**, **18.14 inches in height**, and **8.28 inches in width**. The elegant **black finish** adds a sleek, modern look that complements any setup.','This Acer monitor is a certified refurbished item in excellent condition, offering a high-quality viewing experience suitable for a variety of tasks including casual computing, gaming, and graphic design. The display features a 27-inch IPS LCD screen with a 16:9 aspect ratio, supporting 16.7 million colors for vibrant and accurate visuals. It delivers a brightness of 250 nits and an impressive dynamic contrast ratio of 100,000,000:1,','/uploads/products/2025/10/img_1760190504_012f6b5a99bd873c.webp','XFFGGG',NULL,399.00,NULL,450.00,NULL,'USD',100,5,NULL,4.00,NULL,'active',0,0,0,'','public',1,0,NULL,5,0,0,0,0,'',NULL,NULL,'express',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,NULL,'new',NULL,'taxable',NULL,'','',NULL,0,0,0,0.00,0,'2025-10-11 11:48:24','2025-10-15 19:20:48',0.00,0,'in_stock',0.00,1,1,NULL,NULL,NULL,NULL,0,0,7),
(9,NULL,3,1,4,'Apple iPhone 15 Pro Max (Unlocked) 256GB White Titanium- Open BOX','apple-iphone-15-pro-max-unlocked-256gb-white-titanium-open-box','','','/uploads/products/2025/10/img_1760198504_a84bd543eb0e78e5.webp','CGGHH',NULL,899.90,NULL,NULL,NULL,'USD',24,5,NULL,NULL,NULL,'active',0,0,0,'','public',1,0,NULL,5,0,0,0,0,'',NULL,NULL,'express',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,NULL,NULL,NULL,'refurbished',NULL,'taxable',NULL,'','',NULL,0,0,0,0.00,0,'2025-10-11 14:01:44','2025-10-15 19:20:48',0.00,0,'in_stock',0.00,1,1,NULL,NULL,NULL,NULL,0,0,7),
(10,NULL,3,1,5,'Samsung Galaxy A14 5G Factory Unlocked - 64GB US Version Black - Excellent','samsung-galaxy-a14-5g-factory-unlocked-64gb-us-version-black-excellent','The product is in **excellent refurbished condition**, meaning it has been carefully restored to full working order and shows minimal to no signs of previous use. According to the seller, *“The device is excellent. Cosmetics. This Android 13.0 Operating System runs on the latest Android…”*, indicating that the phone is both cosmetically clean and technically updated. Its **cosmetic condition** is listed as excellent, and it comes in its **original box**, which enhances the value of the purchase.\r\n\r\nPowered by an **Octa-Core processor** and a **Mediatek Dimensity 700 MT6833 (5 nm)** chipset, the device offers fast and reliable performance. It has an MPN of **SM-A146UZKAXAU** and is **factory unlocked**, allowing it to work with any compatible network. The phone supports a **Single SIM** slot and is rated **Energy Star A**, making it energy efficient. Its design follows a **bar style**, and it runs on the **Android** operating system.\r\n\r\nThe smartphone includes a wide range of **modern features** such as Bluetooth connectivity, a high-resolution camera, email access, fast charging, fast wireless charging, GPS, a quad-camera array, a **6.6-inch AMOLED display**, Bluetooth 5.0, and long battery life. It comes with **64 GB of internal storage** and **4 GB of RAM**, ensuring smooth multitasking. The **rear camera** has a resolution of **50 MP**, providing sharp image quality, and the **screen size** of 6.6 inches delivers an immersive viewing experience.\r\n\r\nThe device is available in **black**, both as the **manufacturer color** and exterior finish, and supports **microSDXC** memory cards for expandable storage. Its **model number** is A146U1, and it is part of the **Samsung Galaxy A14 5G** series from **Samsung**. Connectivity options include Bluetooth, USB Type-C, NFC, GPS, Glonass, Galileo, and 5G, offering flexibility and high-speed communication. Finally, it is sold **without a contract**, giving the buyer full freedom to choose their preferred carrier or plan.','The product is in excellent refurbished condition, meaning it has been carefully restored to full working order and shows minimal to no signs of previous use. According to the seller, “The device is excellent. Cosmetics. This Android 13.0 Operating System runs on the latest Android…”, indicating that the phone is both cosmetically clean and technically updated. Its cosmetic condition is listed as excellent, and it comes in its original box,','/uploads/products/2025/10/img_1760216888_b22857a24f31d033.webp','V3-SAMS-086012',NULL,159.99,NULL,NULL,NULL,'USD',20,5,NULL,NULL,NULL,'active',1,0,0,'','public',1,0,NULL,5,1,0,0,0,'',NULL,NULL,'express',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'',NULL,NULL,NULL,NULL,NULL,'new',NULL,'taxable',NULL,'','',NULL,0,0,0,0.00,0,'2025-10-11 19:08:08','2025-10-15 19:20:48',0.00,0,'in_stock',0.00,1,1,NULL,NULL,NULL,NULL,0,0,7),
(13,NULL,3,2,132,'AND1 Men\'s Socks, Cushion Quarter Socks, Stocking Stuffers, 12 Pack','and1-mens-socks-cushion-quarter-socks-stocking-stuffers-12-pack','<div class=\"mb3\">\r\n<div class=\"dangerous-html mb3\">\r\n<p>Experience the ultimate in comfort with AND1 Men\'s Cushion Quarter Socks. Designed with the athlete in mind for superior comfort and fit, AND1 provides a performance sock that delivers. Constructed with a soft, plush footbed, this twelve-pack of socks cushions your feet and adds as a safeguard for impact absorption and friction reduction. These durable men\'s sports socks are made with a comfort stretch technology for a sustained, dependable fit.</p>\r\n</div>\r\n</div>\r\n<div class=\"mb3 f6 mid-gray lh-title overflow-visible db\">\r\n<div class=\"dangerous-html mb3\">\r\n<ul>\r\n<li>12-pack includes: 12 pairs of quarter length men\'s socks</li>\r\n<li>Clothing size 6-12</li>\r\n<li>Arch compression for added support</li>\r\n<li>Cushioned sole for extra protection and comfort</li>\r\n<li>No bunching design</li>\r\n<li>95% Polyester</li>\r\n<li>5% Spandex</li>\r\n<li>Machine washable</li>\r\n<li>AND1 12-Pack Cushioned Quarter Length Men\'s Sock</li>\r\n<li>Country of Origin: China</li>\r\n</ul>\r\n</div>\r\n</div>','','','V3-AND1-3B3A53',NULL,18.00,NULL,NULL,NULL,'USD',150,5,NULL,NULL,NULL,'active',0,0,0,'','public',1,0,NULL,5,0,0,0,0,'',NULL,NULL,'standard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,'',NULL,NULL,NULL,NULL,NULL,'new',NULL,'taxable',NULL,'','',NULL,0,0,0,0.00,0,'2025-10-13 07:13:47','2025-10-15 19:20:48',0.00,0,'in_stock',0.00,1,1,NULL,NULL,NULL,NULL,0,0,7);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `push_subscriptions`
--

DROP TABLE IF EXISTS `push_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `push_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `endpoint` varchar(500) NOT NULL,
  `p256dh_key` varchar(255) NOT NULL,
  `auth_token` varchar(255) NOT NULL,
  `user_agent` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_used` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_endpoint` (`endpoint`(255)),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_last_used` (`last_used`),
  CONSTRAINT `fk_push_subscriptions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `push_subscriptions`
--

LOCK TABLES `push_subscriptions` WRITE;
/*!40000 ALTER TABLE `push_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `push_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reconciliations`
--

DROP TABLE IF EXISTS `reconciliations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `reconciliations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reconciliation_date` date NOT NULL,
  `gateway` varchar(50) NOT NULL,
  `total_transactions` int(11) NOT NULL DEFAULT 0,
  `total_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_fees` decimal(15,2) NOT NULL DEFAULT 0.00,
  `net_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `status` enum('pending','in_progress','completed','failed','manual_review') NOT NULL DEFAULT 'pending',
  `discrepancies` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`discrepancies`)),
  `gateway_report_path` varchar(500) DEFAULT NULL,
  `reconciled_by` int(11) DEFAULT NULL,
  `reconciled_at` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_date_gateway` (`reconciliation_date`,`gateway`),
  KEY `idx_gateway` (`gateway`),
  KEY `idx_status` (`status`),
  KEY `idx_reconciled_by` (`reconciled_by`),
  CONSTRAINT `fk_reconciliations_user` FOREIGN KEY (`reconciled_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reconciliations`
--

LOCK TABLES `reconciliations` WRITE;
/*!40000 ALTER TABLE `reconciliations` DISABLE KEYS */;
/*!40000 ALTER TABLE `reconciliations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `redirects`
--

DROP TABLE IF EXISTS `redirects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `redirects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `from_url` varchar(500) NOT NULL,
  `to_url` varchar(500) NOT NULL,
  `redirect_type` enum('301','302','307','308') NOT NULL DEFAULT '301',
  `reason` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `hit_count` int(11) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_from_url` (`from_url`),
  KEY `idx_to_url` (`to_url`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_redirects_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `redirects`
--

LOCK TABLES `redirects` WRITE;
/*!40000 ALTER TABLE `redirects` DISABLE KEYS */;
/*!40000 ALTER TABLE `redirects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refunds`
--

DROP TABLE IF EXISTS `refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `refunds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `order_item_id` int(11) DEFAULT NULL,
  `transaction_id` int(11) DEFAULT NULL,
  `refund_amount` decimal(10,2) NOT NULL,
  `refund_reason` enum('customer_request','defective_product','wrong_item','damaged_shipping','cancelled_order','dispute_resolution','admin_decision') NOT NULL,
  `refund_method` enum('original_payment','store_credit','bank_transfer','manual') NOT NULL DEFAULT 'original_payment',
  `status` enum('pending','processing','completed','failed','cancelled') NOT NULL DEFAULT 'pending',
  `external_refund_id` varchar(255) DEFAULT NULL,
  `processor_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`processor_response`)),
  `admin_notes` text DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `processed_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_item_id` (`order_item_id`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_status` (`status`),
  KEY `idx_refund_method` (`refund_method`),
  KEY `idx_processed_by` (`processed_by`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_refunds_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_refunds_order_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_refunds_processor` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_refunds_transaction` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refunds`
--

LOCK TABLES `refunds` WRITE;
/*!40000 ALTER TABLE `refunds` DISABLE KEYS */;
/*!40000 ALTER TABLE `refunds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_jobs`
--

DROP TABLE IF EXISTS `report_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `report_type` enum('sales','users','inventory','financial','marketing','custom') NOT NULL,
  `parameters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`parameters`)),
  `format` enum('csv','excel','pdf','json') NOT NULL DEFAULT 'csv',
  `schedule` varchar(100) DEFAULT NULL,
  `email_recipients` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`email_recipients`)),
  `file_path` varchar(500) DEFAULT NULL,
  `status` enum('queued','running','completed','failed') NOT NULL DEFAULT 'queued',
  `progress` int(11) NOT NULL DEFAULT 0,
  `error_message` text DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_report_type` (`report_type`),
  KEY `idx_status` (`status`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_report_jobs_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_jobs`
--

LOCK TABLES `report_jobs` WRITE;
/*!40000 ALTER TABLE `report_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `returns`
--

DROP TABLE IF EXISTS `returns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `returns` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `return_number` varchar(50) NOT NULL,
  `reason` enum('defective','wrong_item','damaged','not_as_described','change_of_mind','warranty','other') NOT NULL,
  `status` enum('requested','approved','rejected','shipped','received','refunded','completed','cancelled') NOT NULL DEFAULT 'requested',
  `description` text DEFAULT NULL,
  `return_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `refund_amount` decimal(10,2) DEFAULT NULL,
  `return_tracking` varchar(100) DEFAULT NULL,
  `admin_notes` text DEFAULT NULL,
  `customer_notes` text DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `processed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_return_number` (`return_number`),
  KEY `idx_return_order` (`order_id`),
  KEY `idx_return_user` (`user_id`),
  KEY `idx_return_vendor` (`vendor_id`),
  KEY `idx_return_status` (`status`),
  KEY `idx_return_created` (`created_at`),
  KEY `idx_return_processed_by` (`processed_by`),
  CONSTRAINT `fk_returns_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_returns_processor` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_returns_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_returns_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `returns`
--

LOCK TABLES `returns` WRITE;
/*!40000 ALTER TABLE `returns` DISABLE KEYS */;
/*!40000 ALTER TABLE `returns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review_helpfulness`
--

DROP TABLE IF EXISTS `review_helpfulness`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `review_helpfulness` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `review_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `is_helpful` tinyint(1) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_review_user` (`review_id`,`user_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_review_helpfulness_review` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_review_helpfulness_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review_helpfulness`
--

LOCK TABLES `review_helpfulness` WRITE;
/*!40000 ALTER TABLE `review_helpfulness` DISABLE KEYS */;
/*!40000 ALTER TABLE `review_helpfulness` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `order_item_id` int(11) DEFAULT NULL,
  `rating` tinyint(1) NOT NULL CHECK (`rating` between 1 and 5),
  `title` varchar(255) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `pros` text DEFAULT NULL,
  `cons` text DEFAULT NULL,
  `status` enum('pending','approved','rejected','hidden') NOT NULL DEFAULT 'pending',
  `helpful_count` int(11) NOT NULL DEFAULT 0,
  `unhelpful_count` int(11) NOT NULL DEFAULT 0,
  `verified_purchase` tinyint(1) NOT NULL DEFAULT 0,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `admin_response` text DEFAULT NULL,
  `responded_at` timestamp NULL DEFAULT NULL,
  `responded_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_order_item_id` (`order_item_id`),
  KEY `idx_status` (`status`),
  KEY `idx_rating` (`rating`),
  KEY `idx_verified_purchase` (`verified_purchase`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_reviews_responder` (`responded_by`),
  KEY `fk_reviews_approver` (`approved_by`),
  CONSTRAINT `fk_reviews_approver` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_reviews_order_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reviews_responder` FOREIGN KEY (`responded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `id` int(11) NOT NULL,
  `role_id` int(10) unsigned NOT NULL,
  `permission_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_role_permission` (`role_id`,`permission_id`),
  KEY `idx_role_permissions_permission` (`permission_id`),
  CONSTRAINT `fk_role_permissions_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) DEFAULT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `level` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_role_name` (`name`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_role_active` (`is_active`),
  KEY `idx_role_level` (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `saved_streams`
--

DROP TABLE IF EXISTS `saved_streams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `saved_streams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller_id` int(11) NOT NULL,
  `stream_title` varchar(255) NOT NULL,
  `stream_description` text DEFAULT NULL,
  `video_url` varchar(255) NOT NULL COMMENT 'URL or path to the saved video file',
  `thumbnail_url` varchar(255) DEFAULT NULL COMMENT 'URL or path to the video thumbnail',
  `duration` int(11) DEFAULT 0 COMMENT 'Duration of the video in seconds',
  `views` int(11) DEFAULT 0,
  `likes` int(11) DEFAULT 0,
  `dislikes` int(11) DEFAULT 0,
  `streamed_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'When the stream was originally live',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `seller_id_idx` (`seller_id`),
  CONSTRAINT `fk_saved_streams_seller_id` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `saved_streams`
--

LOCK TABLES `saved_streams` WRITE;
/*!40000 ALTER TABLE `saved_streams` DISABLE KEYS */;
/*!40000 ALTER TABLE `saved_streams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scheduled_streams`
--

DROP TABLE IF EXISTS `scheduled_streams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `scheduled_streams` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `scheduled_start` datetime NOT NULL,
  `scheduled_end` datetime DEFAULT NULL,
  `estimated_duration` int(11) DEFAULT NULL COMMENT 'Duration in minutes',
  `featured_products` text DEFAULT NULL COMMENT 'JSON array of product IDs',
  `thumbnail_url` varchar(500) DEFAULT NULL,
  `status` enum('scheduled','live','completed','cancelled') NOT NULL DEFAULT 'scheduled',
  `notification_sent` tinyint(1) NOT NULL DEFAULT 0,
  `reminder_sent` tinyint(1) NOT NULL DEFAULT 0,
  `actual_start` datetime DEFAULT NULL,
  `actual_end` datetime DEFAULT NULL,
  `viewer_count` int(11) DEFAULT 0,
  `peak_viewers` int(11) DEFAULT 0,
  `total_sales` decimal(10,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_scheduled_start` (`scheduled_start`),
  KEY `idx_status` (`status`),
  KEY `idx_vendor_status` (`vendor_id`,`status`),
  CONSTRAINT `fk_ss_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scheduled_streams`
--

LOCK TABLES `scheduled_streams` WRITE;
/*!40000 ALTER TABLE `scheduled_streams` DISABLE KEYS */;
INSERT INTO `scheduled_streams` VALUES
(1,3,'FASHION SELLING DIAMOND','Let\'s sell the fashion of this case now and on','2025-10-11 15:09:00',NULL,60,'[]',NULL,'scheduled',0,0,NULL,NULL,0,0,0.00,'2025-10-04 13:07:49','2025-10-04 13:07:49');
/*!40000 ALTER TABLE `scheduled_streams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_queries`
--

DROP TABLE IF EXISTS `search_queries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `search_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `query` varchar(500) NOT NULL,
  `results_count` int(11) NOT NULL DEFAULT 0,
  `clicked_product_id` int(11) DEFAULT NULL,
  `session_id` varchar(128) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `filters_used` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`filters_used`)),
  `sort_order` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_query` (`query`),
  KEY `idx_clicked_product_id` (`clicked_product_id`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_search_queries_product` FOREIGN KEY (`clicked_product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_search_queries_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_queries`
--

LOCK TABLES `search_queries` WRITE;
/*!40000 ALTER TABLE `search_queries` DISABLE KEYS */;
/*!40000 ALTER TABLE `search_queries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `security_logs`
--

DROP TABLE IF EXISTS `security_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `security_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `event_type` enum('login_success','login_failed','login_blocked','logout','password_change','email_change','two_fa_enabled','two_fa_disabled','account_locked','account_unlocked','suspicious_activity','access_denied','data_breach','privilege_escalation') NOT NULL,
  `severity` enum('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `resource_type` varchar(50) DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `risk_score` tinyint(3) unsigned DEFAULT NULL,
  `country` varchar(2) DEFAULT NULL,
  `is_resolved` tinyint(1) NOT NULL DEFAULT 0,
  `resolved_by` int(11) DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_severity` (`severity`),
  KEY `idx_ip_address` (`ip_address`),
  KEY `idx_risk_score` (`risk_score`),
  KEY `idx_is_resolved` (`is_resolved`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_security_logs_resolver` (`resolved_by`),
  CONSTRAINT `fk_security_logs_resolver` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_security_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `security_logs`
--

LOCK TABLES `security_logs` WRITE;
/*!40000 ALTER TABLE `security_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `security_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_ads`
--

DROP TABLE IF EXISTS `seller_ads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_ads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller_id` int(11) NOT NULL,
  `title` varchar(150) NOT NULL,
  `budget` decimal(18,2) NOT NULL,
  `cost` decimal(10,2) DEFAULT 0.00,
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `duration_days` int(11) DEFAULT 7,
  `target` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`target`)),
  `product_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`product_ids`)),
  `status` enum('pending','approved','rejected','running','paused','completed') DEFAULT 'pending',
  `payment_status` enum('pending','paid','failed','refunded') DEFAULT 'pending',
  `payment_method` varchar(50) DEFAULT NULL,
  `payment_reference` varchar(255) DEFAULT NULL,
  `payment_date` timestamp NULL DEFAULT NULL,
  `impressions` int(11) DEFAULT 0,
  `clicks` int(11) DEFAULT 0,
  `spend` decimal(18,2) DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_seller_id` (`seller_id`),
  KEY `idx_status` (`status`),
  KEY `idx_starts_at` (`starts_at`),
  KEY `idx_ends_at` (`ends_at`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_ads`
--

LOCK TABLES `seller_ads` WRITE;
/*!40000 ALTER TABLE `seller_ads` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_ads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_analytics`
--

DROP TABLE IF EXISTS `seller_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_analytics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `metric_date` date NOT NULL,
  `total_views` int(11) NOT NULL DEFAULT 0,
  `total_sales` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_orders` int(11) NOT NULL DEFAULT 0,
  `total_revenue` decimal(15,2) NOT NULL DEFAULT 0.00,
  `conversion_rate` decimal(5,4) NOT NULL DEFAULT 0.0000,
  `average_order_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `return_rate` decimal(5,4) NOT NULL DEFAULT 0.0000,
  `customer_satisfaction` decimal(3,2) DEFAULT NULL,
  `traffic_sources` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`traffic_sources`)),
  `top_products` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`top_products`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_vendor_date` (`vendor_id`,`metric_date`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_metric_date` (`metric_date`),
  KEY `idx_total_revenue` (`total_revenue`),
  CONSTRAINT `fk_seller_analytics_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_analytics`
--

LOCK TABLES `seller_analytics` WRITE;
/*!40000 ALTER TABLE `seller_analytics` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_bank_details`
--

DROP TABLE IF EXISTS `seller_bank_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_bank_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `account_type` enum('checking','savings','business') NOT NULL,
  `bank_name` varchar(255) NOT NULL,
  `account_holder_name` varchar(255) NOT NULL,
  `account_number_encrypted` varchar(500) NOT NULL,
  `routing_number_encrypted` varchar(500) NOT NULL,
  `swift_code` varchar(20) DEFAULT NULL,
  `iban` varchar(50) DEFAULT NULL,
  `bank_address` text DEFAULT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'USD',
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `verified_at` timestamp NULL DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor` (`vendor_id`),
  KEY `idx_is_default` (`is_default`),
  CONSTRAINT `fk_seller_bank_details_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_bank_details`
--

LOCK TABLES `seller_bank_details` WRITE;
/*!40000 ALTER TABLE `seller_bank_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_bank_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_campaign_assets`
--

DROP TABLE IF EXISTS `seller_campaign_assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_campaign_assets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `asset_type` enum('image','video','text','html','banner') NOT NULL,
  `name` varchar(255) NOT NULL,
  `file_path` varchar(500) DEFAULT NULL,
  `content` text DEFAULT NULL,
  `dimensions` varchar(50) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive','pending_approval') NOT NULL DEFAULT 'pending_approval',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_campaign` (`campaign_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_seller_campaign_assets_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `seller_campaigns` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_campaign_assets`
--

LOCK TABLES `seller_campaign_assets` WRITE;
/*!40000 ALTER TABLE `seller_campaign_assets` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_campaign_assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_campaign_stats`
--

DROP TABLE IF EXISTS `seller_campaign_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_campaign_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `impressions` int(11) NOT NULL DEFAULT 0,
  `clicks` int(11) NOT NULL DEFAULT 0,
  `conversions` int(11) NOT NULL DEFAULT 0,
  `spend` decimal(15,2) NOT NULL DEFAULT 0.00,
  `revenue` decimal(15,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `campaign_date` (`campaign_id`,`date`),
  KEY `idx_date` (`date`),
  CONSTRAINT `fk_seller_campaign_stats_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `seller_campaigns` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_campaign_stats`
--

LOCK TABLES `seller_campaign_stats` WRITE;
/*!40000 ALTER TABLE `seller_campaign_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_campaign_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_campaigns`
--

DROP TABLE IF EXISTS `seller_campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_campaigns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` enum('email','social','display','search','affiliate','influencer') NOT NULL,
  `status` enum('draft','active','paused','completed','cancelled') NOT NULL DEFAULT 'draft',
  `budget` decimal(15,2) DEFAULT NULL,
  `spent` decimal(15,2) NOT NULL DEFAULT 0.00,
  `target_audience` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`target_audience`)),
  `objectives` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`objectives`)),
  `start_date` timestamp NOT NULL,
  `end_date` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_status` (`vendor_id`,`status`),
  KEY `idx_dates` (`start_date`,`end_date`),
  CONSTRAINT `fk_seller_campaigns_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_campaigns`
--

LOCK TABLES `seller_campaigns` WRITE;
/*!40000 ALTER TABLE `seller_campaigns` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_campaigns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_chat_messages`
--

DROP TABLE IF EXISTS `seller_chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_chat_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `username` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `message_type` enum('text','emoji','system','product_link') NOT NULL DEFAULT 'text',
  `is_moderator` tinyint(1) NOT NULL DEFAULT 0,
  `is_seller` tinyint(1) NOT NULL DEFAULT 0,
  `is_highlighted` tinyint(1) NOT NULL DEFAULT 0,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_stream` (`stream_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_seller_chat_messages_stream` FOREIGN KEY (`stream_id`) REFERENCES `seller_live_streams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_chat_messages_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_chat_messages`
--

LOCK TABLES `seller_chat_messages` WRITE;
/*!40000 ALTER TABLE `seller_chat_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_commissions`
--

DROP TABLE IF EXISTS `seller_commissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_commissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `order_item_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `sale_amount` decimal(10,2) NOT NULL,
  `commission_rate` decimal(5,4) NOT NULL,
  `commission_amount` decimal(10,2) NOT NULL,
  `platform_fee` decimal(10,2) NOT NULL DEFAULT 0.00,
  `net_amount` decimal(10,2) NOT NULL,
  `status` enum('pending','approved','paid','disputed') NOT NULL DEFAULT 'pending',
  `approved_at` timestamp NULL DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `payout_id` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_order_item_commission` (`order_item_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_status` (`status`),
  KEY `idx_payout_id` (`payout_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_seller_commissions_vendor_status` (`vendor_id`,`status`),
  CONSTRAINT `fk_seller_commissions_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_commissions_order_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_commissions_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_commissions_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_commissions`
--

LOCK TABLES `seller_commissions` WRITE;
/*!40000 ALTER TABLE `seller_commissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_commissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_coupon_redemptions`
--

DROP TABLE IF EXISTS `seller_coupon_redemptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_coupon_redemptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coupon_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `discount_amount` decimal(10,2) NOT NULL,
  `redeemed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_coupon` (`coupon_id`),
  KEY `idx_order` (`order_id`),
  KEY `idx_customer` (`customer_id`),
  KEY `idx_redeemed_at` (`redeemed_at`),
  CONSTRAINT `fk_seller_coupon_redemptions_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `seller_coupons` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_coupon_redemptions_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_coupon_redemptions_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_coupon_redemptions`
--

LOCK TABLES `seller_coupon_redemptions` WRITE;
/*!40000 ALTER TABLE `seller_coupon_redemptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_coupon_redemptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_coupon_rules`
--

DROP TABLE IF EXISTS `seller_coupon_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_coupon_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coupon_id` int(11) NOT NULL,
  `rule_type` enum('customer_group','first_time_buyer','geographic','time_based','purchase_history') NOT NULL,
  `rule_condition` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`rule_condition`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_coupon` (`coupon_id`),
  KEY `idx_rule_type` (`rule_type`),
  CONSTRAINT `fk_seller_coupon_rules_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `seller_coupons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_coupon_rules`
--

LOCK TABLES `seller_coupon_rules` WRITE;
/*!40000 ALTER TABLE `seller_coupon_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_coupon_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_coupons`
--

DROP TABLE IF EXISTS `seller_coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_coupons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `type` enum('percentage','fixed_amount','free_shipping','buy_x_get_y') NOT NULL,
  `value` decimal(10,2) NOT NULL,
  `minimum_amount` decimal(10,2) DEFAULT NULL,
  `maximum_discount` decimal(10,2) DEFAULT NULL,
  `usage_limit` int(11) DEFAULT NULL,
  `usage_limit_per_customer` int(11) DEFAULT 1,
  `used_count` int(11) NOT NULL DEFAULT 0,
  `status` enum('active','inactive','expired') NOT NULL DEFAULT 'active',
  `start_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `end_date` timestamp NULL DEFAULT NULL,
  `applicable_products` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`applicable_products`)),
  `applicable_categories` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`applicable_categories`)),
  `excluded_products` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`excluded_products`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_code` (`vendor_id`,`code`),
  KEY `idx_code` (`code`),
  KEY `idx_status` (`status`),
  KEY `idx_dates` (`start_date`,`end_date`),
  CONSTRAINT `fk_seller_coupons_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_coupons`
--

LOCK TABLES `seller_coupons` WRITE;
/*!40000 ALTER TABLE `seller_coupons` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_coupons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_dispute_evidence`
--

DROP TABLE IF EXISTS `seller_dispute_evidence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_dispute_evidence` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dispute_id` int(11) NOT NULL,
  `submitted_by` int(11) NOT NULL,
  `evidence_type` enum('document','image','email','communication','tracking','receipt') NOT NULL,
  `file_path` varchar(500) DEFAULT NULL,
  `description` text NOT NULL,
  `submission_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dispute` (`dispute_id`),
  KEY `idx_submission_date` (`submission_date`),
  KEY `fk_seller_dispute_evidence_user` (`submitted_by`),
  CONSTRAINT `fk_seller_dispute_evidence_dispute` FOREIGN KEY (`dispute_id`) REFERENCES `seller_disputes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_dispute_evidence_user` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_dispute_evidence`
--

LOCK TABLES `seller_dispute_evidence` WRITE;
/*!40000 ALTER TABLE `seller_dispute_evidence` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_dispute_evidence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_dispute_messages`
--

DROP TABLE IF EXISTS `seller_dispute_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_dispute_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dispute_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `sender_type` enum('customer','seller','admin','system') NOT NULL,
  `message` text NOT NULL,
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
  `is_internal` tinyint(1) NOT NULL DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dispute` (`dispute_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_seller_dispute_messages_sender` (`sender_id`),
  CONSTRAINT `fk_seller_dispute_messages_dispute` FOREIGN KEY (`dispute_id`) REFERENCES `seller_disputes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_dispute_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_dispute_messages`
--

LOCK TABLES `seller_dispute_messages` WRITE;
/*!40000 ALTER TABLE `seller_dispute_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_dispute_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_disputes`
--

DROP TABLE IF EXISTS `seller_disputes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_disputes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `customer_id` int(11) NOT NULL,
  `dispute_number` varchar(50) NOT NULL,
  `type` enum('chargeback','refund_request','product_issue','service_issue','payment_issue') NOT NULL,
  `status` enum('open','under_review','awaiting_response','resolved','escalated','closed') NOT NULL DEFAULT 'open',
  `amount_disputed` decimal(10,2) NOT NULL,
  `customer_claim` text NOT NULL,
  `seller_response` text DEFAULT NULL,
  `resolution` text DEFAULT NULL,
  `resolved_by` int(11) DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `deadline` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `dispute_number` (`dispute_number`),
  KEY `idx_vendor_status` (`vendor_id`,`status`),
  KEY `idx_order` (`order_id`),
  KEY `idx_deadline` (`deadline`),
  KEY `fk_seller_disputes_customer` (`customer_id`),
  KEY `fk_seller_disputes_resolver` (`resolved_by`),
  CONSTRAINT `fk_seller_disputes_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_disputes_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_seller_disputes_resolver` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_seller_disputes_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_disputes`
--

LOCK TABLES `seller_disputes` WRITE;
/*!40000 ALTER TABLE `seller_disputes` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_disputes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_documents`
--

DROP TABLE IF EXISTS `seller_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `document_type` enum('business_license','tax_id','identity','address_proof','bank_statement','tax_form','insurance','certification') NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` int(11) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `document_number` varchar(100) DEFAULT NULL,
  `issued_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `status` enum('pending','approved','rejected','expired') NOT NULL DEFAULT 'pending',
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_type` (`vendor_id`,`document_type`),
  KEY `idx_status` (`status`),
  KEY `idx_expiry_date` (`expiry_date`),
  KEY `fk_seller_documents_reviewer` (`reviewed_by`),
  CONSTRAINT `fk_seller_documents_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_seller_documents_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_documents`
--

LOCK TABLES `seller_documents` WRITE;
/*!40000 ALTER TABLE `seller_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_inventory`
--

DROP TABLE IF EXISTS `seller_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `variant_id` int(11) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `quantity_available` int(11) NOT NULL DEFAULT 0,
  `quantity_reserved` int(11) NOT NULL DEFAULT 0,
  `quantity_damaged` int(11) NOT NULL DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_product_variant_location` (`vendor_id`,`product_id`,`variant_id`,`location`),
  KEY `idx_quantity_available` (`quantity_available`),
  KEY `fk_seller_inventory_product` (`product_id`),
  KEY `fk_seller_inventory_updater` (`updated_by`),
  CONSTRAINT `fk_seller_inventory_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_inventory_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_seller_inventory_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_inventory`
--

LOCK TABLES `seller_inventory` WRITE;
/*!40000 ALTER TABLE `seller_inventory` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_kpis`
--

DROP TABLE IF EXISTS `seller_kpis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_kpis` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `metric_date` date NOT NULL,
  `total_sales` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_orders` int(11) NOT NULL DEFAULT 0,
  `total_customers` int(11) NOT NULL DEFAULT 0,
  `conversion_rate` decimal(5,2) NOT NULL DEFAULT 0.00,
  `avg_order_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `return_rate` decimal(5,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_date` (`vendor_id`,`metric_date`),
  KEY `idx_metric_date` (`metric_date`),
  CONSTRAINT `fk_seller_kpis_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_kpis`
--

LOCK TABLES `seller_kpis` WRITE;
/*!40000 ALTER TABLE `seller_kpis` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_kpis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_kyc`
--

DROP TABLE IF EXISTS `seller_kyc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_kyc` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `verification_type` enum('individual','business','corporation') NOT NULL,
  `business_registration_number` varchar(100) DEFAULT NULL,
  `tax_identification_number` varchar(100) DEFAULT NULL,
  `identity_documents` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`identity_documents`)),
  `business_documents` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`business_documents`)),
  `address_verification` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`address_verification`)),
  `bank_verification` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`bank_verification`)),
  `verification_status` enum('pending','in_review','approved','rejected','requires_resubmission') NOT NULL DEFAULT 'pending',
  `verification_notes` text DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `verified_by` int(11) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_verification_status` (`verification_status`),
  KEY `idx_verification_type` (`verification_type`),
  KEY `idx_verified_by` (`verified_by`),
  KEY `idx_submitted_at` (`submitted_at`),
  CONSTRAINT `fk_seller_kyc_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_kyc_verifier` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_kyc`
--

LOCK TABLES `seller_kyc` WRITE;
/*!40000 ALTER TABLE `seller_kyc` DISABLE KEYS */;
INSERT INTO `seller_kyc` VALUES
(1,3,'individual',NULL,NULL,'{\"government_id\":{\"file_path\":\"\\/storage\\/kyc\\/3\\/id_68ef9fbb27c7c.png\",\"original_name\":\"cart.png\",\"document_number\":\"\"},\"tax_id\":{\"file_path\":\"\\/storage\\/kyc\\/3\\/id_68ef9fbb27d2c.png\",\"original_name\":\"pages.png\",\"document_number\":\"\"}}',NULL,'{\"proof_of_address\":{\"file_path\":\"\\/storage\\/kyc\\/3\\/addr_68ef9fbb27d72.png\",\"original_name\":\"PRODUCT.png\"}}','{\"bank_statement\":{\"file_path\":\"\\/storage\\/kyc\\/3\\/bank_68ef9fbb27dc2.png\",\"original_name\":\"kyc.png\",\"account_number\":\"\"}}','pending',NULL,NULL,NULL,NULL,NULL,'2025-10-15 13:20:59','2025-10-15 13:20:59');
/*!40000 ALTER TABLE `seller_kyc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_live_streams`
--

DROP TABLE IF EXISTS `seller_live_streams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_live_streams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `thumbnail_url` varchar(500) DEFAULT NULL,
  `stream_key` varchar(255) NOT NULL,
  `stream_url` varchar(500) DEFAULT NULL,
  `status` enum('scheduled','live','ended','cancelled') NOT NULL DEFAULT 'scheduled',
  `scheduled_start` timestamp NOT NULL,
  `actual_start` timestamp NULL DEFAULT NULL,
  `actual_end` timestamp NULL DEFAULT NULL,
  `max_viewers` int(11) DEFAULT 0,
  `total_views` int(11) DEFAULT 0,
  `chat_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `recording_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `recording_url` varchar(500) DEFAULT NULL,
  `products_featured` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`products_featured`)),
  `stream_analytics` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`stream_analytics`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `stream_key` (`stream_key`),
  KEY `idx_vendor_status` (`vendor_id`,`status`),
  KEY `idx_scheduled_start` (`scheduled_start`),
  CONSTRAINT `fk_seller_live_streams_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_live_streams`
--

LOCK TABLES `seller_live_streams` WRITE;
/*!40000 ALTER TABLE `seller_live_streams` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_live_streams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_message_templates`
--

DROP TABLE IF EXISTS `seller_message_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_message_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `category` enum('order_confirmation','shipping_notification','delivery_confirmation','return_approved','general_inquiry','support') NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `content` text NOT NULL,
  `variables` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`variables`)),
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `usage_count` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_category` (`vendor_id`,`category`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_seller_message_templates_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_message_templates`
--

LOCK TABLES `seller_message_templates` WRITE;
/*!40000 ALTER TABLE `seller_message_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_message_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_messages`
--

DROP TABLE IF EXISTS `seller_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `conversation_id` varchar(50) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `sender_type` enum('seller','customer','system') NOT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `message_type` enum('text','image','file','order_update','system') NOT NULL DEFAULT 'text',
  `content` text NOT NULL,
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
  `order_id` int(11) DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_conversation` (`vendor_id`,`conversation_id`),
  KEY `idx_customer` (`customer_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_seller_messages_order` (`order_id`),
  CONSTRAINT `fk_seller_messages_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_messages_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_seller_messages_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_messages`
--

LOCK TABLES `seller_messages` WRITE;
/*!40000 ALTER TABLE `seller_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_notifications`
--

DROP TABLE IF EXISTS `seller_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `type` enum('order','product','payout','dispute','system','marketing') NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `read_at` timestamp NULL DEFAULT NULL,
  `action_url` varchar(500) DEFAULT NULL,
  `priority` enum('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_read` (`vendor_id`,`read_at`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_seller_notifications_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_notifications`
--

LOCK TABLES `seller_notifications` WRITE;
/*!40000 ALTER TABLE `seller_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_order_items`
--

DROP TABLE IF EXISTS `seller_order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller_order_id` int(11) NOT NULL,
  `order_item_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `variant_id` int(11) DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `cost_price` decimal(10,2) DEFAULT NULL,
  `commission_rate` decimal(5,2) DEFAULT NULL,
  `commission_amount` decimal(10,2) DEFAULT NULL,
  `status` enum('pending','fulfilled','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_seller_order` (`seller_order_id`),
  KEY `idx_order_item` (`order_item_id`),
  KEY `idx_product` (`product_id`),
  CONSTRAINT `fk_seller_order_items_order_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_order_items_seller_order` FOREIGN KEY (`seller_order_id`) REFERENCES `seller_orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_order_items`
--

LOCK TABLES `seller_order_items` WRITE;
/*!40000 ALTER TABLE `seller_order_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_orders`
--

DROP TABLE IF EXISTS `seller_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `status` enum('pending','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `tracking_number` varchar(100) DEFAULT NULL,
  `shipping_carrier` varchar(100) DEFAULT NULL,
  `shipping_cost` decimal(10,2) DEFAULT NULL,
  `commission_rate` decimal(5,2) DEFAULT NULL,
  `commission_amount` decimal(10,2) DEFAULT NULL,
  `payout_status` enum('pending','processing','paid','on_hold') NOT NULL DEFAULT 'pending',
  `shipped_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_order` (`vendor_id`,`order_id`),
  KEY `idx_status` (`status`),
  KEY `idx_payout_status` (`payout_status`),
  KEY `idx_tracking_number` (`tracking_number`),
  KEY `fk_seller_orders_order` (`order_id`),
  CONSTRAINT `fk_seller_orders_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_orders_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_orders`
--

LOCK TABLES `seller_orders` WRITE;
/*!40000 ALTER TABLE `seller_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_payment_info`
--

DROP TABLE IF EXISTS `seller_payment_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_payment_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `payment_method` enum('bank_transfer','paypal','mobile_money','other') NOT NULL DEFAULT 'bank_transfer',
  `bank_name` varchar(100) DEFAULT NULL,
  `account_holder_name` varchar(100) DEFAULT NULL,
  `account_number` varchar(50) DEFAULT NULL,
  `routing_number` varchar(50) DEFAULT NULL,
  `swift_code` varchar(20) DEFAULT NULL,
  `paypal_email` varchar(100) DEFAULT NULL,
  `mobile_money_provider` varchar(50) DEFAULT NULL,
  `mobile_money_number` varchar(50) DEFAULT NULL,
  `additional_info` text DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  CONSTRAINT `fk_payment_info_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_payment_info`
--

LOCK TABLES `seller_payment_info` WRITE;
/*!40000 ALTER TABLE `seller_payment_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_payment_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_payout_requests`
--

DROP TABLE IF EXISTS `seller_payout_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_payout_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `fee` decimal(15,2) DEFAULT 0.00,
  `net_amount` decimal(15,2) NOT NULL,
  `method` enum('bank_transfer','paypal','crypto','check') NOT NULL DEFAULT 'bank_transfer',
  `account_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`account_details`)),
  `status` enum('pending','processing','approved','paid','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `processed_at` timestamp NULL DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_status` (`vendor_id`,`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_seller_payout_requests_processor` (`processed_by`),
  CONSTRAINT `fk_seller_payout_requests_processor` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_seller_payout_requests_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_payout_requests`
--

LOCK TABLES `seller_payout_requests` WRITE;
/*!40000 ALTER TABLE `seller_payout_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_payout_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_payouts`
--

DROP TABLE IF EXISTS `seller_payouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_payouts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `request_amount` decimal(10,2) NOT NULL,
  `processing_fee` decimal(10,2) NOT NULL DEFAULT 0.00,
  `final_amount` decimal(10,2) NOT NULL,
  `payout_method` enum('bank_transfer','paypal','stripe','wise','manual') NOT NULL DEFAULT 'bank_transfer',
  `payout_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payout_details`)),
  `status` enum('requested','pending','processing','completed','failed','cancelled') NOT NULL DEFAULT 'requested',
  `reference_number` varchar(100) DEFAULT NULL,
  `external_transaction_id` varchar(255) DEFAULT NULL,
  `failure_reason` text DEFAULT NULL,
  `admin_notes` text DEFAULT NULL,
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `processed_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_requested_at` (`requested_at`),
  KEY `idx_processed_by` (`processed_by`),
  KEY `idx_reference_number` (`reference_number`),
  KEY `idx_seller_payouts_vendor_status` (`vendor_id`,`status`),
  CONSTRAINT `fk_seller_payouts_processor` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_seller_payouts_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_payouts`
--

LOCK TABLES `seller_payouts` WRITE;
/*!40000 ALTER TABLE `seller_payouts` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_payouts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_performance_metrics`
--

DROP TABLE IF EXISTS `seller_performance_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_performance_metrics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `metric_date` date NOT NULL,
  `response_time_avg` decimal(8,2) DEFAULT NULL,
  `customer_satisfaction` decimal(3,2) DEFAULT NULL,
  `order_fulfillment_rate` decimal(5,2) DEFAULT NULL,
  `return_rate` decimal(5,2) DEFAULT NULL,
  `dispute_rate` decimal(5,2) DEFAULT NULL,
  `on_time_shipping_rate` decimal(5,2) DEFAULT NULL,
  `product_quality_score` decimal(3,2) DEFAULT NULL,
  `communication_score` decimal(3,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_date` (`vendor_id`,`metric_date`),
  KEY `idx_metric_date` (`metric_date`),
  CONSTRAINT `fk_seller_performance_metrics_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_performance_metrics`
--

LOCK TABLES `seller_performance_metrics` WRITE;
/*!40000 ALTER TABLE `seller_performance_metrics` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_performance_metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_product_media`
--

DROP TABLE IF EXISTS `seller_product_media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_product_media` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller_product_id` int(11) NOT NULL,
  `media_type` enum('image','video','document') NOT NULL DEFAULT 'image',
  `file_path` varchar(500) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_size` int(11) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `alt_text` varchar(255) DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0,
  `is_primary` tinyint(1) NOT NULL DEFAULT 0,
  `approval_status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_seller_product` (`seller_product_id`),
  KEY `idx_sort_order` (`sort_order`),
  CONSTRAINT `fk_seller_product_media_product` FOREIGN KEY (`seller_product_id`) REFERENCES `seller_products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_product_media`
--

LOCK TABLES `seller_product_media` WRITE;
/*!40000 ALTER TABLE `seller_product_media` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_product_media` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_product_variants`
--

DROP TABLE IF EXISTS `seller_product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_product_variants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller_product_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `price_adjustment` decimal(10,2) DEFAULT 0.00,
  `cost_adjustment` decimal(10,2) DEFAULT 0.00,
  `stock_quantity` int(11) DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_seller_product` (`seller_product_id`),
  KEY `idx_sku` (`sku`),
  CONSTRAINT `fk_seller_product_variants_product` FOREIGN KEY (`seller_product_id`) REFERENCES `seller_products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_product_variants`
--

LOCK TABLES `seller_product_variants` WRITE;
/*!40000 ALTER TABLE `seller_product_variants` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_product_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_products`
--

DROP TABLE IF EXISTS `seller_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `cost_price` decimal(10,2) DEFAULT NULL,
  `profit_margin` decimal(5,2) DEFAULT NULL,
  `min_stock_level` int(11) DEFAULT 0,
  `max_stock_level` int(11) DEFAULT NULL,
  `reorder_point` int(11) DEFAULT NULL,
  `lead_time_days` int(11) DEFAULT NULL,
  `approval_status` enum('pending','approved','rejected','under_review') NOT NULL DEFAULT 'pending',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_product` (`vendor_id`,`product_id`),
  KEY `idx_approval_status` (`approval_status`),
  KEY `idx_sku` (`sku`),
  KEY `fk_seller_products_product` (`product_id`),
  KEY `fk_seller_products_approver` (`approved_by`),
  CONSTRAINT `fk_seller_products_approver` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_seller_products_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_products_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_products`
--

LOCK TABLES `seller_products` WRITE;
/*!40000 ALTER TABLE `seller_products` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_profiles`
--

DROP TABLE IF EXISTS `seller_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `store_name` varchar(255) NOT NULL,
  `store_description` longtext DEFAULT NULL,
  `store_logo` varchar(500) DEFAULT NULL,
  `store_banner` varchar(500) DEFAULT NULL,
  `store_address` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`store_address`)),
  `social_links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`social_links`)),
  `business_hours` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`business_hours`)),
  `shipping_policy` longtext DEFAULT NULL,
  `return_policy` longtext DEFAULT NULL,
  `store_policies` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`store_policies`)),
  `notification_settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`notification_settings`)),
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `verification_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_is_verified` (`is_verified`),
  CONSTRAINT `fk_seller_profiles_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_profiles`
--

LOCK TABLES `seller_profiles` WRITE;
/*!40000 ALTER TABLE `seller_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_reports_jobs`
--

DROP TABLE IF EXISTS `seller_reports_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_reports_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `report_type` varchar(100) NOT NULL,
  `parameters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`parameters`)),
  `status` enum('queued','processing','completed','failed','cancelled') NOT NULL DEFAULT 'queued',
  `progress` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `file_path` varchar(500) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_status` (`vendor_id`,`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_seller_reports_jobs_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_reports_jobs`
--

LOCK TABLES `seller_reports_jobs` WRITE;
/*!40000 ALTER TABLE `seller_reports_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_reports_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_rma_notes`
--

DROP TABLE IF EXISTS `seller_rma_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_rma_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rma_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `user_type` enum('customer','seller','admin') NOT NULL,
  `note` text NOT NULL,
  `is_internal` tinyint(1) NOT NULL DEFAULT 0,
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_rma` (`rma_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_seller_rma_notes_user` (`user_id`),
  CONSTRAINT `fk_seller_rma_notes_rma` FOREIGN KEY (`rma_id`) REFERENCES `seller_rmas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_rma_notes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_rma_notes`
--

LOCK TABLES `seller_rma_notes` WRITE;
/*!40000 ALTER TABLE `seller_rma_notes` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_rma_notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_rmas`
--

DROP TABLE IF EXISTS `seller_rmas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_rmas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `rma_number` varchar(50) NOT NULL,
  `reason` enum('defective','wrong_item','damaged','not_as_described','change_of_mind','warranty') NOT NULL,
  `status` enum('pending','approved','rejected','received','refunded','completed') NOT NULL DEFAULT 'pending',
  `return_value` decimal(10,2) NOT NULL,
  `refund_amount` decimal(10,2) DEFAULT NULL,
  `return_label_generated` tinyint(1) DEFAULT 0,
  `return_tracking` varchar(100) DEFAULT NULL,
  `received_condition` enum('good','damaged','unopened','used') DEFAULT NULL,
  `resolution` enum('full_refund','partial_refund','replacement','repair','rejected') DEFAULT NULL,
  `customer_notes` text DEFAULT NULL,
  `seller_notes` text DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `rma_number` (`rma_number`),
  KEY `idx_vendor_status` (`vendor_id`,`status`),
  KEY `idx_order` (`order_id`),
  KEY `idx_customer` (`customer_id`),
  CONSTRAINT `fk_seller_rmas_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_rmas_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_rmas_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_rmas`
--

LOCK TABLES `seller_rmas` WRITE;
/*!40000 ALTER TABLE `seller_rmas` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_rmas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_sales_reports`
--

DROP TABLE IF EXISTS `seller_sales_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_sales_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `report_type` enum('daily','weekly','monthly','quarterly','yearly','custom') NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `total_sales` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_orders` int(11) NOT NULL DEFAULT 0,
  `total_customers` int(11) NOT NULL DEFAULT 0,
  `avg_order_value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `top_products` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`top_products`)),
  `geographic_breakdown` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`geographic_breakdown`)),
  `payment_methods` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payment_methods`)),
  `report_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`report_data`)),
  `generated_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_type` (`vendor_id`,`report_type`),
  KEY `idx_period` (`period_start`,`period_end`),
  CONSTRAINT `fk_seller_sales_reports_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_sales_reports`
--

LOCK TABLES `seller_sales_reports` WRITE;
/*!40000 ALTER TABLE `seller_sales_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_sales_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_shipping_rates`
--

DROP TABLE IF EXISTS `seller_shipping_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_shipping_rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `shipping_zone_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `method` enum('flat_rate','weight_based','price_based','quantity_based','free') NOT NULL,
  `rate` decimal(10,2) NOT NULL DEFAULT 0.00,
  `conditions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`conditions`)),
  `min_order_amount` decimal(10,2) DEFAULT NULL,
  `max_weight` decimal(8,2) DEFAULT NULL,
  `estimated_delivery_days` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_shipping_zone_id` (`shipping_zone_id`),
  KEY `idx_method` (`method`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_seller_shipping_rates_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_shipping_rates_zone` FOREIGN KEY (`shipping_zone_id`) REFERENCES `seller_shipping_zones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_shipping_rates`
--

LOCK TABLES `seller_shipping_rates` WRITE;
/*!40000 ALTER TABLE `seller_shipping_rates` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_shipping_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_shipping_settings`
--

DROP TABLE IF EXISTS `seller_shipping_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_shipping_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `carrier_name` varchar(100) NOT NULL,
  `shipping_zone` varchar(100) DEFAULT 'Domestic',
  `base_rate` decimal(10,2) NOT NULL DEFAULT 0.00,
  `per_item_rate` decimal(10,2) NOT NULL DEFAULT 0.00,
  `free_shipping_threshold` decimal(10,2) DEFAULT NULL,
  `estimated_delivery_days` int(11) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_shipping_settings_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_shipping_settings`
--

LOCK TABLES `seller_shipping_settings` WRITE;
/*!40000 ALTER TABLE `seller_shipping_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_shipping_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_shipping_zones`
--

DROP TABLE IF EXISTS `seller_shipping_zones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_shipping_zones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `countries` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`countries`)),
  `states` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`states`)),
  `postal_codes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`postal_codes`)),
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_sort_order` (`sort_order`),
  CONSTRAINT `fk_seller_shipping_zones_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_shipping_zones`
--

LOCK TABLES `seller_shipping_zones` WRITE;
/*!40000 ALTER TABLE `seller_shipping_zones` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_shipping_zones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_staff`
--

DROP TABLE IF EXISTS `seller_staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_staff` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` enum('manager','editor','viewer','support') NOT NULL DEFAULT 'viewer',
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `invited_by` int(11) NOT NULL,
  `invitation_token` varchar(255) DEFAULT NULL,
  `invitation_expires_at` timestamp NULL DEFAULT NULL,
  `accepted_at` timestamp NULL DEFAULT NULL,
  `status` enum('pending','active','suspended','removed') NOT NULL DEFAULT 'pending',
  `last_active_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_vendor_user` (`vendor_id`,`user_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`),
  KEY `idx_invited_by` (`invited_by`),
  CONSTRAINT `fk_seller_staff_inviter` FOREIGN KEY (`invited_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_staff_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_staff_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_staff`
--

LOCK TABLES `seller_staff` WRITE;
/*!40000 ALTER TABLE `seller_staff` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_stock_logs`
--

DROP TABLE IF EXISTS `seller_stock_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_stock_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_id` int(11) NOT NULL,
  `movement_type` enum('in','out','adjustment','reserved','released','damaged') NOT NULL,
  `quantity` int(11) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `reference_type` enum('order','return','adjustment','damage','restock') DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `performed_by` int(11) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_inventory` (`inventory_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_reference` (`reference_type`,`reference_id`),
  KEY `fk_seller_stock_logs_user` (`performed_by`),
  CONSTRAINT `fk_seller_stock_logs_inventory` FOREIGN KEY (`inventory_id`) REFERENCES `seller_inventory` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seller_stock_logs_user` FOREIGN KEY (`performed_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_stock_logs`
--

LOCK TABLES `seller_stock_logs` WRITE;
/*!40000 ALTER TABLE `seller_stock_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_stock_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_tax_settings`
--

DROP TABLE IF EXISTS `seller_tax_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_tax_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `tax_type` enum('VAT','GST','Sales Tax','Other') NOT NULL DEFAULT 'VAT',
  `tax_rate` decimal(5,2) NOT NULL DEFAULT 0.00,
  `tax_region` varchar(100) DEFAULT NULL,
  `tax_id_number` varchar(50) DEFAULT NULL,
  `apply_to_shipping` tinyint(1) NOT NULL DEFAULT 0,
  `is_inclusive` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_tax_settings_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_tax_settings`
--

LOCK TABLES `seller_tax_settings` WRITE;
/*!40000 ALTER TABLE `seller_tax_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_tax_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seller_wallets`
--

DROP TABLE IF EXISTS `seller_wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seller_wallets` (
  `id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `pending_balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_earned` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_withdrawn` decimal(15,2) NOT NULL DEFAULT 0.00,
  `commission_rate` decimal(5,2) NOT NULL DEFAULT 10.00,
  `payment_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payment_details`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_vendor_wallet` (`vendor_id`),
  KEY `idx_seller_wallets_balance` (`balance`),
  KEY `idx_seller_wallets_created` (`created_at`),
  CONSTRAINT `fk_seller_wallets_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seller_wallets`
--

LOCK TABLES `seller_wallets` WRITE;
/*!40000 ALTER TABLE `seller_wallets` DISABLE KEYS */;
/*!40000 ALTER TABLE `seller_wallets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seo_meta`
--

DROP TABLE IF EXISTS `seo_meta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seo_meta` (
  `entity_type` varchar(50) NOT NULL,
  `entity_id` int(11) NOT NULL,
  `meta_title` varchar(200) DEFAULT NULL,
  `meta_description` varchar(300) DEFAULT NULL,
  `canonical_url` varchar(500) DEFAULT NULL,
  `og_title` varchar(200) DEFAULT NULL,
  `og_description` varchar(300) DEFAULT NULL,
  `og_image` varchar(500) DEFAULT NULL,
  `robots` varchar(50) DEFAULT 'index,follow',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  UNIQUE KEY `uniq_entity` (`entity_type`,`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seo_meta`
--

LOCK TABLES `seo_meta` WRITE;
/*!40000 ALTER TABLE `seo_meta` DISABLE KEYS */;
/*!40000 ALTER TABLE `seo_meta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seo_metadata`
--

DROP TABLE IF EXISTS `seo_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seo_metadata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_type` enum('product','category','page','vendor') NOT NULL,
  `entity_id` int(11) NOT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `meta_keywords` text DEFAULT NULL,
  `canonical_url` varchar(500) DEFAULT NULL,
  `og_title` varchar(255) DEFAULT NULL,
  `og_description` text DEFAULT NULL,
  `og_image` varchar(500) DEFAULT NULL,
  `twitter_title` varchar(255) DEFAULT NULL,
  `twitter_description` text DEFAULT NULL,
  `twitter_image` varchar(500) DEFAULT NULL,
  `schema_markup` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`schema_markup`)),
  `robots_directive` varchar(255) DEFAULT 'index,follow',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_entity_type` (`entity_type`),
  KEY `idx_entity_id` (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seo_metadata`
--

LOCK TABLES `seo_metadata` WRITE;
/*!40000 ALTER TABLE `seo_metadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `seo_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_group` varchar(100) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` longtext DEFAULT NULL,
  `setting_type` enum('string','integer','decimal','boolean','json','text','password') NOT NULL DEFAULT 'string',
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `is_encrypted` tinyint(1) NOT NULL DEFAULT 0,
  `description` text DEFAULT NULL,
  `validation_rules` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`validation_rules`)),
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_group_key` (`setting_group`,`setting_key`),
  KEY `idx_setting_group` (`setting_group`),
  KEY `idx_is_public` (`is_public`),
  KEY `idx_updated_by` (`updated_by`),
  KEY `idx_settings_group_public` (`setting_group`,`is_public`),
  CONSTRAINT `fk_settings_updater` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES
(1,'general','site_name','E-Commerce Platform','string',1,0,'Site name displayed in header and emails',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(2,'general','site_description','Professional E-Commerce Platform','string',1,0,'Site description for SEO',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(3,'general','admin_email','admin@example.com','string',0,0,'Administrator email address',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(4,'general','timezone','UTC','string',1,0,'Default timezone',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(5,'general','currency','USD','string',1,0,'Default currency',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(6,'general','maintenance_mode','false','boolean',0,0,'Enable maintenance mode',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(7,'email','smtp_host','localhost','string',0,0,'SMTP server hostname',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(8,'email','smtp_port','587','integer',0,0,'SMTP server port',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(9,'email','smtp_username','','string',0,0,'SMTP username',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(10,'email','smtp_password','','password',0,0,'SMTP password',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(11,'email','smtp_encryption','tls','string',0,0,'SMTP encryption method',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(12,'payments','default_gateway','stripe','string',0,0,'Default payment gateway',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(13,'payments','stripe_publishable_key','','string',0,0,'Stripe publishable key',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(14,'payments','stripe_secret_key','','password',0,0,'Stripe secret key',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(15,'payments','paypal_client_id','','string',0,0,'PayPal client ID',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(16,'payments','paypal_client_secret','','password',0,0,'PayPal client secret',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(17,'security','session_timeout','3600','integer',0,0,'Session timeout in seconds',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(18,'security','max_login_attempts','5','integer',0,0,'Maximum login attempts before lockout',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(19,'security','lockout_duration','900','integer',0,0,'Account lockout duration in seconds',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(20,'security','require_2fa','false','boolean',0,0,'Require two-factor authentication',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(21,'features','enable_reviews','true','boolean',1,0,'Enable product reviews',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(22,'features','enable_wishlist','true','boolean',1,0,'Enable wishlist functionality',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(23,'features','enable_loyalty','true','boolean',1,0,'Enable loyalty program',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(24,'features','enable_live_streaming','true','boolean',1,0,'Enable live streaming features',NULL,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipment_items`
--

DROP TABLE IF EXISTS `shipment_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipment_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shipment_id` int(11) NOT NULL,
  `order_item_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `shipment_id` (`shipment_id`),
  KEY `order_item_id` (`order_item_id`),
  CONSTRAINT `fk_shipment_items_order_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_shipment_items_shipment` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipment_items`
--

LOCK TABLES `shipment_items` WRITE;
/*!40000 ALTER TABLE `shipment_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `shipment_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipments`
--

DROP TABLE IF EXISTS `shipments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `tracking_number` varchar(255) DEFAULT NULL,
  `carrier` varchar(100) DEFAULT NULL,
  `shipping_method` varchar(100) DEFAULT NULL,
  `shipping_cost` decimal(10,2) DEFAULT 0.00,
  `status` varchar(50) NOT NULL DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `shipped_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `vendor_id` (`vendor_id`),
  KEY `tracking_number` (`tracking_number`),
  KEY `fk_shipments_created_by` (`created_by`),
  CONSTRAINT `fk_shipments_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_shipments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_shipments_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipments`
--

LOCK TABLES `shipments` WRITE;
/*!40000 ALTER TABLE `shipments` DISABLE KEYS */;
/*!40000 ALTER TABLE `shipments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipping_carriers`
--

DROP TABLE IF EXISTS `shipping_carriers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipping_carriers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `tracking_url` varchar(255) DEFAULT NULL COMMENT 'URL template for tracking, e.g., https://www.fedex.com/apps/fedextrack/?tracknumbers={tracking_number}',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `code` varchar(50) NOT NULL,
  `tracking_url_template` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `unique_code` (`code`),
  KEY `idx_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_carriers`
--

LOCK TABLES `shipping_carriers` WRITE;
/*!40000 ALTER TABLE `shipping_carriers` DISABLE KEYS */;
INSERT INTO `shipping_carriers` VALUES
(1,'FedEx','https://www.fedex.com/apps/fedextrack/?tracknumbers=',1,'2025-09-27 10:19:25','2025-10-15 19:20:15','fedex',NULL),
(2,'UPS','https://www.ups.com/track?loc=en_US&tracknum=',1,'2025-09-27 10:19:25','2025-10-15 19:20:15','ups',NULL),
(3,'USPS','https://tools.usps.com/go/TrackConfirmAction_input?qtc_tLabels1=',1,'2025-09-27 10:19:25','2025-10-15 19:20:15','usps',NULL),
(4,'DHL','https://www.dhl.com/en/express/tracking.html?AWB=',1,'2025-09-27 10:19:25','2025-10-15 19:20:15','dhl',NULL),
(5,'Rwanda Post',NULL,1,'2025-10-15 19:20:48','2025-10-15 19:20:48','rwanda-post',NULL);
/*!40000 ALTER TABLE `shipping_carriers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipping_methods`
--

DROP TABLE IF EXISTS `shipping_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipping_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'e.g., Standard Shipping',
  `code` varchar(50) NOT NULL COMMENT 'e.g., standard, express, overnight',
  `description` text DEFAULT NULL,
  `base_cost` decimal(10,2) NOT NULL DEFAULT 0.00,
  `free_shipping_threshold` decimal(10,2) DEFAULT NULL COMMENT 'Free if order >= this amount',
  `delivery_days_min` int(11) DEFAULT NULL COMMENT 'Minimum delivery days',
  `delivery_days_max` int(11) DEFAULT NULL COMMENT 'Maximum delivery days',
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `rate` decimal(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_code` (`code`),
  KEY `idx_status` (`status`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_methods`
--

LOCK TABLES `shipping_methods` WRITE;
/*!40000 ALTER TABLE `shipping_methods` DISABLE KEYS */;
INSERT INTO `shipping_methods` VALUES
(1,'Standard Shipping','standard','Delivery in 5-7 business days',5.99,50.00,5,7,'active',1,'2025-10-13 00:27:30','2025-10-13 00:27:30',0.00),
(2,'Express Shipping','express','Faster delivery in 2-3 business days',12.99,NULL,2,3,'active',2,'2025-10-13 00:27:30','2025-10-13 00:27:30',0.00),
(3,'Overnight Shipping','overnight','Next business day delivery',24.99,NULL,1,1,'active',3,'2025-10-13 00:27:30','2025-10-13 00:27:30',0.00);
/*!40000 ALTER TABLE `shipping_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sponsored_product_analytics`
--

DROP TABLE IF EXISTS `sponsored_product_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sponsored_product_analytics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sponsored_product_id` int(11) NOT NULL,
  `event_type` enum('impression','click','view') NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `referrer` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_sponsored_product_id` (`sponsored_product_id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `sponsored_product_analytics_ibfk_1` FOREIGN KEY (`sponsored_product_id`) REFERENCES `sponsored_products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sponsored_product_analytics`
--

LOCK TABLES `sponsored_product_analytics` WRITE;
/*!40000 ALTER TABLE `sponsored_product_analytics` DISABLE KEYS */;
/*!40000 ALTER TABLE `sponsored_product_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sponsored_product_settings`
--

DROP TABLE IF EXISTS `sponsored_product_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sponsored_product_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `description` text DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sponsored_product_settings`
--

LOCK TABLES `sponsored_product_settings` WRITE;
/*!40000 ALTER TABLE `sponsored_product_settings` DISABLE KEYS */;
INSERT INTO `sponsored_product_settings` VALUES
(1,'price_per_7_days','50.00','Cost per product for 7-day sponsored placement (USD)',NULL,NULL);
/*!40000 ALTER TABLE `sponsored_product_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sponsored_product_transactions`
--

DROP TABLE IF EXISTS `sponsored_product_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sponsored_product_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sponsored_product_id` int(11) NOT NULL,
  `seller_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `transaction_type` enum('payment','refund','adjustment') NOT NULL DEFAULT 'payment',
  `payment_method` varchar(50) DEFAULT 'wallet',
  `description` text DEFAULT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `sponsored_product_id` (`sponsored_product_id`),
  KEY `seller_id` (`seller_id`),
  KEY `idx_transaction_date` (`created_at`),
  CONSTRAINT `fk_sponsor_transaction` FOREIGN KEY (`sponsored_product_id`) REFERENCES `sponsored_products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Financial transactions for product sponsorships';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sponsored_product_transactions`
--

LOCK TABLES `sponsored_product_transactions` WRITE;
/*!40000 ALTER TABLE `sponsored_product_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sponsored_product_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sponsored_products`
--

DROP TABLE IF EXISTS `sponsored_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sponsored_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `seller_id` int(11) NOT NULL,
  `sponsorship_fee` decimal(10,2) NOT NULL DEFAULT 0.00,
  `daily_cost` decimal(10,2) NOT NULL DEFAULT 5.00,
  `total_paid` decimal(10,2) NOT NULL DEFAULT 0.00,
  `start_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `end_date` timestamp NULL DEFAULT NULL,
  `status` enum('active','paused','completed','cancelled') NOT NULL DEFAULT 'active',
  `position` int(11) NOT NULL DEFAULT 0,
  `clicks` int(11) NOT NULL DEFAULT 0,
  `views` int(11) NOT NULL DEFAULT 0,
  `orders` int(11) NOT NULL DEFAULT 0,
  `revenue_generated` decimal(10,2) NOT NULL DEFAULT 0.00,
  `admin_approved` tinyint(1) NOT NULL DEFAULT 0,
  `admin_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `sponsored_until` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `seller_id` (`seller_id`),
  KEY `status` (`status`),
  KEY `idx_sponsored_active` (`status`,`start_date`,`end_date`),
  KEY `idx_sponsored_position` (`position`,`status`),
  KEY `idx_active_sponsored` (`status`,`product_id`),
  KEY `idx_sponsored_until` (`sponsored_until`),
  CONSTRAINT `fk_sponsored_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sponsored_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Sponsored products for paid promotions on homepage';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sponsored_products`
--

LOCK TABLES `sponsored_products` WRITE;
/*!40000 ALTER TABLE `sponsored_products` DISABLE KEYS */;
/*!40000 ALTER TABLE `sponsored_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_appearance`
--

DROP TABLE IF EXISTS `store_appearance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_appearance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `store_logo` varchar(255) DEFAULT NULL,
  `store_banner` varchar(255) DEFAULT NULL,
  `theme_color` varchar(7) DEFAULT '#3b82f6',
  `theme_name` varchar(50) DEFAULT 'default',
  `custom_css` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_vendor` (`vendor_id`),
  CONSTRAINT `fk_store_appearance_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_appearance`
--

LOCK TABLES `store_appearance` WRITE;
/*!40000 ALTER TABLE `store_appearance` DISABLE KEYS */;
INSERT INTO `store_appearance` VALUES
(1,3,NULL,NULL,'#1f1cc4','modern',NULL,'2025-10-01 23:12:29','2025-10-01 23:12:48');
/*!40000 ALTER TABLE `store_appearance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_policies`
--

DROP TABLE IF EXISTS `store_policies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_policies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `return_policy` text DEFAULT NULL,
  `refund_policy` text DEFAULT NULL,
  `exchange_policy` text DEFAULT NULL,
  `shipping_policy` text DEFAULT NULL,
  `privacy_policy` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_vendor` (`vendor_id`),
  CONSTRAINT `fk_store_policies_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_policies`
--

LOCK TABLES `store_policies` WRITE;
/*!40000 ALTER TABLE `store_policies` DISABLE KEYS */;
/*!40000 ALTER TABLE `store_policies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stream_engagement_config`
--

DROP TABLE IF EXISTS `stream_engagement_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_engagement_config` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `stream_id` bigint(20) unsigned NOT NULL,
  `fake_viewers_enabled` tinyint(1) DEFAULT 1,
  `fake_likes_enabled` tinyint(1) DEFAULT 1,
  `min_fake_viewers` int(10) unsigned NOT NULL DEFAULT 10,
  `max_fake_viewers` int(10) unsigned NOT NULL DEFAULT 50,
  `viewer_increase_rate` int(10) unsigned NOT NULL DEFAULT 5 COMMENT 'Viewers per minute',
  `viewer_decrease_rate` int(10) unsigned NOT NULL DEFAULT 3 COMMENT 'Viewers per minute',
  `like_rate` int(10) unsigned NOT NULL DEFAULT 2 COMMENT 'Likes per minute',
  `engagement_multiplier` decimal(3,2) NOT NULL DEFAULT 1.00 COMMENT 'Multiplier for engagement',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_stream_config` (`stream_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stream_engagement_config`
--

LOCK TABLES `stream_engagement_config` WRITE;
/*!40000 ALTER TABLE `stream_engagement_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `stream_engagement_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stream_followers`
--

DROP TABLE IF EXISTS `stream_followers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_followers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `notify_on_live` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_vendor` (`user_id`,`vendor_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  CONSTRAINT `fk_sf_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sf_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stream_followers`
--

LOCK TABLES `stream_followers` WRITE;
/*!40000 ALTER TABLE `stream_followers` DISABLE KEYS */;
/*!40000 ALTER TABLE `stream_followers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stream_interactions`
--

DROP TABLE IF EXISTS `stream_interactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_interactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `interaction_type` enum('like','dislike','comment') NOT NULL,
  `comment_text` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_like_dislike` (`stream_id`,`user_id`,`interaction_type`),
  KEY `user_id` (`user_id`),
  KEY `idx_stream_user` (`stream_id`,`user_id`),
  KEY `idx_stream_type` (`stream_id`,`interaction_type`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `stream_interactions_ibfk_1` FOREIGN KEY (`stream_id`) REFERENCES `live_streams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stream_interactions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stream_interactions`
--

LOCK TABLES `stream_interactions` WRITE;
/*!40000 ALTER TABLE `stream_interactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `stream_interactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stream_orders`
--

DROP TABLE IF EXISTS `stream_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `vendor_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `product_id` (`product_id`),
  KEY `idx_stream_id` (`stream_id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `stream_orders_ibfk_1` FOREIGN KEY (`stream_id`) REFERENCES `live_streams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stream_orders_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stream_orders_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stream_orders_ibfk_4` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stream_orders`
--

LOCK TABLES `stream_orders` WRITE;
/*!40000 ALTER TABLE `stream_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `stream_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stream_viewers`
--

DROP TABLE IF EXISTS `stream_viewers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stream_viewers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stream_id` int(11) NOT NULL COMMENT 'Reference to the active live stream session',
  `user_id` int(11) NOT NULL COMMENT 'Reference to the user viewing the stream',
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `stream_user_unique_idx` (`stream_id`,`user_id`),
  KEY `stream_id_idx` (`stream_id`),
  KEY `fk_stream_viewers_user_id` (`user_id`),
  CONSTRAINT `fk_stream_viewers_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stream_viewers`
--

LOCK TABLES `stream_viewers` WRITE;
/*!40000 ALTER TABLE `stream_viewers` DISABLE KEYS */;
/*!40000 ALTER TABLE `stream_viewers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stripe_events`
--

DROP TABLE IF EXISTS `stripe_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stripe_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` varchar(255) NOT NULL COMMENT 'Stripe Event ID (evt_...)',
  `event_type` varchar(100) NOT NULL COMMENT 'Event type (e.g., payment_intent.succeeded)',
  `processed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Full event payload for debugging' CHECK (json_valid(`payload`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `event_id` (`event_id`),
  KEY `idx_event_id` (`event_id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_processed_at` (`processed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stripe_events`
--

LOCK TABLES `stripe_events` WRITE;
/*!40000 ALTER TABLE `stripe_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `stripe_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stripe_payment_intents`
--

DROP TABLE IF EXISTS `stripe_payment_intents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stripe_payment_intents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `payment_intent_id` varchar(255) NOT NULL COMMENT 'Stripe PaymentIntent ID (pi_...)',
  `order_id` int(11) DEFAULT NULL COMMENT 'Internal order ID',
  `order_reference` varchar(50) DEFAULT NULL COMMENT 'Human-readable order reference',
  `amount_minor` int(11) NOT NULL COMMENT 'Amount in minor units (cents)',
  `currency` varchar(3) NOT NULL DEFAULT 'usd',
  `status` varchar(50) NOT NULL COMMENT 'Stripe PI status: requires_payment_method, requires_confirmation, requires_action, processing, requires_capture, canceled, succeeded',
  `client_secret` varchar(255) DEFAULT NULL COMMENT 'Client secret for frontend confirmation',
  `payment_method` varchar(255) DEFAULT NULL COMMENT 'Stripe payment method ID',
  `customer_id` varchar(255) DEFAULT NULL COMMENT 'Stripe customer ID',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Additional metadata from Stripe' CHECK (json_valid(`metadata`)),
  `last_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Last webhook payload received' CHECK (json_valid(`last_payload`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_intent_id` (`payment_intent_id`),
  KEY `idx_payment_intent_id` (`payment_intent_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_reference` (`order_reference`),
  KEY `idx_status` (`status`),
  KEY `idx_customer_id` (`customer_id`),
  CONSTRAINT `fk_stripe_pi_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stripe_payment_intents`
--

LOCK TABLES `stripe_payment_intents` WRITE;
/*!40000 ALTER TABLE `stripe_payment_intents` DISABLE KEYS */;
INSERT INTO `stripe_payment_intents` VALUES
(1,'pi_3SI64NLvK7krf7171pXO4Yfe',10,'ORD-20251014-000010',2543,'eur','requires_payment_method','pi_3SI64NLvK7krf7171pXO4Yfe_secret_Kh3frArLYlRztijvDBKNRGmoA',NULL,'cus_TEZC0jd1HprPCH','{\"order_id\":\"10\",\"order_ref\":\"ORD-20251014-000010\",\"user_id\":\"4\",\"save_for_future\":\"true\",\"coupon_code\":\"\",\"gift_card_code\":\"\"}','[]','2025-10-14 11:07:07','2025-10-14 11:07:07'),
(2,'pi_3SI8MoLvK7krf7171hRAysPT',12,'ORD-20251014-000012',4487,'usd','requires_payment_method','pi_3SI8MoLvK7krf7171hRAysPT_secret_YVoXVtTYYoehWUXIXPvWPXoEj',NULL,'cus_TEZC0jd1HprPCH','{\"order_id\":\"12\",\"order_ref\":\"ORD-20251014-000012\",\"user_id\":\"4\",\"save_for_future\":\"true\",\"coupon_code\":\"\",\"gift_card_code\":\"\"}','[]','2025-10-14 13:34:18','2025-10-14 13:34:18'),
(3,'pi_3SICmDLvK7krf71705Tr4cNw',16,'ORD-20251014-000016',312971,'usd','requires_payment_method','pi_3SICmDLvK7krf71705Tr4cNw_secret_LQVM89nSTTJkMVLH3F1SZfrdh',NULL,'cus_TEZC0jd1HprPCH','{\"order_id\":\"16\",\"order_ref\":\"ORD-20251014-000016\",\"user_id\":\"4\",\"save_for_future\":\"true\",\"coupon_code\":\"\",\"gift_card_code\":\"\"}','[]','2025-10-14 18:16:50','2025-10-14 18:16:50'),
(4,'pi_3SIEzrLvK7krf7170H6nywlg',17,'ORD-20251014-000017',338632,'usd','requires_payment_method','pi_3SIEzrLvK7krf7170H6nywlg_secret_xSVejlZ9scvLf1iO34q9GH21y',NULL,'cus_TEZC0jd1HprPCH','{\"order_id\":\"17\",\"order_ref\":\"ORD-20251014-000017\",\"user_id\":\"4\",\"save_for_future\":\"true\",\"coupon_code\":\"\",\"gift_card_code\":\"\"}','[]','2025-10-14 20:39:04','2025-10-14 20:39:04');
/*!40000 ALTER TABLE `stripe_payment_intents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stripe_refunds`
--

DROP TABLE IF EXISTS `stripe_refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stripe_refunds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `refund_id` varchar(255) NOT NULL COMMENT 'Stripe Refund ID (re_...)',
  `payment_intent_id` varchar(255) NOT NULL COMMENT 'Related Stripe PaymentIntent ID',
  `order_id` int(11) DEFAULT NULL COMMENT 'Internal order ID',
  `amount_minor` int(11) NOT NULL COMMENT 'Refunded amount in minor units',
  `currency` varchar(3) NOT NULL DEFAULT 'usd',
  `status` varchar(50) NOT NULL COMMENT 'Refund status: pending, succeeded, failed, canceled',
  `reason` varchar(255) DEFAULT NULL COMMENT 'Refund reason',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Additional metadata' CHECK (json_valid(`metadata`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `refund_id` (`refund_id`),
  KEY `idx_refund_id` (`refund_id`),
  KEY `idx_payment_intent_id` (`payment_intent_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_stripe_refund_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stripe_refunds`
--

LOCK TABLES `stripe_refunds` WRITE;
/*!40000 ALTER TABLE `stripe_refunds` DISABLE KEYS */;
/*!40000 ALTER TABLE `stripe_refunds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscriptions` (
  `subscription_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `channel` enum('email','sms','push','in_app') NOT NULL,
  `opt_in_status` tinyint(1) NOT NULL DEFAULT 1,
  `subscription_type` enum('marketing','transactional','notifications','all') NOT NULL DEFAULT 'all',
  `source` varchar(100) DEFAULT NULL,
  `opted_in_at` timestamp NULL DEFAULT NULL,
  `opted_out_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`subscription_id`),
  UNIQUE KEY `idx_user_channel_type` (`user_id`,`channel`,`subscription_type`),
  KEY `idx_channel` (`channel`),
  KEY `idx_opt_in_status` (`opt_in_status`),
  KEY `idx_subscription_type` (`subscription_type`),
  KEY `idx_subscriptions_user_channel` (`user_id`,`channel`,`opt_in_status`),
  CONSTRAINT `fk_subscriptions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
INSERT INTO `subscriptions` VALUES
(1,4,'email',1,'all',NULL,'2025-09-11 15:56:21',NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26');
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_messages`
--

DROP TABLE IF EXISTS `support_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_messages`
--

LOCK TABLES `support_messages` WRITE;
/*!40000 ALTER TABLE `support_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `support_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_ticket_messages`
--

DROP TABLE IF EXISTS `support_ticket_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_ticket_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ticket_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `is_staff` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_ticket_id` (`ticket_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `support_ticket_messages_ibfk_1` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `support_ticket_messages_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_ticket_messages`
--

LOCK TABLES `support_ticket_messages` WRITE;
/*!40000 ALTER TABLE `support_ticket_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `support_ticket_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_ticket_replies`
--

DROP TABLE IF EXISTS `support_ticket_replies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_ticket_replies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ticket_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `guest_email` varchar(255) DEFAULT NULL,
  `reply_type` enum('customer','admin','system','auto') NOT NULL DEFAULT 'customer',
  `message` text NOT NULL,
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
  `is_internal` tinyint(1) NOT NULL DEFAULT 0,
  `is_solution` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_ticket_id` (`ticket_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_reply_type` (`reply_type`),
  KEY `idx_is_internal` (`is_internal`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_support_ticket_replies_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_support_ticket_replies_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_ticket_replies`
--

LOCK TABLES `support_ticket_replies` WRITE;
/*!40000 ALTER TABLE `support_ticket_replies` DISABLE KEYS */;
/*!40000 ALTER TABLE `support_ticket_replies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_tickets`
--

DROP TABLE IF EXISTS `support_tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ticket_number` varchar(20) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `guest_email` varchar(255) DEFAULT NULL,
  `guest_name` varchar(100) DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `category` enum('general','technical','billing','shipping','returns','product','account','complaint','suggestion') NOT NULL DEFAULT 'general',
  `priority` enum('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `status` enum('open','in_progress','pending_customer','pending_vendor','escalated','resolved','closed') NOT NULL DEFAULT 'open',
  `description` text NOT NULL,
  `resolution` text DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `escalated_to` int(11) DEFAULT NULL,
  `related_order_id` int(11) DEFAULT NULL,
  `related_product_id` int(11) DEFAULT NULL,
  `satisfaction_rating` tinyint(1) DEFAULT NULL,
  `satisfaction_feedback` text DEFAULT NULL,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `first_response_at` timestamp NULL DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_ticket_number` (`ticket_number`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_guest_email` (`guest_email`),
  KEY `idx_category` (`category`),
  KEY `idx_priority` (`priority`),
  KEY `idx_status` (`status`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `idx_escalated_to` (`escalated_to`),
  KEY `idx_related_order_id` (`related_order_id`),
  KEY `idx_related_product_id` (`related_product_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_support_tickets_assignee` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_support_tickets_escalated` FOREIGN KEY (`escalated_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_support_tickets_order` FOREIGN KEY (`related_order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_support_tickets_product` FOREIGN KEY (`related_product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_support_tickets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_tickets`
--

LOCK TABLES `support_tickets` WRITE;
/*!40000 ALTER TABLE `support_tickets` DISABLE KEYS */;
/*!40000 ALTER TABLE `support_tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_alerts`
--

DROP TABLE IF EXISTS `system_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `alert_type` enum('security','performance','business','technical','compliance') NOT NULL,
  `severity` enum('info','warning','error','critical') NOT NULL DEFAULT 'info',
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `alert_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`alert_data`)),
  `is_resolved` tinyint(1) NOT NULL DEFAULT 0,
  `resolved_by` int(11) DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_alert_type` (`alert_type`),
  KEY `idx_severity` (`severity`),
  KEY `idx_is_resolved` (`is_resolved`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_resolved_by` (`resolved_by`),
  KEY `idx_system_alerts_type_severity` (`alert_type`,`severity`,`is_resolved`),
  CONSTRAINT `fk_system_alerts_resolver` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_alerts`
--

LOCK TABLES `system_alerts` WRITE;
/*!40000 ALTER TABLE `system_alerts` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_events`
--

DROP TABLE IF EXISTS `system_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_type` enum('performance','security','backup','maintenance','error','warning','info') NOT NULL,
  `severity` enum('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  `component` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `event_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`event_data`)),
  `metrics` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metrics`)),
  `is_resolved` tinyint(1) NOT NULL DEFAULT 0,
  `resolved_by` int(11) DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_severity` (`severity`),
  KEY `idx_component` (`component`),
  KEY `idx_is_resolved` (`is_resolved`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_system_events_resolver` (`resolved_by`),
  CONSTRAINT `fk_system_events_resolver` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_events`
--

LOCK TABLES `system_events` WRITE;
/*!40000 ALTER TABLE `system_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` longtext DEFAULT NULL,
  `setting_type` enum('string','integer','decimal','boolean','json','text') NOT NULL DEFAULT 'string',
  `category` varchar(50) NOT NULL DEFAULT 'general',
  `description` text DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `is_encrypted` tinyint(1) NOT NULL DEFAULT 0,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_setting_key` (`setting_key`),
  KEY `idx_category` (`category`),
  KEY `idx_is_public` (`is_public`),
  KEY `idx_updated_by` (`updated_by`),
  CONSTRAINT `fk_system_settings_user` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES
(0,'maintenance_mode','0','string','general',NULL,0,0,4,'2025-10-15 12:48:38','2025-10-15 18:29:09'),
(2,'maintenance_message','Site temporarily unavailable for maintenance.','string','general',NULL,0,0,4,'2025-10-15 12:48:38','2025-10-15 12:48:38');
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tags` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tax_rules`
--

DROP TABLE IF EXISTS `tax_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tax_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `tax_type` enum('vat','gst','sales_tax','other') NOT NULL,
  `rate` decimal(5,4) NOT NULL,
  `country` varchar(2) NOT NULL,
  `state` varchar(100) DEFAULT NULL,
  `postal_codes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`postal_codes`)),
  `product_categories` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`product_categories`)),
  `is_inclusive` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `effective_from` date NOT NULL,
  `effective_to` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_country` (`country`),
  KEY `idx_state` (`state`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_effective_from` (`effective_from`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tax_rules`
--

LOCK TABLES `tax_rules` WRITE;
/*!40000 ALTER TABLE `tax_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `tax_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `templates`
--

DROP TABLE IF EXISTS `templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `template_type` enum('email','sms','notification','page','component') NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `content` longtext NOT NULL,
  `variables` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`variables`)),
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_template_type` (`template_type`),
  KEY `idx_is_system` (`is_system`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_templates_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `templates`
--

LOCK TABLES `templates` WRITE;
/*!40000 ALTER TABLE `templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `type` enum('payment','refund','partial_refund','chargeback','fee') NOT NULL,
  `status` enum('pending','completed','failed','cancelled') NOT NULL DEFAULT 'pending',
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'USD',
  `payment_method` varchar(50) DEFAULT NULL,
  `gateway` varchar(50) DEFAULT NULL,
  `gateway_transaction_id` varchar(255) DEFAULT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `gateway_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`gateway_response`)),
  `fees` decimal(10,2) NOT NULL DEFAULT 0.00,
  `notes` text DEFAULT NULL,
  `processed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_status` (`status`),
  KEY `idx_gateway_transaction_id` (`gateway_transaction_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_transactions_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_transactions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `unsubscribe_links`
--

DROP TABLE IF EXISTS `unsubscribe_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `unsubscribe_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(255) NOT NULL,
  `user_id` int(11) NOT NULL,
  `channel` enum('email','sms','push','in_app') NOT NULL,
  `subscription_type` enum('marketing','transactional','notifications','all') NOT NULL DEFAULT 'marketing',
  `message_id` int(11) DEFAULT NULL,
  `is_used` tinyint(1) NOT NULL DEFAULT 0,
  `used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_token` (`token`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_channel` (`channel`),
  KEY `idx_message_id` (`message_id`),
  KEY `idx_is_used` (`is_used`),
  CONSTRAINT `fk_unsubscribe_links_message` FOREIGN KEY (`message_id`) REFERENCES `comm_messages` (`message_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_unsubscribe_links_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `unsubscribe_links`
--

LOCK TABLES `unsubscribe_links` WRITE;
/*!40000 ALTER TABLE `unsubscribe_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `unsubscribe_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_activities`
--

DROP TABLE IF EXISTS `user_activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_activities` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `session_id` varchar(64) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `activity_type` enum('view','add_to_cart','purchase') NOT NULL DEFAULT 'view',
  `context` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`context`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_activities_user` (`user_id`),
  KEY `idx_user_activities_product` (`product_id`),
  KEY `idx_user_activities_session` (`session_id`),
  KEY `idx_user_activities_action` (`activity_type`),
  KEY `idx_user_activities_created` (`created_at`),
  CONSTRAINT `fk_user_activities_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_activities`
--

LOCK TABLES `user_activities` WRITE;
/*!40000 ALTER TABLE `user_activities` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_addresses`
--

DROP TABLE IF EXISTS `user_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `address_type` enum('billing','shipping') NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `address_line` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `postal_code` varchar(50) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_addresses`
--

LOCK TABLES `user_addresses` WRITE;
/*!40000 ALTER TABLE `user_addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_audit_logs`
--

DROP TABLE IF EXISTS `user_audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `action` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_user_audit_logs_admin` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_audit_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_audit_logs`
--

LOCK TABLES `user_audit_logs` WRITE;
/*!40000 ALTER TABLE `user_audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_documents`
--

DROP TABLE IF EXISTS `user_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `document_type` enum('identity','address','business','tax','other') NOT NULL,
  `document_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint(20) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `verification_status` enum('pending','approved','rejected','expired') NOT NULL DEFAULT 'pending',
  `verified_by` int(11) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_verification_status` (`verification_status`),
  KEY `idx_verified_by` (`verified_by`),
  CONSTRAINT `fk_user_documents_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_documents_verifier` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_documents`
--

LOCK TABLES `user_documents` WRITE;
/*!40000 ALTER TABLE `user_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_follows`
--

DROP TABLE IF EXISTS `user_follows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_follows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `follower_id` int(11) NOT NULL,
  `following_id` int(11) NOT NULL,
  `type` enum('user','vendor') NOT NULL DEFAULT 'user',
  `notifications_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_follower_following` (`follower_id`,`following_id`,`type`),
  KEY `idx_following_id` (`following_id`),
  KEY `idx_type` (`type`),
  CONSTRAINT `fk_user_follows_follower` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_follows_following` FOREIGN KEY (`following_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_follows`
--

LOCK TABLES `user_follows` WRITE;
/*!40000 ALTER TABLE `user_follows` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_follows` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_logins`
--

DROP TABLE IF EXISTS `user_logins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_logins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `login_type` enum('password','oauth','two_factor','sso') NOT NULL DEFAULT 'password',
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `device_info` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`device_info`)),
  `success` tinyint(1) NOT NULL DEFAULT 1,
  `failure_reason` varchar(255) DEFAULT NULL,
  `session_duration` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_login_type` (`login_type`),
  KEY `idx_ip_address` (`ip_address`),
  KEY `idx_success` (`success`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_user_logins_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_logins`
--

LOCK TABLES `user_logins` WRITE;
/*!40000 ALTER TABLE `user_logins` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_logins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_payment_methods`
--

DROP TABLE IF EXISTS `user_payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_payment_methods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `stripe_payment_method_id` varchar(255) DEFAULT NULL,
  `brand` varchar(50) DEFAULT NULL,
  `last4` varchar(4) DEFAULT NULL,
  `exp_month` int(11) DEFAULT NULL,
  `exp_year` int(11) DEFAULT NULL,
  `is_default` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_stripe_pm_id` (`stripe_payment_method_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_payment_methods`
--

LOCK TABLES `user_payment_methods` WRITE;
/*!40000 ALTER TABLE `user_payment_methods` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_preferences`
--

DROP TABLE IF EXISTS `user_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_preferences` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `language` varchar(10) DEFAULT 'en',
  `currency` varchar(10) DEFAULT 'USD',
  `timezone` varchar(50) DEFAULT 'UTC',
  `marketing_opt_in` tinyint(1) DEFAULT 1,
  `email_notifications` tinyint(1) DEFAULT 1,
  `sms_notifications` tinyint(1) DEFAULT 0,
  `push_notifications` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_prefs` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_preferences`
--

LOCK TABLES `user_preferences` WRITE;
/*!40000 ALTER TABLE `user_preferences` DISABLE KEYS */;
INSERT INTO `user_preferences` VALUES
(1,4,'en','USD','UTC',0,0,0,0,'2025-10-13 01:14:29','2025-10-13 01:42:33');
/*!40000 ALTER TABLE `user_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_product_views`
--

DROP TABLE IF EXISTS `user_product_views`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_product_views` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `product_id` int(11) NOT NULL,
  `session_id` varchar(100) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `referrer` varchar(500) DEFAULT NULL,
  `view_duration` int(11) DEFAULT 0 COMMENT 'Time spent viewing in seconds',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_session_id` (`session_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_user_product` (`user_id`,`product_id`),
  CONSTRAINT `fk_upv_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_upv_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=337 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_product_views`
--

LOCK TABLES `user_product_views` WRITE;
/*!40000 ALTER TABLE `user_product_views` DISABLE KEYS */;
INSERT INTO `user_product_views` VALUES
(2,4,5,'gllkuju74p0bk7lnfkvtmv7hi7','172.68.42.185','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://duns1.fezalogistics.com/product.php?id=5',10,'2025-10-04 10:27:40'),
(3,4,6,'gllkuju74p0bk7lnfkvtmv7hi7','172.68.42.184','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://duns1.fezalogistics.com/product.php?id=6',10,'2025-10-04 10:42:36'),
(6,4,6,'gllkuju74p0bk7lnfkvtmv7hi7','197.234.243.89','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://duns1.fezalogistics.com/product.php?id=6',5,'2025-10-04 10:54:15'),
(9,4,5,'2fcoj19v80drm3chn628c8dp8o','172.68.42.185','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://duns1.fezalogistics.com/product.php?id=5',5,'2025-10-05 10:46:48'),
(10,4,5,'5t4fmnsk376h5v7e9rj20i02rm','197.234.243.89','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://duns1.fezalogistics.com/product.php?id=5',3,'2025-10-05 12:49:14'),
(13,NULL,6,'0hqqd50ab5n6qbq01jljt2e4t7','172.68.42.185','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','https://duns1.fezalogistics.com/product.php?id=6',54,'2025-10-05 20:45:12'),
(15,4,5,'7nj1qibuv935ev4u2dcdbsb5df','197.234.243.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://duns1.fezalogistics.com/product.php?id=5',286,'2025-10-05 22:59:10'),
(16,4,5,'7k06j81h4qqthu36dse9pect81','172.69.254.165','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://duns1.fezalogistics.com/product.php?id=5',6,'2025-10-06 10:44:08'),
(17,4,5,'7k06j81h4qqthu36dse9pect81','172.69.254.165','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://duns1.fezalogistics.com/product.php?id=5',4,'2025-10-06 10:47:22'),
(18,NULL,5,'ig79tt2ahh2als6fig484b726h','172.68.42.185','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','https://duns1.fezalogistics.com/product.php?id=5',13,'2025-10-06 11:14:11'),
(21,4,5,'9ag5gnnn9b4kk0ebuodo86j48g','172.68.42.185','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://duns1.fezalogistics.com/product.php?id=5',13,'2025-10-06 21:48:45'),
(22,4,5,'9ag5gnnn9b4kk0ebuodo86j48g','172.68.42.185','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://duns1.fezalogistics.com/product.php?id=5',1,'2025-10-06 21:48:49'),
(26,NULL,5,'9ag5gnnn9b4kk0ebuodo86j48g','197.234.243.78','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://duns1.fezalogistics.com/product.php?id=5',9,'2025-10-06 22:40:11'),
(27,NULL,6,'n0rlrahh7tta62j23g0kdd4rdv','172.68.42.137','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',283,'2025-10-07 06:56:47'),
(28,NULL,6,'n0rlrahh7tta62j23g0kdd4rdv','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',327,'2025-10-07 07:02:26'),
(29,NULL,5,'n0rlrahh7tta62j23g0kdd4rdv','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',13,'2025-10-07 07:03:40'),
(32,NULL,5,'n0rlrahh7tta62j23g0kdd4rdv','172.68.42.99','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',5,'2025-10-07 07:05:36'),
(33,NULL,5,'n0rlrahh7tta62j23g0kdd4rdv','172.68.42.99','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',6,'2025-10-07 07:05:37'),
(34,NULL,5,'n0rlrahh7tta62j23g0kdd4rdv','172.68.42.98','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',5,'2025-10-07 07:05:37'),
(35,NULL,5,'n0rlrahh7tta62j23g0kdd4rdv','172.68.42.98','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',6,'2025-10-07 07:05:37'),
(45,4,5,'srro74jd0kk9ui75h5e0f12tim','172.68.102.251','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',33,'2025-10-07 08:16:33'),
(46,4,5,'srro74jd0kk9ui75h5e0f12tim','172.68.102.250','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',7,'2025-10-07 08:16:58'),
(47,4,5,'srro74jd0kk9ui75h5e0f12tim','172.68.102.250','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',4,'2025-10-07 08:17:52'),
(48,4,5,'srro74jd0kk9ui75h5e0f12tim','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',1579,'2025-10-07 08:45:58'),
(49,4,5,'srro74jd0kk9ui75h5e0f12tim','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',466,'2025-10-07 08:53:45'),
(50,4,5,'srro74jd0kk9ui75h5e0f12tim','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',0,'2025-10-07 08:53:47'),
(61,NULL,6,'l0u1vnvvp3c2jb8hjk9tuin62r','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',5,'2025-10-07 19:52:20'),
(62,4,6,'6i92l19mjuvbidpk2vgn6tsapt','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',4,'2025-10-07 19:53:52'),
(64,NULL,5,'qfsru5fi6vnmbsgqdpihfqagdv','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',15,'2025-10-07 20:02:33'),
(68,4,5,'brg0qejtnkjch2cfadgqa6n51v','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',9,'2025-10-07 20:44:47'),
(71,4,6,'e0khufm7guchnts4s22poj5861','172.68.42.48','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',13,'2025-10-07 23:52:32'),
(72,NULL,5,'mouqtvdj9bfdu70i6j3lvjh0jc','172.68.42.130','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',3,'2025-10-08 07:06:47'),
(113,NULL,6,'6i92l19mjuvbidpk2vgn6tsapt','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',3,'2025-10-10 06:14:58'),
(114,4,5,'31ho1rvpr8d4de689krn7198la','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',3,'2025-10-10 06:15:38'),
(115,4,5,'31ho1rvpr8d4de689krn7198la','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',10,'2025-10-10 06:16:26'),
(120,4,6,'rgsf62dhl1p5l8jj9gqa7bh3lf','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',5,'2025-10-10 06:44:25'),
(127,4,6,'31ho1rvpr8d4de689krn7198la','172.68.102.31','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',37,'2025-10-10 13:59:29'),
(128,4,5,'2807ue477bl310s3madbcc8nhs','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',3,'2025-10-11 07:07:12'),
(129,4,5,'2807ue477bl310s3madbcc8nhs','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',10,'2025-10-11 07:11:06'),
(130,4,5,'2807ue477bl310s3madbcc8nhs','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',6,'2025-10-11 08:26:20'),
(131,NULL,6,'j5952lmfsm47t1eembd07el9m9','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',53,'2025-10-11 08:29:04'),
(132,NULL,6,'j5952lmfsm47t1eembd07el9m9','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',757,'2025-10-11 08:43:33'),
(133,4,5,'2807ue477bl310s3madbcc8nhs','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',1276,'2025-10-11 08:47:40'),
(134,NULL,6,'j5952lmfsm47t1eembd07el9m9','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',10,'2025-10-11 09:38:56'),
(135,NULL,6,'j5952lmfsm47t1eembd07el9m9','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',2,'2025-10-11 09:39:04'),
(136,NULL,6,'j5952lmfsm47t1eembd07el9m9','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',5,'2025-10-11 09:39:11'),
(137,NULL,6,'j5952lmfsm47t1eembd07el9m9','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',422,'2025-10-11 09:46:36'),
(138,NULL,6,'j5952lmfsm47t1eembd07el9m9','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',422,'2025-10-11 09:46:37'),
(139,NULL,6,'j5952lmfsm47t1eembd07el9m9','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',422,'2025-10-11 09:46:37'),
(140,NULL,5,'j5952lmfsm47t1eembd07el9m9','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',1,'2025-10-11 09:46:39'),
(141,4,5,'2807ue477bl310s3madbcc8nhs','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',521,'2025-10-11 09:46:53'),
(142,NULL,6,'j5952lmfsm47t1eembd07el9m9','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',669,'2025-10-11 09:57:59'),
(143,NULL,6,'j5952lmfsm47t1eembd07el9m9','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',669,'2025-10-11 09:57:59'),
(144,NULL,5,'f7p99vs71qmibjjdmabpi6d927','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',5,'2025-10-11 12:28:02'),
(145,NULL,6,'j5952lmfsm47t1eembd07el9m9','172.69.254.162','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',19,'2025-10-11 12:29:24'),
(146,NULL,5,'j5952lmfsm47t1eembd07el9m9','172.69.254.162','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',16,'2025-10-11 12:29:48'),
(147,NULL,6,'j5952lmfsm47t1eembd07el9m9','172.69.254.162','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',60,'2025-10-11 12:31:07'),
(148,NULL,6,'j5952lmfsm47t1eembd07el9m9','172.69.254.162','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',4,'2025-10-11 12:31:22'),
(149,NULL,5,'j5952lmfsm47t1eembd07el9m9','172.69.254.163','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',2,'2025-10-11 13:12:07'),
(150,NULL,5,'j5952lmfsm47t1eembd07el9m9','172.69.254.162','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',5,'2025-10-11 13:12:13'),
(151,NULL,5,'j5952lmfsm47t1eembd07el9m9','172.69.254.163','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',12,'2025-10-11 13:12:27'),
(152,NULL,5,'f7p99vs71qmibjjdmabpi6d927','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',3,'2025-10-11 13:16:46'),
(153,4,5,'jlvne7vf83e5gc3491l8r0iic9','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',3,'2025-10-11 13:17:07'),
(154,4,5,'jlvne7vf83e5gc3491l8r0iic9','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',4,'2025-10-11 13:34:52'),
(155,4,8,'jlvne7vf83e5gc3491l8r0iic9','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',24,'2025-10-11 13:49:37'),
(156,4,8,'jlvne7vf83e5gc3491l8r0iic9','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',913,'2025-10-11 14:04:57'),
(157,4,8,'jlvne7vf83e5gc3491l8r0iic9','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',11,'2025-10-11 14:10:34'),
(158,4,8,'jlvne7vf83e5gc3491l8r0iic9','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',8,'2025-10-11 14:11:00'),
(159,NULL,8,'j5952lmfsm47t1eembd07el9m9','172.69.254.163','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',12,'2025-10-11 14:26:38'),
(160,NULL,8,'j5952lmfsm47t1eembd07el9m9','172.69.254.163','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',10,'2025-10-11 14:26:50'),
(161,NULL,8,'j5952lmfsm47t1eembd07el9m9','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',509,'2025-10-11 14:35:21'),
(162,NULL,8,'j5952lmfsm47t1eembd07el9m9','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',126,'2025-10-11 14:38:00'),
(163,NULL,8,'j5952lmfsm47t1eembd07el9m9','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',135,'2025-10-11 14:48:35'),
(164,NULL,6,'j5952lmfsm47t1eembd07el9m9','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',9,'2025-10-11 14:48:58'),
(165,4,8,'t1mfs5jjn6ta6sga4ono773psd','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',4,'2025-10-11 14:49:40'),
(166,4,8,'t1mfs5jjn6ta6sga4ono773psd','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',8,'2025-10-11 15:00:35'),
(167,NULL,8,'m4u1ji9e8e4uv5s86delv39hcu','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',8,'2025-10-11 15:08:00'),
(168,NULL,6,'m4u1ji9e8e4uv5s86delv39hcu','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',296,'2025-10-11 15:13:02'),
(169,NULL,8,'m4u1ji9e8e4uv5s86delv39hcu','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',8,'2025-10-11 15:13:22'),
(170,4,8,'q96676n6ep6cvns8kmsm73n8i9','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',3,'2025-10-11 15:15:32'),
(171,NULL,6,'prg5torb5fjogf8cgd5b2htebt','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',2,'2025-10-11 15:15:52'),
(172,4,8,'1fdchgk3katm2l1lcek2a1bh92','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',2,'2025-10-11 15:16:12'),
(173,4,6,'1fdchgk3katm2l1lcek2a1bh92','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',2,'2025-10-11 15:16:50'),
(174,4,6,'1fdchgk3katm2l1lcek2a1bh92','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',2,'2025-10-11 15:17:40'),
(175,NULL,6,'4nul5ml5r2v85vi3av93a2dd24','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',3,'2025-10-11 15:56:17'),
(176,4,6,'cfa99v6lceldpt40qqnb4et6vv','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',3,'2025-10-11 15:56:48'),
(177,4,8,'cfa99v6lceldpt40qqnb4et6vv','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',37,'2025-10-11 15:58:06'),
(178,4,9,'t1mfs5jjn6ta6sga4ono773psd','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',26,'2025-10-11 16:03:49'),
(179,4,9,'t1mfs5jjn6ta6sga4ono773psd','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',8,'2025-10-11 16:03:58'),
(180,4,8,'cfa99v6lceldpt40qqnb4et6vv','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',2,'2025-10-11 16:26:21'),
(181,4,9,'cfa99v6lceldpt40qqnb4et6vv','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',6,'2025-10-11 16:26:32'),
(182,4,8,'cfa99v6lceldpt40qqnb4et6vv','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',7,'2025-10-11 16:26:39'),
(183,4,8,'cfa99v6lceldpt40qqnb4et6vv','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',3,'2025-10-11 16:53:36'),
(184,4,9,'cfa99v6lceldpt40qqnb4et6vv','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',2,'2025-10-11 16:53:39'),
(185,4,8,'cfa99v6lceldpt40qqnb4et6vv','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',26,'2025-10-11 16:54:05'),
(186,4,8,'cfa99v6lceldpt40qqnb4et6vv','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',59,'2025-10-11 16:55:13'),
(187,4,8,'cfa99v6lceldpt40qqnb4et6vv','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',1731,'2025-10-11 17:28:10'),
(188,4,8,'cfa99v6lceldpt40qqnb4et6vv','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',4,'2025-10-11 17:28:19'),
(189,4,8,'nddsj70nsgvnbd7utpe5cmf8fu','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',4,'2025-10-11 17:29:00'),
(190,NULL,9,'t1mfs5jjn6ta6sga4ono773psd','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',5,'2025-10-11 17:45:42'),
(191,4,9,'iok8e9gst4vj66uh7t35u713hp','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',3,'2025-10-11 17:46:30'),
(192,NULL,8,'8draicjh6225hhlgpt4hu0tp7n','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',3,'2025-10-11 18:50:08'),
(193,4,6,'aqa1rgdo5prd7hrnchiodro68n','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',3,'2025-10-11 18:50:34'),
(194,4,8,'aqa1rgdo5prd7hrnchiodro68n','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',3,'2025-10-11 19:19:47'),
(195,4,9,'iok8e9gst4vj66uh7t35u713hp','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',11,'2025-10-11 19:30:06'),
(196,4,5,'iok8e9gst4vj66uh7t35u713hp','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',14,'2025-10-11 19:31:11'),
(197,4,6,'elpdddh4gn7ja6kou7mn3051dt','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',2,'2025-10-11 20:50:33'),
(198,4,6,'elpdddh4gn7ja6kou7mn3051dt','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',1,'2025-10-11 20:52:19'),
(199,4,6,'elpdddh4gn7ja6kou7mn3051dt','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',5,'2025-10-11 20:52:28'),
(200,4,9,'iok8e9gst4vj66uh7t35u713hp','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',6,'2025-10-11 20:55:57'),
(201,4,7,'elpdddh4gn7ja6kou7mn3051dt','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=7',3443,'2025-10-11 21:04:20'),
(202,4,10,'elpdddh4gn7ja6kou7mn3051dt','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',36,'2025-10-11 21:09:07'),
(203,4,10,'elpdddh4gn7ja6kou7mn3051dt','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',32,'2025-10-11 21:10:14'),
(204,4,10,'l7f5n6ul15aoae222gnk4373c0','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',61,'2025-10-11 21:12:02'),
(205,4,9,'l7f5n6ul15aoae222gnk4373c0','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',378,'2025-10-11 21:18:27'),
(206,4,10,'l7f5n6ul15aoae222gnk4373c0','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',188,'2025-10-11 21:21:37'),
(207,4,10,'l7f5n6ul15aoae222gnk4373c0','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',9,'2025-10-11 21:29:48'),
(208,4,5,'iok8e9gst4vj66uh7t35u713hp','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=5',13,'2025-10-11 21:37:00'),
(209,4,9,'iok8e9gst4vj66uh7t35u713hp','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',1,'2025-10-11 21:37:09'),
(210,4,9,'iok8e9gst4vj66uh7t35u713hp','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',6,'2025-10-11 21:37:16'),
(211,4,9,'iok8e9gst4vj66uh7t35u713hp','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',5,'2025-10-11 21:37:54'),
(212,4,8,'iok8e9gst4vj66uh7t35u713hp','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',8,'2025-10-11 21:38:03'),
(213,4,8,'iok8e9gst4vj66uh7t35u713hp','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',10,'2025-10-11 21:38:15'),
(214,4,8,'iok8e9gst4vj66uh7t35u713hp','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',11,'2025-10-11 21:38:16'),
(215,4,9,'iok8e9gst4vj66uh7t35u713hp','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',8,'2025-10-11 21:38:25'),
(216,4,8,'iok8e9gst4vj66uh7t35u713hp','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',51,'2025-10-11 21:39:18'),
(217,4,9,'iok8e9gst4vj66uh7t35u713hp','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',4,'2025-10-11 21:39:24'),
(218,NULL,10,'mvdvgcftsrndpkuu6ruo2j4p1t','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',29,'2025-10-11 21:58:14'),
(219,NULL,10,'iok8e9gst4vj66uh7t35u713hp','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',8,'2025-10-11 21:59:15'),
(220,NULL,9,'iok8e9gst4vj66uh7t35u713hp','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',7,'2025-10-11 21:59:24'),
(221,4,10,'0bnm5hv07glv115823nb4p6kbf','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',4,'2025-10-11 22:07:14'),
(222,4,10,'0bnm5hv07glv115823nb4p6kbf','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',2,'2025-10-11 22:07:37'),
(223,4,10,'0bnm5hv07glv115823nb4p6kbf','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',2,'2025-10-11 22:08:39'),
(224,4,10,'0bnm5hv07glv115823nb4p6kbf','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',5,'2025-10-11 22:08:54'),
(225,NULL,8,'iok8e9gst4vj66uh7t35u713hp','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',671,'2025-10-11 22:10:37'),
(226,NULL,10,'iok8e9gst4vj66uh7t35u713hp','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',105,'2025-10-11 22:12:24'),
(227,NULL,9,'iok8e9gst4vj66uh7t35u713hp','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',1,'2025-10-11 22:12:27'),
(228,NULL,9,'iok8e9gst4vj66uh7t35u713hp','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',8,'2025-10-11 22:12:37'),
(229,4,10,'0bnm5hv07glv115823nb4p6kbf','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',1,'2025-10-11 22:23:58'),
(232,NULL,10,'iok8e9gst4vj66uh7t35u713hp','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',1836,'2025-10-11 22:43:15'),
(233,NULL,9,'iok8e9gst4vj66uh7t35u713hp','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',6,'2025-10-11 22:43:23'),
(234,NULL,9,'iok8e9gst4vj66uh7t35u713hp','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',1,'2025-10-11 22:43:44'),
(235,NULL,10,'iok8e9gst4vj66uh7t35u713hp','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',551,'2025-10-11 22:52:56'),
(237,NULL,8,'iok8e9gst4vj66uh7t35u713hp','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',839,'2025-10-11 23:06:57'),
(238,NULL,10,'iok8e9gst4vj66uh7t35u713hp','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',5,'2025-10-11 23:07:04'),
(244,4,9,'e43fd8c0uqbo2t2go3p2sidjge','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',234,'2025-10-12 00:23:34'),
(245,4,10,'e43fd8c0uqbo2t2go3p2sidjge','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',984,'2025-10-12 00:53:44'),
(247,NULL,6,'iok8e9gst4vj66uh7t35u713hp','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',17,'2025-10-12 01:31:16'),
(249,NULL,9,'5ohi350tnda3up55v4tv89vhbj','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',6,'2025-10-12 09:47:38'),
(250,4,9,'sfvlhdsjds7paphonbqefm0nev','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',5,'2025-10-12 10:44:46'),
(251,4,9,'bhr0q5bhtkkeu4igc7jqaol3aj','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',2,'2025-10-12 12:01:10'),
(252,4,9,'bhr0q5bhtkkeu4igc7jqaol3aj','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',3,'2025-10-12 12:54:34'),
(253,NULL,10,'bhr0q5bhtkkeu4igc7jqaol3aj','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',1628,'2025-10-12 13:41:03'),
(255,4,10,'6q5blmm47f1tu8nnjjato7fh7j','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',5,'2025-10-12 14:32:07'),
(256,NULL,8,'6ojo5a1io8i55se18o4hvlo88k','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',3,'2025-10-12 16:00:18'),
(257,19,10,'l5d4uc2dn2sfnmi7snhlu1cmsr','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',11,'2025-10-12 16:11:01'),
(258,19,6,'l5d4uc2dn2sfnmi7snhlu1cmsr','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',56,'2025-10-12 16:12:37'),
(259,4,8,'vd930l9bd8g33tfup18n5up3f3','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',3,'2025-10-12 16:21:27'),
(261,19,10,'1ooc0c6lanmvtfsoqigp9ih2o5','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',3,'2025-10-12 16:29:51'),
(262,19,8,'1ooc0c6lanmvtfsoqigp9ih2o5','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',2,'2025-10-12 16:29:55'),
(263,19,10,'1ooc0c6lanmvtfsoqigp9ih2o5','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',4,'2025-10-12 16:30:00'),
(264,4,8,'hqvaopa3o824fet5jqce8eii0f','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',10,'2025-10-12 17:36:03'),
(265,19,10,'1ooc0c6lanmvtfsoqigp9ih2o5','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',3,'2025-10-12 18:27:57'),
(266,19,8,'1ooc0c6lanmvtfsoqigp9ih2o5','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=8',5,'2025-10-12 18:28:04'),
(267,19,10,'1ooc0c6lanmvtfsoqigp9ih2o5','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',2,'2025-10-12 18:28:08'),
(268,NULL,10,'2esk9a2gftdefp31aqp08hdpf4','172.70.163.86','Mozilla/5.0 (Linux; Android 10; SM-A750F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.50 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',2,'2025-10-12 22:16:46'),
(269,4,10,'jblapfg5nbj2bpk69nen2jfgae','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',14,'2025-10-12 23:16:28'),
(270,4,10,'jblapfg5nbj2bpk69nen2jfgae','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',181,'2025-10-12 23:19:39'),
(271,4,10,'jblapfg5nbj2bpk69nen2jfgae','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',38,'2025-10-12 23:20:21'),
(272,4,10,'jblapfg5nbj2bpk69nen2jfgae','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',3,'2025-10-12 23:53:05'),
(275,NULL,10,'s4svdvh04jvbf25namo3gqeve3','172.70.108.84','Mozilla/5.0 (Linux; Android 10; SM-A750F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.50 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',2,'2025-10-13 01:27:21'),
(276,NULL,6,'s4svdvh04jvbf25namo3gqeve3','172.70.108.84','Mozilla/5.0 (Linux; Android 10; SM-A750F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.50 Mobile Safari/537.36','https://fezamarket.com/product.php?id=6',1,'2025-10-13 01:27:29'),
(277,NULL,9,'1ooc0c6lanmvtfsoqigp9ih2o5','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',4,'2025-10-13 06:02:39'),
(278,NULL,9,'1ooc0c6lanmvtfsoqigp9ih2o5','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=9',0,'2025-10-13 06:02:40'),
(279,NULL,10,'7j516rchcr6qfpeobfddlhcbh2','172.68.42.71','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',2,'2025-10-13 06:33:28'),
(280,4,13,'428anduhsf60hfqh3h5b0hp6vb','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',17,'2025-10-13 09:17:04'),
(282,4,8,'428anduhsf60hfqh3h5b0hp6vb','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',2,'2025-10-13 10:33:57'),
(284,NULL,13,'1ooc0c6lanmvtfsoqigp9ih2o5','172.68.102.117','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=13',5,'2025-10-13 12:28:14'),
(285,NULL,13,'1ooc0c6lanmvtfsoqigp9ih2o5','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=13',1,'2025-10-13 14:21:10'),
(286,NULL,13,'1ooc0c6lanmvtfsoqigp9ih2o5','172.68.42.71','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=13',8,'2025-10-13 14:21:22'),
(287,NULL,13,'sjhme14ob2un2dehjdtr0te03p','172.68.103.106','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',4,'2025-10-14 10:01:13'),
(288,4,13,'btqffktbplbctf2dqcrkft85s1','172.68.103.106','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',2,'2025-10-14 10:01:31'),
(289,4,9,'btqffktbplbctf2dqcrkft85s1','172.68.103.106','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',3,'2025-10-14 10:16:24'),
(290,4,13,'2dtpit6mo5l9ms5u0jlfdfn811','172.64.236.185','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',2,'2025-10-14 11:02:32'),
(291,4,13,'piq5tnhjjgu4qonokethqmph9t','172.68.47.141','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',3,'2025-10-14 13:08:27'),
(292,4,13,'piq5tnhjjgu4qonokethqmph9t','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',7,'2025-10-14 13:50:20'),
(293,4,13,'piq5tnhjjgu4qonokethqmph9t','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',2,'2025-10-14 14:15:25'),
(294,4,10,'piq5tnhjjgu4qonokethqmph9t','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',849,'2025-10-14 14:31:03'),
(295,NULL,13,'1ooc0c6lanmvtfsoqigp9ih2o5','172.68.102.77','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=13',4,'2025-10-14 18:17:53'),
(296,4,13,'cmoad5n5dn6q5m06gd9olgvo8h','172.68.102.77','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=13',5,'2025-10-14 18:18:31'),
(297,4,10,'bbfsibqmj6o1nrlcj4jrkq91md','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',2,'2025-10-14 21:14:17'),
(298,4,13,'0mrtedasd7qhb4b1kf42pk9sv1','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',10,'2025-10-15 09:03:16'),
(299,4,6,'0mrtedasd7qhb4b1kf42pk9sv1','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=6',5,'2025-10-15 10:14:38'),
(300,4,9,'0mrtedasd7qhb4b1kf42pk9sv1','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',2,'2025-10-15 10:14:49'),
(301,4,13,'cmoad5n5dn6q5m06gd9olgvo8h','197.234.242.127','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=13',4,'2025-10-15 11:20:16'),
(302,4,13,'5vpolhpdtb10eslgr95askrjtg','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=13',10,'2025-10-15 11:21:00'),
(303,4,8,'cmei29b56271fstgqsfgoeiamt','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',6,'2025-10-15 15:08:23'),
(304,4,13,'5vpolhpdtb10eslgr95askrjtg','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=13',2199,'2025-10-15 20:11:59'),
(305,4,13,'5vpolhpdtb10eslgr95askrjtg','197.234.242.126','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=13',5,'2025-10-15 20:12:11'),
(306,4,13,'5vpolhpdtb10eslgr95askrjtg','172.68.42.70','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=13',15,'2025-10-15 20:13:09'),
(307,4,13,'ftfbvp812s6ob84h7rsl62qefr','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',4,'2025-10-15 22:39:56'),
(308,NULL,9,'64t9ncbe1ucnvcavjufv9mvpjs','172.68.102.78','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',3,'2025-10-16 07:28:22'),
(309,4,10,'kf2bqsknac6mcoder898i52r90','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=10',160,'2025-10-16 07:37:56'),
(310,4,8,'kf2bqsknac6mcoder898i52r90','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',4,'2025-10-16 07:38:02'),
(311,4,8,'kf2bqsknac6mcoder898i52r90','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',626,'2025-10-16 07:52:45'),
(312,4,8,'s1n3bno0c2uevk7g55t1u0nd17','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',2606,'2025-10-16 10:55:51'),
(313,4,13,'s88eo8g520qkmao8njj7ae3kup','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',104,'2025-10-16 10:58:05'),
(314,4,13,'s88eo8g520qkmao8njj7ae3kup','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',4,'2025-10-16 10:58:11'),
(315,4,8,'s88eo8g520qkmao8njj7ae3kup','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=8',2,'2025-10-16 11:23:26'),
(316,NULL,13,'3tr5ltr3eaub2gtisopjcr8oim','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',118,'2025-10-16 11:39:10'),
(317,NULL,13,'3tr5ltr3eaub2gtisopjcr8oim','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',1,'2025-10-16 11:41:25'),
(318,NULL,13,'oj713v50j5apj5md8996rfk7po','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',1,'2025-10-16 12:04:53'),
(319,NULL,9,'oj713v50j5apj5md8996rfk7po','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',3,'2025-10-16 12:05:02'),
(320,NULL,13,'12be7oit82h24fjinudhc2dk29','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',0,'2025-10-16 12:33:42'),
(321,NULL,13,'12be7oit82h24fjinudhc2dk29','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',7,'2025-10-16 12:34:37'),
(322,NULL,13,'12be7oit82h24fjinudhc2dk29','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',1,'2025-10-16 13:57:07'),
(323,NULL,13,'12be7oit82h24fjinudhc2dk29','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',3,'2025-10-16 14:44:08'),
(324,NULL,10,'mdo4f2elkij5s2ks2t9f7pj4jn','104.23.175.20','Mozilla/5.0 (Linux; Android 10; SM-A750F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.50 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',8,'2025-10-16 15:16:35'),
(325,NULL,10,'mdo4f2elkij5s2ks2t9f7pj4jn','104.23.175.21','Mozilla/5.0 (Linux; Android 10; SM-A750F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.50 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',8,'2025-10-16 15:16:35'),
(326,NULL,10,'mdo4f2elkij5s2ks2t9f7pj4jn','104.23.175.20','Mozilla/5.0 (Linux; Android 10; SM-A750F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.50 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',3,'2025-10-16 15:16:56'),
(327,NULL,10,'mdo4f2elkij5s2ks2t9f7pj4jn','104.23.175.20','Mozilla/5.0 (Linux; Android 10; SM-A750F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.50 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',3,'2025-10-16 15:16:56'),
(328,NULL,10,'mdo4f2elkij5s2ks2t9f7pj4jn','104.23.175.20','Mozilla/5.0 (Linux; Android 10; SM-A750F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.50 Mobile Safari/537.36','https://fezamarket.com/product.php?id=10',3,'2025-10-16 15:16:56'),
(329,NULL,5,'12be7oit82h24fjinudhc2dk29','172.69.254.162','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=5',5,'2025-10-16 16:34:14'),
(330,NULL,9,'12be7oit82h24fjinudhc2dk29','172.69.254.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',19,'2025-10-16 16:34:40'),
(331,4,13,'5vpolhpdtb10eslgr95askrjtg','172.69.170.148','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','https://fezamarket.com/product.php?id=13',2,'2025-10-16 18:44:06'),
(332,4,13,'5klap4s6aptga08p9rm0scl5uo','197.234.242.127','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',5,'2025-10-16 22:18:18'),
(333,NULL,13,'unotopsatht49ik7q5jissgosn','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',1,'2025-10-16 22:39:31'),
(334,NULL,9,'unotopsatht49ik7q5jissgosn','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=9',1,'2025-10-16 22:39:36'),
(335,NULL,13,'unotopsatht49ik7q5jissgosn','197.234.242.126','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',1,'2025-10-16 22:39:42'),
(336,NULL,13,'unotopsatht49ik7q5jissgosn','172.68.42.70','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','https://fezamarket.com/product.php?id=13',5,'2025-10-16 22:55:04');
/*!40000 ALTER TABLE `user_product_views` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_profiles`
--

DROP TABLE IF EXISTS `user_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `profile_image` varchar(500) DEFAULT NULL,
  `cover_image` varchar(500) DEFAULT NULL,
  `biography` text DEFAULT NULL,
  `website` varchar(500) DEFAULT NULL,
  `social_links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`social_links`)),
  `privacy_settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`privacy_settings`)),
  `notification_preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`notification_preferences`)),
  `timezone` varchar(50) DEFAULT 'UTC',
  `language` varchar(5) DEFAULT 'en',
  `currency` varchar(3) DEFAULT 'USD',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_id` (`user_id`),
  KEY `idx_user_profiles_timezone_language` (`timezone`,`language`),
  CONSTRAINT `fk_user_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_profiles`
--

LOCK TABLES `user_profiles` WRITE;
/*!40000 ALTER TABLE `user_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_role_assignments`
--

DROP TABLE IF EXISTS `user_role_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_role_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `assigned_by` int(11) DEFAULT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_role_unique` (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_role_assignments`
--

LOCK TABLES `user_role_assignments` WRITE;
/*!40000 ALTER TABLE `user_role_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_role_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`permissions`)),
  `is_system_role` tinyint(1) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`),
  KEY `idx_is_system_role` (`is_system_role`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_user_roles_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `session_token` varchar(255) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `csrf_token` varchar(64) NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_session_token` (`session_token`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=175 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sessions`
--

LOCK TABLES `user_sessions` WRITE;
/*!40000 ALTER TABLE `user_sessions` DISABLE KEYS */;
INSERT INTO `user_sessions` VALUES
(1,1,'e1654d2204296d2e9e2e580616a9744bdde20c55f326981c90dd58e01e1e2d0dacc37f6992964a9a4ae3f1f1f0fa3653656d90cc1e5ee1448442b4522e62a81b','197.157.155.163','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36','2025-09-11 17:50:31','2025-09-11 18:50:31',1,'09331009433d0babe15f2a59f0705954d359e6951cc10c6ea8ab261b6ea72854','2025-09-11 21:50:31'),
(2,4,'fe8d72ba1cd07e56ac312d78f08701d3257c0af5481f2f6bd5fdd52367a685926b027db24ebbbca2d681e48e7af61e64b715419eeb098986a55291dd7293cf3d','197.157.145.25','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-14 20:45:42','2025-09-14 21:45:42',1,'6b923c8a66d1674bbcd17ebbfe977793eef8d2670de119389104dcef2051357e','2025-09-15 00:45:42'),
(3,4,'ff880e6fb3c6ab3bababc31e633d5be0324ffe4dc0688e39dbc01bbaf2042d1c18f54d56e5c6aa58708de36db0ad462f1476754091065d0ad269c27c1c14be1b','105.178.32.82','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-15 15:09:28','2025-09-15 16:09:28',1,'b3233fde0d2673231819456355f082f470cbbec8a69eed9bb4a0969a6f0a5ad7','2025-09-15 19:09:28'),
(4,4,'5b25d47ee859b5b6f6c515e7f0acf4e56e285a3f59a6451c8a5a166d5f9e5fea98fefd67eafdabd08744908fe239959353006e8e120e05367381a321c6e116c2','197.157.155.6','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-15 17:22:52','2025-09-15 18:22:52',1,'ce3b39495005f73048a5cf91e3c8deaf684defae8fcb70517dc774a680847239','2025-09-15 21:22:52'),
(5,4,'0d1dcfbfbd356513bb531a18627a96114d1d5321d9ffae9d79d08332a8004ced3fa0dd42b86316050fc3c0da471ca54ca2cf5ac03a2eadc47d22b96e0cc54e0e','197.157.155.6','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-15 17:29:35','2025-09-15 18:29:35',1,'474d6a4b6a916600337f2f9f0aa39697f668b22105ce44cc6c84d8593649c6c1','2025-09-15 21:29:35'),
(6,4,'9ecce897b923b4f8461cbfc308be28634ed4d7a8c6b520e5fe37658b59b29986b6c2acca0233957a2d1c1ace4795526c2d51aedea55b06cbd7ef70bb1a1f6ff8','197.157.155.6','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-15 18:00:11','2025-09-15 19:00:11',1,'9a684e5a7360e8cfc8fa9eba31b8107f22996e38fdd881c7aeb8478fe14baecb','2025-09-15 22:00:11'),
(7,4,'6a209fb3fa928c9818f50d945d86e1b2eef1c0bb6387f44c00cb0285f982ffed747f545da5e5e91b21c589374a5dec86a3d9161487ad7884de7e9dc42be3a9df','197.157.155.6','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-15 18:08:43','2025-09-15 19:08:43',1,'5aae8c8ec3ef68809ed03865471b93ee6e7ded6b35506ec03c60eb77326956e4','2025-09-15 22:08:43'),
(8,4,'31eff7e649fbef5b5009df6c69c11a883a1f8aaaa74cb7be40d7ad2d8d177f0decc7c499b3781f717869a3de951f968b57bbc1f5e413c991210a1c83db28945d','197.157.155.22','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-15 19:11:16','2025-09-15 20:11:16',1,'7e6e0c0e65090089112602c2405d0a5a523ab011b9b1c4ba46e81f8fc57dadb1','2025-09-15 23:11:16'),
(9,4,'2a41df3d0661b91a1a3c3f4089f1f1e602e9a1afa129dd904dfe747044f75d5206e35c7dac8045a07be13b65167f64225341973552f69c68bd093c2ec1e35d98','197.157.155.22','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-15 19:14:55','2025-09-15 20:14:55',1,'99d79fcbccc6cc24421caa733efeb49cbff537bb6d1d6b1ec1f2e56ca47e1d05','2025-09-15 23:14:55'),
(10,4,'ad96b5bd247d2f2a75a101e99f1ba83f02ee6790a857e72e9bc1ba4147b222983125f860f1bb4a573851e2d96ae40368ed3066f67dcf9988986592f1473b3767','197.157.155.22','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-15 20:19:58','2025-09-15 21:19:58',1,'bf6b85fd9531318f8aab8e140b249491786b3de80ca7cf9d0c3c23ea0acc2e8d','2025-09-16 00:19:58'),
(11,4,'9bbd26db276e02923b827a2e4d94460319d17e8a0d95dba916caad1ab9659956a456edd147faeffe2d0ffb28d22edc27d4e0918c145512e3c766e247c6ac7425','197.157.155.22','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-15 21:21:19','2025-09-15 22:21:19',1,'d1b5078286463a664178429896c413e9a762421e49970e2c69c3e808631955a0','2025-09-16 01:21:19'),
(12,4,'e71ea2be86bd51b48d108666fe1d058379f4010c8230dd88a421040a18e70fa36f68a43518d39464f88a5822ae3a63260753ce130db87cad50fc682f1032355d','197.157.155.22','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-15 22:58:23','2025-09-15 23:58:23',1,'3184ab76216f6b2b23019d7748fa9de084abaf302c91cb18447f45b3458f7fd4','2025-09-16 02:58:23'),
(13,4,'ad51fa8ca9f6dbfd513aceb12e16b84f4f82fc424383d7e40e9e1796cfed94356a2dc84eb074596fc386fb89658135105f213a748b0e6b46f8844c7274713b66','105.178.32.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-16 05:50:29','2025-09-16 06:50:29',1,'8a0c4fbb69399122a88237ef943c1a71287e9123d409255e5e1b8ec0b92c1be5','2025-09-16 09:50:29'),
(14,4,'ab820e967e2a60803ae8ad708caa94ddaf76397c8cdb2e2c859b9c0e4750ccf07f5e6011674a823fe71ffe7f29b7f903acbd13ce6af9d686538eff0136b37b57','105.178.32.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-16 07:35:24','2025-09-16 08:35:24',1,'00c8ab0dc8f51bdae66fbf4287379f0c696e3850ebdf2b474b82d9a0cf74ebda','2025-09-16 11:35:24'),
(15,4,'43566b07beb8b96eec9c5093b266f8e19e5036cca2a3188e4e969ededbae37e04ec7395b77605ab954418b2683c95126fe0c44d9694b22cfa0dec634db29745e','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-16 08:10:19','2025-09-16 09:10:19',1,'07060d5c4c96784bfdcca697fb0faf2a9a61d4306f5aafce65ba84bd14071fb4','2025-09-16 12:10:19'),
(16,4,'17a70883d6dc922f23b79cf26e86398643777262ca39e562414b838c44dc6b59f9645c6798d60a6a6d9c97d5bb8aaad5771c9bd42d817af3d621186fea3b5a09','105.178.104.129','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-16 11:25:14','2025-09-16 12:25:14',1,'5d8a570eaa0df9911f432762c89a302623ef14bf76b78dbf293330f2b2dc992d','2025-09-16 15:25:14'),
(17,4,'5f06dba291252182a8b2f0a42d27e664370dcbf24b6acad465640eec09158de832e4e0e24a493bac638a1fb4074e521506340b26d15ddd67dd59202f61f78fe4','105.178.32.65','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-16 16:10:15','2025-09-16 17:10:15',1,'643bfd2f1d062cb8ddc92397773c92c179773243fc704f9d6f1686a6ed260814','2025-09-16 20:10:15'),
(18,4,'d48785759ea8b4e32517219ae0e188a3392d11b7b691de768621d869fb45173486bd0c35aac6fa275c5dbe7705fa03e9059f92c66cabf920ff077f40c707a8c8','105.178.104.65','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-16 16:51:50','2025-09-16 17:51:50',1,'e008343dc0e36d559227eb129dd83f0d31b5795065360d0c8996e0b6ae0084b3','2025-09-16 20:51:50'),
(19,4,'8245a00989a6f128a028c5a0d28e56e1028ec4420468ef05ffd0fd3a2ccefe6744f93188b8051d4cb49a0085635d6b2532f20468313343d638278281bfc0afad','197.157.135.133','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-20 22:20:08','2025-09-20 23:20:08',1,'647ccf73e5fd4d974e8f051eeef2ed60e7214a523ebe8e62949dc51b631ba9c0','2025-09-21 02:20:08'),
(20,4,'592af2f528d10a25a9e3f81d5d50208360ca6e8858f21c97dbbdb033fe501ddc6acc37150bce90284ac0749a35859ccd2978a0214f1a9237b56326b16335f9db','197.157.135.133','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-20 22:21:19','2025-09-20 23:21:19',1,'390744a4592115ab2ddd1c07ceb1de1ca3fd481a6f70a56ab39de4801df1e51b','2025-09-21 02:21:19'),
(21,5,'6704b4de660ddc6e8d9164f3766f4fb51fa2e69d426914839dce67aa088fdf31040980c2da4814c55e0f7d394452d8cf65344ddcbd811f75ca1dc3e5a165847f','197.157.135.133','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-20 22:27:04','2025-09-20 23:27:04',1,'b378b0d439c6140bcfe6e651ae07d6238c17825ceaeb2c8c07b7b144d21f85b3','2025-09-21 02:27:04'),
(22,4,'f5e9dfdcd300c36413a2b387bc9b43f7c61bdab1a18a57cad62a41a4b1bb9e5e80902e3241ddb9b3baa402172811d0cdb074cf6e90021dae3bed8021f7cc2d45','197.157.135.133','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-20 22:31:22','2025-09-20 23:31:22',1,'e35af7b71dc7111e95584e52ddc69eead7715ee96484874670ec1f9c8c7e0696','2025-09-21 02:31:22'),
(23,4,'17f2c2a513cb00ea106ded0edfdc8465cf5ce7e94ee7a904eca94cb214fd4cfbe0e1ccd24a246831a472ec1bec15e64ec6586fb864076bf5d199da7b254e8c3f','41.186.132.60','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-21 06:57:04','2025-09-21 07:57:04',1,'6d761f39b7a07245e02f186554c44ddaf4b1ba0620d0a5f2900adf5c7abb030b','2025-09-21 10:57:04'),
(24,4,'4fb2f4a6be0ff7e4ce7a37455d4270094b7180ddeb15c0443817ce56b31c0fb34202f7cfd13e2c0a9f4502a3209fa9095c5be8ca6c4c9dd6850ca263115ec952','197.157.187.91','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-21 09:07:53','2025-09-21 10:07:53',1,'cd24a266e6ba806401e754034eaa260adebdec513f755fc4a276e7be12591015','2025-09-21 13:07:53'),
(25,4,'031730c9413b2bc112a1b8079542234cdf516ae67b41e63b744956aa8cfe70ed668bf0997479062aee68405c8214a86a281bc735b4f0331801249c30e7fb11c6','105.178.104.165','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-27 09:29:06','2025-09-27 10:29:06',1,'57becd5acda28d9ba6494d5229b87015d662c43dba50e78a7ab900c080caadb0','2025-09-27 11:29:06'),
(26,4,'2c270d1f3db48df927fd814152fe264f2193cec550c15a52d928835f2147a0e99112d7db0e4d52af6a75184e74c0cccb5b7f6b63b9f4671062c98453508bdc44','105.178.32.38','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-27 12:29:31','2025-09-27 13:29:31',1,'8c1ae6be54d60be95aec8f9de52bc07903ee90fb2acb62a0ddf3b6aeb084c972','2025-09-27 14:29:31'),
(27,4,'8578ddaec20f803f947ee962300a696d16e8b46b1779879e7227a4720610b8d7d3b379840372ed9c3d27c889537b3642b8dedd7ba6eb57db9e307f2969cb0df5','102.22.163.69','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-27 14:20:48','2025-09-27 15:20:48',1,'825db3a2d91457ba5207469df11722671107a066dc7c4fbe39325dfab372e8bc','2025-09-27 16:20:48'),
(28,4,'684c6bc5b380a264ad958463f0a226fb18c5811e28f57fa7d49dfea3ed06cfc0676ca96b3797f8f36b239861b6aa6bbd41d97cb1070b1aec449bc4f546c6beea','105.178.104.79','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-27 16:43:44','2025-09-27 17:43:44',1,'55e5420a7a4827c30822c04a90b5105f95a8741b8a011cea1d36e707e06918a6','2025-09-27 18:43:44'),
(29,4,'f6214bb5cdd9fa00a0da42123cdee0deae7b037dafd5ed5388419b894ff9852afdc00d196621873a55e2ee09d79c94c7a22454e38528962a879ad85d1c2e4235','105.178.104.79','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-27 17:26:47','2025-09-27 18:26:47',1,'8cf34af13f09929fbe934e1d33237600c6a6891c0f748e6f389257ef329edb70','2025-09-27 19:26:47'),
(30,4,'e06f0e1c761a523ae9debbddc229ccf36ba24e38c23de0ebeb742f9f298d83ae201a15ed741226a0525803a907d095acd13e340553745c9d7c31e2892ac579bd','105.178.104.79','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-27 20:44:06','2025-09-27 21:44:06',1,'6dcf8006144476cb1fa39c4eb77a51eb408dc1d6c170d761dee1d8af503254e8','2025-09-27 22:44:06'),
(31,4,'5dcf73d5a3e6ea2e1892b60e97b9e178c770b6fd910bfa84a6265e5c5585c58370ec2a82dc4ee350335b7becd15724c013e96cbfeab9df96888948e78404c67e','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-28 19:59:25','2025-09-28 20:59:25',1,'16cb55ad0e3660830ef85912f384848568c69ba82bd03e30f4298112ce8940ef','2025-09-28 21:59:25'),
(32,4,'b3c6ee02edd14faed1a563e12392bbb709f0028d02f37624de9f4f28ca429b0d8806bb6d739de17766049bb7835ed3db7722b0f6e3d64bd72ba380f632336f07','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-28 19:59:42','2025-09-28 20:59:42',1,'337515e2557d57195a027682a27d25a0d5ac7fd397d61c8fcc14f358808bc825','2025-09-28 21:59:42'),
(33,4,'bfc7b3693d12e1265c95e43133915967123bba580cf5dc9292c9a6fad4ed74de3d3c5d24caf8ec45421ae14ebc6fb0cc8db192501783fd98e2bb417e25777973','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-28 20:01:47','2025-09-28 21:01:47',1,'05115566b9fbf3d9a8df495f69044865717f069c2f3112bf1e76e113853b6af2','2025-09-28 22:01:47'),
(34,4,'f800eeee23f5af83c733ba28754198d66b90bd00ab0d3b645c5e5f889d5d247bb11f6addb191e9761599ecb5c5424966abcb8010c5613b972d5777acf05554b0','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-28 21:41:55','2025-09-28 22:41:55',1,'97791dd65cebf2f744f56cf943aee3f39aeda9d6237c0d39e73a01665961ba57','2025-09-28 23:41:55'),
(35,5,'b4325a34675292811edb3e1f9effdd4ddba65520e6ac85e2fdf20c395debdaa5e2b98d1ea4d07e3cb5724f4bf3a41a6cb0685dce6e8bee787c4e173bc4677845','197.157.155.7','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','2025-09-28 22:06:43','2025-09-28 23:06:43',1,'ab39e5b5bf1749c35838f0515378d9314c244803593e05e4aedda2f075f612ee','2025-09-29 00:06:43'),
(36,4,'58b62e270a39c4844374068d20ce56f6453c6a42595695d8df61b374183c741dcdf5232310615ceb1b52edb422c063122d1c4b503425d3c188f55b3285303fe8','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-29 09:17:37','2025-09-29 10:17:37',1,'12c5918c7bc8281d3c8c43e467556e6ce7b8f577fee7342ba4c54e05f7150288','2025-09-29 11:17:37'),
(37,4,'c27c80fad43a570f78ef162a1e097cd6809e0e74f8f6eec3e4265778ce0c6e6a5e43e32cebd2bb34664523380c112c139bdc926827fa8a1d76b3a709994ea01a','105.178.104.179','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-29 10:59:37','2025-09-29 11:59:37',1,'3035757785b160ee890104315cad50aacf959c44d2c2deb50027d79f5724519d','2025-09-29 12:59:37'),
(38,4,'5dd0498b487cda1d234c36f8d9961084f4eb17222afc8416a5f09512bf274a957223372e11991b9e2d93cb601dd7003844f5a1c95811b198fa0d32c0beeba7c0','197.157.155.7','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-29 12:03:37','2025-09-29 13:03:37',1,'14361791933e49d8926f78052180fa7bb3b1dacf1b5f0ffd636a39051b8454c1','2025-09-29 14:03:37'),
(39,4,'f5cb06f07f2e95e10e431c72538807c04cfd84ae59cd45fc0d6a6e62af13b4d99e0f025c144169144a6a370df7940a00d6eabf0696c42f6085b334a20c6c91e8','197.157.145.29','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-29 20:00:41','2025-09-29 21:00:41',1,'e255444c25f55b822e1e1f9e59612a66d4926d9d7e6b39e3a947b3d4ae927bbd','2025-09-29 22:00:41'),
(40,4,'793aa6137c35413f9b5ff319d16f80ccf95362c18a3de1dacabe489b123c8b57d80fd0ed292932611d749a89c41b21eaa20dd7718192508b59c9a8114e3e154f','197.157.145.29','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-29 20:03:41','2025-09-29 21:03:41',1,'3a92d5dbf282bdc7bd0e14df477dab5a8dd3fc5bb45e88251c10fdb53d27a1f6','2025-09-29 22:03:41'),
(41,4,'44a68da316bab1583c308e8d1d63db83a2053a81078e037f80700837c367ec966afb6db6e81dcd4bee4234488697e90d90afbbd5bae8e4cd5accc9820a1b6e56','197.157.145.29','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-29 22:23:24','2025-09-29 23:23:24',1,'43605aa849a3604588392ad974b6b81981a48ab7f489ef8361ab2fb8b4a792f6','2025-09-30 00:23:24'),
(42,4,'ac88524ab244bce5e329c3bf13c26cf931fc6f8709e676c6bc10b9ce58db31a9b1091b44b574c5aaa0737df72a5a587edab7cda38f3fd06bc663864d13e09390','197.157.145.29','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-29 22:59:28','2025-09-29 23:59:28',1,'fe6a26e135a5ec15a158aeec52d0be8a4ac0d6d0cfc08c37ae97df7afe9e1f37','2025-09-30 00:59:28'),
(43,4,'9bfa9b51c7f42c72b38246dffe3e4b528218976513a5c846ccb81d9a344044dcdd09361e3b5d53971f94a036cbe24fac62aa4fd2815106b4af7f2b9a78948511','197.157.145.29','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-30 06:17:58','2025-09-30 07:17:58',1,'25264a17ab86e203fa8bf0ba03a263ba3fa2fc2158775d59afbfdffe3c4168c0','2025-09-30 08:17:58'),
(44,4,'4a00163e7970084cd76d7c123d477d819bd8f8f3f5ae532fffd5954cf1b13d9fe5043b7a19f76cdf3003f27cef70e9a7ccc5d439f7e9fdf0a0bea2bbc9f1afdf','105.178.104.179','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-30 07:43:26','2025-09-30 08:43:26',1,'876d6ae330ea0b48cd7628630ce939a81a0393b1a8537186033bc00957b097e0','2025-09-30 09:43:26'),
(45,4,'22eee994f35dcca04b268f7de5a345493af14817974b5cc1e2492bd4a1026ec01aa8b95538f8e6e1c086c9df65ac961c981a72d6e85da826ade94e490c6ecc27','105.178.32.179','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-09-30 08:48:23','2025-09-30 09:48:23',1,'802612fe026168d7dcd7986b0f46c5266728ef6ab2e9040a5b3dc10872a71304','2025-09-30 10:48:23'),
(46,4,'3541912729002aaf5fb4cd7fc81c79aade247f68fb3bdd4cf1dab6b7cdb07adaca69edb051e80528d69064486c26657a14d2d869ee889caf57d53843c6406033','197.157.155.132','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-01 20:40:33','2025-10-01 21:40:33',1,'39cac70a9c1ddce1aa62311e08912c81e41b6533d60e75ca98dcfa4801a3967f','2025-10-01 22:40:33'),
(47,4,'051f1dd921ef46c81bf61c83cedd720254a0d19140482e322b0a68dad8ffc896a2f757f4257b73c0dc02067df17334fea3ef9f661ba7d278a0ac950e446e6b57','197.157.155.132','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-01 21:41:18','2025-10-01 22:41:18',1,'64b1bc00173911ca6321cf84fff00d8a529babb318246c6a142fc2c4a06b2fd9','2025-10-01 23:41:18'),
(48,4,'44ad0165f43c1ed21110eb75c95cffc94e12a585bf6745f55ff72ee53c462e414764af9625488bbcbb4c991bee6af932d1747bd626819bc23b06b5edb8aaaa61','197.157.155.132','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-01 23:03:58','2025-10-02 00:03:58',1,'ff89d94cf1b71c4bee043b8108d687037397c9c77faa71cac9f3acba60bffb7d','2025-10-02 01:03:58'),
(49,4,'8a748ae0e01cb387805ec1fb67dd68e7cb7c3933833f9af0a4bdb26a601d9a995299b27a6d5654d010b2be55da6064afee19da0d9458cd77ff51aee092b0f32d','105.178.104.110','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-03 13:40:58','2025-10-03 14:40:58',1,'5148352a1cbba64168efc5d6feee4ea1a6c8a42505223a0d0568777aa9ed30db','2025-10-03 15:40:58'),
(50,4,'297da0c1557eb22aa93fc85a646f1b839b51f9aba1e83419e21bd1b27715462346af41c3ff0a93d53e451c718514c310e58f70b2ae706fba2258752b5c657ef7','105.178.32.109','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-03 14:37:32','2025-10-03 15:37:32',1,'c99ca84a9ced6b3d1dc3d77a759c0264b44aa60465f86ae4dbb40fa9bdeaa639','2025-10-03 16:37:32'),
(51,4,'0ce4b9d5786c9311fd5ea14d1172499b231182aa89d92044dfe61a26cdd9bbd470dcbe2696fa0edeffe214d4d1913b4d1317c469cb2b0459ea2c7b7c4464dce9','197.157.135.231','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-03 19:15:40','2025-10-03 20:15:40',1,'872a735f4ee0b6848549c9a8372557ebde25f481abb6013a8553feb6336c31ff','2025-10-03 21:15:40'),
(52,4,'e4167636298ffccd7a9990ffeaa5b9359b030ccee71041fdd52bb4a2a85997c36a51aeab5c7d480f9908d04ded70c3296016bba6b37753201e5686d47a6710eb','197.157.165.150','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-03 20:41:13','2025-10-03 21:41:13',1,'55c9a7671ee63d871fd5091537d2248ce44dbbd851fd351215610bc904356d51','2025-10-03 22:41:13'),
(53,4,'a4188d67841785a4b67f88dc9a785fbf1246bef8bc95402ed68d5b596584df0985eebabd1a2a816064dd1dccffaa9e57d90ced1dd496d1841a706277a2168f52','197.157.165.150','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-03 21:46:27','2025-10-03 22:46:27',1,'280c36d182e631427b50c83f9bfa6c0ba720302632b48ec5e30bd09a52456c04','2025-10-03 23:46:27'),
(54,4,'dfec9a488a59f33f87b90702971a9c8e60a44909413c021c683abeb1a3388049923286cade8ffc3be086b72409ffefbe9b1c3c3006ebe39c72b1e4830bcc6337','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-04 04:46:31','2025-10-04 05:46:31',1,'65ce1b94bedbbff53b5ccc7ca66b007fd4450d5de800a27f9e60d9696dc3ce51','2025-10-04 06:46:31'),
(55,4,'cb1dedcf7ad2feb58f63c7d525e5f993336fb002953c21ba2bb38a2652eef98c9620d0cf4200724892605f34e2e7ce64d11b1886e946c70bba73bd1bff9dca92','197.157.165.87','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','2025-10-04 05:39:23','2025-10-04 06:39:23',1,'318356a320933509f6fa4db3be5ddac6a8c7b2695bcb2279da689bbb8258f621','2025-10-04 07:39:23'),
(56,4,'775f55588d2f2ae207eefa4ee72926c4056bad1a56b9068c1ba3cbb283fb3baf33ce07e8ff9acb3b6a4de2dd6df4c3912e5fcdc341ce8c7450b562a0a694ae97','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-04 07:03:20','2025-10-04 08:03:20',1,'479a06e02c309cfe46e03950e32e74ba1371b06ee10fa1ec84d9bb73fca6f680','2025-10-04 09:03:20'),
(57,4,'d55bf671964a86129413e4d76cb725e9078bbccc1185023cd984a911a400194a1281de0b87401387c595a1295cea24777e9216fa938cd2af57346821159079a0','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-04 07:19:38','2025-10-04 08:19:38',1,'a5018cd0d109be0bf3f38947064df24e361a3de192be0818c30c858112faa34d','2025-10-04 09:19:38'),
(58,4,'c8bc5fa4b866ee150c2df6cb5d7c3961a0282cfa85d294bc6efae687d4854dc61ac1bf30c341e85f32ec5c11ac1641d510bd41ebc48f3110fdce0f7f3b3b405b','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-04 09:14:01','2025-10-04 10:14:01',1,'d46b8258aa13cb9e345844435bd619950431e83cbe73e890547f1bd0d2e0f9a3','2025-10-04 11:14:01'),
(59,4,'73577409c0e95ded583d0f9cc42a892246f89650390168aa85fc350d0f5049a6c98609aa0958838b98113ff86752a9a9348b8fd891afdde8aa74147866973b76','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-04 10:18:18','2025-10-04 11:18:18',1,'f284450a4cd735586fb2cc151f1cc4129f695324755255b25621f84dfd570338','2025-10-04 12:18:18'),
(60,5,'57a2bbd775efd72ec1a33c0d2ea48494cb9243028e2315808db48e2fe88064068477fe014758741379aa9afb9e412c185e63859aa3ac9ef4a7bf6ab2ccdc1147','105.178.104.109','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','2025-10-04 10:46:56','2025-10-04 11:46:56',1,'68bbc3395d254daa5479623aa615a93343441550769bf9bbfc45566d56dfa6fc','2025-10-04 12:46:56'),
(61,4,'a99f28c2b70123d788c45f0edba6118c909a1c8371e2e4fb87e11073692b44d3f3ba65606dd6332bcf9cd501284bc965a0734ed424798b821449c3c292b7e201','197.157.165.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-04 13:04:11','2025-10-04 14:04:11',1,'8d8553642d3ac87218834ffe281caf6bd1ee84b8e96c9f51800c2df7fd47b9b8','2025-10-04 15:04:11'),
(62,5,'20674bd6ef7408c3ca13cd3fc52488a2ba336eac2ea6c088688ca88e86a776eb24f7bf52d5e1c532fc3ec67b29f0c31412bfe60e0074d6ce6db37e3b0169d683','197.157.165.87','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','2025-10-04 14:05:17','2025-10-04 15:05:17',1,'719f2e68a4d4a26442e72018e2d17b347ecae100356c4c9ee66c02e31be2698d','2025-10-04 16:05:17'),
(63,4,'2a949db87b9761d43b4cad1b590c4414ce22993413cede3d9b9cd7193cf6ce518a9dc207fe031d3e14ce8ec82dff13f35307fef538f394b20f7a8eb98e1dd07a','102.22.139.51','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-04 16:14:43','2025-10-04 17:14:43',1,'7d57afdae14f51c41bf8ee17ff8c54216efd9e09ac5165edf3e3d7918dd54810','2025-10-04 18:14:43'),
(64,4,'cf3523b0c52305b63d6c6b8d82f30f3e925dde7fd095dde95992db6f31c39ba3ee9df54313bd0bae0195809818a51a4c709389d71df7e3f78fa36b1e4041eaa6','197.157.165.35','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-04 22:54:31','2025-10-04 23:54:31',1,'12426cb06f1160e196ffa747ea649ba349aa309651bd5e0ffcc595a510888791','2025-10-05 00:54:31'),
(65,4,'f644b683ef25ccb3677616eae5e6be3243c5279dc5ef37cc9dbfdfd00fabb7d9140e2cb40cc1025d1b2022ec784f9f9af6d6c57b7dcf71bf2a3fd0eba11a8522','197.157.135.63','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-05 10:39:55','2025-10-05 11:39:55',1,'93b1d1a093d45937c42ebb666fcbe6e7f6347b7d5d6c3dfc21e4d88535840abd','2025-10-05 12:39:55'),
(66,4,'527b602be0c68eb9a5e0640d5e5ead4cc123accf8c9544137e47bd0bdb5c3d438ba65c691d9c81d2a34d30390f7cf840225e65703c900328df1474839197540e','197.157.135.63','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-05 12:45:41','2025-10-05 13:45:41',1,'2a8f3d708e8e551ed75063f917801fd401bba8fd6166f14d988dc2b05e1f6686','2025-10-05 14:45:41'),
(67,4,'c65f9d4d0fdd2df09ab40e244749c169fe23f4701e48450740e1a65f52c68b9b034ed3ed13405365790451eee74bb5cc9c60a74e3b783288df6dae8513d925b1','197.157.135.63','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-05 12:48:44','2025-10-05 13:48:44',1,'08d18bff8f410afa783b11a098491b8e1ff1fe67e58bae4f8d4ad16438c57f8a','2025-10-05 14:48:44'),
(68,4,'e4180f0c4765ee11b4b649f2bad9beac0a7d6e1502354b755515cf78a8d1d9c5e7d5a15d923f01de8f686b1452ae23b9b59dd8db26b47a701e7b479122511748','197.157.135.63','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','2025-10-05 14:29:25','2025-10-05 15:29:25',1,'2d722df7ee00bb3f645422a6fa4ed9be07d80e7f2bcada1839614d11ca8df7bb','2025-10-05 16:29:25'),
(69,4,'3094176a0714c1454b1ac20a0aa1f260fb79c7db3acbbdee46e41b737cbbf636dd31f9ed434d518d2712067162d3ec7f425413a254db5f5b17e1f63e246c9890','197.157.135.63','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-05 22:46:08','2025-10-05 23:46:08',1,'405b2efb96221b0f1abdfc01dfc642dd68f6ff104a74cded8e0afa4909a365d8','2025-10-06 00:46:08'),
(70,5,'6c2e2195ee700a6b5ac271da5d360540aadaf9eb8f09288c8ed6c42d280c776ed9df283eb1ec9cf65cec8ad13e3e719b5b118a7be0a47d8930fdd84effcc4bef','197.157.135.63','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','2025-10-05 23:00:13','2025-10-06 00:00:13',1,'0a40d32b10b76c2aafb61ae89ed4a4935fb807fdf78270849157ce94f9a274bb','2025-10-06 01:00:13'),
(71,4,'3c6f882ca0651cda0825535105980ff1706cb54dcfa5a9814cd4fce39f78ad63665a04f226c32b885c6d63f30ce7feb1893ac60592aeb2d7c2e8b90f351eacda','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-06 08:44:07','2025-10-06 09:44:07',1,'b0bad75297fc6917cf2c469aa9a91c408237b1e763c1fd6f520c125effb9e5c7','2025-10-06 10:44:07'),
(72,4,'8ed15acf60c94e2bf66e1ebe551bb864e2dc24ee1fe823bf61f33d8185228f571d01c605a5385797e99cc06ef9ae7e114e568e292d1f032e3ec35bbf928e851a','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-06 09:55:14','2025-10-06 10:55:14',1,'e99ff199b7531037e6b8b3f1f8c70dafb628e53acc1399a3051f705e4ff29bf6','2025-10-06 11:55:14'),
(73,5,'1a1005c42bba0b08ed541e9a33d0c9b2398c755b14b11232791b91bc9a0e0a072eac62fd668dcd481f7682fa2fa7b5571909c2b229e9c2a825830e55697f6f89','105.178.32.56','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','2025-10-06 10:52:09','2025-10-06 11:52:09',1,'6fa2ab36d40b2592c0dacddba4339033d730846fedb0c37a5a4c84fb91d7fd0e','2025-10-06 12:52:09'),
(74,4,'fb01347cce35f49c50a5fb214fc65d82e4deef5ba80b7f140867c2ff950a2607ab753ec934e940574aaa63af95b68343d009f4a7517932869a80a2c4650baa8e','105.178.32.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-06 10:58:02','2025-10-06 11:58:02',1,'fa14f9ca6e3a97f245d815fc5af23c23b466e120096e708cac2f576808986d78','2025-10-06 12:58:02'),
(75,4,'59aa167be7c3135c6dbd02120b520fde5a300159c83adfcebddb345cc31a3aad1279e1f66a24ae4d3f2d8b0df1865b04e2bbdd44ad4357e6273cfc9653f1518e','41.186.139.85','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36','2025-10-06 11:15:05','2025-10-06 12:15:05',1,'4407a6e71f8e95f733dc197272cff5d6d92f0df00cf8a40d6045f0002bf037f0','2025-10-06 13:15:05'),
(76,4,'5e73a029e7c67466105a3a6452b40274d48b05fb20e9110de875aa4d24841a175120a520f268aafba6a858fb89c67eb62e462072d6bd305499c353703324b96a','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-06 13:22:44','2025-10-06 14:22:44',1,'b904d1c1f0e032785421425071234e2f57a087cb9bbc05a3f418d40bc34f6416','2025-10-06 15:22:44'),
(77,4,'256aa85305ad907fc08e5b55e84f45e67f390a0065266448d56f2c5191bf7f364b5f6c0b453393dd6fd46e1beba0dfb8bae278af4fd2c322da8e0c1eee5eea2f','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-06 14:00:25','2025-10-06 15:00:25',1,'69576d5f3615db2c502b1b21793748c21473bb4f36a0f9bf5e60421160226173','2025-10-06 16:00:25'),
(78,5,'542696266278fe03cf9992bb3e33e6fd3529d76c354d7fc7654e3c09c9b3c060dcdc7677022065678b6de1e3b117331204d8154549833510dd70c6e15acf101a','105.178.104.56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-06 14:01:49','2025-10-06 15:01:49',1,'5ed41757404d88ec1a22d046d98374da6c899f5019dafda582f936f83cebd5bc','2025-10-06 16:01:49'),
(79,4,'94bd7e20e4f750b183369748a17cd2325c9b1dcb4c0f7d03492413d715cbde60a6e60e6e15f879fe65feca4e171fe8e967dceded1dd70c10035ce5cd3e71e627','197.157.155.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-06 17:57:17','2025-10-06 18:57:17',1,'63b5a47c4a5f4fe791054211712419ad53605cea1bfe88a11bb448a0bc0e53cf','2025-10-06 19:57:17'),
(80,5,'8d56c38d33b61ba6621c5721dcc224b5d006e0382bc593387cce2efa98a8ae3e4416df2e36fd33f4b3b348ea58fce20f6f66098d473f01675b3c6f84d10303b9','197.157.155.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-06 18:01:21','2025-10-06 19:01:21',1,'f3158c371c7470eadb584b41dbd01efb18758ca28352606126dc6d400b1a9c84','2025-10-06 20:01:21'),
(81,4,'54872b8c9b75ad0f4656fd8d4873c5ff54fc84097b6c307421244353133adcd3b7ced9f1d722c57db7c168bcc4c02d0aa02b49bbef33379ebc420f80a686c9d3','197.157.155.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-06 20:55:51','2025-10-06 21:55:51',1,'04d85b13b9d12c7b787317c9cb95414b0c69d629cb10fa274c30ccd9b5aabf48','2025-10-06 22:55:51'),
(82,4,'1b857ebba26ac1897138dceb04ce3c59014d87b37b7400c8ed491dea458a4f6601132c3170cca1cf0d0f1f4d1d81de2a3266a84fdf76154377f39abf93f3c882','197.157.135.201','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 06:48:28','2025-10-07 07:48:28',1,'890e4856908dc667bc10ac9e44e321401420a56d8ce00c85546ad44541b35ff3','2025-10-07 08:48:28'),
(83,4,'4c8dfc8d50d95d99d9d75e0ee0d55ebb63ab1813b735535402a93dabe61b52ea70ae2ab5c148ebf70969d98469795fb9a3cbf35d27e05467bcd03d494d4a74a0','197.157.135.201','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 08:15:54','2025-10-07 09:15:54',1,'f47811096607767d1ba1d97ed999e16d36dabb2b19c93afb345cb7026042dac0','2025-10-07 10:15:54'),
(84,4,'26db5ba62f5b5a497223e2a042401557a2d8f24dcfae7308655265f6766dfa88bba5cbbe4fdda1142dc2dfb91c06c61cd1b337204d280f5afb6c4056b15d0930','197.157.135.201','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 14:46:50','2025-10-07 15:46:50',1,'cd013b4b3375ab104ab88566bb1487bd023ef716f1161a447da62ef4d689a581','2025-10-07 16:46:50'),
(85,4,'26773b05476a38a9ac2d29b113286761b834e9748b379e8a65c3920de7d4a4f76e9f572d1d8ffe805e00315095cb06b515a0b7784103607867a8acb877686df0','105.178.104.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 16:59:45','2025-10-07 17:59:45',1,'9db074d30044945a49a031abfa08608cd66f976d6ad201b807fcf9eb22452c45','2025-10-07 18:59:45'),
(86,13,'562def2e3e74d0719fc41a5dab71f9de383b2becadcf4eff0b9819f9119d9d84155a654d0e8b4058b3e910cbacf8cf04c180c94ab98991b8c259a1049bb223ba','105.178.32.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 17:07:32','2025-10-07 18:07:32',1,'f3ab7bc4f64f88749be702d40a98f1ed8c49184836f3376209e3315d8f023f70','2025-10-07 19:07:32'),
(87,4,'82a45864ec54ded59baf34df43f0f9d3adadc8545f3e14a7c29338e274ac3d8f75f451cdcdf6fb9939e49ed9522914adcf8368c320fb716b254345e39ba32a4d','105.178.104.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 17:33:01','2025-10-07 18:33:01',1,'2baddd119fe8c55cb83605553f0fae1ead2301e16a68c54bf0911b776bd56786','2025-10-07 19:33:01'),
(88,4,'2807a9fd8e9c8bbc8dfb1468c11924690c4c87848b4ef79627dda0392c3fed8d78fdfa77a90b4137f731c46a04aaebf5295b76ba3fcad41d3fcb990f3d75ae50','105.178.32.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 18:51:55','2025-10-07 19:51:55',1,'75c6dc6f4b467215232a3c65e99e38f0a566b5b4bc7ccbf3cb0f00c63ef6279a','2025-10-07 20:51:55'),
(89,4,'104d73d48906ba2571330ef155cb378df6330016852689148b5aeb50fc7d1e399e335b9eb6a82f0a60012f95054b4693ae9187c4f5a1b6003c5909126bad3ae9','197.157.145.87','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','2025-10-07 19:53:10','2025-10-07 20:53:10',1,'89d4941bb76d05228d945caf5af04519b90945e0b2e6a9e8931ac95efba5cdbb','2025-10-07 21:53:10'),
(90,4,'8ddc6804f3ca47fc4d147d626700d36c55d9225965cecdfe8f3928872967d75b3405a68c73fdd2b3ceb234d93cbbf3fd29ef62f3a751c123efbb86a7ce7ce616','197.157.145.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 20:40:43','2025-10-07 21:40:43',1,'2a106ba7ed88cfb5971c1a644975e569f287ed1f6a3a7cbda189f26063edf881','2025-10-07 22:40:43'),
(91,4,'db27971c6b30e0ad4032d90e6d2e406a84d7d6b3d621b7272ff3164de0c160d87bf1a3111682ea8d3bae646e3687aaba5b9e39217d041f9d8886c40339dcffa7','197.157.145.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-07 23:52:13','2025-10-08 00:52:13',1,'1a82f80e48d9e2b427b3c25358c2c0daf91447db490d0f19e3b40cec4db811b6','2025-10-08 01:52:13'),
(92,4,'90407eb8777e1e5e687a739bbb7b6f99b3223a378278f6d9d2e2940ff3710202cfd1f58f60b16421822364febdcd20703541a505d116a445a108448ebdf7ef65','197.157.145.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-08 07:06:55','2025-10-08 08:06:55',1,'135fe292325d21f512430471987bc03925f84b23bc58c29fdda79e08190c771c','2025-10-08 09:06:55'),
(93,4,'e2eb2f1e8ef675f5a13b87c472e55f356a2762aa3013ee331df6f3f4e1a5d36524e5c92130e076449714bfbe69d5e8d6f1883681585bf23d4ed2000d09f246e6','197.157.145.87','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-08 08:18:03','2025-10-08 09:18:03',1,'526c74d03435a9748c4dec8428d52b7ce16aefd19eee9b15d06808cb6a602297','2025-10-08 10:18:03'),
(94,4,'71a277e689e44f0b57a48ad09232e96f468e120e8e37ea3f022f6f103dca350a2fa25a92ea4348593996079dbe435f83319674c3b90455ffc7182c58d68758ca','197.157.135.108','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-08 21:00:43','2025-10-08 22:00:43',1,'209a65533e72b25dc2a669b7c0195624ee03501ff332e611cbbaca5a9c1818f8','2025-10-08 23:00:43'),
(95,4,'9fe805f7cc1d2380772a583b459577fa6d9099389940e8a95c623d51ccec48d4009fc3b29d0c58e273fa1df45f8936e4b6c7c6324bc5ebdf4be58644d6178185','197.157.135.108','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-08 21:39:22','2025-10-08 22:39:22',1,'6dd494ace9780f1a164fa48382d8f391a2434fdd6327219256f58e0e3f69df94','2025-10-08 23:39:22'),
(96,4,'69fbb2284597d77d6bdfc312be78e30532eed220685aca6aa92d5943bcd9bfdf861b20ad608dda7b84e0ba6a1c7848e49bf85d6fa4d6a30700ba5f7a44b72e01','197.157.135.108','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-08 22:42:28','2025-10-08 23:42:28',1,'6ee7dffff830e71cd8a897a8659a3d5785c93a3f76a02bfc4f53dc9d3571e8b2','2025-10-09 00:42:28'),
(97,4,'8d348702a54e483d6d4510991f16ca580cdc13e8725df751676b9ea72213df20ee804aaa71c0be6f0cdd37fc76c0958b34a6bd171bc09050d48fa63a06adc6d8','41.186.139.192','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-08 23:43:21','2025-10-09 00:43:21',1,'37d5934fb5080d5584466c22e3d4a6abcc30bb043f41a8a76fe02c4bc6098e1e','2025-10-09 01:43:21'),
(98,4,'d25912e96d78af802d210d4bbe3d88b72edd6e37dee7a0a7ad2ab1396e0829fc3ca948cae78bcfdb2b1a8a7b12e6183e4568400739b242aee877c69162707c24','197.157.135.11','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 06:37:27','2025-10-09 07:37:27',1,'50f3870774080365396a10cc42b2ef90ebe286fe82dd54c338643ab8ea085a62','2025-10-09 08:37:27'),
(99,4,'5ea7e0a26859483dc80b5cf54a151a0e25dbcafa6a0f1535d9769c50e3fd94b72163f137744f64b204d46b1ac48782cbba2392bb9588fc735976acabafe1c83c','197.157.135.11','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 07:20:31','2025-10-09 08:20:31',1,'630cc2d18b73d75aa19ac63a08e8f5e2a05cdf27ee69efb79915732da6709ec1','2025-10-09 09:20:31'),
(100,4,'febbe3e02f2990605832ee0a0e3776f45553c4fd59bfb752c0b8fbf0fbd69d24d240e2672d00511ad07749117b2f80702035f852411128f4f65ef3f535462d2b','197.157.135.11','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 08:15:52','2025-10-09 09:15:52',1,'f736a018ae9866648d6ce22cbb414a2c409b0765c92f57cdfa4360c82ba19644','2025-10-09 10:15:52'),
(101,4,'fb44e2411a415d9697cb97911b42b2ae86caa2bc1c0c7d226f857bc8973fb82548a1d2abef19ad9bc7601fd037bb42fb70856df9840b51a821131a6ac6dcab0f','105.178.104.255','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 09:11:32','2025-10-09 10:11:32',1,'4efdac97ca61ec01c846788c8e28c7eb183098bc80cb824ff22a678701b3d5e5','2025-10-09 11:11:32'),
(102,4,'3440ad9408a3d3067ebd3fae48fe2f4aa642ae17377820a8334465c7c7f962dbc60762c9769e0682c5d3307b1424c24380c004a2fbb83044bd685272b3fd654a','105.178.32.255','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 11:26:00','2025-10-09 12:26:00',1,'fd0bc2b79170ef201d5e89a187e4f4678f15a862d3064687e2faa786aaf94538','2025-10-09 13:26:00'),
(103,17,'d502e84f3af158ac1d340d0cb9d250fc6b46b78cd066a7dab44b5d053432afaa8c08e8b0be6bd34e60078c83d7b52bbb2f2df4e68c549ffd25ebda6bf774e80e','2401:4900:839b:85b7:211d:bd45:b205:7089','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 13:42:04','2025-10-09 14:42:04',1,'b673421efd0eb73fa84bbbb1644c3b56575ed725d2f275f98f56355bd53c6eed','2025-10-09 15:42:04'),
(104,17,'71a0dae683b42193f9056ceac6bff775e6bb6f67e283ef6d0eb6a7a565bb31fb0f7b711cab013f7f79c538641fa7ce2003cd60db6a94f17f1a0dc14c7922073f','2401:4900:839b:85b7:211d:bd45:b205:7089','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 13:53:48','2025-10-09 14:53:48',1,'69861b14ece7955a3f74f66e31baea7c1fd994a02da495cff712ad9f8547374f','2025-10-09 15:53:48'),
(105,4,'417df46e35d82a2a5bd1f27f0f2fd61b9f8851df23fe2f26d1e52a25e158dc47d0e774612a9fb8e29e0877ae49cdb7e9ac77e75ba39e642946d9c186b0c87a7b','105.178.32.255','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 14:28:28','2025-10-09 15:28:28',1,'fd67d260743e1aa1a0a9308b4b3cbc69c599a8e05864a5073b2330bf823ba330','2025-10-09 16:28:28'),
(106,4,'1b4210ecebc468bafabeaac541c91d1bbbfda9efe43bc8d90bd3d3a02f567e0f916b5eaf3d2b1e2a795dbd04f80b153887b51eea50f365542c76698918925d02','105.178.32.255','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 16:12:36','2025-10-09 17:12:36',1,'aab555633eb2b039cc2dc89c748784139d43bcf48d8b0931514ae0bcfc2b887b','2025-10-09 18:12:36'),
(107,4,'67d3e9d8089d85a3ea8b03f2c1998edc0ecdd1fbb3c4435acda056f09da39b6214b4c425fe12f54b9a79ab404676cf833e1e8874cab24a77fcf574c6dbc1258f','197.157.135.155','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 16:33:59','2025-10-09 17:33:59',1,'bdb8f7b4eaff1702b509acd50559fd3f83556e0d63854fb9779ba05619706118','2025-10-09 18:33:59'),
(108,4,'b93f8bb2290934ec4907806e4756e488e351312ec6fa76e4148ccefa734ee50a74103bfb4d9d1a21834702b0c65ba093914e11b79d2becac84e9bbde85f9b724','197.157.135.155','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 18:05:18','2025-10-09 19:05:18',1,'afb8c08f0b9a62c7a9933df6953696f8820309111757e138d3fd69299c5f38d3','2025-10-09 20:05:18'),
(109,4,'0074c8cc4d8866404fb2c34c6d0e641b6f3a2f99b03d1f130eda2326c6065c3f286abe8ed4cba32f9ee2e223611cfba8809c4a16e7cc32ee1808aeec712cc370','197.157.165.125','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 19:26:00','2025-10-09 20:26:00',1,'7662c5ff110377c81d11a230a2794d6651fdfe99ee640ae4f757854f938f0e28','2025-10-09 21:26:00'),
(110,4,'0aca6b767ada45e343c87330ad36d44835477cd6c6eefb3918ce134eb37ce095fcdca9dbceb4b905ca49e4aeb9a386d0f5d746d3db41a0ea343cc2704cec3c7e','197.157.165.125','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 21:24:26','2025-10-09 22:24:26',1,'8a775c49c1301f52d140d36187bf3797fb3eaeab06f475ded6ff2999f67e9fb4','2025-10-09 23:24:26'),
(111,4,'1d84f11387f8bd8f6f95afc8ab616be7ce4fa54243c2330b470c25dbc96ae6a6bccdd867f374f17519e76f8c32ac656be76213e54bd8064d8780a858adf1da73','197.157.165.125','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-09 22:37:22','2025-10-09 23:37:22',1,'477d87b42be899f6ced773a557d9f713aece9cbdfefc7a276363a05286ee34fa','2025-10-10 00:37:22'),
(112,4,'cc5cddb41c07f66ddc5915f557ae5dba7f84686a7332869fac48628d126b6bb7e9770c208c371ab416ebb4bcaed61fe7625b93b6bb8a8a116d81cd6aee8c465a','197.157.155.94','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','2025-10-10 06:15:19','2025-10-10 07:15:19',1,'fbd5c013d9fd44cd50d690c38cfcc7adbae3e1208e78f64d47934e4abea229e5','2025-10-10 08:15:19'),
(113,4,'216db0fd617b54a6b6f2b7bd3d05cd9e4b32c42a2f01a1ac190649760fc9b839afefbfcbe3f905e6f655fe3e0d148e8f4da658dffdf97e8947ad7e45361a85b8','197.157.155.94','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-10 06:24:55','2025-10-10 07:24:55',1,'d6ee17629bcc06d33dde8ca22d17a27ae51b9f428c6535a4af594c37b64c981a','2025-10-10 08:24:55'),
(114,4,'b02a89e0c1a6abf17b2fc7055d47acf1da545405d58ed1fda9bd2e20e13e51b3abb537f1cebc175446e206f79740915476650e9d590d007d34644d5db6666654','197.157.155.94','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-10 06:53:59','2025-10-10 07:53:59',1,'affe19e62401f7a538eb6b2ba08e909fc5b9c8677b78ed5ca0843e15b6b8c54a','2025-10-10 08:53:59'),
(115,17,'92d9cd26681a20c76fc1336f4c7060f0fdfd01828da94d333b1a61fde26ee5233365f9612b6c9d8dbfe651c54c708019852e659864c3a629ac460d8006605ec9','2401:4900:a06e:7ded:9445:653:2877:4a56','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-10 07:10:41','2025-10-10 08:10:41',1,'9e298ffaf8be23839421099406b82406928bcc065a648a9c5a8ec647c1507163','2025-10-10 09:10:41'),
(116,4,'013f9c5893de28279875111d9ce24148b84238c2be1b9c4f67c5107ffafc5129a9101051be9fed7ef286b5418ac9c9159eefcb47db7a5596465f0c42089ad493','197.157.155.94','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-10 09:15:06','2025-10-10 10:15:06',1,'d9affb15da2cfb14189d834250f8d760f618dae55009c9536dab270cdcb8c285','2025-10-10 11:15:06'),
(117,4,'82c1aa8815ca7dba1d428a930fe4ac9af4f16d8b7f16b11bda26117edece4177def07fda40a2f87061f49c94df3e6ad430dc37ad4e658cd4355a44daee997544','197.157.155.159','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','2025-10-10 13:59:43','2025-10-10 14:59:43',1,'1238e9cad92e4272bbcd4847038212eec542b35ee44a0373328b022523b48a99','2025-10-10 15:59:43'),
(118,4,'9b3eb35fdb1b2dbd87243f64135bea600758178cb909ac3429530bf981138dcfc9cee520c238f7e0bf7e47f3d7d96373abf8efddc981138e980d504e1bb9aefe','105.178.104.166','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-10 18:04:22','2025-10-10 19:04:22',1,'00e7614a1a26d336b97bc4e5394dd87e2c117a19c5118f1fae824ed93541654a','2025-10-10 20:04:22'),
(119,4,'5b5780a0059b9b6a24aebba0dcbf21d198fbdd1a6a1cb5b9821120d1c2fd5ba5e83b1314e6d17496b24bbf0e8fb087b4340582d067b4cd8a8f0104470dbb5c4c','105.178.32.47','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 13:16:53','2025-10-11 14:16:53',1,'095606cffe1c73de3bf62a23f61934486157ecf77b05372af946665cb2087833','2025-10-11 15:16:53'),
(120,4,'c6aa4f8be58c37e988ab2824aae3ccf35750ee8b82490d298b5af16a59db53b60dcb98e9db5c1b9fdeb7b039d98e21bf9975bfbf216d1ac5925113635d22b54d','197.157.145.187','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','2025-10-11 14:49:12','2025-10-11 15:49:12',1,'8f0edd445939774bf36e3aeebce0b7323449584a38844c5b63aaacc8712b8a48','2025-10-11 16:49:12'),
(121,4,'9ebbdddf6252ae0fbe736168a12642eeb9d7948f7f94629504125e4bbf4cec5b693371601f314402fc21d707a9a9ff4f09853d43f79c5c05962895c9dffd8037','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 15:13:49','2025-10-11 16:13:49',1,'16fea9c0578c5ee68c980ed6f69145fe63258c7bcd3f421d04b3d17fc42282d0','2025-10-11 17:13:49'),
(122,4,'0dfb5ed6dfcb2bb2a5f19ec8beb21609a494a86c2bf0a6a7da9608adacc989fdd65dcaab27526149078fdb5753822a09a5ff46efa3ba46b0778dd1bbb793cd11','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 15:16:00','2025-10-11 16:16:00',1,'b486a24168aa0526c6a0ad7645c7c88215695a272aff38b5a1730da9e602fe13','2025-10-11 17:16:00'),
(123,4,'c08bb52614ef64bc37e6d3b8b6a36c6560b18dd5ee423b2bee638421ce9493a8b3ddfbe0e1f2508039858baabb66c41f764f96635fe931db788b67a6dd3ce065','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 15:56:33','2025-10-11 16:56:33',1,'c7d3f681087aa0e6c6f243ce83b5002480a6828bd62b2a9743f371d20990b8fd','2025-10-11 17:56:33'),
(124,4,'f5c3ef447bd802190f4d38400891a7cb769db8c0e60204c36c7dd89e8cbbe62cc431a18bc0250c7cda0023915c4ba29fd56a9ebe6d2b0dfb58eae858028c408b','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 17:28:46','2025-10-11 18:28:46',1,'34e0e34efc4199c262928fb170668def00834e157144a5c3887d55d6e4cb7dc8','2025-10-11 19:28:46'),
(125,4,'1e6d14f2e1a5fdfcb5d0d6373f2ca4171c3ae742245127ab4aab309ebb1f7daeb21c5ad2282ab103786b6156301dcb26935fedb05a86b5061204a75b22423b28','197.157.145.187','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','2025-10-11 17:45:58','2025-10-11 18:45:58',1,'463854f7612f1a671435b9720787297f868b64d98d17f63c17e666c3c4e00c40','2025-10-11 19:45:58'),
(126,4,'8dacf9e9f2bc74554299fa4883c700560b023169605a29c96fdeadf07816e2bcaa6df1b2adc8f1bfbf800b07ab84107df7373aeed029267b50c712c2da598239','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 18:50:16','2025-10-11 19:50:16',1,'a30abfddce549f6d2d71ea794301495689d1ccd0b9bf297aff03118785d10654','2025-10-11 20:50:16'),
(127,4,'29a75ddbccde6f13811fcb76341ca5fad0ac7fb08367bab59ad7b1ca53a7c394f271a4f23a92ec337020486a592939bad09d5cabe124b291eef9da9c075a5cbd','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 20:06:16','2025-10-11 21:06:16',1,'78ee21e48fd9de1481eab235e7a0f9b485a70c4e5d4493868453c0681aef94f1','2025-10-11 22:06:16'),
(128,4,'0fec0dc03be6c95004132f99d8d5e6222ac51132aa4f83365dd3dad937ced3470d592f8e45af7ec52ff50587b8297117438708a85409d04ea000f101cd47a9f4','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 21:10:49','2025-10-11 22:10:49',1,'a7f7234b1b119a465f4f86efbfd34663307fe9d2ae28610923aa17e0c3a8bfe9','2025-10-11 23:10:49'),
(129,4,'dfba8f1bfbc03166038964946ec992daf32afcd3ce361d43a97a86f99dcf2217b21ef858848e4ef3b533093c0e5c1bd5aafe4f036a5f26c5d114ef7beca2d787','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 21:44:39','2025-10-11 22:44:39',1,'258069a447600a1e26dc0ccb74b97945fd50a69baa672b49d0db98cc4167f75c','2025-10-11 23:44:39'),
(130,4,'a815955274e4d63d49cb44936219fe44cccd98508e0cec5d49e1ab29c694cbdca674fefabfcd84d90fa6261780d72bc44a1de67928e310309c1f999ea10c4aaa','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 21:58:20','2025-10-11 22:58:20',1,'6eaf454b52f3279b8934dfa893cb86f6ed9972be1540ba04c367cb609c4a805a','2025-10-11 23:58:20'),
(131,4,'3d538473b66e6da233818b454861595133e05f96d3fb742ccf136c78a9ad34d3e106490d093c3ade80977fc6121a0e74cde2b228c367d7801e163fc103b6f8ee','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 23:02:33','2025-10-12 00:02:33',1,'aed9341ebcb2c4ea3ff60b709588416991b544b80d489f8813ad415b62668c1a','2025-10-12 01:02:33'),
(132,19,'581d33bd10642410c19ee3095adfbe678c075522790d756340332c0d348d1e43003b800c6b435cf67fb8a4ae084c883c4a273553b4e7e65027f8e22d6607a451','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-11 23:33:00','2025-10-12 00:33:00',1,'07138402fad5d6154166c6918b49003884bfc99d0b03d485ec0f0ae2fa537b2b','2025-10-12 01:33:00'),
(133,4,'1f22684fa394d7e313ee6fcf5fb5ae78d699394fab816978208933e7cd1b8357216ec0c66ea48a2290e8362e276b2ba84372c2effbd6c30fe0840d73ce5632b3','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 00:06:03','2025-10-12 01:06:03',1,'617c1fc0c58d42a0c69cda941b36d94f02890b8726dfb467d62ab5bc3c5b5e64','2025-10-12 02:06:03'),
(134,4,'08d3c6698e269e08622b77b9f992314e4d2fa66ca47ad05110147353a0a39344190c6086f71e42534ca878c5e4ec7f3a0996941f0828648c607bd9ef7c07485d','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 01:07:18','2025-10-12 02:07:18',1,'6304e74ca571fc10596a486031d63bcb0b8d64f4060f28a28e5a527ae8bee56b','2025-10-12 03:07:18'),
(135,19,'1653702102de666facf0dd91db54d9a31185091d875ba9cca8d8df14efe9e062fb0584ca87359475c95c5c656417ff23de2068f41c1a88116b96e4a7e2024014','197.157.145.187','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 01:19:53','2025-10-12 02:19:53',1,'821f3d7e6192a775e668c7fce753382d4c61bfd8da90f064832e04e5c6728466','2025-10-12 03:19:53'),
(136,4,'0b17027eeb712340dcda2a2ff961d05c25602396788f7f90f264dc7c5e5285d699767eb997079645c1af0b3e0129ea900e59775fa424f304ad4f94e1b997d6c3','197.157.145.187','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','2025-10-12 01:32:25','2025-10-12 02:32:25',1,'3291622cffb02e6f9848885fff8f4b904f379e05b937580d503371da5570d54a','2025-10-12 03:32:25'),
(137,4,'2ac629349f5a64406cd9968050f19eac82cd8bd81a454dc55d225569068bd6cf90b3233fbe9e86763a9f303f2ae5265d9b59e5ceae404949e9452b8bc2d0baab','197.157.135.137','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 09:47:48','2025-10-12 10:47:48',1,'a4ced79be18047aa78a4931fbb98c60a2d01a124da53962c6304e4e132adc5f6','2025-10-12 11:47:48'),
(138,4,'eee692fe48b5428571e0cea531576b76ed646f21717b61ff0eaecdb0bf4e59857234f18a0c0e7e6792692021ffd7193078cbc3ec9437dc13b93ccaaa16f1048e','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 12:01:01','2025-10-12 13:01:01',1,'1f1d608be656d0c23f90d3a3ce1a03e040c44340f44174d78931d2d9ec6068d3','2025-10-12 14:01:01'),
(139,19,'56c154a355c0d10cebae20af1c5a67f4276121cdc14f67cc6b057ddcb5297be61161dd74033c768fcbdbc254510238a594005c655e86d575e41cf8f3ac36039e','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 13:48:26','2025-10-12 14:48:26',1,'04f2d93425fd2d1bc882f4ce2db48c175f92bd84e73d816320607c88c45ad391','2025-10-12 15:48:26'),
(140,19,'ad04f6aa21c072cc18443fcd6b3447f69b1aed4f9bb0ef1b5b54e41fe4327292f0027aea0ae060430089029bcb6f60863b79e1471040e8b1b36042017837982c','197.157.145.53','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','2025-10-12 14:32:22','2025-10-12 15:32:22',1,'75a5bb9647459803206d5a918194f0583ed6c0ace5c33cf26dafd1d94fdc1e4b','2025-10-12 16:32:22'),
(141,19,'f10954ffb18692df9b734b1657dda02e66d6acc9ae86b4bf7fb1a1ff53e9088620aafc5ec1059e67269498a33287c7400a8f6400b938c14991aae8db3ba6b773','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 16:00:31','2025-10-12 17:00:31',1,'55e87bf76c9e952855c67f7ee3dba3bf5f02e029f0db6d233955b75afd922366','2025-10-12 18:00:31'),
(142,4,'b1bd9e53915c1197f05f6dadb721da76d87ab819341b958f46ef7670c8428f81a47e3d4892563773c6743d989884f825060531a7c007cdcfe764e14c09838844','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 16:21:11','2025-10-12 17:21:11',1,'3a0446607b63190f03571b98e2f92803dbbd19152c0d7217013b6b163c3e090c','2025-10-12 18:21:11'),
(143,4,'9ec5512695a0342a6cd22f4c6595f588c1c2d5d524383d00a2555605393bd07d11d61e2650a9a61cc332772073bc86adbd97b5e0688c8a672ea0b67de0ed1c27','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 17:26:39','2025-10-12 18:26:39',1,'25a3fd398d3a7eb0ad6d8a6bdd0ee083be9b02eb47f597b0b4e38b09d5bb9fd9','2025-10-12 19:26:39'),
(144,4,'7f2c216db7a4b84b87c02a3359bc68186f732061c209aeb43a0f1f821c05a3a9660a27031c0f36d001022abdba4c723e0efedcb5111809ec0fa7bdd9102a749d','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 18:29:20','2025-10-12 19:29:20',1,'d3ec079f5bedf5cad63a1e017ef1d5276ee50a0f90f8f23ff687697b62aef8c4','2025-10-12 20:29:20'),
(145,4,'61eb8e273940b1e66ee8879a186fccadb4ec48e09a764910ebef547785539d7ddc9e5a13395fed2444bfde230dd1b6d774ee6b68af714213a1377f475ed3a1cf','197.157.145.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36','2025-10-12 21:01:34','2025-10-12 22:01:34',1,'e345004699ae93a47840dd14ac5c2c14639c4a87c16b2d1bdc85d347f3219bc3','2025-10-12 23:01:34'),
(146,4,'d5a4c4807f45fb38a8ae8cb8e4c2bf2d9fd34739c821fe733d3d820cf26e4a168da5aab9351bc9a00dc39162032cb00e7d823ffd0db122053b3674b29945847c','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-12 22:31:16','2025-10-12 23:31:16',1,'fdee4b2053972aa33fe33d850cd2dc0ebf1b28bde8355f081a1302d36055a340','2025-10-13 00:31:16'),
(147,4,'5c6e400aba35a89455f599a89dd42b330a14b129ae8a539c77929727826348310eb7898ffebf4da0d196845914fac548a0a01459ec6a21f883e44e23efe28a74','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-12 23:11:56','2025-10-13 00:11:56',1,'aa20e40a8062229e4d71ac5873c02839dfc01f4c330a030da559d911729e4cf5','2025-10-13 01:11:56'),
(148,4,'c1ac023c88c8ce4ebbc70bc15268ad4bdfe6e75f0f85bb03f7d3630981b0dcbcf1f087c34f872d41b3b57a4c8f2ac55ffcc6ab3f3afe407eb3ad9cab0979232e','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-13 00:18:32','2025-10-13 01:18:32',1,'b7573d7d9a52e02b2d2cc1be8141736b901e697c8ba79c0df217ed7a0f1d6cb3','2025-10-13 02:18:32'),
(149,19,'e47f29eabda56a8baa535a86c0c9031e3abfd3ae37881ee74ce98be9ba15a705c123265cc38858973ddf6d3aee0222d197df3af6bcb9f22f9652d18582f6af36','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-13 00:20:21','2025-10-13 01:20:21',1,'4de3f82c981a8f1f998826b7f7e6ba3d0c356db288ee2bc097237fa0ae030a3d','2025-10-13 02:20:21'),
(150,4,'40f9ec74fdb255370cd02907a3f9baa45f7b8e207deb0d2d71e26e91377e4f11996a2eaad742011ba06cc371e77e42a4ce549f19a02c775d3fab7e2eb6fbe321','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-13 01:21:48','2025-10-13 02:21:48',1,'f2ab78327b62c07f723d9af8ac4f9c918e645050cd95f93084fb9252cf17e605','2025-10-13 03:21:48'),
(151,19,'b9b5bbc964be3ea75a00e6ec6caf8a6d3933248aedd587bc878be6f1a23b3b367d7f54ef379739ac373bdc79cc7ca04b1cc90e31224e6d18895889ecca5356e2','197.157.165.74','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-13 01:22:23','2025-10-13 02:22:23',1,'e20678ff827c2a493604dc549bf9042b44a60f0cca6b5ebfd6b4333687b97ca8','2025-10-13 03:22:23'),
(152,19,'e9344b7d5b7dfa06df3c7fba15125703f38e7b0d0f777e620aa1f23dec5585753b8cc154849abbd065711cc3c512633231cb713bfa5112ca8223aec8f11cc3f5','197.157.135.140','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-13 06:33:38','2025-10-13 07:33:38',1,'7dda3170234159988b73ffe107bf7b07bac79423f6eeeb4653821cd971805bbb','2025-10-13 08:33:38'),
(153,19,'5b79f8df530550d7b48d8592d7b789eeb06a98c9e7563f9275b94026ff87a5657d5170e54f1157f355ad08637088f134e2e6bea2c0ce8ae16ea9d66797c7f673','197.157.135.140','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-13 07:46:38','2025-10-13 08:46:38',1,'d86e00244d67d5190804d1ada4892b41b1fd9e52d7881c41cffae1c58d20d550','2025-10-13 09:46:38'),
(154,4,'a992760ea1934e26ae8123ee05a00b50ab17fe62b9b56314e24618ce86e98e77cf861ce96ad91e6fa88d713d93354d76ca6f9d600cbd732869cb14831d3eda70','105.178.32.118','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-13 09:04:23','2025-10-13 10:04:23',1,'8a7f4e3889fd60345de704292a32be22e341416b5932fc9aa12fb7b10d355157','2025-10-13 11:04:23'),
(155,4,'59c5b01b642c3b6e887c5ccc77e914e23ce0fbf511f6a703f826963a0264bad67406e3ad1e4095ddfac525c825aa4baf0b844ad8e44f988ac5525adebda4874e','197.157.155.40','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-14 10:01:19','2025-10-14 11:01:19',1,'9452a0f1dacd012f401e021fdab8ea3f881e9a92632e316f26c1a3dde6f75bf0','2025-10-14 12:01:19'),
(156,4,'d1527ef1b08f26d59765dcb947068639c342377e295e3eeb285ff939d148f385503a795752dcafa27d2b840731c66d0fa7869b6268585120482ba3b378c3963e','197.157.155.40','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-14 11:02:02','2025-10-14 12:02:02',1,'ab377cf8b51852c88fd6f1564867892d7fe8fe31706a74467c932caac7f2e105','2025-10-14 13:02:02'),
(157,4,'1bde7f97abbc60f95356082ccc42227c3e3f8d55ca2ea076e9d5083f199186b4d70adbca93378e267d5ef7070121200c7afc87470520d7b23708cd8cedd84697','105.178.104.101','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-14 13:08:14','2025-10-14 14:08:14',1,'bebaebc69d29f458374a45523871caa997f6afa5462ed8f086871caacae2cc50','2025-10-14 15:08:14'),
(158,4,'4d90dcb6701dc61365d4a805577d1974fbe5377945bd3835946c3b84afa70cde0f4575691bd29cc665e464bdfba6db9e510a7aa339fc70a57c8436e809296d9c','105.178.32.101','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-14 14:31:10','2025-10-14 15:31:10',1,'bd736ed1df565d1e9030e4bc53fc99e94525f9cce03902636af4d63af418ecb8','2025-10-14 16:31:10'),
(159,4,'68a4ce0035270f74786e7dfe7372250d7ffb81ac5f3efabb2a1292a09bff164cc6498b5a9270c9ab681919eba1e49696aa506c19668d5e5efd7a2c99ec3922bb','197.157.186.89','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','2025-10-14 18:18:13','2025-10-14 19:18:13',1,'cbbe2706d888764371ce5d817f0c8cdee95cee4b7b3fa3563eb35965b96e5b93','2025-10-14 20:18:13'),
(160,4,'b2a001294399aa91531784881bcc66c7412c4eb733f8ce2b17f3ea772774033cb2d50d00c5cd3d27c96811a63da0bad126343ecf900790b2b22d80bc98bd9ce8','197.157.187.170','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-14 18:23:24','2025-10-14 19:23:24',1,'b04a305efce3c885ce4e452c2926a61aa89ee3b860afeca56526779ccc2c087f','2025-10-14 20:23:24'),
(161,4,'1d6b561cac79a4413aac49a0548cc65f394f4d91a4991a924ffc0faa7389e3a868b50a0eda58779e6af829648cc437e61fd324c884b2bf7d86c6ca33497d933a','197.157.187.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-14 20:16:21','2025-10-14 21:16:21',1,'74c6c6804f3c2cd7d84735ae3f5633d35b0bb0e5b88be15d71e83cec239f3b8c','2025-10-14 22:16:21'),
(162,4,'2fd3491ba0e9487075b1aee23fd07232ae4b5bffecbb722502372c8383976b555baff8ceaf3d88aae44822c493da1064ef568ea13f66f84db9bba2d86fad7b8c','197.157.187.84','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-14 22:19:45','2025-10-14 23:19:45',1,'b4b78723832268c159457cf63c9ac23160590c649dddd2499c9f97e026b7e244','2025-10-15 00:19:45'),
(163,4,'96d17b8ddbf012584aaeebc73bf8ee5e76677f51f9b29061ddf1e1582ec3eb407bb903c9a8b3421e5d2025be87bf3b2b9e8f6c1b4e25ca88713565bb4f61671b','105.178.104.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-15 09:02:17','2025-10-15 10:02:17',1,'9d742f533a100da71f41bc646da5e251f04cadfd0b2fb994ed6f7e1efbbc41b5','2025-10-15 11:02:17'),
(164,4,'fc95c67bcc17fce3418cb8b6335c84088aa854929313d3624a2c78d482db556aff8ec1a465856ba0c887938dd1107c9f363e3612e256f4af9a1c23b98add2ebd','105.178.32.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-15 10:40:10','2025-10-15 11:40:10',1,'82fd97c9862881091479baa263f55b0fac9b4292c4f894071b98cf02aaac9efa','2025-10-15 12:40:10'),
(165,4,'0e229b4c099905dd2b10894401f2fb0c00fd3ddd5ff2159d7709800fb3ae2670e2ea53709358f771b74cb3e5ede0d1e018dcf06b4a6c67d37bae6e375c878dc7','197.157.187.84','Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.105 Mobile Safari/537.36','2025-10-15 11:20:36','2025-10-15 12:20:36',1,'e5505f282a294d49ae4bd5ed429cddc863a3d0262a30d8b69000eb509cdbd815','2025-10-15 13:20:36'),
(166,4,'17a688289aee0b8c43e8181a316f7ce1b723dd5ba4cb914bed35a05b763cba293192ae0324b7905446353d34b04985ff09a2652dbfcc08cc06f8292ee1c4b8c2','105.178.104.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-15 12:46:01','2025-10-15 13:46:01',1,'664db44c399ebbe42466bb33969f6c397d1f7a105003d7e8713fd8c1d3196a7b','2025-10-15 14:46:01'),
(167,4,'03a9acd771d795407f3a3e5e303147ff6e4546d066c14d09037f3e34af8473100fc65e9ad7ee6229f31c0b67fd9256f685ed28ef9a012ef68b6c043bcc8a0784','105.178.32.138','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-15 15:00:59','2025-10-15 16:00:59',1,'a956a957b3281f735733eeb73cb2ca70ddf8239f75dcbcfec5035a33d33cd12a','2025-10-15 17:00:59'),
(168,4,'d40062db21aa19dffa982b7403ae5abc92a5804f6fc28d08c9ee951eea416a94a2716bdafa4f9e5bc709b092f3ddd87cc50eb53ec5e5ff3142f206e854612ebc','41.186.138.204','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-15 18:29:30','2025-10-15 19:29:30',1,'25ccb04d6efc87b780b0047c8a6b647cd277043da33377d81b1ec2d22ce1fcac','2025-10-15 20:29:30'),
(169,4,'0205e9d26b75d65b5817b441bbca0f2cfdd2a54fc80b69448e0be367c9e4a9fd3e7c524b3edb6db7c713bb433804010ac12aa3ee66e6ebdd49eec41837d99615','197.157.187.139','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-15 19:34:19','2025-10-15 20:34:19',1,'9c7868fe830132dc3129722633040cb3e30743b2df67df023f1c936520064566','2025-10-15 21:34:19'),
(170,4,'f5db00bcf65379c8749cf19c849f09610e3ab4a2c3e0ed279ba6bcf97968f131161c59ebd132e9abf8383e74c7560d37a6f7b14af9dbcb71fe02e009020b01da','197.157.187.169','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 07:35:00','2025-10-16 08:35:00',1,'0620247d3309be126769c54df181c91514ac80f601c1ce2bbba1cf9ed18328ed','2025-10-16 09:35:00'),
(171,4,'e0e07dddabfbe6fdcea47a84a0e219e35324957578dac1302f35ddb6c95df48078c8e6d7244d20a5146c4b3f325ca3a394b49c97af56eb60772293a2c7fff695','105.178.32.160','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 09:48:15','2025-10-16 10:48:15',1,'ccedf4df410c2dd240309d651926e8c95a607b3be991e3ee77d91a235c33164c','2025-10-16 11:48:15'),
(172,4,'d0735a764fa8ea59ebae513bf22ca8f7405cd72aca76aed013a4101e446ccc405dd15bebdb3abbc3fbb94ec2c5b6058eaa99629b73a990e67519b82f26fd51fb','105.178.32.160','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 10:56:08','2025-10-16 11:56:08',1,'074156c2db6ebe98db0bd9c47844fadfa8caccd250330b5c92e609da2750bf55','2025-10-16 12:56:08'),
(173,4,'f45ff55f6bb22c3c91ff70a8ea4d4e1fdf925fd56947f27cfc20fcc989bde67085a6449d6adfa80acfdb68ca89eca216b5f92fbc416fd1da74f7dfdacf0c2d2b','197.157.185.236','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 22:17:38','2025-10-16 23:17:38',1,'04d82117a27d38e17c608e42a6509064abd7db2db703cb925a2aa0e05de100d6','2025-10-17 00:17:38'),
(174,4,'a6a8f18d3cf5ae21b47e60730f52aae516038113f74b816096409cb30293c1a76346b52318b40f8a52dc41645124d3b644b5026e7f9f5d88a36269cb840d6b5c','197.157.186.103','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','2025-10-16 22:55:20','2025-10-16 23:55:20',1,'30d43699786b4e09cc06cbd5796ad0c81f9e88cae66f17501ee504cfe2414c0d','2025-10-17 00:55:20');
/*!40000 ALTER TABLE `user_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_two_factor_auth`
--

DROP TABLE IF EXISTS `user_two_factor_auth`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_two_factor_auth` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `method` enum('totp','sms','email','backup_codes') NOT NULL,
  `secret_key` varchar(255) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `backup_codes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`backup_codes`)),
  `is_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `recovery_codes_used` int(11) NOT NULL DEFAULT 0,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `enabled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_method` (`user_id`,`method`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_method` (`method`),
  KEY `idx_is_enabled` (`is_enabled`),
  CONSTRAINT `fk_user_two_factor_auth_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_two_factor_auth`
--

LOCK TABLES `user_two_factor_auth` WRITE;
/*!40000 ALTER TABLE `user_two_factor_auth` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_two_factor_auth` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_wallets`
--

DROP TABLE IF EXISTS `user_wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_wallets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_deposits` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_spent` decimal(15,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_user_wallets_balance` (`balance`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_wallets`
--

LOCK TABLES `user_wallets` WRITE;
/*!40000 ALTER TABLE `user_wallets` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_wallets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL DEFAULT 'guest',
  `email` varchar(100) NOT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `pass_hash` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) NOT NULL DEFAULT 'Unknown',
  `last_name` varchar(255) NOT NULL DEFAULT 'Unknown',
  `phone` varchar(20) DEFAULT NULL,
  `role` varchar(50) NOT NULL DEFAULT 'customer',
  `status` enum('active','inactive','pending','suspended','deleted') NOT NULL DEFAULT 'pending',
  `suspended` tinyint(1) DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`preferences`)),
  `two_factor_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `two_fa_secret` varchar(255) DEFAULT NULL,
  `login_email_alerts` tinyint(1) NOT NULL DEFAULT 1,
  `login_sms_alerts` tinyint(1) NOT NULL DEFAULT 0,
  `new_device_alerts` tinyint(1) NOT NULL DEFAULT 1,
  `suspicious_activity_alerts` tinyint(1) NOT NULL DEFAULT 1,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `last_login_ip` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login` datetime DEFAULT NULL,
  `stripe_customer_id` varchar(255) DEFAULT NULL COMMENT 'Stripe Customer ID for repeat purchases',
  `oauth_provider` varchar(50) DEFAULT NULL,
  `oauth_provider_id` varchar(255) DEFAULT NULL,
  `oauth_token` text DEFAULT NULL,
  `oauth_refresh_token` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`),
  UNIQUE KEY `idx_email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_users_role_status` (`role`,`status`),
  KEY `idx_stripe_customer_id` (`stripe_customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(1,'johndoe','johndoe@example.com',0,NULL,'John','Doe',NULL,'customer','pending',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-14 15:23:44','2025-10-14 15:23:44',NULL,NULL,NULL,NULL,NULL,NULL),
(4,'Joseph','ellyj164@gmail.com',0,'$argon2id$v=19$m=65536,t=4,p=3$Yjg2Y2dNN0wzdFZZOUEuUA$XCK6vnbTtHx4S8EJvZP0qHf3xXNl0UQKNxa9fIcTHWs','xxxx','Mark bb','+250 789 721 783','admin','active',0,NULL,NULL,NULL,NULL,'{\"email_marketing\":1,\"email_order_updates\":1,\"email_recommendations\":1,\"currency\":\"USD\",\"language\":\"en\",\"profile_public\":1,\"data_collection\":1}',1,NULL,NULL,1,1,1,1,NULL,NULL,'2025-09-11 15:56:21','2025-10-14 11:07:06',NULL,'cus_TEZC0jd1HprPCH',NULL,NULL,NULL,NULL),
(19,'dsdf','fezamarketgroup@gmail.com',1,'$argon2id$v=19$m=65536,t=4,p=3$UThseWc4dm9pNk0wSnNubQ$KMh601HJgIPnJ/Ahv3bvs6GELIjNcN3WqAzeQf9B+HA','ffefes','fggg','+250 788827138','customer','active',0,NULL,'2025-10-11 23:32:46',NULL,NULL,NULL,0,'2025-10-11 23:32:46',NULL,1,0,1,1,NULL,NULL,'2025-10-11 21:32:09','2025-10-11 23:32:46',NULL,NULL,NULL,NULL,NULL,NULL),
(20,'HunterTem','ayoka.l.us.oh.i55.5@gmail.com',0,'$argon2id$v=19$m=65536,t=4,p=3$RFBzeXZEQ045T1A1Z3J6RQ$zf6L/K9HrhzmeyDf6SgXCFirMtAoHHMSyaHPtgC3CSo','HunterTemLQ','HunterTemLQ','88446722649','customer','deleted',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-12 21:20:17','2025-10-14 20:24:28',NULL,NULL,NULL,NULL,NULL,NULL),
(21,'admin','admin@epd.local',0,'$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Admin','User',NULL,'admin','active',0,NULL,'2025-10-14 19:55:26',NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-14 19:55:26','2025-10-14 19:55:26',NULL,NULL,NULL,NULL,NULL,NULL),
(22,'seller1','seller@epd.local',0,'$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Test','Seller',NULL,'vendor','active',0,NULL,'2025-10-14 19:55:26',NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-14 19:55:26','2025-10-14 19:55:26',NULL,NULL,NULL,NULL,NULL,NULL),
(23,'john_doe','john@example.com',0,'$2y$10$EGsjrhL6.eDWrlVhHbwyZeeGZllVfz00oBc8jKsGswjuZ1cukIC/K','John','Doe',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:33:30','2025-10-15 14:33:30',NULL,NULL,NULL,NULL,NULL,NULL),
(24,'jane_seller','jane@example.com',0,'$2y$10$yhDxfyaj6wP1ylccGY7IceJzOu8L.yijaDo0/f3qViJhvGqNKMfwe','Jane','Smith',NULL,'seller','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:33:30','2025-10-15 14:33:30',NULL,NULL,NULL,NULL,NULL,NULL),
(25,'christophervazquez','ugarza@lamb.info',0,'$2y$10$nFgjMjm6g6JyN1w/DtaBWe63QkVXT/GKFaRhtlBe6TfgBIMgPWsh6','Brenda','King',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:53','2025-10-15 14:40:53',NULL,NULL,NULL,NULL,NULL,NULL),
(26,'hughesjessica','mramsey@hotmail.com',0,'$2y$10$hVH2W6llPo9QoiLPZq/Hse.GYNeisIg8cXUDmVLP3A/SNQvrRXS/y','Levi','Rivera',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:53','2025-10-15 14:40:53',NULL,NULL,NULL,NULL,NULL,NULL),
(27,'weaverwillie','cmcdonald@caldwell-patterson.net',0,'$2y$10$6M6mkkO66ValsIA6IsXfD.gsAWO03Vb/qMdDWS7M24OJ3EsFX2.UC','Stephanie','Henry',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:53','2025-10-15 14:40:53',NULL,NULL,NULL,NULL,NULL,NULL),
(28,'thomas21','vross@yahoo.com',0,'$2y$10$9s0cdrYp20cldDITRcH8aOt84CY32ubKER0Lq9kooMlfYRcXbrn6K','Stacy','Stafford',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(29,'brownashley','bowerserin@hotmail.com',0,'$2y$10$VM2HuB9pT6nDaVy9oi0G4egwNuTE6qo4HxJwHcWRuoSQxwY1/8NuW','James','Aguilar',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(30,'carpenterphilip','burkefelicia@hotmail.com',0,'$2y$10$tV1GrU3O5ChOrhhv7JJ4CuZ0nrRtReqN6hEe1.kH5d.IsCBxNmwVa','Stephanie','Johnson',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(31,'donaldramos','arthurharris@griffith.net',0,'$2y$10$Donc4Ywh9OET622Uq3yNj.dGbNxpuz0C/EOxlrRYLuNZSQvJrLV6S','Katie','Hanson',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(32,'castillojohn','uwaters@pena.com',0,'$2y$10$tdQmQMH5wBQMx2gNt/5qyektOKx5SaBZHpcBD81Aps6G.3otRYz4S','Nathan','Davila',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(33,'meghan73','amy55@johnson.com',0,'$2y$10$D7vvvNOl/yaSnEJhIaTA4utt7TZnDYj0.DvtUhMVEMBOgiwwhaYOu','Brooke','Fuentes',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(34,'jeanetteheath','robert11@pearson.org',0,'$2y$10$T.Wvl/91FMjfjiUEBGf0O.1HJBER3DhZG8isDp4i3ymkW9tYcE1YG','Marilyn','Thomas',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(35,'imoore','ewang@yahoo.com',0,'$2y$10$CJR/8ugYFOVxmk9GrEuqkOQ0drdTuCoeD.r7TNDR35pZiTajW8AUW','Joshua','Powell',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(36,'ian63','cummingsveronica@gmail.com',0,'$2y$10$ipWjCd0JgnUeSQd9BBrIfuYd03h38vGNRB2EuHPBlpY2oBYCp76mi','Janice','Haas',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(37,'anna20','jessicaadkins@johnson-thomas.org',0,'$2y$10$.O2UGCIJ1g5jePB4ll/huOhXBeWRUQj9ti086oH.c78c5M1hoTBE.','Catherine','Robinson',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(38,'msantiago','fhall@williams.net',0,'$2y$10$t3nKz6LKT66csL1IrpM83eIqOuTqQjhK5zhFq6ghcAH8uWHzSXfz.','Stephanie','Stone',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(39,'cynthia23','zwilliams@hotmail.com',0,'$2y$10$ZKB8DfhVN7W/c1fXVwbGS.cN9/a1bgncKEtl9e7.yxBfFzop1jYJy','Marie','Garcia',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(40,'chiggins','cheyenne32@taylor.info',0,'$2y$10$kgnoT2Y7v8PRvOEd0PedWuVak0SNgQtrBWXNxmtnZvPg0vLWtAAkO','Mark','Scott',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(41,'brittney44','richardsonmichael@williams.com',0,'$2y$10$b3B9y2kNGypJi43vF3ojOuWZ8Fc8.XVX1l6pNncdjs.YNixyWoyUC','Sharon','Roberson',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(42,'nancy62','mayala@wilson-cline.info',0,'$2y$10$7fTJ2Wttac91fi6tYiagG.klVod/B.dQnWaLzi7Bys7xeDnAb35HG','Mark','Mayo',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:54','2025-10-15 14:40:54',NULL,NULL,NULL,NULL,NULL,NULL),
(43,'joel79','robert30@herrera-garner.com',0,'$2y$10$sQP.RF9aB5yefAhiaVcSLexS3pXHvScZHTbN5KzFkIhr23qw/GZQW','Natasha','Hoffman',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:55','2025-10-15 14:40:55',NULL,NULL,NULL,NULL,NULL,NULL),
(44,'adrianbradshaw','tinajohnson@yahoo.com',0,'$2y$10$FXNjDoBp8uobLqYvxQu27OiPpN.vznnipQyyN/eXKe5LcjZ/w0AqC','Mark','Shea',NULL,'customer','active',0,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,1,0,1,1,NULL,NULL,'2025-10-15 14:40:55','2025-10-15 14:40:55',NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendor_commissions`
--

DROP TABLE IF EXISTS `vendor_commissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_commissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `commission_type` enum('percentage','fixed') NOT NULL DEFAULT 'percentage',
  `commission_rate` decimal(8,4) NOT NULL DEFAULT 5.0000,
  `commission_amount` decimal(10,2) DEFAULT NULL,
  `minimum_payout` decimal(10,2) NOT NULL DEFAULT 50.00,
  `payout_schedule` enum('weekly','monthly','quarterly') NOT NULL DEFAULT 'monthly',
  `status` enum('active','inactive','suspended') NOT NULL DEFAULT 'active',
  `effective_from` timestamp NOT NULL DEFAULT current_timestamp(),
  `effective_until` timestamp NULL DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_effective_from` (`effective_from`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_vendor_commissions_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vendor_commissions_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendor_commissions`
--

LOCK TABLES `vendor_commissions` WRITE;
/*!40000 ALTER TABLE `vendor_commissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `vendor_commissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendor_payouts`
--

DROP TABLE IF EXISTS `vendor_payouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_payouts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `commission_earned` decimal(10,2) NOT NULL,
  `platform_fee` decimal(10,2) NOT NULL DEFAULT 0.00,
  `tax_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `net_amount` decimal(10,2) NOT NULL,
  `payout_method` enum('bank_transfer','paypal','stripe','manual') NOT NULL DEFAULT 'bank_transfer',
  `reference_number` varchar(100) NOT NULL,
  `status` enum('pending','processing','completed','failed','cancelled') NOT NULL DEFAULT 'pending',
  `processed_at` timestamp NULL DEFAULT NULL,
  `failure_reason` text DEFAULT NULL,
  `payment_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payment_details`)),
  `period_from` date NOT NULL,
  `period_to` date NOT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_reference_number` (`reference_number`),
  KEY `idx_vendor_id` (`vendor_id`),
  KEY `idx_status` (`status`),
  KEY `idx_processed_at` (`processed_at`),
  KEY `idx_period_from` (`period_from`),
  KEY `idx_period_to` (`period_to`),
  KEY `idx_processed_by` (`processed_by`),
  CONSTRAINT `fk_vendor_payouts_processor` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_vendor_payouts_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `vendors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendor_payouts`
--

LOCK TABLES `vendor_payouts` WRITE;
/*!40000 ALTER TABLE `vendor_payouts` DISABLE KEYS */;
/*!40000 ALTER TABLE `vendor_payouts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendors`
--

DROP TABLE IF EXISTS `vendors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `business_name` varchar(100) NOT NULL,
  `business_description` text DEFAULT NULL,
  `business_type` enum('individual','business','corporation') NOT NULL DEFAULT 'individual',
  `tax_id` varchar(50) DEFAULT NULL,
  `business_address` text DEFAULT NULL,
  `business_phone` varchar(20) DEFAULT NULL,
  `business_email` varchar(100) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `logo_url` varchar(255) DEFAULT NULL,
  `banner_url` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','suspended','rejected') NOT NULL DEFAULT 'pending',
  `commission_rate` decimal(5,2) NOT NULL DEFAULT 10.00,
  `payment_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payment_details`)),
  `business_documents` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`business_documents`)),
  `approved_at` timestamp NULL DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `name` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_business_name` (`business_name`),
  KEY `fk_vendors_approver` (`approved_by`),
  CONSTRAINT `fk_vendors_approver` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_vendors_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendors`
--

LOCK TABLES `vendors` WRITE;
/*!40000 ALTER TABLE `vendors` DISABLE KEYS */;
INSERT INTO `vendors` VALUES
(3,4,'Fezamarket','ffffff','individual','','Kigali, Rwanda\r\nAUSTIN, TEXAS USA',NULL,NULL,NULL,NULL,NULL,NULL,'approved',10.00,NULL,NULL,NULL,NULL,'2025-09-14 20:46:17','2025-10-11 13:58:49','',''),
(5,22,'Test Seller Business',NULL,'business',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'approved',10.00,NULL,NULL,'2025-10-14 19:55:26',21,'2025-10-14 19:55:26','2025-10-14 19:55:26','','');
/*!40000 ALTER TABLE `vendors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallet`
--

DROP TABLE IF EXISTS `wallet`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallet` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `currency` varchar(10) NOT NULL DEFAULT 'RWF' COMMENT 'Currency code, e.g., RWF, USD',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id_unique_idx` (`user_id`),
  CONSTRAINT `fk_wallet_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet`
--

LOCK TABLES `wallet` WRITE;
/*!40000 ALTER TABLE `wallet` DISABLE KEYS */;
INSERT INTO `wallet` VALUES
(1,4,0.00,'USD','2025-10-03 20:51:00','2025-10-03 20:51:00');
/*!40000 ALTER TABLE `wallet` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallet_entries`
--

DROP TABLE IF EXISTS `wallet_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallet_entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wallet_id` int(11) NOT NULL,
  `entry_type` enum('credit','debit') NOT NULL,
  `transaction_type` enum('sale','commission','payout','refund','adjustment','fee','bonus') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `balance_before` decimal(15,2) NOT NULL,
  `balance_after` decimal(15,2) NOT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `description` text NOT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_wallet_id` (`wallet_id`),
  KEY `idx_entry_type` (`entry_type`),
  KEY `idx_transaction_type` (`transaction_type`),
  KEY `idx_reference` (`reference_type`,`reference_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_wallet_entries_creator` (`created_by`),
  CONSTRAINT `fk_wallet_entries_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_wallet_entries_wallet` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_entries`
--

LOCK TABLES `wallet_entries` WRITE;
/*!40000 ALTER TABLE `wallet_entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `wallet_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallet_transactions`
--

DROP TABLE IF EXISTS `wallet_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallet_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `wallet_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `from_user_id` int(11) DEFAULT NULL,
  `amount` decimal(18,2) NOT NULL,
  `type` enum('credit','debit','transfer') NOT NULL,
  `balance_before` decimal(18,2) DEFAULT NULL,
  `balance_after` decimal(18,2) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` enum('success','failed','pending') NOT NULL DEFAULT 'success',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_wallet_id` (`wallet_id`),
  KEY `idx_status` (`status`),
  KEY `idx_from_user_id` (`from_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_transactions`
--

LOCK TABLES `wallet_transactions` WRITE;
/*!40000 ALTER TABLE `wallet_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `wallet_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallets`
--

DROP TABLE IF EXISTS `wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `wallet_type` enum('vendor','affiliate','customer') NOT NULL DEFAULT 'vendor',
  `balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `status` enum('active','suspended') NOT NULL DEFAULT 'active',
  `pending_balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `frozen_balance` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_earned` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_withdrawn` decimal(15,2) NOT NULL DEFAULT 0.00,
  `currency` varchar(3) NOT NULL DEFAULT 'USD',
  `minimum_payout` decimal(10,2) NOT NULL DEFAULT 50.00,
  `auto_payout_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `auto_payout_threshold` decimal(10,2) NOT NULL DEFAULT 100.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_wallet_type` (`user_id`,`wallet_type`),
  KEY `idx_wallet_type` (`wallet_type`),
  KEY `idx_balance` (`balance`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_wallets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallets`
--

LOCK TABLES `wallets` WRITE;
/*!40000 ALTER TABLE `wallets` DISABLE KEYS */;
INSERT INTO `wallets` VALUES
(2,4,'vendor',0.00,'active',0.00,0.00,0.00,0.00,'USD',50.00,0,100.00,'2025-10-05 22:50:11','2025-10-05 22:50:11'),
(3,19,'vendor',0.00,'active',0.00,0.00,0.00,0.00,'USD',50.00,0,100.00,'2025-10-11 23:33:00','2025-10-11 23:33:00'),
(4,1,'vendor',0.00,'active',0.00,0.00,0.00,0.00,'USD',50.00,0,100.00,'2025-10-14 20:15:15','2025-10-14 20:15:15'),
(5,20,'vendor',0.00,'active',0.00,0.00,0.00,0.00,'USD',50.00,0,100.00,'2025-10-14 20:15:47','2025-10-14 20:15:47'),
(6,22,'vendor',0.00,'active',0.00,0.00,0.00,0.00,'USD',50.00,0,100.00,'2025-10-15 12:56:03','2025-10-15 12:56:03'),
(7,21,'vendor',0.00,'active',0.00,0.00,0.00,0.00,'USD',50.00,0,100.00,'2025-10-15 18:48:45','2025-10-15 18:48:45');
/*!40000 ALTER TABLE `wallets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `warehouses`
--

DROP TABLE IF EXISTS `warehouses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `code` varchar(50) NOT NULL,
  `address` text NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `country` varchar(2) NOT NULL DEFAULT 'US',
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `manager_id` int(11) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `operating_hours` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`operating_hours`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code` (`code`),
  KEY `idx_name` (`name`),
  KEY `idx_manager_id` (`manager_id`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_warehouses_manager` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `warehouses`
--

LOCK TABLES `warehouses` WRITE;
/*!40000 ALTER TABLE `warehouses` DISABLE KEYS */;
INSERT INTO `warehouses` VALUES
(1,'Main Warehouse','MAIN','123 Warehouse St','Los Angeles','CA','90210','US','+1-555-0123','warehouse@example.com',NULL,NULL,1,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26'),
(2,'East Coast Facility','EAST','456 Shipping Ave','New York','NY','10001','US','+1-555-0124','east@example.com',NULL,NULL,1,NULL,'2025-09-14 19:54:26','2025-09-14 19:54:26');
/*!40000 ALTER TABLE `warehouses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `watchlist`
--

DROP TABLE IF EXISTS `watchlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `watchlist` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_watchlist_user_product` (`user_id`,`product_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `watchlist_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `watchlist_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `watchlist`
--

LOCK TABLES `watchlist` WRITE;
/*!40000 ALTER TABLE `watchlist` DISABLE KEYS */;
INSERT INTO `watchlist` VALUES
(6,4,5,'2025-10-07 08:16:21'),
(9,4,13,'2025-10-15 20:13:03');
/*!40000 ALTER TABLE `watchlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webhook_deliveries`
--

DROP TABLE IF EXISTS `webhook_deliveries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhook_deliveries` (
  `id` int(11) NOT NULL,
  `webhook_id` int(11) NOT NULL,
  `integration_id` int(11) NOT NULL,
  `webhook_url` varchar(500) NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`payload`)),
  `response_status` int(11) DEFAULT NULL,
  `response_headers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`response_headers`)),
  `response_body` longtext DEFAULT NULL,
  `delivery_attempts` int(11) NOT NULL DEFAULT 1,
  `last_attempt` timestamp NOT NULL DEFAULT current_timestamp(),
  `next_attempt` timestamp NULL DEFAULT NULL,
  `status` enum('pending','delivered','failed','abandoned') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_webhook_integration` (`integration_id`),
  KEY `idx_webhook_status` (`status`),
  KEY `idx_webhook_event` (`event_type`),
  KEY `idx_webhook_next_attempt` (`next_attempt`),
  KEY `idx_webhook_id` (`webhook_id`),
  CONSTRAINT `fk_webhook_deliveries_integration` FOREIGN KEY (`integration_id`) REFERENCES `integrations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhook_deliveries`
--

LOCK TABLES `webhook_deliveries` WRITE;
/*!40000 ALTER TABLE `webhook_deliveries` DISABLE KEYS */;
/*!40000 ALTER TABLE `webhook_deliveries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webhook_subscriptions`
--

DROP TABLE IF EXISTS `webhook_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhook_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(500) NOT NULL,
  `events` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`events`)),
  `secret` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `retry_count` int(11) NOT NULL DEFAULT 3,
  `timeout` int(11) NOT NULL DEFAULT 30,
  `headers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`headers`)),
  `last_triggered_at` timestamp NULL DEFAULT NULL,
  `failure_count` int(11) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_last_triggered_at` (`last_triggered_at`),
  CONSTRAINT `fk_webhook_subscriptions_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhook_subscriptions`
--

LOCK TABLES `webhook_subscriptions` WRITE;
/*!40000 ALTER TABLE `webhook_subscriptions` DISABLE KEYS */;
INSERT INTO `webhook_subscriptions` VALUES
(1,'https://duns1.fezalogistics.com/','[\"payment.completed\"]','12c9d3d35669aed34578d6c3682eeaa828cf11e5882ad65ae0654785c1697998',1,3,30,NULL,NULL,0,4,'2025-10-05 13:13:41','2025-10-05 13:13:41'),
(2,'https://duns1.fezalogistics.com/','[\"order.cancelled\",\"payment.completed\"]','e65b1169f7141ac3c73edd9e774e1b1d098570d77148d8eed889130e5a7bbc32',1,3,30,NULL,NULL,0,4,'2025-10-05 13:14:35','2025-10-05 13:14:35'),
(3,'https://duns1.fezalogistics.com/','[\"order.cancelled\",\"payment.completed\"]','c210704fd4ac33da8bde58b2c1c72127944d2a82583186d17d14cc3c8744f16a',1,3,30,NULL,NULL,0,4,'2025-10-05 13:15:02','2025-10-05 13:15:02');
/*!40000 ALTER TABLE `webhook_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `webhooks`
--

DROP TABLE IF EXISTS `webhooks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `webhooks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `webhook_subscription_id` int(11) DEFAULT NULL,
  `url` varchar(255) NOT NULL,
  `environment` enum('sandbox','live') NOT NULL,
  `events` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`events`)),
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `secret` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id_idx` (`user_id`),
  KEY `fk_webhook_subscription_idx` (`webhook_subscription_id`),
  CONSTRAINT `fk_webhook_subscription` FOREIGN KEY (`webhook_subscription_id`) REFERENCES `api_subscriptions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_webhooks_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `webhooks`
--

LOCK TABLES `webhooks` WRITE;
/*!40000 ALTER TABLE `webhooks` DISABLE KEYS */;
/*!40000 ALTER TABLE `webhooks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wishlist`
--

DROP TABLE IF EXISTS `wishlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wishlist` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_product_wishlist` (`user_id`,`product_id`),
  KEY `idx_user_wishlist` (`user_id`),
  KEY `idx_product_wishlist` (`product_id`),
  KEY `idx_wishlist_created` (`created_at`),
  CONSTRAINT `fk_wishlist_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wishlist_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlist`
--

LOCK TABLES `wishlist` WRITE;
/*!40000 ALTER TABLE `wishlist` DISABLE KEYS */;
/*!40000 ALTER TABLE `wishlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wishlists`
--

DROP TABLE IF EXISTS `wishlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wishlists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `priority` tinyint(1) NOT NULL DEFAULT 3,
  `notes` text DEFAULT NULL,
  `price_alert` tinyint(1) NOT NULL DEFAULT 0,
  `alert_price` decimal(10,2) DEFAULT NULL,
  `notify_on_restock` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_product` (`user_id`,`product_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_priority` (`priority`),
  KEY `idx_price_alert` (`price_alert`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_wishlists_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wishlists_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlists`
--

LOCK TABLES `wishlists` WRITE;
/*!40000 ALTER TABLE `wishlists` DISABLE KEYS */;
INSERT INTO `wishlists` VALUES
(13,4,5,3,NULL,0,NULL,0,'2025-10-06 21:48:40','2025-10-06 21:48:40'),
(17,4,10,3,NULL,0,NULL,0,'2025-10-11 21:29:42','2025-10-11 21:29:42'),
(18,19,8,3,NULL,0,NULL,0,'2025-10-13 00:20:44','2025-10-13 00:20:44'),
(19,19,6,3,NULL,0,NULL,0,'2025-10-13 00:20:53','2025-10-13 00:20:53'),
(20,4,6,3,NULL,0,NULL,0,'2025-10-14 15:04:39','2025-10-14 15:04:39'),
(21,4,13,3,NULL,0,NULL,0,'2025-10-15 20:12:56','2025-10-15 20:12:56');
/*!40000 ALTER TABLE `wishlists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'ecommerce_platform'
--

--
-- Dumping routines for database 'ecommerce_platform'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-17  0:59:45
