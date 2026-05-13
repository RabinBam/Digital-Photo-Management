<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.DigiPic4.model.User" %>
<%@ page import="com.DigiPic4.model.Photo" %>
<%
    User galleryUser = (User) session.getAttribute("user");
    if (galleryUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    String galleryRole = galleryUser.getRole() == null ? "" : galleryUser.getRole().trim();
    boolean isAdmin = "admin".equalsIgnoreCase(galleryRole);

    List<Photo> photos = (List<Photo>) request.getAttribute("photos");
    boolean hasPhotos  = photos != null && !photos.isEmpty();

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gallery – DigiPic</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style-light.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">

    <style>
        :root { --font-serif: 'Cormorant Garamond', serif; --font-sans: 'Sora', sans-serif; }

        .page-container { max-width: 1400px; margin: 0 auto; padding: 0 24px 40px; }

        /* ── Section header ───────────────────── */
        .section-header { margin-bottom: 22px; }
        .section-header h5 { color:#2563eb; font-size:12px; letter-spacing:1px; font-weight:700; text-transform:uppercase; margin-bottom:6px; }
        .section-header h1 { font-size:40px; margin:0; font-family:var(--font-serif); font-weight:700; color:#1e293b; }

        /* ── Layout ───────────────────────────── */
        .gallery-layout {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 28px;
            align-items: start;
        }

        /* ── Masonry grid ─────────────────────── */
        .gallery-scroll {
            overflow-y: auto;
            max-height: 72vh;
            padding-right: 8px;
        }

        .gallery-scroll::-webkit-scrollbar { width: 5px; }
        .gallery-scroll::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }

        .masonry { columns: 2; column-gap: 16px; }

        .masonry-item {
            break-inside: avoid;
            margin-bottom: 16px;
            position: relative;
            cursor: pointer;
            border-radius: 12px;
            overflow: hidden;
            border: 2px solid transparent;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            transition: all 0.25s ease;
        }

        .masonry-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 28px rgba(37,99,235,0.15);
        }

        .masonry-item.selected {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37,99,235,0.2), 0 8px 20px rgba(37,99,235,0.2);
        }

        .masonry-item img {
            width: 100%; display: block;
        }

        .photo-overlay {
            position: absolute; inset: 0;
            background: linear-gradient(to top, rgba(0,0,0,0.55) 0%, transparent 50%);
            opacity: 0; transition: opacity 0.2s;
            display: flex; align-items: flex-end; padding: 12px;
        }

        .masonry-item:hover .photo-overlay { opacity: 1; }

        .photo-overlay-title {
            color: #fff; font-size: 12px; font-weight: 600;
            text-shadow: 0 1px 4px rgba(0,0,0,0.5);
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%;
        }

        /* ── Empty state ──────────────────────── */
        .empty-gallery {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            min-height: 300px; border: 2px dashed var(--border-color);
            border-radius: 16px; color: #94a3b8; text-align: center; padding: 40px;
        }

        .empty-gallery i { font-size: 48px; margin-bottom: 14px; }
        .empty-gallery h3 { font-family: var(--font-serif); font-size: 24px; color: #64748b; margin: 0 0 8px; }

        /* ── Details panel ────────────────────── */
        .details-panel {
            background: var(--bg-surface); border: 1px solid var(--border-color);
            padding: 24px; border-radius: 18px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            position: sticky; top: 20px;
        }

        .details-panel h5 {
            color: #94a3b8; font-size: 11px; letter-spacing: 1.2px;
            margin-bottom: 14px; text-transform: uppercase; font-weight: 700;
        }

        .details-panel h2 {
            font-size: 22px; font-family: var(--font-serif); font-weight: 700;
            margin: 10px 0 4px; color: #1e293b;
        }

        .details-panel .location {
            color: #64748b; font-size: 13px; display: flex; align-items: center; gap: 5px;
        }

        .detail-img {
            width: 100%; border-radius: 12px; margin-bottom: 16px;
            object-fit: cover; max-height: 220px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .tech-specs {
            display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin: 16px 0;
        }

        .spec-box {
            background: var(--bg-surface-light); padding: 12px; border-radius: 10px;
            border: 1px solid var(--border-color);
        }

        .spec-box span { font-size: 10px; color: #2563eb; font-weight: 700; letter-spacing: 0.8px; text-transform: uppercase; }
        .spec-box h4   { margin: 5px 0 0; font-size: 14px; color: #1e293b; }

        .tags { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 14px; }

        .tag {
            padding: 5px 12px; font-size: 12px; border-radius: 20px;
            background: #eff6ff; color: #2563eb; border: 1px solid #dbeafe; font-weight: 600;
        }

        .actions { display: flex; gap: 10px; margin-top: 18px; }

        .btn-action {
            flex: 1; padding: 10px; border-radius: 10px;
            border: 1px solid var(--border-color); background: var(--bg-surface-light);
            color: var(--text-primary); cursor: pointer; font-weight: 600; font-size: 13px;
            transition: all 0.2s; text-align: center; text-decoration: none; display: flex;
            align-items: center; justify-content: center; gap: 6px;
        }

        .btn-action:hover { border-color: #2563eb; color: #2563eb; background: #eff6ff; }
        .btn-action.danger:hover { border-color: #ef4444; color: #ef4444; background: #fee2e2; }

        /* ── Placeholder msg ──────────────────── */
        .no-select {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            min-height: 200px; color: #94a3b8; text-align: center;
        }

        .no-select i { font-size: 36px; margin-bottom: 10px; }

        @media (max-width: 1000px) {
            .gallery-layout { grid-template-columns: 1fr; }
            .details-panel  { position: static; }
        }

        @media (max-width: 600px) {
            .masonry { columns: 1; }
            .section-header h1 { font-size: 30px; }
        }
    </style>
</head>
<body>

    <jsp:include page='<%= isAdmin ? "../components/adminSidebar.jsp" : "../components/sidebar.jsp" %>' />


    <main class="main-content">
           <jsp:include page='<%= isAdmin ? "../components/adminHeader.jsp" : "../components/Header.jsp" %>' />


        <div class="page-container">

            <div class="section-header">
                <h5>RECENT COLLECTIONS</h5>
                <h1>Your Archive</h1>
            </div>

            <div class="gallery-layout">

                <%-- Masonry grid --%>
                <div class="gallery-scroll">
                    <% if (!hasPhotos) { %>
                        <div class="empty-gallery">
                            <i class="bi bi-images"></i>
                            <h3>No photos yet</h3>
                            <p>Upload your first files to start building your archive.</p>
                            <a href="${pageContext.request.contextPath}/uploadImport"
                               style="margin-top:16px; color:#2563eb; font-weight:700; text-decoration:none;">
                                <i class="bi bi-cloud-upload"></i> Go to Upload
                            </a>
                        </div>
                    <% } else { %>
                        <div class="masonry" id="masonryGrid">
                            <% for (Photo p : photos) {
                                String src = request.getContextPath() + "/uploads/" + galleryUser.getUserId() + "/" + p.getFilePath();
                                String title = p.getTitle() != null && !p.getTitle().isEmpty() ? p.getTitle() : p.getFilePath();
                            %>
                                <div class="masonry-item"
                                     data-photoid="<%= p.getPhotoId() %>"
                                     data-title="<%= title %>"
                                     data-src="<%= src %>"
                                     data-aperture="<%= p.getAperture() != null ? p.getAperture() : "–" %>"
                                     data-shutter="<%= p.getShutterSpeed() != null ? p.getShutterSpeed() : "–" %>"
                                     data-iso="<%= p.getIso() != null ? p.getIso() : "–" %>"
                                     data-focal="<%= p.getFocalLength() != null ? p.getFocalLength() : "–" %>"
                                     data-location="<%= p.getLocationTag() != null ? p.getLocationTag() : "" %>"
                                     onclick="selectPhoto(this)">
                                    <img src="<%= src %>" alt="<%= title %>" loading="lazy">
                                    <div class="photo-overlay">
                                        <span class="photo-overlay-title"><%= title %></span>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>

                <%-- Details panel --%>
                <div class="details-panel">
                    <h5>SELECTED ITEM</h5>
                    <div id="noSelect" class="no-select">
                        <i class="bi bi-hand-index-thumb"></i>
                        <p>Click a photo to see its details</p>
                    </div>
                    <div id="photoDetail" style="display:none;">
                        <img id="detailImg" src="" alt="Selected" class="detail-img">
                        <h2 id="detailTitle">–</h2>
                        <p class="location" id="detailLocation" style="display:none;">
                            <i class="bi bi-geo-alt"></i> <span id="detailLocationText"></span>
                        </p>
                        <div class="tech-specs">
                            <div class="spec-box"><span>Aperture</span><h4 id="detailAperture">–</h4></div>
                            <div class="spec-box"><span>Shutter</span><h4 id="detailShutter">–</h4></div>
                            <div class="spec-box"><span>ISO</span><h4 id="detailIso">–</h4></div>
                            <div class="spec-box"><span>Focal</span><h4 id="detailFocal">–</h4></div>
                        </div>
                        <div class="actions">
                            <a id="detailDownload" href="#" download class="btn-action">
                                <i class="bi bi-download"></i> Download
                            </a>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </main>

    <script>
        let selected = null;

        function selectPhoto(el) {
            if (selected) selected.classList.remove('selected');
            el.classList.add('selected');
            selected = el;

            const d = el.dataset;
            document.getElementById('noSelect').style.display    = 'none';
            document.getElementById('photoDetail').style.display = 'block';

            document.getElementById('detailImg').src      = d.src;
            document.getElementById('detailTitle').textContent = d.title;
            document.getElementById('detailAperture').textContent = d.aperture;
            document.getElementById('detailShutter').textContent  = d.shutter;
            document.getElementById('detailIso').textContent      = d.iso;
            document.getElementById('detailFocal').textContent    = d.focal;
            document.getElementById('detailDownload').href        = d.src;

            const locEl = document.getElementById('detailLocation');
            if (d.location && d.location.trim()) {
                document.getElementById('detailLocationText').textContent = d.location;
                locEl.style.display = 'flex';
            } else {
                locEl.style.display = 'none';
            }
        }
    </script>
</body>
</html>
