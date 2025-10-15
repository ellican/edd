<?php
/**
 * Professional Dispute Resolution Dashboard
 * 
 * Full-featured dispute management with live chat integration,
 * SLA tracking, assignment, and resolution workflows.
 * 
 * @package    Admin/Disputes
 * @version    2.0.0
 */

// Core application requirements
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/csrf.php';
require_once __DIR__ . '/../../includes/rbac.php';
require_once __DIR__ . '/../../includes/init.php';

// --- Page Setup & Security ---
$page_title = 'Dispute Resolution Dashboard';
$error_message = $_SESSION['error_message'] ?? null;
$success_message = $_SESSION['success_message'] ?? null;
unset($_SESSION['error_message'], $_SESSION['success_message']);

// Initialize default values
$stats = ['total_disputes' => 0, 'pending_resolution' => 0, 'overdue_sla' => 0, 'resolved' => 0];
$disputes = [];
$admins = [];

try {
    // Authenticate and check permissions
    requireAdminAuth();
    checkPermission('disputes.view');
    $pdo = db();
    
    // Handle POST actions
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
        if (!verifyCsrfToken($_POST['csrf_token'] ?? '')) {
            throw new Exception('Invalid security token');
        }
        
        $action = $_POST['action'];
        $dispute_id = (int)($_POST['dispute_id'] ?? 0);
        $admin_id = Session::getUserId();
        
        switch ($action) {
            case 'assign':
                checkPermission('disputes.assign');
                $assignee_id = (int)($_POST['assignee_id'] ?? 0);
                
                $stmt = $pdo->prepare("UPDATE disputes SET assigned_to = ?, status = 'in_progress', updated_at = NOW() WHERE id = ?");
                $stmt->execute([$assignee_id, $dispute_id]);
                
                // Log activity
                $stmt = $pdo->prepare("INSERT INTO dispute_activity (dispute_id, actor_id, actor_type, action, details) VALUES (?, ?, 'admin', 'assigned', JSON_OBJECT('assignee_id', ?))");
                $stmt->execute([$dispute_id, $admin_id, $assignee_id]);
                
                $_SESSION['success_message'] = 'Dispute assigned successfully';
                break;
                
            case 'escalate':
                checkPermission('disputes.escalate');
                $stmt = $pdo->prepare("UPDATE disputes SET priority = 'critical', status = 'escalated', updated_at = NOW() WHERE id = ?");
                $stmt->execute([$dispute_id]);
                
                // Log activity
                $stmt = $pdo->prepare("INSERT INTO dispute_activity (dispute_id, actor_id, actor_type, action) VALUES (?, ?, 'admin', 'escalated')");
                $stmt->execute([$dispute_id, $admin_id]);
                
                $_SESSION['success_message'] = 'Dispute escalated successfully';
                break;
                
            case 'resolve':
                checkPermission('disputes.resolve');
                $resolution_notes = trim($_POST['resolution_notes'] ?? '');
                
                $stmt = $pdo->prepare("UPDATE disputes SET status = 'resolved', resolution_notes = ?, resolved_at = NOW(), updated_at = NOW() WHERE id = ?");
                $stmt->execute([$resolution_notes, $dispute_id]);
                
                // Log activity
                $stmt = $pdo->prepare("INSERT INTO dispute_activity (dispute_id, actor_id, actor_type, action, details) VALUES (?, ?, 'admin', 'resolved', JSON_OBJECT('notes', ?))");
                $stmt->execute([$dispute_id, $admin_id, $resolution_notes]);
                
                $_SESSION['success_message'] = 'Dispute resolved successfully';
                break;
                
            case 'send_message':
                checkPermission('disputes.message');
                $message = trim($_POST['message'] ?? '');
                $is_internal = isset($_POST['is_internal']) ? 1 : 0;
                
                if (empty($message)) {
                    throw new Exception('Message cannot be empty');
                }
                
                $stmt = $pdo->prepare("INSERT INTO dispute_messages (dispute_id, sender_id, sender_type, message, is_internal, created_at) VALUES (?, ?, 'admin', ?, ?, NOW())");
                $stmt->execute([$dispute_id, $admin_id, $message, $is_internal]);
                
                // Update dispute timestamp
                $pdo->prepare("UPDATE disputes SET updated_at = NOW() WHERE id = ?")->execute([$dispute_id]);
                
                $_SESSION['success_message'] = 'Message sent successfully';
                break;
        }
        
        header('Location: /admin/disputes/');
        exit;
    }

    // --- DATA FETCHING FOR DISPLAY (GET REQUESTS) ---
    // Fetch dashboard statistics
    $stats_query = $pdo->query("
        SELECT
            COUNT(*) as total_disputes,
            COALESCE(SUM(CASE WHEN status IN ('pending', 'in_progress', 'escalated') THEN 1 ELSE 0 END), 0) as pending_resolution,
            COALESCE(SUM(CASE WHEN status NOT IN ('resolved', 'closed') AND sla_deadline < NOW() THEN 1 ELSE 0 END), 0) as overdue_sla,
            COALESCE(SUM(CASE WHEN status IN ('resolved', 'closed') THEN 1 ELSE 0 END), 0) as resolved
        FROM disputes
    ");
    if ($stats_query) {
        $stats = $stats_query->fetch(PDO::FETCH_ASSOC);
    }
    
    // Get admins for assignment
    $admins_query = $pdo->query("SELECT id, username, email FROM users WHERE role IN ('admin', 'support') AND status = 'active' ORDER BY username");
    $admins = $admins_query->fetchAll(PDO::FETCH_ASSOC);

    // Filtering logic
    $filter = $_GET['filter'] ?? 'all';
    $assigned_filter = $_GET['assigned_to'] ?? '';
    $params = [];
    $where_conditions = [];

    switch ($filter) {
        case 'pending':
            $where_conditions[] = "d.status IN ('pending', 'in_progress')";
            break;
        case 'overdue':
            $where_conditions[] = "d.status NOT IN ('resolved', 'closed') AND d.sla_deadline < NOW()";
            break;
        case 'escalated':
            $where_conditions[] = "d.status = 'escalated'";
            break;
        case 'resolved':
            $where_conditions[] = "d.status IN ('resolved', 'closed')";
            break;
    }
    
    if (!empty($assigned_filter)) {
        $where_conditions[] = "d.assigned_to = ?";
        $params[] = $assigned_filter;
    }
    
    $where_sql = !empty($where_conditions) ? 'WHERE ' . implode(' AND ', $where_conditions) : '';

    // Fetch dispute data with unread message counts
    $disputes_query = $pdo->prepare("
        SELECT
            d.id,
            d.order_id,
            d.subject,
            d.status,
            d.priority,
            d.created_at,
            d.updated_at,
            d.sla_deadline,
            cust.id as user_id,
            cust.username as user_name,
            cust.email as user_email,
            v.id as vendor_id,
            v.business_name as vendor_name,
            adm.id as assigned_admin_id,
            adm.username as assigned_admin_name,
            (SELECT COUNT(*) FROM dispute_messages WHERE dispute_id = d.id AND is_read = 0 AND sender_type != 'admin') as unread_count
        FROM disputes d
        LEFT JOIN users cust ON d.user_id = cust.id
        LEFT JOIN vendors v ON d.vendor_id = v.id
        LEFT JOIN users adm ON d.assigned_to = adm.id
        $where_sql
        ORDER BY 
            CASE WHEN d.status NOT IN ('resolved', 'closed') AND d.sla_deadline < NOW() THEN 0 ELSE 1 END,
            d.priority DESC,
            d.created_at DESC
        LIMIT 100
    ");
    $disputes_query->execute($params);
    $disputes = $disputes_query->fetchAll(PDO::FETCH_ASSOC);

} catch (Exception $e) {
    // Centralized error handling with logging
    error_log("Admin Disputes Dashboard Error: " . $e->getMessage());
    $error_message = "An error occurred while loading disputes. Please try again.";
}

// --- RENDER PAGE ---
require_once __DIR__ . '/../../includes/header.php';
?>

<style>
/* Professional Dispute Resolution Dashboard Styling */
.card {
    border-radius: 8px;
    transition: shadow 0.3s ease;
}
.card:hover {
    box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1);
}
.card-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 8px 8px 0 0;
    padding: 1rem 1.5rem;
}
.table th {
    background-color: #f8f9fa;
    font-weight: 600;
    text-transform: uppercase;
    font-size: 0.85rem;
    letter-spacing: 0.5px;
}
.badge {
    padding: 0.4em 0.8em;
    font-size: 0.85rem;
}
.btn-group .btn {
    transition: all 0.2s ease;
}
.btn-group .btn:hover {
    transform: translateY(-2px);
}
.table-hover tbody tr:hover {
    background-color: #f8f9fa;
}
.modal-header {
    border-radius: 8px 8px 0 0;
}
</style>

<div class="container-fluid my-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h2"><i class="fas fa-gavel"></i> Dispute Resolution</h1>
        <nav class="nav">
            <a class="nav-link" href="/admin/">Back to Admin</a>
            <a class="nav-link active" href="/admin/disputes/">Disputes</a>
            <a class="nav-link" href="/logout.php">Logout</a>
        </nav>
    </div>

    <?php if ($error_message): ?>
        <div class="alert alert-danger"><?php echo htmlspecialchars($error_message); ?></div>
    <?php endif; ?>

    <!-- Stats Cards -->
    <div class="row g-4 mb-4">
        <div class="col-md-3"><div class="card shadow-sm text-center"><div class="card-body"><h5 class="card-title h2 text-primary"><?php echo (int)($stats['total_disputes'] ?? 0); ?></h5><p class="card-text text-muted">Total Disputes</p></div></div></div>
        <div class="col-md-3"><div class="card shadow-sm text-center"><div class="card-body"><h5 class="card-title h2 text-warning"><?php echo (int)($stats['pending_resolution'] ?? 0); ?></h5><p class="card-text text-muted">Pending Resolution</p></div></div></div>
        <div class="col-md-3"><div class="card shadow-sm text-center"><div class="card-body"><h5 class="card-title h2 text-danger"><?php echo (int)($stats['overdue_sla'] ?? 0); ?></h5><p class="card-text text-muted">Overdue SLA</p></div></div></div>
        <div class="col-md-3"><div class="card shadow-sm text-center"><div class="card-body"><h5 class="card-title h2 text-success"><?php echo (int)($stats['resolved'] ?? 0); ?></h5><p class="card-text text-muted">Resolved</p></div></div></div>
    </div>

    <div class="card shadow-sm">
        <div class="card-header d-flex justify-content-between align-items-center">
            <div class="btn-group" role="group">
                <a href="?filter=all" class="btn <?php echo $filter === 'all' ? 'btn-primary' : 'btn-outline-primary'; ?>">All Disputes</a>
                <a href="?filter=pending" class="btn <?php echo $filter === 'pending' ? 'btn-warning' : 'btn-outline-warning'; ?>">Pending</a>
                <a href="?filter=overdue" class="btn <?php echo $filter === 'overdue' ? 'btn-danger' : 'btn-outline-danger'; ?>">Overdue</a>
                <a href="?filter=resolved" class="btn <?php echo $filter === 'resolved' ? 'btn-success' : 'btn-outline-success'; ?>">Resolved</a>
            </div>
            <button class="btn btn-secondary"><i class="fas fa-download me-2"></i>Export</button>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th>Dispute ID</th>
                            <th>Subject</th>
                            <th>Parties Involved</th>
                            <th>Status</th>
                            <th>Date Created</th>
                            <th>SLA Deadline</th>
                            <th>Assigned To</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($disputes)): ?>
                            <tr><td colspan="8" class="text-center text-muted p-5"><i class="fas fa-gavel fa-2x mb-2"></i><br>No disputes found for this filter.</td></tr>
                        <?php else: foreach ($disputes as $dispute): ?>
                            <tr>
                                <td>#<?php echo htmlspecialchars($dispute['id']); ?></td>
                                <td><?php echo htmlspecialchars($dispute['subject']); ?></td>
                                <td>
                                    <?php if($dispute['user_name']): ?><div><small>Customer:</small> <?php echo htmlspecialchars($dispute['user_name']); ?></div><?php endif; ?>
                                    <?php if($dispute['vendor_name']): ?><div><small>Vendor:</small> <?php echo htmlspecialchars($dispute['vendor_name']); ?></div><?php endif; ?>
                                </td>
                                <td>
                                    <?php
                                    $status_map = ['pending' => 'warning', 'in_progress' => 'info', 'resolved' => 'success', 'closed' => 'secondary'];
                                    $status_class = $status_map[$dispute['status']] ?? 'primary';
                                    ?>
                                    <span class="badge bg-<?php echo $status_class; ?>"><?php echo ucfirst(str_replace('_', ' ', $dispute['status'])); ?></span>
                                </td>
                                <td><?php echo date('Y-m-d H:i', strtotime($dispute['created_at'])); ?></td>
                                <td>
                                    <?php if($dispute['sla_deadline']): ?>
                                        <span class="<?php echo strtotime($dispute['sla_deadline']) < time() ? 'text-danger fw-bold' : ''; ?>">
                                            <?php echo date('Y-m-d H:i', strtotime($dispute['sla_deadline'])); ?>
                                        </span>
                                    <?php else: ?>
                                        <span class="text-muted">N/A</span>
                                    <?php endif; ?>
                                </td>
                                <td><?php echo htmlspecialchars($dispute['assigned_admin_name'] ?? 'Unassigned'); ?></td>
                                <td class="text-end">
                                    <div class="btn-group btn-group-sm" role="group">
                                        <a href="view_dispute.php?id=<?php echo $dispute['id']; ?>" class="btn btn-primary" title="View Details">
                                            <i class="fas fa-eye"></i> View
                                        </a>
                                        <?php if ($dispute['status'] !== 'resolved' && $dispute['status'] !== 'closed'): ?>
                                            <button type="button" class="btn btn-info" data-bs-toggle="modal" data-bs-target="#assignModal" 
                                                data-dispute-id="<?php echo $dispute['id']; ?>" title="Assign to Admin">
                                                <i class="fas fa-user-plus"></i> Assign
                                            </button>
                                            <button type="button" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#escalateModal" 
                                                data-dispute-id="<?php echo $dispute['id']; ?>" title="Escalate">
                                                <i class="fas fa-exclamation-triangle"></i> Escalate
                                            </button>
                                            <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#resolveModal" 
                                                data-dispute-id="<?php echo $dispute['id']; ?>" title="Resolve">
                                                <i class="fas fa-check"></i> Resolve
                                            </button>
                                        <?php endif; ?>
                                    </div>
                                </td>
                            </tr>
                        <?php endforeach; endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Modals for Dispute Actions -->

<!-- Assign Modal -->
<div class="modal fade" id="assignModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title"><i class="fas fa-user-plus"></i> Assign Dispute</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                    <input type="hidden" name="action" value="assign">
                    <input type="hidden" name="dispute_id" class="modal-dispute-id">
                    <div class="mb-3">
                        <label class="form-label">Assign To</label>
                        <select name="assignee_id" class="form-select" required>
                            <option value="">Select admin or support staff</option>
                            <?php foreach ($admins as $admin): ?>
                                <option value="<?php echo $admin['id']; ?>">
                                    <?php echo htmlspecialchars($admin['username']); ?> (<?php echo htmlspecialchars($admin['email']); ?>)
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-info"><i class="fas fa-user-plus"></i> Assign</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Escalate Modal -->
<div class="modal fade" id="escalateModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header bg-warning text-dark">
                    <h5 class="modal-title"><i class="fas fa-exclamation-triangle"></i> Escalate Dispute</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                    <input type="hidden" name="action" value="escalate">
                    <input type="hidden" name="dispute_id" class="modal-dispute-id">
                    <div class="alert alert-warning">
                        <i class="fas fa-info-circle"></i> This will mark the dispute as critical priority and notify the escalation team.
                    </div>
                    <p>Are you sure you want to escalate this dispute?</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-warning"><i class="fas fa-exclamation-triangle"></i> Escalate</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Resolve Modal -->
<div class="modal fade" id="resolveModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title"><i class="fas fa-check"></i> Resolve Dispute</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="csrf_token" value="<?php echo generateCSRFToken(); ?>">
                    <input type="hidden" name="action" value="resolve">
                    <input type="hidden" name="dispute_id" class="modal-dispute-id">
                    <div class="mb-3">
                        <label class="form-label">Resolution Notes</label>
                        <textarea name="resolution_notes" class="form-control" rows="4" required 
                            placeholder="Enter resolution details and outcome..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success"><i class="fas fa-check"></i> Resolve Dispute</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// Modal data population
document.addEventListener('DOMContentLoaded', function() {
    // Assign Modal
    var assignModal = document.getElementById('assignModal');
    if (assignModal) {
        assignModal.addEventListener('show.bs.modal', function (e) {
            var button = e.relatedTarget;
            var disputeId = button.getAttribute('data-dispute-id');
            assignModal.querySelector('.modal-dispute-id').value = disputeId;
        });
    }
    
    // Escalate Modal
    var escalateModal = document.getElementById('escalateModal');
    if (escalateModal) {
        escalateModal.addEventListener('show.bs.modal', function (e) {
            var button = e.relatedTarget;
            var disputeId = button.getAttribute('data-dispute-id');
            escalateModal.querySelector('.modal-dispute-id').value = disputeId;
        });
    }
    
    // Resolve Modal
    var resolveModal = document.getElementById('resolveModal');
    if (resolveModal) {
        resolveModal.addEventListener('show.bs.modal', function (e) {
            var button = e.relatedTarget;
            var disputeId = button.getAttribute('data-dispute-id');
            resolveModal.querySelector('.modal-dispute-id').value = disputeId;
        });
    }
});

// Auto-refresh stats every 30 seconds for real-time updates
let autoRefreshEnabled = true;

function refreshStats() {
    if (!autoRefreshEnabled) return;
    
    fetch(window.location.href, {
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
    .then(response => response.text())
    .then(html => {
        // Parse the response and update only the stats
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        
        // Update stat cards
        const statCards = document.querySelectorAll('.row.g-4 .card-title');
        const newStatCards = doc.querySelectorAll('.row.g-4 .card-title');
        
        statCards.forEach((card, index) => {
            if (newStatCards[index]) {
                card.textContent = newStatCards[index].textContent;
            }
        });
        
        console.log('Stats refreshed at ' + new Date().toLocaleTimeString());
    })
    .catch(error => console.error('Auto-refresh error:', error));
}

// Refresh every 30 seconds
setInterval(refreshStats, 30000);

// Toggle auto-refresh button
function toggleAutoRefresh() {
    autoRefreshEnabled = !autoRefreshEnabled;
    const btn = event.target;
    btn.textContent = autoRefreshEnabled ? 'Auto-Refresh: ON' : 'Auto-Refresh: OFF';
    btn.className = autoRefreshEnabled ? 'btn btn-success btn-sm' : 'btn btn-secondary btn-sm';
}

// Add auto-refresh toggle button to the page
document.addEventListener('DOMContentLoaded', function() {
    const header = document.querySelector('.card-header');
    if (header) {
        const refreshBtn = document.createElement('button');
        refreshBtn.textContent = 'Auto-Refresh: ON';
        refreshBtn.className = 'btn btn-success btn-sm ms-2';
        refreshBtn.onclick = toggleAutoRefresh;
        header.querySelector('.btn-group').after(refreshBtn);
    }
});
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>