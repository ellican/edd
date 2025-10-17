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
            case 'verify_document':
                $doc_id = $_POST['document_id'] ?? 0;
                $status = $_POST['status'] ?? 'approved';
                $remarks = $_POST['remarks'] ?? '';
                
                Database::query(
                    "UPDATE vendor_kyc SET 
                        status = ?,
                        verified_by = ?,
                        verified_at = NOW(),
                        remarks = ?,
                        rejection_reason = ?
                     WHERE id = ? AND vendor_id = ?",
                    [
                        $status,
                        $admin_id,
                        $remarks,
                        $status === 'rejected' ? $remarks : null,
                        $doc_id,
                        $vendor_id
                    ]
                );
                
                // Update vendor KYC status
                $all_docs = Database::query(
                    "SELECT status FROM vendor_kyc WHERE vendor_id = ?",
                    [$vendor_id]
                )->fetchAll();
                
                $all_approved = true;
                $has_rejected = false;
                foreach ($all_docs as $doc) {
                    if ($doc['status'] !== 'approved') {
                        $all_approved = false;
                    }
                    if ($doc['status'] === 'rejected') {
                        $has_rejected = true;
                    }
                }
                
                $vendor_kyc_status = 'pending';
                if ($all_approved && count($all_docs) > 0) {
                    $vendor_kyc_status = 'approved';
                } elseif ($has_rejected) {
                    $vendor_kyc_status = 'rejected';
                } elseif ($status === 'in_review') {
                    $vendor_kyc_status = 'in_review';
                }
                
                Database::query(
                    "UPDATE vendors SET kyc_status = ?, kyc_verified_at = ? WHERE id = ?",
                    [$vendor_kyc_status, $vendor_kyc_status === 'approved' ? date('Y-m-d H:i:s') : null, $vendor_id]
                );
                
                // Log audit
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, new_value, reason, ip_address) 
                     VALUES (?, ?, 'kyc_document_verified', 'kyc_verification', ?, ?, ?)",
                    [$vendor_id, $admin_id, $status, $remarks, $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'KYC document status updated.';
                
                // Send notification
                if (function_exists('sendEmail')) {
                    $subject = "KYC Document " . ucfirst($status);
                    $message = "Your KYC document has been {$status}.\n\n";
                    if ($remarks) {
                        $message .= "Remarks: {$remarks}";
                    }
                    sendEmail($vendor['email'], $subject, $message);
                }
                break;
                
            case 'request_resubmission':
                $doc_id = $_POST['document_id'] ?? 0;
                $message = $_POST['resubmission_message'] ?? '';
                
                Database::query(
                    "UPDATE vendor_kyc SET status = 'resubmission_required', remarks = ? WHERE id = ? AND vendor_id = ?",
                    [$message, $doc_id, $vendor_id]
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
                        "Please resubmit your KYC document.\n\nReason: {$message}"
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

// Get KYC documents
try {
    $kyc_docs = Database::query(
        "SELECT vk.*, u.username as verified_by_name
         FROM vendor_kyc vk
         LEFT JOIN users u ON vk.verified_by = u.id
         WHERE vk.vendor_id = ?
         ORDER BY vk.uploaded_at DESC",
        [$vendor_id]
    )->fetchAll();
} catch (Exception $e) {
    $kyc_docs = [];
    Logger::error("Failed to fetch KYC documents: " . $e->getMessage());
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

        <!-- KYC Documents -->
        <?php if (empty($kyc_docs)): ?>
        <div class="card">
            <div class="card-body text-center py-5">
                <i class="fas fa-id-card fa-4x text-muted mb-3"></i>
                <h4>No KYC Documents Uploaded</h4>
                <p class="text-muted">This vendor has not uploaded any KYC documents yet.</p>
            </div>
        </div>
        <?php else: ?>
        <?php foreach ($kyc_docs as $doc): ?>
        <div class="card kyc-status-card">
            <div class="card-body">
                <div class="row">
                    <div class="col-md-8">
                        <h5>
                            <i class="fas fa-file-alt me-2"></i>
                            <?php echo ucfirst(str_replace('_', ' ', $doc['document_type'])); ?>
                        </h5>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <strong>File Name:</strong><br>
                                <?php echo htmlspecialchars($doc['file_name']); ?>
                            </div>
                            <div class="col-md-6">
                                <strong>File Size:</strong><br>
                                <?php echo number_format($doc['file_size'] / 1024, 2); ?> KB
                            </div>
                            <div class="col-md-6 mt-2">
                                <strong>Uploaded:</strong><br>
                                <?php echo date('M d, Y H:i', strtotime($doc['uploaded_at'])); ?>
                            </div>
                            <?php if ($doc['expiry_date']): ?>
                            <div class="col-md-6 mt-2">
                                <strong>Expiry Date:</strong><br>
                                <?php echo date('M d, Y', strtotime($doc['expiry_date'])); ?>
                                <?php if (strtotime($doc['expiry_date']) < time()): ?>
                                <span class="badge bg-danger">Expired</span>
                                <?php endif; ?>
                            </div>
                            <?php endif; ?>
                        </div>
                        
                        <div class="mb-3">
                            <strong>Status:</strong>
                            <?php
                            $docStatusClass = [
                                'pending' => 'warning',
                                'in_review' => 'info',
                                'approved' => 'success',
                                'rejected' => 'danger',
                                'resubmission_required' => 'warning'
                            ][$doc['status']] ?? 'secondary';
                            ?>
                            <span class="badge bg-<?php echo $docStatusClass; ?>">
                                <?php echo ucfirst(str_replace('_', ' ', $doc['status'])); ?>
                            </span>
                        </div>
                        
                        <?php if ($doc['verified_at']): ?>
                        <div class="mb-2">
                            <strong>Verified:</strong> 
                            <?php echo date('M d, Y H:i', strtotime($doc['verified_at'])); ?>
                            <?php if ($doc['verified_by_name']): ?>
                            by <?php echo htmlspecialchars($doc['verified_by_name']); ?>
                            <?php endif; ?>
                        </div>
                        <?php endif; ?>
                        
                        <?php if ($doc['remarks']): ?>
                        <div class="alert alert-info mb-0">
                            <strong>Remarks:</strong><br>
                            <?php echo nl2br(htmlspecialchars($doc['remarks'])); ?>
                        </div>
                        <?php endif; ?>
                        
                        <?php if ($doc['status'] === 'rejected' && $doc['rejection_reason']): ?>
                        <div class="alert alert-danger mb-0">
                            <strong>Rejection Reason:</strong><br>
                            <?php echo nl2br(htmlspecialchars($doc['rejection_reason'])); ?>
                        </div>
                        <?php endif; ?>
                    </div>
                    
                    <div class="col-md-4">
                        <!-- Document Preview -->
                        <div class="mb-3">
                            <?php if (strpos($doc['mime_type'], 'image/') === 0): ?>
                            <img src="<?php echo htmlspecialchars($doc['file_path']); ?>" 
                                 class="document-preview" alt="Document">
                            <?php else: ?>
                            <div class="document-preview text-center p-4">
                                <i class="fas fa-file fa-4x text-muted mb-2"></i>
                                <p class="text-muted"><?php echo htmlspecialchars($doc['mime_type']); ?></p>
                            </div>
                            <?php endif; ?>
                        </div>
                        
                        <div class="d-grid gap-2">
                            <a href="<?php echo htmlspecialchars($doc['file_path']); ?>" 
                               target="_blank" class="btn btn-outline-primary btn-sm">
                                <i class="fas fa-download me-1"></i> Download
                            </a>
                            
                            <?php if ($doc['status'] !== 'approved'): ?>
                            <button type="button" class="btn btn-success btn-sm" 
                                    onclick="verifyDocument(<?php echo $doc['id']; ?>, 'approved')">
                                <i class="fas fa-check me-1"></i> Approve
                            </button>
                            <?php endif; ?>
                            
                            <?php if ($doc['status'] !== 'rejected'): ?>
                            <button type="button" class="btn btn-danger btn-sm" 
                                    onclick="verifyDocument(<?php echo $doc['id']; ?>, 'rejected')">
                                <i class="fas fa-times me-1"></i> Reject
                            </button>
                            <?php endif; ?>
                            
                            <?php if ($doc['status'] !== 'in_review'): ?>
                            <button type="button" class="btn btn-info btn-sm" 
                                    onclick="verifyDocument(<?php echo $doc['id']; ?>, 'in_review')">
                                <i class="fas fa-search me-1"></i> Mark In Review
                            </button>
                            <?php endif; ?>
                            
                            <button type="button" class="btn btn-warning btn-sm" 
                                    onclick="requestResubmission(<?php echo $doc['id']; ?>)">
                                <i class="fas fa-redo me-1"></i> Request Resubmission
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php endforeach; ?>
        <?php endif; ?>
    </div>

    <!-- Verification Modal -->
    <div class="modal fade" id="verifyModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST">
                    <?php echo csrfTokenInput(); ?>
                    <input type="hidden" name="action" value="verify_document">
                    <input type="hidden" name="document_id" id="verifyDocId">
                    <input type="hidden" name="status" id="verifyStatus">
                    <div class="modal-header">
                        <h5 class="modal-title" id="verifyModalLabel">Verify Document</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <p id="verifyMessage"></p>
                        <div class="mb-3">
                            <label class="form-label">Remarks</label>
                            <textarea class="form-control" name="remarks" rows="4" 
                                      placeholder="Add any remarks or notes about this document..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary" id="verifyBtn">Confirm</button>
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
                    <input type="hidden" name="document_id" id="resubmitDocId">
                    <div class="modal-header">
                        <h5 class="modal-title">Request Document Resubmission</h5>
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
        const verifyModal = new bootstrap.Modal(document.getElementById('verifyModal'));
        const resubmitModal = new bootstrap.Modal(document.getElementById('resubmitModal'));

        function verifyDocument(docId, status) {
            document.getElementById('verifyDocId').value = docId;
            document.getElementById('verifyStatus').value = status;
            
            let message = '';
            let btnClass = 'btn-primary';
            
            if (status === 'approved') {
                message = 'Are you sure you want to approve this document?';
                btnClass = 'btn-success';
            } else if (status === 'rejected') {
                message = 'Are you sure you want to reject this document?';
                btnClass = 'btn-danger';
            } else if (status === 'in_review') {
                message = 'Mark this document as being in review?';
                btnClass = 'btn-info';
            }
            
            document.getElementById('verifyMessage').textContent = message;
            document.getElementById('verifyBtn').className = 'btn ' + btnClass;
            document.getElementById('verifyModalLabel').textContent = 
                status.charAt(0).toUpperCase() + status.slice(1).replace('_', ' ') + ' Document';
            
            verifyModal.show();
        }

        function requestResubmission(docId) {
            document.getElementById('resubmitDocId').value = docId;
            resubmitModal.show();
        }
    </script>
</body>
</html>
