<?php
/**
 * Vendor Edit Page
 * Edit vendor profile and manage account access
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
        "SELECT v.*, u.username, u.email, u.id as user_id 
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

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    validateCsrfAndRateLimit();
    
    try {
        $action = $_POST['action'] ?? 'update';
        $admin_id = Session::getUserId();
        
        switch ($action) {
            case 'update':
                // Update vendor details
                Database::query(
                    "UPDATE vendors SET 
                        business_name = ?,
                        business_email = ?,
                        business_phone = ?,
                        business_type = ?,
                        tax_id = ?,
                        website = ?,
                        category = ?,
                        commission_rate = ?,
                        business_description = ?,
                        updated_at = NOW()
                     WHERE id = ?",
                    [
                        $_POST['business_name'],
                        $_POST['business_email'],
                        $_POST['business_phone'],
                        $_POST['business_type'],
                        $_POST['tax_id'],
                        $_POST['website'],
                        $_POST['category'],
                        $_POST['commission_rate'],
                        $_POST['business_description'],
                        $vendor_id
                    ]
                );
                
                // Log audit
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, reason, ip_address) 
                     VALUES (?, ?, 'profile_updated', 'profile_update', 'Profile information updated', ?)",
                    [$vendor_id, $admin_id, $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Vendor profile updated successfully.';
                break;
                
            case 'suspend':
                Database::query(
                    "UPDATE vendors SET status = 'suspended', suspended_by = ?, suspended_at = NOW(), suspension_reason = ? WHERE id = ?",
                    [$admin_id, $_POST['suspension_reason'] ?? '', $vendor_id]
                );
                
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, old_value, new_value, reason, ip_address) 
                     VALUES (?, ?, 'vendor_suspended', 'account_suspension', 'approved', 'suspended', ?, ?)",
                    [$vendor_id, $admin_id, $_POST['suspension_reason'] ?? 'Account suspended', $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Vendor account suspended.';
                break;
                
            case 'reactivate':
                Database::query(
                    "UPDATE vendors SET status = 'approved', suspended_by = NULL, suspended_at = NULL, suspension_reason = NULL WHERE id = ?",
                    [$vendor_id]
                );
                
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, old_value, new_value, reason, ip_address) 
                     VALUES (?, ?, 'vendor_reactivated', 'status_change', 'suspended', 'approved', 'Account reactivated', ?)",
                    [$vendor_id, $admin_id, $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Vendor account reactivated.';
                break;
                
            case 'reset_password':
                // Generate random password
                $new_password = bin2hex(random_bytes(8));
                $password_hash = password_hash($new_password, PASSWORD_DEFAULT);
                
                Database::query(
                    "UPDATE users SET pass_hash = ? WHERE id = ?",
                    [$password_hash, $vendor['user_id']]
                );
                
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, reason, ip_address) 
                     VALUES (?, ?, 'password_reset', 'other', 'Password reset by admin', ?)",
                    [$vendor_id, $admin_id, $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Password reset. New password: ' . $new_password;
                
                // Send email to vendor
                if (function_exists('sendEmail')) {
                    sendEmail(
                        $vendor['email'],
                        'Password Reset',
                        "Your password has been reset by an administrator.\n\nNew password: {$new_password}\n\nPlease change it after logging in."
                    );
                }
                break;
                
            case 'toggle_access':
                $new_status = $_POST['new_status'] ?? 'active';
                Database::query(
                    "UPDATE users SET status = ? WHERE id = ?",
                    [$new_status, $vendor['user_id']]
                );
                
                Database::query(
                    "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, new_value, reason, ip_address) 
                     VALUES (?, ?, 'access_toggled', 'other', ?, 'User access changed to {$new_status}', ?)",
                    [$vendor_id, $admin_id, $new_status, $_SERVER['REMOTE_ADDR'] ?? '']
                );
                
                $_SESSION['success_message'] = 'Vendor access updated.';
                break;
        }
        
        header('Location: /admin/vendors/show.php?id=' . $vendor_id);
        exit;
    } catch (Exception $e) {
        $_SESSION['error_message'] = $e->getMessage();
        Logger::error("Vendor edit error: " . $e->getMessage());
    }
}

$page_title = 'Edit Vendor: ' . htmlspecialchars($vendor['business_name']);
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
    </style>
</head>
<body>
    <!-- Admin Header -->
    <div class="admin-header">
        <div class="container-fluid">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="h3 mb-0">
                        <i class="fas fa-edit me-2"></i>
                        Edit Vendor
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

        <div class="row">
            <!-- Edit Form -->
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Vendor Information</h5>
                    </div>
                    <div class="card-body">
                        <form method="POST">
                            <?php echo csrfTokenInput(); ?>
                            <input type="hidden" name="action" value="update">
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Business Name *</label>
                                    <input type="text" class="form-control" name="business_name" 
                                           value="<?php echo htmlspecialchars($vendor['business_name']); ?>" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Business Type *</label>
                                    <select class="form-select" name="business_type" required>
                                        <option value="individual" <?php echo $vendor['business_type'] === 'individual' ? 'selected' : ''; ?>>Individual</option>
                                        <option value="business" <?php echo $vendor['business_type'] === 'business' ? 'selected' : ''; ?>>Business</option>
                                        <option value="corporation" <?php echo $vendor['business_type'] === 'corporation' ? 'selected' : ''; ?>>Corporation</option>
                                    </select>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Business Email</label>
                                    <input type="email" class="form-control" name="business_email" 
                                           value="<?php echo htmlspecialchars($vendor['business_email'] ?? ''); ?>">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Business Phone</label>
                                    <input type="tel" class="form-control" name="business_phone" 
                                           value="<?php echo htmlspecialchars($vendor['business_phone'] ?? ''); ?>">
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Tax ID</label>
                                    <input type="text" class="form-control" name="tax_id" 
                                           value="<?php echo htmlspecialchars($vendor['tax_id'] ?? ''); ?>">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Website</label>
                                    <input type="url" class="form-control" name="website" 
                                           value="<?php echo htmlspecialchars($vendor['website'] ?? ''); ?>">
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Category</label>
                                    <input type="text" class="form-control" name="category" 
                                           value="<?php echo htmlspecialchars($vendor['category'] ?? ''); ?>"
                                           placeholder="e.g., Electronics, Fashion, Food">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Commission Rate (%)</label>
                                    <input type="number" class="form-control" name="commission_rate" 
                                           value="<?php echo $vendor['commission_rate']; ?>" 
                                           min="0" max="100" step="0.01" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Business Description</label>
                                <textarea class="form-control" name="business_description" rows="4"><?php echo htmlspecialchars($vendor['business_description'] ?? ''); ?></textarea>
                            </div>

                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save me-2"></i> Save Changes
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Account Controls -->
            <div class="col-lg-4">
                <div class="card mb-3">
                    <div class="card-header">
                        <h5 class="mb-0">Account Controls</h5>
                    </div>
                    <div class="card-body">
                        <?php if ($vendor['status'] === 'approved'): ?>
                        <button type="button" class="btn btn-warning w-100 mb-2" data-bs-toggle="modal" data-bs-target="#suspendModal">
                            <i class="fas fa-pause me-2"></i> Suspend Account
                        </button>
                        <?php elseif ($vendor['status'] === 'suspended'): ?>
                        <form method="POST" class="mb-2">
                            <?php echo csrfTokenInput(); ?>
                            <input type="hidden" name="action" value="reactivate">
                            <button type="submit" class="btn btn-success w-100" onclick="return confirm('Reactivate this vendor account?')">
                                <i class="fas fa-play me-2"></i> Reactivate Account
                            </button>
                        </form>
                        <?php endif; ?>
                        
                        <button type="button" class="btn btn-secondary w-100 mb-2" data-bs-toggle="modal" data-bs-target="#resetPasswordModal">
                            <i class="fas fa-key me-2"></i> Reset Password
                        </button>
                        
                        <button type="button" class="btn btn-info w-100 mb-2" data-bs-toggle="modal" data-bs-target="#toggleAccessModal">
                            <i class="fas fa-toggle-on me-2"></i> Toggle Access
                        </button>
                        
                        <a href="/admin/vendors/kyc.php?id=<?php echo $vendor_id; ?>" class="btn btn-outline-primary w-100">
                            <i class="fas fa-id-card me-2"></i> Manage KYC
                        </a>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Quick Links</h5>
                    </div>
                    <div class="card-body">
                        <div class="d-grid gap-2">
                            <a href="/admin/products/?vendor=<?php echo $vendor['user_id']; ?>" class="btn btn-outline-secondary">
                                <i class="fas fa-box me-2"></i> View Products
                            </a>
                            <a href="/admin/orders/?vendor=<?php echo $vendor['user_id']; ?>" class="btn btn-outline-secondary">
                                <i class="fas fa-shopping-cart me-2"></i> View Orders
                            </a>
                            <a href="/admin/payouts/?vendor=<?php echo $vendor['user_id']; ?>" class="btn btn-outline-secondary">
                                <i class="fas fa-money-bill-wave me-2"></i> View Payouts
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modals -->
    <div class="modal fade" id="suspendModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST">
                    <?php echo csrfTokenInput(); ?>
                    <input type="hidden" name="action" value="suspend">
                    <div class="modal-header">
                        <h5 class="modal-title">Suspend Vendor Account</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="alert alert-warning">
                            <i class="fas fa-exclamation-triangle me-2"></i>
                            This will prevent the vendor from selling products.
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Suspension Reason *</label>
                            <textarea class="form-control" name="suspension_reason" rows="4" required
                                      placeholder="Explain why this account is being suspended..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-warning">Suspend Account</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="resetPasswordModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST">
                    <?php echo csrfTokenInput(); ?>
                    <input type="hidden" name="action" value="reset_password">
                    <div class="modal-header">
                        <h5 class="modal-title">Reset Vendor Password</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="alert alert-info">
                            <i class="fas fa-info-circle me-2"></i>
                            A new random password will be generated and sent to the vendor's email.
                        </div>
                        <p>Are you sure you want to reset the password for <strong><?php echo htmlspecialchars($vendor['email']); ?></strong>?</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Reset Password</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="toggleAccessModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST">
                    <?php echo csrfTokenInput(); ?>
                    <input type="hidden" name="action" value="toggle_access">
                    <div class="modal-header">
                        <h5 class="modal-title">Toggle Vendor Access</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Set User Status</label>
                            <select class="form-select" name="new_status" required>
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                                <option value="banned">Banned</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-info">Update Access</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
