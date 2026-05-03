<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">

<%
    String adminUri = request.getRequestURI();
    String adminTitle = "The Bio-Luminous Gallery";
    String adminSubtitle = "Vault: Personal Archives";

    if (adminUri != null && adminUri.endsWith("/albums")) {
        adminTitle = "Collections Overview";
        adminSubtitle = "ADMIN CURATION HUB";
    } else if (adminUri != null && adminUri.endsWith("/captain-cabin")) {
        adminTitle = "Captain's Cabin";
        adminSubtitle = "ADMIN CONTROL DECK";
    } else if (adminUri != null && (adminUri.endsWith("/uploadImport") || adminUri.endsWith("/uploadImport.jsp"))) {
        adminTitle = "Upload & Import";
        adminSubtitle = "MEDIA MANAGEMENT";
    }
%>
<div class="header">
    <div class="header-left">
        <h1 class="page-title"><%= adminTitle %></h1>
        <p class="page-subtitle"><%= adminSubtitle %></p>
    </div>

    <div class="header-right">
        <div class="search-container">
            <input type="text" class="search-bar" placeholder="Search crew or records...">
        </div>

        <div class="header-icons">
            <div class="icon" title="Notifications">
                <i class="bi bi-bell"></i>
            </div>
            <div class="icon" title="Settings">
                <i class="bi bi-gear"></i>
            </div>
        </div>

        <div class="profile">
            <img src="${pageContext.request.contextPath}/images/user.jpg" alt="profile">
        </div>
    </div>
</div>

<style>
    .icon i {
        font-size: 18px;
    }
</style>