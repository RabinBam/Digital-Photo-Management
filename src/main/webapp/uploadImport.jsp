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

    // Albums for the target selector (passed by UploadImportServlet)
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
            max-width: 1280px; margin: 0 auto; padding: 0 28px 48px;
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
            transition: box-shadow 0.2s, transform 0.2s;
        }
        .stat-card:hover { box-shadow: 0 6px 18px rgba(37,99,235,0.1); transform: translateY(-2px); }
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
            transition: all 0.25s; position: relative;
        }
        .upload-zone:hover, .upload-zone.drag-over {
            border-color: #2563eb; background: #eff6ff;
            box-shadow: 0 0 0 4px rgba(37,99,235,0.08);
        }
        .upload-zone i { font-size: 48px; color: #2563eb; margin-bottom: 14px; display: block; }
        .upload-zone h3 { font-family: var(--font-serif); font-size: 22px; color: #1e293b; margin: 0 0 6px; }
        .upload-zone p  { color: #64748b; font-size: 13px; line-height: 1.6; margin: 0; }
        .upload-zone .hint {
            margin-top: 12px; font-size: 11px; font-weight: 700; letter-spacing: 0.8px;
            text-transform: uppercase; color: #2563eb;
        }
        .upload-zone input[type="file"] {
            position: absolute; inset: 0; opacity: 0; cursor: pointer; width: 100%; height: 100%;
        }

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
        .selected-files {
            display: none; background: #f8fafc; border: 1px solid var(--border-color);
            border-radius: 12px; padding: 16px; margin-top: 16px;
        }
        .selected-files h4 { font-size: 13px; font-weight: 700; color: #1e293b; margin: 0 0 12px; }
        .file-list { display: flex; flex-direction: column; gap: 8px; max-height: 200px; overflow-y: auto; }
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
            font-size: 16px; padding: 4px; border-radius: 6px; transition: color 0.2s;
            flex-shrink: 0;
        }
        .remove-btn:hover { color: #ef4444; background: #fee2e2; }

        /* ── Progress bar ───────────────────────────── */
        .upload-progress { display: none; margin-top: 16px; }
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
        .btn-upload:hover { box-shadow: 0 6px 18px rgba(37,99,235,0.25); transform: translateY(-1px); }
        .btn-upload:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
        .btn-clear {
            background: var(--bg-surface-light); color: var(--text-primary);
            border: 1px solid var(--border-color); padding: 11px 18px; border-radius: 10px;
            font-weight: 600; cursor: pointer; transition: all 0.2s;
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
        .transfer-ico.fail { background: #fee2e2; color: #dc2626; }
        .transfer-info { flex: 1; min-width: 0; }
        .transfer-name { font-size: 13px; font-weight: 600; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .transfer-meta { font-size: 11px; color: #94a3b8; margin-top: 2px; }
        .transfer-pct  { font-size: 12px; font-weight: 700; color: #2563eb; flex-shrink: 0; }

        /* ── Responsive ─────────────────────────────── */
        @media (max-width: 1100px) { .upload-layout { grid-template-columns: 1fr; } }
        @media (max-width: 768px)  { .stats-row { grid-template-columns: 1fr; } .import-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

    <%-- BUG FIX: removed escaped-quote JSP include that caused compile error --%>
    <% if (uploadIsAdmin) { %>
        <jsp:include page="adminSidebar.jsp" />
    <% } else { %>
        <jsp:include page="sidebar.jsp" />
    <% } %>

    <main class="main-content">
        <% if (uploadIsAdmin) { %>
            <jsp:include page="adminHeader.jsp" />
        <% } else { %>
            <jsp:include page="Header.jsp" />
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
                    <p class="panel-subtitle">Drag files onto the zone below or click to browse. All selected files are listed before you submit.</p>

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

                    <form id="uploadForm"
                          action="<%= request.getContextPath() %>/uploadImport"
                          method="post"
                          enctype="multipart/form-data">

                        <%-- Drop zone with embedded file input --%>
                        <div class="upload-zone" id="uploadZone">
                            <input type="file" id="fileInput" name="file" multiple
                                   accept="image/*,video/*,.pdf">
                            <i class="bi bi-cloud-arrow-up"></i>
                            <h3>Drag &amp; Drop Your Media</h3>
                            <p>Drop files anywhere in this box, or click to open the file picker.</p>
                            <div class="hint">JPG · PNG · GIF · MP4 · MOV · PDF · Max 500 MB each</div>
                        </div>

                        <%-- Album selector --%>
                        <div class="album-selector-wrap">
                            <label for="albumId">Save to Album</label>
                            <select id="albumId" name="albumId" class="album-select">
                                <option value="">— Auto-create "My Uploads" —</option>
                                <% if (uploadAlbums != null) {
                                    for (Album al : uploadAlbums) { %>
                                        <option value="<%= al.getAlbumId() %>"><%= al.getAlbumName() %></option>
                                <%  }
                                } %>
                            </select>
                        </div>

                        <%-- Selected files list --%>
                        <div class="selected-files" id="selectedFiles">
                            <h4 id="selectedCount">Selected Files (0)</h4>
                            <div class="file-list" id="fileList"></div>
                        </div>

                        <%-- Upload progress (shown during form submit) --%>
                        <div class="upload-progress" id="uploadProgress">
                            <div class="progress-header">
                                <span id="progressLabel">Uploading…</span>
                                <span id="progressPct">0%</span>
                            </div>
                            <div class="progress-track">
                                <div class="progress-fill" id="progressFill"></div>
                            </div>
                        </div>

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

                    <%-- Import sources --%>
                    <section class="panel">
                        <h2>Import Sources</h2>
                        <p class="panel-subtitle">Connect cloud services or paste a URL to pull in media without leaving the dashboard.</p>

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
                            <div class="import-card" onclick="importFromUrl()">
                                <i class="bi bi-link-45deg"></i>
                                <h4>From URL</h4>
                                <p>Paste any direct file link</p>
                            </div>
                        </div>

                        <div class="side-note">
                            <strong>Tip:</strong> Organise uploads into albums before importing large batches — the album selector above assigns files automatically.
                        </div>
                    </section>

                    <%-- Recent transfers --%>
                    <section class="panel">
                        <h2>Recent Transfers</h2>
                        <p class="panel-subtitle">Latest upload and import activity.</p>

                        <div class="transfer-item">
                            <div class="transfer-ico done"><i class="bi bi-check2"></i></div>
                            <div class="transfer-info">
                                <div class="transfer-name">Vacation_Sea_View_01.jpg</div>
                                <div class="transfer-meta">Uploaded from device · 24 min ago</div>
                            </div>
                            <span class="transfer-pct">100%</span>
                        </div>
                        <div class="transfer-item">
                            <div class="transfer-ico done"><i class="bi bi-check2"></i></div>
                            <div class="transfer-info">
                                <div class="transfer-name">Family_Backup_2024.zip</div>
                                <div class="transfer-meta">Cloud Drive sync · 3 hours ago</div>
                            </div>
                            <span class="transfer-pct">100%</span>
                        </div>
                        <div class="transfer-item">
                            <div class="transfer-ico pend"><i class="bi bi-hourglass-split"></i></div>
                            <div class="transfer-info">
                                <div class="transfer-name">ShortClip.mp4</div>
                                <div class="transfer-meta">URL fetch in progress · Today</div>
                            </div>
                            <span class="transfer-pct">41%</span>
                        </div>
                    </section>

                </div>
            </div>
        </div>
    </main>

    <script>
    (function () {
        const zone      = document.getElementById('uploadZone');
        const input     = document.getElementById('fileInput');
        const selBox    = document.getElementById('selectedFiles');
        const fileList  = document.getElementById('fileList');
        const countLbl  = document.getElementById('selectedCount');
        const uploadBtn = document.getElementById('uploadBtn');
        const clearBtn  = document.getElementById('clearBtn');
        const form      = document.getElementById('uploadForm');
        let buffered    = [];

        const ICONS = {
            image: 'bi-image',
            video: 'bi-camera-video',
            application: 'bi-file-earmark-pdf',
            default: 'bi-file-earmark'
        };

        function iconForType(type) {
            const base = (type || '').split('/')[0];
            return ICONS[base] || ICONS.default;
        }

        function fmt(bytes) {
            if (!bytes) return '0 B';
            const s = ['B','KB','MB','GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(1024));
            return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + s[i];
        }

        function render() {
            if (!buffered.length) {
                selBox.style.display = 'none';
                uploadBtn.disabled   = true;
                return;
            }
            countLbl.textContent = 'Selected Files (' + buffered.length + ')';
            fileList.innerHTML   = buffered.map((f, i) => `
                <div class="file-item">
                    <div class="file-item-icon"><i class="bi ${iconForType(f.type)}"></i></div>
                    <div class="file-item-info">
                        <div class="file-name">${f.name}</div>
                        <div class="file-size">${fmt(f.size)}</div>
                    </div>
                    <button class="remove-btn" type="button" data-idx="${i}" title="Remove">
                        <i class="bi bi-x-lg"></i>
                    </button>
                </div>`).join('');
            selBox.style.display = 'block';
            uploadBtn.disabled   = false;

            // Wire remove buttons
            fileList.querySelectorAll('.remove-btn').forEach(btn => {
                btn.onclick = () => {
                    buffered.splice(+btn.dataset.idx, 1);
                    syncInput();
                    render();
                };
            });
        }

        function syncInput() {
            const dt = new DataTransfer();
            buffered.forEach(f => dt.items.add(f));
            input.files = dt.files;
        }

        function addFiles(newFiles) {
            const allowed = ['.jpg','.jpeg','.png','.gif','.mp4','.mov','.pdf'];
            Array.from(newFiles).forEach(f => {
                const ext = '.' + f.name.split('.').pop().toLowerCase();
                if (allowed.includes(ext)) buffered.push(f);
                else alert(f.name + ' is not a supported file type.');
            });
            syncInput();
            render();
        }

        // File picker
        input.onchange = e => addFiles(e.target.files);

        // Drag & drop on the zone (the native input already handles clicks)
        ['dragenter','dragover'].forEach(ev =>
            zone.addEventListener(ev, e => { e.preventDefault(); zone.classList.add('drag-over'); }));
        ['dragleave','drop'].forEach(ev =>
            zone.addEventListener(ev, e => { e.preventDefault(); zone.classList.remove('drag-over'); }));
        zone.addEventListener('drop', e => addFiles(e.dataTransfer.files));

        // Clear
        clearBtn.onclick = () => {
            buffered = [];
            input.value = '';
            render();
        };

        // Animate progress on submit
        form.onsubmit = () => {
            if (!buffered.length) return false;
            const prog = document.getElementById('uploadProgress');
            const fill = document.getElementById('progressFill');
            const pct  = document.getElementById('progressPct');
            prog.style.display = 'block';
            uploadBtn.disabled = true;
            uploadBtn.innerHTML = '<i class="bi bi-hourglass-split"></i> Uploading…';
            let p = 0;
            const iv = setInterval(() => {
                p = Math.min(p + Math.random() * 15, 90);
                fill.style.width = p + '%';
                pct.textContent  = Math.floor(p) + '%';
            }, 250);
            // Let the browser actually submit
            setTimeout(() => clearInterval(iv), 10000);
            return true;
        };
    })();

    function importAlert(source) {
        alert(source + ' integration coming soon!\n\nYou can currently upload files directly from your device using the form on the left.');
    }

    function importFromUrl() {
        const url = prompt('Paste the direct URL of the media file you want to import:');
        if (url && url.trim()) {
            alert('URL import queued:\n' + url.trim() + '\n\nThis feature will be wired to the backend upload pipeline in a future release.');
        }
    }
    </script>
</body>
</html>
