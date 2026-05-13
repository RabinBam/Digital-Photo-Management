<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.DigiPic4.model.AuditLog" %>
<%@ page import="com.DigiPic4.model.User" %>
<%
    User auditSessionUser = (User) session.getAttribute("user");
    if (auditSessionUser == null || !"admin".equalsIgnoreCase(auditSessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/gallery");
        return;
    }

    List<AuditLog> logs       = (List<AuditLog>) request.getAttribute("logs");
    User filterUser           = (User) request.getAttribute("filterUser");
    List<User> allUsers       = (List<User>) request.getAttribute("allUsers");

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Log – DigiPic</title>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style-light.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">

    <style>
        :root { --font-serif: 'Cormorant Garamond', serif; --font-sans: 'Sora', sans-serif; }

        .log-shell {
            max-width: 1100px;
            margin: 0 auto;
            padding: 0 24px 40px;
        }

        .section-header { margin-bottom: 24px; }
        .section-header h5 {
            color: #2563eb; font-size: 12px; letter-spacing: 1.5px; font-weight: 700;
            text-transform: uppercase; margin-bottom: 6px;
        }
        .section-header h1 {
            font-family: var(--font-serif); font-size: 40px; font-weight: 700; color: #1e293b; margin: 0;
        }
        .section-header p { color: #64748b; margin-top: 6px; }

        /* ── Filter bar ───────────────────────── */
        .filter-bar {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            padding: 18px 22px;
            display: flex; gap: 14px; align-items: center; flex-wrap: wrap;
            margin-bottom: 24px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }

        .filter-bar label { font-size: 13px; font-weight: 700; color: #1e293b; white-space: nowrap; }

        .filter-bar select {
            padding: 9px 14px; border-radius: 10px;
            border: 1px solid var(--border-color);
            background: var(--bg-surface-light);
            color: var(--text-primary);
            font-family: var(--font-sans); font-size: 14px;
            min-width: 220px;
        }

        .filter-bar select:focus { outline: none; border-color: #2563eb; }

        .filter-btn {
            background: linear-gradient(135deg, #2563eb, #1e40af);
            color: #fff; border: none; padding: 9px 18px; border-radius: 10px;
            font-weight: 700; cursor: pointer; font-family: var(--font-sans);
            transition: all 0.2s;
        }

        .filter-btn:hover { box-shadow: 0 4px 14px rgba(37,99,235,0.25); transform: translateY(-1px); }

        .clear-btn {
            background: var(--bg-surface-light); color: var(--text-primary);
            border: 1px solid var(--border-color); padding: 9px 14px; border-radius: 10px;
            font-weight: 600; cursor: pointer; text-decoration: none; font-size: 13px;
            transition: all 0.2s;
        }

        .clear-btn:hover { border-color: #2563eb; color: #2563eb; }

        /* ── Stats strip ──────────────────────── */
        .log-stats {
            display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 20px;
        }

        .log-stat {
            background: var(--bg-surface); border: 1px solid var(--border-color);
            border-radius: 12px; padding: 14px 20px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.04);
        }

        .log-stat .ls-label { font-size: 11px; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; font-weight: 700; }
        .log-stat .ls-value { font-size: 24px; font-weight: 800; color: #1e293b; }

        /* ── Table ────────────────────────────── */
        .log-table-wrap {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }

        .log-table {
            width: 100%;
            border-collapse: collapse;
        }

        .log-table thead th {
            background: #f0f4f8;
            padding: 13px 16px;
            text-align: left;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            font-weight: 800;
            color: #2563eb;
            border-bottom: 1px solid var(--border-color);
        }

        .log-table tbody tr {
            border-bottom: 1px solid var(--border-color);
            transition: background 0.15s;
        }

        .log-table tbody tr:last-child { border-bottom: none; }
        .log-table tbody tr:hover { background: #f8fafc; }

        .log-table td {
            padding: 13px 16px;
            font-size: 13px;
            color: #1e293b;
            vertical-align: middle;
        }

        .log-table td.email-cell { color: #2563eb; font-weight: 600; }
        .log-table td.time-cell  { color: #94a3b8; font-size: 12px; white-space: nowrap; }
        .log-table td.action-cell{ max-width: 360px; }

        .empty-state {
            text-align: center; padding: 60px 20px; color: #94a3b8;
        }

        .empty-state i { font-size: 40px; display: block; margin-bottom: 10px; }

        /* ── Search ───────────────────────────── */
        .search-input {
            flex: 1; min-width: 180px;
            padding: 9px 14px; border-radius: 10px;
            border: 1px solid var(--border-color);
            background: var(--bg-surface-light);
            font-family: var(--font-sans); font-size: 13px;
            color: var(--text-primary);
        }

        .search-input:focus { outline: none; border-color: #2563eb; }

        @media (max-width: 768px) {
            .filter-bar { flex-direction: column; align-items: stretch; }
            .filter-bar select,
            .search-input { width: 100%; }
            .log-stats { flex-direction: column; }
            .log-table { font-size: 12px; }
            .log-table td.email-cell { display: none; }
        }
    </style>
</head>
<body>

    <jsp:include page="../components/adminSidebar.jsp" />

    <main class="main-content">
        <jsp:include page="../components/adminHeader.jsp" />

        <div class="log-shell">
            <div class="section-header">
                <h5>ADMIN</h5>
                <h1>Audit Log</h1>
                <p>
                    <% if (filterUser != null) { %>
                        Showing activity for <strong><%= filterUser.getFirstName() %> <%= filterUser.getLastName() %></strong>
                        (<%= filterUser.getEmail() %>)
                    <% } else { %>
                        Full system activity trail — newest first, capped at 100 entries.
                    <% } %>
                </p>
            </div>

            <%-- Filter bar --%>
            <form class="filter-bar" action="<%= request.getContextPath() %>/audit-log" method="get">
                <label for="filterSelect"><i class="bi bi-funnel"></i> Filter by user</label>
                <select id="filterSelect" name="userId">
                    <option value="">— All users —</option>
                    <% if (allUsers != null) {
                        for (User u : allUsers) { %>
                            <option value="<%= u.getUserId() %>"
                                <%= filterUser != null && filterUser.getUserId() == u.getUserId() ? "selected" : "" %>>
                                <%= u.getFirstName() %> <%= u.getLastName() %> (ID #<%= u.getUserId() %>)
                            </option>
                    <%  } } %>
                </select>
                <input type="text" class="search-input" id="logSearch" placeholder="Search actions…" oninput="filterTable(this.value)">
                <button type="submit" class="filter-btn"><i class="bi bi-funnel-fill"></i> Apply</button>
                <% if (filterUser != null) { %>
                    <a class="clear-btn" href="<%= request.getContextPath() %>/audit-log"><i class="bi bi-x"></i> Clear</a>
                <% } %>
            </form>

            <%-- Stats strip --%>
            <div class="log-stats">
                <div class="log-stat">
                    <div class="ls-label">Entries shown</div>
                    <div class="ls-value"><%= logs != null ? logs.size() : 0 %></div>
                </div>
                <% if (filterUser != null) { %>
                    <div class="log-stat">
                        <div class="ls-label">Filtered user</div>
                        <div class="ls-value" style="font-size:16px;"><%= filterUser.getEmail() %></div>
                    </div>
                <% } %>
            </div>

            <%-- Log table --%>
            <div class="log-table-wrap">
                <table class="log-table" id="logTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>User</th>
                            <th>Action</th>
                            <th>Timestamp</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (logs == null || logs.isEmpty()) { %>
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state">
                                        <i class="bi bi-journal-x"></i>
                                        No audit entries found.
                                    </div>
                                </td>
                            </tr>
                        <% } else {
                            for (AuditLog log : logs) { %>
                                <tr>
                                    <td><strong><%= log.getLogId() %></strong></td>
                                    <td class="email-cell">
                                        <a href="<%= request.getContextPath() %>/profile?userId=<%= log.getUserId() %>"
                                           style="color:#2563eb; text-decoration:none; font-weight:600;">
                                            <%= log.getUserEmail() != null ? log.getUserEmail() : "Deleted user" %>
                                        </a>
                                    </td>
                                    <td class="action-cell"><%= log.getActionDetails() != null ? log.getActionDetails() : "–" %></td>
                                    <td class="time-cell">
                                        <%= log.getLogTime() != null ? log.getLogTime().toString().substring(0,16) : "–" %>
                                    </td>
                                    <td>
                                        <a href="<%= request.getContextPath() %>/audit-log?userId=<%= log.getUserId() %>"
                                           style="color:#2563eb; font-size:12px; font-weight:700; text-decoration:none;">
                                            Filter
                                        </a>
                                    </td>
                                </tr>
                        <%  }
                        } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <script>
        function filterTable(query) {
            const rows = document.querySelectorAll('#logTable tbody tr');
            const q = query.toLowerCase();
            rows.forEach(row => {
                row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
            });
        }
    </script>
</body>
</html>
