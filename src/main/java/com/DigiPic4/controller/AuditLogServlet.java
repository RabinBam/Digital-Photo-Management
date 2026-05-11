package com.DigiPic4.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import com.DigiPic4.dao.UserDAO;
import com.DigiPic4.model.AuditLog;
import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/audit-log")
public class AuditLogServlet extends HttpServlet {

    private static final int DEFAULT_LIMIT = 100;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);
        User sessionUser = requireAdmin(req, res);
        if (sessionUser == null) return;

        UserDAO dao = new UserDAO();

        // Optional filter by userId
        String filterParam = req.getParameter("userId");
        User filterUser = null;
        List<AuditLog> logs;

        if (filterParam != null && !filterParam.isBlank()) {
            try {
                int filterId = Integer.parseInt(filterParam);
                filterUser = dao.findUserById(filterId);
                logs = dao.findAuditLogsByUser(filterId, DEFAULT_LIMIT);
            } catch (NumberFormatException e) {
                logs = dao.findAllAuditLogs(DEFAULT_LIMIT);
            }
        } else {
            logs = dao.findAllAuditLogs(DEFAULT_LIMIT);
        }

        req.setAttribute("logs", logs);
        req.setAttribute("filterUser", filterUser);
        req.setAttribute("allUsers", dao.findAllUsers());

        req.getRequestDispatcher("/WEB-INF/Pages/auditLog.jsp").forward(req, res);    }

    private User requireAdmin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect(req.getContextPath() + "/login"); return null; }
        Object u = session.getAttribute("user");
        if (!(u instanceof User)) { res.sendRedirect(req.getContextPath() + "/login"); return null; }
        User user = (User) u;
        if (!"admin".equalsIgnoreCase(user.getRole())) {
            String enc = URLEncoder.encode("Admin access required.", StandardCharsets.UTF_8);
            res.sendRedirect(req.getContextPath() + "/gallery?error=" + enc);
            return null;
        }
        return user;
    }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}