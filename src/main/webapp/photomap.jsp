<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.DigiPic4.model.User" %>
<%
    User mapUser = (User) session.getAttribute("user");
    if (mapUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String mapRole = mapUser.getRole() == null ? "" : mapUser.getRole().trim();
    boolean mapIsAdmin = "admin".equalsIgnoreCase(mapRole);
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
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
    <!-- Leaflet CSS (free, open-source, no key needed) -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
    <style>
        :root { --font-serif: 'Cormorant Garamond', serif; --font-sans: 'Sora', sans-serif; }

        .page-content { max-width: 1400px; margin: 0 auto; padding: 0 24px 40px; }

        .section-header { margin-bottom: 22px; display:flex; justify-content:space-between; align-items:flex-end; flex-wrap:wrap; gap:14px; }
        .section-header-text h5 { color:#2563eb; font-size:12px; letter-spacing:1.5px; font-weight:700; text-transform:uppercase; margin-bottom:6px; }
        .section-header-text h1 { font-size:40px; margin:0; font-family:var(--font-serif); font-weight:700; color:#1e293b; }

        /* Layout */
        .map-layout { display:grid; grid-template-columns:1fr 340px; gap:24px; align-items:start; }
        @media(max-width:900px){ .map-layout { grid-template-columns:1fr; } }

        /* Map container */
        #photoMap {
            height:68vh; border-radius:18px; border:2px solid var(--border-color);
            box-shadow:0 4px 20px rgba(0,0,0,0.08); overflow:hidden;
        }

        /* Sidebar panel */
        .map-panel {
            background:var(--bg-surface); border:1px solid var(--border-color); border-radius:18px;
            padding:24px; box-shadow:0 2px 8px rgba(0,0,0,0.05); position:sticky; top:20px;
        }

        .map-panel h3 { font-family:var(--font-serif); font-size:22px; font-weight:700; color:#1e293b; margin:0 0 6px; }
        .map-panel .panel-sub { font-size:13px; color:#64748b; margin-bottom:20px; }

        /* Add pin form */
        .mfield { display:flex; flex-direction:column; margin-bottom:12px; }
        .mfield label { font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:#1e293b; margin-bottom:5px; }
        .mfield input, .mfield select {
            padding:10px 12px; border-radius:10px; border:1.5px solid var(--border-color);
            background:var(--bg-surface-light); font-size:13.5px; font-family:var(--font-sans);
            color:#1e293b; transition:border-color 0.2s;
        }
        .mfield input:focus, .mfield select:focus { outline:none; border-color:#2563eb; box-shadow:0 0 0 3px rgba(37,99,235,0.1); }

        .btn-add-pin {
            width:100%; padding:11px; background:linear-gradient(135deg,#2563eb,#1e40af); color:#fff;
            border:none; border-radius:10px; font-weight:700; cursor:pointer; font-family:var(--font-sans);
            display:flex; align-items:center; justify-content:center; gap:7px; transition:all 0.2s;
        }
        .btn-add-pin:hover { box-shadow:0 6px 18px rgba(37,99,235,0.3); transform:translateY(-1px); }

        .map-sep { height:1px; background:var(--border-color); margin:18px 0; }

        /* Pin list */
        .pin-list { max-height:200px; overflow-y:auto; }
        .pin-item {
            display:flex; align-items:center; gap:10px; padding:9px 0;
            border-bottom:1px solid var(--border-color); cursor:pointer; transition:background 0.15s;
            border-radius:6px; padding:8px 6px;
        }
        .pin-item:last-child { border-bottom:none; }
        .pin-item:hover { background:#f0f4f8; }
        .pin-thumb { width:40px; height:34px; border-radius:7px; object-fit:cover; flex-shrink:0; }
        .pin-thumb-ph { width:40px; height:34px; border-radius:7px; background:#eff6ff; display:flex; align-items:center; justify-content:center; color:#2563eb; font-size:16px; flex-shrink:0; }
        .pin-info-name { font-size:12.5px; font-weight:700; color:#1e293b; }
        .pin-info-loc { font-size:11px; color:#64748b; margin-top:2px; }
        .pin-del { margin-left:auto; background:none; border:none; cursor:pointer; color:#94a3b8; font-size:14px; padding:4px; border-radius:6px; transition:color 0.2s; flex-shrink:0; }
        .pin-del:hover { color:#ef4444; }

        /* Leaflet popup override */
        .leaflet-popup-content-wrapper { border-radius:12px !important; box-shadow:0 8px 24px rgba(0,0,0,0.15) !important; border:none !important; padding:0 !important; overflow:hidden; }
        .leaflet-popup-content { margin:0 !important; }
        .map-popup { width:200px; }
        .map-popup img { width:100%; height:120px; object-fit:cover; display:block; }
        .map-popup-body { padding:10px 12px 12px; }
        .map-popup-title { font-size:13px; font-weight:700; color:#1e293b; margin-bottom:4px; }
        .map-popup-loc { font-size:11px; color:#64748b; display:flex; align-items:center; gap:4px; }

        /* Status message */
        .map-status { text-align:center; color:#64748b; font-size:13px; padding:12px; }
        .tip-bar {
            background:#eff6ff; border:1px solid #dbeafe; border-radius:10px; padding:10px 14px;
            font-size:12px; color:#1e40af; margin-bottom:18px; display:flex; align-items:center; gap:8px;
        }
    </style>
</head>
<body>
    <jsp:include page='<%= mapIsAdmin ? "adminSidebar.jsp" : "sidebar.jsp" %>' />

    <main class="main-content">
        <jsp:include page='<%= mapIsAdmin ? "adminHeader.jsp" : "Header.jsp" %>' />

        <div class="page-content">
            <div class="section-header">
                <div class="section-header-text">
                    <h5>GEOLOCATION ARCHIVE</h5>
                    <h1>Photo Map</h1>
                </div>
            </div>

            <div class="map-layout">
                <!-- Map -->
                <div id="photoMap"></div>

                <!-- Panel -->
                <div class="map-panel">
                    <h3>Pin a Photo</h3>
                    <p class="panel-sub">Drop a location pin and attach a photo. Hover pins on the map to preview.</p>

                    <div class="tip-bar"><i class="bi bi-cursor-fill"></i> Click anywhere on the map to set coordinates automatically.</div>

                    <div class="mfield">
                        <label>Photo Title</label>
                        <input type="text" id="pinTitle" placeholder="e.g. Sunset at Pokhara">
                    </div>
                    <div class="mfield">
                        <label>Image URL (optional)</label>
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

                    <button class="btn-add-pin" onclick="addPin()">
                        <i class="bi bi-geo-alt-fill"></i> Add Pin to Map
                    </button>

                    <div class="map-sep"></div>

                    <div style="font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.8px; color:#94a3b8; margin-bottom:12px;">
                        <i class="bi bi-pin-map"></i> Pinned Locations (<span id="pinCount">0</span>)
                    </div>
                    <div class="pin-list" id="pinList">
                        <div class="map-status">No pins yet. Click the map or fill the form above.</div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Leaflet JS (free, no API key required) -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
    // ── Map init ─────────────────────────────────────────────────────
    const map = L.map('photoMap', { zoomControl: true }).setView([20, 0], 2);

    // Free OpenStreetMap tiles — no API key needed
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        maxZoom: 19
    }).addTo(map);

    let pins = JSON.parse(localStorage.getItem('digipic_map_pins') || '[]');
    const markers = {};

    // Custom pin icon
    function makeIcon(color) {
        return L.divIcon({
            className: '',
            html: `<div style="width:28px;height:28px;border-radius:50% 50% 50% 0;background:${color};border:3px solid #fff;box-shadow:0 4px 12px rgba(0,0,0,0.3);transform:rotate(-45deg);"></div>`,
            iconSize: [28, 28],
            iconAnchor: [14, 28],
            popupAnchor: [0, -30]
        });
    }

    function saveToStorage() { localStorage.setItem('digipic_map_pins', JSON.stringify(pins)); }

    // ── Add marker to map ─────────────────────────────────────────────
    function addMarkerToMap(pin) {
        const marker = L.marker([pin.lat, pin.lng], { icon: makeIcon('#2563eb') }).addTo(map);
        const imgTag = pin.imageUrl
            ? `<img src="${pin.imageUrl}" onerror="this.style.display='none'" style="width:100%;height:120px;object-fit:cover;display:block;">`
            : `<div style="width:100%;height:90px;background:#eff6ff;display:flex;align-items:center;justify-content:center;font-size:30px;">📸</div>`;
        const popupHtml = `
            <div class="map-popup">
                ${imgTag}
                <div class="map-popup-body">
                    <div class="map-popup-title">${pin.title}</div>
                    <div class="map-popup-loc"><i class="bi bi-geo-alt"></i>${pin.location || 'No location'}</div>
                    <div style="font-size:11px;color:#94a3b8;margin-top:4px;">${pin.lat.toFixed(4)}, ${pin.lng.toFixed(4)}</div>
                </div>
            </div>`;
        marker.bindPopup(popupHtml, { maxWidth: 220 });
        // Hover to show popup
        marker.on('mouseover', function() { this.openPopup(); });
        markers[pin.id] = marker;
    }

    // ── Render pin list ──────────────────────────────────────────────
    function renderPinList() {
        const list = document.getElementById('pinList');
        document.getElementById('pinCount').textContent = pins.length;
        if (!pins.length) {
            list.innerHTML = '<div class="map-status">No pins yet. Click the map or fill the form above.</div>';
            return;
        }
        list.innerHTML = pins.map((p, i) => `
            <div class="pin-item" onclick="flyToPin('${p.id}')">
                ${p.imageUrl ? `<img class="pin-thumb" src="${p.imageUrl}" onerror="this.style.display='none'">` : `<div class="pin-thumb-ph"><i class="bi bi-geo-alt-fill"></i></div>`}
                <div>
                    <div class="pin-info-name">${p.title}</div>
                    <div class="pin-info-loc"><i class="bi bi-geo-alt"></i> ${p.location || p.lat.toFixed(3)+', '+p.lng.toFixed(3)}</div>
                </div>
                <button class="pin-del" onclick="event.stopPropagation(); removePin(${i})" title="Remove pin"><i class="bi bi-trash3"></i></button>
            </div>`).join('');
    }

    function flyToPin(id) {
        const m = markers[id];
        if (!m) return;
        map.flyTo(m.getLatLng(), 12, { animate: true, duration: 1 });
        setTimeout(() => m.openPopup(), 900);
    }

    function removePin(idx) {
        const pin = pins[idx];
        if (markers[pin.id]) { markers[pin.id].remove(); delete markers[pin.id]; }
        pins.splice(idx, 1);
        saveToStorage();
        renderPinList();
    }

    // ── Add pin ──────────────────────────────────────────────────────
    function addPin() {
        const title    = document.getElementById('pinTitle').value.trim();
        const imageUrl = document.getElementById('pinImageUrl').value.trim();
        const lat      = parseFloat(document.getElementById('pinLat').value);
        const lng      = parseFloat(document.getElementById('pinLng').value);
        const location = document.getElementById('pinLocation').value.trim();

        if (!title) { alert('Please enter a photo title.'); return; }
        if (isNaN(lat) || isNaN(lng)) { alert('Please enter valid coordinates (or click the map to auto-fill).'); return; }

        const pin = { id: Date.now().toString(), title, imageUrl, lat, lng, location };
        pins.push(pin);
        saveToStorage();
        addMarkerToMap(pin);
        renderPinList();
        map.flyTo([lat, lng], 10, { animate: true, duration: 1.2 });

        // Clear form
        ['pinTitle','pinImageUrl','pinLat','pinLng','pinLocation'].forEach(id => {
            document.getElementById(id).value = '';
        });
    }

    // ── Click map to set coordinates ─────────────────────────────────
    map.on('click', function(e) {
        document.getElementById('pinLat').value = e.latlng.lat.toFixed(6);
        document.getElementById('pinLng').value = e.latlng.lng.toFixed(6);
        // Try reverse geocode via free Nominatim API
        fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${e.latlng.lat}&lon=${e.latlng.lng}`)
            .then(r => r.json())
            .then(d => {
                if (d && d.display_name) {
                    const short = d.address
                        ? [d.address.city || d.address.town || d.address.village, d.address.country].filter(Boolean).join(', ')
                        : d.display_name.split(',').slice(0,2).join(',');
                    document.getElementById('pinLocation').value = short;
                }
            }).catch(() => {});
    });

    // ── Load stored pins ─────────────────────────────────────────────
    pins.forEach(addMarkerToMap);
    renderPinList();

    // ── Pre-seeded demo pins (shown on first load) ────────────────────
    if (!pins.length) {
        const demos = [
            { id:'d1', title:'Phewa Lake, Pokhara', imageUrl:'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=400&q=80', lat:28.2096, lng:83.9856, location:'Pokhara, Nepal' },
            { id:'d2', title:'Eiffel Tower at Dusk', imageUrl:'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=400&q=80', lat:48.8584, lng:2.2945, location:'Paris, France' },
            { id:'d3', title:'Great Barrier Reef', imageUrl:'https://images.unsplash.com/photo-1516426122078-c23e76319801?w=400&q=80', lat:-18.2871, lng:147.6992, location:'Queensland, Australia' },
        ];
        demos.forEach(p => { pins.push(p); addMarkerToMap(p); });
        saveToStorage();
        renderPinList();
    }
    </script>
</body>
</html>
