-- Admin Communications Enhancement Migration
-- Add metadata column to email_queue for attachments support

-- Check if metadata column exists, if not add it
SET @dbname = DATABASE();
SET @tablename = 'email_queue';
SET @columnname = 'metadata';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' JSON NULL COMMENT ''Stores email metadata including attachments''')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Ensure email attachments directory exists (handled by PHP code)
-- Directory: /uploads/email_attachments/
