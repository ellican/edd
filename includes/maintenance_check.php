<?php
/**
 * Maintenance Mode Middleware
 * Checks if the site is in maintenance mode and blocks access for non-admin users
 */

// Only run maintenance check if we're not already in the admin area
$current_uri = $_SERVER['REQUEST_URI'] ?? '';
$is_admin_area = (
    strpos($current_uri, '/admin/') !== false ||
    strpos($current_uri, '/phpmyadmin/') !== false
);

// Don't check maintenance mode for admin pages, health checks, or API health endpoints
if (!$is_admin_area && 
    strpos($current_uri, '/healthz.php') === false && 
    strpos($current_uri, '/readyz.php') === false) {
    
    try {
        // Check if maintenance mode is enabled
        $pdo = db();
        $stmt = $pdo->prepare("
            SELECT setting_value 
            FROM system_settings 
            WHERE setting_key = 'maintenance_mode'
        ");
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($result && $result['setting_value'] == '1') {
            // Site is in maintenance mode
            $user_role = $_SESSION['user_role'] ?? null;
            
            // Allow admin users to access the site during maintenance
            if ($user_role !== 'admin') {
                // Get maintenance message
                $stmt = $pdo->prepare("
                    SELECT setting_value 
                    FROM system_settings 
                    WHERE setting_key = 'maintenance_message'
                ");
                $stmt->execute();
                $message_result = $stmt->fetch(PDO::FETCH_ASSOC);
                $maintenance_message = $message_result['setting_value'] ?? 'Site temporarily unavailable for maintenance. Please check back soon.';
                
                // Display maintenance page
                http_response_code(503);
                header('Retry-After: 3600'); // Retry after 1 hour
                ?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Site Maintenance</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .maintenance-container {
            background: white;
            border-radius: 20px;
            padding: 3rem;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 600px;
            text-align: center;
        }
        .maintenance-icon {
            font-size: 5rem;
            color: #667eea;
            margin-bottom: 1.5rem;
        }
        .maintenance-title {
            font-size: 2rem;
            font-weight: bold;
            color: #333;
            margin-bottom: 1rem;
        }
        .maintenance-message {
            color: #666;
            font-size: 1.1rem;
            line-height: 1.6;
            margin-bottom: 2rem;
        }
        .btn-return {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            color: white;
            padding: 12px 30px;
            border-radius: 25px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: transform 0.3s ease;
        }
        .btn-return:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
            color: white;
        }
    </style>
</head>
<body>
    <div class="maintenance-container">
        <i class="fas fa-tools maintenance-icon"></i>
        <h1 class="maintenance-title">We'll Be Back Soon!</h1>
        <p class="maintenance-message">
            <?php echo htmlspecialchars($maintenance_message); ?>
        </p>
        <p class="text-muted">
            <small>We apologize for any inconvenience. Thank you for your patience.</small>
        </p>
        <a href="/" class="btn-return">
            <i class="fas fa-home me-2"></i>
            Return to Homepage
        </a>
    </div>
</body>
</html>
                <?php
                exit;
            }
        }
    } catch (Exception $e) {
        // If there's a database error, don't block access
        // Log the error but allow the site to continue functioning
        if (function_exists('Logger')) {
            Logger::error("Maintenance mode check failed: " . $e->getMessage());
        }
    }
}
