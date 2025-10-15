#!/bin/bash
# Database Migration Runner
# Runs all pending migrations in order

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "   Database Migration Runner"
echo "======================================"
echo ""

# Get database credentials from .env or prompt
if [ -f .env ]; then
    echo "Loading database credentials from .env..."
    DB_HOST=$(grep DB_HOST .env | cut -d '=' -f2)
    DB_NAME=$(grep DB_NAME .env | cut -d '=' -f2)
    DB_USER=$(grep DB_USER .env | cut -d '=' -f2)
    DB_PASS=$(grep DB_PASS .env | cut -d '=' -f2)
else
    echo -e "${YELLOW}Warning: .env file not found${NC}"
    read -p "Database host [localhost]: " DB_HOST
    DB_HOST=${DB_HOST:-localhost}
    read -p "Database name: " DB_NAME
    read -p "Database user: " DB_USER
    read -sp "Database password: " DB_PASS
    echo ""
fi

echo ""
echo "Database: $DB_NAME"
echo "Host: $DB_HOST"
echo "User: $DB_USER"
echo ""

# Function to run a migration
run_migration() {
    local file=$1
    local filename=$(basename "$file")
    
    echo -n "Running migration: $filename ... "
    
    if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$file" 2>/dev/null; then
        echo -e "${GREEN}✓ Success${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed${NC}"
        return 1
    fi
}

# Get all migration files
MIGRATION_DIR="migrations"
FAILED=0
SUCCESS=0

if [ ! -d "$MIGRATION_DIR" ]; then
    echo -e "${RED}Error: migrations directory not found${NC}"
    exit 1
fi

echo "Finding migration files..."
echo ""

# Run only our new migrations
MIGRATIONS=(
    "$MIGRATION_DIR/20251015_admin_communications_tables.sql"
    "$MIGRATION_DIR/20251015_live_stream_engagement_system.sql"
)

for migration in "${MIGRATIONS[@]}"; do
    if [ -f "$migration" ]; then
        if run_migration "$migration"; then
            ((SUCCESS++))
        else
            ((FAILED++))
        fi
    else
        echo -e "${YELLOW}Warning: Migration file not found: $migration${NC}"
    fi
done

echo ""
echo "======================================"
echo "   Migration Summary"
echo "======================================"
echo -e "Success: ${GREEN}$SUCCESS${NC}"
echo -e "Failed:  ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All migrations completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}Some migrations failed. Please check the errors above.${NC}"
    exit 1
fi
