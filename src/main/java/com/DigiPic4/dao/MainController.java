package com.DigiPic4.dao;

import java.io.IOException;

import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/gallery", "/albums", "/favorites", "/archived"})
public class MainController extends HttpServlet {

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

        switch (path) {

            case "/gallery":
                forward(request, response, "gallery.jsp", "gallery");
                break;

            case "/albums":
                forward(request, response, "albums.jsp", "albums");
                break;

            case "/favorites":
                response.sendRedirect(request.getContextPath() + "/gallery");
                break;

            case "/archived":
                response.sendRedirect(request.getContextPath() + "/gallery");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/gallery");
                break;
        }
    }

    private void forward(HttpServletRequest request,
                         HttpServletResponse response,
                         String page,
                         String activePage)
            throws ServletException, IOException {

        request.setAttribute("page", activePage);

        request.getRequestDispatcher("/" + page)
               .forward(request, response);
    }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}