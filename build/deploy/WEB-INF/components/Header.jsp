<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.DigiPic4.model.User, com.DigiPic4.dao.PhotoDAO, com.DigiPic4.dao.AlbumDAO" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">

<%
    String headerUri  = request.getRequestURI();
    String headerTitle    = "The Bio-Luminous Gallery";
    String headerSubtitle = "VAULT: PERSONAL ARCHIVES";
    String activePage     = "";

    if (headerUri != null) {
        if (headerUri.endsWith("/albums"))                                  { headerTitle = "Collections Overview";   headerSubtitle = "CURATION HUB";        activePage = "albums"; }
        else if (headerUri.endsWith("/uploadImport"))                       { headerTitle = "Upload & Import";        headerSubtitle = "MEDIA MANAGEMENT";    activePage = "upload"; }
        else if (headerUri.endsWith("/explore"))                            { headerTitle = "Explore the Ocean";      headerSubtitle = "DISCOVERY FEED";       activePage = "explore"; }
        else if (headerUri.endsWith("/about"))                              { headerTitle = "About Us";               headerSubtitle = "OUR STORY & MISSION";  activePage = "about"; }
        else if (headerUri.endsWith("/contact"))                            { headerTitle = "Contact Us";             headerSubtitle = "GET IN TOUCH";         activePage = "contact"; }
        else if (headerUri.endsWith("/gallery"))                            { headerTitle = "The Bio-Luminous Gallery"; headerSubtitle = "VAULT: PERSONAL ARCHIVES"; activePage = "gallery"; }
    }

    User   hUser    = (User) session.getAttribute("user");
    String hName    = (hUser != null)
                        ? (hUser.getFirstName() != null ? hUser.getFirstName() : "") + " "
                          + (hUser.getLastName()  != null ? hUser.getLastName()  : "")
                        : "User";
    hName = hName.trim();
    String hEmail   = (hUser != null && hUser.getEmail()  != null) ? hUser.getEmail()  : "";
    String hFirst   = (hUser != null && hUser.getFirstName() != null) ? hUser.getFirstName() : "";
    String hLast    = (hUser != null && hUser.getLastName()  != null) ? hUser.getLastName()  : "";
    String hCtx     = request.getContextPath();
    String isExplore = "explore".equals(activePage) ? "true" : "false";

    int headerPhotoCount = 0;
    int headerAlbumCount = 0;
    if (hUser != null) {
        headerPhotoCount = new PhotoDAO().countPhotosByUser(hUser.getUserId());
        headerAlbumCount = new AlbumDAO().countAlbumsByUser(hUser.getUserId());
    }
%>

<!-- ═══════════════════════════════ HEADER ═══════════════════════════════ -->
<div class="header" id="mainHeader">

    <!-- Mobile hamburger button -->
    <button class="mobile-hamburger" onclick="openMobileSidebar()" aria-label="Open menu">
        <i class="bi bi-list"></i>
    </button>

    <div class="header-left">
        <h1 class="page-title"><%= headerTitle %></h1>
        <p class="page-subtitle"><%= headerSubtitle %></p>
    </div>

    <div class="header-right">

        <!-- SMART SEARCH BAR -->
        <div class="search-wrapper">
            <i class="bi bi-search search-ico"></i>
            <input  type="text"
                    id="globalSearchBar"
                    class="search-bar"
                    placeholder="<%= "explore".equals(activePage) ? "Search the ocean…" : "Search your archive…" %>"
                    autocomplete="off"
                    oninput="handleSearch(this.value)"
                    onkeydown="handleSearchKey(event)">
            <span class="search-mode-tag" id="searchModeTag">
                <%= "explore".equals(activePage) ? "API" : "LOCAL" %>
            </span>
            <div class="search-results-dropdown" id="searchResultsDropdown"></div>
        </div>

        <!-- ICON TRAY -->
        <div class="header-icons">
            <div class="icon notif-trigger" title="Notifications" onclick="toggleNotifPanel(event)">
                <i class="bi bi-bell"></i>
                <span class="notif-badge" id="notifBadge">2</span>
            </div>
            <div class="icon" title="Settings" onclick="toggleSettings(event)" id="gearIconBtn">
                <i class="bi bi-gear-fill"></i>
            </div>
        </div>

        <!-- PROFILE BUTTON (clickable → settings) -->
        <button class="profile-trigger" onclick="toggleSettings(event)" title="Account & Settings">
            <div class="profile-avatar-wrap" id="profileAvatarWrap">
                <i class="bi bi-person-circle default-avatar-icon" id="profileDefaultIcon"></i>
                <img id="profileCustomImg"
                     style="display:none; width:40px; height:40px; border-radius:50%; object-fit:cover; border:2.5px solid #2563eb; box-shadow:0 0 0 3px rgba(37,99,235,0.15);"
                     alt="Profile">
            </div>
            <i class="bi bi-chevron-down profile-chevron" id="profileChevron"></i>
        </button>

    </div>
</div>

<!-- ─────────────── SETTINGS DROPDOWN PANEL ─────────────── -->
<div class="settings-scrim"  id="settingsScrim"  onclick="closeSettings()"></div>
<div class="settings-panel"  id="settingsPanel">

    <!-- Panel top strip -->
    <div class="sp-top">
        <div class="sp-avatar-big" id="spAvatarBig">
            <i class="bi bi-person-circle sp-avatar-ico" id="spAvatarIco"></i>
            <img id="spAvatarImg"
                 style="display:none; width:100%; height:100%; object-fit:cover; border-radius:50%;"
                 alt="Avatar">
            <label class="sp-avatar-edit" for="profileUploadInput" title="Change photo">
                <i class="bi bi-camera-fill"></i>
            </label>
        </div>
        <div class="sp-user-meta">
            <div class="sp-user-name"  id="spUserName"><%= hName %></div>
            <div class="sp-user-email"><%= hEmail %></div>
            <span class="sp-plan-pill"><i class="bi bi-gem"></i> <%= hUser != null ? hUser.getCredits() : 0 %> Credits</span>
        </div>
        <button class="sp-close-btn" onclick="closeSettings()"><i class="bi bi-x-lg"></i></button>
    </div>
    <input type="file" id="profileUploadInput" accept="image/*" style="display:none;" onchange="applyProfilePhoto(this)">

    <!-- Tabs -->
    <div class="sp-tab-row">
        <button class="sp-tab-btn active" data-tab="profile"  onclick="switchTab('profile',  this)"><i class="bi bi-person-fill"></i> Profile</button>
        <button class="sp-tab-btn"        data-tab="plan"     onclick="switchTab('plan',     this)"><i class="bi bi-gem"></i> Plans</button>
        <button class="sp-tab-btn"        data-tab="usage"    onclick="switchTab('usage',    this)"><i class="bi bi-bar-chart-fill"></i> Usage</button>
    </div>

    <!-- ── TAB: PROFILE ── -->
    <div class="sp-tab-body" id="tab-profile">
        <p class="sp-section-lbl">Edit Profile Information</p>
        <form action="<%= hCtx %>/profile" method="post" class="sp-mini-form">
            <input type="hidden" name="action" value="updateProfile">
            <input type="hidden" name="email"  value="<%= hEmail %>">
            <div class="sp-field-row">
                <div class="sp-field">
                    <label>First Name</label>
                    <input type="text" name="firstName" value="<%= hFirst %>" required>
                </div>
                <div class="sp-field">
                    <label>Last Name</label>
                    <input type="text" name="lastName"  value="<%= hLast  %>" required>
                </div>
            </div>
            <div class="sp-field">
                <label>Email Address</label>
                <input type="email" name="email" value="<%= hEmail %>" required>
            </div>
            <button type="submit" class="sp-primary-btn"><i class="bi bi-save2"></i> Save Changes</button>
        </form>

        <div class="sp-sep"></div>
        <p class="sp-section-lbl">Profile Photo</p>
        <div class="photo-actions-row">
            <label for="profileUploadInput" class="sp-outline-btn"><i class="bi bi-upload"></i> Upload New Photo</label>
            <button class="sp-outline-btn danger" onclick="removeProfilePhoto()"><i class="bi bi-trash3"></i> Remove</button>
        </div>

        <div class="sp-sep"></div>
        <a href="<%= hCtx %>/logout" class="sp-signout-link"><i class="bi bi-box-arrow-right"></i> Sign Out</a>
    </div>

    <!-- ── TAB: PLAN ── -->
    <div class="sp-tab-body" id="tab-plan" style="display:none;">
        <div class="current-plan-strip">
            <i class="bi bi-lightning-fill"></i>
            <span>You are on the <strong>Free Plan</strong></span>
        </div>
        <div class="plan-cards-row">
            <!-- Free -->
            <div class="plan-card-item">
                <div class="plan-item-name">Free</div>
                <div class="plan-item-price">$0<span>/mo</span></div>
                <ul class="plan-item-features">
                    <li><i class="bi bi-check2"></i> 3 Albums</li>
                    <li><i class="bi bi-check2"></i> 50 Photos</li>
                    <li><i class="bi bi-check2"></i> Basic Search</li>
                </ul>
                <button class="plan-item-btn current" disabled>Current Plan</button>
            </div>
            <!-- Pro -->
            <div class="plan-card-item featured">
                <div class="plan-popular-tag">✦ Popular</div>
                <div class="plan-item-name">Pro</div>
                <div class="plan-item-price">$9<span>/mo</span></div>
                <ul class="plan-item-features">
                    <li><i class="bi bi-check2"></i> Unlimited Albums</li>
                    <li><i class="bi bi-check2"></i> AI-Powered Search</li>
                    <li><i class="bi bi-check2"></i> Photo Map & Geotag</li>
                    <li><i class="bi bi-check2"></i> Explore API Access</li>
                </ul>
                <button class="plan-item-btn upgrade" onclick="alert('Pro plan upgrade — coming soon!')">Upgrade to Pro</button>
            </div>
            <!-- Enterprise -->
            <div class="plan-card-item">
                <div class="plan-item-name">Enterprise</div>
                <div class="plan-item-price">$29<span>/mo</span></div>
                <ul class="plan-item-features">
                    <li><i class="bi bi-check2"></i> Team Collaboration</li>
                    <li><i class="bi bi-check2"></i> Priority Support</li>
                    <li><i class="bi bi-check2"></i> Custom Branding</li>
                    <li><i class="bi bi-check2"></i> SLA Guarantee</li>
                </ul>
                <button class="plan-item-btn upgrade" onclick="alert('Contact sales@digipic.com')">Contact Sales</button>
            </div>
        </div>
    </div>

    <!-- ── TAB: USAGE ── -->
    <div class="sp-tab-body" id="tab-usage" style="display:none;">
        <div class="current-plan-strip"><i class="bi bi-lightning-fill"></i><span>Free Plan — Renews Never</span></div>
        <div class="usage-list">
            <div class="usage-row">
                <div class="usage-row-label"><i class="bi bi-folder2"></i> Albums</div>
                <% int albumPct = Math.min(100, headerAlbumCount * 100 / 3); %>
                <div class="usage-row-bar"><div class="ubfill <%= headerAlbumCount >= 3 ? "orange" : "" %>" style="width:<%= albumPct %>%;"></div></div>
                <div class="usage-row-val"><%= headerAlbumCount %> <span>/ 3</span></div>
            </div>
            <div class="usage-row">
                <div class="usage-row-label"><i class="bi bi-image"></i> Photos</div>
                <% int photoPct = Math.min(100, headerPhotoCount * 100 / 50); %>
                <div class="usage-row-bar"><div class="ubfill <%= headerPhotoCount >= 50 ? "orange" : "" %>" style="width:<%= photoPct %>%;"></div></div>
                <div class="usage-row-val"><%= headerPhotoCount %> <span>/ 50</span></div>
            </div>
            <div class="usage-row">
                <div class="usage-row-label"><i class="bi bi-compass"></i> API Calls</div>
                <div class="usage-row-bar"><div class="ubfill" style="width:12%;"></div></div>
                <div class="usage-row-val">120 <span>/ 1,000</span></div>
            </div>
            <div class="usage-row">
                <div class="usage-row-label"><i class="bi bi-gem"></i> Plan Credits</div>
                <div class="usage-row-bar"><div class="ubfill <%= (hUser != null && hUser.getCredits() < 20) ? "orange" : "" %>" style="width:<%= hUser != null ? Math.min(100, (hUser.getCredits() / 5)) : 0 %>%;"></div></div>
                <div class="usage-row-val"><%= hUser != null ? hUser.getCredits() : 0 %> <span>/ 500</span></div>
            </div>
        </div>
        <a href="<%= hCtx %>/profile" class="sp-link-btn"><i class="bi bi-person-badge"></i> Full Profile & Audit Log</a>
    </div>

</div>

<!-- ─────────────── NOTIFICATION PANEL ─────────────── -->
<div class="notif-panel" id="notifPanel">
    <div class="notif-panel-hdr">
        <span><i class="bi bi-bell-fill"></i> Notifications</span>
        <button onclick="closeNotifPanel()"><i class="bi bi-x-lg"></i></button>
    </div>
    <div class="notif-entry unread">
        <div class="notif-ico sync"><i class="bi bi-cloud-check-fill"></i></div>
        <div class="notif-txt">
            <div class="notif-msg">Sync complete — 3 photos uploaded successfully</div>
            <div class="notif-time">2 minutes ago</div>
        </div>
    </div>
    <div class="notif-entry">
        <div class="notif-ico info"><i class="bi bi-stars"></i></div>
        <div class="notif-txt">
            <div class="notif-msg">New feature: Photo Map is now available!</div>
            <div class="notif-time">Yesterday</div>
        </div>
    </div>
    <button class="notif-clear-btn" onclick="clearNotifs()">Mark all as read</button>
</div>

<!-- ══════════════════════ STYLES ══════════════════════ -->
<style>
/* ── Header Shell ─────────────────────────────────────── */
.header-right { display: flex; align-items: center; gap: 14px; }

/* ── Search ───────────────────────────────────────────── */
.search-wrapper {
    position: relative; display: flex; align-items: center;
    background: var(--bg-surface-light);
    border: 1.5px solid var(--border-color);
    border-radius: 12px; overflow: visible;
    transition: border-color 0.2s, box-shadow 0.2s;
}
.search-wrapper:focus-within {
    border-color: #2563eb;
    box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
}
.search-ico {
    position: absolute; left: 12px; color: #94a3b8; font-size: 14px; pointer-events: none;
}
.search-bar {
    width: 280px; padding: 9px 52px 9px 34px;
    background: transparent; border: none; outline: none;
    color: var(--text-primary); font-size: 13.5px; font-family: var(--font-family);
}
.search-bar::placeholder { color: #94a3b8; }
.search-mode-tag {
    position: absolute; right: 10px;
    font-size: 9px; font-weight: 800; letter-spacing: 1px;
    color: #2563eb; background: #eff6ff; border: 1px solid #dbeafe;
    padding: 2px 7px; border-radius: 20px; pointer-events: none;
    text-transform: uppercase;
}
.search-results-dropdown {
    display: none; position: absolute; top: calc(100% + 6px); left: 0;
    width: 340px; background: var(--bg-surface);
    border: 1px solid var(--border-color);
    border-radius: 14px; box-shadow: 0 12px 32px rgba(0,0,0,0.1);
    z-index: 9999; overflow: hidden; max-height: 380px; overflow-y: auto;
}
.search-results-dropdown.open { display: block; }
.srd-item {
    display: flex; align-items: center; gap: 12px;
    padding: 10px 14px; cursor: pointer; transition: background 0.15s;
    border-bottom: 1px solid var(--border-color);
}
.srd-item:last-child { border-bottom: none; }
.srd-item:hover { background: #f0f4f8; }
.srd-thumb { width: 44px; height: 36px; border-radius: 8px; object-fit: cover; flex-shrink: 0; }
.srd-thumb-ph { width: 44px; height: 36px; border-radius: 8px; background: #e0e7ff; display:flex; align-items:center; justify-content:center; color:#2563eb; font-size:18px; flex-shrink:0; }
.srd-info { flex:1; min-width:0; }
.srd-name { font-size: 13px; font-weight: 600; color: #1e293b; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.srd-meta { font-size: 11px; color: #94a3b8; margin-top: 2px; }

/* ── Header Icons ─────────────────────────────────────── */
.icon {
    width: 38px; height: 38px; display:flex; align-items:center; justify-content:center;
    border-radius: 10px; background: var(--bg-surface-light);
    border: 1px solid var(--border-color); cursor: pointer;
    font-size: 17px; position: relative; transition: all 0.2s;
}
.icon:hover { color: #2563eb; border-color: #93c5fd; box-shadow: 0 4px 12px rgba(37,99,235,0.15); }
.notif-badge {
    position: absolute; top: -5px; right: -5px;
    width: 18px; height: 18px; border-radius: 50%;
    background: #ef4444; color: #fff; font-size: 10px; font-weight: 800;
    display: flex; align-items: center; justify-content: center;
    border: 2px solid var(--bg-surface);
}

/* ── Profile Button ───────────────────────────────────── */
.profile-trigger {
    display: flex; align-items: center; gap: 6px; padding: 4px 10px 4px 4px;
    background: var(--bg-surface-light); border: 1.5px solid var(--border-color);
    border-radius: 24px; cursor: pointer; transition: all 0.2s;
}
.profile-trigger:hover { border-color: #2563eb; box-shadow: 0 4px 14px rgba(37,99,235,0.15); }
.profile-avatar-wrap { width: 40px; height: 40px; position: relative; }
.default-avatar-icon { font-size: 38px; color: #2563eb; line-height: 1; }
.profile-chevron { font-size: 11px; color: #64748b; transition: transform 0.25s; }
.settings-open .profile-chevron { transform: rotate(180deg); }

/* ── Settings Scrim ───────────────────────────────────── */
.settings-scrim {
    display: none; position: fixed; inset: 0; z-index: 10002; background: rgba(0,0,0,0.22);
    backdrop-filter: blur(3px);
}
.settings-scrim.open { display: block; }

/* ── Settings Panel ───────────────────────────────────── */
.settings-panel {
    position: fixed; top: 0; right: -440px; width: 420px; height: 100vh;
    background: var(--bg-surface); border-left: 1px solid var(--border-color);
    box-shadow: -12px 0 40px rgba(0,0,0,0.1); z-index: 10003;
    display: flex; flex-direction: column; overflow-y: auto;
    transition: right 0.32s cubic-bezier(.4,0,.2,1);
}
.settings-panel.open { right: 0; }

/* ── SP Top Strip ─────────────────────────────────────── */
.sp-top {
    display: flex; align-items: center; gap: 14px; padding: 24px 22px 18px;
    border-bottom: 1px solid var(--border-color);
    background: linear-gradient(135deg, #eff6ff, #f8faff);
}
.sp-avatar-big {
    width: 64px; height: 64px; border-radius: 50%; flex-shrink: 0; position: relative;
    background: linear-gradient(135deg,#2563eb,#1e40af);
    display:flex; align-items:center; justify-content:center;
    box-shadow: 0 6px 18px rgba(37,99,235,0.25);
}
.sp-avatar-ico { font-size: 32px; color: #fff; }
.sp-avatar-edit {
    position: absolute; bottom: 0; right: -2px; width: 22px; height: 22px;
    border-radius: 50%; background: #2563eb; color: #fff;
    display: flex; align-items: center; justify-content: center;
    font-size: 11px; cursor: pointer; border: 2px solid #fff;
    transition: background 0.2s;
}
.sp-avatar-edit:hover { background: #1e40af; }
.sp-user-meta { flex: 1; min-width: 0; }
.sp-user-name  { font-size: 15px; font-weight: 800; color: #1e293b; }
.sp-user-email { font-size: 12px; color: #64748b; margin-top: 2px; word-break: break-all; }
.sp-plan-pill  {
    display: inline-flex; align-items: center; gap: 4px; margin-top: 6px;
    padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 700;
    background: #eff6ff; color: #2563eb; border: 1px solid #dbeafe;
}
.sp-close-btn {
    width: 32px; height: 32px; border-radius: 8px; background: var(--bg-surface-light);
    border: 1px solid var(--border-color); cursor: pointer; font-size: 14px;
    color: #64748b; display: flex; align-items: center; justify-content: center;
    flex-shrink: 0; transition: all 0.2s;
}
.sp-close-btn:hover { background: #fee2e2; color: #ef4444; border-color: #fecaca; }

/* ── SP Tabs ──────────────────────────────────────────── */
.sp-tab-row {
    display: flex; border-bottom: 1px solid var(--border-color); padding: 0 22px;
}
.sp-tab-btn {
    flex: 1; padding: 12px 6px; border: none; background: none; cursor: pointer;
    font-size: 12.5px; font-weight: 600; color: #64748b;
    border-bottom: 2.5px solid transparent; transition: all 0.2s;
    display: flex; align-items: center; justify-content: center; gap: 5px;
}
.sp-tab-btn.active  { color: #2563eb; border-bottom-color: #2563eb; }
.sp-tab-btn:hover   { color: #2563eb; }

/* ── SP Tab Body ──────────────────────────────────────── */
.sp-tab-body { padding: 22px; flex: 1; overflow-y: auto; }
.sp-section-lbl {
    font-size: 11px; font-weight: 800; letter-spacing: 1px; text-transform: uppercase;
    color: #94a3b8; margin-bottom: 12px;
}

/* ── Mini Form ────────────────────────────────────────── */
.sp-mini-form { display: flex; flex-direction: column; gap: 10px; }
.sp-field-row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.sp-field { display: flex; flex-direction: column; gap: 5px; }
.sp-field label { font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; }
.sp-field input {
    padding: 9px 12px; border-radius: 9px; border: 1.5px solid var(--border-color);
    background: var(--bg-surface-light); font-size: 13.5px; color: var(--text-primary);
    font-family: var(--font-family); transition: border-color 0.2s;
}
.sp-field input:focus { outline: none; border-color: #2563eb; background: var(--bg-surface); }
.sp-primary-btn {
    padding: 10px 18px; background: linear-gradient(135deg,#2563eb,#1e40af); color: #fff;
    border: none; border-radius: 10px; font-weight: 700; cursor: pointer;
    font-size: 13px; display: flex; align-items: center; gap: 7px;
    transition: all 0.2s; width: 100%; justify-content: center;
}
.sp-primary-btn:hover { box-shadow: 0 6px 18px rgba(37,99,235,0.3); transform: translateY(-1px); }
.sp-sep { height: 1px; background: var(--border-color); margin: 18px 0; }
.photo-actions-row { display: flex; gap: 10px; flex-wrap: wrap; }
.sp-outline-btn {
    padding: 8px 14px; border-radius: 9px; border: 1.5px solid var(--border-color);
    background: var(--bg-surface-light); color: var(--text-primary); cursor: pointer;
    font-size: 12.5px; font-weight: 600; display: flex; align-items: center; gap: 6px;
    transition: all 0.2s;
}
.sp-outline-btn:hover       { border-color: #2563eb; color: #2563eb; }
.sp-outline-btn.danger:hover{ border-color: #ef4444; color: #ef4444; background: #fee2e2; }
.sp-signout-link {
    display: flex; align-items: center; gap: 6px; color: #ef4444;
    text-decoration: none; font-size: 13px; font-weight: 700;
    padding: 9px 12px; border-radius: 9px; transition: background 0.2s;
}
.sp-signout-link:hover { background: #fee2e2; }

/* ── Plan Cards ───────────────────────────────────────── */
.current-plan-strip {
    display: flex; align-items: center; gap: 8px; padding: 10px 14px;
    background: #eff6ff; border: 1px solid #dbeafe; border-radius: 10px;
    font-size: 13px; color: #1e293b; font-weight: 600; margin-bottom: 16px;
}
.current-plan-strip i { color: #f59e0b; }
.plan-cards-row { display: flex; flex-direction: column; gap: 12px; }
.plan-card-item {
    border: 1.5px solid var(--border-color); border-radius: 14px; padding: 16px;
    position: relative; background: var(--bg-surface-light); transition: all 0.2s;
}
.plan-card-item.featured { border-color: #2563eb; background: #f0f5ff; }
.plan-popular-tag {
    position: absolute; top: -10px; right: 14px;
    background: #2563eb; color: #fff; font-size: 10px; font-weight: 800;
    padding: 2px 10px; border-radius: 20px; letter-spacing: 0.5px;
}
.plan-item-name { font-size: 14px; font-weight: 800; color: #1e293b; margin-bottom: 2px; }
.plan-item-price { font-size: 24px; font-weight: 800; color: #2563eb; }
.plan-item-price span { font-size: 13px; font-weight: 500; color: #64748b; }
.plan-item-features { list-style: none; padding: 0; margin: 10px 0; display: flex; flex-direction: column; gap: 4px; }
.plan-item-features li { font-size: 12.5px; color: #475569; display: flex; align-items: center; gap: 6px; }
.plan-item-features li i { color: #22c55e; font-size: 13px; }
.plan-item-btn {
    width: 100%; padding: 8px; border-radius: 9px; font-size: 13px; font-weight: 700;
    cursor: pointer; transition: all 0.2s; border: 1.5px solid transparent;
}
.plan-item-btn.current { background: var(--bg-surface); border-color: var(--border-color); color: #94a3b8; cursor: default; }
.plan-item-btn.upgrade { background: #2563eb; color: #fff; }
.plan-item-btn.upgrade:hover { background: #1e40af; box-shadow: 0 4px 12px rgba(37,99,235,0.3); }

/* ── Usage ────────────────────────────────────────────── */
.usage-list { display: flex; flex-direction: column; gap: 14px; margin-top: 16px; }
.usage-row { }
.usage-row-label { font-size: 12.5px; font-weight: 700; color: #1e293b; margin-bottom: 5px; display:flex; align-items:center; gap:6px; }
.usage-row-bar { height: 6px; background: #e2e8f0; border-radius: 3px; overflow: hidden; }
.ubfill { height: 100%; background: linear-gradient(90deg,#2563eb,#3b82f6); border-radius:3px; transition: width 0.8s ease; }
.ubfill.orange { background: linear-gradient(90deg,#f59e0b,#fb923c); }
.ubfill.green  { background: linear-gradient(90deg,#22c55e,#4ade80); }
.usage-row-val { font-size: 11px; color: #64748b; margin-top: 3px; font-weight: 600; }
.usage-row-val span { font-weight: 400; }
.sp-link-btn {
    display: flex; align-items: center; gap: 8px; padding: 10px 14px; margin-top: 20px;
    background: var(--bg-surface-light); border: 1px solid var(--border-color); border-radius: 10px;
    color: #2563eb; font-size: 13px; font-weight: 700; text-decoration: none; transition: all 0.2s;
}
.sp-link-btn:hover { border-color: #2563eb; background: #eff6ff; }

/* ── Notification Panel ───────────────────────────────── */
.notif-panel {
    display: none; position: fixed; top: 68px; right: 24px; width: 320px;
    background: var(--bg-surface); border: 1px solid var(--border-color);
    border-radius: 16px; box-shadow: 0 16px 40px rgba(0,0,0,0.12); z-index: 10003;
    overflow: hidden; animation: dropIn 0.18s ease;
}
@keyframes dropIn { from { opacity:0; transform:translateY(-8px); } to { opacity:1; transform:none; } }
.notif-panel.open { display: block; }
.notif-panel-hdr {
    display: flex; justify-content: space-between; align-items: center;
    padding: 14px 16px; border-bottom: 1px solid var(--border-color);
    font-size: 13px; font-weight: 800; color: #1e293b;
}
.notif-panel-hdr button { background:none; border:none; cursor:pointer; font-size:14px; color:#64748b; }
.notif-entry {
    display: flex; gap: 12px; padding: 12px 16px; border-bottom: 1px solid var(--border-color);
    transition: background 0.15s;
}
.notif-entry.unread { background: #f8fbff; }
.notif-entry:hover  { background: #f0f4f8; }
.notif-ico {
    width: 36px; height: 36px; border-radius: 50%; flex-shrink: 0;
    display: flex; align-items:center; justify-content:center; font-size:16px;
}
.notif-ico.sync { background: #dbeafe; color: #2563eb; }
.notif-ico.warn { background: #fef3c7; color: #f59e0b; }
.notif-ico.info { background: #f0fdf4; color: #22c55e; }
.notif-msg  { font-size: 12.5px; color: #1e293b; font-weight: 600; line-height: 1.4; }
.notif-time { font-size: 11px; color: #94a3b8; margin-top: 3px; }
.notif-clear-btn {
    width: 100%; padding: 12px; border: none; background: none; cursor: pointer;
    color: #2563eb; font-size: 12.5px; font-weight: 700; transition: background 0.15s;
}
.notif-clear-btn:hover { background: #eff6ff; }

@media (max-width: 768px) {
    .search-bar { width: 180px; }
    .settings-panel { width: 100%; right: -100%; }
}
</style>

<!-- ══════════════════════ SCRIPTS ══════════════════════ -->
<script>
(function() {
    /* ── Restore saved profile photo ─────────────── */
    var saved = localStorage.getItem('digipic_profile_photo');
    if (saved) {
        showCustomPhoto(saved);
    }

    /* ── Search context flag ─────────────── */
    window._isExplorePage = (<%= isExplore %>);

    /* ── Expose gallery images for local search (set by page) ─ */
    window._localImages = window._localImages || [];
    window._localAlbums = window._localAlbums || [];
})();

/* ─────────────── PROFILE PHOTO ─────────────── */
function applyProfilePhoto(input) {
    var file = input.files[0];
    if (!file) return;
    var reader = new FileReader();
    reader.onload = function(e) {
        localStorage.setItem('digipic_profile_photo', e.target.result);
        showCustomPhoto(e.target.result);
    };
    reader.readAsDataURL(file);
}

function showCustomPhoto(src) {
    var di  = document.getElementById('profileDefaultIcon');
    var ci  = document.getElementById('profileCustomImg');
    var spi = document.getElementById('spAvatarIco');
    var spm = document.getElementById('spAvatarImg');
    if (di)  di.style.display  = 'none';
    if (ci)  { ci.src = src; ci.style.display = 'block'; }
    if (spi) spi.style.display = 'none';
    if (spm) { spm.src = src; spm.style.display = 'block'; }
}

function removeProfilePhoto() {
    localStorage.removeItem('digipic_profile_photo');
    ['profileDefaultIcon','spAvatarIco'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) el.style.display = '';
    });
    ['profileCustomImg','spAvatarImg'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) { el.style.display = 'none'; el.src = ''; }
    });
}

/* ─────────────── SETTINGS PANEL ─────────────── */
function toggleSettings(e) {
    if (e) e.stopPropagation();
    var panel  = document.getElementById('settingsPanel');
    var scrim  = document.getElementById('settingsScrim');
    var isOpen = panel.classList.contains('open');
    if (isOpen) { closeSettings(); return; }
    panel.classList.add('open');
    scrim.classList.add('open');
    document.body.classList.add('settings-open');
    closeNotifPanel();
}

function closeSettings() {
    document.getElementById('settingsPanel').classList.remove('open');
    document.getElementById('settingsScrim').classList.remove('open');
    document.body.classList.remove('settings-open');
}

/* ─────────────── TABS ─────────────── */
function switchTab(name, btn) {
    ['profile','plan','usage'].forEach(function(t) {
        var el = document.getElementById('tab-' + t);
        if (el) el.style.display = (t === name) ? 'block' : 'none';
    });
    document.querySelectorAll('.sp-tab-btn').forEach(function(b) {
        b.classList.remove('active');
    });
    if (btn) btn.classList.add('active');
}

/* ─────────────── NOTIFICATIONS ─────────────── */
function toggleNotifPanel(e) {
    if (e) e.stopPropagation();
    var np = document.getElementById('notifPanel');
    var isOpen = np.classList.contains('open');
    if (isOpen) { closeNotifPanel(); } else {
        np.classList.add('open');
        closeSettings();
    }
}
function closeNotifPanel() {
    var np = document.getElementById('notifPanel');
    if (np) np.classList.remove('open');
}
function clearNotifs() {
    document.querySelectorAll('.notif-entry.unread').forEach(function(e){ e.classList.remove('unread'); });
    var badge = document.getElementById('notifBadge');
    if (badge) badge.style.display = 'none';
    closeNotifPanel();
}

/* ─────────────── SEARCH ─────────────── */
function handleSearch(val) {
    if (window._isExplorePage) {
        // API search handled by explore.jsp
        if (window.exploreSearch) window.exploreSearch(val);
        return;
    }
    // Local search: filter gallery images
    localSearch(val);
}

function handleSearchKey(e) {
    if (e.key === 'Enter') {
        var val = e.target.value.trim();
        if (window._isExplorePage && window.exploreSearch) {
            window.exploreSearch(val, true);
        } else {
            localSearch(val);
        }
    }
    if (e.key === 'Escape') closeSearchDropdown();
}

function localSearch(val) {
    var dr = document.getElementById('searchResultsDropdown');
    val = val.trim().toLowerCase();
    if (!val) { dr.classList.remove('open'); dr.innerHTML = ''; return; }

    // Filter masonry items if on gallery page
    var items = document.querySelectorAll('.masonry-item');
    var found = [];
    items.forEach(function(item) {
        var title = (item.getAttribute('data-title') || item.querySelector('img')?.alt || '').toLowerCase();
        var match = title.includes(val);
        item.style.display = match ? '' : 'none';
        if (match) found.push({ title: item.getAttribute('data-title') || 'Photo', src: item.getAttribute('data-src') || (item.querySelector('img')?.src || ''), type: 'photo' });
    });

    // Filter album cards
    document.querySelectorAll('.album-card, .card').forEach(function(card) {
        var nm = (card.querySelector('.album-name, h3')?.textContent || '').toLowerCase();
        var match = nm.includes(val);
        card.style.display = match ? '' : 'none';
    });

    // Show dropdown suggestions
    if (found.length === 0 && items.length === 0) { dr.classList.remove('open'); return; }
    var html = found.slice(0,5).map(function(f) {
        return '<div class="srd-item" onclick="closeSearchDropdown()">' +
               (f.src ? '<img class="srd-thumb" src="'+f.src+'" onerror="this.parentNode.querySelector(\'.srd-thumb-ph\').style.display=\'flex\'; this.style.display=\'none\'">' : '') +
               '<div class="srd-thumb-ph" style="display:none"><i class="bi bi-image"></i></div>' +
               '<div class="srd-info"><div class="srd-name">'+f.title+'</div><div class="srd-meta">'+f.type+'</div></div></div>';
    }).join('');
    if (html) { dr.innerHTML = html; dr.classList.add('open'); }
    else dr.classList.remove('open');
}

function closeSearchDropdown() {
    var dr = document.getElementById('searchResultsDropdown');
    if (dr) { dr.classList.remove('open'); dr.innerHTML = ''; }
    // Reset visibility
    document.querySelectorAll('.masonry-item, .album-card, .card').forEach(function(el){ el.style.display=''; });
}

// Close panels on outside click
document.addEventListener('click', function(e) {
    var sp = document.getElementById('settingsPanel');
    var np = document.getElementById('notifPanel');
    var sb = document.getElementById('globalSearchBar');
    if (sp && !sp.contains(e.target) && !e.target.closest('.profile-trigger') && !e.target.closest('#gearIconBtn')) closeSettings();
    if (np && !np.contains(e.target) && !e.target.closest('.notif-trigger')) closeNotifPanel();
    if (sb && !sb.closest('.search-wrapper').contains(e.target)) closeSearchDropdown();
});
</script>
