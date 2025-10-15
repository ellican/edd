-- Comprehensive Notification System
-- Migration Date: October 15, 2025
-- This migration creates all required tables for a complete notification system

-- ============================================================================
-- Notification Templates Table
-- Stores reusable notification templates for all notification types
-- ============================================================================
CREATE TABLE IF NOT EXISTS `notification_templates` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `type` VARCHAR(100) NOT NULL UNIQUE COMMENT 'Unique identifier for notification type',
  `category` ENUM(
    'authentication',
    'order',
    'payment',
    'security',
    'marketing',
    'seller',
    'system'
  ) NOT NULL DEFAULT 'system',
  `name` VARCHAR(255) NOT NULL COMMENT 'Human-readable name',
  `description` TEXT NULL COMMENT 'Description of when this notification is used',
  `subject` VARCHAR(500) NOT NULL COMMENT 'Email subject line with variables',
  `body_template` TEXT NOT NULL COMMENT 'Email/notification body with variables',
  `variables` JSON NULL COMMENT 'List of available variables for this template',
  `enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `send_email` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Send as email',
  `send_in_app` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Send as in-app notification',
  `send_sms` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Send as SMS (optional)',
  `priority` ENUM('low', 'normal', 'high', 'urgent') NOT NULL DEFAULT 'normal',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_type` (`type`),
  INDEX `idx_category` (`category`),
  INDEX `idx_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Notification Preferences Table
-- Stores user preferences for notification channels
-- ============================================================================
CREATE TABLE IF NOT EXISTS `notification_preferences` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL,
  `category` ENUM(
    'authentication',
    'order',
    'payment',
    'security',
    'marketing',
    'seller',
    'system'
  ) NOT NULL,
  `email_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `in_app_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `sms_enabled` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_user_category` (`user_id`, `category`),
  INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Notification Logs Table
-- Tracks all sent notifications for audit and debugging
-- ============================================================================
CREATE TABLE IF NOT EXISTS `notification_logs` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL,
  `template_type` VARCHAR(100) NOT NULL,
  `category` VARCHAR(50) NOT NULL,
  `subject` VARCHAR(500) NOT NULL,
  `body` TEXT NOT NULL,
  `channel` ENUM('email', 'in_app', 'sms', 'push') NOT NULL,
  `status` ENUM('pending', 'sent', 'failed', 'bounced') NOT NULL DEFAULT 'pending',
  `recipient` VARCHAR(255) NULL COMMENT 'Email address, phone number, etc.',
  `error_message` TEXT NULL,
  `sent_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_template_type` (`template_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Email Attachments Table (Optional)
-- For notifications that need to include attachments
-- ============================================================================
CREATE TABLE IF NOT EXISTS `email_attachments` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `email_queue_id` BIGINT UNSIGNED NULL COMMENT 'Reference to email_queue table',
  `notification_log_id` BIGINT UNSIGNED NULL COMMENT 'Reference to notification_logs table',
  `file_name` VARCHAR(255) NOT NULL,
  `file_path` VARCHAR(500) NOT NULL,
  `file_size` INT UNSIGNED NOT NULL COMMENT 'Size in bytes',
  `mime_type` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_email_queue_id` (`email_queue_id`),
  INDEX `idx_notification_log_id` (`notification_log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Insert Default Notification Templates
-- ============================================================================

-- Authentication & Account Security Notifications
INSERT INTO `notification_templates` (`type`, `category`, `name`, `description`, `subject`, `body_template`, `variables`, `priority`) VALUES
('login_success', 'authentication', 'Successful Login', 'Sent after successful login with device info', 'Successful login to your {app_name} account', 'Hello {customer_name},\n\nYou successfully logged in to your account.\n\nTimestamp: {login_time}\nDevice: {device_info}\nIP Address: {ip_address}\nLocation: {location}\n\nIf this was not you, please secure your account immediately: {security_url}\n\nBest regards,\n{app_name} Team', '["customer_name","login_time","device_info","ip_address","location","security_url","app_name"]', 'normal'),

('login_failed', 'authentication', 'Failed Login Attempt', 'Sent after failed login attempts', 'Failed login attempt on your {app_name} account', 'Hello {customer_name},\n\nWe detected a failed login attempt on your account.\n\nTimestamp: {attempt_time}\nDevice: {device_info}\nIP Address: {ip_address}\nLocation: {location}\n\nIf this was you, please try again or reset your password: {reset_url}\n\nIf this was not you, your account may be at risk. Please secure it immediately: {security_url}\n\nBest regards,\n{app_name} Team', '["customer_name","attempt_time","device_info","ip_address","location","reset_url","security_url","app_name"]', 'high'),

('new_device_login', 'authentication', 'New Device Login', 'Sent when login from new device/location detected', 'New device login detected - {app_name}', 'Hello {customer_name},\n\nWe detected a login from a new device or location:\n\nTimestamp: {login_time}\nDevice: {device_info}\nBrowser: {browser_info}\nLocation: {location}\nIP Address: {ip_address}\n\nIf this was you, you can safely ignore this message.\n\nIf this was not you, please secure your account immediately: {security_url}\n\nBest regards,\n{app_name} Team', '["customer_name","login_time","device_info","browser_info","location","ip_address","security_url","app_name"]', 'high'),

('password_changed', 'authentication', 'Password Changed', 'Sent after successful password change', 'Your {app_name} password has been changed', 'Hello {customer_name},\n\nYour password was successfully changed.\n\nTimestamp: {change_time}\nDevice: {device_info}\nIP Address: {ip_address}\n\nIf you did not make this change, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","change_time","device_info","ip_address","support_email","app_name"]', 'high'),

('password_reset_request', 'authentication', 'Password Reset Request', 'Sent when password reset is requested', 'Reset your {app_name} password', 'Hello {customer_name},\n\nWe received a request to reset your password.\n\nClick here to reset your password: {reset_url}\n\nThis link will expire in {expiry_time}.\n\nIf you did not request this, please ignore this email and your password will remain unchanged.\n\nBest regards,\n{app_name} Team', '["customer_name","reset_url","expiry_time","app_name"]', 'high'),

('profile_updated', 'authentication', 'Profile Updated', 'Sent when profile information is edited', 'Your {app_name} profile has been updated', 'Hello {customer_name},\n\nYour profile information has been updated.\n\nChanges made:\n{changes_list}\n\nTimestamp: {update_time}\n\nIf you did not make these changes, please contact support immediately: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","changes_list","update_time","support_email","app_name"]', 'normal'),

('email_changed', 'authentication', 'Email Address Changed', 'Sent to both old and new email addresses', 'Your {app_name} email address has been changed', 'Hello {customer_name},\n\nYour email address has been changed from {old_email} to {new_email}.\n\nTimestamp: {change_time}\n\nIf you did not make this change, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","old_email","new_email","change_time","support_email","app_name"]', 'high'),

('2fa_enabled', 'authentication', '2FA Enabled', 'Sent when two-factor authentication is activated', 'Two-factor authentication enabled on your {app_name} account', 'Hello {customer_name},\n\nTwo-factor authentication has been successfully enabled on your account.\n\nTimestamp: {enable_time}\nDevice: {device_info}\n\nYour account is now more secure. You will need to enter a verification code when logging in from new devices.\n\nIf you did not enable this, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","enable_time","device_info","support_email","app_name"]', 'high'),

('2fa_disabled', 'authentication', '2FA Disabled', 'Sent when two-factor authentication is deactivated', 'Two-factor authentication disabled on your {app_name} account', 'Hello {customer_name},\n\nTwo-factor authentication has been disabled on your account.\n\nTimestamp: {disable_time}\nDevice: {device_info}\n\nYour account is now less secure. We recommend keeping 2FA enabled.\n\nIf you did not disable this, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","disable_time","device_info","support_email","app_name"]', 'high'),

('account_deactivated', 'authentication', 'Account Deactivated', 'Sent when account is deactivated', 'Your {app_name} account has been deactivated', 'Hello {customer_name},\n\nYour account has been deactivated.\n\nTimestamp: {deactivation_time}\nReason: {reason}\n\nYou can reactivate your account at any time by logging in: {login_url}\n\nIf you did not request this, please contact us: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","deactivation_time","reason","login_url","support_email","app_name"]', 'high'),

('account_reactivated', 'authentication', 'Account Reactivated', 'Sent when account is reactivated', 'Welcome back! Your {app_name} account has been reactivated', 'Hello {customer_name},\n\nYour account has been reactivated and you can now access all features.\n\nTimestamp: {reactivation_time}\n\nStart shopping: {shop_url}\n\nBest regards,\n{app_name} Team', '["customer_name","reactivation_time","shop_url","app_name"]', 'normal'),

('account_deletion_request', 'authentication', 'Account Deletion Request', 'Sent when account deletion is requested', 'Account deletion requested - {app_name}', 'Hello {customer_name},\n\nWe received a request to delete your account.\n\nYour account will be permanently deleted on: {deletion_date}\n\nTo cancel this request, log in to your account: {cancel_url}\n\nBest regards,\n{app_name} Team', '["customer_name","deletion_date","cancel_url","app_name"]', 'high'),

('account_deleted', 'authentication', 'Account Deleted', 'Sent when account is permanently deleted', 'Your {app_name} account has been deleted', 'Hello {customer_name},\n\nYour account has been permanently deleted as requested.\n\nAll your data has been removed from our systems.\n\nThank you for being part of {app_name}.\n\nBest regards,\n{app_name} Team', '["customer_name","app_name"]', 'high');

-- Order & Shopping Activity Notifications
INSERT INTO `notification_templates` (`type`, `category`, `name`, `description`, `subject`, `body_template`, `variables`, `priority`) VALUES
('order_placed', 'order', 'Order Placed', 'Sent immediately after order is placed', 'Order confirmation #{order_number} - {app_name}', 'Hello {customer_name},\n\nThank you for your order!\n\nOrder Number: #{order_number}\nOrder Date: {order_date}\nTotal Amount: {total_amount}\n\nOrder Details:\n{order_items}\n\nShipping Address:\n{shipping_address}\n\nTracking Link: {tracking_url}\n\nView your order: {order_url}\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","order_date","total_amount","order_items","shipping_address","tracking_url","order_url","app_name"]', 'high'),

('order_confirmed', 'order', 'Order Confirmed', 'Sent when order is confirmed by seller', 'Order #{order_number} confirmed - {app_name}', 'Hello {customer_name},\n\nYour order has been confirmed and is being prepared for shipment.\n\nOrder Number: #{order_number}\nConfirmed: {confirmation_time}\nEstimated Delivery: {estimated_delivery}\n\nTrack your order: {tracking_url}\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","confirmation_time","estimated_delivery","tracking_url","app_name"]', 'normal'),

('order_processing', 'order', 'Order Processing', 'Sent when order is being processed', 'Order #{order_number} is being processed - {app_name}', 'Hello {customer_name},\n\nYour order is now being processed.\n\nOrder Number: #{order_number}\nStatus: Processing\n\nWe will notify you once it has been shipped.\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","order_url","app_name"]', 'normal'),

('order_packed', 'order', 'Order Packed', 'Sent when order is packed and ready to ship', 'Order #{order_number} has been packed - {app_name}', 'Hello {customer_name},\n\nYour order has been packed and is ready for shipment.\n\nOrder Number: #{order_number}\nPacked: {packed_time}\n\nIt will be shipped soon!\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","packed_time","order_url","app_name"]', 'normal'),

('order_shipped', 'order', 'Order Shipped', 'Sent when order has shipped', 'Order #{order_number} has shipped - {app_name}', 'Hello {customer_name},\n\nGreat news! Your order has been shipped.\n\nOrder Number: #{order_number}\nShipped: {shipped_date}\nTracking Number: {tracking_number}\nCarrier: {carrier_name}\nEstimated Delivery: {estimated_delivery}\n\nTrack your shipment: {tracking_url}\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","shipped_date","tracking_number","carrier_name","estimated_delivery","tracking_url","app_name"]', 'high'),

('order_in_transit', 'order', 'Order In Transit', 'Sent when order is out for delivery', 'Order #{order_number} is out for delivery - {app_name}', 'Hello {customer_name},\n\nYour order is out for delivery!\n\nOrder Number: #{order_number}\nExpected Delivery: {delivery_date}\n\nTrack your order: {tracking_url}\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","delivery_date","tracking_url","app_name"]', 'normal'),

('order_delivered', 'order', 'Order Delivered', 'Sent when order is delivered', 'Order #{order_number} has been delivered - {app_name}', 'Hello {customer_name},\n\nYour order has been delivered!\n\nOrder Number: #{order_number}\nDelivered: {delivery_time}\n\nHow was your experience? Leave a review: {review_url}\n\nThank you for shopping with us!\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","delivery_time","review_url","app_name"]', 'high'),

('order_delayed', 'order', 'Order Delayed', 'Sent when shipment is delayed', 'Order #{order_number} is delayed - {app_name}', 'Hello {customer_name},\n\nWe apologize, but your order has been delayed.\n\nOrder Number: #{order_number}\nOriginal Delivery: {original_date}\nNew Estimated Delivery: {new_date}\nReason: {delay_reason}\n\nWe apologize for any inconvenience.\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","original_date","new_date","delay_reason","order_url","app_name"]', 'high'),

('order_backordered', 'order', 'Order Backordered', 'Sent when item is on backorder', 'Order #{order_number} - Item backordered - {app_name}', 'Hello {customer_name},\n\nOne or more items in your order are currently on backorder.\n\nOrder Number: #{order_number}\nBackordered Items:\n{backordered_items}\n\nExpected Restock Date: {restock_date}\n\nWe will ship your order as soon as items are available.\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","backordered_items","restock_date","order_url","app_name"]', 'normal'),

('order_cancelled', 'order', 'Order Cancelled', 'Sent when order is cancelled', 'Order #{order_number} has been cancelled - {app_name}', 'Hello {customer_name},\n\nYour order has been cancelled.\n\nOrder Number: #{order_number}\nCancelled: {cancellation_time}\nReason: {cancellation_reason}\n\nRefund Status: {refund_status}\n\nIf you have any questions, please contact us: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","cancellation_time","cancellation_reason","refund_status","support_email","app_name"]', 'high'),

('order_modified', 'order', 'Order Modified', 'Sent when order details are modified', 'Order #{order_number} has been modified - {app_name}', 'Hello {customer_name},\n\nYour order has been modified.\n\nOrder Number: #{order_number}\nModified: {modification_time}\n\nChanges:\n{changes_list}\n\nNew Total: {new_total}\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","modification_time","changes_list","new_total","order_url","app_name"]', 'normal'),

('review_request', 'order', 'Review Request', 'Sent after delivery to request product review', 'How was your order? - {app_name}', 'Hello {customer_name},\n\nWe hope you love your recent purchase!\n\nOrder Number: #{order_number}\n\nWould you mind leaving a review? Your feedback helps other customers and improves our service.\n\nLeave a review: {review_url}\n\nThank you for shopping with us!\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","review_url","app_name"]', 'low');

-- Payment & Billing Notifications
INSERT INTO `notification_templates` (`type`, `category`, `name`, `description`, `subject`, `body_template`, `variables`, `priority`) VALUES
('payment_successful', 'payment', 'Payment Successful', 'Sent when payment is processed successfully', 'Payment received - {app_name}', 'Hello {customer_name},\n\nYour payment has been processed successfully.\n\nAmount: {amount}\nPayment Method: {payment_method}\nTransaction ID: {transaction_id}\nDate: {payment_date}\n\nOrder Number: #{order_number}\n\nView invoice: {invoice_url}\n\nBest regards,\n{app_name} Team', '["customer_name","amount","payment_method","transaction_id","payment_date","order_number","invoice_url","app_name"]', 'high'),

('payment_failed', 'payment', 'Payment Failed', 'Sent when payment fails', 'Payment failed for order #{order_number} - {app_name}', 'Hello {customer_name},\n\nWe were unable to process your payment.\n\nOrder Number: #{order_number}\nAmount: {amount}\nReason: {failure_reason}\n\nPlease update your payment method and try again: {payment_url}\n\nIf you need assistance, contact us: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","order_number","amount","failure_reason","payment_url","support_email","app_name"]', 'urgent'),

('invoice_issued', 'payment', 'Invoice Issued', 'Sent when new invoice is created', 'Invoice #{invoice_number} - {app_name}', 'Hello {customer_name},\n\nA new invoice has been issued.\n\nInvoice Number: #{invoice_number}\nIssue Date: {issue_date}\nDue Date: {due_date}\nAmount: {amount}\n\nView invoice: {invoice_url}\nMake payment: {payment_url}\n\nBest regards,\n{app_name} Team', '["customer_name","invoice_number","issue_date","due_date","amount","invoice_url","payment_url","app_name"]', 'normal'),

('refund_issued', 'payment', 'Refund Issued', 'Sent when refund is processed', 'Refund processed - {app_name}', 'Hello {customer_name},\n\nYour refund has been processed.\n\nRefund Amount: {refund_amount}\nOriginal Order: #{order_number}\nRefund Method: {refund_method}\nProcessing Time: {processing_time}\n\nYou should see the refund in your account within {refund_days} business days.\n\nBest regards,\n{app_name} Team', '["customer_name","refund_amount","order_number","refund_method","processing_time","refund_days","app_name"]', 'high'),

('credit_issued', 'payment', 'Store Credit Issued', 'Sent when store credit is added', 'Store credit added to your account - {app_name}', 'Hello {customer_name},\n\nStore credit has been added to your account!\n\nCredit Amount: {credit_amount}\nReason: {credit_reason}\nExpires: {expiry_date}\n\nYour new balance: {new_balance}\n\nStart shopping: {shop_url}\n\nBest regards,\n{app_name} Team', '["customer_name","credit_amount","credit_reason","expiry_date","new_balance","shop_url","app_name"]', 'normal'),

('payment_method_added', 'payment', 'Payment Method Added', 'Sent when new payment method is added', 'New payment method added - {app_name}', 'Hello {customer_name},\n\nA new payment method has been added to your account.\n\nPayment Method: {payment_method}\nAdded: {add_time}\nDevice: {device_info}\n\nIf you did not make this change, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","payment_method","add_time","device_info","support_email","app_name"]', 'high'),

('payment_method_removed', 'payment', 'Payment Method Removed', 'Sent when payment method is removed', 'Payment method removed - {app_name}', 'Hello {customer_name},\n\nA payment method has been removed from your account.\n\nPayment Method: {payment_method}\nRemoved: {remove_time}\nDevice: {device_info}\n\nIf you did not make this change, please contact us immediately: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","payment_method","remove_time","device_info","support_email","app_name"]', 'high'),

('low_balance_alert', 'payment', 'Low Balance Alert', 'Sent when wallet balance is low', 'Low balance alert - {app_name}', 'Hello {customer_name},\n\nYour wallet balance is running low.\n\nCurrent Balance: {current_balance}\nLow Balance Threshold: {threshold}\n\nAdd funds to your wallet: {add_funds_url}\n\nBest regards,\n{app_name} Team', '["customer_name","current_balance","threshold","add_funds_url","app_name"]', 'normal');

-- Security & Compliance Alerts
INSERT INTO `notification_templates` (`type`, `category`, `name`, `description`, `subject`, `body_template`, `variables`, `priority`) VALUES
('suspicious_activity', 'security', 'Suspicious Activity Detected', 'Sent when suspicious activity is detected', 'Security alert - Suspicious activity detected - {app_name}', 'Hello {customer_name},\n\nWe detected suspicious activity on your account.\n\nActivity Type: {activity_type}\nDetected: {detection_time}\nLocation: {location}\nIP Address: {ip_address}\n\nWe have temporarily restricted some account functions for your protection.\n\nIf this was you, you can verify your identity here: {verify_url}\n\nIf this was not you, please secure your account immediately: {security_url}\n\nContact support: {support_email}\n\nBest regards,\n{app_name} Security Team', '["customer_name","activity_type","detection_time","location","ip_address","verify_url","security_url","support_email","app_name"]', 'urgent'),

('multiple_failed_logins', 'security', 'Multiple Failed Login Attempts', 'Sent after multiple failed login attempts', 'Security alert - Multiple failed login attempts - {app_name}', 'Hello {customer_name},\n\nWe detected multiple failed login attempts on your account.\n\nAttempts: {attempt_count}\nTime Period: {time_period}\nLast Attempt: {last_attempt_time}\nLocation: {location}\n\nYour account has been temporarily locked for security.\n\nReset your password: {reset_url}\n\nIf you need help, contact us: {support_email}\n\nBest regards,\n{app_name} Security Team', '["customer_name","attempt_count","time_period","last_attempt_time","location","reset_url","support_email","app_name"]', 'urgent'),

('terms_updated', 'security', 'Terms of Service Updated', 'Sent when ToS is updated', 'Terms of Service updated - {app_name}', 'Hello {customer_name},\n\nWe have updated our Terms of Service.\n\nEffective Date: {effective_date}\n\nKey Changes:\n{changes_summary}\n\nRead the full terms: {terms_url}\n\nBy continuing to use our service after {effective_date}, you agree to the updated terms.\n\nBest regards,\n{app_name} Team', '["customer_name","effective_date","changes_summary","terms_url","app_name"]', 'normal'),

('privacy_policy_updated', 'security', 'Privacy Policy Updated', 'Sent when privacy policy is updated', 'Privacy Policy updated - {app_name}', 'Hello {customer_name},\n\nWe have updated our Privacy Policy.\n\nEffective Date: {effective_date}\n\nKey Changes:\n{changes_summary}\n\nRead the full policy: {privacy_url}\n\nIf you have questions, contact us: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","effective_date","changes_summary","privacy_url","support_email","app_name"]', 'normal'),

('account_suspended', 'security', 'Account Suspended', 'Sent when account is suspended', 'Your account has been suspended - {app_name}', 'Hello {customer_name},\n\nYour account has been suspended.\n\nSuspension Date: {suspension_date}\nReason: {suspension_reason}\nDuration: {duration}\n\nTo appeal this decision or get more information, contact us: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","suspension_date","suspension_reason","duration","support_email","app_name"]', 'urgent'),

('account_restriction', 'security', 'Account Restriction Notice', 'Sent when account has restrictions', 'Account restriction notice - {app_name}', 'Hello {customer_name},\n\nCertain features of your account have been restricted.\n\nRestricted Features:\n{restricted_features}\n\nReason: {restriction_reason}\nDuration: {duration}\n\nTo resolve this, please: {resolution_steps}\n\nContact support: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","restricted_features","restriction_reason","duration","resolution_steps","support_email","app_name"]', 'high'),

('kyc_approved', 'security', 'KYC Verification Approved', 'Sent when KYC is approved', 'KYC verification approved - {app_name}', 'Hello {customer_name},\n\nGreat news! Your identity verification has been approved.\n\nVerification Level: {verification_level}\nApproved: {approval_date}\n\nYou now have access to all features.\n\nStart using your account: {dashboard_url}\n\nBest regards,\n{app_name} Team', '["customer_name","verification_level","approval_date","dashboard_url","app_name"]', 'high'),

('kyc_rejected', 'security', 'KYC Verification Rejected', 'Sent when KYC is rejected', 'KYC verification needs attention - {app_name}', 'Hello {customer_name},\n\nWe were unable to verify your identity.\n\nReason: {rejection_reason}\n\nYou can resubmit your documents: {resubmit_url}\n\nIf you need assistance, contact us: {support_email}\n\nBest regards,\n{app_name} Team', '["customer_name","rejection_reason","resubmit_url","support_email","app_name"]', 'high'),

('kyc_pending', 'security', 'KYC Verification Pending', 'Sent when KYC is under review', 'KYC verification is being reviewed - {app_name}', 'Hello {customer_name},\n\nThank you for submitting your verification documents.\n\nStatus: Under Review\nExpected Processing Time: {processing_time}\n\nWe will notify you once the review is complete.\n\nBest regards,\n{app_name} Team', '["customer_name","processing_time","app_name"]', 'normal');

-- Marketing & Engagement Notifications
INSERT INTO `notification_templates` (`type`, `category`, `name`, `description`, `subject`, `body_template`, `variables`, `priority`, `send_email`, `send_in_app`) VALUES
('newsletter', 'marketing', 'Newsletter', 'Regular newsletter', '{newsletter_title} - {app_name}', 'Hello {customer_name},\n\n{newsletter_content}\n\nRead more: {newsletter_url}\n\nBest regards,\n{app_name} Team', '["customer_name","newsletter_title","newsletter_content","newsletter_url","app_name"]', 'low', 1, 0),

('promotion', 'marketing', 'Promotional Offer', 'Special promotions and offers', '{promotion_title} - {app_name}', 'Hello {customer_name},\n\n{promotion_message}\n\nDiscount Code: {discount_code}\nValid Until: {expiry_date}\n\nShop now: {promotion_url}\n\nBest regards,\n{app_name} Team', '["customer_name","promotion_title","promotion_message","discount_code","expiry_date","promotion_url","app_name"]', 'low', 1, 1),

('price_drop', 'marketing', 'Price Drop Alert', 'Sent when wishlist item price drops', 'Price drop alert! - {app_name}', 'Hello {customer_name},\n\nGreat news! An item on your wishlist has dropped in price.\n\nProduct: {product_name}\nOld Price: {old_price}\nNew Price: {new_price}\nYou save: {savings}\n\nBuy now: {product_url}\n\nBest regards,\n{app_name} Team', '["customer_name","product_name","old_price","new_price","savings","product_url","app_name"]', 'normal', 1, 1),

('back_in_stock', 'marketing', 'Back in Stock Alert', 'Sent when wishlist item is back in stock', 'Back in stock! - {app_name}', 'Hello {customer_name},\n\nGood news! An item you were waiting for is back in stock.\n\nProduct: {product_name}\nPrice: {price}\n\nGet it before it sells out: {product_url}\n\nBest regards,\n{app_name} Team', '["customer_name","product_name","price","product_url","app_name"]', 'normal', 1, 1),

('abandoned_cart', 'marketing', 'Abandoned Cart Reminder', 'Sent when cart is abandoned', 'You left items in your cart - {app_name}', 'Hello {customer_name},\n\nYou have {item_count} items waiting in your cart.\n\n{cart_items}\n\nTotal: {cart_total}\n\nComplete your purchase: {cart_url}\n\nUse code {discount_code} for {discount_percent}% off!\n\nBest regards,\n{app_name} Team', '["customer_name","item_count","cart_items","cart_total","cart_url","discount_code","discount_percent","app_name"]', 'low', 1, 1),

('new_product_alert', 'marketing', 'New Product Alert', 'Sent when new products match preferences', 'New products you might like - {app_name}', 'Hello {customer_name},\n\nWe added new products based on your interests:\n\n{products_list}\n\nExplore more: {shop_url}\n\nBest regards,\n{app_name} Team', '["customer_name","products_list","shop_url","app_name"]', 'low', 1, 1);

-- Seller-Side Notifications
INSERT INTO `notification_templates` (`type`, `category`, `name`, `description`, `subject`, `body_template`, `variables`, `priority`) VALUES
('seller_new_order', 'seller', 'New Order Received', 'Sent when seller receives new order', 'New order received #{order_number} - {app_name}', 'Hello {seller_name},\n\nYou have received a new order!\n\nOrder Number: #{order_number}\nCustomer: {customer_name}\nAmount: {order_amount}\nItems: {item_count}\n\nView order details: {order_url}\n\nPlease process this order promptly.\n\nBest regards,\n{app_name} Team', '["seller_name","order_number","customer_name","order_amount","item_count","order_url","app_name"]', 'urgent'),

('seller_order_status_changed', 'seller', 'Order Status Changed', 'Sent when order status is updated', 'Order #{order_number} status updated - {app_name}', 'Hello {seller_name},\n\nOrder status has been updated.\n\nOrder Number: #{order_number}\nNew Status: {new_status}\nUpdated: {update_time}\n\nView order: {order_url}\n\nBest regards,\n{app_name} Team', '["seller_name","order_number","new_status","update_time","order_url","app_name"]', 'normal'),

('seller_low_stock', 'seller', 'Low Stock Alert', 'Sent when product stock is low', 'Low stock alert - {product_name} - {app_name}', 'Hello {seller_name},\n\nYour product is running low on stock.\n\nProduct: {product_name}\nCurrent Stock: {current_stock}\nLow Stock Threshold: {threshold}\n\nRestock soon to avoid stockouts.\n\nUpdate inventory: {inventory_url}\n\nBest regards,\n{app_name} Team', '["seller_name","product_name","current_stock","threshold","inventory_url","app_name"]', 'high'),

('seller_out_of_stock', 'seller', 'Out of Stock Alert', 'Sent when product is out of stock', 'Product out of stock - {product_name} - {app_name}', 'Hello {seller_name},\n\nYour product is now out of stock.\n\nProduct: {product_name}\nLast Sold: {last_sold_time}\n\nRestock to continue selling.\n\nUpdate inventory: {inventory_url}\n\nBest regards,\n{app_name} Team', '["seller_name","product_name","last_sold_time","inventory_url","app_name"]', 'urgent'),

('seller_payout_issued', 'seller', 'Payout Issued', 'Sent when payout is processed', 'Payout issued - {app_name}', 'Hello {seller_name},\n\nYour payout has been processed!\n\nPayout Amount: {payout_amount}\nPeriod: {payout_period}\nPayment Method: {payment_method}\nTransfer Date: {transfer_date}\n\nView details: {payout_url}\n\nBest regards,\n{app_name} Team', '["seller_name","payout_amount","payout_period","payment_method","transfer_date","payout_url","app_name"]', 'high'),

('seller_payout_failed', 'seller', 'Payout Failed', 'Sent when payout fails', 'Payout failed - Action required - {app_name}', 'Hello {seller_name},\n\nWe were unable to process your payout.\n\nPayout Amount: {payout_amount}\nReason: {failure_reason}\n\nPlease update your payment information: {payment_settings_url}\n\nContact support if you need help: {support_email}\n\nBest regards,\n{app_name} Team', '["seller_name","payout_amount","failure_reason","payment_settings_url","support_email","app_name"]', 'urgent'),

('seller_message_received', 'seller', 'Customer Message', 'Sent when buyer sends message', 'New message from customer - {app_name}', 'Hello {seller_name},\n\nYou have received a new message from a customer.\n\nFrom: {customer_name}\nRegarding: Order #{order_number}\n\nMessage:\n{message_content}\n\nRespond to message: {message_url}\n\nBest regards,\n{app_name} Team', '["seller_name","customer_name","order_number","message_content","message_url","app_name"]', 'high'),

('seller_dispute_opened', 'seller', 'Dispute Opened', 'Sent when buyer opens dispute', 'Dispute opened - Order #{order_number} - {app_name}', 'Hello {seller_name},\n\nA customer has opened a dispute.\n\nOrder Number: #{order_number}\nCustomer: {customer_name}\nDispute Type: {dispute_type}\nReason: {dispute_reason}\n\nPlease respond within {response_time} to avoid auto-refund.\n\nView dispute: {dispute_url}\n\nBest regards,\n{app_name} Team', '["seller_name","order_number","customer_name","dispute_type","dispute_reason","response_time","dispute_url","app_name"]', 'urgent'),

('seller_review_received', 'seller', 'New Review Received', 'Sent when seller receives review', 'New review received - {app_name}', 'Hello {seller_name},\n\nYou have received a new review!\n\nProduct: {product_name}\nRating: {rating} stars\nCustomer: {customer_name}\n\nReview:\n{review_text}\n\nView review: {review_url}\n\nBest regards,\n{app_name} Team', '["seller_name","product_name","rating","customer_name","review_text","review_url","app_name"]', 'normal'),

('seller_policy_violation', 'seller', 'Policy Violation Warning', 'Sent when seller violates policy', 'Policy violation warning - {app_name}', 'Hello {seller_name},\n\nWe detected a policy violation on your account.\n\nViolation Type: {violation_type}\nDate: {violation_date}\nDetails: {violation_details}\n\nAction Taken: {action_taken}\n\nPlease review our policies: {policies_url}\n\nRepeated violations may result in account suspension.\n\nContact support: {support_email}\n\nBest regards,\n{app_name} Team', '["seller_name","violation_type","violation_date","violation_details","action_taken","policies_url","support_email","app_name"]', 'urgent'),

('seller_account_suspended', 'seller', 'Seller Account Suspended', 'Sent when seller account is suspended', 'Your seller account has been suspended - {app_name}', 'Hello {seller_name},\n\nYour seller account has been suspended.\n\nSuspension Date: {suspension_date}\nReason: {suspension_reason}\n\nDuring suspension, you cannot:\n- List new products\n- Process orders\n- Receive payouts\n\nTo appeal or resolve this: {appeal_url}\n\nContact support: {support_email}\n\nBest regards,\n{app_name} Team', '["seller_name","suspension_date","suspension_reason","appeal_url","support_email","app_name"]', 'urgent'),

('seller_performance_summary', 'seller', 'Performance Summary', 'Monthly performance report', 'Your monthly performance summary - {app_name}', 'Hello {seller_name},\n\nHere is your performance summary for {period}:\n\nTotal Sales: {total_sales}\nOrders: {order_count}\nAverage Rating: {avg_rating} stars\nResponse Rate: {response_rate}%\n\nTop Products:\n{top_products}\n\nView full report: {report_url}\n\nBest regards,\n{app_name} Team', '["seller_name","period","total_sales","order_count","avg_rating","response_rate","top_products","report_url","app_name"]', 'low');

-- Platform System Notifications
INSERT INTO `notification_templates` (`type`, `category`, `name`, `description`, `subject`, `body_template`, `variables`, `priority`) VALUES
('system_feature_update', 'system', 'New Feature Available', 'Sent when new features are added', 'New features on {app_name}!', 'Hello {customer_name},\n\nWe have exciting new features for you!\n\n{features_list}\n\nCheck them out: {features_url}\n\nBest regards,\n{app_name} Team', '["customer_name","features_list","features_url","app_name"]', 'low'),

('system_maintenance', 'system', 'Scheduled Maintenance', 'Sent before scheduled maintenance', 'Scheduled maintenance - {app_name}', 'Hello {customer_name},\n\nWe will be performing scheduled maintenance.\n\nStart: {maintenance_start}\nEnd: {maintenance_end}\nDuration: {duration}\n\nDuring this time, {affected_services} may be unavailable.\n\nWe apologize for any inconvenience.\n\nBest regards,\n{app_name} Team', '["customer_name","maintenance_start","maintenance_end","duration","affected_services","app_name"]', 'high'),

('system_downtime', 'system', 'Unplanned Downtime', 'Sent after unplanned downtime', 'Service interruption notice - {app_name}', 'Hello {customer_name},\n\nWe experienced an unplanned service interruption.\n\nOccurred: {downtime_start}\nRestored: {downtime_end}\nAffected Services: {affected_services}\n\nAll systems are now operational. We apologize for any inconvenience.\n\nBest regards,\n{app_name} Team', '["customer_name","downtime_start","downtime_end","affected_services","app_name"]', 'high'),

('api_key_activity', 'system', 'API Key Activity', 'Sent when API key is used', 'API key activity detected - {app_name}', 'Hello {customer_name},\n\nActivity detected on your API key:\n\nAPI Key: {api_key_name}\nActivity: {activity_type}\nTimestamp: {activity_time}\nIP Address: {ip_address}\n\nManage API keys: {api_settings_url}\n\nBest regards,\n{app_name} Team', '["customer_name","api_key_name","activity_type","activity_time","ip_address","api_settings_url","app_name"]', 'normal'),

('webhook_failure', 'system', 'Webhook Failure', 'Sent when webhook fails', 'Webhook failure - {app_name}', 'Hello {customer_name},\n\nA webhook failed to deliver.\n\nWebhook: {webhook_name}\nEndpoint: {webhook_url}\nFailed At: {failure_time}\nError: {error_message}\n\nAttempts: {attempt_count}/{max_attempts}\n\nCheck your webhook configuration: {webhook_settings_url}\n\nBest regards,\n{app_name} Team', '["customer_name","webhook_name","webhook_url","failure_time","error_message","attempt_count","max_attempts","webhook_settings_url","app_name"]', 'high'),

('app_connection_update', 'system', 'App Connection Update', 'Sent when connected app is updated', 'App connection updated - {app_name}', 'Hello {customer_name},\n\nA connected application has been updated.\n\nApp: {connected_app_name}\nUpdate Type: {update_type}\nTimestamp: {update_time}\n\nManage connections: {connections_url}\n\nBest regards,\n{app_name} Team', '["customer_name","connected_app_name","update_type","update_time","connections_url","app_name"]', 'normal');

-- ============================================================================
-- Create default notification preferences for existing users
-- ============================================================================
INSERT IGNORE INTO `notification_preferences` (`user_id`, `category`, `email_enabled`, `in_app_enabled`, `sms_enabled`)
SELECT 
    id as user_id,
    'authentication' as category,
    1 as email_enabled,
    1 as in_app_enabled,
    0 as sms_enabled
FROM users
WHERE NOT EXISTS (
    SELECT 1 FROM notification_preferences np 
    WHERE np.user_id = users.id AND np.category = 'authentication'
);

-- Repeat for all categories
INSERT IGNORE INTO `notification_preferences` (`user_id`, `category`, `email_enabled`, `in_app_enabled`, `sms_enabled`)
SELECT id, 'order', 1, 1, 0 FROM users;

INSERT IGNORE INTO `notification_preferences` (`user_id`, `category`, `email_enabled`, `in_app_enabled`, `sms_enabled`)
SELECT id, 'payment', 1, 1, 0 FROM users;

INSERT IGNORE INTO `notification_preferences` (`user_id`, `category`, `email_enabled`, `in_app_enabled`, `sms_enabled`)
SELECT id, 'security', 1, 1, 0 FROM users;

INSERT IGNORE INTO `notification_preferences` (`user_id`, `category`, `email_enabled`, `in_app_enabled`, `sms_enabled`)
SELECT id, 'marketing', 1, 1, 0 FROM users;

INSERT IGNORE INTO `notification_preferences` (`user_id`, `category`, `email_enabled`, `in_app_enabled`, `sms_enabled`)
SELECT id, 'seller', 1, 1, 0 FROM users WHERE role = 'seller';

INSERT IGNORE INTO `notification_preferences` (`user_id`, `category`, `email_enabled`, `in_app_enabled`, `sms_enabled`)
SELECT id, 'system', 1, 1, 0 FROM users;
