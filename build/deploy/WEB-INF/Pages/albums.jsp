<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.List, java.util.Map" %>
        <%@ page import="com.DigiPic4.model.User, com.DigiPic4.model.Album, com.DigiPic4.model.Photo" %>
            <%@ page import="com.DigiPic4.dao.PhotoDAO" %>
                <% User albumsUser=(User) session.getAttribute("user"); if (albumsUser==null) {
                    response.sendRedirect(request.getContextPath() + "/login" ); return; } String
                    albumsRole=albumsUser.getRole()==null ? "" : albumsUser.getRole().trim(); boolean
                    albumsIsAdmin="admin" .equalsIgnoreCase(albumsRole); List<Album> albums = (List<Album>)
                        request.getAttribute("albums");
                        Map<Integer, List<Photo>> albumPhotosMap = (Map<Integer, List<Photo>>)
                                request.getAttribute("albumPhotosMap");
                                boolean hasAlbums = albums != null && !albums.isEmpty();
                                int currentAlbumCount = albums != null ? albums.size() : 0;
                                boolean limitReached = currentAlbumCount >= 3;

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

                                    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style-light.css">
                                    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sidebar-light.css">
                                    <link rel="stylesheet"
                                        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
                                    <link
                                        href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Sora:wght@400;500;600&display=swap"
                                        rel="stylesheet">

                                    <style>
                                        :root {
                                            --font-serif: 'Cormorant Garamond', serif;
                                            --font-sans: 'Sora', sans-serif;
                                        }

                                        .page-content {
                                            max-width: 100%;
                                            margin: 0 auto;
                                            padding: 40px 20px 40px;
                                        }

                                        .section-header {
                                            margin-top: 24px;
                                            margin-bottom: 56px;
                                            display: flex;
                                            justify-content: space-between;
                                            align-items: center;
                                            flex-wrap: wrap;
                                            gap: 32px;
                                            padding: 60px 52px;
                                            background: rgba(255, 255, 255, 0.65);
                                            backdrop-filter: blur(24px) saturate(180%);
                                            -webkit-backdrop-filter: blur(24px) saturate(180%);
                                            border: 1px solid rgba(255, 255, 255, 0.5);
                                            border-radius: 40px;
                                            box-shadow: 
                                                0 10px 25px -5px rgba(0, 0, 0, 0.02),
                                                0 20px 50px -10px rgba(0, 0, 0, 0.04);
                                            position: relative;
                                            overflow: hidden;
                                        }

                                        .section-header::before {
                                            content: '';
                                            position: absolute;
                                            inset: 0;
                                            background: linear-gradient(
                                                120deg, 
                                                rgba(37, 99, 235, 0.05), 
                                                rgba(99, 102, 241, 0.05), 
                                                rgba(139, 92, 246, 0.05)
                                            );
                                            background-size: 200% 200%;
                                            animation: gradientFlow 8s ease infinite;
                                            z-index: -1;
                                        }

                                        @keyframes gradientFlow {
                                            0% { background-position: 0% 50%; }
                                            50% { background-position: 100% 50%; }
                                            100% { background-position: 0% 50%; }
                                        }

                                        .header-deco {
                                            position: absolute;
                                            top: -20%;
                                            right: -5%;
                                            width: 300px;
                                            height: 300px;
                                            background: radial-gradient(circle, rgba(37, 99, 235, 0.08) 0%, transparent 70%);
                                            filter: blur(40px);
                                            pointer-events: none;
                                            z-index: -1;
                                        }

                                        .section-header-text h5 {
                                            color: #2563eb;
                                            font-size: 11px;
                                            letter-spacing: 3px;
                                            font-weight: 800;
                                            text-transform: uppercase;
                                            margin-bottom: 14px;
                                            display: flex;
                                            align-items: center;
                                            gap: 10px;
                                            opacity: 0.8;
                                        }

                                        .section-header-text h1 {
                                            font-size: 56px;
                                            margin: 0 0 20px;
                                            font-family: var(--font-display);
                                            font-weight: 800;
                                            color: #0f172a;
                                            letter-spacing: -2px;
                                            line-height: 1.1;
                                        }

                                        .header-stats {
                                            display: flex;
                                            align-items: center;
                                            gap: 16px;
                                            color: #475569;
                                            font-size: 14px;
                                            font-weight: 600;
                                            background: rgba(255, 255, 255, 0.9);
                                            padding: 12px 24px;
                                            border-radius: 100px;
                                            width: fit-content;
                                            border: 1px solid rgba(226, 232, 240, 0.8);
                                            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
                                        }

                                        .header-stats span {
                                            display: flex;
                                            align-items: center;
                                            gap: 8px;
                                        }

                                        .header-stats i {
                                            color: #2563eb;
                                            font-size: 18px;
                                        }

                                        .header-stats .dot {
                                            width: 5px;
                                            height: 5px;
                                            background: #cbd5e1;
                                            border-radius: 50%;
                                        }

                                        /* ── Grid ─────────────────────────────── */
                                        .album-grid {
                                            display: grid;
                                            grid-template-columns: repeat(3, 1fr);
                                            gap: 32px;
                                        }

                                        /* Responsive adjustment for mobile */
                                        @media (max-width: 900px) {
                                            .album-grid {
                                                grid-template-columns: repeat(2, 1fr);
                                            }
                                        }

                                        @media (max-width: 640px) {
                                            .album-grid {
                                                grid-template-columns: 1fr;
                                            }
                                        }

                                        /* ── Album card (CLICKABLE CONTAINER) ─── */
                                        .album-card {
                                            background: #ffffff;
                                            border: 1px solid rgba(226, 232, 240, 0.8);
                                            border-radius: 24px;
                                            overflow: hidden;
                                            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
                                            cursor: pointer;
                                            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
                                            position: relative;
                                            display: flex;
                                            flex-direction: column;
                                            aspect-ratio: 0.85 / 1;
                                        }

                                        .album-card:hover {
                                            transform: translateY(-12px) scale(1.01);
                                            box-shadow: 0 30px 60px rgba(37, 99, 235, 0.12);
                                            border-color: #2563eb;
                                        }

                                        .album-card::after {
                                            content: 'Click to open';
                                            position: absolute;
                                            top: 12px;
                                            right: 12px;
                                            background: rgba(37, 99, 235, 0.9);
                                            color: #fff;
                                            font-size: 11px;
                                            font-weight: 700;
                                            letter-spacing: 0.5px;
                                            padding: 4px 10px;
                                            border-radius: 20px;
                                            opacity: 0;
                                            transition: opacity 0.2s;
                                        }

                                        .album-card:hover::after {
                                            opacity: 1;
                                        }

                                        .album-thumb {
                                            width: 100%;
                                            flex-grow: 1;
                                            height: 0;
                                            object-fit: cover;
                                            display: block;
                                            pointer-events: none;
                                        }

                                        .album-thumb-placeholder {
                                            width: 100%;
                                            flex-grow: 1;
                                            background: linear-gradient(135deg, #eff6ff, #e0e7ff);
                                            display: flex;
                                            align-items: center;
                                            justify-content: center;
                                            color: #93c5fd;
                                            font-size: 56px;
                                            pointer-events: none;
                                        }

                                        .album-info {
                                            padding: 24px;
                                            flex-shrink: 0;
                                            background: #ffffff;
                                            z-index: 2;
                                            border-top: 1px solid #f1f5f9;
                                        }

                                        .album-meta {
                                            font-size: 10px;
                                            font-weight: 800;
                                            letter-spacing: 1px;
                                            text-transform: uppercase;
                                            color: #2563eb;
                                            margin-bottom: 8px;
                                            display: flex;
                                            align-items: center;
                                            gap: 6px;
                                        }

                                        .album-meta::before {
                                            content: '';
                                            width: 4px;
                                            height: 4px;
                                            background: #2563eb;
                                            border-radius: 50%;
                                        }

                                        .album-name {
                                            font-size: 20px;
                                            font-weight: 800;
                                            color: #0f172a;
                                            font-family: var(--font-display);
                                            margin: 0 0 8px;
                                            letter-spacing: -0.5px;
                                        }

                                        .album-desc {
                                            font-size: 14px;
                                            color: #64748b;
                                            line-height: 1.6;
                                            margin-bottom: 20px;
                                            display: -webkit-box;
                                            -webkit-line-clamp: 2;
                                            -webkit-box-orient: vertical;
                                            overflow: hidden;
                                        }

                                        .album-actions {
                                            display: flex;
                                            gap: 8px;
                                        }

                                        .album-btn {
                                            flex: 1;
                                            padding: 10px 12px;
                                            border-radius: 12px;
                                            font-size: 13px;
                                            font-weight: 700;
                                            cursor: pointer;
                                            text-align: center;
                                            transition: all 0.2s ease;
                                            border: 1px solid #e2e8f0;
                                            background: #f8fafc;
                                            color: #475569;
                                            text-decoration: none;
                                            display: flex;
                                            align-items: center;
                                            justify-content: center;
                                            gap: 8px;
                                        }

                                        .album-btn:hover {
                                            border-color: #2563eb;
                                            color: #2563eb;
                                            background: #eff6ff;
                                            transform: translateY(-2px);
                                        }

                                        .album-btn.danger:hover {
                                            border-color: #ef4444;
                                            color: #ef4444;
                                            background: #fee2e2;
                                        }

                                        /* ── Empty state ──────────────────────── */
                                        .empty-state {
                                            grid-column: 1/-1;
                                            display: flex;
                                            flex-direction: column;
                                            align-items: center;
                                            justify-content: center;
                                            min-height: 280px;
                                            border: 2px dashed var(--border-color);
                                            border-radius: 16px;
                                            color: #94a3b8;
                                            text-align: center;
                                            padding: 40px;
                                        }

                                        .empty-state i {
                                            font-size: 48px;
                                            margin-bottom: 14px;
                                        }

                                        .empty-state h3 {
                                            font-family: var(--font-serif);
                                            font-size: 24px;
                                            color: #64748b;
                                            margin: 0 0 8px;
                                        }

                                        /* ── Create button ────────────────────── */
                                        .btn-create {
                                            background: linear-gradient(135deg, #2563eb, #1d4ed8);
                                            color: #fff;
                                            border: none;
                                            padding: 14px 28px;
                                            border-radius: 14px;
                                            font-weight: 700;
                                            cursor: pointer;
                                            display: flex;
                                            align-items: center;
                                            gap: 10px;
                                            font-family: var(--font-sans);
                                            font-size: 15px;
                                            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                                            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
                                        }

                                        .btn-create:hover {
                                            box-shadow: 0 12px 24px rgba(37, 99, 235, 0.3);
                                            transform: translateY(-3px);
                                            background: linear-gradient(135deg, #3b82f6, #2563eb);
                                        }

                                        .btn-create i {
                                            font-size: 18px;
                                        }

                                        /* ── Create Modal ─────────────────────── */
                                        .modal-overlay {
                                            position: fixed;
                                            inset: 0;
                                            background: rgba(0, 0, 0, 0.45);
                                            backdrop-filter: blur(6px);
                                            display: none;
                                            justify-content: center;
                                            align-items: center;
                                            z-index: 1000;
                                        }

                                        .modal-overlay.open {
                                            display: flex;
                                        }

                                        .modal-box {
                                            background: var(--bg-surface);
                                            border: 1px solid var(--border-color);
                                            border-radius: 20px;
                                            padding: 32px;
                                            width: 90%;
                                            max-width: 480px;
                                            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
                                            animation: slideUp 0.2s ease;
                                        }

                                        @keyframes slideUp {
                                            from {
                                                opacity: 0;
                                                transform: translateY(20px);
                                            }

                                            to {
                                                opacity: 1;
                                                transform: translateY(0);
                                            }
                                        }

                                        .modal-box h2 {
                                            font-family: var(--font-serif);
                                            font-size: 26px;
                                            color: #1e293b;
                                            margin: 0 0 6px;
                                        }

                                        .modal-box p {
                                            color: #64748b;
                                            font-size: 13px;
                                            margin-bottom: 24px;
                                        }

                                        .mfield {
                                            display: flex;
                                            flex-direction: column;
                                            margin-bottom: 14px;
                                        }

                                        .mfield label {
                                            font-size: 12px;
                                            font-weight: 700;
                                            text-transform: uppercase;
                                            letter-spacing: 0.5px;
                                            color: #1e293b;
                                            margin-bottom: 6px;
                                        }

                                        .mfield input,
                                        .mfield textarea {
                                            padding: 11px 14px;
                                            border-radius: 10px;
                                            border: 1px solid var(--border-color);
                                            background: var(--bg-surface-light);
                                            color: var(--text-primary);
                                            font-family: var(--font-sans);
                                            font-size: 14px;
                                            transition: border-color 0.2s;
                                        }

                                        .mfield textarea {
                                            resize: vertical;
                                            min-height: 80px;
                                        }

                                        .mfield input:focus,
                                        .mfield textarea:focus {
                                            outline: none;
                                            border-color: #2563eb;
                                            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
                                        }

                                        .modal-actions {
                                            display: flex;
                                            gap: 10px;
                                            justify-content: flex-end;
                                            margin-top: 20px;
                                        }

                                        .btn-cancel {
                                            background: var(--bg-surface-light);
                                            border: 1px solid var(--border-color);
                                            color: var(--text-primary);
                                            padding: 10px 18px;
                                            border-radius: 10px;
                                            font-weight: 600;
                                            cursor: pointer;
                                            transition: all 0.2s;
                                        }

                                        .btn-cancel:hover {
                                            border-color: #94a3b8;
                                        }

                                        .btn-confirm {
                                            background: linear-gradient(135deg, #2563eb, #1e40af);
                                            color: #fff;
                                            border: none;
                                            padding: 10px 20px;
                                            border-radius: 10px;
                                            font-weight: 700;
                                            cursor: pointer;
                                            transition: all 0.2s;
                                        }

                                        .btn-confirm:hover {
                                            box-shadow: 0 4px 14px rgba(37, 99, 235, 0.25);
                                        }

                                        /* ── Album Lightbox / Photo Viewer ────── */
                                        .album-viewer-overlay {
                                            position: fixed;
                                            inset: 0;
                                            background: rgba(15, 23, 42, 0.85);
                                            backdrop-filter: blur(12px);
                                            z-index: 2000;
                                            display: none;
                                            flex-direction: column;
                                        }

                                        .album-viewer-overlay.open {
                                            display: flex;
                                        }

                                        .album-viewer-header {
                                            padding: 20px 32px;
                                            display: flex;
                                            align-items: center;
                                            justify-content: space-between;
                                            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
                                            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
                                        }

                                        .album-viewer-header h2 {
                                            font-family: var(--font-serif);
                                            font-size: 28px;
                                            color: #f8fafc;
                                            margin: 0;
                                            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
                                        }

                                        .album-viewer-header .viewer-count-badge {
                                            display: inline-flex;
                                            align-items: center;
                                            gap: 6px;
                                            background: rgba(37, 99, 235, 0.25);
                                            color: #93c5fd;
                                            font-size: 12px;
                                            font-weight: 700;
                                            padding: 4px 12px;
                                            border-radius: 20px;
                                            border: 1px solid rgba(37, 99, 235, 0.3);
                                            letter-spacing: 0.5px;
                                        }

                                        .album-viewer-close {
                                            width: 42px;
                                            height: 42px;
                                            border-radius: 50%;
                                            background: rgba(255, 255, 255, 0.08);
                                            border: 1px solid rgba(255, 255, 255, 0.12);
                                            cursor: pointer;
                                            font-size: 18px;
                                            color: #94a3b8;
                                            display: flex;
                                            align-items: center;
                                            justify-content: center;
                                            transition: all 0.25s;
                                        }

                                        .album-viewer-close:hover {
                                            background: rgba(239, 68, 68, 0.2);
                                            color: #fca5a5;
                                            border-color: rgba(239, 68, 68, 0.3);
                                        }

                                        .album-viewer-body {
                                            flex: 1;
                                            overflow-y: auto;
                                            padding: 32px;
                                        }

                                        .album-viewer-body::-webkit-scrollbar {
                                            width: 6px;
                                        }

                                        .album-viewer-body::-webkit-scrollbar-thumb {
                                            background: rgba(255, 255, 255, 0.15);
                                            border-radius: 3px;
                                        }

                                        .viewer-grid {
                                            display: grid;
                                            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                                            gap: 18px;
                                        }

                                        @media(max-width:700px) {
                                            .viewer-grid {
                                                grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
                                                gap: 12px;
                                            }
                                        }

                                        .viewer-item {
                                            border-radius: 14px;
                                            overflow: hidden;
                                            cursor: pointer;
                                            position: relative;
                                            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
                                            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                                            aspect-ratio: 4/3;
                                            background: #1e293b;
                                        }

                                        .viewer-item:hover {
                                            transform: translateY(-6px) scale(1.02);
                                            box-shadow: 0 16px 40px rgba(37, 99, 235, 0.25);
                                        }

                                        .viewer-item img {
                                            width: 100%;
                                            height: 100%;
                                            object-fit: cover;
                                            display: block;
                                            transition: transform 0.4s;
                                        }

                                        .viewer-item:hover img {
                                            transform: scale(1.06);
                                        }

                                        .viewer-item-overlay {
                                            position: absolute;
                                            inset: 0;
                                            background: linear-gradient(to top, rgba(0, 0, 0, 0.7) 0%, rgba(0, 0, 0, 0.1) 40%, transparent 60%);
                                            opacity: 0;
                                            transition: opacity 0.3s;
                                            display: flex;
                                            flex-direction: column;
                                            justify-content: flex-end;
                                            padding: 14px;
                                        }

                                        .viewer-item:hover .viewer-item-overlay {
                                            opacity: 1;
                                        }

                                        .viewer-item-label {
                                            color: #f1f5f9;
                                            font-size: 13px;
                                            font-weight: 600;
                                            white-space: nowrap;
                                            overflow: hidden;
                                            text-overflow: ellipsis;
                                            text-shadow: 0 1px 4px rgba(0, 0, 0, 0.5);
                                        }

                                        .viewer-item-hint {
                                            color: rgba(255, 255, 255, 0.6);
                                            font-size: 10px;
                                            font-weight: 500;
                                            margin-top: 4px;
                                            letter-spacing: 0.5px;
                                        }

                                        .viewer-empty {
                                            text-align: center;
                                            padding: 80px 20px;
                                            color: #64748b;
                                            grid-column: 1 / -1;
                                        }

                                        .viewer-empty i {
                                            font-size: 56px;
                                            display: block;
                                            margin-bottom: 16px;
                                            color: #475569;
                                        }

                                        .viewer-empty h3 {
                                            font-family: var(--font-serif);
                                            color: #94a3b8;
                                            font-size: 22px;
                                            margin: 0 0 8px;
                                        }

                                        .viewer-empty p {
                                            color: #64748b;
                                            font-size: 14px;
                                        }

                                        /* Full image lightbox */
                                        .img-lightbox {
                                            position: fixed;
                                            inset: 0;
                                            background: rgba(0, 0, 0, 0.95);
                                            z-index: 3000;
                                            display: none;
                                            justify-content: center;
                                            align-items: center;
                                            padding: 24px;
                                        }

                                        .img-lightbox.open {
                                            display: flex;
                                        }

                                        .img-lightbox img {
                                            max-width: 92vw;
                                            max-height: 90vh;
                                            border-radius: 12px;
                                            box-shadow: 0 24px 80px rgba(0, 0, 0, 0.6);
                                            animation: lbFadeIn 0.25s ease;
                                        }

                                        @keyframes lbFadeIn {
                                            from {
                                                opacity: 0;
                                                transform: scale(0.95);
                                            }

                                            to {
                                                opacity: 1;
                                                transform: scale(1);
                                            }
                                        }

                                        .img-lightbox-close {
                                            position: absolute;
                                            top: 24px;
                                            right: 28px;
                                            width: 44px;
                                            height: 44px;
                                            border-radius: 50%;
                                            background: rgba(255, 255, 255, 0.1);
                                            border: 1px solid rgba(255, 255, 255, 0.15);
                                            cursor: pointer;
                                            font-size: 18px;
                                            color: #e2e8f0;
                                            display: flex;
                                            align-items: center;
                                            justify-content: center;
                                            transition: all 0.2s;
                                            backdrop-filter: blur(8px);
                                        }

                                        .img-lightbox-close:hover {
                                            background: rgba(239, 68, 68, 0.3);
                                            color: #fca5a5;
                                        }
                                    </style>
                                </head>

                                <body>

                                    <jsp:include
                                        page='<%= albumsIsAdmin ? "../components/adminSidebar.jsp" : "../components/sidebar.jsp" %>' />

                                    <main class="main-content">
                                        <jsp:include
                                            page='<%= albumsIsAdmin ? "../components/adminHeader.jsp" : "../components/Header.jsp" %>' />

                                        <div class="page-content">
                                            <% int totalAlbums=albums !=null ? albums.size() : 0; int
                                                totalPhotosCount=0; if (albumPhotosMap !=null) { for (List<Photo> lp :
                                                albumPhotosMap.values()) {
                                                if (lp != null) totalPhotosCount += lp.size();
                                                }
                                                }
                                                %>
                                                <div class="section-header">
                                                    <div class="header-deco"></div>
                                                    <div class="section-header-text">
                                                        <h5>CURATION HUB</h5>
                                                        <h1>Your Collections</h1>

                                                        <% String albumErr = (String) session.getAttribute("albumError");
                                                           if (albumErr != null) { %>
                                                            <div style="background: #fee2e2; border: 1px solid #fca5a5; color: #b91c1c; padding: 12px 16px; border-radius: 12px; font-size: 13px; font-weight: 600; margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                                                                <i class="bi bi-exclamation-triangle-fill"></i> <%= albumErr %>
                                                            </div>
                                                        <% session.removeAttribute("albumError"); } %>

                                                        <div class="header-stats">
                                                            <span><i class="bi bi-folder2"></i>
                                                                <%= totalAlbums %> Collections
                                                            </span>
                                                            <div class="dot"></div>
                                                            <span><i class="bi bi-images"></i>
                                                                <%= totalPhotosCount %> Photos
                                                            </span>
                                                        </div>
                                                    </div>
                                                    <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 8px;">
                                                        <button class="btn-create" onclick="openCreateModal()" <%= limitReached ? "disabled style='opacity: 0.6; cursor: not-allowed;'" : "" %>>
                                                            <i class="bi <%= limitReached ? "bi-lock-fill" : "bi-plus-circle-fill" %>"></i> 
                                                            <%= limitReached ? "Limit Reached" : "Create Collection" %>
                                                        </button>
                                                        <div style="font-size: 11px; font-weight: 700; color: <%= limitReached ? "#ef4444" : "#64748b" %>; letter-spacing: 0.5px; text-transform: uppercase;">
                                                            <%= currentAlbumCount %>/3 Collections Used
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="album-grid" id="albumGrid">
                                                    <% if (!hasAlbums) { %>
                                                        <div class="empty-state">
                                                            <i class="bi bi-folder2-open"></i>
                                                            <h3>No albums yet</h3>
                                                            <p>Create your first collection to start organising your
                                                                archive.</p>
                                                            <button class="btn-create" onclick="openCreateModal()"
                                                                style="margin-top:16px;">
                                                                <i class="bi bi-plus-circle"></i> Create Album
                                                            </button>
                                                        </div>
                                                        <% } else { for (Album a : albums) { List<Photo> albumPhotos =
                                                            albumPhotosMap != null ? albumPhotosMap.get(a.getAlbumId())
                                                            : null;
                                                            int pCount = albumPhotos != null ? albumPhotos.size() : 0;

                                                            // Build JSON array of photo paths
                                                            StringBuilder photosJson = new StringBuilder("[");
                                                            if (albumPhotos != null) {
                                                                for (int pi = 0; pi < albumPhotos.size(); pi++) { 
                                                                    Photo ph=albumPhotos.get(pi); 
                                                                    String t=ph.getTitle() !=null && !ph.getTitle().isEmpty() ? ph.getTitle() : ph.getFilePath(); 
                                                                    String fp=ph.getFilePath(); 
                                                                    // External URLs (http/https) are used directly; local
                                                                    // paths go through image-serve String src; 
                                                                    String src;
                                                                    if (fp !=null && (fp.startsWith("http://") || fp.startsWith("https://"))) { 
                                                                        src=fp; 
                                                                    } else {
                                                                        src=request.getContextPath() + "/image-serve/" + fp; 
                                                                    }
                                                                if (pi> 0) photosJson.append(",");
                                                                photosJson.append("{\"src\":\"").append(src.replace("\"", "\\\"")).append("\",\"title\":\"").append(t.replace("\"", "\\\"")).append("\"}");
                                                                }
                                                                }
                                                                photosJson.append("]");
                                                                %>
                                                                <div class="album-card"
                                                                    data-album-id="<%= a.getAlbumId() %>"
                                                                    data-album-name="<%= a.getAlbumName().replace("\"", "&quot;").replace("'", "&#39;") %>"
                                                                    data-photos="<%= photosJson.toString().replace("\"", "&quot;") %>"
                                                                    onclick="openAlbumViewer(this)">
                                                                        <% if (a.getCoverImageUrl() != null && !a.getCoverImageUrl().isBlank()) { %>
                                                                            <img class="album-thumb" src="<%= a.getCoverImageUrl() %>" alt="<%= a.getAlbumName() %>">
                                                                        <% } else { %>
                                                                            <div class="album-thumb-placeholder"><i class="bi bi-folder2"></i></div>
                                                                        <% } %>
                                                                                    <div class="album-info">
                                                                                        <div class="album-meta">
                                                                                            <%= pCount %> PHOTO<%=
                                                                                                    pCount !=1 ? "S"
                                                                                                    : "" %>
                                                                                        </div>
                                                                                        <h3 class="album-name">
                                                                                            <%= a.getAlbumName() %>
                                                                                        </h3>
                                                                                        <% if (a.getDescription() !=null
                                                                                            &&
                                                                                            !a.getDescription().isBlank())
                                                                                            { %>
                                                                                            <p class="album-desc">
                                                                                                <%= a.getDescription()
                                                                                                    %>
                                                                                            </p>
                                                                                            <% } %>
                                                                                                <div class="album-actions"
                                                                                                    onclick="event.stopPropagation()">
                                                                                                    <button
                                                                                                        class="album-btn"
                                                                                                        onclick="openAlbumViewer(this.closest('.album-card'))">
                                                                                                        <i
                                                                                                            class="bi bi-images"></i>
                                                                                                        View Photos
                                                                                                    </button>
                                                                                                    <form
                                                                                                        action="${pageContext.request.contextPath}/albums"
                                                                                                        method="post"
                                                                                                        style="flex:1;"
                                                                                                        onsubmit="return confirm('Delete this album? This cannot be undone.');">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="action"
                                                                                                            value="delete">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="albumId"
                                                                                                            value="<%= a.getAlbumId() %>">
                                                                                                        <button
                                                                                                            type="submit"
                                                                                                            class="album-btn danger"
                                                                                                            style="width:100%;">
                                                                                                            <i
                                                                                                                class="bi bi-trash"></i>
                                                                                                            Delete
                                                                                                        </button>
                                                                                                    </form>
                                                                                                </div>
                                                                                    </div>
                                                                </div>
                                                                <% } } %>
                                                </div>
                                        </div>

                                        <jsp:include page="../components/footer.jsp" />
                                    </main>

                                    <!-- Modal script logic below... -->

                                    <%-- Create album modal --%>
                                        <div class="modal-overlay" id="createModal">
                                            <div class="modal-box">
                                                <h2>New Collection</h2>
                                                <p>Give your album a name and optional details.</p>
                                                <form action="${pageContext.request.contextPath}/albums" method="post">
                                                    <input type="hidden" name="action" value="create">
                                                    <div class="mfield"><label>Album Name *</label><input type="text"
                                                            name="albumName" required maxlength="255"
                                                            placeholder="e.g. Summer 2025"></div>
                                                    <div class="mfield"><label>Description</label><textarea
                                                            name="description" maxlength="500"
                                                            placeholder="Short description…"></textarea></div>
                                                    <div class="mfield"><label>Cover Image URL</label><input type="url"
                                                            name="coverImageUrl" placeholder="https://…"></div>
                                                    <div class="modal-actions">
                                                        <button type="button" class="btn-cancel"
                                                            onclick="closeCreateModal()">Cancel</button>
                                                        <button type="submit" class="btn-confirm"><i
                                                                class="bi bi-folder-plus"></i> Create Album</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>

                                        <%-- Album photo viewer --%>
                                            <div class="album-viewer-overlay" id="albumViewer">
                                                <div class="album-viewer-header">
                                                    <div
                                                        style="display:flex; align-items:center; gap:16px; flex-wrap:wrap;">
                                                        <h2 id="viewerAlbumName">Album</h2>
                                                        <span class="viewer-count-badge" id="viewerPhotoCount"><i
                                                                class="bi bi-images"></i> 0 photos</span>
                                                    </div>
                                                    <button class="album-viewer-close" onclick="closeAlbumViewer()"><i
                                                            class="bi bi-x-lg"></i></button>
                                                </div>
                                                <div class="album-viewer-body">
                                                    <div class="viewer-grid" id="viewerGrid"></div>
                                                </div>
                                            </div>

                                            <%-- Full image lightbox --%>
                                                <div class="img-lightbox" id="imgLightbox"
                                                    onclick="closeImgLightbox(event)">
                                                    <button class="img-lightbox-close" onclick="closeImgLightbox()"><i
                                                            class="bi bi-x-lg"></i></button>
                                                    <img id="imgLightboxSrc" src="" alt="">
                                                </div>

                                                <script>
                                                    // ── Create modal ─────────────────────────────────────────────
                                                    function openCreateModal() { document.getElementById('createModal').classList.add('open'); }
                                                    function closeCreateModal() { document.getElementById('createModal').classList.remove('open'); }
                                                    document.getElementById('createModal').addEventListener('click', function (e) { if (e.target === this) closeCreateModal(); });

                                                    // ── Album viewer ─────────────────────────────────────────────
                                                    function openAlbumViewer(card) {
                                                        const name = card.getAttribute('data-album-name');
                                                        const rawPhotos = card.getAttribute('data-photos');

                                                        let photos = [];
                                                        try {
                                                            photos = JSON.parse(rawPhotos || '[]');
                                                        } catch (e) {
                                                            console.error("Failed to parse photos JSON:", e);
                                                        }

                                                        document.getElementById('viewerAlbumName').textContent = name;
                                                        document.getElementById('viewerPhotoCount').innerHTML =
                                                            '<i class="bi bi-images"></i> ' + photos.length + ' photo' + (photos.length !== 1 ? 's' : '');

                                                        const grid = document.getElementById('viewerGrid');
                                                        if (!photos.length) {
                                                            grid.innerHTML = '<div class="viewer-empty"><i class="bi bi-images"></i><h3>No photos in this album yet</h3><p>Upload photos and assign them to this album.</p></div>';
                                                        } else {
                                                            grid.innerHTML = photos.map(function (p) {
                                                                var safeSrc = p.src.replace(/'/g, "\\'");
                                                                var safeTitle = p.title.replace(/'/g, "\\'").replace(/</g, "&lt;");
                                                                return '<div class="viewer-item" onclick="openImgLightbox(\'' + safeSrc + '\')">' +
                                                                    '<img src="' + p.src + '" alt="' + safeTitle + '" loading="lazy" ' +
                                                                    'onerror="this.style.display=\'none\'">' +
                                                                    '<div class="viewer-item-overlay">' +
                                                                    '<span class="viewer-item-label">' + safeTitle + '</span>' +
                                                                    '<span class="viewer-item-hint">Click to enlarge</span>' +
                                                                    '</div></div>';
                                                            }).join('');
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

                                                        // Track in Recent Floats
                                                        var recent = JSON.parse(localStorage.getItem('recent_floats') || '[]');
                                                        if (!recent.some(function (item) { return item.src === src; })) {
                                                            recent.unshift({
                                                                name: 'Album Photo',
                                                                type: 'Album View',
                                                                time: 'Just now',
                                                                src: src,
                                                                timestamp: Date.now()
                                                            });
                                                            localStorage.setItem('recent_floats', JSON.stringify(recent.slice(0, 20)));
                                                        }
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