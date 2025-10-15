<?php
/**
 * Admin Account Management Panel
 * Monitor and control user activities, transactions, and security
 */

require_once __DIR__ . '/../../includes/init.php';
require_once __DIR__ . '/../../includes/rbac.php';

// Require admin authentication
requireAdminAuth();
checkPermission('users.view');

$page_title = 'Account Management';
$userId = (int)($_GET['user_id'] ?? 0);

// Placeholder for now - full implementation to be added
$userData = null;

if ($userId > 0) {
    try {
        $db = Database::getInstance()->getConnection();
        
        // Get user data
        $stmt = $db->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $userData = $stmt->fetch(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        error_log("Admin Account Management Error: " . $e->getMessage());
    }
}

include __DIR__ . '/../includes/admin_header.php';
?>

<div style="padding: 2rem;">
    <h1>Account Management</h1>
    <p>Monitor and manage user activities, transactions, and security</p>
    
    <div style="background: white; padding: 1.5rem; border-radius: 8px; margin-top: 2rem;">
        <h3>Find User</h3>
        <form method="GET" action="" style="display: flex; gap: 1rem; margin-top: 1rem;">
            <input 
                type="text" 
                name="user_id" 
                placeholder="Enter User ID..."
                value="<?php echo htmlspecialchars($_GET['user_id'] ?? ''); ?>"
                style="flex: 1; padding: 0.75rem; border: 1px solid #ddd; border-radius: 6px;"
                required
            >
            <button type="submit" style="padding: 0.75rem 2rem; background: #3b82f6; color: white; border: none; border-radius: 6px; cursor: pointer;">Search</button>
        </form>
    </div>
    
    <?php if ($userData): ?>
        <div style="background: white; padding: 2rem; border-radius: 8px; margin-top: 2rem;">
            <h2><?php echo htmlspecialchars($userData['first_name'] . ' ' . $userData['last_name']); ?></h2>
            <p><?php echo htmlspecialchars($userData['email']); ?> • User ID: <?php echo $userData['id']; ?></p>
            <p>Role: <?php echo htmlspecialchars(ucfirst($userData['role'])); ?> • Status: <?php echo htmlspecialchars(ucfirst($userData['status'])); ?></p>
            
            <p style="margin-top: 2rem;">Full implementation coming soon...</p>
        </div>
    <?php elseif (isset($_GET['user_id']) && $_GET['user_id'] !== ''): ?>
        <div style="background: white; padding: 2rem; border-radius: 8px; margin-top: 2rem;">
            <p>User not found. Please try a different search.</p>
        </div>
    <?php endif; ?>
</div>

<?php include __DIR__ . '/../includes/admin_footer.php'; ?>
