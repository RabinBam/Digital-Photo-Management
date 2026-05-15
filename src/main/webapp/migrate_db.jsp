<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.DigiPic4.dao.DBConnection" %>
<!DOCTYPE html>
<html>
<head><title>Migrate DB</title></head>
<body>
<%
    try (Connection conn = DBConnection.getConnection();
         Statement stmt = conn.createStatement()) {
        
        out.println("Applying migrations...<br>");
        
        try {
            stmt.executeUpdate("ALTER TABLE users ADD COLUMN credits INT DEFAULT 100");
            out.println("Success: Added 'credits' column to 'users' table.<br>");
        } catch (SQLException e) {
            out.println("Note: 'credits' column might already exist: " + e.getMessage() + "<br>");
        }

        out.println("Migration complete.");
    } catch(Exception e) {
        out.println("FATAL ERROR: " + e.getMessage());
        e.printStackTrace();
    }
%>
</body>
</html>
