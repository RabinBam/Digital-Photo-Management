<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="com.DigiPic4.model.User, com.DigiPic4.model.AuditLog" %>
<%
    User usageUser = (User) session.getAttribute("user");
    if (usageUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    boolean usageIsAdmin = "admin".equalsIgnoreCase(usageUser.getRole() == null ? "" : usageUser.getRole().trim());

    int totalAlbums  = request.getAttribute("totalAlbums") != null ? (int) request.getAttribute("totalAlbums") : 0;
    int totalPhotos  = request.getAttribute("totalPhotos") != null ? (int) request.getAttribute("totalPhotos") : 0;
    int withAperture = request.getAttribute("withAperture")!= null ? (int) request.getAttribute("withAperture"): 0;
    int withISO      = request.getAttribute("withISO")     != null ? (int) request.getAttribute("withISO")     : 0;
    int withShutter  = request.getAttribute("withShutter") != null ? (int) request.getAttribute("withShutter") : 0;
    int withFocal    = request.getAttribute("withFocal")   != null ? (int) request.getAttribute("withFocal")   : 0;

    @SuppressWarnings("unchecked")
    Map<String, Integer> photosPerAlbum = (Map<String, Integer>) request.getAttribute("photosPerAlbum");
    @SuppressWarnings("unchecked")
    List<AuditLog> recentLogs = (List<AuditLog>) request.getAttribute("recentLogs");

    double avgPerAlbum = totalAlbums > 0 ? (double) totalPhotos / totalAlbums : 0;

    // Build JS arrays for charts
    StringBuilder albumLabels = new StringBuilder("[");
    StringBuilder albumData   = new StringBuilder("[");
    if (photosPerAlbum != null) {
        boolean first = true;
        for (Map.Entry<String, Integer> e : photosPerAlbum.entrySet()) {
            if (!first) { albumLabels.append(","); albumData.append(","); }
            albumLabels.append("\"").append(e.getKey().replace("\"","\\\"")).append("\"");
            albumData.append(e.getValue());
            first = false;
        }
    }
    albumLabels.append("]");
    albumData.append("]");

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Usage Analytics – DigiPic</title>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style-light.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.min.js"></script>

    <style>
        :root { --font-serif: 'Cormorant Garamond', serif; --font-sans: 'Sora', sans-serif; }

        .usage-shell { max-width: 100%; margin: 0; padding: 32px 28px 48px; }

        /* ── Page header ─── */
        .usage-header {
            display: flex; justify-content: space-between; align-items: flex-end;
            flex-wrap: wrap; gap: 16px; margin-bottom: 36px;
        }
        .usage-header h5 {
            color: #2563eb; font-size: 11px; letter-spacing: 2px; font-weight: 800;
            text-transform: uppercase; margin-bottom: 6px;
            display: flex; align-items: center; gap: 8px;
        }
        .usage-header h5::after { content:''; height:1px; width:28px; background:#bfdbfe; display:inline-block; }
        .usage-header h1 {
            font-size: 46px; margin: 0; font-family: var(--font-serif);
            font-weight: 700; color: #1e293b;
        }
        .header-sub { color: #64748b; font-size: 14px; margin-top: 6px; }

        /* ── KPI cards ─── */
        .kpi-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 32px; }
        @media(max-width:1000px){ .kpi-row { grid-template-columns: repeat(2,1fr); } }
        @media(max-width:560px) { .kpi-row { grid-template-columns: 1fr; } }

        .kpi-card {
            background: #fff; border: 1px solid var(--border-color);
            border-radius: 20px; padding: 26px 24px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.05);
            display: flex; flex-direction: column; gap: 6px;
            position: relative; overflow: hidden;
            transition: box-shadow 0.25s, transform 0.25s;
        }
        .kpi-card:hover { box-shadow: 0 12px 32px rgba(37,99,235,0.12); transform: translateY(-3px); }
        .kpi-card::before {
            content: ''; position: absolute; top: 0; left: 0;
            width: 4px; height: 100%; border-radius: 4px 0 0 4px;
        }
        .kpi-card.blue::before  { background: linear-gradient(to bottom, #2563eb, #1e40af); }
        .kpi-card.green::before { background: linear-gradient(to bottom, #16a34a, #15803d); }
        .kpi-card.violet::before{ background: linear-gradient(to bottom, #7c3aed, #5b21b6); }
        .kpi-card.amber::before { background: linear-gradient(to bottom, #d97706, #b45309); }

        .kpi-label { font-size: 11px; color: #94a3b8; text-transform: uppercase; letter-spacing: 1.2px; font-weight: 700; }
        .kpi-value { font-size: 44px; font-weight: 800; color: #1e293b; line-height: 1; }
        .kpi-sub   { font-size: 12px; font-weight: 600; }
        .kpi-card.blue  .kpi-sub { color: #2563eb; }
        .kpi-card.green .kpi-sub { color: #16a34a; }
        .kpi-card.violet.kpi-sub { color: #7c3aed; }
        .kpi-card.amber .kpi-sub { color: #d97706; }
        .kpi-icon { font-size: 28px; margin-bottom: 4px; }
        .kpi-card.blue  .kpi-icon { color: #2563eb; }
        .kpi-card.green .kpi-icon { color: #16a34a; }
        .kpi-card.violet .kpi-icon{ color: #7c3aed; }
        .kpi-card.amber  .kpi-icon{ color: #d97706; }

        /* ── Chart row ─── */
        .chart-row { display: grid; grid-template-columns: 1.6fr 1fr; gap: 24px; margin-bottom: 28px; }
        @media(max-width:900px){ .chart-row { grid-template-columns: 1fr; } }

        .chart-card {
            background: #fff; border: 1px solid var(--border-color);
            border-radius: 20px; padding: 28px 24px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.05);
        }
        .chart-card h3 {
            font-family: var(--font-serif); font-size: 22px; font-weight: 700;
            color: #1e293b; margin: 0 0 4px;
        }
        .chart-card .chart-sub { color: #64748b; font-size: 13px; margin-bottom: 22px; }
        .chart-wrap { position: relative; height: 260px; }

        /* ── Metadata card ─── */
        .meta-row { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 28px; }
        @media(max-width:700px){ .meta-row { grid-template-columns: 1fr; } }

        .meta-bar-item { margin-bottom: 14px; }
        .meta-bar-label { display: flex; justify-content: space-between; font-size: 13px; color: #1e293b; font-weight: 600; margin-bottom: 6px; }
        .meta-bar-track { height: 8px; background: #f1f5f9; border-radius: 8px; overflow: hidden; }
        .meta-bar-fill  { height: 100%; border-radius: 8px; transition: width 1.2s cubic-bezier(.4,0,.2,1); }

        /* ── Activity log ─── */
        .activity-card {
            background: #fff; border: 1px solid var(--border-color);
            border-radius: 20px; padding: 28px 24px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.05);
        }
        .activity-card h3 { font-family: var(--font-serif); font-size: 22px; font-weight: 700; color: #1e293b; margin: 0 0 4px; }
        .activity-card .chart-sub { color: #64748b; font-size: 13px; margin-bottom: 18px; }

        .log-timeline { position: relative; padding-left: 20px; }
        .log-timeline::before {
            content: ''; position: absolute; left: 5px; top: 0; bottom: 0;
            width: 2px; background: linear-gradient(to bottom, #bfdbfe, transparent);
        }
        .log-item { display: flex; gap: 14px; align-items: flex-start; padding: 11px 0; position: relative; }
        .log-dot {
            width: 10px; height: 10px; border-radius: 50%; background: #2563eb;
            border: 2px solid #eff6ff; flex-shrink: 0; margin-top: 4px;
            position: absolute; left: -16px;
        }
        .log-body { flex: 1; }
        .log-action { font-size: 13px; color: #1e293b; font-weight: 600; line-height: 1.4; }
        .log-time   { font-size: 11px; color: #94a3b8; margin-top: 3px; display: flex; align-items: center; gap: 4px; }
        .log-empty  { color: #94a3b8; text-align: center; padding: 24px; font-size: 14px; }

        @keyframes countUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .kpi-value { animation: countUp 0.5s ease forwards; }
    </style>
</head>
<body>

<jsp:include page='<%= usageIsAdmin ? "../components/adminSidebar.jsp" : "../components/sidebar.jsp" %>' />

<main class="main-content">
<jsp:include page='<%= usageIsAdmin ? "../components/adminHeader.jsp" : "../components/Header.jsp" %>' />

<div class="usage-shell">

    <!-- ── Page header ─────────────────────────────────────── -->
    <div class="usage-header">
        <div>
            <h5>ANALYTICS</h5>
            <h1>Usage Dashboard</h1>
            <div class="header-sub">Live statistics about your DigiPic archive</div>
        </div>
        <a href="<%= request.getContextPath() %>/gallery"
           style="display:inline-flex;align-items:center;gap:8px;padding:12px 22px;background:linear-gradient(135deg,#2563eb,#1e40af);color:#fff;border-radius:12px;font-weight:700;text-decoration:none;font-size:14px;box-shadow:0 4px 12px rgba(37,99,235,.2);transition:all .2s;">
            <i class="bi bi-images"></i> Go to Gallery
        </a>
    </div>

    <!-- ── KPI cards ───────────────────────────────────────── -->
    <div class="kpi-row">
        <div class="kpi-card blue">
            <i class="bi bi-images kpi-icon"></i>
            <div class="kpi-label">Total Photos</div>
            <div class="kpi-value" id="kvPhotos">0</div>
            <div class="kpi-sub">files in your archive</div>
        </div>
        <div class="kpi-card green">
            <i class="bi bi-folder2 kpi-icon"></i>
            <div class="kpi-label">Total Albums</div>
            <div class="kpi-value" id="kvAlbums">0</div>
            <div class="kpi-sub">collections created</div>
        </div>
        <div class="kpi-card amber">
            <i class="bi bi-bar-chart-line kpi-icon"></i>
            <div class="kpi-label">Avg per Album</div>
            <div class="kpi-value" id="kvAvg">0</div>
            <div class="kpi-sub">photos per collection</div>
        </div>
    </div>

    <!-- ── Charts ──────────────────────────────────────────── -->
    <div class="chart-row" style="grid-template-columns: 1fr;">
        <!-- Photos per album bar chart -->
        <div class="chart-card">
            <h3>Photos by Album</h3>
            <div class="chart-sub">Distribution of photos across your collections</div>
            <div class="chart-wrap">
                <canvas id="albumChart"></canvas>
            </div>
        </div>
    </div>

    <!-- ── Metadata + Activity ─────────────────────────────── -->
    <div class="meta-row">
        <!-- Camera metadata richness -->
        <div class="chart-card">
            <h3>Metadata Richness</h3>
            <div class="chart-sub">How many photos have EXIF camera data filled in</div>
            <%
                int tp = totalPhotos > 0 ? totalPhotos : 1;
                int pAperture = (int)Math.round(withAperture  * 100.0 / tp);
                int pISO      = (int)Math.round(withISO       * 100.0 / tp);
                int pShutter  = (int)Math.round(withShutter   * 100.0 / tp);
                int pFocal    = (int)Math.round(withFocal     * 100.0 / tp);
            %>
            <div class="meta-bar-item">
                <div class="meta-bar-label"><span><i class="bi bi-aperture"></i> Aperture</span><span><%= withAperture %>/<%= totalPhotos %></span></div>
                <div class="meta-bar-track"><div class="meta-bar-fill" style="width:0%;background:linear-gradient(90deg,#2563eb,#60a5fa);" data-target="<%= pAperture %>"></div></div>
            </div>
            <div class="meta-bar-item">
                <div class="meta-bar-label"><span><i class="bi bi-sun"></i> ISO</span><span><%= withISO %>/<%= totalPhotos %></span></div>
                <div class="meta-bar-track"><div class="meta-bar-fill" style="width:0%;background:linear-gradient(90deg,#7c3aed,#a78bfa);" data-target="<%= pISO %>"></div></div>
            </div>
            <div class="meta-bar-item">
                <div class="meta-bar-label"><span><i class="bi bi-camera"></i> Shutter Speed</span><span><%= withShutter %>/<%= totalPhotos %></span></div>
                <div class="meta-bar-track"><div class="meta-bar-fill" style="width:0%;background:linear-gradient(90deg,#16a34a,#4ade80);" data-target="<%= pShutter %>"></div></div>
            </div>
            <div class="meta-bar-item">
                <div class="meta-bar-label"><span><i class="bi bi-binoculars"></i> Focal Length</span><span><%= withFocal %>/<%= totalPhotos %></span></div>
                <div class="meta-bar-track"><div class="meta-bar-fill" style="width:0%;background:linear-gradient(90deg,#d97706,#fbbf24);" data-target="<%= pFocal %>"></div></div>
            </div>
        </div>

        <!-- Recent activity -->
        <div class="activity-card">
            <h3>Recent Activity</h3>
            <div class="chart-sub">Your last 15 recorded actions</div>
            <div class="log-timeline">
                <% if (recentLogs == null || recentLogs.isEmpty()) { %>
                    <div class="log-empty"><i class="bi bi-journal-x" style="font-size:28px;display:block;margin-bottom:8px;"></i>No activity recorded yet.</div>
                <% } else { for (AuditLog log : recentLogs) { %>
                    <div class="log-item">
                        <div class="log-dot"></div>
                        <div class="log-body">
                            <div class="log-action"><%= log.getActionDetails() != null ? log.getActionDetails() : "–" %></div>
                            <div class="log-time">
                                <i class="bi bi-clock"></i>
                                <%= log.getLogTime() != null ? log.getLogTime().toString().substring(0,16) : "–" %>
                            </div>
                        </div>
                    </div>
                <% } } %>
            </div>
        </div>
    </div>

</div>

<jsp:include page="../components/footer.jsp" />
</main>

<script>
    // ── Server data ──────────────────────────────────────────────────
    const DATA = {
        totalPhotos: <%= totalPhotos %>,
        totalAlbums: <%= totalAlbums %>,
        avgPerAlbum: <%= String.format("%.1f", avgPerAlbum) %>,
        albumLabels: <%= albumLabels %>,
        albumData:   <%= albumData %>
    };

    // ── Animated KPI counters ────────────────────────────────────────
    function animateCount(el, target, decimals, suffix) {
        const duration = 1000;
        const step     = 16;
        const steps    = duration / step;
        const inc      = target / steps;
        let cur = 0;
        const timer = setInterval(() => {
            cur += inc;
            if (cur >= target) { cur = target; clearInterval(timer); }
            el.textContent = decimals > 0 ? cur.toFixed(decimals) : Math.floor(cur);
        }, step);
    }

    window.addEventListener('DOMContentLoaded', () => {
        animateCount(document.getElementById('kvPhotos'), DATA.totalPhotos, 0);
        animateCount(document.getElementById('kvAlbums'), DATA.totalAlbums, 0);
        animateCount(document.getElementById('kvAvg'),    parseFloat(DATA.avgPerAlbum), 1);

        // ── Bar chart: Photos per album ──────────────────────────────
        const barCtx = document.getElementById('albumChart').getContext('2d');
        if (DATA.albumLabels.length > 0) {
            new Chart(barCtx, {
                type: 'bar',
                data: {
                    labels: DATA.albumLabels,
                    datasets: [{
                        label: 'Photos',
                        data: DATA.albumData,
                        backgroundColor: DATA.albumLabels.map((_, i) => {
                            const colors = ['#2563eb','#7c3aed','#16a34a','#d97706','#0891b2','#be185d'];
                            return colors[i % colors.length] + 'cc';
                        }),
                        borderColor: DATA.albumLabels.map((_, i) => {
                            const colors = ['#2563eb','#7c3aed','#16a34a','#d97706','#0891b2','#be185d'];
                            return colors[i % colors.length];
                        }),
                        borderWidth: 2,
                        borderRadius: 8,
                        borderSkipped: false,
                    }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { display: false }, tooltip: { callbacks: { label: c => ' ' + c.raw + ' photo' + (c.raw !== 1 ? 's' : '') } } },
                    scales: {
                        x: { grid: { display: false }, ticks: { font: { family: 'Sora', size: 12 }, maxRotation: 30 } },
                        y: { grid: { color: '#f1f5f9' }, ticks: { font: { family: 'Sora', size: 12 }, stepSize: 1 }, beginAtZero: true }
                    }
                }
            });
        } else {
            barCtx.canvas.parentElement.innerHTML = '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#94a3b8;font-size:14px;">No albums yet — create one to see data here.</div>';
        }



        // ── Animate metadata bars ────────────────────────────────────
        document.querySelectorAll('.meta-bar-fill').forEach(bar => {
            const target = parseInt(bar.dataset.target || '0');
            setTimeout(() => { bar.style.width = target + '%'; }, 300);
        });
    });
</script>
</body>
</html>
