<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.DigiPic4.model.User" %>
<%
    User cabinSessionUser = (User) session.getAttribute("user");
    if (cabinSessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String cabinRole = cabinSessionUser.getRole() == null ? "" : cabinSessionUser.getRole().trim();
    if (!"admin".equalsIgnoreCase(cabinRole)) {
        response.sendRedirect(request.getContextPath() + "/gallery");
        return;
    }
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<%
    List<User> users = (List<User>) request.getAttribute("users");
    User editingUser = (User) request.getAttribute("editingUser");
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Captain's Cabin - Admin Panel</title>

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style-light.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@400;700&family=Cormorant+Garamond:wght@400;500;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">

    <style>
        :root {
            --font-serif: 'Cormorant Garamond', serif;
            --font-sans: 'Sora', sans-serif;
        }

        .cabin-content {
            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            margin-top: 20px;
        }

        .section-header {
            margin-bottom: 30px;
        }

        .section-header h5 {
            color: #2563eb;
            font-size: 12px;
            letter-spacing: 1.5px;
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

        .section-header p {
            color: #64748b;
            margin-top: 8px;
            font-size: 15px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 24px;
            align-items: start;
            margin-top: 20px;
        }

        .card {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }

        .card h3 {
            font-size: 18px;
            font-family: var(--font-serif);
            font-weight: 700;
            margin: 0 0 16px;
            color: #1e293b;
        }

        .card p {
            color: #64748b;
            line-height: 1.6;
            margin: 8px 0;
            font-size: 14px;
        }

        .card code {
            background: #f0f4f8;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            color: #2563eb;
            font-weight: 600;
        }

        .crud-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 12px;
        }

        .crud-table th,
        .crud-table td {
            border-bottom: 1px solid var(--border-color);
            padding: 12px;
            text-align: left;
        }

        .crud-table th {
            color: #2563eb;
            font-size: 12px;
            letter-spacing: 0.5px;
            font-weight: 700;
            text-transform: uppercase;
            background: #f0f4f8;
        }

        .crud-table td {
            color: #1e293b;
            font-size: 14px;
        }

        .form-row {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
        }

        .field {
            display: flex;
            flex-direction: column;
            margin-bottom: 10px;
        }

        .field label {
            font-size: 13px;
            color: #1e293b;
            margin-bottom: 6px;
            font-weight: 600;
        }

        .field input,
        .field select {
            padding: 10px;
            border-radius: 10px;
            border: 1px solid var(--border-color);
            background: var(--bg-surface-light);
            color: var(--text-primary);
            font-family: var(--font-sans);
            font-size: 14px;
        }

        .field input:focus,
        .field select:focus {
            outline: none;
            border-color: #2563eb;
            box-shadow: 0 0 8px rgba(37, 99, 235, 0.15);
            background: var(--bg-surface);
        }

        .inline-form {
            display: inline;
        }

        .notice {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 16px;
            font-weight: 600;
            font-size: 14px;
        }

        .error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
            padding: 12px 16px;
            border-radius: 10px;
            margin-bottom: 16px;
            font-weight: 600;
            font-size: 14px;
        }

        .btn {
            background: linear-gradient(135deg, #2563eb, #1e40af);
            color: #ffffff;
            border: none;
            padding: 10px 18px;
            border-radius: 10px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            font-family: var(--font-sans);
            margin-right: 8px;
            margin-top: 8px;
        }

        .btn:hover {
            box-shadow: 0 6px 16px rgba(37, 99, 235, 0.25);
            transform: translateY(-2px);
        }

        .secondary-btn {
            display: inline-block;
            background: var(--bg-surface-light);
            color: var(--text-primary);
            border: 1px solid var(--border-color);
            padding: 8px 12px;
            border-radius: 10px;
            cursor: pointer;
            text-decoration: none;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.3s ease;
            margin-right: 6px;
        }

        .secondary-btn:hover {
            border-color: #2563eb;
            color: #2563eb;
            background: #eff6ff;
        }

        .danger-btn {
            border: 1px solid #ef4444;
            background: transparent;
            color: #ef4444;
            padding: 8px 12px;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.3s ease;
        }

        .danger-btn:hover {
            background: #fee2e2;
            border-color: #dc2626;
        }

        @media (max-width: 1080px) {
            .grid {
                grid-template-columns: 1fr;
            }

            .section-header h1 {
                font-size: 32px;
            }

            .form-row {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .cabin-content {
                padding: 0 12px;
            }

            .card {
                padding: 16px;
            }

            .section-header h1 {
                font-size: 28px;
            }
        }
    </style>
</head>

<body>

    <jsp:include page="../components/adminSidebar.jsp" />

    <main class="main-content">
        <jsp:include page="../components/adminHeader.jsp" />

        <section class="cabin-content">
            <div class="section-header">
                <h5>ADMIN OPERATIONS</h5>
                <h1>Captain's Cabin</h1>
                <p>Curation protocol, security controls, and user management in one place.</p>
            </div>

            <% if (message != null) { %>
                <div class="notice"><i class="bi bi-check-circle"></i> <%= message %></div>
            <% } %>
            <% if (error != null) { %>
                <div class="error"><i class="bi bi-exclamation-triangle"></i> <%= error %></div>
            <% } %>

            <div class="grid">

                <!-- USER CREATION/UPDATION FORM -->
                <div class="card">
                    <h3><%= editingUser == null ? "Create Crew Member" : "Update Crew Member" %></h3>
                    <form action="<%= request.getContextPath() %>/captain-cabin" method="post">
                        <input type="hidden" name="action" value="<%= editingUser == null ? "create" : "update" %>">
                        <% if (editingUser != null) { %>
                            <input type="hidden" name="userId" value="<%= editingUser.getUserId() %>">
                        <% } %>

                        <div class="form-row">
                            <div class="field">
                                <label>First Name</label>
                                <input type="text" name="firstName" required value="<%= editingUser == null ? "" : editingUser.getFirstName() %>">
                            </div>
                            <div class="field">
                                <label>Last Name</label>
                                <input type="text" name="lastName" required value="<%= editingUser == null ? "" : editingUser.getLastName() %>">
                            </div>
                        </div>

                        <div class="field">
                            <label>Email Address</label>
                            <input type="email" name="email" required value="<%= editingUser == null ? "" : editingUser.getEmail() %>">
                        </div>

                        <div class="field">
                            <label>Password <%= editingUser == null ? "" : "(leave blank to keep current)" %></label>
                            <input type="password" name="password" <%= editingUser == null ? "required" : "" %>>
                        </div>

                        <div class="field">
                            <label>Role Assignment</label>
                            <select name="role">
                                <option value="user" <%= editingUser != null && "user".equalsIgnoreCase(editingUser.getRole()) ? "selected" : "" %>>User</option>
                                <option value="admin" <%= editingUser != null && "admin".equalsIgnoreCase(editingUser.getRole()) ? "selected" : "" %>>Administrator</option>
                            </select>
                        </div>

                        <button class="btn" type="submit"><i class="bi bi-save"></i> <%= editingUser == null ? "Create User" : "Update User" %></button>
                        <% if (editingUser != null) { %>
                            <a class="secondary-btn" href="<%= request.getContextPath() %>/captain-cabin"><i class="bi bi-x"></i> Cancel</a>
                        <% } %>
                    </form>
                </div>

                <!-- REGISTERED CREW TABLE -->
                <div class="card">
                    <h3>Registered Crew Members</h3>
                    <table class="crud-table">
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% if (users == null || users.isEmpty()) { %>
                            <tr>
                                <td colspan="5" style="text-align: center; color: #94a3b8;">No users available</td>
                            </tr>
                        <% } else {
                            for (User u : users) { %>
                            <tr>
                                <td><strong><%= u.getUserId() %></strong></td>
                                <td><%= u.getFirstName() %> <%= u.getLastName() %></td>
                                <td><%= u.getEmail() %></td>
                                <td><span style="background: #eff6ff; color: #2563eb; padding: 4px 8px; border-radius: 6px; font-weight: 600; font-size: 12px;"><%= u.getRole() %></span></td>
                                <td>
                                    <a class="secondary-btn" href="<%= request.getContextPath() %>/captain-cabin?editId=<%= u.getUserId() %>"><i class="bi bi-pencil"></i> Edit</a>
                                    <form class="inline-form" action="<%= request.getContextPath() %>/captain-cabin" method="post">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                        <button class="danger-btn" type="submit" onclick="return confirm('Are you sure you want to delete this user?');"><i class="bi bi-trash"></i> Delete</button>
                                    </form>
                                </td>
                            </tr>
                        <%  }
                        } %>
                        </tbody>
                    </table>
                </div>

                <!-- SESSION AND CACHE GUARD INFO -->
                <div class="card">
                    <h3><i class="bi bi-shield-check"></i> Security & Sessions</h3>
                    <p>Session management with encrypted credentials and per-user authentication tokens.</p>
                    <p>No-cache headers prevent sensitive pages from browser cache replay and unauthorized access.</p>
                    <p>Session timeout enforced after login to reduce risk of stale access and unauthorized operations.</p>
                </div>

                <!-- SYSTEM STATUS INFO -->
                <div class="card">
                    <h3><i class="bi bi-info-circle"></i> System Status</h3>
                    <p><strong>Authentication:</strong> Encrypted password storage with salt-based hashing.</p>
                    <p><strong>Audit Logs:</strong> All user actions recorded in the audit_logs database table.</p>
                    <p><strong>Routing:</strong> Servlet-based routing via <code>@WebServlet</code> annotations and configurations.</p>
                </div>

            </div>
        </section>
    </main>

</body>
</html>
