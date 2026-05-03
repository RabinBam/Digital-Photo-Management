package com.DigiPic4.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.DigiPic4.model.User;
import com.DigiPic4.util.PasswordUtil;

public class UserDAO {

    public boolean register(User user) {
        String sql = "INSERT INTO users(first_name,last_name,email,password,role) VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFirstName());
            ps.setString(2, user.getLastName());
            ps.setString(3, user.getEmail());
            ps.setString(4, PasswordUtil.hashPassword(user.getPassword()));
            ps.setString(5, user.getRole() == null ? "user" : user.getRole());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public User login(String email, String plainPassword) {
        String sql = "SELECT user_id, first_name, last_name, email, password, role FROM users WHERE email=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedPassword = rs.getString("password");
                if (PasswordUtil.verifyPassword(plainPassword, storedPassword)) {
                    return mapUser(rs, false);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public User findUserByEmail(String email) {
        String sql = "SELECT user_id, first_name, last_name, email, role FROM users WHERE email=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs, false);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updatePasswordById(int userId, String plainPassword) {
        String sql = "UPDATE users SET password=? WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, PasswordUtil.hashPassword(plainPassword));
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<User> findAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT user_id, first_name, last_name, email, role FROM users ORDER BY user_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                users.add(mapUser(rs, false));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }

    public User findUserById(int userId) {
        String sql = "SELECT user_id, first_name, last_name, email, role FROM users WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs, false);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createUser(User user) {
        return register(user);
    }

    public boolean updateUser(User user, boolean updatePassword) {
        String sql = updatePassword
                ? "UPDATE users SET first_name=?, last_name=?, email=?, password=?, role=? WHERE user_id=?"
                : "UPDATE users SET first_name=?, last_name=?, email=?, role=? WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFirstName());
            ps.setString(2, user.getLastName());
            ps.setString(3, user.getEmail());

            if (updatePassword) {
                ps.setString(4, PasswordUtil.hashPassword(user.getPassword()));
                ps.setString(5, user.getRole());
                ps.setInt(6, user.getUserId());
            } else {
                ps.setString(4, user.getRole());
                ps.setInt(5, user.getUserId());
            }

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void logAction(int userId, String actionDetails) {
        String sql = "INSERT INTO audit_logs(user_id, action_details, log_time) VALUES (?, ?, NOW())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, actionDetails);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private User mapUser(ResultSet rs, boolean withPassword) throws Exception {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setFirstName(rs.getString("first_name"));
        user.setLastName(rs.getString("last_name"));
        user.setEmail(rs.getString("email"));
        user.setRole(rs.getString("role"));
        if (withPassword) {
            user.setPassword(rs.getString("password"));
        }
        return user;
    }
}