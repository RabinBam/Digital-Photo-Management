package com.DigiPic4.controller;

import java.io.IOException;

import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/explore", "/photomap"})
public class ExploreServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        applyNoCache(response);

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        if ("/explore".equals(path)) {
            request.setAttribute("page", "explore");
            request.getRequestDispatcher("/WEB-INF/Pages/explore.jsp").forward(request, response);
        } else if ("/photomap".equals(path)) {
            request.setAttribute("page", "map");
            request.getRequestDispatcher("/WEB-INF/Pages/photomap.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/gallery");
        }
    }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}
