# Stripe Payment Methods Configuration Fix

## Issue Summary

Users were receiving an error "Stripe is not configured. Please contact support." when attempting to add payment methods in the account section (https://fezamarket.com/account.php#payment-methods).

## Root Cause

The issue occurred when Stripe API keys were not properly configured in the environment variables. The system had the following problems:

1. **Missing Meta Tag**: When `getStripePublishableKey()` returned `null` or empty string, the `stripe-publishable-key` meta tag was not rendered at all in the HTML header.
2. **Poor Error Detection**: The JavaScript in `account.php` checked for the existence of the meta tag, but didn't provide clear guidance on what was missing.
3. **No Backend Validation**: The API endpoint didn't validate Stripe configuration before attempting to create setup intents.

## Solution Implemented

### 1. Header.php - Always Render Meta Tag

**File**: `/includes/header.php`

**Changes**:
- Always render the `stripe-publishable-key` meta tag, even if empty
- Added try-catch error handling around `getStripePublishableKey()`
- Only load Stripe.js library if publishable key is configured
- This allows JavaScript to detect if Stripe is configured vs. not present

**Before**:
```php
<?php
if (file_exists(__DIR__ . '/stripe/init_stripe.php')) {
    require_once __DIR__ . '/stripe/init_stripe.php';
    $stripePublishableKey = getStripePublishableKey();
    if ($stripePublishableKey): ?>
<meta name="stripe-publishable-key" content="<?php echo htmlspecialchars($stripePublishableKey); ?>">
<script src="https://js.stripe.com/v3/"></script>
    <?php endif;
}
?>
```

**After**:
```php
<?php
$stripePublishableKey = '';
if (file_exists(__DIR__ . '/stripe/init_stripe.php')) {
    require_once __DIR__ . '/stripe/init_stripe.php';
    try {
        $stripePublishableKey = getStripePublishableKey() ?? '';
    } catch (Exception $e) {
        error_log("[STRIPE] Error getting publishable key: " . $e->getMessage());
        $stripePublishableKey = '';
    }
}
?>
<!-- Always render meta tag so JavaScript can detect if Stripe is configured -->
<meta name="stripe-publishable-key" content="<?php echo htmlspecialchars($stripePublishableKey); ?>">
<?php if (!empty($stripePublishableKey)): ?>
<script src="https://js.stripe.com/v3/"></script>
<?php endif; ?>
```

### 2. Account.php - Improved Error Message

**File**: `/account.php`

**Changes**:
- Added check for empty/blank publishable key (not just missing meta tag)
- Provided detailed, actionable error message explaining what the administrator needs to configure
- Listed specific environment variables that need to be set

**Before**:
```javascript
const stripeKey = document.querySelector('meta[name="stripe-publishable-key"]')?.content;
if (!stripeKey) {
    alert('Stripe is not configured. Please contact support.');
    return;
}
```

**After**:
```javascript
const stripeKey = document.querySelector('meta[name="stripe-publishable-key"]')?.content;
if (!stripeKey || stripeKey.trim() === '') {
    alert('Stripe payment processing is not configured on this site.\n\nTo enable payment methods, the site administrator needs to:\n1. Add Stripe API keys to the .env file\n2. Set STRIPE_LIVE_PUBLISHABLE_KEY (for live mode) or STRIPE_TEST_PUBLISHABLE_KEY (for test mode)\n3. Set STRIPE_MODE=live (or test)\n\nPlease contact support for assistance.');
    return;
}
```

### 3. Create Setup Intent API - Configuration Validation

**File**: `/api/payment-methods/create-setup-intent.php`

**Changes**:
- Added Stripe configuration check before attempting to initialize Stripe
- Provides specific error messages listing what's missing
- Uses the existing `checkStripeConfiguration()` function from `init_stripe.php`

**Added Code**:
```php
// Check if Stripe is configured before proceeding
$stripeConfig = checkStripeConfiguration();
if (!$stripeConfig['configured']) {
    throw new Exception(
        'Stripe is not configured. Please configure the following: ' . 
        implode(', ', $stripeConfig['errors']) . 
        '. Contact administrator to set up Stripe in the .env file.'
    );
}
```

## Required Stripe Configuration

To enable payment methods, the following environment variables must be set in the `.env` file:

### For Live Mode (Production):
```env
STRIPE_MODE=live
STRIPE_LIVE_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxxxx
STRIPE_LIVE_SECRET_KEY=sk_live_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET_LIVE=whsec_xxxxxxxxxxxxx
```

### For Test Mode (Development):
```env
STRIPE_MODE=test
STRIPE_TEST_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx
STRIPE_TEST_SECRET_KEY=sk_test_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET_TEST=whsec_xxxxxxxxxxxxx
```

## How to Get Stripe API Keys

1. **Sign up/Login to Stripe**: https://dashboard.stripe.com/register
2. **Navigate to Developers → API Keys**: https://dashboard.stripe.com/apikeys
3. **For Test Keys**: Click on "Test mode" toggle and copy the keys
4. **For Live Keys**: Click on "Live mode" toggle and copy the keys
5. **For Webhook Secrets**: Go to Developers → Webhooks → Add endpoint
   - Endpoint URL: `https://yourdomain.com/api/stripe-webhook.php`
   - Select events to listen to (or select "Select all events")
   - Copy the webhook signing secret

## Testing the Fix

### 1. Test with Stripe Configured
1. Set proper Stripe keys in `.env` file
2. Navigate to https://fezamarket.com/account.php#payment-methods
3. Click "Add Payment Method"
4. Verify modal opens with Stripe card form
5. Test adding a payment method

### 2. Test without Stripe Configured
1. Remove or comment out Stripe keys in `.env`
2. Navigate to https://fezamarket.com/account.php#payment-methods
3. Click "Add Payment Method"
4. Verify improved error message appears:
   ```
   Stripe payment processing is not configured on this site.
   
   To enable payment methods, the site administrator needs to:
   1. Add Stripe API keys to the .env file
   2. Set STRIPE_LIVE_PUBLISHABLE_KEY (for live mode) or STRIPE_TEST_PUBLISHABLE_KEY (for test mode)
   3. Set STRIPE_MODE=live (or test)
   
   Please contact support for assistance.
   ```

### 3. Test API Endpoint
```bash
# Without Stripe configured, should return detailed error
curl -X POST https://fezamarket.com/api/payment-methods/create-setup-intent.php \
  -H "Content-Type: application/json" \
  -H "Cookie: your_session_cookie" \
  -d '{"csrf_token": "your_token"}'

# Expected response:
{
  "error": "Stripe is not configured. Please configure the following: Secret key not configured for live mode, Publishable key not configured for live mode, Webhook secret not configured for live mode. Contact administrator to set up Stripe in the .env file."
}
```

## Benefits of This Fix

1. **Better User Experience**: 
   - Clear, actionable error messages instead of generic "contact support"
   - Users know exactly what needs to be configured
   - System doesn't fail silently

2. **Easier Debugging**:
   - Meta tag always present makes it easy to inspect configuration
   - Error messages list specific missing components
   - Error logs capture configuration issues

3. **Safer Deployment**:
   - Try-catch prevents fatal errors from breaking the site
   - Configuration validation before processing payments
   - Graceful degradation when Stripe is not configured

4. **Administrator-Friendly**:
   - Error messages guide administrators to the exact fix needed
   - Clear documentation on required environment variables
   - Links to Stripe dashboard for getting keys

## Backward Compatibility

This fix is fully backward compatible:
- Sites with Stripe properly configured continue working as before
- Sites without Stripe now show helpful error messages instead of breaking
- No database changes required
- No changes to Stripe integration logic

## Error Logging

The system now logs Stripe configuration errors:
- `[STRIPE] Error getting publishable key: ...` - When key retrieval fails
- Error logs help administrators diagnose configuration issues
- Logs don't expose sensitive key values

## Related Files

**Modified**:
- `/includes/header.php` - Meta tag rendering and error handling
- `/account.php` - Improved error message in JavaScript
- `/api/payment-methods/create-setup-intent.php` - Configuration validation

**Unchanged but Related**:
- `/includes/stripe/init_stripe.php` - Contains `checkStripeConfiguration()` function
- `/config/stripe.php` - Documentation file
- `.env.example` - Template for Stripe configuration

## Deployment Checklist

- [x] Update header.php with meta tag fix
- [x] Update account.php with better error message
- [x] Update create-setup-intent.php with configuration check
- [x] Test PHP syntax validation (all files pass)
- [ ] Deploy to staging environment
- [ ] Test with Stripe configured
- [ ] Test without Stripe configured
- [ ] Verify error messages are helpful
- [ ] Deploy to production
- [ ] Configure Stripe keys in production .env
- [ ] Test payment method addition

## Support Documentation

For administrators setting up Stripe:

1. **Get Stripe Account**: https://stripe.com/
2. **Get API Keys**: https://dashboard.stripe.com/apikeys
3. **Set Environment Variables**: Add to `/path/to/.env` file
4. **Restart Application**: Reload environment variables
5. **Test Configuration**: Try adding a payment method

For users encountering errors:
- If you see "Stripe is not configured", contact your site administrator
- Provide the full error message to support
- Site administrator needs to configure Stripe API keys

## Security Notes

- Publishable keys are safe to expose in HTML (they're meant to be public)
- Secret keys are never exposed to the frontend
- Meta tag rendering doesn't leak sensitive information
- Error messages guide to fix without exposing actual key values

## Version History

**Version**: 1.0  
**Date**: 2025-10-18  
**Status**: ✅ Ready for Deployment
