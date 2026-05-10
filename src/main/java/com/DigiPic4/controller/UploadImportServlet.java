package com.DigiPic4.controller;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Collection;
import java.util.List;

import com.DigiPic4.dao.AlbumDAO;
import com.DigiPic4.dao.PhotoDAO;
import com.DigiPic4.dao.UserDAO;
import com.DigiPic4.model.Album;
import com.DigiPic4.model.Photo;
import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/uploadImport")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize       = 500L * 1024 * 1024, // 500 MB
    maxRequestSize    = 1000L * 1024 * 1024 // 1 GB
)
public class UploadImportServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ── GET ─────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);

        User user = getAuthenticatedUser(req, res);
        if (user == null) return;

        req.setAttribute("page", "uploadImport");

        // Pass default album list so the JSP can show a target-album selector
        AlbumDAO albumDAO = new AlbumDAO();
        List<Album> albums = albumDAO.findAlbumsByUserId(user.getUserId());
        req.setAttribute("albums", albums);

        req.getRequestDispatcher("/uploadImport.jsp").forward(req, res);
    }

    // ── POST ────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);

        User user = getAuthenticatedUser(req, res);
        if (user == null) return;

        // Resolve upload directory on disk
        String uploadDirBase = getServletContext().getRealPath("/uploads");
        Path userUploadPath  = Paths.get(uploadDirBase, String.valueOf(user.getUserId()));
        if (!Files.exists(userUploadPath)) {
            Files.createDirectories(userUploadPath);
        }

        // Determine (or auto-create) the target album
        int albumId = resolveAlbumId(req, user);

        AlbumDAO albumDAO = new AlbumDAO();
        PhotoDAO photoDAO = new PhotoDAO();
        UserDAO  userDAO  = new UserDAO();

        int successCount = 0;
        int failCount    = 0;

        Collection<Part> parts;
        try {
            parts = req.getParts();
        } catch (Exception e) {
            e.printStackTrace();
            redirectWithStatus(req, res, null, "Upload failed: " + e.getMessage());
            return;
        }

        for (Part part : parts) {
            if (!"file".equals(part.getName())) continue;

            String fileName = extractFileName(part);
            if (fileName == null || fileName.isEmpty()) continue;

            if (!isValidFileType(fileName)) {
                failCount++;
                continue;
            }

            // Sanitise filename
            String safeFileName = sanitizeFileName(fileName);

            try {
                // Save to disk
                Path filePath = userUploadPath.resolve(safeFileName);
                try (InputStream in = part.getInputStream()) {
                    Files.copy(in, filePath, StandardCopyOption.REPLACE_EXISTING);
                }

                // Persist to DB only when we have a valid album
                if (albumId > 0) {
                    Photo photo = new Photo();
                    photo.setTitle(fileNameWithoutExtension(safeFileName));
                    photo.setFilePath(safeFileName);
                    photo.setAlbumId(albumId);
                    // EXIF fields left blank — user can fill later
                    int newId = photoDAO.addPhoto(photo);
                    if (newId > 0) {
                        userDAO.logAction(user.getUserId(), "Uploaded photo: " + safeFileName + " to album #" + albumId);
                        successCount++;
                    } else {
                        // File saved but DB insert failed — still count as partial success
                        successCount++;
                    }
                } else {
                    // No album — file is on disk but not yet catalogued
                    successCount++;
                }

            } catch (Exception e) {
                e.printStackTrace();
                failCount++;
            }
        }

        if (successCount == 0 && failCount == 0) {
            redirectWithStatus(req, res, null, "No valid files were selected for upload.");
            return;
        }

        String successMsg = successCount > 0 ? successCount + " file(s) uploaded successfully." : null;
        String errorMsg   = failCount    > 0 ? failCount    + " file(s) failed to upload."     : null;
        redirectWithStatus(req, res, successMsg, errorMsg);
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    /**
     * Returns an existing albumId selected by the user, or creates a default
     * "My Uploads" album automatically when none is selected.
     */
    private int resolveAlbumId(HttpServletRequest req, User user) {
        String albumIdParam = req.getParameter("albumId");
        if (albumIdParam != null && !albumIdParam.isBlank()) {
            try {
                int id = Integer.parseInt(albumIdParam.trim());
                if (id > 0) return id;
            } catch (NumberFormatException ignored) {}
        }

        // Auto-create "My Uploads" album if user has none
        AlbumDAO albumDAO = new AlbumDAO();
        List<Album> existing = albumDAO.findAlbumsByUserId(user.getUserId());
        for (Album a : existing) {
            if ("My Uploads".equalsIgnoreCase(a.getAlbumName())) return a.getAlbumId();
        }

        Album defaultAlbum = new Album();
        defaultAlbum.setAlbumName("My Uploads");
        defaultAlbum.setDescription("Auto-created album for uploaded files.");
        defaultAlbum.setUserId(user.getUserId());
        int newId = albumDAO.createAlbum(defaultAlbum);
        return newId > 0 ? newId : -1;
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null || contentDisp.isBlank()) return null;
        for (String item : contentDisp.split(";")) {
            String trimmed = item.trim();
            if (trimmed.startsWith("filename")) {
                String raw = trimmed.substring(trimmed.indexOf('=') + 1).trim();
                // Strip surrounding quotes if present
                if (raw.startsWith("\"") && raw.endsWith("\"")) {
                    raw = raw.substring(1, raw.length() - 1);
                }
                // Return only the base file name (strip any path separators from browser)
                int sep = Math.max(raw.lastIndexOf('/'), raw.lastIndexOf('\\'));
                return sep >= 0 ? raw.substring(sep + 1) : raw;
            }
        }
        return null;
    }

    private boolean isValidFileType(String fileName) {
        String lower = fileName.toLowerCase();
        for (String ext : new String[]{".jpg", ".jpeg", ".png", ".gif", ".mp4", ".mov", ".pdf"}) {
            if (lower.endsWith(ext)) return true;
        }
        return false;
    }

    /** Replace spaces and non-alphanumeric chars (except dots/dashes/underscores). */
    private String sanitizeFileName(String fileName) {
        return fileName.replaceAll("[^a-zA-Z0-9.\\-_]", "_");
    }

    private String fileNameWithoutExtension(String fileName) {
        int dot = fileName.lastIndexOf('.');
        return dot > 0 ? fileName.substring(0, dot) : fileName;
    }

    private User getAuthenticatedUser(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect(req.getContextPath() + "/login"); return null; }
        Object u = session.getAttribute("user");
        if (!(u instanceof User)) { res.sendRedirect(req.getContextPath() + "/login"); return null; }
        return (User) u;
    }

    private void redirectWithStatus(HttpServletRequest req, HttpServletResponse res,
                                    String success, String error) throws IOException {
        StringBuilder url = new StringBuilder(req.getContextPath()).append("/uploadImport");
        boolean hasParam = false;
        if (success != null && !success.isBlank()) {
            url.append("?success=")
               .append(java.net.URLEncoder.encode(success, java.nio.charset.StandardCharsets.UTF_8));
            hasParam = true;
        }
        if (error != null && !error.isBlank()) {
            url.append(hasParam ? "&" : "?").append("error=")
               .append(java.net.URLEncoder.encode(error, java.nio.charset.StandardCharsets.UTF_8));
        }
        res.sendRedirect(url.toString());
    }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}