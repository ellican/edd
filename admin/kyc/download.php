<?php
/**
 * KYC Document Download Handler
 * Secure download endpoint for KYC documents
 */

require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';

// Require admin authentication
requireAdminAuth();
checkPermission('kyc.view');

$pdo = db();
$document_id = intval($_GET['id'] ?? 0);
$type = $_GET['type'] ?? 'user'; // 'user' or 'seller'

if (!$document_id) {
    header('HTTP/1.1 400 Bad Request');
    die('Invalid document ID');
}

try {
    if ($type === 'seller') {
        // Handle seller KYC document download
        $stmt = $pdo->prepare("
            SELECT sk.*, v.business_name, u.email
            FROM seller_kyc sk
            JOIN vendors v ON sk.vendor_id = v.id
            JOIN users u ON v.user_id = u.id
            WHERE sk.id = ?
        ");
        $stmt->execute([$document_id]);
        $kyc = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$kyc) {
            header('HTTP/1.1 404 Not Found');
            die('Document not found');
        }
        
        // For seller KYC, we need to check which document to download
        $doc_type = $_GET['doc_type'] ?? '';
        $doc_category = $_GET['doc_category'] ?? '';
        
        if (empty($doc_type) || empty($doc_category)) {
            header('HTTP/1.1 400 Bad Request');
            die('Document type and category required');
        }
        
        // Parse the JSON document data
        $documents = [];
        switch ($doc_category) {
            case 'identity':
                $documents = json_decode($kyc['identity_documents'] ?? '{}', true);
                break;
            case 'address':
                $documents = json_decode($kyc['address_verification'] ?? '{}', true);
                break;
            case 'bank':
                $documents = json_decode($kyc['bank_verification'] ?? '{}', true);
                break;
            default:
                header('HTTP/1.1 400 Bad Request');
                die('Invalid document category');
        }
        
        if (!isset($documents[$doc_type]) || !isset($documents[$doc_type]['file_path'])) {
            header('HTTP/1.1 404 Not Found');
            die('Document file not found');
        }
        
        $file_path = __DIR__ . '/../..' . $documents[$doc_type]['file_path'];
        $original_name = $documents[$doc_type]['original_name'] ?? basename($file_path);
        
    } else {
        // Handle user KYC document download
        $stmt = $pdo->prepare("
            SELECT kd.*, u.username, u.email
            FROM kyc_documents kd
            JOIN users u ON kd.user_id = u.id
            WHERE kd.id = ?
        ");
        $stmt->execute([$document_id]);
        $document = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$document) {
            header('HTTP/1.1 404 Not Found');
            die('Document not found');
        }
        
        $file_path = __DIR__ . '/../..' . $document['file_path'];
        $original_name = $document['original_filename'] ?? $document['file_name'] ?? basename($file_path);
    }
    
    // Verify file exists
    if (!file_exists($file_path)) {
        error_log("KYC download: File not found at path: " . $file_path);
        header('HTTP/1.1 404 Not Found');
        die('File not found on server');
    }
    
    // Log the download
    logAuditEvent('kyc_document_downloaded', $document_id, 'download', [
        'type' => $type,
        'file' => $original_name
    ]);
    
    // Serve the file
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mime_type = finfo_file($finfo, $file_path);
    finfo_close($finfo);
    
    header('Content-Type: ' . $mime_type);
    header('Content-Disposition: attachment; filename="' . basename($original_name) . '"');
    header('Content-Length: ' . filesize($file_path));
    header('Cache-Control: no-cache, must-revalidate');
    header('Pragma: no-cache');
    
    readfile($file_path);
    exit;
    
} catch (Exception $e) {
    error_log("KYC download error: " . $e->getMessage());
    header('HTTP/1.1 500 Internal Server Error');
    die('Error downloading file');
}
