<?php
/**
 * Admin: Create Coupon
 * Discount & Promotion Management
 */

require_once __DIR__ . '/../../includes/init.php';

// Security: Ensure user is an admin
Session::requireLogin();
RoleMiddleware::requireAdmin();

$page_title = 'Create New Coupon';
$errors = [];
$success = '';

// Form data
$code = '';
$type = 'percentage';
$value = '';
$min_purchase = '';
$max_discount = '';
$usage_limit = '';
$expires_at = '';
$status = 'active';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // CSRF validation
    if (!verifyCsrfToken($_POST['csrf_token'] ?? '')) {
        $errors[] = 'Invalid request. Please try again.';
    } else {
        // Sanitize and validate inputs
        $code = strtoupper(sanitizeInput($_POST['code'] ?? ''));
        $type = sanitizeInput($_POST['type'] ?? 'percentage');
        $value = filter_input(INPUT_POST, 'value', FILTER_VALIDATE_FLOAT);
        $min_purchase = filter_input(INPUT_POST, 'min_purchase', FILTER_VALIDATE_FLOAT);
        $max_discount = filter_input(INPUT_POST, 'max_discount', FILTER_VALIDATE_FLOAT);
        $usage_limit = filter_input(INPUT_POST, 'usage_limit', FILTER_VALIDATE_INT);
        $expires_at = sanitizeInput($_POST['expires_at'] ?? '');
        $status = sanitizeInput($_POST['status'] ?? 'active');
        $description = sanitizeInput($_POST['description'] ?? '');

        // Validation
        if (empty($code)) $errors[] = 'Coupon code is required.';
        if ($value === false || $value <= 0) $errors[] = 'A valid discount value is required.';
        if ($type === 'percentage' && $value > 100) $errors[] = 'Percentage cannot exceed 100%.';
        if (!in_array($type, ['percentage', 'fixed'])) $errors[] = 'Invalid coupon type.';

        if (empty($errors)) {
            try {
                $db = db();
                
                // Check if code already exists
                $stmt = $db->prepare("SELECT id FROM coupons WHERE code = ?");
                $stmt->execute([$code]);
                if ($stmt->fetch()) {
                    $errors[] = 'Coupon code already exists.';
                } else {
                    // Create coupon
                    $stmt = $db->prepare("
                        INSERT INTO coupons 
                        (code, type, value, min_purchase_amount, max_discount_amount, usage_limit, expires_at, status, description, created_at, updated_at)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
                    ");
                    
                    if ($stmt->execute([
                        $code, 
                        $type, 
                        $value, 
                        $min_purchase ?: null, 
                        $max_discount ?: null, 
                        $usage_limit ?: null, 
                        $expires_at ?: null, 
                        $status,
                        $description
                    ])) {
                        $_SESSION['success_message'] = 'Coupon created successfully!';
                        redirect('/admin/coupons/');
                    } else {
                        $errors[] = 'Failed to create coupon. Please try again.';
                    }
                }
            } catch (Exception $e) {
                $errors[] = 'Database error: ' . $e->getMessage();
            }
        }
    }
}

include_once __DIR__ . '/../../includes/admin_header.php';
?>

<div class="admin-container">
    <div class="admin-header">
        <div class="admin-header-left">
            <h1><?php echo htmlspecialchars($page_title); ?></h1>
            <p class="admin-subtitle">Create discount coupons and promotional codes</p>
        </div>
        <div class="admin-header-right">
            <a href="/admin/coupons/" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Coupons
            </a>
        </div>
    </div>

    <?php if (!empty($errors)): ?>
        <div class="alert alert-danger">
            <ul class="mb-0">
                <?php foreach ($errors as $error): ?>
                    <li><?php echo htmlspecialchars($error); ?></li>
                <?php endforeach; ?>
            </ul>
        </div>
    <?php endif; ?>

    <div class="card">
        <div class="card-body">
            <form method="POST" action="">
                <input type="hidden" name="csrf_token" value="<?php echo generateCsrfToken(); ?>">
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="code" class="form-label">Coupon Code *</label>
                        <input type="text" class="form-control" id="code" name="code" 
                               value="<?php echo htmlspecialchars($code); ?>" 
                               placeholder="SUMMER2024" style="text-transform: uppercase;" required>
                        <small class="form-text text-muted">Use uppercase letters and numbers (e.g., SAVE20)</small>
                    </div>
                    
                    <div class="col-md-6 mb-3">
                        <label for="type" class="form-label">Discount Type *</label>
                        <select class="form-control" id="type" name="type" required>
                            <option value="percentage" <?php echo $type === 'percentage' ? 'selected' : ''; ?>>Percentage (%)</option>
                            <option value="fixed" <?php echo $type === 'fixed' ? 'selected' : ''; ?>>Fixed Amount ($)</option>
                        </select>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="value" class="form-label">Discount Value *</label>
                        <input type="number" class="form-control" id="value" name="value" 
                               value="<?php echo htmlspecialchars($value); ?>" 
                               step="0.01" min="0" placeholder="10" required>
                        <small class="form-text text-muted">Percentage (1-100) or fixed amount</small>
                    </div>
                    
                    <div class="col-md-6 mb-3">
                        <label for="usage_limit" class="form-label">Usage Limit</label>
                        <input type="number" class="form-control" id="usage_limit" name="usage_limit" 
                               value="<?php echo htmlspecialchars($usage_limit); ?>" 
                               min="0" placeholder="Unlimited">
                        <small class="form-text text-muted">Leave empty for unlimited uses</small>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="min_purchase" class="form-label">Minimum Purchase Amount</label>
                        <input type="number" class="form-control" id="min_purchase" name="min_purchase" 
                               value="<?php echo htmlspecialchars($min_purchase); ?>" 
                               step="0.01" min="0" placeholder="0.00">
                        <small class="form-text text-muted">Minimum order total required</small>
                    </div>
                    
                    <div class="col-md-6 mb-3">
                        <label for="max_discount" class="form-label">Maximum Discount Amount</label>
                        <input type="number" class="form-control" id="max_discount" name="max_discount" 
                               value="<?php echo htmlspecialchars($max_discount); ?>" 
                               step="0.01" min="0" placeholder="Unlimited">
                        <small class="form-text text-muted">Cap for percentage discounts</small>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="expires_at" class="form-label">Expiration Date</label>
                        <input type="datetime-local" class="form-control" id="expires_at" name="expires_at" 
                               value="<?php echo htmlspecialchars($expires_at); ?>">
                        <small class="form-text text-muted">Leave empty for no expiration</small>
                    </div>
                    
                    <div class="col-md-6 mb-3">
                        <label for="status" class="form-label">Status *</label>
                        <select class="form-control" id="status" name="status" required>
                            <option value="active" <?php echo $status === 'active' ? 'selected' : ''; ?>>Active</option>
                            <option value="inactive" <?php echo $status === 'inactive' ? 'selected' : ''; ?>>Inactive</option>
                        </select>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label for="description" class="form-label">Description</label>
                    <textarea class="form-control" id="description" name="description" rows="3" 
                              placeholder="Optional description for internal use"><?php echo htmlspecialchars($description ?? ''); ?></textarea>
                </div>
                
                <div class="d-flex justify-content-end gap-2">
                    <a href="/admin/coupons/" class="btn btn-secondary">Cancel</a>
                    <button type="submit" class="btn btn-primary">Create Coupon</button>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
.admin-container {
    padding: 2rem;
    max-width: 1200px;
    margin: 0 auto;
}

.admin-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
}

.admin-subtitle {
    color: #6c757d;
    margin: 0;
}

.card {
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.card-body {
    padding: 2rem;
}

.form-label {
    font-weight: 500;
    margin-bottom: 0.5rem;
}

.form-control {
    padding: 0.5rem;
    border: 1px solid #ced4da;
    border-radius: 4px;
    width: 100%;
}

.btn {
    padding: 0.5rem 1rem;
    border-radius: 4px;
    text-decoration: none;
    display: inline-block;
    border: none;
    cursor: pointer;
}

.btn-primary {
    background: #0d6efd;
    color: white;
}

.btn-secondary {
    background: #6c757d;
    color: white;
}

.gap-2 {
    gap: 0.5rem;
}

.alert-danger {
    background: #f8d7da;
    border: 1px solid #f5c2c7;
    color: #842029;
    padding: 1rem;
    border-radius: 4px;
    margin-bottom: 1rem;
}
</style>

<?php include_once __DIR__ . '/../../includes/admin_footer.php'; ?>
