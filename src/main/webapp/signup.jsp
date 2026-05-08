<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>DigiPic - Sign Up</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { position: relative; overflow: hidden; }
        .bg-video {
            position: fixed;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            z-index: 0;
            opacity: 0.24;
            pointer-events: none;
        }
        .video-overlay {
            position: fixed;
            inset: 0;
            z-index: 1;
            pointer-events: none;
            background: radial-gradient(circle at top, rgba(6, 182, 212, 0.12), rgba(7, 13, 20, 0.92));
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
        .bubble.b1 { left: 8%; width: 14px; height: 14px; animation-duration: 15s; }
        .bubble.b2 { left: 18%; width: 9px; height: 9px; animation-duration: 11s; animation-delay: 2s; }
        .bubble.b3 { left: 68%; width: 16px; height: 16px; animation-duration: 17s; animation-delay: 3s; }
        .bubble.b4 { left: 82%; width: 11px; height: 11px; animation-duration: 12s; animation-delay: 1s; }
        .bubble.b5 { left: 50%; width: 7px; height: 7px; animation-duration: 10s; animation-delay: 4s; }
        @keyframes bubbleRise {
            0% { transform: translateY(0) translateX(0) scale(1); opacity: 0; }
            10% { opacity: 0.55; }
            100% { transform: translateY(-120vh) translateX(-18px) scale(1.15); opacity: 0; }
        }
        .auth-wrapper {
            position: relative;
            z-index: 2;
            display: flex; justify-content: center; align-items: center; height: 100vh; width: 100%;
        }
        .auth-card {
            background: var(--bg-surface); padding: 40px; border-radius: 16px; width: 450px;
            border: 1px solid rgba(103,232,249,0.08); box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.55);
            backdrop-filter: blur(10px);
        }
        .auth-card h2 { margin-bottom: 5px; font-size: 28px; }
        .auth-card p { color: var(--text-secondary); margin-bottom: 30px; font-size: 14px; }
        .form-group { margin-bottom: 20px; }
        .form-row { display: flex; gap: 15px; }
        .form-row .form-group { flex: 1; }
        .form-group label { display: block; color: var(--text-secondary); font-size: 12px; margin-bottom: 8px; letter-spacing: 1px; }
        .form-control {
            width: 100%; padding: 12px 15px; background: var(--bg-surface-light); border: 1px solid rgba(255,255,255,0.1);
            border-radius: 8px; color: white; outline: none; transition: border 0.3s;
        }
        .form-control:focus { border-color: var(--accent-teal); }
        .btn-full { width: 100%; padding: 15px; font-size: 16px; margin-top: 10px; }
        .auth-links { margin-top: 20px; text-align: center; font-size: 14px; color: var(--text-secondary); }
        .auth-links a { color: var(--accent-teal); text-decoration: none; }
        .auth-error { margin: 12px 0; font-size: 13px; color: #fca5a5; }
    </style>
</head>
<body>
    <video autoplay muted loop playsinline preload="auto" class="bg-video" aria-hidden="true">
        <source src="${pageContext.request.contextPath}/video/Signup-bg.mp4" type="video/mp4">
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
            <h2>Start Exploring</h2>
            <p>Create an account to begin curating your artifacts.</p>

            <% String signupError = (String) request.getAttribute("error"); %>
            <% if (signupError != null) { %>
                <div class="auth-error"><%= signupError %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/signup" method="POST">
                <div class="form-row">
                    <div class="form-group">
                        <label>FIRST NAME</label>
                        <input type="text" name="firstName" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>LAST NAME</label>
                        <input type="text" name="lastName" class="form-control" required>
                    </div>
                </div>
                <div class="form-group">
                    <label>EMAIL ADDRESS</label>
                    <input type="email" name="email" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>PASSWORD</label>
                    <input type="password" name="password" class="form-control" required>
                </div>
                <button type="submit" class="btn-primary btn-full">Initialize Account</button>
            </form>

            <div class="auth-links">
                Already have an account? <a href="${pageContext.request.contextPath}/login">Log in here</a>
            </div>
        </div>
    </div>
</body>
</html>
