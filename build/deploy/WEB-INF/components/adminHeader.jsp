<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">

<%
    String adminUri = request.getRequestURI();
    String adminTitle = "The Bio-Luminous Gallery";
    String adminSubtitle = "VAULT: PERSONAL ARCHIVES";
    String adminActivePage = "";

    if (adminUri != null) {
        if (adminUri.contains("/albums"))                          { adminTitle = "Collections Overview";   adminSubtitle = "ADMIN CURATION HUB";    adminActivePage = "albums"; }
        else if (adminUri.contains("/captain-cabin"))              { adminTitle = "Captain's Cabin";        adminSubtitle = "ADMIN CONTROL DECK";    adminActivePage = "captain"; }
        else if (adminUri.contains("/uploadImport"))               { adminTitle = "Upload & Import";        adminSubtitle = "MEDIA MANAGEMENT";      adminActivePage = "upload"; }
        else if (adminUri.contains("/audit-log"))                  { adminTitle = "Audit Logs";             adminSubtitle = "SYSTEM ACTIVITY LOGS";  adminActivePage = "audit"; }
        else if (adminUri.contains("/gallery"))                    { adminTitle = "The Bio-Luminous Gallery"; adminSubtitle = "VAULT: PERSONAL ARCHIVES"; adminActivePage = "gallery"; }
    }
%>

<!-- ═══════════════════════════════ ADMIN HEADER ═══════════════════════════════ -->
<div class="header" id="adminHeader">

    <!-- Mobile hamburger button -->
    <button class="mobile-hamburger" onclick="openMobileSidebar()" aria-label="Open menu">
        <i class="bi bi-list"></i>
    </button>

    <div class="header-left">
        <h1 class="page-title"><%= adminTitle %></h1>
        <p class="page-subtitle"><%= adminSubtitle %></p>
    </div>

    <div class="header-right">

        <!-- SMART SEARCH BAR -->
        <div class="search-wrapper">
            <i class="bi bi-search search-ico"></i>
            <input  type="text"
                    id="adminSearchBar"
                    class="search-bar"
                    placeholder="Search users, records, or logs..."
                    autocomplete="off"
                    oninput="handleAdminSearch(this.value)">
            <div class="search-results-dropdown" id="adminSearchResults"></div>
        </div>

        <!-- ICON TRAY -->
        <div class="header-icons">
            <div class="icon notif-trigger" title="Notifications" onclick="toggleAdminNotifPanel(event)">
                <i class="bi bi-bell"></i>
                <span class="notif-badge" id="adminNotifBadge">1</span>
            </div>
            <div class="icon" title="System Status">
                <i class="bi bi-bar-chart-fill"></i>
            </div>
        </div>

    </div>
</div>

<!-- ─────────────── ADMIN NOTIFICATION PANEL ─────────────── -->
<div class="notif-panel" id="adminNotifPanel">
    <div class="notif-panel-hdr">
        <span><i class="bi bi-bell-fill"></i> Admin Alerts</span>
        <button onclick="closeAdminNotifPanel()"><i class="bi bi-x-lg"></i></button>
    </div>
    <div class="notif-entry unread">
        <div class="notif-ico info"><i class="bi bi-info-circle-fill"></i></div>
        <div class="notif-txt">
            <div class="notif-msg">System backup completed successfully</div>
            <div class="notif-time">1 hour ago</div>
        </div>
    </div>
</div>

<style>
    :root {
        --font-family: 'Sora', sans-serif;
        --font-serif: 'Cormorant Garamond', serif;
        --text-primary: #1e293b;
        --text-muted: #94a3b8;
        --bg-surface: #ffffff;
        --bg-surface-light: #f8fafc;
        --border-color: #e2e8f0;
    }

    /* ── Header Base ─────────────────────────────────────── */
    .header-left {
        flex: 1;
    }

    .page-title {
        margin: 0;
        font-size: 32px;
        font-family: var(--font-serif);
        font-weight: 700;
        color: var(--text-primary);
    }

    .page-subtitle {
        margin: 6px 0 0;
        font-size: 12px;
        letter-spacing: 1.2px;
        text-transform: uppercase;
        color: #2563eb;
        font-weight: 700;
    }

    /* ── Header Right ─────────────────────────────────────── */
    .header-right {
        display: flex;
        align-items: center;
        gap: 18px;
        flex-shrink: 0;
    }

    /* ── Search Wrapper ─────────────────────────────────────── */
    .search-wrapper {
        position: relative;
        background: var(--bg-surface-light);
        border: 1.5px solid var(--border-color);
        border-radius: 12px;
        overflow: visible;
        transition: border-color 0.2s, box-shadow 0.2s;
    }

    .search-wrapper:focus-within {
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
    }

    .search-ico {
        position: absolute;
        left: 12px;
        color: #94a3b8;
        font-size: 14px;
        pointer-events: none;
    }

    .search-bar {
        width: 280px;
        padding: 9px 52px 9px 34px;
        background: transparent;
        border: none;
        outline: none;
        color: var(--text-primary);
        font-size: 13.5px;
        font-family: var(--font-family);
    }

    .search-bar::placeholder {
        color: #94a3b8;
    }

    .search-results-dropdown {
        display: none;
        position: absolute;
        top: calc(100% + 6px);
        left: 0;
        width: 340px;
        background: var(--bg-surface);
        border: 1px solid var(--border-color);
        border-radius: 14px;
        box-shadow: 0 12px 32px rgba(0,0,0,0.1);
        z-index: 9999;
        overflow: hidden;
        max-height: 380px;
        overflow-y: auto;
    }

    .search-results-dropdown.open {
        display: block;
    }

    /* ── Header Icons ─────────────────────────────────────── */
    .header-icons {
        display: flex;
        gap: 10px;
    }

    .icon {
        width: 38px;
        height: 38px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 10px;
        background: var(--bg-surface-light);
        border: 1px solid var(--border-color);
        cursor: pointer;
        transition: all 0.2s ease;
        position: relative;
    }

    .icon:hover {
        background: #eff6ff;
        border-color: #2563eb;
        color: #2563eb;
    }

    .icon i {
        font-size: 16px;
    }

    .notif-badge {
        position: absolute;
        top: -6px;
        right: -6px;
        background: #ef4444;
        color: white;
        font-size: 10px;
        font-weight: 800;
        width: 20px;
        height: 20px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2px solid var(--bg-surface);
    }

    /* ── Notification Panel ─────────────────────────────────────── */
    .notif-panel {
        position: fixed;
        top: 70px;
        right: 24px;
        width: 360px;
        max-height: 500px;
        background: var(--bg-surface);
        border: 1px solid var(--border-color);
        border-radius: 14px;
        box-shadow: 0 12px 32px rgba(0,0,0,0.12);
        z-index: 9998;
        display: none;
        flex-direction: column;
        overflow: hidden;
    }

    .notif-panel.open {
        display: flex;
    }

    .notif-panel-hdr {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 14px 16px;
        border-bottom: 1px solid var(--border-color);
        font-weight: 700;
        font-size: 13px;
        color: var(--text-primary);
    }

    .notif-panel-hdr button {
        background: none;
        border: none;
        cursor: pointer;
        color: #94a3b8;
        font-size: 16px;
    }

    .notif-panel-hdr button:hover {
        color: var(--text-primary);
    }

    .notif-entry {
        display: flex;
        gap: 12px;
        padding: 12px 14px;
        border-bottom: 1px solid var(--border-color);
        cursor: pointer;
        transition: background 0.2s;
    }

    .notif-entry:last-child {
        border-bottom: none;
    }

    .notif-entry:hover {
        background: #f8fafc;
    }

    .notif-entry.unread {
        background: #eff6ff;
    }

    .notif-ico {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        flex-shrink: 0;
    }

    .notif-ico.info {
        background: #dbeafe;
        color: #2563eb;
    }

    .notif-txt {
        flex: 1;
        min-width: 0;
    }

    .notif-msg {
        font-size: 13px;
        font-weight: 600;
        color: var(--text-primary);
        margin-bottom: 2px;
    }

    .notif-time {
        font-size: 11px;
        color: #94a3b8;
    }

    /* ── Responsive ─────────────────────────────────────── */
    @media (max-width: 1200px) {
        .page-title {
            font-size: 26px;
        }

        .search-bar {
            width: 220px;
        }
    }

    @media (max-width: 768px) {
        .search-wrapper {
            display: none !important;
        }

        .page-title {
            font-size: 18px;
        }

        .page-subtitle {
            font-size: 9px;
        }

        .notif-panel {
            right: 8px;
            left: 8px;
            width: auto;
            top: 60px;
        }
    }
</style>

<script>
    function toggleAdminNotifPanel(event) {
        event.stopPropagation();
        var panel = document.getElementById('adminNotifPanel');
        if (panel) {
            panel.classList.toggle('open');
        }
    }

    function closeAdminNotifPanel() {
        var panel = document.getElementById('adminNotifPanel');
        if (panel) {
            panel.classList.remove('open');
        }
    }

    function handleAdminSearch(value) {
        var dropdown = document.getElementById('adminSearchResults');
        if (!dropdown) return;

        if (!value || value.trim().length === 0) {
            dropdown.classList.remove('open');
            dropdown.innerHTML = '';
            return;
        }

        // Placeholder search results for admin
        var results = [
            { name: 'User: john@example.com', type: 'Email' },
            { name: 'Log: Admin action', type: 'Audit' },
            { name: 'Album: Vacation 2025', type: 'Record' }
        ];

        var html = results
            .filter(r => r.name.toLowerCase().includes(value.toLowerCase()))
            .map(r => '<div class="srd-item"><div class="srd-info"><div class="srd-name">' + r.name + '</div><div class="srd-meta">' + r.type + '</div></div></div>')
            .join('');

        if (html) {
            dropdown.innerHTML = html;
            dropdown.classList.add('open');
        } else {
            dropdown.classList.remove('open');
        }
    }

    // Close on outside click
    document.addEventListener('click', function(e) {
        var np = document.getElementById('adminNotifPanel');
        var sb = document.getElementById('adminSearchBar');
        if (np && !np.contains(e.target) && !e.target.closest('.notif-trigger')) closeAdminNotifPanel();
        if (sb && !sb.closest('.search-wrapper').contains(e.target)) {
            var dr = document.getElementById('adminSearchResults');
            if (dr) dr.classList.remove('open');
        }
    });
</script>