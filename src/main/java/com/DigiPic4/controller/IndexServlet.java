package com.DigiPic4.controller;

import java.io.IOException;

import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "", "/index" })
public class IndexServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);

        // If already logged in, skip the landing page
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user != null) {
            String role = user.getRole() == null ? "" : user.getRole().trim();
            res.sendRedirect(req.getContextPath()
                    + ("admin".equalsIgnoreCase(role) ? "/captain-cabin" : "/gallery"));
            return;
        }

        req.getRequestDispatcher("/WEB-INF/Pages/index.jsp").forward(req, res);
    }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}