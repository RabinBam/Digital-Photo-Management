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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@400;700&family=Cormorant+Garamond:wght@400;500;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --font-serif: 'Cormorant Garamond', serif;
            --font-sans: 'Sora', sans-serif;
        }

        body {
            font-family: var(--font-sans);
        }

        .section-header h1 {
            font-family: var(--font-serif);
            font-weight: 700;
            font-size: 42px;
        }

        .section-header h5 {
            font-family: var(--font-sans);
        }

        .panel h2 {
            font-family: var(--font-serif);
            font-weight: 700;
            font-size: 28px;
        }

        .upload-zone h3 {
            font-family: var(--font-serif);
            font-weight: 700;
        }

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
            <h5 style="color: var(--accent-teal); font-size: 12px; letter-spacing: 2px; font-weight: 700; text-transform: uppercase; margin-bottom: 0.5rem;">MEDIA MANAGEMENT</h5>
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
                <p class="panel-subtitle">
                    Drag and drop files into the upload zone or browse manually. Selected files will be listed before submission.
                </p>

                <div class="feedback-stack">
                    <% if (successMessage != null && !successMessage.isBlank()) { %>
                        <div class="feedback success">
                            <i class="bi bi-check-circle-fill"></i>
                            <div><%= successMessage %></div>
                        </div>
                    <% } %>
                    <% if (errorMessage != null && !errorMessage.isBlank()) { %>
                        <div class="feedback error">
                            <i class="bi bi-exclamation-triangle-fill"></i>
                            <div><%= errorMessage %></div>
                        </div>
                    <% } %>
                </div>

                <form class="upload-form" action="<%= request.getContextPath() %>/uploadImport" method="post" enctype="multipart/form-data" id="uploadForm">
                    <input type="file" id="fileInput" class="hidden-file-input" name="file" multiple accept="image/*,video/*,.pdf">

                    <div class="upload-zone" id="uploadZone" role="button" tabindex="0" aria-label="Upload files">
                        <i class="bi bi-cloud-arrow-up"></i>
                        <h3>Drag &amp; Drop Your Media</h3>
                        <p>Click anywhere in this panel to browse your device or drop files directly into the zone.</p>
                        <p class="upload-hint">Themed for photos, clips, and documents from your personal archive.</p>
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
                    <p class="panel-subtitle">
                        Bring assets in from connected services and external links without leaving the dashboard.
                    </p>

                    <div class="import-grid">
                        <div class="import-card" data-import="Cloud Drive">
                            <i class="bi bi-cloud-fill"></i>
                            <h4>Cloud Drive</h4>
                            <p>Google Drive, OneDrive, Dropbox, and similar cloud vaults.</p>
                        </div>
                        <div class="import-card" data-import="Social Media">
                            <i class="bi bi-share-fill"></i>
                            <h4>Social Media</h4>
                            <p>Import posts and backups from social platforms and archives.</p>
                        </div>
                        <div class="import-card" data-import="Mobile Device">
                            <i class="bi bi-phone-fill"></i>
                            <h4>Mobile Device</h4>
                            <p>Sync photos and videos from your phone using the same theme.</p>
                        </div>
                        <div class="import-card" data-import="URL Import">
                            <i class="bi bi-link-45deg"></i>
                            <h4>From URL</h4>
                            <p>Paste a direct file link to add media to the archive.</p>
                        </div>
                    </div>

                    <div class="side-note">
                        <strong>Tip:</strong> Keep your uploads organised in collections before importing larger batches.
                        The upload flow already validates the supported file types server-side.
                    </div>
                </section>

                <section class="panel history-list">
                    <h2>Recent Transfers</h2>
                    <p class="panel-subtitle">
                        Recent upload and import activity from the same archive stream.
                    </p>

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
    const clearSelectionBtn = document.getElementById('clearSelectionBtn');
    let bufferedFiles = [];

    function formatSize(bytes) {
        if (!bytes) return '0 Bytes';
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const index = Math.floor(Math.log(bytes) / Math.log(1024));
        return Math.round((bytes / Math.pow(1024, index)) * 100) / 100 + ' ' + sizes[index];
    }

    function syncInputFiles() {
        const dataTransfer = new DataTransfer();
        bufferedFiles.forEach(function (file) {
            dataTransfer.items.add(file);
        });
        fileInput.files = dataTransfer.files;
    }

    function renderFiles(files) {
        selectedFilesList.innerHTML = '';

        if (!files || files.length === 0) {
            selectedFiles.style.display = 'none';
            return;
        }

        Array.from(files).forEach((file, index) => {
            const row = document.createElement('div');
            row.className = 'file-item';
            row.innerHTML = `
                <div>
                    <div class="file-name">${file.name}</div>
                    <div class="file-size">${formatSize(file.size)}</div>
                </div>
                <button type="button" class="remove-btn" title="Remove file">
                    <i class="bi bi-x-circle"></i>
                </button>
            `;

            row.querySelector('.remove-btn').addEventListener('click', function () {
                bufferedFiles.splice(index, 1);
                syncInputFiles();
                renderFiles(bufferedFiles);
            });

            selectedFilesList.appendChild(row);
        });

        selectedFiles.style.display = 'block';
    }

    function updateFilesFromInput(event) {
        bufferedFiles = Array.from(event.target.files || []);
        renderFiles(bufferedFiles);
    }

    uploadZone.addEventListener('click', function () {
        fileInput.click();
    });

    uploadZone.addEventListener('keydown', function (event) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            fileInput.click();
        }
    });

    fileInput.addEventListener('change', updateFilesFromInput);

    clearSelectionBtn.addEventListener('click', function () {
        bufferedFiles = [];
        fileInput.value = '';
        selectedFilesList.innerHTML = '';
        selectedFiles.style.display = 'none';
    });

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(function (eventName) {
        uploadZone.addEventListener(eventName, function (event) {
            event.preventDefault();
            event.stopPropagation();
        }, false);
    });

    ['dragenter', 'dragover'].forEach(function (eventName) {
        uploadZone.addEventListener(eventName, function () {
            uploadZone.classList.add('drag-over');
        });
    });

    ['dragleave', 'drop'].forEach(function (eventName) {
        uploadZone.addEventListener(eventName, function () {
            uploadZone.classList.remove('drag-over');
        });
    });

    uploadZone.addEventListener('drop', function (event) {
        bufferedFiles = Array.from(event.dataTransfer.files || []);
        syncInputFiles();
        renderFiles(bufferedFiles);
    });

    document.querySelectorAll('.import-card').forEach(function (card) {
        card.addEventListener('click', function () {
            const source = card.getAttribute('data-import');
            if (source === 'URL Import') {
                const url = prompt('Enter the media URL to import:');
                if (url) {
                    alert('Import request queued for: ' + url);
                }
                return;
            }

            alert(source + ' import is connected to the same archive styling and can be wired to a backend source next.');
        });
    });
})();
</script>

</body>
</html>