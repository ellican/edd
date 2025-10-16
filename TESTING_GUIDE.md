# Testing Guide for KYC Dashboard and Cart UI Fixes

## Overview
This document provides testing instructions for the two fixes implemented:
1. Admin KYC Dashboard now displays seller documents
2. Shopping cart UI positioning improvements

## Issue 1: Admin KYC Dashboard - Seller Documents Display

### What Was Fixed
The admin KYC dashboard (`/admin/kyc/index.php`) now fetches and displays KYC submissions from BOTH:
- `kyc_documents` table (user KYC documents)
- `seller_kyc` table (seller/vendor KYC submissions)

### Testing Steps

#### Prerequisites
1. Log in as an admin user
2. Ensure the database has:
   - At least one record in `kyc_documents` table (user KYC)
   - At least one record in `seller_kyc` table (seller KYC)

#### Test Case 1: View Combined KYC List
1. Navigate to `/admin/kyc/`
2. **Expected Result**: You should see both user KYC and seller KYC documents in the list
3. **Verification Points**:
   - Each row should have a "Type" column showing either "User" (blue badge) or "Seller" (yellow badge)
   - Seller KYC records should show the seller's business name/username
   - Statistics at the top should reflect combined counts from both tables

#### Test Case 2: Filter by Type
1. Navigate to `/admin/kyc/`
2. Use the "Type Filter" dropdown:
   - Select "All Types" - should show all documents
   - Select "User KYC" - should show only user documents
   - Select "Seller KYC" - should show only seller documents
3. **Verification Points**:
   - Filter works correctly
   - URL parameter `?type=user` or `?type=seller` is applied
   - Pagination preserves the filter

#### Test Case 3: Filter by Status
1. Navigate to `/admin/kyc/`
2. Use the "Status Filter" dropdown:
   - Try "Pending Review", "Approved", "Rejected", "Expired"
3. **Verification Points**:
   - Works for both user and seller KYC documents
   - Combined with type filter if needed

#### Test Case 4: Search Functionality
1. Navigate to `/admin/kyc/`
2. Enter search terms:
   - Username
   - Email
   - Document type
3. **Verification Points**:
   - Search works across both user and seller KYC
   - Results show proper type badges

#### Test Case 5: Review Seller KYC Document
1. Navigate to `/admin/kyc/`
2. Find a seller KYC record (yellow badge)
3. Click "Review" button
4. **Expected Result**: Should redirect to `/admin/kyc/view.php?id=X` 
5. **Verification Points**:
   - Shows seller's business information
   - Displays identity documents, address verification, bank documents
   - Shows approval/rejection options

#### Test Case 6: Statistics Accuracy
1. Navigate to `/admin/kyc/`
2. Check the statistics cards at the top
3. **Verification Points**:
   - "Total Documents" = count from kyc_documents + count from seller_kyc
   - "Pending Review" = pending from both tables
   - "Approved" = approved from both tables
   - "Rejected" = rejected from both tables
   - "Expired" = expired from both tables

### SQL Verification
Run these queries to verify data:

```sql
-- Check user KYC count
SELECT COUNT(*) as user_kyc_count FROM kyc_documents;

-- Check seller KYC count
SELECT COUNT(*) as seller_kyc_count FROM seller_kyc;

-- Check combined data
SELECT 
    'user' as kyc_type, 
    status, 
    COUNT(*) as count 
FROM kyc_documents 
GROUP BY status
UNION ALL
SELECT 
    'seller' as kyc_type, 
    status, 
    COUNT(*) as count 
FROM seller_kyc 
GROUP BY status;
```

---

## Issue 2: Shopping Cart UI - Floating Cart Positioning

### What Was Fixed
The floating shopping cart overlay had positioning issues. The following CSS improvements were made:
- Added `!important` flags to critical positioning properties
- Ensured `position: fixed` is properly applied
- Added proper z-index (9999) to float above all content
- Improved overlay pointer-events handling

### Testing Steps

#### Test Case 1: Cart Opens as Floating Panel
1. Navigate to the home page (`/`)
2. Click on the shopping cart icon in the header
3. **Expected Result**: 
   - A sliding panel should appear from the right side
   - Panel should overlay the page content (not push it)
   - Background should have a dark overlay
4. **Verification Points**:
   - Cart panel slides in from right
   - Panel is positioned at the very top-right of the viewport
   - Panel extends full height of the screen
   - Dark overlay covers the rest of the page

#### Test Case 2: Cart Closes Properly
1. Open the cart (as in Test Case 1)
2. Try closing via:
   - Clicking the X button
   - Clicking the dark overlay
   - Pressing ESC key
3. **Expected Result**: Cart slides out and overlay fades away

#### Test Case 3: Cart Position on Scroll
1. Navigate to a page with scrollable content (home page)
2. Scroll down the page
3. Open the cart
4. **Expected Result**:
   - Cart should still appear at top-right of viewport
   - Cart should NOT scroll with the page
   - Cart should be at the same position regardless of scroll position

#### Test Case 4: Cart on Different Pages
Test the cart on:
1. Home page (`/`)
2. Product page (`/product.php?id=1`)
3. Category page (`/category.php?id=1`)
4. Search results (`/search.php?q=test`)

**Verification Points**:
- Cart works consistently across all pages
- Cart appears in same position
- Cart doesn't interfere with footer content

#### Test Case 5: Mobile Responsive
Test on mobile viewport (or resize browser to < 768px width):
1. Open the cart
2. **Expected Result**:
   - Cart should take full width on mobile
   - Cart should still overlay content, not push it
   - Scrolling in cart works properly

#### Test Case 6: Z-Index Verification
1. Open various modals/overlays on the site
2. Then open the cart
3. **Verification Points**:
   - Cart (z-index: 9999) should appear above most content
   - Cart overlay (z-index: 9998) should be below cart but above page content

### Visual Inspection
Using browser DevTools:

1. Open DevTools (F12)
2. Inspect the `.floating-cart-panel` element
3. **Verify CSS**:
   ```css
   position: fixed !important;
   top: 0 !important;
   right: 0 !important; /* when active */
   height: 100vh !important;
   z-index: 9999 !important;
   ```

4. Inspect the `.floating-cart-overlay` element
5. **Verify CSS**:
   ```css
   position: fixed !important;
   top: 0 !important;
   left: 0 !important;
   width: 100% !important;
   height: 100% !important;
   z-index: 9998 !important;
   ```

---

## Common Issues and Troubleshooting

### KYC Dashboard Issues

**Issue**: Seller KYC records not showing
- **Check**: Does the `seller_kyc` table exist and have data?
- **Check**: Are you filtering by "User KYC" only?
- **Check**: Check browser console for JavaScript errors

**Issue**: Type filter not working
- **Check**: URL should have `?type=user` or `?type=seller` parameter
- **Check**: JavaScript function `updateFilter(value, filterType)` is being called

### Shopping Cart Issues

**Issue**: Cart appears in footer instead of floating
- **Check**: Inspect the `.floating-cart-panel` CSS
- **Check**: Verify `position: fixed` is applied (should have `!important`)
- **Check**: Check if any parent element has `overflow: hidden`

**Issue**: Cart doesn't open
- **Check**: JavaScript console for errors
- **Check**: Verify `openFloatingCart()` function exists
- **Check**: Verify cart icon click handler is attached

**Issue**: Cart appears behind other content
- **Check**: Z-index values - cart should be 9999
- **Check**: Other overlays/modals z-index values

---

## Regression Testing

After these fixes, verify these still work:

1. **User KYC Submission** (`/account/kyc.php`)
   - Users can still submit KYC documents
   - Documents appear in admin dashboard

2. **Seller KYC Submission** (`/seller/kyc.php`)
   - Sellers can submit KYC verification
   - Documents appear in admin dashboard

3. **Admin KYC Review** (`/admin/kyc/`)
   - Admins can approve/reject documents
   - Quick approve/reject buttons work

4. **Shopping Cart Functionality**
   - Adding items to cart works
   - Updating quantities works
   - Removing items works
   - Cart count updates correctly

---

## Screenshot Locations

After testing, take screenshots and save them to:
- `/docs/screenshots/kyc-dashboard-fixed.png` - Admin KYC dashboard showing both user and seller documents
- `/docs/screenshots/kyc-type-filter.png` - Type filter dropdown
- `/docs/screenshots/seller-kyc-badge.png` - Seller KYC records with yellow badge
- `/docs/screenshots/floating-cart-open.png` - Floating cart panel open
- `/docs/screenshots/floating-cart-mobile.png` - Floating cart on mobile

---

## Sign-off

Once all tests pass, update this document with:
- Date tested: ___________
- Tested by: ___________
- Environment: ___________
- All tests passed: [ ] Yes [ ] No
- Issues found: ___________
