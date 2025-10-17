<?php
/**
 * Robust Email Service with PHPMailer
 * Ensures reliable email delivery with proper SMTP, validation, and retry logic
 */

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception as PHPMailerException;

class RobustEmailService {
    private $mailer;
    private $db;
    private $config;
    private $logger;
    
    public function __construct() {
        $this->config = [
            'smtp_host' => SMTP_HOST,
            'smtp_port' => SMTP_PORT,
            'smtp_username' => SMTP_USERNAME,
            'smtp_password' => SMTP_PASSWORD,
            'smtp_encryption' => SMTP_ENCRYPTION ?? 'tls',
            'from_email' => FROM_EMAIL,
            'from_name' => FROM_NAME,
            'support_email' => SUPPORT_EMAIL ?? FROM_EMAIL,
        ];
        
        try {
            $this->db = db();
        } catch (Exception $e) {
            error_log("Email service database connection failed: " . $e->getMessage());
        }
        
        $this->initializeMailer();
    }
    
    /**
     * Initialize PHPMailer with SMTP configuration
     */
    private function initializeMailer() {
        $this->mailer = new PHPMailer(true);
        
        try {
            // Determine mail transport method
            $mailMethod = defined('MAIL_METHOD') ? MAIL_METHOD : 'smtp';
            
            if ($mailMethod === 'mail') {
                // Use PHP's mail() function (requires local MTA like Postfix)
                $this->mailer->isMail();
            } elseif ($mailMethod === 'sendmail') {
                // Use sendmail binary
                $this->mailer->isSendmail();
                if (defined('SENDMAIL_PATH')) {
                    $this->mailer->Sendmail = SENDMAIL_PATH;
                }
            } else {
                // Use SMTP (default)
                $this->mailer->isSMTP();
                $this->mailer->Host = $this->config['smtp_host'];
                
                // Only use authentication if credentials are provided
                // For direct sending from local server, authentication may not be needed
                if (!empty($this->config['smtp_username']) && !empty($this->config['smtp_password'])) {
                    $this->mailer->SMTPAuth = true;
                    $this->mailer->Username = $this->config['smtp_username'];
                    $this->mailer->Password = $this->config['smtp_password'];
                } else {
                    $this->mailer->SMTPAuth = false;
                }
                
                // Set encryption and port
                if (!empty($this->config['smtp_encryption']) && $this->config['smtp_encryption'] !== 'none') {
                    $this->mailer->SMTPSecure = $this->config['smtp_encryption'];
                }
                $this->mailer->Port = $this->config['smtp_port'];
                
                // For direct sending, allow self-signed certificates
                if ($this->config['smtp_host'] === 'localhost' || $this->config['smtp_host'] === '127.0.0.1') {
                    $this->mailer->SMTPOptions = [
                        'ssl' => [
                            'verify_peer' => false,
                            'verify_peer_name' => false,
                            'allow_self_signed' => true
                        ]
                    ];
                }
            }
            
            // Disable debug output by default (can be enabled in dev mode)
            $this->mailer->SMTPDebug = defined('APP_DEBUG') && APP_DEBUG ? SMTP::DEBUG_SERVER : SMTP::DEBUG_OFF;
            
            // Set default from address
            $this->mailer->setFrom($this->config['from_email'], $this->config['from_name']);
            
            // Enable HTML by default
            $this->mailer->isHTML(true);
            
            // Set charset
            $this->mailer->CharSet = 'UTF-8';
            
            // Set timeout
            $this->mailer->Timeout = 30;
            
            // Enable DKIM if configured
            if (defined('DKIM_DOMAIN') && defined('DKIM_PRIVATE_KEY') && defined('DKIM_SELECTOR')) {
                $this->mailer->DKIM_domain = DKIM_DOMAIN;
                $this->mailer->DKIM_private = DKIM_PRIVATE_KEY;
                $this->mailer->DKIM_selector = DKIM_SELECTOR;
                $this->mailer->DKIM_passphrase = defined('DKIM_PASSPHRASE') ? DKIM_PASSPHRASE : '';
            }
            
        } catch (PHPMailerException $e) {
            error_log("PHPMailer initialization failed: " . $e->getMessage());
        }
    }
    
    /**
     * Send email with validation and error handling
     */
    public function sendEmail($to, $subject, $body, $options = []) {
        try {
            // Validate email address
            if (!$this->validateEmail($to)) {
                throw new Exception("Invalid email address: $to");
            }
            
            // Clear any previous recipients
            $this->mailer->clearAddresses();
            $this->mailer->clearAttachments();
            $this->mailer->clearCustomHeaders();
            
            // Set recipient
            $toName = $options['to_name'] ?? '';
            $this->mailer->addAddress($to, $toName);
            
            // Set subject and body
            $this->mailer->Subject = $subject;
            $this->mailer->Body = $body;
            
            // Set plain text alternative if provided
            if (isset($options['alt_body'])) {
                $this->mailer->AltBody = $options['alt_body'];
            } else {
                // Generate plain text from HTML
                $this->mailer->AltBody = strip_tags($body);
            }
            
            // Add CC if provided
            if (isset($options['cc'])) {
                if (is_array($options['cc'])) {
                    foreach ($options['cc'] as $ccEmail) {
                        if ($this->validateEmail($ccEmail)) {
                            $this->mailer->addCC($ccEmail);
                        }
                    }
                } else if ($this->validateEmail($options['cc'])) {
                    $this->mailer->addCC($options['cc']);
                }
            }
            
            // Add BCC if provided
            if (isset($options['bcc'])) {
                if (is_array($options['bcc'])) {
                    foreach ($options['bcc'] as $bccEmail) {
                        if ($this->validateEmail($bccEmail)) {
                            $this->mailer->addBCC($bccEmail);
                        }
                    }
                } else if ($this->validateEmail($options['bcc'])) {
                    $this->mailer->addBCC($options['bcc']);
                }
            }
            
            // Add Reply-To if provided
            if (isset($options['reply_to'])) {
                $replyName = $options['reply_to_name'] ?? '';
                if ($this->validateEmail($options['reply_to'])) {
                    $this->mailer->addReplyTo($options['reply_to'], $replyName);
                }
            }
            
            // Add attachments if provided
            if (isset($options['attachments']) && is_array($options['attachments'])) {
                foreach ($options['attachments'] as $attachment) {
                    if (is_array($attachment)) {
                        $this->mailer->addAttachment(
                            $attachment['path'],
                            $attachment['name'] ?? '',
                            $attachment['encoding'] ?? PHPMailer::ENCODING_BASE64,
                            $attachment['type'] ?? ''
                        );
                    } else if (file_exists($attachment)) {
                        $this->mailer->addAttachment($attachment);
                    }
                }
            }
            
            // Set priority if provided
            if (isset($options['priority'])) {
                $this->mailer->Priority = $options['priority'];
            }
            
            // Add custom headers if provided
            if (isset($options['headers']) && is_array($options['headers'])) {
                foreach ($options['headers'] as $name => $value) {
                    $this->mailer->addCustomHeader($name, $value);
                }
            }
            
            // Send the email
            $success = $this->mailer->send();
            
            // Log the attempt
            $this->logEmailAttempt($to, $subject, $success ? 'sent' : 'failed', null, $options['user_id'] ?? null);
            
            return $success;
            
        } catch (PHPMailerException $e) {
            $errorMsg = $e->getMessage();
            error_log("Email sending failed: $errorMsg");
            $this->logEmailAttempt($to, $subject, 'failed', $errorMsg, $options['user_id'] ?? null);
            return false;
        } catch (Exception $e) {
            $errorMsg = $e->getMessage();
            error_log("Email sending error: $errorMsg");
            $this->logEmailAttempt($to, $subject, 'error', $errorMsg, $options['user_id'] ?? null);
            return false;
        }
    }
    
    /**
     * Queue email for later delivery
     */
    public function queueEmail($to, $subject, $body, $options = []) {
        try {
            $stmt = $this->db->prepare("
                INSERT INTO email_queue 
                (to_email, to_name, subject, body, template, template_data, priority, status, scheduled_at, metadata, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?, NOW())
            ");
            
            $templateData = isset($options['template_data']) ? json_encode($options['template_data']) : null;
            $metadata = isset($options['metadata']) ? json_encode($options['metadata']) : null;
            $priority = $options['priority'] ?? 3;
            $scheduledAt = $options['scheduled_at'] ?? null;
            
            return $stmt->execute([
                $to,
                $options['to_name'] ?? null,
                $subject,
                $body,
                $options['template'] ?? null,
                $templateData,
                $priority,
                $scheduledAt,
                $metadata
            ]);
            
        } catch (Exception $e) {
            error_log("Failed to queue email: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Process queued emails
     */
    public function processQueue($limit = 50) {
        try {
            // Get pending emails
            $stmt = $this->db->prepare("
                SELECT * FROM email_queue
                WHERE status = 'pending'
                  AND attempts < max_attempts
                  AND (scheduled_at IS NULL OR scheduled_at <= NOW())
                ORDER BY priority ASC, created_at ASC
                LIMIT ?
            ");
            $stmt->execute([$limit]);
            $emails = $stmt->fetchAll();
            
            $processed = 0;
            $sent = 0;
            $failed = 0;
            
            foreach ($emails as $email) {
                $processed++;
                
                // Update status to sending
                $this->updateQueueStatus($email['id'], 'sending');
                
                // Prepare email options
                $options = [];
                if ($email['to_name']) {
                    $options['to_name'] = $email['to_name'];
                }
                
                if ($email['metadata']) {
                    $metadata = json_decode($email['metadata'], true);
                    if (is_array($metadata)) {
                        $options = array_merge($options, $metadata);
                    }
                }
                
                // Send email
                $success = $this->sendEmail($email['to_email'], $email['subject'], $email['body'], $options);
                
                if ($success) {
                    $sent++;
                    $this->updateQueueStatus($email['id'], 'sent', null, date('Y-m-d H:i:s'));
                } else {
                    $failed++;
                    $newAttempts = $email['attempts'] + 1;
                    $status = $newAttempts >= $email['max_attempts'] ? 'failed' : 'pending';
                    $this->updateQueueStatus($email['id'], $status, $this->mailer->ErrorInfo, null, $newAttempts);
                }
            }
            
            error_log("Email queue processed: $processed emails ($sent sent, $failed failed)");
            return $processed;
            
        } catch (Exception $e) {
            error_log("Queue processing error: " . $e->getMessage());
            return 0;
        }
    }
    
    /**
     * Update queue email status
     */
    private function updateQueueStatus($id, $status, $errorMessage = null, $sentAt = null, $attempts = null) {
        try {
            $updates = ["status = ?"];
            $params = [$status];
            
            if ($errorMessage !== null) {
                $updates[] = "error_message = ?";
                $params[] = $errorMessage;
            }
            
            if ($sentAt !== null) {
                $updates[] = "sent_at = ?";
                $params[] = $sentAt;
            }
            
            if ($attempts !== null) {
                $updates[] = "attempts = ?";
                $params[] = $attempts;
            }
            
            $updates[] = "updated_at = NOW()";
            $params[] = $id;
            
            $sql = "UPDATE email_queue SET " . implode(', ', $updates) . " WHERE id = ?";
            $stmt = $this->db->prepare($sql);
            return $stmt->execute($params);
            
        } catch (Exception $e) {
            error_log("Failed to update queue status: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Validate email address
     */
    private function validateEmail($email) {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }
    
    /**
     * Log email attempt to database
     */
    private function logEmailAttempt($to, $subject, $status, $errorMessage = null, $userId = null) {
        try {
            if (!$this->db) return;
            
            $stmt = $this->db->prepare("
                INSERT INTO email_logs (user_id, to_email, subject, status, error_message, sent_at)
                VALUES (?, ?, ?, ?, ?, NOW())
            ");
            
            $stmt->execute([
                $userId,
                $to,
                $subject,
                $status,
                $errorMessage
            ]);
            
        } catch (Exception $e) {
            error_log("Failed to log email attempt: " . $e->getMessage());
        }
    }
    
    /**
     * Test SMTP connection
     */
    public function testConnection() {
        try {
            return $this->mailer->smtpConnect();
        } catch (PHPMailerException $e) {
            error_log("SMTP connection test failed: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Get last error message
     */
    public function getLastError() {
        return $this->mailer->ErrorInfo;
    }
}
