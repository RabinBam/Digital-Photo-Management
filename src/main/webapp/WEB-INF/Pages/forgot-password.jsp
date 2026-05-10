<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.lang.String" %>
<%
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
    String generatedCode = (String) request.getAttribute("generatedCode");
    String email = (String) request.getAttribute("email");
    Object sessionCode = session.getAttribute("resetCode");
    boolean hasResetSession = sessionCode != null;
%>
<!DOCTYPE html>
<html>
<head>
    <title>DigiPic - Forgot Password</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { position: relative; overflow: hidden; }
        .auth-wrapper {
            position: relative;
            z-index: 2;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            width: 100%;
            padding: 20px;
        }
        .auth-card {
            background: var(--bg-surface);
            padding: 40px;
            border-radius: 16px;
            width: 470px;
            border: 1px solid rgba(103,232,249,0.08);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.55);
            backdrop-filter: blur(10px);
        }
        .auth-card h2 { margin-bottom: 5px; font-size: 28px; }
        .auth-card p { color: var(--text-secondary); margin-bottom: 24px; font-size: 14px; }
        .form-group { margin-bottom: 18px; }
        .form-group label { display: block; color: var(--text-secondary); font-size: 12px; margin-bottom: 8px; letter-spacing: 1px; }
        .form-control {
            width: 100%;
            padding: 12px 15px;
            background: var(--bg-surface-light);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 8px;
            color: white;
            outline: none;
        }
        .form-control:focus { border-color: var(--accent-teal); }
        .btn-full { width: 100%; padding: 15px; font-size: 16px; margin-top: 10px; }
        .auth-message { margin: 12px 0; font-size: 13px; color: #7dd3fc; }
        .auth-error { margin: 12px 0; font-size: 13px; color: #fca5a5; }
        .auth-links { margin-top: 20px; text-align: center; font-size: 14px; color: var(--text-secondary); }
        .auth-links a { color: var(--accent-teal); text-decoration: none; }
        .reset-code-box {
            margin: 16px 0 20px;
            padding: 14px;
            border-radius: 10px;
            border: 1px dashed rgba(103,232,249,0.25);
            color: #7dd3fc;
            background: rgba(6, 182, 212, 0.05);
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="auth-wrapper">
        <div class="auth-card">
            <div class="logo" style="margin-bottom: 20px; font-size: 20px;">Digi Pic<span>DIGITAL OCEAN</span></div>
            <h2>Forgot Password</h2>
            <p>Request a reset code, then use it to set a new encrypted password.</p>

            <% if (message != null) { %>
                <div class="auth-message"><%= message %></div>
            <% } %>
            <% if (error != null) { %>
                <div class="auth-error"><%= error %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/forgot-password" method="post">
                <input type="hidden" name="action" value="request">
                <div class="form-group">
                    <label>EMAIL ADDRESS</label>
                    <input type="email" name="email" class="form-control" value="<%= email == null ? "" : email %>" placeholder="voyager@ocean.com" required>
                </div>
                <button type="submit" class="btn-primary btn-full">Generate Reset Code</button>
            </form>

            <% if (generatedCode != null || hasResetSession) { %>
                <div class="reset-code-box">
                    <strong>Reset Code:</strong> <%= generatedCode != null ? generatedCode : sessionCode %>
                    <div style="margin-top: 6px; color: var(--text-secondary);">
                        Demo note: because the current schema does not include a reset-token table, the code is shown here for local use.
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/forgot-password" method="post">
                    <input type="hidden" name="action" value="reset">
                    <div class="form-group">
                        <label>RESET CODE</label>
                        <input type="text" name="code" class="form-control" placeholder="Enter the 6-digit code" required>
                    </div>
                    <div class="form-group">
                        <label>NEW PASSWORD</label>
                        <input type="password" name="newPassword" class="form-control" minlength="6" required>
                    </div>
                    <div class="form-group">
                        <label>CONFIRM PASSWORD</label>
                        <input type="password" name="confirmPassword" class="form-control" minlength="6" required>
                    </div>
                    <button type="submit" class="btn-primary btn-full">Update Password</button>
                </form>
            <% } %>

            <div class="auth-links">
                Back to <a href="${pageContext.request.contextPath}/login">log in</a>
            </div>
        </div>
    </div>
</body>
</html>
