/**
 * Account Dashboard Enhanced JavaScript
 * Adds full AJAX functionality to all account tabs
 */

// Orders Management
async function loadOrders(status = '', page = 1) {
    try {
        const url = new URL('/api/account/get-orders.php', window.location.origin);
        if (status) url.searchParams.append('status', status);
        url.searchParams.append('page', page);
        url.searchParams.append('per_page', 10);
        
        const response = await fetch(url);
        const data = await response.json();
        
        if (data.success) {
            displayOrders(data.orders, data.pagination);
        } else {
            showNotification(data.error || 'Failed to load orders', 'error');
        }
    } catch (error) {
        console.error('Load orders error:', error);
        showNotification('Error loading orders', 'error');
    }
}

function displayOrders(orders, pagination) {
    const container = document.querySelector('.orders-list');
    if (!container) return;
    
    if (orders.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>No orders found</p></div>';
        return;
    }
    
    container.innerHTML = orders.map(order => `
        <div class="order-item">
            <div class="order-info">
                <div class="order-number">Order #${order.id}</div>
                <div class="order-date">${order.formatted_date}</div>
                <div class="order-status status-${order.status.toLowerCase()}">${order.status}</div>
            </div>
            <div class="order-details">
                <div class="order-total">${order.formatted_total}</div>
                <div class="order-description">${order.item_count} item(s)</div>
            </div>
            <div class="order-actions">
                <button class="btn btn-sm" onclick="viewOrderDetails(${order.id})">View Details</button>
                <button class="btn btn-sm" onclick="downloadReceipt(${order.id})">Receipt</button>
                ${order.can_cancel ? `<button class="btn btn-sm btn-danger" onclick="cancelOrder(${order.id})">Cancel</button>` : ''}
            </div>
        </div>
    `).join('');
}

async function downloadReceipt(orderId) {
    window.open(`/api/account/get-order-receipt.php?order_id=${orderId}&format=html`, '_blank');
}

function viewOrderDetails(orderId) {
    window.location.href = `/order.php?id=${orderId}`;
}

// Session Management
async function loadSessions() {
    try {
        const response = await fetch('/api/account/get-sessions.php');
        const data = await response.json();
        
        if (data.success) {
            displaySessions(data.sessions);
        } else {
            showNotification(data.error || 'Failed to load sessions', 'error');
        }
    } catch (error) {
        console.error('Load sessions error:', error);
        showNotification('Error loading sessions', 'error');
    }
}

function displaySessions(sessions) {
    const container = document.getElementById('sessionsContainer');
    if (!container) return;
    
    if (sessions.length === 0) {
        container.innerHTML = '<p>No active sessions</p>';
        return;
    }
    
    container.innerHTML = sessions.map(session => `
        <div class="session-item" style="padding: 1rem; border: 1px solid #e5e7eb; border-radius: 8px; margin-bottom: 1rem;">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <div style="font-weight: 600;">${session.device_info.description}</div>
                    <div style="color: #6b7280; font-size: 0.875rem;">${session.ip_address} • ${session.location}</div>
                    <div style="color: #6b7280; font-size: 0.875rem;">${session.formatted_date}</div>
                    ${session.is_current ? '<span style="color: #10b981; font-weight: 600;">Current Session</span>' : ''}
                </div>
                ${!session.is_current ? `
                    <button class="btn btn-sm btn-danger" onclick="logoutSession(${session.id})">Logout</button>
                ` : ''}
            </div>
        </div>
    `).join('');
}

async function logoutSession(sessionId) {
    if (!confirm('Are you sure you want to logout this session?')) return;
    
    try {
        const response = await fetch('/api/account/logout-session.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
            },
            body: JSON.stringify({
                session_id: sessionId,
                csrf_token: document.querySelector('meta[name="csrf-token"]')?.content || ''
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification(data.message, 'success');
            loadSessions();
        } else {
            showNotification(data.error || 'Failed to logout session', 'error');
        }
    } catch (error) {
        console.error('Logout session error:', error);
        showNotification('Error logging out session', 'error');
    }
}

// Security Logs
async function loadSecurityLogs() {
    try {
        const response = await fetch('/api/account/get-security-logs.php');
        const data = await response.json();
        
        if (data.success) {
            displaySecurityLogs(data.logs);
        } else {
            showNotification(data.error || 'Failed to load security logs', 'error');
        }
    } catch (error) {
        console.error('Load security logs error:', error);
        showNotification('Error loading security logs', 'error');
    }
}

function displaySecurityLogs(logs) {
    const container = document.getElementById('securityLogsContainer');
    if (!container) return;
    
    if (logs.length === 0) {
        container.innerHTML = '<p>No security logs found</p>';
        return;
    }
    
    container.innerHTML = logs.map(log => `
        <div class="log-item" style="padding: 1rem; border-bottom: 1px solid #e5e7eb;">
            <div style="display: flex; justify-content: between; align-items: start;">
                <div style="flex: 1;">
                    <div style="font-weight: 600;">${log.icon} ${log.event_label}</div>
                    <div style="color: #6b7280; font-size: 0.875rem; margin-top: 0.25rem;">${log.formatted_date}</div>
                    <div style="color: #6b7280; font-size: 0.875rem;">IP: ${log.ip_address}</div>
                    ${log.details ? `<div style="color: #374151; margin-top: 0.5rem;">${log.details}</div>` : ''}
                </div>
                <span class="badge badge-${log.severity === 'critical' ? 'danger' : log.severity === 'warning' ? 'warning' : 'info'}">
                    ${log.severity}
                </span>
            </div>
        </div>
    `).join('');
}

// Password Change
async function submitPasswordChange(event) {
    event.preventDefault();
    
    const form = event.target;
    const formData = new FormData(form);
    
    try {
        const response = await fetch('/api/account/change-password.php', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification(data.message, 'success');
            form.reset();
            closePasswordModal();
        } else {
            showNotification(data.error || 'Failed to change password', 'error');
        }
    } catch (error) {
        console.error('Password change error:', error);
        showNotification('Error changing password', 'error');
    }
}

// Payment Methods Management
async function makeDefaultPaymentMethod(methodId) {
    try {
        const response = await fetch('/api/payment-methods/set-default.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
            },
            body: JSON.stringify({
                method_id: methodId,
                csrf_token: document.querySelector('meta[name="csrf-token"]')?.content || ''
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification('Default payment method updated', 'success');
            location.reload();
        } else {
            showNotification(data.error || 'Failed to update default payment method', 'error');
        }
    } catch (error) {
        console.error('Set default payment method error:', error);
        showNotification('Error updating payment method', 'error');
    }
}

async function deletePaymentMethod(methodId) {
    if (!confirm('Are you sure you want to remove this payment method?')) return;
    
    try {
        const response = await fetch('/api/payment-methods/delete.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
            },
            body: JSON.stringify({
                method_id: methodId,
                csrf_token: document.querySelector('meta[name="csrf-token"]')?.content || ''
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification('Payment method removed', 'success');
            location.reload();
        } else {
            showNotification(data.error || 'Failed to remove payment method', 'error');
        }
    } catch (error) {
        console.error('Delete payment method error:', error);
        showNotification('Error removing payment method', 'error');
    }
}

// Addresses Management
async function makeDefaultAddress(addressId) {
    try {
        const response = await fetch('/api/addresses/set-default.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
            },
            body: JSON.stringify({
                address_id: addressId,
                csrf_token: document.querySelector('meta[name="csrf-token"]')?.content || ''
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification('Default address updated', 'success');
            location.reload();
        } else {
            showNotification(data.error || 'Failed to update default address', 'error');
        }
    } catch (error) {
        console.error('Set default address error:', error);
        showNotification('Error updating address', 'error');
    }
}

async function deleteAddress(addressId) {
    if (!confirm('Are you sure you want to delete this address?')) return;
    
    try {
        const response = await fetch('/api/addresses/delete.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
            },
            body: JSON.stringify({
                address_id: addressId,
                csrf_token: document.querySelector('meta[name="csrf-token"]')?.content || ''
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification('Address deleted', 'success');
            location.reload();
        } else {
            showNotification(data.error || 'Failed to delete address', 'error');
        }
    } catch (error) {
        console.error('Delete address error:', error);
        showNotification('Error deleting address', 'error');
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    // Load dynamic content based on active tab
    const currentTab = new URLSearchParams(window.location.search).get('tab') || 'overview';
    
    // Auto-load data for specific tabs
    if (currentTab === 'orders') {
        // Orders already loaded server-side, but could add filters
        const filterButtons = document.querySelectorAll('.order-filter-btn');
        filterButtons.forEach(btn => {
            btn.addEventListener('click', function() {
                const status = this.dataset.status;
                loadOrders(status);
            });
        });
    }
    
    // Attach form handlers with defensive checks
    const passwordForm = document.getElementById('changePasswordForm');
    if (passwordForm) {
        passwordForm.addEventListener('submit', submitPasswordChange);
    } else {
        // Try to find it in modal when modal is shown
        const passwordModal = document.getElementById('passwordModal');
        if (passwordModal) {
            const observer = new MutationObserver(function(mutations) {
                const form = document.getElementById('changePasswordForm') || 
                             passwordModal.querySelector('form.modal-form');
                if (form && !form.dataset.listenerAttached) {
                    form.dataset.listenerAttached = 'true';
                    form.addEventListener('submit', submitPasswordChange);
                }
            });
            observer.observe(passwordModal, { childList: true, subtree: true });
        }
    }
    
    // Add loading states to buttons
    document.querySelectorAll('[data-loading]').forEach(btn => {
        btn.addEventListener('click', function() {
            this.disabled = true;
            this.innerHTML = '<span class="spinner"></span> Loading...';
        });
    });
    
    // Add global error handler to catch unhandled promise rejections
    window.addEventListener('unhandledrejection', function(event) {
        console.error('Unhandled promise rejection:', event.reason);
        if (typeof showNotification === 'function') {
            showNotification('An unexpected error occurred. Please try again.', 'error');
        }
    });
});

// Export functions to window for onclick handlers
if (typeof window !== 'undefined') {
    window.submitPasswordChange = submitPasswordChange;
    window.loadOrders = loadOrders;
    window.loadSessions = loadSessions;
    window.loadSecurityLogs = loadSecurityLogs;
    window.makeDefaultPaymentMethod = makeDefaultPaymentMethod;
    window.deletePaymentMethod = deletePaymentMethod;
    window.makeDefaultAddress = window.makeDefaultAddress || makeDefaultAddress;
    window.deleteAddress = window.deleteAddress || deleteAddress;
    window.downloadReceipt = downloadReceipt;
    window.viewOrderDetails = viewOrderDetails;
    window.logoutSession = logoutSession;
}
