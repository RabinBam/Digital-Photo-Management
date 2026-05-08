package com.DigiPic4.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.DigiPic4.model.Photo;

public class PhotoDAO {

    public List<Photo> findPhotosByAlbumId(int albumId) {
        List<Photo> photos = new ArrayList<>();
        String sql = "SELECT photo_id, title, file_path, album_id, aperture, shutter_speed, " +
                     "iso, focal_length, location_tag FROM photos WHERE album_id = ? ORDER BY photo_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, albumId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) photos.add(mapPhoto(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return photos;
    }

    /** Fetch all photos belonging to a user (joined through albums). */
    public List<Photo> findPhotosByUserId(int userId) {
        List<Photo> photos = new ArrayList<>();
        String sql = "SELECT p.photo_id, p.title, p.file_path, p.album_id, p.aperture, " +
                     "p.shutter_speed, p.iso, p.focal_length, p.location_tag " +
                     "FROM photos p INNER JOIN albums a ON p.album_id = a.album_id " +
                     "WHERE a.user_id = ? ORDER BY p.photo_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) photos.add(mapPhoto(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return photos;
    }

    public Photo findPhotoById(int photoId) {
        String sql = "SELECT photo_id, title, file_path, album_id, aperture, shutter_speed, " +
                     "iso, focal_length, location_tag FROM photos WHERE photo_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, photoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapPhoto(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Returns generated photo_id or -1. */
    public int addPhoto(Photo photo) {
        String sql = "INSERT INTO photos(title, file_path, album_id, aperture, shutter_speed, " +
                     "iso, focal_length, location_tag) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, photo.getTitle());
            ps.setString(2, photo.getFilePath());
            ps.setInt(3, photo.getAlbumId());
            ps.setString(4, photo.getAperture());
            ps.setString(5, photo.getShutterSpeed());
            ps.setString(6, photo.getIso());
            ps.setString(7, photo.getFocalLength());
            ps.setString(8, photo.getLocationTag());
            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) return keys.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean deletePhoto(int photoId) {
        String sql = "DELETE FROM photos WHERE photo_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, photoId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countPhotosByUser(int userId) {
        String sql = "SELECT COUNT(*) FROM photos p INNER JOIN albums a ON p.album_id = a.album_id " +
                     "WHERE a.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Photo mapPhoto(ResultSet rs) throws Exception {
        Photo p = new Photo();
        p.setPhotoId(rs.getInt("photo_id"));
        p.setTitle(rs.getString("title"));
        p.setFilePath(rs.getString("file_path"));
        p.setAlbumId(rs.getInt("album_id"));
        p.setAperture(rs.getString("aperture"));
        p.setShutterSpeed(rs.getString("shutter_speed"));
        p.setIso(rs.getString("iso"));
        p.setFocalLength(rs.getString("focal_length"));
        p.setLocationTag(rs.getString("location_tag"));
        return p;
    }
}