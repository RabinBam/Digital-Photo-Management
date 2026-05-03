<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    com.DigiPic4.model.User galleryUser = (com.DigiPic4.model.User) session.getAttribute("user");
    if (galleryUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String galleryRole = galleryUser.getRole() == null ? "" : galleryUser.getRole().trim();
    boolean galleryIsAdmin = "admin".equalsIgnoreCase(galleryRole);

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gallery</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style-light.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@400;700&family=Cormorant+Garamond:wght@400;500;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">

    <style>
        :root {
            --font-serif: 'Cormorant Garamond', serif;
            --font-sans: 'Sora', sans-serif;
        }

        .page-container {
            width: 100%;
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .gallery-layout {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 30px;
            margin-top: 20px;
            align-items: start;
        }

        .gallery-grid {
            overflow-y: auto;
            max-height: 70vh;
            padding-right: 10px;
        }

        .gallery-grid::-webkit-scrollbar {
            width: 6px;
        }

        .gallery-grid::-webkit-scrollbar-track {
            background: transparent;
        }

        .gallery-grid::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 3px;
        }

        .section-header {
            margin-bottom: 20px;
        }

        .section-header h5 {
            color: #2563eb;
            font-size: 12px;
            letter-spacing: 1px;
            font-weight: 700;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }

        .section-header h1 {
            font-size: 42px;
            margin: 0;
            font-family: var(--font-serif);
            font-weight: 700;
            color: #1e293b;
        }

        .masonry {
            columns: 2;
            column-gap: 18px;
        }

        .masonry img {
            width: 100%;
            border-radius: 12px;
            margin-bottom: 18px;
            cursor: pointer;
            transition: all 0.3s ease;
            break-inside: avoid;
            border: 2px solid transparent;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }

        .masonry img:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 28px rgba(37, 99, 235, 0.15);
        }

        .masonry img.selected {
            border-color: #2563eb;
            box-shadow: 0 0 20px rgba(37, 99, 235, 0.3);
        }

        .details-panel {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            position: sticky;
            top: 20px;
        }

        .details-panel img {
            width: 100%;
            border-radius: 12px;
            margin-bottom: 15px;
        }

        .details-panel h5 {
            color: #94a3b8;
            font-size: 11px;
            letter-spacing: 1.2px;
            margin-bottom: 15px;
            text-transform: uppercase;
            font-weight: 700;
        }

        .details-panel h2 {
            font-size: 22px;
            font-family: var(--font-serif);
            font-weight: 700;
            margin: 10px 0;
            color: #1e293b;
        }

        .details-panel p {
            color: #64748b;
            font-size: 13px;
        }

        .tech-specs {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-top: 15px;
        }

        .spec-box {
            background: var(--bg-surface-light);
            padding: 14px;
            border-radius: 10px;
            border: 1px solid var(--border-color);
        }

        .spec-box span {
            font-size: 10px;
            color: #2563eb;
            font-weight: 700;
            letter-spacing: 0.8px;
            text-transform: uppercase;
        }

        .spec-box h4 {
            margin: 6px 0 0;
            font-size: 14px;
            color: #1e293b;
        }

        .tags {
            margin-top: 15px;
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .tag {
            display: inline-block;
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 20px;
            background: #eff6ff;
            color: #2563eb;
            border: 1px solid #dbeafe;
            font-weight: 600;
        }

        .actions {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }

        .btn-secondary {
            flex: 1;
            padding: 10px;
            border-radius: 10px;
            border: 1px solid var(--border-color);
            background: var(--bg-surface-light);
            color: var(--text-primary);
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-secondary:hover {
            border-color: #2563eb;
            color: #2563eb;
            background: #eff6ff;
        }

        @media (max-width: 1000px) {
            .gallery-layout {
                grid-template-columns: 1fr;
            }

            .details-panel {
                position: static;
            }

            .section-header h1 {
                font-size: 32px;
            }

            .masonry {
                columns: 1;
            }
        }
    </style>
</head>

<body>

    <!-- SIDEBAR -->
    <jsp:include page='<%= galleryIsAdmin ? "adminSidebar.jsp" : "sidebar.jsp" %>' />

    <!-- MAIN -->
    <main class="main-content">

        <!-- HEADER -->
        <jsp:include page='<%= galleryIsAdmin ? "adminHeader.jsp" : "Header.jsp" %>' />

        <!-- PAGE WRAPPER -->
        <div class="page-container">

            <!-- TITLE -->
            <div class="section-header">
                <h5>RECENT COLLECTIONS</h5>
                <h1>Pacific Expeditions</h1>
            </div>

            <!-- GALLERY + DETAILS -->
            <div class="gallery-layout">

                <!-- LEFT -->
                <div class="gallery-grid">
                    <div class="masonry">
                        <img src="https://images.unsplash.com/photo-1682687982501-1e58f813fb3b?w=800" alt="gallery item 1">
                        <img src="https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800" alt="gallery item 2">
                        <img src="https://images.unsplash.com/photo-1470071131384-001b85755536?w=800" alt="gallery item 3">
                        <img class="selected" src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800" alt="selected item">
                    </div>
                </div>

                <!-- RIGHT -->
                <div class="details-panel">
                    <h5>SELECTED ITEM</h5>
                    <img src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800" alt="selected details">
                    <h2>Golden Hour Serenity</h2>
                    <p>Captured in Maui, Hawaii - Sep 24, 2023</p>

                    <!-- SPECS -->
                    <div class="tech-specs">
                        <div class="spec-box">
                            <span>APERTURE</span>
                            <h4>f/2.8</h4>
                        </div>
                        <div class="spec-box">
                            <span>SHUTTER</span>
                            <h4>1/200s</h4>
                        </div>
                        <div class="spec-box">
                            <span>ISO</span>
                            <h4>100</h4>
                        </div>
                        <div class="spec-box">
                            <span>FOCAL</span>
                            <h4>35mm</h4>
                        </div>
                    </div>

                    <!-- TAGS -->
                    <div class="tags">
                        <span class="tag">#beach</span>
                        <span class="tag">#hawaii</span>
                        <span class="tag">#nature</span>
                    </div>

                    <!-- ACTIONS -->
                    <div class="actions">
                        <button class="btn-secondary" type="button">Download</button>
                        <button class="btn-secondary" type="button">Archive</button>
                    </div>
                </div>

            </div>

        </div>

    </main>

</body>
</html>
