package com.DigiPic4.controller;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.DigiPic4.dao.AlbumDAO;
import com.DigiPic4.dao.PhotoDAO;
import com.DigiPic4.dao.UserDAO;
import com.DigiPic4.model.Album;
import com.DigiPic4.model.AuditLog;
import com.DigiPic4.model.Photo;
import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/usage")
public class UsageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        applyNoCache(res);
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) { res.sendRedirect(req.getContextPath() + "/login"); return; }

        AlbumDAO albumDAO = new AlbumDAO();
        PhotoDAO photoDAO = new PhotoDAO();
        UserDAO  userDAO  = new UserDAO();

        List<Album> albums   = albumDAO.findAlbumsByUserId(user.getUserId());
        List<Photo> allPhotos = photoDAO.findPhotosByUserId(user.getUserId());
        List<AuditLog> recentLogs = userDAO.findAuditLogsByUser(user.getUserId(), 15);

        // Build photos-per-album map (label → count) for chart
        Map<String, Integer> photosPerAlbum = new LinkedHashMap<>();
        for (Album a : albums) {
            List<Photo> ap = photoDAO.findPhotosByAlbumId(a.getAlbumId());
            photosPerAlbum.put(a.getAlbumName(), ap.size());
        }

        // Build camera metadata counts for bar chart
        int withAperture  = (int) allPhotos.stream().filter(p -> p.getAperture()    != null && !p.getAperture().isEmpty()).count();
        int withISO       = (int) allPhotos.stream().filter(p -> p.getIso()         != null && !p.getIso().isEmpty()).count();
        int withShutter   = (int) allPhotos.stream().filter(p -> p.getShutterSpeed()!= null && !p.getShutterSpeed().isEmpty()).count();
        int withFocal     = (int) allPhotos.stream().filter(p -> p.getFocalLength() != null && !p.getFocalLength().isEmpty()).count();

        req.setAttribute("totalAlbums",   albums.size());
        req.setAttribute("totalPhotos",   allPhotos.size());
        req.setAttribute("photosPerAlbum", photosPerAlbum);
        req.setAttribute("recentLogs",    recentLogs);
        req.setAttribute("withAperture",  withAperture);
        req.setAttribute("withISO",       withISO);
        req.setAttribute("withShutter",   withShutter);
        req.setAttribute("withFocal",     withFocal);
        req.setAttribute("page", "usage");
        req.getRequestDispatcher("/WEB-INF/Pages/usage.jsp").forward(req, res);
    }

    private void applyNoCache(HttpServletResponse res) {
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
    }
}
