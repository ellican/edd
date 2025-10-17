<?php
/**
 * Media Library Management
 * Admin Module - File and Asset Management
 */

require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../../includes/functions.php';
require_once __DIR__ . '/../../includes/services/VirusScanService.php';

// Check admin authentication - simplified
if (!Session::isLoggedIn()) {
    header('Location: /login.php');
    exit;
}

$pageTitle = 'Media Library - Admin';
$currentModule = 'media';
$virusScanner = new VirusScanService();

// Handle file upload
$uploadMessage = '';
$uploadError = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    if ($_POST['action'] === 'upload' && isset($_FILES['media_file'])) {
        $uploadDir = __DIR__ . '/../../uploads/media/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }
        
        $file = $_FILES['media_file'];
        $allowedTypes = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'heif', 'svg', 'mp4', 'avi', 'mov', 'pdf', 'doc', 'docx'];
        $fileExt = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        
        if (in_array($fileExt, $allowedTypes) && $file['size'] <= 10 * 1024 * 1024) {
            // Scan file for viruses
            $scanResult = $virusScanner->scanFile($file['tmp_name']);
            
            if (!$scanResult['safe']) {
                $uploadError = 'File failed security scan: ' . $scanResult['message'];
            } else {
                $fileName = time() . '_' . preg_replace('/[^a-zA-Z0-9._-]/', '', $file['name']);
                $filePath = $uploadDir . $fileName;
                
                if (move_uploaded_file($file['tmp_name'], $filePath)) {
                    // Save to database
                    try {
                        $db = Database::getInstance()->getConnection();
                        $stmt = $db->prepare("INSERT INTO cms_media (filename, original_name, file_path, file_size, mime_type, uploaded_by, created_at) VALUES (?, ?, ?, ?, ?, ?, datetime('now'))");
                        $stmt->execute([
                            $fileName,
                            $file['name'],
                            'uploads/media/' . $fileName,
                            $file['size'],
                            $file['type'],
                            Session::getUserId()
                        ]);
                        $uploadMessage = 'File uploaded successfully!';
                    } catch (Exception $e) {
                        error_log("Media upload error: " . $e->getMessage());
                        $uploadError = 'File uploaded but failed to save to database: ' . $e->getMessage();
                    }
                } else {
                    $uploadError = 'Failed to upload file.';
                }
            }
        } else {
            $uploadError = 'Invalid file type or size too large (max 10MB).';
        }
    }
}

// Get media files with filtering and pagination
$db = Database::getInstance()->getConnection();

// Get filter parameters
$filter_type = $_GET['type'] ?? 'all';
$search_query = $_GET['search'] ?? '';
$page = max(1, intval($_GET['page'] ?? 1));
$per_page = 24;
$offset = ($page - 1) * $per_page;

// Build WHERE clause
$where_clauses = [];
$params = [];

if ($filter_type !== 'all') {
    $where_clauses[] = "mime_type LIKE ?";
    $params[] = $filter_type . '%';
}

if (!empty($search_query)) {
    $where_clauses[] = "(original_name LIKE ? OR filename LIKE ?)";
    $params[] = '%' . $search_query . '%';
    $params[] = '%' . $search_query . '%';
}

$where_sql = !empty($where_clauses) ? 'WHERE ' . implode(' AND ', $where_clauses) : '';

// Get total count
try {
    $count_stmt = $db->prepare("SELECT COUNT(*) FROM cms_media $where_sql");
    $count_stmt->execute($params);
    $total_media = $count_stmt->fetchColumn();
} catch (Exception $e) {
    error_log("Error counting media: " . $e->getMessage());
    $total_media = 0;
}

$total_pages = ceil($total_media / $per_page);

// Get media files
$mediaFiles = [];
try {
    $params[] = $per_page;
    $params[] = $offset;
    $stmt = $db->prepare("SELECT * FROM cms_media $where_sql ORDER BY created_at DESC LIMIT ? OFFSET ?");
    $stmt->execute($params);
    $mediaFiles = $stmt->fetchAll();
} catch (Exception $e) {
    error_log("Error fetching media: " . $e->getMessage());
    $mediaFiles = [];
}

// Also fetch product images from products table
$productImages = [];
try {
    $stmt = $db->query("
        SELECT DISTINCT 
            image_url as file_path,
            name as original_name,
            'image/jpeg' as mime_type,
            0 as file_size,
            created_at
        FROM products 
        WHERE image_url IS NOT NULL AND image_url != ''
        ORDER BY created_at DESC
        LIMIT 100
    ");
    $productImages = $stmt->fetchAll();
} catch (Exception $e) {
    error_log("Error fetching product images: " . $e->getMessage());
    $productImages = [];
}

// Get media type counts for filter badges
$type_counts = [
    'image' => 0,
    'video' => 0,
    'application' => 0,
];
try {
    $type_counts['image'] = $db->query("SELECT COUNT(*) FROM cms_media WHERE mime_type LIKE 'image%'")->fetchColumn();
    $type_counts['video'] = $db->query("SELECT COUNT(*) FROM cms_media WHERE mime_type LIKE 'video%'")->fetchColumn();
    $type_counts['application'] = $db->query("SELECT COUNT(*) FROM cms_media WHERE mime_type LIKE 'application%'")->fetchColumn();
} catch (Exception $e) {
    error_log("Error getting type counts: " . $e->getMessage());
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($pageTitle); ?></title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f8fafc; }
        
        .admin-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .admin-header h1 { font-size: 2rem; margin-bottom: 0.5rem; }
        .admin-header p { opacity: 0.9; }
        
        .container { max-width: 1200px; margin: 2rem auto; padding: 0 2rem; }
        
        .upload-section {
            background: white;
            border-radius: 12px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .upload-form {
            display: flex;
            gap: 1rem;
            align-items: end;
            flex-wrap: wrap;
        }
        
        .form-group {
            flex: 1;
            min-width: 200px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #374151;
        }
        
        .form-group input[type="file"] {
            width: 100%;
            padding: 0.75rem;
            border: 2px dashed #d1d5db;
            border-radius: 8px;
            background: #f9fafb;
        }
        
        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }
        
        .message {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
        }
        
        .message.success {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }
        
        .message.error {
            background: #fee2e2;
            color: #dc2626;
            border: 1px solid #fecaca;
        }
        
        .media-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
        }
        
        .media-item {
            background: white;
            border-radius: 12px;
            padding: 1rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        
        .media-item:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        
        .media-preview {
            width: 100%;
            height: 150px;
            border-radius: 8px;
            object-fit: cover;
            background: #f3f4f6;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1rem;
        }
        
        .media-info h4 {
            font-size: 0.9rem;
            color: #374151;
            margin-bottom: 0.5rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .media-meta {
            font-size: 0.8rem;
            color: #6b7280;
        }
        
        .file-icon {
            font-size: 3rem;
            color: #9ca3af;
        }
        
        .back-link {
            color: white;
            text-decoration: none;
            opacity: 0.9;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            margin-top: 1rem;
        }
        
        .back-link:hover { opacity: 1; }
        
        .form-control {
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            background: white;
            width: 100%;
        }
        
        /* Responsive Media Grid */
        @media (max-width: 768px) {
            .media-grid {
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
                gap: 1rem;
            }
            
            .upload-form {
                flex-direction: column;
            }
            
            .form-group {
                width: 100%;
            }
            
            .admin-header {
                padding: 1.5rem;
            }
            
            .container {
                padding: 0 1rem;
            }
            
            .upload-section {
                padding: 1.5rem;
            }
        }
        
        @media (max-width: 480px) {
            .media-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 0.75rem;
            }
            
            .media-preview {
                height: 120px;
            }
            
            .admin-header h1 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="admin-header">
        <h1>Media Library Management</h1>
        <p>Upload, organize, and manage media assets for your e-commerce platform</p>
        <a href="/admin/" class="back-link">← Back to Admin Dashboard</a>
    </div>
    
    <div class="container">
        <?php if ($uploadMessage): ?>
            <div class="message success"><?php echo htmlspecialchars($uploadMessage); ?></div>
        <?php endif; ?>
        
        <?php if ($uploadError): ?>
            <div class="message error"><?php echo htmlspecialchars($uploadError); ?></div>
        <?php endif; ?>
        
        <!-- Filter and Search Section -->
        <div class="upload-section">
            <form method="GET" class="upload-form">
                <div class="form-group">
                    <label>Filter by Type</label>
                    <select name="type" class="form-control" onchange="this.form.submit()">
                        <option value="all" <?php echo $filter_type === 'all' ? 'selected' : ''; ?>>All Media (<?php echo $total_media; ?>)</option>
                        <option value="image" <?php echo $filter_type === 'image' ? 'selected' : ''; ?>>Images (<?php echo $type_counts['image']; ?>)</option>
                        <option value="video" <?php echo $filter_type === 'video' ? 'selected' : ''; ?>>Videos (<?php echo $type_counts['video']; ?>)</option>
                        <option value="application" <?php echo $filter_type === 'application' ? 'selected' : ''; ?>>Documents (<?php echo $type_counts['application']; ?>)</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Search Media</label>
                    <input type="text" name="search" class="form-control" placeholder="Search by filename..." 
                           value="<?php echo htmlspecialchars($search_query); ?>">
                </div>
                
                <button type="submit" class="btn btn-primary">Search</button>
                <?php if (!empty($search_query) || $filter_type !== 'all'): ?>
                    <a href="?" class="btn" style="background: #6b7280; color: white;">Clear Filters</a>
                <?php endif; ?>
            </form>
        </div>
        
        <!-- Upload Section -->
        <div class="upload-section">
            <h2 style="margin-bottom: 1.5rem; color: #374151;">Upload New Media</h2>
            <form method="POST" enctype="multipart/form-data" class="upload-form">
                <input type="hidden" name="action" value="upload">
                <div class="form-group">
                    <label for="media_file">Choose File</label>
                    <input type="file" id="media_file" name="media_file" required 
                           accept=".jpg,.jpeg,.png,.gif,.bmp,.webp,.heic,.heif,.svg,.mp4,.avi,.mov,.pdf,.doc,.docx">
                    <small style="color: #6b7280; margin-top: 0.5rem; display: block;">
                        Supported: Images, Videos, Documents (Max: 10MB)
                    </small>
                </div>
                <button type="submit" class="btn btn-primary">Upload File</button>
            </form>
        </div>
        
        <div class="media-section">
            <h2 style="color: #374151; margin-bottom: 1rem;">Media Library (<?php echo count($mediaFiles); ?> files)</h2>
            
            <?php if (empty($mediaFiles) && empty($productImages)): ?>
                <div style="text-align: center; padding: 3rem; color: #6b7280;">
                    <div style="font-size: 4rem; margin-bottom: 1rem;">📁</div>
                    <h3>No Media Files</h3>
                    <p>Upload your first media file to get started.</p>
                </div>
            <?php else: ?>
                <div class="media-grid">
                    <?php foreach ($mediaFiles as $file): ?>
                        <div class="media-item">
                            <div class="media-preview">
                                <?php 
                                $isImage = in_array(strtolower(pathinfo($file['filename'], PATHINFO_EXTENSION)), ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']);
                                if ($isImage): 
                                ?>
                                    <img src="/<?php echo htmlspecialchars($file['file_path']); ?>" 
                                         alt="<?php echo htmlspecialchars($file['original_name']); ?>"
                                         loading="lazy"
                                         onerror="this.style.display='none'; this.parentElement.innerHTML='<div class=\'file-icon\'>📄</div>';"
                                         style="width: 100%; height: 100%; object-fit: cover; border-radius: 8px;">
                                <?php else: ?>
                                    <div class="file-icon">📄</div>
                                <?php endif; ?>
                            </div>
                            <div class="media-info">
                                <h4 title="<?php echo htmlspecialchars($file['original_name']); ?>">
                                    <?php echo htmlspecialchars($file['original_name']); ?>
                                </h4>
                                <div class="media-meta">
                                    <div>Size: <?php echo number_format($file['file_size'] / 1024, 1); ?> KB</div>
                                    <div>Type: <?php echo htmlspecialchars($file['mime_type']); ?></div>
                                    <div>Uploaded: <?php echo date('M j, Y', strtotime($file['created_at'])); ?></div>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                    
                    <?php foreach ($productImages as $img): ?>
                        <div class="media-item" style="border: 2px solid #3b82f6;">
                            <div class="media-preview">
                                <img src="/<?php echo htmlspecialchars($img['file_path']); ?>" 
                                     alt="<?php echo htmlspecialchars($img['original_name']); ?>"
                                     loading="lazy"
                                     onerror="this.style.display='none'; this.parentElement.innerHTML='<div class=\'file-icon\'>🖼️</div>';"
                                     style="width: 100%; height: 100%; object-fit: cover; border-radius: 8px;">
                            </div>
                            <div class="media-info">
                                <h4 title="<?php echo htmlspecialchars($img['original_name']); ?>">
                                    <?php echo htmlspecialchars(substr($img['original_name'], 0, 30)); ?>
                                </h4>
                                <div class="media-meta">
                                    <div><span style="color: #3b82f6; font-weight: bold;">📦 Product Image</span></div>
                                    <div>From: Products Database</div>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
                
                <!-- Pagination -->
                <?php if ($total_pages > 1): ?>
                    <div style="margin-top: 2rem; text-align: center;">
                        <div style="display: inline-flex; gap: 0.5rem; background: white; padding: 1rem; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                            <?php if ($page > 1): ?>
                                <a href="?page=<?php echo $page - 1; ?>&type=<?php echo $filter_type; ?>&search=<?php echo urlencode($search_query); ?>" 
                                   class="btn" style="background: #6b7280; color: white;">← Previous</a>
                            <?php endif; ?>
                            
                            <span style="padding: 0.75rem 1.5rem; color: #374151;">
                                Page <?php echo $page; ?> of <?php echo $total_pages; ?>
                            </span>
                            
                            <?php if ($page < $total_pages): ?>
                                <a href="?page=<?php echo $page + 1; ?>&type=<?php echo $filter_type; ?>&search=<?php echo urlencode($search_query); ?>" 
                                   class="btn" style="background: #6b7280; color: white;">Next →</a>
                            <?php endif; ?>
                        </div>
                    </div>
                <?php endif; ?>
            <?php endif; ?>
        </div>
    </div>
</body>
</html>