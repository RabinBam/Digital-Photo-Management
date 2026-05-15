package com.DigiPic4.controller;

import java.io.IOException;

import com.DigiPic4.dao.UserDAO;
import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);
        HttpSession session = req.getSession(false);
        User currentUser = session == null ? null : (User) session.getAttribute("user");
        if (currentUser != null) {
            res.sendRedirect(req.getContextPath() + dashboardPath(currentUser));
            return;
        }
        req.getRequestDispatcher("/WEB-INF/Pages/login.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email != null) {
            email = email.trim();
        }

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Please enter both email and password.");
            applyNoCache(res);
            req.getRequestDispatcher("/WEB-INF/Pages/login.jsp").forward(req, res);
            return;
        }

        UserDAO dao = new UserDAO();
        User user = dao.login(email, password);

        if (user != null) {
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession newSession = req.getSession(true);
            newSession.setAttribute("user", user);
            newSession.setMaxInactiveInterval(15 * 60);

            dao.logAction(user.getUserId(), "User logged in");
            applyNoCache(res);
            res.sendRedirect(req.getContextPath() + dashboardPath(user));
        } else {
            req.setAttribute("error", "Invalid credentials");
            applyNoCache(res);
            req.getRequestDispatcher("/WEB-INF/Pages/login.jsp").forward(req, res);
        }
    }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }

    private String dashboardPath(User user) {
        String role = user.getRole() == null ? "" : user.getRole().trim();
        return "admin".equalsIgnoreCase(role) ? "/captain-cabin" : "/gallery";
    }
}