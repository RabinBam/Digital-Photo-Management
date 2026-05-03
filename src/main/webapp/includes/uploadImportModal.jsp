<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Upload & Import Modal -->
<div id="uploadImportModal" class="upload-import-modal" style="display: none;">
    
    <!-- Modal Overlay -->
    <div class="modal-overlay" onclick="closeUploadModal()"></div>
    
    <!-- Modal Content -->
    <div class="modal-content">
        
        <!-- Modal Header -->
        <div class="modal-header">
            <h2>Upload & Import Media</h2>
            <button class="modal-close" onclick="closeUploadModal()">
                <i class="fas fa-times"></i>
            </button>
        </div>
        
        <!-- Alert Messages -->
        <div id="uploadAlerts"></div>
        
        <!-- Modal Body -->
        <div class="modal-body">
            <div class="upload-tabs">
                
                <!-- Tab Buttons -->
                <div class="tab-buttons">
                    <button class="tab-btn active" onclick="switchTab('upload-tab')">
                        <i class="fas fa-cloud-upload-alt"></i> Upload
                    </button>
                    <button class="tab-btn" onclick="switchTab('import-tab')">
                        <i class="fas fa-download"></i> Import
                    </button>
                </div>
                
                <!-- Upload Tab -->
                <div id="upload-tab" class="tab-content active">
                    
                    <form id="uploadForm" method="POST" enctype="multipart/form-data" style="display: none;">
                        <input type="file" id="fileInput" name="file" multiple accept="image/*,video/*,.pdf">
                    </form>
                    
                    <!-- Upload Zone -->
                    <div class="upload-zone" id="uploadZone">
                        <div class="upload-zone-icon">
                            <i class="fas fa-image"></i>
                        </div>
                        <h3>Drag & Drop Your Media</h3>
                        <p>Or click to browse your files</p>
                        <p class="upload-hint">JPG, PNG, GIF, MP4, MOV, PDF • Max 500MB per file</p>
                    </div>
                    
                    <!-- Upload Progress -->
                    <div class="upload-progress" id="uploadProgress" style="display: none;">
                        <div class="progress-info">
                            <span id="progressPercent">0%</span>
                            <span id="progressSpeed">0 KB/s</span>
                        </div>
                        <div class="progress-bar-container">
                            <div class="progress-bar-fill" id="progressFill"></div>
                        </div>
                    </div>
                    
                    <!-- File List -->
                    <div class="file-list-container" id="fileListContainer" style="display: none;">
                        <h4>Selected Files</h4>
                        <div id="fileListItems"></div>
                    </div>
                    
                    <!-- Upload Tips -->
                    <div class="tips-box">
                        <h4><i class="fas fa-lightbulb"></i> Tips</h4>
                        <ul>
                            <li>Organize files into collections before uploading</li>
                            <li>Large files will be automatically optimized</li>
                            <li>Your media is securely backed up to the cloud</li>
                        </ul>
                    </div>
                    
                </div>
                
                <!-- Import Tab -->
                <div id="import-tab" class="tab-content">
                    
                    <h3>Import from Sources</h3>
                    
                    <!-- Import Sources Grid -->
                    <div class="import-sources-grid">
                        
                        <div class="import-source-card" onclick="openCloudImport();">
                            <i class="fab fa-google-drive"></i>
                            <h4>Cloud Drive</h4>
                            <p>Google Drive, OneDrive, Dropbox</p>
                        </div>
                        
                        <div class="import-source-card" onclick="openSocialImport();">
                            <i class="fas fa-share-alt"></i>
                            <h4>Social Media</h4>
                            <p>Instagram, Facebook, Twitter</p>
                        </div>
                        
                        <div class="import-source-card" onclick="openDeviceImport();">
                            <i class="fas fa-mobile-alt"></i>
                            <h4>Mobile Device</h4>
                            <p>iOS, Android photos & videos</p>
                        </div>
                        
                        <div class="import-source-card" onclick="openURLImport();">
                            <i class="fas fa-link"></i>
                            <h4>From URL</h4>
                            <p>Direct link or web address</p>
                        </div>
                        
                    </div>
                    
                    <!-- Recent Imports -->
                    <h4 style="margin-top: 30px; margin-bottom: 15px;">
                        <i class="fas fa-history"></i> Recent Imports
                    </h4>
                    
                    <div class="recent-imports">
                        <div class="import-item">
                            <div class="import-item-icon">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div class="import-item-info">
                                <div class="import-item-name">Vacation Photos from Google Drive</div>
                                <div class="import-item-meta">23 items • 2 hours ago</div>
                            </div>
                        </div>
                        
                        <div class="import-item">
                            <div class="import-item-icon">
                                <i class="fas fa-check-circle"></i>
                            </div>
                            <div class="import-item-info">
                                <div class="import-item-name">Instagram Backup</div>
                                <div class="import-item-meta">12 items • 1 day ago</div>
                            </div>
                        </div>
                    </div>
                    
                </div>
                
            </div>
        </div>
        
        <!-- Modal Footer -->
        <div class="modal-footer">
            <button class="btn-cancel" onclick="closeUploadModal()">
                <i class="fas fa-times"></i> Cancel
            </button>
            <button class="btn-submit" id="submitBtn" style="display: none;" onclick="submitUpload()">
                <i class="fas fa-upload"></i> Upload
            </button>
        </div>
        
    </div>
    
</div>

<style>
    /* ===== MODAL OVERLAY ===== */
    .upload-import-modal {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
    }

    .modal-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.6);
        backdrop-filter: blur(4px);
    }

    /* ===== MODAL CONTENT ===== */
    .modal-content {
        position: relative;
        z-index: 10001;
        background: linear-gradient(145deg, #111822, #0c131b);
        border: 1px solid rgba(0, 245, 212, 0.1);
        border-radius: 16px;
        width: 90%;
        max-width: 800px;
        max-height: 85vh;
        display: flex;
        flex-direction: column;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.8), 0 0 40px rgba(0, 245, 212, 0.1);
        animation: slideUp 0.3s ease-out;
    }

    @keyframes slideUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    /* ===== MODAL HEADER ===== */
    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 25px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    }

    .modal-header h2 {
        font-size: 24px;
        color: var(--text-primary);
        margin: 0;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .modal-close {
        background: transparent;
        border: none;
        color: var(--text-secondary);
        font-size: 24px;
        cursor: pointer;
        padding: 0;
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 8px;
        transition: all 0.3s;
    }

    .modal-close:hover {
        background: rgba(255, 255, 255, 0.1);
        color: var(--accent-teal);
    }

    /* ===== MODAL BODY ===== */
    .modal-body {
        flex: 1;
        overflow-y: auto;
        padding: 25px;
    }

    /* ===== TABS ===== */
    .upload-tabs {
        display: flex;
        flex-direction: column;
        height: 100%;
    }

    .tab-buttons {
        display: flex;
        gap: 10px;
        margin-bottom: 25px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    }

    .tab-btn {
        background: transparent;
        border: none;
        color: var(--text-secondary);
        font-size: 14px;
        font-weight: 600;
        padding: 12px 20px;
        cursor: pointer;
        border-bottom: 3px solid transparent;
        transition: all 0.3s;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .tab-btn:hover {
        color: var(--accent-teal);
    }

    .tab-btn.active {
        color: var(--accent-teal);
        border-bottom-color: var(--accent-teal);
    }

    .tab-content {
        display: none;
    }

    .tab-content.active {
        display: block;
    }

    /* ===== UPLOAD ZONE ===== */
    .upload-zone {
        border: 2px dashed rgba(0, 245, 212, 0.3);
        border-radius: 12px;
        padding: 40px;
        text-align: center;
        cursor: pointer;
        transition: all 0.3s;
        background: rgba(0, 245, 212, 0.02);
    }

    .upload-zone:hover {
        border-color: var(--accent-teal);
        background: rgba(0, 245, 212, 0.05);
    }

    .upload-zone.drag-over {
        border-color: var(--accent-teal);
        background: rgba(0, 245, 212, 0.1);
        box-shadow: 0 0 20px rgba(0, 245, 212, 0.2);
    }

    .upload-zone-icon {
        font-size: 48px;
        color: var(--accent-teal);
        margin-bottom: 15px;
    }

    .upload-zone h3 {
        font-size: 18px;
        color: var(--text-primary);
        margin: 10px 0;
    }

    .upload-zone p {
        color: var(--text-secondary);
        font-size: 14px;
        margin: 5px 0;
    }

    .upload-hint {
        font-size: 12px;
        color: var(--text-secondary);
        margin-top: 15px;
    }

    /* ===== UPLOAD PROGRESS ===== */
    .upload-progress {
        margin-top: 20px;
        padding: 15px;
        background: rgba(255, 255, 255, 0.02);
        border-radius: 8px;
    }

    .progress-info {
        display: flex;
        justify-content: space-between;
        margin-bottom: 10px;
        font-size: 12px;
        color: var(--text-secondary);
    }

    .progress-bar-container {
        height: 6px;
        background: rgba(255, 255, 255, 0.05);
        border-radius: 3px;
        overflow: hidden;
    }

    .progress-bar-fill {
        height: 100%;
        background: linear-gradient(90deg, var(--accent-teal), #00d9d9);
        width: 0%;
        transition: width 0.3s;
    }

    /* ===== FILE LIST ===== */
    .file-list-container {
        margin-top: 20px;
    }

    .file-list-container h4 {
        color: var(--text-primary);
        font-size: 13px;
        margin-bottom: 10px;
    }

    .file-item {
        background: rgba(255, 255, 255, 0.02);
        border: 1px solid rgba(255, 255, 255, 0.05);
        padding: 12px;
        border-radius: 8px;
        margin-bottom: 8px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 13px;
    }

    .file-item-info {
        flex: 1;
    }

    .file-item-name {
        color: var(--text-primary);
        font-weight: 500;
        margin-bottom: 3px;
    }

    .file-item-size {
        color: var(--text-secondary);
        font-size: 11px;
    }

    .file-item-remove {
        background: transparent;
        border: none;
        color: var(--text-secondary);
        cursor: pointer;
        font-size: 14px;
        padding: 4px 8px;
        transition: all 0.3s;
    }

    .file-item-remove:hover {
        color: #ff6b6b;
    }

    /* ===== TIPS BOX ===== */
    .tips-box {
        background: rgba(0, 245, 212, 0.05);
        border: 1px solid rgba(0, 245, 212, 0.1);
        border-radius: 8px;
        padding: 15px;
        margin-top: 20px;
    }

    .tips-box h4 {
        color: var(--accent-teal);
        font-size: 12px;
        margin: 0 0 10px 0;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .tips-box ul {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .tips-box li {
        color: var(--text-secondary);
        font-size: 12px;
        margin-bottom: 6px;
        padding-left: 20px;
        position: relative;
    }

    .tips-box li:before {
        content: "✓";
        color: var(--accent-teal);
        position: absolute;
        left: 0;
    }

    /* ===== IMPORT SOURCES ===== */
    .import-sources-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 15px;
        margin-bottom: 20px;
    }

    .import-source-card {
        background: rgba(255, 255, 255, 0.02);
        border: 1px solid rgba(255, 255, 255, 0.05);
        border-radius: 8px;
        padding: 20px;
        text-align: center;
        cursor: pointer;
        transition: all 0.3s;
    }

    .import-source-card:hover {
        border-color: var(--accent-teal);
        background: rgba(0, 245, 212, 0.05);
        transform: translateY(-2px);
        box-shadow: 0 0 15px rgba(0, 245, 212, 0.1);
    }

    .import-source-card i {
        font-size: 32px;
        color: var(--accent-teal);
        margin-bottom: 10px;
    }

    .import-source-card h4 {
        color: var(--text-primary);
        font-size: 14px;
        margin: 10px 0 5px 0;
    }

    .import-source-card p {
        color: var(--text-secondary);
        font-size: 11px;
        margin: 0;
    }

    /* ===== RECENT IMPORTS ===== */
    .recent-imports {
        display: flex;
        flex-direction: column;
        gap: 10px;
    }

    .import-item {
        background: rgba(255, 255, 255, 0.02);
        border: 1px solid rgba(255, 255, 255, 0.05);
        border-radius: 8px;
        padding: 12px;
        display: flex;
        gap: 12px;
        align-items: flex-start;
    }

    .import-item-icon {
        font-size: 18px;
        color: var(--accent-teal);
        flex-shrink: 0;
        margin-top: 2px;
    }

    .import-item-info {
        flex: 1;
    }

    .import-item-name {
        color: var(--text-primary);
        font-size: 13px;
        font-weight: 500;
        margin-bottom: 3px;
    }

    .import-item-meta {
        color: var(--text-secondary);
        font-size: 11px;
    }

    /* ===== ALERTS ===== */
    #uploadAlerts {
        margin-bottom: 20px;
    }

    .alert {
        padding: 12px;
        border-radius: 8px;
        margin-bottom: 10px;
        font-size: 13px;
        border-left: 4px solid;
        display: flex;
        gap: 10px;
        align-items: flex-start;
    }

    .alert i {
        flex-shrink: 0;
        margin-top: 2px;
    }

    .alert-success {
        background: rgba(0, 245, 212, 0.1);
        border-left-color: #00f5d4;
        color: #00f5d4;
    }

    .alert-error {
        background: rgba(255, 107, 107, 0.1);
        border-left-color: #ff6b6b;
        color: #ff6b6b;
    }

    /* ===== MODAL FOOTER ===== */
    .modal-footer {
        display: flex;
        justify-content: flex-end;
        gap: 10px;
        padding: 20px 25px;
        border-top: 1px solid rgba(255, 255, 255, 0.05);
    }

    .btn-cancel {
        background: transparent;
        border: 1px solid rgba(255, 255, 255, 0.1);
        color: var(--text-secondary);
        padding: 10px 20px;
        border-radius: 8px;
        cursor: pointer;
        font-size: 13px;
        font-weight: 600;
        transition: all 0.3s;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .btn-cancel:hover {
        border-color: var(--text-secondary);
        color: var(--text-primary);
    }

    .btn-submit {
        background: var(--accent-teal);
        border: 1px solid var(--accent-teal);
        color: var(--bg-base);
        padding: 10px 20px;
        border-radius: 8px;
        cursor: pointer;
        font-size: 13px;
        font-weight: 600;
        transition: all 0.3s;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .btn-submit:hover {
        background: transparent;
        color: var(--accent-teal);
        box-shadow: 0 0 15px rgba(0, 245, 212, 0.3);
    }

    /* ===== RESPONSIVE ===== */
    @media (max-width: 600px) {
        .modal-content {
            width: 95%;
            max-height: 90vh;
        }

        .import-sources-grid {
            grid-template-columns: 1fr;
        }

        .upload-zone {
            padding: 30px 20px;
        }

        .modal-header h2 {
            font-size: 18px;
        }

        .modal-body {
            padding: 15px;
        }
    }
</style>

<script>
    // ===== TAB SWITCHING =====
    function switchTab(tabId) {
        // Hide all tabs
        document.querySelectorAll('.tab-content').forEach(tab => {
            tab.classList.remove('active');
        });
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });

        // Show selected tab
        document.getElementById(tabId).classList.add('active');
        event.target.closest('.tab-btn').classList.add('active');

        // Show/hide submit button
        const submitBtn = document.getElementById('submitBtn');
        if (tabId === 'upload-tab') {
            submitBtn.style.display = 'flex';
        } else {
            submitBtn.style.display = 'none';
        }
    }

    // ===== DRAG & DROP =====
    const uploadZone = document.querySelector('.upload-zone');
    const fileInput = document.getElementById('fileInput');
    const fileListContainer = document.getElementById('fileListContainer');
    const fileListItems = document.getElementById('fileListItems');

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        uploadZone.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    ['dragenter', 'dragover'].forEach(eventName => {
        uploadZone.addEventListener(eventName, () => {
            uploadZone.classList.add('drag-over');
        });
    });

    ['dragleave', 'drop'].forEach(eventName => {
        uploadZone.addEventListener(eventName, () => {
            uploadZone.classList.remove('drag-over');
        });
    });

    uploadZone.addEventListener('drop', (e) => {
        const dt = e.dataTransfer;
        const files = dt.files;
        handleFiles(files);
    });

    uploadZone.addEventListener('click', () => {
        fileInput.click();
    });

    fileInput.addEventListener('change', (e) => {
        handleFiles(e.target.files);
    });

    function handleFiles(files) {
        if (files.length === 0) return;

        fileListItems.innerHTML = '';
        fileListContainer.style.display = 'block';

        Array.from(files).forEach((file, index) => {
            const fileItem = document.createElement('div');
            fileItem.className = 'file-item';
            fileItem.innerHTML = `
                <div class="file-item-info">
                    <div class="file-item-name">${file.name}</div>
                    <div class="file-item-size">${formatFileSize(file.size)}</div>
                </div>
                <button type="button" class="file-item-remove" onclick="this.parentElement.remove(); if(document.querySelectorAll('.file-item').length === 0) document.getElementById('fileListContainer').style.display = 'none';">
                    <i class="fas fa-times"></i>
                </button>
            `;
            fileListItems.appendChild(fileItem);
        });

        showProgress();
    }

    function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    }

    function showProgress() {
        const progressContainer = document.getElementById('uploadProgress');
        const progressFill = document.getElementById('progressFill');
        const progressPercent = document.getElementById('progressPercent');
        const progressSpeed = document.getElementById('progressSpeed');

        progressContainer.style.display = 'block';
        let progress = 0;

        const interval = setInterval(() => {
            progress += Math.random() * 30;
            if (progress >= 100) {
                progress = 100;
                clearInterval(interval);
            }
            progressFill.style.width = progress + '%';
            progressPercent.textContent = Math.floor(progress) + '%';
            progressSpeed.textContent = Math.floor(Math.random() * 1000 + 500) + ' KB/s';
        }, 300);
    }

    function submitUpload() {
        const form = document.getElementById('uploadForm');
        form.submit();
    }

    // ===== IMPORT FUNCTIONS =====
    function openCloudImport() {
        showAlert('success', 'Cloud import feature will connect to your cloud storage account.');
    }

    function openSocialImport() {
        showAlert('success', 'Social media import will allow you to backup your photos from social platforms.');
    }

    function openDeviceImport() {
        showAlert('success', 'Mobile device import will sync photos and videos from your device.');
    }

    function openURLImport() {
        const url = prompt('Enter the URL of the media file:');
        if (url) {
            showAlert('success', 'Importing from: ' + url);
        }
    }

    function showAlert(type, message) {
        const alertsContainer = document.getElementById('uploadAlerts');
        const alertDiv = document.createElement('div');
        alertDiv.className = 'alert alert-' + type;
        alertDiv.innerHTML = `
            <i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-circle'}"></i>
            <div>${message}</div>
        `;
        alertsContainer.appendChild(alertDiv);

        setTimeout(() => {
            alertDiv.remove();
        }, 5000);
    }
</script>
