package com.DigiPic4.controller;   // ← BUG FIX: was wrongly in com.DigiPic4.dao

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;

import com.DigiPic4.dao.AlbumDAO;
import com.DigiPic4.dao.PhotoDAO;
import com.DigiPic4.dao.UserDAO;
import com.DigiPic4.model.Album;
import com.DigiPic4.model.Photo;
import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/gallery", "/albums", "/favorites", "/archived", "/about", "/contact"})
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
            case "/gallery": {
                PhotoDAO photoDAO = new PhotoDAO();
                List<Photo> photos = photoDAO.findPhotosByUserId(user.getUserId());
                request.setAttribute("photos", photos);
                forward(request, response, "gallery.jsp", "gallery");
                break;
            }

            case "/albums": {
                AlbumDAO albumDAO = new AlbumDAO();
                PhotoDAO photoDAO = new PhotoDAO();
                List<Album> albums = albumDAO.findAlbumsByUserId(user.getUserId());

                Map<Integer, List<Photo>> albumPhotosMap = new LinkedHashMap<>();
                for (Album a : albums) {
                    albumPhotosMap.put(a.getAlbumId(), photoDAO.findPhotosByAlbumId(a.getAlbumId()));
                }

                request.setAttribute("albums", albums);
                request.setAttribute("albumPhotosMap", albumPhotosMap);
                forward(request, response, "albums.jsp", "albums");
                break;
            }

            case "/about":
                forward(request, response, "about.jsp", "about");
                break;
                
            case "/contact":
                forward(request, response, "contact.jsp", "contact");
                break;

            case "/favorites":
            case "/archived":
            default:
                response.sendRedirect(request.getContextPath() + "/gallery");
                break;
        }
    }

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
            // Enforce 3-album limit
            int existingCount = dao.countAlbumsByUser(user.getUserId());
            if (existingCount < 3) {
                Album a = new Album();
                a.setAlbumName(req.getParameter("albumName"));
                a.setDescription(req.getParameter("description"));
                a.setCoverImageUrl(req.getParameter("coverImageUrl"));
                a.setUserId(user.getUserId());
                int id = dao.createAlbum(a);
                if (id > 0) {
                    uDAO.logAction(user.getUserId(), "Created album: " + a.getAlbumName());
                }
            } else {
                // Limit reached - we could set an error attribute or just ignore
                req.getSession().setAttribute("albumError", "Album limit reached (Max 3).");
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
req.getRequestDispatcher("/WEB-INF/Pages/" + page).forward(req, res);
}
    
    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}
