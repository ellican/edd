#!/bin/bash
# Checkout Implementation Verification Script
# Verifies that all checkout components are properly installed

echo "=== Checkout Implementation Verification ==="
echo ""

PASSED=0
FAILED=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function check_file_exists() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 MISSING"
        ((FAILED++))
        return 1
    fi
}

function check_file_contains() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $3"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $3 MISSING"
        ((FAILED++))
        return 1
    fi
}

function check_php_syntax() {
    if php -l "$1" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $1 PHP syntax valid"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 PHP syntax ERROR"
        ((FAILED++))
        return 1
    fi
}

echo "1. Checking Core Files"
echo "---------------------"
check_file_exists "checkout.php"
check_file_exists "js/checkout-payment.js"
check_file_exists "api/validate-coupon.php"
check_file_exists "api/validate-giftcard.php"
check_file_exists "migrations/20251012_checkout_support.sql"
check_file_exists "CHECKOUT_IMPLEMENTATION_GUIDE.md"
echo ""

echo "2. Checking PHP Syntax"
echo "---------------------"
check_php_syntax "checkout.php"
check_php_syntax "api/validate-coupon.php"
check_php_syntax "api/validate-giftcard.php"
echo ""

echo "3. Checking Checkout Features"
echo "----------------------------"
check_file_contains "checkout.php" "Cart & Order Summary" "Cart & Order Summary section"
check_file_contains "checkout.php" "Customer Information" "Customer Information section"
check_file_contains "checkout.php" "Shipping Address" "Shipping Address section"
check_file_contains "checkout.php" "Billing Address" "Billing Address section"
check_file_contains "checkout.php" "Shipping Method" "Shipping Method section"
check_file_contains "checkout.php" "Discount Codes" "Discount Codes section"
check_file_contains "checkout.php" "Payment Information" "Payment Information section"
check_file_contains "checkout.php" "stripe-card-number" "Stripe card number element"
check_file_contains "checkout.php" "stripe-card-expiry" "Stripe card expiry element"
check_file_contains "checkout.php" "stripe-card-cvc" "Stripe CVC element"
check_file_contains "checkout.php" "save_card" "Save card checkbox"
check_file_contains "checkout.php" "same_as_shipping" "Same as shipping checkbox"
check_file_contains "checkout.php" "apply-coupon-btn" "Apply coupon button"
check_file_contains "checkout.php" "apply-giftcard-btn" "Apply gift card button"
echo ""

echo "4. Checking Security Features"
echo "---------------------------"
check_file_contains "checkout.php" "Session::requireLogin" "Login requirement"
check_file_contains "checkout.php" "getCsrfToken" "CSRF token function"
check_file_contains "api/validate-coupon.php" "verifyCsrfToken" "CSRF validation in coupon API"
check_file_contains "api/validate-giftcard.php" "verifyCsrfToken" "CSRF validation in gift card API"
check_file_contains "api/validate-coupon.php" "Session::isLoggedIn" "Authentication in coupon API"
check_file_contains "api/validate-giftcard.php" "Session::isLoggedIn" "Authentication in gift card API"
echo ""

echo "5. Checking Stripe Integration"
echo "-----------------------------"
check_file_contains "checkout.php" "STRIPE_PUBLISHABLE_KEY" "Stripe publishable key"
check_file_contains "checkout.php" "Stripe.js" "Stripe.js loaded"
check_file_contains "js/checkout-payment.js" "stripe.confirmCardPayment" "Stripe payment confirmation"
check_file_contains "js/checkout-payment.js" "create-payment-intent.php" "PaymentIntent creation call"
check_file_contains "js/checkout-payment.js" "cardNumberElement" "Card number element"
check_file_contains "js/checkout-payment.js" "cardExpiryElement" "Card expiry element"
check_file_contains "js/checkout-payment.js" "cardCvcElement" "Card CVC element"
echo ""

echo "6. Checking JavaScript Functions"
echo "-------------------------------"
check_file_contains "js/checkout-payment.js" "validateCheckoutForm" "Form validation function"
check_file_contains "js/checkout-payment.js" "getCheckoutFormData" "Get form data function"
check_file_contains "js/checkout-payment.js" "handleCardError" "Card error handler"
check_file_contains "checkout.php" "updateOrderSummary" "Update order summary function"
check_file_contains "checkout.php" "removeCoupon" "Remove coupon function"
check_file_contains "checkout.php" "removeGiftCard" "Remove gift card function"
echo ""

echo "7. Checking Database Migration"
echo "-----------------------------"
check_file_contains "migrations/20251012_checkout_support.sql" "CREATE TABLE.*coupons" "Coupons table creation"
check_file_contains "migrations/20251012_checkout_support.sql" "CREATE TABLE.*coupon_usage" "Coupon usage table creation"
check_file_contains "migrations/20251012_checkout_support.sql" "CREATE TABLE.*shipping_methods" "Shipping methods table creation"
check_file_contains "migrations/20251012_checkout_support.sql" "ALTER TABLE.*gift_cards" "Gift cards table enhancement"
check_file_contains "migrations/20251012_checkout_support.sql" "ALTER TABLE.*orders" "Orders table enhancement"
check_file_contains "migrations/20251012_checkout_support.sql" "INSERT.*shipping_methods" "Default shipping methods"
echo ""

echo "8. Checking API Endpoints"
echo "------------------------"
check_file_contains "api/validate-coupon.php" "POST" "POST method check in coupon API"
check_file_contains "api/validate-coupon.php" "json_encode" "JSON response in coupon API"
check_file_contains "api/validate-coupon.php" "discount_amount" "Discount calculation"
check_file_contains "api/validate-giftcard.php" "POST" "POST method check in gift card API"
check_file_contains "api/validate-giftcard.php" "json_encode" "JSON response in gift card API"
check_file_contains "api/validate-giftcard.php" "gift_card_amount" "Gift card amount calculation"
echo ""

echo "9. Checking Responsive Design"
echo "----------------------------"
check_file_contains "checkout.php" "@media" "Media queries for responsive design"
check_file_contains "checkout.php" "grid-template-columns" "CSS Grid layout"
check_file_contains "checkout.php" "checkout-grid" "Checkout grid class"
echo ""

echo "10. Checking Documentation"
echo "------------------------"
check_file_contains "CHECKOUT_IMPLEMENTATION_GUIDE.md" "Installation" "Installation section"
check_file_contains "CHECKOUT_IMPLEMENTATION_GUIDE.md" "Usage Guide" "Usage guide section"
check_file_contains "CHECKOUT_IMPLEMENTATION_GUIDE.md" "Security" "Security section"
check_file_contains "CHECKOUT_IMPLEMENTATION_GUIDE.md" "Testing" "Testing section"
check_file_contains "CHECKOUT_IMPLEMENTATION_GUIDE.md" "Troubleshooting" "Troubleshooting section"
check_file_contains "CHECKOUT_IMPLEMENTATION_GUIDE.md" "API Reference" "API reference section"
echo ""

# Summary
echo "=========================================="
echo -e "Total checks: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "=========================================="
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Checkout implementation is complete.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Apply database migration:"
    echo "   mysql -u [user] -p [database] < migrations/20251012_checkout_support.sql"
    echo ""
    echo "2. Configure Stripe keys in .env file"
    echo ""
    echo "3. Test checkout flow:"
    echo "   - Add items to cart"
    echo "   - Navigate to /checkout.php"
    echo "   - Complete checkout with test card: 4242 4242 4242 4242"
    echo ""
    echo "4. Create test coupons:"
    echo "   INSERT INTO coupons (code, type, value, status) VALUES ('TEST20', 'percentage', 20, 'active');"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please review the errors above.${NC}"
    exit 1
fi
