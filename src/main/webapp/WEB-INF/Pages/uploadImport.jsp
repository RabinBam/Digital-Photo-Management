<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.DigiPic4.model.User, com.DigiPic4.model.Album, java.util.List" %>
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
    String errorMessage   = request.getParameter("error");

    List<Album> uploadAlbums = (List<Album>) request.getAttribute("albums");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload & Import – DigiPic</title>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style-light.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">

    <style>
        :root {
            --font-serif: 'Cormorant Garamond', serif;
            --font-sans:  'Sora', sans-serif;
        }

        /* ── Page shell ─────────────────────────────── */
        .page-shell {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0 28px 48px;
        }

        .section-header { margin-bottom: 28px; }
        .section-header h5 {
            color: #2563eb; font-size: 11px; letter-spacing: 2px; font-weight: 700;
            text-transform: uppercase; margin-bottom: 6px;
        }
        .section-header h1 {
            font-family: var(--font-serif); font-size: 42px; font-weight: 700;
            color: #1e293b; margin: 0 0 8px;
        }
        .section-header p { color: #64748b; font-size: 14px; line-height: 1.6; max-width: 640px; }

        /* ── Stats row ──────────────────────────────── */
        .stats-row {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 28px;
        }
        .stat-card {
            background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: 14px;
            padding: 18px 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .stat-label { font-size: 11px; color: #94a3b8; text-transform: uppercase; letter-spacing: 1.4px; font-weight: 700; margin-bottom: 8px; }
        .stat-value { font-size: 26px; font-weight: 800; color: #1e293b; }
        .stat-meta  { font-size: 12px; color: #2563eb; font-weight: 600; margin-top: 2px; }

        /* ── Two-column layout ──────────────────────── */
        .upload-layout {
            display: grid; grid-template-columns: 1.4fr 0.9fr; gap: 24px; align-items: start;
        }

        /* ── Panels ─────────────────────────────────── */
        .panel {
            background: var(--bg-surface); border: 1px solid var(--border-color);
            border-radius: 18px; padding: 28px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .panel h2 {
            font-family: var(--font-serif); font-size: 26px; font-weight: 700; color: #1e293b; margin: 0 0 6px;
        }
        .panel-subtitle { color: #64748b; font-size: 13px; margin-bottom: 22px; line-height: 1.5; }

        /* ── Feedback banners ───────────────────────── */
        .feedback {
            display: flex; gap: 10px; align-items: flex-start; padding: 13px 16px;
            border-radius: 10px; font-size: 13px; font-weight: 600;
            border-left: 4px solid; margin-bottom: 18px;
        }
        .feedback.success { background: #dcfce7; color: #166534; border-left-color: #16a34a; }
        .feedback.error   { background: #fee2e2; color: #991b1b; border-left-color: #dc2626; }
        .feedback i { margin-top: 1px; flex-shrink: 0; }

        /* ── Upload zone ────────────────────────────── */
        .upload-zone {
            border: 2px dashed #cbd5e1; border-radius: 14px; padding: 42px 24px;
            text-align: center; cursor: pointer; background: #f8fafc;
            transition: border-color 0.2s, background 0.2s, box-shadow 0.2s;
            user-select: none;
        }
        .upload-zone:hover, .upload-zone.drag-over {
            border-color: #2563eb; background: #eff6ff;
            box-shadow: 0 0 0 4px rgba(37,99,235,0.08);
        }
        .upload-zone i { font-size: 48px; color: #2563eb; margin-bottom: 14px; display: block; pointer-events: none; }
        .upload-zone h3 { font-family: var(--font-serif); font-size: 22px; color: #1e293b; margin: 0 0 6px; pointer-events: none; }
        .upload-zone p  { color: #64748b; font-size: 13px; line-height: 1.6; margin: 0; pointer-events: none; }
        .upload-zone .hint {
            margin-top: 12px; font-size: 11px; font-weight: 700; letter-spacing: 0.8px;
            text-transform: uppercase; color: #2563eb; pointer-events: none;
        }
        /* Hidden file input OUTSIDE the zone - triggered by JS */
        #fileInput { display: none; }

        /* ── Album selector ─────────────────────────── */
        .album-selector-wrap { margin-top: 18px; }
        .album-selector-wrap label {
            font-size: 12px; font-weight: 700; letter-spacing: 0.5px; text-transform: uppercase;
            color: #1e293b; margin-bottom: 8px; display: block;
        }
        .album-select {
            width: 100%; padding: 11px 14px; border-radius: 10px;
            border: 1.5px solid var(--border-color); background: var(--bg-surface-light);
            font-family: var(--font-sans); font-size: 14px; color: #1e293b; cursor: pointer;
            transition: border-color 0.2s;
        }
        .album-select:focus { outline: none; border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37,99,235,0.1); }

        /* ── Selected files list ────────────────────── */
        #selectedFilesBox {
            display: none; background: #f8fafc; border: 1px solid var(--border-color);
            border-radius: 12px; padding: 16px; margin-top: 16px;
        }
        #selectedFilesBox h4 { font-size: 13px; font-weight: 700; color: #1e293b; margin: 0 0 12px; }
        .file-list { display: flex; flex-direction: column; gap: 8px; max-height: 240px; overflow-y: auto; }
        .file-item {
            display: flex; align-items: center; gap: 12px; padding: 10px 12px;
            background: var(--bg-surface); border: 1px solid var(--border-color);
            border-radius: 9px;
        }
        .file-item-icon {
            width: 36px; height: 36px; border-radius: 8px; background: #eff6ff;
            display: flex; align-items: center; justify-content: center;
            color: #2563eb; font-size: 16px; flex-shrink: 0;
        }
        .file-item-info { flex: 1; min-width: 0; }
        .file-name { font-size: 13px; font-weight: 600; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .file-size { font-size: 11px; color: #94a3b8; margin-top: 2px; }
        .remove-btn {
            background: none; border: none; cursor: pointer; color: #94a3b8;
            font-size: 16px; padding: 4px 6px; border-radius: 6px; transition: color 0.2s, background 0.2s;
            flex-shrink: 0;
        }
        .remove-btn:hover { color: #ef4444; background: #fee2e2; }

        /* ── Progress bar ───────────────────────────── */
        #uploadProgress { display: none; margin-top: 16px; }
        .progress-header { display: flex; justify-content: space-between; font-size: 12px; color: #64748b; margin-bottom: 6px; font-weight: 600; }
        .progress-track { height: 6px; background: #e2e8f0; border-radius: 3px; overflow: hidden; }
        .progress-fill  { height: 100%; background: linear-gradient(90deg, #2563eb, #3b82f6); border-radius: 3px; width: 0%; transition: width 0.3s ease; }

        /* ── Form actions ───────────────────────────── */
        .form-actions { display: flex; gap: 12px; margin-top: 20px; flex-wrap: wrap; }
        .btn-upload {
            background: linear-gradient(135deg, #2563eb, #1e40af); color: #fff; border: none;
            padding: 11px 24px; border-radius: 10px; font-weight: 700; cursor: pointer;
            font-family: var(--font-sans); font-size: 14px; display: flex; align-items: center; gap: 8px;
            transition: all 0.2s;
        }
        .btn-upload:hover:not(:disabled) { box-shadow: 0 6px 18px rgba(37,99,235,0.25); transform: translateY(-1px); }
        .btn-upload:disabled { opacity: 0.45; cursor: not-allowed; transform: none; }
        .btn-clear {
            background: var(--bg-surface-light); color: var(--text-primary);
            border: 1px solid var(--border-color); padding: 11px 18px; border-radius: 10px;
            font-weight: 600; cursor: pointer; font-family: var(--font-sans); transition: all 0.2s;
        }
        .btn-clear:hover { border-color: #ef4444; color: #ef4444; background: #fee2e2; }

        /* ── Import cards ───────────────────────────── */
        .import-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .import-card {
            background: #f8fafc; border: 1.5px solid var(--border-color); border-radius: 12px;
            padding: 18px; cursor: pointer; transition: all 0.2s; text-align: center;
        }
        .import-card:hover {
            border-color: #2563eb; background: #eff6ff;
            transform: translateY(-2px); box-shadow: 0 6px 16px rgba(37,99,235,0.1);
        }
        .import-card i { font-size: 28px; color: #2563eb; margin-bottom: 10px; display: block; }
        .import-card h4 { font-size: 13px; font-weight: 700; color: #1e293b; margin: 0 0 4px; }
        .import-card p  { font-size: 11px; color: #64748b; margin: 0; line-height: 1.4; }

        .side-note {
            background: #eff6ff; border: 1px solid #dbeafe; border-radius: 10px;
            padding: 14px 16px; margin-top: 16px; font-size: 12px; color: #1e40af; line-height: 1.6;
        }
        .side-note strong { color: #1e293b; }

        /* ── Recent transfers ───────────────────────── */
        .transfer-item {
            display: flex; align-items: center; gap: 12px; padding: 12px 0;
            border-bottom: 1px solid var(--border-color);
        }
        .transfer-item:last-child { border-bottom: none; padding-bottom: 0; }
        .transfer-ico {
            width: 38px; height: 38px; border-radius: 10px; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center; font-size: 16px;
        }
        .transfer-ico.done { background: #dcfce7; color: #16a34a; }
        .transfer-ico.pend { background: #fef9c3; color: #ca8a04; }
        .transfer-name { font-size: 13px; font-weight: 600; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .transfer-meta { font-size: 11px; color: #94a3b8; margin-top: 2px; }
        .transfer-pct  { font-size: 12px; font-weight: 700; color: #2563eb; flex-shrink: 0; margin-left: auto; }

        /* ── Responsive ─────────────────────────────── */
        @media (max-width: 1100px) { .upload-layout { grid-template-columns: 1fr; } }
        @media (max-width: 768px)  { .stats-row { grid-template-columns: 1fr; } .import-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

    <%-- Sidebar --%>
    <% if (uploadIsAdmin) { %>
        <jsp:include page="../components/adminSidebar.jsp" />
    <% } else { %>
        <jsp:include page="../components/sidebar.jsp" />
    <% } %>

    <main class="main-content">
        <%-- Header --%>
        <% if (uploadIsAdmin) { %>
            <jsp:include page="../components/adminHeader.jsp" />
        <% } else { %>
            <jsp:include page="../components/Header.jsp" />
        <% } %>

        <div class="page-shell">

            <div class="section-header">
                <h5>Media Management</h5>
                <h1>Upload &amp; Import</h1>
                <p>Upload files from your device or pull from cloud sources. Files are validated server-side and catalogued in your chosen album automatically.</p>
            </div>

            <%-- Stats --%>
            <div class="stats-row">
                <div class="stat-card">
                    <div class="stat-label">Max File Size</div>
                    <div class="stat-value">500 MB</div>
                    <div class="stat-meta">per file</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Accepted Formats</div>
                    <div class="stat-value">7 Types</div>
                    <div class="stat-meta">JPG · PNG · GIF · MP4 · MOV · PDF</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Sync Mode</div>
                    <div class="stat-value">Live</div>
                    <div class="stat-meta">instant archive updates</div>
                </div>
            </div>

            <div class="upload-layout">

                <%-- ── Left: Upload form ─────────────────────────── --%>
                <section class="panel">
                    <h2>Upload From Device</h2>
                    <p class="panel-subtitle">Click the zone to browse files, or drag and drop them directly. All selected files are listed before you submit.</p>

                    <%-- Flash feedback --%>
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

                    <%-- Hidden file input — outside the drop zone so it doesn't interfere --%>
                    <input type="file" id="fileInput" name="file" multiple accept="image/*,video/*,.pdf">

                    <form id="uploadForm"
                          action="<%= request.getContextPath() %>/uploadImport"
                          method="post"
                          enctype="multipart/form-data">

                        <div class="upload-zone" id="uploadZone">
                            <i class="bi bi-cloud-arrow-up"></i>
                            <h3>Drag &amp; Drop Your Media</h3>
                            <p>Click anywhere in this box to open the file picker,<br>or drop files directly here.</p>
                            <div class="hint">JPG · PNG · GIF · MP4 · MOV · PDF &nbsp;·&nbsp; Max 500 MB each</div>
                        </div>

                        <%-- Album selector --%>
                        <div class="album-selector-wrap" style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                            <div>
                                <label for="albumId">Save to Existing Album</label>
                                <select id="albumId" name="albumId" class="album-select">
                                    <option value="">— Create New / Use Default —</option>
                                    <% if (uploadAlbums != null) {
                                        for (Album al : uploadAlbums) { %>
                                            <option value="<%= al.getAlbumId() %>"><%= al.getAlbumName() %> (<%= al.getPhotoCount() %> photos)</option>
                                    <%  }
                                    } %>
                                </select>
                            </div>
                            <div>
                                <label for="newAlbumName">Or Create New Album</label>
                                <input type="text" id="newAlbumName" name="newAlbumName" class="album-select" 
                                       placeholder="Enter name (e.g. Vacation 2024)"
                                       <%= (uploadAlbums != null && uploadAlbums.size() >= 3) ? "disabled" : "" %>>
                                <% if (uploadAlbums != null && uploadAlbums.size() >= 3) { %>
                                    <div style="color: #ef4444; font-size: 11px; font-weight: 700; margin-top: 4px;">
                                        <i class="bi bi-exclamation-circle"></i> Album limit reached (3/3)
                                    </div>
                                <% } else if (uploadAlbums != null) { %>
                                    <div style="color: #64748b; font-size: 11px; margin-top: 4px;">
                                        Albums: <%= uploadAlbums.size() %>/3
                                    </div>
                                <% } %>
                            </div>
                        </div>

                        <%-- Metadata fields --%>
                        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:20px; border-top:1px solid #e2e8f0; padding-top:20px;">
                            <div class="mfield" style="margin:0;">
                                <label><i class="bi bi-camera"></i> Aperture</label>
                                <input type="text" name="aperture" placeholder="e.g. f/1.8">
                            </div>
                            <div class="mfield" style="margin:0;">
                                <label><i class="bi bi-stopwatch"></i> Shutter Speed</label>
                                <input type="text" name="shutterSpeed" placeholder="e.g. 1/1000">
                            </div>
                            <div class="mfield" style="margin:0;">
                                <label><i class="bi bi-film"></i> ISO</label>
                                <input type="text" name="iso" placeholder="e.g. 100">
                            </div>
                            <div class="mfield" style="margin:0;">
                                <label><i class="bi bi-arrows-expand"></i> Focal Length</label>
                                <input type="text" name="focalLength" placeholder="e.g. 35mm">
                            </div>
                        </div>

                        <%-- Selected files list --%>
                        <div id="selectedFilesBox">
                            <h4 id="selectedCount">Selected Files (0)</h4>
                            <div class="file-list" id="fileList"></div>
                        </div>

                        <%-- Upload progress --%>
                        <div id="uploadProgress">
                            <div class="progress-header">
                                <span>Uploading to server…</span>
                                <span id="progressPct">0%</span>
                            </div>
                            <div class="progress-track">
                                <div class="progress-fill" id="progressFill"></div>
                            </div>
                        </div>

                        <%-- The actual file input that submits with the form --%>
                        <%-- We clone buffered files into a second hidden input on submit --%>
                        <input type="file" id="formFileInput" name="file" multiple accept="image/*,video/*,.pdf" style="display:none">

                        <div class="form-actions">
                            <button type="submit" class="btn-upload" id="uploadBtn" disabled>
                                <i class="bi bi-upload"></i> Start Upload
                            </button>
                            <button type="button" class="btn-clear" id="clearBtn">
                                <i class="bi bi-x-circle"></i> Clear
                            </button>
                        </div>
                    </form>
                </section>

                <%-- ── Right column ──────────────────────────────── --%>
                <div style="display:flex; flex-direction:column; gap:20px;">

                    <section class="panel">
                        <h2>Import Sources</h2>
                        <p class="panel-subtitle">Connect cloud services or paste a URL to pull in media.</p>
                        
                        <div id="urlImportSection" style="display:none; margin-bottom: 20px; padding: 15px; background: #eff6ff; border-radius: 12px; border: 1px solid #dbeafe;">
                            <h4 style="font-size:13px; font-weight:700; margin-bottom:10px;">Import from URL</h4>
                            <form action="<%= request.getContextPath() %>/uploadImport" method="post" style="display:flex; gap:10px;">
                                <input type="url" name="importUrl" placeholder="https://example.com/image.jpg" required 
                                       style="flex:1; padding:8px 12px; border-radius:8px; border:1.5px solid #cbd5e1; font-size:13px;">
                                <input type="hidden" name="albumId" id="urlAlbumId">
                                <button type="submit" class="btn-upload" style="padding:8px 16px; font-size:12px;">Import</button>
                                <button type="button" class="btn-clear" onclick="toggleUrlImport()" style="padding:8px 12px; font-size:12px;">Cancel</button>
                            </form>
                        </div>

                        <div class="import-grid">
                            <div class="import-card" onclick="importAlert('Cloud Drive')">
                                <i class="bi bi-cloud-fill"></i>
                                <h4>Cloud Drive</h4>
                                <p>Google Drive, OneDrive, Dropbox</p>
                            </div>
                            <div class="import-card" onclick="importAlert('Social Media')">
                                <i class="bi bi-share-fill"></i>
                                <h4>Social Media</h4>
                                <p>Instagram, Facebook backups</p>
                            </div>
                            <div class="import-card" onclick="importAlert('Mobile Sync')">
                                <i class="bi bi-phone-fill"></i>
                                <h4>Mobile Sync</h4>
                                <p>iOS &amp; Android photo rolls</p>
                            </div>
                            <div class="import-card" onclick="toggleUrlImport()">
                                <i class="bi bi-link-45deg"></i>
                                <h4>From URL</h4>
                                <p>Paste any direct file link</p>
                            </div>
                        </div>
                        <div class="side-note">
                            <strong>Tip:</strong> Organise uploads into albums before importing large batches — the album selector on the left assigns files automatically.
                        </div>
                    </section>

                    <section class="panel">
                        <h2>Recent Transfers</h2>
                        <p class="panel-subtitle">Latest upload activity.</p>
                        <div id="recentActivityList">
                            <!-- Populated by JS from localStorage -->
                            <div class="transfer-item">
                                <div class="transfer-ico done"><i class="bi bi-check2"></i></div>
                                <div style="flex:1;min-width:0;">
                                    <div class="transfer-name">No recent activity</div>
                                    <div class="transfer-meta">Upload or import images to see them here</div>
                                </div>
                            </div>
                        </div>
                    </section>

                </div>
            </div>
        </div>
        
        <jsp:include page="../components/footer.jsp" />
    </main>

    <script>
    (function () {
        var zone     = document.getElementById('uploadZone');
        var picker   = document.getElementById('fileInput');       // hidden picker, NOT in form
        var formInput = document.getElementById('formFileInput');  // submits with form
        var selBox   = document.getElementById('selectedFilesBox');
        var fileList = document.getElementById('fileList');
        var countLbl = document.getElementById('selectedCount');
        var uploadBtn = document.getElementById('uploadBtn');
        var clearBtn  = document.getElementById('clearBtn');
        var form      = document.getElementById('uploadForm');
        var buffered  = [];

        var ALLOWED = ['.jpg', '.jpeg', '.png', '.gif', '.mp4', '.mov', '.pdf'];
        var ICONS = { image: 'bi-image', video: 'bi-camera-video', application: 'bi-file-earmark-pdf' };

        function iconFor(type) {
            var base = (type || '').split('/')[0];
            return ICONS[base] || 'bi-file-earmark';
        }

        function fmt(bytes) {
            if (!bytes) return '0 B';
            var s = ['B','KB','MB','GB'];
            var i = Math.floor(Math.log(bytes) / Math.log(1024));
            return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + s[i];
        }

        function isAllowed(name) {
            var ext = '.' + name.split('.').pop().toLowerCase();
            return ALLOWED.indexOf(ext) !== -1;
        }

        function render() {
            if (!buffered.length) {
                selBox.style.display = 'none';
                uploadBtn.disabled = true;
                return;
            }
            countLbl.textContent = 'Selected Files (' + buffered.length + ')';
            fileList.innerHTML = buffered.map(function(f, i) {
                return '<div class="file-item">' +
                    '<div class="file-item-icon"><i class="bi ' + iconFor(f.type) + '"></i></div>' +
                    '<div class="file-item-info">' +
                        '<div class="file-name">' + f.name + '</div>' +
                        '<div class="file-size">' + fmt(f.size) + '</div>' +
                    '</div>' +
                    '<button class="remove-btn" type="button" data-idx="' + i + '" title="Remove">' +
                        '<i class="bi bi-x-lg"></i>' +
                    '</button>' +
                '</div>';
            }).join('');
            selBox.style.display = 'block';
            uploadBtn.disabled = false;

            fileList.querySelectorAll('.remove-btn').forEach(function(btn) {
                btn.onclick = function() {
                    buffered.splice(parseInt(btn.dataset.idx), 1);
                    render();
                };
            });
        }

        function addFiles(newFiles) {
            var skipped = [];
            Array.from(newFiles).forEach(function(f) {
                if (isAllowed(f.name)) {
                    buffered.push(f);
                } else {
                    skipped.push(f.name);
                }
            });
            if (skipped.length) {
                alert('Skipped unsupported file(s):\n' + skipped.join('\n'));
            }
            render();
        }

        // Click on drop zone → open file picker
        zone.addEventListener('click', function() {
            picker.value = '';
            picker.click();
        });

        // File picker selection
        picker.addEventListener('change', function(e) {
            if (e.target.files && e.target.files.length) {
                addFiles(e.target.files);
            }
        });

        // Drag and drop on zone
        zone.addEventListener('dragenter', function(e) { e.preventDefault(); zone.classList.add('drag-over'); });
        zone.addEventListener('dragover',  function(e) { e.preventDefault(); zone.classList.add('drag-over'); });
        zone.addEventListener('dragleave', function(e) { e.preventDefault(); zone.classList.remove('drag-over'); });
        zone.addEventListener('drop', function(e) {
            e.preventDefault();
            zone.classList.remove('drag-over');
            if (e.dataTransfer && e.dataTransfer.files.length) {
                addFiles(e.dataTransfer.files);
            }
        });

        // Clear all
        clearBtn.addEventListener('click', function() {
            buffered = [];
            picker.value = '';
            render();
        });

        // On submit: copy buffered files into the form input via DataTransfer, then show progress
        form.addEventListener('submit', function(e) {
            if (!buffered.length) {
                e.preventDefault();
                return;
            }

            // Build a new DataTransfer with our buffered files and assign to the form input
            var dt = new DataTransfer();
            buffered.forEach(function(f) { dt.items.add(f); });
            formInput.files = dt.files;

            // Show progress animation
            var prog = document.getElementById('uploadProgress');
            var fill = document.getElementById('progressFill');
            var pct  = document.getElementById('progressPct');
            prog.style.display = 'block';
            uploadBtn.disabled = true;
            uploadBtn.innerHTML = '<i class="bi bi-hourglass-split"></i> Uploading…';

            // Update localStorage for recent transfers before submission
            var recent = JSON.parse(localStorage.getItem('recent_floats') || '[]');
            buffered.forEach(function(f) {
                recent.unshift({
                    name: f.name,
                    type: 'Device upload',
                    time: 'Just now',
                    timestamp: Date.now()
                });
            });
            localStorage.setItem('recent_floats', JSON.stringify(recent.slice(0, 20)));

            var p = 0;
            var iv = setInterval(function() {
                p = Math.min(p + Math.random() * 12, 88);
                fill.style.width = p + '%';
                pct.textContent  = Math.floor(p) + '%';
            }, 300);
            setTimeout(function() { clearInterval(iv); }, 15000);
            // Allow form to submit naturally
        });

        // Keyboard accessibility on drop zone
        zone.setAttribute('tabindex', '0');
        zone.setAttribute('role', 'button');
        zone.setAttribute('aria-label', 'Click or drop files to upload');
        zone.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); picker.click(); }
        });
    })();

    function importAlert(source) {
        alert(source + ' integration coming soon!\n\nUse the Upload From Device panel to upload files from your computer.');
    }

    function toggleUrlImport() {
        var sec = document.getElementById('urlImportSection');
        var albumId = document.getElementById('albumId').value;
        document.getElementById('urlAlbumId').value = albumId;
        sec.style.display = (sec.style.display === 'none') ? 'block' : 'none';
        if (sec.style.display === 'block') sec.scrollIntoView({ behavior: 'smooth' });
    }

    function renderRecentActivity() {
        var recent = JSON.parse(localStorage.getItem('recent_floats') || '[]');
        var list = document.getElementById('recentActivityList');
        if (!recent.length) return;

        list.innerHTML = recent.slice(0, 5).map(function(item) {
            return '<div class="transfer-item">' +
                '<div class="transfer-ico done"><i class="bi bi-check2"></i></div>' +
                '<div style="flex:1;min-width:0;">' +
                    '<div class="transfer-name">' + item.name + '</div>' +
                    '<div class="transfer-meta">' + item.type + ' · ' + item.time + '</div>' +
                '</div>' +
                '<span class="transfer-pct">100%</span>' +
            '</div>';
        }).join('');
    }

    // Call on load
    renderRecentActivity();



    // Track URL imports too
    document.querySelector('#urlImportSection form').addEventListener('submit', function() {
        var urlInput = this.querySelector('input[name="importUrl"]');
        var recent = JSON.parse(localStorage.getItem('recent_floats') || '[]');
        recent.unshift({
            name: urlInput.value.split('/').pop() || 'Imported URL',
            type: 'URL Import',
            time: 'Just now',
            timestamp: Date.now()
        });
        localStorage.setItem('recent_floats', JSON.stringify(recent.slice(0, 20)));
    });
    </script>
</body>
</html>
