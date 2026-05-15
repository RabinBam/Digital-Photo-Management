<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.DigiPic4.model.User" %>
<%
    User contactUser = (User) session.getAttribute("user");
    if (contactUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String userRole = contactUser.getRole() == null ? "" : contactUser.getRole().trim();
    boolean isAdmin = "admin".equalsIgnoreCase(userRole);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Us – DigiPic</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style-light.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Sora:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        .page-container {
            max-width: 1000px; margin: 0 auto; padding: 0 24px 60px;
        }

        /* ── Hero Section ────────────────────────── */
        .contact-hero {
            text-align: center; margin-bottom: 50px;
        }
        .contact-hero h5 {
            color: #2563eb; font-size: 13px; letter-spacing: 2px; font-weight: 700;
            text-transform: uppercase; margin-bottom: 12px;
        }
        .contact-hero h1 {
            font-size: 46px; font-family: var(--font-display, 'Playfair Display', serif);
            font-weight: 700; color: #1e293b; margin: 0 0 16px;
            line-height: 1.1;
        }
        .contact-hero p {
            font-size: 16px; color: #64748b; max-width: 600px; margin: 0 auto;
            line-height: 1.6;
        }

        /* ── Layout ───────────────────────────── */
        .contact-grid {
            display: grid; grid-template-columns: 1fr 1.3fr; gap: 40px;
        }

        @media (max-width: 800px) {
            .contact-grid { grid-template-columns: 1fr; }
        }

        /* ── Info Cards ───────────────────────── */
        .contact-info-list {
            display: flex; flex-direction: column; gap: 20px;
        }
        .info-card {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            padding: 24px; border-radius: 16px;
            display: flex; gap: 18px; align-items: flex-start;
            box-shadow: var(--shadow-sm); transition: all 0.25s;
        }
        .info-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-md);
            border-color: #2563eb;
        }
        .info-icon {
            width: 48px; height: 48px; border-radius: 12px;
            background: #eff6ff; color: #2563eb;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px; flex-shrink: 0;
        }
        .info-card-content h3 {
            font-size: 16px; font-weight: 700; color: #1e293b; margin: 0 0 6px;
        }
        .info-card-content p {
            font-size: 14px; color: #64748b; line-height: 1.5; margin: 0;
        }

        /* ── Form Section ─────────────────────── */
        .contact-form-box {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            padding: 36px; border-radius: 20px;
            box-shadow: var(--shadow-sm);
        }
        .contact-form-box h3 {
            font-family: var(--font-display, 'Playfair Display', serif);
            font-size: 24px; color: #1e293b; margin: 0 0 24px;
        }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px; }
        @media (max-width: 500px) { .form-grid { grid-template-columns: 1fr; } }
        
        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .form-group.full { grid-column: 1 / -1; }
        .form-group label {
            font-size: 12px; font-weight: 700; color: #64748b;
            text-transform: uppercase; letter-spacing: 0.5px;
        }
        .form-group input, .form-group textarea, .form-group select {
            padding: 12px 16px; border-radius: 10px;
            border: 1.5px solid var(--border-color);
            background: var(--bg-surface-light);
            font-size: 14px; font-family: var(--font-family);
            color: var(--text-primary); transition: all 0.2s;
        }
        .form-group input:focus, .form-group textarea:focus, .form-group select:focus {
            outline: none; border-color: #2563eb; background: var(--bg-surface);
            box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
        }
        .form-group textarea { resize: vertical; min-height: 120px; }
        
        .btn-submit {
            width: 100%; padding: 14px; border: none; border-radius: 10px;
            background: linear-gradient(135deg, #2563eb, #1e40af);
            color: #fff; font-size: 15px; font-weight: 700; font-family: var(--font-family);
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            gap: 10px; transition: all 0.25s; box-shadow: 0 6px 20px rgba(37,99,235,0.2);
            margin-top: 24px;
        }
        .btn-submit:hover {
            transform: translateY(-2px); box-shadow: 0 10px 28px rgba(37,99,235,0.3);
        }

        /* Success Message */
        .success-msg {
            display: none; background: #f0fdf4; border: 1px solid #bbf7d0;
            color: #166534; padding: 16px; border-radius: 10px; margin-bottom: 24px;
            text-align: center; font-weight: 600; font-size: 14px;
        }
    </style>
</head>
<body>

    <jsp:include page='<%= isAdmin ? "../components/adminSidebar.jsp" : "../components/sidebar.jsp" %>' />

    <main class="main-content">
        <jsp:include page='<%= isAdmin ? "../components/adminHeader.jsp" : "../components/Header.jsp" %>' />

        <div class="page-container">
            <div class="contact-hero">
                <h5>GET IN TOUCH</h5>
                <h1>How can we help?</h1>
                <p>Have a question about storage plans, encountered an issue, or just want to share some feedback? Our team is here to assist you.</p>
            </div>

            <div class="contact-grid">
                
                <!-- Left: Info -->
                <div class="contact-info-list">
                    <div class="info-card">
                        <div class="info-icon"><i class="bi bi-chat-dots-fill"></i></div>
                        <div class="info-card-content">
                            <h3>General Support</h3>
                            <p>For app usage, bugs, or account inquiries.<br><strong>support@digipic.com</strong></p>
                        </div>
                    </div>
                    <div class="info-card">
                        <div class="info-icon"><i class="bi bi-briefcase-fill"></i></div>
                        <div class="info-card-content">
                            <h3>Business & Enterprise</h3>
                            <p>For custom storage plans and API access.<br><strong>sales@digipic.com</strong></p>
                        </div>
                    </div>
                    <div class="info-card">
                        <div class="info-icon"><i class="bi bi-geo-alt-fill"></i></div>
                        <div class="info-card-content">
                            <h3>Headquarters</h3>
                            <p>101 Digital Ave, Suite 400<br>San Francisco, CA 94107</p>
                        </div>
                    </div>
                </div>

                <!-- Right: Form -->
                <div class="contact-form-box">
                    <div id="contactSuccessMsg" class="success-msg">
                        <i class="bi bi-check-circle-fill"></i> Message sent! We'll get back to you shortly.
                    </div>
                    
                    <h3>Send a Message</h3>
                    <form id="contactForm" onsubmit="submitContactForm(event)">
                        <div class="form-grid">
                            <div class="form-group">
                                <label>Your Name</label>
                                <input type="text" value="<%= contactUser.getFirstName() + " " + contactUser.getLastName() %>" required>
                            </div>
                            <div class="form-group">
                                <label>Email Address</label>
                                <input type="email" value="<%= contactUser.getEmail() %>" required readonly style="background:#e2e8f0; cursor:not-allowed;">
                            </div>
                        </div>
                        
                        <div class="form-group" style="margin-bottom:16px;">
                            <label>Topic</label>
                            <select required>
                                <option value="" disabled selected>Select a topic…</option>
                                <option value="support">Technical Support</option>
                                <option value="billing">Billing & Plans</option>
                                <option value="feedback">Feedback</option>
                                <option value="other">Other</option>
                            </select>
                        </div>
                        
                        <div class="form-group full">
                            <label>Message</label>
                            <textarea required placeholder="How can we help you today?"></textarea>
                        </div>
                        
                        <button type="submit" class="btn-submit" id="btnSubmit">
                            <i class="bi bi-send-fill"></i> Send Message
                        </button>
                    </form>
                </div>

            </div>
        </div>

        <jsp:include page="../components/footer.jsp" />
    </main>

    <script>
        function submitContactForm(e) {
            e.preventDefault();
            const btn = document.getElementById('btnSubmit');
            const msg = document.getElementById('contactSuccessMsg');
            
            btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Sending...';
            btn.disabled = true;
            
            // Simulate network delay
            setTimeout(() => {
                document.getElementById('contactForm').reset();
                btn.innerHTML = '<i class="bi bi-send-fill"></i> Send Message';
                btn.disabled = false;
                msg.style.display = 'block';
                
                // Hide message after 5 seconds
                setTimeout(() => {
                    msg.style.display = 'none';
                }, 5000);
            }, 1200);
        }
    </script>
</body>
</html>
