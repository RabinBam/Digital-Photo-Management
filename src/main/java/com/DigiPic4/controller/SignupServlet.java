package com.DigiPic4.controller;

import java.io.IOException;

import com.DigiPic4.dao.UserDAO;
import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);
        if (req.getSession(false) != null && req.getSession(false).getAttribute("user") != null) {
            res.sendRedirect(req.getContextPath() + "/gallery");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/Pages/signup.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        User user = new User();
        String firstName = req.getParameter("firstName");
        String lastName = req.getParameter("lastName");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        user.setFirstName(firstName == null ? null : firstName.trim());
        user.setLastName(lastName == null ? null : lastName.trim());
        user.setEmail(email == null ? null : email.trim());
        user.setPassword(password == null ? null : password.trim());
        user.setRole("user");

        if (user.getFirstName() == null || user.getFirstName().isBlank()
                || user.getLastName() == null || user.getLastName().isBlank()
                || user.getEmail() == null || user.getEmail().isBlank()
                || user.getPassword() == null || user.getPassword().isBlank()) {
            req.setAttribute("error", "Please complete every field.");
            applyNoCache(res);
            req.getRequestDispatcher("/signup.jsp").forward(req, res);
            return;
        }

        UserDAO dao = new UserDAO();
        if (dao.emailExists(user.getEmail())) {
            req.setAttribute("error", "That email address is already registered.");
            applyNoCache(res);
            req.getRequestDispatcher("/signup.jsp").forward(req, res);
            return;
        }

        boolean success = dao.register(user);

        if (success) {
            res.sendRedirect(req.getContextPath() + "/login?success=Account created. Please login.");
        } else {
            applyNoCache(res);
            req.setAttribute("error", "Unable to create account. Email may already exist.");
            req.getRequestDispatcher("/signup.jsp").forward(req, res);
        }
    }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}
