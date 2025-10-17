<?php
/**
 * Virus Scanning Service
 * Provides security scanning for uploaded files
 */

class VirusScanService
{
    private $scanEnabled;
    private $maxFileSize;
    private $dangerousExtensions;
    private $suspiciousPatterns;
    
    public function __construct()
    {
        // Enable scanning by default
        $this->scanEnabled = true;
        
        // Max file size to scan (10MB)
        $this->maxFileSize = 10 * 1024 * 1024;
        
        // Dangerous file extensions that should be blocked
        $this->dangerousExtensions = [
            'exe', 'bat', 'cmd', 'com', 'pif', 'scr', 'vbs', 'js', 
            'jar', 'app', 'deb', 'rpm', 'dmg', 'pkg', 'sh', 'bash',
            'ps1', 'psm1', 'dll', 'sys', 'drv', 'msi', 'hta', 'cpl',
            'reg', 'vb', 'wsf', 'wsh', 'asp', 'aspx', 'php3', 'php4',
            'php5', 'phtml', 'jsp', 'jspx'
        ];
        
        // Suspicious patterns in file content (simple heuristic detection)
        $this->suspiciousPatterns = [
            '/eval\s*\(/i',
            '/base64_decode\s*\(/i',
            '/system\s*\(/i',
            '/exec\s*\(/i',
            '/shell_exec\s*\(/i',
            '/passthru\s*\(/i',
            '/proc_open\s*\(/i',
            '/popen\s*\(/i',
            '/<\?php.*?eval/is',
            '/\$_GET\[.*?\]\s*\(/i',
            '/\$_POST\[.*?\]\s*\(/i',
            '/chmod\s*\(\s*[\'"].*?[\'"]\s*,\s*0?7{3,4}\s*\)/i', // chmod 777
        ];
    }
    
    /**
     * Scan a file for viruses and malicious content
     * 
     * @param string $filePath Path to the file to scan
     * @return array ['safe' => bool, 'message' => string, 'threats' => array]
     */
    public function scanFile($filePath)
    {
        if (!$this->scanEnabled) {
            return ['safe' => true, 'message' => 'Scanning disabled', 'threats' => []];
        }
        
        if (!file_exists($filePath)) {
            return ['safe' => false, 'message' => 'File not found', 'threats' => ['file_not_found']];
        }
        
        $threats = [];
        
        // Check 1: File extension validation
        $extension = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
        if (in_array($extension, $this->dangerousExtensions)) {
            $threats[] = "dangerous_extension:{$extension}";
        }
        
        // Check 2: MIME type validation
        $mimeCheck = $this->validateMimeType($filePath, $extension);
        if (!$mimeCheck['valid']) {
            $threats[] = "mime_type_mismatch:{$mimeCheck['message']}";
        }
        
        // Check 3: File size check
        $fileSize = filesize($filePath);
        if ($fileSize === 0) {
            $threats[] = 'empty_file';
        }
        
        // Check 4: Content-based scanning (for text-based files only)
        if ($fileSize > 0 && $fileSize <= $this->maxFileSize) {
            $contentThreats = $this->scanFileContent($filePath, $extension);
            $threats = array_merge($threats, $contentThreats);
        }
        
        // Check 5: ClamAV integration (if available)
        if (function_exists('clam_scan_file')) {
            try {
                $clamResult = clam_scan_file($filePath);
                if ($clamResult !== 'OK') {
                    $threats[] = "clamav:{$clamResult}";
                }
            } catch (Exception $e) {
                error_log("ClamAV scan error: " . $e->getMessage());
            }
        }
        
        // Determine if file is safe
        $safe = empty($threats);
        $message = $safe 
            ? 'File passed security scan' 
            : 'File failed security scan: ' . implode(', ', $threats);
        
        // Log scan result
        $this->logScanResult($filePath, $safe, $threats);
        
        return [
            'safe' => $safe,
            'message' => $message,
            'threats' => $threats
        ];
    }
    
    /**
     * Validate MIME type matches file extension
     */
    private function validateMimeType($filePath, $extension)
    {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $filePath);
        finfo_close($finfo);
        
        // Define allowed MIME types for common extensions
        $allowedMimes = [
            'jpg' => ['image/jpeg', 'image/jpg'],
            'jpeg' => ['image/jpeg', 'image/jpg'],
            'png' => ['image/png'],
            'gif' => ['image/gif'],
            'pdf' => ['application/pdf'],
            'doc' => ['application/msword'],
            'docx' => ['application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
            'xls' => ['application/vnd.ms-excel'],
            'xlsx' => ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
            'zip' => ['application/zip', 'application/x-zip-compressed'],
            'txt' => ['text/plain'],
        ];
        
        if (!isset($allowedMimes[$extension])) {
            return ['valid' => false, 'message' => 'Extension not in allowed list'];
        }
        
        if (!in_array($mimeType, $allowedMimes[$extension])) {
            return ['valid' => false, 'message' => "MIME type {$mimeType} doesn't match extension {$extension}"];
        }
        
        return ['valid' => true, 'message' => 'MIME type valid'];
    }
    
    /**
     * Scan file content for suspicious patterns
     */
    private function scanFileContent($filePath, $extension)
    {
        $threats = [];
        
        // Only scan text-based files
        $textExtensions = ['txt', 'php', 'html', 'htm', 'js', 'css', 'xml', 'json'];
        if (!in_array($extension, $textExtensions)) {
            return $threats;
        }
        
        $content = file_get_contents($filePath);
        
        // Check for suspicious patterns
        foreach ($this->suspiciousPatterns as $pattern) {
            if (preg_match($pattern, $content)) {
                $threats[] = "suspicious_pattern:" . substr($pattern, 0, 30);
            }
        }
        
        // Check for null bytes (can indicate binary injection)
        if (strpos($content, "\0") !== false) {
            $threats[] = 'null_byte_detected';
        }
        
        // Check for embedded PHP tags in non-PHP files
        if ($extension !== 'php' && preg_match('/<\?php/i', $content)) {
            $threats[] = 'embedded_php_code';
        }
        
        return $threats;
    }
    
    /**
     * Log scan result for audit purposes
     */
    private function logScanResult($filePath, $safe, $threats)
    {
        $logMessage = sprintf(
            "[VirusScan] File: %s | Safe: %s | Threats: %s",
            basename($filePath),
            $safe ? 'YES' : 'NO',
            empty($threats) ? 'none' : implode(', ', $threats)
        );
        
        error_log($logMessage);
        
        // If there's a global audit log function, use it
        if (function_exists('logAuditEvent')) {
            logAuditEvent('virus_scan', null, 'scan', [
                'file' => basename($filePath),
                'safe' => $safe,
                'threats' => $threats
            ]);
        }
    }
    
    /**
     * Quick validation for uploaded files (to be called during upload)
     */
    public function validateUpload($file)
    {
        if (!isset($file['tmp_name']) || !is_uploaded_file($file['tmp_name'])) {
            return ['valid' => false, 'message' => 'Invalid file upload'];
        }
        
        // Check file size (100MB max)
        if ($file['size'] > 100 * 1024 * 1024) {
            return ['valid' => false, 'message' => 'File too large (max 100MB)'];
        }
        
        // Scan the uploaded file
        $scanResult = $this->scanFile($file['tmp_name']);
        
        if (!$scanResult['safe']) {
            return [
                'valid' => false,
                'message' => 'File failed security scan: ' . $scanResult['message'],
                'threats' => $scanResult['threats']
            ];
        }
        
        return ['valid' => true, 'message' => 'File passed security validation'];
    }
}
