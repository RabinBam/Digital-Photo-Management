<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.DigiPic4.model.User, com.DigiPic4.model.Photo, com.DigiPic4.dao.PhotoDAO" %>
<%@ page import="java.util.List" %>
<%
    User mapUser = (User) session.getAttribute("user");
    if (mapUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String mapRole = mapUser.getRole() == null ? "" : mapUser.getRole().trim();
    boolean mapIsAdmin = "admin".equalsIgnoreCase(mapRole);
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Load all user photos that have a location_tag set
    PhotoDAO photoDAO = new PhotoDAO();
    List<Photo> allPhotos = photoDAO.findPhotosByUserId(mapUser.getUserId());

    // Build JSON array of photos that have location_tag
    StringBuilder geoPhotosJson = new StringBuilder("[");
    boolean first = true;
    for (Photo ph : allPhotos) {
        String loc = ph.getLocationTag();
        if (loc == null || loc.trim().isEmpty()) continue;
        String title = ph.getTitle() != null && !ph.getTitle().isEmpty() ? ph.getTitle() : ph.getFilePath();
        String src = request.getContextPath() + "/uploads/" + mapUser.getUserId() + "/" + ph.getFilePath();
        // Check if src looks like an external URL (starts with http)
        if (ph.getFilePath() != null && (ph.getFilePath().startsWith("http://") || ph.getFilePath().startsWith("https://"))) {
            src = ph.getFilePath();
        }
        if (!first) geoPhotosJson.append(",");
        first = false;
        geoPhotosJson.append("{")
            .append("\"photoId\":").append(ph.getPhotoId()).append(",")
            .append("\"title\":\"").append(title.replace("\"","\\\"").replace("\\","\\\\")).append("\",")
            .append("\"src\":\"").append(src.replace("\"","\\\"")).append("\",")
            .append("\"location\":\"").append(loc.replace("\"","\\\"").replace("\\","\\\\")).append("\"")
            .append("}");
    }
    geoPhotosJson.append("]");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Photo Map – DigiPic</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style-light.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar-light.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Sora:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.css">

    <style>
        :root { --font-serif: 'Cormorant Garamond', serif; --font-sans: 'Sora', sans-serif; }

        .page-content { max-width: 1500px; margin: 0 auto; padding: 0 24px 40px; }

        .section-header {
            margin-bottom: 18px;
            display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 12px;
        }
        .section-header-text h5 { color:#2563eb; font-size:12px; letter-spacing:1.5px; font-weight:700; text-transform:uppercase; margin-bottom:6px; }
        .section-header-text h1 { font-size:38px; margin:0; font-family:var(--font-serif); font-weight:700; color:#1e293b; }

        /* Stats strip */
        .map-stats { display:flex; gap:10px; flex-wrap:wrap; }
        .map-stat {
            background:var(--bg-surface); border:1px solid var(--border-color);
            border-radius:10px; padding:10px 16px; font-size:12px; color:#64748b;
            display:flex; align-items:center; gap:6px;
        }
        .map-stat strong { color:#1e293b; font-size:15px; }

        /* Layout */
        .map-layout { display:grid; grid-template-columns:1fr 360px; gap:22px; align-items:start; }
        @media(max-width:960px){ .map-layout { grid-template-columns:1fr; } }

        /* Map */
        #photoMap {
            height:72vh; border-radius:18px;
            border:2px solid var(--border-color);
            box-shadow:0 6px 24px rgba(0,0,0,0.08); overflow:hidden;
        }

        /* Panel */
        .map-panel {
            background:var(--bg-surface); border:1px solid var(--border-color);
            border-radius:18px; overflow:hidden;
            box-shadow:0 2px 8px rgba(0,0,0,0.05); position:sticky; top:20px;
            max-height: 72vh; display:flex; flex-direction:column;
        }

        /* Panel tabs */
        .panel-tabs {
            display:flex; border-bottom:1px solid var(--border-color);
        }
        .panel-tab {
            flex:1; padding:12px 8px; border:none; background:none; cursor:pointer;
            font-size:12px; font-weight:700; color:#64748b; text-transform:uppercase;
            letter-spacing:0.5px; transition:all 0.2s;
            border-bottom: 2.5px solid transparent;
            display:flex; align-items:center; justify-content:center; gap:5px;
        }
        .panel-tab.active { color:#2563eb; border-bottom-color:#2563eb; background:#f8faff; }
        .panel-tab:hover { color:#2563eb; }

        /* Panel body */
        .panel-body { padding:20px; overflow-y:auto; flex:1; }

        /* Form fields */
        .mfield { display:flex; flex-direction:column; margin-bottom:10px; }
        .mfield label { font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:#1e293b; margin-bottom:5px; }
        .mfield input, .mfield select {
            padding:9px 12px; border-radius:10px; border:1.5px solid var(--border-color);
            background:var(--bg-surface-light); font-size:13px; font-family:var(--font-sans);
            color:#1e293b; transition:border-color 0.2s;
        }
        .mfield input:focus, .mfield select:focus { outline:none; border-color:#2563eb; box-shadow:0 0 0 3px rgba(37,99,235,0.1); }

        .btn-add-pin {
            width:100%; padding:11px; background:linear-gradient(135deg,#2563eb,#1e40af); color:#fff;
            border:none; border-radius:10px; font-weight:700; cursor:pointer; font-family:var(--font-sans);
            display:flex; align-items:center; justify-content:center; gap:7px; transition:all 0.2s;
            margin-top:4px;
        }
        .btn-add-pin:hover { box-shadow:0 6px 18px rgba(37,99,235,0.3); transform:translateY(-1px); }

        /* Tip bar */
        .tip-bar {
            background:#eff6ff; border:1px solid #dbeafe; border-radius:10px;
            padding:9px 12px; font-size:11.5px; color:#1e40af; margin-bottom:14px;
            display:flex; align-items:center; gap:7px;
        }

        /* Pin list */
        .pin-list { display:flex; flex-direction:column; gap:2px; }
        .pin-item {
            display:flex; align-items:center; gap:10px; padding:9px 8px;
            border-radius:9px; cursor:pointer; transition:background 0.15s;
        }
        .pin-item:hover { background:#f0f4f8; }
        .pin-thumb { width:42px; height:34px; border-radius:7px; object-fit:cover; flex-shrink:0; }
        .pin-thumb-ph {
            width:42px; height:34px; border-radius:7px; flex-shrink:0;
            display:flex; align-items:center; justify-content:center; font-size:18px;
        }
        .pin-thumb-ph.gallery { background:#dbeafe; color:#2563eb; }
        .pin-thumb-ph.custom  { background:#ede9fe; color:#7c3aed; }
        .pin-info-name { font-size:12.5px; font-weight:700; color:#1e293b; line-height:1.3; }
        .pin-info-loc  { font-size:11px; color:#64748b; margin-top:2px; }
        .pin-badge {
            font-size:9px; font-weight:800; padding:2px 6px; border-radius:10px;
            text-transform:uppercase; letter-spacing:0.5px; flex-shrink:0;
        }
        .pin-badge.gallery { background:#dbeafe; color:#1e40af; }
        .pin-badge.custom  { background:#ede9fe; color:#6d28d9; }
        .pin-del { margin-left:auto; background:none; border:none; cursor:pointer; color:#94a3b8; font-size:14px; padding:4px; border-radius:6px; transition:color 0.2s; flex-shrink:0; }
        .pin-del:hover { color:#ef4444; }

        /* Section label */
        .pin-section-label {
            font-size:10px; font-weight:800; text-transform:uppercase; letter-spacing:1px;
            color:#94a3b8; padding:10px 8px 4px; margin-top:6px;
        }

        /* Empty state */
        .map-empty { text-align:center; color:#94a3b8; padding:24px 12px; }
        .map-empty i { font-size:32px; display:block; margin-bottom:8px; }

        /* Geocode status */
        .geocode-status {
            font-size:11px; color:#64748b; padding:5px 0; min-height:18px;
            display:flex; align-items:center; gap:5px;
        }

        /* Leaflet popup */
        .leaflet-popup-content-wrapper {
            border-radius:14px !important; box-shadow:0 8px 28px rgba(0,0,0,0.15) !important;
            border:none !important; padding:0 !important; overflow:hidden;
        }
        .leaflet-popup-content { margin:0 !important; }
        .map-popup { width:210px; }
        .map-popup img { width:100%; height:130px; object-fit:cover; display:block; }
        .map-popup-ph { width:100%; height:90px; background:#eff6ff; display:flex; align-items:center; justify-content:center; font-size:32px; }
        .map-popup-body { padding:10px 12px 13px; }
        .map-popup-title { font-size:13px; font-weight:700; color:#1e293b; margin-bottom:5px; }
        .map-popup-loc { font-size:11px; color:#64748b; display:flex; align-items:center; gap:4px; margin-bottom:4px; }
        .map-popup-badge { font-size:10px; font-weight:700; padding:2px 8px; border-radius:10px; }
        .map-popup-badge.gallery { background:#dbeafe; color:#1e40af; }
        .map-popup-badge.custom  { background:#ede9fe; color:#6d28d9; }
    </style>
</head>
<body>
<jsp:include page='<%= mapIsAdmin ? "../components/adminSidebar.jsp" : "../components/sidebar.jsp" %>' />

    <main class="main-content">
    <jsp:include page='<%= mapIsAdmin ? "../components/adminHeader.jsp" : "../components/Header.jsp" %>' />

        <div class="page-content">
            <div class="section-header">
                <div class="section-header-text">
                    <h5>GEOLOCATION ARCHIVE</h5>
                    <h1>Photo Map</h1>
                </div>
                <div class="map-stats">
                    <div class="map-stat">
                        <i class="bi bi-images" style="color:#2563eb;"></i>
                        Gallery pins: <strong id="galleryPinCount">—</strong>
                    </div>
                    <div class="map-stat">
                        <i class="bi bi-geo-alt-fill" style="color:#7c3aed;"></i>
                        Custom pins: <strong id="customPinCount">—</strong>
                    </div>
                </div>
            </div>

            <div class="map-layout">
                <!-- Map -->
                <div id="photoMap"></div>

                <!-- Panel -->
                <div class="map-panel">
                    <div class="panel-tabs">
                        <button class="panel-tab active" id="tabAdd" onclick="switchPanelTab('add')">
                            <i class="bi bi-plus-circle"></i> Add Pin
                        </button>
                        <button class="panel-tab" id="tabPins" onclick="switchPanelTab('pins')">
                            <i class="bi bi-pin-map"></i> All Pins
                        </button>
                    </div>

                    <!-- ADD PIN tab -->
                    <div class="panel-body" id="bodyAdd">
                        <div class="tip-bar">
                            <i class="bi bi-cursor-fill"></i>
                            Click anywhere on the map to auto-fill coordinates &amp; location.
                        </div>

                        <div class="mfield">
                            <label>Photo Title *</label>
                            <input type="text" id="pinTitle" placeholder="e.g. Sunset at Pokhara">
                        </div>

                        <div class="mfield">
                            <label>Photo from Gallery</label>
                            <select id="pinGalleryPhoto">
                                <option value="">— Paste URL below instead —</option>
                                <% for (Photo ph : allPhotos) {
                                    String t = ph.getTitle() != null && !ph.getTitle().isEmpty() ? ph.getTitle() : ph.getFilePath();
                                    String s = ph.getFilePath() != null && (ph.getFilePath().startsWith("http://") || ph.getFilePath().startsWith("https://"))
                                               ? ph.getFilePath()
                                               : request.getContextPath() + "/uploads/" + mapUser.getUserId() + "/" + ph.getFilePath();
                                %>
                                    <option value="<%= s %>"><%= t %></option>
                                <% } %>
                            </select>
                        </div>

                        <div class="mfield">
                            <label>Or Image URL</label>
                            <input type="url" id="pinImageUrl" placeholder="https://…">
                        </div>

                        <div class="mfield">
                            <label>Latitude</label>
                            <input type="number" id="pinLat" placeholder="e.g. 27.9881" step="any">
                        </div>
                        <div class="mfield">
                            <label>Longitude</label>
                            <input type="number" id="pinLng" placeholder="e.g. 86.9250" step="any">
                        </div>
                        <div class="mfield">
                            <label>Location Name</label>
                            <input type="text" id="pinLocation" placeholder="e.g. Annapurna, Nepal">
                        </div>
                        <div class="geocode-status" id="geocodeStatus"></div>

                        <button class="btn-add-pin" onclick="addCustomPin()">
                            <i class="bi bi-geo-alt-fill"></i> Drop Pin on Map
                        </button>
                    </div>

                    <!-- ALL PINS tab -->
                    <div class="panel-body" id="bodyPins" style="display:none;">
                        <div class="pin-list" id="allPinsList">
                            <div class="map-empty">
                                <i class="bi bi-pin-map"></i>
                                Loading pins…
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script>
    // ── Gallery photos with location_tag (injected server-side) ──────────────
    const GEO_PHOTOS = <%= geoPhotosJson %>;

    // ── Custom pins stored in localStorage ──────────────────────────────────
    let customPins = [];
    try { customPins = JSON.parse(localStorage.getItem('digipic_map_pins') || '[]'); } catch(e) { customPins = []; }

    // ── Map & marker storage ─────────────────────────────────────────────────
    let map = null;
    const markers = {};   // id → Leaflet marker

    // ── Panel tab switch ─────────────────────────────────────────────────────
    function switchPanelTab(tab) {
        document.getElementById('tabAdd').classList.toggle('active', tab === 'add');
        document.getElementById('tabPins').classList.toggle('active', tab === 'pins');
        document.getElementById('bodyAdd').style.display  = tab === 'add'  ? '' : 'none';
        document.getElementById('bodyPins').style.display = tab === 'pins' ? '' : 'none';
        if (tab === 'pins') renderPinList();
    }

    // ── Helpers ──────────────────────────────────────────────────────────────
    function esc(s) {
        return String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    }
    function saveCustom() { localStorage.setItem('digipic_map_pins', JSON.stringify(customPins)); }
    function updateCounts() {
        document.getElementById('galleryPinCount').textContent = GEO_PHOTOS.length;
        document.getElementById('customPinCount').textContent  = customPins.length;
    }

    // ── Icon factory ─────────────────────────────────────────────────────────
    function makeIcon(color, emoji) {
        return L.divIcon({
            className: '',
            html: `<div style="position:relative;width:32px;height:32px;">
                     <div style="width:32px;height:32px;border-radius:50% 50% 50% 0;background:${color};border:3px solid #fff;box-shadow:0 4px 14px rgba(0,0,0,0.3);transform:rotate(-45deg);"></div>
                     <span style="position:absolute;top:3px;left:6px;font-size:13px;transform:rotate(45deg);">${emoji}</span>
                   </div>`,
            iconSize: [32, 32], iconAnchor: [16, 32], popupAnchor: [0, -34]
        });
    }

    // ── Build popup HTML ─────────────────────────────────────────────────────
    function buildPopup(title, location, src, badgeClass, badgeLabel, lat, lng) {
        const imgHtml = src
            ? `<img src="${esc(src)}" onerror="this.style.display='none'; this.nextSibling.style.display='flex';" style="width:100%;height:130px;object-fit:cover;display:block;">
               <div class="map-popup-ph" style="display:none;">📸</div>`
            : `<div class="map-popup-ph">📸</div>`;
        return `<div class="map-popup">
                  ${imgHtml}
                  <div class="map-popup-body">
                    <div class="map-popup-title">${esc(title)}</div>
                    <div class="map-popup-loc"><i class="bi bi-geo-alt"></i>${esc(location || 'Unknown location')}</div>
                    <span class="map-popup-badge ${badgeClass}">${badgeLabel}</span>
                  </div>
                </div>`;
    }

    // ── Geocode a location string → [lat, lng] via Nominatim ────────────────
    async function geocodeLocation(query) {
        try {
            const r = await fetch(
                `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=1`,
                { headers: { 'Accept': 'application/json' }, referrerPolicy: 'no-referrer' }
            );
            const data = await r.json();
            if (data && data.length > 0) {
                return [parseFloat(data[0].lat), parseFloat(data[0].lon)];
            }
        } catch(e) {}
        return null;
    }

    // ── Reverse geocode ──────────────────────────────────────────────────────
    async function reverseGeocode(lat, lng) {
        try {
            const r = await fetch(
                `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}`,
                { headers: { 'Accept': 'application/json' }, referrerPolicy: 'no-referrer' }
            );
            const d = await r.json();
            if (d && d.address) {
                return [d.address.city||d.address.town||d.address.village||'', d.address.country||'']
                    .filter(Boolean).join(', ');
            }
        } catch(e) {}
        return '';
    }

    // ── Add a gallery photo pin (geocoded from location_tag) ─────────────────
    async function addGalleryPin(photo) {
        const coords = await geocodeLocation(photo.location);
        if (!coords) {
            console.warn('Could not geocode:', photo.location);
            return;
        }
        const id = 'gallery_' + photo.photoId;
        const marker = L.marker(coords, { icon: makeIcon('#2563eb', '🖼') }).addTo(map);
        marker.bindPopup(buildPopup(photo.title, photo.location, photo.src, 'gallery', 'Gallery', coords[0], coords[1]),
                         { maxWidth: 230 });
        marker.on('mouseover', function() { this.openPopup(); });
        markers[id] = marker;
    }

    // ── Add a custom pin ─────────────────────────────────────────────────────
    function addCustomPinToMap(pin) {
        const marker = L.marker([pin.lat, pin.lng], { icon: makeIcon('#7c3aed', '📍') }).addTo(map);
        marker.bindPopup(buildPopup(pin.title, pin.location, pin.imageUrl, 'custom', 'Custom', pin.lat, pin.lng),
                         { maxWidth: 230 });
        marker.on('mouseover', function() { this.openPopup(); });
        markers[pin.id] = marker;
    }

    // ── Add custom pin (from form) ────────────────────────────────────────────
    async function addCustomPin() {
        const title    = document.getElementById('pinTitle').value.trim();
        const gallSrc  = document.getElementById('pinGalleryPhoto').value;
        const urlSrc   = document.getElementById('pinImageUrl').value.trim();
        const latVal   = document.getElementById('pinLat').value;
        const lngVal   = document.getElementById('pinLng').value;
        const location = document.getElementById('pinLocation').value.trim();

        if (!title) { alert('Please enter a photo title.'); return; }

        let lat = parseFloat(latVal);
        let lng = parseFloat(lngVal);

        // If no coords but we have a location string, try geocoding it
        if ((isNaN(lat) || isNaN(lng)) && location) {
            document.getElementById('geocodeStatus').innerHTML =
                '<i class="bi bi-arrow-repeat" style="animation:spin 1s linear infinite;"></i> Locating…';
            const coords = await geocodeLocation(location);
            if (coords) { lat = coords[0]; lng = coords[1]; }
            document.getElementById('geocodeStatus').innerHTML = '';
        }

        if (isNaN(lat) || isNaN(lng)) {
            alert('Please enter coordinates or a recognisable location name (so it can be geocoded).');
            return;
        }

        const imageUrl = gallSrc || urlSrc || '';
        const pin = {
            id: 'custom_' + Date.now(),
            title, imageUrl, lat, lng,
            location: location || (lat.toFixed(3) + ', ' + lng.toFixed(3))
        };
        customPins.push(pin);
        saveCustom();
        addCustomPinToMap(pin);
        map.flyTo([lat, lng], 12, { animate: true, duration: 1.2 });
        updateCounts();

        // Clear form
        ['pinTitle','pinImageUrl','pinLat','pinLng','pinLocation'].forEach(id => {
            document.getElementById(id).value = '';
        });
        document.getElementById('pinGalleryPhoto').value = '';
    }

    // ── Remove custom pin ─────────────────────────────────────────────────────
    function removeCustomPin(id) {
        customPins = customPins.filter(p => p.id !== id);
        saveCustom();
        if (markers[id]) { markers[id].remove(); delete markers[id]; }
        updateCounts();
        renderPinList();
    }

    // ── Fly to any pin ────────────────────────────────────────────────────────
    function flyToPin(id) {
        const m = markers[id];
        if (!m || !map) return;
        map.flyTo(m.getLatLng(), 13, { animate: true, duration: 1 });
        setTimeout(() => m.openPopup(), 900);
    }

    // ── Render combined pin list ───────────────────────────────────────────────
    function renderPinList() {
        const list = document.getElementById('allPinsList');
        let html = '';

        // Gallery pins
        if (GEO_PHOTOS.length > 0) {
            html += `<div class="pin-section-label"><i class="bi bi-images"></i> From Your Gallery (${GEO_PHOTOS.length})</div>`;
            GEO_PHOTOS.forEach(photo => {
                const id = 'gallery_' + photo.photoId;
                html += `<div class="pin-item" onclick="flyToPin('${esc(id)}')">
                    <img class="pin-thumb" src="${esc(photo.src)}" onerror="this.style.display='none'">
                    <div style="flex:1;min-width:0;">
                        <div class="pin-info-name">${esc(photo.title)}</div>
                        <div class="pin-info-loc"><i class="bi bi-geo-alt"></i> ${esc(photo.location)}</div>
                    </div>
                    <span class="pin-badge gallery">Gallery</span>
                </div>`;
            });
        }

        // Custom pins
        if (customPins.length > 0) {
            html += `<div class="pin-section-label"><i class="bi bi-geo-alt-fill"></i> Custom Pins (${customPins.length})</div>`;
            customPins.forEach(pin => {
                const imgHtml = pin.imageUrl
                    ? `<img class="pin-thumb" src="${esc(pin.imageUrl)}" onerror="this.style.display='none'">`
                    : `<div class="pin-thumb-ph custom"><i class="bi bi-geo-alt-fill"></i></div>`;
                html += `<div class="pin-item" onclick="flyToPin('${esc(pin.id)}')">
                    ${imgHtml}
                    <div style="flex:1;min-width:0;">
                        <div class="pin-info-name">${esc(pin.title)}</div>
                        <div class="pin-info-loc"><i class="bi bi-geo-alt"></i> ${esc(pin.location)}</div>
                    </div>
                    <span class="pin-badge custom">Custom</span>
                    <button class="pin-del" onclick="event.stopPropagation(); removeCustomPin('${esc(pin.id)}')" title="Remove">
                        <i class="bi bi-trash3"></i>
                    </button>
                </div>`;
            });
        }

        if (!html) {
            html = `<div class="map-empty">
                        <i class="bi bi-pin-map"></i>
                        <p>No pins yet.<br>Tag photos with a location in your gallery, or add custom pins from the Add Pin tab.</p>
                    </div>`;
        }
        list.innerHTML = html;
    }

    // ── Map init ─────────────────────────────────────────────────────────────
    function initMap() {
        if (!window.L) {
            document.getElementById('photoMap').innerHTML =
                '<div style="display:flex;align-items:center;justify-content:center;height:100%;color:#64748b;font-size:14px;padding:24px;text-align:center;">Map could not load — Leaflet library unavailable.</div>';
            return;
        }

        map = L.map('photoMap', { zoomControl: true }).setView([20, 0], 2);

        // Free OpenStreetMap tiles — no API key needed
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
            maxZoom: 19
        }).addTo(map);

        // Click on map → auto-fill coordinates + reverse geocode
        map.on('click', async function(e) {
            document.getElementById('pinLat').value = e.latlng.lat.toFixed(6);
            document.getElementById('pinLng').value = e.latlng.lng.toFixed(6);
            document.getElementById('geocodeStatus').innerHTML =
                '<i class="bi bi-arrow-repeat"></i> Looking up location…';
            const name = await reverseGeocode(e.latlng.lat, e.latlng.lng);
            if (name) document.getElementById('pinLocation').value = name;
            document.getElementById('geocodeStatus').innerHTML = name
                ? `<i class="bi bi-check-circle" style="color:#16a34a;"></i> ${esc(name)}`
                : '';
        });

        // Load custom pins
        customPins.forEach(addCustomPinToMap);

        // Load gallery pins (async geocoding per pin)
        const geocodeQueue = [...GEO_PHOTOS];
        async function processQueue() {
            for (const photo of geocodeQueue) {
                await addGalleryPin(photo);
                await new Promise(r => setTimeout(r, 220)); // rate-limit Nominatim (1 req/sec rule)
            }
            renderPinList();
        }
        processQueue();

        // Demo pins only when BOTH lists are empty
        if (GEO_PHOTOS.length === 0 && customPins.length === 0) {
            const demos = [
                { id:'demo_1', title:'Phewa Lake, Pokhara', imageUrl:'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=400&q=80', lat:28.2096, lng:83.9856, location:'Pokhara, Nepal' },
                { id:'demo_2', title:'Eiffel Tower at Dusk',  imageUrl:'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=400&q=80', lat:48.8584, lng:2.2945,  location:'Paris, France' },
                { id:'demo_3', title:'Great Barrier Reef',    imageUrl:'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=400&q=80', lat:-18.2871, lng:147.6992, location:'Queensland, Australia' },
            ];
            demos.forEach(p => { customPins.push(p); addCustomPinToMap(p); });
            saveCustom();
            renderPinList();
        }

        updateCounts();
    }

    // ── Spin animation for loading indicator ──────────────────────────────────
    const spinStyle = document.createElement('style');
    spinStyle.textContent = '@keyframes spin { to { transform: rotate(360deg); } }';
    document.head.appendChild(spinStyle);

    // ── Gallery photo selector auto-fills title ───────────────────────────────
    document.getElementById('pinGalleryPhoto').addEventListener('change', function() {
        // Auto-fill title from selected option text if title is empty
        const sel = this.options[this.selectedIndex];
        const titleInput = document.getElementById('pinTitle');
        if (this.value && !titleInput.value) {
            titleInput.value = sel.text;
        }
    });

    // ── Boot ──────────────────────────────────────────────────────────────────
    function boot() {
        if (window.L) { initMap(); return; }
        const s = document.createElement('script');
        s.src = 'https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.js';
        s.onload = initMap;
        s.onerror = () => {
            // fallback CDN
            const s2 = document.createElement('script');
            s2.src = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js';
            s2.onload = initMap;
            document.head.appendChild(s2);
        };
        document.head.appendChild(s);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }
    </script>
</body>
</html>
