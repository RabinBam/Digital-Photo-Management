<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.DigiPic4.model.User" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">

<%
    User sidebarUser = (User) session.getAttribute("user");
    String currentPage = (String) request.getAttribute("page");
    if (currentPage == null) {
        String uri = request.getRequestURI();
        if (uri != null) {
            if (uri.endsWith("/gallery"))           currentPage = "gallery";
            else if (uri.endsWith("/albums"))        currentPage = "albums";
            else if (uri.endsWith("/uploadImport"))  currentPage = "uploadImport";
            else if (uri.endsWith("/profile"))       currentPage = "profile";
            else if (uri.endsWith("/about"))         currentPage = "about";
            else if (uri.endsWith("/contact"))       currentPage = "contact";
            else if (uri.endsWith("/explore"))       currentPage = "explore";
            else if (uri.endsWith("/usage"))         currentPage = "usage";
            else                                     currentPage = "";
        } else { currentPage = ""; }
    }

    String displayName = sidebarUser != null
        ? (sidebarUser.getFirstName() + " " + sidebarUser.getLastName()).trim()
        : "User";
    String initials = "";
    if (sidebarUser != null) {
        if (sidebarUser.getFirstName() != null && !sidebarUser.getFirstName().isEmpty())
            initials += sidebarUser.getFirstName().charAt(0);
        if (sidebarUser.getLastName() != null && !sidebarUser.getLastName().isEmpty())
            initials += sidebarUser.getLastName().charAt(0);
    }
    if (initials.isEmpty()) initials = "U";
%>

<div class="sidebar">
    <div class="logo">MyVault<span>Personal Archive</span></div>

    <ul class="nav-links">
        <li>
            <a href="${pageContext.request.contextPath}/gallery"
               class="<%= "gallery".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-collection"></i> Recent Floats
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/albums"
               class="<%= "albums".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-folder2"></i> Deep Storage
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/uploadImport"
               class="<%= "uploadImport".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-cloud-upload"></i> Upload &amp; Import
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/explore"
               class="<%= "explore".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-compass"></i> Explore the Ocean
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/usage"
               class="<%= "usage".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-graph-up"></i> Usage Analytics
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/profile"
               class="<%= "profile".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-person-circle"></i> My Profile
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/about"
               class="<%= "about".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-info-circle"></i> About Us
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/contact"
               class="<%= "contact".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-envelope"></i> Contact Us
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/logout">
                <i class="bi bi-box-arrow-left"></i> Logout
            </a>
        </li>
    </ul>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/profile" class="sidebar-user-card">
            <div class="user-avatar"><%= initials.toUpperCase() %></div>
            <div class="user-info">
                <div class="user-name"><%= displayName %></div>
                <div class="user-role"><%= sidebarUser != null ? sidebarUser.getRole() : "user" %></div>
            </div>
        </a>
    </div>
</div>

<style>
    /* Critical Sidebar Layout */
    .sidebar {
        width: 250px;
        background-color: var(--bg-surface, #ffffff);
        display: flex;
        flex-direction: column;
        padding: 20px;
        border-right: 1px solid var(--border-color, #e2e8f0);
        height: 100vh;
        position: sticky;
        top: 0;
    }

    .logo {
        background: linear-gradient(135deg, #2563eb, #1e40af);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        font-size: 24px;
        font-weight: 800;
        font-family: 'Playfair Display', serif;
        margin-bottom: 40px;
    }

    .logo span {
        font-size: 12px;
        color: #94a3b8;
        display: block;
        font-weight: 500;
        letter-spacing: 0.8px;
        text-transform: uppercase;
        margin-top: 4px;
    }

    .nav-links {
        list-style: none;
        flex-grow: 1;
        padding: 0;
        margin: 0;
    }

    .nav-links li { margin-bottom: 12px; }

    .nav-links a {
        color: #64748b;
        text-decoration: none;
        font-size: 14px;
        display: flex;
        align-items: center;
        padding: 12px;
        border-radius: 12px;
        transition: all 0.3s ease;
        font-weight: 500;
        gap: 12px;
    }

    .nav-links a i { font-size: 18px; }

    .nav-links a:hover,
    .nav-links a.active {
        background: #f0f4f8;
        color: #2563eb;
    }

    .sidebar-footer {
        margin-top: auto;
        padding-top: 16px;
        border-top: 1px solid var(--border-color, #e2e8f0);
    }

    .sidebar-user-card {
        display: flex; align-items: center; gap: 10px; padding: 10px 12px;
        border-radius: 12px; text-decoration: none; transition: background 0.2s; cursor: pointer;
    }

    .sidebar-user-card:hover { background: var(--bg-surface-light, #f0f4f8); }

    .user-avatar {
        width: 36px; height: 36px; border-radius: 50%;
        background: linear-gradient(135deg, #2563eb, #1e40af); color: #fff;
        display: flex; align-items: center; justify-content: center;
        font-size: 13px; font-weight: 700; flex-shrink: 0;
    }

    .user-name { font-size: 13px; font-weight: 700; color: var(--text-primary, #1e293b); }
    .user-role { font-size: 11px; color: var(--text-muted, #94a3b8); text-transform: capitalize; }
</style>
