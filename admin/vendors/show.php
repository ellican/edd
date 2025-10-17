<?php
/**
 * Vendor Profile View
 * Complete vendor profile with products, transactions, payout history, and activity logs
 */

require_once __DIR__ . '/../../includes/init.php';

// Initialize PDO global variable for this module
$pdo = db();

// For testing, bypass admin check 
if (!defined('ADMIN_BYPASS') || !ADMIN_BYPASS) {
    RoleMiddleware::requireAdmin();
}

$vendor_id = $_GET['id'] ?? 0;

if (!$vendor_id) {
    $_SESSION['error_message'] = 'Invalid vendor ID';
    header('Location: /admin/vendors/');
    exit;
}

// Get vendor details
try {
    $vendor = Database::query(
        "SELECT v.*, u.username, u.email, u.created_at as user_created, u.status as user_status,
                approver.username as approved_by_name,
                suspender.username as suspended_by_name
         FROM vendors v
         LEFT JOIN users u ON v.user_id = u.id
         LEFT JOIN users approver ON v.approved_by = approver.id
         LEFT JOIN users suspender ON v.suspended_by = suspender.id
         WHERE v.id = ?",
        [$vendor_id]
    )->fetch();
    
    if (!$vendor) {
        $_SESSION['error_message'] = 'Vendor not found';
        header('Location: /admin/vendors/');
        exit;
    }
} catch (Exception $e) {
    $_SESSION['error_message'] = 'Error loading vendor: ' . $e->getMessage();
    header('Location: /admin/vendors/');
    exit;
}

// Get vendor statistics
try {
    // Get product count (you'll need to adjust table name based on your schema)
    $product_stats = Database::query(
        "SELECT COUNT(*) as total FROM products WHERE seller_id = ?",
        [$vendor['user_id']]
    )->fetch();
    
    // Get order statistics
    $order_stats = Database::query(
        "SELECT COUNT(*) as total_orders, COALESCE(SUM(total_amount), 0) as total_sales 
         FROM orders WHERE seller_id = ?",
        [$vendor['user_id']]
    )->fetch();
    
    // Get KYC documents
    $kyc_docs = Database::query(
        "SELECT * FROM vendor_kyc WHERE vendor_id = ? ORDER BY uploaded_at DESC",
        [$vendor_id]
    )->fetchAll();
    
    // Get activity logs
    $activity_logs = Database::query(
        "SELECT * FROM vendor_activity_logs WHERE vendor_id = ? ORDER BY created_at DESC LIMIT 20",
        [$vendor_id]
    )->fetchAll();
    
    // Get audit logs
    $audit_logs = Database::query(
        "SELECT val.*, u.username as admin_username
         FROM vendor_audit_logs val
         LEFT JOIN users u ON val.admin_id = u.id
         WHERE val.vendor_id = ?
         ORDER BY val.created_at DESC
         LIMIT 50",
        [$vendor_id]
    )->fetchAll();
} catch (Exception $e) {
    $product_stats = ['total' => 0];
    $order_stats = ['total_orders' => 0, 'total_sales' => 0];
    $kyc_docs = [];
    $activity_logs = [];
    $audit_logs = [];
}

$page_title = 'Vendor Profile: ' . htmlspecialchars($vendor['business_name']);
?>
<!DOCTYPE html>
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
        .profile-header {
            background: white;
            border-radius: 8px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .vendor-logo-large {
            width: 120px;
            height: 120px;
            object-fit: cover;
            border-radius: 12px;
        }
        .stat-card {
            background: white;
            border-radius: 8px;
            padding: 1.5rem;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .tab-content {
            background: white;
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .activity-item {
            border-left: 3px solid #3498db;
            padding-left: 1rem;
            margin-bottom: 1rem;
        }
        .audit-item {
            border-left: 3px solid #e74c3c;
            padding-left: 1rem;
            margin-bottom: 1rem;
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
                        <i class="fas fa-user-tie me-2"></i>
                        Vendor Profile
                    </h1>
                </div>
                <div class="col-md-6 text-end">
                    <a href="/admin/vendors/" class="btn btn-outline-light">
                        <i class="fas fa-arrow-left me-1"></i> Back to Vendors
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid py-4">
        <!-- Vendor Profile Header -->
        <div class="profile-header">
            <div class="row">
                <div class="col-md-8">
                    <div class="d-flex align-items-start">
                        <?php if (!empty($vendor['logo_url'])): ?>
                        <img src="<?php echo htmlspecialchars($vendor['logo_url']); ?>" 
                             class="vendor-logo-large me-4" alt="Logo">
                        <?php else: ?>
                        <div class="vendor-logo-large me-4 bg-light d-flex align-items-center justify-content-center">
                            <i class="fas fa-store fa-4x text-muted"></i>
                        </div>
                        <?php endif; ?>
                        <div class="flex-grow-1">
                            <h2><?php echo htmlspecialchars($vendor['business_name']); ?></h2>
                            <p class="text-muted mb-2">
                                <i class="fas fa-user me-1"></i> <?php echo htmlspecialchars($vendor['username']); ?>
                                <span class="mx-2">|</span>
                                <i class="fas fa-envelope me-1"></i> <?php echo htmlspecialchars($vendor['email']); ?>
                            </p>
                            <div class="mb-2">
                                <?php
                                $statusClass = [
                                    'pending' => 'warning',
                                    'approved' => 'success',
                                    'rejected' => 'danger',
                                    'suspended' => 'secondary'
                                ][$vendor['status']] ?? 'secondary';
                                ?>
                                <span class="badge bg-<?php echo $statusClass; ?> me-2">
                                    <?php echo ucfirst($vendor['status']); ?>
                                </span>
                                
                                <?php
                                $kycClass = [
                                    'not_submitted' => 'secondary',
                                    'pending' => 'warning',
                                    'in_review' => 'info',
                                    'approved' => 'success',
                                    'rejected' => 'danger'
                                ][$vendor['kyc_status'] ?? 'not_submitted'] ?? 'secondary';
                                ?>
                                <span class="badge bg-<?php echo $kycClass; ?>">
                                    KYC: <?php echo ucfirst(str_replace('_', ' ', $vendor['kyc_status'] ?? 'Not Submitted')); ?>
                                </span>
                                
                                <span class="badge bg-info ms-2">
                                    <?php echo ucfirst($vendor['business_type']); ?>
                                </span>
                            </div>
                            <div class="text-muted">
                                <small>
                                    <i class="fas fa-calendar me-1"></i> 
                                    Joined <?php echo date('F d, Y', strtotime($vendor['user_created'])); ?>
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 text-end">
                    <div class="d-grid gap-2">
                        <a href="/admin/vendors/edit.php?id=<?php echo $vendor_id; ?>" class="btn btn-primary">
                            <i class="fas fa-edit me-2"></i> Edit Profile
                        </a>
                        <a href="/admin/vendors/kyc.php?id=<?php echo $vendor_id; ?>" class="btn btn-info">
                            <i class="fas fa-id-card me-2"></i> Manage KYC
                        </a>
                        <?php if ($vendor['status'] === 'approved'): ?>
                        <button type="button" class="btn btn-warning" onclick="suspendVendor()">
                            <i class="fas fa-pause me-2"></i> Suspend Account
                        </button>
                        <?php elseif ($vendor['status'] === 'suspended'): ?>
                        <button type="button" class="btn btn-success" onclick="reactivateVendor()">
                            <i class="fas fa-play me-2"></i> Reactivate Account
                        </button>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="h2 text-primary"><?php echo number_format($product_stats['total']); ?></div>
                    <div class="text-muted">Total Products</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="h2 text-success"><?php echo number_format($order_stats['total_orders']); ?></div>
                    <div class="text-muted">Total Orders</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="h2 text-info">$<?php echo number_format($order_stats['total_sales'], 2); ?></div>
                    <div class="text-muted">Total Sales</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="h2 text-warning"><?php echo count($kyc_docs); ?></div>
                    <div class="text-muted">KYC Documents</div>
                </div>
            </div>
        </div>

        <!-- Tabs -->
        <ul class="nav nav-tabs mb-3" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="details-tab" data-bs-toggle="tab" 
                        data-bs-target="#details" type="button" role="tab">
                    <i class="fas fa-info-circle me-1"></i> Business Details
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="products-tab" data-bs-toggle="tab" 
                        data-bs-target="#products" type="button" role="tab">
                    <i class="fas fa-box me-1"></i> Products
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="transactions-tab" data-bs-toggle="tab" 
                        data-bs-target="#transactions" type="button" role="tab">
                    <i class="fas fa-shopping-cart me-1"></i> Transactions
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="activity-tab" data-bs-toggle="tab" 
                        data-bs-target="#activity" type="button" role="tab">
                    <i class="fas fa-chart-line me-1"></i> Activity Log
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="audit-tab" data-bs-toggle="tab" 
                        data-bs-target="#audit" type="button" role="tab">
                    <i class="fas fa-clipboard-list me-1"></i> Audit Log
                </button>
            </li>
        </ul>

        <div class="tab-content">
            <!-- Business Details Tab -->
            <div class="tab-pane fade show active" id="details" role="tabpanel">
                <div class="row">
                    <div class="col-md-6">
                        <h5 class="mb-3">Business Information</h5>
                        <table class="table">
                            <tr>
                                <th width="40%">Business Name:</th>
                                <td><?php echo htmlspecialchars($vendor['business_name']); ?></td>
                            </tr>
                            <tr>
                                <th>Business Type:</th>
                                <td><?php echo ucfirst($vendor['business_type']); ?></td>
                            </tr>
                            <tr>
                                <th>Business Email:</th>
                                <td><?php echo htmlspecialchars($vendor['business_email'] ?? 'N/A'); ?></td>
                            </tr>
                            <tr>
                                <th>Business Phone:</th>
                                <td><?php echo htmlspecialchars($vendor['business_phone'] ?? 'N/A'); ?></td>
                            </tr>
                            <tr>
                                <th>Tax ID:</th>
                                <td><?php echo htmlspecialchars($vendor['tax_id'] ?? 'N/A'); ?></td>
                            </tr>
                            <tr>
                                <th>Website:</th>
                                <td>
                                    <?php if (!empty($vendor['website'])): ?>
                                    <a href="<?php echo htmlspecialchars($vendor['website']); ?>" target="_blank" rel="noopener">
                                        <?php echo htmlspecialchars($vendor['website']); ?>
                                    </a>
                                    <?php else: ?>
                                    N/A
                                    <?php endif; ?>
                                </td>
                            </tr>
                            <tr>
                                <th>Category:</th>
                                <td><?php echo htmlspecialchars($vendor['category'] ?? 'N/A'); ?></td>
                            </tr>
                            <tr>
                                <th>Commission Rate:</th>
                                <td><?php echo number_format($vendor['commission_rate'], 2); ?>%</td>
                            </tr>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <h5 class="mb-3">Account Information</h5>
                        <table class="table">
                            <tr>
                                <th width="40%">Account Status:</th>
                                <td><span class="badge bg-<?php echo $statusClass; ?>"><?php echo ucfirst($vendor['status']); ?></span></td>
                            </tr>
                            <tr>
                                <th>User Status:</th>
                                <td><?php echo ucfirst($vendor['user_status']); ?></td>
                            </tr>
                            <?php if ($vendor['approved_at']): ?>
                            <tr>
                                <th>Approved:</th>
                                <td>
                                    <?php echo date('M d, Y H:i', strtotime($vendor['approved_at'])); ?>
                                    <?php if ($vendor['approved_by_name']): ?>
                                    <br><small class="text-muted">by <?php echo htmlspecialchars($vendor['approved_by_name']); ?></small>
                                    <?php endif; ?>
                                </td>
                            </tr>
                            <?php endif; ?>
                            <?php if ($vendor['status'] === 'suspended' && $vendor['suspended_at']): ?>
                            <tr>
                                <th>Suspended:</th>
                                <td>
                                    <?php echo date('M d, Y H:i', strtotime($vendor['suspended_at'])); ?>
                                    <?php if ($vendor['suspended_by_name']): ?>
                                    <br><small class="text-muted">by <?php echo htmlspecialchars($vendor['suspended_by_name']); ?></small>
                                    <?php endif; ?>
                                </td>
                            </tr>
                            <?php if (!empty($vendor['suspension_reason'])): ?>
                            <tr>
                                <th>Suspension Reason:</th>
                                <td><?php echo nl2br(htmlspecialchars($vendor['suspension_reason'])); ?></td>
                            </tr>
                            <?php endif; ?>
                            <?php endif; ?>
                            <tr>
                                <th>Registered:</th>
                                <td><?php echo date('M d, Y H:i', strtotime($vendor['user_created'])); ?></td>
                            </tr>
                            <tr>
                                <th>Last Updated:</th>
                                <td><?php echo date('M d, Y H:i', strtotime($vendor['updated_at'])); ?></td>
                            </tr>
                        </table>
                        
                        <?php if (!empty($vendor['business_description'])): ?>
                        <h5 class="mb-3 mt-4">Business Description</h5>
                        <p><?php echo nl2br(htmlspecialchars($vendor['business_description'])); ?></p>
                        <?php endif; ?>
                    </div>
                </div>
            </div>

            <!-- Products Tab -->
            <div class="tab-pane fade" id="products" role="tabpanel">
                <h5 class="mb-3">Vendor Products</h5>
                <p class="text-muted">View and manage products from this vendor</p>
                <a href="/admin/products/?vendor=<?php echo $vendor['user_id']; ?>" class="btn btn-primary">
                    <i class="fas fa-box me-2"></i> View All Products
                </a>
            </div>

            <!-- Transactions Tab -->
            <div class="tab-pane fade" id="transactions" role="tabpanel">
                <h5 class="mb-3">Transaction History</h5>
                <p class="text-muted">View orders and payout history for this vendor</p>
                <div class="row">
                    <div class="col-md-6">
                        <a href="/admin/orders/?vendor=<?php echo $vendor['user_id']; ?>" class="btn btn-primary w-100 mb-2">
                            <i class="fas fa-shopping-cart me-2"></i> View Orders
                        </a>
                    </div>
                    <div class="col-md-6">
                        <a href="/admin/payouts/?vendor=<?php echo $vendor['user_id']; ?>" class="btn btn-success w-100 mb-2">
                            <i class="fas fa-money-bill-wave me-2"></i> View Payouts
                        </a>
                    </div>
                </div>
            </div>

            <!-- Activity Log Tab -->
            <div class="tab-pane fade" id="activity" role="tabpanel">
                <h5 class="mb-3">Vendor Activity Log</h5>
                <?php if (empty($activity_logs)): ?>
                <p class="text-muted">No activity recorded</p>
                <?php else: ?>
                <div class="activity-timeline">
                    <?php foreach ($activity_logs as $log): ?>
                    <div class="activity-item">
                        <div class="d-flex justify-content-between">
                            <div>
                                <strong><?php echo ucfirst(str_replace('_', ' ', $log['activity_type'])); ?></strong>
                                <p class="mb-0"><?php echo htmlspecialchars($log['description']); ?></p>
                            </div>
                            <small class="text-muted">
                                <?php echo date('M d, Y H:i', strtotime($log['created_at'])); ?>
                            </small>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
                <?php endif; ?>
            </div>

            <!-- Audit Log Tab -->
            <div class="tab-pane fade" id="audit" role="tabpanel">
                <h5 class="mb-3">Admin Audit Log</h5>
                <p class="text-muted">Track all administrative actions on this vendor account</p>
                <?php if (empty($audit_logs)): ?>
                <p class="text-muted">No audit log entries</p>
                <?php else: ?>
                <div class="audit-timeline">
                    <?php foreach ($audit_logs as $log): ?>
                    <div class="audit-item">
                        <div class="row">
                            <div class="col-md-8">
                                <strong><?php echo ucfirst(str_replace('_', ' ', $log['action'])); ?></strong>
                                <p class="mb-0">
                                    <span class="badge bg-secondary"><?php echo ucfirst(str_replace('_', ' ', $log['action_type'])); ?></span>
                                    <?php if ($log['admin_username']): ?>
                                    by <strong><?php echo htmlspecialchars($log['admin_username']); ?></strong>
                                    <?php endif; ?>
                                </p>
                                <?php if (!empty($log['reason'])): ?>
                                <p class="mb-0 text-muted"><small>Reason: <?php echo htmlspecialchars($log['reason']); ?></small></p>
                                <?php endif; ?>
                                <?php if ($log['old_value'] && $log['new_value']): ?>
                                <p class="mb-0 text-muted">
                                    <small>
                                        Changed from <code><?php echo htmlspecialchars($log['old_value']); ?></code> 
                                        to <code><?php echo htmlspecialchars($log['new_value']); ?></code>
                                    </small>
                                </p>
                                <?php endif; ?>
                            </div>
                            <div class="col-md-4 text-end">
                                <small class="text-muted">
                                    <?php echo date('M d, Y H:i:s', strtotime($log['created_at'])); ?>
                                    <?php if ($log['ip_address']): ?>
                                    <br>IP: <?php echo htmlspecialchars($log['ip_address']); ?>
                                    <?php endif; ?>
                                </small>
                            </div>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function suspendVendor() {
            window.location.href = '/admin/vendors/edit.php?id=<?php echo $vendor_id; ?>&action=suspend';
        }
        
        function reactivateVendor() {
            window.location.href = '/admin/vendors/edit.php?id=<?php echo $vendor_id; ?>&action=reactivate';
        }
    </script>
</body>
</html>
