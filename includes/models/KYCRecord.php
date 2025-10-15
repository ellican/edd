<?php
/**
 * KYC Records Management Class
 * Handles all KYC record operations including CRUD, verification, and compliance
 */

class KYCRecord extends BaseModel {
    protected $table = 'kyc_records';
    
    /**
     * Get KYC record by user ID
     */
    public function getByUserId($userId) {
        if (!$this->db) {
            throw new Exception("Database connection not available");
        }
        
        $stmt = $this->db->prepare("SELECT * FROM {$this->table} WHERE user_id = ? ORDER BY created_at DESC LIMIT 1");
        $stmt->execute([$userId]);
        return $stmt->fetch();
    }
    
    /**
     * Get all KYC records with filters
     */
    public function getRecords($filters = [], $limit = 25, $offset = 0) {
        if (!$this->db) {
            throw new Exception("Database connection not available");
        }
        
        $whereConditions = [];
        $params = [];
        
        if (!empty($filters['status'])) {
            $whereConditions[] = "status = ?";
            $params[] = $filters['status'];
        }
        
        if (!empty($filters['risk_level'])) {
            $whereConditions[] = "risk_level = ?";
            $params[] = $filters['risk_level'];
        }
        
        if (!empty($filters['date_from'])) {
            $whereConditions[] = "created_at >= ?";
            $params[] = $filters['date_from'];
        }
        
        if (!empty($filters['date_to'])) {
            $whereConditions[] = "created_at <= ?";
            $params[] = $filters['date_to'];
        }
        
        if (!empty($filters['search'])) {
            $whereConditions[] = "(full_name LIKE ? OR id_number LIKE ? OR user_id = ?)";
            $searchTerm = "%{$filters['search']}%";
            $params[] = $searchTerm;
            $params[] = $searchTerm;
            $params[] = intval($filters['search']);
        }
        
        $whereClause = !empty($whereConditions) ? "WHERE " . implode(" AND ", $whereConditions) : "";
        
        $sql = "
            SELECT kr.*, u.email, u.first_name, u.last_name, u.phone,
                   verifier.first_name as verifier_first_name, 
                   verifier.last_name as verifier_last_name
            FROM {$this->table} kr
            JOIN users u ON kr.user_id = u.id
            LEFT JOIN users verifier ON kr.verified_by = verifier.id
            {$whereClause}
            ORDER BY kr.created_at DESC
            LIMIT ? OFFSET ?
        ";
        
        $params[] = $limit;
        $params[] = $offset;
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }
    
    /**
     * Get KYC statistics
     */
    public function getStatistics() {
        if (!$this->db) {
            return [
                'total' => 0,
                'pending' => 0,
                'approved' => 0,
                'rejected' => 0,
                'expired' => 0,
                'incomplete' => 0
            ];
        }
        
        $sql = "
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
                SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
                SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
                SUM(CASE WHEN status = 'expired' THEN 1 ELSE 0 END) as expired,
                SUM(CASE WHEN status = 'incomplete' THEN 1 ELSE 0 END) as incomplete
            FROM {$this->table}
        ";
        
        $stmt = $this->db->query($sql);
        return $stmt->fetch();
    }
    
    /**
     * Count records by filter
     */
    public function countRecords($filters = []) {
        if (!$this->db) {
            return 0;
        }
        
        $whereConditions = [];
        $params = [];
        
        if (!empty($filters['status'])) {
            $whereConditions[] = "status = ?";
            $params[] = $filters['status'];
        }
        
        if (!empty($filters['risk_level'])) {
            $whereConditions[] = "risk_level = ?";
            $params[] = $filters['risk_level'];
        }
        
        if (!empty($filters['search'])) {
            $whereConditions[] = "(full_name LIKE ? OR id_number LIKE ? OR user_id = ?)";
            $searchTerm = "%{$filters['search']}%";
            $params[] = $searchTerm;
            $params[] = $searchTerm;
            $params[] = intval($filters['search']);
        }
        
        $whereClause = !empty($whereConditions) ? "WHERE " . implode(" AND ", $whereConditions) : "";
        
        $sql = "SELECT COUNT(*) FROM {$this->table} {$whereClause}";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchColumn();
    }
    
    /**
     * Approve KYC record
     */
    public function approve($id, $verifierId, $notes = '') {
        if (!$this->db) {
            throw new Exception("Database connection not available");
        }
        
        $this->db->beginTransaction();
        
        try {
            // Update KYC record
            $stmt = $this->db->prepare("
                UPDATE {$this->table} 
                SET status = 'approved', 
                    verified_by = ?,
                    verified_at = NOW(),
                    notes = ?
                WHERE id = ?
            ");
            $stmt->execute([$verifierId, $notes, $id]);
            
            // Log history
            $this->logHistory($id, 'approved', $verifierId, $notes);
            
            $this->db->commit();
            return true;
        } catch (Exception $e) {
            $this->db->rollBack();
            throw $e;
        }
    }
    
    /**
     * Reject KYC record
     */
    public function reject($id, $verifierId, $reason) {
        if (!$this->db) {
            throw new Exception("Database connection not available");
        }
        
        if (empty($reason)) {
            throw new Exception("Rejection reason is required");
        }
        
        $this->db->beginTransaction();
        
        try {
            // Update KYC record
            $stmt = $this->db->prepare("
                UPDATE {$this->table} 
                SET status = 'rejected', 
                    verified_by = ?,
                    verified_at = NOW(),
                    rejection_reason = ?,
                    notes = ?
                WHERE id = ?
            ");
            $stmt->execute([$verifierId, $reason, $reason, $id]);
            
            // Log history
            $this->logHistory($id, 'rejected', $verifierId, $reason);
            
            $this->db->commit();
            return true;
        } catch (Exception $e) {
            $this->db->rollBack();
            throw $e;
        }
    }
    
    /**
     * Log verification history
     */
    private function logHistory($kycRecordId, $action, $performedBy, $notes = '') {
        $stmt = $this->db->prepare("
            INSERT INTO kyc_verification_history 
            (kyc_record_id, action, performed_by, notes, ip_address, created_at)
            VALUES (?, ?, ?, ?, ?, NOW())
        ");
        
        $ipAddress = $_SERVER['REMOTE_ADDR'] ?? null;
        $stmt->execute([$kycRecordId, $action, $performedBy, $notes, $ipAddress]);
    }
    
    /**
     * Get records expiring soon
     */
    public function getExpiringRecords($daysBeforeExpiry = 30) {
        if (!$this->db) {
            return [];
        }
        
        $sql = "
            SELECT kr.*, u.email, u.first_name, u.last_name
            FROM {$this->table} kr
            JOIN users u ON kr.user_id = u.id
            WHERE kr.status = 'approved'
            AND kr.expiry_date IS NOT NULL
            AND kr.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
            AND kr.expiry_date >= CURDATE()
            ORDER BY kr.expiry_date ASC
        ";
        
        $stmt = $this->db->prepare($sql);
        $stmt->execute([$daysBeforeExpiry]);
        return $stmt->fetchAll();
    }
    
    /**
     * Mark expired records
     */
    public function markExpiredRecords() {
        if (!$this->db) {
            return 0;
        }
        
        $stmt = $this->db->prepare("
            UPDATE {$this->table}
            SET status = 'expired'
            WHERE status = 'approved'
            AND expiry_date IS NOT NULL
            AND expiry_date < CURDATE()
        ");
        $stmt->execute();
        return $stmt->rowCount();
    }
    
    /**
     * Export KYC records to CSV
     */
    public function exportToCSV($filters = []) {
        $records = $this->getRecords($filters, 10000, 0);
        
        $headers = [
            'ID', 'User ID', 'Full Name', 'Email', 'ID Type', 'ID Number', 
            'Status', 'Risk Level', 'Verified By', 'Verified At', 
            'Created At', 'Expiry Date'
        ];
        
        $csv = [];
        $csv[] = $headers;
        
        foreach ($records as $record) {
            $csv[] = [
                $record['id'],
                $record['user_id'],
                $record['full_name'],
                $record['email'] ?? '',
                $record['id_type'],
                $record['id_number'],
                $record['status'],
                $record['risk_level'],
                ($record['verifier_first_name'] ?? '') . ' ' . ($record['verifier_last_name'] ?? ''),
                $record['verified_at'] ?? '',
                $record['created_at'],
                $record['expiry_date'] ?? ''
            ];
        }
        
        return $csv;
    }
}
