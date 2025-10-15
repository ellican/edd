#!/bin/bash

# Deployment Script for Account and Payment System
# This script runs database migrations and verifies the deployment

echo "========================================="
echo "Account & Payment System Deployment"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please copy .env.example to .env and configure it."
    exit 1
fi

echo -e "${GREEN}✓${NC} .env file found"

# Check for required PHP extensions
echo ""
echo "Checking PHP extensions..."
php -m | grep -q "pdo_mysql" && echo -e "${GREEN}✓${NC} PDO MySQL" || echo -e "${RED}✗${NC} PDO MySQL (required)"
php -m | grep -q "curl" && echo -e "${GREEN}✓${NC} cURL" || echo -e "${RED}✗${NC} cURL (required)"
php -m | grep -q "json" && echo -e "${GREEN}✓${NC} JSON" || echo -e "${RED}✗${NC} JSON (required)"
php -m | grep -q "mbstring" && echo -e "${GREEN}✓${NC} Mbstring" || echo -e "${RED}✗${NC} Mbstring (required)"

# Run database migrations
echo ""
echo "========================================="
echo "Running Database Migrations"
echo "========================================="
echo ""

# Migration 041: Admin Activity Logs
echo "Running migration 041: Create admin_activity_logs table..."
php -r "
require_once 'includes/init.php';
\$db = Database::getInstance()->getConnection();
\$migration = include 'database/migrations/041_create_admin_activity_logs.php';
try {
    \$db->exec(\$migration['up']);
    echo '✓ Migration 041 completed\n';
} catch (Exception \$e) {
    echo '✗ Migration 041 failed: ' . \$e->getMessage() . '\n';
}
"

# Migration 042: Enhance Orders Table
echo "Running migration 042: Enhance orders table..."
php -r "
require_once 'includes/init.php';
\$db = Database::getInstance()->getConnection();
\$migration = include 'database/migrations/042_enhance_orders_table.php';
try {
    \$db->exec(\$migration['up']);
    echo '✓ Migration 042 completed\n';
} catch (Exception \$e) {
    echo '✗ Migration 042 failed: ' . \$e->getMessage() . '\n';
}
"

# Migration 043: Order Tracking Updates
echo "Running migration 043: Create order_tracking_updates table..."
php -r "
require_once 'includes/init.php';
\$db = Database::getInstance()->getConnection();
\$migration = include 'database/migrations/043_create_order_tracking_updates.php';
try {
    \$db->exec(\$migration['up']);
    echo '✓ Migration 043 completed\n';
} catch (Exception \$e) {
    echo '✗ Migration 043 failed: ' . \$e->getMessage() . '\n';
}
"

echo ""
echo "========================================="
echo "Verifying Database Tables"
echo "========================================="
echo ""

# Verify tables exist
php -r "
require_once 'includes/init.php';
\$db = Database::getInstance()->getConnection();

\$tables = [
    'admin_activity_logs',
    'order_tracking_updates',
    'wallets',
    'wallet_transactions',
    'user_payment_methods',
    'addresses',
    'security_logs'
];

foreach (\$tables as \$table) {
    // Use prepared statement to prevent SQL injection
    \$stmt = \$db->prepare('SHOW TABLES LIKE ?');
    \$stmt->execute([\$table]);
    if (\$stmt->rowCount() > 0) {
        echo \"✓ Table '\$table' exists\n\";
    } else {
        echo \"✗ Table '\$table' missing\n\";
    }
}
"

echo ""
echo "========================================="
echo "Checking Stripe Configuration"
echo "========================================="
echo ""

php -r "
require_once 'includes/init.php';

\$mode = getStripeMode();
\$publishableKey = getStripePublishableKey();
\$secretKey = getStripeSecretKey();

echo 'Stripe Mode: ' . \$mode . '\n';

if (!empty(\$publishableKey) && strpos(\$publishableKey, 'pk_') === 0) {
    echo '✓ Publishable key configured\n';
} else {
    echo '✗ Publishable key missing or invalid\n';
}

if (!empty(\$secretKey) && strpos(\$secretKey, 'sk_') === 0) {
    echo '✓ Secret key configured\n';
} else {
    echo '✗ Secret key missing or invalid\n';
}
"

echo ""
echo "========================================="
echo "Setting Permissions"
echo "========================================="
echo ""

# Set proper permissions
# Directories need 755 (rwxr-xr-x)
# PHP files need 644 (rw-r--r--)
find api/ -type d -exec chmod 755 {} \; 2>/dev/null || true
find api/ -type f -name "*.php" -exec chmod 644 {} \; 2>/dev/null || true
find admin/ -type d -exec chmod 755 {} \; 2>/dev/null || true
find admin/ -type f -name "*.php" -exec chmod 644 {} \; 2>/dev/null || true
find includes/ -type d -exec chmod 755 {} \; 2>/dev/null || true
find includes/ -type f -name "*.php" -exec chmod 644 {} \; 2>/dev/null || true
echo -e "${GREEN}✓${NC} Permissions set (directories: 755, PHP files: 644)"

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "Next Steps:"
echo "1. Test user account features at: /account.php"
echo "2. Test checkout process at: /checkout.php"
echo "3. Test admin panel at: /admin/accounts/"
echo "4. Configure Stripe webhook URL in Stripe Dashboard"
echo "5. Monitor error logs for any issues"
echo ""
echo "Documentation: See ACCOUNT_AND_PAYMENT_IMPLEMENTATION.md"
echo ""
