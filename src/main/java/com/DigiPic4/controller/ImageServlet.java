package com.DigiPic4.controller;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import com.DigiPic4.util.MediaStorageUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/media")
public class ImageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String relativePath = request.getParameter("path");
        if (relativePath == null || relativePath.isBlank()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Path basePath = MediaStorageUtil.resolveMediaBase(getServletContext());
        Path target = basePath.resolve(Paths.get(relativePath)).normalize();
        if (!target.startsWith(basePath) || !Files.exists(target) || Files.isDirectory(target)) {
            System.err.println("[ImageServlet] target not found or invalid: " + target + " (base=" + basePath + ")");
            // Try a helpful fallback: if relativePath looks like a legacy filename or contains uploads path, try realPath('/uploads/...')
            try {
                String p = relativePath.replaceAll("\\\\","/");
                String[] parts = p.split("/");
                String candidate = null;
                if (p.startsWith("user/") && parts.length >= 4) {
                    // pattern user/<id>/albums/<album>/<file>
                    candidate = getServletContext().getRealPath("/WEB-INF/image/" + p);
                } else if (!p.contains("/")) {
                    // legacy filename — try /uploads/<someUser>/<file> for the user running the request is unknown here;
                    // attempt to search the uploads directory under webapp if available (best-effort)
                    String uploadsBase = getServletContext().getRealPath("/uploads");
                    if (uploadsBase != null) {
                        Path uploadsPath = Paths.get(uploadsBase);
                        if (Files.exists(uploadsPath) && Files.isDirectory(uploadsPath)) {
                            // try to locate file in any user folder (not exhaustive) — pick first match
                            try (java.util.stream.Stream<Path> s = Files.walk(uploadsPath, 2)) {
                                java.util.Optional<Path> found = s.filter(pth -> pth.getFileName().toString().equals(p)).findFirst();
                                if (found.isPresent()) {
                                    candidate = found.get().toAbsolutePath().toString();
                                }
                            }
                        }
                    }
                }
                if (candidate != null) {
                    Path cand = Paths.get(candidate);
                    if (Files.exists(cand) && !Files.isDirectory(cand)) {
                        System.out.println("[ImageServlet] fallback serving file from: " + cand);
                        String contentType = Files.probeContentType(cand);
                        if (contentType == null || contentType.isBlank()) contentType = "application/octet-stream";
                        response.setContentType(contentType);
                        response.setContentLengthLong(Files.size(cand));
                        response.setHeader("Content-Disposition", "inline; filename=\"" + cand.getFileName().toString() + "\"");
                        try (InputStream in = Files.newInputStream(cand); OutputStream out = response.getOutputStream()) {
                            byte[] buffer = new byte[8192]; int len; while ((len = in.read(buffer)) != -1) out.write(buffer, 0, len);
                        }
                        return;
                    }
                }
            } catch (Exception ex) {
                System.err.println("[ImageServlet] fallback attempt failed: " + ex.getMessage());
                ex.printStackTrace();
            }
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = Files.probeContentType(target);
        if (contentType == null || contentType.isBlank()) {
            contentType = "application/octet-stream";
        }

        response.setContentType(contentType);
        response.setContentLengthLong(Files.size(target));
        response.setHeader("Content-Disposition", "inline; filename=\"" + target.getFileName().toString() + "\"");

        try (InputStream in = Files.newInputStream(target); OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int len;
            while ((len = in.read(buffer)) != -1) {
                out.write(buffer, 0, len);
            }
        }
    }
}
