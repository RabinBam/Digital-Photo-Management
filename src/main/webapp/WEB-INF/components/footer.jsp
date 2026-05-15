<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<footer class="dp-footer">
    <div class="dp-footer-inner">

        <!-- Column 1: Brand -->
        <div class="dp-footer-col dp-footer-brand">
            <div class="dp-footer-logo">DigiPic<span>Digital Ocean</span></div>
            <p class="dp-footer-tagline">Your personal digital photo vault. Store, organise, explore, and relive every moment — all in one place.</p>
            <div class="dp-footer-social">
                <a href="#" title="Twitter"><i class="bi bi-twitter-x"></i></a>
                <a href="#" title="Instagram"><i class="bi bi-instagram"></i></a>
                <a href="#" title="GitHub"><i class="bi bi-github"></i></a>
                <a href="#" title="LinkedIn"><i class="bi bi-linkedin"></i></a>
            </div>
        </div>

        <!-- Column 2: Quick Links -->
        <div class="dp-footer-col">
            <h4>Quick Links</h4>
            <ul>
                <li><a href="${pageContext.request.contextPath}/gallery"><i class="bi bi-collection"></i> Gallery</a></li>
                <li><a href="${pageContext.request.contextPath}/albums"><i class="bi bi-folder2"></i> Collections</a></li>
                <li><a href="${pageContext.request.contextPath}/uploadImport"><i class="bi bi-cloud-upload"></i> Upload</a></li>
                <li><a href="${pageContext.request.contextPath}/explore"><i class="bi bi-compass"></i> Explore</a></li>

            </ul>
        </div>

        <!-- Column 3: Support -->
        <div class="dp-footer-col">
            <h4>Support</h4>
            <ul>
                <li><a href="${pageContext.request.contextPath}/about"><i class="bi bi-info-circle"></i> About Us</a></li>
                <li><a href="${pageContext.request.contextPath}/contact"><i class="bi bi-envelope"></i> Contact Us</a></li>
                <li><a href="${pageContext.request.contextPath}/profile"><i class="bi bi-person-circle"></i> My Profile</a></li>
                <li><a href="#"><i class="bi bi-shield-check"></i> Privacy Policy</a></li>
                <li><a href="#"><i class="bi bi-file-earmark-text"></i> Terms of Service</a></li>
            </ul>
        </div>

        <!-- Column 4: Newsletter -->
        <div class="dp-footer-col">
            <h4>Stay Updated</h4>
            <p class="dp-footer-newsletter-text">Get the latest features and updates delivered to your inbox.</p>
            <form class="dp-footer-newsletter" onsubmit="event.preventDefault(); this.querySelector('button').textContent='Subscribed!'; this.querySelector('button').disabled=true;">
                <input type="email" placeholder="your@email.com" required>
                <button type="submit"><i class="bi bi-send-fill"></i></button>
            </form>
        </div>
    </div>

    <!-- Bottom Bar -->
    <div class="dp-footer-bottom">
        <span>&copy; 2026 DigiPic — Digital Photo Management. All rights reserved.</span>
        <span class="dp-footer-bottom-links">
            <a href="${pageContext.request.contextPath}/about">About</a>
            <a href="${pageContext.request.contextPath}/contact">Contact</a>
            <a href="#">Privacy</a>
        </span>
    </div>
</footer>

<style>
/* ── DigiPic Footer ──────────────────────────────────────── */
.dp-footer {
    background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
    color: #cbd5e1;
    padding: 0;
    margin-top: 60px;
    border-top: 3px solid #2563eb;
    font-family: var(--font-family, 'Sora', sans-serif);
}

.dp-footer-inner {
    display: grid;
    grid-template-columns: 1.4fr 1fr 1fr 1.2fr;
    gap: 40px;
    max-width: 1200px;
    margin: 0 auto;
    padding: 48px 32px 36px;
}

/* Brand column */
.dp-footer-brand { max-width: 280px; }

.dp-footer-logo {
    font-family: var(--font-display, 'Playfair Display', serif);
    font-size: 26px;
    font-weight: 800;
    background: linear-gradient(135deg, #60a5fa, #3b82f6);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    margin-bottom: 6px;
}

.dp-footer-logo span {
    display: block;
    font-family: var(--font-family, 'Sora', sans-serif);
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 2px;
    text-transform: uppercase;
    -webkit-text-fill-color: #64748b;
    margin-top: 2px;
}

.dp-footer-tagline {
    font-size: 13px;
    line-height: 1.7;
    color: #94a3b8;
    margin: 14px 0 18px;
}

.dp-footer-social {
    display: flex;
    gap: 10px;
}

.dp-footer-social a {
    width: 36px; height: 36px; border-radius: 10px;
    background: rgba(255,255,255,0.06);
    border: 1px solid rgba(255,255,255,0.08);
    display: flex; align-items: center; justify-content: center;
    color: #94a3b8; font-size: 15px;
    transition: all 0.25s; text-decoration: none;
}

.dp-footer-social a:hover {
    background: rgba(37,99,235,0.2);
    border-color: rgba(37,99,235,0.4);
    color: #60a5fa;
    transform: translateY(-2px);
}

/* Link columns */
.dp-footer-col h4 {
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    color: #f1f5f9;
    margin-bottom: 18px;
    position: relative;
    padding-bottom: 10px;
}

.dp-footer-col h4::after {
    content: '';
    position: absolute;
    bottom: 0; left: 0;
    width: 28px; height: 2px;
    background: linear-gradient(90deg, #2563eb, #3b82f6);
    border-radius: 2px;
}

.dp-footer-col ul {
    list-style: none;
    padding: 0;
    margin: 0;
}

.dp-footer-col ul li { margin-bottom: 10px; }

.dp-footer-col ul a {
    color: #94a3b8;
    text-decoration: none;
    font-size: 13px;
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.2s;
    padding: 4px 0;
}

.dp-footer-col ul a i { font-size: 14px; }

.dp-footer-col ul a:hover {
    color: #60a5fa;
    transform: translateX(4px);
}

/* Newsletter */
.dp-footer-newsletter-text {
    font-size: 13px;
    color: #94a3b8;
    line-height: 1.6;
    margin-bottom: 14px;
}

.dp-footer-newsletter {
    display: flex;
    border-radius: 10px;
    overflow: hidden;
    border: 1px solid rgba(255,255,255,0.1);
    background: rgba(255,255,255,0.04);
}

.dp-footer-newsletter input {
    flex: 1;
    padding: 10px 14px;
    background: transparent;
    border: none;
    outline: none;
    color: #e2e8f0;
    font-size: 13px;
    font-family: var(--font-family, 'Sora', sans-serif);
}

.dp-footer-newsletter input::placeholder { color: #64748b; }

.dp-footer-newsletter button {
    padding: 10px 16px;
    background: linear-gradient(135deg, #2563eb, #1e40af);
    border: none;
    color: #fff;
    cursor: pointer;
    font-size: 14px;
    transition: all 0.2s;
}

.dp-footer-newsletter button:hover {
    background: linear-gradient(135deg, #3b82f6, #2563eb);
}

/* Bottom bar */
.dp-footer-bottom {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 18px 32px;
    border-top: 1px solid rgba(255,255,255,0.06);
    font-size: 12px;
    color: #64748b;
    max-width: 1200px;
    margin: 0 auto;
}

.dp-footer-bottom-links {
    display: flex;
    gap: 18px;
}

.dp-footer-bottom-links a {
    color: #64748b;
    text-decoration: none;
    transition: color 0.2s;
}

.dp-footer-bottom-links a:hover { color: #60a5fa; }

@media (max-width: 900px) {
    .dp-footer-inner { grid-template-columns: 1fr 1fr; gap: 28px; }
}

@media (max-width: 550px) {
    .dp-footer-inner { grid-template-columns: 1fr; gap: 24px; }
    .dp-footer-bottom { flex-direction: column; gap: 8px; text-align: center; }
}
</style>
