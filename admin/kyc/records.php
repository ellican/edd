<?php
/**
 * Enhanced KYC Records Management Dashboard
 * Comprehensive KYC/AML compliance management system
 */

require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/models/KYCRecord.php';
require_once __DIR__ . '/../../includes/services/KYCNotificationService.php';

// Require admin authentication
requireAdminAuth();
checkPermission('kyc.view');

$pdo = db();
$kycModel = new KYCRecord();
$notificationService = new KYCNotificationService();

$page_title = 'KYC Records Management';
$action = $_GET['action'] ?? 'list';
$record_id = $_GET['id'] ?? null;

// Handle POST actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!validateCSRFToken($_POST['csrf_token'] ?? '')) {
        $_SESSION['error_message'] = 'Invalid security token.';
    } else {
        try {
            $adminId = Session::getUserId();
            
            switch ($_POST['action']) {
                case 'approve_kyc':
                    checkPermission('kyc.approve');
                    $recordId = intval($_POST['record_id']);
                    $notes = sanitizeInput($_POST['notes'] ?? '');
                    
                    $kycModel->approve($recordId, $adminId, $notes);
                    $notificationService->sendApprovalNotification($recordId);
                    
                    $_SESSION['success_message'] = 'KYC record approved successfully.';
                    break;
                    
                case 'reject_kyc':
                    checkPermission('kyc.reject');
                    $recordId = intval($_POST['record_id']);
                    $reason = sanitizeInput($_POST['reason'] ?? '');
                    
                    if (empty($reason)) {
                        $_SESSION['error_message'] = 'Rejection reason is required.';
                        break;
                    }
                    
                    $kycModel->reject($recordId, $adminId, $reason);
                    $notificationService->sendRejectionNotification($recordId, $reason);
                    
                    $_SESSION['success_message'] = 'KYC record rejected successfully.';
                    break;
                    
                case 'export_csv':
                    checkPermission('kyc.export');
                    
                    $filters = [
                        'status' => $_POST['status'] ?? '',
                        'risk_level' => $_POST['risk_level'] ?? '',
                        'date_from' => $_POST['date_from'] ?? '',
                        'date_to' => $_POST['date_to'] ?? '',
                        'search' => $_POST['search'] ?? ''
                    ];
                    
                    $csvData = $kycModel->exportToCSV($filters);
                    
                    header('Content-Type: text/csv');
                    header('Content-Disposition: attachment; filename="kyc_records_' . date('Y-m-d') . '.csv"');
                    
                    $output = fopen('php://output', 'w');
                    foreach ($csvData as $row) {
                        fputcsv($output, $row);
                    }
                    fclose($output);
                    exit;
                    
                case 'bulk_action':
                    checkPermission('kyc.bulk_actions');
                    $bulkAction = $_POST['bulk_action'] ?? '';
                    $selectedRecords = $_POST['selected_records'] ?? [];
                    
                    if (empty($selectedRecords)) {
                        $_SESSION['error_message'] = 'No records selected.';
                        break;
                    }
                    
                    $count = 0;
                    foreach ($selectedRecords as $recordId) {
                        $recordId = intval($recordId);
                        
                        switch ($bulkAction) {
                            case 'approve':
                                $kycModel->approve($recordId, $adminId, 'Bulk approved');
                                $notificationService->sendApprovalNotification($recordId);
                                $count++;
                                break;
                                
                            case 'mark_pending':
                                $stmt = $pdo->prepare("
                                    UPDATE kyc_records 
                                    SET status = 'pending', verified_by = NULL, verified_at = NULL 
                                    WHERE id = ?
                                ");
                                $stmt->execute([$recordId]);
                                $count++;
                                break;
                        }
                    }
                    
                    $_SESSION['success_message'] = "Bulk action completed on {$count} records.";
                    break;
            }
        } catch (Exception $e) {
            error_log("KYC Management Error: " . $e->getMessage());
            $_SESSION['error_message'] = 'An error occurred: ' . $e->getMessage();
        }
    }
    
    header('Location: /admin/kyc/records.php');
    exit;
}

// Get filters
$filters = [
    'status' => $_GET['status'] ?? '',
    'risk_level' => $_GET['risk_level'] ?? '',
    'date_from' => $_GET['date_from'] ?? '',
    'date_to' => $_GET['date_to'] ?? '',
    'search' => $_GET['search'] ?? ''
];

$page = max(1, intval($_GET['page'] ?? 1));
$limit = 25;
$offset = ($page - 1) * $limit;

// Get statistics
$stats = $kycModel->getStatistics();

// Get records
$records = $kycModel->getRecords($filters, $limit, $offset);
$totalRecords = $kycModel->countRecords($filters);
$totalPages = ceil($totalRecords / $limit);

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($page_title); ?> - Admin</title>
    <link rel="stylesheet" href="/assets/css/admin.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            margin: 10px 0;
        }
        
        .stat-label {
            color: #666;
            font-size: 14px;
        }
        
        .status-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-pending { background: #FFF3CD; color: #856404; }
        .status-approved { background: #D4EDDA; color: #155724; }
        .status-rejected { background: #F8D7DA; color: #721C24; }
        .status-expired { background: #E2E3E5; color: #383D41; }
        .status-incomplete { background: #D1ECF1; color: #0C5460; }
        
        .risk-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .risk-low { background: #D4EDDA; color: #155724; }
        .risk-medium { background: #FFF3CD; color: #856404; }
        .risk-high { background: #F8D7DA; color: #721C24; }
        .risk-unknown { background: #E2E3E5; color: #383D41; }
        
        .filters-panel {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .filters-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 15px;
        }
        
        .records-table {
            width: 100%;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .records-table table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .records-table th,
        .records-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }
        
        .records-table th {
            background: #f8f9fa;
            font-weight: 600;
            color: #495057;
        }
        
        .records-table tr:hover {
            background: #f8f9fa;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .btn {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary { background: #007bff; color: white; }
        .btn-success { background: #28a745; color: white; }
        .btn-danger { background: #dc3545; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        .btn-sm { padding: 4px 8px; font-size: 12px; }
    </style>
</head>
<body>
    <div class="admin-container">
        <!-- Admin Sidebar -->
        <aside class="admin-sidebar">
            <div class="admin-logo">
                <h2>Admin Panel</h2>
            </div>
            <nav class="admin-nav">
                <a href="/admin/">Dashboard</a>
                <a href="/admin/kyc/records.php" class="active">KYC Records</a>
                <a href="/admin/kyc/">Legacy KYC</a>
                <a href="/admin/users/">Users</a>
                <a href="/admin/orders/">Orders</a>
                <a href="/admin/products/">Products</a>
            </nav>
        </aside>

        <!-- Main Content -->
        <main class="admin-main">
            <div class="admin-header">
                <h1><?php echo htmlspecialchars($page_title); ?></h1>
            </div>

            <!-- Statistics Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-label">Total Records</div>
                    <div class="stat-value"><?php echo number_format($stats['total']); ?></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Pending Verification</div>
                    <div class="stat-value" style="color: #FFC107;"><?php echo number_format($stats['pending']); ?></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Approved</div>
                    <div class="stat-value" style="color: #28A745;"><?php echo number_format($stats['approved']); ?></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Rejected</div>
                    <div class="stat-value" style="color: #DC3545;"><?php echo number_format($stats['rejected']); ?></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Expired</div>
                    <div class="stat-value" style="color: #6C757D;"><?php echo number_format($stats['expired']); ?></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Incomplete</div>
                    <div class="stat-value" style="color: #17A2B8;"><?php echo number_format($stats['incomplete']); ?></div>
                </div>
            </div>

            <!-- Messages -->
            <?php if (isset($_SESSION['success_message'])): ?>
                <div class="alert alert-success">
                    <?php echo htmlspecialchars($_SESSION['success_message']); unset($_SESSION['success_message']); ?>
                </div>
            <?php endif; ?>

            <?php if (isset($_SESSION['error_message'])): ?>
                <div class="alert alert-danger">
                    <?php echo htmlspecialchars($_SESSION['error_message']); unset($_SESSION['error_message']); ?>
                </div>
            <?php endif; ?>

            <!-- Filters Panel -->
            <div class="filters-panel">
                <form method="GET" action="">
                    <div class="filters-grid">
                        <div>
                            <label>Status</label>
                            <select name="status" class="form-control">
                                <option value="">All Statuses</option>
                                <option value="pending" <?php echo $filters['status'] === 'pending' ? 'selected' : ''; ?>>Pending</option>
                                <option value="approved" <?php echo $filters['status'] === 'approved' ? 'selected' : ''; ?>>Approved</option>
                                <option value="rejected" <?php echo $filters['status'] === 'rejected' ? 'selected' : ''; ?>>Rejected</option>
                                <option value="expired" <?php echo $filters['status'] === 'expired' ? 'selected' : ''; ?>>Expired</option>
                                <option value="incomplete" <?php echo $filters['status'] === 'incomplete' ? 'selected' : ''; ?>>Incomplete</option>
                            </select>
                        </div>
                        <div>
                            <label>Risk Level</label>
                            <select name="risk_level" class="form-control">
                                <option value="">All Risk Levels</option>
                                <option value="low" <?php echo $filters['risk_level'] === 'low' ? 'selected' : ''; ?>>Low</option>
                                <option value="medium" <?php echo $filters['risk_level'] === 'medium' ? 'selected' : ''; ?>>Medium</option>
                                <option value="high" <?php echo $filters['risk_level'] === 'high' ? 'selected' : ''; ?>>High</option>
                                <option value="unknown" <?php echo $filters['risk_level'] === 'unknown' ? 'selected' : ''; ?>>Unknown</option>
                            </select>
                        </div>
                        <div>
                            <label>Date From</label>
                            <input type="date" name="date_from" class="form-control" value="<?php echo htmlspecialchars($filters['date_from']); ?>">
                        </div>
                        <div>
                            <label>Date To</label>
                            <input type="date" name="date_to" class="form-control" value="<?php echo htmlspecialchars($filters['date_to']); ?>">
                        </div>
                        <div>
                            <label>Search</label>
                            <input type="text" name="search" class="form-control" placeholder="Name, ID, Email..." value="<?php echo htmlspecialchars($filters['search']); ?>">
                        </div>
                    </div>
                    <div style="display: flex; gap: 10px; margin-top: 15px;">
                        <button type="submit" class="btn btn-primary">Apply Filters</button>
                        <a href="/admin/kyc/records.php" class="btn btn-secondary">Clear Filters</a>
                        <form method="POST" style="display: inline;">
                            <input type="hidden" name="csrf_token" value="<?php echo csrfToken(); ?>">
                            <input type="hidden" name="action" value="export_csv">
                            <?php foreach ($filters as $key => $value): if (!empty($value)): ?>
                                <input type="hidden" name="<?php echo $key; ?>" value="<?php echo htmlspecialchars($value); ?>">
                            <?php endif; endforeach; ?>
                            <button type="submit" class="btn btn-success">Export to CSV</button>
                        </form>
                    </div>
                </form>
            </div>

            <!-- Records Table -->
            <div class="records-table">
                <form method="POST" id="bulkForm">
                    <input type="hidden" name="csrf_token" value="<?php echo csrfToken(); ?>">
                    <input type="hidden" name="action" value="bulk_action">
                    
                    <div style="padding: 15px; border-bottom: 1px solid #dee2e6; display: flex; gap: 10px; align-items: center;">
                        <select name="bulk_action" class="form-control" style="width: 200px;">
                            <option value="">Bulk Actions...</option>
                            <option value="approve">Approve Selected</option>
                            <option value="mark_pending">Mark as Pending</option>
                        </select>
                        <button type="submit" class="btn btn-secondary btn-sm">Apply</button>
                        <span style="margin-left: auto; color: #666;">
                            Showing <?php echo count($records); ?> of <?php echo $totalRecords; ?> records
                        </span>
                    </div>
                    
                    <table>
                        <thead>
                            <tr>
                                <th><input type="checkbox" id="selectAll"></th>
                                <th>ID</th>
                                <th>User</th>
                                <th>Full Name</th>
                                <th>ID Type/Number</th>
                                <th>Status</th>
                                <th>Risk</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if (empty($records)): ?>
                                <tr>
                                    <td colspan="9" style="text-align: center; padding: 40px;">
                                        No KYC records found matching your criteria.
                                    </td>
                                </tr>
                            <?php else: ?>
                                <?php foreach ($records as $record): ?>
                                    <tr>
                                        <td>
                                            <input type="checkbox" name="selected_records[]" value="<?php echo $record['id']; ?>" class="record-checkbox">
                                        </td>
                                        <td><?php echo $record['id']; ?></td>
                                        <td>
                                            <div><?php echo htmlspecialchars($record['email']); ?></div>
                                            <small style="color: #666;">ID: <?php echo $record['user_id']; ?></small>
                                        </td>
                                        <td><?php echo htmlspecialchars($record['full_name']); ?></td>
                                        <td>
                                            <div><?php echo htmlspecialchars($record['id_type']); ?></div>
                                            <small style="color: #666;"><?php echo htmlspecialchars($record['id_number']); ?></small>
                                        </td>
                                        <td>
                                            <span class="status-badge status-<?php echo $record['status']; ?>">
                                                <?php echo $record['status']; ?>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="risk-badge risk-<?php echo $record['risk_level']; ?>">
                                                <?php echo $record['risk_level']; ?>
                                            </span>
                                        </td>
                                        <td>
                                            <div><?php echo date('M d, Y', strtotime($record['created_at'])); ?></div>
                                            <small style="color: #666;"><?php echo date('H:i', strtotime($record['created_at'])); ?></small>
                                        </td>
                                        <td>
                                            <div class="action-buttons">
                                                <a href="/admin/kyc/view_record.php?id=<?php echo $record['id']; ?>" class="btn btn-primary btn-sm">View</a>
                                                <?php if ($record['status'] === 'pending'): ?>
                                                    <button type="button" class="btn btn-success btn-sm" onclick="approveRecord(<?php echo $record['id']; ?>)">Approve</button>
                                                    <button type="button" class="btn btn-danger btn-sm" onclick="rejectRecord(<?php echo $record['id']; ?>)">Reject</button>
                                                <?php endif; ?>
                                            </div>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </form>
            </div>

            <!-- Pagination -->
            <?php if ($totalPages > 1): ?>
                <div style="margin-top: 20px; text-align: center;">
                    <?php for ($i = 1; $i <= $totalPages; $i++): ?>
                        <a href="?page=<?php echo $i; ?><?php foreach ($filters as $key => $value): if (!empty($value)): echo '&' . $key . '=' . urlencode($value); endif; endforeach; ?>" 
                           class="btn <?php echo $i === $page ? 'btn-primary' : 'btn-secondary'; ?> btn-sm">
                            <?php echo $i; ?>
                        </a>
                    <?php endfor; ?>
                </div>
            <?php endif; ?>
        </main>
    </div>

    <script>
        // Select all checkbox
        document.getElementById('selectAll').addEventListener('change', function() {
            const checkboxes = document.querySelectorAll('.record-checkbox');
            checkboxes.forEach(cb => cb.checked = this.checked);
        });

        function approveRecord(recordId) {
            const notes = prompt('Enter approval notes (optional):');
            if (notes !== null) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.innerHTML = `
                    <input type="hidden" name="csrf_token" value="<?php echo csrfToken(); ?>">
                    <input type="hidden" name="action" value="approve_kyc">
                    <input type="hidden" name="record_id" value="${recordId}">
                    <input type="hidden" name="notes" value="${notes}">
                `;
                document.body.appendChild(form);
                form.submit();
            }
        }

        function rejectRecord(recordId) {
            const reason = prompt('Enter rejection reason (required):');
            if (reason && reason.trim()) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.innerHTML = `
                    <input type="hidden" name="csrf_token" value="<?php echo csrfToken(); ?>">
                    <input type="hidden" name="action" value="reject_kyc">
                    <input type="hidden" name="record_id" value="${recordId}">
                    <input type="hidden" name="reason" value="${reason}">
                `;
                document.body.appendChild(form);
                form.submit();
            } else {
                alert('Rejection reason is required.');
            }
        }
    </script>
</body>
</html>
