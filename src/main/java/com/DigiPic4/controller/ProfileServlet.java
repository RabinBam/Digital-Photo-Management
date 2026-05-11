package com.DigiPic4.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import com.DigiPic4.dao.AlbumDAO;
import com.DigiPic4.dao.PhotoDAO;
import com.DigiPic4.dao.UserDAO;
import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);
        User sessionUser = requireAuth(req, res);
        if (sessionUser == null) return;

        UserDAO userDAO   = new UserDAO();
        AlbumDAO albumDAO = new AlbumDAO();
        PhotoDAO photoDAO = new PhotoDAO();

        // Admins may view any profile via ?userId=X
        String userIdParam = req.getParameter("userId");
        User profileUser = sessionUser;

        if (userIdParam != null && !userIdParam.isBlank()) {
            if (!"admin".equalsIgnoreCase(sessionUser.getRole())) {
                res.sendRedirect(req.getContextPath() + "/profile");
                return;
            }
            try {
                User found = userDAO.findUserById(Integer.parseInt(userIdParam));
                if (found == null) {
                    String enc = URLEncoder.encode("User not found.", StandardCharsets.UTF_8);
                    res.sendRedirect(req.getContextPath() + "/captain-cabin?error=" + enc);
                    return;
                }
                profileUser = found;
            } catch (NumberFormatException e) {
                res.sendRedirect(req.getContextPath() + "/captain-cabin");
                return;
            }
        }

        // Attach stats
        req.setAttribute("profileUser", profileUser);
        req.setAttribute("isOwnProfile", profileUser.getUserId() == sessionUser.getUserId());
        req.setAttribute("albumCount", albumDAO.countAlbumsByUser(profileUser.getUserId()));
        req.setAttribute("photoCount", photoDAO.countPhotosByUser(profileUser.getUserId()));
        req.setAttribute("recentLogs",
                userDAO.findAuditLogsByUser(profileUser.getUserId(), 10));

        passFlash(req);
        req.getRequestDispatcher("/WEB-INF/Pages/profile.jsp").forward(req, res);   
        }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);
        User sessionUser = requireAuth(req, res);
        if (sessionUser == null) return;

        // Determine whose profile is being updated
        String targetIdParam = req.getParameter("targetUserId");
        int targetUserId = sessionUser.getUserId();

        if (targetIdParam != null && !targetIdParam.isBlank()) {
            if (!"admin".equalsIgnoreCase(sessionUser.getRole())) {
                redirect(res, req.getContextPath() + "/profile", "error", "Access denied.");
                return;
            }
            try {
                targetUserId = Integer.parseInt(targetIdParam);
            } catch (NumberFormatException e) {
                redirect(res, req.getContextPath() + "/profile", "error", "Invalid user ID.");
                return;
            }
        }

        String action = safe(req.getParameter("action"));
        if (!"updateProfile".equalsIgnoreCase(action)) {
            res.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        // Validate required fields
        String firstName = safe(req.getParameter("firstName"));
        String lastName  = safe(req.getParameter("lastName"));
        String email     = safe(req.getParameter("email"));

        if (firstName.isEmpty() || lastName.isEmpty() || email.isEmpty()) {
            redirect(res, req.getContextPath() + "/profile", "error", "First name, last name, and email are required.");
            return;
        }

        UserDAO dao = new UserDAO();

        // Check duplicate email
        if (dao.emailExistsExcluding(email, targetUserId)) {
            redirect(res, req.getContextPath() + "/profile", "error", "That email is already used by another account.");
            return;
        }

        // Build updated user
        User updated = new User();
        updated.setUserId(targetUserId);
        updated.setFirstName(firstName);
        updated.setLastName(lastName);
        updated.setEmail(email);

        // Only admin may change role
        if ("admin".equalsIgnoreCase(sessionUser.getRole())) {
            String role = safe(req.getParameter("role"));
            updated.setRole(role.isEmpty() ? "user" : role);
        } else {
            User existing = dao.findUserById(targetUserId);
            updated.setRole(existing != null ? existing.getRole() : "user");
        }

        // Optional password change
        String newPw  = safe(req.getParameter("newPassword"));
        String confPw = safe(req.getParameter("confirmPassword"));
        boolean changePw = !newPw.isEmpty();

        if (changePw) {
            if (newPw.length() < 6) {
                redirect(res, req.getContextPath() + "/profile", "error", "Password must be at least 6 characters.");
                return;
            }
            if (!newPw.equals(confPw)) {
                redirect(res, req.getContextPath() + "/profile", "error", "Passwords do not match.");
                return;
            }
            updated.setPassword(newPw);
        }

        boolean ok = dao.updateUser(updated, changePw);
        if (ok) {
            // Refresh session if user updated their own record
            if (targetUserId == sessionUser.getUserId()) {
                User refreshed = dao.findUserById(targetUserId);
                if (refreshed != null) req.getSession().setAttribute("user", refreshed);
            }
            dao.logAction(sessionUser.getUserId(), "Updated profile for user ID: " + targetUserId);

            String destination = req.getContextPath() + "/profile"
                    + (targetUserId != sessionUser.getUserId() ? "?userId=" + targetUserId : "");
            redirect(res, destination, "message", "Profile updated successfully.");
        } else {
            redirect(res, req.getContextPath() + "/profile", "error", "Update failed. Please try again.");
        }
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private User requireAuth(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect(req.getContextPath() + "/login"); return null; }
        Object u = session.getAttribute("user");
        if (!(u instanceof User)) { res.sendRedirect(req.getContextPath() + "/login"); return null; }
        return (User) u;
    }

    private void passFlash(HttpServletRequest req) {
        if (req.getParameter("message") != null) req.setAttribute("message", req.getParameter("message"));
        if (req.getParameter("error")   != null) req.setAttribute("error",   req.getParameter("error"));
    }

    private void redirect(HttpServletResponse res, String base, String key, String msg) throws IOException {
        String encoded = URLEncoder.encode(msg, StandardCharsets.UTF_8);
        res.sendRedirect(base + (base.contains("?") ? "&" : "?") + key + "=" + encoded);
    }

    private String safe(String v) { return v == null ? "" : v.trim(); }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}