<?php
/**
 * Secure File Upload Handler
 * Centralized file upload handler with virus scanning and validation
 */

require_once __DIR__ . '/services/VirusScanService.php';

class SecureFileUploadHandler
{
    private $virusScanner;
    private $allowedExtensions;
    private $maxFileSize;
    private $uploadBasePath;
    
    public function __construct($allowedExtensions = null, $maxFileSize = null)
    {
        $this->virusScanner = new VirusScanService();
        
        // Default allowed extensions for images and documents
        $this->allowedExtensions = $allowedExtensions ?? [
            'jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx', 'xls', 'xlsx'
        ];
        
        // Default max file size: 10MB
        $this->maxFileSize = $maxFileSize ?? (10 * 1024 * 1024);
        
        // Base upload path
        $this->uploadBasePath = __DIR__ . '/../uploads/';
    }
    
    /**
     * Handle file upload with security validation
     * 
     * @param array $file The $_FILES array element
     * @param string $destination Destination directory relative to uploads/
     * @param string $prefix Optional filename prefix
     * @return array ['success' => bool, 'message' => string, 'file_path' => string, 'file_info' => array]
     */
    public function handleUpload($file, $destination = '', $prefix = '')
    {
        // Validate file was uploaded
        if (!isset($file['tmp_name']) || !is_uploaded_file($file['tmp_name'])) {
            return $this->error('Invalid file upload');
        }
        
        // Check for upload errors
        if ($file['error'] !== UPLOAD_ERR_OK) {
            return $this->error($this->getUploadErrorMessage($file['error']));
        }
        
        // Validate file size
        if ($file['size'] > $this->maxFileSize) {
            return $this->error('File too large (max ' . $this->formatBytes($this->maxFileSize) . ')');
        }
        
        if ($file['size'] === 0) {
            return $this->error('File is empty');
        }
        
        // Validate file extension
        $filename = $file['name'];
        $extension = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
        
        if (!in_array($extension, $this->allowedExtensions)) {
            return $this->error('File type not allowed: ' . $extension);
        }
        
        // Scan file for viruses and malicious content
        $scanResult = $this->virusScanner->scanFile($file['tmp_name']);
        
        if (!$scanResult['safe']) {
            error_log("File upload blocked by virus scanner: " . $scanResult['message']);
            return $this->error('File failed security scan: ' . $scanResult['message']);
        }
        
        // Create destination directory if it doesn't exist
        $uploadPath = $this->uploadBasePath . $destination;
        if (!is_dir($uploadPath)) {
            if (!mkdir($uploadPath, 0755, true)) {
                return $this->error('Failed to create upload directory');
            }
        }
        
        // Generate unique filename
        $newFilename = $this->generateUniqueFilename($prefix, $extension);
        $filePath = $uploadPath . $newFilename;
        
        // Move uploaded file
        if (!move_uploaded_file($file['tmp_name'], $filePath)) {
            return $this->error('Failed to save uploaded file');
        }
        
        // Set proper permissions
        chmod($filePath, 0644);
        
        // Get file info
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $filePath);
        finfo_close($finfo);
        
        return [
            'success' => true,
            'message' => 'File uploaded successfully',
            'file_path' => '/' . ltrim($destination, '/') . $newFilename,
            'file_info' => [
                'original_name' => $filename,
                'saved_name' => $newFilename,
                'size' => filesize($filePath),
                'mime_type' => $mimeType,
                'extension' => $extension
            ]
        ];
    }
    
    /**
     * Handle multiple file uploads
     */
    public function handleMultipleUploads($files, $destination = '', $prefix = '')
    {
        $results = [];
        $errors = [];
        
        foreach ($files['name'] as $key => $filename) {
            $file = [
                'name' => $files['name'][$key],
                'type' => $files['type'][$key],
                'tmp_name' => $files['tmp_name'][$key],
                'error' => $files['error'][$key],
                'size' => $files['size'][$key]
            ];
            
            $result = $this->handleUpload($file, $destination, $prefix);
            
            if ($result['success']) {
                $results[] = $result;
            } else {
                $errors[] = $result['message'];
            }
        }
        
        return [
            'success' => count($errors) === 0,
            'uploaded' => $results,
            'errors' => $errors,
            'count' => count($results)
        ];
    }
    
    /**
     * Generate unique filename
     */
    private function generateUniqueFilename($prefix, $extension)
    {
        $timestamp = time();
        $random = bin2hex(random_bytes(8));
        return ($prefix ? $prefix . '_' : '') . $timestamp . '_' . $random . '.' . $extension;
    }
    
    /**
     * Get upload error message
     */
    private function getUploadErrorMessage($errorCode)
    {
        $errors = [
            UPLOAD_ERR_INI_SIZE => 'File exceeds upload_max_filesize',
            UPLOAD_ERR_FORM_SIZE => 'File exceeds MAX_FILE_SIZE',
            UPLOAD_ERR_PARTIAL => 'File was only partially uploaded',
            UPLOAD_ERR_NO_FILE => 'No file was uploaded',
            UPLOAD_ERR_NO_TMP_DIR => 'Missing temporary folder',
            UPLOAD_ERR_CANT_WRITE => 'Failed to write file to disk',
            UPLOAD_ERR_EXTENSION => 'Upload stopped by extension'
        ];
        
        return $errors[$errorCode] ?? 'Unknown upload error';
    }
    
    /**
     * Format bytes to human-readable size
     */
    private function formatBytes($bytes)
    {
        if ($bytes >= 1073741824) {
            return number_format($bytes / 1073741824, 2) . ' GB';
        } elseif ($bytes >= 1048576) {
            return number_format($bytes / 1048576, 2) . ' MB';
        } elseif ($bytes >= 1024) {
            return number_format($bytes / 1024, 2) . ' KB';
        }
        return $bytes . ' bytes';
    }
    
    /**
     * Create error response
     */
    private function error($message)
    {
        return [
            'success' => false,
            'message' => $message,
            'file_path' => null,
            'file_info' => null
        ];
    }
    
    /**
     * Delete uploaded file
     */
    public function deleteFile($filePath)
    {
        $fullPath = $this->uploadBasePath . ltrim($filePath, '/');
        
        if (file_exists($fullPath)) {
            return unlink($fullPath);
        }
        
        return false;
    }
}
