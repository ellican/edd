# Fix: SQL Exception - Unknown Column in live_streams Table

## Problem Description

The application was experiencing the following SQL exception:

```
Exception: SQLSTATE[42S22]: Column not found: 1054 Unknown column 'ls.like_count' in 'SELECT'
File: /home/fezamarket/public_html/includes/models_extended.php
Line: 971
```

## Root Cause

The `live_streams` table was missing several columns that the application code expected:
- `like_count` - Total likes for the stream
- `dislike_count` - Total dislikes for the stream  
- `comment_count` - Total comments for the stream
- `video_path` - Path to saved stream video/replay

Additionally, the status enum was missing the 'archived' value.

## Solution

### 1. Migration File Created

A new migration file was created at:
```
database/migrations/056_add_engagement_columns_to_live_streams.php
```

This migration:
- Adds the missing engagement count columns
- Adds the video_path column for archived streams
- Updates the status enum to include 'archived'
- Creates an index for archived streams

### 2. Schema Updated

The base schema file `database/schema.sql` was updated to include these columns for new installations.

### 3. How to Apply

To apply this fix to an existing database, run the migration:

```bash
php database/migrate.php up
```

This will:
1. Add the missing columns with default values (0 for count columns, NULL for video_path)
2. Update the status enum
3. Create the necessary indexes

## Files Modified

1. **database/migrations/056_add_engagement_columns_to_live_streams.php** (NEW)
   - Migration file to add missing columns

2. **database/schema.sql** (MODIFIED)
   - Updated live_streams table definition with new columns

## Affected Code Files

The following files reference these columns and will work correctly after migration:

1. **includes/models_extended.php**
   - `LiveStream::getActiveStreams()` - Selects like_count, dislike_count, comment_count

2. **live.php**
   - Displays like_count for recent streams (line 262)

3. **api/streams/engagement.php**
   - Updates engagement counts in real-time

4. **api/streams/end.php**
   - Saves final engagement counts when stream ends

## Verification

After running the migration, verify the fix by:

1. Checking the table structure:
```sql
DESCRIBE live_streams;
```

2. Confirming the columns exist:
```sql
SHOW COLUMNS FROM live_streams LIKE '%_count';
SHOW COLUMNS FROM live_streams LIKE 'video_path';
```

3. Testing the live streams page:
```
https://fezamarket.com/live.php
```

## Rollback

If needed, the migration can be rolled back:

```bash
php database/migrate.php down
```

This will remove the added columns and revert the status enum.

## Additional Notes

- The migration uses `ADD COLUMN IF NOT EXISTS` to prevent errors if columns already exist
- Default values ensure backward compatibility with existing data
- The migration is safe to run on production databases
- No data loss will occur during the migration

## Related Files

- Migration: `database/migrations/056_add_engagement_columns_to_live_streams.php`
- Schema: `database/schema.sql`
- Original migration reference: `migrations/20251017_enhance_live_streaming_system.sql`
