<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.DigiPic4.model.User" %>
<%
    User uploadUser = (User) session.getAttribute("user");
    if (uploadUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String uploadRole = uploadUser.getRole() == null ? "" : uploadUser.getRole().trim();
    boolean uploadIsAdmin = "admin".equalsIgnoreCase(uploadRole);

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String successMessage = request.getParameter("success");
    String errorMessage = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload & Import</title>
    
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style-light.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/uploadCss-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    
    <style>
        .history-item { align-items: flex-start; }
    </style>
</head>
<body>

<% if (uploadIsAdmin) { %>
    <jsp:include page="adminSidebar.jsp" />
<% } else { %>
    <jsp:include page="sidebar.jsp" />
<% } %>

<main class="main-content">
    <jsp:include page="<%= uploadIsAdmin ? \"adminHeader.jsp\" : \"Header.jsp\" %>" />

    <div class="page-shell">
        <div class="section-header">
            <h5 style="color: var(--accent-primary); font-size: 12px; letter-spacing: 2px; font-weight: 700; text-transform: uppercase; margin-bottom: 0.5rem;">Media Management</h5>
            <h1>Upload &amp; Import</h1>
            <p>Upload files from your device or import from cloud sources. Organize and manage your media archive.</p>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Storage Ready</div>
                <div class="stat-value">500 MB</div>
                <div class="stat-meta">per file supported</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Accepted Formats</div>
                <div class="stat-value">7 Types</div>
                <div class="stat-meta">JPG, PNG, GIF, MP4, MOV, PDF</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Sync Mode</div>
                <div class="stat-value">Live</div>
                <div class="stat-meta">instant archive updates</div>
            </div>
        </div>

        <div class="upload-layout">
            <section class="panel">
                <h2>Upload From Device</h2>
                <p class="panel-subtitle">Drag and drop files or click to browse. Files are validated before upload.</p>

                <% if (successMessage != null && !successMessage.isBlank()) { %>
                    <div class="feedback success" style="margin-bottom: 16px;">
                        <i class="bi bi-check-circle-fill"></i>
                        <div><%= successMessage %></div>
                    </div>
                <% } %>
                <% if (errorMessage != null && !errorMessage.isBlank()) { %>
                    <div class="feedback error" style="margin-bottom: 16px;">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        <div><%= errorMessage %></div>
                    </div>
                <% } %>

                <form class="upload-form" action="<%= request.getContextPath() %>/uploadImport" method="post" enctype="multipart/form-data" id="uploadForm">
                    <input type="file" id="fileInput" class="hidden-file-input" name="file" multiple accept="image/*,video/*,.pdf">

                    <div class="upload-zone" id="uploadZone" role="button" tabindex="0">
                        <i class="bi bi-cloud-arrow-up"></i>
                        <h3>Drag &amp; Drop Your Media</h3>
                        <p>Click here to browse or drop files directly into this area</p>
                        <p class="upload-hint">Supports JPG, PNG, GIF, MP4, MOV, and PDF files</p>
                    </div>

                    <div class="selected-files" id="selectedFiles">
                        <h4>Selected Files</h4>
                        <div id="selectedFilesList"></div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn-primary">
                            <i class="bi bi-upload" style="margin-right: 8px;"></i> Start Upload
                        </button>
                        <button type="button" class="btn-secondary" id="clearSelectionBtn">Clear Selection</button>
                    </div>
                </form>
            </section>

            <div class="side-stack">
                <section class="panel">
                    <h2>Import Sources</h2>
                    <p class="panel-subtitle">Connect cloud services and external links to import media.</p>

                    <div class="import-grid">
                        <div class="import-card" data-import="Cloud Drive">
                            <i class="bi bi-cloud-fill"></i>
                            <h4>Cloud Drive</h4>
                            <p>Google Drive, OneDrive, Dropbox</p>
                        </div>
                        <div class="import-card" data-import="Social Media">
                            <i class="bi bi-share-fill"></i>
                            <h4>Social Media</h4>
                            <p>Import from platforms and archives</p>
                        </div>
                        <div class="import-card" data-import="Mobile Device">
                            <i class="bi bi-phone-fill"></i>
                            <h4>Mobile Device</h4>
                            <p>Sync from your phone directly</p>
                        </div>
                        <div class="import-card" data-import="URL Import">
                            <i class="bi bi-link-45deg"></i>
                            <h4>From URL</h4>
                            <p>Paste direct file links</p>
                        </div>
                    </div>

                    <div class="side-note">
                        <strong>Tip:</strong> Organize your uploads in collections before importing large batches for better management.
                    </div>
                </section>

                <section class="panel history-list">
                    <h2>Recent Transfers</h2>
                    <p class="panel-subtitle">Recent upload and import activity</p>

                    <h4>Activity Log</h4>
                    <div class="history-item">
                        <div>
                            <div class="history-status">Completed</div>
                            <div class="history-name">Vacation_Sea_View_01.jpg</div>
                            <div class="history-meta">Uploaded from device • 24 minutes ago</div>
                        </div>
                        <span class="stat-meta">98%</span>
                    </div>

                    <div class="history-item">
                        <div>
                            <div class="history-status">Imported</div>
                            <div class="history-name">Family_Backup.zip</div>
                            <div class="history-meta">Cloud Drive sync • 3 hours ago</div>
                        </div>
                        <span class="stat-meta">72%</span>
                    </div>

                    <div class="history-item">
                        <div>
                            <div class="history-status">Queued</div>
                            <div class="history-name">ShortClip.mp4</div>
                            <div class="history-meta">URL fetch in progress • Today</div>
                        </div>
                        <span class="stat-meta">41%</span>
                    </div>
                </section>
            </div>
        </div>
    </div>
</main>

<script>
(function () {
    const uploadZone = document.getElementById('uploadZone');
    const fileInput = document.getElementById('fileInput');
    const selectedFiles = document.getElementById('selectedFiles');
    const selectedFilesList = document.getElementById('selectedFilesList');
    const clearBtn = document.getElementById('clearSelectionBtn');
    let files = [];

    function formatSize(b) {
        if (!b) return '0 B';
        const s = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(b) / Math.log(1024));
        return Math.round((b / Math.pow(1024, i)) * 100) / 100 + ' ' + s[i];
    }

    function render() {
        selectedFilesList.innerHTML = '';
        if (!files.length) {
            selectedFiles.style.display = 'none';
            return;
        }
        files.forEach((f, i) => {
            const d = document.createElement('div');
            d.className = 'file-item';
            d.innerHTML = `<div><div class="file-name">${f.name}</div><div class="file-size">${formatSize(f.size)}</div></div><button type="button" class="remove-btn" data-idx="${i}"><i class="bi bi-x"></i></button>`;
            d.querySelector('.remove-btn').onclick = () => { files.splice(i, 1); render(); };
            selectedFilesList.appendChild(d);
        });
        selectedFiles.style.display = 'block';
    }

    uploadZone.onclick = () => fileInput.click();
    fileInput.onchange = (e) => { files = Array.from(e.target.files || []); render(); };
    clearBtn.onclick = () => { files = []; fileInput.value = ''; render(); };

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(t => {
        uploadZone.addEventListener(t, e => { e.preventDefault(); e.stopPropagation(); });
    });
    ['dragenter', 'dragover'].forEach(t => {
        uploadZone.addEventListener(t, () => uploadZone.classList.add('drag-over'));
    });
    ['dragleave', 'drop'].forEach(t => {
        uploadZone.addEventListener(t, () => uploadZone.classList.remove('drag-over'));
    });
    uploadZone.ondrop = (e) => { files = Array.from(e.dataTransfer.files || []); render(); };

    document.querySelectorAll('.import-card').forEach(c => {
        c.onclick = () => {
            const s = c.getAttribute('data-import');
            if (s === 'URL Import') {
                const u = prompt('Enter media URL:');
                if (u) alert('Queued: ' + u);
                return;
            }
            alert(s + ' import connected to archive.');
        };
    });
})();
</script>

</body>
</html>
