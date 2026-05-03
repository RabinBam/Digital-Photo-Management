<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%-- Header Component --%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">

<%
    String headerUri = request.getRequestURI();
    String headerTitle = "The Bio-Luminous Gallery";
    String headerSubtitle = "Vault: Personal Archives";

    if (headerUri != null && headerUri.endsWith("/albums")) {
        headerTitle = "Collections Overview";
        headerSubtitle = "CURATION HUB";
    } else if (headerUri != null && (headerUri.endsWith("/uploadImport") || headerUri.endsWith("/uploadImport.jsp"))) {
        headerTitle = "Upload & Import";
        headerSubtitle = "MEDIA MANAGEMENT";
    }
%>

<div class="header">

    <!-- LEFT: TITLE -->
    <div class="header-left">
        <h1 class="page-title"><%= headerTitle %></h1>
        <p class="page-subtitle"><%= headerSubtitle %></p>
    </div>

    <!-- RIGHT: CONTROLS -->
    <div class="header-right">

        <!-- SEARCH -->
        <div class="search-container">
            <input type="text" class="search-bar" placeholder="Explore archive...">
        </div>

        <!-- ICONS -->
        <div class="header-icons">
            <div class="icon" title="Notifications">
                <i class="bi bi-bell"></i>
            </div>
            <div class="icon" title="Settings">
                <i class="bi bi-gear"></i>
            </div>
        </div>

        <!-- PROFILE -->
        <div class="profile">
            <img src="${pageContext.request.contextPath}/images/user.jpg" alt="profile">
        </div>

    </div>

</div>

<style>
    .header {
        position: sticky;
        top: 0;
        z-index: 100;
        width: 100%;
        margin: 0;
        padding: 16px 24px !important;
        background: var(--bg-surface);
        border-bottom: 1px solid var(--border-color);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 20px;
        left: 0;
        right: 0;
    }

    .icon i {
        font-size: 18px;
    }

    @media (max-width: 768px) {
        .header {
            padding: 12px 16px !important;
            flex-wrap: wrap;
        }

        .search-container {
            order: 3;
            width: 100%;
            margin-top: 8px;
        }
    }
</style>