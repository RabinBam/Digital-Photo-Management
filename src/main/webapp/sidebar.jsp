<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.DigiPic4.model.User" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">

<%
    User sidebarUser = (User) session.getAttribute("user");
    String currentPage = (String) request.getAttribute("page");
    if (currentPage == null) {
        String uri = request.getRequestURI();
        if (uri != null) {
            if (uri.endsWith("/gallery"))                                currentPage = "gallery";
            else if (uri.endsWith("/albums"))                            currentPage = "albums";
            else if (uri.endsWith("/uploadImport"))                      currentPage = "uploadImport";
            else if (uri.endsWith("/profile"))                           currentPage = "profile";
            else                                                         currentPage = "";
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
            <div class="user-avatar"><%= initials.toUpperCase() %></div>
            <div class="user-info">
                <div class="user-name"><%= displayName %></div>
                <div class="user-role"><%= sidebarUser != null ? sidebarUser.getRole() : "user" %></div>
            </div>
        </a>
    </div>
</div>

<style>
    .nav-links a i { margin-right: 8px; }

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
        cursor: pointer;
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

    .user-name  { font-size: 13px; font-weight: 700; color: var(--text-primary); }
    .user-role  { font-size: 11px; color: var(--text-muted); text-transform: capitalize; }
</style>
