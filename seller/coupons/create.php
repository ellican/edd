<?php
/**
 * Create Coupon - Seller Interface
 */

require_once __DIR__ . '/../../includes/init.php';

Session::requireLogin();

$userId = Session::getUserId();
$userRole = Session::get('user_role');

// Check if user is seller
if ($userRole !== 'seller' && $userRole !== 'vendor') {
    redirect('/seller/dashboard.php');
}

// Get vendor ID
$vendor = new Vendor();
$vendorInfo = $vendor->findByUserId($userId);
if (!$vendorInfo) {
    redirect('/seller-onboarding.php');
}
$vendorId = $vendorInfo['id'];

$error = '';
$success = '';

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $code = strtoupper(trim($_POST['code'] ?? ''));
        $name = trim($_POST['name'] ?? '');
        $type = $_POST['type'] ?? 'percentage';
        $value = floatval($_POST['value'] ?? 0);
        $minPurchase = floatval($_POST['min_purchase'] ?? 0);
        $maxDiscount = !empty($_POST['max_discount']) ? floatval($_POST['max_discount']) : null;
        $usageLimit = !empty($_POST['usage_limit']) ? intval($_POST['usage_limit']) : null;
        $appliesTo = $_POST['applies_to'] ?? 'all';
        $products = $_POST['products'] ?? [];
        $startDate = $_POST['start_date'] ?? null;
        $endDate = $_POST['end_date'] ?? null;
        
        // Validation
        if (empty($code)) {
            throw new Exception('Coupon code is required');
        }
        
        if (strlen($code) < 4 || strlen($code) > 20) {
            throw new Exception('Coupon code must be between 4 and 20 characters');
        }
        
        if (!preg_match('/^[A-Z0-9_-]+$/', $code)) {
            throw new Exception('Coupon code can only contain letters, numbers, underscores and hyphens');
        }
        
        if ($value <= 0) {
            throw new Exception('Coupon value must be greater than 0');
        }
        
        if ($type === 'percentage' && $value > 100) {
            throw new Exception('Percentage discount cannot exceed 100%');
        }
        
        if ($type === 'fixed' && $value > 10000) {
            throw new Exception('Fixed discount seems too high');
        }
        
        // Check if code already exists for this seller
        $db = db();
        $checkStmt = $db->prepare("SELECT id FROM coupons WHERE seller_id = ? AND code = ?");
        $checkStmt->execute([$vendorId, $code]);
        if ($checkStmt->fetch()) {
            throw new Exception('You already have a coupon with this code');
        }
        
        // Prepare product JSON
        $applicableProducts = null;
        if ($appliesTo === 'specific' && !empty($products)) {
            $applicableProducts = json_encode(array_map('intval', $products));
        }
        
        // Insert coupon
        $stmt = $db->prepare("
            INSERT INTO coupons 
            (seller_id, code, name, type, value, min_purchase_amount, max_discount_amount, usage_limit, applies_to, applicable_products, start_date, end_date, status, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', NOW())
        ");
        $stmt->execute([
            $vendorId,
            $code,
            $name,
            $type,
            $value,
            $minPurchase,
            $maxDiscount,
            $usageLimit,
            $appliesTo,
            $applicableProducts,
            $startDate,
            $endDate
        ]);
        
        $success = 'Coupon created successfully!';
        
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}

// Get seller's products for product selection
$db = db();
$productsStmt = $db->prepare("SELECT id, name, price FROM products WHERE vendor_id = ? AND status = 'active' ORDER BY name");
$productsStmt->execute([$vendorId]);
$sellerProducts = $productsStmt->fetchAll(PDO::FETCH_ASSOC);

$page_title = 'Create Coupon';
include __DIR__ . '/../../includes/header.php';
?>

<style>
.coupons-container {
    max-width: 900px;
    margin: 40px auto;
    padding: 0 20px;
}

.page-header {
    margin-bottom: 30px;
}

.page-header h1 {
    font-size: 2rem;
    font-weight: 700;
    margin-bottom: 10px;
}

.page-header p {
    color: #666;
}

.coupon-form {
    background: white;
    border-radius: 8px;
    padding: 30px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    margin-bottom: 30px;
}

.form-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;
}

.form-group {
    margin-bottom: 20px;
}

.form-group.full-width {
    grid-column: 1 / -1;
}

.form-label {
    display: block;
    font-weight: 600;
    margin-bottom: 8px;
    color: #333;
}

.form-label .required {
    color: #f44336;
}

.form-input,
.form-select,
.form-textarea {
    width: 100%;
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
}

.form-input:focus,
.form-select:focus {
    outline: none;
    border-color: #4285f4;
}

.form-help {
    font-size: 0.85rem;
    color: #666;
    margin-top: 5px;
}

.btn {
    padding: 12px 24px;
    border-radius: 4px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    border: none;
}

.btn-primary {
    background: #4285f4;
    color: white;
}

.btn-primary:hover {
    background: #3367d6;
}

.btn-secondary {
    background: #e0e0e0;
    color: #333;
    margin-left: 10px;
}

.btn-secondary:hover {
    background: #d0d0d0;
}

.btn-generate {
    padding: 10px 20px;
    background: #f5f5f5;
    border: 1px solid #ddd;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
}

.btn-generate:hover {
    background: #e8e8e8;
}

.alert {
    padding: 15px;
    margin-bottom: 20px;
    border-radius: 4px;
}

.alert-success {
    background: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
}

.alert-error {
    background: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
}

.product-selector {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 10px;
    max-height: 300px;
    overflow-y: auto;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
}

.product-checkbox {
    display: flex;
    align-items: center;
    gap: 8px;
}

.product-checkbox input[type="checkbox"] {
    width: 18px;
    height: 18px;
}

.product-checkbox label {
    font-size: 14px;
    cursor: pointer;
}

.value-preview {
    margin-top: 10px;
    padding: 10px;
    background: #f5f7fa;
    border-radius: 4px;
    font-weight: 600;
    color: #333;
}

@media (max-width: 768px) {
    .form-grid {
        grid-template-columns: 1fr;
    }
}
</style>

<div class="coupons-container">
    <div class="page-header">
        <h1>Create Coupon</h1>
        <p>Create discount coupons for your products</p>
    </div>
    
    <?php if ($error): ?>
        <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
    <?php endif; ?>
    
    <?php if ($success): ?>
        <div class="alert alert-success">
            <?= htmlspecialchars($success) ?>
            <a href="/seller/coupons/manage.php" style="margin-left: 15px;">View all coupons</a>
        </div>
    <?php endif; ?>
    
    <div class="coupon-form">
        <form method="POST" id="couponForm">
            <div class="form-grid">
                <div class="form-group">
                    <label class="form-label">
                        Coupon Code <span class="required">*</span>
                    </label>
                    <div style="display: flex; gap: 10px;">
                        <input type="text" id="code" name="code" class="form-input" 
                               placeholder="e.g., SUMMER2024" 
                               pattern="[A-Z0-9_-]+" 
                               maxlength="20"
                               required
                               style="text-transform: uppercase;">
                        <button type="button" onclick="generateCode()" class="btn-generate">
                            🎲 Generate
                        </button>
                    </div>
                    <small class="form-help">Letters, numbers, underscores and hyphens only</small>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Name/Description</label>
                    <input type="text" name="name" class="form-input" placeholder="e.g., Summer Sale 2024">
                    <small class="form-help">Internal name for this coupon</small>
                </div>
                
                <div class="form-group">
                    <label class="form-label">
                        Discount Type <span class="required">*</span>
                    </label>
                    <select name="type" id="discountType" class="form-select" onchange="updateValuePreview()" required>
                        <option value="percentage">Percentage Discount</option>
                        <option value="fixed">Fixed Amount Discount</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">
                        Discount Value <span class="required">*</span>
                    </label>
                    <input type="number" name="value" id="discountValue" class="form-input" 
                           step="0.01" min="0.01" placeholder="e.g., 10" onchange="updateValuePreview()" required>
                    <div id="valuePreview" class="value-preview" style="display: none;"></div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Minimum Purchase Amount ($)</label>
                    <input type="number" name="min_purchase" class="form-input" 
                           step="0.01" min="0" value="0" placeholder="0.00">
                    <small class="form-help">Minimum order total required</small>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Maximum Discount Amount ($)</label>
                    <input type="number" name="max_discount" class="form-input" 
                           step="0.01" min="0" placeholder="Optional">
                    <small class="form-help">Cap for percentage discounts</small>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Usage Limit</label>
                    <input type="number" name="usage_limit" class="form-input" 
                           min="1" placeholder="Unlimited">
                    <small class="form-help">Maximum number of times this coupon can be used</small>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Applies To</label>
                    <select name="applies_to" id="appliesTo" class="form-select" onchange="toggleProductSelector()">
                        <option value="all">All My Products</option>
                        <option value="specific">Specific Products</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Start Date</label>
                    <input type="datetime-local" name="start_date" class="form-input">
                    <small class="form-help">Leave empty to start immediately</small>
                </div>
                
                <div class="form-group">
                    <label class="form-label">End Date</label>
                    <input type="datetime-local" name="end_date" class="form-input">
                    <small class="form-help">Leave empty for no expiration</small>
                </div>
                
                <div class="form-group full-width" id="productSelectorGroup" style="display: none;">
                    <label class="form-label">Select Products</label>
                    <div class="product-selector">
                        <?php if (!empty($sellerProducts)): ?>
                            <?php foreach ($sellerProducts as $product): ?>
                                <div class="product-checkbox">
                                    <input type="checkbox" name="products[]" value="<?= $product['id'] ?>" id="product_<?= $product['id'] ?>">
                                    <label for="product_<?= $product['id'] ?>">
                                        <?= htmlspecialchars($product['name']) ?> ($<?= number_format($product['price'], 2) ?>)
                                    </label>
                                </div>
                            <?php endforeach; ?>
                        <?php else: ?>
                            <p style="color: #666;">No active products found</p>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
            
            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #e0e0e0;">
                <button type="submit" class="btn btn-primary">Create Coupon</button>
                <a href="/seller/coupons/manage.php" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
function generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 10; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    document.getElementById('code').value = code;
}

function toggleProductSelector() {
    const appliesTo = document.getElementById('appliesTo').value;
    const selector = document.getElementById('productSelectorGroup');
    selector.style.display = appliesTo === 'specific' ? 'block' : 'none';
}

function updateValuePreview() {
    const type = document.getElementById('discountType').value;
    const value = parseFloat(document.getElementById('discountValue').value) || 0;
    const preview = document.getElementById('valuePreview');
    
    if (value > 0) {
        if (type === 'percentage') {
            preview.textContent = `${value}% off`;
        } else {
            preview.textContent = `$${value.toFixed(2)} off`;
        }
        preview.style.display = 'block';
    } else {
        preview.style.display = 'none';
    }
}
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
