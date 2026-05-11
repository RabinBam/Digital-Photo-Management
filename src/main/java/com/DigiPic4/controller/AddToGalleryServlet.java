package com.DigiPic4.controller;

import java.io.IOException;
import java.util.List;

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

@WebServlet("/addToGallery")
public class AddToGalleryServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");

        // Auth check
        HttpSession session = req.getSession(false);
        if (session == null || !(session.getAttribute("user") instanceof User)) {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            res.getWriter().write("{\"success\":false,\"message\":\"Not logged in\"}");
            return;
        }
        User user = (User) session.getAttribute("user");

        String imageUrl = req.getParameter("imageUrl");
        String title    = req.getParameter("title");

        if (imageUrl == null || imageUrl.isBlank()) {
            res.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            res.getWriter().write("{\"success\":false,\"message\":\"No image URL provided\"}");
            return;
        }
        if (title == null || title.isBlank()) title = "Explore Import";

        // Find or auto-create the "Explore Imports" album
        AlbumDAO albumDAO = new AlbumDAO();
        int albumId = -1;

        List<Album> albums = albumDAO.findAlbumsByUserId(user.getUserId());
        for (Album a : albums) {
            if ("Explore Imports".equalsIgnoreCase(a.getAlbumName())) {
                albumId = a.getAlbumId();
                break;
            }
        }

        if (albumId < 0) {
            Album newAlbum = new Album();
            newAlbum.setAlbumName("Explore Imports");
            newAlbum.setDescription("Photos saved from the Explore page.");
            newAlbum.setUserId(user.getUserId());
            albumId = albumDAO.createAlbum(newAlbum);
        }

        if (albumId < 0) {
            res.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            res.getWriter().write("{\"success\":false,\"message\":\"Could not create album\"}");
            return;
        }

        // Persist photo — file_path stores the full external URL
        PhotoDAO photoDAO = new PhotoDAO();
        Photo photo = new Photo();
        photo.setTitle(title);
        photo.setFilePath(imageUrl);   // external URL stored directly
        photo.setAlbumId(albumId);

        int newId = photoDAO.addPhoto(photo);
        if (newId > 0) {
            new UserDAO().logAction(user.getUserId(), "Saved from Explore: " + title);
            res.getWriter().write("{\"success\":true,\"message\":\"Saved to your gallery!\"}");
        } else {
            res.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            res.getWriter().write("{\"success\":false,\"message\":\"Database error — try again\"}");
        }
    }
}