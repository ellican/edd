# KYC Security & Functionality Enhancements - Visual Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     KYC Management System                        │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│   Admin Panel    │      │  File Uploads    │      │   Dashboard      │
│   /admin/kyc/    │      │  (Multiple       │      │   Statistics     │
│                  │      │   Sources)       │      │                  │
└──────────────────┘      └──────────────────┘      └──────────────────┘
         │                         │                          │
         ├─────────────────────────┼──────────────────────────┤
         │                         │                          │
         ▼                         ▼                          ▼
┌─────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│  Download       │      │  Virus Scanner   │      │  Stats Query     │
│  Endpoint       │      │  Service         │      │  Engine          │
│  download.php   │      │  VirusScan       │      │  Fixed Queries   │
└─────────────────┘      └──────────────────┘      └──────────────────┘
```

## File Upload Security Flow

```
User Upload
    │
    ▼
┌─────────────────────────────────────────────────┐
│ Step 1: Extension Validation                    │
│ • Check against whitelist                       │
│ • Block: .exe, .bat, .php, .js, etc.           │
└─────────────────────────────────────────────────┘
    │ ✓ PASS
    ▼
┌─────────────────────────────────────────────────┐
│ Step 2: MIME Type Validation                    │
│ • Verify content matches extension              │
│ • Block mismatches (.jpg with .exe content)    │
└─────────────────────────────────────────────────┘
    │ ✓ PASS
    ▼
┌─────────────────────────────────────────────────┐
│ Step 3: Content Scanning                        │
│ • Scan for suspicious patterns:                │
│   - eval(), exec(), system()                   │
│   - base64_decode()                            │
│   - embedded PHP code                          │
│   - Null byte injection                        │
└─────────────────────────────────────────────────┘
    │ ✓ PASS
    ▼
┌─────────────────────────────────────────────────┐
│ Step 4: File Size & Format Check               │
│ • Verify file size within limits               │
│ • Check for empty files                        │
└─────────────────────────────────────────────────┘
    │ ✓ PASS
    ▼
┌─────────────────────────────────────────────────┐
│ Step 5: Secure Storage                          │
│ • Generate unique filename                      │
│ • Set proper permissions (0644)                │
│ • Store in designated directory                │
│ • Log upload event                             │
└─────────────────────────────────────────────────┘
    │ ✓ SUCCESS
    ▼
   UPLOAD COMPLETE
```

## Document Download Flow

```
Admin Request → /admin/kyc/download.php?id=X&type=user
    │
    ▼
┌─────────────────────────────────────────────────┐
│ Authentication Check                             │
│ • Verify admin session                          │
│ • Check KYC view permission                     │
└─────────────────────────────────────────────────┘
    │ ✓ AUTHORIZED
    ▼
┌─────────────────────────────────────────────────┐
│ Document Retrieval                               │
│ • Query database for document metadata          │
│ • Validate document ownership                   │
│ • Resolve file path                            │
└─────────────────────────────────────────────────┘
    │ ✓ FOUND
    ▼
┌─────────────────────────────────────────────────┐
│ Security Validation                              │
│ • Verify file exists on disk                   │
│ • Check file permissions                        │
│ • Prevent path traversal attacks               │
└─────────────────────────────────────────────────┘
    │ ✓ SAFE
    ▼
┌─────────────────────────────────────────────────┐
│ Serve File                                       │
│ • Set proper Content-Type header               │
│ • Set Content-Disposition: attachment          │
│ • Stream file to browser                        │
│ • Log download event                           │
└─────────────────────────────────────────────────┘
    │ ✓ SUCCESS
    ▼
  FILE DOWNLOADED
```

## Dashboard Statistics Flow

```
Admin visits /admin/kyc/
    │
    ▼
┌─────────────────────────────────────────────────┐
│ Query kyc_documents table                       │
│ • Try query with user_id column                │
│ • Fallback to kyc_request_id if needed         │
│ • Count: pending, approved, rejected, expired  │
└─────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────┐
│ Query seller_kyc table                          │
│ • Count by verification_status                  │
│ • Count: pending, approved, rejected, expired  │
└─────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────┐
│ Aggregate Statistics                            │
│ • Total = kyc_docs + seller_kyc                │
│ • Pending = sum of pending from both           │
│ • Approved = sum of approved from both         │
│ • Rejected = sum of rejected from both         │
│ • Expired = sum of expired from both           │
│ • Verified Users = approved count              │
└─────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────┐
│ Display Dashboard                                │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐            │
│ │ Total   │ │ Pending │ │Approved │            │
│ │   X     │ │   Y     │ │   Z     │            │
│ └─────────┘ └─────────┘ └─────────┘            │
└─────────────────────────────────────────────────┘
```

## Protected Upload Endpoints

```
┌─────────────────────────────────────────────────────┐
│ Virus Scanning Applied To:                          │
├─────────────────────────────────────────────────────┤
│ 1. KYC Documents                                    │
│    • /seller/kyc.php                                │
│    • Identity, Address, Bank verification docs      │
│                                                      │
│ 2. Product Images                                   │
│    • /admin/products/create.php                     │
│    • /seller/products/add.php (if exists)           │
│                                                      │
│ 3. Chat Attachments                                 │
│    • /api/messages/send.php                         │
│    • File sharing in conversations                  │
│                                                      │
│ 4. Media Library                                    │
│    • /admin/media/index.php                         │
│    • General file uploads                           │
└─────────────────────────────────────────────────────┘
```

## Security Threats Blocked

```
┌──────────────────────────────────────────────────┐
│ BLOCKED FILE TYPES                                │
├──────────────────────────────────────────────────┤
│ ❌ Executables: .exe, .bat, .cmd, .com           │
│ ❌ Scripts: .php, .js, .vbs, .sh, .bash          │
│ ❌ System Files: .dll, .sys, .drv               │
│ ❌ Installers: .msi, .deb, .rpm, .pkg           │
│ ❌ Mobile Apps: .apk, .ipa, .app                │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│ BLOCKED CONTENT PATTERNS                          │
├──────────────────────────────────────────────────┤
│ ❌ eval() function calls                         │
│ ❌ system(), exec(), shell_exec()               │
│ ❌ base64_decode() (potential obfuscation)      │
│ ❌ $_GET/$_POST in executable context           │
│ ❌ chmod 777 (permission escalation)            │
│ ❌ Embedded PHP in non-PHP files                │
│ ❌ Null byte injection (\0)                     │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│ ALLOWED FILE TYPES                                │
├──────────────────────────────────────────────────┤
│ ✅ Images: .jpg, .jpeg, .png, .gif, .bmp        │
│ ✅ Documents: .pdf, .doc, .docx                 │
│ ✅ Spreadsheets: .xls, .xlsx                    │
│ ✅ (Context-dependent, configurable)            │
└──────────────────────────────────────────────────┘
```

## Admin Panel UI Updates

```
Before:
┌────────────────────────────────────────────┐
│ KYC Documents List                          │
├────────────────────────────────────────────┤
│ User    | Document  | Status | Actions    │
│ john@ex | ID Card   | Pending| [View]     │  ❌ No download
│ jane@ex | Passport  | Approved| [View]    │  ❌ 404 on view
└────────────────────────────────────────────┘

After:
┌────────────────────────────────────────────┐
│ KYC Documents List                          │
├────────────────────────────────────────────┤
│ User    | Document  | Status | Actions    │
│ john@ex | ID Card   | Pending| [View] [📥]│  ✅ Download works
│ jane@ex | Passport  | Approved| [View] [📥]│ ✅ Secure download
└────────────────────────────────────────────┘

Dashboard Before:
┌────────────────────────────────────────────┐
│ Statistics                                  │
├────────────────────────────────────────────┤
│ Total: 0  Pending: 0  Approved: 0         │  ❌ All zeros
└────────────────────────────────────────────┘

Dashboard After:
┌────────────────────────────────────────────┐
│ Statistics                                  │
├────────────────────────────────────────────┤
│ Total: 47  Pending: 12  Approved: 28      │  ✅ Real data
└────────────────────────────────────────────┘
```

## Error Handling & Logging

```
Upload Attempt
    │
    ├──► Success Path
    │     │
    │     ├─► Log: "[VirusScan] File: doc.pdf | Safe: YES"
    │     ├─► Store file securely
    │     └─► Return success to user
    │
    └──► Blocked Path
          │
          ├─► Log: "[VirusScan] File: malware.exe | Safe: NO"
          ├─► Log: "Threats: dangerous_extension:exe"
          ├─► Delete temporary file
          └─► Return error to user: "File failed security scan"

Download Attempt
    │
    ├──► Success Path
    │     │
    │     ├─► Log: "kyc_document_downloaded by admin_123"
    │     └─► Serve file to browser
    │
    └──► Error Path
          │
          ├─► Not Found: HTTP 404
          ├─► Unauthorized: HTTP 401
          └─► Log error for debugging
```

## Compliance & Audit Trail

```
Every Action is Logged:
┌────────────────────────────────────────────┐
│ Audit Events                                │
├────────────────────────────────────────────┤
│ • File Upload Attempt                      │
│   - User ID, Timestamp, Filename           │
│   - File size, MIME type                   │
│   - Scan result (pass/fail)                │
│                                             │
│ • Document Download                        │
│   - Admin ID, Document ID                  │
│   - Timestamp, IP address                  │
│   - File downloaded                        │
│                                             │
│ • Virus Scan Results                       │
│   - Filename, Scan status                  │
│   - Threats detected (if any)              │
│   - Action taken (allow/block)             │
└────────────────────────────────────────────┘
```

## Testing Checklist

```
✅ Virus Scanner Tests
   ├─ ✓ Blocks .exe files
   ├─ ✓ Blocks .php files  
   ├─ ✓ Blocks eval() content
   ├─ ✓ Blocks empty files
   └─ ✓ Allows clean PDFs

✅ Download Functionality
   ├─ ✓ Download button visible in list
   ├─ ✓ Download button in review page
   ├─ ✓ File downloads successfully
   ├─ ✓ No 404 errors
   └─ ✓ Audit log created

✅ Dashboard Statistics
   ├─ ✓ Displays non-zero counts
   ├─ ✓ Counts from kyc_documents
   ├─ ✓ Counts from seller_kyc
   ├─ ✓ Proper aggregation
   └─ ✓ Error handling works

✅ Security
   ├─ ✓ Admin auth required
   ├─ ✓ CSRF protection
   ├─ ✓ Path traversal prevented
   ├─ ✓ Malicious files blocked
   └─ ✓ All uploads scanned
```
