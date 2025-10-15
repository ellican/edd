<?php
/**
 * Enhanced Notification Service
 * Comprehensive notification system with template support, user preferences, and multi-channel delivery
 * E-Commerce Platform - PHP 8
 */

class EnhancedNotificationService {
    private $db;
    
    public function __construct() {
        $this->db = db();
    }
    
    /**
     * Send a notification using template
     * 
     * @param string $type Template type identifier
     * @param int $userId User ID to send to
     * @param array $variables Variables to replace in template
     * @param array $options Additional options (force_email, force_sms, etc.)
     * @return bool Success status
     */
    public function send($type, $userId, $variables = [], $options = []) {
        try {
            // Get template
            $template = $this->getTemplate($type);
            if (!$template || !$template['enabled']) {
                error_log("Notification template not found or disabled: {$type}");
                return false;
            }
            
            // Get user info
            $user = $this->getUser($userId);
            if (!$user) {
                error_log("User not found: {$userId}");
                return false;
            }
            
            // Get user preferences
            $preferences = $this->getUserPreferences($userId, $template['category']);
            
            // Add default variables
            $variables = array_merge($this->getDefaultVariables($user), $variables);
            
            // Replace variables in template
            $subject = $this->replaceVariables($template['subject'], $variables);
            $body = $this->replaceVariables($template['body_template'], $variables);
            
            $success = true;
            
            // Send in-app notification
            if (($template['send_in_app'] && $preferences['in_app_enabled']) || 
                ($options['force_in_app'] ?? false)) {
                $success = $this->sendInApp($userId, $type, $subject, $body, $variables, $template['category']) && $success;
            }
            
            // Send email
            if (($template['send_email'] && $preferences['email_enabled']) || 
                ($options['force_email'] ?? false)) {
                $success = $this->sendEmail($user['email'], $user['username'], $subject, $body, $type, $template['category']) && $success;
            }
            
            // Send SMS (if enabled and configured)
            if (($template['send_sms'] && $preferences['sms_enabled']) || 
                ($options['force_sms'] ?? false)) {
                if (!empty($user['phone'])) {
                    $success = $this->sendSMS($user['phone'], $body, $userId, $type, $template['category']) && $success;
                }
            }
            
            return $success;
            
        } catch (Exception $e) {
            error_log("Notification send error: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Send notification to multiple users
     */
    public function sendBulk($type, $userIds, $variables = [], $options = []) {
        $success = 0;
        $failed = 0;
        
        foreach ($userIds as $userId) {
            if ($this->send($type, $userId, $variables, $options)) {
                $success++;
            } else {
                $failed++;
            }
        }
        
        return ['success' => $success, 'failed' => $failed];
    }
    
    /**
     * Send notification to all users with specific role
     */
    public function sendToRole($type, $role, $variables = [], $options = []) {
        $stmt = $this->db->prepare("SELECT id FROM users WHERE role = ? AND status = 'active'");
        $stmt->execute([$role]);
        $userIds = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        return $this->sendBulk($type, $userIds, $variables, $options);
    }
    
    /**
     * Send notification to all active users
     */
    public function sendToAll($type, $variables = [], $options = []) {
        $stmt = $this->db->query("SELECT id FROM users WHERE status = 'active'");
        $userIds = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        return $this->sendBulk($type, $userIds, $variables, $options);
    }
    
    /**
     * Get notification template by type
     */
    private function getTemplate($type) {
        $stmt = $this->db->prepare("SELECT * FROM notification_templates WHERE type = ?");
        $stmt->execute([$type]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    /**
     * Get user information
     */
    private function getUser($userId) {
        $stmt = $this->db->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
    
    /**
     * Get user notification preferences
     */
    private function getUserPreferences($userId, $category) {
        $stmt = $this->db->prepare("
            SELECT * FROM notification_preferences 
            WHERE user_id = ? AND category = ?
        ");
        $stmt->execute([$userId, $category]);
        $prefs = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Return defaults if no preferences set
        if (!$prefs) {
            return [
                'email_enabled' => 1,
                'in_app_enabled' => 1,
                'sms_enabled' => 0
            ];
        }
        
        return $prefs;
    }
    
    /**
     * Get default variables available to all templates
     */
    private function getDefaultVariables($user) {
        $name = trim(($user['first_name'] ?? '') . ' ' . ($user['last_name'] ?? ''));
        if (empty($name)) {
            $name = $user['username'] ?? 'Customer';
        }
        
        return [
            'customer_name' => $name,
            'user_email' => $user['email'] ?? '',
            'app_name' => APP_NAME ?? 'FezaMarket',
            'app_url' => APP_URL ?? 'https://fezamarket.com',
            'support_email' => SUPPORT_EMAIL ?? 'support@fezamarket.com',
            'current_date' => date('F j, Y'),
            'current_time' => date('g:i A'),
            'current_year' => date('Y')
        ];
    }
    
    /**
     * Replace template variables
     */
    private function replaceVariables($template, $variables) {
        foreach ($variables as $key => $value) {
            $template = str_replace('{' . $key . '}', $value, $template);
        }
        return $template;
    }
    
    /**
     * Send in-app notification
     */
    private function sendInApp($userId, $type, $title, $message, $variables, $category) {
        try {
            $stmt = $this->db->prepare("
                INSERT INTO notifications (user_id, type, title, message, action_url, created_at)
                VALUES (?, ?, ?, ?, ?, NOW())
            ");
            
            $result = $stmt->execute([
                $userId,
                $type,
                $title,
                $message,
                $variables['action_url'] ?? null
            ]);
            
            // Log the notification
            $this->logNotification($userId, $type, $category, $title, $message, 'in_app', 
                $result ? 'sent' : 'failed', null);
            
            return $result;
            
        } catch (Exception $e) {
            error_log("In-app notification error: " . $e->getMessage());
            $this->logNotification($userId, $type, $category, $title, $message, 'in_app', 
                'failed', null, $e->getMessage());
            return false;
        }
    }
    
    /**
     * Send email notification
     */
    private function sendEmail($email, $name, $subject, $body, $type, $category) {
        try {
            // Queue email for sending
            $stmt = $this->db->prepare("
                INSERT INTO email_queue (recipient_email, recipient_name, subject, body, status, created_at)
                VALUES (?, ?, ?, ?, 'pending', NOW())
            ");
            
            $result = $stmt->execute([$email, $name, $subject, $body]);
            
            // Log the notification
            $this->logNotification(null, $type, $category, $subject, $body, 'email', 
                $result ? 'sent' : 'failed', $email);
            
            return $result;
            
        } catch (Exception $e) {
            error_log("Email notification error: " . $e->getMessage());
            $this->logNotification(null, $type, $category, $subject, $body, 'email', 
                'failed', $email, $e->getMessage());
            return false;
        }
    }
    
    /**
     * Send SMS notification (placeholder - implement with SMS gateway)
     */
    private function sendSMS($phone, $message, $userId, $type, $category) {
        // TODO: Implement SMS gateway integration
        // This is a placeholder for SMS functionality
        
        $this->logNotification($userId, $type, $category, 'SMS Notification', $message, 'sms', 
            'pending', $phone);
        
        return true;
    }
    
    /**
     * Log notification to database
     */
    private function logNotification($userId, $type, $category, $subject, $body, $channel, $status, $recipient = null, $error = null) {
        try {
            $stmt = $this->db->prepare("
                INSERT INTO notification_logs 
                (user_id, template_type, category, subject, body, channel, status, recipient, error_message, sent_at, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
            ");
            
            $stmt->execute([
                $userId,
                $type,
                $category,
                $subject,
                $body,
                $channel,
                $status,
                $recipient,
                $error,
                $status === 'sent' ? date('Y-m-d H:i:s') : null
            ]);
            
        } catch (Exception $e) {
            error_log("Failed to log notification: " . $e->getMessage());
        }
    }
    
    /**
     * Update user notification preferences
     */
    public function updatePreferences($userId, $category, $emailEnabled, $inAppEnabled, $smsEnabled) {
        try {
            $stmt = $this->db->prepare("
                INSERT INTO notification_preferences 
                (user_id, category, email_enabled, in_app_enabled, sms_enabled, updated_at)
                VALUES (?, ?, ?, ?, ?, NOW())
                ON DUPLICATE KEY UPDATE
                    email_enabled = VALUES(email_enabled),
                    in_app_enabled = VALUES(in_app_enabled),
                    sms_enabled = VALUES(sms_enabled),
                    updated_at = NOW()
            ");
            
            return $stmt->execute([$userId, $category, $emailEnabled, $inAppEnabled, $smsEnabled]);
            
        } catch (Exception $e) {
            error_log("Failed to update preferences: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Get all user preferences
     */
    public function getAllPreferences($userId) {
        $stmt = $this->db->prepare("
            SELECT * FROM notification_preferences 
            WHERE user_id = ?
            ORDER BY category
        ");
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Get user's unread notification count
     */
    public function getUnreadCount($userId) {
        $stmt = $this->db->prepare("
            SELECT COUNT(*) FROM notifications 
            WHERE user_id = ? AND read_at IS NULL
        ");
        $stmt->execute([$userId]);
        return (int)$stmt->fetchColumn();
    }
    
    /**
     * Mark notification as read
     */
    public function markAsRead($notificationId, $userId) {
        $stmt = $this->db->prepare("
            UPDATE notifications 
            SET read_at = NOW() 
            WHERE id = ? AND user_id = ?
        ");
        return $stmt->execute([$notificationId, $userId]);
    }
    
    /**
     * Mark all notifications as read
     */
    public function markAllAsRead($userId) {
        $stmt = $this->db->prepare("
            UPDATE notifications 
            SET read_at = NOW() 
            WHERE user_id = ? AND read_at IS NULL
        ");
        return $stmt->execute([$userId]);
    }
    
    /**
     * Get user notifications
     */
    public function getUserNotifications($userId, $limit = 50, $offset = 0, $type = null) {
        $sql = "
            SELECT * FROM notifications 
            WHERE user_id = ?
        ";
        
        $params = [$userId];
        
        if ($type) {
            $sql .= " AND type = ?";
            $params[] = $type;
        }
        
        $sql .= " ORDER BY created_at DESC LIMIT ? OFFSET ?";
        $params[] = $limit;
        $params[] = $offset;
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Delete notification
     */
    public function deleteNotification($notificationId, $userId) {
        $stmt = $this->db->prepare("
            DELETE FROM notifications 
            WHERE id = ? AND user_id = ?
        ");
        return $stmt->execute([$notificationId, $userId]);
    }
    
    /**
     * Get notification statistics for user
     */
    public function getStatistics($userId, $days = 30) {
        $stmt = $this->db->prepare("
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN read_at IS NULL THEN 1 ELSE 0 END) as unread,
                type,
                DATE(created_at) as date
            FROM notifications
            WHERE user_id = ? 
            AND created_at >= DATE_SUB(NOW(), INTERVAL ? DAY)
            GROUP BY type, DATE(created_at)
            ORDER BY created_at DESC
        ");
        $stmt->execute([$userId, $days]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Clean up old notifications
     */
    public function cleanup($daysOld = 90) {
        $stmt = $this->db->prepare("
            DELETE FROM notifications 
            WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)
            AND read_at IS NOT NULL
        ");
        return $stmt->execute([$daysOld]);
    }
    
    /**
     * Get all notification templates
     */
    public function getAllTemplates($category = null) {
        if ($category) {
            $stmt = $this->db->prepare("
                SELECT * FROM notification_templates 
                WHERE category = ?
                ORDER BY name
            ");
            $stmt->execute([$category]);
        } else {
            $stmt = $this->db->query("
                SELECT * FROM notification_templates 
                ORDER BY category, name
            ");
        }
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Create or update notification template
     */
    public function saveTemplate($data) {
        try {
            if (isset($data['id'])) {
                // Update existing template
                $stmt = $this->db->prepare("
                    UPDATE notification_templates 
                    SET name = ?, description = ?, subject = ?, body_template = ?, 
                        category = ?, enabled = ?, send_email = ?, send_in_app = ?, 
                        send_sms = ?, priority = ?, updated_at = NOW()
                    WHERE id = ?
                ");
                return $stmt->execute([
                    $data['name'],
                    $data['description'],
                    $data['subject'],
                    $data['body_template'],
                    $data['category'],
                    $data['enabled'] ?? 1,
                    $data['send_email'] ?? 1,
                    $data['send_in_app'] ?? 1,
                    $data['send_sms'] ?? 0,
                    $data['priority'] ?? 'normal',
                    $data['id']
                ]);
            } else {
                // Create new template
                $stmt = $this->db->prepare("
                    INSERT INTO notification_templates 
                    (type, name, description, subject, body_template, category, enabled, 
                     send_email, send_in_app, send_sms, priority, created_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
                ");
                return $stmt->execute([
                    $data['type'],
                    $data['name'],
                    $data['description'],
                    $data['subject'],
                    $data['body_template'],
                    $data['category'],
                    $data['enabled'] ?? 1,
                    $data['send_email'] ?? 1,
                    $data['send_in_app'] ?? 1,
                    $data['send_sms'] ?? 0,
                    $data['priority'] ?? 'normal'
                ]);
            }
        } catch (Exception $e) {
            error_log("Failed to save template: " . $e->getMessage());
            return false;
        }
    }
}

// Helper functions for easy access
if (!function_exists('sendNotification')) {
    function sendNotification($type, $userId, $variables = [], $options = []) {
        $service = new EnhancedNotificationService();
        return $service->send($type, $userId, $variables, $options);
    }
}

if (!function_exists('sendNotificationToRole')) {
    function sendNotificationToRole($type, $role, $variables = [], $options = []) {
        $service = new EnhancedNotificationService();
        return $service->sendToRole($type, $role, $variables, $options);
    }
}

if (!function_exists('sendNotificationToAll')) {
    function sendNotificationToAll($type, $variables = [], $options = []) {
        $service = new EnhancedNotificationService();
        return $service->sendToAll($type, $variables, $options);
    }
}

if (!function_exists('updateNotificationPreferences')) {
    function updateNotificationPreferences($userId, $category, $emailEnabled, $inAppEnabled, $smsEnabled) {
        $service = new EnhancedNotificationService();
        return $service->updatePreferences($userId, $category, $emailEnabled, $inAppEnabled, $smsEnabled);
    }
}
