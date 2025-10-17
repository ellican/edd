<?php
/**
 * Forgot Password Page
 * Live Shopping E-Commerce Platform
 */

require_once __DIR__ . '/includes/init.php';
require_once __DIR__ . '/includes/RobustEmailService.php';

// Redirect if already logged in
if (Session::isLoggedIn()) {
    redirect('/');
}

$error = '';
$success = '';
$email = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // CSRF protection
    $csrfToken = $_POST['csrf_token'] ?? '';
    if (!verifyCsrfToken($csrfToken)) {
        $error = 'Invalid request. Please try again.';
    } else {
        $email = sanitizeInput($_POST['email'] ?? '');
        
        if (empty($email)) {
            $error = 'Please enter your email address';
        } elseif (!validateEmail($email)) {
            $error = 'Please enter a valid email address';
        } else {
            $user = new User();
            $userData = $user->findByEmail($email);
            
            if ($userData) {
                // Generate password reset token (like reference)
                $token = bin2hex(random_bytes(32));
                
                // Store the token in email_tokens table
                $db = Database::getInstance()->getConnection();
                
                // Clear any existing password reset tokens for this user
                $deleteStmt = $db->prepare("
                    DELETE FROM email_tokens 
                    WHERE user_id = ? AND type = 'password_reset'
                ");
                $deleteStmt->execute([$userData['id']]);
                
                // Store new token with expiry calculated in database time (1 hour from NOW)
                $stmt = $db->prepare("
                    INSERT INTO email_tokens (user_id, token, type, email, expires_at, ip_address, created_at)
                    VALUES (?, ?, 'password_reset', ?, DATE_ADD(NOW(), INTERVAL 1 HOUR), ?, NOW())
                ");
                $tokenStored = $stmt->execute([
                    $userData['id'],
                    $token,
                    $userData['email'],
                    $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1'
                ]);
                
                if ($tokenStored) {
                    // Send the reset link email using RobustEmailService with professional template
                    $reset_link = APP_URL . "/reset-password.php?token=" . $token;
                    $subject = "Password Reset Request - " . FROM_NAME;
                    
                    // Load professional HTML email template
                    $templatePath = __DIR__ . '/includes/emails/reset_password_template.php';
                    ob_start();
                    include $templatePath;
                    $email_message = ob_get_clean();
                    
                    // Replace template placeholders
                    $replacements = [
                        '{{USERNAME}}' => htmlspecialchars($userData['first_name']),
                        '{{RESET_LINK}}' => htmlspecialchars($reset_link),
                        '{{APP_NAME}}' => htmlspecialchars(APP_NAME),
                        '{{APP_URL}}' => htmlspecialchars(APP_URL),
                        '{{IP_ADDRESS}}' => htmlspecialchars($_SERVER['REMOTE_ADDR'] ?? 'Unknown'),
                        '{{YEAR}}' => date('Y'),
                        '{{SUPPORT_EMAIL}}' => htmlspecialchars(SUPPORT_EMAIL ?? FROM_EMAIL)
                    ];
                    $email_message = str_replace(array_keys($replacements), array_values($replacements), $email_message);
                    
                    try {
                        $emailService = new RobustEmailService();
                        $emailSent = $emailService->sendEmail(
                            $userData['email'], 
                            $subject, 
                            $email_message,
                            [
                                'to_name' => $userData['first_name'] . ' ' . $userData['last_name'],
                                'user_id' => $userData['id']
                            ]
                        );
                        
                        if ($emailSent) {
                            Logger::info("Password reset email sent to: {$userData['email']}");
                        } else {
                            Logger::error("Failed to send password reset email to: {$userData['email']}");
                        }
                    } catch (Exception $e) {
                        Logger::error("Password reset email error: " . $e->getMessage());
                    }
                }
                
                logSecurityEvent($userData['id'], 'password_reset_requested', 'user', $userData['id']);
                
                // Always show generic success message (like reference)
                $success = "If an account with that email exists, we have sent a password reset link.";
            } else {
                // Always show generic success message to prevent user enumeration (like reference)
                logSecurityEvent(null, 'password_reset_unknown_email', 'user', null, ['email' => $email]);
                $success = "If an account with that email exists, we have sent a password reset link.";
            }
        }
    }
}

$page_title = 'Forgot Password';
includeHeader($page_title);
?>

<div class="container">
    <div class="row justify-center">
        <div class="col-6">
            <div class="card mt-4">
                <div class="card-body">
                    <h1 class="card-title text-center">Reset Your Password</h1>
                    <p class="text-center text-muted">Enter your email address and we'll send you a link to reset your password.</p>
                    
                    <?php if ($error): ?>
                        <div class="alert alert-error"><?php echo $error; ?></div>
                    <?php endif; ?>
                    
                    <?php if ($success): ?>
                        <div class="alert alert-success"><?php echo $success; ?></div>
                    <?php else: ?>
                    
                    <form method="POST" class="validate-form">
                        <input type="hidden" name="csrf_token" value="<?php echo csrfToken(); ?>">
                        
                        <div class="form-group">
                            <label for="email" class="form-label">Email Address</label>
                            <input type="email" id="email" name="email" class="form-control" required
                                   value="<?php echo htmlspecialchars($email); ?>"
                                   placeholder="Enter your email address">
                        </div>
                        
                        <button type="submit" class="btn btn-lg" style="width: 100%; margin-bottom: 1rem;">
                            Send Reset Link
                        </button>
                    </form>
                    
                    <?php endif; ?>
                    
                    <div class="text-center">
                        <p><a href="/login.php">← Back to Login</a></p>
                        <p>Don't have an account? <a href="/register.php">Register here</a></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<?php includeFooter(); ?>