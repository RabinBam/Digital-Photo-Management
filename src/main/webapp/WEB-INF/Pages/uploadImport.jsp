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

        /* ── URL import ─────────────────────────────── */
        .url-import-wrap { margin-top: 18px; }
        .url-import-wrap label {
            font-size: 12px; font-weight: 700; letter-spacing: 0.5px; text-transform: uppercase;
            color: #1e293b; margin-bottom: 8px; display: block;
        }
        .url-import-row { display:flex; gap:10px; align-items:center; }
        .url-import-input {
            flex: 1; padding: 11px 14px; border-radius: 10px;
            border: 1.5px solid var(--border-color); background: var(--bg-surface-light);
            font-family: var(--font-sans); font-size: 14px; color: #1e293b;
        }
        .url-import-input:focus { outline:none; border-color:#2563eb; box-shadow:0 0 0 3px rgba(37,99,235,0.1); }
        .btn-url {
            padding: 11px 16px; border-radius: 10px; border: 1px solid #2563eb; background:#eff6ff;
            color:#1e40af; font-weight:700; cursor:pointer; font-family: var(--font-sans);
        }
        .btn-url:hover { background:#dbeafe; }
        .url-import-note { margin-top: 8px; font-size: 11px; color:#64748b; line-height:1.5; }

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

        /* ── Recent images float ───────────────────── */
        .recent-float {
            position: fixed; right: 18px; bottom: 18px; width: 250px; z-index: 1200;
            background: rgba(255,255,255,0.96); backdrop-filter: blur(10px);
            border: 1px solid var(--border-color); border-radius: 16px; box-shadow: 0 16px 38px rgba(15,23,42,0.16);
            overflow: hidden;
        }
        .recent-float-header {
            padding: 12px 14px; font-size: 11px; font-weight: 800; text-transform: uppercase; letter-spacing: 1px;
            color: #64748b; border-bottom: 1px solid var(--border-color); display:flex; align-items:center; gap:8px;
        }
        .recent-float-list { max-height: 260px; overflow-y: auto; }
        .recent-float-item {
            display:flex; gap:10px; padding: 10px 12px; align-items:center; cursor:pointer; text-decoration:none; color: inherit;
            border-bottom: 1px solid rgba(148,163,184,0.16);
        }
        .recent-float-item:last-child { border-bottom:none; }
        .recent-float-item:hover { background:#eff6ff; }
        .recent-float-thumb { width: 42px; height: 42px; border-radius: 10px; object-fit:cover; flex-shrink:0; background:#e2e8f0; }
        .recent-float-meta { min-width:0; }
        .recent-float-title { font-size: 12px; font-weight: 700; color:#1e293b; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .recent-float-sub { font-size: 10px; color:#94a3b8; margin-top:2px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .recent-float-empty { padding: 14px; color:#94a3b8; font-size: 12px; text-align:center; }

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

                        <%-- URL import --%>
                        <div class="url-import-wrap">
                            <label for="importUrl">Import From URL</label>
                            <div class="url-import-row">
                                <input type="url" id="importUrl" name="importUrl" class="url-import-input" placeholder="https://example.com/photo.jpg">
                                <button type="button" class="btn-url" id="importUrlBtn"><i class="bi bi-link-45deg"></i> Import URL</button>
                            </div>
                            <div class="url-import-note">Paste a direct image URL. The file will be downloaded into <strong>WEB-INF/image/user/&lt;user&gt;/albums/&lt;album&gt;</strong>.</div>
                        </div>

                        <%-- Optional default metadata --%>
                        <div style="margin-top:12px; display:flex; gap:10px;">
                            <div style="flex:1;">
                                <label style="font-size:12px; font-weight:700; text-transform:uppercase; color:#1e293b; display:block; margin-bottom:6px;">Default title</label>
                                <input type="text" id="defaultTitle" name="defaultTitle" placeholder="Optional title applied to uploaded items" style="width:100%; padding:10px 12px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-surface-light);">
                            </div>
                            <div style="flex:1;">
                                <label style="font-size:12px; font-weight:700; text-transform:uppercase; color:#1e293b; display:block; margin-bottom:6px;">Location tag</label>
                                <input type="text" id="defaultLocation" name="defaultLocation" placeholder="Optional location (e.g. London, Studio)" style="width:100%; padding:10px 12px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-surface-light);">
                            </div>
                        </div>

                        <div style="margin-top:10px; font-size:12px; color:#64748b;">Storage preview: <code id="storagePathPreview">WEB-INF/image/user/<%= uploadUser.getUserId() %>/albums/&lt;album&gt;/</code></div>

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
                            <strong>Tip:</strong> Organise uploads into albums before importing large batches — the album selector on the left assigns files automatically.
                        </div>
                    </section>

                    <section class="panel">
                        <h2>Recent Transfers</h2>
                        <p class="panel-subtitle">Latest upload activity.</p>
                        <div class="transfer-item">
                            <div class="transfer-ico done"><i class="bi bi-check2"></i></div>
                            <div style="flex:1;min-width:0;">
                                <div class="transfer-name">Vacation_Sea_View_01.jpg</div>
                                <div class="transfer-meta">Device upload · 24 min ago</div>
                            </div>
                            <span class="transfer-pct">100%</span>
                        </div>
                        <div class="transfer-item">
                            <div class="transfer-ico done"><i class="bi bi-check2"></i></div>
                            <div style="flex:1;min-width:0;">
                                <div class="transfer-name">Family_Backup_2024.zip</div>
                                <div class="transfer-meta">Cloud Drive sync · 3 hours ago</div>
                            </div>
                            <span class="transfer-pct">100%</span>
                        </div>
                        <div class="transfer-item">
                            <div class="transfer-ico pend"><i class="bi bi-hourglass-split"></i></div>
                            <div style="flex:1;min-width:0;">
                                <div class="transfer-name">ShortClip.mp4</div>
                                <div class="transfer-meta">URL fetch in progress</div>
                            </div>
                            <span class="transfer-pct">41%</span>
                        </div>
                    </section>

                    <section class="panel" style="padding:18px;">
                        <h2 style="font-size:22px; margin-bottom:4px;">Recent Images</h2>
                        <p class="panel-subtitle" style="margin-bottom:12px;">Images you opened in Explore or Gallery.</p>
                        <div id="recentInlineHost" style="max-height:240px; overflow-y:auto;"></div>
                    </section>

                </div>
            </div>
        </div>
    </main>

    <div class="recent-float" id="recentFloat">
        <div class="recent-float-header"><i class="bi bi-clock-history"></i> Recent images</div>
        <div class="recent-float-list" id="recentFloatList"></div>
    </div>

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
        var importUrl = document.getElementById('importUrl');
        var importUrlBtn = document.getElementById('importUrlBtn');
        var recentKey = 'digipic_recent_media';

        var ALLOWED = ['.jpg', '.jpeg', '.png', '.gif', '.mp4', '.mov', '.pdf'];
        var ICONS = { image: 'bi-image', video: 'bi-camera-video', application: 'bi-file-earmark-pdf' };

        function loadRecent() {
            try { return JSON.parse(localStorage.getItem(recentKey) || '[]'); } catch (e) { return []; }
        }

        function saveRecent(items) {
            localStorage.setItem(recentKey, JSON.stringify(items.slice(0, 8)));
            renderRecent();
        }

        function rememberRecent(item) {
            if (!item || !item.src) return;
            var items = loadRecent().filter(function (x) { return x.src !== item.src; });
            items.unshift({ src: item.src, title: item.title || 'Untitled', sub: item.sub || 'Upload' });
            saveRecent(items);
        }

        function renderRecent() {
            var host = document.getElementById('recentFloatList');
            var inlineHost = document.getElementById('recentInlineHost');
            var items = loadRecent();
            var html = '';
            if (!items.length) {
                html = '<div class="recent-float-empty">Click a photo in Explore or Gallery to pin it here.</div>';
            } else {
                html = items.map(function (item) {
                    return '<a class="recent-float-item" href="' + item.src + '" target="_blank" rel="noopener">' +
                        '<img class="recent-float-thumb" src="' + item.src + '" alt="">' +
                        '<div class="recent-float-meta">' +
                            '<div class="recent-float-title">' + item.title + '</div>' +
                            '<div class="recent-float-sub">' + item.sub + '</div>' +
                        '</div>' +
                    '</a>';
                }).join('');
            }
            if (host) host.innerHTML = html;
            if (inlineHost) inlineHost.innerHTML = html;
        }

        function titleFromUrl(url) {
            try {
                var clean = url.split('?')[0].split('#')[0];
                var name = clean.substring(clean.lastIndexOf('/') + 1) || 'Imported image';
                return name.replace(/\.[^.]+$/, '').replace(/[_-]+/g, ' ').trim() || 'Imported image';
            } catch (e) {
                return 'Imported image';
            }
        }

        function syncSubmitState() {
            var hasUrl = importUrl && importUrl.value && importUrl.value.trim().length > 0;
            uploadBtn.disabled = !(buffered.length || hasUrl);
        }

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
                syncSubmitState();
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
            syncSubmitState();

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
            if (importUrl) importUrl.value = '';
            render();
            syncSubmitState();
        });

        if (importUrl) {
            importUrl.addEventListener('input', syncSubmitState);
        }

        if (importUrlBtn) {
            importUrlBtn.addEventListener('click', function() {
                if (importUrl && importUrl.value.trim()) {
                    form.requestSubmit();
                } else {
                    var url = prompt('Paste the direct URL of the media file to import:');
                    if (url && url.trim()) {
                        importUrl.value = url.trim();
                        rememberRecent({ src: importUrl.value.trim(), title: titleFromUrl(importUrl.value.trim()), sub: 'URL import' });
                        syncSubmitState();
                        form.requestSubmit();
                    }
                }
            });
        }

        // On submit: copy buffered files into the form input via DataTransfer, then show progress
        form.addEventListener('submit', function(e) {
            var hasUrl = importUrl && importUrl.value && importUrl.value.trim().length > 0;
            if (!buffered.length && !hasUrl) {
                e.preventDefault();
                return;
            }

            if (buffered.length) {
                // Build a new DataTransfer with our buffered files and assign to the form input
                var dt = new DataTransfer();
                buffered.forEach(function(f) { dt.items.add(f); });
                formInput.files = dt.files;
            }

            if (hasUrl) {
                rememberRecent({ src: importUrl.value.trim(), title: titleFromUrl(importUrl.value.trim()), sub: 'URL import' });
            }

            // Show progress animation
            var prog = document.getElementById('uploadProgress');
            var fill = document.getElementById('progressFill');
            var pct  = document.getElementById('progressPct');
            prog.style.display = 'block';
            uploadBtn.disabled = true;
            uploadBtn.innerHTML = '<i class="bi bi-hourglass-split"></i> Uploading…';

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

        renderRecent();
        syncSubmitState();
        // Storage preview: update when album selection changes
        var albumSelectEl = document.getElementById('albumId');
        var storagePreviewEl = document.getElementById('storagePathPreview');
        function updateStoragePreview() {
            if (!storagePreviewEl || !albumSelectEl) return;
            var aid = albumSelectEl.value && albumSelectEl.value.trim() ? albumSelectEl.value.trim() : '<album>';
            storagePreviewEl.textContent = 'WEB-INF/image/user/<%= uploadUser.getUserId() %>/albums/' + aid + '/';
        }
        if (albumSelectEl) albumSelectEl.addEventListener('change', updateStoragePreview);
        updateStoragePreview();
    })();

    function importAlert(source) {
        alert(source + ' integration coming soon!\n\nUse the Upload From Device panel to upload files from your computer.');
    }

    function importFromUrl() {
        var url = prompt('Paste the direct URL of the media file to import:');
        if (url && url.trim()) {
            var input = document.getElementById('importUrl');
            if (input) {
                input.value = url.trim();
                input.dispatchEvent(new Event('input'));
            }
            alert('URL added to the import form. Click Start Upload to download it into your gallery.');
        }
    }
    </script>
</body>
</html>
