<?php
/**
 * Checkout Page - Complete E-Commerce Checkout Flow
 * 
 * Features:
 * 1. Cart & Order Summary (items preview, totals)
 * 2. Customer Information (auto-fill for logged-in, guest checkout)
 * 3. Shipping & Billing Address
 * 4. Shipping Method Selection
 * 5. Coupon/Promo Code Support
 * 6. Stripe Payment Integration (Stripe Elements)
 * 7. Review & Confirmation
 * 8. Security (CSRF, HTTPS, server-side validation)
 */

require_once __DIR__ . '/includes/init.php';
require_once __DIR__ . '/includes/stripe/init_stripe.php';

// Currency Detection and Initialization
try {
    $currency = Currency::getInstance();
    
    // Auto-detect and set currency on first visit
    if (!Session::get('currency_code')) {
        $currency->detectAndSetCurrency();
    }
} catch (Exception $e) {
    error_log("Currency initialization error on checkout: " . $e->getMessage());
}

// Require login for checkout
Session::requireLogin();

$userId = Session::getUserId();
$cart = new Cart();
$cartItems = $cart->getCartItems($userId);

// Redirect to cart if empty
if (empty($cartItems)) {
    redirect('/cart.php?error=empty_cart');
}

// Calculate cart totals
$subtotal = 0;
foreach ($cartItems as $item) {
    $subtotal += $item['price'] * $item['quantity'];
}

// Calculate tax and shipping (server-side)
$taxRate = 8.25; // 8.25% - could come from settings/geolocation
$taxAmount = $subtotal * ($taxRate / 100);
$shippingAmount = $subtotal >= 50 ? 0 : 5.99; // Free shipping over $50
$total = $subtotal + $taxAmount + $shippingAmount;

// Get user information for auto-fill
$user = new User();
$userData = $user->find($userId);

// Get saved addresses if available
$db = db();
$savedAddresses = [];
try {
    $stmt = $db->prepare("SELECT * FROM addresses WHERE user_id = ? ORDER BY is_default DESC, created_at DESC");
    $stmt->execute([$userId]);
    $savedAddresses = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Exception $e) {
    // Addresses table might not exist yet
}

// Get Stripe publishable key
$stripePublishableKey = getStripePublishableKey();

$page_title = 'Secure Checkout';
includeHeader($page_title);
?>

<style>
/* Checkout Page Styles */
.checkout-container {
    max-width: 1400px;
    margin: 2rem auto;
    padding: 0 1.5rem;
}

.checkout-grid {
    display: grid;
    grid-template-columns: 1fr 450px;
    gap: 2rem;
    margin-top: 2rem;
}

@media (max-width: 992px) {
    .checkout-grid {
        grid-template-columns: 1fr;
    }
    
    .order-summary-sidebar {
        order: -1;
    }
}

.checkout-section {
    background: white;
    border-radius: 12px;
    padding: 2rem;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    margin-bottom: 1.5rem;
}

.section-header {
    display: flex;
    align-items: center;
    margin-bottom: 1.5rem;
    padding-bottom: 1rem;
    border-bottom: 2px solid #f0f0f0;
}

.section-header h2 {
    margin: 0;
    font-size: 1.5rem;
    color: #333;
    display: flex;
    align-items: center;
    gap: 0.75rem;
}

.section-number {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    background: linear-gradient(135deg, #4285f4 0%, #1a73e8 100%);
    color: white;
    border-radius: 50%;
    font-weight: bold;
    font-size: 1.1rem;
}

.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
    margin-bottom: 1rem;
}

/* Mobile responsive adjustments for form rows */
@media (max-width: 768px) {
    .form-row {
        grid-template-columns: 1fr;
        gap: 0.75rem;
    }
    
    .checkout-container {
        padding: 0 1rem;
    }
    
    .checkout-section {
        padding: 1.25rem;
        margin-bottom: 1rem;
        border-radius: 8px;
    }
    
    .section-header h2 {
        font-size: 1.25rem;
    }
    
    .section-number {
        width: 32px;
        height: 32px;
        font-size: 1rem;
    }
}

@media (max-width: 480px) {
    .checkout-container {
        padding: 0 0.75rem;
        margin: 1rem auto;
    }
    
    .checkout-section {
        padding: 1rem;
        border-radius: 6px;
    }
    
    .section-header {
        margin-bottom: 1rem;
    }
    
    .section-header h2 {
        font-size: 1.1rem;
        gap: 0.5rem;
    }
}

@media (max-width: 375px) {
    .checkout-container {
        padding: 0 0.5rem;
    }
    
    .section-header h2 {
        font-size: 1rem;
    }
    
    .form-control {
        font-size: 0.9rem;
        padding: 0.625rem;
    }
}

@media (max-width: 320px) {
    .checkout-container {
        padding: 0 0.5rem;
    }
    
    .checkout-section {
        padding: 0.75rem;
    }
    
    .section-number {
        width: 28px;
        height: 28px;
        font-size: 0.9rem;
    }
}

.form-group {
    margin-bottom: 1rem;
}

.form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: #333;
}

.form-group label .required {
    color: #e53e3e;
    margin-left: 0.25rem;
}

.form-control {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 1rem;
    transition: border-color 0.2s;
}

.form-control:focus {
    outline: none;
    border-color: #4285f4;
    box-shadow: 0 0 0 3px rgba(66, 133, 244, 0.1);
}

.checkbox-group {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin: 1rem 0;
}

.checkbox-group input[type="checkbox"] {
    width: 18px;
    height: 18px;
    cursor: pointer;
}

.shipping-options {
    display: grid;
    gap: 1rem;
}

.shipping-option {
    border: 2px solid #ddd;
    border-radius: 8px;
    padding: 1.25rem;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    gap: 1rem;
}

.shipping-option:hover {
    border-color: #4285f4;
    background: #f8f9ff;
}

.shipping-option.selected {
    border-color: #4285f4;
    background: #f0f4ff;
    box-shadow: 0 2px 8px rgba(66, 133, 244, 0.2);
}

.shipping-option input[type="radio"] {
    width: 20px;
    height: 20px;
    cursor: pointer;
}

.shipping-info {
    flex: 1;
}

.shipping-name {
    font-weight: 600;
    font-size: 1.1rem;
    margin-bottom: 0.25rem;
}

.shipping-description {
    color: #666;
    font-size: 0.9rem;
    margin-bottom: 0.25rem;
}

.shipping-delivery {
    color: #4285f4;
    font-size: 0.9rem;
    font-weight: 500;
}

.shipping-price {
    font-weight: bold;
    font-size: 1.25rem;
    color: #333;
}

.shipping-price.free {
    color: #22c55e;
}

.coupon-section {
    background: #f8f9fa;
    border-radius: 8px;
    padding: 1.25rem;
    margin: 1rem 0;
}

.coupon-input-group {
    display: flex;
    gap: 0.75rem;
    margin-top: 0.75rem;
}

.coupon-input-group input {
    flex: 1;
}

.btn-apply {
    padding: 0.75rem 1.5rem;
    background: #4285f4;
    color: white;
    border: none;
    border-radius: 6px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
}

.btn-apply:hover {
    background: #1a73e8;
}

.applied-coupon {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    background: #dcfce7;
    border: 1px solid #22c55e;
    border-radius: 6px;
    color: #166534;
    font-weight: 500;
    margin-top: 0.75rem;
}

.applied-coupon button {
    background: none;
    border: none;
    color: #166534;
    cursor: pointer;
    font-size: 1.2rem;
    padding: 0;
    margin-left: 0.5rem;
}

/* Payment Section */
.stripe-element {
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 6px;
    background: white;
    transition: border-color 0.2s;
}

.stripe-element.StripeElement--focus {
    border-color: #4285f4;
    box-shadow: 0 0 0 3px rgba(66, 133, 244, 0.1);
}

.stripe-element.StripeElement--invalid {
    border-color: #e53e3e;
}

#stripe-card-errors {
    color: #e53e3e;
    font-size: 0.875rem;
    margin-top: 0.5rem;
    min-height: 1.25rem;
}

/* Order Summary Sidebar */
.order-summary-sidebar {
    position: sticky;
    top: 2rem;
    height: fit-content;
}

.order-summary {
    background: white;
    border-radius: 12px;
    padding: 2rem;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.order-summary h3 {
    font-size: 1.5rem;
    margin-bottom: 1.5rem;
    padding-bottom: 1rem;
    border-bottom: 2px solid #f0f0f0;
}

.cart-item-preview {
    display: flex;
    gap: 1rem;
    padding: 1rem 0;
    border-bottom: 1px solid #f0f0f0;
}

.item-image {
    width: 70px;
    height: 70px;
    border-radius: 8px;
    overflow: hidden;
    flex-shrink: 0;
}

.item-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.item-details {
    flex: 1;
    min-width: 0;
}

.item-name {
    font-weight: 500;
    margin-bottom: 0.25rem;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.item-quantity {
    color: #666;
    font-size: 0.875rem;
}

.item-price {
    font-weight: 600;
    text-align: right;
}

.summary-totals {
    margin-top: 1.5rem;
}

.summary-line {
    display: flex;
    justify-content: space-between;
    margin-bottom: 0.75rem;
    color: #666;
}

.summary-line.total {
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 2px solid #f0f0f0;
    font-size: 1.25rem;
    font-weight: bold;
    color: #333;
}

.summary-line.discount {
    color: #22c55e;
    font-weight: 500;
}

.checkout-button {
    width: 100%;
    padding: 1rem;
    background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 1.125rem;
    font-weight: 600;
    cursor: pointer;
    transition: transform 0.2s, box-shadow 0.2s;
    margin-top: 1.5rem;
}

.checkout-button:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(34, 197, 94, 0.3);
}

.checkout-button:disabled {
    background: #ccc;
    cursor: not-allowed;
}

/* Mobile responsive buttons and order summary */
@media (max-width: 768px) {
    .checkout-button {
        padding: 0.875rem;
        font-size: 1rem;
        margin-top: 1.25rem;
    }
    
    .order-summary-sidebar {
        position: static;
    }
    
    .order-summary {
        padding: 1.5rem;
    }
    
    .order-summary h3 {
        font-size: 1.25rem;
    }
    
    .cart-item-preview {
        padding: 0.75rem 0;
    }
    
    .item-image {
        width: 60px;
        height: 60px;
    }
}

@media (max-width: 480px) {
    .checkout-button {
        padding: 0.75rem;
        font-size: 0.95rem;
        margin-top: 1rem;
    }
    
    .order-summary {
        padding: 1.25rem;
        border-radius: 8px;
    }
    
    .order-summary h3 {
        font-size: 1.1rem;
        margin-bottom: 1rem;
    }
    
    .cart-item-preview {
        gap: 0.75rem;
    }
    
    .item-name {
        font-size: 0.9rem;
    }
}

@media (max-width: 375px) {
    .order-summary {
        padding: 1rem;
    }
    
    .item-image {
        width: 50px;
        height: 50px;
    }
}

@media (max-width: 320px) {
    .checkout-button {
        padding: 0.625rem;
        font-size: 0.9rem;
    }
    
    .order-summary {
        padding: 0.875rem;
    }
}

.security-badge {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    margin-top: 1rem;
    padding: 0.75rem;
    background: #f0f4ff;
    border-radius: 6px;
    font-size: 0.875rem;
    color: #4285f4;
}

.alert {
    padding: 1rem;
    border-radius: 6px;
    margin-bottom: 1rem;
}

.alert-info {
    background: #e0f2fe;
    border-left: 4px solid #0284c7;
    color: #075985;
}

.alert-success {
    background: #dcfce7;
    border-left: 4px solid #22c55e;
    color: #166534;
}

.alert-error {
    background: #fee2e2;
    border-left: 4px solid #ef4444;
    color: #991b1b;
}

#payment-message {
    margin-top: 1rem;
}

.spinner {
    display: inline-block;
    width: 20px;
    height: 20px;
    border: 3px solid rgba(255, 255, 255, 0.3);
    border-radius: 50%;
    border-top-color: white;
    animation: spin 0.8s linear infinite;
}

@keyframes spin {
    to { transform: rotate(360deg); }
}

.saved-address-select {
    margin-bottom: 1rem;
    padding: 1rem;
    background: #f8f9fa;
    border-radius: 8px;
}

.iti {
    width: 100%;
}
</style>

<div class="checkout-container">
    <h1>🔒 Secure Checkout</h1>
    <p class="text-muted">Complete your purchase securely with Stripe</p>

    <div class="checkout-grid">
        <!-- Main Checkout Form -->
        <div class="checkout-main">
            <form id="checkout-form">
                <!-- Section 1: Customer Information -->
                <div class="checkout-section">
                    <div class="section-header">
                        <h2>
                            <span class="section-number">1</span>
                            Contact Information
                        </h2>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="customer_email">Email Address <span class="required">*</span></label>
                            <input type="email" 
                                   id="customer_email" 
                                   name="customer_email" 
                                   class="form-control" 
                                   value="<?php echo htmlspecialchars($userData['email'] ?? ''); ?>" 
                                   required>
                        </div>
                        <div class="form-group">
                            <label for="customer_phone">Phone Number <span class="required">*</span></label>
                            <input type="tel" 
                                   id="customer_phone" 
                                   name="customer_phone" 
                                   class="form-control" 
                                   value="<?php echo htmlspecialchars($userData['phone'] ?? ''); ?>" 
                                   required>
                        </div>
                    </div>
                </div>

                <!-- Section 2: Shipping Address -->
                <div class="checkout-section">
                    <div class="section-header">
                        <h2>
                            <span class="section-number">2</span>
                            Shipping Address
                        </h2>
                    </div>

                    <?php if (!empty($savedAddresses)): ?>
                    <div class="saved-address-select">
                        <label for="saved_shipping_address">
                            <strong>Use a saved address:</strong>
                        </label>
                        <select id="saved_shipping_address" class="form-control" style="margin-top: 0.5rem;">
                            <option value="">Enter new address</option>
                            <?php foreach ($savedAddresses as $address): ?>
                                <?php if ($address['type'] === 'shipping' || $address['type'] === 'both'): ?>
                                    <option value="<?php echo $address['id']; ?>" 
                                            data-address='<?php echo htmlspecialchars(json_encode($address)); ?>'>
                                        <?php echo htmlspecialchars($address['first_name'] . ' ' . $address['last_name']); ?> - 
                                        <?php echo htmlspecialchars($address['address_line1'] . ', ' . $address['city']); ?>
                                        <?php echo $address['is_default'] ? '(Default)' : ''; ?>
                                    </option>
                                <?php endif; ?>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <?php endif; ?>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="shipping_first_name">First Name <span class="required">*</span></label>
                            <input type="text" 
                                   id="shipping_first_name" 
                                   name="shipping_first_name" 
                                   class="form-control" 
                                   value="<?php echo htmlspecialchars($userData['first_name'] ?? ''); ?>" 
                                   required>
                        </div>
                        <div class="form-group">
                            <label for="shipping_last_name">Last Name <span class="required">*</span></label>
                            <input type="text" 
                                   id="shipping_last_name" 
                                   name="shipping_last_name" 
                                   class="form-control" 
                                   value="<?php echo htmlspecialchars($userData['last_name'] ?? ''); ?>" 
                                   required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="shipping_address_line1">Street Address <span class="required">*</span></label>
                        <input type="text" 
                               id="shipping_address_line1" 
                               name="shipping_address_line1" 
                               class="form-control" 
                               placeholder="123 Main Street" 
                               required>
                    </div>

                    <div class="form-group">
                        <label for="shipping_address_line2">Apartment, Suite, etc. (Optional)</label>
                        <input type="text" 
                               id="shipping_address_line2" 
                               name="shipping_address_line2" 
                               class="form-control" 
                               placeholder="Apt 4B">
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="shipping_city">City <span class="required">*</span></label>
                            <input type="text" 
                                   id="shipping_city" 
                                   name="shipping_city" 
                                   class="form-control" 
                                   required>
                        </div>
                        <div class="form-group">
                            <label for="shipping_state">State/Province <span class="required">*</span></label>
                            <input type="text" 
                                   id="shipping_state" 
                                   name="shipping_state" 
                                   class="form-control" 
                                   required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="shipping_postal_code">Postal Code <span class="required">*</span></label>
                            <input type="text" 
                                   id="shipping_postal_code" 
                                   name="shipping_postal_code" 
                                   class="form-control" 
                                   required>
                        </div>
                        <div class="form-group">
                            <label for="shipping_country">Country <span class="required">*</span></label>
                            <select id="shipping_country" name="shipping_country" class="form-control" required>
                                <option value="">Select Country</option>
                                <option value="US" selected>United States</option>
                                <option value="RW">Rwanda</option>
                                <option value="CA">Canada</option>
                                <option value="GB">United Kingdom</option>
                                <option value="AU">Australia</option>
                                <option value="DE">Germany</option>
                                <option value="FR">France</option>
                                <!-- Add more countries as needed -->
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="shipping_phone">Shipping Phone <span class="required">*</span></label>
                        <input type="tel" 
                               id="shipping_phone" 
                               name="shipping_phone" 
                               class="form-control" 
                               value="<?php echo htmlspecialchars($userData['phone'] ?? ''); ?>" 
                               required>
                    </div>

                    <div class="checkbox-group">
                        <input type="checkbox" id="save_address" name="save_address" checked>
                        <label for="save_address">Save this address for future orders</label>
                    </div>
                </div>

                <!-- Section 3: Billing Address -->
                <div class="checkout-section">
                    <div class="section-header">
                        <h2>
                            <span class="section-number">3</span>
                            Billing Address
                        </h2>
                    </div>

                    <div class="checkbox-group">
                        <input type="checkbox" id="same_as_shipping" name="same_as_shipping" checked>
                        <label for="same_as_shipping">Same as shipping address</label>
                    </div>

                    <div id="billing-address-form" style="display: none;">
                        <?php if (!empty($savedAddresses)): ?>
                        <div class="saved-address-select">
                            <label for="saved_billing_address">
                                <strong>Use a saved address:</strong>
                            </label>
                            <select id="saved_billing_address" class="form-control" style="margin-top: 0.5rem;">
                                <option value="">Enter new address</option>
                                <?php foreach ($savedAddresses as $address): ?>
                                    <?php if ($address['type'] === 'billing' || $address['type'] === 'both'): ?>
                                        <option value="<?php echo $address['id']; ?>" 
                                                data-address='<?php echo htmlspecialchars(json_encode($address)); ?>'>
                                            <?php echo htmlspecialchars($address['first_name'] . ' ' . $address['last_name']); ?> - 
                                            <?php echo htmlspecialchars($address['address_line1'] . ', ' . $address['city']); ?>
                                            <?php echo $address['is_default'] ? '(Default)' : ''; ?>
                                        </option>
                                    <?php endif; ?>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <?php endif; ?>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="billing_first_name">First Name <span class="required">*</span></label>
                                <input type="text" id="billing_first_name" name="billing_first_name" class="form-control">
                            </div>
                            <div class="form-group">
                                <label for="billing_last_name">Last Name <span class="required">*</span></label>
                                <input type="text" id="billing_last_name" name="billing_last_name" class="form-control">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="billing_address_line1">Street Address <span class="required">*</span></label>
                            <input type="text" id="billing_address_line1" name="billing_address_line1" class="form-control" placeholder="123 Main Street">
                        </div>

                        <div class="form-group">
                            <label for="billing_address_line2">Apartment, Suite, etc. (Optional)</label>
                            <input type="text" id="billing_address_line2" name="billing_address_line2" class="form-control" placeholder="Apt 4B">
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="billing_city">City <span class="required">*</span></label>
                                <input type="text" id="billing_city" name="billing_city" class="form-control">
                            </div>
                            <div class="form-group">
                                <label for="billing_state">State/Province <span class="required">*</span></label>
                                <input type="text" id="billing_state" name="billing_state" class="form-control">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="billing_postal_code">Postal Code <span class="required">*</span></label>
                                <input type="text" id="billing_postal_code" name="billing_postal_code" class="form-control">
                            </div>
                            <div class="form-group">
                                <label for="billing_country">Country <span class="required">*</span></label>
                                <select id="billing_country" name="billing_country" class="form-control">
                                    <option value="">Select Country</option>
                                    <option value="US" selected>United States</option>
                                    <option value="RW">Rwanda</option>
                                    <option value="CA">Canada</option>
                                    <option value="GB">United Kingdom</option>
                                    <option value="AU">Australia</option>
                                    <option value="DE">Germany</option>
                                    <option value="FR">France</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="billing_phone">Billing Phone <span class="required">*</span></label>
                            <input type="tel" id="billing_phone" name="billing_phone" class="form-control">
                        </div>
                    </div>
                </div>

                <!-- Section 4: Shipping Method -->
                <div class="checkout-section">
                    <div class="section-header">
                        <h2>
                            <span class="section-number">4</span>
                            Shipping Method
                        </h2>
                    </div>

                    <div class="shipping-options">
                        <div class="shipping-option selected" data-method="standard" data-cost="<?php echo $subtotal >= 50 ? 0 : 5.99; ?>">
                            <input type="radio" name="shipping_method" value="standard" id="shipping_standard" checked>
                            <div class="shipping-info">
                                <div class="shipping-name">Standard Shipping</div>
                                <div class="shipping-description">Delivery in 5-7 business days</div>
                                <div class="shipping-delivery">📦 Estimated delivery: <?php echo date('M j', strtotime('+7 days')); ?></div>
                            </div>
                            <div class="shipping-price <?php echo $subtotal >= 50 ? 'free' : ''; ?>">
                                <?php echo $subtotal >= 50 ? 'FREE' : '$5.99'; ?>
                            </div>
                        </div>

                        <div class="shipping-option" data-method="express" data-cost="12.99">
                            <input type="radio" name="shipping_method" value="express" id="shipping_express">
                            <div class="shipping-info">
                                <div class="shipping-name">Express Shipping</div>
                                <div class="shipping-description">Faster delivery in 2-3 business days</div>
                                <div class="shipping-delivery">🚀 Estimated delivery: <?php echo date('M j', strtotime('+3 days')); ?></div>
                            </div>
                            <div class="shipping-price">$12.99</div>
                        </div>

                        <div class="shipping-option" data-method="overnight" data-cost="24.99">
                            <input type="radio" name="shipping_method" value="overnight" id="shipping_overnight">
                            <div class="shipping-info">
                                <div class="shipping-name">Overnight Shipping</div>
                                <div class="shipping-description">Next business day delivery</div>
                                <div class="shipping-delivery">⚡ Estimated delivery: <?php echo date('M j', strtotime('+1 day')); ?></div>
                            </div>
                            <div class="shipping-price">$24.99</div>
                        </div>
                    </div>
                </div>

                <!-- Section 5: Discount Codes -->
                <div class="checkout-section">
                    <div class="section-header">
                        <h2>
                            <span class="section-number">5</span>
                            Discount Codes
                        </h2>
                    </div>

                    <div class="coupon-section">
                        <label for="coupon_code"><strong>💰 Have a coupon or promo code?</strong></label>
                        <div class="coupon-input-group">
                            <input type="text" 
                                   id="coupon_code" 
                                   name="coupon_code" 
                                   class="form-control" 
                                   placeholder="Enter code here"
                                   style="text-transform: uppercase;">
                            <button type="button" id="apply-coupon-btn" class="btn-apply">Apply</button>
                        </div>
                        <div id="coupon-message"></div>
                    </div>

                    <div class="coupon-section">
                        <label for="gift_card_code"><strong>🎁 Have a gift card?</strong></label>
                        <div class="coupon-input-group">
                            <input type="text" 
                                   id="gift_card_code" 
                                   name="gift_card_code" 
                                   class="form-control" 
                                   placeholder="Enter gift card code"
                                   style="text-transform: uppercase;">
                            <button type="button" id="apply-giftcard-btn" class="btn-apply">Apply</button>
                        </div>
                        <div id="giftcard-message"></div>
                    </div>
                </div>

                <!-- Section 6: Payment Information -->
                <div class="checkout-section">
                    <div class="section-header">
                        <h2>
                            <span class="section-number">6</span>
                            Payment Information
                        </h2>
                    </div>

                    <div class="alert alert-info">
                        <strong>🔒 Secure Payment:</strong> Your payment information is encrypted and processed securely by Stripe. We never store your card details.
                    </div>

                    <div class="form-group">
                        <label for="stripe-card-number">Card Number <span class="required">*</span></label>
                        <div id="stripe-card-number" class="stripe-element"></div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="stripe-card-expiry">Expiration Date <span class="required">*</span></label>
                            <div id="stripe-card-expiry" class="stripe-element"></div>
                        </div>
                        <div class="form-group">
                            <label for="stripe-card-cvc">CVC <span class="required">*</span></label>
                            <div id="stripe-card-cvc" class="stripe-element"></div>
                        </div>
                    </div>

                    <div id="stripe-card-errors"></div>

                    <div class="checkbox-group">
                        <input type="checkbox" id="save_card" name="save_card">
                        <label for="save_card">💳 Save this card for future purchases</label>
                    </div>

                    <div id="payment-message"></div>
                </div>

                <!-- Hidden fields -->
                <input type="hidden" id="selected_shipping_method" name="selected_shipping_method" value="standard">
                <input type="hidden" id="selected_shipping_cost" name="selected_shipping_cost" value="<?php echo $subtotal >= 50 ? 0 : 5.99; ?>">
                <input type="hidden" id="applied_coupon_code" name="applied_coupon_code" value="">
                <input type="hidden" id="applied_gift_card_code" name="applied_gift_card_code" value="">
            </form>
        </div>

        <!-- Order Summary Sidebar -->
        <div class="order-summary-sidebar">
            <div class="order-summary">
                <h3>📋 Order Summary</h3>

                <div class="cart-items-preview">
                    <?php foreach ($cartItems as $item): ?>
                        <div class="cart-item-preview">
                            <div class="item-image">
                                <img src="<?php echo getSafeProductImageUrl($item); ?>" 
                                     alt="<?php echo htmlspecialchars($item['product_name'] ?? ''); ?>">
                            </div>
                            <div class="item-details">
                                <div class="item-name"><?php echo htmlspecialchars($item['product_name'] ?? ''); ?></div>
                                <div class="item-quantity">Qty: <?php echo $item['quantity']; ?></div>
                            </div>
                            <div class="item-price">
                                <?php echo formatPrice($item['price'] * $item['quantity']); ?>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>

                <div class="summary-totals">
                    <div class="summary-line">
                        <span>Subtotal:</span>
                        <span id="summary-subtotal"><?php echo formatPrice($subtotal); ?></span>
                    </div>
                    <div class="summary-line">
                        <span>Tax (<?php echo $taxRate; ?>%):</span>
                        <span id="summary-tax"><?php echo formatPrice($taxAmount); ?></span>
                    </div>
                    <div class="summary-line">
                        <span>Shipping:</span>
                        <span id="summary-shipping"><?php echo $shippingAmount > 0 ? formatPrice($shippingAmount) : '<span class="free">FREE</span>'; ?></span>
                    </div>
                    <div class="summary-line discount" id="discount-line" style="display: none;">
                        <span>Discount:</span>
                        <span id="summary-discount">-$0.00</span>
                    </div>
                    <div class="summary-line total">
                        <span>Total:</span>
                        <span id="summary-total"><?php echo formatPrice($total); ?></span>
                    </div>
                </div>

                <button type="button" id="submit-checkout" class="checkout-button">
                    <span id="button-text">Place Order</span>
                    <span id="button-spinner" style="display: none;" class="spinner"></span>
                </button>

                <div class="security-badge">
                    <span>🔒</span>
                    <span>Secured by Stripe SSL Encryption</span>
                </div>

                <div style="margin-top: 1rem; text-align: center; font-size: 0.875rem; color: #666;">
                    <p>By placing your order, you agree to our <a href="/user-agreement.php">Terms of Service</a> and <a href="/privacy.php">Privacy Policy</a>.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Load Stripe.js -->
<script src="https://js.stripe.com/v3/"></script>

<!-- Load intl-tel-input for phone formatting -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/intl-tel-input@18.2.1/build/css/intlTelInput.css">
<script src="https://cdn.jsdelivr.net/npm/intl-tel-input@18.2.1/build/js/intlTelInput.min.js"></script>

<script>
// Set Stripe publishable key for JavaScript
window.STRIPE_PUBLISHABLE_KEY = '<?php echo $stripePublishableKey; ?>';

// Cart totals for calculation
const cartTotals = {
    subtotal: <?php echo $subtotal; ?>,
    taxRate: <?php echo $taxRate; ?>,
    taxAmount: <?php echo $taxAmount; ?>,
    shippingAmount: <?php echo $shippingAmount; ?>,
    discountAmount: 0,
    giftCardAmount: 0,
    total: <?php echo $total; ?>
};

// CSRF token helper
function getCsrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
}
</script>

<script src="/js/checkout-payment.js"></script>

<script>
// Checkout Page Specific JavaScript
(function() {
    'use strict';

    // Handle same as shipping checkbox
    const sameAsShippingCheckbox = document.getElementById('same_as_shipping');
    const billingAddressForm = document.getElementById('billing-address-form');
    
    sameAsShippingCheckbox?.addEventListener('change', function() {
        if (this.checked) {
            billingAddressForm.style.display = 'none';
            // Clear billing required fields
            const billingInputs = billingAddressForm.querySelectorAll('input[required], select[required]');
            billingInputs.forEach(input => input.removeAttribute('required'));
        } else {
            billingAddressForm.style.display = 'block';
            // Restore billing required fields
            const billingInputs = billingAddressForm.querySelectorAll('input[name^="billing_"], select[name^="billing_"]');
            billingInputs.forEach(input => {
                if (!input.name.includes('line2')) {
                    input.setAttribute('required', 'required');
                }
            });
        }
    });

    // Handle shipping method selection
    const shippingOptions = document.querySelectorAll('.shipping-option');
    shippingOptions.forEach(option => {
        option.addEventListener('click', function() {
            // Remove selected class from all
            shippingOptions.forEach(opt => opt.classList.remove('selected'));
            
            // Add selected class to clicked
            this.classList.add('selected');
            
            // Check the radio button
            const radio = this.querySelector('input[type="radio"]');
            radio.checked = true;
            
            // Update hidden fields
            const method = this.dataset.method;
            const cost = parseFloat(this.dataset.cost);
            document.getElementById('selected_shipping_method').value = method;
            document.getElementById('selected_shipping_cost').value = cost;
            
            // Update totals
            updateOrderSummary();
        });
    });

    // Handle saved address selection for shipping
    const savedShippingSelect = document.getElementById('saved_shipping_address');
    savedShippingSelect?.addEventListener('change', function() {
        if (this.value) {
            const addressData = JSON.parse(this.options[this.selectedIndex].dataset.address);
            document.getElementById('shipping_first_name').value = addressData.first_name || '';
            document.getElementById('shipping_last_name').value = addressData.last_name || '';
            document.getElementById('shipping_address_line1').value = addressData.address_line1 || '';
            document.getElementById('shipping_address_line2').value = addressData.address_line2 || '';
            document.getElementById('shipping_city').value = addressData.city || '';
            document.getElementById('shipping_state').value = addressData.state || '';
            document.getElementById('shipping_postal_code').value = addressData.postal_code || '';
            document.getElementById('shipping_country').value = addressData.country || '';
            document.getElementById('shipping_phone').value = addressData.phone || '';
        }
    });

    // Handle saved address selection for billing
    const savedBillingSelect = document.getElementById('saved_billing_address');
    savedBillingSelect?.addEventListener('change', function() {
        if (this.value) {
            const addressData = JSON.parse(this.options[this.selectedIndex].dataset.address);
            document.getElementById('billing_first_name').value = addressData.first_name || '';
            document.getElementById('billing_last_name').value = addressData.last_name || '';
            document.getElementById('billing_address_line1').value = addressData.address_line1 || '';
            document.getElementById('billing_address_line2').value = addressData.address_line2 || '';
            document.getElementById('billing_city').value = addressData.city || '';
            document.getElementById('billing_state').value = addressData.state || '';
            document.getElementById('billing_postal_code').value = addressData.postal_code || '';
            document.getElementById('billing_country').value = addressData.country || '';
            document.getElementById('billing_phone').value = addressData.phone || '';
        }
    });

    // Update order summary totals
    function updateOrderSummary() {
        const shippingCost = parseFloat(document.getElementById('selected_shipping_cost').value) || 0;
        const newTotal = cartTotals.subtotal + cartTotals.taxAmount + shippingCost - cartTotals.discountAmount - cartTotals.giftCardAmount;
        
        // Update shipping display
        const shippingDisplay = shippingCost > 0 ? '$' + shippingCost.toFixed(2) : '<span class="free">FREE</span>';
        document.getElementById('summary-shipping').innerHTML = shippingDisplay;
        
        // Update total
        document.getElementById('summary-total').textContent = '$' + newTotal.toFixed(2);
        cartTotals.total = newTotal;
    }

    // Coupon application
    const applyCouponBtn = document.getElementById('apply-coupon-btn');
    applyCouponBtn?.addEventListener('click', async function() {
        const couponCode = document.getElementById('coupon_code').value.trim().toUpperCase();
        const messageDiv = document.getElementById('coupon-message');
        
        if (!couponCode) {
            messageDiv.innerHTML = '<p class="alert alert-error" style="margin-top: 0.75rem;">Please enter a coupon code</p>';
            return;
        }
        
        this.disabled = true;
        this.textContent = 'Checking...';
        
        try {
            const response = await fetch('/api/validate-coupon.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': getCsrfToken()
                },
                body: JSON.stringify({ 
                    code: couponCode, 
                    subtotal: cartTotals.subtotal 
                })
            });
            
            const data = await response.json();
            
            if (data.success) {
                cartTotals.discountAmount = data.discount_amount;
                document.getElementById('applied_coupon_code').value = couponCode;
                document.getElementById('discount-line').style.display = 'flex';
                document.getElementById('summary-discount').textContent = '-$' + data.discount_amount.toFixed(2);
                
                messageDiv.innerHTML = `<div class="applied-coupon">
                    ✓ ${couponCode} applied (-$${data.discount_amount.toFixed(2)})
                    <button type="button" onclick="removeCoupon()">&times;</button>
                </div>`;
                
                document.getElementById('coupon_code').disabled = true;
                this.style.display = 'none';
                
                updateOrderSummary();
            } else {
                messageDiv.innerHTML = '<p class="alert alert-error" style="margin-top: 0.75rem;">' + (data.error || 'Invalid coupon code') + '</p>';
            }
        } catch (error) {
            messageDiv.innerHTML = '<p class="alert alert-error" style="margin-top: 0.75rem;">Failed to validate coupon. Please try again.</p>';
        } finally {
            this.disabled = false;
            this.textContent = 'Apply';
        }
    });

    // Gift card application
    const applyGiftCardBtn = document.getElementById('apply-giftcard-btn');
    applyGiftCardBtn?.addEventListener('click', async function() {
        const giftCardCode = document.getElementById('gift_card_code').value.trim().toUpperCase();
        const messageDiv = document.getElementById('giftcard-message');
        
        if (!giftCardCode) {
            messageDiv.innerHTML = '<p class="alert alert-error" style="margin-top: 0.75rem;">Please enter a gift card code</p>';
            return;
        }
        
        this.disabled = true;
        this.textContent = 'Checking...';
        
        try {
            const response = await fetch('/api/validate-giftcard.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': getCsrfToken()
                },
                body: JSON.stringify({ 
                    code: giftCardCode, 
                    total: cartTotals.total 
                })
            });
            
            const data = await response.json();
            
            if (data.success) {
                cartTotals.giftCardAmount = data.gift_card_amount;
                document.getElementById('applied_gift_card_code').value = giftCardCode;
                
                messageDiv.innerHTML = `<div class="applied-coupon">
                    ✓ Gift card applied (-$${data.gift_card_amount.toFixed(2)})
                    <button type="button" onclick="removeGiftCard()">&times;</button>
                </div>`;
                
                document.getElementById('gift_card_code').disabled = true;
                this.style.display = 'none';
                
                updateOrderSummary();
            } else {
                messageDiv.innerHTML = '<p class="alert alert-error" style="margin-top: 0.75rem;">' + (data.error || 'Invalid gift card code') + '</p>';
            }
        } catch (error) {
            messageDiv.innerHTML = '<p class="alert alert-error" style="margin-top: 0.75rem;">Failed to validate gift card. Please try again.</p>';
        } finally {
            this.disabled = false;
            this.textContent = 'Apply';
        }
    });

    // Remove coupon
    window.removeCoupon = function() {
        cartTotals.discountAmount = 0;
        document.getElementById('applied_coupon_code').value = '';
        document.getElementById('discount-line').style.display = 'none';
        document.getElementById('coupon-message').innerHTML = '';
        document.getElementById('coupon_code').disabled = false;
        document.getElementById('coupon_code').value = '';
        document.getElementById('apply-coupon-btn').style.display = 'inline-block';
        updateOrderSummary();
    };

    // Remove gift card
    window.removeGiftCard = function() {
        cartTotals.giftCardAmount = 0;
        document.getElementById('applied_gift_card_code').value = '';
        document.getElementById('giftcard-message').innerHTML = '';
        document.getElementById('gift_card_code').disabled = false;
        document.getElementById('gift_card_code').value = '';
        document.getElementById('apply-giftcard-btn').style.display = 'inline-block';
        updateOrderSummary();
    };

    // Initialize phone inputs
    if (window.intlTelInput) {
        const phoneFields = ['customer_phone', 'shipping_phone', 'billing_phone'];
        phoneFields.forEach(fieldId => {
            const field = document.getElementById(fieldId);
            if (field) {
                window.intlTelInput(field, {
                    initialCountry: 'us',
                    preferredCountries: ['us', 'rw', 'ca', 'gb', 'au'],
                    separateDialCode: true,
                    utilsScript: 'https://cdn.jsdelivr.net/npm/intl-tel-input@18.2.1/build/js/utils.js'
                });
            }
        });
    }
})();
</script>

<?php includeFooter(); ?>
