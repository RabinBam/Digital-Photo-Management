<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">

<%
    String currentPage = (String) request.getAttribute("page");
    if (currentPage == null || currentPage.trim().isEmpty()) {
        String uri = request.getRequestURI();
        if (uri != null) {
            if (uri.endsWith("/gallery")) {
                currentPage = "gallery";
            } else if (uri.endsWith("/albums")) {
                currentPage = "albums";
            } else if (uri.endsWith("/captain-cabin")) {
                currentPage = "captain-cabin";
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

    <ul class="nav-links menu">
        <li>
            <a href="${pageContext.request.contextPath}/gallery" class="<%= "gallery".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-collection"></i> Recent Floats
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/albums" class="<%= "albums".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-folder2"></i> Deep Storage
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/uploadImport" class="<%= "uploadImport".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-cloud-upload"></i> Upload & Import
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/captain-cabin" class="<%= "captain-cabin".equals(currentPage) ? "active" : "" %>">
                <i class="bi bi-shield-lock"></i> Captain Cabin
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/logout">
                <i class="bi bi-box-arrow-left"></i> Logout
            </a>
        </li>
    </ul>
</div>

<style>
    .nav-links a i {
        margin-right: 8px;
    }
</style>