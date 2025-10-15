<?php
/**
 * Seller Orders - Print Shipping Labels
 * Generate printable shipping labels for orders
 */

require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../auth.php'; // Seller authentication guard

// Initialize database connection
$db = db();

$vendor = new Vendor();

// Check if user is a vendor
$vendorInfo = $vendor->findByUserId(Session::getUserId());
if (!$vendorInfo || $vendorInfo['status'] !== 'approved') {
    http_response_code(403);
    die('Access denied. Vendor approval required.');
}

$vendorId = $vendorInfo['id'];

// Get filters from request
$status = $_GET['status'] ?? $_POST['status'] ?? 'processing,shipped';
$dateRange = $_GET['date_range'] ?? $_POST['date_range'] ?? '';

// Check if specific order items are being printed
$specificOrderItems = $_POST['order_item_ids'] ?? $_GET['order_item_ids'] ?? [];

// Build query with filters
$whereConditions = ['oi.vendor_id = ?'];
$params = [$vendorId];

if (!empty($specificOrderItems)) {
    $placeholders = implode(',', array_fill(0, count($specificOrderItems), '?'));
    $whereConditions[] = "oi.id IN ($placeholders)";
    $params = array_merge($params, $specificOrderItems);
} else {
    // Default: only get orders that need labels (processing or shipped without tracking)
    $statusList = explode(',', $status);
    $statusPlaceholders = implode(',', array_fill(0, count($statusList), '?'));
    $whereConditions[] = "oi.status IN ($statusPlaceholders)";
    $params = array_merge($params, $statusList);
}

if (!empty($dateRange)) {
    switch ($dateRange) {
        case 'today':
            $whereConditions[] = 'DATE(o.created_at) = CURDATE()';
            break;
        case 'week':
            $whereConditions[] = 'o.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)';
            break;
        case 'month':
            $whereConditions[] = 'o.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)';
            break;
    }
}

$whereClause = 'WHERE ' . implode(' AND ', $whereConditions);

// Get orders for label printing
$ordersQuery = "
    SELECT 
        o.order_number,
        DATE_FORMAT(o.created_at, '%Y-%m-%d') as order_date,
        oi.id as order_item_id,
        oi.product_name,
        oi.sku,
        oi.qty as quantity,
        oi.tracking_number,
        oi.status as item_status,
        CONCAT(u.first_name, ' ', u.last_name) as customer_name,
        u.email as customer_email,
        u.phone as customer_phone,
        o.shipping_address,
        v.shop_name as vendor_name,
        v.address as vendor_address,
        v.phone as vendor_phone
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN users u ON o.user_id = u.id
    LEFT JOIN vendors v ON oi.vendor_id = v.id
    $whereClause
    ORDER BY o.created_at DESC
    LIMIT 100
";

try {
    $ordersStmt = $db->prepare($ordersQuery);
    $ordersStmt->execute($params);
    $orders = $ordersStmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($orders)) {
        echo '<!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>No Labels to Print</title>
            <style>
                body { font-family: Arial, sans-serif; padding: 40px; text-align: center; }
                .message { font-size: 18px; color: #666; }
            </style>
        </head>
        <body>
            <h1>No Orders Found</h1>
            <p class="message">There are no orders available to print labels for with the selected filters.</p>
            <button onclick="window.close()">Close</button>
        </body>
        </html>';
        exit;
    }
    
} catch (Exception $e) {
    error_log('Label printing error: ' . $e->getMessage());
    http_response_code(500);
    die('Error loading orders: ' . $e->getMessage());
}

// Parse shipping addresses
foreach ($orders as &$order) {
    $shippingLines = explode("\n", $order['shipping_address']);
    $order['shipping_parsed'] = [
        'full_address' => $order['shipping_address'],
        'line1' => $shippingLines[0] ?? '',
        'line2' => $shippingLines[1] ?? '',
        'line3' => $shippingLines[2] ?? '',
        'line4' => $shippingLines[3] ?? '',
    ];
}
unset($order);

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shipping Labels - <?php echo htmlspecialchars($vendorInfo['shop_name']); ?></title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            font-size: 12pt;
            line-height: 1.4;
        }
        
        .no-print {
            padding: 20px;
            background: #f5f5f5;
            border-bottom: 2px solid #ddd;
        }
        
        .no-print button {
            padding: 10px 20px;
            margin-right: 10px;
            font-size: 14px;
            cursor: pointer;
            background: #3b82f6;
            color: white;
            border: none;
            border-radius: 4px;
        }
        
        .no-print button:hover {
            background: #2563eb;
        }
        
        .no-print .info {
            margin-top: 10px;
            color: #666;
        }
        
        .label-container {
            width: 4in;
            height: 6in;
            padding: 0.25in;
            margin: 0 auto;
            page-break-after: always;
            border: 1px solid #000;
            position: relative;
        }
        
        .label-container:last-child {
            page-break-after: auto;
        }
        
        .label-header {
            border-bottom: 2px solid #000;
            padding-bottom: 10px;
            margin-bottom: 10px;
        }
        
        .from-section, .to-section {
            margin-bottom: 15px;
        }
        
        .section-title {
            font-weight: bold;
            font-size: 10pt;
            margin-bottom: 5px;
            text-transform: uppercase;
        }
        
        .vendor-name {
            font-size: 14pt;
            font-weight: bold;
            margin-bottom: 3px;
        }
        
        .customer-name {
            font-size: 16pt;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .address-line {
            font-size: 11pt;
            margin-bottom: 2px;
        }
        
        .order-info {
            border-top: 1px dashed #000;
            padding-top: 10px;
            margin-top: 10px;
            font-size: 9pt;
        }
        
        .order-info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 3px;
        }
        
        .product-details {
            margin-top: 10px;
            font-size: 10pt;
            border-top: 1px dashed #000;
            padding-top: 10px;
        }
        
        .tracking-number {
            font-size: 14pt;
            font-weight: bold;
            text-align: center;
            padding: 10px;
            background: #f0f0f0;
            margin: 10px 0;
            border: 2px solid #000;
        }
        
        .barcode-placeholder {
            text-align: center;
            padding: 15px;
            background: #fff;
            border: 1px solid #ddd;
            margin: 10px 0;
            font-family: 'Courier New', monospace;
            font-size: 20pt;
            letter-spacing: 2px;
        }
        
        @media print {
            .no-print {
                display: none;
            }
            
            body {
                margin: 0;
                padding: 0;
            }
            
            .label-container {
                margin: 0;
                border: 1px solid #000;
                width: 4in;
                height: 6in;
            }
        }
    </style>
</head>
<body>
    <div class="no-print">
        <button onclick="window.print()">🖨️ Print Labels</button>
        <button onclick="window.close()">❌ Close</button>
        <div class="info">
            <strong><?php echo count($orders); ?> label(s)</strong> ready to print. 
            Make sure your printer is set to 4x6 inch label size.
        </div>
    </div>
    
    <?php foreach ($orders as $order): ?>
    <div class="label-container">
        <!-- From Section -->
        <div class="from-section">
            <div class="section-title">From:</div>
            <div class="vendor-name"><?php echo htmlspecialchars($order['vendor_name'] ?? 'Seller'); ?></div>
            <?php if (!empty($order['vendor_address'])): ?>
                <div class="address-line"><?php echo nl2br(htmlspecialchars($order['vendor_address'])); ?></div>
            <?php endif; ?>
            <?php if (!empty($order['vendor_phone'])): ?>
                <div class="address-line">📞 <?php echo htmlspecialchars($order['vendor_phone']); ?></div>
            <?php endif; ?>
        </div>
        
        <!-- To Section -->
        <div class="to-section">
            <div class="section-title">Ship To:</div>
            <div class="customer-name"><?php echo htmlspecialchars($order['customer_name']); ?></div>
            <?php foreach ($order['shipping_parsed'] as $line): ?>
                <?php if (!empty($line)): ?>
                    <div class="address-line"><?php echo htmlspecialchars($line); ?></div>
                <?php endif; ?>
            <?php endforeach; ?>
            <?php if (!empty($order['customer_phone'])): ?>
                <div class="address-line">📞 <?php echo htmlspecialchars($order['customer_phone']); ?></div>
            <?php endif; ?>
        </div>
        
        <!-- Tracking Number -->
        <?php if (!empty($order['tracking_number'])): ?>
        <div class="tracking-number">
            <?php echo htmlspecialchars($order['tracking_number']); ?>
        </div>
        <div class="barcode-placeholder">
            ||||| |||| ||||| ||||
        </div>
        <?php endif; ?>
        
        <!-- Product Details -->
        <div class="product-details">
            <div><strong>Product:</strong> <?php echo htmlspecialchars($order['product_name']); ?></div>
            <div><strong>SKU:</strong> <?php echo htmlspecialchars($order['sku']); ?></div>
            <div><strong>Qty:</strong> <?php echo htmlspecialchars($order['quantity']); ?></div>
        </div>
        
        <!-- Order Info -->
        <div class="order-info">
            <div class="order-info-row">
                <span><strong>Order:</strong> <?php echo htmlspecialchars($order['order_number']); ?></span>
                <span><strong>Date:</strong> <?php echo htmlspecialchars($order['order_date']); ?></span>
            </div>
            <div class="order-info-row">
                <span><strong>Status:</strong> <?php echo htmlspecialchars(ucfirst($order['item_status'])); ?></span>
                <span><strong>Item ID:</strong> <?php echo htmlspecialchars($order['order_item_id']); ?></span>
            </div>
        </div>
    </div>
    <?php endforeach; ?>
    
    <script>
        // Auto-print on load (optional)
        // window.onload = function() {
        //     window.print();
        // };
    </script>
</body>
</html>
