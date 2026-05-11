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
    String ctxPath = request.getContextPath();
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
            position:absolute; inset:0; background:linear-gradient(to top, rgba(0,0,0,0.65) 0%, transparent 55%);
            opacity:0; transition:opacity 0.2s; display:flex; flex-direction:column;
            justify-content:flex-end; padding:14px; gap:8px;
        }
        .explore-card:hover .explore-card-overlay { opacity:1; }
        .explore-card-title { color:#fff; font-size:12px; font-weight:600; line-height:1.4; }
        .explore-card-author { color:rgba(255,255,255,0.7); font-size:11px; }

        /* Save to Gallery button */
        .save-to-gallery-btn {
            display:inline-flex; align-items:center; gap:5px;
            padding:6px 12px; border-radius:8px; font-size:11px; font-weight:700;
            background:rgba(37,99,235,0.9); color:#fff; border:none; cursor:pointer;
            transition:all 0.2s; align-self:flex-start;
        }
        .save-to-gallery-btn:hover { background:#2563eb; transform:scale(1.05); }
        .save-to-gallery-btn.saved { background:rgba(34,197,94,0.9); }
        .save-to-gallery-btn.saving { opacity:0.6; pointer-events:none; }

        .loading-spinner { display:none; text-align:center; padding:60px; }
        .spinner { width:40px; height:40px; border:3px solid #e2e8f0; border-top-color:#2563eb;
            border-radius:50%; animation:spin 0.8s linear infinite; margin:0 auto 14px; }
        @keyframes spin { to { transform:rotate(360deg); } }

        .explore-stats { display:flex; gap:12px; margin-bottom:20px; flex-wrap:wrap; }
        .explore-stat {
            background:var(--bg-surface); border:1px solid var(--border-color); border-radius:12px;
            padding:12px 18px; font-size:12px; color:#64748b; display:flex; align-items:center; gap:6px;
        }
        .explore-stat strong { color:#1e293b; }

        .explore-empty { text-align:center; padding:80px 20px; color:#94a3b8; }
        .explore-empty i { font-size:48px; margin-bottom:14px; display:block; }

        .lightbox-overlay {
            display:none; position:fixed; inset:0; background:rgba(0,0,0,0.88);
            z-index:2000; justify-content:center; align-items:center; padding:20px;
        }
        .lightbox-overlay.open { display:flex; }
        .lightbox-inner { position:relative; max-width:900px; width:100%; }
        .lightbox-inner img { width:100%; border-radius:14px; box-shadow:0 24px 60px rgba(0,0,0,0.5); }
        .lightbox-close {
            position:absolute; top:-16px; right:-16px; width:36px; height:36px; border-radius:50%;
            background:#fff; border:none; cursor:pointer; font-size:18px;
            display:flex; align-items:center; justify-content:center; transition:all 0.2s;
        }
        .lightbox-close:hover { background:#ef4444; color:#fff; }
        .lightbox-caption { color:#fff; text-align:center; margin-top:14px; font-size:14px; }
        .lightbox-author  { color:rgba(255,255,255,0.6); font-size:12px; margin-top:4px; text-align:center; }

        .explore-pagination { display:flex; justify-content:center; gap:10px; margin-top:32px; }
        .page-btn {
            padding:9px 18px; border-radius:10px; border:1.5px solid var(--border-color);
            background:var(--bg-surface); font-size:13px; font-weight:600; cursor:pointer;
            transition:all 0.2s; color:#475569;
        }
        .page-btn:hover, .page-btn.active { background:#2563eb; color:#fff; border-color:#2563eb; }
        .page-btn:disabled { opacity:0.4; cursor:not-allowed; }

        /* Toast notification */
        .explore-toast {
            position:fixed; bottom:28px; right:28px; z-index:9999;
            padding:13px 20px; border-radius:12px; font-size:13px; font-weight:600; color:#fff;
            box-shadow:0 6px 20px rgba(0,0,0,0.2); display:flex; align-items:center; gap:8px;
            animation:toastIn 0.3s ease; pointer-events:none;
        }
        @keyframes toastIn { from { opacity:0; transform:translateY(16px); } to { opacity:1; transform:none; } }
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
                    <div class="explore-stat"><i class="bi bi-cloud-check"></i> Unsplash via API</div>
                </div>
            </div>

            <div class="explore-search-wrap">
                <input type="text" id="exploreSearchInput" class="explore-search-input"
                       placeholder="Search photos… (e.g. ocean, mountains, street)" value="ocean">
                <button class="explore-search-btn" onclick="triggerSearch()">
                    <i class="bi bi-search"></i> Search
                </button>
            </div>

            <div class="explore-tags">
                <span class="explore-tag active" onclick="searchTag(this,'ocean')">🌊 Ocean</span>
                <span class="explore-tag" onclick="searchTag(this,'mountains')">🏔️ Mountains</span>
                <span class="explore-tag" onclick="searchTag(this,'architecture')">🏛️ Architecture</span>
                <span class="explore-tag" onclick="searchTag(this,'portrait')">👤 Portrait</span>
                <span class="explore-tag" onclick="searchTag(this,'nature')">🌿 Nature</span>
                <span class="explore-tag" onclick="searchTag(this,'street photography')">📸 Street</span>
                <span class="explore-tag" onclick="searchTag(this,'abstract')">🎨 Abstract</span>
                <span class="explore-tag" onclick="searchTag(this,'wildlife')">🦁 Wildlife</span>
            </div>

            <div class="loading-spinner" id="loadingSpinner">
                <div class="spinner"></div>
                <p style="color:#64748b;font-size:14px;">Diving into the ocean…</p>
            </div>

            <div class="explore-grid" id="exploreGrid"></div>

            <div class="explore-empty" id="exploreEmpty" style="display:none;">
                <i class="bi bi-search"></i>
                <h3 style="font-family:var(--font-serif);color:#64748b;">No results found</h3>
                <p>Try a different search term</p>
            </div>

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

    <div class="lightbox-overlay" id="lightbox" onclick="closeLightbox(event)">
        <div class="lightbox-inner">
            <button class="lightbox-close" onclick="closeLightbox()"><i class="bi bi-x"></i></button>
            <img id="lightboxImg" src="" alt="">
            <div class="lightbox-caption" id="lightboxCaption"></div>
            <div class="lightbox-author"  id="lightboxAuthor"></div>
        </div>
    </div>

    <script>
    // ── Context path (set server-side so JS can call our servlets) ───────
    const CTX = '<%= ctxPath %>';

    // ── State ─────────────────────────────────────────────────────────────
    let currentQuery = 'ocean';
    let currentPage  = 1;
    let totalPages   = 1;

    // ── Fallback preloaded images (shown if API key not yet configured) ───
    const PRELOADED = [
        { id:'p1', description:'Deep blue ocean waves',       urls:{ small:'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=400&q=80', regular:'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=1080&q=80' }, user:{ name:'Jeremy Bishop' } },
        { id:'p2', description:'Turquoise waters aerial',     urls:{ small:'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?w=400&q=80', regular:'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?w=1080&q=80' }, user:{ name:'Shifaaz Shamoon' } },
        { id:'p3', description:'Ocean sunset golden hour',    urls:{ small:'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80', regular:'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080&q=80' }, user:{ name:'Sean Oulashin' } },
        { id:'p4', description:'Underwater coral reef',       urls:{ small:'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80', regular:'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1080&q=80' }, user:{ name:'Hiroko Yoshii' } },
        { id:'p5', description:'Rocky coastline waves',       urls:{ small:'https://images.unsplash.com/photo-1455156218388-5e61b526818b?w=400&q=80', regular:'https://images.unsplash.com/photo-1455156218388-5e61b526818b?w=1080&q=80' }, user:{ name:'Steven Kamenar' } },
        { id:'p6', description:'Calm ocean horizon',          urls:{ small:'https://images.unsplash.com/photo-1530053969600-caed2596d242?w=400&q=80', regular:'https://images.unsplash.com/photo-1530053969600-caed2596d242?w=1080&q=80' }, user:{ name:'Nick Scheerbart' } },
        { id:'p7', description:'Ocean from above – drone',    urls:{ small:'https://images.unsplash.com/photo-1498892812623-8f8604177375?w=400&q=80', regular:'https://images.unsplash.com/photo-1498892812623-8f8604177375?w=1080&q=80' }, user:{ name:'Ben Collins' } },
        { id:'p8', description:'Waves crashing on shore',     urls:{ small:'https://images.unsplash.com/photo-1476673160081-cf065607f449?w=400&q=80', regular:'https://images.unsplash.com/photo-1476673160081-cf065607f449?w=1080&q=80' }, user:{ name:'Artem Beliaikin' } },
        { id:'p9', description:'Mountain lake reflection',    urls:{ small:'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80', regular:'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1080&q=80' }, user:{ name:'Kalen Emsley' } },
        { id:'p10',description:'Forest path in autumn',       urls:{ small:'https://images.unsplash.com/photo-1477322524744-0eece9e79640?w=400&q=80', regular:'https://images.unsplash.com/photo-1477322524744-0eece9e79640?w=1080&q=80' }, user:{ name:'Patrick Fore' } },
    ];

    // ── Render the image grid ─────────────────────────────────────────────
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
            const thumb  = item.urls.small  || item.urls.thumb;
            const full   = item.urls.regular || item.urls.full;

            const card = document.createElement('div');
            card.className = 'explore-card';

            // Escape for use in onclick attribute
            const safeUrl   = full.replace(/'/g, "\\'");
            const safeDesc  = desc.replace(/'/g, "\\'").replace(/"/g, '&quot;');
            const safeAuth  = author.replace(/'/g, "\\'");

            card.innerHTML = `
                <img src="${thumb}" alt="${desc}" loading="lazy"
                     onerror="this.src='https://via.placeholder.com/400x300?text=Image+unavailable'">
                <div class="explore-card-overlay">
                    <div class="explore-card-title">${desc}</div>
                    <div class="explore-card-author">📸 ${author}</div>
                    <button class="save-to-gallery-btn"
                            onclick="event.stopPropagation(); saveToGallery(this, '${safeUrl}', '${safeDesc}')">
                        <i class="bi bi-bookmark-plus"></i> Save to Gallery
                    </button>
                </div>`;

            card.addEventListener('click', () => openLightbox(full, desc, author));
            grid.appendChild(card);
        });

        document.getElementById('explorePagination').style.display = 'flex';
        document.getElementById('pageIndicator').textContent = 'Page ' + currentPage;
        document.getElementById('prevBtn').disabled = currentPage <= 1;
        document.getElementById('nextBtn').disabled = currentPage >= totalPages;
    }

    // ── Fetch via backend proxy (avoids CORS + keeps API key secure) ──────
    async function fetchImages(query, page) {
        document.getElementById('loadingSpinner').style.display = 'block';
        document.getElementById('exploreGrid').innerHTML = '';
        document.getElementById('exploreEmpty').style.display = 'none';
        document.getElementById('explorePagination').style.display = 'none';

        try {
            const res = await fetch(
                `${CTX}/api/explore?query=${encodeURIComponent(query)}&page=${page}`
            );

            if (!res.ok) throw new Error('HTTP ' + res.status);

            const data = await res.json();

            // Handle both array (error payload) and object responses
            if (!data.results) throw new Error('No results in response');

            totalPages = data.total_pages || 1;
            document.getElementById('totalCount').textContent =
                (data.total || data.results.length || 0).toLocaleString();

            renderGrid(data.results);

        } catch (e) {
            console.warn('API unavailable – showing sample images. Error:', e.message);
            totalPages = 1;
            document.getElementById('totalCount').textContent = PRELOADED.length;
            renderGrid(PRELOADED);
        } finally {
            document.getElementById('loadingSpinner').style.display = 'none';
        }
    }

    // ── Save an Explore image into the user's gallery ─────────────────────
    async function saveToGallery(btn, imageUrl, title) {
        if (btn.classList.contains('saved') || btn.classList.contains('saving')) return;

        btn.classList.add('saving');
        btn.innerHTML = '<i class="bi bi-hourglass-split"></i> Saving…';

        try {
            const formData = new FormData();
            formData.append('imageUrl', imageUrl);
            formData.append('title', title);

            const res  = await fetch(`${CTX}/addToGallery`, { method: 'POST', body: formData });
            const data = await res.json();

            if (data.success) {
                btn.classList.remove('saving');
                btn.classList.add('saved');
                btn.innerHTML = '<i class="bi bi-bookmark-check-fill"></i> Saved!';
                showToast(data.message, 'success');
            } else {
                throw new Error(data.message || 'Unknown error');
            }
        } catch (e) {
            btn.classList.remove('saving');
            btn.innerHTML = '<i class="bi bi-bookmark-plus"></i> Save to Gallery';
            showToast('Could not save: ' + e.message, 'error');
        }
    }

    // ── Toast notification ────────────────────────────────────────────────
    function showToast(message, type) {
        const toast = document.createElement('div');
        toast.className = 'explore-toast';
        toast.style.background = type === 'success' ? '#22c55e' : '#ef4444';
        toast.innerHTML = `<i class="bi bi-${type === 'success' ? 'check-circle-fill' : 'exclamation-triangle-fill'}"></i> ${message}`;
        document.body.appendChild(toast);
        setTimeout(() => { toast.style.opacity = '0'; setTimeout(() => toast.remove(), 400); }, 2800);
    }

    // ── Controls ──────────────────────────────────────────────────────────
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

    document.getElementById('exploreSearchInput').addEventListener('keydown', e => {
        if (e.key === 'Enter') triggerSearch();
    });

    // ── Lightbox ──────────────────────────────────────────────────────────
    function openLightbox(src, caption, author) {
        document.getElementById('lightboxImg').src    = src;
        document.getElementById('lightboxCaption').textContent = caption;
        document.getElementById('lightboxAuthor').textContent  = '📸 ' + author;
        document.getElementById('lightbox').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeLightbox(e) {
        if (e && e.target !== document.getElementById('lightbox')
               && !e.target.closest('.lightbox-close')) return;
        document.getElementById('lightbox').classList.remove('open');
        document.body.style.overflow = '';
    }

    document.addEventListener('keydown', e => { if (e.key === 'Escape') closeLightbox(); });

    // Expose for Header.jsp global search integration
    window._isExplorePage = true;
    window.exploreSearch  = function(val, immediate) {
        document.getElementById('exploreSearchInput').value = val;
        clearTimeout(window._exploreDebounce);
        window._exploreDebounce = setTimeout(() => {
            currentQuery = val;
            currentPage  = 1;
            fetchImages(currentQuery, currentPage);
        }, immediate ? 0 : 450);
    };

    // ── Init ──────────────────────────────────────────────────────────────
    window.addEventListener('DOMContentLoaded', () => {
        fetchImages(currentQuery, currentPage);
    });
    </script>
</body>
</html>
