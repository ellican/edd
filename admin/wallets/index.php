<?php
/**
 * Professional Wallet Management Dashboard
 * Features: Search, Filtering, Pagination, and Full Admin Controls.
 * @version 4.0.0
 */

// Core application requirements
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/csrf.php';
require_once __DIR__ . '/../../includes/rbac.php';
require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../../includes/audit_log.php';

// --- Page Setup & Security ---
$page_title = 'Wallet Management';
$error_message = $_SESSION['error_message'] ?? null;
$success_message = $_SESSION['success_message'] ?? null;
unset($_SESSION['error_message'], $_SESSION['success_message']);

// Initialize default values
$stats = ['total_users' => 0, 'active_wallets' => 0, 'total_balance' => 0.00, 'suspended_wallets' => 0];
$user_wallets = [];
$pagination_links = '';

try {
    requireAdminAuth();
    checkPermission('wallets.view');
    $pdo = db();
    $admin_id = $_SESSION['user_id'] ?? null;

    // --- ACTION HANDLING (POST) ---
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // (The POST handling logic from the previous version is robust and remains unchanged)
        // It handles 'create_wallet', 'credit_debit', 'change_status' securely.
        if (!validateCSRFToken($_POST['csrf_token'])) throw new Exception('Invalid security token.');
        checkPermission('wallets.edit');
        $action = $_POST['action'] ?? '';
        $user_id = filter_input(INPUT_POST, 'user_id', FILTER_VALIDATE_INT);
        if (!$user_id) throw new Exception('Invalid user specified.');
        
        $pdo->beginTransaction();
        $stmt = $pdo->prepare("SELECT id, balance FROM wallets WHERE user_id = ?");
        $stmt->execute([$user_id]);
        $wallet = $stmt->fetch(PDO::FETCH_ASSOC);

        switch ($action) {
            case 'create_wallet':
                if ($wallet) throw new Exception('User already has a wallet.');
                $pdo->prepare("INSERT INTO wallets (user_id, balance, status) VALUES (?, 0.00, 'active')")->execute([$user_id]);
                
                // Create notification for user
                try {
                    $pdo->prepare("INSERT INTO notifications (user_id, type, title, message, created_at) VALUES (?, 'wallet', 'Wallet Created', 'Your wallet has been successfully created and is now active.', NOW())")->execute([$user_id]);
                } catch (Exception $e) {
                    error_log("Failed to create wallet notification: " . $e->getMessage());
                }
                
                $_SESSION['success_message'] = 'Wallet created successfully.';
                break;
            case 'credit_debit':
                if (!$wallet) throw new Exception('No wallet found.');
                $type = $_POST['type'];
                $amount = filter_input(INPUT_POST, 'amount', FILTER_VALIDATE_FLOAT);
                $description = trim(filter_input(INPUT_POST, 'description', FILTER_SANITIZE_STRING));
                if ($amount <= 0) throw new Exception("Amount must be positive.");
                if (empty($description)) throw new Exception("A description is required.");
                if ($type === 'debit' && $amount > $wallet['balance']) throw new Exception("Cannot debit more than the current balance.");
                $balance_before = $wallet['balance'];
                $balance_after = ($type === 'credit') ? $balance_before + $amount : $balance_before - $amount;
                
                // Atomic balance update
                $pdo->prepare("UPDATE wallets SET balance = ? WHERE id = ?")->execute([$balance_after, $wallet['id']]);
                
                // Log transaction
                $log_stmt = $pdo->prepare("INSERT INTO wallet_transactions (wallet_id, admin_id, type, amount, balance_before, balance_after, description) VALUES (?, ?, ?, ?, ?, ?, ?)");
                $log_stmt->execute([$wallet['id'], $admin_id, $type, $amount, $balance_before, $balance_after, $description]);
                
                // Log security event
                if (function_exists('logSecurityEvent')) {
                    logSecurityEvent($admin_id, "wallet_{$type}", 'admin_wallet', $user_id, [
                        'amount' => $amount,
                        'balance_before' => $balance_before,
                        'balance_after' => $balance_after,
                        'description' => $description
                    ]);
                }
                
                // Create notification for user
                try {
                    $notification_title = ($type === 'credit') ? 'Wallet Credited' : 'Wallet Debited';
                    $notification_msg = sprintf(
                        'Your wallet has been %s with $%.2f. New balance: $%.2f. Reason: %s',
                        $type === 'credit' ? 'credited' : 'debited',
                        $amount,
                        $balance_after,
                        $description
                    );
                    $pdo->prepare("INSERT INTO notifications (user_id, type, title, message, created_at) VALUES (?, 'wallet', ?, ?, NOW())")->execute([$user_id, $notification_title, $notification_msg]);
                } catch (Exception $e) {
                    error_log("Failed to create wallet transaction notification: " . $e->getMessage());
                }
                
                $_SESSION['success_message'] = 'Wallet balance updated successfully.';
                break;
            case 'change_status':
                 if (!$wallet) throw new Exception('No wallet found.');
                 $new_status = in_array($_POST['status'], ['active', 'suspended']) ? $_POST['status'] : 'active';
                 $pdo->prepare("UPDATE wallets SET status = ? WHERE id = ?")->execute([$new_status, $wallet['id']]);
                 
                 // Log security event
                 if (function_exists('logSecurityEvent')) {
                     logSecurityEvent($admin_id, "wallet_status_change", 'admin_wallet', $user_id, [
                         'new_status' => $new_status
                     ]);
                 }
                 
                 // Create notification for user
                 try {
                     $notification_title = ($new_status === 'suspended') ? 'Wallet Suspended' : 'Wallet Activated';
                     $notification_msg = ($new_status === 'suspended') 
                         ? 'Your wallet has been suspended. Please contact support for more information.'
                         : 'Your wallet has been activated and is now ready to use.';
                     $pdo->prepare("INSERT INTO notifications (user_id, type, title, message, created_at) VALUES (?, 'wallet', ?, ?, NOW())")->execute([$user_id, $notification_title, $notification_msg]);
                 } catch (Exception $e) {
                     error_log("Failed to create wallet status notification: " . $e->getMessage());
                 }
                 
                 $_SESSION['success_message'] = 'Wallet status updated successfully.';
                break;
            case 'transfer':
                if (!$wallet) throw new Exception('No wallet found.');
                $to_user_id = filter_input(INPUT_POST, 'to_user_id', FILTER_VALIDATE_INT);
                $amount = filter_input(INPUT_POST, 'amount', FILTER_VALIDATE_FLOAT);
                $description = trim(filter_input(INPUT_POST, 'description', FILTER_SANITIZE_STRING));
                
                if (!$to_user_id) throw new Exception("Invalid recipient user.");
                if ($to_user_id == $user_id) throw new Exception("Cannot transfer to the same wallet.");
                if ($amount <= 0) throw new Exception("Amount must be positive.");
                if (empty($description)) throw new Exception("A description is required.");
                if ($amount > $wallet['balance']) throw new Exception("Insufficient balance for transfer.");
                
                // Check if recipient has a wallet
                $to_wallet_stmt = $pdo->prepare("SELECT id, balance FROM wallets WHERE user_id = ?");
                $to_wallet_stmt->execute([$to_user_id]);
                $to_wallet = $to_wallet_stmt->fetch(PDO::FETCH_ASSOC);
                
                if (!$to_wallet) throw new Exception("Recipient does not have a wallet.");
                
                $balance_before_from = $wallet['balance'];
                $balance_after_from = $balance_before_from - $amount;
                $balance_before_to = $to_wallet['balance'];
                $balance_after_to = $balance_before_to + $amount;
                
                // Debit from sender
                $pdo->prepare("UPDATE wallets SET balance = ? WHERE id = ?")->execute([$balance_after_from, $wallet['id']]);
                $pdo->prepare("INSERT INTO wallet_transactions (wallet_id, admin_id, user_id, type, amount, balance_before, balance_after, description) VALUES (?, ?, ?, 'debit', ?, ?, ?, ?)")
                    ->execute([$wallet['id'], $admin_id, $user_id, $amount, $balance_before_from, $balance_after_from, "Transfer to user #$to_user_id: $description"]);
                
                // Credit to recipient
                $pdo->prepare("UPDATE wallets SET balance = ? WHERE id = ?")->execute([$balance_after_to, $to_wallet['id']]);
                $pdo->prepare("INSERT INTO wallet_transactions (wallet_id, admin_id, user_id, type, amount, balance_before, balance_after, description) VALUES (?, ?, ?, 'credit', ?, ?, ?, ?)")
                    ->execute([$to_wallet['id'], $admin_id, $to_user_id, $amount, $balance_before_to, $balance_after_to, "Transfer from user #$user_id: $description"]);
                
                // Log security event
                if (function_exists('logSecurityEvent')) {
                    logSecurityEvent($admin_id, "wallet_transfer", 'admin_wallet', $user_id, [
                        'amount' => $amount,
                        'from_user_id' => $user_id,
                        'to_user_id' => $to_user_id,
                        'description' => $description
                    ]);
                }
                
                // Create notifications for both users
                try {
                    $pdo->prepare("INSERT INTO notifications (user_id, type, title, message, created_at) VALUES (?, 'wallet', 'Wallet Transfer', 'An admin transferred $%.2f from your wallet. New balance: $%.2f. Reason: %s', NOW())")
                        ->execute([$user_id, sprintf('$%.2f', $amount), sprintf('$%.2f', $balance_after_from), $description]);
                    $pdo->prepare("INSERT INTO notifications (user_id, type, title, message, created_at) VALUES (?, 'wallet', 'Wallet Transfer', 'An admin transferred $%.2f to your wallet. New balance: $%.2f. Reason: %s', NOW())")
                        ->execute([$to_user_id, sprintf('$%.2f', $amount), sprintf('$%.2f', $balance_after_to), $description]);
                } catch (Exception $e) {
                    error_log("Failed to create transfer notifications: " . $e->getMessage());
                }
                
                $_SESSION['success_message'] = 'Transfer completed successfully.';
                break;
            case 'pay':
                if (!$wallet) throw new Exception('No wallet found.');
                $amount = filter_input(INPUT_POST, 'amount', FILTER_VALIDATE_FLOAT);
                $description = trim(filter_input(INPUT_POST, 'description', FILTER_SANITIZE_STRING));
                $payment_method = trim($_POST['payment_method'] ?? '');
                
                if ($amount <= 0) throw new Exception("Amount must be positive.");
                if (empty($description)) throw new Exception("A description is required.");
                if (empty($payment_method)) throw new Exception("Payment method is required.");
                
                $balance_before = $wallet['balance'];
                $balance_after = $balance_before - $amount;
                
                if ($balance_after < 0) throw new Exception("Insufficient wallet balance.");
                
                // Update balance
                $pdo->prepare("UPDATE wallets SET balance = ? WHERE id = ?")->execute([$balance_after, $wallet['id']]);
                
                // Log transaction
                $pdo->prepare("INSERT INTO wallet_transactions (wallet_id, admin_id, user_id, type, amount, balance_before, balance_after, description, meta) VALUES (?, ?, ?, 'debit', ?, ?, ?, ?, ?)")
                    ->execute([$wallet['id'], $admin_id, $user_id, $amount, $balance_before, $balance_after, "Payment via $payment_method: $description", json_encode(['payment_method' => $payment_method])]);
                
                // Log security event
                if (function_exists('logSecurityEvent')) {
                    logSecurityEvent($admin_id, "wallet_payment", 'admin_wallet', $user_id, [
                        'amount' => $amount,
                        'payment_method' => $payment_method,
                        'description' => $description
                    ]);
                }
                
                // Create notification
                try {
                    $pdo->prepare("INSERT INTO notifications (user_id, type, title, message, created_at) VALUES (?, 'wallet', 'Wallet Payment', ?, NOW())")
                        ->execute([$user_id, sprintf('A payment of $%.2f was processed from your wallet via %s. New balance: $%.2f. Details: %s', $amount, $payment_method, $balance_after, $description)]);
                } catch (Exception $e) {
                    error_log("Failed to create payment notification: " . $e->getMessage());
                }
                
                $_SESSION['success_message'] = 'Payment processed successfully.';
                break;
        }
        $pdo->commit();
        header("Location: " . strtok($_SERVER['REQUEST_URI'], '?'));
        exit;
    }

    // --- DATA FETCHING (GET) ---
    // Stats
    $stats_query = $pdo->query("SELECT (SELECT COUNT(*) FROM users) as total_users, COALESCE(SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END), 0) as active_wallets, COALESCE(SUM(balance), 0) as total_balance, COALESCE(SUM(CASE WHEN status = 'suspended' THEN 1 ELSE 0 END), 0) as suspended_wallets FROM wallets");
    if ($stats_query) $stats = $stats_query->fetch(PDO::FETCH_ASSOC);

    // Filtering and Searching
    $search = trim($_GET['search'] ?? '');
    $status_filter = trim($_GET['status_filter'] ?? '');
    $params = [];
    $where_clauses = [];

    if ($search) {
        $where_clauses[] = "(u.username LIKE ? OR u.email LIKE ?)";
        $params[] = "%$search%";
        $params[] = "%$search%";
    }
    if ($status_filter) {
        $where_clauses[] = "w.status = ?";
        $params[] = $status_filter;
    }
    $where_sql = count($where_clauses) > 0 ? "WHERE " . implode(' AND ', $where_clauses) : '';

    // Pagination
    $page = filter_input(INPUT_GET, 'page', FILTER_VALIDATE_INT, ['options' => ['default' => 1, 'min_range' => 1]]);
    $limit = 15;
    $offset = ($page - 1) * $limit;
    
    $total_records_stmt = $pdo->prepare("SELECT COUNT(*) FROM users u LEFT JOIN wallets w ON u.id = w.user_id $where_sql");
    $total_records_stmt->execute($params);
    $total_records = $total_records_stmt->fetchColumn();
    $total_pages = ceil($total_records / $limit);

    // Fetch user data with pagination
    $users_stmt = $pdo->prepare("SELECT u.id, u.username, u.email, u.role, w.id as wallet_id, w.balance, w.status as wallet_status FROM users u LEFT JOIN wallets w ON u.id = w.user_id $where_sql ORDER BY u.created_at DESC LIMIT ? OFFSET ?");
    $users_stmt->execute(array_merge($params, [$limit, $offset]));
    $user_wallets = $users_stmt->fetchAll(PDO::FETCH_ASSOC);

} catch (Exception $e) {
    if (isset($pdo) && $pdo->inTransaction()) $pdo->rollBack();
    $error_message = "A critical error occurred: " . $e->getMessage();
}

require_once __DIR__ . '/../../includes/header.php';
?>

<style>
/* Professional Wallet Dashboard Styling */
.btn-group .btn {
    margin: 0 1px;
}
.card {
    border-radius: 8px;
    transition: box-shadow 0.3s ease;
}
.card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}
.table th {
    background-color: #f8f9fa;
    font-weight: 600;
    text-transform: uppercase;
    font-size: 0.85rem;
    letter-spacing: 0.5px;
}
.badge {
    padding: 0.4em 0.8em;
    font-size: 0.85rem;
}
.modal-header {
    border-radius: 8px 8px 0 0;
}
.btn-group-sm > .btn {
    padding: 0.375rem 0.75rem;
    font-size: 0.875rem;
}
.alert {
    border-radius: 6px;
}
</style>

<div class="container-fluid my-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h2">Wallet Management</h1>
        <nav class="nav"><a class="nav-link" href="/admin/">Dashboard</a><a class="nav-link active" href="/admin/wallets/">Wallets</a><a class="nav-link" href="/logout.php">Logout</a></nav>
    </div>

    <?php if ($success_message): ?><div class="alert alert-success"><?php echo htmlspecialchars($success_message); ?></div><?php endif; ?>
    <?php if ($error_message): ?><div class="alert alert-danger"><?php echo htmlspecialchars($error_message); ?></div><?php endif; ?>

    <div class="row g-4 mb-4">
        <div class="col-md-3"><div class="card shadow-sm text-center"><div class="card-body"><h5 class="card-title h2"><?php echo (int)($stats['total_users'] ?? 0); ?></h5><p class="card-text text-muted">TOTAL USERS</p></div></div></div>
        <div class="col-md-3"><div class="card shadow-sm text-center"><div class="card-body"><h5 class="card-title h2 text-success"><?php echo (int)($stats['active_wallets'] ?? 0); ?></h5><p class="card-text text-muted">ACTIVE WALLETS</p></div></div></div>
        <div class="col-md-3"><div class="card shadow-sm text-center"><div class="card-body"><h5 class="card-title h2 text-primary">$<?php echo number_format((float)($stats['total_balance'] ?? 0), 2); ?></h5><p class="card-text text-muted">TOTAL BALANCE</p></div></div></div>
        <div class="col-md-3"><div class="card shadow-sm text-center"><div class="card-body"><h5 class="card-title h2 text-danger"><?php echo (int)($stats['suspended_wallets'] ?? 0); ?></h5><p class="card-text text-muted">SUSPENDED WALLETS</p></div></div></div>
    </div>

    <div class="card shadow-sm">
        <div class="card-header">
            <h5 class="mb-0">User Wallets Overview</h5>
            <form method="GET" class="row g-3 mt-2">
                <div class="col-md-6"><input type="text" name="search" class="form-control" placeholder="Search by username or email..." value="<?php echo htmlspecialchars($search); ?>"></div>
                <div class="col-md-4">
                    <select name="status_filter" class="form-select">
                        <option value="">All Statuses</option>
                        <option value="active" <?php if($status_filter == 'active') echo 'selected'; ?>>Active</option>
                        <option value="suspended" <?php if($status_filter == 'suspended') echo 'selected'; ?>>Suspended</option>
                    </select>
                </div>
                <div class="col-md-2"><button type="submit" class="btn btn-primary w-100">Filter</button></div>
            </form>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead><tr><th>User</th><th>Email</th><th>Role</th><th>Balance</th><th>Status</th><th class="text-end">Actions</th></tr></thead>
                    <tbody>
                        <?php if (empty($user_wallets)): ?>
                            <tr><td colspan="6" class="text-center text-muted p-4">No users found matching your criteria.</td></tr>
                        <?php else: foreach ($user_wallets as $user): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($user['username']); ?></td>
                                <td><?php echo htmlspecialchars($user['email']); ?></td>
                                <td><span class="badge bg-secondary"><?php echo htmlspecialchars($user['role']); ?></span></td>
                                <td><b><?php echo $user['wallet_id'] ? '$' . number_format($user['balance'], 2) : '<span class="text-muted">No Wallet</span>'; ?></b></td>
                                <td>
                                    <?php $status = $user['wallet_status'] ?? 'not_created'; $badges = ['active' => 'bg-success', 'suspended' => 'bg-danger', 'not_created' => 'bg-warning text-dark']; ?>
                                    <span class="badge <?php echo $badges[$status]; ?>"><?php echo str_replace('_', ' ', ucfirst($status)); ?></span>
                                </td>
                                <td class="text-end">
                                    <?php if (!$user['wallet_id']): ?>
                                        <form method="POST" class="d-inline"><input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>"><input type="hidden" name="action" value="create_wallet"><input type="hidden" name="user_id" value="<?php echo $user['id']; ?>"><button type="submit" class="btn btn-sm btn-primary">Create</button></form>
                                    <?php else: ?>
                                        <div class="btn-group btn-group-sm" role="group">
                                            <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#creditModal" data-user-id="<?php echo $user['id']; ?>" data-user-name="<?php echo htmlspecialchars($user['username']); ?>" title="Add funds"><i class="fas fa-plus"></i> Credit</button>
                                            <button class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#debitModal" data-user-id="<?php echo $user['id']; ?>" data-user-name="<?php echo htmlspecialchars($user['username']); ?>" title="Remove funds"><i class="fas fa-minus"></i> Debit</button>
                                            <button class="btn btn-info" data-bs-toggle="modal" data-bs-target="#transferModal" data-user-id="<?php echo $user['id']; ?>" data-user-name="<?php echo htmlspecialchars($user['username']); ?>" title="Transfer funds"><i class="fas fa-exchange-alt"></i> Transfer</button>
                                            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#payModal" data-user-id="<?php echo $user['id']; ?>" data-user-name="<?php echo htmlspecialchars($user['username']); ?>" title="Process payment"><i class="fas fa-credit-card"></i> Pay</button>
                                            <button class="btn btn-secondary" data-bs-toggle="modal" data-bs-target="#statusModal" data-user-id="<?php echo $user['id']; ?>" data-user-name="<?php echo htmlspecialchars($user['username']); ?>" data-current-status="<?php echo $user['wallet_status']; ?>" title="Change status"><i class="fas fa-toggle-on"></i> Status</button>
                                            <a href="wallet_history.php?user_id=<?php echo $user['id']; ?>" class="btn btn-outline-dark" title="View history"><i class="fas fa-history"></i> History</a>
                                        </div>
                                    <?php endif; ?>
                                </td>
                            </tr>
                        <?php endforeach; endif; ?>
                    </tbody>
                </table>
            </div>
            <?php if($total_pages > 1): ?>
            <nav><ul class="pagination justify-content-center">
                <?php for($i = 1; $i <= $total_pages; $i++): ?>
                    <li class="page-item <?php if($i == $page) echo 'active'; ?>"><a class="page-link" href="?page=<?php echo $i; ?>&search=<?php echo urlencode($search); ?>&status_filter=<?php echo urlencode($status_filter); ?>"><?php echo $i; ?></a></li>
                <?php endfor; ?>
            </ul></nav>
            <?php endif; ?>
        </div>
    </div>
</div>

<!-- Modals -->
<!-- Credit Modal -->
<div class="modal fade" id="creditModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title"><i class="fas fa-plus-circle"></i> Credit Wallet</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                    <input type="hidden" name="action" value="credit_debit">
                    <input type="hidden" name="type" value="credit">
                    <input type="hidden" name="user_id" class="modal-user-id">
                    <p>User: <strong class="modal-user-name"></strong></p>
                    <div class="mb-3">
                        <label class="form-label">Amount to Add</label>
                        <input type="number" name="amount" class="form-control" step="0.01" min="0.01" required placeholder="Enter amount">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Reason / Description</label>
                        <input type="text" name="description" class="form-control" required placeholder="e.g., Bonus credit, Refund">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success"><i class="fas fa-plus"></i> Add Funds</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Debit Modal -->
<div class="modal fade" id="debitModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header bg-warning text-dark">
                    <h5 class="modal-title"><i class="fas fa-minus-circle"></i> Debit Wallet</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                    <input type="hidden" name="action" value="credit_debit">
                    <input type="hidden" name="type" value="debit">
                    <input type="hidden" name="user_id" class="modal-user-id">
                    <p>User: <strong class="modal-user-name"></strong></p>
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle"></i> This will remove funds from the user's wallet.
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Amount to Remove</label>
                        <input type="number" name="amount" class="form-control" step="0.01" min="0.01" required placeholder="Enter amount">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Reason / Description</label>
                        <input type="text" name="description" class="form-control" required placeholder="e.g., Adjustment, Chargeback">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-warning"><i class="fas fa-minus"></i> Remove Funds</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Transfer Modal -->
<div class="modal fade" id="transferModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title"><i class="fas fa-exchange-alt"></i> Transfer Funds</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                    <input type="hidden" name="action" value="transfer">
                    <input type="hidden" name="user_id" class="modal-user-id">
                    <p>From User: <strong class="modal-user-name"></strong></p>
                    <div class="mb-3">
                        <label class="form-label">To User ID</label>
                        <input type="number" name="to_user_id" class="form-control" required placeholder="Enter recipient user ID">
                        <small class="form-text text-muted">Enter the ID of the user to transfer funds to.</small>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Amount to Transfer</label>
                        <input type="number" name="amount" class="form-control" step="0.01" min="0.01" required placeholder="Enter amount">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Transfer Reason</label>
                        <input type="text" name="description" class="form-control" required placeholder="e.g., Internal transfer, Settlement">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-info"><i class="fas fa-exchange-alt"></i> Transfer</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Pay Modal -->
<div class="modal fade" id="payModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title"><i class="fas fa-credit-card"></i> Process Payment</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                    <input type="hidden" name="action" value="pay">
                    <input type="hidden" name="user_id" class="modal-user-id">
                    <p>User: <strong class="modal-user-name"></strong></p>
                    <div class="mb-3">
                        <label class="form-label">Payment Amount</label>
                        <input type="number" name="amount" class="form-control" step="0.01" min="0.01" required placeholder="Enter amount">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Payment Method</label>
                        <select name="payment_method" class="form-select" required>
                            <option value="">Select payment method</option>
                            <option value="bank_transfer">Bank Transfer</option>
                            <option value="check">Check</option>
                            <option value="cash">Cash</option>
                            <option value="wire_transfer">Wire Transfer</option>
                            <option value="other">Other</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Payment Description</label>
                        <input type="text" name="description" class="form-control" required placeholder="e.g., Vendor payout, Commission payment">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-credit-card"></i> Process Payment</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Status Modal -->
<div class="modal fade" id="statusModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header bg-secondary text-white">
                    <h5 class="modal-title"><i class="fas fa-toggle-on"></i> Change Wallet Status</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                    <input type="hidden" name="action" value="change_status">
                    <input type="hidden" name="user_id" class="modal-user-id">
                    <p>User: <strong class="modal-user-name"></strong></p>
                    <div class="mb-3">
                        <label class="form-label">New Status</label>
                        <select name="status" class="form-select modal-current-status" required>
                            <option value="active">Active</option>
                            <option value="suspended">Suspended</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger"><i class="fas fa-save"></i> Update Status</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    function populateModal(modalElement, button) {
        modalElement.querySelector('.modal-user-id').value = button.getAttribute('data-user-id');
        modalElement.querySelector('.modal-user-name').textContent = button.getAttribute('data-user-name');
    }
    
    // Credit Modal
    var creditModal = document.getElementById('creditModal');
    if(creditModal) creditModal.addEventListener('show.bs.modal', (e) => populateModal(creditModal, e.relatedTarget));
    
    // Debit Modal
    var debitModal = document.getElementById('debitModal');
    if(debitModal) debitModal.addEventListener('show.bs.modal', (e) => populateModal(debitModal, e.relatedTarget));
    
    // Transfer Modal
    var transferModal = document.getElementById('transferModal');
    if(transferModal) transferModal.addEventListener('show.bs.modal', (e) => populateModal(transferModal, e.relatedTarget));
    
    // Pay Modal
    var payModal = document.getElementById('payModal');
    if(payModal) payModal.addEventListener('show.bs.modal', (e) => populateModal(payModal, e.relatedTarget));
    
    // Status Modal
    var statusModal = document.getElementById('statusModal');
    if(statusModal) statusModal.addEventListener('show.bs.modal', function (e) {
        populateModal(statusModal, e.relatedTarget);
        statusModal.querySelector('.modal-current-status').value = e.relatedTarget.getAttribute('data-current-status');
    });
});
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>