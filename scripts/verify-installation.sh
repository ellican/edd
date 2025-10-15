#!/bin/bash
# Installation Verification Script
# Checks if all features are properly installed

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "======================================"
echo "   Installation Verification"
echo "======================================"
echo ""

# Counter
CHECKS_PASSED=0
CHECKS_FAILED=0

# Function to check something
check() {
    local description=$1
    local command=$2
    
    echo -n "Checking: $description ... "
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((CHECKS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC}"
        ((CHECKS_FAILED++))
        return 1
    fi
}

# Check files exist
echo -e "${BLUE}File Checks:${NC}"
check "Admin communications compose file" "test -f admin/communications/compose.php"
check "Admin security index file" "test -f admin/security/index.php"
check "Fake engagement generator" "test -f api/live/fake-engagement.php"
check "Trigger engagement endpoint" "test -f api/live/trigger-engagement.php"
check "Communications migration" "test -f migrations/20251015_admin_communications_tables.sql"
check "Engagement migration" "test -f migrations/20251015_live_stream_engagement_system.sql"
check "Fake engagement cron script" "test -f scripts/fake-engagement-cron.sh"
echo ""

# Check .env configuration
echo -e "${BLUE}Configuration Checks:${NC}"
if [ -f .env ]; then
    check "ADMIN_BYPASS in .env" "grep -q 'ADMIN_BYPASS' .env"
    
    # Check if ADMIN_BYPASS is true
    if grep -q "ADMIN_BYPASS=true" .env; then
        echo -e "  ${GREEN}✓${NC} ADMIN_BYPASS is enabled"
    else
        echo -e "  ${YELLOW}⚠${NC} ADMIN_BYPASS is not enabled (set to true for testing)"
    fi
else
    echo -e "  ${RED}✗${NC} .env file not found"
    ((CHECKS_FAILED++))
fi
echo ""

# Check Apache configuration
echo -e "${BLUE}Apache Checks:${NC}"
check ".htaccess file exists" "test -f .htaccess"
check "mod_rewrite directive in .htaccess" "grep -q 'RewriteEngine On' .htaccess"
echo ""

# Check database connection (if possible)
echo -e "${BLUE}Database Checks:${NC}"
if [ -f .env ]; then
    DB_HOST=$(grep DB_HOST .env | cut -d '=' -f2 | tr -d ' ')
    DB_NAME=$(grep DB_NAME .env | cut -d '=' -f2 | tr -d ' ')
    DB_USER=$(grep DB_USER .env | cut -d '=' -f2 | tr -d ' ')
    DB_PASS=$(grep DB_PASS .env | cut -d '=' -f2 | tr -d ' ')
    
    echo -n "Checking database connection ... "
    if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT 1" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((CHECKS_PASSED++))
        
        # Check if tables exist
        echo -n "Checking email_queue table ... "
        if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "DESCRIBE email_queue" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
            ((CHECKS_PASSED++))
        else
            echo -e "${YELLOW}⚠${NC} (run migrations)"
            ((CHECKS_FAILED++))
        fi
        
        echo -n "Checking notifications table ... "
        if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "DESCRIBE notifications" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
            ((CHECKS_PASSED++))
        else
            echo -e "${YELLOW}⚠${NC} (run migrations)"
            ((CHECKS_FAILED++))
        fi
        
        echo -n "Checking stream_engagement_config table ... "
        if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "DESCRIBE stream_engagement_config" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
            ((CHECKS_PASSED++))
        else
            echo -e "${YELLOW}⚠${NC} (run migrations)"
            ((CHECKS_FAILED++))
        fi
        
        echo -n "Checking stream_viewers.is_fake column ... "
        if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "DESCRIBE stream_viewers" | grep -q "is_fake" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
            ((CHECKS_PASSED++))
        else
            echo -e "${YELLOW}⚠${NC} (run migrations)"
            ((CHECKS_FAILED++))
        fi
    else
        echo -e "${RED}✗${NC}"
        echo "  Cannot connect to database. Please check credentials."
        ((CHECKS_FAILED++))
    fi
else
    echo "  ${YELLOW}⚠${NC} Cannot check database (no .env file)"
fi
echo ""

# Summary
echo "======================================"
echo "   Verification Summary"
echo "======================================"
echo -e "Passed: ${GREEN}$CHECKS_PASSED${NC}"
echo -e "Failed: ${RED}$CHECKS_FAILED${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Open https://fezamarket.com/admin/communications/compose"
    echo "2. Open https://fezamarket.com/admin/security/"
    echo "3. Open https://fezamarket.com/live.php"
    exit 0
else
    echo -e "${YELLOW}⚠ Some checks failed${NC}"
    echo ""
    echo "Next steps:"
    if grep -q "run migrations" <<< "$OUTPUT"; then
        echo "1. Run: ./scripts/run-migrations.sh"
    fi
    if ! grep -q "ADMIN_BYPASS=true" .env 2>/dev/null; then
        echo "2. Set ADMIN_BYPASS=true in .env file"
    fi
    exit 1
fi
