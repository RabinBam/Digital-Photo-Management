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
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
        maxFileSize = 500L * 1024 * 1024, // 500 MB
        maxRequestSize = 1000L * 1024 * 1024 // 1 GB
)
public class UploadImportServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ── GET ─────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);

        User user = getAuthenticatedUser(req, res);
        if (user == null)
            return;

        req.setAttribute("page", "uploadImport");

        // Pass default album list so the JSP can show a target-album selector
        AlbumDAO albumDAO = new AlbumDAO();
        List<Album> albums = albumDAO.findAlbumsByUserId(user.getUserId());
        req.setAttribute("albums", albums);

        req.getRequestDispatcher("/WEB-INF/Pages/uploadImport.jsp").forward(req, res);
    }

    // ── POST ────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);

        User user = getAuthenticatedUser(req, res);
        if (user == null)
            return;

        System.out.println("[UPLOAD] ========== START UPLOAD ==========");
        System.out.println("[UPLOAD] User: " + user.getUserId() + " (" + user.getEmail() + ")");
        System.out.println("[UPLOAD] ContentType: " + req.getContentType());

        // Determine (or auto-create) the target album
        int albumId = resolveAlbumId(req, user);
        System.out.println("[UPLOAD] Target albumId: " + albumId);

        if (albumId == -2) {
            redirectWithStatus(req, res, null, "Album limit reached (Max 3). Cannot create a new album.");
            return;
        }
        if (albumId <= 0) {
            redirectWithStatus(req, res, null, "Failed to resolve or create target album.");
            return;
        }

        // Resolve upload directory on disk in persistent storage
        String uploadDirBase = "C:/DigiPicStorage/images";
        java.nio.file.Path finalUploadPath = java.nio.file.Paths.get(uploadDirBase, String.valueOf(user.getUserId()),
                String.valueOf(albumId));
        if (!java.nio.file.Files.exists(finalUploadPath)) {
            java.nio.file.Files.createDirectories(finalUploadPath);
            System.out.println("[UPLOAD] Created directory: " + finalUploadPath);
        }

        PhotoDAO photoDAO = new PhotoDAO();
        UserDAO userDAO = new UserDAO();

        // Capture metadata from request
        String aperture = req.getParameter("aperture");
        String shutter = req.getParameter("shutterSpeed");
        String iso = req.getParameter("iso");
        String focal = req.getParameter("focalLength");
        System.out.println("[UPLOAD] Metadata - aperture:" + aperture);

        java.util.List<String> uploadErrors = new java.util.ArrayList<>();

        int successCount = 0;
        int failCount = 0;

        // ── Handle URL Import ──
        String importUrl = req.getParameter("importUrl");
        if (importUrl != null && !importUrl.isBlank()) {
            System.out.println("[UPLOAD] URL Import: " + importUrl);
            try {
                String fileName = "imported_" + System.currentTimeMillis() + ".jpg";
                try {
                    String path = new java.net.URL(importUrl).getPath();
                    if (path.contains("/") && path.lastIndexOf('/') < path.length() - 1) {
                        String ext = path.substring(path.lastIndexOf('/') + 1);
                        if (isValidFileType(ext))
                            fileName = sanitizeFileName(ext);
                    }
                } catch (Exception ignored) {
                }

                java.nio.file.Path filePath = finalUploadPath.resolve(fileName);
                try (InputStream in = new java.net.URL(importUrl).openStream()) {
                    java.nio.file.Files.copy(in, filePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                } catch (Exception e) {
                    uploadErrors.add("URL stream error: " + e.getMessage());
                    throw e;
                }
                System.out.println("[UPLOAD] URL file saved: " + filePath + " size=" + filePath.toFile().length());

                Photo photo = new Photo();
                photo.setTitle("Imported " + fileName);
                photo.setFilePath(user.getUserId() + "/" + albumId + "/" + fileName);
                photo.setAlbumId(albumId);
                photo.setAperture(aperture);
                photo.setShutterSpeed(shutter);
                photo.setIso(iso);
                photo.setFocalLength(focal);

                int photoId = photoDAO.addPhoto(photo);
                System.out.println("[UPLOAD] URL photo DB result: " + photoId);
                if (photoId > 0) {
                    userDAO.logAction(user.getUserId(), "Imported photo from URL: " + fileName);
                    userDAO.deductCredits(user.getUserId(), 10);
                    successCount++;
                } else {
                    uploadErrors.add("photoDAO.addPhoto failed for URL import");
                    failCount++;
                }
            } catch (Exception e) {
                System.out.println("[UPLOAD] URL Import ERROR: " + e.getMessage());
                uploadErrors.add("URL Import Exception: " + e.toString());
                e.printStackTrace();
                failCount++;
            }
        }

        // ── Handle Multi-part File Upload ──
        try {
            String contentType = req.getContentType();
            if (contentType != null && contentType.startsWith("multipart/form-data")) {
                java.util.Collection<jakarta.servlet.http.Part> parts = req.getParts();
                System.out.println("[UPLOAD] Multipart parts count: " + parts.size());
                for (jakarta.servlet.http.Part part : parts) {
                    System.out.println("[UPLOAD]   Part: name=" + part.getName() + " size=" + part.getSize()
                            + " contentType=" + part.getContentType());
                    if (!"file".equals(part.getName()))
                        continue;
                    if (part.getSize() == 0) {
                        System.out.println("[UPLOAD]   Skipping empty file part");
                        continue;
                    }

                    String fileName = extractFileName(part);
                    System.out.println("[UPLOAD]   Extracted filename: " + fileName);
                    if (fileName == null || fileName.isEmpty()) {
                        uploadErrors.add("Extracted filename is null or empty");
                        continue;
                    }

                    if (!isValidFileType(fileName)) {
                        System.out.println("[UPLOAD]   REJECTED: invalid file type: " + fileName);
                        uploadErrors.add("Invalid file type: " + fileName);
                        failCount++;
                        continue;
                    }

                    String safeFileName = sanitizeFileName(fileName);
                    try {
                        java.nio.file.Path filePath = finalUploadPath.resolve(safeFileName);
                        try (InputStream in = part.getInputStream()) {
                            java.nio.file.Files.copy(in, filePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                        }
                        System.out
                                .println("[UPLOAD]   File saved: " + filePath + " size=" + filePath.toFile().length());

                        Photo photo = new Photo();
                        photo.setTitle(fileNameWithoutExtension(safeFileName));
                        photo.setFilePath(user.getUserId() + "/" + albumId + "/" + safeFileName);
                        photo.setAlbumId(albumId);
                        photo.setAperture(aperture);
                        photo.setShutterSpeed(shutter);
                        photo.setIso(iso);
                        photo.setFocalLength(focal);

                        int photoId = photoDAO.addPhoto(photo);
                        System.out.println("[UPLOAD]   Photo DB result: " + photoId);
                        if (photoId > 0) {
                            userDAO.logAction(user.getUserId(), "Uploaded photo: " + safeFileName);
                            userDAO.deductCredits(user.getUserId(), 10);
                            successCount++;
                        } else {
                            uploadErrors.add("photoDAO.addPhoto failed for file upload");
                            failCount++;
                        }
                    } catch (Exception e) {
                        System.out.println("[UPLOAD]   File save ERROR: " + e.getMessage());
                        uploadErrors.add("File Save Exception: " + e.toString());
                        e.printStackTrace();
                        failCount++;
                    }
                }
            } else {
                System.out.println("[UPLOAD] NOT multipart. ContentType: " + contentType);
                uploadErrors.add("Not multipart form-data. Content-Type: " + contentType);
            }
        } catch (Exception e) {
            System.out.println("[UPLOAD] Multipart processing ERROR: " + e.getMessage());
            uploadErrors.add("Multipart Processing Exception: " + e.toString());
            e.printStackTrace();
        }

        System.out.println("[UPLOAD] Result: success=" + successCount + " fail=" + failCount);
        req.getSession().setAttribute("uploadErrors", uploadErrors);

        // Refresh session user to update credits in UI
        User updatedUser = userDAO.findUserById(user.getUserId());
        if (updatedUser != null) {
            req.getSession().setAttribute("user", updatedUser);
        }

        if (successCount == 0 && failCount == 0) {
            redirectWithStatus(req, res, null, "No items were processed.");
            return;
        }

        String successMsg = successCount > 0 ? successCount + " item(s) processed successfully." : null;
        String errorMsg = failCount > 0 ? failCount + " item(s) failed." : null;
        redirectWithStatus(req, res, successMsg, errorMsg);
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    /**
     * Returns an existing albumId selected by the user, or creates a new one
     * based on the 'newAlbumName' parameter. Enforces a limit of 3 albums.
     */
    private int resolveAlbumId(HttpServletRequest req, User user) {
        String albumIdParam = req.getParameter("albumId");
        String newAlbumName = req.getParameter("newAlbumName");

        // 1. If an existing album was selected, use it (ignore new album name)
        if (albumIdParam != null && !albumIdParam.isBlank()) {
            try {
                int id = Integer.parseInt(albumIdParam.trim());
                if (id > 0)
                    return id;
            } catch (NumberFormatException ignored) {
            }
        }

        AlbumDAO albumDAO = new AlbumDAO();
        List<Album> existing = albumDAO.findAlbumsByUserId(user.getUserId());

        // 2. If a new album name was provided, try to create it (if under limit)
        if (newAlbumName != null && !newAlbumName.isBlank()) {
            if (existing.size() >= 3) {
                // Limit reached - we could throw an exception or return -1
                // For now, return -1 so the servlet can handle the error
                return -2; // Special code for limit reached
            }

            // Check if it already exists by name
            for (Album a : existing) {
                if (newAlbumName.equalsIgnoreCase(a.getAlbumName()))
                    return a.getAlbumId();
            }

            Album newAlbum = new Album();
            newAlbum.setAlbumName(newAlbumName.trim());
            newAlbum.setDescription("Created during upload.");
            newAlbum.setUserId(user.getUserId());
            int newId = albumDAO.createAlbum(newAlbum);
            return newId > 0 ? newId : -1;
        }

        // 3. Fallback: Auto-create "My Uploads" album if user has none
        for (Album a : existing) {
            if ("My Uploads".equalsIgnoreCase(a.getAlbumName()))
                return a.getAlbumId();
        }

        if (existing.size() >= 3) return -2;

        Album defaultAlbum = new Album();
        defaultAlbum.setAlbumName("My Uploads");
        defaultAlbum.setDescription("Auto-created album for uploaded files.");
        defaultAlbum.setUserId(user.getUserId());
        int newId = albumDAO.createAlbum(defaultAlbum);
        return newId > 0 ? newId : -1;
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null || contentDisp.isBlank())
            return null;
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
        for (String ext : new String[] { ".jpg", ".jpeg", ".png", ".gif", ".mp4", ".mov", ".pdf" }) {
            if (lower.endsWith(ext))
                return true;
        }
        return false;
    }

    /**
     * Replace spaces and non-alphanumeric chars (except dots/dashes/underscores).
     */
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
        if (session == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        Object u = session.getAttribute("user");
        if (!(u instanceof User)) {
            res.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
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