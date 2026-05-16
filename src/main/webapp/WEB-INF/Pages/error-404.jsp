<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found – DigiPic</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Sora:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-deep: #070d14; --bg-surface: rgba(15,23,42,0.85);
            --accent: #2563eb; --accent-lt: #3b82f6; --teal: #06b6d4;
            --text: #e2e8f0; --text-dim: #94a3b8;
            --font-sans: 'Sora', sans-serif; --font-serif: 'Playfair Display', serif;
        }
        *,*::before,*::after { box-sizing:border-box; margin:0; padding:0; }
        body { background:var(--bg-deep); color:var(--text); font-family:var(--font-sans); min-height:100vh; overflow:hidden; display:flex; align-items:center; justify-content:center; }

        .ocean-bg { position:fixed; inset:0; z-index:0; background: radial-gradient(ellipse 80% 50% at 50% 120%,rgba(6,182,212,0.08) 0%,transparent 60%), radial-gradient(ellipse 60% 40% at 20% 80%,rgba(37,99,235,0.06) 0%,transparent 50%), var(--bg-deep); }
        .particles { position:fixed; inset:0; z-index:1; pointer-events:none; overflow:hidden; }
        .particle { position:absolute; border-radius:50%; background:radial-gradient(circle,rgba(6,182,212,0.3),transparent 70%); animation:drift linear infinite; bottom:-10px; }
        .particle:nth-child(1){width:4px;height:4px;left:12%;animation-duration:18s;}
        .particle:nth-child(2){width:6px;height:6px;left:28%;animation-duration:14s;animation-delay:2s;}
        .particle:nth-child(3){width:3px;height:3px;left:45%;animation-duration:20s;animation-delay:5s;}
        .particle:nth-child(4){width:5px;height:5px;left:62%;animation-duration:16s;animation-delay:1s;}
        .particle:nth-child(5){width:4px;height:4px;left:78%;animation-duration:22s;animation-delay:3s;}
        .particle:nth-child(6){width:7px;height:7px;left:90%;animation-duration:15s;animation-delay:4s;}
        @keyframes drift { 0%{transform:translateY(0) translateX(0);opacity:0;} 10%{opacity:0.7;} 90%{opacity:0.4;} 100%{transform:translateY(-110vh) translateX(30px);opacity:0;} }

        .wave-container { position:fixed; bottom:0; left:0; right:0; height:200px; z-index:1; pointer-events:none; overflow:hidden; }
        .wave { position:absolute; bottom:0; width:200%; height:100%; background-repeat:repeat-x; animation:wave-slide linear infinite; }
        .wave-1 { background:linear-gradient(90deg,transparent 0%,rgba(6,182,212,0.04) 25%,rgba(37,99,235,0.06) 50%,rgba(6,182,212,0.04) 75%,transparent 100%); background-size:50% 100%; height:60%; animation-duration:25s; }
        .wave-2 { background:linear-gradient(90deg,transparent 0%,rgba(37,99,235,0.03) 25%,rgba(6,182,212,0.05) 50%,rgba(37,99,235,0.03) 75%,transparent 100%); background-size:50% 100%; height:40%; animation-duration:18s; animation-direction:reverse; }
        @keyframes wave-slide { 0%{transform:translateX(0);} 100%{transform:translateX(-50%);} }

        .error-wrapper { position:relative; z-index:10; text-align:center; max-width:520px; padding:20px; }

        .error-code {
            font-family:var(--font-serif); font-size:clamp(100px,18vw,160px); font-weight:700; line-height:1;
            background:linear-gradient(135deg,var(--teal),var(--accent),var(--accent-lt)); background-size:200% 200%;
            -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text;
            animation:gradient-shift 4s ease infinite; margin-bottom:8px; position:relative;
        }
        .error-code::after { content:''; position:absolute; bottom:10px; left:50%; transform:translateX(-50%); width:80px; height:4px; background:linear-gradient(90deg,transparent,var(--teal),transparent); border-radius:2px; animation:pulse-bar 2s ease-in-out infinite; }
        @keyframes gradient-shift { 0%,100%{background-position:0% 50%;} 50%{background-position:100% 50%;} }
        @keyframes pulse-bar { 0%,100%{opacity:0.3;width:60px;} 50%{opacity:1;width:100px;} }

        .error-card {
            background:var(--bg-surface); backdrop-filter:blur(20px); border:1px solid rgba(103,232,249,0.08);
            border-radius:24px; padding:40px 36px 36px;
            box-shadow:0 25px 60px rgba(0,0,0,0.4),0 0 80px rgba(6,182,212,0.04),inset 0 1px 0 rgba(255,255,255,0.04);
            animation:card-enter 0.6s cubic-bezier(0.22,1,0.36,1) both;
        }
        @keyframes card-enter { from{opacity:0;transform:translateY(30px) scale(0.97);} to{opacity:1;transform:none;} }

        .error-subtitle { font-size:10px; font-weight:700; letter-spacing:3px; text-transform:uppercase; color:var(--teal); margin-bottom:16px; }
        .error-title { font-family:var(--font-serif); font-size:28px; font-weight:700; color:#f1f5f9; margin-bottom:12px; line-height:1.3; }
        .error-message { font-size:14px; color:var(--text-dim); line-height:1.7; margin-bottom:32px; max-width:380px; margin-left:auto; margin-right:auto; }

        .error-actions { display:flex; gap:12px; justify-content:center; flex-wrap:wrap; }
        .btn-home {
            display:inline-flex; align-items:center; gap:8px; padding:13px 28px;
            background:linear-gradient(135deg,var(--accent),#1e40af); color:#fff; border:none; border-radius:12px;
            font-family:var(--font-sans); font-size:14px; font-weight:700; cursor:pointer; text-decoration:none;
            box-shadow:0 8px 24px rgba(37,99,235,0.3); transition:all 0.3s;
        }
        .btn-home:hover { transform:translateY(-2px); box-shadow:0 12px 32px rgba(37,99,235,0.4); }
        .btn-back {
            display:inline-flex; align-items:center; gap:8px; padding:13px 28px;
            background:rgba(255,255,255,0.04); color:var(--text); border:1.5px solid rgba(255,255,255,0.1);
            border-radius:12px; font-family:var(--font-sans); font-size:14px; font-weight:600;
            cursor:pointer; text-decoration:none; transition:all 0.3s;
        }
        .btn-back:hover { border-color:var(--teal); background:rgba(6,182,212,0.06); color:#fff; transform:translateY(-2px); }

        .error-footer { margin-top:28px; font-size:12px; color:rgba(148,163,184,0.5); }
        .error-footer a { color:var(--teal); text-decoration:none; font-weight:600; transition:color 0.2s; }
        .error-footer a:hover { color:#22d3ee; }

        @media (max-width:480px) {
            .error-card { padding:30px 24px 28px; }
            .error-title { font-size:22px; }
            .error-actions { flex-direction:column; }
            .btn-home,.btn-back { width:100%; justify-content:center; }
        }
    </style>
</head>
<body>
    <div class="ocean-bg"></div>
    <div class="particles" aria-hidden="true">
        <span class="particle"></span><span class="particle"></span><span class="particle"></span>
        <span class="particle"></span><span class="particle"></span><span class="particle"></span>
    </div>
    <div class="wave-container" aria-hidden="true"><div class="wave wave-1"></div><div class="wave wave-2"></div></div>

    <div class="error-wrapper">
        <div class="error-code" aria-hidden="true">404</div>
        <div class="error-card">
            <div class="error-subtitle">Navigation Error</div>
            <h1 class="error-title">Lost in the Digital Ocean</h1>
            <p class="error-message">The page you're looking for has drifted away or doesn't exist. Don't worry — let's get you back on course.</p>
            <div class="error-actions">
                <a href="${pageContext.request.contextPath}/gallery" class="btn-home" id="btn-go-gallery"><i class="bi bi-house-door-fill"></i> Go to Gallery</a>
                <a href="javascript:history.back()" class="btn-back" id="btn-go-back"><i class="bi bi-arrow-left"></i> Go Back</a>
            </div>
            <div class="error-footer">
                Or try <a href="${pageContext.request.contextPath}/explore">Explore</a> · <a href="${pageContext.request.contextPath}/albums">Albums</a> · <a href="${pageContext.request.contextPath}/contact">Contact</a>
            </div>
        </div>
    </div>
</body>
</html>
