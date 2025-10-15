<?php
/**
 * Wallet Service
 * Handles wallet operations, transfers, and balance management
 */

class WalletService {
    private $db;
    
    public function __construct($db = null) {
        $this->db = $db ?? db();
    }
    
    /**
     * Get or create user wallet
     */
    public function getWallet($userId, $currency = 'USD') {
        $stmt = $this->db->prepare("
            SELECT * FROM wallets WHERE user_id = ? AND currency = ?
        ");
        $stmt->execute([$userId, $currency]);
        $wallet = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$wallet) {
            // Create wallet
            $stmt = $this->db->prepare("
                INSERT INTO wallets (user_id, balance, currency, status, created_at)
                VALUES (?, 0.00, ?, 'active', NOW())
            ");
            $stmt->execute([$userId, $currency]);
            
            return $this->getWallet($userId, $currency);
        }
        
        return $wallet;
    }
    
    /**
     * Check if wallet is active
     */
    private function checkWalletStatus($wallet) {
        if (!isset($wallet['status']) || $wallet['status'] === 'suspended') {
            throw new Exception('Wallet is suspended. Please contact support.');
        }
    }
    
    /**
     * Credit wallet
     */
    public function credit($userId, $amount, $reference = null, $description = null, $meta = null) {
        if ($amount <= 0) {
            throw new Exception('Amount must be positive');
        }
        
        $this->db->beginTransaction();
        try {
            $wallet = $this->getWallet($userId);
            $this->checkWalletStatus($wallet);
            
            $balance_before = $wallet['balance'];
            $newBalance = $balance_before + $amount;
            
            // Update balance
            $stmt = $this->db->prepare("
                UPDATE wallets SET balance = ?, updated_at = NOW() WHERE id = ?
            ");
            $stmt->execute([$newBalance, $wallet['id']]);
            
            // Record transaction
            $stmt = $this->db->prepare("
                INSERT INTO wallet_transactions 
                (wallet_id, user_id, type, amount, balance_before, balance_after, reference, description, status, meta, created_at)
                VALUES (?, ?, 'credit', ?, ?, ?, ?, ?, 'success', ?, NOW())
            ");
            $stmt->execute([
                $wallet['id'],
                $userId, 
                $amount,
                $balance_before, 
                $newBalance, 
                $reference, 
                $description, 
                $meta ? json_encode($meta) : null
            ]);
            
            // Send email notification
            $this->sendWalletEmail($userId, 'credit', $amount, $newBalance, $description, $wallet['currency']);
            
            $this->db->commit();
            return $newBalance;
        } catch (Exception $e) {
            $this->db->rollBack();
            throw $e;
        }
    }
    
    /**
     * Debit wallet
     */
    public function debit($userId, $amount, $reference = null, $description = null, $meta = null) {
        if ($amount <= 0) {
            throw new Exception('Amount must be positive');
        }
        
        $this->db->beginTransaction();
        try {
            $wallet = $this->getWallet($userId);
            $this->checkWalletStatus($wallet);
            
            if ($wallet['balance'] < $amount) {
                throw new Exception('Insufficient wallet balance');
            }
            
            $balance_before = $wallet['balance'];
            $newBalance = $balance_before - $amount;
            
            // Update balance
            $stmt = $this->db->prepare("
                UPDATE wallets SET balance = ?, updated_at = NOW() WHERE id = ?
            ");
            $stmt->execute([$newBalance, $wallet['id']]);
            
            // Record transaction
            $stmt = $this->db->prepare("
                INSERT INTO wallet_transactions 
                (wallet_id, user_id, type, amount, balance_before, balance_after, reference, description, status, meta, created_at)
                VALUES (?, ?, 'debit', ?, ?, ?, ?, ?, 'success', ?, NOW())
            ");
            $stmt->execute([
                $wallet['id'],
                $userId, 
                $amount,
                $balance_before, 
                $newBalance, 
                $reference, 
                $description, 
                $meta ? json_encode($meta) : null
            ]);
            
            // Send email notification
            $this->sendWalletEmail($userId, 'debit', $amount, $newBalance, $description, $wallet['currency']);
            
            $this->db->commit();
            return $newBalance;
        } catch (Exception $e) {
            $this->db->rollBack();
            throw $e;
        }
    }
    
    /**
     * Transfer between users
     */
    public function transfer($fromUserId, $toUserId, $amount, $note = null) {
        if ($amount <= 0) {
            throw new Exception('Amount must be positive');
        }
        
        if ($fromUserId == $toUserId) {
            throw new Exception('Cannot transfer to yourself');
        }
        
        // Verify recipient exists and get user info
        $stmt = $this->db->prepare("SELECT id, email, first_name, last_name FROM users WHERE id = ? AND status = 'active'");
        $stmt->execute([$toUserId]);
        $recipient = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$recipient) {
            throw new Exception('Recipient not found or account is not active');
        }
        
        // Get sender info for notifications
        $stmt = $this->db->prepare("SELECT id, email, first_name, last_name FROM users WHERE id = ?");
        $stmt->execute([$fromUserId]);
        $sender = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $this->db->beginTransaction();
        try {
            // Debit sender
            $this->debit($fromUserId, $amount, "transfer_to_{$toUserId}", $note, [
                'transfer_type' => 'send',
                'recipient_id' => $toUserId,
                'recipient_email' => $recipient['email']
            ]);
            
            // Credit recipient
            $this->credit($toUserId, $amount, "transfer_from_{$fromUserId}", $note, [
                'transfer_type' => 'receive',
                'sender_id' => $fromUserId,
                'sender_email' => $sender['email']
            ]);
            
            // Create notifications for both parties
            try {
                // Notify sender
                $senderMsg = sprintf(
                    'You sent $%.2f to %s (%s).%s',
                    $amount,
                    $recipient['first_name'] . ' ' . $recipient['last_name'],
                    $recipient['email'],
                    $note ? " Note: $note" : ''
                );
                $this->db->prepare("INSERT INTO notifications (user_id, type, title, message, created_at) VALUES (?, 'wallet', 'Transfer Sent', ?, NOW())")->execute([$fromUserId, $senderMsg]);
                
                // Notify recipient
                $recipientMsg = sprintf(
                    'You received $%.2f from %s (%s).%s',
                    $amount,
                    $sender['first_name'] . ' ' . $sender['last_name'],
                    $sender['email'],
                    $note ? " Note: $note" : ''
                );
                $this->db->prepare("INSERT INTO notifications (user_id, type, title, message, created_at) VALUES (?, 'wallet', 'Transfer Received', ?, NOW())")->execute([$toUserId, $recipientMsg]);
            } catch (Exception $e) {
                error_log("Failed to create transfer notifications: " . $e->getMessage());
            }
            
            $this->db->commit();
            return true;
        } catch (Exception $e) {
            $this->db->rollBack();
            throw $e;
        }
    }
    
    /**
     * Get transaction history
     */
    public function getTransactions($userId, $limit = 50, $offset = 0) {
        $stmt = $this->db->prepare("
            SELECT * FROM wallet_transactions 
            WHERE user_id = ? 
            ORDER BY created_at DESC 
            LIMIT ? OFFSET ?
        ");
        $stmt->execute([$userId, $limit, $offset]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    /**
     * Send wallet notification email
     */
    private function sendWalletEmail($userId, $type, $amount, $newBalance, $description, $currency = 'USD') {
        try {
            // Get user info
            $stmt = $this->db->prepare("SELECT email, first_name, last_name FROM users WHERE id = ?");
            $stmt->execute([$userId]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user) {
                return;
            }
            
            $userName = $user['first_name'] . ' ' . $user['last_name'];
            
            // Check if EmailService exists
            if (class_exists('EmailService')) {
                $emailService = EmailService::getInstance();
                $emailService->send(
                    $user['email'],
                    'Wallet ' . ucfirst($type) . ' Notification',
                    'wallet_notification',
                    [
                        'userName' => $userName,
                        'type' => $type,
                        'amount' => $amount,
                        'newBalance' => $newBalance,
                        'description' => $description,
                        'currency' => $currency
                    ]
                );
            }
        } catch (Exception $e) {
            error_log("Failed to send wallet email: " . $e->getMessage());
        }
    }
}
