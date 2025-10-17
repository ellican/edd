<?php
/**
 * Vendor Export API
 * Export vendors to CSV based on filters
 */

require_once __DIR__ . '/../../../includes/init.php';

// For testing, bypass admin check 
if (!defined('ADMIN_BYPASS') || !ADMIN_BYPASS) {
    RoleMiddleware::requireAdmin();
}

try {
    // Get filter parameters
    $status_filter = $_GET['status'] ?? '';
    $kyc_filter = $_GET['kyc'] ?? '';
    $search = $_GET['search'] ?? '';
    $sort_by = $_GET['sort'] ?? 'created_at';
    $sort_order = $_GET['order'] ?? 'DESC';

    // Build query with filters
    $where_conditions = ["1=1"];
    $params = [];

    if ($status_filter) {
        $where_conditions[] = "v.status = ?";
        $params[] = $status_filter;
    }

    if ($kyc_filter) {
        $where_conditions[] = "v.kyc_status = ?";
        $params[] = $kyc_filter;
    }

    if ($search) {
        $where_conditions[] = "(v.business_name LIKE ? OR u.username LIKE ? OR u.email LIKE ?)";
        $search_param = "%{$search}%";
        $params[] = $search_param;
        $params[] = $search_param;
        $params[] = $search_param;
    }

    $where_clause = implode(" AND ", $where_conditions);

    // Validate sort column
    $allowed_sorts = ['created_at', 'business_name', 'status', 'total_sales', 'total_orders'];
    if (!in_array($sort_by, $allowed_sorts)) {
        $sort_by = 'created_at';
    }

    $sort_order = strtoupper($sort_order) === 'ASC' ? 'ASC' : 'DESC';

    // Get vendors
    $query = "SELECT 
                v.id,
                v.business_name,
                v.business_email,
                v.business_phone,
                v.business_type,
                v.tax_id,
                v.website,
                v.category,
                v.status,
                v.kyc_status,
                v.commission_rate,
                COALESCE(v.total_products, 0) as total_products,
                COALESCE(v.total_orders, 0) as total_orders,
                COALESCE(v.total_sales, 0.00) as total_sales,
                v.created_at,
                v.approved_at,
                v.kyc_verified_at,
                u.username,
                u.email,
                u.status as user_status
         FROM vendors v
         LEFT JOIN users u ON v.user_id = u.id
         WHERE {$where_clause}
         ORDER BY v.{$sort_by} {$sort_order}";
    
    $vendors = Database::query($query, $params)->fetchAll();

    // Set headers for CSV download
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename=vendors_export_' . date('Y-m-d_His') . '.csv');
    header('Pragma: no-cache');
    header('Expires: 0');

    // Create output stream
    $output = fopen('php://output', 'w');

    // Add BOM for UTF-8
    fprintf($output, chr(0xEF).chr(0xBB).chr(0xBF));

    // CSV Headers
    $headers = [
        'ID',
        'Business Name',
        'Business Email',
        'Business Phone',
        'Business Type',
        'Tax ID',
        'Website',
        'Category',
        'Status',
        'KYC Status',
        'Commission Rate (%)',
        'Total Products',
        'Total Orders',
        'Total Sales',
        'Username',
        'User Email',
        'User Status',
        'Registration Date',
        'Approved Date',
        'KYC Verified Date'
    ];

    fputcsv($output, $headers);

    // CSV Data
    foreach ($vendors as $vendor) {
        $row = [
            $vendor['id'],
            $vendor['business_name'],
            $vendor['business_email'] ?? '',
            $vendor['business_phone'] ?? '',
            ucfirst($vendor['business_type']),
            $vendor['tax_id'] ?? '',
            $vendor['website'] ?? '',
            $vendor['category'] ?? '',
            ucfirst($vendor['status']),
            ucfirst(str_replace('_', ' ', $vendor['kyc_status'] ?? 'Not Submitted')),
            number_format($vendor['commission_rate'], 2),
            $vendor['total_products'],
            $vendor['total_orders'],
            number_format($vendor['total_sales'], 2),
            $vendor['username'],
            $vendor['email'],
            ucfirst($vendor['user_status']),
            $vendor['created_at'] ? date('Y-m-d H:i:s', strtotime($vendor['created_at'])) : '',
            $vendor['approved_at'] ? date('Y-m-d H:i:s', strtotime($vendor['approved_at'])) : '',
            $vendor['kyc_verified_at'] ? date('Y-m-d H:i:s', strtotime($vendor['kyc_verified_at'])) : ''
        ];

        fputcsv($output, $row);
    }

    fclose($output);

    // Log export action
    Database::query(
        "INSERT INTO vendor_audit_logs (vendor_id, admin_id, action, action_type, reason, ip_address) 
         VALUES (0, ?, 'vendors_exported', 'other', 'Exported ' . ? . ' vendors to CSV', ?)",
        [Session::getUserId(), count($vendors), $_SERVER['REMOTE_ADDR'] ?? '']
    );

    exit;
} catch (Exception $e) {
    Logger::error("Vendor export error: " . $e->getMessage());
    http_response_code(500);
    echo "Error exporting vendors: " . $e->getMessage();
    exit;
}
