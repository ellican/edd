<?php
/**
 * Floating Shopping Cart Panel
 * Professional floating cart that slides in from the right
 * Can be triggered from anywhere on the site
 */

// Get cart data if user is logged in
$floatingCartItems = [];
$floatingCartTotal = 0;
$floatingCartCount = 0;

if (Session::isLoggedIn()) {
    try {
        $pdo = db();
        $userId = Session::getUserId();
        
        // Get cart items with product details
        $stmt = $pdo->prepare("
            SELECT c.*, p.name, p.price, p.image_url, p.slug, v.business_name as vendor_name
            FROM cart c
            INNER JOIN products p ON c.product_id = p.id
            LEFT JOIN vendors v ON p.vendor_id = v.id
            WHERE c.user_id = ?
            ORDER BY c.created_at DESC
        ");
        $stmt->execute([$userId]);
        $floatingCartItems = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Calculate total
        foreach ($floatingCartItems as $item) {
            $floatingCartTotal += $item['price'] * $item['quantity'];
            $floatingCartCount += $item['quantity'];
        }
    } catch (Exception $e) {
        error_log("Floating cart error: " . $e->getMessage());
    }
}
?>

<!-- Floating Cart Overlay -->
<div class="floating-cart-overlay" id="floatingCartOverlay" style="display: none;"></div>

<!-- Floating Cart Panel -->
<div class="floating-cart-panel" id="floatingCartPanel">
    <div class="floating-cart-header">
        <h3>
            <i class="fas fa-shopping-cart"></i>
            Shopping Cart
            <?php if ($floatingCartCount > 0): ?>
                <span class="cart-count-badge">(<?php echo $floatingCartCount; ?>)</span>
            <?php endif; ?>
        </h3>
        <button class="floating-cart-close" id="closeFloatingCart" aria-label="Close cart">
            <i class="fas fa-times"></i>
        </button>
    </div>
    
    <div class="floating-cart-content">
        <?php if (empty($floatingCartItems)): ?>
            <div class="floating-cart-empty">
                <i class="fas fa-shopping-cart empty-cart-icon"></i>
                <h4>Your cart is empty</h4>
                <p>Add items to get started!</p>
                <a href="/products.php" class="btn btn-primary">Start Shopping</a>
            </div>
        <?php else: ?>
            <div class="floating-cart-items">
                <?php foreach ($floatingCartItems as $item): ?>
                    <div class="floating-cart-item" data-product-id="<?php echo $item['product_id']; ?>">
                        <div class="item-image">
                            <?php 
                            $imageUrl = $item['image_url'] ?? '/images/placeholder-product.jpg';
                            if (!empty($imageUrl) && $imageUrl[0] === '/') {
                                $imageUrl = $imageUrl;
                            } elseif (empty($imageUrl) || $imageUrl === 'placeholder.jpg') {
                                $imageUrl = '/images/placeholder-product.jpg';
                            }
                            ?>
                            <img src="<?php echo htmlspecialchars($imageUrl); ?>" 
                                 alt="<?php echo htmlspecialchars($item['name']); ?>">
                        </div>
                        <div class="item-details">
                            <h4 class="item-name">
                                <a href="/product.php?id=<?php echo $item['product_id']; ?>">
                                    <?php echo htmlspecialchars($item['name']); ?>
                                </a>
                            </h4>
                            <?php if (!empty($item['vendor_name'])): ?>
                                <p class="item-vendor">by <?php echo htmlspecialchars($item['vendor_name']); ?></p>
                            <?php endif; ?>
                            <div class="item-price-qty">
                                <span class="item-price"><?php echo formatPrice($item['price']); ?></span>
                                <div class="item-quantity">
                                    <button class="qty-btn qty-decrease" data-product-id="<?php echo $item['product_id']; ?>">
                                        <i class="fas fa-minus"></i>
                                    </button>
                                    <input type="number" 
                                           class="qty-input" 
                                           value="<?php echo $item['quantity']; ?>" 
                                           min="1" 
                                           max="99"
                                           data-product-id="<?php echo $item['product_id']; ?>"
                                           readonly>
                                    <button class="qty-btn qty-increase" data-product-id="<?php echo $item['product_id']; ?>">
                                        <i class="fas fa-plus"></i>
                                    </button>
                                </div>
                            </div>
                            <button class="item-remove" data-product-id="<?php echo $item['product_id']; ?>">
                                <i class="fas fa-trash"></i> Remove
                            </button>
                        </div>
                        <div class="item-total">
                            <?php echo formatPrice($item['price'] * $item['quantity']); ?>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>
    
    <?php if (!empty($floatingCartItems)): ?>
        <div class="floating-cart-footer">
            <div class="cart-summary">
                <div class="summary-row">
                    <span>Subtotal:</span>
                    <span class="cart-subtotal"><?php echo formatPrice($floatingCartTotal); ?></span>
                </div>
                <?php if ($floatingCartTotal < 50 && $floatingCartTotal > 0): ?>
                    <div class="free-shipping-notice">
                        <i class="fas fa-shipping-fast"></i>
                        Add <?php echo formatPrice(50 - $floatingCartTotal); ?> more for free shipping!
                    </div>
                <?php endif; ?>
            </div>
            <div class="cart-actions">
                <a href="/cart.php" class="btn btn-secondary btn-block">View Cart</a>
                <a href="/checkout.php" class="btn btn-primary btn-block">
                    <i class="fas fa-lock"></i> Proceed to Checkout
                </a>
            </div>
        </div>
    <?php endif; ?>
</div>

<style>
/* Floating Cart Overlay */
.floating-cart-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    z-index: 9998;
    opacity: 0;
    transition: opacity 0.3s ease;
}

.floating-cart-overlay.active {
    opacity: 1;
}

/* Floating Cart Panel */
.floating-cart-panel {
    position: fixed;
    top: 0;
    right: -420px; /* Hidden off-screen initially */
    width: 420px;
    max-width: 90vw;
    height: 100vh;
    background: #ffffff;
    box-shadow: -2px 0 20px rgba(0, 0, 0, 0.15);
    z-index: 9999;
    display: flex;
    flex-direction: column;
    transition: right 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.floating-cart-panel.active {
    right: 0;
}

/* Cart Header */
.floating-cart-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 24px;
    border-bottom: 1px solid #e5e7eb;
    background: #f9fafb;
}

.floating-cart-header h3 {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
    color: #1f2937;
    display: flex;
    align-items: center;
    gap: 8px;
}

.cart-count-badge {
    background: #3b82f6;
    color: white;
    padding: 2px 8px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
}

.floating-cart-close {
    background: none;
    border: none;
    font-size: 20px;
    color: #6b7280;
    cursor: pointer;
    padding: 8px;
    width: 36px;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 6px;
    transition: background 0.2s ease;
}

.floating-cart-close:hover {
    background: #e5e7eb;
    color: #1f2937;
}

/* Cart Content */
.floating-cart-content {
    flex: 1;
    overflow-y: auto;
    padding: 16px;
}

.floating-cart-empty {
    text-align: center;
    padding: 60px 20px;
    color: #6b7280;
}

.empty-cart-icon {
    font-size: 64px;
    color: #d1d5db;
    margin-bottom: 16px;
}

.floating-cart-empty h4 {
    color: #1f2937;
    margin-bottom: 8px;
}

.floating-cart-empty p {
    margin-bottom: 24px;
}

/* Cart Items */
.floating-cart-items {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.floating-cart-item {
    display: flex;
    gap: 12px;
    padding: 12px;
    background: #f9fafb;
    border-radius: 8px;
    position: relative;
}

.item-image {
    width: 80px;
    height: 80px;
    flex-shrink: 0;
}

.item-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 6px;
}

.item-details {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.item-name {
    margin: 0;
    font-size: 14px;
    font-weight: 600;
    color: #1f2937;
    line-height: 1.4;
}

.item-name a {
    color: inherit;
    text-decoration: none;
}

.item-name a:hover {
    color: #3b82f6;
}

.item-vendor {
    margin: 0;
    font-size: 12px;
    color: #6b7280;
}

.item-price-qty {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-top: auto;
}

.item-price {
    font-weight: 600;
    color: #1f2937;
    font-size: 14px;
}

.item-quantity {
    display: flex;
    align-items: center;
    gap: 4px;
    background: white;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    padding: 2px;
}

.qty-btn {
    background: none;
    border: none;
    width: 24px;
    height: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    color: #6b7280;
    border-radius: 4px;
    transition: all 0.2s ease;
}

.qty-btn:hover {
    background: #f3f4f6;
    color: #1f2937;
}

.qty-input {
    width: 32px;
    text-align: center;
    border: none;
    background: none;
    font-weight: 600;
    color: #1f2937;
    font-size: 13px;
}

.item-remove {
    background: none;
    border: none;
    color: #ef4444;
    font-size: 12px;
    cursor: pointer;
    padding: 4px 0;
    text-align: left;
    transition: color 0.2s ease;
}

.item-remove:hover {
    color: #dc2626;
}

.item-total {
    font-weight: 700;
    color: #1f2937;
    font-size: 15px;
    text-align: right;
}

/* Cart Footer */
.floating-cart-footer {
    border-top: 1px solid #e5e7eb;
    padding: 20px 24px;
    background: #f9fafb;
}

.cart-summary {
    margin-bottom: 16px;
}

.summary-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
    font-size: 16px;
}

.cart-subtotal {
    font-weight: 700;
    color: #1f2937;
    font-size: 18px;
}

.free-shipping-notice {
    background: #dbeafe;
    color: #1e40af;
    padding: 8px 12px;
    border-radius: 6px;
    font-size: 12px;
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 12px;
}

.cart-actions {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.btn-block {
    width: 100%;
    text-align: center;
    padding: 12px 20px;
    font-weight: 600;
    border-radius: 8px;
    text-decoration: none;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    transition: all 0.2s ease;
}

.btn-primary {
    background: #3b82f6;
    color: white;
    border: none;
}

.btn-primary:hover {
    background: #2563eb;
}

.btn-secondary {
    background: white;
    color: #1f2937;
    border: 1px solid #d1d5db;
}

.btn-secondary:hover {
    background: #f9fafb;
    border-color: #9ca3af;
}

/* Responsive Design */
@media (max-width: 768px) {
    .floating-cart-panel {
        width: 100%;
        max-width: 100%;
        right: -100%;
    }
    
    .floating-cart-panel.active {
        right: 0;
    }
}

/* Scrollbar Styling */
.floating-cart-content::-webkit-scrollbar {
    width: 6px;
}

.floating-cart-content::-webkit-scrollbar-track {
    background: #f1f1f1;
}

.floating-cart-content::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 3px;
}

.floating-cart-content::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
}
</style>

<script>
// Floating Cart JavaScript
(function() {
    const panel = document.getElementById('floatingCartPanel');
    const overlay = document.getElementById('floatingCartOverlay');
    const closeBtn = document.getElementById('closeFloatingCart');
    
    // Open floating cart
    window.openFloatingCart = function() {
        panel.classList.add('active');
        overlay.style.display = 'block';
        setTimeout(() => overlay.classList.add('active'), 10);
        document.body.style.overflow = 'hidden';
    };
    
    // Close floating cart
    window.closeFloatingCart = function() {
        panel.classList.remove('active');
        overlay.classList.remove('active');
        setTimeout(() => {
            overlay.style.display = 'none';
            document.body.style.overflow = '';
        }, 300);
    };
    
    // Close button click
    if (closeBtn) {
        closeBtn.addEventListener('click', closeFloatingCart);
    }
    
    // Overlay click
    if (overlay) {
        overlay.addEventListener('click', closeFloatingCart);
    }
    
    // ESC key to close
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && panel.classList.contains('active')) {
            closeFloatingCart();
        }
    });
    
    // Quantity controls
    document.querySelectorAll('.qty-decrease').forEach(btn => {
        btn.addEventListener('click', function() {
            const productId = this.dataset.productId;
            const input = document.querySelector(`.qty-input[data-product-id="${productId}"]`);
            const currentQty = parseInt(input.value);
            if (currentQty > 1) {
                updateCartQuantity(productId, currentQty - 1);
            }
        });
    });
    
    document.querySelectorAll('.qty-increase').forEach(btn => {
        btn.addEventListener('click', function() {
            const productId = this.dataset.productId;
            const input = document.querySelector(`.qty-input[data-product-id="${productId}"]`);
            const currentQty = parseInt(input.value);
            if (currentQty < 99) {
                updateCartQuantity(productId, currentQty + 1);
            }
        });
    });
    
    // Remove item
    document.querySelectorAll('.item-remove').forEach(btn => {
        btn.addEventListener('click', function() {
            const productId = this.dataset.productId;
            if (confirm('Remove this item from your cart?')) {
                removeFromCart(productId);
            }
        });
    });
    
    // Update cart quantity via AJAX
    function updateCartQuantity(productId, quantity) {
        fetch('/api/cart.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                action: 'update',
                product_id: productId,
                quantity: quantity
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Reload page to update cart
                location.reload();
            } else {
                alert(data.message || 'Failed to update cart');
            }
        })
        .catch(error => {
            console.error('Cart update error:', error);
            alert('Failed to update cart');
        });
    }
    
    // Remove from cart via AJAX
    function removeFromCart(productId) {
        fetch('/api/cart.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                action: 'remove',
                product_id: productId
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Reload page to update cart
                location.reload();
            } else {
                alert(data.message || 'Failed to remove item');
            }
        })
        .catch(error => {
            console.error('Cart remove error:', error);
            alert('Failed to remove item');
        });
    }
    
    // Update cart icon click to open floating cart instead of navigating
    document.addEventListener('DOMContentLoaded', function() {
        const cartLinks = document.querySelectorAll('a[href="/cart.php"]');
        cartLinks.forEach(link => {
            // Add click handler but only for the icon, not the full cart page link
            if (link.classList.contains('ebay-header-icon')) {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    openFloatingCart();
                });
            }
        });
    });
})();
</script>
