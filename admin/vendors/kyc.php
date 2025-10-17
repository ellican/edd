<?php
/**
 * Vendor KYC Management
 * Upload, verify, and manage KYC documents
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
        "SELECT v.*, u.username, u.email 
         FROM vendors v
         LEFT JOIN users u ON v.user_id = u.id
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

// Handle KYC actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    validateCsrfAndRateLimit();
    
    try {
        $action = $_POST['action'] ?? '';
        $admin_id = Session::getUserId();
        
        switch ($action) {
            case 'update_status':
                $new_status = $_POST['status'] ?? 'pending';
                $notes = $_POST['notes'] ?? '';
                
                // Update seller_kyc record status
                Database::query(
                    "UPDATE seller_kyc SET 
                        verification_status = ?,
                        verified_by = ?,
                        verified_at = NOW(),
                        verification_notes = ?,
                        rejection_reason = ?
                     WHERE vendor_id = ?",
                    [
                        $new_status,
                        $admin_id,
                        $notes,
                        $new_status === 'rejected' ? $notes : null,
                        $vendor_id
                    ]
                );
                
                // Update vendor KYC status
                Database::query(
                    "UPDATE vendors SET kyc_status = ?, kyc_verified_at = ? WHERE id = ?",
                    [$new_status, $new_status === 'approved' ? date('Y-m-d H:i:s') : null, $vendor_id]
                );
                
                // Log audit
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, new_value, reason, ip_address) 
                     VALUES (?, ?, 'kyc_status_updated', 'kyc_verification', ?, ?, ?)",
                    [$vendor_id, $admin_id, $new_status, $notes, $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'KYC status updated successfully.';
                
                // Send notification
                if (function_exists('sendEmail')) {
                    $subject = "KYC Verification " . ucfirst($new_status);
                    $message = "Your KYC verification status has been updated to: {$new_status}.\n\n";
                    if ($notes) {
                        $message .= "Notes: {$notes}";
                    }
                    sendEmail($vendor['email'], $subject, $message);
                }
                break;
                
            case 'request_resubmission':
                $message = $_POST['resubmission_message'] ?? '';
                
                Database::query(
                    "UPDATE seller_kyc SET verification_status = 'requires_resubmission', verification_notes = ? WHERE vendor_id = ?",
                    [$message, $vendor_id]
                );
                
                Database::query(
                    "UPDATE vendors SET kyc_status = 'requires_resubmission' WHERE id = ?",
                    [$vendor_id]
                );
                
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, reason, ip_address) 
                     VALUES (?, ?, 'kyc_resubmission_requested', 'kyc_verification', ?, ?)",
                    [$vendor_id, $admin_id, $message, $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Resubmission request sent.';
                
                // Send notification
                if (function_exists('sendEmail')) {
                    sendEmail(
                        $vendor['email'],
                        'KYC Document Resubmission Required',
                        "Please resubmit your KYC documents.\n\nReason: {$message}"
                    );
                }
                break;
        }
        
        header('Location: /admin/vendors/kyc.php?id=' . $vendor_id);
        exit;
    } catch (Exception $e) {
        $_SESSION['error_message'] = $e->getMessage();
        Logger::error("KYC management error: " . $e->getMessage());
    }
}

// Get KYC submission
try {
    $kyc_submission = Database::query(
        "SELECT sk.*, u.username as verified_by_name
         FROM seller_kyc sk
         LEFT JOIN users u ON sk.verified_by = u.id
         WHERE sk.vendor_id = ?
         ORDER BY sk.submitted_at DESC
         LIMIT 1",
        [$vendor_id]
    )->fetch();
} catch (Exception $e) {
    $kyc_submission = null;
    Logger::error("Failed to fetch KYC submission: " . $e->getMessage());
}

$page_title = 'KYC Management: ' . htmlspecialchars($vendor['business_name']);
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
        .kyc-status-card {
            border-left: 4px solid #3498db;
            margin-bottom: 1.5rem;
        }
        .document-preview {
            max-width: 100%;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 10px;
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
                        <i class="fas fa-id-card me-2"></i>
                        KYC Document Management
                    </h1>
                </div>
                <div class="col-md-6 text-end">
                    <a href="/admin/vendors/show.php?id=<?php echo $vendor_id; ?>" class="btn btn-outline-light">
                        <i class="fas fa-arrow-left me-1"></i> Back to Profile
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

        <!-- Vendor Info Card -->
        <div class="card mb-4">
            <div class="card-body">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h5><?php echo htmlspecialchars($vendor['business_name']); ?></h5>
                        <p class="text-muted mb-0">
                            <i class="fas fa-user me-1"></i> <?php echo htmlspecialchars($vendor['username']); ?>
                            <span class="mx-2">|</span>
                            <i class="fas fa-envelope me-1"></i> <?php echo htmlspecialchars($vendor['email']); ?>
                        </p>
                    </div>
                    <div class="col-md-4 text-end">
                        <?php
                        $kycClass = [
                            'not_submitted' => 'secondary',
                            'pending' => 'warning',
                            'in_review' => 'info',
                            'approved' => 'success',
                            'rejected' => 'danger'
                        ][$vendor['kyc_status'] ?? 'not_submitted'] ?? 'secondary';
                        ?>
                        <span class="badge bg-<?php echo $kycClass; ?> p-2">
                            KYC Status: <?php echo ucfirst(str_replace('_', ' ', $vendor['kyc_status'] ?? 'Not Submitted')); ?>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- KYC Submission -->
        <?php if (!$kyc_submission): ?>
        <div class="card">
            <div class="card-body text-center py-5">
                <i class="fas fa-id-card fa-4x text-muted mb-3"></i>
                <h4>No KYC Submission</h4>
                <p class="text-muted">This vendor has not submitted KYC documents yet.</p>
            </div>
        </div>
        <?php else: 
            $identity_docs = json_decode($kyc_submission['identity_documents'] ?? '[]', true) ?: [];
            $address_docs = json_decode($kyc_submission['address_verification'] ?? '[]', true) ?: [];
            $bank_docs = json_decode($kyc_submission['bank_verification'] ?? '[]', true) ?: [];
            $business_docs = json_decode($kyc_submission['business_documents'] ?? '[]', true) ?: [];
        ?>
        <div class="card kyc-status-card mb-4">
            <div class="card-body">
                <div class="row">
                    <div class="col-md-8">
                        <h5><i class="fas fa-info-circle me-2"></i>KYC Submission Overview</h5>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong>Verification Type:</strong><br>
                                <?php echo ucfirst($kyc_submission['verification_type']); ?>
                            </div>
                            <div class="col-md-6">
                                <strong>Submitted:</strong><br>
                                <?php echo date('M d, Y H:i', strtotime($kyc_submission['submitted_at'])); ?>
                            </div>
                            <?php if ($kyc_submission['business_registration_number']): ?>
                            <div class="col-md-6 mt-2">
                                <strong>Business Registration #:</strong><br>
                                <?php echo htmlspecialchars($kyc_submission['business_registration_number']); ?>
                            </div>
                            <?php endif; ?>
                            <?php if ($kyc_submission['tax_identification_number']): ?>
                            <div class="col-md-6 mt-2">
                                <strong>Tax ID:</strong><br>
                                <?php echo htmlspecialchars($kyc_submission['tax_identification_number']); ?>
                            </div>
                            <?php endif; ?>
                        </div>
                        
                        <div class="mb-3">
                            <strong>Status:</strong>
                            <?php
                            $statusClass = [
                                'pending' => 'warning',
                                'in_review' => 'info',
                                'approved' => 'success',
                                'rejected' => 'danger',
                                'requires_resubmission' => 'warning'
                            ][$kyc_submission['verification_status']] ?? 'secondary';
                            ?>
                            <span class="badge bg-<?php echo $statusClass; ?>">
                                <?php echo ucfirst(str_replace('_', ' ', $kyc_submission['verification_status'])); ?>
                            </span>
                        </div>
                        
                        <?php if ($kyc_submission['verified_at']): ?>
                        <div class="mb-2">
                            <strong>Verified:</strong> 
                            <?php echo date('M d, Y H:i', strtotime($kyc_submission['verified_at'])); ?>
                            <?php if ($kyc_submission['verified_by_name']): ?>
                            by <?php echo htmlspecialchars($kyc_submission['verified_by_name']); ?>
                            <?php endif; ?>
                        </div>
                        <?php endif; ?>
                        
                        <?php if ($kyc_submission['verification_notes']): ?>
                        <div class="alert alert-info mb-0">
                            <strong>Verification Notes:</strong><br>
                            <?php echo nl2br(htmlspecialchars($kyc_submission['verification_notes'])); ?>
                        </div>
                        <?php endif; ?>
                        
                        <?php if ($kyc_submission['verification_status'] === 'rejected' && $kyc_submission['rejection_reason']): ?>
                        <div class="alert alert-danger mb-0">
                            <strong>Rejection Reason:</strong><br>
                            <?php echo nl2br(htmlspecialchars($kyc_submission['rejection_reason'])); ?>
                        </div>
                        <?php endif; ?>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="d-grid gap-2">
                            <?php if ($kyc_submission['verification_status'] !== 'approved'): ?>
                            <button type="button" class="btn btn-success" 
                                    onclick="updateStatus('approved')">
                                <i class="fas fa-check me-1"></i> Approve KYC
                            </button>
                            <?php endif; ?>
                            
                            <?php if ($kyc_submission['verification_status'] !== 'rejected'): ?>
                            <button type="button" class="btn btn-danger" 
                                    onclick="updateStatus('rejected')">
                                <i class="fas fa-times me-1"></i> Reject KYC
                            </button>
                            <?php endif; ?>
                            
                            <?php if ($kyc_submission['verification_status'] !== 'in_review'): ?>
                            <button type="button" class="btn btn-info" 
                                    onclick="updateStatus('in_review')">
                                <i class="fas fa-search me-1"></i> Mark In Review
                            </button>
                            <?php endif; ?>
                            
                            <button type="button" class="btn btn-warning" 
                                    onclick="requestResubmission()">
                                <i class="fas fa-redo me-1"></i> Request Resubmission
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Document Categories -->
        <?php if (!empty($identity_docs)): ?>
        <div class="card mb-3">
            <div class="card-header bg-primary text-white">
                <h6 class="mb-0"><i class="fas fa-id-card me-2"></i>Identity Documents</h6>
            </div>
            <div class="card-body">
                <div class="row">
                    <?php foreach ($identity_docs as $key => $doc): ?>
                    <div class="col-md-6 mb-3">
                        <div class="border p-3 rounded">
                            <strong><?php echo ucfirst(str_replace('_', ' ', $key)); ?></strong>
                            <p class="mb-1 text-muted"><small><?php echo htmlspecialchars($doc['original_name'] ?? 'Document'); ?></small></p>
                            <?php if (!empty($doc['document_number'])): ?>
                            <p class="mb-1"><small>Number: <?php echo htmlspecialchars($doc['document_number']); ?></small></p>
                            <?php endif; ?>
                            <a href="<?php echo htmlspecialchars($doc['file_path']); ?>" target="_blank" class="btn btn-sm btn-outline-primary mt-2">
                                <i class="fas fa-eye me-1"></i> View
                            </a>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>
        <?php endif; ?>

        <?php if (!empty($address_docs)): ?>
        <div class="card mb-3">
            <div class="card-header bg-success text-white">
                <h6 class="mb-0"><i class="fas fa-map-marker-alt me-2"></i>Address Verification</h6>
            </div>
            <div class="card-body">
                <div class="row">
                    <?php foreach ($address_docs as $key => $doc): ?>
                    <div class="col-md-6 mb-3">
                        <div class="border p-3 rounded">
                            <strong><?php echo ucfirst(str_replace('_', ' ', $key)); ?></strong>
                            <p class="mb-1 text-muted"><small><?php echo htmlspecialchars($doc['original_name'] ?? 'Document'); ?></small></p>
                            <a href="<?php echo htmlspecialchars($doc['file_path']); ?>" target="_blank" class="btn btn-sm btn-outline-primary mt-2">
                                <i class="fas fa-eye me-1"></i> View
                            </a>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>
        <?php endif; ?>

        <?php if (!empty($bank_docs)): ?>
        <div class="card mb-3">
            <div class="card-header bg-info text-white">
                <h6 class="mb-0"><i class="fas fa-university me-2"></i>Bank Verification</h6>
            </div>
            <div class="card-body">
                <div class="row">
                    <?php foreach ($bank_docs as $key => $doc): ?>
                    <div class="col-md-6 mb-3">
                        <div class="border p-3 rounded">
                            <strong><?php echo ucfirst(str_replace('_', ' ', $key)); ?></strong>
                            <p class="mb-1 text-muted"><small><?php echo htmlspecialchars($doc['original_name'] ?? 'Document'); ?></small></p>
                            <?php if (!empty($doc['account_number'])): ?>
                            <p class="mb-1"><small>Account: ****<?php echo htmlspecialchars($doc['account_number']); ?></small></p>
                            <?php endif; ?>
                            <a href="<?php echo htmlspecialchars($doc['file_path']); ?>" target="_blank" class="btn btn-sm btn-outline-primary mt-2">
                                <i class="fas fa-eye me-1"></i> View
                            </a>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>
        <?php endif; ?>

        <?php if (!empty($business_docs)): ?>
        <div class="card mb-3">
            <div class="card-header bg-warning text-dark">
                <h6 class="mb-0"><i class="fas fa-briefcase me-2"></i>Business Documents</h6>
            </div>
            <div class="card-body">
                <div class="row">
                    <?php foreach ($business_docs as $key => $doc): ?>
                    <div class="col-md-6 mb-3">
                        <div class="border p-3 rounded">
                            <strong><?php echo ucfirst(str_replace('_', ' ', $key)); ?></strong>
                            <p class="mb-1 text-muted"><small><?php echo htmlspecialchars($doc['original_name'] ?? 'Document'); ?></small></p>
                            <a href="<?php echo htmlspecialchars($doc['file_path']); ?>" target="_blank" class="btn btn-sm btn-outline-primary mt-2">
                                <i class="fas fa-eye me-1"></i> View
                            </a>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>
        <?php endif; ?>
        <?php endif; ?>
    </div>

    <!-- Status Update Modal -->
    <div class="modal fade" id="statusModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST">
                    <?php echo csrfTokenInput(); ?>
                    <input type="hidden" name="action" value="update_status">
                    <input type="hidden" name="status" id="newStatus">
                    <div class="modal-header">
                        <h5 class="modal-title" id="statusModalLabel">Update KYC Status</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p id="statusMessage"></p>
                        <div class="mb-3">
                            <label class="form-label">Notes</label>
                            <textarea class="form-control" name="notes" rows="4" 
                                      placeholder="Add any notes about this status change..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary" id="statusBtn">Confirm</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Resubmission Modal -->
    <div class="modal fade" id="resubmitModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST">
                    <?php echo csrfTokenInput(); ?>
                    <input type="hidden" name="action" value="request_resubmission">
                    <div class="modal-header">
                        <h5 class="modal-title">Request KYC Resubmission</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Message to Vendor *</label>
                            <textarea class="form-control" name="resubmission_message" rows="5" required
                                      placeholder="Explain what needs to be corrected or resubmitted..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-warning">Request Resubmission</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const statusModal = new bootstrap.Modal(document.getElementById('statusModal'));
        const resubmitModal = new bootstrap.Modal(document.getElementById('resubmitModal'));

        function updateStatus(status) {
            document.getElementById('newStatus').value = status;
            
            let message = '';
            let btnClass = 'btn-primary';
            
            if (status === 'approved') {
                message = 'Are you sure you want to approve this KYC submission?';
                btnClass = 'btn-success';
            } else if (status === 'rejected') {
                message = 'Are you sure you want to reject this KYC submission?';
                btnClass = 'btn-danger';
            } else if (status === 'in_review') {
                message = 'Mark this KYC submission as being in review?';
                btnClass = 'btn-info';
            }
            
            document.getElementById('statusMessage').textContent = message;
            document.getElementById('statusBtn').className = 'btn ' + btnClass;
            document.getElementById('statusModalLabel').textContent = 
                status.charAt(0).toUpperCase() + status.slice(1).replace('_', ' ') + ' KYC';
            
            statusModal.show();
        }

        function requestResubmission() {
            resubmitModal.show();
        }
    </script>
</body>
</html>
