# KYC Status Display Fix

## Issue
The admin vendors page (/admin/vendors/) was showing "Not submitted" for all vendors in the KYC column, even though sellers had submitted their KYC documents and the data was available in the database.

## Root Cause
The problem was a database query issue:

1. **Vendors table structure**: The `vendors` table does NOT have a `kyc_status` column
2. **Separate KYC table**: KYC information is stored in the `seller_kyc` table with:
   - `vendor_id` (foreign key to vendors)
   - `verification_status` (enum: pending, in_review, approved, rejected, requires_resubmission)
3. **Missing JOIN**: The query in `admin/vendors/index.php` was only querying the `vendors` table without joining `seller_kyc`
4. **Result**: `$vendor['kyc_status']` was always NULL, defaulting to "Not submitted"

## Solution

### 1. Updated Main Query
Added LEFT JOIN with seller_kyc table:

```php
// BEFORE
$query = "SELECT v.*, u.username, u.email, u.created_at as user_created,
            COALESCE(v.total_products, 0) as product_count,
            COALESCE(v.total_orders, 0) as order_count,
            COALESCE(v.total_sales, 0.00) as total_sales
     FROM vendors v
     LEFT JOIN users u ON v.user_id = u.id
     WHERE {$where_clause}
     ORDER BY v.{$sort_by} {$sort_order}
     LIMIT ? OFFSET ?";

// AFTER
$query = "SELECT v.*, u.username, u.email, u.created_at as user_created,
            COALESCE(v.total_products, 0) as product_count,
            COALESCE(v.total_orders, 0) as order_count,
            COALESCE(v.total_sales, 0.00) as total_sales,
            sk.verification_status as kyc_status,
            sk.submitted_at as kyc_submitted_at,
            sk.verified_at as kyc_verified_at
     FROM vendors v
     LEFT JOIN users u ON v.user_id = u.id
     LEFT JOIN seller_kyc sk ON v.id = sk.vendor_id
     WHERE {$where_clause}
     ORDER BY v.{$sort_by} {$sort_order}
     LIMIT ? OFFSET ?";
```

### 2. Updated Statistics Query
Fixed the stats query to count KYC statuses from the joined table:

```php
// BEFORE
$stats_query = "SELECT 
    COUNT(*) as total,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
    ...
    SUM(CASE WHEN kyc_status = 'pending' OR kyc_status = 'in_review' THEN 1 ELSE 0 END) as pending_kyc
FROM vendors";

// AFTER
$stats_query = "SELECT 
    COUNT(*) as total,
    SUM(CASE WHEN v.status = 'pending' THEN 1 ELSE 0 END) as pending,
    ...
    SUM(CASE WHEN sk.verification_status IN ('pending', 'in_review') THEN 1 ELSE 0 END) as pending_kyc
FROM vendors v
LEFT JOIN seller_kyc sk ON v.id = sk.vendor_id";
```

### 3. Updated KYC Filter Logic
Added special handling for "not_submitted" filter (NULL values):

```php
if ($kyc_filter) {
    if ($kyc_filter === 'not_submitted') {
        // Filter for vendors with no KYC submission (NULL seller_kyc records)
        $where_conditions[] = "sk.id IS NULL";
    } else {
        $where_conditions[] = "sk.verification_status = ?";
        $params[] = $kyc_filter;
    }
}
```

### 4. Updated Display Logic
Improved status mapping to handle NULL values and all verification statuses:

```php
// Map seller_kyc verification_status to display status
$kycStatus = $vendor['kyc_status'] ?? null;

if ($kycStatus === null) {
    $kycStatusDisplay = 'Not submitted';
    $kycStatusClass = 'secondary';
} else {
    $statusMap = [
        'pending' => ['display' => 'Pending', 'class' => 'warning'],
        'in_review' => ['display' => 'In Review', 'class' => 'info'],
        'approved' => ['display' => 'Approved', 'class' => 'success'],
        'rejected' => ['display' => 'Rejected', 'class' => 'danger'],
        'requires_resubmission' => ['display' => 'Requires Resubmission', 'class' => 'warning']
    ];
    
    $statusInfo = $statusMap[$kycStatus] ?? ['display' => 'Unknown', 'class' => 'secondary'];
    $kycStatusDisplay = $statusInfo['display'];
    $kycStatusClass = $statusInfo['class'];
}
```

### 5. Added Missing Filter Option
Added "Requires Resubmission" to the KYC filter dropdown to match all possible database states.

## Database Schema Reference

### seller_kyc table
```sql
CREATE TABLE `seller_kyc` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_id` int(11) NOT NULL,
  `verification_type` enum('individual','business','corporation') NOT NULL,
  `identity_documents` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `business_documents` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `address_verification` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `bank_verification` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `verification_status` enum('pending','in_review','approved','rejected','requires_resubmission') NOT NULL DEFAULT 'pending',
  `verification_notes` text DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `verified_by` int(11) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_vendor_id` (`vendor_id`),
  ...
) ENGINE=InnoDB;
```

## Result

The admin vendors page now correctly displays:
- ✅ **Pending** - For submitted KYC awaiting review
- ✅ **In Review** - For KYC currently being reviewed
- ✅ **Approved** - For approved KYC
- ✅ **Rejected** - For rejected KYC
- ✅ **Requires Resubmission** - For KYC needing updates
- ✅ **Not submitted** - For vendors who haven't submitted KYC

All KYC data from the `seller_kyc` table is now properly displayed in the admin interface.

## Files Changed
- `/admin/vendors/index.php` - Updated queries and display logic

## Testing
To verify the fix:
1. Navigate to `/admin/vendors/`
2. Check that vendors who submitted KYC show correct status (e.g., "Pending", "Approved")
3. Filter by different KYC statuses to verify filtering works
4. Check that statistics counter shows correct pending KYC count
