# KYC Data Flow - Before and After

## Before (Broken Flow)

```
┌─────────────────────┐
│   Seller submits    │
│   KYC documents     │
│  /seller/kyc.php    │
└──────────┬──────────┘
           │
           ▼
    ┌──────────────┐
    │ seller_kyc   │  ← Data goes here
    │   table      │
    └──────────────┘
                            ╔════════════════╗
                            ║ ADMIN CANNOT   ║
                            ║ SEE DOCUMENTS  ║
                            ╚════════════════╝
    ┌──────────────┐              ▲
    │ vendor_kyc   │              │
    │   table      │              │ Admin queries empty table
    │  (EMPTY!)    │              │
    └──────────────┘              │
           ▲                      │
           │                      │
           │              ┌───────┴────────┐
           └──────────────┤ Admin views    │
                          │ /admin/vendors/│
                          │   show.php     │
                          │   kyc.php      │
                          └────────────────┘

PROBLEM: Data flow disconnected!
- Seller writes to seller_kyc ✓
- Admin reads from vendor_kyc ✗ (empty table)
- Result: Admin sees "No KYC Documents"
```

## After (Fixed Flow)

```
┌─────────────────────┐
│   Seller submits    │
│   KYC documents     │
│  /seller/kyc.php    │
└──────────┬──────────┘
           │
           ▼
    ┌──────────────────────────────────┐
    │         seller_kyc table         │
    │                                  │
    │ - vendor_id                      │
    │ - verification_type              │
    │ - identity_documents (JSON)      │
    │ - address_verification (JSON)    │
    │ - bank_verification (JSON)       │
    │ - business_documents (JSON)      │
    │ - verification_status            │
    │ - verified_by, verified_at       │
    └──────────────┬───────────────────┘
                   │
                   │ Same table! ✓
                   │
                   ▼
           ┌───────────────┐
           │ Admin views   │
           │ and manages   │
           │               │
           │ /admin/vendors/show.php  ← Shows KYC count
           │ /admin/vendors/kyc.php   ← Full management
           │ /admin/kyc/index.php     ← List view
           └───────────────┘
                   │
                   │ Admin actions:
                   ▼ - Approve
    ┌──────────────────────────┐ - Reject
    │ Updates:                 │ - Request resubmission
    │ • seller_kyc status     │
    │ • vendors.kyc_status    │
    │ • vendor_audit_logs     │
    └──────────────────────────┘

SOLUTION: Single source of truth!
- Seller writes to seller_kyc ✓
- Admin reads from seller_kyc ✓
- Result: Admin sees all submitted documents
```

## Table Comparison

### vendor_kyc (Deprecated - Not Used)
```
Individual document approach
├── One row per document
├── Fields: document_type, file_path, file_name
└── Problem: Never populated by seller submission flow
```

### seller_kyc (Active - Single Source of Truth)
```
Comprehensive submission approach
├── One row per vendor
├── JSON fields for multiple documents:
│   ├── identity_documents (array of docs)
│   ├── address_verification (array of docs)
│   ├── bank_verification (array of docs)
│   └── business_documents (array of docs)
├── Overall verification_status
├── verified_by, verified_at for audit
└── Used by both seller submission and admin review
```

## Code Changes Summary

### 1. admin/vendors/show.php
```php
// BEFORE
FROM vendor_kyc WHERE vendor_id = ? ORDER BY uploaded_at DESC

// AFTER
FROM seller_kyc WHERE vendor_id = ? ORDER BY submitted_at DESC
```

### 2. admin/vendors/kyc.php
```php
// BEFORE: Individual document management
- Query vendor_kyc for list of documents
- UPDATE vendor_kyc SET status = ? WHERE id = ?
- Display each document with approve/reject buttons

// AFTER: Comprehensive submission management
- Query seller_kyc for single submission (LIMIT 1)
- UPDATE seller_kyc SET verification_status = ? WHERE vendor_id = ?
- Display all documents grouped by category
- Approve/reject entire submission at once
```

### 3. admin/kyc/index.php
```php
// BEFORE: Incorrect field names
FROM seller_kyc sk
WHERE sk.status = ?  // Wrong field name

// AFTER: Correct field names
FROM seller_kyc sk  
WHERE sk.verification_status = ?  // Correct field name
SELECT verification_status as status  // Proper aliasing
```

## Benefits of This Approach

1. **Data Consistency**: Single source of truth eliminates confusion
2. **Better UX**: Admin sees comprehensive view of all documents at once
3. **Easier Auditing**: One verification_status per vendor, not per document
4. **JSON Flexibility**: Can store varying numbers/types of documents
5. **Backward Compatible**: Old vendor_kyc table still exists (just deprecated)
6. **No Data Loss**: No data migration needed, all existing data preserved

## Validation

All validation checks passed:
✓ No vendor_kyc references in active PHP code
✓ All files query seller_kyc correctly
✓ Proper field mappings (verification_status, verification_notes, etc.)
✓ Valid PHP syntax in all modified files
✓ Seller submission flow unchanged and working
✓ Admin review flow now working correctly
