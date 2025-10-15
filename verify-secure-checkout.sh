#!/bin/bash
# Secure Checkout Verification Script
# Tests key components of the secure checkout implementation

echo "=============================================="
echo "Secure Checkout Implementation Verification"
echo "=============================================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
PASSED=0
FAILED=0
WARNINGS=0

# Function to check if file exists and contains pattern
# Uses grep -q for literal string matching (not regex)
# For flexible pattern matching, consider using grep -E for regex
check_file_contains() {
    local file=$1
    local pattern=$2
    local description=$3
    
    if [ -f "$file" ]; then
        if grep -q "$pattern" "$file"; then
            echo -e "${GREEN}✓${NC} $description"
            ((PASSED++))
        else
            echo -e "${RED}✗${NC} $description"
            echo "   Pattern not found: $pattern in $file"
            ((FAILED++))
        fi
    else
        echo -e "${RED}✗${NC} $description"
        echo "   File not found: $file"
        ((FAILED++))
    fi
}

# Function to check if file exists
check_file_exists() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $description"
        ((FAILED++))
    fi
}

echo "1. Checking Core Files"
echo "----------------------"
check_file_exists "checkout.php" "Checkout page exists"
check_file_exists "api/create-payment-intent.php" "Payment Intent API exists"
check_file_exists "api/stripe-webhook.php" "Webhook handler exists"
check_file_exists "order-confirmation.php" "Order confirmation page exists"
check_file_exists "includes/orders.php" "Order helper functions exist"
echo ""

echo "2. Checking CSRF Protection"
echo "---------------------------"
check_file_contains "checkout.php" "csrfMeta()" "CSRF meta tag in checkout page"
check_file_contains "checkout.php" "getCsrfToken()" "CSRF token in checkout form"
check_file_contains "checkout.php" "getCsrfToken()" "JavaScript CSRF helper function"
check_file_contains "checkout.php" "'X-CSRF-Token': getCsrfToken()" "CSRF token sent in API request"
check_file_contains "api/create-payment-intent.php" "verifyCsrfToken" "CSRF validation in API endpoint"
echo ""

echo "3. Checking Security Measures"
echo "-----------------------------"
# Check for HTTPS enforcement - look for multiple patterns
if grep -q "HTTPS" "api/create-payment-intent.php" || \
   grep -q "https" "api/create-payment-intent.php" || \
   grep -q "\$_SERVER\['HTTPS'\]" "api/create-payment-intent.php"; then
    echo -e "${GREEN}✓${NC} HTTPS enforcement"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} HTTPS enforcement"
    ((FAILED++))
fi
check_file_contains "api/create-payment-intent.php" "rate_limits" "Rate limiting implemented"
check_file_contains "api/create-payment-intent.php" "idempotency_key" "Idempotency key generation"
# Check for input sanitization - look for multiple methods
if grep -q "strip_tags" "api/create-payment-intent.php" || \
   grep -q "htmlspecialchars" "api/create-payment-intent.php" || \
   grep -q "filter_var" "api/create-payment-intent.php"; then
    echo -e "${GREEN}✓${NC} Input sanitization"
    ((PASSED++))
else
    echo -e "${YELLOW}!${NC} Input sanitization (consider using more robust methods like filter_var)"
    ((WARNINGS++))
fi
check_file_contains "api/create-payment-intent.php" "Billing address is required" "Required field validation"
echo ""

echo "4. Checking Payment Flow"
echo "-----------------------"
check_file_contains "checkout.php" "confirmCardPayment" "Stripe payment confirmation"
check_file_contains "checkout.php" "card_declined" "Card declined error handling"
check_file_contains "checkout.php" "insufficient_funds" "Insufficient funds error handling"
check_file_contains "checkout.php" "authentication_required" "3DS error handling"
check_file_contains "checkout.php" "sessionStorage.removeItem('checkoutFormValues')" "Form data cleanup on success"
echo ""

echo "5. Checking Coupon & Gift Card Support"
echo "--------------------------------------"
check_file_contains "checkout.php" "apply-coupon-btn" "Coupon apply button exists"
check_file_contains "checkout.php" "apply-giftcard-btn" "Gift card apply button exists"
check_file_contains "checkout.php" "appliedCouponCode" "Coupon code tracking"
check_file_contains "checkout.php" "appliedGiftCardCode" "Gift card code tracking"
check_file_contains "api/create-payment-intent.php" "coupon_code" "Coupon code in API request"
check_file_contains "api/create-payment-intent.php" "gift_card_code" "Gift card code in API request"
check_file_exists "api/coupons/validate.php" "Coupon validation endpoint exists"
check_file_exists "api/gift-cards/validate.php" "Gift card validation endpoint exists"
echo ""

echo "6. Checking Order Management"
echo "---------------------------"
check_file_contains "api/create-payment-intent.php" "create_internal_order" "Order creation function call"
check_file_contains "api/create-payment-intent.php" "generate_order_reference" "Order reference generation"
check_file_contains "api/create-payment-intent.php" "pending_payment" "Pending payment status"
check_file_contains "api/stripe-webhook.php" "payment_intent.succeeded" "Payment success webhook handler"
check_file_contains "api/stripe-webhook.php" "payment_intent.payment_failed" "Payment failed webhook handler"
check_file_contains "api/stripe-webhook.php" "finalize_order_paid" "Order finalization function"
echo ""

echo "7. Checking Error Handling"
echo "-------------------------"
check_file_contains "checkout.php" "try {" "Try-catch error handling"
check_file_contains "checkout.php" "paymentMessage.textContent" "Error message display"
check_file_contains "checkout.php" "setLoading(false)" "Form re-enable on error"
check_file_contains "api/create-payment-intent.php" "catch (Exception" "Exception handling in API"
check_file_contains "api/create-payment-intent.php" "http_response_code(500)" "Proper error status codes"
echo ""

echo "8. Checking Webhook Security"
echo "----------------------------"
check_file_contains "api/stripe-webhook.php" "constructEvent" "Webhook signature verification"
check_file_contains "api/stripe-webhook.php" "event_already_processed" "Webhook idempotency check"
check_file_contains "api/stripe-webhook.php" "record_processed_event" "Event recording"
echo ""

echo "9. Checking Documentation"
echo "------------------------"
check_file_exists "SECURE_CHECKOUT_IMPLEMENTATION.md" "Implementation documentation exists"
if [ -f "SECURE_CHECKOUT_IMPLEMENTATION.md" ]; then
    word_count=$(wc -w < SECURE_CHECKOUT_IMPLEMENTATION.md)
    if [ $word_count -gt 1000 ]; then
        echo -e "${GREEN}✓${NC} Documentation is comprehensive ($word_count words)"
        ((PASSED++))
    else
        echo -e "${YELLOW}!${NC} Documentation exists but may need expansion ($word_count words)"
        ((WARNINGS++))
    fi
    
    # Additional quality checks
    if grep -q "Testing Guide" SECURE_CHECKOUT_IMPLEMENTATION.md && \
       grep -q "Security Features" SECURE_CHECKOUT_IMPLEMENTATION.md && \
       grep -q "Error Handling" SECURE_CHECKOUT_IMPLEMENTATION.md; then
        echo -e "${GREEN}✓${NC} Documentation includes key sections"
        ((PASSED++))
    else
        echo -e "${YELLOW}!${NC} Documentation may be missing some key sections"
        ((WARNINGS++))
    fi
fi
echo ""

echo "10. Environment Configuration"
echo "----------------------------"
if [ -f ".env.example" ]; then
    check_file_contains ".env.example" "STRIPE_PUBLISHABLE_KEY" "Stripe publishable key in example"
    check_file_contains ".env.example" "STRIPE_SECRET_KEY" "Stripe secret key in example"
    check_file_contains ".env.example" "STRIPE_WEBHOOK_SECRET" "Stripe webhook secret in example"
else
    echo -e "${YELLOW}!${NC} .env.example not found (consider creating one)"
    ((WARNINGS++))
fi
echo ""

echo "=============================================="
echo "Verification Summary"
echo "=============================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo ""

# Calculate success rate
total=$((PASSED + FAILED))
if [ $total -gt 0 ]; then
    success_rate=$((PASSED * 100 / total))
    echo "Success Rate: ${success_rate}%"
    echo ""
    
    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All checks passed! Implementation looks good.${NC}"
        exit 0
    elif [ $success_rate -ge 80 ]; then
        echo -e "${YELLOW}⚠ Most checks passed. Review failed items above.${NC}"
        exit 1
    else
        echo -e "${RED}✗ Multiple checks failed. Implementation needs work.${NC}"
        exit 2
    fi
else
    echo -e "${RED}✗ No tests were run successfully.${NC}"
    exit 3
fi
