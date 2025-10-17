# Vendor Management System

A comprehensive vendor management system for marketplace administration.

## 🎯 Features

### Core Functionality
- ✅ **Vendor Directory** - Search, filter, sort, and manage all vendors
- ✅ **Application Center** - Review and process vendor applications
- ✅ **KYC Verification** - Upload, verify, and manage KYC documents
- ✅ **Profile Management** - Complete vendor profile with activity tracking
- ✅ **Bulk Actions** - Approve, reject, or suspend multiple vendors at once
- ✅ **CSV Export** - Export vendor data with applied filters
- ✅ **Audit Logging** - Complete audit trail of all admin actions
- ✅ **Email Notifications** - Automatic notifications for all vendor actions

### Admin Pages

| Page | URL | Description |
|------|-----|-------------|
| Vendor Directory | `/admin/vendors/` | List all vendors with filters and bulk actions |
| Applications | `/admin/vendors/applications.php` | Pending vendor applications |
| Vendor Profile | `/admin/vendors/show.php?id={id}` | Detailed vendor profile with tabs |
| Edit Vendor | `/admin/vendors/edit.php?id={id}` | Edit vendor information and controls |
| KYC Management | `/admin/vendors/kyc.php?id={id}` | Manage and verify KYC documents |

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/admin/vendors/export.php` | GET | Export vendors to CSV |

## 🚀 Quick Start

### 1. Installation

```bash
# Run database migration
mysql -u username -p database < migrations/20251017_vendor_management_system.sql
```

### 2. Access

Navigate to: `https://your-domain.com/admin/vendors/`

### 3. Verify

- ✅ Tables created: `vendor_kyc`, `vendor_audit_logs`, `vendor_activity_logs`, `feature_flags`
- ✅ Feature flag enabled: `VENDOR_MGMT`
- ✅ Admin access working

## 📊 Database Schema

### New Tables

- **vendor_kyc** - KYC documents and verification status
- **vendor_audit_logs** - Admin action audit trail
- **vendor_activity_logs** - Vendor activity tracking
- **feature_flags** - Feature toggle management

### Enhanced Vendors Table

New columns: `category`, `kyc_status`, `total_products`, `total_sales`, `total_orders`, `suspension_reason`, and more.

## 🔐 Security Features

- ✅ CSRF Protection on all forms
- ✅ Rate Limiting on actions
- ✅ Role-Based Access Control (Admin only)
- ✅ Complete Audit Logging
- ✅ SQL Injection Prevention (parameterized queries)
- ✅ XSS Protection (input sanitization)

## 📧 Notifications

Automatic email notifications sent for:
- Vendor application approved
- Vendor application rejected
- Vendor account suspended
- KYC document verified
- KYC resubmission required
- Password reset

## 📱 Responsive Design

Fully responsive interface with:
- Mobile-first approach
- Bootstrap 5 framework
- Optimized for mobile, tablet, and desktop

## ♿ Accessibility

- WCAG AA compliant
- Semantic HTML
- ARIA labels
- Keyboard navigation
- Screen reader support

## 📈 Performance

- Indexed database queries
- Pagination (20 items per page)
- Cached statistics
- Optimized SQL queries

## 📝 Documentation

- **Full Documentation**: [VENDOR_MANAGEMENT_SYSTEM.md](docs/VENDOR_MANAGEMENT_SYSTEM.md)
- **Setup Guide**: [VENDOR_MANAGEMENT_SETUP.md](docs/VENDOR_MANAGEMENT_SETUP.md)

## 🔧 Configuration

### Email Setup

Edit `config/config.php`:

```php
define('SMTP_HOST', 'smtp.your-provider.com');
define('SMTP_PORT', 587);
define('SMTP_USERNAME', 'no-reply@your-domain.com');
define('SMTP_PASSWORD', 'your-password');
```

### Access Control

Only `admin` and `super` roles can access by default.

To add more roles, edit `middleware/RoleMiddleware.php`.

## 🧪 Testing

### Manual Testing Checklist

- [ ] View vendor directory with statistics
- [ ] Apply filters and search
- [ ] Sort vendors by different fields
- [ ] Use pagination
- [ ] Approve vendor application
- [ ] Reject vendor application with reason
- [ ] Request additional information
- [ ] Edit vendor profile
- [ ] Suspend vendor account
- [ ] Reactivate suspended account
- [ ] Verify KYC document
- [ ] Request KYC resubmission
- [ ] Perform bulk approve action
- [ ] Perform bulk suspend action
- [ ] Export vendors to CSV
- [ ] View audit logs
- [ ] Verify email notifications sent

## 🐛 Troubleshooting

### Common Issues

**Error: Table doesn't exist**
```sql
SHOW TABLES LIKE 'vendor%';
```

**Emails not sending**
- Check SMTP configuration
- Verify email functions are loaded
- Check PHP error logs

**Access denied**
- Verify user role is `admin` or `super`
- Check `RoleMiddleware.php` permissions

See [Setup Guide](docs/VENDOR_MANAGEMENT_SETUP.md) for more troubleshooting tips.

## 📦 File Structure

```
/admin/vendors/
├── index.php           # Vendor directory
├── applications.php    # Application center
├── show.php           # Vendor profile
├── edit.php           # Edit vendor
└── kyc.php            # KYC management

/api/admin/vendors/
└── export.php         # CSV export

/migrations/
└── 20251017_vendor_management_system.sql

/docs/
├── VENDOR_MANAGEMENT_SYSTEM.md     # Full documentation
└── VENDOR_MANAGEMENT_SETUP.md      # Setup guide
```

## 🔄 Rollback

To rollback the system:

```sql
DROP TABLE IF EXISTS vendor_activity_logs;
DROP TABLE IF EXISTS vendor_audit_logs;
DROP TABLE IF EXISTS vendor_kyc;

ALTER TABLE vendors 
  DROP COLUMN category,
  DROP COLUMN kyc_status,
  -- ... other columns
  
UPDATE feature_flags SET is_enabled = 0 WHERE flag_name = 'VENDOR_MGMT';
```

## 🚧 Future Enhancements

- [ ] Automated KYC verification via third-party services
- [ ] Vendor analytics dashboard with charts
- [ ] Automated commission calculations
- [ ] Performance scoring system
- [ ] Advanced reporting builder
- [ ] Direct vendor messaging
- [ ] Multi-language support

## 📄 License

This is part of the FezaMarket e-commerce platform.

## 👥 Support

- Technical Support: dev@fezamarket.com
- Documentation: docs@fezamarket.com
- GitHub Issues: [Report an issue](https://github.com/eliruf/edd/issues)

---

**Version**: 1.0.0  
**Last Updated**: October 17, 2025  
**Status**: ✅ Production Ready
