<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.DigiPic4.model.User" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">

<%
    User adminSidebarUser = (User) session.getAttribute("user");
    String currentPage = (String) request.getAttribute("page");
    if (currentPage == null) {
        String uri = request.getRequestURI();
        if (uri != null) {
            if (uri.endsWith("/gallery"))           currentPage = "gallery";
            else if (uri.endsWith("/albums"))       currentPage = "albums";
            else if (uri.endsWith("/captain-cabin"))currentPage = "captain-cabin";
            else if (uri.endsWith("/uploadImport")) currentPage = "uploadImport";
            else if (uri.endsWith("/audit-log"))    currentPage = "audit-log";
            else if (uri.endsWith("/profile"))      currentPage = "profile";
            else                                    currentPage = "";
        } else { currentPage = ""; }
    }

    String adDisplayName = adminSidebarUser != null
        ? (adminSidebarUser.getFirstName() + " " + adminSidebarUser.getLastName()).trim()
        : "Admin";
    String adInitials = "";
    if (adminSidebarUser != null) {
        if (adminSidebarUser.getFirstName() != null && !adminSidebarUser.getFirstName().isEmpty())
            adInitials += adminSidebarUser.getFirstName().charAt(0);
        if (adminSidebarUser.getLastName() != null && !adminSidebarUser.getLastName().isEmpty())
            adInitials += adminSidebarUser.getLastName().charAt(0);
    }
    if (adInitials.isEmpty()) adInitials = "A";
%>

<div class="sidebar">
    <div class="logo">MyVault<span>Admin Archive</span></div>

    <ul class="nav-links menu">
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

        <li class="nav-section-label">Administration</li>

        <li>
            <a href="${pageContext.request.contextPath}/captain-cabin"
               class="<%= "captain-cabin".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-shield-lock"></i> Captain's Cabin
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/audit-log"
               class="<%= "audit-log".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-journal-text"></i> Audit Logs
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/profile"
               class="<%= "profile".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-person-circle"></i> My Profile
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
            <div class="user-avatar admin-avatar"><%= adInitials.toUpperCase() %></div>
            <div class="user-info">
                <div class="user-name"><%= adDisplayName %></div>
                <div class="user-role" style="color: #2563eb;">Administrator</div>
            </div>
        </a>
    </div>
</div>

<style>
    .nav-links a i { margin-right: 8px; }

    .nav-section-label {
        font-size: 10px;
        text-transform: uppercase;
        letter-spacing: 1.2px;
        color: var(--text-muted, #94a3b8);
        padding: 14px 12px 6px;
        font-weight: 700;
    }

    .sidebar-footer {
        margin-top: auto;
        padding-top: 16px;
        border-top: 1px solid var(--border-color);
    }

    .sidebar-user-card {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        border-radius: 12px;
        text-decoration: none;
        transition: background 0.2s;
    }

    .sidebar-user-card:hover { background: var(--bg-surface-light); }

    .user-avatar {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: linear-gradient(135deg, #2563eb, #1e40af);
        color: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 13px;
        font-weight: 700;
        flex-shrink: 0;
    }

    .admin-avatar { background: linear-gradient(135deg, #7c3aed, #4f46e5); }

    .user-name { font-size: 13px; font-weight: 700; color: var(--text-primary); }
    .user-role { font-size: 11px; color: var(--text-muted); text-transform: capitalize; }
</style>
