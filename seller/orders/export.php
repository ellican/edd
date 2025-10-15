<?php
/**
 * Seller Orders Export
 * Export orders to CSV/Excel format
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
$search = $_GET['search'] ?? $_POST['search'] ?? '';
$status = $_GET['status'] ?? $_POST['status'] ?? '';
$dateRange = $_GET['date_range'] ?? $_POST['date_range'] ?? '';
$exportFormat = $_GET['format'] ?? $_POST['format'] ?? 'csv';

// Check if specific order items are being exported
$specificOrderItems = $_POST['order_item_ids'] ?? [];

// Build query with filters
$whereConditions = ['oi.vendor_id = ?'];
$params = [$vendorId];

if (!empty($specificOrderItems)) {
    $placeholders = implode(',', array_fill(0, count($specificOrderItems), '?'));
    $whereConditions[] = "oi.id IN ($placeholders)";
    $params = array_merge($params, $specificOrderItems);
}

if (!empty($search)) {
    $whereConditions[] = '(o.order_number LIKE ? OR u.first_name LIKE ? OR u.last_name LIKE ? OR u.email LIKE ? OR oi.product_name LIKE ?)';
    $searchTerm = "%{$search}%";
    $params = array_merge($params, [$searchTerm, $searchTerm, $searchTerm, $searchTerm, $searchTerm]);
}

if (!empty($status)) {
    $whereConditions[] = 'oi.status = ?';
    $params[] = $status;
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
        case 'quarter':
            $whereConditions[] = 'o.created_at >= DATE_SUB(NOW(), INTERVAL 3 MONTH)';
            break;
        case 'year':
            $whereConditions[] = 'o.created_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR)';
            break;
    }
}

$whereClause = 'WHERE ' . implode(' AND ', $whereConditions);

// Get orders for export (no pagination limit)
$ordersQuery = "
    SELECT 
        o.order_number,
        DATE_FORMAT(o.created_at, '%Y-%m-%d %H:%i:%s') as order_date,
        o.status as order_status,
        o.payment_status,
        o.payment_method,
        o.total as order_total,
        oi.id as order_item_id,
        oi.product_name,
        oi.sku,
        oi.qty as quantity,
        oi.price as unit_price,
        oi.subtotal as item_total,
        oi.status as item_status,
        oi.tracking_number,
        DATE_FORMAT(oi.shipped_at, '%Y-%m-%d %H:%i:%s') as shipped_date,
        DATE_FORMAT(oi.delivered_at, '%Y-%m-%d %H:%i:%s') as delivered_date,
        CONCAT(u.first_name, ' ', u.last_name) as customer_name,
        u.email as customer_email,
        u.phone as customer_phone,
        o.shipping_address,
        o.billing_address,
        v.shop_name as vendor_name
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN users u ON o.user_id = u.id
    LEFT JOIN vendors v ON oi.vendor_id = v.id
    $whereClause
    ORDER BY o.created_at DESC
";

try {
    $ordersStmt = $db->prepare($ordersQuery);
    $ordersStmt->execute($params);
    $orders = $ordersStmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (empty($orders)) {
        die('No orders found to export.');
    }
    
    // Set up export based on format
    if ($exportFormat === 'excel' || $exportFormat === 'xlsx') {
        // Excel format
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment; filename="orders_export_' . date('Y-m-d_His') . '.xls"');
        header('Pragma: no-cache');
        header('Expires: 0');
        
        echo '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">';
        echo '<head><meta charset="UTF-8"></head><body>';
        echo '<table border="1">';
        
        // Header row
        echo '<tr>';
        echo '<th>Order Number</th>';
        echo '<th>Order Date</th>';
        echo '<th>Customer Name</th>';
        echo '<th>Customer Email</th>';
        echo '<th>Customer Phone</th>';
        echo '<th>Product Name</th>';
        echo '<th>SKU</th>';
        echo '<th>Quantity</th>';
        echo '<th>Unit Price</th>';
        echo '<th>Item Total</th>';
        echo '<th>Order Total</th>';
        echo '<th>Item Status</th>';
        echo '<th>Order Status</th>';
        echo '<th>Payment Status</th>';
        echo '<th>Payment Method</th>';
        echo '<th>Tracking Number</th>';
        echo '<th>Shipped Date</th>';
        echo '<th>Delivered Date</th>';
        echo '<th>Shipping Address</th>';
        echo '<th>Billing Address</th>';
        echo '<th>Vendor</th>';
        echo '</tr>';
        
        // Data rows
        foreach ($orders as $order) {
            echo '<tr>';
            echo '<td>' . htmlspecialchars($order['order_number']) . '</td>';
            echo '<td>' . htmlspecialchars($order['order_date']) . '</td>';
            echo '<td>' . htmlspecialchars($order['customer_name']) . '</td>';
            echo '<td>' . htmlspecialchars($order['customer_email']) . '</td>';
            echo '<td>' . htmlspecialchars($order['customer_phone'] ?? '') . '</td>';
            echo '<td>' . htmlspecialchars($order['product_name']) . '</td>';
            echo '<td>' . htmlspecialchars($order['sku']) . '</td>';
            echo '<td>' . htmlspecialchars($order['quantity']) . '</td>';
            echo '<td>' . htmlspecialchars(number_format($order['unit_price'], 2)) . '</td>';
            echo '<td>' . htmlspecialchars(number_format($order['item_total'], 2)) . '</td>';
            echo '<td>' . htmlspecialchars(number_format($order['order_total'], 2)) . '</td>';
            echo '<td>' . htmlspecialchars(ucfirst($order['item_status'])) . '</td>';
            echo '<td>' . htmlspecialchars(ucfirst($order['order_status'])) . '</td>';
            echo '<td>' . htmlspecialchars(ucfirst($order['payment_status'])) . '</td>';
            echo '<td>' . htmlspecialchars($order['payment_method'] ?? '') . '</td>';
            echo '<td>' . htmlspecialchars($order['tracking_number'] ?? '') . '</td>';
            echo '<td>' . htmlspecialchars($order['shipped_date'] ?? '') . '</td>';
            echo '<td>' . htmlspecialchars($order['delivered_date'] ?? '') . '</td>';
            echo '<td>' . htmlspecialchars(str_replace(["\n", "\r"], ' ', $order['shipping_address'] ?? '')) . '</td>';
            echo '<td>' . htmlspecialchars(str_replace(["\n", "\r"], ' ', $order['billing_address'] ?? '')) . '</td>';
            echo '<td>' . htmlspecialchars($order['vendor_name'] ?? '') . '</td>';
            echo '</tr>';
        }
        
        echo '</table>';
        echo '</body></html>';
        
    } else {
        // CSV format (default)
        header('Content-Type: text/csv; charset=utf-8');
        header('Content-Disposition: attachment; filename="orders_export_' . date('Y-m-d_His') . '.csv"');
        header('Pragma: no-cache');
        header('Expires: 0');
        
        // Output stream
        $output = fopen('php://output', 'w');
        
        // UTF-8 BOM for Excel compatibility
        fprintf($output, chr(0xEF).chr(0xBB).chr(0xBF));
        
        // Header row
        fputcsv($output, [
            'Order Number',
            'Order Date',
            'Customer Name',
            'Customer Email',
            'Customer Phone',
            'Product Name',
            'SKU',
            'Quantity',
            'Unit Price',
            'Item Total',
            'Order Total',
            'Item Status',
            'Order Status',
            'Payment Status',
            'Payment Method',
            'Tracking Number',
            'Shipped Date',
            'Delivered Date',
            'Shipping Address',
            'Billing Address',
            'Vendor'
        ]);
        
        // Data rows
        foreach ($orders as $order) {
            fputcsv($output, [
                $order['order_number'],
                $order['order_date'],
                $order['customer_name'],
                $order['customer_email'],
                $order['customer_phone'] ?? '',
                $order['product_name'],
                $order['sku'],
                $order['quantity'],
                number_format($order['unit_price'], 2, '.', ''),
                number_format($order['item_total'], 2, '.', ''),
                number_format($order['order_total'], 2, '.', ''),
                ucfirst($order['item_status']),
                ucfirst($order['order_status']),
                ucfirst($order['payment_status']),
                $order['payment_method'] ?? '',
                $order['tracking_number'] ?? '',
                $order['shipped_date'] ?? '',
                $order['delivered_date'] ?? '',
                str_replace(["\n", "\r"], ' ', $order['shipping_address'] ?? ''),
                str_replace(["\n", "\r"], ' ', $order['billing_address'] ?? ''),
                $order['vendor_name'] ?? ''
            ]);
        }
        
        fclose($output);
    }
    
} catch (Exception $e) {
    error_log('Order export error: ' . $e->getMessage());
    http_response_code(500);
    die('Error exporting orders: ' . $e->getMessage());
}
