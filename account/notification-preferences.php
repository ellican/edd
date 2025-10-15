<?php
/**
 * Notification Preferences Management
 * E-Commerce Platform
 */

require_once __DIR__ . '/../includes/init.php';
require_once __DIR__ . '/../includes/enhanced_notification_service.php';

// Require user login
Session::requireLogin();

$userId = Session::getUserId();
$notificationService = new EnhancedNotificationService();

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'update_preferences') {
    // Verify CSRF token if available
    if (function_exists('verifyCsrfToken')) {
        verifyCsrfToken();
    }
    
    $categories = ['authentication', 'order', 'payment', 'security', 'marketing', 'seller', 'system'];
    $success = true;
    
    foreach ($categories as $category) {
        $emailEnabled = isset($_POST["{$category}_email"]) ? 1 : 0;
        $inAppEnabled = isset($_POST["{$category}_in_app"]) ? 1 : 0;
        $smsEnabled = isset($_POST["{$category}_sms"]) ? 1 : 0;
        
        if (!$notificationService->updatePreferences($userId, $category, $emailEnabled, $inAppEnabled, $smsEnabled)) {
            $success = false;
        }
    }
    
    if ($success) {
        $successMessage = "Your notification preferences have been updated successfully.";
    } else {
        $errorMessage = "There was an error updating your preferences. Please try again.";
    }
}

// Get current preferences
$preferences = $notificationService->getAllPreferences($userId);
$preferencesByCategory = [];
foreach ($preferences as $pref) {
    $preferencesByCategory[$pref['category']] = $pref;
}

// Default preferences for categories not yet set
$defaultPreference = [
    'email_enabled' => 1,
    'in_app_enabled' => 1,
    'sms_enabled' => 0
];

$page_title = 'Notification Preferences';
includeHeader($page_title);
?>

<div class="container notification-preferences-page">
    <div class="page-header">
        <h1><i class="fas fa-bell"></i> Notification Preferences</h1>
        <p class="subtitle">Manage how you receive notifications from us</p>
    </div>

    <?php if (isset($successMessage)): ?>
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> <?php echo htmlspecialchars($successMessage); ?>
        </div>
    <?php endif; ?>

    <?php if (isset($errorMessage)): ?>
        <div class="alert alert-error">
            <i class="fas fa-exclamation-circle"></i> <?php echo htmlspecialchars($errorMessage); ?>
        </div>
    <?php endif; ?>

    <form method="POST" action="" class="preferences-form">
        <input type="hidden" name="action" value="update_preferences">
        <?php if (function_exists('generateCsrfToken')): ?>
            <input type="hidden" name="csrf_token" value="<?php echo generateCsrfToken(); ?>">
        <?php endif; ?>

        <!-- Authentication & Security -->
        <div class="preference-category">
            <div class="category-header">
                <div class="category-icon">🔐</div>
                <div class="category-info">
                    <h3>Authentication & Security</h3>
                    <p>Notifications about account login, password changes, and security alerts</p>
                </div>
            </div>
            <div class="category-channels">
                <?php 
                $pref = $preferencesByCategory['authentication'] ?? $defaultPreference;
                ?>
                <label class="channel-toggle">
                    <input type="checkbox" name="authentication_email" <?php echo $pref['email_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-envelope"></i> Email</span>
                </label>
                <label class="channel-toggle">
                    <input type="checkbox" name="authentication_in_app" <?php echo $pref['in_app_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-bell"></i> In-App</span>
                </label>
                <label class="channel-toggle disabled" title="SMS notifications coming soon">
                    <input type="checkbox" name="authentication_sms" <?php echo $pref['sms_enabled'] ? 'checked' : ''; ?> disabled>
                    <span class="toggle-label"><i class="fas fa-sms"></i> SMS (Coming Soon)</span>
                </label>
            </div>
        </div>

        <!-- Orders & Shopping -->
        <div class="preference-category">
            <div class="category-header">
                <div class="category-icon">📦</div>
                <div class="category-info">
                    <h3>Orders & Shopping</h3>
                    <p>Order confirmations, shipping updates, and delivery notifications</p>
                </div>
            </div>
            <div class="category-channels">
                <?php 
                $pref = $preferencesByCategory['order'] ?? $defaultPreference;
                ?>
                <label class="channel-toggle">
                    <input type="checkbox" name="order_email" <?php echo $pref['email_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-envelope"></i> Email</span>
                </label>
                <label class="channel-toggle">
                    <input type="checkbox" name="order_in_app" <?php echo $pref['in_app_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-bell"></i> In-App</span>
                </label>
                <label class="channel-toggle disabled" title="SMS notifications coming soon">
                    <input type="checkbox" name="order_sms" <?php echo $pref['sms_enabled'] ? 'checked' : ''; ?> disabled>
                    <span class="toggle-label"><i class="fas fa-sms"></i> SMS (Coming Soon)</span>
                </label>
            </div>
        </div>

        <!-- Payment & Billing -->
        <div class="preference-category">
            <div class="category-header">
                <div class="category-icon">💳</div>
                <div class="category-info">
                    <h3>Payment & Billing</h3>
                    <p>Payment confirmations, refunds, and billing notifications</p>
                </div>
            </div>
            <div class="category-channels">
                <?php 
                $pref = $preferencesByCategory['payment'] ?? $defaultPreference;
                ?>
                <label class="channel-toggle">
                    <input type="checkbox" name="payment_email" <?php echo $pref['email_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-envelope"></i> Email</span>
                </label>
                <label class="channel-toggle">
                    <input type="checkbox" name="payment_in_app" <?php echo $pref['in_app_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-bell"></i> In-App</span>
                </label>
                <label class="channel-toggle disabled" title="SMS notifications coming soon">
                    <input type="checkbox" name="payment_sms" <?php echo $pref['sms_enabled'] ? 'checked' : ''; ?> disabled>
                    <span class="toggle-label"><i class="fas fa-sms"></i> SMS (Coming Soon)</span>
                </label>
            </div>
        </div>

        <!-- Security Alerts -->
        <div class="preference-category">
            <div class="category-header">
                <div class="category-icon">🛡️</div>
                <div class="category-info">
                    <h3>Security Alerts</h3>
                    <p>Important security alerts and compliance notifications</p>
                </div>
            </div>
            <div class="category-channels">
                <?php 
                $pref = $preferencesByCategory['security'] ?? $defaultPreference;
                ?>
                <label class="channel-toggle">
                    <input type="checkbox" name="security_email" <?php echo $pref['email_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-envelope"></i> Email</span>
                </label>
                <label class="channel-toggle">
                    <input type="checkbox" name="security_in_app" <?php echo $pref['in_app_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-bell"></i> In-App</span>
                </label>
                <label class="channel-toggle disabled" title="SMS notifications coming soon">
                    <input type="checkbox" name="security_sms" <?php echo $pref['sms_enabled'] ? 'checked' : ''; ?> disabled>
                    <span class="toggle-label"><i class="fas fa-sms"></i> SMS (Coming Soon)</span>
                </label>
            </div>
        </div>

        <!-- Marketing & Promotions -->
        <div class="preference-category">
            <div class="category-header">
                <div class="category-icon">🎁</div>
                <div class="category-info">
                    <h3>Marketing & Promotions</h3>
                    <p>Newsletters, special offers, discounts, and promotional content</p>
                </div>
            </div>
            <div class="category-channels">
                <?php 
                $pref = $preferencesByCategory['marketing'] ?? $defaultPreference;
                ?>
                <label class="channel-toggle">
                    <input type="checkbox" name="marketing_email" <?php echo $pref['email_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-envelope"></i> Email</span>
                </label>
                <label class="channel-toggle">
                    <input type="checkbox" name="marketing_in_app" <?php echo $pref['in_app_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-bell"></i> In-App</span>
                </label>
                <label class="channel-toggle disabled" title="SMS notifications coming soon">
                    <input type="checkbox" name="marketing_sms" <?php echo $pref['sms_enabled'] ? 'checked' : ''; ?> disabled>
                    <span class="toggle-label"><i class="fas fa-sms"></i> SMS (Coming Soon)</span>
                </label>
            </div>
        </div>

        <?php
        // Show seller notifications only if user is a seller
        $user = Session::getUser();
        if ($user && ($user['role'] === 'seller' || $user['role'] === 'admin')):
        ?>
        <!-- Seller Notifications -->
        <div class="preference-category">
            <div class="category-header">
                <div class="category-icon">🏪</div>
                <div class="category-info">
                    <h3>Seller Notifications</h3>
                    <p>New orders, inventory alerts, payouts, and seller-related updates</p>
                </div>
            </div>
            <div class="category-channels">
                <?php 
                $pref = $preferencesByCategory['seller'] ?? $defaultPreference;
                ?>
                <label class="channel-toggle">
                    <input type="checkbox" name="seller_email" <?php echo $pref['email_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-envelope"></i> Email</span>
                </label>
                <label class="channel-toggle">
                    <input type="checkbox" name="seller_in_app" <?php echo $pref['in_app_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-bell"></i> In-App</span>
                </label>
                <label class="channel-toggle disabled" title="SMS notifications coming soon">
                    <input type="checkbox" name="seller_sms" <?php echo $pref['sms_enabled'] ? 'checked' : ''; ?> disabled>
                    <span class="toggle-label"><i class="fas fa-sms"></i> SMS (Coming Soon)</span>
                </label>
            </div>
        </div>
        <?php endif; ?>

        <!-- System Notifications -->
        <div class="preference-category">
            <div class="category-header">
                <div class="category-icon">⚙️</div>
                <div class="category-info">
                    <h3>System Notifications</h3>
                    <p>Platform updates, maintenance alerts, and feature announcements</p>
                </div>
            </div>
            <div class="category-channels">
                <?php 
                $pref = $preferencesByCategory['system'] ?? $defaultPreference;
                ?>
                <label class="channel-toggle">
                    <input type="checkbox" name="system_email" <?php echo $pref['email_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-envelope"></i> Email</span>
                </label>
                <label class="channel-toggle">
                    <input type="checkbox" name="system_in_app" <?php echo $pref['in_app_enabled'] ? 'checked' : ''; ?>>
                    <span class="toggle-label"><i class="fas fa-bell"></i> In-App</span>
                </label>
                <label class="channel-toggle disabled" title="SMS notifications coming soon">
                    <input type="checkbox" name="system_sms" <?php echo $pref['sms_enabled'] ? 'checked' : ''; ?> disabled>
                    <span class="toggle-label"><i class="fas fa-sms"></i> SMS (Coming Soon)</span>
                </label>
            </div>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">
                <i class="fas fa-save"></i> Save Preferences
            </button>
            <a href="/account.php" class="btn btn-secondary">
                <i class="fas fa-times"></i> Cancel
            </a>
        </div>
    </form>

    <div class="info-box">
        <h3><i class="fas fa-info-circle"></i> About Notifications</h3>
        <ul>
            <li><strong>Email:</strong> Notifications sent to your registered email address</li>
            <li><strong>In-App:</strong> Notifications displayed in your account dashboard</li>
            <li><strong>SMS:</strong> Text messages sent to your mobile phone (coming soon)</li>
        </ul>
        <p class="note">
            <i class="fas fa-exclamation-triangle"></i> 
            <strong>Important:</strong> Some security-critical notifications cannot be disabled to protect your account.
        </p>
    </div>
</div>

<style>
.notification-preferences-page {
    max-width: 900px;
    margin: 40px auto;
    padding: 0 20px;
}

.page-header {
    text-align: center;
    margin-bottom: 40px;
}

.page-header h1 {
    font-size: 32px;
    color: #1f2937;
    margin-bottom: 10px;
}

.page-header .subtitle {
    color: #6b7280;
    font-size: 16px;
}

.alert {
    padding: 15px 20px;
    border-radius: 8px;
    margin-bottom: 30px;
    display: flex;
    align-items: center;
    gap: 10px;
}

.alert-success {
    background: #d1fae5;
    color: #065f46;
    border: 1px solid #34d399;
}

.alert-error {
    background: #fee2e2;
    color: #991b1b;
    border: 1px solid #f87171;
}

.preferences-form {
    background: #fff;
    border-radius: 12px;
    padding: 0;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.preference-category {
    border-bottom: 1px solid #e5e7eb;
    padding: 30px;
}

.preference-category:last-of-type {
    border-bottom: none;
}

.category-header {
    display: flex;
    align-items: center;
    gap: 20px;
    margin-bottom: 20px;
}

.category-icon {
    font-size: 36px;
    width: 60px;
    height: 60px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #f3f4f6;
    border-radius: 12px;
    flex-shrink: 0;
}

.category-info h3 {
    font-size: 20px;
    color: #1f2937;
    margin: 0 0 5px 0;
}

.category-info p {
    color: #6b7280;
    font-size: 14px;
    margin: 0;
}

.category-channels {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
}

.channel-toggle {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 12px 20px;
    background: #f9fafb;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
    min-width: 150px;
}

.channel-toggle:hover:not(.disabled) {
    background: #eff6ff;
    border-color: #3b82f6;
}

.channel-toggle.disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

.channel-toggle input[type="checkbox"] {
    width: 20px;
    height: 20px;
    cursor: pointer;
}

.channel-toggle input[type="checkbox"]:disabled {
    cursor: not-allowed;
}

.toggle-label {
    font-size: 15px;
    color: #374151;
    display: flex;
    align-items: center;
    gap: 8px;
}

.toggle-label i {
    color: #6b7280;
}

.channel-toggle input[type="checkbox"]:checked + .toggle-label {
    color: #1f2937;
    font-weight: 600;
}

.channel-toggle input[type="checkbox"]:checked + .toggle-label i {
    color: #3b82f6;
}

.form-actions {
    padding: 30px;
    background: #f9fafb;
    border-top: 1px solid #e5e7eb;
    display: flex;
    gap: 15px;
    justify-content: center;
}

.btn {
    padding: 12px 30px;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    border: none;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    transition: all 0.3s ease;
    text-decoration: none;
}

.btn-primary {
    background: #3b82f6;
    color: white;
}

.btn-primary:hover {
    background: #2563eb;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
}

.btn-secondary {
    background: #6b7280;
    color: white;
}

.btn-secondary:hover {
    background: #4b5563;
}

.info-box {
    margin-top: 30px;
    padding: 25px;
    background: #fffbeb;
    border: 1px solid #fcd34d;
    border-radius: 12px;
}

.info-box h3 {
    font-size: 18px;
    color: #92400e;
    margin: 0 0 15px 0;
    display: flex;
    align-items: center;
    gap: 10px;
}

.info-box ul {
    margin: 0 0 15px 0;
    padding-left: 20px;
}

.info-box li {
    color: #78350f;
    margin-bottom: 8px;
}

.info-box .note {
    color: #92400e;
    font-size: 14px;
    margin: 0;
    padding: 12px;
    background: #fef3c7;
    border-radius: 6px;
    display: flex;
    align-items: flex-start;
    gap: 10px;
}

@media (max-width: 768px) {
    .notification-preferences-page {
        padding: 0 15px;
    }
    
    .page-header h1 {
        font-size: 24px;
    }
    
    .preference-category {
        padding: 20px;
    }
    
    .category-header {
        flex-direction: column;
        align-items: flex-start;
        text-align: left;
    }
    
    .category-channels {
        flex-direction: column;
    }
    
    .channel-toggle {
        width: 100%;
    }
    
    .form-actions {
        flex-direction: column;
    }
    
    .btn {
        width: 100%;
        justify-content: center;
    }
}
</style>

<?php includeFooter(); ?>
