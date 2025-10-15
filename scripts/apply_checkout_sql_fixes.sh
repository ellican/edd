#!/bin/bash
###############################################################################
# Apply Checkout SQL Fixes Migrations
# 
# This script applies the database migrations to fix checkout SQL errors
# for Rwanda (RW) and US countries.
###############################################################################

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Applying Checkout SQL Fixes Migrations ==="
echo ""

# Check if migrations exist
if [ ! -f "$PROJECT_ROOT/migrations/2025_10_13_000001_add_price_minor_columns_to_order_items.php" ]; then
    echo "ERROR: Migration file not found!"
    echo "Expected: $PROJECT_ROOT/migrations/2025_10_13_000001_add_price_minor_columns_to_order_items.php"
    exit 1
fi

# Migration 1: Add price_minor columns to order_items
echo "1. Adding price_minor and subtotal_minor columns to order_items table..."
php "$PROJECT_ROOT/migrations/2025_10_13_000001_add_price_minor_columns_to_order_items.php" up
if [ $? -eq 0 ]; then
    echo "   ✓ Migration 1 completed successfully"
else
    echo "   ✗ Migration 1 failed!"
    exit 1
fi
echo ""

# Migration 2: Add currency_rate columns
echo "2. Adding currency rate columns to currency_rates table..."
php "$PROJECT_ROOT/migrations/2025_10_13_000002_add_currency_rate_columns.php" up
if [ $? -eq 0 ]; then
    echo "   ✓ Migration 2 completed successfully"
else
    echo "   ✗ Migration 2 failed!"
    exit 1
fi
echo ""

# Run verification test
echo "3. Verifying migrations..."
if [ -f "$PROJECT_ROOT/tests/test_checkout_sql_fixes.php" ]; then
    php "$PROJECT_ROOT/tests/test_checkout_sql_fixes.php"
    if [ $? -eq 0 ]; then
        echo ""
        echo "=== All migrations applied successfully! ==="
        echo ""
        echo "The checkout process should now work correctly for:"
        echo "  ✓ Rwanda (RW) - currency rate lookups"
        echo "  ✓ United States (US) and other countries - order item creation"
        echo ""
    else
        echo ""
        echo "⚠ Migrations applied but verification found issues."
        echo "Please check the output above for details."
        exit 1
    fi
else
    echo "   ⚠ Verification test not found, skipping..."
    echo ""
    echo "=== Migrations applied successfully! ==="
    echo ""
fi
