<?php
/**
 * Stream Management Dashboard
 * Manage active, scheduled, and recent streams
 */

require_once __DIR__ . '/../includes/init.php';

// Require vendor login
Session::requireLogin();

// Load models
$vendor = new Vendor();

// Check if user is a vendor
$vendorInfo = $vendor->findByUserId(Session::getUserId());
if (!$vendorInfo || $vendorInfo['status'] !== 'approved') {
    redirect('/seller-onboarding.php');
}

$vendorId = $vendorInfo['id'];

$page_title = 'Stream Management - Seller Dashboard';
$meta_description = 'Manage your live streams, scheduled events, and stream recordings.';

include __DIR__ . '/../templates/seller-header.php';
?>

<style>
.streams-dashboard {
    max-width: 1400px;
    margin: 0 auto;
    padding: 20px;
}

.page-header {
    margin-bottom: 30px;
}

.page-header h1 {
    font-size: 28px;
    margin-bottom: 10px;
    color: #1f2937;
}

.page-header p {
    color: #6b7280;
    font-size: 16px;
}

.section {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 12px;
    padding: 24px;
    margin-bottom: 24px;
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 12px;
    border-bottom: 2px solid #e5e7eb;
}

.section-header h2 {
    font-size: 20px;
    color: #1f2937;
    font-weight: 600;
}

.section-badge {
    background: #dc2626;
    color: white;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.section-badge.scheduled {
    background: #3b82f6;
}

.section-badge.recent {
    background: #10b981;
}

.empty-state {
    text-align: center;
    padding: 40px 20px;
    color: #6b7280;
}

.empty-state-icon {
    font-size: 48px;
    margin-bottom: 16px;
}

.empty-state h3 {
    font-size: 18px;
    color: #374151;
    margin-bottom: 8px;
}

.stream-card {
    background: #f9fafb;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 16px;
    transition: all 0.2s;
}

.stream-card:hover {
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.stream-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;
}

.stream-title {
    font-size: 18px;
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 4px;
}

.stream-status {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}

.stream-status.live {
    background: #fef2f2;
    color: #dc2626;
}

.stream-status.scheduled {
    background: #eff6ff;
    color: #3b82f6;
}

.stream-status.archived {
    background: #f0fdf4;
    color: #10b981;
}

.status-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: currentColor;
}

.stream-status.live .status-dot {
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
}

.stream-meta {
    display: flex;
    gap: 20px;
    margin-bottom: 12px;
    font-size: 14px;
    color: #6b7280;
}

.stream-meta-item {
    display: flex;
    align-items: center;
    gap: 6px;
}

.stream-stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
    gap: 12px;
    padding: 12px;
    background: white;
    border-radius: 6px;
    margin-bottom: 12px;
}

.stat-item {
    text-align: center;
}

.stat-value {
    font-size: 18px;
    font-weight: 700;
    color: #1f2937;
}

.stat-label {
    font-size: 11px;
    color: #6b7280;
    margin-top: 2px;
}

.stream-actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
}

.btn {
    padding: 8px 16px;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}

.btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}

.btn-primary {
    background: #dc2626;
    color: white;
}

.btn-primary:hover {
    background: #b91c1c;
}

.btn-secondary {
    background: #6b7280;
    color: white;
}

.btn-secondary:hover {
    background: #4b5563;
}

.btn-success {
    background: #10b981;
    color: white;
}

.btn-success:hover {
    background: #059669;
}

.btn-info {
    background: #3b82f6;
    color: white;
}

.btn-info:hover {
    background: #2563eb;
}

.btn-outline {
    background: white;
    color: #374151;
    border: 1px solid #d1d5db;
}

.btn-outline:hover {
    background: #f9fafb;
}

.btn-danger {
    background: #ef4444;
    color: white;
}

.btn-danger:hover {
    background: #dc2626;
}

@media (max-width: 768px) {
    .stream-header {
        flex-direction: column;
        gap: 12px;
    }
    
    .stream-stats {
        grid-template-columns: repeat(2, 1fr);
    }
    
    .stream-actions {
        flex-direction: column;
    }
    
    .btn {
        width: 100%;
        justify-content: center;
    }
}
</style>

<div class="streams-dashboard">
    <div class="page-header">
        <h1>🎥 Stream Management</h1>
        <p>Manage your live streams, scheduled events, and recordings</p>
    </div>

    <!-- Active Streams Section -->
    <div class="section">
        <div class="section-header">
            <h2>🔴 Active Streams</h2>
            <span class="section-badge" id="activeCount">0</span>
        </div>
        <div id="activeStreams">
            <div class="empty-state">
                <div class="empty-state-icon">📡</div>
                <h3>No Active Streams</h3>
                <p>You don't have any live streams at the moment</p>
            </div>
        </div>
    </div>

    <!-- Scheduled Streams Section -->
    <div class="section">
        <div class="section-header">
            <h2>📅 Scheduled Streams</h2>
            <span class="section-badge scheduled" id="scheduledCount">0</span>
        </div>
        <div id="scheduledStreams">
            <div class="empty-state">
                <div class="empty-state-icon">📅</div>
                <h3>No Scheduled Streams</h3>
                <p>Schedule your next live stream to notify your followers</p>
            </div>
        </div>
    </div>

    <!-- Recent Streams Section -->
    <div class="section">
        <div class="section-header">
            <h2>📼 Recent Streams</h2>
            <span class="section-badge recent" id="recentCount">0</span>
        </div>
        <div id="recentStreams">
            <div class="empty-state">
                <div class="empty-state-icon">📼</div>
                <h3>No Recent Streams</h3>
                <p>Your past streams will appear here</p>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); z-index: 9999; align-items: center; justify-content: center;">
    <div style="background: white; border-radius: 12px; padding: 30px; max-width: 500px; width: 90%;">
        <h2 style="margin-bottom: 16px; color: #1f2937;">Delete Stream Recording?</h2>
        <p style="margin-bottom: 24px; color: #6b7280;">
            This will permanently delete the stream recording. This action cannot be undone.
        </p>
        <div style="display: flex; gap: 10px; justify-content: flex-end;">
            <button onclick="closeDeleteModal()" class="btn btn-outline">
                Cancel
            </button>
            <button onclick="confirmDelete()" class="btn btn-danger">
                Delete Recording
            </button>
        </div>
    </div>
</div>

<!-- Cancel Stream Modal -->
<div id="cancelModal" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); z-index: 9999; align-items: center; justify-content: center;">
    <div style="background: white; border-radius: 12px; padding: 30px; max-width: 500px; width: 90%;">
        <h2 style="margin-bottom: 16px; color: #1f2937;">Cancel Scheduled Stream?</h2>
        <p style="margin-bottom: 24px; color: #6b7280;">
            This will cancel the scheduled stream. Followers who were notified will not receive an update.
        </p>
        <div style="display: flex; gap: 10px; justify-content: flex-end;">
            <button onclick="closeCancelModal()" class="btn btn-outline">
                Keep Stream
            </button>
            <button onclick="confirmCancel()" class="btn btn-danger">
                Cancel Stream
            </button>
        </div>
    </div>
</div>

<script>
let streamToDelete = null;
let streamToCancel = null;

// Load all streams on page load
document.addEventListener('DOMContentLoaded', function() {
    loadActiveStreams();
    loadScheduledStreams();
    loadRecentStreams();
    
    // Refresh active streams every 10 seconds
    setInterval(loadActiveStreams, 10000);
});

function loadActiveStreams() {
    fetch('/api/streams/list.php?type=live')
        .then(response => response.json())
        .then(data => {
            if (data.success && data.streams && data.streams.length > 0) {
                renderActiveStreams(data.streams);
            } else {
                document.getElementById('activeStreams').innerHTML = `
                    <div class="empty-state">
                        <div class="empty-state-icon">📡</div>
                        <h3>No Active Streams</h3>
                        <p>You don't have any live streams at the moment</p>
                    </div>
                `;
            }
            document.getElementById('activeCount').textContent = data.streams?.length || 0;
        })
        .catch(error => {
            console.error('Error loading active streams:', error);
        });
}

function loadScheduledStreams() {
    fetch('/api/streams/list.php?type=scheduled')
        .then(response => response.json())
        .then(data => {
            if (data.success && data.streams && data.streams.length > 0) {
                renderScheduledStreams(data.streams);
            } else {
                document.getElementById('scheduledStreams').innerHTML = `
                    <div class="empty-state">
                        <div class="empty-state-icon">📅</div>
                        <h3>No Scheduled Streams</h3>
                        <p>Schedule your next live stream to notify your followers</p>
                    </div>
                `;
            }
            document.getElementById('scheduledCount').textContent = data.streams?.length || 0;
        })
        .catch(error => {
            console.error('Error loading scheduled streams:', error);
        });
}

function loadRecentStreams() {
    fetch('/api/streams/list.php?type=archived')
        .then(response => response.json())
        .then(data => {
            if (data.success && data.streams && data.streams.length > 0) {
                renderRecentStreams(data.streams);
            } else {
                document.getElementById('recentStreams').innerHTML = `
                    <div class="empty-state">
                        <div class="empty-state-icon">📼</div>
                        <h3>No Recent Streams</h3>
                        <p>Your past streams will appear here</p>
                    </div>
                `;
            }
            document.getElementById('recentCount').textContent = data.streams?.length || 0;
        })
        .catch(error => {
            console.error('Error loading recent streams:', error);
        });
}

function renderActiveStreams(streams) {
    const html = streams.map(stream => {
        const duration = calculateDuration(stream.started_at);
        
        return `
            <div class="stream-card">
                <div class="stream-header">
                    <div>
                        <h3 class="stream-title">${escapeHtml(stream.title)}</h3>
                        <span class="stream-status live">
                            <span class="status-dot"></span>
                            LIVE
                        </span>
                    </div>
                </div>
                
                <div class="stream-meta">
                    <div class="stream-meta-item">
                        <span>⏱️</span>
                        <span>${duration}</span>
                    </div>
                    <div class="stream-meta-item">
                        <span>👥</span>
                        <span>${stream.viewer_count || 0} viewers</span>
                    </div>
                </div>
                
                <div class="stream-stats">
                    <div class="stat-item">
                        <div class="stat-value">${stream.viewer_count || 0}</div>
                        <div class="stat-label">Viewers</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">${stream.like_count || 0}</div>
                        <div class="stat-label">Likes</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">${stream.comment_count || 0}</div>
                        <div class="stat-label">Comments</div>
                    </div>
                </div>
                
                <div class="stream-actions">
                    <a href="/seller/stream-interface.php?stream_id=${stream.id}" class="btn btn-primary">
                        🎥 View Stream
                    </a>
                    <button onclick="stopStream(${stream.id})" class="btn btn-secondary">
                        ⏹️ Stop Stream
                    </button>
                </div>
            </div>
        `;
    }).join('');
    
    document.getElementById('activeStreams').innerHTML = html;
}

function renderScheduledStreams(streams) {
    const html = streams.map(stream => {
        const scheduledDate = new Date(stream.scheduled_at);
        const timeUntil = getTimeUntil(scheduledDate);
        
        return `
            <div class="stream-card">
                <div class="stream-header">
                    <div>
                        <h3 class="stream-title">${escapeHtml(stream.title)}</h3>
                        <span class="stream-status scheduled">
                            <span class="status-dot"></span>
                            SCHEDULED
                        </span>
                    </div>
                </div>
                
                <div class="stream-meta">
                    <div class="stream-meta-item">
                        <span>📅</span>
                        <span>${formatDate(scheduledDate)}</span>
                    </div>
                    <div class="stream-meta-item">
                        <span>⏰</span>
                        <span>${timeUntil}</span>
                    </div>
                </div>
                
                ${stream.description ? `<p style="color: #6b7280; margin-bottom: 12px;">${escapeHtml(stream.description)}</p>` : ''}
                
                <div class="stream-actions">
                    <button onclick="startScheduledStream(${stream.id})" class="btn btn-success">
                        ▶️ Start Now
                    </button>
                    <button onclick="editStream(${stream.id})" class="btn btn-info">
                        ✏️ Edit
                    </button>
                    <button onclick="cancelStream(${stream.id})" class="btn btn-outline">
                        ❌ Cancel
                    </button>
                </div>
            </div>
        `;
    }).join('');
    
    document.getElementById('scheduledStreams').innerHTML = html;
}

function renderRecentStreams(streams) {
    const html = streams.map(stream => {
        const endedDate = new Date(stream.ended_at);
        const duration = stream.started_at && stream.ended_at ? 
            calculateDurationBetween(stream.started_at, stream.ended_at) : 'N/A';
        
        return `
            <div class="stream-card">
                <div class="stream-header">
                    <div>
                        <h3 class="stream-title">${escapeHtml(stream.title)}</h3>
                        <span class="stream-status archived">
                            <span class="status-dot"></span>
                            ARCHIVED
                        </span>
                    </div>
                </div>
                
                <div class="stream-meta">
                    <div class="stream-meta-item">
                        <span>📅</span>
                        <span>${formatDate(endedDate)}</span>
                    </div>
                    <div class="stream-meta-item">
                        <span>⏱️</span>
                        <span>${duration}</span>
                    </div>
                </div>
                
                <div class="stream-stats">
                    <div class="stat-item">
                        <div class="stat-value">${stream.viewer_count || 0}</div>
                        <div class="stat-label">Total Viewers</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">${stream.like_count || 0}</div>
                        <div class="stat-label">Likes</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">${stream.comment_count || 0}</div>
                        <div class="stat-label">Comments</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-value">$${(stream.total_revenue || 0).toFixed(2)}</div>
                        <div class="stat-label">Revenue</div>
                    </div>
                </div>
                
                <div class="stream-actions">
                    ${stream.video_path ? `
                        <button onclick="watchRecording(${stream.id})" class="btn btn-success">
                            ▶️ Watch Recording
                        </button>
                    ` : ''}
                    <button onclick="viewStats(${stream.id})" class="btn btn-info">
                        📊 View Stats
                    </button>
                    <button onclick="deleteStream(${stream.id})" class="btn btn-danger">
                        🗑️ Delete
                    </button>
                </div>
            </div>
        `;
    }).join('');
    
    document.getElementById('recentStreams').innerHTML = html;
}

function stopStream(streamId) {
    if (!streamId) {
        showNotification('Invalid stream ID', 'error');
        return;
    }
    
    // Show confirmation modal with options
    showStopStreamModal(streamId);
}

// Add modal for stopping stream with save/delete options
let streamToStop = null;

function showStopStreamModal(streamId) {
    streamToStop = streamId;
    
    // Create modal if it doesn't exist
    let modal = document.getElementById('stopStreamModal');
    if (!modal) {
        modal = document.createElement('div');
        modal.id = 'stopStreamModal';
        modal.style.cssText = 'display: flex; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); z-index: 9999; align-items: center; justify-content: center;';
        modal.innerHTML = `
            <div style="background: white; border-radius: 12px; padding: 30px; max-width: 500px; width: 90%;">
                <h2 style="margin-bottom: 20px; color: #1f2937;">Stop Live Stream?</h2>
                <p style="margin-bottom: 20px; color: #6b7280;">
                    This will end the live stream. Would you like to save the recording for viewers to watch later?
                </p>
                <div style="display: flex; gap: 10px; margin-bottom: 10px;">
                    <button onclick="confirmStopStream('save')" style="flex: 1; padding: 12px; background: #10b981; color: white; border: none; border-radius: 6px; font-weight: 600; cursor: pointer;">
                        💾 Save & Stop
                    </button>
                    <button onclick="confirmStopStream('delete')" style="flex: 1; padding: 12px; background: #dc2626; color: white; border: none; border-radius: 6px; font-weight: 600; cursor: pointer;">
                        🗑️ Delete & Stop
                    </button>
                </div>
                <button onclick="closeStopStreamModal()" style="width: 100%; padding: 12px; background: white; color: #6b7280; border: 1px solid #d1d5db; border-radius: 6px; cursor: pointer;">
                    Cancel
                </button>
            </div>
        `;
        document.body.appendChild(modal);
    } else {
        modal.style.display = 'flex';
    }
}

function closeStopStreamModal() {
    const modal = document.getElementById('stopStreamModal');
    if (modal) {
        modal.style.display = 'none';
    }
    streamToStop = null;
}

function confirmStopStream(action) {
    if (!streamToStop) return;
    
    // Show loading notification
    showNotification('Stopping stream...', 'info');
    
    // Call the end stream API
    fetch('/api/streams/end.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            stream_id: streamToStop,
            action: action
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            closeStopStreamModal();
            if (action === 'save') {
                showNotification('✅ Stream stopped and saved successfully!', 'success');
            } else {
                showNotification('✅ Stream stopped successfully!', 'success');
            }
            // Reload the page to update the stream list
            setTimeout(() => {
                window.location.reload();
            }, 1500);
        } else {
            showNotification('Error: ' + data.error, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Failed to stop stream. Please try again.', 'error');
    });
}

function startScheduledStream(streamId) {
    window.location.href = `/seller/stream-interface.php?stream_id=${streamId}`;
}

function editStream(streamId) {
    // TODO: Implement edit modal or redirect to edit page
    alert('Edit functionality will be implemented soon');
}

function cancelStream(streamId) {
    streamToCancel = streamId;
    document.getElementById('cancelModal').style.display = 'flex';
}

function closeCancelModal() {
    streamToCancel = null;
    document.getElementById('cancelModal').style.display = 'none';
}

function confirmCancel() {
    if (!streamToCancel) return;
    
    fetch('/api/streams/cancel.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            stream_id: streamToCancel
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification('Stream cancelled successfully', 'success');
            closeCancelModal();
            loadScheduledStreams();
        } else {
            showNotification('Error: ' + data.error, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Failed to cancel stream', 'error');
    });
}

function deleteStream(streamId) {
    streamToDelete = streamId;
    document.getElementById('deleteModal').style.display = 'flex';
}

function closeDeleteModal() {
    streamToDelete = null;
    document.getElementById('deleteModal').style.display = 'none';
}

function confirmDelete() {
    if (!streamToDelete) return;
    
    fetch('/api/streams/delete.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            stream_id: streamToDelete
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification('Stream deleted successfully', 'success');
            closeDeleteModal();
            loadRecentStreams();
        } else {
            showNotification('Error: ' + data.error, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Failed to delete stream', 'error');
    });
}

function watchRecording(streamId) {
    window.location.href = `/watch?stream_id=${streamId}`;
}

function viewStats(streamId) {
    window.location.href = `/seller/analytics.php?stream_id=${streamId}`;
}

function calculateDuration(startTime) {
    if (!startTime) return 'N/A';
    
    const start = new Date(startTime);
    const now = new Date();
    const diff = Math.floor((now - start) / 1000);
    
    const hours = Math.floor(diff / 3600);
    const minutes = Math.floor((diff % 3600) / 60);
    const seconds = diff % 60;
    
    if (hours > 0) {
        return `${hours}h ${minutes}m`;
    } else if (minutes > 0) {
        return `${minutes}m ${seconds}s`;
    } else {
        return `${seconds}s`;
    }
}

function calculateDurationBetween(start, end) {
    if (!start || !end) return 'N/A';
    
    const startTime = new Date(start);
    const endTime = new Date(end);
    const diff = Math.floor((endTime - startTime) / 1000);
    
    const hours = Math.floor(diff / 3600);
    const minutes = Math.floor((diff % 3600) / 60);
    
    if (hours > 0) {
        return `${hours}h ${minutes}m`;
    } else {
        return `${minutes}m`;
    }
}

function getTimeUntil(futureDate) {
    const now = new Date();
    const diff = Math.floor((futureDate - now) / 1000);
    
    if (diff < 0) return 'Starting soon';
    
    const days = Math.floor(diff / 86400);
    const hours = Math.floor((diff % 86400) / 3600);
    const minutes = Math.floor((diff % 3600) / 60);
    
    if (days > 0) {
        return `in ${days}d ${hours}h`;
    } else if (hours > 0) {
        return `in ${hours}h ${minutes}m`;
    } else {
        return `in ${minutes}m`;
    }
}

function formatDate(date) {
    return date.toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'error' ? '#ef4444' : type === 'success' ? '#10b981' : '#3b82f6'};
        color: white;
        padding: 16px 24px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 10000;
        max-width: 400px;
        font-weight: 600;
    `;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.transition = 'opacity 0.3s';
        notification.style.opacity = '0';
        setTimeout(() => notification.remove(), 300);
    }, 5000);
}
</script>

<?php
include __DIR__ . '/../templates/footer.php';
?>
