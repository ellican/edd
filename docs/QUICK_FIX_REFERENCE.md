# Quick Reference: Live Streams SQL Exception Fix

## TL;DR - Fix the Error in 2 Steps

1. **Run the migration:**
   ```bash
   php database/migrate.php up
   ```

2. **Verify it worked:**
   ```bash
   mysql -u[user] -p[pass] [database] -e "DESCRIBE live_streams;" | grep "_count"
   ```

## What This Fixes

**Error**: `Column not found: 1054 Unknown column 'ls.like_count' in 'SELECT'`

**Solution**: Adds 4 missing columns to `live_streams` table

## Quick Test After Fix

```bash
# Test 1: Check columns exist
mysql -u[user] -p[pass] [database] -e "SELECT like_count, dislike_count, comment_count, video_path FROM live_streams LIMIT 1;"

# Test 2: Visit the page (should work without errors)
curl https://fezamarket.com/live.php

# Test 3: Check logs (should be clean)
tail -n 50 storage/logs/error.log | grep -i "column not found"
```

## Need More Info?

- **Detailed Fix Guide**: `docs/FIX_SQL_EXCEPTION_LIVE_STREAMS.md`
- **Full Code Review**: `docs/CODEBASE_REVIEW_SUMMARY.md`
- **Migration File**: `database/migrations/056_add_engagement_columns_to_live_streams.php`

## Rollback (if needed)

```bash
php database/migrate.php down
```

## Support

If the migration fails:
1. Check database credentials in `.env`
2. Ensure database is accessible
3. Check for existing column names conflicts
4. Review migration log output for specific errors

## Safe to Run?

✅ Yes - Uses `IF NOT EXISTS` clauses  
✅ Yes - Sets default values for existing rows  
✅ Yes - Backwards compatible  
✅ Yes - Can be rolled back  
