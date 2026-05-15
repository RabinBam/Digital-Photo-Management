package com.DigiPic4.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.DigiPic4.model.Album;

public class AlbumDAO {

    public List<Album> findAlbumsByUserId(int userId) {
        List<Album> albums = new ArrayList<>();
        String sql = "SELECT a.album_id, a.album_name, a.description, a.cover_image_url, a.user_id, COUNT(p.photo_id) as photo_count " +
                     "FROM albums a LEFT JOIN photos p ON a.album_id = p.album_id " +
                     "WHERE a.user_id = ? GROUP BY a.album_id ORDER BY a.album_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) albums.add(mapAlbum(rs, true));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return albums;
    }

    public Album findAlbumById(int albumId) {
        String sql = "SELECT album_id, album_name, description, cover_image_url, user_id " +
                     "FROM albums WHERE album_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, albumId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapAlbum(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Album findAlbumById(int albumId, int ownerId) {
        String sql = "SELECT album_id, album_name, description, cover_image_url, user_id " +
                     "FROM albums WHERE album_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, albumId);
            ps.setInt(2, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapAlbum(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Returns the generated album_id, or -1 on failure. */
    public int createAlbum(Album album) {
        String sql = "INSERT INTO albums(album_name, description, cover_image_url, user_id) VALUES (?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, album.getAlbumName());
            ps.setString(2, album.getDescription());
            ps.setString(3, album.getCoverImageUrl());
            ps.setInt(4, album.getUserId());
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

    public boolean updateAlbum(Album album) {
        String sql = "UPDATE albums SET album_name=?, description=?, cover_image_url=? " +
                     "WHERE album_id=? AND user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, album.getAlbumName());
            ps.setString(2, album.getDescription());
            ps.setString(3, album.getCoverImageUrl());
            ps.setInt(4, album.getAlbumId());
            ps.setInt(5, album.getUserId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteAlbum(int albumId, int ownerId) {
        String sql = "DELETE FROM albums WHERE album_id=? AND user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, albumId);
            ps.setInt(2, ownerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countAlbumsByUser(int userId) {
        String sql = "SELECT COUNT(*) FROM albums WHERE user_id = ?";
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

    private Album mapAlbum(ResultSet rs) throws Exception {
        return mapAlbum(rs, false);
    }

    private Album mapAlbum(ResultSet rs, boolean withPhotoCount) throws Exception {
        Album a = new Album();
        a.setAlbumId(rs.getInt("album_id"));
        a.setAlbumName(rs.getString("album_name"));
        a.setDescription(rs.getString("description"));
        a.setCoverImageUrl(rs.getString("cover_image_url"));
        a.setUserId(rs.getInt("user_id"));
        if (withPhotoCount) {
            a.setPhotoCount(rs.getInt("photo_count"));
        }
        return a;
    }
}