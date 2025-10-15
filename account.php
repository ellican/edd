<?php
/**
 * User Account Management Page
 * Comprehensive account dashboard with profile, orders, addresses, wishlist, and more
 */

require_once __DIR__ . '/includes/init.php';

// Require user login
Session::requireLogin();

$db = db();
$userId = Session::getUserId();

// Get user information
$userQuery = "SELECT * FROM users WHERE id = ?";
$userStmt = $db->prepare($userQuery);
$userStmt->execute([$userId]);
$user = $userStmt->fetch();

// Get user statistics
$orderCountQuery = "SELECT COUNT(*) as count FROM orders WHERE user_id = ?";
$orderCountStmt = $db->prepare($orderCountQuery);
$orderCountStmt->execute([$userId]);
$orderStats = $orderCountStmt->fetch();

$addressCountQuery = "SELECT COUNT(*) as count FROM addresses WHERE user_id = ?";
$addressCountStmt = $db->prepare($addressCountQuery);
$addressCountStmt->execute([$userId]);
$addressStats = $addressCountStmt->fetch();

$wishlistCountQuery = "SELECT COUNT(*) as count FROM wishlists WHERE user_id = ?";
$wishlistCountStmt = $db->prepare($wishlistCountQuery);
$wishlistCountStmt->execute([$userId]);
$wishlistStats = $wishlistCountStmt->fetch();

$page_title = 'My Account';
includeHeader($page_title);
?>

<link rel="stylesheet" href="/css/account.css">

<div class="container" style="margin-top: 2rem; margin-bottom: 2rem;">
    <div class="account-header">
        <h1>My Account</h1>
        <p class="account-subtitle">Welcome back, <?php echo htmlspecialchars($user['first_name'] . ' ' . $user['last_name']); ?></p>
    </div>

    <!-- Tab Navigation -->
    <nav class="account-navigation">
        <div class="nav-tabs">
            <a href="#overview" class="nav-tab active" data-tab="overview">
                <i class="fas fa-home"></i>
                <span>Overview</span>
            </a>
            <a href="#orders" class="nav-tab" data-tab="orders">
                <i class="fas fa-shopping-bag"></i>
                <span>Orders</span>
            </a>
            <a href="#addresses" class="nav-tab" data-tab="addresses">
                <i class="fas fa-map-marker-alt"></i>
                <span>Address Book</span>
            </a>
            <a href="#wishlist" class="nav-tab" data-tab="wishlist">
                <i class="fas fa-heart"></i>
                <span>Wishlist</span>
            </a>
            <a href="#payment-methods" class="nav-tab" data-tab="payment-methods">
                <i class="fas fa-credit-card"></i>
                <span>Payment Methods</span>
            </a>
            <a href="#wallet" class="nav-tab" data-tab="wallet">
                <i class="fas fa-wallet"></i>
                <span>Wallet</span>
            </a>
            <a href="#notifications" class="nav-tab" data-tab="notifications">
                <i class="fas fa-bell"></i>
                <span>Notifications</span>
            </a>
            <a href="#security" class="nav-tab" data-tab="security">
                <i class="fas fa-shield-alt"></i>
                <span>Security</span>
            </a>
            <a href="#support" class="nav-tab" data-tab="support">
                <i class="fas fa-life-ring"></i>
                <span>Support</span>
            </a>
            <a href="#tracking" class="nav-tab" data-tab="tracking">
                <i class="fas fa-shipping-fast"></i>
                <span>Track Order</span>
            </a>
        </div>
    </nav>

    <!-- Account Content -->
    <div class="account-content">
        <!-- Overview Tab -->
        <div id="overview" class="tab-content active">
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-number"><?php echo $orderStats['count'] ?? 0; ?></div>
                    <div class="stat-label">Total Orders</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><?php echo $addressStats['count'] ?? 0; ?></div>
                    <div class="stat-label">Saved Addresses</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><?php echo $wishlistStats['count'] ?? 0; ?></div>
                    <div class="stat-label">Wishlist Items</div>
                </div>
            </div>

            <!-- Profile Information Card -->
            <div class="card">
                <div class="card-header">
                    <h3>Profile Information</h3>
                    <button class="btn btn-primary" onclick="editProfile()">Edit Profile</button>
                </div>
                <div class="card-body">
                    <div class="profile-info-grid">
                        <div class="profile-info-item">
                            <label>Full Name</label>
                            <p><?php echo htmlspecialchars($user['first_name'] . ' ' . $user['last_name']); ?></p>
                        </div>
                        <div class="profile-info-item">
                            <label>Email</label>
                            <p><?php echo htmlspecialchars($user['email']); ?></p>
                        </div>
                        <div class="profile-info-item">
                            <label>Phone Number</label>
                            <p><?php echo htmlspecialchars($user['phone'] ?? 'Not provided'); ?></p>
                        </div>
                        <div class="profile-info-item">
                            <label>Account Status</label>
                            <p>
                                <span class="badge badge-<?php echo $user['status'] === 'active' ? 'success' : 'warning'; ?>">
                                    <?php echo ucfirst($user['status']); ?>
                                </span>
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="card">
                <div class="card-header">
                    <h3>Quick Actions</h3>
                </div>
                <div class="card-body">
                    <div class="quick-actions">
                        <a href="#orders" class="action-btn" onclick="switchTab('orders')">
                            <i class="fas fa-shopping-bag"></i>
                            <span>View Orders</span>
                        </a>
                        <a href="/products.php" class="action-btn">
                            <i class="fas fa-shopping-cart"></i>
                            <span>Continue Shopping</span>
                        </a>
                        <a href="#addresses" class="action-btn" onclick="switchTab('addresses')">
                            <i class="fas fa-map-marker-alt"></i>
                            <span>Manage Addresses</span>
                        </a>
                        <a href="#security" class="action-btn" onclick="switchTab('security')">
                            <i class="fas fa-key"></i>
                            <span>Change Password</span>
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Orders Tab -->
        <div id="orders" class="tab-content">
            <div class="card">
                <div class="card-header">
                    <h3>Order History</h3>
                    <a href="/products.php" class="btn btn-primary">Continue Shopping</a>
                </div>
                <div class="card-body">
                    <div id="orders-list">
                        <p class="text-center text-muted">Loading orders...</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Addresses Tab -->
        <div id="addresses" class="tab-content">
            <div class="card">
                <div class="card-header">
                    <h3>Address Book</h3>
                    <button class="btn btn-primary" onclick="addAddress()">Add New Address</button>
                </div>
                <div class="card-body">
                    <div id="addresses-list">
                        <p class="text-center text-muted">Loading addresses...</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Wishlist Tab -->
        <div id="wishlist" class="tab-content">
            <div class="card">
                <div class="card-header">
                    <h3>My Wishlist</h3>
                    <a href="/products.php" class="btn btn-primary">Browse Products</a>
                </div>
                <div class="card-body">
                    <div id="wishlist-items">
                        <p class="text-center text-muted">Loading wishlist...</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Payment Methods Tab -->
        <div id="payment-methods" class="tab-content">
            <div class="card">
                <div class="card-header">
                    <h3>Payment Methods</h3>
                    <button class="btn btn-primary" onclick="addPaymentMethod()">Add Payment Method</button>
                </div>
                <div class="card-body">
                    <div id="payment-methods-list">
                        <p class="text-center text-muted">Loading payment methods...</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Wallet Tab -->
        <div id="wallet" class="tab-content">
            <div class="card">
                <div class="card-header">
                    <h3>My Wallet</h3>
                    <div class="btn-group">
                        <button class="btn btn-success" onclick="showAddFundsModal()">
                            <i class="fas fa-plus"></i> Add Funds
                        </button>
                        <button class="btn btn-primary" onclick="showTransferModal()">
                            <i class="fas fa-exchange-alt"></i> Transfer
                        </button>
                        <button class="btn btn-warning" onclick="showWithdrawModal()">
                            <i class="fas fa-money-bill-wave"></i> Withdraw
                        </button>
                    </div>
                </div>
                <div class="card-body">
                    <!-- Wallet Balance -->
                    <div class="wallet-balance-section">
                        <div class="balance-card">
                            <h4>Current Balance</h4>
                            <div id="wallet-balance" class="wallet-balance">
                                <span class="balance-amount">Loading...</span>
                            </div>
                            <div id="wallet-status" class="wallet-status"></div>
                            <p class="text-muted" style="margin-top: 10px;">
                                <small>Currency: <span id="wallet-currency">USD</span></small>
                            </p>
                        </div>
                    </div>

                    <!-- Transaction History -->
                    <div class="wallet-transactions-section">
                        <h4>Transaction History</h4>
                        <div id="wallet-transactions">
                            <p class="text-center text-muted">Loading transactions...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Notifications Tab -->
        <div id="notifications" class="tab-content">
            <div class="card">
                <div class="card-header">
                    <h3>Notification Preferences</h3>
                    <button class="btn btn-primary" onclick="saveNotificationPreferences()">Save Preferences</button>
                </div>
                <div class="card-body">
                    <form id="notification-preferences-form">
                        <input type="hidden" name="csrf_token" value="<?php echo generateCsrfToken(); ?>">
                        
                        <div class="notification-group">
                            <h4>Email Notifications</h4>
                            <div class="notification-item">
                                <label>
                                    <input type="checkbox" name="email_order_updates" checked>
                                    Order updates and shipping notifications
                                </label>
                            </div>
                            <div class="notification-item">
                                <label>
                                    <input type="checkbox" name="email_promotions" checked>
                                    Promotional offers and deals
                                </label>
                            </div>
                            <div class="notification-item">
                                <label>
                                    <input type="checkbox" name="email_newsletter" checked>
                                    Weekly newsletter
                                </label>
                            </div>
                        </div>

                        <div class="notification-group">
                            <h4>Account Notifications</h4>
                            <div class="notification-item">
                                <label>
                                    <input type="checkbox" name="security_alerts" checked disabled>
                                    Security alerts (required)
                                </label>
                            </div>
                            <div class="notification-item">
                                <label>
                                    <input type="checkbox" name="account_updates" checked>
                                    Account activity updates
                                </label>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Security Tab -->
        <div id="security" class="tab-content">
            <div class="card">
                <div class="card-header">
                    <h3>Security Settings</h3>
                </div>
                <div class="card-body">
                    <!-- Change Password Section -->
                    <div class="security-section">
                        <h4>Change Password</h4>
                        <form id="change-password-form" onsubmit="return handlePasswordChange(event)">
                            <input type="hidden" name="csrf_token" value="<?php echo generateCsrfToken(); ?>">
                            <div class="form-group">
                                <label>Current Password</label>
                                <input type="password" name="current_password" class="form-control" required>
                            </div>
                            <div class="form-group">
                                <label>New Password</label>
                                <input type="password" name="new_password" class="form-control" required minlength="8">
                            </div>
                            <div class="form-group">
                                <label>Confirm New Password</label>
                                <input type="password" name="confirm_password" class="form-control" required minlength="8">
                            </div>
                            <button type="submit" class="btn btn-primary">Update Password</button>
                        </form>
                    </div>

                    <!-- Two-Factor Authentication -->
                    <div class="security-section">
                        <h4>Two-Factor Authentication</h4>
                        <p>Add an extra layer of security to your account.</p>
                        <?php if ($user['two_factor_enabled']): ?>
                            <p class="text-success"><i class="fas fa-check-circle"></i> Two-factor authentication is enabled</p>
                            <button class="btn btn-danger" onclick="disable2FA()">Disable 2FA</button>
                        <?php else: ?>
                            <p class="text-warning"><i class="fas fa-exclamation-triangle"></i> Two-factor authentication is disabled</p>
                            <button class="btn btn-primary" onclick="enable2FA()">Enable 2FA</button>
                        <?php endif; ?>
                    </div>

                    <!-- Active Sessions -->
                    <div class="security-section">
                        <h4>Active Sessions</h4>
                        <p>Manage devices where you're currently logged in.</p>
                        <div id="active-sessions-list">
                            <p class="text-muted">Loading sessions...</p>
                        </div>
                    </div>

                    <!-- Login History -->
                    <div class="security-section">
                        <h4>Login History</h4>
                        <p>Recent login activity on your account.</p>
                        <div id="login-history-list">
                            <p class="text-muted">Loading login history...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Support Tab -->
        <div id="support" class="tab-content">
            <div class="card">
                <div class="card-header">
                    <h3>Customer Support</h3>
                    <button class="btn btn-primary" onclick="createSupportTicket()">New Support Ticket</button>
                </div>
                <div class="card-body">
                    <div class="support-options">
                        <div class="support-option">
                            <i class="fas fa-question-circle fa-3x"></i>
                            <h4>Help Center</h4>
                            <p>Find answers to common questions</p>
                            <a href="/help.php" class="btn btn-outline-primary">Visit Help Center</a>
                        </div>
                        <div class="support-option">
                            <i class="fas fa-comments fa-3x"></i>
                            <h4>Live Chat</h4>
                            <p>Chat with our support team</p>
                            <button class="btn btn-outline-primary" onclick="startLiveChat()">Start Chat</button>
                        </div>
                        <div class="support-option">
                            <i class="fas fa-envelope fa-3x"></i>
                            <h4>Email Support</h4>
                            <p>Send us an email</p>
                            <a href="/contact.php" class="btn btn-outline-primary">Contact Us</a>
                        </div>
                    </div>

                    <!-- Support Tickets -->
                    <div class="support-tickets-section">
                        <h4>My Support Tickets</h4>
                        <div id="support-tickets-list">
                            <p class="text-muted">Loading support tickets...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Order Tracking Tab -->
        <div id="tracking" class="tab-content">
            <div class="card">
                <div class="card-header">
                    <h3>Track Your Order</h3>
                </div>
                <div class="card-body">
                    <div class="tracking-search-section">
                        <p>Enter your order number or tracking number to see the latest status of your shipment.</p>
                        <form id="tracking-search-form" onsubmit="searchOrderTracking(event)">
                            <div class="form-group">
                                <label for="tracking-input">Order Number or Tracking Number</label>
                                <input type="text" id="tracking-input" name="order_id" class="form-control" 
                                       placeholder="e.g., ORD-20251015-001234" required>
                            </div>
                            <button type="submit" class="btn btn-primary">Track Order</button>
                        </form>
                    </div>

                    <!-- Tracking Results -->
                    <div id="tracking-results" style="margin-top: 30px; display: none;">
                        <h4>Order Status</h4>
                        <div id="tracking-details"></div>
                    </div>

                    <!-- Recent Orders for Quick Tracking -->
                    <div class="recent-orders-section" style="margin-top: 40px;">
                        <h4>Track Recent Orders</h4>
                        <div id="recent-orders-tracking">
                            <p class="text-muted">Loading recent orders...</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Live Chat Modal -->
<div id="liveChatModal" class="modal" style="display: none;">
    <div class="modal-content" style="max-width: 500px; height: 600px; display: flex; flex-direction: column;">
        <div class="modal-header">
            <h3>Live Chat Support</h3>
            <button class="close-btn" onclick="closeLiveChat()">&times;</button>
        </div>
        <div class="modal-body" style="flex: 1; overflow-y: auto; padding: 20px;" id="chatMessages">
            <p class="text-center text-muted">Starting chat...</p>
        </div>
        <div class="modal-footer" style="padding: 15px;">
            <form id="chatMessageForm" onsubmit="sendChatMessage(event)" style="display: flex; gap: 10px;">
                <input type="hidden" id="chatSessionId" name="chat_id">
                <input type="text" id="chatMessageInput" name="message" 
                       class="form-control" placeholder="Type your message..." required style="flex: 1;">
                <button type="submit" class="btn btn-primary">Send</button>
            </form>
        </div>
    </div>
</div>

<!-- Modals will be loaded from account-modals.php -->
<?php include __DIR__ . '/account-modals.php'; ?>

<script src="/js/account-management.js"></script>
<script>
// Initialize account page
document.addEventListener('DOMContentLoaded', function() {
    // Tab switching functionality
    const navTabs = document.querySelectorAll('.nav-tab');
    navTabs.forEach(tab => {
        tab.addEventListener('click', function(e) {
            e.preventDefault();
            const targetTab = this.getAttribute('data-tab');
            switchTab(targetTab);
        });
    });

    // Load initial data for active tab
    loadOverviewData();
});

function switchTab(tabName) {
    // Update navigation
    document.querySelectorAll('.nav-tab').forEach(tab => {
        tab.classList.remove('active');
    });
    document.querySelector(`.nav-tab[data-tab="${tabName}"]`).classList.add('active');

    // Update content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });
    document.getElementById(tabName).classList.add('active');

    // Load data for the tab
    loadTabData(tabName);

    // Update URL hash
    window.location.hash = tabName;
}

function loadOverviewData() {
    // Overview data is already loaded from PHP
}

function loadTabData(tabName) {
    switch(tabName) {
        case 'orders':
            loadOrders();
            break;
        case 'addresses':
            loadAddresses();
            break;
        case 'wishlist':
            loadWishlist();
            break;
        case 'payment-methods':
            loadPaymentMethods();
            break;
        case 'wallet':
            loadWallet();
            break;
        case 'security':
            loadActiveSessions();
            loadLoginHistory();
            break;
        case 'support':
            loadSupportTickets();
            break;
        case 'tracking':
            loadRecentOrdersForTracking();
            break;
    }
}

// Load orders
async function loadOrders() {
    try {
        const response = await fetch('/api/account/get-orders.php');
        const result = await response.json();
        
        if (result.success && result.data.length > 0) {
            const ordersHtml = result.data.map(order => `
                <div class="order-item">
                    <div class="order-header">
                        <div>
                            <strong>Order #${order.order_number || order.order_reference}</strong>
                            <span class="badge badge-${getOrderStatusClass(order.status)}">${order.status}</span>
                        </div>
                        <div class="order-date">${formatDate(order.created_at)}</div>
                    </div>
                    <div class="order-details">
                        <p>Total: $${parseFloat(order.total).toFixed(2)}</p>
                        <p>Items: ${order.item_count || 0}</p>
                    </div>
                    <div class="order-actions">
                        <a href="/order-details.php?id=${order.id}" class="btn btn-sm btn-primary">View Details</a>
                        <button onclick="reorder(${order.id})" class="btn btn-sm btn-outline-primary">Reorder</button>
                    </div>
                </div>
            `).join('');
            document.getElementById('orders-list').innerHTML = ordersHtml;
        } else {
            document.getElementById('orders-list').innerHTML = '<p class="text-center text-muted">No orders found</p>';
        }
    } catch (error) {
        console.error('Error loading orders:', error);
        document.getElementById('orders-list').innerHTML = '<p class="text-center text-danger">Error loading orders</p>';
    }
}

// Load addresses
async function loadAddresses() {
    try {
        const response = await fetch('/api/account/get-addresses.php');
        const result = await response.json();
        
        if (result.success && result.data.length > 0) {
            const addressesHtml = result.data.map(address => `
                <div class="address-item">
                    <div class="address-header">
                        <strong>${address.first_name} ${address.last_name}</strong>
                        ${address.is_default ? '<span class="badge badge-primary">Default</span>' : ''}
                    </div>
                    <div class="address-details">
                        <p>${address.address_line1}</p>
                        ${address.address_line2 ? `<p>${address.address_line2}</p>` : ''}
                        <p>${address.city}, ${address.state} ${address.postal_code}</p>
                        <p>${address.country}</p>
                    </div>
                    <div class="address-actions">
                        <button onclick="editAddress(${address.id})" class="btn btn-sm btn-primary">Edit</button>
                        ${!address.is_default ? `<button onclick="setDefaultAddress(${address.id})" class="btn btn-sm btn-outline-primary">Set Default</button>` : ''}
                        <button onclick="deleteAddress(${address.id})" class="btn btn-sm btn-danger">Delete</button>
                    </div>
                </div>
            `).join('');
            document.getElementById('addresses-list').innerHTML = addressesHtml;
        } else {
            document.getElementById('addresses-list').innerHTML = '<p class="text-center text-muted">No addresses found</p>';
        }
    } catch (error) {
        console.error('Error loading addresses:', error);
        document.getElementById('addresses-list').innerHTML = '<p class="text-center text-danger">Error loading addresses</p>';
    }
}

// Load wishlist
async function loadWishlist() {
    try {
        const response = await fetch('/api/account/get-wishlist.php');
        const result = await response.json();
        
        if (result.success && result.data.length > 0) {
            const wishlistHtml = result.data.map(item => `
                <div class="wishlist-item">
                    <img src="${item.image_url || '/images/placeholder.png'}" alt="${item.name}">
                    <div class="wishlist-details">
                        <h5>${item.name}</h5>
                        <p class="price">$${parseFloat(item.price).toFixed(2)}</p>
                    </div>
                    <div class="wishlist-actions">
                        <a href="/product.php?id=${item.product_id}" class="btn btn-sm btn-primary">View</a>
                        <button onclick="addToCart(${item.product_id})" class="btn btn-sm btn-success">Add to Cart</button>
                        <button onclick="removeFromWishlist(${item.id})" class="btn btn-sm btn-danger">Remove</button>
                    </div>
                </div>
            `).join('');
            document.getElementById('wishlist-items').innerHTML = wishlistHtml;
        } else {
            document.getElementById('wishlist-items').innerHTML = '<p class="text-center text-muted">Your wishlist is empty</p>';
        }
    } catch (error) {
        console.error('Error loading wishlist:', error);
        document.getElementById('wishlist-items').innerHTML = '<p class="text-center text-danger">Error loading wishlist</p>';
    }
}

// Load wallet
async function loadWallet() {
    try {
        const response = await fetch('/api/wallet/balance.php');
        const result = await response.json();
        
        if (result.success) {
            const balance = parseFloat(result.balance || 0);
            const status = result.status || 'active';
            const currency = result.currency || 'USD';
            
            // Display balance
            document.getElementById('wallet-balance').innerHTML = `
                <span class="balance-amount">$${balance.toFixed(2)} ${currency}</span>
            `;
            
            // Display currency
            if (document.getElementById('wallet-currency')) {
                document.getElementById('wallet-currency').textContent = currency;
            }
            
            // Display status
            const statusBadge = status === 'active' 
                ? '<span class="badge badge-success">Active</span>'
                : '<span class="badge badge-danger">Suspended</span>';
            document.getElementById('wallet-status').innerHTML = statusBadge;
            
            // Load transactions
            loadWalletTransactions();
        } else {
            document.getElementById('wallet-balance').innerHTML = '<span class="text-danger">Error loading balance</span>';
        }
    } catch (error) {
        console.error('Error loading wallet:', error);
        document.getElementById('wallet-balance').innerHTML = '<span class="text-danger">Error loading balance</span>';
    }
}

// Load wallet transactions
async function loadWalletTransactions() {
    try {
        const response = await fetch('/api/wallet/transactions.php');
        const result = await response.json();
        
        if (result.success && result.data && result.data.length > 0) {
            const transactionsHtml = result.data.map(tx => {
                const typeClass = tx.type === 'credit' ? 'success' : tx.type === 'debit' ? 'danger' : 'info';
                const typeIcon = tx.type === 'credit' ? '↑' : tx.type === 'debit' ? '↓' : '↔';
                const amount = parseFloat(tx.amount || 0);
                
                return `
                    <div class="transaction-item">
                        <div class="transaction-icon text-${typeClass}">
                            <i class="fas fa-arrow-${tx.type === 'credit' ? 'up' : tx.type === 'debit' ? 'down' : 'right'}"></i>
                        </div>
                        <div class="transaction-details">
                            <div class="transaction-description">
                                <strong>${tx.description || tx.type}</strong>
                                ${tx.reference ? `<small class="text-muted"> (${tx.reference})</small>` : ''}
                            </div>
                            <div class="transaction-date text-muted">
                                <small>${formatDate(tx.created_at)}</small>
                            </div>
                        </div>
                        <div class="transaction-amount text-${typeClass}">
                            <strong>${tx.type === 'credit' ? '+' : '-'}$${amount.toFixed(2)}</strong>
                            <div class="balance-after text-muted">
                                <small>Balance: $${parseFloat(tx.balance_after).toFixed(2)}</small>
                            </div>
                        </div>
                    </div>
                `;
            }).join('');
            document.getElementById('wallet-transactions').innerHTML = transactionsHtml;
        } else {
            document.getElementById('wallet-transactions').innerHTML = '<p class="text-center text-muted">No transactions yet</p>';
        }
    } catch (error) {
        console.error('Error loading transactions:', error);
        document.getElementById('wallet-transactions').innerHTML = '<p class="text-center text-danger">Error loading transactions</p>';
    }
}


// Load payment methods
async function loadPaymentMethods() {
    try {
        const response = await fetch('/api/payment-methods/get.php');
        const result = await response.json();
        
        if (result.success && result.data.length > 0) {
            const methodsHtml = result.data.map(method => `
                <div class="payment-method-item ${method.is_default ? 'default' : ''}">
                    <div class="payment-method-info">
                        <i class="fab fa-cc-${method.brand.toLowerCase()} fa-2x"></i>
                        <div>
                            <strong>${method.brand} •••• ${method.last4}</strong>
                            <p>Expires: ${method.exp_month}/${method.exp_year}</p>
                            ${method.is_default ? '<span class="badge badge-primary">Default</span>' : ''}
                        </div>
                    </div>
                    <div class="payment-method-actions">
                        ${!method.is_default ? `<button onclick="setDefaultPaymentMethod(${method.id})" class="btn btn-sm btn-outline-primary">Set as Default</button>` : ''}
                        <button onclick="deletePaymentMethod(${method.id})" class="btn btn-sm btn-danger">Delete</button>
                    </div>
                </div>
            `).join('');
            document.getElementById('payment-methods-list').innerHTML = methodsHtml;
        } else {
            document.getElementById('payment-methods-list').innerHTML = '<p class="text-center text-muted">No payment methods saved. Add a payment method to save it for future purchases.</p>';
        }
    } catch (error) {
        console.error('Error loading payment methods:', error);
        document.getElementById('payment-methods-list').innerHTML = '<p class="text-center text-danger">Error loading payment methods</p>';
    }
}

// Load active sessions
async function loadActiveSessions() {
    try {
        const response = await fetch('/api/account/get-sessions.php');
        const result = await response.json();
        
        if (result.success && result.data.length > 0) {
            const sessionsHtml = result.data.map(session => `
                <div class="session-item">
                    <div class="session-details">
                        <strong>${session.device || 'Unknown Device'}</strong>
                        <p>Last active: ${formatDate(session.last_activity)}</p>
                        <p>IP: ${session.ip_address}</p>
                    </div>
                    ${!session.is_current ? `<button onclick="logoutSession('${session.id}')" class="btn btn-sm btn-danger">Logout</button>` : '<span class="badge badge-success">Current Session</span>'}
                </div>
            `).join('');
            document.getElementById('active-sessions-list').innerHTML = sessionsHtml;
        } else {
            document.getElementById('active-sessions-list').innerHTML = '<p class="text-muted">No active sessions</p>';
        }
    } catch (error) {
        console.error('Error loading sessions:', error);
    }
}

// Load login history
async function loadLoginHistory() {
    try {
        const response = await fetch('/api/account/get-login-history.php');
        const result = await response.json();
        
        if (result.success && result.data.length > 0) {
            const historyHtml = result.data.map(entry => {
                const statusClass = entry.status === 'success' ? 'success' : entry.status === 'failed' ? 'danger' : 'warning';
                const statusIcon = entry.status === 'success' ? 'check-circle' : entry.status === 'failed' ? 'times-circle' : 'exclamation-circle';
                
                return `
                    <div class="login-history-item">
                        <div class="login-history-icon">
                            <i class="fas fa-${statusIcon} text-${statusClass}"></i>
                        </div>
                        <div class="login-history-details">
                            <div>
                                <strong>${entry.device_type || 'Unknown Device'}</strong>
                                ${entry.browser ? ` - ${entry.browser}` : ''}
                                ${entry.os ? ` on ${entry.os}` : ''}
                            </div>
                            <div class="text-muted">
                                <small>
                                    ${formatDate(entry.login_time)} - IP: ${entry.ip_address}
                                    ${entry.location ? ` - ${entry.location}` : ''}
                                </small>
                            </div>
                        </div>
                        <span class="badge badge-${statusClass}">${entry.status}</span>
                    </div>
                `;
            }).join('');
            document.getElementById('login-history-list').innerHTML = historyHtml;
        } else {
            document.getElementById('login-history-list').innerHTML = '<p class="text-center text-muted">No login history available</p>';
        }
    } catch (error) {
        console.error('Error loading login history:', error);
        document.getElementById('login-history-list').innerHTML = '<p class="text-center text-danger">Error loading login history</p>';
    }
}

// Load support tickets
async function loadSupportTickets() {
    try {
        const response = await fetch('/api/account/get-support-tickets.php');
        const result = await response.json();
        
        if (result.success && result.data.length > 0) {
            const ticketsHtml = result.data.map(ticket => `
                <div class="ticket-item">
                    <div class="ticket-header">
                        <strong>Ticket #${ticket.ticket_number}</strong>
                        <span class="badge badge-${getTicketStatusClass(ticket.status)}">${ticket.status}</span>
                    </div>
                    <div class="ticket-details">
                        <p><strong>${ticket.subject}</strong></p>
                        <p>Category: ${ticket.category} | Priority: ${ticket.priority}</p>
                        <p>Created: ${formatDate(ticket.created_at)}</p>
                    </div>
                    <div class="ticket-actions">
                        <a href="/support/ticket.php?id=${ticket.id}" class="btn btn-sm btn-primary">View</a>
                    </div>
                </div>
            `).join('');
            document.getElementById('support-tickets-list').innerHTML = ticketsHtml;
        } else {
            document.getElementById('support-tickets-list').innerHTML = '<p class="text-center text-muted">No support tickets</p>';
        }
    } catch (error) {
        console.error('Error loading support tickets:', error);
    }
}

// Additional action functions
function getCsrfToken() {
    // Try meta tag first
    const metaTag = document.querySelector('meta[name="csrf-token"]');
    if (metaTag && metaTag.getAttribute('content')) {
        return metaTag.getAttribute('content');
    }
    // Fallback: try to get from any hidden input on page
    const input = document.querySelector('input[name="csrf_token"]');
    if (input && input.value) {
        return input.value;
    }
    console.warn('CSRF token not found');
    return '';
}

function addAddress() {
    if (typeof showAddressModal === 'function') {
        showAddressModal();
    } else {
        alert('Address management requires the address modal. Please refresh the page or contact support.');
    }
}

function saveNotificationPreferences() {
    const form = document.getElementById('notification-preferences-form');
    const formData = new FormData(form);
    const data = Object.fromEntries(formData.entries());
    
    // Convert checkboxes to boolean
    const checkboxes = form.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(cb => {
        data[cb.name] = cb.checked ? 1 : 0;
    });
    
    // Ensure CSRF token is included
    if (!data.csrf_token) {
        data.csrf_token = getCsrfToken();
    }
    
    fetch('/api/account/update-preferences.php', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            alert('Preferences saved successfully!');
        } else {
            alert('Error: ' + (result.error || 'Failed to save preferences'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('An error occurred while saving preferences');
    });
}

function handlePasswordChange(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);
    const data = Object.fromEntries(formData.entries());
    
    if (data.new_password !== data.confirm_password) {
        alert('New password and confirm password do not match');
        return false;
    }
    
    // Ensure CSRF token is included
    if (!data.csrf_token) {
        data.csrf_token = getCsrfToken();
    }
    
    fetch('/api/account/change-password.php', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            alert('Password changed successfully!');
            form.reset();
        } else {
            alert('Error: ' + (result.error || 'Failed to change password'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('An error occurred while changing password');
    });
    
    return false;
}

async function enable2FA() {
    try {
        const response = await fetch('/api/account/setup-2fa.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                action: 'enable',
                csrf_token: getCsrfToken()
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            alert('Two-factor authentication has been enabled!\n\n' + 
                  'Secret: ' + result.secret + '\n\n' +
                  'Please save this secret in your authenticator app.\n' +
                  'QR Code URL: ' + result.qr_code_url);
            location.reload();
        } else {
            alert('Error: ' + (result.error || 'Failed to enable 2FA'));
        }
    } catch (error) {
        console.error('Error enabling 2FA:', error);
        alert('An error occurred while enabling two-factor authentication');
    }
}

async function disable2FA() {
    if (confirm('Are you sure you want to disable two-factor authentication? This will make your account less secure.')) {
        try {
            const response = await fetch('/api/account/setup-2fa.php', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    action: 'disable',
                    csrf_token: getCsrfToken()
                })
            });
            
            const result = await response.json();
            
            if (result.success) {
                alert('Two-factor authentication has been disabled');
                location.reload();
            } else {
                alert('Error: ' + (result.error || 'Failed to disable 2FA'));
            }
        } catch (error) {
            console.error('Error disabling 2FA:', error);
            alert('An error occurred while disabling two-factor authentication');
        }
    }
}

// Payment method management functions
let stripe = null;
let cardElement = null;
let setupIntentClientSecret = null;

async function addPaymentMethod() {
    // Initialize Stripe if not already done
    if (!stripe) {
        // Get Stripe publishable key from meta tag (should be set in header)
        const stripeKey = document.querySelector('meta[name="stripe-publishable-key"]')?.content;
        if (!stripeKey) {
            alert('Stripe is not configured. Please contact support.');
            return;
        }
        stripe = Stripe(stripeKey);
    }
    
    // Show modal
    document.getElementById('addPaymentMethodModal').style.display = 'flex';
    
    // Create Setup Intent
    try {
        const response = await fetch('/api/payment-methods/create-setup-intent.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                csrf_token: getCsrfToken()
            })
        });
        
        const result = await response.json();
        
        if (!result.success) {
            throw new Error(result.error || 'Failed to create setup intent');
        }
        
        setupIntentClientSecret = result.client_secret;
        
        // Initialize Stripe Elements
        const elements = stripe.elements();
        cardElement = elements.create('card', {
            style: {
                base: {
                    fontSize: '16px',
                    color: '#32325d',
                    '::placeholder': {
                        color: '#aab7c4'
                    }
                }
            }
        });
        
        cardElement.mount('#card-element');
        
        // Handle card errors
        cardElement.on('change', function(event) {
            const displayError = document.getElementById('card-errors');
            if (event.error) {
                displayError.textContent = event.error.message;
            } else {
                displayError.textContent = '';
            }
        });
        
    } catch (error) {
        console.error('Error initializing payment method form:', error);
        alert('Error: ' + error.message);
        closeAddPaymentMethodModal();
    }
}

function closeAddPaymentMethodModal() {
    document.getElementById('addPaymentMethodModal').style.display = 'none';
    if (cardElement) {
        cardElement.unmount();
        cardElement = null;
    }
}

// Handle payment method form submission
document.addEventListener('DOMContentLoaded', function() {
    const paymentMethodForm = document.getElementById('payment-method-form');
    if (paymentMethodForm) {
        paymentMethodForm.addEventListener('submit', async function(event) {
            event.preventDefault();
            
            const submitButton = document.getElementById('submit-payment-method');
            submitButton.disabled = true;
            submitButton.textContent = 'Processing...';
            
            try {
                // Confirm the setup intent with Stripe
                const {setupIntent, error} = await stripe.confirmCardSetup(
                    setupIntentClientSecret,
                    {
                        payment_method: {
                            card: cardElement
                        }
                    }
                );
                
                if (error) {
                    throw new Error(error.message);
                }
                
                // Save payment method to database
                const isDefault = document.getElementById('set-default-payment').checked;
                const response = await fetch('/api/payment-methods/add-card.php', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({
                        payment_method_id: setupIntent.payment_method,
                        is_default: isDefault,
                        csrf_token: getCsrfToken()
                    })
                });
                
                const result = await response.json();
                
                if (!result.success) {
                    throw new Error(result.error || 'Failed to save payment method');
                }
                
                alert('Payment method added successfully!');
                closeAddPaymentMethodModal();
                loadPaymentMethods();
                
            } catch (error) {
                console.error('Error adding payment method:', error);
                document.getElementById('card-errors').textContent = error.message;
            } finally {
                submitButton.disabled = false;
                submitButton.textContent = 'Add Payment Method';
            }
        });
    }
});

async function deletePaymentMethod(paymentMethodId) {
    if (!confirm('Are you sure you want to delete this payment method?')) {
        return;
    }
    
    try {
        const response = await fetch('/api/payment-methods/delete.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                payment_method_id: paymentMethodId,
                csrf_token: getCsrfToken()
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            alert('Payment method deleted successfully');
            loadPaymentMethods();
        } else {
            alert('Error: ' + (result.error || 'Failed to delete payment method'));
        }
    } catch (error) {
        console.error('Error deleting payment method:', error);
        alert('An error occurred while deleting the payment method');
    }
}

async function setDefaultPaymentMethod(paymentMethodId) {
    try {
        const response = await fetch('/api/payment-methods/set-default.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                payment_method_id: paymentMethodId,
                csrf_token: getCsrfToken()
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            alert('Default payment method updated successfully');
            loadPaymentMethods();
        } else {
            alert('Error: ' + (result.error || 'Failed to set default payment method'));
        }
    } catch (error) {
        console.error('Error setting default payment method:', error);
        alert('An error occurred while setting the default payment method');
    }
}

function createSupportTicket() {
    if (typeof openSupportTicketModal === 'function') {
        openSupportTicketModal();
    } else {
        window.location.href = '/contact.php';
    }
}

function startLiveChat() {
    // Show live chat modal
    document.getElementById('liveChatModal').style.display = 'flex';
    
    // Start chat session
    fetch('/api/live-chat.php?action=start', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            csrf_token: getCsrfToken()
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            document.getElementById('chatSessionId').value = result.data.chat_id;
            document.getElementById('chatMessages').innerHTML = '';
            
            // Start polling for messages
            startChatPolling(result.data.chat_id);
            
            // Load initial messages
            loadChatMessages(result.data.chat_id);
        } else {
            document.getElementById('chatMessages').innerHTML = 
                '<p class="text-danger">Error: ' + (result.error || 'Failed to start chat') + '</p>';
        }
    })
    .catch(error => {
        console.error('Error starting chat:', error);
        document.getElementById('chatMessages').innerHTML = 
            '<p class="text-danger">Error starting chat. Please try again later.</p>';
    });
}

function closeLiveChat() {
    const chatId = document.getElementById('chatSessionId').value;
    if (chatId) {
        // Stop polling
        if (window.chatPollingInterval) {
            clearInterval(window.chatPollingInterval);
        }
        
        // Close chat session
        fetch('/api/live-chat.php?action=close', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                chat_id: chatId,
                csrf_token: getCsrfToken()
            })
        });
    }
    
    document.getElementById('liveChatModal').style.display = 'none';
}

function sendChatMessage(event) {
    event.preventDefault();
    
    const form = event.target;
    const chatId = document.getElementById('chatSessionId').value;
    const message = document.getElementById('chatMessageInput').value;
    
    if (!chatId || !message.trim()) return;
    
    fetch('/api/live-chat.php?action=send', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            chat_id: chatId,
            message: message,
            csrf_token: getCsrfToken()
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            // Clear input
            document.getElementById('chatMessageInput').value = '';
            
            // Add message to chat
            appendChatMessage('user', message);
        } else {
            alert('Error: ' + (result.error || 'Failed to send message'));
        }
    })
    .catch(error => {
        console.error('Error sending message:', error);
        alert('Error sending message');
    });
}

function loadChatMessages(chatId, since = 0) {
    fetch(`/api/live-chat.php?action=messages&chat_id=${chatId}&since=${since}`)
    .then(response => response.json())
    .then(result => {
        if (result.success && result.data.messages) {
            result.data.messages.forEach(msg => {
                appendChatMessage(msg.sender, msg.message, msg.created_at, msg.id);
            });
            
            // Scroll to bottom
            const chatMessages = document.getElementById('chatMessages');
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }
    })
    .catch(error => {
        console.error('Error loading messages:', error);
    });
}

function appendChatMessage(sender, message, timestamp = null, messageId = null) {
    const chatMessages = document.getElementById('chatMessages');
    
    // Check if message already exists
    if (messageId && chatMessages.querySelector(`[data-message-id="${messageId}"]`)) {
        return;
    }
    
    const messageDiv = document.createElement('div');
    messageDiv.className = `chat-message ${sender}`;
    if (messageId) messageDiv.dataset.messageId = messageId;
    
    const timeStr = timestamp ? new Date(timestamp).toLocaleTimeString() : new Date().toLocaleTimeString();
    
    messageDiv.innerHTML = `
        <div class="message-content">
            <div class="message-sender">${sender === 'user' ? 'You' : sender === 'agent' ? 'Support Agent' : 'System'}</div>
            <div class="message-text">${escapeHtml(message)}</div>
            <div class="message-time">${timeStr}</div>
        </div>
    `;
    
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

function startChatPolling(chatId) {
    let lastMessageId = 0;
    
    window.chatPollingInterval = setInterval(() => {
        loadChatMessages(chatId, lastMessageId);
        
        // Update last message ID
        const messages = document.querySelectorAll('.chat-message[data-message-id]');
        if (messages.length > 0) {
            const lastMsg = messages[messages.length - 1];
            lastMessageId = parseInt(lastMsg.dataset.messageId);
        }
    }, 3000); // Poll every 3 seconds
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Order Tracking Functions
function searchOrderTracking(event) {
    event.preventDefault();
    
    const orderId = document.getElementById('tracking-input').value;
    
    if (!orderId.trim()) {
        alert('Please enter an order number or tracking number');
        return;
    }
    
    fetch(`/api/track-order.php?order_id=${encodeURIComponent(orderId)}`)
    .then(response => response.json())
    .then(result => {
        if (result.success && result.data.order) {
            displayTrackingResults(result.data.order);
        } else {
            document.getElementById('tracking-results').style.display = 'block';
            document.getElementById('tracking-details').innerHTML = 
                '<p class="text-danger">Order not found. Please check your order number and try again.</p>';
        }
    })
    .catch(error => {
        console.error('Error tracking order:', error);
        document.getElementById('tracking-results').style.display = 'block';
        document.getElementById('tracking-details').innerHTML = 
            '<p class="text-danger">Error loading tracking information. Please try again later.</p>';
    });
}

function displayTrackingResults(order) {
    document.getElementById('tracking-results').style.display = 'block';
    
    const statusClass = getOrderStatusClass(order.status);
    let trackingHtml = `
        <div class="tracking-card">
            <div class="order-summary">
                <div class="order-info">
                    <h5>Order #${order.order_reference || order.id}</h5>
                    <p>Order Date: ${formatDate(order.created_at)}</p>
                    <p>Status: <span class="badge badge-${statusClass}">${order.status}</span></p>
                </div>
                ${order.tracking_number ? `
                    <div class="tracking-info">
                        <p><strong>Tracking Number:</strong> ${order.tracking_number}</p>
                        ${order.carrier ? `<p><strong>Carrier:</strong> ${order.carrier}</p>` : ''}
                        ${order.estimated_delivery ? `<p><strong>Estimated Delivery:</strong> ${formatDate(order.estimated_delivery)}</p>` : ''}
                    </div>
                ` : ''}
            </div>
            
            <div class="tracking-timeline">
                <h5>Tracking History</h5>
                ${order.tracking_updates && order.tracking_updates.length > 0 ? `
                    <div class="timeline">
                        ${order.tracking_updates.map(update => `
                            <div class="timeline-item">
                                <div class="timeline-marker"></div>
                                <div class="timeline-content">
                                    <div class="timeline-status"><strong>${update.status}</strong></div>
                                    ${update.description ? `<div class="timeline-description">${update.description}</div>` : ''}
                                    ${update.location ? `<div class="timeline-location"><i class="fas fa-map-marker-alt"></i> ${update.location}</div>` : ''}
                                    <div class="timeline-time">${formatDateTime(update.created_at)}</div>
                                </div>
                            </div>
                        `).join('')}
                    </div>
                ` : '<p class="text-muted">No tracking updates available yet.</p>'}
            </div>
        </div>
    `;
    
    document.getElementById('tracking-details').innerHTML = trackingHtml;
}

function loadRecentOrdersForTracking() {
    fetch('/api/account/get-orders.php?per_page=5')
    .then(response => response.json())
    .then(result => {
        if (result.success && result.data && result.data.length > 0) {
            const ordersHtml = result.data.map(order => `
                <div class="recent-order-track-item">
                    <div class="order-info">
                        <strong>Order #${order.order_reference || order.id}</strong>
                        <span class="badge badge-${getOrderStatusClass(order.status)}">${order.status}</span>
                    </div>
                    <div class="order-date">${formatDate(order.created_at)}</div>
                    <button onclick="trackOrderById('${order.order_reference || order.id}')" class="btn btn-sm btn-outline-primary">
                        <i class="fas fa-shipping-fast"></i> Track
                    </button>
                </div>
            `).join('');
            document.getElementById('recent-orders-tracking').innerHTML = ordersHtml;
        } else {
            document.getElementById('recent-orders-tracking').innerHTML = 
                '<p class="text-muted">No recent orders to track.</p>';
        }
    })
    .catch(error => {
        console.error('Error loading recent orders:', error);
    });
}

function trackOrderById(orderId) {
    document.getElementById('tracking-input').value = orderId;
    document.getElementById('tracking-search-form').dispatchEvent(new Event('submit'));
}

function formatDateTime(dateString) {
    const date = new Date(dateString);
    return date.toLocaleString('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function reorder(orderId) {
    // Future enhancement - would need to implement cart API endpoint
    if (confirm('This will add all items from this order to your cart. Continue?')) {
        alert('Reorder functionality will be implemented in a future update. For now, please add items manually from your order details.');
    }
}

function addToCart(productId) {
    fetch('/api/cart/add.php', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            product_id: productId,
            quantity: 1,
            csrf_token: getCsrfToken()
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            alert('Product added to cart!');
        } else {
            alert('Error: ' + (result.error || 'Failed to add to cart'));
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('An error occurred');
    });
}

function removeFromWishlist(wishlistId) {
    if (confirm('Remove this item from your wishlist?')) {
        fetch('/api/wishlist/remove.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                wishlist_id: wishlistId,
                csrf_token: getCsrfToken()
            })
        })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                loadWishlist();
            } else {
                alert('Error: ' + (result.error || 'Failed to remove from wishlist'));
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('An error occurred');
        });
    }
}

function setDefaultAddress(addressId) {
    if (typeof makeDefaultAddress === 'function') {
        makeDefaultAddress(addressId);
    } else {
        // Fallback implementation
        fetch('/api/addresses/set-default.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                address_id: addressId,
                csrf_token: getCsrfToken()
            })
        })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                alert('Default address updated');
                loadAddresses();
            } else {
                alert('Error: ' + (result.error || 'Failed to set default address'));
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('An error occurred');
        });
    }
}

function logoutSession(sessionId) {
    if (confirm('Logout this session?')) {
        fetch('/api/account/logout-session.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                session_id: sessionId,
                csrf_token: getCsrfToken()
            })
        })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                loadActiveSessions();
            } else {
                alert('Error: ' + (result.error || 'Failed to logout session'));
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('An error occurred');
        });
    }
}

// Helper functions
function getOrderStatusClass(status) {
    const statusMap = {
        'pending': 'warning',
        'processing': 'info',
        'shipped': 'primary',
        'delivered': 'success',
        'cancelled': 'danger',
        'refunded': 'secondary'
    };
    return statusMap[status] || 'secondary';
}

function getTicketStatusClass(status) {
    const statusMap = {
        'open': 'warning',
        'in_progress': 'info',
        'resolved': 'success',
        'closed': 'secondary'
    };
    return statusMap[status] || 'secondary';
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
}

// Wallet management functions
function loadWalletBalance() {
    loadWallet();
}

function showAddFundsModal() {
    document.getElementById('addFundsModal').style.display = 'flex';
}

function closeAddFundsModal() {
    document.getElementById('addFundsModal').style.display = 'none';
    document.getElementById('add-funds-form').reset();
}

function showTransferModal() {
    document.getElementById('transferFundsModal').style.display = 'flex';
}

function closeTransferModal() {
    document.getElementById('transferFundsModal').style.display = 'none';
    document.getElementById('transfer-funds-form').reset();
}

function showWithdrawModal() {
    document.getElementById('withdrawFundsModal').style.display = 'flex';
}

function closeWithdrawModal() {
    document.getElementById('withdrawFundsModal').style.display = 'none';
    document.getElementById('withdraw-funds-form').reset();
}

async function submitAddFunds(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);
    
    try {
        const response = await fetch('/api/wallet/add-funds.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                amount: parseFloat(formData.get('amount')),
                payment_method: formData.get('payment_method'),
                csrf_token: getCsrfToken()
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            alert('Funds added successfully!');
            closeAddFundsModal();
            loadWalletBalance();
            loadWalletTransactions();
        } else {
            alert('Error: ' + (result.error || 'Failed to add funds'));
        }
    } catch (error) {
        console.error('Error adding funds:', error);
        alert('An error occurred while adding funds');
    }
}

async function submitTransfer(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);
    
    try {
        const response = await fetch('/api/wallet/transfer.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                recipient: formData.get('recipient'),
                amount: parseFloat(formData.get('amount')),
                description: formData.get('description'),
                csrf_token: getCsrfToken()
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            alert('Transfer completed successfully!');
            closeTransferModal();
            loadWalletBalance();
            loadWalletTransactions();
        } else {
            alert('Error: ' + (result.error || 'Failed to transfer funds'));
        }
    } catch (error) {
        console.error('Error transferring funds:', error);
        alert('An error occurred while transferring funds');
    }
}

async function submitWithdraw(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);
    
    try {
        const response = await fetch('/api/wallet/request-payout.php', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                amount: parseFloat(formData.get('amount')),
                withdrawal_method: formData.get('withdrawal_method'),
                notes: formData.get('notes'),
                csrf_token: getCsrfToken()
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            alert('Withdrawal request submitted successfully!');
            closeWithdrawModal();
            loadWalletBalance();
            loadWalletTransactions();
        } else {
            alert('Error: ' + (result.error || 'Failed to request withdrawal'));
        }
    } catch (error) {
        console.error('Error requesting withdrawal:', error);
        alert('An error occurred while requesting withdrawal');
    }
}

// Check for hash on page load
if (window.location.hash) {
    const tabName = window.location.hash.substring(1);
    switchTab(tabName);
}
</script>

<?php includeFooter(); ?>
