<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="com.DigiPic4.model.User, com.DigiPic4.model.Album, com.DigiPic4.model.Photo" %>
<%@ page import="com.DigiPic4.dao.PhotoDAO" %>
<%
    User albumsUser = (User) session.getAttribute("user");
    if (albumsUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    String albumsRole = albumsUser.getRole() == null ? "" : albumsUser.getRole().trim();
    boolean albumsIsAdmin = "admin".equalsIgnoreCase(albumsRole);

    List<Album> albums       = (List<Album>) request.getAttribute("albums");
    Map<Integer,Integer> cnt = (Map<Integer,Integer>) request.getAttribute("photoCounts");
    boolean hasAlbums = albums != null && !albums.isEmpty();

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Collections – DigiPic</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style-light.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">

    <style>
        :root { --font-serif: 'Cormorant Garamond', serif; --font-sans: 'Sora', sans-serif; }

        .page-content { max-width: 1200px; margin: 0 auto; padding: 0 24px 40px; }

        .section-header { margin-bottom: 28px; display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 14px; }
        .section-header-text h5 { color:#2563eb; font-size:12px; letter-spacing:1.5px; font-weight:700; text-transform:uppercase; margin-bottom:6px; }
        .section-header-text h1 { font-size:40px; margin:0; font-family:var(--font-serif); font-weight:700; color:#1e293b; }

        /* ── Grid ─────────────────────────────── */
        .album-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 24px;
        }

        /* ── Album card (CLICKABLE CONTAINER) ─── */
        .album-card {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 16px; overflow: hidden;
            transition: all 0.25s; cursor: pointer;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            position: relative;
        }

        .album-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 14px 32px rgba(37,99,235,0.14);
            border-color: #93c5fd;
        }

        .album-card::after {
            content: 'Click to open';
            position: absolute; top: 10px; right: 10px;
            background: rgba(37,99,235,0.85); color: #fff;
            font-size: 10px; font-weight: 700; letter-spacing: 0.5px;
            padding: 3px 8px; border-radius: 20px;
            opacity: 0; transition: opacity 0.2s;
        }
        .album-card:hover::after { opacity: 1; }

        .album-thumb { width: 100%; height: 180px; object-fit: cover; display: block; pointer-events: none; }

        .album-thumb-placeholder {
            width: 100%; height: 180px;
            background: linear-gradient(135deg, #eff6ff, #e0e7ff);
            display: flex; align-items: center; justify-content: center;
            color: #93c5fd; font-size: 48px; pointer-events: none;
        }

        .album-info { padding: 16px; }

        .album-meta {
            font-size: 11px; font-weight: 700; letter-spacing: 0.5px; text-transform: uppercase;
            background: linear-gradient(135deg, #2563eb, #1e40af);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text; margin-bottom: 6px;
        }

        .album-name { font-size: 18px; font-weight: 700; color: #1e293b; font-family: var(--font-serif); margin: 0 0 4px; }
        .album-desc { font-size: 13px; color: #64748b; line-height: 1.5; margin-bottom: 14px; }

        .album-actions { display: flex; gap: 8px; }

        .album-btn {
            flex: 1; padding: 8px 10px; border-radius: 8px; font-size: 12px; font-weight: 700;
            cursor: pointer; text-align: center; transition: all 0.2s; border: 1px solid var(--border-color);
            background: var(--bg-surface-light); color: var(--text-primary); text-decoration: none;
            display: flex; align-items: center; justify-content: center; gap: 4px;
        }

        .album-btn:hover { border-color: #2563eb; color: #2563eb; background: #eff6ff; }
        .album-btn.danger:hover { border-color: #ef4444; color: #ef4444; background: #fee2e2; }

        /* ── Empty state ──────────────────────── */
        .empty-state {
            grid-column: 1/-1; display: flex; flex-direction: column; align-items: center;
            justify-content: center; min-height: 280px; border: 2px dashed var(--border-color);
            border-radius: 16px; color: #94a3b8; text-align: center; padding: 40px;
        }
        .empty-state i { font-size: 48px; margin-bottom: 14px; }
        .empty-state h3 { font-family: var(--font-serif); font-size: 24px; color: #64748b; margin: 0 0 8px; }

        /* ── Create button ────────────────────── */
        .btn-create {
            background: linear-gradient(135deg, #2563eb, #1e40af); color: #fff; border: none;
            padding: 11px 22px; border-radius: 12px; font-weight: 700; cursor: pointer;
            display: flex; align-items: center; gap: 8px;
            font-family: var(--font-sans); font-size: 14px; transition: all 0.25s;
        }
        .btn-create:hover { box-shadow: 0 6px 18px rgba(37,99,235,0.25); transform: translateY(-2px); }

        /* ── Create Modal ─────────────────────── */
        .modal-overlay {
            position: fixed; inset: 0; background: rgba(0,0,0,0.45); backdrop-filter: blur(6px);
            display: none; justify-content: center; align-items: center; z-index: 1000;
        }
        .modal-overlay.open { display: flex; }
        .modal-box {
            background: var(--bg-surface); border: 1px solid var(--border-color);
            border-radius: 20px; padding: 32px; width: 90%; max-width: 480px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15); animation: slideUp 0.2s ease;
        }
        @keyframes slideUp { from { opacity:0; transform: translateY(20px); } to { opacity:1; transform: translateY(0); } }
        .modal-box h2 { font-family: var(--font-serif); font-size: 26px; color: #1e293b; margin: 0 0 6px; }
        .modal-box p  { color: #64748b; font-size: 13px; margin-bottom: 24px; }
        .mfield { display: flex; flex-direction: column; margin-bottom: 14px; }
        .mfield label { font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #1e293b; margin-bottom: 6px; }
        .mfield input, .mfield textarea {
            padding: 11px 14px; border-radius: 10px; border: 1px solid var(--border-color);
            background: var(--bg-surface-light); color: var(--text-primary); font-family: var(--font-sans); font-size: 14px; transition: border-color 0.2s;
        }
        .mfield textarea { resize: vertical; min-height: 80px; }
        .mfield input:focus, .mfield textarea:focus { outline: none; border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37,99,235,0.12); }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }
        .btn-cancel { background: var(--bg-surface-light); border: 1px solid var(--border-color); color: var(--text-primary); padding: 10px 18px; border-radius: 10px; font-weight: 600; cursor: pointer; transition: all 0.2s; }
        .btn-cancel:hover { border-color: #94a3b8; }
        .btn-confirm { background: linear-gradient(135deg, #2563eb, #1e40af); color: #fff; border: none; padding: 10px 20px; border-radius: 10px; font-weight: 700; cursor: pointer; transition: all 0.2s; }
        .btn-confirm:hover { box-shadow: 0 4px 14px rgba(37,99,235,0.25); }

        /* ── Album Lightbox / Photo Viewer ────── */
        .album-viewer-overlay {
            position: fixed; inset: 0; background: rgba(0,0,0,0.7); backdrop-filter: blur(8px);
            z-index: 2000; display: none; flex-direction: column;
        }
        .album-viewer-overlay.open { display: flex; }

        .album-viewer-header {
            padding: 18px 28px; display: flex; align-items: center; justify-content: space-between;
            background: rgba(255,255,255,0.95); border-bottom: 1px solid #e2e8f0;
        }
        .album-viewer-header h2 { font-family: var(--font-serif); font-size: 26px; color: #1e293b; margin:0; }
        .album-viewer-close {
            width: 40px; height: 40px; border-radius: 50%; background: #f0f4f8; border: 1px solid #e2e8f0;
            cursor: pointer; font-size: 18px; display:flex; align-items:center; justify-content:center;
            transition: all 0.2s;
        }
        .album-viewer-close:hover { background: #fee2e2; color: #ef4444; }

        .album-viewer-body { flex:1; overflow-y:auto; padding: 28px; }

        .viewer-grid { columns: 3; column-gap: 16px; }
        @media(max-width:900px){ .viewer-grid { columns:2; } }
        @media(max-width:500px){ .viewer-grid { columns:1; } }

        .viewer-item {
            break-inside: avoid; margin-bottom: 16px; border-radius: 12px; overflow: hidden;
            cursor: pointer; position: relative; box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            transition: all 0.22s;
        }
        .viewer-item:hover { transform: translateY(-3px); box-shadow: 0 12px 28px rgba(37,99,235,0.18); }
        .viewer-item img { width: 100%; display: block; }
        .viewer-item-overlay {
            position: absolute; inset: 0; background: linear-gradient(to top, rgba(0,0,0,0.55) 0%, transparent 50%);
            opacity: 0; transition: opacity 0.2s; display:flex; align-items:flex-end; padding:10px;
        }
        .viewer-item:hover .viewer-item-overlay { opacity: 1; }
        .viewer-item-label { color:#fff; font-size:12px; font-weight:600; }

        .viewer-empty { text-align:center; padding:80px 20px; color:#94a3b8; }
        .viewer-empty i { font-size:48px; display:block; margin-bottom:14px; }

        /* Full image lightbox */
        .img-lightbox {
            position: fixed; inset:0; background:rgba(0,0,0,0.92); z-index:3000;
            display:none; justify-content:center; align-items:center; padding:20px;
        }
        .img-lightbox.open { display:flex; }
        .img-lightbox img { max-width:90vw; max-height:90vh; border-radius:12px; box-shadow:0 24px 60px rgba(0,0,0,0.5); }
        .img-lightbox-close {
            position:absolute; top:20px; right:24px; width:40px; height:40px; border-radius:50%;
            background:#fff; border:none; cursor:pointer; font-size:18px; display:flex;
            align-items:center; justify-content:center;
        }
        .img-lightbox-close:hover { background:#ef4444; color:#fff; }
    </style>
</head>
<body>

<jsp:include page='<%= albumsIsAdmin ? "../components/adminSidebar.jsp" : "../components/sidebar.jsp" %>' />

    <main class="main-content">
    <jsp:include page='<%= albumsIsAdmin ? "../components/adminHeader.jsp" : "../components/Header.jsp" %>' />

        <div class="page-content">
            <div class="section-header">
                <div class="section-header-text">
                    <h5>CURATION HUB</h5>
                    <h1>Your Collections</h1>
                </div>
                <button class="btn-create" onclick="openCreateModal()">
                    <i class="bi bi-plus-circle"></i> New Album
                </button>
            </div>

            <div class="album-grid" id="albumGrid">
                <% if (!hasAlbums) { %>
                    <div class="empty-state">
                        <i class="bi bi-folder2-open"></i>
                        <h3>No albums yet</h3>
                        <p>Create your first collection to start organising your archive.</p>
                        <button class="btn-create" onclick="openCreateModal()" style="margin-top:16px;">
                            <i class="bi bi-plus-circle"></i> Create Album
                        </button>
                    </div>
                <% } else {
                    for (Album a : albums) {
                        int pCount = cnt != null && cnt.containsKey(a.getAlbumId()) ? cnt.get(a.getAlbumId()) : 0;
                        // Fetch photos for this album to embed as JSON
                        PhotoDAO photoDAO = new PhotoDAO();
                        List<Photo> albumPhotos = photoDAO.findPhotosByAlbumId(a.getAlbumId());
                        // Build JSON array of photo paths
                        StringBuilder photosJson = new StringBuilder("[");
                        for (int pi = 0; pi < albumPhotos.size(); pi++) {
                            Photo ph = albumPhotos.get(pi);
                            String t = ph.getTitle() != null && !ph.getTitle().isEmpty() ? ph.getTitle() : ph.getFilePath();
                            String src = request.getContextPath() + "/uploads/" + albumsUser.getUserId() + "/" + ph.getFilePath();
                            if (pi > 0) photosJson.append(",");
                            photosJson.append("{\"src\":\"").append(src).append("\",\"title\":\"").append(t.replace("\"","\\\"")).append("\"}");
                        }
                        photosJson.append("]");
                %>
                    <div class="album-card"
                         data-album-id="<%= a.getAlbumId() %>"
                         data-album-name="<%= a.getAlbumName().replace("\"","&quot;") %>"
                         data-photos='<%= photosJson %>'
                         onclick="openAlbumViewer(this)">
                        <% if (a.getCoverImageUrl() != null && !a.getCoverImageUrl().isBlank()) { %>
                            <img class="album-thumb" src="<%= a.getCoverImageUrl() %>" alt="<%= a.getAlbumName() %>">
                        <% } else { %>
                            <div class="album-thumb-placeholder"><i class="bi bi-folder2"></i></div>
                        <% } %>
                        <div class="album-info">
                            <div class="album-meta"><%= pCount %> PHOTO<%= pCount != 1 ? "S" : "" %></div>
                            <h3 class="album-name"><%= a.getAlbumName() %></h3>
                            <% if (a.getDescription() != null && !a.getDescription().isBlank()) { %>
                                <p class="album-desc"><%= a.getDescription() %></p>
                            <% } %>
                            <div class="album-actions" onclick="event.stopPropagation()">
                                <button class="album-btn" onclick="openAlbumViewer(this.closest('.album-card'))">
                                    <i class="bi bi-images"></i> View Photos
                                </button>
                                <form action="${pageContext.request.contextPath}/albums" method="post" style="flex:1;"
                                      onsubmit="return confirm('Delete this album? This cannot be undone.');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="albumId" value="<%= a.getAlbumId() %>">
                                    <button type="submit" class="album-btn danger" style="width:100%;">
                                        <i class="bi bi-trash"></i> Delete
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                <%  }
                } %>
            </div>
        </div>
    </main>

    <%-- Create album modal --%>
    <div class="modal-overlay" id="createModal">
        <div class="modal-box">
            <h2>New Collection</h2>
            <p>Give your album a name and optional details.</p>
            <form action="${pageContext.request.contextPath}/albums" method="post">
                <input type="hidden" name="action" value="create">
                <div class="mfield"><label>Album Name *</label><input type="text" name="albumName" required maxlength="255" placeholder="e.g. Summer 2025"></div>
                <div class="mfield"><label>Description</label><textarea name="description" maxlength="500" placeholder="Short description…"></textarea></div>
                <div class="mfield"><label>Cover Image URL</label><input type="url" name="coverImageUrl" placeholder="https://…"></div>
                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeCreateModal()">Cancel</button>
                    <button type="submit" class="btn-confirm"><i class="bi bi-folder-plus"></i> Create Album</button>
                </div>
            </form>
        </div>
    </div>

    <%-- Album photo viewer --%>
    <div class="album-viewer-overlay" id="albumViewer">
        <div class="album-viewer-header">
            <div>
                <h2 id="viewerAlbumName">Album</h2>
                <div style="font-size:13px; color:#64748b;" id="viewerPhotoCount"></div>
            </div>
            <button class="album-viewer-close" onclick="closeAlbumViewer()"><i class="bi bi-x-lg"></i></button>
        </div>
        <div class="album-viewer-body">
            <div class="viewer-grid" id="viewerGrid"></div>
        </div>
    </div>

    <%-- Full image lightbox --%>
    <div class="img-lightbox" id="imgLightbox" onclick="closeImgLightbox(event)">
        <button class="img-lightbox-close" onclick="closeImgLightbox()"><i class="bi bi-x"></i></button>
        <img id="imgLightboxSrc" src="" alt="">
    </div>

    <script>
        // ── Create modal ─────────────────────────────────────────────
        function openCreateModal()  { document.getElementById('createModal').classList.add('open'); }
        function closeCreateModal() { document.getElementById('createModal').classList.remove('open'); }
        document.getElementById('createModal').addEventListener('click', function(e) { if(e.target===this) closeCreateModal(); });

        // ── Album viewer ─────────────────────────────────────────────
        function openAlbumViewer(card) {
            const name   = card.getAttribute('data-album-name');
            const photos = JSON.parse(card.getAttribute('data-photos') || '[]');

            document.getElementById('viewerAlbumName').textContent = name;
            document.getElementById('viewerPhotoCount').textContent = photos.length + ' photo' + (photos.length !== 1 ? 's' : '');

            const grid = document.getElementById('viewerGrid');
            if (!photos.length) {
                grid.innerHTML = '<div class="viewer-empty"><i class="bi bi-images"></i><h3 style="font-family:var(--font-serif);color:#64748b;">No photos in this album yet</h3><p>Upload photos and assign them to this album.</p></div>';
            } else {
                grid.innerHTML = photos.map(p => `
                    <div class="viewer-item" onclick="openImgLightbox('${p.src}')">
                        <img src="${p.src}" alt="${p.title}" loading="lazy" onerror="this.src='https://via.placeholder.com/400x300?text=Image+not+found'">
                        <div class="viewer-item-overlay">
                            <span class="viewer-item-label">${p.title}</span>
                        </div>
                    </div>`).join('');
            }

            document.getElementById('albumViewer').classList.add('open');
            document.body.style.overflow = 'hidden';
        }

        function closeAlbumViewer() {
            document.getElementById('albumViewer').classList.remove('open');
            document.body.style.overflow = '';
        }

        // ── Full image lightbox ──────────────────────────────────────
        function openImgLightbox(src) {
            document.getElementById('imgLightboxSrc').src = src;
            document.getElementById('imgLightbox').classList.add('open');
        }

        function closeImgLightbox(e) {
            if (e && e.target !== document.getElementById('imgLightbox') && !e.target.closest('.img-lightbox-close')) return;
            document.getElementById('imgLightbox').classList.remove('open');
        }

        // Esc key closes viewers
        document.addEventListener('keydown', e => {
            if (e.key === 'Escape') {
                closeImgLightbox();
                closeAlbumViewer();
                closeCreateModal();
            }
        });

        // ── Local search support (for Header.jsp's localSearch) ──────
        window._localAlbums = Array.from(document.querySelectorAll('.album-card')).map(c => ({
            name: c.getAttribute('data-album-name'),
            el: c
        }));
    </script>
</body>
</html>
