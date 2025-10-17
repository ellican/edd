#!/bin/bash
# Migration Script for Live Streams SQL Exception Fix
# This script applies the fix for missing engagement columns in live_streams table
# 
# Usage: bash scripts/fix_live_streams_sql_exception.sh

set -e  # Exit on error

echo "=========================================="
echo "Live Streams SQL Exception Fix"
echo "=========================================="
echo ""
echo "This script will apply migration 056_add_engagement_columns_to_live_streams.php"
echo "which adds missing columns to the live_streams table:"
echo "  - like_count"
echo "  - dislike_count"
echo "  - comment_count"
echo "  - video_path"
echo ""

# Check if we're in the correct directory
if [ ! -f "database/migrate.php" ]; then
    echo "Error: This script must be run from the repository root directory."
    exit 1
fi

# Check if migration file exists
if [ ! -f "database/migrations/056_add_engagement_columns_to_live_streams.php" ]; then
    echo "Error: Migration file not found!"
    exit 1
fi

echo "Environment check..."
if [ -f ".env" ]; then
    echo "✓ .env file found"
else
    echo "⚠ Warning: .env file not found. Using defaults from .env.example"
fi

echo ""
echo "Ready to run migration."
read -p "Do you want to proceed? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Migration cancelled."
    exit 0
fi

echo ""
echo "Running migration..."
php database/migrate.php up

echo ""
echo "=========================================="
echo "Migration completed successfully!"
echo "=========================================="
echo ""
echo "Verification steps:"
echo "1. Check table structure:"
echo "   mysql -u[user] -p[pass] [database] -e 'DESCRIBE live_streams;'"
echo ""
echo "2. Test the live streaming page:"
echo "   Visit: https://fezamarket.com/live.php"
echo ""
echo "3. Check for errors in logs:"
echo "   tail -f storage/logs/error.log"
echo ""
echo "For more information, see:"
echo "  - docs/FIX_SQL_EXCEPTION_LIVE_STREAMS.md"
echo "  - docs/CODEBASE_REVIEW_SUMMARY.md"
