<?php
/**
 * Vendor Management - Admin Module
 * Marketplace & Vendor Management System
 */

require_once __DIR__ . '/../../includes/init.php';

// Initialize PDO global variable for this module
$pdo = db();

// For testing, bypass admin check 
if (!defined('ADMIN_BYPASS') || !ADMIN_BYPASS) {
    RoleMiddleware::requireAdmin();
}

$page_title = 'Vendor Management';
$action = $_GET['action'] ?? 'list';
$vendor_id = $_GET['id'] ?? null;

// Get filter parameters
$status_filter = $_GET['status'] ?? '';
$kyc_filter = $_GET['kyc'] ?? '';
$search = $_GET['search'] ?? '';
$sort_by = $_GET['sort'] ?? 'created_at';
$sort_order = $_GET['order'] ?? 'DESC';
$page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
$per_page = 20;
$offset = ($page - 1) * $per_page;

// Handle vendor actions
if ($_POST && isset($_POST['action'])) {
    validateCsrfAndRateLimit();
    
    try {
        $admin_id = Session::getUserId();
        
        switch ($_POST['action']) {
            case 'approve_vendor':
                Database::query(
                    "UPDATE vendors SET status = 'approved', approved_by = ?, approved_at = NOW() WHERE id = ?",
                    [$admin_id, $_POST['vendor_id']]
                );
                
                // Log audit
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, old_value, new_value, reason, ip_address) 
                     VALUES (?, ?, 'vendor_approved', 'status_change', 'pending', 'approved', ?, ?)",
                    [$_POST['vendor_id'], $admin_id, $_POST['reason'] ?? 'Approved by admin', $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Vendor approved successfully.';
                logAdminActivity($admin_id, 'vendor_approved', 'vendor', $_POST['vendor_id']);
                
                // Send notification (implementation in notification system)
                sendVendorStatusNotification($_POST['vendor_id'], 'approved', $_POST['reason'] ?? '');
                break;
                
            case 'reject_vendor':
                Database::query(
                    "UPDATE vendors SET status = 'rejected' WHERE id = ?",
                    [$_POST['vendor_id']]
                );
                
                // Log audit
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, old_value, new_value, reason, ip_address) 
                     VALUES (?, ?, 'vendor_rejected', 'status_change', 'pending', 'rejected', ?, ?)",
                    [$_POST['vendor_id'], $admin_id, $_POST['reason'] ?? 'Rejected by admin', $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Vendor rejected.';
                logAdminActivity($admin_id, 'vendor_rejected', 'vendor', $_POST['vendor_id']);
                
                // Send notification
                sendVendorStatusNotification($_POST['vendor_id'], 'rejected', $_POST['reason'] ?? '');
                break;
                
            case 'suspend_vendor':
                Database::query(
                    "UPDATE vendors SET status = 'suspended', suspended_by = ?, suspended_at = NOW(), suspension_reason = ? WHERE id = ?",
                    [$admin_id, $_POST['reason'] ?? '', $_POST['vendor_id']]
                );
                
                // Log audit
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, old_value, new_value, reason, ip_address) 
                     VALUES (?, ?, 'vendor_suspended', 'account_suspension', 'approved', 'suspended', ?, ?)",
                    [$_POST['vendor_id'], $admin_id, $_POST['reason'] ?? 'Suspended by admin', $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Vendor suspended.';
                logAdminActivity($admin_id, 'vendor_suspended', 'vendor', $_POST['vendor_id']);
                
                // Send notification
                sendVendorStatusNotification($_POST['vendor_id'], 'suspended', $_POST['reason'] ?? '');
                break;
                
            case 'bulk_action':
                $vendor_ids = $_POST['vendor_ids'] ?? [];
                $bulk_action = $_POST['bulk_action_type'] ?? '';
                
                if (empty($vendor_ids) || empty($bulk_action)) {
                    throw new Exception('Invalid bulk action parameters');
                }
                
                foreach ($vendor_ids as $vid) {
                    switch ($bulk_action) {
                        case 'approve':
                            Database::query(
                                "UPDATE vendors SET status = 'approved', approved_by = ?, approved_at = NOW() WHERE id = ?",
                                [$admin_id, $vid]
                            );
                            Database::query(
                                "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, new_value, reason, ip_address) 
                                 VALUES (?, ?, 'bulk_approved', 'bulk_action', 'approved', 'Bulk approval', ?)",
                                [$vid, $admin_id, $_SERVER['REMOTE_ADDR'] ?? '']
                            );
                            sendVendorStatusNotification($vid, 'approved', 'Bulk approval');
                            break;
                            
                        case 'reject':
                            Database::query("UPDATE vendors SET status = 'rejected' WHERE id = ?", [$vid]);
                            Database::query(
                                "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, new_value, reason, ip_address) 
                                 VALUES (?, ?, 'bulk_rejected', 'bulk_action', 'rejected', 'Bulk rejection', ?)",
                                [$vid, $admin_id, $_SERVER['REMOTE_ADDR'] ?? '']
                            );
                            sendVendorStatusNotification($vid, 'rejected', 'Bulk rejection');
                            break;
                            
                        case 'suspend':
                            Database::query(
                                "UPDATE vendors SET status = 'suspended', suspended_by = ?, suspended_at = NOW() WHERE id = ?",
                                [$admin_id, $vid]
                            );
                            Database::query(
                                "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, new_value, reason, ip_address) 
                                 VALUES (?, ?, 'bulk_suspended', 'bulk_action', 'suspended', 'Bulk suspension', ?)",
                                [$vid, $admin_id, $_SERVER['REMOTE_ADDR'] ?? '']
                            );
                            sendVendorStatusNotification($vid, 'suspended', 'Bulk suspension');
                            break;
                    }
                }
                
                $_SESSION['success_message'] = count($vendor_ids) . ' vendors updated successfully.';
                break;
        }
    } catch (Exception $e) {
        $_SESSION['error_message'] = $e->getMessage();
        Logger::error("Vendor management error: " . $e->getMessage());
    }
    
    header('Location: /admin/vendors/');
    exit;
}

// Helper function to send vendor notifications
function sendVendorStatusNotification($vendor_id, $status, $reason = '') {
    try {
        $vendor = Database::query("SELECT v.*, u.email FROM vendors v JOIN users u ON v.user_id = u.id WHERE v.id = ?", [$vendor_id])->fetch();
        if ($vendor) {
            // Email notification
            $subject = "Vendor Application " . ucfirst($status);
            $message = "Your vendor application has been {$status}.";
            if ($reason) {
                $message .= "\n\nReason: {$reason}";
            }
            
            // Use email system if available
            if (function_exists('sendEmail')) {
                sendEmail($vendor['email'], $subject, $message);
            }
            
            // In-app notification
            if (function_exists('createNotification')) {
                createNotification($vendor['user_id'], $subject, $message, 'vendor_status');
            }
        }
    } catch (Exception $e) {
        Logger::error("Failed to send vendor notification: " . $e->getMessage());
    }
}

// Build query with filters
$where_conditions = ["1=1"];
$params = [];

if ($status_filter) {
    $where_conditions[] = "v.status = ?";
    $params[] = $status_filter;
}

if ($kyc_filter) {
    if ($kyc_filter === 'not_submitted') {
        // Filter for vendors with no KYC submission (NULL seller_kyc records)
        $where_conditions[] = "sk.id IS NULL";
    } else {
        $where_conditions[] = "sk.verification_status = ?";
        $params[] = $kyc_filter;
    }
}

if ($search) {
    $where_conditions[] = "(v.business_name LIKE ? OR u.username LIKE ? OR u.email LIKE ?)";
    $search_param = "%{$search}%";
    $params[] = $search_param;
    $params[] = $search_param;
    $params[] = $search_param;
}

$where_clause = implode(" AND ", $where_conditions);

// Validate sort column
$allowed_sorts = ['created_at', 'business_name', 'status', 'total_sales', 'total_orders'];
if (!in_array($sort_by, $allowed_sorts)) {
    $sort_by = 'created_at';
}

$sort_order = strtoupper($sort_order) === 'ASC' ? 'ASC' : 'DESC';

// Get total count for pagination
try {
    $total_count = Database::query(
        "SELECT COUNT(*) as cnt FROM vendors v LEFT JOIN users u ON v.user_id = u.id WHERE {$where_clause}",
        $params
    )->fetch()['cnt'];
    
    $total_pages = ceil($total_count / $per_page);
} catch (Exception $e) {
    $total_count = 0;
    $total_pages = 1;
}

// Get vendors with statistics
try {
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
    
    $vendors = Database::query($query, array_merge($params, [$per_page, $offset]))->fetchAll();
    
    // Get overall statistics (without filters)
    $stats_query = "SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN v.status = 'pending' THEN 1 ELSE 0 END) as pending,
        SUM(CASE WHEN v.status = 'approved' THEN 1 ELSE 0 END) as approved,
        SUM(CASE WHEN v.status = 'rejected' THEN 1 ELSE 0 END) as rejected,
        SUM(CASE WHEN v.status = 'suspended' THEN 1 ELSE 0 END) as suspended,
        SUM(CASE WHEN sk.verification_status IN ('pending', 'in_review') THEN 1 ELSE 0 END) as pending_kyc
    FROM vendors v
    LEFT JOIN seller_kyc sk ON v.id = sk.vendor_id";
    
    $stats = Database::query($stats_query)->fetch();
} catch (Exception $e) {
    $vendors = [];
    $stats = ['total' => 0, 'pending' => 0, 'approved' => 0, 'rejected' => 0, 'suspended' => 0, 'pending_kyc' => 0];
    Logger::error("Vendor query error: " . $e->getMessage());
}
?><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $page_title; ?> - Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .admin-header {
            background: linear-gradient(135deg, #2c3e50, #34495e);
            color: white;
            padding: 1rem 0;
        }
        .stats-card {
            background: white;
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #3498db;
        }
        .stats-card.success { border-left-color: #27ae60; }
        .stats-card.warning { border-left-color: #f39c12; }
        .stats-card.danger { border-left-color: #e74c3c; }
        .vendor-logo {
            width: 50px;
            height: 50px;
            object-fit: cover;
            border-radius: 8px;
        }
        .status-badge {
            font-size: 0.8rem;
            padding: 0.25rem 0.5rem;
        }
    </style>
</head>
<body>
    <!-- Admin Header -->
    <div class="admin-header">
        <div class="container-fluid">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="h3 mb-0">
                        <i class="fas fa-store me-2"></i>
                        <?php echo $page_title; ?>
                    </h1>
                    <small class="text-white-50">Manage marketplace vendors and partners</small>
                </div>
                <div class="col-md-6 text-end">
                    <a href="/admin/" class="btn btn-outline-light">
                        <i class="fas fa-arrow-left me-1"></i> Back to Dashboard
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid py-4">
        <!-- Success/Error Messages -->
        <?php if (isset($_SESSION['success_message'])): ?>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="fas fa-check-circle me-2"></i>
            <?php echo htmlspecialchars($_SESSION['success_message']); unset($_SESSION['success_message']); ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <?php endif; ?>
        
        <?php if (isset($_SESSION['error_message'])): ?>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="fas fa-exclamation-circle me-2"></i>
            <?php echo htmlspecialchars($_SESSION['error_message']); unset($_SESSION['error_message']); ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <?php endif; ?>

        <!-- Quick Actions Bar -->
        <div class="row mb-3">
            <div class="col-md-6">
                <a href="/admin/vendors/applications.php" class="btn btn-warning">
                    <i class="fas fa-clock me-1"></i> Pending Applications (<?php echo $stats['pending']; ?>)
                </a>
                <a href="/admin/vendors/index.php?kyc=pending" class="btn btn-info">
                    <i class="fas fa-id-card me-1"></i> Pending KYC (<?php echo $stats['pending_kyc']; ?>)
                </a>
            </div>
            <div class="col-md-6 text-end">
                <a href="/api/admin/vendors/export.php?<?php echo http_build_query($_GET); ?>" class="btn btn-success">
                    <i class="fas fa-download me-1"></i> Export CSV
                </a>
            </div>
        </div>

        <!-- Vendor Statistics -->
        <div class="row mb-4">
            <div class="col-lg-2 col-md-4 mb-3">
                <div class="stats-card">
                    <div class="h4 mb-1"><?php echo number_format($stats['total']); ?></div>
                    <div class="text-muted small">Total Vendors</div>
                </div>
            </div>
            <div class="col-lg-2 col-md-4 mb-3">
                <div class="stats-card warning">
                    <div class="h4 mb-1 text-warning"><?php echo number_format($stats['pending']); ?></div>
                    <div class="text-muted small">Pending Approval</div>
                </div>
            </div>
            <div class="col-lg-2 col-md-4 mb-3">
                <div class="stats-card success">
                    <div class="h4 mb-1 text-success"><?php echo number_format($stats['approved']); ?></div>
                    <div class="text-muted small">Approved</div>
                </div>
            </div>
            <div class="col-lg-2 col-md-4 mb-3">
                <div class="stats-card danger">
                    <div class="h4 mb-1 text-danger"><?php echo number_format($stats['suspended']); ?></div>
                    <div class="text-muted small">Suspended</div>
                </div>
            </div>
            <div class="col-lg-2 col-md-4 mb-3">
                <div class="stats-card">
                    <div class="h4 mb-1"><?php echo number_format($stats['rejected']); ?></div>
                    <div class="text-muted small">Rejected</div>
                </div>
            </div>
            <div class="col-lg-2 col-md-4 mb-3">
                <div class="stats-card warning">
                    <div class="h4 mb-1 text-warning"><?php echo number_format($stats['pending_kyc']); ?></div>
                    <div class="text-muted small">Pending KYC</div>
                </div>
            </div>
        </div>

        <!-- Search and Filter Section -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="GET" action="/admin/vendors/" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">Search</label>
                        <input type="text" name="search" class="form-control" placeholder="Business name, email..." 
                               value="<?php echo htmlspecialchars($search); ?>" aria-label="Search vendors">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-select" aria-label="Filter by status">
                            <option value="">All Statuses</option>
                            <option value="pending" <?php echo $status_filter === 'pending' ? 'selected' : ''; ?>>Pending</option>
                            <option value="approved" <?php echo $status_filter === 'approved' ? 'selected' : ''; ?>>Approved</option>
                            <option value="suspended" <?php echo $status_filter === 'suspended' ? 'selected' : ''; ?>>Suspended</option>
                            <option value="rejected" <?php echo $status_filter === 'rejected' ? 'selected' : ''; ?>>Rejected</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">KYC Status</label>
                        <select name="kyc" class="form-select" aria-label="Filter by KYC status">
                            <option value="">All KYC</option>
                            <option value="not_submitted" <?php echo $kyc_filter === 'not_submitted' ? 'selected' : ''; ?>>Not Submitted</option>
                            <option value="pending" <?php echo $kyc_filter === 'pending' ? 'selected' : ''; ?>>Pending</option>
                            <option value="in_review" <?php echo $kyc_filter === 'in_review' ? 'selected' : ''; ?>>In Review</option>
                            <option value="approved" <?php echo $kyc_filter === 'approved' ? 'selected' : ''; ?>>Approved</option>
                            <option value="rejected" <?php echo $kyc_filter === 'rejected' ? 'selected' : ''; ?>>Rejected</option>
                            <option value="requires_resubmission" <?php echo $kyc_filter === 'requires_resubmission' ? 'selected' : ''; ?>>Requires Resubmission</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Sort By</label>
                        <select name="sort" class="form-select" aria-label="Sort by">
                            <option value="created_at" <?php echo $sort_by === 'created_at' ? 'selected' : ''; ?>>Registration Date</option>
                            <option value="business_name" <?php echo $sort_by === 'business_name' ? 'selected' : ''; ?>>Business Name</option>
                            <option value="total_sales" <?php echo $sort_by === 'total_sales' ? 'selected' : ''; ?>>Total Sales</option>
                            <option value="total_orders" <?php echo $sort_by === 'total_orders' ? 'selected' : ''; ?>>Total Orders</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Order</label>
                        <select name="order" class="form-select" aria-label="Sort order">
                            <option value="DESC" <?php echo $sort_order === 'DESC' ? 'selected' : ''; ?>>Descending</option>
                            <option value="ASC" <?php echo $sort_order === 'ASC' ? 'selected' : ''; ?>>Ascending</option>
                        </select>
                    </div>
                    <div class="col-md-1 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Bulk Actions Bar -->
        <div class="card mb-3">
            <div class="card-body">
                <form method="POST" id="bulkActionsForm">
                    <?php echo csrfTokenInput(); ?>
                    <input type="hidden" name="action" value="bulk_action">
                    <div class="row align-items-center">
                        <div class="col-md-3">
                            <select name="bulk_action_type" class="form-select" aria-label="Bulk action type">
                                <option value="">Select Bulk Action</option>
                                <option value="approve">Approve Selected</option>
                                <option value="reject">Reject Selected</option>
                                <option value="suspend">Suspend Selected</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-primary" onclick="return confirmBulkAction()">
                                <i class="fas fa-check-double me-1"></i> Apply
                            </button>
                        </div>
                        <div class="col-md-7 text-end">
                            <small class="text-muted">
                                <span id="selectedCount">0</span> vendor(s) selected
                            </small>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Vendors Table -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">Vendor Applications & Management</h5>
                <div>
                    <input type="checkbox" id="selectAll" class="form-check-input me-2">
                    <label for="selectAll" class="form-check-label small">Select All</label>
                </div>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th width="40"><input type="checkbox" id="selectAllTable" class="form-check-input"></th>
                                <th>Vendor</th>
                                <th>Business Info</th>
                                <th>Performance</th>
                                <th>Status</th>
                                <th>KYC</th>
                                <th>Joined</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (empty($vendors)): ?>
                            <tr>
                                <td colspan="8" class="text-center py-4">
                                    <i class="fas fa-store fa-3x text-muted mb-3"></i>
                                    <div class="h5 text-muted">No vendors found</div>
                                    <?php if ($search || $status_filter || $kyc_filter): ?>
                                    <a href="/admin/vendors/" class="btn btn-sm btn-primary mt-2">Clear Filters</a>
                                    <?php endif; ?>
                                </td>
                            </tr>
                            <?php else: ?>
                            <?php foreach ($vendors as $vendor): ?>
                            <tr>
                                <td>
                                    <input type="checkbox" name="vendor_ids[]" value="<?php echo $vendor['id']; ?>" 
                                           class="form-check-input vendor-checkbox" form="bulkActionsForm">
                                </td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <?php if (!empty($vendor['logo_url'])): ?>
                                        <img src="<?php echo htmlspecialchars($vendor['logo_url']); ?>" 
                                             class="vendor-logo me-3" alt="Logo">
                                        <?php else: ?>
                                        <div class="vendor-logo me-3 bg-light d-flex align-items-center justify-content-center">
                                            <i class="fas fa-store text-muted"></i>
                                        </div>
                                        <?php endif; ?>
                                        <div>
                                            <div class="fw-bold">
                                                <a href="/admin/vendors/show.php?id=<?php echo $vendor['id']; ?>">
                                                    <?php echo htmlspecialchars($vendor['username']); ?>
                                                </a>
                                            </div>
                                            <small class="text-muted"><?php echo htmlspecialchars($vendor['email']); ?></small>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="fw-bold"><?php echo htmlspecialchars($vendor['business_name'] ?? 'N/A'); ?></div>
                                    <small class="text-muted"><?php echo ucfirst($vendor['business_type'] ?? 'individual'); ?></small>
                                    <?php if (!empty($vendor['category'])): ?>
                                    <div><span class="badge bg-secondary"><?php echo htmlspecialchars($vendor['category']); ?></span></div>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <div><strong><?php echo number_format($vendor['product_count']); ?></strong> products</div>
                                    <div><strong><?php echo number_format($vendor['order_count']); ?></strong> orders</div>
                                    <div><strong>$<?php echo number_format($vendor['total_sales'], 2); ?></strong> sales</div>
                                </td>
                                <td>
                                    <?php
                                    $statusClass = [
                                        'pending' => 'warning',
                                        'approved' => 'success',
                                        'rejected' => 'danger',
                                        'suspended' => 'secondary'
                                    ][$vendor['status']] ?? 'secondary';
                                    ?>
                                    <span class="badge bg-<?php echo $statusClass; ?> status-badge">
                                        <?php echo ucfirst($vendor['status']); ?>
                                    </span>
                                </td>
                                <td>
                                    <?php
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
                                    ?>
                                    <span class="badge bg-<?php echo $kycStatusClass; ?> status-badge">
                                        <?php echo $kycStatusDisplay; ?>
                                    </span>
                                </td>
                                <td>
                                    <?php echo date('M d, Y', strtotime($vendor['user_created'])); ?>
                                </td>
                                <td>
                                    <div class="btn-group">
                                        <a href="/admin/vendors/show.php?id=<?php echo $vendor['id']; ?>" 
                                           class="btn btn-sm btn-outline-primary" title="View Profile">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <?php if ($vendor['status'] === 'pending'): ?>
                                        <button type="button" class="btn btn-sm btn-success" 
                                                onclick="approveVendor(<?php echo $vendor['id']; ?>)" title="Approve">
                                            <i class="fas fa-check"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-danger" 
                                                onclick="rejectVendor(<?php echo $vendor['id']; ?>)" title="Reject">
                                            <i class="fas fa-times"></i>
                                        </button>
                                        <?php elseif ($vendor['status'] === 'approved'): ?>
                                        <button type="button" class="btn btn-sm btn-warning" 
                                                onclick="suspendVendor(<?php echo $vendor['id']; ?>)" title="Suspend">
                                            <i class="fas fa-pause"></i>
                                        </button>
                                        <?php endif; ?>
                                        <a href="/admin/vendors/edit.php?id=<?php echo $vendor['id']; ?>" 
                                           class="btn btn-sm btn-outline-secondary" title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <a href="/admin/vendors/kyc.php?id=<?php echo $vendor['id']; ?>" 
                                           class="btn btn-sm btn-outline-info" title="View KYC">
                                            <i class="fas fa-id-card"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Pagination -->
            <?php if ($total_pages > 1): ?>
            <div class="card-footer">
                <nav aria-label="Vendor pagination">
                    <ul class="pagination mb-0 justify-content-center">
                        <?php
                        $query_params = $_GET;
                        for ($i = 1; $i <= $total_pages; $i++):
                            $query_params['page'] = $i;
                            $is_active = $i === $page;
                        ?>
                        <li class="page-item <?php echo $is_active ? 'active' : ''; ?>">
                            <a class="page-link" href="?<?php echo http_build_query($query_params); ?>">
                                <?php echo $i; ?>
                            </a>
                        </li>
                        <?php endfor; ?>
                    </ul>
                </nav>
                <div class="text-center mt-2">
                    <small class="text-muted">
                        Showing <?php echo min($offset + 1, $total_count); ?> - 
                        <?php echo min($offset + $per_page, $total_count); ?> of 
                        <?php echo number_format($total_count); ?> vendors
                    </small>
                </div>
            </div>
            <?php endif; ?>
        </div>
    </div>

    <!-- Action Modals -->
    <div class="modal fade" id="actionModal" tabindex="-1" aria-labelledby="actionModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST" id="actionForm">
                    <?php echo csrfTokenInput(); ?>
                    <input type="hidden" name="action" id="modalAction">
                    <input type="hidden" name="vendor_id" id="modalVendorId">
                    <div class="modal-header">
                        <h5 class="modal-title" id="actionModalLabel">Confirm Action</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p id="modalMessage"></p>
                        <div class="mb-3">
                            <label for="reason" class="form-label">Reason (Optional)</label>
                            <textarea class="form-control" id="reason" name="reason" rows="3" 
                                      placeholder="Provide a reason for this action..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary" id="modalConfirmBtn">Confirm</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Checkbox selection
        document.getElementById('selectAll')?.addEventListener('change', function() {
            const checkboxes = document.querySelectorAll('.vendor-checkbox');
            checkboxes.forEach(cb => cb.checked = this.checked);
            updateSelectedCount();
        });
        
        document.getElementById('selectAllTable')?.addEventListener('change', function() {
            const checkboxes = document.querySelectorAll('.vendor-checkbox');
            checkboxes.forEach(cb => cb.checked = this.checked);
            updateSelectedCount();
        });
        
        document.querySelectorAll('.vendor-checkbox').forEach(cb => {
            cb.addEventListener('change', updateSelectedCount);
        });
        
        function updateSelectedCount() {
            const count = document.querySelectorAll('.vendor-checkbox:checked').length;
            document.getElementById('selectedCount').textContent = count;
        }
        
        function confirmBulkAction() {
            const action = document.querySelector('[name="bulk_action_type"]').value;
            const count = document.querySelectorAll('.vendor-checkbox:checked').length;
            
            if (!action) {
                alert('Please select a bulk action');
                return false;
            }
            
            if (count === 0) {
                alert('Please select at least one vendor');
                return false;
            }
            
            return confirm(`Are you sure you want to ${action} ${count} vendor(s)?`);
        }
        
        // Modal action functions
        const actionModal = new bootstrap.Modal(document.getElementById('actionModal'));
        
        function approveVendor(id) {
            document.getElementById('modalAction').value = 'approve_vendor';
            document.getElementById('modalVendorId').value = id;
            document.getElementById('actionModalLabel').textContent = 'Approve Vendor';
            document.getElementById('modalMessage').textContent = 'Are you sure you want to approve this vendor?';
            document.getElementById('modalConfirmBtn').className = 'btn btn-success';
            actionModal.show();
        }
        
        function rejectVendor(id) {
            document.getElementById('modalAction').value = 'reject_vendor';
            document.getElementById('modalVendorId').value = id;
            document.getElementById('actionModalLabel').textContent = 'Reject Vendor';
            document.getElementById('modalMessage').textContent = 'Are you sure you want to reject this vendor application?';
            document.getElementById('modalConfirmBtn').className = 'btn btn-danger';
            actionModal.show();
        }
        
        function suspendVendor(id) {
            document.getElementById('modalAction').value = 'suspend_vendor';
            document.getElementById('modalVendorId').value = id;
            document.getElementById('actionModalLabel').textContent = 'Suspend Vendor';
            document.getElementById('modalMessage').textContent = 'Are you sure you want to suspend this vendor? They will not be able to sell products.';
            document.getElementById('modalConfirmBtn').className = 'btn btn-warning';
            actionModal.show();
        }
    </script>

</body>
</html>