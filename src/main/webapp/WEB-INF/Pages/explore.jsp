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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style-light.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        :root { --font-serif: 'Cormorant Garamond', serif; --font-sans: 'Sora', sans-serif; }

        .page-content { max-width: 1400px; margin: 0 auto; padding: 0 24px 40px; }

        .section-header { margin-bottom: 22px; display:flex; justify-content:space-between; align-items:flex-end; flex-wrap:wrap; gap:14px; }
        .section-header-text h5 { color:#2563eb; font-size:12px; letter-spacing:1.5px; font-weight:700; text-transform:uppercase; margin-bottom:6px; }
        .section-header-text h1 { font-size:40px; margin:0; font-family:var(--font-serif); font-weight:700; color:#1e293b; }

        /* Search bar at top */
        .explore-search-wrap {
            display:flex; gap:10px; align-items:center; margin-bottom:28px;
        }
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

        /* Tags */
        .explore-tags { display:flex; gap:8px; flex-wrap:wrap; margin-bottom:24px; }
        .explore-tag {
            padding:6px 14px; border-radius:20px; border:1.5px solid var(--border-color);
            background:var(--bg-surface); font-size:12px; font-weight:600; cursor:pointer;
            transition:all 0.2s; color:#475569;
        }
        .explore-tag:hover, .explore-tag.active { background:#2563eb; color:#fff; border-color:#2563eb; }

        /* Grid */
        .explore-grid { columns:4; column-gap:16px; }
        @media(max-width:1100px){ .explore-grid { columns:3; } }
        @media(max-width:760px) { .explore-grid { columns:2; } }
        @media(max-width:480px) { .explore-grid { columns:1; } }

        .explore-card {
            break-inside:avoid; margin-bottom:16px; border-radius:14px; overflow:hidden;
            position:relative; cursor:pointer; border:2px solid transparent;
            box-shadow:0 4px 12px rgba(0,0,0,0.08); transition:all 0.25s;
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

        /* Loading */
        .loading-spinner {
            display:none; text-align:center; padding:60px;
        }
        .spinner { width:40px; height:40px; border:3px solid #e2e8f0; border-top-color:#2563eb; border-radius:50%; animation:spin 0.8s linear infinite; margin:0 auto 14px; }
        @keyframes spin { to { transform:rotate(360deg); } }

        /* Stats strip */
        .explore-stats {
            display:flex; gap:12px; margin-bottom:20px; flex-wrap:wrap;
        }
        .explore-stat {
            background:var(--bg-surface); border:1px solid var(--border-color); border-radius:12px;
            padding:12px 18px; font-size:12px; color:#64748b; display:flex; align-items:center; gap:6px;
        }
        .explore-stat strong { color:#1e293b; }

        /* Empty state */
        .explore-empty { text-align:center; padding:80px 20px; color:#94a3b8; }
        .explore-empty i { font-size:48px; margin-bottom:14px; display:block; }

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
        .lightbox-caption { color:#fff; text-align:center; margin-top:14px; font-size:14px; }
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
                    <div class="explore-stat"><i class="bi bi-images"></i> <strong id="totalCount">–</strong> results</div>
                    <div class="explore-stat"><i class="bi bi-search"></i> Powered by Unsplash</div>
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

            <!-- Loading -->
            <div class="loading-spinner" id="loadingSpinner">
                <div class="spinner"></div>
                <p style="color:#64748b; font-size:14px;">Diving into the ocean…</p>
            </div>

            <!-- Grid -->
            <div class="explore-grid" id="exploreGrid"></div>
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
    // ── Config ──────────────────────────────────────────────────────
    const API_HOST  = 'unsplash-image-search-api.p.rapidapi.com';
    const API_KEY   = 'YOUR_RAPIDAPI_KEY'; // Replace with actual key
    let currentQuery = 'ocean';
    let currentPage  = 1;
    let totalPages   = 1;

    // ── Pre-loaded images (shown immediately, no API needed) ─────────
    const PRELOADED = [
        { id: 'pre1', description: 'Deep blue ocean waves', urls: { small: 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=400&q=80', regular: 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=1080&q=80' }, user: { name: 'Jeremy Bishop' } },
        { id: 'pre2', description: 'Turquoise waters aerial view', urls: { small: 'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?w=400&q=80', regular: 'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?w=1080&q=80' }, user: { name: 'Shifaaz Shamoon' } },
        { id: 'pre3', description: 'Ocean sunset golden hour', urls: { small: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80', regular: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080&q=80' }, user: { name: 'Sean Oulashin' } },
        { id: 'pre4', description: 'Underwater coral reef', urls: { small: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80', regular: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1080&q=80' }, user: { name: 'Hiroko Yoshii' } },
        { id: 'pre5', description: 'Rocky coastline waves', urls: { small: 'https://images.unsplash.com/photo-1455156218388-5e61b526818b?w=400&q=80', regular: 'https://images.unsplash.com/photo-1455156218388-5e61b526818b?w=1080&q=80' }, user: { name: 'Steven Kamenar' } },
        { id: 'pre6', description: 'Calm ocean horizon', urls: { small: 'https://images.unsplash.com/photo-1530053969600-caed2596d242?w=400&q=80', regular: 'https://images.unsplash.com/photo-1530053969600-caed2596d242?w=1080&q=80' }, user: { name: 'Nick Scheerbart' } },
        { id: 'pre7', description: 'Ocean from above drone', urls: { small: 'https://images.unsplash.com/photo-1498892812623-8f8604177375?w=400&q=80', regular: 'https://images.unsplash.com/photo-1498892812623-8f8604177375?w=1080&q=80' }, user: { name: 'Ben Collins' } },
        { id: 'pre8', description: 'Waves crashing on shore', urls: { small: 'https://images.unsplash.com/photo-1476673160081-cf065607f449?w=400&q=80', regular: 'https://images.unsplash.com/photo-1476673160081-cf065607f449?w=1080&q=80' }, user: { name: 'Artem Beliaikin' } },
    ];

    // ── Render ───────────────────────────────────────────────────────
    function renderGrid(results) {
        const grid  = document.getElementById('exploreGrid');
        const empty = document.getElementById('exploreEmpty');
        grid.innerHTML = '';
        if (!results || !results.length) {
            empty.style.display = 'block';
            document.getElementById('explorePagination').style.display = 'none';
            return;
        }
        empty.style.display = 'none';
        results.forEach(item => {
            const desc   = item.description || item.alt_description || 'Untitled';
            const author = item.user ? item.user.name : 'Unknown';
            const thumb  = item.urls.small || item.urls.thumb;
            const full   = item.urls.regular || item.urls.full;
            const card   = document.createElement('div');
            card.className = 'explore-card';
            card.innerHTML = `
                <img src="${thumb}" alt="${desc}" loading="lazy">
                <div class="explore-card-overlay">
                    <div class="explore-card-title">${desc}</div>
                    <div class="explore-card-author">📸 ${author}</div>
                </div>`;
            card.addEventListener('click', () => openLightbox(full, desc, author));
            grid.appendChild(card);
        });
        document.getElementById('explorePagination').style.display = 'flex';
        document.getElementById('pageIndicator').textContent = 'Page ' + currentPage;
        document.getElementById('prevBtn').disabled = currentPage <= 1;
        document.getElementById('nextBtn').disabled = currentPage >= totalPages;
    }

    // ── API call ─────────────────────────────────────────────────────
    async function fetchImages(query, page) {
        document.getElementById('loadingSpinner').style.display = 'block';
        document.getElementById('exploreGrid').innerHTML = '';
        document.getElementById('exploreEmpty').style.display = 'none';
        try {
            const res = await fetch(
                `https://${API_HOST}/search?page=${page}&query=${encodeURIComponent(query)}`,
                {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json',
                        'x-rapidapi-host': API_HOST,
                        'x-rapidapi-key': API_KEY
                    }
                }
            );
            if (!res.ok) throw new Error('API error ' + res.status);
            const data = await res.json();
            totalPages = data.total_pages || 1;
            document.getElementById('totalCount').textContent = (data.total || 0).toLocaleString();
            renderGrid(data.results || []);
        } catch(e) {
            console.warn('API unavailable, using preloaded images:', e.message);
            totalPages = 1;
            document.getElementById('totalCount').textContent = PRELOADED.length;
            renderGrid(PRELOADED);
        } finally {
            document.getElementById('loadingSpinner').style.display = 'none';
        }
    }

    // ── Controls ─────────────────────────────────────────────────────
    function triggerSearch() {
        const q = document.getElementById('exploreSearchInput').value.trim();
        if (!q) return;
        currentQuery = q;
        currentPage  = 1;
        fetchImages(currentQuery, currentPage);
    }

    function searchTag(el, tag) {
        document.querySelectorAll('.explore-tag').forEach(t => t.classList.remove('active'));
        el.classList.add('active');
        document.getElementById('exploreSearchInput').value = tag;
        currentQuery = tag;
        currentPage  = 1;
        fetchImages(currentQuery, currentPage);
    }

    function changePage(dir) {
        currentPage = Math.max(1, Math.min(totalPages, currentPage + dir));
        fetchImages(currentQuery, currentPage);
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // Enter key
    document.getElementById('exploreSearchInput').addEventListener('keydown', e => {
        if (e.key === 'Enter') triggerSearch();
    });

    // ── Lightbox ─────────────────────────────────────────────────────
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
            window._exploreDebounce = setTimeout(() => {
                currentQuery = val;
                currentPage = 1;
                fetchImages(currentQuery, currentPage);
            }, immediate ? 0 : 400);
        }
    };

    // ── Init ─────────────────────────────────────────────────────────
    window.addEventListener('DOMContentLoaded', () => {
        fetchImages(currentQuery, currentPage);
    });
    </script>
</body>
</html>
