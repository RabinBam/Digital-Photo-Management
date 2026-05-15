<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, com.DigiPic4.dao.DBConnection, com.DigiPic4.model.User" %>
<!DOCTYPE html>
<html>
<head><title>DigiPic - Full Pipeline Test</title>
<style>
    body { font-family: 'Segoe UI', sans-serif; padding: 30px; background: #f8fafc; }
    .card { background: white; border-radius: 12px; padding: 20px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    .card h2 { margin-top: 0; color: #1e293b; border-bottom: 2px solid #e2e8f0; padding-bottom: 8px; }
    .ok { color: #16a34a; font-weight: bold; }
    .fail { color: #dc2626; font-weight: bold; }
    .warn { color: #f59e0b; font-weight: bold; }
    table { border-collapse: collapse; width: 100%; margin: 10px 0; }
    th, td { text-align: left; padding: 8px 12px; border: 1px solid #e2e8f0; font-size: 13px; }
    th { background: #f1f5f9; }
    .test-form { display: flex; gap: 10px; align-items: center; margin: 10px 0; }
    .test-form input[type=file] { padding: 8px; }
    .test-form button { background: #2563eb; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: bold; }
    .img-preview { max-width: 100px; max-height: 80px; border-radius: 6px; }
</style>
</head>
<body>
<h1>🔍 DigiPic Full Pipeline Diagnostic</h1>

<%
    User currentUser = (User) session.getAttribute("user");
%>

<!-- 1. SESSION CHECK -->
<div class="card">
    <h2>1. Session & Authentication</h2>
    <% if (currentUser == null) { %>
        <p class="fail">❌ NOT LOGGED IN - Please login first at <a href="<%= request.getContextPath() %>/login">/login</a></p>
    <% } else { %>
        <p class="ok">✅ Logged in as: <b><%= currentUser.getEmail() %></b> (ID: <%= currentUser.getUserId() %>)</p>
        <p>Credits (session): <b><%= currentUser.getCredits() %></b></p>
        <%
            // Check live credits from DB
            try (Connection c = DBConnection.getConnection();
                 PreparedStatement ps = c.prepareStatement("SELECT credits FROM users WHERE user_id=?")) {
                ps.setInt(1, currentUser.getUserId());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    out.println("<p>Credits (DB live): <b>" + rs.getInt("credits") + "</b></p>");
                }
            } catch (Exception e) {
                out.println("<p class='fail'>DB Error: " + e.getMessage() + "</p>");
            }
        %>
    <% } %>
</div>

<!-- 2. STORAGE CHECK -->
<div class="card">
    <h2>2. File Storage (C:/DigiPicStorage/images)</h2>
    <%
        File storageRoot = new File("C:/DigiPicStorage/images");
        if (!storageRoot.exists()) {
            out.println("<p class='fail'>❌ Directory does NOT exist</p>");
            storageRoot.mkdirs();
            out.println("<p class='warn'>⚠ Created directory</p>");
        } else {
            out.println("<p class='ok'>✅ Directory exists</p>");
        }
        out.println("<p>Writable: <b>" + storageRoot.canWrite() + "</b></p>");
        
        // List all files recursively
        int fileCount = 0;
        StringBuilder fileList = new StringBuilder();
        listFilesRecursive(storageRoot, storageRoot, fileList);
        String files = fileList.toString();
        if (files.isEmpty()) {
            out.println("<p class='warn'>⚠ Directory is EMPTY - no uploaded files</p>");
        } else {
            out.println("<p class='ok'>Files found:</p><pre>" + files + "</pre>");
        }
    %>
    <%!
        void listFilesRecursive(File root, File dir, StringBuilder sb) {
            File[] children = dir.listFiles();
            if (children == null) return;
            for (File f : children) {
                String rel = f.getAbsolutePath().substring(root.getAbsolutePath().length());
                if (f.isDirectory()) {
                    sb.append("📁 " + rel + "/\n");
                    listFilesRecursive(root, f, sb);
                } else {
                    sb.append("📄 " + rel + " [" + f.length() + " bytes]\n");
                }
            }
        }
    %>
</div>

<!-- 3. DATABASE TABLES -->
<div class="card">
    <h2>3. Database State</h2>
    
    <h3>Albums</h3>
    <table>
    <%
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM albums ORDER BY album_id DESC LIMIT 15")) {
            ResultSetMetaData md = rs.getMetaData();
            int cols = md.getColumnCount();
            out.println("<tr>");
            for (int i = 1; i <= cols; i++) out.println("<th>" + md.getColumnName(i) + "</th>");
            out.println("</tr>");
            int rowCount = 0;
            while (rs.next()) {
                rowCount++;
                out.println("<tr>");
                for (int i = 1; i <= cols; i++) out.println("<td>" + rs.getString(i) + "</td>");
                out.println("</tr>");
            }
            if (rowCount == 0) out.println("<tr><td colspan='" + cols + "' class='warn'>NO ALBUMS</td></tr>");
        } catch (Exception e) { out.println("<tr><td class='fail'>ERROR: " + e.getMessage() + "</td></tr>"); }
    %>
    </table>
    
    <h3>Photos</h3>
    <table>
    <%
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM photos ORDER BY photo_id DESC LIMIT 15")) {
            ResultSetMetaData md = rs.getMetaData();
            int cols = md.getColumnCount();
            out.println("<tr>");
            for (int i = 1; i <= cols; i++) out.println("<th>" + md.getColumnName(i) + "</th>");
            out.println("</tr>");
            int rowCount = 0;
            while (rs.next()) {
                rowCount++;
                out.println("<tr>");
                for (int i = 1; i <= cols; i++) {
                    String val = rs.getString(i);
                    out.println("<td>" + (val != null ? val : "null") + "</td>");
                }
                out.println("</tr>");
            }
            if (rowCount == 0) out.println("<tr><td colspan='" + cols + "' class='warn'>NO PHOTOS</td></tr>");
        } catch (Exception e) { out.println("<tr><td class='fail'>ERROR: " + e.getMessage() + "</td></tr>"); }
    %>
    </table>
    
    <h3>Photo File Verification</h3>
    <table>
        <tr><th>photo_id</th><th>file_path (DB)</th><th>File on Disk?</th><th>Image Serve URL</th><th>Preview</th></tr>
    <%
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT photo_id, file_path FROM photos ORDER BY photo_id DESC LIMIT 15")) {
            while (rs.next()) {
                int pid = rs.getInt("photo_id");
                String fp = rs.getString("file_path");
                File onDisk = new File("C:/DigiPicStorage/images", fp != null ? fp : "");
                boolean exists = onDisk.exists() && onDisk.isFile();
                String serveUrl = request.getContextPath() + "/image-serve/" + fp;
                out.println("<tr>");
                out.println("<td>" + pid + "</td>");
                
                java.util.List<String> uploadErrors = (java.util.List<String>) session.getAttribute("uploadErrors");
                if (uploadErrors != null && !uploadErrors.isEmpty()) {
                    out.println("<div style='margin-top: 15px; padding: 10px; background: #fee2e2; border: 1px solid #ef4444; border-radius: 6px;'>");
                    out.println("<h3 style='margin-top: 0; color: #b91c1c;'>Recent Upload Errors:</h3><ul>");
                    for (String err : uploadErrors) {
                        out.println("<li style='color: #991b1b;'>" + err + "</li>");
                    }
                    out.println("</ul></div>");
                }
                
                out.println("<td>" + fp + "</td>");
                out.println("<td class='" + (exists ? "ok" : "fail") + "'>" + (exists ? "✅ YES (" + onDisk.length() + " bytes)" : "❌ NO") + "</td>");
                out.println("<td><a href='" + serveUrl + "' target='_blank'>" + serveUrl + "</a></td>");
                out.println("<td>" + (exists ? "<img class='img-preview' src='" + serveUrl + "'>" : "—") + "</td>");
                out.println("</tr>");
            }
        } catch (Exception e) { out.println("<tr><td colspan='5' class='fail'>ERROR: " + e.getMessage() + "</td></tr>"); }
    %>
    </table>
</div>

<!-- 4. QUICK UPLOAD TEST -->
<div class="card">
    <h2>4. Quick Upload Test</h2>
    <p>Use this to test if the upload pipeline works. Select a file and click Upload.</p>
    <form action="<%= request.getContextPath() %>/uploadImport" method="post" enctype="multipart/form-data" class="test-form">
        <input type="file" name="file" accept="image/*" required>
        <input type="hidden" name="albumId" value="">

        <input type="hidden" name="aperture" value="f/test">
        <button type="submit">🚀 Test Upload</button>
    </form>
    <p style="font-size:12px;color:#64748b">After upload, you'll be redirected. Come back here to see if the file appeared.</p>
</div>

<!-- 5. USERS -->
<div class="card">
    <h2>5. Users (Credits)</h2>
    <table>
    <%
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT user_id, email, role, credits FROM users LIMIT 15")) {
            out.println("<tr><th>user_id</th><th>email</th><th>role</th><th>credits</th></tr>");
            while (rs.next()) {
                out.println("<tr><td>" + rs.getInt("user_id") + "</td><td>" + rs.getString("email") + "</td><td>" + rs.getString("role") + "</td><td>" + rs.getInt("credits") + "</td></tr>");
            }
        } catch (Exception e) { out.println("<tr><td class='fail'>ERROR: " + e.getMessage() + "</td></tr>"); }
    %>
    </table>
</div>

</body>
</html>
