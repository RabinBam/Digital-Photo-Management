<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="com.DigiPic4.model.User, com.DigiPic4.model.Album" %>
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

        /* ── Header ───────────────────────────── */
        .section-header { margin-bottom: 28px; display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 14px; }
        .section-header-text h5 { color:#2563eb; font-size:12px; letter-spacing:1.5px; font-weight:700; text-transform:uppercase; margin-bottom:6px; }
        .section-header-text h1 { font-size:40px; margin:0; font-family:var(--font-serif); font-weight:700; color:#1e293b; }

        /* ── Grid ─────────────────────────────── */
        .album-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 24px;
        }

        /* ── Album card ───────────────────────── */
        .album-card {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 16px; overflow: hidden;
            transition: all 0.25s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

        .album-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 14px 32px rgba(37,99,235,0.14);
            border-color: #93c5fd;
        }

        .album-thumb {
            width: 100%; height: 180px; object-fit: cover; display: block;
        }

        .album-thumb-placeholder {
            width: 100%; height: 180px;
            background: linear-gradient(135deg, #eff6ff, #e0e7ff);
            display: flex; align-items: center; justify-content: center;
            color: #93c5fd; font-size: 48px;
        }

        .album-info { padding: 16px; }

        .album-meta {
            font-size: 11px; font-weight: 700; letter-spacing: 0.5px; text-transform: uppercase;
            background: linear-gradient(135deg, #2563eb, #1e40af);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            background-clip: text; margin-bottom: 6px;
        }

        .album-name {
            font-size: 18px; font-weight: 700; color: #1e293b;
            font-family: var(--font-serif); margin: 0 0 4px;
        }

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
            grid-column: 1/-1;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            min-height: 280px; border: 2px dashed var(--border-color);
            border-radius: 16px; color: #94a3b8; text-align: center; padding: 40px;
        }

        .empty-state i { font-size: 48px; margin-bottom: 14px; }
        .empty-state h3 { font-family: var(--font-serif); font-size: 24px; color: #64748b; margin: 0 0 8px; }

        /* ── Create button ────────────────────── */
        .btn-create {
            background: linear-gradient(135deg, #2563eb, #1e40af);
            color: #fff; border: none; padding: 11px 22px;
            border-radius: 12px; font-weight: 700; cursor: pointer;
            display: flex; align-items: center; gap: 8px;
            font-family: var(--font-sans); font-size: 14px; transition: all 0.25s;
        }

        .btn-create:hover { box-shadow: 0 6px 18px rgba(37,99,235,0.25); transform: translateY(-2px); }

        /* ── Modal ────────────────────────────── */
        .modal-overlay {
            position: fixed; inset: 0;
            background: rgba(0,0,0,0.45); backdrop-filter: blur(6px);
            display: none; justify-content: center; align-items: center; z-index: 1000;
        }

        .modal-overlay.open { display: flex; }

        .modal-box {
            background: var(--bg-surface); border: 1px solid var(--border-color);
            border-radius: 20px; padding: 32px; width: 90%; max-width: 480px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            animation: slideUp 0.2s ease;
        }

        @keyframes slideUp {
            from { opacity:0; transform: translateY(20px); }
            to   { opacity:1; transform: translateY(0); }
        }

        .modal-box h2 { font-family: var(--font-serif); font-size: 26px; color: #1e293b; margin: 0 0 6px; }
        .modal-box p  { color: #64748b; font-size: 13px; margin-bottom: 24px; }

        .mfield { display: flex; flex-direction: column; margin-bottom: 14px; }
        .mfield label { font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #1e293b; margin-bottom: 6px; }

        .mfield input, .mfield textarea {
            padding: 11px 14px; border-radius: 10px;
            border: 1px solid var(--border-color); background: var(--bg-surface-light);
            color: var(--text-primary); font-family: var(--font-sans); font-size: 14px;
            transition: border-color 0.2s;
        }

        .mfield textarea { resize: vertical; min-height: 80px; }

        .mfield input:focus, .mfield textarea:focus {
            outline: none; border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37,99,235,0.12);
        }

        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }

        .btn-cancel {
            background: var(--bg-surface-light); border: 1px solid var(--border-color);
            color: var(--text-primary); padding: 10px 18px; border-radius: 10px;
            font-weight: 600; cursor: pointer; font-family: var(--font-sans); transition: all 0.2s;
        }

        .btn-cancel:hover { border-color: #94a3b8; }

        .btn-confirm {
            background: linear-gradient(135deg, #2563eb, #1e40af);
            color: #fff; border: none; padding: 10px 20px; border-radius: 10px;
            font-weight: 700; cursor: pointer; font-family: var(--font-sans); transition: all 0.2s;
        }

        .btn-confirm:hover { box-shadow: 0 4px 14px rgba(37,99,235,0.25); }

        @media (max-width: 600px) {
            .section-header { flex-direction: column; align-items: flex-start; }
        }
    </style>
</head>
<body>

    <jsp:include page='<%= albumsIsAdmin ? "adminSidebar.jsp" : "sidebar.jsp" %>' />

    <main class="main-content">
        <jsp:include page='<%= albumsIsAdmin ? "adminHeader.jsp" : "Header.jsp" %>' />

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

            <div class="album-grid">
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
                %>
                    <div class="album-card">
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
                            <div class="album-actions">
                                <a href="${pageContext.request.contextPath}/gallery" class="album-btn">
                                    <i class="bi bi-images"></i> View
                                </a>
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

                <div class="mfield">
                    <label>Album Name *</label>
                    <input type="text" name="albumName" required maxlength="255" placeholder="e.g. Summer 2025">
                </div>
                <div class="mfield">
                    <label>Description</label>
                    <textarea name="description" maxlength="500" placeholder="Short description of this collection…"></textarea>
                </div>
                <div class="mfield">
                    <label>Cover Image URL</label>
                    <input type="url" name="coverImageUrl" placeholder="https://…">
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeCreateModal()">Cancel</button>
                    <button type="submit" class="btn-confirm"><i class="bi bi-folder-plus"></i> Create Album</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openCreateModal()  { document.getElementById('createModal').classList.add('open'); }
        function closeCreateModal() { document.getElementById('createModal').classList.remove('open'); }

        document.getElementById('createModal').addEventListener('click', function(e) {
            if (e.target === this) closeCreateModal();
        });
    </script>
</body>
</html>
