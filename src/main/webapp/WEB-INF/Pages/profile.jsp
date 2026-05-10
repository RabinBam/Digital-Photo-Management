<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.DigiPic4.model.User" %>
<%@ page import="com.DigiPic4.model.AuditLog" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    User profileUser  = (User) request.getAttribute("profileUser");
    boolean isOwnProfile = (Boolean) request.getAttribute("isOwnProfile");
    int albumCount = request.getAttribute("albumCount") != null ? (int) request.getAttribute("albumCount") : 0;
    int photoCount = request.getAttribute("photoCount") != null ? (int) request.getAttribute("photoCount") : 0;
    List<AuditLog> recentLogs = (List<AuditLog>) request.getAttribute("recentLogs");

    String message = (String) request.getAttribute("message");
    String error   = (String) request.getAttribute("error");

    boolean isAdmin = "admin".equalsIgnoreCase(sessionUser.getRole());

    String initials = "";
    if (profileUser.getFirstName() != null && !profileUser.getFirstName().isEmpty())
        initials += profileUser.getFirstName().charAt(0);
    if (profileUser.getLastName() != null && !profileUser.getLastName().isEmpty())
        initials += profileUser.getLastName().charAt(0);
    if (initials.isEmpty()) initials = "U";

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isOwnProfile ? "My Profile" : profileUser.getFirstName() + "'s Profile" %> – DigiPic</title>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style-light.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;500;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">

    <style>
        :root { --font-serif: 'Cormorant Garamond', serif; --font-sans: 'Sora', sans-serif; }

        .profile-shell {
            max-width: 1100px;
            margin: 0 auto;
            padding: 0 24px 40px;
        }

        /* ── Hero ─────────────────────────────── */
        .profile-hero {
            background: linear-gradient(135deg, #eff6ff 0%, #e0e7ff 100%);
            border: 1px solid #c7d2fe;
            border-radius: 20px;
            padding: 36px 32px;
            display: flex;
            gap: 28px;
            align-items: center;
            margin-bottom: 28px;
            position: relative;
            overflow: hidden;
        }

        .profile-hero::before {
            content: '';
            position: absolute;
            top: -60px; right: -60px;
            width: 200px; height: 200px;
            border-radius: 50%;
            background: rgba(37,99,235,0.07);
        }

        .hero-avatar {
            width: 88px; height: 88px;
            border-radius: 50%;
            background: linear-gradient(135deg, #2563eb, #1e40af);
            color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-size: 32px; font-weight: 800;
            flex-shrink: 0;
            box-shadow: 0 8px 24px rgba(37,99,235,0.25);
        }

        .hero-avatar.admin-av { background: linear-gradient(135deg, #7c3aed, #4f46e5); }

        .hero-info { flex: 1; }

        .hero-info h1 {
            font-family: var(--font-serif);
            font-size: 36px; font-weight: 700;
            color: #1e293b; margin: 0 0 4px;
        }

        .hero-info .email-line { color: #64748b; font-size: 14px; }

        .role-badge {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 5px 12px; border-radius: 20px;
            font-size: 12px; font-weight: 700; letter-spacing: 0.4px;
            margin-top: 10px;
        }

        .role-badge.admin { background: #ede9fe; color: #6d28d9; border: 1px solid #c4b5fd; }
        .role-badge.user  { background: #dbeafe; color: #1e40af; border: 1px solid #bfdbfe; }

        /* ── Stats row ────────────────────────── */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin-bottom: 28px;
        }

        .stat-box {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 22px 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            transition: box-shadow 0.2s;
        }

        .stat-box:hover { box-shadow: 0 6px 18px rgba(37,99,235,0.1); }

        .stat-label { font-size: 11px; color: #94a3b8; text-transform: uppercase; letter-spacing: 1.2px; font-weight: 700; margin-bottom: 8px; }
        .stat-value { font-size: 32px; font-weight: 800; color: #1e293b; }
        .stat-sub   { font-size: 12px; color: #2563eb; font-weight: 600; margin-top: 2px; }

        /* ── Two-column layout ─────────────────── */
        .profile-grid {
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            gap: 24px;
            align-items: start;
        }

        /* ── Cards ────────────────────────────── */
        .pcard {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 18px;
            padding: 28px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }

        .pcard h2 {
            font-family: var(--font-serif);
            font-size: 24px; font-weight: 700;
            color: #1e293b; margin: 0 0 6px;
        }

        .pcard .card-sub { color: #64748b; font-size: 13px; margin-bottom: 22px; }

        /* ── Form ─────────────────────────────── */
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }

        .field { display: flex; flex-direction: column; margin-bottom: 14px; }

        .field label {
            font-size: 12px; font-weight: 700; letter-spacing: 0.5px;
            color: #1e293b; margin-bottom: 6px; text-transform: uppercase;
        }

        .field input,
        .field select {
            padding: 11px 14px;
            border-radius: 10px;
            border: 1px solid var(--border-color);
            background: var(--bg-surface-light);
            color: var(--text-primary);
            font-family: var(--font-sans);
            font-size: 14px;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .field input:focus,
        .field select:focus {
            outline: none;
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37,99,235,0.12);
            background: var(--bg-surface);
        }

        .field input[readonly] {
            background: #f0f4f8;
            color: #94a3b8;
            cursor: not-allowed;
        }

        .divider {
            height: 1px; background: var(--border-color);
            margin: 22px 0;
        }

        /* ── Buttons ──────────────────────────── */
        .btn-save {
            background: linear-gradient(135deg, #2563eb, #1e40af);
            color: #fff; border: none; padding: 11px 24px;
            border-radius: 10px; font-weight: 700; cursor: pointer;
            transition: all 0.3s; font-family: var(--font-sans);
        }

        .btn-save:hover {
            box-shadow: 0 6px 18px rgba(37,99,235,0.25);
            transform: translateY(-2px);
        }

        /* ── Flash banners ────────────────────── */
        .banner {
            padding: 13px 16px; border-radius: 10px;
            font-weight: 600; font-size: 14px;
            display: flex; align-items: center; gap: 8px;
            margin-bottom: 20px;
        }

        .banner.success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .banner.danger  { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

        /* ── Activity log ─────────────────────── */
        .log-entry {
            display: flex; gap: 12px; align-items: flex-start;
            padding: 12px 0; border-bottom: 1px solid var(--border-color);
        }

        .log-entry:last-child { border-bottom: none; padding-bottom: 0; }

        .log-dot {
            width: 8px; height: 8px; border-radius: 50%;
            background: #2563eb; flex-shrink: 0; margin-top: 6px;
        }

        .log-action { font-size: 13px; color: #1e293b; font-weight: 600; }
        .log-time   { font-size: 11px; color: #94a3b8; margin-top: 3px; }

        .empty-log  { color: #94a3b8; font-size: 13px; padding: 20px 0; text-align: center; }

        /* ── Password section ─────────────────── */
        .pw-toggle {
            color: #2563eb; font-size: 13px; font-weight: 700;
            cursor: pointer; text-decoration: underline; background: none;
            border: none; padding: 0;
        }

        .pw-section { display: none; }

        /* ── Responsive ───────────────────────── */
        @media (max-width: 900px) {
            .profile-grid { grid-template-columns: 1fr; }
            .stats-row    { grid-template-columns: 1fr 1fr; }
        }

        @media (max-width: 600px) {
            .profile-hero { flex-direction: column; text-align: center; }
            .stats-row    { grid-template-columns: 1fr; }
            .form-row     { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

    <%-- Sidebar --%>
    <% if (isAdmin) { %>
        <jsp:include page="../components/adminSidebar.jsp" />
    <% } else { %>
        <jsp:include page="../components/sidebar.jsp" />
    <% } %>

    <main class="main-content">
        <%-- Header --%>
        <% if (isAdmin) { %>
            <jsp:include page="../components/adminHeader.jsp" />
        <% } else { %>
            <jsp:include page="../components/Header.jsp" />
        <% } %>

        <div class="profile-shell">

            <%-- Flash messages --%>
            <% if (message != null) { %>
                <div class="banner success"><i class="bi bi-check-circle-fill"></i> <%= message %></div>
            <% } %>
            <% if (error != null) { %>
                <div class="banner danger"><i class="bi bi-exclamation-triangle-fill"></i> <%= error %></div>
            <% } %>

            <%-- Hero section --%>
            <div class="profile-hero">
                <div class="hero-avatar <%= "admin".equalsIgnoreCase(profileUser.getRole()) ? "admin-av" : "" %>">
                    <%= initials.toUpperCase() %>
                </div>
                <div class="hero-info">
                    <h1><%= profileUser.getFirstName() %> <%= profileUser.getLastName() %></h1>
                    <div class="email-line"><i class="bi bi-envelope" style="margin-right:5px;"></i><%= profileUser.getEmail() %></div>
                    <span class="role-badge <%= "admin".equalsIgnoreCase(profileUser.getRole()) ? "admin" : "user" %>">
                        <i class="bi bi-<%= "admin".equalsIgnoreCase(profileUser.getRole()) ? "shield-lock-fill" : "person-fill" %>"></i>
                        <%= profileUser.getRole() != null ? profileUser.getRole().substring(0,1).toUpperCase() + profileUser.getRole().substring(1) : "User" %>
                    </span>
                    <% if (!isOwnProfile) { %>
                        <span style="font-size:12px; color:#64748b; margin-left: 12px;">
                            <i class="bi bi-eye"></i> Viewing as admin — ID #<%= profileUser.getUserId() %>
                        </span>
                    <% } %>
                </div>
            </div>

            <%-- Stats --%>
            <div class="stats-row">
                <div class="stat-box">
                    <div class="stat-label">Albums</div>
                    <div class="stat-value"><%= albumCount %></div>
                    <div class="stat-sub">collections created</div>
                </div>
                <div class="stat-box">
                    <div class="stat-label">Photos</div>
                    <div class="stat-value"><%= photoCount %></div>
                    <div class="stat-sub">files archived</div>
                </div>
                <div class="stat-box">
                    <div class="stat-label">Account ID</div>
                    <div class="stat-value" style="font-size:26px;">#<%= profileUser.getUserId() %></div>
                    <div class="stat-sub"><%= "admin".equalsIgnoreCase(profileUser.getRole()) ? "administrator account" : "member account" %></div>
                </div>
            </div>

            <%-- Main grid --%>
            <div class="profile-grid">

                <%-- Left: Edit form --%>
                <div class="pcard">
                    <h2><%= isOwnProfile ? "Edit Profile" : "Edit User" %></h2>
                    <p class="card-sub">Update account details. Leave the password fields blank to keep the current password.</p>

                    <form action="<%= request.getContextPath() %>/profile" method="post">
                        <input type="hidden" name="action" value="updateProfile">
                        <% if (!isOwnProfile) { %>
                            <input type="hidden" name="targetUserId" value="<%= profileUser.getUserId() %>">
                        <% } %>

                        <div class="form-row">
                            <div class="field">
                                <label>First Name</label>
                                <input type="text" name="firstName" required
                                       value="<%= profileUser.getFirstName() != null ? profileUser.getFirstName() : "" %>">
                            </div>
                            <div class="field">
                                <label>Last Name</label>
                                <input type="text" name="lastName" required
                                       value="<%= profileUser.getLastName() != null ? profileUser.getLastName() : "" %>">
                            </div>
                        </div>

                        <div class="field">
                            <label>Email Address</label>
                            <input type="email" name="email" required
                                   value="<%= profileUser.getEmail() != null ? profileUser.getEmail() : "" %>">
                        </div>

                        <% if (isAdmin) { %>
                            <div class="field">
                                <label>Role</label>
                                <select name="role">
                                    <option value="user"  <%= "user".equalsIgnoreCase(profileUser.getRole())  ? "selected" : "" %>>User</option>
                                    <option value="admin" <%= "admin".equalsIgnoreCase(profileUser.getRole()) ? "selected" : "" %>>Administrator</option>
                                </select>
                            </div>
                        <% } %>

                        <div class="divider"></div>

                        <div style="margin-bottom: 16px;">
                            <button type="button" class="pw-toggle" onclick="togglePassword()">
                                <i class="bi bi-key"></i> Change Password
                            </button>
                        </div>

                        <div class="pw-section" id="pwSection">
                            <div class="form-row">
                                <div class="field">
                                    <label>New Password</label>
                                    <input type="password" name="newPassword" minlength="6" placeholder="Min. 6 characters">
                                </div>
                                <div class="field">
                                    <label>Confirm Password</label>
                                    <input type="password" name="confirmPassword" placeholder="Repeat password">
                                </div>
                            </div>
                        </div>

                        <button type="submit" class="btn-save">
                            <i class="bi bi-save" style="margin-right:6px;"></i>
                            Save Changes
                        </button>
                    </form>
                </div>

                <%-- Right: Activity log --%>
                <div class="pcard">
                    <h2>Recent Activity</h2>
                    <p class="card-sub">Last 10 actions on this account.</p>

                    <% if (recentLogs == null || recentLogs.isEmpty()) { %>
                        <div class="empty-log"><i class="bi bi-journal-x" style="font-size:28px; display:block; margin-bottom:8px;"></i>No activity recorded yet.</div>
                    <% } else {
                        for (AuditLog log : recentLogs) { %>
                            <div class="log-entry">
                                <div class="log-dot"></div>
                                <div>
                                    <div class="log-action"><%= log.getActionDetails() != null ? log.getActionDetails() : "–" %></div>
                                    <div class="log-time">
                                        <i class="bi bi-clock" style="margin-right:3px;"></i>
                                        <%= log.getLogTime() != null ? log.getLogTime().toString().substring(0,16) : "–" %>
                                    </div>
                                </div>
                            </div>
                    <%  }
                    } %>

                    <% if (isAdmin) { %>
                        <div style="margin-top: 20px;">
                            <a href="<%= request.getContextPath() %>/audit-log?userId=<%= profileUser.getUserId() %>"
                               style="color:#2563eb; font-size:13px; font-weight:700; text-decoration:none;">
                                <i class="bi bi-arrow-right-circle"></i> View full audit trail →
                            </a>
                        </div>
                    <% } %>
                </div>

            </div>
        </div>
    </main>

    <script>
        function togglePassword() {
            const section = document.getElementById('pwSection');
            const isHidden = section.style.display === 'none' || section.style.display === '';
            section.style.display = isHidden ? 'block' : 'none';
        }
    </script>
</body>
</html>
