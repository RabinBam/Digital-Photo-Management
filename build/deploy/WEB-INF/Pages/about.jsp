<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.DigiPic4.model.User" %>
<%
    User aboutUser = (User) session.getAttribute("user");
    if (aboutUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String userRole = aboutUser.getRole() == null ? "" : aboutUser.getRole().trim();
    boolean isAdmin = "admin".equalsIgnoreCase(userRole);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About Us – DigiPic</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style-light.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700;800&family=Sora:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        .page-container {
            max-width: 1000px; margin: 0 auto; padding: 0 24px 60px;
        }

        /* ── Hero Section ────────────────────────── */
        .about-hero {
            text-align: center; margin-bottom: 60px;
            padding: 40px 20px; background: var(--bg-surface);
            border-radius: 24px; border: 1px solid var(--border-color);
            box-shadow: var(--shadow-sm);
            background-image: radial-gradient(circle at top right, rgba(37,99,235,0.05), transparent 400px);
        }
        .about-hero h5 {
            color: #2563eb; font-size: 13px; letter-spacing: 2px; font-weight: 700;
            text-transform: uppercase; margin-bottom: 12px;
        }
        .about-hero h1 {
            font-size: 52px; font-family: var(--font-display, 'Playfair Display', serif);
            font-weight: 800; color: #1e293b; margin: 0 0 20px;
            line-height: 1.1;
        }
        .about-hero p {
            font-size: 17px; color: #64748b; max-width: 650px; margin: 0 auto;
            line-height: 1.6;
        }

        /* ── Mission Grid ────────────────────────── */
        .mission-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px;
            margin-bottom: 60px;
        }
        @media (max-width: 800px) { .mission-grid { grid-template-columns: 1fr; } }

        .mission-card {
            background: var(--bg-surface); padding: 32px 24px;
            border-radius: 20px; border: 1px solid var(--border-color);
            text-align: center; box-shadow: var(--shadow-sm);
            transition: all 0.25s;
        }
        .mission-card:hover {
            transform: translateY(-6px); box-shadow: var(--shadow-md);
            border-color: #93c5fd;
        }
        .mc-icon {
            width: 60px; height: 60px; border-radius: 16px;
            background: linear-gradient(135deg, #eff6ff, #dbeafe);
            color: #2563eb; font-size: 26px; display: inline-flex;
            align-items: center; justify-content: center; margin-bottom: 20px;
        }
        .mission-card h3 { font-size: 18px; font-weight: 700; color: #1e293b; margin: 0 0 10px; }
        .mission-card p { font-size: 14px; color: #64748b; line-height: 1.6; margin: 0; }

        /* ── Story Section ───────────────────────── */
        .story-section {
            display: grid; grid-template-columns: 1fr 1fr; gap: 40px; align-items: center;
            background: var(--bg-surface); border-radius: 24px;
            border: 1px solid var(--border-color); overflow: hidden;
            box-shadow: var(--shadow-sm); margin-bottom: 60px;
        }
        @media (max-width: 800px) { .story-section { grid-template-columns: 1fr; } }
        
        .story-img {
            width: 100%; height: 100%; min-height: 350px; object-fit: cover;
            background: #e2e8f0;
        }
        .story-content { padding: 40px; }
        .story-content h2 {
            font-family: var(--font-display, 'Playfair Display', serif);
            font-size: 32px; color: #1e293b; margin: 0 0 16px;
        }
        .story-content p {
            font-size: 15px; color: #64748b; line-height: 1.7; margin-bottom: 16px;
        }
        .story-content p:last-child { margin-bottom: 0; }

        /* ── Stats ───────────────────────────────── */
        .stats-wrap {
            display: flex; justify-content: space-around; flex-wrap: wrap; gap: 20px;
            padding: 40px 0; border-top: 1px solid var(--border-color);
            border-bottom: 1px solid var(--border-color);
            margin-bottom: 60px;
        }
        .stat-item { text-align: center; }
        .stat-num {
            font-size: 42px; font-family: var(--font-display, 'Playfair Display', serif);
            font-weight: 800; color: #2563eb; line-height: 1; margin-bottom: 8px;
        }
        .stat-lbl {
            font-size: 12px; font-weight: 700; color: #94a3b8;
            text-transform: uppercase; letter-spacing: 1px;
        }

    </style>
</head>
<body>

    <jsp:include page='<%= isAdmin ? "../components/adminSidebar.jsp" : "../components/sidebar.jsp" %>' />

    <main class="main-content">
        <jsp:include page='<%= isAdmin ? "../components/adminHeader.jsp" : "../components/Header.jsp" %>' />

        <div class="page-container">
            
            <div class="about-hero">
                <h5>OUR VISION</h5>
                <h1>Preserving Your<br>Digital Memories</h1>
                <p>DigiPic was built on a simple premise: your photos are the timeline of your life. They deserve a home that is secure, beautiful, and intuitively organized.</p>
            </div>

            <div class="mission-grid">
                <div class="mission-card">
                    <div class="mc-icon"><i class="bi bi-shield-lock-fill"></i></div>
                    <h3>Secure Vault</h3>
                    <p>Enterprise-grade encryption ensures your personal archives remain strictly yours. No data mining, no privacy compromises.</p>
                </div>
                <div class="mission-card">
                    <div class="mc-icon"><i class="bi bi-magic"></i></div>
                    <h3>Smart Curation</h3>
                    <p>Effortlessly organize thousands of photos into stunning albums using intelligent metadata and categorization.</p>
                </div>
                <div class="mission-card">
                    <div class="mc-icon"><i class="bi bi-globe-americas"></i></div>
                    <h3>Discover the World</h3>
                    <p>Integrate with external APIs to explore curated photography from around the globe directly within your vault.</p>
                </div>
            </div>

            <div class="story-section">
                <img src="https://images.unsplash.com/photo-1542038784456-1ea8e935640e?q=80&w=1200&auto=format&fit=crop" alt="Camera lens" class="story-img">
                <div class="story-content">
                    <h2>The Story Behind DigiPic</h2>
                    <p>We started DigiPic in 2026 out of frustration. Existing cloud storage felt cold and disjointed, while social media photo apps compromised privacy for engagement.</p>
                    <p>We set out to build the "Digital Ocean" — a personal vault that treats your photography with respect. Whether you are a professional photographer managing RAW files or a parent saving family memories, DigiPic provides a seamless, premium experience designed purely around your content.</p>
                </div>
            </div>

            <div class="stats-wrap">
                <div class="stat-item">
                    <div class="stat-num">50M+</div>
                    <div class="stat-lbl">Photos Stored</div>
                </div>
                <div class="stat-item">
                    <div class="stat-num">120k</div>
                    <div class="stat-lbl">Active Vaults</div>
                </div>
                <div class="stat-item">
                    <div class="stat-num">99.9%</div>
                    <div class="stat-lbl">Uptime</div>
                </div>
                <div class="stat-item">
                    <div class="stat-num">0</div>
                    <div class="stat-lbl">Data Breaches</div>
                </div>
            </div>

        </div>

        <jsp:include page="../components/footer.jsp" />
    </main>

</body>
</html>
