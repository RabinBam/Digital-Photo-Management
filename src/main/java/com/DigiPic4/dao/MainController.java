package com.DigiPic4.dao;

import java.io.IOException;
<<<<<<< HEAD
import java.util.List;

import com.DigiPic4.model.Album;
import com.DigiPic4.model.Photo;
=======

>>>>>>> ef437becfd842209955dd0ce82dfeae595f55344
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
<<<<<<< HEAD
        applyNoCache(response);

=======

        applyNoCache(response);
>>>>>>> ef437becfd842209955dd0ce82dfeae595f55344
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        switch (path) {

<<<<<<< HEAD
            case "/gallery": {
                // Load user's photos for gallery
                PhotoDAO photoDAO = new PhotoDAO();
                List<Photo> photos = photoDAO.findPhotosByUserId(user.getUserId());
                request.setAttribute("photos", photos);
                forward(request, response, "gallery.jsp", "gallery");
                break;
            }

            case "/albums": {
                // Load user's albums with their photo counts
                AlbumDAO albumDAO = new AlbumDAO();
                PhotoDAO photoDAO = new PhotoDAO();
                List<Album> albums = albumDAO.findAlbumsByUserId(user.getUserId());
                request.setAttribute("albums", albums);
                // Pass photo counts per album as a separate map
                java.util.Map<Integer, Integer> photoCounts = new java.util.LinkedHashMap<>();
                for (Album a : albums) {
                    photoCounts.put(a.getAlbumId(), photoDAO.findPhotosByAlbumId(a.getAlbumId()).size());
                }
                request.setAttribute("photoCounts", photoCounts);
                forward(request, response, "albums.jsp", "albums");
                break;
            }

            case "/favorites":
=======
            case "/gallery":
                forward(request, response, "gallery.jsp", "gallery");
                break;

            case "/albums":
                forward(request, response, "albums.jsp", "albums");
                break;

            case "/favorites":
                response.sendRedirect(request.getContextPath() + "/gallery");
                break;

>>>>>>> ef437becfd842209955dd0ce82dfeae595f55344
            case "/archived":
                response.sendRedirect(request.getContextPath() + "/gallery");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/gallery");
                break;
        }
    }

<<<<<<< HEAD
    // ─── POST: handle album CRUD ───────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        applyNoCache(response);

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();
        if ("/albums".equals(path)) {
            handleAlbumPost(request, response, user);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/gallery");
    }

    private void handleAlbumPost(HttpServletRequest req, HttpServletResponse res, User user)
            throws IOException {
        String action = req.getParameter("action");
        AlbumDAO dao  = new AlbumDAO();
        UserDAO  uDAO = new UserDAO();

        if ("create".equalsIgnoreCase(action)) {
            Album a = new Album();
            a.setAlbumName(req.getParameter("albumName"));
            a.setDescription(req.getParameter("description"));
            a.setCoverImageUrl(req.getParameter("coverImageUrl"));
            a.setUserId(user.getUserId());
            int id = dao.createAlbum(a);
            if (id > 0) {
                uDAO.logAction(user.getUserId(), "Created album: " + a.getAlbumName());
            }

        } else if ("delete".equalsIgnoreCase(action)) {
            try {
                int albumId = Integer.parseInt(req.getParameter("albumId"));
                if (dao.deleteAlbum(albumId, user.getUserId())) {
                    uDAO.logAction(user.getUserId(), "Deleted album ID: " + albumId);
                }
            } catch (NumberFormatException ignored) {}
        }

        res.sendRedirect(req.getContextPath() + "/albums");
    }

    private void forward(HttpServletRequest req, HttpServletResponse res,
                         String page, String activePage)
            throws ServletException, IOException {
        req.setAttribute("page", activePage);
        req.getRequestDispatcher("/" + page).forward(req, res);
=======
    private void forward(HttpServletRequest request,
                         HttpServletResponse response,
                         String page,
                         String activePage)
            throws ServletException, IOException {

        request.setAttribute("page", activePage);

        request.getRequestDispatcher("/" + page)
               .forward(request, response);
>>>>>>> ef437becfd842209955dd0ce82dfeae595f55344
    }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}