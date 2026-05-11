package com.DigiPic4.controller;

import java.io.IOException;
import java.security.SecureRandom;

import com.DigiPic4.dao.UserDAO;
import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private static final String RESET_EMAIL = "resetEmail";
    private static final String RESET_CODE = "resetCode";
    private static final String RESET_USER_ID = "resetUserId";
    private static final String RESET_EXPIRES_AT = "resetExpiresAt";
    private static final long RESET_TTL_MS = 5 * 60 * 1000L;
    private static final SecureRandom RANDOM = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);
        req.getRequestDispatcher("/WEB-INF/Pages/forgot-password.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);

        String action = safe(req.getParameter("action"));
        if ("reset".equalsIgnoreCase(action)) {
            handleReset(req, res);
            return;
        }

        handleRequest(req, res);
    }

    private void handleRequest(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String email = safe(req.getParameter("email"));
        if (email.isEmpty()) {
            req.setAttribute("error", "Please enter your email address.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, res);
            return;
        }

        UserDAO dao = new UserDAO();
        User user = dao.findUserByEmail(email);
        if (user == null) {
            req.setAttribute("error", "No account was found for that email address.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, res);
            return;
        }

        String resetCode = generateResetCode();
        HttpSession session = req.getSession(true);
        session.setAttribute(RESET_EMAIL, user.getEmail());
        session.setAttribute(RESET_CODE, resetCode);
        session.setAttribute(RESET_USER_ID, user.getUserId());
        session.setAttribute(RESET_EXPIRES_AT, System.currentTimeMillis() + RESET_TTL_MS);
        session.setMaxInactiveInterval(10 * 60);

        req.setAttribute("message", "Reset code generated. Enter the code below to set a new password.");
        req.setAttribute("generatedCode", resetCode);
        req.setAttribute("email", user.getEmail());
        req.getRequestDispatcher("/forgot-password.jsp").forward(req, res);
    }

    private void handleReset(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute(RESET_CODE) == null) {
            req.setAttribute("error", "Your reset session expired. Please request a new code.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, res);
            return;
        }

        long expiresAt = (long) session.getAttribute(RESET_EXPIRES_AT);
        if (System.currentTimeMillis() > expiresAt) {
            clearResetSession(session);
            req.setAttribute("error", "Your reset code expired. Please request a new one.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, res);
            return;
        }

        String submittedCode = safe(req.getParameter("code"));
        String storedCode = String.valueOf(session.getAttribute(RESET_CODE));
        if (!storedCode.equals(submittedCode)) {
            req.setAttribute("error", "Invalid reset code.");
            req.setAttribute("generatedCode", storedCode);
            req.setAttribute("email", session.getAttribute(RESET_EMAIL));
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, res);
            return;
        }

        String newPassword = safe(req.getParameter("newPassword"));
        String confirmPassword = safe(req.getParameter("confirmPassword"));
        if (newPassword.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters long.");
            req.setAttribute("generatedCode", storedCode);
            req.setAttribute("email", session.getAttribute(RESET_EMAIL));
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, res);
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match.");
            req.setAttribute("generatedCode", storedCode);
            req.setAttribute("email", session.getAttribute(RESET_EMAIL));
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, res);
            return;
        }

        int userId = (int) session.getAttribute(RESET_USER_ID);
        UserDAO dao = new UserDAO();
        boolean updated = dao.updatePasswordById(userId, newPassword);
        if (!updated) {
            req.setAttribute("error", "Unable to update your password right now.");
            req.setAttribute("generatedCode", storedCode);
            req.setAttribute("email", session.getAttribute(RESET_EMAIL));
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, res);
            return;
        }

        dao.logAction(userId, "Password reset via forgot-password flow");
        clearResetSession(session);
        res.sendRedirect(req.getContextPath() + "/login?success=Password updated successfully. Please log in.");
    }

    private void clearResetSession(HttpSession session) {
        session.removeAttribute(RESET_EMAIL);
        session.removeAttribute(RESET_CODE);
        session.removeAttribute(RESET_USER_ID);
        session.removeAttribute(RESET_EXPIRES_AT);
    }

    private String generateResetCode() {
        return String.format("%06d", RANDOM.nextInt(1_000_000));
    }

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}
