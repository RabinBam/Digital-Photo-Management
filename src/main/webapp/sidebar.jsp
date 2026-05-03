<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">

<%-- Sidebar Component (Member) --%>

<%
    String currentPage = (String) request.getAttribute("page");
    if (currentPage == null) {
        String uri = request.getRequestURI();
        if (uri != null) {
            if (uri.endsWith("/gallery")) {
                currentPage = "gallery";
            } else if (uri.endsWith("/albums")) {
                currentPage = "albums";
            } else if (uri.endsWith("/uploadImport") || uri.endsWith("/uploadImport.jsp")) {
                currentPage = "uploadImport";
            } else {
                currentPage = "";
            }
        } else {
            currentPage = "";
        }
    }
%>

<div class="sidebar">

    <div class="logo">
        MyVault
        <span>Personal Archive</span>
    </div>

    <ul class="nav-links">
        <li>
            <a href="${pageContext.request.contextPath}/gallery" class="<%= currentPage.equals("gallery") ? "active" : "" %>">
                <i class="bi bi-collection"></i> Recent Floats
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/albums" class="<%= currentPage.equals("albums") ? "active" : "" %>">
                <i class="bi bi-folder2"></i> Deep Storage
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/uploadImport" class="<%= currentPage.equals("uploadImport") ? "active" : "" %>">
                <i class="bi bi-cloud-upload"></i> Upload & Import
            </a>
        </li>

        <li>
            <a href="${pageContext.request.contextPath}/logout">
                <i class="bi bi-box-arrow-left"></i> Logout
            </a>
        </li>
    </ul>

    <div style="margin-top:auto;">
        <button class="btn-primary" style="width:100%; margin-bottom:20px;">
            <i class="bi bi-plus-circle"></i> New Collection
        </button>

        <div style="font-size:12px; color: var(--text-secondary);">
            <p>Sync Status <span style="float:right;">98%</span></p>
            <p>Cloud Usage <span style="float:right;">1.2 TB</span></p>
        </div>
    </div>

</div>

<style>
    .nav-links a i {
        margin-right: 8px;
    }
    
    .btn-primary i {
        margin-right: 6px;
    }
</style>
