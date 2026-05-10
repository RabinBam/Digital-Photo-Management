package com.DigiPic4.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import com.DigiPic4.dao.UserDAO;
import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/captain-cabin")
public class CaptainCabinServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);
        User sessionUser = requireAdmin(req, res);
        if (sessionUser == null) {
            return;
        }

        try {
            UserDAO dao = new UserDAO();
            String editId = req.getParameter("editId");

            if (editId != null && !editId.isBlank()) {
                try {
                    User editingUser = dao.findUserById(Integer.parseInt(editId));
                    req.setAttribute("editingUser", editingUser);
                } catch (NumberFormatException e) {
                    req.setAttribute("error", "Invalid user selected for editing.");
                }
            }

            List<User> users = dao.findAllUsers();
            req.setAttribute("users", users);

            if (req.getParameter("message") != null) {
                req.setAttribute("message", req.getParameter("message"));
            }
            if (req.getParameter("error") != null) {
                req.setAttribute("error", req.getParameter("error"));
            }

            req.getRequestDispatcher("/captainCabin.jsp").forward(req, res);
        } catch (Exception e) {
            e.printStackTrace();
            StringWriter sw = new StringWriter();
            PrintWriter pw = new PrintWriter(sw);
            e.printStackTrace(pw);
            String errorDetails = sw.toString();
            
            req.setAttribute("error", "Database Error: " + e.getClass().getName() + " - " + e.getMessage());
            System.err.println("CaptainCabin Error: " + errorDetails);
            
            try {
                req.getRequestDispatcher("/captainCabin.jsp").forward(req, res);
            } catch (Exception ex) {
                res.sendError(500, "Critical error: " + ex.getMessage());
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);
        User sessionUser = requireAdmin(req, res);
        if (sessionUser == null) {
            return;
        }

        String action = req.getParameter("action");
        UserDAO dao = new UserDAO();

        try {
            if ("create".equalsIgnoreCase(action)) {
                User user = new User();
                user.setFirstName(req.getParameter("firstName"));
                user.setLastName(req.getParameter("lastName"));
                user.setEmail(req.getParameter("email"));
                user.setPassword(req.getParameter("password"));
                user.setRole(req.getParameter("role"));

                boolean ok = dao.createUser(user);
                if (ok) {
                    dao.logAction(sessionUser.getUserId(), "Created user: " + user.getEmail());
                    redirectWithMessage(req, res, "User created successfully.", false);
                } else {
                    redirectWithMessage(req, res, "Failed to create user.", true);
                }
                return;
            }

            if ("update".equalsIgnoreCase(action)) {
                User user = new User();
                user.setUserId(Integer.parseInt(req.getParameter("userId")));
                user.setFirstName(req.getParameter("firstName"));
                user.setLastName(req.getParameter("lastName"));
                user.setEmail(req.getParameter("email"));
                user.setRole(req.getParameter("role"));

                String password = req.getParameter("password");
                boolean updatePassword = password != null && !password.isBlank();
                if (updatePassword) {
                    user.setPassword(password);
                }

                boolean ok = dao.updateUser(user, updatePassword);
                if (ok) {
                    dao.logAction(sessionUser.getUserId(), "Updated user ID: " + user.getUserId());
                    redirectWithMessage(req, res, "User updated successfully.", false);
                } else {
                    redirectWithMessage(req, res, "Failed to update user.", true);
                }
                return;
            }

            if ("delete".equalsIgnoreCase(action)) {
                int userId = Integer.parseInt(req.getParameter("userId"));
                if (userId == sessionUser.getUserId()) {
                    redirectWithMessage(req, res, "You cannot delete your own active account.", true);
                    return;
                }
                boolean ok = dao.deleteUser(userId);
                if (ok) {
                    dao.logAction(sessionUser.getUserId(), "Deleted user ID: " + userId);
                    redirectWithMessage(req, res, "User deleted successfully.", false);
                } else {
                    redirectWithMessage(req, res, "Failed to delete user.", true);
                }
                return;
            }

            redirectWithMessage(req, res, "Unsupported action.", true);
        } catch (Exception e) {
            e.printStackTrace();
            redirectWithMessage(req, res, "Operation failed due to invalid data.", true);
        }
    }

    private User requireAdmin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return null;
        }

        Object userObj = session.getAttribute("user");
        if (!(userObj instanceof User)) {
            res.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        User user = (User) userObj;
        String role = user.getRole() == null ? "" : user.getRole().trim();
        if (!"admin".equalsIgnoreCase(role)) {
            String encoded = URLEncoder.encode("Admin access is required for Captain Cabin.", StandardCharsets.UTF_8);
            res.sendRedirect(req.getContextPath() + "/gallery?error=" + encoded);
            return null;
        }
        return user;
    }

    private void redirectWithMessage(HttpServletRequest req, HttpServletResponse res, String text, boolean isError)
            throws IOException {
        String key = isError ? "error" : "message";
        String encoded = URLEncoder.encode(text, StandardCharsets.UTF_8);
        res.sendRedirect(req.getContextPath() + "/captain-cabin?" + key + "=" + encoded);
    }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}
