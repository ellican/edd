# KYC Data Flow Refactoring Summary

## Problem Statement
There was a data flow issue due to confusion between multiple KYC-related tables (`seller_kyc`, `vendor_kyc`, `kyc_documents`). Seller KYC submissions were correctly saved to the `seller_kyc` table, but the admin panel at `admin/vendors/` incorrectly queried the empty `vendor_kyc` table to display documents for verification. This prevented admins from seeing or managing submitted KYC documents.

## Solution
Refactored the entire codebase to consistently use `seller_kyc` as the single source of truth for vendor KYC data.

## Changes Made

### 1. `/admin/vendors/show.php`
**Before:**
```php
$kyc_docs = Database::query(
    "SELECT * FROM vendor_kyc WHERE vendor_id = ? ORDER BY uploaded_at DESC",
    [$vendor_id]
)->fetchAll();
```

**After:**
```php
$kyc_docs = Database::query(
    "SELECT * FROM seller_kyc WHERE vendor_id = ? ORDER BY submitted_at DESC",
    [$vendor_id]
)->fetchAll();
```

### 2. `/admin/vendors/kyc.php`
**Major Changes:**
- Changed from querying individual documents in `vendor_kyc` to querying the single comprehensive KYC submission in `seller_kyc`
- Updated action handling from `verify_document` to `update_status` to work with the overall KYC submission status rather than individual documents
- Modified the UI to display JSON-encoded documents from `seller_kyc` fields:
  - `identity_documents`
  - `address_verification`
  - `bank_verification`
  - `business_documents`
- Updated field references:
  - `status` → `verification_status`
  - `remarks` → `verification_notes`
  - `uploaded_at` → `submitted_at`

### 3. `/admin/kyc/index.php`
**Updated field mappings in seller_kyc queries:**
- `sk.status` → `sk.verification_status as status`
- `sk.rejection_reason` → `sk.verification_notes as review_notes`
- Fixed all COUNT queries to use `verification_status` instead of `status`

### 4. `/migrations/20251017_vendor_management_system.sql`
Added deprecation notice to `vendor_kyc` table:
```sql
-- DEPRECATED: This table is no longer used. Use seller_kyc table instead.
-- seller_kyc provides a more comprehensive KYC system with JSON document storage
-- This table is kept for backward compatibility only
```

## Table Structure Comparison

### `vendor_kyc` (Deprecated)
- Stores individual document records
- Fields: `document_type`, `file_path`, `file_name`, `status`, etc.
- One row per document

### `seller_kyc` (Current Standard)
- Stores comprehensive KYC submission
- JSON fields for multiple document categories:
  - `identity_documents`
  - `business_documents`
  - `address_verification`
  - `bank_verification`
- Single row per vendor with overall status
- Field: `verification_status` (instead of `status`)
- More comprehensive metadata

## Data Flow After Refactoring

1. **Seller Submission** (`/seller/kyc.php`):
   - Seller uploads documents
   - Documents stored in `/storage/kyc/{vendor_id}/`
   - Metadata saved to `seller_kyc` table as JSON

2. **Admin Review** (`/admin/vendors/kyc.php`):
   - Admin views KYC submission from `seller_kyc`
   - Documents displayed by category (identity, address, bank, business)
   - Admin can approve/reject/request resubmission
   - Overall status updated in `seller_kyc.verification_status`
   - Vendor status updated in `vendors.kyc_status`

3. **Admin Dashboard** (`/admin/vendors/show.php`):
   - Displays KYC document count from `seller_kyc`
   - Links to KYC management page

4. **Admin KYC List** (`/admin/kyc/index.php`):
   - Shows combined list from `kyc_documents` (user KYC) and `seller_kyc` (vendor KYC)
   - Uses proper field mappings for `seller_kyc`

## Validation Results

All validation checks passed:
- ✓ No `vendor_kyc` references in active PHP code
- ✓ `admin/vendors/show.php` correctly uses `seller_kyc` table
- ✓ `admin/vendors/kyc.php` correctly uses `seller_kyc` table
- ✓ `admin/kyc/index.php` uses correct field mappings
- ✓ `seller/kyc.php` correctly submits to `seller_kyc` table
- ✓ All modified files have valid PHP syntax

## Notes

- The `kyc_documents` table is a separate system for user KYC (not vendor/seller) and was not modified
- The `vendor_kyc` table is kept for backward compatibility but marked as deprecated
- No data migration was performed - existing `vendor_kyc` data remains but is not used
- All foreign key constraints remain intact
