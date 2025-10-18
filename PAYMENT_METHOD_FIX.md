# Payment Method Fix - Summary

## Issues
Users were getting errors when trying to add payment methods in the Account section, even though Stripe API keys were properly configured in the `.env` file.

## Root Causes

### Issue 1: Webhook Secret Required (Fixed in Commit 5faf134)
The `create-setup-intent.php` API was calling `checkStripeConfiguration()` which required ALL Stripe configuration including webhook secret. However:
- **Webhook secrets are only needed for processing Stripe webhooks** (e.g., payment confirmations, subscription updates)
- **Setup intents do NOT require webhook secrets** - they only need API keys (publishable and secret)

This caused a false error: `"Webhook secret not configured for {mode} mode"` even when the user's API keys were correctly set.

### Issue 2: Publishable Key Meta Tag Missing (Fixed in Commit 8910031)
The `templates/header.php` file was missing the Stripe publishable key meta tag. The issue:
- The meta tag existed in `includes/header.php` but not in `templates/header.php`
- Account.php uses `templates/header.php` via the `includeHeader()` function
- JavaScript couldn't find the publishable key to initialize Stripe
- This caused the alert: `"Stripe payment processing is not configured on this site"`

## Solutions

### Fix 1: Remove Webhook Secret Check (Commit 5faf134)
Removed the `checkStripeConfiguration()` call from `create-setup-intent.php`. Now:
- The API only validates that API keys are configured (via `initStripe()`)
- `initStripe()` throws proper errors if secret or publishable keys are missing
- Webhook secret is no longer checked for payment method operations
- Webhook secret is still checked for webhook processing endpoints (where it's actually needed)

### Fix 2: Add Publishable Key to Header (Commit 8910031)
Added Stripe publishable key meta tag to `templates/header.php`:
- Loads Stripe configuration using `getStripePublishableKey()`
- Renders meta tag with publishable key
- Loads Stripe.js script when key is available
- Proper error logging if key retrieval fails
- JavaScript can now properly initialize Stripe on account pages

## What Changed

### Before (Broken)
```php
// create-setup-intent.php
// Check if Stripe is configured before proceeding
$stripeConfig = checkStripeConfiguration();
if (!$stripeConfig['configured']) {
    throw new Exception(
        'Stripe is not configured. Please configure the following: ' . 
        implode(', ', $stripeConfig['errors']) . 
        '. Contact administrator to set up Stripe in the .env file.'
    );
}

// Initialize Stripe
$stripe = initStripe();
```

```php
// templates/header.php
<!-- CSRF Token -->
<meta name="csrf-token" content="<?php echo csrfToken(); ?>">

<!-- CSS Files -->
<!-- Missing Stripe key meta tag! -->
```

### After (Fixed)
```php
// create-setup-intent.php
// Initialize Stripe (will throw exception if keys not configured)
$stripe = initStripe();
```

```php
// templates/header.php
<!-- CSRF Token -->
<meta name="csrf-token" content="<?php echo csrfToken(); ?>">

<!-- Stripe Publishable Key -->
<?php
$stripePublishableKey = '';
if (file_exists(BASE_PATH . '/includes/stripe/init_stripe.php')) {
    require_once BASE_PATH . '/includes/stripe/init_stripe.php';
    try {
        $stripePublishableKey = getStripePublishableKey() ?? '';
    } catch (Exception $e) {
        error_log("[STRIPE] Error getting publishable key in header: " . $e->getMessage());
        $stripePublishableKey = '';
    }
}
?>
<!-- Always render meta tag so JavaScript can detect if Stripe is configured -->
<meta name="stripe-publishable-key" content="<?php echo htmlspecialchars($stripePublishableKey); ?>">
<?php if (!empty($stripePublishableKey)): ?>
<script src="https://js.stripe.com/v3/"></script>
<?php endif; ?>

<!-- CSS Files -->
```

## Testing

### Steps to Test
1. Navigate to Account → Payment Methods tab
2. Click "Add Payment Method" button
3. ✅ No "Stripe payment processing is not configured" alert
4. ✅ Stripe form should load without errors
5. Enter card details and save
6. ✅ Payment method should be added successfully

### Expected Behavior
- **With API keys configured:** Payment method form loads and works
- **Without API keys configured:** Clear error message about missing API keys
- **No more webhook secret errors** for payment method operations
- **No more "not configured" alerts** when keys are properly set

## Files Modified
- `api/payment-methods/create-setup-intent.php` - Removed webhook secret check (Commit 5faf134)
- `templates/header.php` - Added Stripe publishable key meta tag (Commit 8910031)

## Commits
- **5faf134** - Fix payment method errors - remove webhook secret requirement for setup intents
- **8910031** - Fix Stripe publishable key not loading in account page header

## Configuration Required
Users only need these in `.env` for payment methods to work:
```env
# For live mode
STRIPE_MODE=live
STRIPE_LIVE_PUBLISHABLE_KEY=pk_live_xxxxx
STRIPE_LIVE_SECRET_KEY=sk_live_xxxxx

# OR for test mode
STRIPE_MODE=test
STRIPE_TEST_PUBLISHABLE_KEY=pk_test_xxxxx
STRIPE_TEST_SECRET_KEY=sk_test_xxxxx
```

Webhook secrets are optional and only needed for webhook endpoints:
```env
# Optional - only needed for webhooks
STRIPE_WEBHOOK_SECRET_LIVE=whsec_xxxxx
STRIPE_WEBHOOK_SECRET_TEST=whsec_xxxxx
```

## Error Messages

### Before Fixes
1. ❌ "Webhook secret not configured for {mode} mode"
2. ❌ "Stripe payment processing is not configured on this site"

### After Fixes
✅ Payment method form loads without errors when API keys are configured
✅ Only shows errors if API keys are actually missing
