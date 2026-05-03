<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    com.DigiPic4.model.User albumsUser = (com.DigiPic4.model.User) session.getAttribute("user");
    if (albumsUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String albumsRole = albumsUser.getRole() == null ? "" : albumsUser.getRole().trim();
    boolean albumsIsAdmin = "admin".equalsIgnoreCase(albumsRole);

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Collections - Digi Pic</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style-light.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/uploadCss-light.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@400;700&family=Cormorant+Garamond:wght@400;500;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">

    <style>
        :root {
            --font-serif: 'Cormorant Garamond', serif;
            --font-sans: 'Sora', sans-serif;
        }

        .page-content {
            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .section-header {
            margin-bottom: 30px;
        }

        .section-header h5 {
            color: #2563eb;
            font-size: 12px;
            letter-spacing: 1.5px;
            font-weight: 700;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }

        .section-header h1 {
            font-size: 42px;
            margin: 0;
            font-family: var(--font-serif);
            font-weight: 700;
            color: #1e293b;
        }

        .section-header p {
            color: #64748b;
            margin-top: 8px;
            font-size: 15px;
        }

        .grid {
            display: grid;
            gap: 24px;
            margin-top: 20px;
        }

        .grid-3 {
            grid-template-columns: repeat(3, 1fr);
        }

        .card {
            background: var(--bg-surface);
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid var(--border-color);
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            cursor: pointer;
        }

        .card:hover {
            transform: translateY(-6px);
            box-shadow: 0 12px 28px rgba(37, 99, 235, 0.15);
            border-color: #3b82f6;
        }

        .card img {
            width: 100%;
            height: 200px;
            object-fit: cover;
        }

        .card-info {
            padding: 16px;
        }

        .card-info p {
            background: linear-gradient(135deg, #2563eb, #1e40af);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }

        .card-info h3 {
            font-size: 18px;
            font-weight: 700;
            color: #1e293b;
            margin: 0;
            font-family: var(--font-serif);
        }

        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(8px);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .modal-content {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            width: 90%;
            max-width: 720px;
            display: flex;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
        }

        .drop-zone {
            flex: 1;
            padding: 50px;
            text-align: center;
            border-right: 1px solid var(--border-color);
            background: #f0f4f8;
            border: 2px dashed #cbd5e1;
            margin: 20px;
            border-radius: 16px;
        }

        .drop-zone h2 {
            font-family: var(--font-serif);
            font-size: 22px;
            font-weight: 700;
            color: #1e293b;
            margin: 20px 0 10px;
        }

        .drop-zone p {
            color: #64748b;
            font-size: 14px;
            margin-bottom: 30px;
        }

        .upload-details {
            flex: 1;
            padding: 35px;
        }

        .progress-bar {
            height: 4px;
            background: #e2e8f0;
            border-radius: 2px;
            margin-top: 6px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #2563eb, #1e40af);
        }

        @media (max-width: 768px) {
            .grid-3 {
                grid-template-columns: repeat(2, 1fr);
            }

            .modal-content {
                flex-direction: column;
            }

            .drop-zone {
                border-right: none;
                border-bottom: 1px solid var(--border-color);
            }

            .section-header h1 {
                font-size: 32px;
            }
        }

        @media (max-width: 480px) {
            .grid-3 {
                grid-template-columns: 1fr;
            }

            .page-content {
                padding: 0 12px;
            }
        }
    </style>
</head>

<body>

    <jsp:include page="<%= albumsIsAdmin ? \"adminSidebar.jsp\" : \"sidebar.jsp\" %>" />

    <main class="main-content">

        <jsp:include page="<%= albumsIsAdmin ? \"adminHeader.jsp\" : \"Header.jsp\" %>" />

        <div class="page-content">
            <div class="section-header">
                <h5>CURATION HUB</h5>
                <h1>Your Collections</h1>
                <p>Organized visual artifacts from your digital expeditions</p>
            </div>

            <div class="grid grid-3">
                <div class="card">
                    <img src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800" alt="Summer 2025">
                    <div class="card-info">
                        <p>VOL. 12 - 456 PHOTOS</p>
                        <h3>Summer 2025</h3>
                    </div>
                </div>

                <div class="card">
                    <img src="https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800" alt="Underwater Exploration">
                    <div class="card-info">
                        <p>EXPEDITION - 128 PHOTOS</p>
                        <h3>Underwater Exploration</h3>
                    </div>
                </div>

                <div class="card">
                    <img src="https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800" alt="Family Memories">
                    <div class="card-info">
                        <p>LEGACY - 892 PHOTOS</p>
                        <h3>Family Memories</h3>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal-overlay" id="uploadModal">
            <div class="modal-content">
                <div class="drop-zone">
                    <h2>Drop into the Ocean</h2>
                    <p>Release your digital artifacts to begin the curation process</p>
                    <button class="btn-primary" type="button">SELECT FILES</button>
                </div>

                <div class="upload-details">
                    <div style="display: flex; justify-content: space-between; margin-bottom: 25px; align-items: center;">
                        <span style="color: #2563eb; font-size: 12px; font-weight: 700; text-transform: uppercase;">IMPORT QUEUE</span>
                        <button onclick="closeUploadModal()" style="background: none; border: none; color: #64748b; cursor: pointer; font-size: 20px; font-weight: 700;">×</button>
                    </div>

                    <div>
                        <div style="display: flex; justify-content: space-between; font-size: 14px; margin-bottom: 8px; font-weight: 600;">
                            <span>DSC0912_DeepSea.raw</span>
                            <span style="background: linear-gradient(135deg, #2563eb, #1e40af); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;">85%</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: 85%;"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </main>

    <script>
        function openUploadModal() {
            document.getElementById('uploadModal').style.display = 'flex';
        }

        function closeUploadModal() {
            document.getElementById('uploadModal').style.display = 'none';
        }
    </script>

</body>
</html>
