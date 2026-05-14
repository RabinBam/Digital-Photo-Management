package com.DigiPic4.util;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.Part;

public final class MediaStorageUtil {

    private static final String MEDIA_BASE = "/WEB-INF/image";

    private MediaStorageUtil() {
    }

    public static String resolveBrowserSrc(ServletContext context, String filePath) {
        if (filePath == null || filePath.isBlank()) {
            return "";
        }
        String normalized = filePath.trim();
        if (normalized.startsWith("http://") || normalized.startsWith("https://")) {
            return normalized;
        }
        return context.getContextPath() + "/media?path=" + URLEncoder.encode(normalized, StandardCharsets.UTF_8);
    }

    public static String storePart(ServletContext context, Part part, int userId, int albumId) throws IOException {
        String submittedName = extractSubmittedFileName(part);
        if (submittedName == null || submittedName.isBlank()) {
            submittedName = "upload-" + System.currentTimeMillis();
        }
        return storeStream(context, part.getInputStream(), submittedName, part.getContentType(), userId, albumId);
    }

    public static String storeRemoteUrl(ServletContext context, String sourceUrl, int userId, int albumId)
            throws IOException {
        if (sourceUrl == null || sourceUrl.isBlank()) {
            throw new IOException("Empty source URL");
        }

        HttpURLConnection conn = null;
        try {
            conn = (HttpURLConnection) new URL(sourceUrl).openConnection();
            conn.setInstanceFollowRedirects(true);
            conn.setConnectTimeout(15_000);
            conn.setReadTimeout(15_000);
            conn.setRequestProperty("User-Agent", "DigiPic4/1.0");

            int status = conn.getResponseCode();
            if (status < 200 || status >= 300) {
                throw new IOException("Unable to download media from URL (HTTP " + status + ")");
            }

            String contentType = conn.getContentType();
            String fileName = deriveNameFromUrl(sourceUrl);
            if (fileName == null || fileName.isBlank()) fileName = "remote-media";

            try (InputStream in = conn.getInputStream()) {
                return storeStream(context, in, fileName, contentType, userId, albumId);
            }
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    public static Path resolveAlbumDirectory(ServletContext context, int userId, int albumId) throws IOException {
        Path base = resolveMediaBase(context);
        Path albumDir = base.resolve(Paths.get("user", String.valueOf(userId), "albums", String.valueOf(albumId)))
                .normalize();
        Files.createDirectories(albumDir);
        return albumDir;
    }

    public static Path resolveMediaBase(ServletContext context) throws IOException {
        String realPath = context.getRealPath(MEDIA_BASE);
        Path base;
        if (realPath != null && !realPath.isBlank()) {
            base = Paths.get(realPath);
        } else {
            base = Paths.get(System.getProperty("java.io.tmpdir"), "digipic-media").resolve("image");
        }
        Files.createDirectories(base);
        return base.toAbsolutePath().normalize();
    }

    public static String buildRelativePath(int userId, int albumId, String fileName) {
        return "user/" + userId + "/albums/" + albumId + "/" + fileName;
    }

    public static String sanitizeFileName(String fileName) {
        if (fileName == null || fileName.isBlank()) {
            return "media";
        }
        String cleaned = Paths.get(fileName).getFileName().toString();
        cleaned = cleaned.replaceAll("[^a-zA-Z0-9._-]", "_");
        cleaned = cleaned.replaceAll("_+", "_");
        cleaned = cleaned.replaceAll("^\\.+", "");
        return cleaned.isBlank() ? "media" : cleaned;
    }

    public static String extractSubmittedFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) {
            return null;
        }
        for (String token : header.split(";")) {
            String trimmed = token.trim();
            if (trimmed.startsWith("filename")) {
                String raw = trimmed.substring(trimmed.indexOf('=') + 1).trim();
                if (raw.startsWith("\"") && raw.endsWith("\"")) {
                    raw = raw.substring(1, raw.length() - 1);
                }
                int sep = Math.max(raw.lastIndexOf('/'), raw.lastIndexOf('\\'));
                return sep >= 0 ? raw.substring(sep + 1) : raw;
            }
        }
        return null;
    }

    private static String storeStream(ServletContext context, InputStream in, String originalName, String contentType,
            int userId, int albumId) throws IOException {
        Path albumDir = resolveAlbumDirectory(context, userId, albumId);
        String safeName = sanitizeFileName(originalName);
        safeName = ensureExtension(safeName, contentType, originalName);
        safeName = makeUniqueName(albumDir, safeName);

        Path target = albumDir.resolve(safeName);
        Files.copy(in, target);
        return buildRelativePath(userId, albumId, safeName);
    }

    private static String makeUniqueName(Path directory, String fileName) throws IOException {
        String candidate = fileName;
        String baseName = candidate;
        String extension = "";
        int dot = candidate.lastIndexOf('.');
        if (dot > 0) {
            baseName = candidate.substring(0, dot);
            extension = candidate.substring(dot);
        }

        int counter = 1;
        while (Files.exists(directory.resolve(candidate))) {
            candidate = baseName + "_" + counter + extension;
            counter++;
        }
        return candidate;
    }

    private static String ensureExtension(String fileName, String contentType, String sourceName) {
        if (fileName.contains(".")) {
            return fileName;
        }

        String extension = extensionFromContentType(contentType);
        if (extension == null) {
            extension = extensionFromSourceName(sourceName);
        }
        return extension == null ? fileName : fileName + extension;
    }

    private static String extensionFromSourceName(String sourceName) {
        if (sourceName == null) {
            return null;
        }
        String cleaned = sourceName.toLowerCase(Locale.ROOT);
        if (cleaned.endsWith(".jpg") || cleaned.endsWith(".jpeg")) return ".jpg";
        if (cleaned.endsWith(".png")) return ".png";
        if (cleaned.endsWith(".gif")) return ".gif";
        if (cleaned.endsWith(".webp")) return ".webp";
        if (cleaned.endsWith(".bmp")) return ".bmp";
        if (cleaned.endsWith(".svg")) return ".svg";
        if (cleaned.endsWith(".mp4")) return ".mp4";
        if (cleaned.endsWith(".mov")) return ".mov";
        if (cleaned.endsWith(".pdf")) return ".pdf";
        return null;
    }

    private static String extensionFromContentType(String contentType) {
        if (contentType == null || contentType.isBlank()) {
            return null;
        }
        String normalized = contentType.toLowerCase(Locale.ROOT).trim();
        if (normalized.startsWith("image/jpeg")) return ".jpg";
        if (normalized.startsWith("image/jpg")) return ".jpg";
        if (normalized.startsWith("image/png")) return ".png";
        if (normalized.startsWith("image/gif")) return ".gif";
        if (normalized.startsWith("image/webp")) return ".webp";
        if (normalized.startsWith("image/bmp")) return ".bmp";
        if (normalized.startsWith("image/svg")) return ".svg";
        if (normalized.startsWith("video/mp4")) return ".mp4";
        if (normalized.startsWith("video/quicktime")) return ".mov";
        if (normalized.startsWith("application/pdf")) return ".pdf";
        return null;
    }

    public static String deriveNameFromUrl(String sourceUrl) {
        if (sourceUrl == null || sourceUrl.isBlank()) {
            return null;
        }
        try {
            URI uri = URI.create(sourceUrl);
            String path = uri.getPath();
            if (path != null && !path.isBlank()) {
                int lastSlash = path.lastIndexOf('/');
                String name = lastSlash >= 0 ? path.substring(lastSlash + 1) : path;
                if (!name.isBlank()) {
                    return name;
                }
            }
        } catch (IllegalArgumentException ignored) {
        }
        return null;
    }

    public static boolean isRemoteUrl(String value) {
        return value != null && (value.startsWith("http://") || value.startsWith("https://"));
    }

    public static String readSafeContentType(String path) throws IOException {
        String probe = Files.probeContentType(Paths.get(path));
        if (probe != null && !probe.isBlank()) {
            return probe;
        }
        return URLConnection.guessContentTypeFromName(path);
    }
}
