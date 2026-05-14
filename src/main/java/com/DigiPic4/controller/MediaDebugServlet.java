package com.DigiPic4.controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.stream.Collectors;

import com.DigiPic4.model.User;
import com.DigiPic4.util.MediaStorageUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/mediaDebug")
public class MediaDebugServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || !(session.getAttribute("user") instanceof User)) {
            resp.getWriter().println("<p>Not logged in. Please login first.</p>");
            return;
        }
        User u = (User) session.getAttribute("user");
        int userId = u.getUserId();

        resp.getWriter().println("<h3>Media debug for user: " + userId + "</h3>");
        try {
            Path base = MediaStorageUtil.resolveMediaBase(getServletContext());
            resp.getWriter().println("<p>Media base: " + base.toString() + "</p>");
            Path userDir = base.resolve(Path.of("user", String.valueOf(userId))).normalize();
            if (!Files.exists(userDir)) {
                resp.getWriter().println("<p>No media directory found for user.</p>");
                return;
            }
            resp.getWriter().println("<ul>");
            Files.walk(userDir).filter(p -> Files.isRegularFile(p)).forEach(p -> {
                try {
                    String rel = userDir.relativize(p).toString();
                    resp.getWriter().println("<li>" + rel + " &mdash; " + Files.size(p) + " bytes</li>");
                } catch (IOException e) {
                    // ignore
                }
            });
            resp.getWriter().println("</ul>");
        } catch (Exception e) {
            resp.getWriter().println("<pre>Debug error: " + e.getMessage() + "</pre>");
            e.printStackTrace(resp.getWriter());
        }
    }
}
