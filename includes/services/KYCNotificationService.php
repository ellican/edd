<?php
/**
 * KYC Notification Service
 * Handles sending notifications for KYC status changes and reminders
 */

class KYCNotificationService {
    private $db;
    
    public function __construct() {
        $this->db = db();
    }
    
    /**
     * Send approval notification
     */
    public function sendApprovalNotification($kycRecordId) {
        try {
            $record = $this->getKYCRecord($kycRecordId);
            if (!$record) {
                return false;
            }
            
            $user = $this->getUser($record['user_id']);
            if (!$user || empty($user['email'])) {
                return false;
            }
            
            $subject = "KYC Verification Approved";
            $message = "
                <h2>Your KYC Verification Has Been Approved</h2>
                <p>Dear {$user['first_name']},</p>
                <p>We're pleased to inform you that your KYC verification has been successfully approved.</p>
                <p><strong>Details:</strong></p>
                <ul>
                    <li>Verification ID: #{$kycRecordId}</li>
                    <li>Status: Approved</li>
                    <li>Approved On: " . date('F j, Y') . "</li>
                </ul>
                <p>You now have full access to all features of your account.</p>
                <p>Thank you for completing your verification!</p>
            ";
            
            // Send email
            $this->sendEmail($user['email'], $subject, $message);
            
            // Log notification
            $this->logNotification($kycRecordId, 'approval', 'email', $user['email'], $subject, $message, 'sent');
            
            return true;
        } catch (Exception $e) {
            error_log("KYC Approval Notification Error: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Send rejection notification
     */
    public function sendRejectionNotification($kycRecordId, $reason) {
        try {
            $record = $this->getKYCRecord($kycRecordId);
            if (!$record) {
                return false;
            }
            
            $user = $this->getUser($record['user_id']);
            if (!$user || empty($user['email'])) {
                return false;
            }
            
            $subject = "KYC Verification - Additional Information Required";
            $message = "
                <h2>KYC Verification Update</h2>
                <p>Dear {$user['first_name']},</p>
                <p>Thank you for submitting your KYC verification documents.</p>
                <p>After reviewing your submission, we need some additional information or clarification:</p>
                <blockquote style='background: #f5f5f5; padding: 15px; border-left: 4px solid #ff6b6b;'>
                    {$reason}
                </blockquote>
                <p><strong>Next Steps:</strong></p>
                <ul>
                    <li>Please review the feedback above</li>
                    <li>Update your documents or information as needed</li>
                    <li>Resubmit your KYC verification</li>
                </ul>
                <p>If you have any questions, please don't hesitate to contact our support team.</p>
            ";
            
            // Send email
            $this->sendEmail($user['email'], $subject, $message);
            
            // Log notification
            $this->logNotification($kycRecordId, 'rejection', 'email', $user['email'], $subject, $message, 'sent');
            
            return true;
        } catch (Exception $e) {
            error_log("KYC Rejection Notification Error: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Send expiry reminder
     */
    public function sendExpiryReminder($kycRecordId, $daysUntilExpiry) {
        try {
            $record = $this->getKYCRecord($kycRecordId);
            if (!$record) {
                return false;
            }
            
            $user = $this->getUser($record['user_id']);
            if (!$user || empty($user['email'])) {
                return false;
            }
            
            $expiryDate = date('F j, Y', strtotime($record['expiry_date']));
            
            $subject = "KYC Verification Expiring Soon - Action Required";
            $message = "
                <h2>KYC Verification Renewal Required</h2>
                <p>Dear {$user['first_name']},</p>
                <p>This is a reminder that your KYC verification will expire in <strong>{$daysUntilExpiry} days</strong>.</p>
                <p><strong>Details:</strong></p>
                <ul>
                    <li>Expiry Date: {$expiryDate}</li>
                    <li>Days Remaining: {$daysUntilExpiry}</li>
                </ul>
                <p>To avoid any interruption to your account access, please renew your KYC verification before the expiry date.</p>
                <p><a href='/account/kyc' style='background: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;'>Renew KYC Now</a></p>
            ";
            
            // Send email
            $this->sendEmail($user['email'], $subject, $message);
            
            // Log notification
            $this->logNotification($kycRecordId, 'expiry_reminder', 'email', $user['email'], $subject, $message, 'sent');
            
            return true;
        } catch (Exception $e) {
            error_log("KYC Expiry Reminder Error: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Send incomplete KYC reminder
     */
    public function sendIncompleteReminder($kycRecordId) {
        try {
            $record = $this->getKYCRecord($kycRecordId);
            if (!$record) {
                return false;
            }
            
            $user = $this->getUser($record['user_id']);
            if (!$user || empty($user['email'])) {
                return false;
            }
            
            $subject = "Complete Your KYC Verification";
            $message = "
                <h2>Complete Your KYC Verification</h2>
                <p>Dear {$user['first_name']},</p>
                <p>We noticed that your KYC verification is still incomplete.</p>
                <p>Completing your verification unlocks:</p>
                <ul>
                    <li>Full account access</li>
                    <li>Higher transaction limits</li>
                    <li>Priority customer support</li>
                    <li>Access to premium features</li>
                </ul>
                <p><a href='/account/kyc' style='background: #2196F3; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;'>Complete KYC Now</a></p>
            ";
            
            // Send email
            $this->sendEmail($user['email'], $subject, $message);
            
            // Log notification
            $this->logNotification($kycRecordId, 'incomplete', 'email', $user['email'], $subject, $message, 'sent');
            
            return true;
        } catch (Exception $e) {
            error_log("KYC Incomplete Reminder Error: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Get KYC record
     */
    private function getKYCRecord($id) {
        $stmt = $this->db->prepare("SELECT * FROM kyc_records WHERE id = ?");
        $stmt->execute([$id]);
        return $stmt->fetch();
    }
    
    /**
     * Get user information
     */
    private function getUser($userId) {
        $stmt = $this->db->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        return $stmt->fetch();
    }
    
    /**
     * Send email
     */
    private function sendEmail($to, $subject, $message) {
        // Use existing email system if available
        if (function_exists('sendHTMLEmail')) {
            return sendHTMLEmail($to, $subject, $message);
        }
        
        // Fallback to basic mail
        $headers = "MIME-Version: 1.0" . "\r\n";
        $headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";
        $headers .= "From: noreply@" . ($_SERVER['HTTP_HOST'] ?? 'example.com') . "\r\n";
        
        return mail($to, $subject, $message, $headers);
    }
    
    /**
     * Log notification in database
     */
    private function logNotification($kycRecordId, $type, $channel, $recipient, $subject, $message, $status) {
        try {
            $stmt = $this->db->prepare("
                INSERT INTO kyc_notifications 
                (kyc_record_id, notification_type, channel, recipient, subject, message, status, sent_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
            ");
            $stmt->execute([$kycRecordId, $type, $channel, $recipient, $subject, $message, $status]);
        } catch (Exception $e) {
            error_log("Failed to log KYC notification: " . $e->getMessage());
        }
    }
    
    /**
     * Process expiry reminders (cron job)
     */
    public static function processExpiryReminders() {
        try {
            $db = db();
            $service = new self();
            
            // Get records expiring in 30 days
            $stmt = $db->prepare("
                SELECT id FROM kyc_records 
                WHERE status = 'approved'
                AND expiry_date = DATE_ADD(CURDATE(), INTERVAL 30 DAY)
                AND id NOT IN (
                    SELECT kyc_record_id FROM kyc_notifications 
                    WHERE notification_type = 'expiry_reminder' 
                    AND DATE(sent_at) = CURDATE()
                )
            ");
            $stmt->execute();
            $records = $stmt->fetchAll();
            
            foreach ($records as $record) {
                $service->sendExpiryReminder($record['id'], 30);
            }
            
            // Get records expiring in 7 days
            $stmt = $db->prepare("
                SELECT id FROM kyc_records 
                WHERE status = 'approved'
                AND expiry_date = DATE_ADD(CURDATE(), INTERVAL 7 DAY)
                AND id NOT IN (
                    SELECT kyc_record_id FROM kyc_notifications 
                    WHERE notification_type = 'expiry_reminder' 
                    AND DATE(sent_at) = CURDATE()
                )
            ");
            $stmt->execute();
            $records = $stmt->fetchAll();
            
            foreach ($records as $record) {
                $service->sendExpiryReminder($record['id'], 7);
            }
            
        } catch (Exception $e) {
            error_log("KYC Expiry Reminders Process Error: " . $e->getMessage());
        }
    }
}
