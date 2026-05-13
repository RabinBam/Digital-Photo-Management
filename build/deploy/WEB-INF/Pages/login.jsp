<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>DigiPic - Login</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=<%= System.currentTimeMillis() %>">
    <style>
        body { position: relative; overflow: hidden; }
        .bg-video {
            position: fixed;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            z-index: 0;
            opacity: 0.22;
            pointer-events: none;
        }
        .video-overlay {
            position: fixed;
            inset: 0;
            z-index: 1;
            pointer-events: none;
            background: radial-gradient(circle at top, rgba(6, 182, 212, 0.10), rgba(7, 13, 20, 0.92));
        }
        .ocean-bubbles { position: fixed; inset: 0; z-index: 1; pointer-events: none; overflow: hidden; }
        .bubble {
            position: absolute;
            bottom: -80px;
            border-radius: 50%;
            border: 1px solid rgba(103, 232, 249, 0.22);
            background: rgba(255, 255, 255, 0.04);
            box-shadow: 0 0 20px rgba(6, 182, 212, 0.12);
            animation: bubbleRise linear infinite;
        }
        .bubble::after {
            content: "";
            position: absolute;
            inset: 18%;
            border-radius: 50%;
            background: rgba(255,255,255,0.08);
        }
        .bubble.b1 { left: 10%; width: 16px; height: 16px; animation-duration: 14s; }
        .bubble.b2 { left: 22%; width: 10px; height: 10px; animation-duration: 10s; animation-delay: 2s; }
        .bubble.b3 { left: 74%; width: 18px; height: 18px; animation-duration: 16s; animation-delay: 3s; }
        .bubble.b4 { left: 86%; width: 12px; height: 12px; animation-duration: 12s; animation-delay: 1s; }
        .bubble.b5 { left: 54%; width: 8px; height: 8px; animation-duration: 11s; animation-delay: 4s; }
        @keyframes bubbleRise {
            0% { transform: translateY(0) translateX(0) scale(1); opacity: 0; }
            10% { opacity: 0.55; }
            100% { transform: translateY(-120vh) translateX(20px) scale(1.15); opacity: 0; }
        }
        .auth-wrapper {
            position: relative;
            z-index: 2;
            display: flex; justify-content: center; align-items: center; height: 100vh; width: 100%;
        }
        .auth-card {
            background: var(--bg-surface); padding: 40px; border-radius: 16px; width: 400px;
            border: 1px solid rgba(103,232,249,0.08); box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.55);
            backdrop-filter: blur(10px);
        }
        .auth-card h2 { margin-bottom: 5px; font-size: 28px; }
        .auth-card p { color: var(--text-secondary); margin-bottom: 30px; font-size: 14px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; color: var(--text-secondary); font-size: 12px; margin-bottom: 8px; letter-spacing: 1px; }
        .form-control {
            width: 100%; padding: 12px 15px; background: var(--bg-surface-light); border: 1px solid rgba(255,255,255,0.1);
            border-radius: 8px; color: white; outline: none; transition: border 0.3s;
        }
        .form-control:focus { border-color: var(--accent-teal); }
        .btn-full { width: 100%; padding: 15px; font-size: 16px; margin-top: 10px; }
        .auth-links { margin-top: 20px; text-align: center; font-size: 14px; color: var(--text-secondary); }
        .auth-links a { color: var(--accent-teal); text-decoration: none; }
        .auth-message { margin: 12px 0; font-size: 13px; color: #7dd3fc; }
        .auth-error { margin: 12px 0; font-size: 13px; color: #fca5a5; }
    </style>
</head>
<body>
    <video autoplay muted loop playsinline preload="auto" class="bg-video" aria-hidden="true">
        <source src="${pageContext.request.contextPath}/video/login-bg.mp4" type="video/mp4">
    </video>
    <div class="video-overlay"></div>
    <div class="ocean-bubbles" aria-hidden="true">
        <span class="bubble b1"></span>
        <span class="bubble b2"></span>
        <span class="bubble b3"></span>
        <span class="bubble b4"></span>
        <span class="bubble b5"></span>
    </div>

    <div class="auth-wrapper">
        <div class="auth-card">
            <div class="logo" style="margin-bottom: 20px; font-size: 20px;">Digi Pic<span>DIGITAL OCEAN</span></div>
            <h2>Welcome Back</h2>
            <p>Enter your credentials to access your collections.</p>

            <% String loginError = (String) request.getAttribute("error"); %>
            <% String success = request.getParameter("success"); %>
            <% if (success != null) { %>
                <div class="auth-message"><%= success %></div>
            <% } %>
            <% if (loginError != null) { %>
                <div class="auth-error"><%= loginError %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/login" method="POST">
                <div class="form-group">
                    <label>EMAIL ADDRESS</label>
                    <input type="email" name="email" class="form-control" placeholder="voyager@ocean.com" required>
                </div>
                <div class="form-group">
                    <label>PASSWORD</label>
                    <input type="password" name="password" class="form-control" placeholder="........" required>
                </div>
                <button type="submit" class="btn-primary btn-full">Access Hub</button>
            </form>

            <div class="auth-links">
                New to the ocean? <a href="${pageContext.request.contextPath}/signup">Create an account</a>
                <br><a href="${pageContext.request.contextPath}/forgot-password">Forgot password?</a>
            </div>
        </div>
    </div>
</body>
</html>
