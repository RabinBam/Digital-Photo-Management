<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.DigiPic4.model.User" %>
<%
    User exploreUser = (User) session.getAttribute("user");
    if (exploreUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String exploreRole = exploreUser.getRole() == null ? "" : exploreUser.getRole().trim();
    boolean exploreIsAdmin = "admin".equalsIgnoreCase(exploreRole);
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Explore the Ocean – DigiPic</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style-light.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar-light.css?v=<%= System.currentTimeMillis() %>">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@600;700&family=Sora:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root { --font-serif: 'Cormorant Garamond', serif; --font-sans: 'Sora', sans-serif; }
        
        body {
            background-color: #f8fafb;
            color: #1e293b;
            font-family: var(--font-sans);
            display: flex;
            height: 100vh;
            margin: 0;
            padding: 0;
            overflow: hidden;
        }

        .main-content {
            flex-grow: 1;
            padding: 40px;
            overflow-y: auto;
            background-color: #f8fafb;
            display: flex;
            flex-direction: column;
        }

        .page-content { max-width: 1400px; margin: 0 auto; padding: 0 24px 40px; }

        .section-header { margin-bottom: 22px; display:flex; justify-content:space-between; align-items:flex-end; flex-wrap:wrap; gap:14px; }
        .section-header-text h5 { color:#2563eb; font-size:12px; letter-spacing:1.5px; font-weight:700; text-transform:uppercase; margin-bottom:6px; }
        .section-header-text h1 { font-size:40px; margin:0; font-family:var(--font-serif); font-weight:700; color:#1e293b; }

        .explore-search-wrap { display:flex; gap:10px; align-items:center; margin-bottom:28px; }
        .explore-search-input {
            flex:1; padding:12px 18px; border-radius:12px; border:1.5px solid var(--border-color);
            background:var(--bg-surface); font-size:14px; font-family:var(--font-sans); color:#1e293b;
            transition:border-color 0.2s, box-shadow 0.2s;
        }
        .explore-search-input:focus { outline:none; border-color:#2563eb; box-shadow:0 0 0 3px rgba(37,99,235,0.1); }
        .explore-search-btn {
            padding:12px 24px; background:linear-gradient(135deg,#2563eb,#1e40af); color:#fff;
            border:none; border-radius:12px; font-weight:700; cursor:pointer; font-family:var(--font-sans);
            display:flex; align-items:center; gap:8px; transition:all 0.2s;
        }
        .explore-search-btn:hover { box-shadow:0 6px 18px rgba(37,99,235,0.3); transform:translateY(-1px); }

        .explore-tags { display:flex; gap:8px; flex-wrap:wrap; margin-bottom:24px; }
        .explore-tag {
            padding:6px 14px; border-radius:20px; border:1.5px solid var(--border-color);
            background:var(--bg-surface); font-size:12px; font-weight:600; cursor:pointer;
            transition:all 0.2s; color:#475569;
        }
        .explore-tag:hover, .explore-tag.active { background:#2563eb; color:#fff; border-color:#2563eb; }

        /* Masonry grid */
        .explore-grid { columns:4; column-gap:16px; }
        @media(max-width:1100px){ .explore-grid { columns:3; } }
        @media(max-width:760px) { .explore-grid { columns:2; } }
        @media(max-width:480px) { .explore-grid { columns:1; } }

        .explore-card {
            break-inside:avoid; margin-bottom:16px; border-radius:14px; overflow:hidden;
            position:relative; cursor:pointer; border:2px solid transparent;
            box-shadow:0 4px 12px rgba(0,0,0,0.08); transition:all 0.25s; display:block;
        }
        .explore-card:hover { transform:translateY(-4px); box-shadow:0 14px 32px rgba(37,99,235,0.15); border-color:#93c5fd; }
        .explore-card img { width:100%; display:block; }
        .explore-card-overlay {
            position:absolute; inset:0; background:linear-gradient(to top, rgba(0,0,0,0.6) 0%, transparent 50%);
            opacity:0; transition:opacity 0.2s; display:flex; flex-direction:column; justify-content:flex-end; padding:14px;
        }
        .explore-card:hover .explore-card-overlay { opacity:1; }
        .explore-card-title { color:#fff; font-size:12px; font-weight:600; line-height:1.4; margin-bottom:4px; }
        .explore-card-author { color:rgba(255,255,255,0.7); font-size:11px; }

        /* Skeleton loader */
        .skeleton-grid { columns:4; column-gap:16px; }
        @media(max-width:1100px){ .skeleton-grid { columns:3; } }
        @media(max-width:760px) { .skeleton-grid { columns:2; } }
        @media(max-width:480px) { .skeleton-grid { columns:1; } }

        .skeleton-card {
            break-inside:avoid; margin-bottom:16px; border-radius:14px; overflow:hidden;
            background: linear-gradient(90deg, #f0f4f8 25%, #e2e8f0 50%, #f0f4f8 75%);
            background-size: 200% 100%;
            animation: shimmer 1.5s infinite;
        }
        .skeleton-card.h1 { height: 220px; }
        .skeleton-card.h2 { height: 160px; }
        .skeleton-card.h3 { height: 280px; }
        .skeleton-card.h4 { height: 200px; }

        @keyframes shimmer {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }

        .explore-empty { text-align:center; padding:80px 20px; color:#94a3b8; }
        .explore-empty i { font-size:48px; margin-bottom:14px; display:block; }

        .explore-stats { display:flex; gap:12px; margin-bottom:20px; flex-wrap:wrap; }
        .explore-stat {
            background:var(--bg-surface); border:1px solid var(--border-color); border-radius:12px;
            padding:12px 18px; font-size:12px; color:#64748b; display:flex; align-items:center; gap:6px;
        }
        .explore-stat strong { color:#1e293b; }

        /* Lightbox */
        .lightbox-overlay {
            display:none; position:fixed; inset:0; background:rgba(0,0,0,0.88); z-index:2000;
            justify-content:center; align-items:center; padding:20px;
        }
        .lightbox-overlay.open { display:flex; }
        .lightbox-inner { position:relative; max-width:900px; width:100%; }
        .lightbox-inner img { width:100%; border-radius:14px; box-shadow:0 24px 60px rgba(0,0,0,0.5); }
        .lightbox-close {
            position:absolute; top:-16px; right:-16px; width:36px; height:36px; border-radius:50%;
            background:#fff; border:none; cursor:pointer; font-size:18px; display:flex;
            align-items:center; justify-content:center; transition:all 0.2s;
        }
        .lightbox-close:hover { background:#ef4444; color:#fff; }
        .lightbox-caption { color:#fff; text-align:center; margin-top:14px; font-size:14px; font-weight:600; }
        .lightbox-author { color:rgba(255,255,255,0.6); font-size:12px; margin-top:4px; text-align:center; }

        /* Pagination */
        .explore-pagination { display:flex; justify-content:center; gap:10px; margin-top:32px; }
        .page-btn {
            padding:9px 18px; border-radius:10px; border:1.5px solid var(--border-color);
            background:var(--bg-surface); font-size:13px; font-weight:600; cursor:pointer;
            transition:all 0.2s; color:#475569;
        }
        .page-btn:hover, .page-btn.active { background:#2563eb; color:#fff; border-color:#2563eb; }
        .page-btn:disabled { opacity:0.4; cursor:not-allowed; }

        /* API status badge */
        .api-badge {
            display:inline-flex; align-items:center; gap:5px; padding:4px 10px;
            border-radius:20px; font-size:11px; font-weight:700;
        }
        .api-badge.live { background:#dcfce7; color:#166534; border:1px solid #bbf7d0; }
        .api-badge.preloaded { background:#eff6ff; color:#1e40af; border:1px solid #bfdbfe; }
    </style>
</head>
<body>
<jsp:include page='<%= exploreIsAdmin ? "../components/adminSidebar.jsp" : "../components/sidebar.jsp" %>' />

    <main class="main-content">
    <jsp:include page='<%= exploreIsAdmin ? "../components/adminHeader.jsp" : "../components/Header.jsp" %>' />

        <div class="page-content">
            <div class="section-header">
                <div class="section-header-text">
                    <h5>DISCOVERY FEED</h5>
                    <h1>Explore the Ocean</h1>
                </div>
                <div class="explore-stats">
                    <div class="explore-stat">
                        <i class="bi bi-images"></i>
                        <strong id="totalCount">—</strong>&nbsp;results
                    </div>
                    <div class="explore-stat" id="apiStatusBadge">
                        <i class="bi bi-circle-fill" style="color:#94a3b8; font-size:8px;"></i>
                        Loading…
                    </div>
                </div>
            </div>

            <!-- Search -->
            <div class="explore-search-wrap">
                <input type="text" id="exploreSearchInput" class="explore-search-input"
                       placeholder="Search the ocean… (e.g. ocean, mountains, architecture)"
                       value="ocean">
                <button class="explore-search-btn" onclick="triggerSearch()">
                    <i class="bi bi-search"></i> Search
                </button>
            </div>

            <!-- Quick tags -->
            <div class="explore-tags">
                <span class="explore-tag active" onclick="searchTag(this, 'ocean')">🌊 Ocean</span>
                <span class="explore-tag" onclick="searchTag(this, 'mountains')">🏔️ Mountains</span>
                <span class="explore-tag" onclick="searchTag(this, 'architecture')">🏛️ Architecture</span>
                <span class="explore-tag" onclick="searchTag(this, 'portrait')">👤 Portrait</span>
                <span class="explore-tag" onclick="searchTag(this, 'nature')">🌿 Nature</span>
                <span class="explore-tag" onclick="searchTag(this, 'street photography')">📸 Street</span>
                <span class="explore-tag" onclick="searchTag(this, 'abstract')">🎨 Abstract</span>
                <span class="explore-tag" onclick="searchTag(this, 'wildlife')">🦁 Wildlife</span>
            </div>

            <!-- Skeleton loader (shown while loading) -->
            <div id="skeletonLoader" class="skeleton-grid">
                <div class="skeleton-card h1"></div>
                <div class="skeleton-card h2"></div>
                <div class="skeleton-card h3"></div>
                <div class="skeleton-card h4"></div>
                <div class="skeleton-card h2"></div>
                <div class="skeleton-card h1"></div>
                <div class="skeleton-card h3"></div>
                <div class="skeleton-card h2"></div>
            </div>

            <!-- Grid -->
            <div class="explore-grid" id="exploreGrid" style="display:none;"></div>
            <div class="explore-empty" id="exploreEmpty" style="display:none;">
                <i class="bi bi-search"></i>
                <h3 style="font-family:var(--font-serif); color:#64748b;">No results found</h3>
                <p>Try a different search term</p>
            </div>

            <!-- Pagination -->
            <div class="explore-pagination" id="explorePagination" style="display:none;">
                <button class="page-btn" id="prevBtn" onclick="changePage(-1)" disabled>
                    <i class="bi bi-chevron-left"></i> Prev
                </button>
                <span class="page-btn active" id="pageIndicator">Page 1</span>
                <button class="page-btn" id="nextBtn" onclick="changePage(1)">
                    Next <i class="bi bi-chevron-right"></i>
                </button>
            </div>
        </div>
    </main>

    <!-- Lightbox -->
    <div class="lightbox-overlay" id="lightbox" onclick="closeLightbox(event)">
        <div class="lightbox-inner">
            <button class="lightbox-close" onclick="closeLightbox()"><i class="bi bi-x"></i></button>
            <img id="lightboxImg" src="" alt="">
            <div class="lightbox-caption" id="lightboxCaption"></div>
            <div class="lightbox-author" id="lightboxAuthor"></div>
        </div>
    </div>

    <script>
    // ── Preloaded image banks (categorised so tag search works offline) ────────
    const IMAGE_BANKS = {
        ocean: [
            { description: 'Deep blue ocean waves', urls: { small: 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=400&q=80', regular: 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=1080&q=80' }, user: { name: 'Jeremy Bishop' } },
            { description: 'Turquoise waters aerial view', urls: { small: 'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?w=400&q=80', regular: 'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?w=1080&q=80' }, user: { name: 'Shifaaz Shamoon' } },
            { description: 'Ocean sunset golden hour', urls: { small: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80', regular: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080&q=80' }, user: { name: 'Sean Oulashin' } },
            { description: 'Underwater coral reef', urls: { small: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80', regular: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1080&q=80' }, user: { name: 'Hiroko Yoshii' } },
            { description: 'Rocky coastline waves', urls: { small: 'https://images.unsplash.com/photo-1455156218388-5e61b526818b?w=400&q=80', regular: 'https://images.unsplash.com/photo-1455156218388-5e61b526818b?w=1080&q=80' }, user: { name: 'Steven Kamenar' } },
            { description: 'Calm ocean horizon', urls: { small: 'https://images.unsplash.com/photo-1530053969600-caed2596d242?w=400&q=80', regular: 'https://images.unsplash.com/photo-1530053969600-caed2596d242?w=1080&q=80' }, user: { name: 'Nick Scheerbart' } },
            { description: 'Ocean from above, drone shot', urls: { small: 'https://images.unsplash.com/photo-1498892812623-8f8604177375?w=400&q=80', regular: 'https://images.unsplash.com/photo-1498892812623-8f8604177375?w=1080&q=80' }, user: { name: 'Ben Collins' } },
            { description: 'Waves crashing on shore', urls: { small: 'https://images.unsplash.com/photo-1476673160081-cf065607f449?w=400&q=80', regular: 'https://images.unsplash.com/photo-1476673160081-cf065607f449?w=1080&q=80' }, user: { name: 'Artem Beliaikin' } },
            { description: 'Tropical beach paradise', urls: { small: 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=400&q=80', regular: 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=1080&q=80' }, user: { name: 'Ryan Brandt' } },
            { description: 'Crystal clear lagoon', urls: { small: 'https://images.unsplash.com/photo-1534190760961-74e8c1c5c3da?w=400&q=80', regular: 'https://images.unsplash.com/photo-1534190760961-74e8c1c5c3da?w=1080&q=80' }, user: { name: 'Ishan Seefromthesky' } },
            { description: 'Sea cliffs at dusk', urls: { small: 'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?w=400&q=80', regular: 'https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?w=1080&q=80' }, user: { name: 'Matt Hardy' } },
            { description: 'Night ocean with stars', urls: { small: 'https://images.unsplash.com/photo-1462275646964-a0e3386b89fa?w=400&q=80', regular: 'https://images.unsplash.com/photo-1462275646964-a0e3386b89fa?w=1080&q=80' }, user: { name: 'Jared Erondu' } },
        ],
        mountains: [
            { description: 'Snow-capped mountain peaks', urls: { small: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80', regular: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1080&q=80' }, user: { name: 'Paul Csogi' } },
            { description: 'Mountain lake reflection', urls: { small: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80', regular: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1080&q=80' }, user: { name: 'Samuel Ferrara' } },
            { description: 'Foggy mountain valley', urls: { small: 'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?w=400&q=80', regular: 'https://images.unsplash.com/photo-1486870591958-9b9d0d1dda99?w=1080&q=80' }, user: { name: 'Kalen Emsley' } },
            { description: 'Himalayan sunrise', urls: { small: 'https://images.unsplash.com/photo-1585409677983-0f6c41ca9c3b?w=400&q=80', regular: 'https://images.unsplash.com/photo-1585409677983-0f6c41ca9c3b?w=1080&q=80' }, user: { name: 'David Köhler' } },
            { description: 'Alpine meadow and peaks', urls: { small: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=400&q=80', regular: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=1080&q=80' }, user: { name: 'Thomas Heaton' } },
            { description: 'Rocky mountain trail', urls: { small: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400&q=80', regular: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=1080&q=80' }, user: { name: 'Geran de Klerk' } },
        ],
        architecture: [
            { description: 'Modern glass skyscraper', urls: { small: 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=400&q=80', regular: 'https://images.unsplash.com/photo-1486325212027-8081e485255e?w=1080&q=80' }, user: { name: 'Jacek Dylag' } },
            { description: 'Historic cathedral interior', urls: { small: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80', regular: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=1080&q=80' }, user: { name: 'Spencer Davis' } },
            { description: 'Brutalist concrete facade', urls: { small: 'https://images.unsplash.com/photo-1511818966892-d7d671e672a2?w=400&q=80', regular: 'https://images.unsplash.com/photo-1511818966892-d7d671e672a2?w=1080&q=80' }, user: { name: 'Patrick Baum' } },
            { description: 'Spiral staircase from above', urls: { small: 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?w=400&q=80', regular: 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?w=1080&q=80' }, user: { name: 'Steven Wei' } },
            { description: 'Bridge at night, city lights', urls: { small: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=400&q=80', regular: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=1080&q=80' }, user: { name: 'Pedro Lastra' } },
            { description: 'Minimalist white building', urls: { small: 'https://images.unsplash.com/photo-1513584684374-8bab748fbf90?w=400&q=80', regular: 'https://images.unsplash.com/photo-1513584684374-8bab748fbf90?w=1080&q=80' }, user: { name: 'Lance Anderson' } },
        ],
        portrait: [
            { description: 'Studio portrait, dramatic light', urls: { small: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400&q=80', regular: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=1080&q=80' }, user: { name: 'Tamara Bellis' } },
            { description: 'Natural light portrait', urls: { small: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80', regular: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=1080&q=80' }, user: { name: 'Ben Parker' } },
            { description: 'Close-up eye detail', urls: { small: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=400&q=80', regular: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=1080&q=80' }, user: { name: 'andi rieger' } },
            { description: 'Candid street portrait', urls: { small: 'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=400&q=80', regular: 'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=1080&q=80' }, user: { name: 'Daniel Apodaca' } },
        ],
        nature: [
            { description: 'Misty forest morning', urls: { small: 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=400&q=80', regular: 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=1080&q=80' }, user: { name: 'veeterzy' } },
            { description: 'Wildflower meadow', urls: { small: 'https://images.unsplash.com/photo-1468421870903-4df1664ac249?w=400&q=80', regular: 'https://images.unsplash.com/photo-1468421870903-4df1664ac249?w=1080&q=80' }, user: { name: 'Aaron Burden' } },
            { description: 'Autumn leaves macro', urls: { small: 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=400&q=80', regular: 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=1080&q=80' }, user: { name: 'Chris Lawton' } },
            { description: 'Desert sand dunes', urls: { small: 'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=400&q=80', regular: 'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=1080&q=80' }, user: { name: 'Wolfgang Hasselmann' } },
            { description: 'Tropical rainforest waterfall', urls: { small: 'https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=400&q=80', regular: 'https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=1080&q=80' }, user: { name: 'Nikolai Justesen' } },
            { description: 'Northern lights aurora', urls: { small: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=400&q=80', regular: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=1080&q=80' }, user: { name: 'Tobias Bjørkli' } },
        ],
        'street photography': [
            { description: 'Rainy night street, neon reflections', urls: { small: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=400&q=80', regular: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=1080&q=80' }, user: { name: 'Pedro Lastra' } },
            { description: 'Tokyo street crossing', urls: { small: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400&q=80', regular: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=1080&q=80' }, user: { name: 'Jezael Melgoza' } },
            { description: 'NYC alley, moody light', urls: { small: 'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=400&q=80', regular: 'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=1080&q=80' }, user: { name: 'Andre Benz' } },
            { description: 'Market street, warm tones', urls: { small: 'https://images.unsplash.com/photo-1555881400-74d7acaacd8b?w=400&q=80', regular: 'https://images.unsplash.com/photo-1555881400-74d7acaacd8b?w=1080&q=80' }, user: { name: 'Ishan Gupta' } },
        ],
        abstract: [
            { description: 'Colourful paint swirls', urls: { small: 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?w=400&q=80', regular: 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?w=1080&q=80' }, user: { name: 'Steve Johnson' } },
            { description: 'Light trails long exposure', urls: { small: 'https://images.unsplash.com/photo-1518098268026-4e89f1a2cd8e?w=400&q=80', regular: 'https://images.unsplash.com/photo-1518098268026-4e89f1a2cd8e?w=1080&q=80' }, user: { name: 'JR Korpa' } },
            { description: 'Geometric shadows', urls: { small: 'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?w=400&q=80', regular: 'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?w=1080&q=80' }, user: { name: 'Ryan Quintal' } },
            { description: 'Ink in water macro', urls: { small: 'https://images.unsplash.com/photo-1548504769-900b70ed122e?w=400&q=80', regular: 'https://images.unsplash.com/photo-1548504769-900b70ed122e?w=1080&q=80' }, user: { name: 'Pawel Czerwinski' } },
        ],
        wildlife: [
            { description: 'Lion portrait golden hour', urls: { small: 'https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=400&q=80', regular: 'https://images.unsplash.com/photo-1546182990-dffeafbe841d?w=1080&q=80' }, user: { name: 'Laura College' } },
            { description: 'Elephant in savanna', urls: { small: 'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=400&q=80', regular: 'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=1080&q=80' }, user: { name: 'Ray Harrington' } },
            { description: 'Bird in flight', urls: { small: 'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=400&q=80', regular: 'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=1080&q=80' }, user: { name: 'Gary Bendig' } },
            { description: 'Fox in autumn forest', urls: { small: 'https://images.unsplash.com/photo-1474511320723-9a56873867b5?w=400&q=80', regular: 'https://images.unsplash.com/photo-1474511320723-9a56873867b5?w=1080&q=80' }, user: { name: 'Ray Hennessy' } },
            { description: 'Whale breaching ocean', urls: { small: 'https://images.unsplash.com/photo-1568430462989-44163eb1752f?w=400&q=80', regular: 'https://images.unsplash.com/photo-1568430462989-44163eb1752f?w=1080&q=80' }, user: { name: 'Todd Cravens' } },
        ],
    };

    // Fallback pool: flatten all
    const ALL_PRELOADED = Object.values(IMAGE_BANKS).flat();

    // ── State ─────────────────────────────────────────────────────────
    const API_ENDPOINT = '${pageContext.request.contextPath}/api/explore';
    let currentQuery  = 'ocean';
    let currentPage   = 1;
    let totalPages    = 1;
    let isUsingAPI    = false;

    // ── Render ────────────────────────────────────────────────────────
    function renderGrid(results, source) {
        const grid  = document.getElementById('exploreGrid');
        const empty = document.getElementById('exploreEmpty');
        const skel  = document.getElementById('skeletonLoader');

        skel.style.display = 'none';

        if (!results || !results.length) {
            grid.style.display = 'none';
            empty.style.display = 'block';
            document.getElementById('explorePagination').style.display = 'none';
            document.getElementById('totalCount').textContent = '0';
            updateStatusBadge(source);
            return;
        }

        empty.style.display = 'none';
        grid.innerHTML = '';
        results.forEach(function(item) {
            var desc   = item.description || item.alt_description || 'Untitled';
            var author = item.user ? item.user.name : 'Unknown';
            var thumb  = item.urls.small || item.urls.thumb;
            var full   = item.urls.regular || item.urls.full;
            var card   = document.createElement('div');
            card.className = 'explore-card';
            card.innerHTML =
                '<img src="' + thumb + '" alt="' + escHtml(desc) + '" loading="lazy" ' +
                'onerror="this.closest(\'.explore-card\').style.display=\'none\'">' +
                '<div class="explore-card-overlay">' +
                '<div class="explore-card-title">' + escHtml(desc) + '</div>' +
                '<div class="explore-card-author">📸 ' + escHtml(author) + '</div>' +
                '</div>';
            card.addEventListener('click', function() { openLightbox(full, desc, author); });
            grid.appendChild(card);
        });

        grid.style.display = '';
        document.getElementById('totalCount').textContent = results.length + (source === 'api' ? '+' : '');
        document.getElementById('explorePagination').style.display = 'flex';
        document.getElementById('pageIndicator').textContent = 'Page ' + currentPage;
        document.getElementById('prevBtn').disabled = currentPage <= 1;
        document.getElementById('nextBtn').disabled = currentPage >= totalPages;
        updateStatusBadge(source);
    }

    function updateStatusBadge(source) {
        var el = document.getElementById('apiStatusBadge');
        if (source === 'api') {
            el.innerHTML = '<i class="bi bi-circle-fill" style="color:#16a34a; font-size:8px;"></i> Live API via server';
        } else {
            el.innerHTML = '<i class="bi bi-circle-fill" style="color:#2563eb; font-size:8px;"></i> Curated Library';
        }
    }

    function escHtml(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    // ── Get preloaded images for a query ──────────────────────────────
    function getPreloaded(query) {
        var q = (query || '').toLowerCase().trim();
        // Exact category match
        if (IMAGE_BANKS[q]) return IMAGE_BANKS[q];
        // Partial match
        for (var key in IMAGE_BANKS) {
            if (q.includes(key) || key.includes(q)) return IMAGE_BANKS[key];
        }
        // Filter ALL by description keyword
        var filtered = ALL_PRELOADED.filter(function(img) {
            return img.description.toLowerCase().includes(q);
        });
        return filtered.length > 0 ? filtered : ALL_PRELOADED;
    }

    // ── Show skeleton while loading ───────────────────────────────────
    function showSkeleton() {
        document.getElementById('skeletonLoader').style.display = '';
        document.getElementById('exploreGrid').style.display = 'none';
        document.getElementById('exploreEmpty').style.display = 'none';
    }

    // ── Try API, always fall back to preloaded ────────────────────────
    async function fetchImages(query, page) {
        showSkeleton();

        try {
            var res = await fetch(API_ENDPOINT + '?page=' + encodeURIComponent(page) + '&query=' + encodeURIComponent(query), {
                method: 'GET',
                headers: { 'Accept': 'application/json' }
            });
            if (!res.ok) throw new Error('HTTP ' + res.status);
            var data = await res.json();
            
            // New API might return an array directly or a results object
            var results = [];
            if (Array.isArray(data)) {
                results = data;
                totalPages = 10; // Assume 10 pages if array, or implement header check if needed
            } else {
                results = data.results || data.images || [];
                totalPages = data.total_pages || 10;
            }
            
            isUsingAPI = true;
            renderGrid(results, 'api');
        } catch (e) {
            console.warn('API unavailable, using curated library:', e.message);
            showPreloaded(query);
        }
    }

    function showPreloaded(query) {
        isUsingAPI = false;
        totalPages = 1;
        currentPage = 1;
        var results = getPreloaded(query);
        renderGrid(results, 'preloaded');
    }

    // ── Controls ──────────────────────────────────────────────────────
    function triggerSearch() {
        var q = document.getElementById('exploreSearchInput').value.trim();
        if (!q) return;
        currentQuery = q;
        currentPage  = 1;
        fetchImages(currentQuery, currentPage);
    }

    function searchTag(el, tag) {
        document.querySelectorAll('.explore-tag').forEach(function(t){ t.classList.remove('active'); });
        el.classList.add('active');
        document.getElementById('exploreSearchInput').value = tag;
        currentQuery = tag;
        currentPage  = 1;
        fetchImages(currentQuery, currentPage);
    }

    function changePage(dir) {
        currentPage = Math.max(1, Math.min(totalPages, currentPage + dir));
        if (isUsingAPI) {
            fetchImages(currentQuery, currentPage);
        } else {
            showPreloaded(currentQuery);
        }
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    document.getElementById('exploreSearchInput').addEventListener('keydown', function(e) {
        if (e.key === 'Enter') triggerSearch();
    });

    // ── Lightbox ──────────────────────────────────────────────────────
    function openLightbox(src, caption, author) {
        document.getElementById('lightboxImg').src    = src;
        document.getElementById('lightboxCaption').textContent = caption;
        document.getElementById('lightboxAuthor').textContent  = '📸 ' + author;
        document.getElementById('lightbox').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeLightbox(e) {
        if (e && e.target !== document.getElementById('lightbox') && !e.target.closest('.lightbox-close')) return;
        document.getElementById('lightbox').classList.remove('open');
        document.body.style.overflow = '';
    }

    // Expose for Header.jsp global search
    window.exploreSearch = function(val, immediate) {
        document.getElementById('exploreSearchInput').value = val;
        if (immediate || val.length >= 3) {
            clearTimeout(window._exploreDebounce);
            window._exploreDebounce = setTimeout(function() {
                currentQuery = val;
                currentPage  = 1;
                fetchImages(currentQuery, currentPage);
            }, immediate ? 0 : 400);
        }
    };

    // Keyboard
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            document.getElementById('lightbox').classList.remove('open');
            document.body.style.overflow = '';
        }
    });

    // ── Init: load immediately on DOMContentLoaded ────────────────────
    document.addEventListener('DOMContentLoaded', function() {
        fetchImages(currentQuery, currentPage);
    });
    </script>
</body>
<script>
    console.log("Context Path: ${pageContext.request.contextPath}");
</script>
</html>
