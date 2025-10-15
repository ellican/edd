<?php
/**
 * Shipping & Fulfillment Module
 * E-Commerce Platform - Admin Panel
 * 
 * Features:
 * - Shipment creation and tracking
 * - Shipping carrier management
 * - Label generation
 * - Delivery tracking
 */

// Global admin page requirements
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/csrf.php';
require_once __DIR__ . '/../../includes/rbac.php';
require_once __DIR__ . '/../../includes/mailer.php';
require_once __DIR__ . '/../../includes/audit_log.php';

// Initialize with graceful fallback
require_once __DIR__ . '/../../includes/init.php';

// Database graceful fallback
$database_available = false;
$pdo = null;
try {
    $pdo = db();
    $pdo->query('SELECT 1');
    $database_available = true;
} catch (Exception $e) {
    $database_available = false;
    error_log("Database connection failed: " . $e->getMessage());
}

requireAdminAuth();
checkPermission('shipping.view');

// Handle actions
$action = $_GET['action'] ?? 'list';
$shipment_id = $_GET['id'] ?? '';
$message = '';
$error = '';

// Process form submissions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!validateCSRFToken($_POST['csrf_token'] ?? '')) {
        $error = 'Invalid security token.';
    } else {
        try {
            switch ($action) {
                case 'toggle_carrier':
                    $carrier_id = (int)$_POST['carrier_id'];
                    $is_active = (int)$_POST['is_active'];
                    
                    $stmt = $pdo->prepare("UPDATE shipping_carriers SET is_active = ? WHERE id = ?");
                    $stmt->execute([$is_active, $carrier_id]);
                    
                    logAuditEvent('shipping_carrier', $carrier_id, 'toggle_status', [
                        'is_active' => $is_active
                    ]);
                    
                    $_SESSION['success_message'] = 'Carrier status updated successfully.';
                    header('Location: /admin/shipping/');
                    exit;
                    
                case 'toggle_seller_access':
                    $carrier_id = (int)$_POST['carrier_id'];
                    $enabled_for_sellers = (int)$_POST['enabled_for_sellers'];
                    
                    $stmt = $pdo->prepare("UPDATE shipping_carriers SET enabled_for_sellers = ? WHERE id = ?");
                    $stmt->execute([$enabled_for_sellers, $carrier_id]);
                    
                    logAuditEvent('shipping_carrier', $carrier_id, 'toggle_seller_access', [
                        'enabled_for_sellers' => $enabled_for_sellers
                    ]);
                    
                    $_SESSION['success_message'] = 'Seller access updated successfully.';
                    header('Location: /admin/shipping/');
                    exit;
                    
                case 'create_shipment':
                    $order_id = (int)$_POST['order_id'];
                    $carrier = sanitizeInput($_POST['carrier']);
                    $tracking_number = sanitizeInput($_POST['tracking_number']);
                    $shipping_cost = (float)$_POST['shipping_cost'];
                    $notes = sanitizeInput($_POST['notes']);
                    
                    $pdo->beginTransaction();
                    
                    // Create shipment
                    $stmt = $pdo->prepare("
                        INSERT INTO shipments 
                        (order_id, carrier, tracking_number, shipping_cost, status, notes, created_by, created_at)
                        VALUES (?, ?, ?, ?, 'pending', ?, ?, NOW())
                    ");
                    $stmt->execute([$order_id, $carrier, $tracking_number, $shipping_cost, $notes, $_SESSION['admin_id']]);
                    
                    $shipment_id = $pdo->lastInsertId();
                    
                    // Update order status
                    $stmt = $pdo->prepare("UPDATE orders SET status = 'shipped' WHERE id = ?");
                    $stmt->execute([$order_id]);
                    
                    $pdo->commit();
                    
                    logAuditEvent('shipment', $shipment_id, 'create', [
                        'order_id' => $order_id,
                        'carrier' => $carrier,
                        'tracking_number' => $tracking_number
                    ]);
                    
                    $message = 'Shipment created successfully.';
                    break;
                    
                case 'update_status':
                    $id = (int)$_POST['id'];
                    $status = sanitizeInput($_POST['status']);
                    $notes = sanitizeInput($_POST['notes']);
                    
                    $stmt = $pdo->prepare("
                        UPDATE shipments 
                        SET status = ?, notes = ?, updated_at = NOW()
                        WHERE id = ?
                    ");
                    $stmt->execute([$status, $notes, $id]);
                    
                    // Update order status based on shipment status
                    if ($status === 'delivered') {
                        $stmt = $pdo->prepare("
                            UPDATE orders o
                            JOIN shipments s ON o.id = s.order_id
                            SET o.status = 'delivered'
                            WHERE s.id = ?
                        ");
                        $stmt->execute([$id]);
                    }
                    
                    logAuditEvent('shipment', $id, 'status_update', [
                        'new_status' => $status,
                        'notes' => $notes
                    ]);
                    
                    $message = 'Shipment status updated successfully.';
                    break;
                    
                case 'add_carrier':
                    checkPermission('shipping.rates');
                    $name = sanitizeInput($_POST['name']);
                    $code = sanitizeInput($_POST['code']);
                    $tracking_url = sanitizeInput($_POST['tracking_url']);
                    $api_url = sanitizeInput($_POST['api_url'] ?? '');
                    $api_key = sanitizeInput($_POST['api_key'] ?? '');
                    $api_secret = sanitizeInput($_POST['api_secret'] ?? '');
                    $webhook_url = sanitizeInput($_POST['webhook_url'] ?? '');
                    $supports_live_rates = isset($_POST['supports_live_rates']) ? 1 : 0;
                    
                    $stmt = $pdo->prepare("
                        INSERT INTO shipping_carriers 
                        (name, code, tracking_url, api_url, api_key, api_secret, webhook_url, supports_live_rates, is_active)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)
                    ");
                    $stmt->execute([$name, $code, $tracking_url, $api_url, $api_key, $api_secret, $webhook_url, $supports_live_rates]);
                    
                    logAuditEvent('shipping_carrier', $pdo->lastInsertId(), 'create', [
                        'name' => $name,
                        'code' => $code
                    ]);
                    
                    $_SESSION['success_message'] = 'Shipping carrier added successfully.';
                    header('Location: /admin/shipping/');
                    exit;
                    
                case 'edit_carrier':
                    checkPermission('shipping.rates');
                    $carrier_id = (int)$_POST['carrier_id'];
                    $name = sanitizeInput($_POST['name']);
                    $code = sanitizeInput($_POST['code']);
                    $tracking_url = sanitizeInput($_POST['tracking_url']);
                    $api_url = sanitizeInput($_POST['api_url'] ?? '');
                    $api_key = sanitizeInput($_POST['api_key'] ?? '');
                    $api_secret = sanitizeInput($_POST['api_secret'] ?? '');
                    $webhook_url = sanitizeInput($_POST['webhook_url'] ?? '');
                    $supports_live_rates = isset($_POST['supports_live_rates']) ? 1 : 0;
                    
                    $stmt = $pdo->prepare("
                        UPDATE shipping_carriers 
                        SET name = ?, code = ?, tracking_url = ?, api_url = ?, api_key = ?, 
                            api_secret = ?, webhook_url = ?, supports_live_rates = ?, updated_at = NOW()
                        WHERE id = ?
                    ");
                    $stmt->execute([$name, $code, $tracking_url, $api_url, $api_key, $api_secret, $webhook_url, $supports_live_rates, $carrier_id]);
                    
                    logAuditEvent('shipping_carrier', $carrier_id, 'update', [
                        'name' => $name,
                        'code' => $code
                    ]);
                    
                    $_SESSION['success_message'] = 'Shipping carrier updated successfully.';
                    header('Location: /admin/shipping/');
                    exit;
                    
                case 'delete_carrier':
                    checkPermission('shipping.rates');
                    $carrier_id = (int)$_POST['carrier_id'];
                    
                    $stmt = $pdo->prepare("DELETE FROM shipping_carriers WHERE id = ?");
                    $stmt->execute([$carrier_id]);
                    
                    logAuditEvent('shipping_carrier', $carrier_id, 'delete', []);
                    
                    $_SESSION['success_message'] = 'Shipping carrier deleted successfully.';
                    header('Location: /admin/shipping/');
                    exit;
                    
                case 'test_api':
                    checkPermission('shipping.rates');
                    header('Content-Type: application/json');
                    
                    $carrier_id = (int)$_POST['carrier_id'];
                    $stmt = $pdo->prepare("SELECT * FROM shipping_carriers WHERE id = ?");
                    $stmt->execute([$carrier_id]);
                    $carrier = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    if (!$carrier) {
                        echo json_encode(['success' => false, 'message' => 'Carrier not found']);
                        exit;
                    }
                    
                    if (empty($carrier['api_url'])) {
                        echo json_encode(['success' => false, 'message' => 'API URL not configured']);
                        exit;
                    }
                    
                    // Test API connection
                    try {
                        $ch = curl_init($carrier['api_url']);
                        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
                        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
                        
                        if (!empty($carrier['api_key'])) {
                            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                                'Authorization: Bearer ' . $carrier['api_key']
                            ]);
                        }
                        
                        $response = curl_exec($ch);
                        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                        $error = curl_error($ch);
                        curl_close($ch);
                        
                        if ($error) {
                            echo json_encode(['success' => false, 'message' => 'Connection error: ' . $error]);
                        } elseif ($httpCode >= 200 && $httpCode < 300) {
                            echo json_encode(['success' => true, 'message' => 'API connection successful (HTTP ' . $httpCode . ')']);
                        } elseif ($httpCode >= 400 && $httpCode < 500) {
                            echo json_encode(['success' => false, 'message' => 'Authentication error (HTTP ' . $httpCode . ')']);
                        } else {
                            echo json_encode(['success' => false, 'message' => 'Server error (HTTP ' . $httpCode . ')']);
                        }
                    } catch (Exception $e) {
                        echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
                    }
                    exit;
            }
        } catch (Exception $e) {
            if (isset($pdo) && $pdo->inTransaction()) {
                $pdo->rollBack();
            }
            $error = $e->getMessage();
        }
    }
}

// Get data for display
$shipments = [];
$carriers = [];
$pending_orders = [];
$shipping_stats = [
    'total_shipments' => 0,
    'pending_shipments' => 0,
    'shipped_count' => 0,
    'delivered_count' => 0,
    'avg_delivery_days' => 0
];

if ($database_available) {
    try {
        // Get shipments with order and customer info - Fixed MariaDB compatibility
        $stmt = $pdo->query("
            SELECT s.*, o.id as order_number, 
                   COALESCE(u.username, 'Guest') as customer_name, 
                   u.email as customer_email,
                   COALESCE(admin.username, 'System') as created_by_name
            FROM shipments s
            JOIN orders o ON s.order_id = o.id
            LEFT JOIN users u ON o.user_id = u.id
            LEFT JOIN users admin ON s.created_by = admin.id
            ORDER BY s.created_at DESC
            LIMIT 50
        ");
        $shipments = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Get shipping carriers - Create default carriers if none exist
        $stmt = $pdo->query("SELECT * FROM shipping_carriers ORDER BY sort_order, name");
        $carriers = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // If no carriers exist, create some default ones
        if (empty($carriers)) {
            $default_carriers = [
                ['name' => 'UPS', 'code' => 'ups', 'tracking_url' => 'https://www.ups.com/track?track=yes&trackNums={{tracking_number}}', 'api_url' => '', 'api_key' => '', 'api_secret' => '', 'webhook_url' => ''],
                ['name' => 'FedEx', 'code' => 'fedex', 'tracking_url' => 'https://www.fedex.com/fedextrack/?trknbr={{tracking_number}}', 'api_url' => '', 'api_key' => '', 'api_secret' => '', 'webhook_url' => ''],
                ['name' => 'DHL', 'code' => 'dhl', 'tracking_url' => 'https://www.dhl.com/track?trackingNumber={{tracking_number}}', 'api_url' => '', 'api_key' => '', 'api_secret' => '', 'webhook_url' => ''],
                ['name' => 'USPS', 'code' => 'usps', 'tracking_url' => 'https://tools.usps.com/go/TrackConfirmAction?qtc_tLabels1={{tracking_number}}', 'api_url' => '', 'api_key' => '', 'api_secret' => '', 'webhook_url' => '']
            ];
            
            foreach ($default_carriers as $carrier) {
                $stmt = $pdo->prepare("
                    INSERT INTO shipping_carriers (name, code, tracking_url, api_url, api_key, api_secret, webhook_url, is_active) 
                    VALUES (?, ?, ?, ?, ?, ?, ?, 1)
                ");
                $stmt->execute([$carrier['name'], $carrier['code'], $carrier['tracking_url'], $carrier['api_url'], $carrier['api_key'], $carrier['api_secret'], $carrier['webhook_url']]);
            }
            
            // Re-fetch carriers
            $stmt = $pdo->query("SELECT * FROM shipping_carriers ORDER BY sort_order, name");
            $carriers = $stmt->fetchAll(PDO::FETCH_ASSOC);
        }
        
        // Get orders ready for shipping - Fixed MariaDB compatibility
        $stmt = $pdo->query("
            SELECT o.*, COALESCE(u.username, 'Guest') as customer_name, u.email as customer_email
            FROM orders o
            LEFT JOIN users u ON o.user_id = u.id
            LEFT JOIN shipments s ON o.id = s.order_id
            WHERE o.status IN ('paid', 'processing') AND s.id IS NULL
            ORDER BY o.created_at DESC
            LIMIT 20
        ");
        $pending_orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Get shipping statistics - Fixed date function for MariaDB
        $stmt = $pdo->query("
            SELECT 
                COUNT(*) as total_shipments,
                COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_shipments,
                COUNT(CASE WHEN status = 'shipped' THEN 1 END) as shipped_count,
                COUNT(CASE WHEN status = 'delivered' THEN 1 END) as delivered_count,
                AVG(DATEDIFF(
                    CASE WHEN status = 'delivered' THEN delivered_at ELSE CURDATE() END,
                    created_at
                )) as avg_delivery_days
            FROM shipments
            WHERE DATE(created_at) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
        ");
        $shipping_stats = $stmt->fetch(PDO::FETCH_ASSOC) ?: $shipping_stats;
        
    } catch (Exception $e) {
        $error = "Error loading shipping data: " . $e->getMessage();
        error_log("Shipping data error: " . $e->getMessage());
    }
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shipping & Fulfillment - Admin Panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .sidebar { min-height: 100vh; background-color: #2c3e50; }
        .sidebar a { color: #bdc3c7; text-decoration: none; }
        .sidebar a:hover { color: #fff; background-color: #34495e; }
        .btn-group-sm .btn { 
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
            white-space: nowrap;
        }
        .table-responsive { overflow-x: auto; }
        .badge { font-size: 0.875rem; }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-2 sidebar p-3">
                <h4 class="text-white mb-4">Admin Panel</h4>
                <ul class="nav flex-column">
                    <li class="nav-item">
                        <a class="nav-link" href="../index.php">
                            <i class="fas fa-tachometer-alt"></i> Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="index.php">
                            <i class="fas fa-truck"></i> Shipping
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../orders/index.php">
                            <i class="fas fa-shopping-cart"></i> Orders
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../inventory/index.php">
                            <i class="fas fa-boxes"></i> Inventory
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Main Content -->
            <div class="col-md-10 p-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="fas fa-truck text-primary"></i> Shipping & Fulfillment</h2>
                    <div class="btn-group">
                        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#shipmentModal">
                            <i class="fas fa-plus"></i> Create Shipment
                        </button>
                        <?php if (hasPermission('shipping.rates')): ?>
                        <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#carrierModal">
                            <i class="fas fa-shipping-fast"></i> Add Carrier
                        </button>
                        <?php endif; ?>
                    </div>
                </div>

                <?php if ($message): ?>
                    <div class="alert alert-success alert-dismissible fade show">
                        <?= htmlspecialchars($message) ?>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <?php endif; ?>

                <?php if ($error): ?>
                    <div class="alert alert-danger alert-dismissible fade show">
                        <?= htmlspecialchars($error) ?>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <?php endif; ?>

                <?php if (!$database_available): ?>
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle"></i>
                        Database connection unavailable. Some features may not work properly.
                    </div>
                <?php endif; ?>

                <!-- Shipping Statistics -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card bg-warning text-white">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h4><?= number_format($shipping_stats['pending_shipments'] ?? 0) ?></h4>
                                        <p class="mb-0">Pending Shipments</p>
                                    </div>
                                    <div class="align-self-center">
                                        <i class="fas fa-clock fa-2x"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-info text-white">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h4><?= number_format($shipping_stats['shipped_count'] ?? 0) ?></h4>
                                        <p class="mb-0">In Transit</p>
                                    </div>
                                    <div class="align-self-center">
                                        <i class="fas fa-truck fa-2x"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-success text-white">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h4><?= number_format($shipping_stats['delivered_count'] ?? 0) ?></h4>
                                        <p class="mb-0">Delivered</p>
                                    </div>
                                    <div class="align-self-center">
                                        <i class="fas fa-check-circle fa-2x"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card bg-primary text-white">
                            <div class="card-body">
                                <div class="d-flex justify-content-between">
                                    <div>
                                        <h4><?= number_format($shipping_stats['avg_delivery_days'] ?? 0, 1) ?></h4>
                                        <p class="mb-0">Avg Delivery Days</p>
                                    </div>
                                    <div class="align-self-center">
                                        <i class="fas fa-calendar fa-2x"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <!-- Pending Orders -->
                    <div class="col-md-6">
                        <div class="card mb-4">
                            <div class="card-header">
                                <h5 class="mb-0">Orders Ready for Shipping</h5>
                            </div>
                            <div class="card-body">
                                <?php if (empty($pending_orders)): ?>
                                    <div class="text-center py-4">
                                        <i class="fas fa-truck fa-3x text-muted mb-3"></i>
                                        <p class="text-muted">No orders ready for shipping.</p>
                                    </div>
                                <?php else: ?>
                                <div class="table-responsive">
                                    <table class="table table-sm">
                                        <thead>
                                            <tr>
                                                <th>Order</th>
                                                <th>Customer</th>
                                                <th>Total</th>
                                                <th>Date</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php foreach ($pending_orders as $order): ?>
                                            <tr>
                                                <td>
                                                    <a href="../orders/index.php?action=view&id=<?= $order['id'] ?>">
                                                        #<?= $order['id'] ?>
                                                    </a>
                                                </td>
                                                <td>
                                                    <?= htmlspecialchars($order['customer_name'] ?? 'Guest') ?><br>
                                                    <small class="text-muted"><?= htmlspecialchars($order['customer_email'] ?? '') ?></small>
                                                </td>
                                                <td>$<?= number_format($order['total'] ?? 0, 2) ?></td>
                                                <td><?= date('M j', strtotime($order['created_at'])) ?></td>
                                                <td>
                                                    <button class="btn btn-sm btn-primary" onclick="createShipment(<?= $order['id'] ?>)">
                                                        <i class="fas fa-truck"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                            <?php endforeach; ?>
                                        </tbody>
                                    </table>
                                </div>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>

                    <!-- Shipping Carriers -->
                    <div class="col-md-6">
                        <div class="card mb-4">
                            <div class="card-header">
                                <h5 class="mb-0">Shipping Carriers</h5>
                            </div>
                            <div class="card-body">
                                <?php if (empty($carriers)): ?>
                                    <div class="text-center py-4">
                                        <i class="fas fa-shipping-fast fa-3x text-muted mb-3"></i>
                                        <p class="text-muted">No shipping carriers configured.</p>
                                        <?php if (hasPermission('shipping.rates')): ?>
                                        <button class="btn btn-success" data-bs-toggle="modal" data-bs-target="#carrierModal">
                                            <i class="fas fa-plus"></i> Add Carrier
                                        </button>
                                        <?php endif; ?>
                                    </div>
                                <?php else: ?>
                                <div class="table-responsive">
                                    <table class="table table-sm">
                                        <thead>
                                            <tr>
                                                <th>Carrier</th>
                                                <th>Code</th>
                                                <th>API Status</th>
                                                <th>Seller Access</th>
                                                <th>Status</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <?php foreach ($carriers as $carrier): ?>
                                            <tr>
                                                <td>
                                                    <strong><?= htmlspecialchars($carrier['name'] ?? 'Unknown') ?></strong>
                                                </td>
                                                <td><code><?= htmlspecialchars($carrier['code'] ?? 'N/A') ?></code></td>
                                                <td>
                                                    <?php if (!empty($carrier['api_url']) || !empty($carrier['api_key'])): ?>
                                                        <span class="badge bg-success">
                                                            <i class="fas fa-check-circle"></i> Configured
                                                        </span>
                                                    <?php else: ?>
                                                        <span class="badge bg-warning">
                                                            <i class="fas fa-exclamation-circle"></i> Not Configured
                                                        </span>
                                                    <?php endif; ?>
                                                </td>
                                                <td>
                                                    <?php if ($carrier['enabled_for_sellers'] ?? 0): ?>
                                                        <span class="badge bg-success">
                                                            <i class="fas fa-users"></i> Enabled
                                                        </span>
                                                    <?php else: ?>
                                                        <span class="badge bg-secondary">
                                                            <i class="fas fa-ban"></i> Disabled
                                                        </span>
                                                    <?php endif; ?>
                                                </td>
                                                <td>
                                                    <span class="badge bg-<?= ($carrier['is_active'] ?? 0) ? 'success' : 'secondary' ?>">
                                                        <?= ($carrier['is_active'] ?? 0) ? 'Active' : 'Inactive' ?>
                                                    </span>
                                                </td>
                                                <td>
                                                    <?php if (hasPermission('shipping.rates')): ?>
                                                    <div class="btn-group btn-group-sm" role="group">
                                                        <button class="btn btn-outline-primary" 
                                                                onclick="editCarrier(<?= $carrier['id'] ?>)"
                                                                title="Edit Carrier Settings"
                                                                data-carrier='<?= htmlspecialchars(json_encode($carrier), ENT_QUOTES) ?>'>
                                                            <i class="fas fa-edit"></i> Edit
                                                        </button>
                                                        <button class="btn btn-outline-<?= ($carrier['is_active'] ?? 0) ? 'warning' : 'success' ?>"
                                                                onclick="toggleCarrierStatus(<?= $carrier['id'] ?>, <?= ($carrier['is_active'] ?? 0) ? 'false' : 'true' ?>)"
                                                                title="<?= ($carrier['is_active'] ?? 0) ? 'Disable' : 'Enable' ?> Carrier">
                                                            <i class="fas fa-power-off"></i> <?= ($carrier['is_active'] ?? 0) ? 'Disable' : 'Enable' ?>
                                                        </button>
                                                        <button class="btn btn-outline-info"
                                                                onclick="toggleSellerAccess(<?= $carrier['id'] ?>, <?= ($carrier['enabled_for_sellers'] ?? 0) ? 'false' : 'true' ?>)"
                                                                title="<?= ($carrier['enabled_for_sellers'] ?? 0) ? 'Disable' : 'Enable' ?> for Sellers">
                                                            <i class="fas fa-store"></i> Seller
                                                        </button>
                                                        <?php if (!empty($carrier['api_url'])): ?>
                                                        <button class="btn btn-outline-secondary"
                                                                onclick="testAPI(<?= $carrier['id'] ?>)"
                                                                title="Test API Connection">
                                                            <i class="fas fa-plug"></i> Test
                                                        </button>
                                                        <?php endif; ?>
                                                        <button class="btn btn-outline-danger"
                                                                onclick="deleteCarrier(<?= $carrier['id'] ?>, '<?= htmlspecialchars($carrier['name'], ENT_QUOTES) ?>')"
                                                                title="Delete Carrier">
                                                            <i class="fas fa-trash"></i>
                                                        </button>
                                                    </div>
                                                    <?php endif; ?>
                                                </td>
                                            </tr>
                                            <?php endforeach; ?>
                                        </tbody>
                                    </table>
                                </div>
                                <?php endif; ?>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Shipments -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Recent Shipments</h5>
                    </div>
                    <div class="card-body">
                        <?php if (empty($shipments)): ?>
                            <div class="text-center py-4">
                                <i class="fas fa-shipping-fast fa-3x text-muted mb-3"></i>
                                <p class="text-muted">No shipments found.</p>
                            </div>
                        <?php else: ?>
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Shipment ID</th>
                                        <th>Order</th>
                                        <th>Customer</th>
                                        <th>Carrier</th>
                                        <th>Tracking</th>
                                        <th>Status</th>
                                        <th>Created</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($shipments as $shipment): ?>
                                    <tr>
                                        <td>#<?= $shipment['id'] ?></td>
                                        <td>
                                            <a href="../orders/index.php?action=view&id=<?= $shipment['order_id'] ?>">
                                                #<?= $shipment['order_number'] ?>
                                            </a>
                                        </td>
                                        <td>
                                            <?= htmlspecialchars($shipment['customer_name'] ?? 'Guest') ?><br>
                                            <small class="text-muted"><?= htmlspecialchars($shipment['customer_email'] ?? '') ?></small>
                                        </td>
                                        <td><?= htmlspecialchars($shipment['carrier'] ?? 'N/A') ?></td>
                                        <td>
                                            <?php if (!empty($shipment['tracking_number'])): ?>
                                            <code><?= htmlspecialchars($shipment['tracking_number']) ?></code>
                                            <?php else: ?>
                                            <span class="text-muted">N/A</span>
                                            <?php endif; ?>
                                        </td>
                                        <td>
                                            <?php
                                            $status_colors = [
                                                'pending' => 'warning',
                                                'shipped' => 'info',
                                                'in_transit' => 'primary',
                                                'delivered' => 'success',
                                                'exception' => 'danger'
                                            ];
                                            $color = $status_colors[$shipment['status'] ?? 'pending'] ?? 'secondary';
                                            ?>
                                            <span class="badge bg-<?= $color ?>"><?= ucfirst($shipment['status'] ?? 'Pending') ?></span>
                                        </td>
                                        <td><?= date('M j, Y', strtotime($shipment['created_at'])) ?></td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-primary" onclick="updateShipmentStatus(<?= $shipment['id'] ?>, '<?= $shipment['status'] ?? 'pending' ?>')">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <?php if (!empty($shipment['tracking_number'])): ?>
                                            <button class="btn btn-sm btn-outline-info" onclick="trackShipment('<?= htmlspecialchars($shipment['tracking_number']) ?>', '<?= htmlspecialchars($shipment['carrier'] ?? '') ?>')">
                                                <i class="fas fa-search"></i>
                                            </button>
                                            <?php endif; ?>
                                        </td>
                                    </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Create Shipment Modal -->
    <div class="modal fade" id="shipmentModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form method="POST" action="?action=create_shipment">
                    <div class="modal-header">
                        <h5 class="modal-title">Create Shipment</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="csrf_token" value="<?= generateCSRFToken() ?>">
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Order *</label>
                                    <select name="order_id" id="shipment_order_id" class="form-select" required>
                                        <option value="">Select Order</option>
                                        <?php foreach ($pending_orders as $order): ?>
                                        <option value="<?= $order['id'] ?>">
                                            #<?= $order['id'] ?> - <?= htmlspecialchars($order['customer_name'] ?? 'Guest') ?>
                                        </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Carrier *</label>
                                    <select name="carrier" class="form-select" required>
                                        <option value="">Select Carrier</option>
                                        <?php foreach ($carriers as $carrier): ?>
                                        <option value="<?= htmlspecialchars($carrier['code'] ?? $carrier['name']) ?>">
                                            <?= htmlspecialchars($carrier['name'] ?? 'Unknown Carrier') ?>
                                        </option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Tracking Number</label>
                                    <input type="text" name="tracking_number" class="form-control">
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Shipping Cost</label>
                                    <input type="number" name="shipping_cost" class="form-control" step="0.01" value="0">
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Notes</label>
                                    <textarea name="notes" class="form-control" rows="4"></textarea>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Create Shipment</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Add Carrier Modal -->
    <div class="modal fade" id="carrierModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form method="POST" action="?action=add_carrier" id="addCarrierForm">
                    <div class="modal-header">
                        <h5 class="modal-title">Add Shipping Carrier</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="csrf_token" value="<?= generateCSRFToken() ?>">
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Carrier Name *</label>
                                    <input type="text" name="name" class="form-control" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Carrier Code *</label>
                                    <input type="text" name="code" class="form-control" required>
                                    <small class="text-muted">Unique identifier (e.g., ups, fedex, dhl)</small>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Tracking URL Template</label>
                            <input type="url" name="tracking_url" class="form-control" placeholder="https://example.com/track?id={{tracking_number}}">
                            <small class="text-muted">Use {{tracking_number}} as placeholder</small>
                        </div>
                        
                        <hr>
                        <h6 class="mb-3">API Configuration</h6>
                        
                        <div class="mb-3">
                            <label class="form-label">API URL</label>
                            <input type="url" name="api_url" class="form-control" placeholder="https://api.carrier.com/v1">
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">API Key</label>
                                    <input type="text" name="api_key" class="form-control" placeholder="Your API key">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">API Secret</label>
                                    <input type="password" name="api_secret" class="form-control" placeholder="Your API secret">
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Webhook URL</label>
                            <input type="url" name="webhook_url" class="form-control" placeholder="https://yoursite.com/webhooks/shipping">
                        </div>
                        
                        <div class="form-check mb-3">
                            <input type="checkbox" name="supports_live_rates" class="form-check-input" id="supports_live_rates_add">
                            <label class="form-check-label" for="supports_live_rates_add">
                                Supports Live Rates
                            </label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success">Add Carrier</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Edit Carrier Modal -->
    <div class="modal fade" id="editCarrierModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <form method="POST" action="?action=edit_carrier" id="editCarrierForm">
                    <div class="modal-header">
                        <h5 class="modal-title">Edit Shipping Carrier</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="csrf_token" value="<?= generateCSRFToken() ?>">
                        <input type="hidden" name="carrier_id" id="edit_carrier_id">
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Carrier Name *</label>
                                    <input type="text" name="name" id="edit_name" class="form-control" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Carrier Code *</label>
                                    <input type="text" name="code" id="edit_code" class="form-control" required>
                                    <small class="text-muted">Unique identifier</small>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Tracking URL Template</label>
                            <input type="url" name="tracking_url" id="edit_tracking_url" class="form-control" placeholder="https://example.com/track?id={{tracking_number}}">
                            <small class="text-muted">Use {{tracking_number}} as placeholder</small>
                        </div>
                        
                        <hr>
                        <h6 class="mb-3">API Configuration</h6>
                        
                        <div class="mb-3">
                            <label class="form-label">API URL</label>
                            <input type="url" name="api_url" id="edit_api_url" class="form-control" placeholder="https://api.carrier.com/v1">
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">API Key</label>
                                    <input type="text" name="api_key" id="edit_api_key" class="form-control" placeholder="Your API key">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">API Secret</label>
                                    <input type="password" name="api_secret" id="edit_api_secret" class="form-control" placeholder="Leave blank to keep unchanged">
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Webhook URL</label>
                            <input type="url" name="webhook_url" id="edit_webhook_url" class="form-control" placeholder="https://yoursite.com/webhooks/shipping">
                        </div>
                        
                        <div class="form-check mb-3">
                            <input type="checkbox" name="supports_live_rates" class="form-check-input" id="edit_supports_live_rates">
                            <label class="form-check-label" for="edit_supports_live_rates">
                                Supports Live Rates
                            </label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Update Carrier</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Update Status Modal -->
    <div class="modal fade" id="statusModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST" action="?action=update_status">
                    <div class="modal-header">
                        <h5 class="modal-title">Update Shipment Status</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <input type="hidden" name="csrf_token" value="<?= generateCSRFToken() ?>">
                        <input type="hidden" name="id" id="status_shipment_id">
                        
                        <div class="mb-3">
                            <label class="form-label">Status</label>
                            <select name="status" id="status_select" class="form-select" required>
                                <option value="pending">Pending</option>
                                <option value="shipped">Shipped</option>
                                <option value="in_transit">In Transit</option>
                                <option value="delivered">Delivered</option>
                                <option value="exception">Exception</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Notes</label>
                            <textarea name="notes" class="form-control" rows="3"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Update Status</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function createShipment(orderId) {
            document.getElementById('shipment_order_id').value = orderId;
            var modal = new bootstrap.Modal(document.getElementById('shipmentModal'));
            modal.show();
        }
        
        function updateShipmentStatus(shipmentId, currentStatus) {
            document.getElementById('status_shipment_id').value = shipmentId;
            document.getElementById('status_select').value = currentStatus;
            
            var modal = new bootstrap.Modal(document.getElementById('statusModal'));
            modal.show();
        }
        
        function trackShipment(trackingNumber, carrier) {
            // Implementation for tracking shipment
            alert(`Track shipment ${trackingNumber} with ${carrier}`);
        }
        
        // Carrier Management Functions
        async function toggleCarrierStatus(carrierId, enable) {
            if (!confirm(`Are you sure you want to ${enable ? 'enable' : 'disable'} this carrier?`)) {
                return;
            }
            
            try {
                const formData = new FormData();
                formData.append('carrier_id', carrierId);
                formData.append('is_active', enable ? '1' : '0');
                formData.append('csrf_token', '<?= generateCSRFToken() ?>');
                
                const response = await fetch('?action=toggle_carrier', {
                    method: 'POST',
                    body: formData
                });
                
                if (response.ok) {
                    location.reload();
                } else {
                    alert('Failed to update carrier status');
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An error occurred while updating carrier status');
            }
        }
        
        async function toggleSellerAccess(carrierId, enable) {
            if (!confirm(`Are you sure you want to ${enable ? 'enable' : 'disable'} this carrier for sellers?`)) {
                return;
            }
            
            try {
                const formData = new FormData();
                formData.append('carrier_id', carrierId);
                formData.append('enabled_for_sellers', enable ? '1' : '0');
                formData.append('csrf_token', '<?= generateCSRFToken() ?>');
                
                const response = await fetch('?action=toggle_seller_access', {
                    method: 'POST',
                    body: formData
                });
                
                if (response.ok) {
                    location.reload();
                } else {
                    alert('Failed to update seller access');
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An error occurred while updating seller access');
            }
        }
        
        function editCarrier(carrierId) {
            // Get carrier data from button attribute
            const button = event.target.closest('button');
            const carrierData = JSON.parse(button.getAttribute('data-carrier'));
            
            // Populate form fields
            document.getElementById('edit_carrier_id').value = carrierData.id;
            document.getElementById('edit_name').value = carrierData.name || '';
            document.getElementById('edit_code').value = carrierData.code || '';
            document.getElementById('edit_tracking_url').value = carrierData.tracking_url || '';
            document.getElementById('edit_api_url').value = carrierData.api_url || '';
            document.getElementById('edit_api_key').value = carrierData.api_key || '';
            document.getElementById('edit_api_secret').value = ''; // Don't pre-fill secrets
            document.getElementById('edit_webhook_url').value = carrierData.webhook_url || '';
            document.getElementById('edit_supports_live_rates').checked = carrierData.supports_live_rates == 1;
            
            // Show modal
            var modal = new bootstrap.Modal(document.getElementById('editCarrierModal'));
            modal.show();
        }
        
        async function deleteCarrier(carrierId, carrierName) {
            if (!confirm(`Are you sure you want to delete "${carrierName}"? This action cannot be undone.`)) {
                return;
            }
            
            try {
                const formData = new FormData();
                formData.append('carrier_id', carrierId);
                formData.append('csrf_token', '<?= generateCSRFToken() ?>');
                
                const response = await fetch('?action=delete_carrier', {
                    method: 'POST',
                    body: formData
                });
                
                if (response.ok) {
                    location.reload();
                } else {
                    alert('Failed to delete carrier');
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An error occurred while deleting carrier');
            }
        }
        
        async function testAPI(carrierId) {
            const button = event.target.closest('button');
            const originalHtml = button.innerHTML;
            button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Testing...';
            button.disabled = true;
            
            try {
                const formData = new FormData();
                formData.append('carrier_id', carrierId);
                formData.append('csrf_token', '<?= generateCSRFToken() ?>');
                
                const response = await fetch('?action=test_api', {
                    method: 'POST',
                    body: formData
                });
                
                const result = await response.json();
                
                if (result.success) {
                    alert('✅ ' + result.message);
                } else {
                    alert('❌ ' + result.message);
                }
            } catch (error) {
                console.error('Error:', error);
                alert('An error occurred while testing API connection');
            } finally {
                button.innerHTML = originalHtml;
                button.disabled = false;
            }
        }
    </script>
</body>
</html>