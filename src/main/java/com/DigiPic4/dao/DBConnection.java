package com.DigiPic4.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Simple connection pool for MySQL.
 * Replaces the old single-connection approach that caused slow page loads.
 *
 * Drop-in replacement: callers still use DBConnection.getConnection()
 * and must close() the returned Connection when done (try-with-resources).
 */
public class DBConnection {

    // ── Configuration ─────────────────────────────────────────────────────────
    private static final String URL      = "jdbc:mysql://localhost:3306/digipic_db"
            + "?useSSL=false&allowPublicKeyRetrieval=true"
            + "&serverTimezone=UTC"
            + "&autoReconnect=true"
            + "&cachePrepStmts=true"
            + "&useServerPrepStmts=true"
            + "&prepStmtCacheSize=250"
            + "&prepStmtCacheSqlLimit=2048";
    private static final String USER     = "root";
    private static final String PASSWORD = "";

    // Pool settings
    private static final int POOL_SIZE   = 10;   // max concurrent connections
    private static final int TIMEOUT_MS  = 5000; // wait up to 5 s for a free slot

    // ── Pool state ─────────────────────────────────────────────────────────────
    private static final List<Connection> pool      = new ArrayList<>();
    private static final List<Connection> usedList  = new ArrayList<>();
    private static boolean initialized = false;

    // ── Init ───────────────────────────────────────────────────────────────────
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            for (int i = 0; i < POOL_SIZE; i++) {
                pool.add(createFreshConnection());
            }
            initialized = true;
            System.out.println("[DBPool] Initialized " + POOL_SIZE + " connections.");
        } catch (Exception e) {
            System.err.println("[DBPool] INIT FAILED: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static Connection createFreshConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // ── Public API ─────────────────────────────────────────────────────────────

    /**
     * Borrow a connection from the pool.
     * The caller MUST call conn.close() (or use try-with-resources)
     * which returns it to the pool instead of closing it.
     */
    public static synchronized Connection getConnection() {
        if (!initialized) {
            // Fallback: direct connection if pool failed to init
            try {
                return DriverManager.getConnection(URL, USER, PASSWORD);
            } catch (SQLException e) {
                throw new RuntimeException("DB unavailable and pool not initialized.", e);
            }
        }

        long deadline = System.currentTimeMillis() + TIMEOUT_MS;
        while (pool.isEmpty()) {
            long remaining = deadline - System.currentTimeMillis();
            if (remaining <= 0) {
                throw new RuntimeException("Connection pool exhausted – no free connection after " + TIMEOUT_MS + " ms.");
            }
            try { DBConnection.class.wait(remaining); } catch (InterruptedException ignored) { Thread.currentThread().interrupt(); }
        }

        Connection conn = pool.remove(pool.size() - 1);

        // Validate; replace dead connections transparently
        try {
            if (conn == null || conn.isClosed() || !conn.isValid(2)) {
                conn = createFreshConnection();
            }
        } catch (SQLException e) {
            try { conn = createFreshConnection(); } catch (SQLException ex) {
                throw new RuntimeException("Cannot create replacement connection.", ex);
            }
        }

        usedList.add(conn);
        return wrapConnection(conn);
    }

    // Return a connection back to the pool (called by the wrapper's close())
    static synchronized void returnConnection(Connection conn) {
        usedList.remove(conn);
        pool.add(conn);
        DBConnection.class.notifyAll();
    }

    // ── Wrapper ────────────────────────────────────────────────────────────────

    /**
     * Wraps a real connection so that calling close() returns it to the pool
     * rather than actually closing the underlying socket.
     */
    private static Connection wrapConnection(final Connection real) {
        return (Connection) java.lang.reflect.Proxy.newProxyInstance(
            Connection.class.getClassLoader(),
            new Class[]{ Connection.class },
            (proxy, method, args) -> {
                if ("close".equals(method.getName())) {
                    returnConnection(real);
                    return null;
                }
                if ("isClosed".equals(method.getName())) {
                    return real.isClosed();
                }
                try {
                    return method.invoke(real, args);
                } catch (java.lang.reflect.InvocationTargetException e) {
                    throw e.getCause();
                }
            }
        );
    }
}
