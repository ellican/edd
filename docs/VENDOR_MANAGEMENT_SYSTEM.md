# Vendor Management System Documentation

## Overview

The Vendor Management System provides a comprehensive admin interface for managing marketplace vendors, including application processing, KYC verification, account management, and detailed reporting.

## Features

### 1. Vendor Directory (`/admin/vendors/index.php`)
- **View all vendors** with comprehensive filtering and sorting
- **Search** by business name, username, or email
- **Filter** by:
  - Status (pending, approved, suspended, rejected)
  - KYC status (not submitted, pending, in review, approved, rejected)
- **Sort** by:
  - Registration date
  - Business name
  - Total sales
  - Total orders
- **Bulk Actions**:
  - Approve multiple vendors at once
  - Reject multiple vendors at once
  - Suspend multiple vendors at once
- **Export** vendors to CSV with current filters applied
- **Statistics Dashboard** showing:
  - Total vendors
  - Pending approvals
  - Approved vendors
  - Suspended vendors
  - Rejected vendors
  - Pending KYC

### 2. Vendor Application Center (`/admin/vendors/applications.php`)
- **List** all pending vendor applications
- **Review** application details including:
  - Business information
  - Contact details
  - Tax ID and website
- **Actions**:
  - Approve applications with optional notes
  - Reject applications with required reason
  - Request additional information
- **Automatic notifications** sent to vendors on all actions

### 3. Vendor Profile View (`/admin/vendors/show.php`)
- **Comprehensive vendor profile** with tabs:
  - **Business Details**: Complete business information and account status
  - **Products**: Link to view all vendor products
  - **Transactions**: Links to orders and payout history
  - **Activity Log**: Vendor activity timeline
  - **Audit Log**: Admin action history with timestamps and reasons
- **Statistics Cards**:
  - Total products
  - Total orders
  - Total sales
  - KYC documents count
- **Quick Actions**:
  - Edit profile
  - Manage KYC
  - Suspend/reactivate account

### 4. Vendor Edit (`/admin/vendors/edit.php`)
- **Edit vendor information**:
  - Business name and type
  - Contact information
  - Tax ID and website
  - Category assignment
  - Commission rate
  - Business description
- **Account Controls**:
  - Suspend account with reason
  - Reactivate suspended accounts
  - Reset vendor password
  - Toggle user access (active/inactive/banned)
- **Quick Links** to:
  - View products
  - View orders
  - View payouts
  - Manage KYC

### 5. KYC Management (`/admin/vendors/kyc.php`)
- **View all KYC documents** for a vendor
- **Document details**:
  - Document type (business license, tax certificate, ID verification, etc.)
  - Upload date
  - Expiry date
  - Current status
  - Verification history
- **Document Actions**:
  - Approve documents
  - Reject documents with reason
  - Mark as "in review"
  - Request resubmission with specific instructions
  - Download documents
- **Automated KYC status** updates based on document verification
- **Email notifications** for all KYC actions

### 6. CSV Export (`/api/admin/vendors/export.php`)
- **Export vendor data** with all applied filters
- **Includes**:
  - All vendor business information
  - Performance metrics (products, orders, sales)
  - Status information
  - Registration and approval dates
- **UTF-8 encoded** with BOM for Excel compatibility
- **Timestamped filename** for easy organization

## Database Schema

### New Tables

#### `vendor_kyc`
Stores KYC documents for vendor verification:
```sql
CREATE TABLE vendor_kyc (
  id INT PRIMARY KEY AUTO_INCREMENT,
  vendor_id INT NOT NULL,
  document_type ENUM('business_license','tax_certificate','bank_statement','id_verification','proof_of_address','other'),
  file_path VARCHAR(500),
  file_name VARCHAR(255),
  file_size INT,
  mime_type VARCHAR(100),
  status ENUM('pending','in_review','approved','rejected','resubmission_required'),
  verified_by INT,
  verified_at TIMESTAMP,
  expiry_date DATE,
  remarks TEXT,
  rejection_reason TEXT,
  uploaded_at TIMESTAMP,
  updated_at TIMESTAMP,
  FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE
);
```

#### `vendor_audit_logs`
Tracks all admin actions on vendor accounts:
```sql
CREATE TABLE vendor_audit_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  vendor_id INT NOT NULL,
  admin_id INT NOT NULL,
  action VARCHAR(100),
  action_type ENUM('status_change','kyc_verification','profile_update','account_suspension','bulk_action','other'),
  old_value TEXT,
  new_value TEXT,
  reason TEXT,
  ip_address VARCHAR(45),
  user_agent VARCHAR(500),
  created_at TIMESTAMP,
  FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE,
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### `vendor_activity_logs`
Tracks vendor activities:
```sql
CREATE TABLE vendor_activity_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  vendor_id INT NOT NULL,
  activity_type ENUM('login','product_added','product_updated','order_processed','payout_requested','profile_updated','other'),
  description VARCHAR(500),
  metadata JSON,
  ip_address VARCHAR(45),
  created_at TIMESTAMP,
  FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE
);
```

#### `feature_flags`
Manages feature toggles:
```sql
CREATE TABLE feature_flags (
  id INT PRIMARY KEY AUTO_INCREMENT,
  flag_name VARCHAR(100) UNIQUE,
  is_enabled BOOLEAN DEFAULT 0,
  description TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### Enhanced Vendors Table
New columns added:
- `category` - Vendor category/vertical
- `subcategory` - Vendor subcategory
- `kyc_status` - KYC verification status
- `kyc_verified_at` - KYC verification timestamp
- `last_activity_at` - Last vendor activity
- `total_products` - Cached product count
- `total_sales` - Cached total sales
- `total_orders` - Cached order count
- `rating` - Vendor rating
- `suspension_reason` - Reason for suspension
- `suspended_at` - Suspension timestamp
- `suspended_by` - Admin who suspended the account

## Setup and Installation

### 1. Run Database Migration

```bash
# Execute the migration SQL file
mysql -u [username] -p [database_name] < migrations/20251017_vendor_management_system.sql
```

### 2. Enable Feature Flag

The migration automatically enables the `VENDOR_MGMT` feature flag. To manually toggle:

```sql
UPDATE feature_flags SET is_enabled = 1 WHERE flag_name = 'VENDOR_MGMT';
```

### 3. Configure Permissions

Ensure admin users have the required permissions in `middleware/RoleMiddleware.php`:
- `vendors.manage` - Full vendor management access
- This is included in the `admin` role by default

### 4. Test Email Configuration

Vendor notifications require a working email system. Verify email settings in `config/config.php`:
```php
define('SMTP_HOST', env('SMTP_HOST', 'smtp.example.com'));
define('SMTP_PORT', (int)env('SMTP_PORT', 587));
define('SMTP_USERNAME', env('SMTP_USERNAME', 'no-reply@example.com'));
define('SMTP_PASSWORD', env('SMTP_PASSWORD', ''));
```

## Usage Guide

### For Administrators

#### Reviewing Vendor Applications

1. Navigate to **Admin Dashboard** → **Vendors** → **Pending Applications**
2. Review the vendor's business information
3. Choose an action:
   - **Approve**: Send optional welcome notes
   - **Reject**: Provide a reason (required)
   - **Request More Info**: Specify what's needed
4. Vendor receives automatic email notification

#### Managing KYC Documents

1. Go to **Vendor Profile** → **Manage KYC**
2. Review each uploaded document
3. Actions available:
   - **Approve**: Mark document as verified
   - **Reject**: Provide rejection reason
   - **In Review**: Mark for further review
   - **Request Resubmission**: Specify what needs correction
4. Vendor's overall KYC status updates automatically

#### Bulk Operations

1. From vendor directory, use checkboxes to select vendors
2. Choose bulk action from dropdown
3. Confirm action
4. All selected vendors are updated and notified

#### Exporting Vendor Data

1. Apply desired filters (status, KYC, search)
2. Click "Export CSV" button
3. File downloads with timestamp in filename
4. Open in Excel or other spreadsheet software

### API Endpoints

#### Export Vendors
```
GET /api/admin/vendors/export.php
```

**Query Parameters:**
- `status` - Filter by vendor status
- `kyc` - Filter by KYC status
- `search` - Search term
- `sort` - Sort field
- `order` - Sort order (ASC/DESC)

**Response:** CSV file download

## Security Features

### 1. CSRF Protection
All forms include CSRF tokens via `csrfTokenInput()` function.

### 2. Rate Limiting
Actions are rate-limited via `validateCsrfAndRateLimit()` function.

### 3. Role-Based Access Control
Access restricted to admin roles via `RoleMiddleware::requireAdmin()`.

### 4. Audit Logging
All administrative actions are logged with:
- Admin ID
- Timestamp
- IP address
- Action details
- Reason/notes

### 5. Input Validation
All user inputs are:
- Sanitized with `htmlspecialchars()`
- Validated before database operations
- Parameterized in SQL queries (preventing SQL injection)

## Notification System

### Email Notifications Sent On:

1. **Vendor Application Approved**
   - Subject: "Vendor Application Approved"
   - Includes: Approval notes (if any)

2. **Vendor Application Rejected**
   - Subject: "Vendor Application Rejected"
   - Includes: Rejection reason

3. **Vendor Account Suspended**
   - Subject: "Vendor Application Suspended"
   - Includes: Suspension reason

4. **KYC Document Verified**
   - Subject: "KYC Document Approved/Rejected"
   - Includes: Status and remarks

5. **KYC Resubmission Required**
   - Subject: "KYC Document Resubmission Required"
   - Includes: Specific instructions

6. **Password Reset**
   - Subject: "Password Reset"
   - Includes: New temporary password

### In-App Notifications
When `createNotification()` function is available, in-app notifications are created for all vendor-related actions.

## Accessibility Features

### Compliance (a11y)

1. **Semantic HTML**: Proper use of headings, lists, and landmarks
2. **ARIA Labels**: All form controls have proper labels
3. **Keyboard Navigation**: Full keyboard support for all actions
4. **Color Contrast**: All text meets WCAG AA standards
5. **Screen Reader Support**: All icons have descriptive text alternatives
6. **Focus Management**: Clear focus indicators on all interactive elements

## Internationalization (i18n)

The system includes placeholders for i18n support:
- All user-facing strings are extractable
- Date formats use PHP's `date()` function for easy localization
- Number formats use `number_format()` for locale-aware formatting

To add translations:
1. Extract strings from PHP files
2. Create language files in `/locales/`
3. Use translation function like `__('string_key')`

## Responsive Design

All pages are fully responsive with:
- Mobile-first approach
- Bootstrap 5 grid system
- Optimized layouts for:
  - Mobile (< 768px)
  - Tablet (768px - 1024px)
  - Desktop (> 1024px)

## Performance Considerations

### Database Optimization
- Indexed columns: `status`, `kyc_status`, `created_at`, `total_sales`
- Composite indexes for common filter combinations
- Pagination (20 items per page) to reduce query load

### Caching
- Statistics queries can be cached (implement with Redis/Memcached)
- Consider caching vendor counts per status

### File Handling
- KYC documents stored outside web root
- File paths stored in database, not files themselves
- Consider implementing CDN for document serving

## Troubleshooting

### Common Issues

**Problem**: Vendor notifications not being sent
- Check SMTP configuration in `config/config.php`
- Verify email functions are loaded in `includes/init.php`
- Check error logs for SMTP errors

**Problem**: CSV export showing garbled characters
- The export includes UTF-8 BOM for Excel compatibility
- If issues persist, try opening in Google Sheets first

**Problem**: Bulk actions not working
- Verify CSRF token is included in form
- Check JavaScript console for errors
- Ensure at least one vendor is selected

**Problem**: KYC documents not displaying
- Verify file paths are correct
- Check file permissions (documents should be readable)
- Ensure mime types are correctly stored

## Rollback Instructions

To rollback the vendor management system:

```sql
-- Drop new tables
DROP TABLE IF EXISTS vendor_activity_logs;
DROP TABLE IF EXISTS vendor_audit_logs;
DROP TABLE IF EXISTS vendor_kyc;

-- Remove new columns from vendors table
ALTER TABLE vendors 
  DROP COLUMN IF EXISTS category,
  DROP COLUMN IF EXISTS subcategory,
  DROP COLUMN IF EXISTS kyc_status,
  DROP COLUMN IF EXISTS kyc_verified_at,
  DROP COLUMN IF EXISTS last_activity_at,
  DROP COLUMN IF EXISTS total_products,
  DROP COLUMN IF EXISTS total_sales,
  DROP COLUMN IF EXISTS total_orders,
  DROP COLUMN IF EXISTS rating,
  DROP COLUMN IF EXISTS suspension_reason,
  DROP COLUMN IF EXISTS suspended_at,
  DROP COLUMN IF EXISTS suspended_by;

-- Disable feature flag
UPDATE feature_flags SET is_enabled = 0 WHERE flag_name = 'VENDOR_MGMT';
```

## Future Enhancements

### Planned Features
1. **Automated KYC Verification**: Integration with third-party KYC services
2. **Vendor Analytics Dashboard**: Comprehensive metrics and charts
3. **Automated Commission Calculations**: Based on sales and order data
4. **Vendor Performance Scoring**: Algorithmic vendor rating system
5. **Advanced Reporting**: Custom report builder for vendor data
6. **Vendor Communication Center**: Direct messaging system
7. **Document Templates**: Pre-defined document requirements per category
8. **Multi-language Support**: Full i18n implementation

## Support and Maintenance

### Logging
All errors are logged using the `Logger::error()` function to:
- `/storage/logs/error.log`

### Monitoring
Monitor these metrics:
- Pending vendor applications count
- Average approval time
- KYC verification rate
- Export frequency

### Regular Maintenance
1. **Weekly**: Review audit logs for suspicious activity
2. **Monthly**: Archive old audit logs (older than 12 months)
3. **Quarterly**: Review and update vendor categories
4. **Annually**: Audit KYC document expiry dates

## Contact

For technical support or feature requests, please contact:
- Technical Team: dev@fezamarket.com
- Documentation: docs@fezamarket.com

---

**Version**: 1.0.0  
**Last Updated**: October 17, 2025  
**Author**: Development Team
