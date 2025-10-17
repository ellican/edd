# Vendor Management System - Quick Setup Guide

## Prerequisites
- PHP 8.0 or higher
- MySQL/MariaDB database
- Admin access to the application
- Email/SMTP configured (for notifications)

## Installation Steps

### Step 1: Run Database Migration

Execute the migration file to create necessary tables:

```bash
mysql -u your_username -p your_database < /home/runner/work/edd/edd/migrations/20251017_vendor_management_system.sql
```

Or via phpMyAdmin:
1. Login to phpMyAdmin
2. Select your database
3. Go to "Import" tab
4. Choose file: `migrations/20251017_vendor_management_system.sql`
5. Click "Go"

### Step 2: Verify Installation

Check that the following tables were created:
- `vendor_kyc`
- `vendor_audit_logs`
- `vendor_activity_logs`
- `feature_flags`

Verify the `vendors` table has new columns:
```sql
DESCRIBE vendors;
```

You should see: `category`, `kyc_status`, `total_products`, `total_sales`, etc.

### Step 3: Enable Feature Flag

The migration automatically enables the feature, but verify:

```sql
SELECT * FROM feature_flags WHERE flag_name = 'VENDOR_MGMT';
```

Should show `is_enabled = 1`.

### Step 4: Access Admin Panel

Navigate to: **https://your-domain.com/admin/vendors/**

You should see:
- Vendor statistics dashboard
- Search and filter options
- List of all vendors (if any exist)

### Step 5: Test Core Features

#### Test 1: View Pending Applications
1. Go to `/admin/vendors/applications.php`
2. Verify pending vendor applications are listed
3. Try approving/rejecting an application

#### Test 2: Manage Vendor Profile
1. Click on any vendor from the list
2. Verify all tabs work (Details, Products, Transactions, Activity, Audit)
3. Click "Edit Profile" button
4. Make a change and save
5. Verify the change appears in the audit log

#### Test 3: KYC Management
1. From vendor profile, click "Manage KYC"
2. If KYC documents exist, try verifying one
3. Test approve/reject actions
4. Verify email notifications are sent

#### Test 4: Bulk Actions
1. From vendor directory, select multiple vendors using checkboxes
2. Choose a bulk action (Approve/Reject/Suspend)
3. Confirm and verify all selected vendors are updated

#### Test 5: CSV Export
1. Apply some filters (e.g., status = "approved")
2. Click "Export CSV"
3. Open the downloaded file
4. Verify data matches the filtered results

## Configuration

### Email Notifications

Edit `/home/runner/work/edd/edd/config/config.php`:

```php
define('SMTP_HOST', 'smtp.your-provider.com');
define('SMTP_PORT', 587);
define('SMTP_USERNAME', 'no-reply@your-domain.com');
define('SMTP_PASSWORD', 'your-password');
define('FROM_EMAIL', 'no-reply@your-domain.com');
```

### Commission Rates

Default commission rate is 10%. To change:
1. Go to vendor edit page
2. Update "Commission Rate (%)" field
3. Save changes

### Access Control

By default, only users with `admin` role can access vendor management.

To add additional roles:

Edit `/home/runner/work/edd/edd/middleware/RoleMiddleware.php`:

```php
'admin' => [
    'vendors.manage',
    // ... other permissions
],
'ops_admin' => [  // Add this for operations team
    'vendors.manage',
    'vendors.view',
],
```

## Verification Checklist

- [ ] Database tables created successfully
- [ ] Feature flag `VENDOR_MGMT` is enabled
- [ ] Can access `/admin/vendors/` without errors
- [ ] Can view vendor list with statistics
- [ ] Search and filters work correctly
- [ ] Pagination works for large vendor lists
- [ ] Can approve/reject vendor applications
- [ ] Can edit vendor profiles
- [ ] Can verify KYC documents
- [ ] Email notifications are being sent
- [ ] Bulk actions work correctly
- [ ] CSV export downloads successfully
- [ ] Audit logs are being recorded
- [ ] All actions are logged with admin ID and timestamp

## Common Issues and Solutions

### Issue: "Table doesn't exist" error

**Solution**: Make sure the migration was run successfully:
```sql
SHOW TABLES LIKE 'vendor%';
```

### Issue: Emails not sending

**Solution**:
1. Check SMTP configuration in `config/config.php`
2. Verify the email functions are loaded:
   ```php
   if (function_exists('sendEmail')) {
       echo "Email system loaded";
   }
   ```
3. Check PHP error logs for SMTP errors

### Issue: "Access denied" when accessing admin pages

**Solution**:
1. Verify you're logged in as admin user
2. Check role in database:
   ```sql
   SELECT role FROM users WHERE id = YOUR_USER_ID;
   ```
3. Should be `admin` or `super`

### Issue: KYC documents not displaying

**Solution**:
1. Check file paths in `vendor_kyc` table
2. Verify upload directory exists and is writable:
   ```bash
   ls -la /home/runner/work/edd/edd/uploads/kyc/
   ```
3. Ensure proper permissions:
   ```bash
   chmod 755 /home/runner/work/edd/edd/uploads/kyc/
   ```

### Issue: Statistics showing zero

**Solution**:
Update cached values:
```sql
UPDATE vendors v 
SET 
  total_products = (SELECT COUNT(*) FROM products WHERE seller_id = v.user_id),
  total_orders = (SELECT COUNT(*) FROM orders WHERE seller_id = v.user_id),
  total_sales = (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE seller_id = v.user_id);
```

## Next Steps

### 1. Customize Vendor Categories

Add relevant categories for your marketplace:

```sql
-- Example categories
UPDATE vendors SET category = 'Electronics' WHERE business_type = 'business' AND business_name LIKE '%Tech%';
UPDATE vendors SET category = 'Fashion' WHERE business_type = 'individual' AND business_name LIKE '%Style%';
```

### 2. Set Up Automated Tasks

Create cron jobs for:

**Update vendor statistics (daily):**
```bash
0 0 * * * php /path/to/scripts/update_vendor_stats.php
```

**Send KYC expiry reminders (weekly):**
```bash
0 9 * * 1 php /path/to/scripts/kyc_expiry_reminders.php
```

### 3. Configure Notification Templates

Customize email templates in `/includes/emails/` directory:
- `vendor_approved.php`
- `vendor_rejected.php`
- `vendor_suspended.php`
- `kyc_approved.php`
- `kyc_rejected.php`

### 4. Add Dashboard Widgets

Add vendor stats to main admin dashboard:

```php
// In /admin/index.php
$pending_vendors = Database::query(
    "SELECT COUNT(*) as cnt FROM vendors WHERE status = 'pending'"
)->fetch()['cnt'];

$pending_kyc = Database::query(
    "SELECT COUNT(*) as cnt FROM vendors WHERE kyc_status IN ('pending', 'in_review')"
)->fetch()['cnt'];
```

## Support

For detailed documentation, see: `/docs/VENDOR_MANAGEMENT_SYSTEM.md`

For issues or questions:
- Technical Support: dev@fezamarket.com
- Feature Requests: GitHub Issues

## Migration Commands Reference

**Run migration:**
```bash
mysql -u username -p database < migrations/20251017_vendor_management_system.sql
```

**Rollback (if needed):**
```sql
source migrations/20251017_vendor_management_system_rollback.sql
```

**Check migration status:**
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'your_database' 
AND table_name LIKE 'vendor%';
```

---

**Setup Complete!** 🎉

Your Vendor Management System is now ready to use.
