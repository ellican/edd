<?php
/**
 * Product Inquiry Messaging Center
 * Buyer-Seller product inquiry conversations
 */

require_once __DIR__ . '/includes/init.php';
require_once __DIR__ . '/includes/auth.php';

// Check if user is logged in
if (!Session::isLoggedIn()) {
    header('Location: /login.php?redirect=/messages.php');
    exit;
}

$userId = Session::getUserId();
$userRole = Session::getUserRole();

$page_title = 'Messages - FezaMarket';
$meta_description = 'View and send messages to buyers, sellers, and FezaMarket support.';

includeHeader($page_title);
?>

<div class="messages-page">
    <div class="container">
        <div class="messages-container">
            <!-- Sidebar -->
            <div class="messages-sidebar">
                <div class="sidebar-header">
                    <h2>Messages</h2>
                    <span class="unread-badge" id="totalUnreadBadge" style="display: none;">0</span>
                </div>
                
                <div class="message-filters">
                    <button class="filter-btn active" data-filter="all">All</button>
                    <button class="filter-btn" data-filter="unread">Unread</button>
                    <?php if ($userRole === 'seller' || $userRole === 'vendor'): ?>
                        <button class="filter-btn" data-filter="buyers">Buyers</button>
                    <?php else: ?>
                        <button class="filter-btn" data-filter="sellers">Sellers</button>
                    <?php endif; ?>
                </div>
                
                <div class="message-list" id="conversationList">
                    <div class="loading-state">
                        <i class="fas fa-spinner fa-spin"></i>
                        <p>Loading conversations...</p>
                    </div>
                </div>
            </div>
            
            <!-- Message Content Area -->
            <div class="messages-content" id="messagesContent">
                <div class="empty-state-large" id="emptyState">
                    <div class="empty-icon-large">
                        <i class="far fa-comments"></i>
                    </div>
                    <h3>Welcome to your Message Center</h3>
                    <p>Select a conversation to view messages or start a new conversation from a product page.</p>
                </div>
                
                <!-- Active Thread View (hidden by default) -->
                <div class="thread-view" id="threadView" style="display: none;">
                    <div class="thread-header">
                        <div class="product-info">
                            <img id="threadProductImage" src="" alt="Product">
                            <div>
                                <h3 id="threadProductName"></h3>
                                <a id="threadProductLink" href="#" target="_blank">View Product</a>
                            </div>
                        </div>
                        <div class="thread-participant">
                            <span id="threadParticipantName"></span>
                        </div>
                    </div>
                    
                    <div class="thread-messages" id="threadMessages">
                        <!-- Messages will be loaded here -->
                    </div>
                    
                    <div class="thread-input">
                        <form id="sendMessageForm" enctype="multipart/form-data">
                            <input type="hidden" id="activeThreadId" name="thread_id">
                            <div class="input-group">
                                <textarea 
                                    id="messageInput" 
                                    name="message" 
                                    placeholder="Type your message..." 
                                    rows="2"
                                    maxlength="5000"
                                    required
                                ></textarea>
                                <div class="input-actions">
                                    <label for="fileInput" class="file-attach-btn" title="Attach image or PDF">
                                        <i class="fas fa-paperclip"></i>
                                        <input type="file" id="fileInput" name="attachment" accept="image/*,.pdf" style="display: none;">
                                    </label>
                                    <button type="submit" class="send-btn" id="sendBtn">
                                        <i class="fas fa-paper-plane"></i> Send
                                    </button>
                                </div>
                            </div>
                            <div id="filePreview" style="display: none; margin-top: 10px;">
                                <small id="fileName"></small>
                                <button type="button" onclick="clearFileInput()" class="btn-sm">Remove</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.messages-page {
    background-color: #f8f9fa;
    min-height: 80vh;
    padding: 30px 20px;
}

.container {
    max-width: 1400px;
    margin: 0 auto;
}

.messages-container {
    display: grid;
    grid-template-columns: 350px 1fr;
    gap: 0;
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
    min-height: 600px;
    max-height: 85vh;
}

.messages-sidebar {
    background: #f8f9fa;
    border-right: 1px solid #e0e0e0;
    display: flex;
    flex-direction: column;
}

.sidebar-header {
    padding: 25px 20px;
    background: white;
    border-bottom: 1px solid #e0e0e0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.sidebar-header h2 {
    font-size: 1.5rem;
    font-weight: 700;
    color: #333;
}

.unread-badge {
    background: #f44336;
    color: white;
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 0.85rem;
    font-weight: 600;
}

.message-filters {
    padding: 15px 20px;
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    border-bottom: 1px solid #e0e0e0;
}

.filter-btn {
    padding: 8px 16px;
    border: 1px solid #e0e0e0;
    background: white;
    border-radius: 20px;
    font-size: 0.9rem;
    cursor: pointer;
    transition: all 0.2s ease;
}

.filter-btn:hover,
.filter-btn.active {
    background: #4285f4;
    color: white;
    border-color: #4285f4;
}

.message-list {
    flex: 1;
    overflow-y: auto;
}

.conversation-item {
    padding: 15px 20px;
    border-bottom: 1px solid #e0e0e0;
    cursor: pointer;
    transition: background 0.2s ease;
    display: flex;
    gap: 12px;
    align-items: flex-start;
}

.conversation-item:hover {
    background: white;
}

.conversation-item.active {
    background: #e3f2fd;
}

.conversation-item.unread {
    background: #f5f5f5;
}

.conversation-item .product-thumb {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 6px;
    flex-shrink: 0;
}

.conversation-item .conversation-info {
    flex: 1;
    min-width: 0;
}

.conversation-item .conversation-header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 5px;
}

.conversation-item .product-name {
    font-weight: 600;
    font-size: 0.9rem;
    color: #333;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.conversation-item .timestamp {
    font-size: 0.75rem;
    color: #999;
    flex-shrink: 0;
}

.conversation-item .participant-name {
    font-size: 0.85rem;
    color: #666;
}

.conversation-item .last-message {
    font-size: 0.85rem;
    color: #999;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    margin-top: 4px;
}

.conversation-item .unread-indicator {
    width: 10px;
    height: 10px;
    background: #4285f4;
    border-radius: 50%;
    margin-left: 5px;
}

.loading-state,
.empty-state {
    padding: 60px 20px;
    text-align: center;
    color: #999;
}

.loading-state i {
    font-size: 2rem;
    margin-bottom: 10px;
}

.messages-content {
    display: flex;
    flex-direction: column;
    position: relative;
    overflow: hidden;
}

.empty-state-large {
    padding: 60px 40px;
    text-align: center;
    margin: auto;
}

.empty-icon-large {
    font-size: 5rem;
    color: #ccc;
    margin-bottom: 25px;
}

.empty-state-large h3 {
    font-size: 2rem;
    font-weight: 700;
    margin-bottom: 15px;
    color: #333;
}

.empty-state-large p {
    font-size: 1.1rem;
    color: #666;
    line-height: 1.6;
}

/* Thread View */
.thread-view {
    display: flex;
    flex-direction: column;
    height: 100%;
}

.thread-header {
    padding: 20px;
    border-bottom: 2px solid #e0e0e0;
    background: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.product-info {
    display: flex;
    gap: 15px;
    align-items: center;
}

.product-info img {
    width: 60px;
    height: 60px;
    object-fit: cover;
    border-radius: 8px;
}

.product-info h3 {
    font-size: 1.1rem;
    font-weight: 600;
    margin-bottom: 5px;
    color: #333;
}

.product-info a {
    font-size: 0.85rem;
    color: #4285f4;
    text-decoration: none;
}

.product-info a:hover {
    text-decoration: underline;
}

.thread-participant {
    font-size: 0.9rem;
    color: #666;
}

.thread-messages {
    flex: 1;
    overflow-y: auto;
    padding: 20px;
    background: #f5f7fa;
}

.message-bubble {
    margin-bottom: 15px;
    display: flex;
    flex-direction: column;
}

.message-bubble.sent {
    align-items: flex-end;
}

.message-bubble.received {
    align-items: flex-start;
}

.message-content {
    max-width: 70%;
    padding: 12px 16px;
    border-radius: 18px;
    word-wrap: break-word;
}

.message-bubble.sent .message-content {
    background: #4285f4;
    color: white;
    border-bottom-right-radius: 4px;
}

.message-bubble.received .message-content {
    background: white;
    color: #333;
    border-bottom-left-radius: 4px;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.message-sender {
    font-size: 0.75rem;
    font-weight: 600;
    margin-bottom: 4px;
    color: #666;
}

.message-text {
    line-height: 1.4;
}

.message-attachment {
    margin-top: 8px;
}

.message-attachment img {
    max-width: 200px;
    border-radius: 8px;
    cursor: pointer;
}

.message-attachment a {
    color: inherit;
    text-decoration: underline;
}

.message-timestamp {
    font-size: 0.7rem;
    margin-top: 4px;
    opacity: 0.7;
}

.message-flagged {
    border-left: 3px solid #f44336;
}

.thread-input {
    padding: 20px;
    background: white;
    border-top: 2px solid #e0e0e0;
}

.input-group {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

#messageInput {
    width: 100%;
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 0.95rem;
    font-family: inherit;
    resize: none;
}

#messageInput:focus {
    outline: none;
    border-color: #4285f4;
}

.input-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.file-attach-btn {
    cursor: pointer;
    padding: 8px 12px;
    border-radius: 6px;
    transition: background 0.2s;
}

.file-attach-btn:hover {
    background: #f5f5f5;
}

.send-btn {
    background: #4285f4;
    color: white;
    padding: 10px 24px;
    border: none;
    border-radius: 6px;
    font-size: 0.95rem;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
    display: flex;
    align-items: center;
    gap: 8px;
}

.send-btn:hover {
    background: #3367d6;
}

.send-btn:disabled {
    background: #ccc;
    cursor: not-allowed;
}

.btn {
    padding: 10px 20px;
    border-radius: 6px;
    font-size: 0.95rem;
    font-weight: 600;
    text-decoration: none;
    display: inline-block;
    transition: all 0.3s ease;
    border: none;
    cursor: pointer;
}

.btn-sm {
    padding: 6px 12px;
    font-size: 0.85rem;
}

.btn-primary {
    background: #4285f4;
    color: white;
}

.btn-primary:hover {
    background: #3367d6;
}

@media (max-width: 768px) {
    .messages-container {
        grid-template-columns: 1fr;
        max-height: none;
    }
    
    .messages-sidebar {
        border-right: none;
        border-bottom: 1px solid #e0e0e0;
    }
    
    .message-content {
        max-width: 85%;
    }
}
</style>

<script>
// Global variables
let currentFilter = 'all';
let currentThreadId = null;
let pollingInterval = null;
const userRole = '<?php echo $userRole; ?>';

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    loadConversations();
    setupFilterButtons();
    setupMessageForm();
    setupFileInput();
    
    // Poll for new messages every 10 seconds
    pollingInterval = setInterval(() => {
        if (currentThreadId) {
            loadThreadMessages(currentThreadId, false);
        }
        updateUnreadCount();
    }, 10000);
});

// Filter buttons
function setupFilterButtons() {
    const filterButtons = document.querySelectorAll('.filter-btn');
    filterButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            filterButtons.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            currentFilter = this.dataset.filter;
            loadConversations();
        });
    });
}

// Load conversations
async function loadConversations() {
    const conversationList = document.getElementById('conversationList');
    
    try {
        const response = await fetch(`/api/messages/conversations.php?filter=${currentFilter}`);
        const data = await response.json();
        
        if (data.success && data.conversations.length > 0) {
            conversationList.innerHTML = data.conversations.map(conv => createConversationHTML(conv)).join('');
            
            // Add click handlers
            document.querySelectorAll('.conversation-item').forEach(item => {
                item.addEventListener('click', function() {
                    const threadId = this.dataset.threadId;
                    loadThread(threadId);
                });
            });
        } else {
            conversationList.innerHTML = `
                <div class="empty-state">
                    <i class="far fa-envelope"></i>
                    <p>No conversations yet</p>
                </div>
            `;
        }
    } catch (error) {
        console.error('Error loading conversations:', error);
        conversationList.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-exclamation-triangle"></i>
                <p>Error loading conversations</p>
            </div>
        `;
    }
}

// Create conversation HTML
function createConversationHTML(conv) {
    const unreadBadge = conv.unread_count > 0 ? `<span class="unread-indicator"></span>` : '';
    const unreadClass = conv.unread_count > 0 ? 'unread' : '';
    const activeClass = conv.thread_id == currentThreadId ? 'active' : '';
    
    const participantName = userRole === 'seller' || userRole === 'vendor' 
        ? (conv.buyer_username || `${conv.buyer_first_name} ${conv.buyer_last_name}`)
        : (conv.seller_username || `${conv.seller_first_name} ${conv.seller_last_name}`);
    
    const productImage = conv.product_image || '/assets/images/placeholder.png';
    const lastMessage = conv.last_message ? truncate(conv.last_message, 50) : 'No messages yet';
    const timestamp = formatTimestamp(conv.last_message_at || conv.created_at);
    
    return `
        <div class="conversation-item ${unreadClass} ${activeClass}" data-thread-id="${conv.thread_id}">
            <img src="${escapeHtml(productImage)}" alt="Product" class="product-thumb">
            <div class="conversation-info">
                <div class="conversation-header">
                    <span class="product-name">${escapeHtml(conv.product_name)}</span>
                    <span class="timestamp">${timestamp}</span>
                </div>
                <div class="participant-name">${escapeHtml(participantName)}</div>
                <div class="last-message">${escapeHtml(lastMessage)} ${unreadBadge}</div>
            </div>
        </div>
    `;
}

// Load thread
async function loadThread(threadId) {
    currentThreadId = threadId;
    
    // Update active state in sidebar
    document.querySelectorAll('.conversation-item').forEach(item => {
        item.classList.remove('active');
        if (item.dataset.threadId == threadId) {
            item.classList.add('active');
        }
    });
    
    // Show thread view, hide empty state
    document.getElementById('emptyState').style.display = 'none';
    document.getElementById('threadView').style.display = 'flex';
    document.getElementById('activeThreadId').value = threadId;
    
    // Load messages
    loadThreadMessages(threadId, true);
}

// Load thread messages
async function loadThreadMessages(threadId, scrollToBottom = true) {
    try {
        const response = await fetch(`/api/messages/thread.php?thread_id=${threadId}`);
        const data = await response.json();
        
        if (data.success) {
            // Update thread header
            const product = data.product;
            document.getElementById('threadProductImage').src = product.image || '/assets/images/placeholder.png';
            document.getElementById('threadProductName').textContent = product.name;
            document.getElementById('threadProductLink').href = `/product/${product.slug || product.id}`;
            
            // Determine participant name
            const thread = data.thread;
            const participantId = thread.buyer_id == <?php echo $userId; ?> ? thread.seller_id : thread.buyer_id;
            document.getElementById('threadParticipantName').textContent = 'Chat about this product';
            
            // Render messages
            const messagesContainer = document.getElementById('threadMessages');
            messagesContainer.innerHTML = data.messages.map(msg => createMessageHTML(msg)).join('');
            
            if (scrollToBottom) {
                messagesContainer.scrollTop = messagesContainer.scrollHeight;
            }
            
            // Reload conversations to update unread count
            loadConversations();
        }
    } catch (error) {
        console.error('Error loading thread messages:', error);
    }
}

// Create message HTML
function createMessageHTML(msg) {
    const isSent = msg.sender_id == <?php echo $userId; ?>;
    const bubbleClass = isSent ? 'sent' : 'received';
    const senderName = msg.sender_username || `${msg.sender_first_name} ${msg.sender_last_name}`;
    
    let attachmentHTML = '';
    if (msg.attachment_path) {
        if (msg.attachment_type && msg.attachment_type.startsWith('image/')) {
            attachmentHTML = `
                <div class="message-attachment">
                    <img src="${escapeHtml(msg.attachment_path)}" alt="Attachment" onclick="window.open('${escapeHtml(msg.attachment_path)}', '_blank')">
                </div>
            `;
        } else {
            attachmentHTML = `
                <div class="message-attachment">
                    <a href="${escapeHtml(msg.attachment_path)}" target="_blank">
                        <i class="fas fa-file"></i> View Attachment
                    </a>
                </div>
            `;
        }
    }
    
    const flaggedClass = msg.flagged ? 'message-flagged' : '';
    
    return `
        <div class="message-bubble ${bubbleClass}">
            ${!isSent ? `<div class="message-sender">${escapeHtml(senderName)}</div>` : ''}
            <div class="message-content ${flaggedClass}">
                <div class="message-text">${escapeHtml(msg.message_text)}</div>
                ${attachmentHTML}
                <div class="message-timestamp">${formatTimestamp(msg.created_at)}</div>
            </div>
        </div>
    `;
}

// Setup message form
function setupMessageForm() {
    const form = document.getElementById('sendMessageForm');
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const threadId = document.getElementById('activeThreadId').value;
        const message = document.getElementById('messageInput').value.trim();
        const fileInput = document.getElementById('fileInput');
        
        if (!message) return;
        
        const formData = new FormData();
        formData.append('thread_id', threadId);
        formData.append('message', message);
        
        if (fileInput.files.length > 0) {
            formData.append('attachment', fileInput.files[0]);
        }
        
        const sendBtn = document.getElementById('sendBtn');
        sendBtn.disabled = true;
        sendBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Sending...';
        
        try {
            const response = await fetch('/api/messages/send.php', {
                method: 'POST',
                body: formData
            });
            
            const data = await response.json();
            
            if (data.success) {
                document.getElementById('messageInput').value = '';
                clearFileInput();
                loadThreadMessages(threadId, true);
            } else {
                alert(data.error || 'Failed to send message');
            }
        } catch (error) {
            console.error('Error sending message:', error);
            alert('Failed to send message');
        } finally {
            sendBtn.disabled = false;
            sendBtn.innerHTML = '<i class="fas fa-paper-plane"></i> Send';
        }
    });
}

// Setup file input
function setupFileInput() {
    const fileInput = document.getElementById('fileInput');
    fileInput.addEventListener('change', function() {
        if (this.files.length > 0) {
            const file = this.files[0];
            document.getElementById('fileName').textContent = file.name;
            document.getElementById('filePreview').style.display = 'block';
        }
    });
}

function clearFileInput() {
    document.getElementById('fileInput').value = '';
    document.getElementById('filePreview').style.display = 'none';
}

// Update unread count in header
async function updateUnreadCount() {
    try {
        const response = await fetch('/api/messages/unread_count.php');
        const data = await response.json();
        
        if (data.success && data.unread_count > 0) {
            const badge = document.getElementById('totalUnreadBadge');
            badge.textContent = data.unread_count;
            badge.style.display = 'inline-block';
        }
    } catch (error) {
        console.error('Error updating unread count:', error);
    }
}

// Utility functions
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function truncate(text, length) {
    return text.length > length ? text.substring(0, length) + '...' : text;
}

function formatTimestamp(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffMins < 1440) return `${Math.floor(diffMins / 60)}h ago`;
    if (diffMins < 10080) return `${Math.floor(diffMins / 1440)}d ago`;
    
    return date.toLocaleDateString();
}

// Cleanup on page unload
window.addEventListener('beforeunload', function() {
    if (pollingInterval) {
        clearInterval(pollingInterval);
    }
});
</script>

<?php includeFooter(); ?>
