<?php
/**
 * Notification Integration Helpers
 * Helper functions to easily integrate notifications throughout the platform
 * E-Commerce Platform - PHP 8
 */

require_once __DIR__ . '/enhanced_notification_service.php';

// ============================================================================
// AUTHENTICATION & SECURITY INTEGRATIONS
// ============================================================================

/**
 * Send login success notification
 * Call this after successful user authentication
 */
function notifyLoginSuccess($userId, $deviceInfo = []) {
    $variables = [
        'login_time' => date('F j, Y g:i A'),
        'device_info' => $deviceInfo['device'] ?? $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown device',
        'ip_address' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
        'location' => $deviceInfo['location'] ?? 'Unknown',
        'security_url' => APP_URL . '/account.php?tab=security',
        'action_url' => APP_URL . '/account.php'
    ];
    
    return sendNotification('login_success', $userId, $variables);
}

/**
 * Send failed login alert
 */
function notifyFailedLogin($userId, $email) {
    $variables = [
        'attempt_time' => date('F j, Y g:i A'),
        'device_info' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown device',
        'ip_address' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
        'location' => 'Unknown', // Integrate with GeoIP service
        'reset_url' => APP_URL . '/forgot-password.php',
        'security_url' => APP_URL . '/account.php?tab=security',
        'action_url' => APP_URL . '/login.php'
    ];
    
    return sendNotification('login_failed', $userId, $variables, ['force_email' => true]);
}

/**
 * Send new device login alert
 */
function notifyNewDeviceLogin($userId, $deviceInfo = []) {
    $variables = [
        'login_time' => date('F j, Y g:i A'),
        'device_info' => $deviceInfo['device'] ?? $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown device',
        'browser_info' => $deviceInfo['browser'] ?? 'Unknown browser',
        'location' => $deviceInfo['location'] ?? 'Unknown',
        'ip_address' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
        'security_url' => APP_URL . '/account.php?tab=security',
        'action_url' => APP_URL . '/account.php?tab=security'
    ];
    
    return sendNotification('new_device_login', $userId, $variables, ['force_email' => true]);
}

/**
 * Send password changed notification
 */
function notifyPasswordChanged($userId) {
    $variables = [
        'change_time' => date('F j, Y g:i A'),
        'device_info' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown device',
        'ip_address' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
        'action_url' => APP_URL . '/account.php'
    ];
    
    return sendNotification('password_changed', $userId, $variables, ['force_email' => true, 'force_in_app' => true]);
}

/**
 * Send password reset request notification
 */
function notifyPasswordResetRequest($userId, $resetToken) {
    $variables = [
        'reset_url' => APP_URL . '/reset-password.php?token=' . urlencode($resetToken),
        'expiry_time' => '1 hour',
        'action_url' => APP_URL . '/reset-password.php?token=' . urlencode($resetToken)
    ];
    
    return sendNotification('password_reset_request', $userId, $variables, ['force_email' => true]);
}

/**
 * Send profile updated notification
 */
function notifyProfileUpdated($userId, $changes = []) {
    $changesList = '';
    foreach ($changes as $field => $value) {
        $changesList .= "- " . ucfirst(str_replace('_', ' ', $field)) . "\n";
    }
    
    $variables = [
        'changes_list' => $changesList,
        'update_time' => date('F j, Y g:i A'),
        'action_url' => APP_URL . '/account.php'
    ];
    
    return sendNotification('profile_updated', $userId, $variables);
}

/**
 * Send email changed notification
 */
function notifyEmailChanged($userId, $oldEmail, $newEmail) {
    $variables = [
        'old_email' => $oldEmail,
        'new_email' => $newEmail,
        'change_time' => date('F j, Y g:i A'),
        'action_url' => APP_URL . '/account.php'
    ];
    
    // Send to both emails
    sendNotification('email_changed', $userId, $variables, ['force_email' => true]);
    return true;
}

/**
 * Send 2FA enabled notification
 */
function notify2FAEnabled($userId) {
    $variables = [
        'enable_time' => date('F j, Y g:i A'),
        'device_info' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown device',
        'action_url' => APP_URL . '/account.php?tab=security'
    ];
    
    return sendNotification('2fa_enabled', $userId, $variables, ['force_email' => true]);
}

/**
 * Send 2FA disabled notification
 */
function notify2FADisabled($userId) {
    $variables = [
        'disable_time' => date('F j, Y g:i A'),
        'device_info' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown device',
        'action_url' => APP_URL . '/account.php?tab=security'
    ];
    
    return sendNotification('2fa_disabled', $userId, $variables, ['force_email' => true]);
}

// ============================================================================
// ORDER & SHOPPING INTEGRATIONS
// ============================================================================

/**
 * Send order placed notification
 */
function notifyOrderPlaced($userId, $orderDetails) {
    $itemsList = '';
    foreach ($orderDetails['items'] as $item) {
        $itemsList .= "- " . $item['name'] . " (x" . $item['quantity'] . ") - " . $item['price'] . "\n";
    }
    
    $variables = [
        'order_number' => $orderDetails['order_number'],
        'order_date' => date('F j, Y g:i A', strtotime($orderDetails['created_at'])),
        'total_amount' => formatCurrency($orderDetails['total']),
        'order_items' => $itemsList,
        'shipping_address' => $orderDetails['shipping_address'] ?? 'N/A',
        'tracking_url' => APP_URL . '/account.php?section=orders&id=' . $orderDetails['id'],
        'order_url' => APP_URL . '/account.php?section=orders&id=' . $orderDetails['id'],
        'action_url' => APP_URL . '/account.php?section=orders&id=' . $orderDetails['id']
    ];
    
    return sendNotification('order_placed', $userId, $variables, ['force_email' => true, 'force_in_app' => true]);
}

/**
 * Send order shipped notification
 */
function notifyOrderShipped($userId, $orderDetails, $trackingInfo) {
    $variables = [
        'order_number' => $orderDetails['order_number'],
        'shipped_date' => date('F j, Y'),
        'tracking_number' => $trackingInfo['tracking_number'],
        'carrier_name' => $trackingInfo['carrier'] ?? 'Standard Shipping',
        'estimated_delivery' => date('F j, Y', strtotime($trackingInfo['estimated_delivery'] ?? '+5 days')),
        'tracking_url' => $trackingInfo['tracking_url'] ?? APP_URL . '/account.php?section=orders&id=' . $orderDetails['id'],
        'action_url' => APP_URL . '/account.php?section=orders&id=' . $orderDetails['id']
    ];
    
    return sendNotification('order_shipped', $userId, $variables, ['force_email' => true, 'force_in_app' => true]);
}

/**
 * Send order delivered notification
 */
function notifyOrderDelivered($userId, $orderDetails) {
    $variables = [
        'order_number' => $orderDetails['order_number'],
        'delivery_time' => date('F j, Y g:i A'),
        'review_url' => APP_URL . '/review.php?order=' . $orderDetails['id'],
        'action_url' => APP_URL . '/review.php?order=' . $orderDetails['id']
    ];
    
    return sendNotification('order_delivered', $userId, $variables, ['force_email' => true, 'force_in_app' => true]);
}

/**
 * Send order cancelled notification
 */
function notifyOrderCancelled($userId, $orderDetails, $reason = 'Customer request') {
    $variables = [
        'order_number' => $orderDetails['order_number'],
        'cancellation_time' => date('F j, Y g:i A'),
        'cancellation_reason' => $reason,
        'refund_status' => 'Processing',
        'action_url' => APP_URL . '/account.php?section=orders&id=' . $orderDetails['id']
    ];
    
    return sendNotification('order_cancelled', $userId, $variables);
}

// ============================================================================
// PAYMENT & BILLING INTEGRATIONS
// ============================================================================

/**
 * Send payment successful notification
 */
function notifyPaymentSuccessful($userId, $paymentDetails) {
    $variables = [
        'amount' => formatCurrency($paymentDetails['amount']),
        'payment_method' => $paymentDetails['payment_method'] ?? 'Card',
        'transaction_id' => $paymentDetails['transaction_id'],
        'payment_date' => date('F j, Y g:i A'),
        'order_number' => $paymentDetails['order_number'],
        'invoice_url' => APP_URL . '/invoice.php?id=' . $paymentDetails['order_id'],
        'action_url' => APP_URL . '/account.php?section=orders&id=' . $paymentDetails['order_id']
    ];
    
    return sendNotification('payment_successful', $userId, $variables, ['force_email' => true]);
}

/**
 * Send payment failed notification
 */
function notifyPaymentFailed($userId, $paymentDetails, $reason = 'Payment declined') {
    $variables = [
        'order_number' => $paymentDetails['order_number'],
        'amount' => formatCurrency($paymentDetails['amount']),
        'failure_reason' => $reason,
        'payment_url' => APP_URL . '/checkout.php?order=' . $paymentDetails['order_id'],
        'action_url' => APP_URL . '/checkout.php?order=' . $paymentDetails['order_id']
    ];
    
    return sendNotification('payment_failed', $userId, $variables, ['force_email' => true, 'force_in_app' => true]);
}

/**
 * Send refund issued notification
 */
function notifyRefundIssued($userId, $refundDetails) {
    $variables = [
        'refund_amount' => formatCurrency($refundDetails['amount']),
        'order_number' => $refundDetails['order_number'],
        'refund_method' => $refundDetails['refund_method'] ?? 'Original payment method',
        'processing_time' => $refundDetails['processing_time'] ?? date('F j, Y'),
        'refund_days' => '5-10',
        'action_url' => APP_URL . '/account.php?section=orders&id=' . $refundDetails['order_id']
    ];
    
    return sendNotification('refund_issued', $userId, $variables);
}

// ============================================================================
// SELLER NOTIFICATIONS
// ============================================================================

/**
 * Send new order notification to seller
 */
function notifySellerNewOrder($sellerId, $orderDetails) {
    $variables = [
        'seller_name' => $orderDetails['seller_name'],
        'order_number' => $orderDetails['order_number'],
        'customer_name' => $orderDetails['customer_name'],
        'order_amount' => formatCurrency($orderDetails['total']),
        'item_count' => count($orderDetails['items']),
        'order_url' => APP_URL . '/seller/orders.php?id=' . $orderDetails['id'],
        'action_url' => APP_URL . '/seller/orders.php?id=' . $orderDetails['id']
    ];
    
    return sendNotification('seller_new_order', $sellerId, $variables, ['force_email' => true, 'force_in_app' => true]);
}

/**
 * Send low stock alert to seller
 */
function notifySellerLowStock($sellerId, $productDetails) {
    $variables = [
        'seller_name' => $productDetails['seller_name'],
        'product_name' => $productDetails['name'],
        'current_stock' => $productDetails['stock'],
        'threshold' => $productDetails['low_stock_threshold'] ?? 10,
        'inventory_url' => APP_URL . '/seller/products/inventory.php?id=' . $productDetails['id'],
        'action_url' => APP_URL . '/seller/products/inventory.php?id=' . $productDetails['id']
    ];
    
    return sendNotification('seller_low_stock', $sellerId, $variables);
}

/**
 * Send payout issued notification to seller
 */
function notifySellerPayoutIssued($sellerId, $payoutDetails) {
    $variables = [
        'seller_name' => $payoutDetails['seller_name'],
        'payout_amount' => formatCurrency($payoutDetails['amount']),
        'payout_period' => $payoutDetails['period'],
        'payment_method' => $payoutDetails['payment_method'] ?? 'Bank Transfer',
        'transfer_date' => date('F j, Y'),
        'payout_url' => APP_URL . '/seller/finance.php',
        'action_url' => APP_URL . '/seller/finance.php'
    ];
    
    return sendNotification('seller_payout_issued', $sellerId, $variables, ['force_email' => true]);
}

// ============================================================================
// MARKETING & ENGAGEMENT
// ============================================================================

/**
 * Send abandoned cart reminder
 */
function notifyAbandonedCart($userId, $cartDetails) {
    $itemsList = '';
    foreach ($cartDetails['items'] as $item) {
        $itemsList .= "- " . $item['name'] . " - " . formatCurrency($item['price']) . "\n";
    }
    
    $variables = [
        'item_count' => count($cartDetails['items']),
        'cart_items' => $itemsList,
        'cart_total' => formatCurrency($cartDetails['total']),
        'cart_url' => APP_URL . '/cart.php',
        'discount_code' => 'SAVE10',
        'discount_percent' => '10',
        'action_url' => APP_URL . '/cart.php'
    ];
    
    return sendNotification('abandoned_cart', $userId, $variables);
}

/**
 * Send price drop alert
 */
function notifyPriceDrop($userId, $productDetails) {
    $savings = $productDetails['old_price'] - $productDetails['new_price'];
    
    $variables = [
        'product_name' => $productDetails['name'],
        'old_price' => formatCurrency($productDetails['old_price']),
        'new_price' => formatCurrency($productDetails['new_price']),
        'savings' => formatCurrency($savings),
        'product_url' => APP_URL . '/product.php?id=' . $productDetails['id'],
        'action_url' => APP_URL . '/product.php?id=' . $productDetails['id']
    ];
    
    return sendNotification('price_drop', $userId, $variables);
}

/**
 * Send back in stock alert
 */
function notifyBackInStock($userId, $productDetails) {
    $variables = [
        'product_name' => $productDetails['name'],
        'price' => formatCurrency($productDetails['price']),
        'product_url' => APP_URL . '/product.php?id=' . $productDetails['id'],
        'action_url' => APP_URL . '/product.php?id=' . $productDetails['id']
    ];
    
    return sendNotification('back_in_stock', $userId, $variables);
}

// ============================================================================
// SECURITY ALERTS
// ============================================================================

/**
 * Send suspicious activity alert
 */
function notifySuspiciousActivity($userId, $activityDetails) {
    $variables = [
        'activity_type' => $activityDetails['type'],
        'detection_time' => date('F j, Y g:i A'),
        'location' => $activityDetails['location'] ?? 'Unknown',
        'ip_address' => $activityDetails['ip'] ?? $_SERVER['REMOTE_ADDR'],
        'verify_url' => APP_URL . '/account.php?action=verify_activity',
        'security_url' => APP_URL . '/account.php?tab=security',
        'action_url' => APP_URL . '/account.php?tab=security'
    ];
    
    return sendNotification('suspicious_activity', $userId, $variables, ['force_email' => true, 'force_in_app' => true]);
}

// ============================================================================
// SYSTEM NOTIFICATIONS
// ============================================================================

/**
 * Send maintenance notification to all users
 */
function notifyMaintenanceScheduled($maintenanceDetails) {
    $variables = [
        'maintenance_start' => date('F j, Y g:i A', strtotime($maintenanceDetails['start_time'])),
        'maintenance_end' => date('F j, Y g:i A', strtotime($maintenanceDetails['end_time'])),
        'duration' => $maintenanceDetails['duration'],
        'affected_services' => $maintenanceDetails['affected_services'],
        'action_url' => APP_URL . '/maintenance.php'
    ];
    
    return sendNotificationToAll('system_maintenance', $variables);
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Format currency for display
 */
function formatCurrency($amount, $currency = 'USD') {
    if (!is_numeric($amount)) {
        return $amount;
    }
    
    $symbols = [
        'USD' => '$',
        'EUR' => '€',
        'GBP' => '£',
        'RWF' => 'FRw'
    ];
    
    $symbol = $symbols[$currency] ?? '$';
    return $symbol . number_format($amount, 2);
}

/**
 * Check if login is from new device and send alert
 */
function checkAndSendLoginAlert($userId, $userData) {
    // Simple implementation - in production, you'd check against stored devices
    $currentDevice = $_SERVER['HTTP_USER_AGENT'] ?? '';
    $currentIP = $_SERVER['REMOTE_ADDR'] ?? '';
    
    // Check if this is a known device (you'd implement this based on your device tracking)
    $isNewDevice = true; // Placeholder - implement your logic
    
    if ($isNewDevice) {
        notifyNewDeviceLogin($userId, [
            'device' => $currentDevice,
            'location' => 'Unknown', // Integrate with GeoIP service
            'ip' => $currentIP
        ]);
    } else {
        notifyLoginSuccess($userId, [
            'device' => $currentDevice,
            'location' => 'Unknown'
        ]);
    }
}
