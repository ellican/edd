<?php
/**
 * Vendor Application Center
 * Manage pending vendor applications with approve/reject/request info
 */

require_once __DIR__ . '/../../includes/init.php';

// Initialize PDO global variable for this module
$pdo = db();

// For testing, bypass admin check 
if (!defined('ADMIN_BYPASS') || !ADMIN_BYPASS) {
    RoleMiddleware::requireAdmin();
}

$page_title = 'Vendor Applications';

// Handle actions
if ($_POST && isset($_POST['action'])) {
    validateCsrfAndRateLimit();
    
    try {
        $admin_id = Session::getUserId();
        $vendor_id = $_POST['vendor_id'] ?? 0;
        
        switch ($_POST['action']) {
            case 'approve':
                Database::query(
                    "UPDATE vendors SET status = 'approved', approved_by = ?, approved_at = NOW() WHERE id = ?",
                    [$admin_id, $vendor_id]
                );
                
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, new_value, reason, ip_address) 
                     VALUES (?, ?, 'application_approved', 'status_change', 'approved', ?, ?)",
                    [$vendor_id, $admin_id, $_POST['notes'] ?? 'Approved', $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Vendor application approved successfully.';
                sendVendorStatusNotification($vendor_id, 'approved', $_POST['notes'] ?? '');
                break;
                
            case 'reject':
                Database::query(
                    "UPDATE vendors SET status = 'rejected' WHERE id = ?",
                    [$vendor_id]
                );
                
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, new_value, reason, ip_address) 
                     VALUES (?, ?, 'application_rejected', 'status_change', 'rejected', ?, ?)",
                    [$vendor_id, $admin_id, $_POST['rejection_reason'] ?? 'Application rejected', $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Vendor application rejected.';
                sendVendorStatusNotification($vendor_id, 'rejected', $_POST['rejection_reason'] ?? '');
                break;
                
            case 'request_info':
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, reason, ip_address) 
                     VALUES (?, ?, 'info_requested', 'other', ?, ?)",
                    [$vendor_id, $admin_id, $_POST['info_request'] ?? 'Additional information requested', $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Information request sent to vendor.';
                sendVendorInfoRequest($vendor_id, $_POST['info_request'] ?? '');
                break;
        }
    } catch (Exception $e) {
        $_SESSION['error_message'] = $e->getMessage();
        Logger::error("Vendor application error: " . $e->getMessage());
    }
    
    header('Location: /admin/vendors/applications.php');
    exit;
}

// Get pending applications
try {
    $applications = Database::query(
        "SELECT v.*, u.username, u.email, u.created_at as user_created
         FROM vendors v
         LEFT JOIN users u ON v.user_id = u.id
         WHERE v.status = 'pending'
         ORDER BY v.created_at ASC"
    )->fetchAll();
} catch (Exception $e) {
    $applications = [];
    Logger::error("Failed to fetch applications: " . $e->getMessage());
}

// Helper functions
function sendVendorStatusNotification($vendor_id, $status, $reason = '') {
    try {
        $vendor = Database::query("SELECT v.*, u.email FROM vendors v JOIN users u ON v.user_id = u.id WHERE v.id = ?", [$vendor_id])->fetch();
        if ($vendor && function_exists('sendEmail')) {
            $subject = "Vendor Application " . ucfirst($status);
            $message = "Your vendor application has been {$status}.";
            if ($reason) {
                $message .= "\n\nReason: {$reason}";
            }
            sendEmail($vendor['email'], $subject, $message);
        }
    } catch (Exception $e) {
        Logger::error("Failed to send notification: " . $e->getMessage());
    }
}

function sendVendorInfoRequest($vendor_id, $message) {
    try {
        $vendor = Database::query("SELECT v.*, u.email FROM vendors v JOIN users u ON v.user_id = u.id WHERE v.id = ?", [$vendor_id])->fetch();
        if ($vendor && function_exists('sendEmail')) {
            $subject = "Additional Information Required for Vendor Application";
            sendEmail($vendor['email'], $subject, $message);
        }
    } catch (Exception $e) {
        Logger::error("Failed to send info request: " . $e->getMessage());
    }
}
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
        .application-card {
            border-left: 4px solid #f39c12;
            margin-bottom: 1rem;
        }
        .vendor-logo {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 8px;
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
                        <i class="fas fa-clipboard-list me-2"></i>
                        <?php echo $page_title; ?>
                    </h1>
                    <small class="text-white-50">Review and process pending vendor applications</small>
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

        <div class="row">
            <div class="col-12">
                <div class="card mb-3">
                    <div class="card-body">
                        <h5>Pending Applications: <?php echo count($applications); ?></h5>
                        <p class="text-muted mb-0">Review vendor applications and approve, reject, or request additional information</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Applications List -->
        <?php if (empty($applications)): ?>
        <div class="card">
            <div class="card-body text-center py-5">
                <i class="fas fa-check-circle fa-4x text-success mb-3"></i>
                <h4>No Pending Applications</h4>
                <p class="text-muted">All vendor applications have been processed</p>
                <a href="/admin/vendors/" class="btn btn-primary">View All Vendors</a>
            </div>
        </div>
        <?php else: ?>
        <?php foreach ($applications as $app): ?>
        <div class="card application-card">
            <div class="card-body">
                <div class="row">
                    <div class="col-md-8">
                        <div class="d-flex align-items-start mb-3">
                            <?php if (!empty($app['logo_url'])): ?>
                            <img src="<?php echo htmlspecialchars($app['logo_url']); ?>" 
                                 class="vendor-logo me-3" alt="Logo">
                            <?php else: ?>
                            <div class="vendor-logo me-3 bg-light d-flex align-items-center justify-content-center">
                                <i class="fas fa-store fa-2x text-muted"></i>
                            </div>
                            <?php endif; ?>
                            <div class="flex-grow-1">
                                <h5 class="mb-1"><?php echo htmlspecialchars($app['business_name'] ?? 'N/A'); ?></h5>
                                <div class="text-muted">
                                    <i class="fas fa-user me-1"></i> <?php echo htmlspecialchars($app['username']); ?>
                                    <span class="mx-2">|</span>
                                    <i class="fas fa-envelope me-1"></i> <?php echo htmlspecialchars($app['email']); ?>
                                </div>
                                <div class="mt-2">
                                    <span class="badge bg-secondary"><?php echo ucfirst($app['business_type'] ?? 'individual'); ?></span>
                                    <span class="badge bg-info ms-1">
                                        <i class="fas fa-clock me-1"></i>
                                        Applied <?php echo date('M d, Y', strtotime($app['user_created'])); ?>
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row g-3">
                            <div class="col-md-6">
                                <strong>Business Email:</strong><br>
                                <?php echo htmlspecialchars($app['business_email'] ?? 'N/A'); ?>
                            </div>
                            <div class="col-md-6">
                                <strong>Business Phone:</strong><br>
                                <?php echo htmlspecialchars($app['business_phone'] ?? 'N/A'); ?>
                            </div>
                            <div class="col-md-6">
                                <strong>Website:</strong><br>
                                <?php if (!empty($app['website'])): ?>
                                <a href="<?php echo htmlspecialchars($app['website']); ?>" target="_blank" rel="noopener">
                                    <?php echo htmlspecialchars($app['website']); ?>
                                </a>
                                <?php else: ?>
                                N/A
                                <?php endif; ?>
                            </div>
                            <div class="col-md-6">
                                <strong>Tax ID:</strong><br>
                                <?php echo htmlspecialchars($app['tax_id'] ?? 'N/A'); ?>
                            </div>
                            <?php if (!empty($app['business_description'])): ?>
                            <div class="col-12">
                                <strong>Business Description:</strong><br>
                                <?php echo nl2br(htmlspecialchars($app['business_description'])); ?>
                            </div>
                            <?php endif; ?>
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="d-grid gap-2">
                            <button type="button" class="btn btn-success" 
                                    onclick="approveApplication(<?php echo $app['id']; ?>)">
                                <i class="fas fa-check me-2"></i> Approve Application
                            </button>
                            <button type="button" class="btn btn-danger" 
                                    onclick="rejectApplication(<?php echo $app['id']; ?>)">
                                <i class="fas fa-times me-2"></i> Reject Application
                            </button>
                            <button type="button" class="btn btn-info" 
                                    onclick="requestInfo(<?php echo $app['id']; ?>)">
                                <i class="fas fa-question-circle me-2"></i> Request More Info
                            </button>
                            <a href="/admin/vendors/show.php?id=<?php echo $app['id']; ?>" class="btn btn-outline-primary">
                                <i class="fas fa-eye me-2"></i> View Full Profile
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php endforeach; ?>
        <?php endif; ?>
    </div>

    <!-- Modals -->
    <div class="modal fade" id="approveModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST">
                    <?php echo csrfTokenInput(); ?>
                    <input type="hidden" name="action" value="approve">
                    <input type="hidden" name="vendor_id" id="approveVendorId">
                    <div class="modal-header">
                        <h5 class="modal-title">Approve Vendor Application</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p>Are you sure you want to approve this vendor application?</p>
                        <div class="mb-3">
                            <label class="form-label">Notes (Optional)</label>
                            <textarea class="form-control" name="notes" rows="3" 
                                      placeholder="Add any notes for the vendor..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success">Approve</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="rejectModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST">
                    <?php echo csrfTokenInput(); ?>
                    <input type="hidden" name="action" value="reject">
                    <input type="hidden" name="vendor_id" id="rejectVendorId">
                    <div class="modal-header">
                        <h5 class="modal-title">Reject Vendor Application</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p>Please provide a reason for rejecting this application:</p>
                        <div class="mb-3">
                            <label class="form-label">Rejection Reason *</label>
                            <textarea class="form-control" name="rejection_reason" rows="4" required
                                      placeholder="Explain why this application is being rejected..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-danger">Reject Application</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="infoModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST">
                    <?php echo csrfTokenInput(); ?>
                    <input type="hidden" name="action" value="request_info">
                    <input type="hidden" name="vendor_id" id="infoVendorId">
                    <div class="modal-header">
                        <h5 class="modal-title">Request Additional Information</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Information Request *</label>
                            <textarea class="form-control" name="info_request" rows="5" required
                                      placeholder="Specify what additional information is needed..."></textarea>
                        </div>
                        <div class="alert alert-info">
                            <i class="fas fa-info-circle me-2"></i>
                            This message will be sent to the vendor via email.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-info">Send Request</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const approveModal = new bootstrap.Modal(document.getElementById('approveModal'));
        const rejectModal = new bootstrap.Modal(document.getElementById('rejectModal'));
        const infoModal = new bootstrap.Modal(document.getElementById('infoModal'));

        function approveApplication(id) {
            document.getElementById('approveVendorId').value = id;
            approveModal.show();
        }

        function rejectApplication(id) {
            document.getElementById('rejectVendorId').value = id;
            rejectModal.show();
        }

        function requestInfo(id) {
            document.getElementById('infoVendorId').value = id;
            infoModal.show();
        }
    </script>
</body>
</html>
