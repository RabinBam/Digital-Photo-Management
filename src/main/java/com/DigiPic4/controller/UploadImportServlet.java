package com.DigiPic4.controller;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collection;

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
    fileSizeThreshold = 1024 * 1024,     // 1 MB
    maxFileSize = 500 * 1024 * 1024,     // 500 MB
    maxRequestSize = 1000 * 1024 * 1024  // 1 GB
)
public class UploadImportServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        
        // Apply no-cache headers
        applyNoCache(res);
        
        // Check authentication
        HttpSession session = req.getSession(false);
        User currentUser = session == null ? null : (User) session.getAttribute("user");
        
        if (currentUser == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        // Set page attribute for sidebar navigation
        req.setAttribute("page", "uploadImport");
        
        // Forward to JSP
        req.getRequestDispatcher("/uploadImport.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        
        // Apply no-cache headers
        applyNoCache(res);
        
        // Check authentication
        HttpSession session = req.getSession(false);
        User currentUser = session == null ? null : (User) session.getAttribute("user");
        
        if (currentUser == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        // Get the upload directory path
        String uploadDir = getServletContext().getRealPath("/uploads");
        Path uploadPath = Paths.get(uploadDir);
        
        // Create upload directory if it doesn't exist
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        try {
            // Get all parts of the multipart request
            Collection<Part> parts = req.getParts();
            int successCount = 0;
            int failCount = 0;
            
            for (Part part : parts) {
                // Skip non-file parts
                if (part.getName().equals("file")) {
                    String fileName = extractFileName(part);
                    
                    if (fileName != null && !fileName.isEmpty()) {
                        try {
                            // Validate file type
                            if (isValidFileType(fileName)) {
                                // Create user-specific upload folder
                                String userUploadDir = uploadDir + "/" + currentUser.getUserId();
                                Path userUploadPath = Paths.get(userUploadDir);
                                
                                if (!Files.exists(userUploadPath)) {
                                    Files.createDirectories(userUploadPath);
                                }
                                
                                // Save the file
                                Path filePath = userUploadPath.resolve(fileName);
                                try (InputStream input = part.getInputStream()) {
                                	Files.copy(input, filePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);                                }
                                
                                successCount++;
                                
                            } else {
                                failCount++;
                            }
                        } catch (Exception e) {
                            failCount++;
                            e.printStackTrace();
                        }
                    }
                }
            }
            
            if (successCount == 0 && failCount == 0) {
                redirectWithStatus(req, res, null, "No valid files were selected for upload.");
                return;
            }

            String successMessage = successCount > 0 ? successCount + " file(s) uploaded successfully" : null;
            String errorMessage = failCount > 0 ? failCount + " file(s) failed to upload" : null;

            redirectWithStatus(req, res, successMessage, errorMessage);
            return;
            
        } catch (Exception e) {
            e.printStackTrace();
            redirectWithStatus(req, res, null, "Upload failed: " + e.getMessage());
            return;
        }
    }

    /**
     * Extract file name from part header
     */
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null || contentDisp.isBlank()) {
            return null;
        }
        String[] items = contentDisp.split(";");
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                return new File(item.substring(item.indexOf("=") + 2, item.length() - 1)).getName();
            }
        }
        return null;
    }

    /**
     * Validate file type
     */
    private boolean isValidFileType(String fileName) {
        String[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".mp4", ".mov", ".pdf" };
        String lowerFileName = fileName.toLowerCase();
        
        for (String ext : allowedExtensions) {
            if (lowerFileName.endsWith(ext)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Apply no-cache headers
     */
    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }

    private void redirectWithStatus(HttpServletRequest req, HttpServletResponse res, String success, String error)
            throws IOException {
        StringBuilder redirectUrl = new StringBuilder(req.getContextPath()).append("/uploadImport");
        boolean hasParam = false;

        if (success != null && !success.isBlank()) {
            redirectUrl.append(hasParam ? "&" : "?");
            redirectUrl.append("success=").append(java.net.URLEncoder.encode(success, java.nio.charset.StandardCharsets.UTF_8));
            hasParam = true;
        }

        if (error != null && !error.isBlank()) {
            redirectUrl.append(hasParam ? "&" : "?");
            redirectUrl.append("error=").append(java.net.URLEncoder.encode(error, java.nio.charset.StandardCharsets.UTF_8));
        }

        res.sendRedirect(redirectUrl.toString());
    }
}