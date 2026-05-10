<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>DigiPic - Welcome</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
    <style>
        .bg-video {
            position: fixed;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            z-index: 0;
            opacity: 0.28;
            pointer-events: none;
        }
        .video-overlay {
            position: fixed;
            inset: 0;
            z-index: 1;
            pointer-events: none;
            background: radial-gradient(circle at center, rgba(17, 24, 34, 0.45) 0%, rgba(7, 13, 20, 0.9) 100%);
        }
        .landing-container {
            display: flex; flex-direction: column; justify-content: center; align-items: center;
            position: relative; z-index: 2;
            height: 100vh; text-align: center;
            width: 100%;
        }
        .landing-title { font-size: 64px; color: var(--text-primary); margin-bottom: 10px; font-weight: 800; }
        .landing-title span { color: var(--accent-teal); }
        .landing-subtitle { color: var(--text-secondary); font-size: 18px; margin-bottom: 40px; max-width: 500px; }
        .auth-buttons { display: flex; gap: 20px; }
        .btn-outline {
            background: transparent; border: 2px solid var(--accent-teal); color: var(--accent-teal);
            padding: 12px 30px; border-radius: 30px; font-weight: bold; cursor: pointer; text-decoration: none;
            transition: all 0.3s;
        }
        .btn-outline:hover { background: var(--accent-teal); color: var(--bg-base); box-shadow: 0 0 15px var(--accent-teal-glow); }
        .btn-filled {
            background: var(--accent-teal); border: 2px solid var(--accent-teal); color: var(--bg-base);
            padding: 12px 30px; border-radius: 30px; font-weight: bold; cursor: pointer; text-decoration: none;
            box-shadow: 0 0 15px var(--accent-teal-glow); transition: all 0.3s;
        }
        .btn-filled:hover { transform: translateY(-2px); box-shadow: 0 0 25px var(--accent-teal-glow); }
    </style>
</head>
<body>
    <video autoplay muted loop playsinline preload="auto" class="bg-video" aria-hidden="true">
        <source src="${pageContext.request.contextPath}/video/index-bg.mp4" type="video/mp4">
    </video>
    <div class="video-overlay"></div>

    <div class="landing-container">
        <h1 class="landing-title">Digi<span>Pic</span></h1>
        <p class="landing-subtitle">Dive into your digital ocean. A premium curation hub for your visual artifacts.</p>
        <div class="auth-buttons">
            <a href="${pageContext.request.contextPath}/login" class="btn-outline">Log In</a>
            <a href="${pageContext.request.contextPath}/signup" class="btn-filled">Get Started</a>
        </div>
    </div>
</body>
</html>