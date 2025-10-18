# Database Migrations

This directory contains SQL migration files for the streaming system.

## Migration Files

### Stream Engagement System
- `20251015_live_stream_engagement_system.sql` - Initial engagement system setup
- `20251017_enhance_live_streaming_system.sql` - Enhanced streaming features
- `20251018_add_stream_key_to_live_streams.sql` - Stream key column addition
- `20251018_add_is_fake_columns.sql` - Fake engagement tracking columns

## Running Migrations

### Automated Migration Scripts

The repository includes PHP scripts to run migrations safely:

#### 1. Stream Key Migration
```bash
php run_stream_key_migration.php
```

#### 2. is_fake Columns Migration (Required for Fake Engagement)
```bash
php run_is_fake_columns_migration.php
```

These scripts:
- Check for existing columns/indexes before adding
- Handle "already exists" errors gracefully
- Provide detailed progress output
- Compatible with MariaDB 10.5+

### Manual Migration (Alternative)

If you prefer to run migrations manually:

```bash
mysql -u username -p database_name < migrations/20251018_add_is_fake_columns.sql
```

## Migration Order

Run migrations in this order:
1. `20251015_live_stream_engagement_system.sql`
2. `20251017_enhance_live_streaming_system.sql`
3. `20251018_add_stream_key_to_live_streams.sql`
4. `20251018_add_is_fake_columns.sql` ⚠️ **NEW - Required**

## Validation

After running migrations, validate the setup:

```bash
php validate_stream_engagement.php
```

This will check:
- ✅ Required tables exist
- ✅ Required columns exist (including `is_fake`)
- ✅ Indexes are properly created
- ✅ API endpoints are accessible

## Troubleshooting

### Error: "Column not found: 1054 Unknown column 'is_fake'"

This means the `is_fake` columns are missing. Run:

```bash
php run_is_fake_columns_migration.php
```

### Error: "IF NOT EXISTS not supported"

Your MariaDB version is too old. Upgrade to MariaDB 10.5+ or manually add the columns:

```sql
ALTER TABLE stream_viewers ADD COLUMN is_fake TINYINT(1) NOT NULL DEFAULT 0;
ALTER TABLE stream_interactions ADD COLUMN is_fake TINYINT(1) NOT NULL DEFAULT 0;
```

### Error: "Duplicate column name 'is_fake'"

This means the migration has already been run. You can safely ignore this error.

## Schema Changes

### stream_viewers Table
New columns:
- `is_fake` TINYINT(1) - Identifies fake viewers for engagement simulation
- `left_at` TIMESTAMP - When viewer left the stream
- `watch_duration` INT - Duration viewer watched in seconds

### stream_interactions Table
New columns:
- `is_fake` TINYINT(1) - Identifies fake interactions for engagement simulation

## Support

If you encounter issues:
1. Check MariaDB version: `SELECT VERSION();`
2. Verify table structure: `SHOW COLUMNS FROM stream_viewers;`
3. Check error logs in `/home/fezamarket/public_html/logs/`
4. Review validation output from `validate_stream_engagement.php`
