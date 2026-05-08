package com.DigiPic4.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.DigiPic4.model.AuditLog;
import com.DigiPic4.model.User;
import com.DigiPic4.util.PasswordUtil;

public class UserDAO {

    // ─── AUTHENTICATION ───────────────────────────────────────────────────────

    public boolean register(User user) {
        String sql = "INSERT INTO users(first_name, last_name, email, password, role) VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trim(user.getFirstName()));
            ps.setString(2, trim(user.getLastName()));
            ps.setString(3, trim(user.getEmail()));
            ps.setString(4, PasswordUtil.hashPassword(user.getPassword()));
            ps.setString(5, user.getRole() == null ? "user" : user.getRole().trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public User login(String email, String plainPassword) {
        String sql = "SELECT user_id, first_name, last_name, email, password, role FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trim(email));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String stored = rs.getString("password");
                    if (PasswordUtil.verifyPassword(plainPassword, stored)) {
                        return mapUser(rs, false);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean emailExists(String email) {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trim(email));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean emailExistsExcluding(String email, int excludeUserId) {
        String sql = "SELECT 1 FROM users WHERE email = ? AND user_id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trim(email));
            ps.setInt(2, excludeUserId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─── READ ─────────────────────────────────────────────────────────────────

    public User findUserByEmail(String email) {
        String sql = "SELECT user_id, first_name, last_name, email, role FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trim(email));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapUser(rs, false);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User findUserById(int userId) {
        String sql = "SELECT user_id, first_name, last_name, email, role FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapUser(rs, false);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<User> findAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT user_id, first_name, last_name, email, role FROM users ORDER BY user_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) users.add(mapUser(rs, false));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }

    public int countUsers() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ─── WRITE ────────────────────────────────────────────────────────────────

    public boolean createUser(User user) {
        return register(user);
    }

    public boolean updateUser(User user, boolean updatePassword) {
        // Guard: check for duplicate email from a different user
        if (emailExistsExcluding(user.getEmail(), user.getUserId())) {
            return false;
        }
        String sql = updatePassword
                ? "UPDATE users SET first_name=?, last_name=?, email=?, password=?, role=? WHERE user_id=?"
                : "UPDATE users SET first_name=?, last_name=?, email=?, role=? WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trim(user.getFirstName()));
            ps.setString(2, trim(user.getLastName()));
            ps.setString(3, trim(user.getEmail()));
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

    // ─── AUDIT LOGS ───────────────────────────────────────────────────────────

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

    /** All audit logs with joined user email, newest first. */
    public List<AuditLog> findAllAuditLogs(int limit) {
        List<AuditLog> logs = new ArrayList<>();
        String sql = "SELECT a.log_id, a.user_id, u.email, a.action_details, a.log_time " +
                     "FROM audit_logs a LEFT JOIN users u ON a.user_id = u.user_id " +
                     "ORDER BY a.log_time DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) logs.add(mapLog(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return logs;
    }

    /** Audit logs for a single user. */
    public List<AuditLog> findAuditLogsByUser(int userId, int limit) {
        List<AuditLog> logs = new ArrayList<>();
        String sql = "SELECT a.log_id, a.user_id, u.email, a.action_details, a.log_time " +
                     "FROM audit_logs a LEFT JOIN users u ON a.user_id = u.user_id " +
                     "WHERE a.user_id = ? ORDER BY a.log_time DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) logs.add(mapLog(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return logs;
    }

    // ─── PRIVATE HELPERS ──────────────────────────────────────────────────────

    private User mapUser(ResultSet rs, boolean withPassword) throws Exception {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFirstName(rs.getString("first_name"));
        u.setLastName(rs.getString("last_name"));
        u.setEmail(rs.getString("email"));
        u.setRole(rs.getString("role"));
        if (withPassword) u.setPassword(rs.getString("password"));
        return u;
    }

    private AuditLog mapLog(ResultSet rs) throws Exception {
        AuditLog log = new AuditLog();
        log.setLogId(rs.getInt("log_id"));
        log.setUserId(rs.getInt("user_id"));
        log.setUserEmail(rs.getString("email"));
        log.setActionDetails(rs.getString("action_details"));
        log.setLogTime(rs.getTimestamp("log_time"));
        return log;
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }
}