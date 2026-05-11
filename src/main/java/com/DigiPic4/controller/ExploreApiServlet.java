package com.DigiPic4.controller;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import com.DigiPic4.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/api/explore")
public class ExploreApiServlet extends HttpServlet {

    // ── TODO: Paste your actual RapidAPI key here ──────────────────────────
    private static final String RAPIDAPI_KEY = "88689ceb4bmsh4efdac04205e16fp12e25djsn09594386af7";
    // ───────────────────────────────────────────────────────────────────────

    private static final String API_HOST =
            "unsplash-image-search-api.p.rapidapi.com";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        // Must be logged in
        HttpSession session = req.getSession(false);
        if (session == null || !(session.getAttribute("user") instanceof User)) {
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Login required");
            return;
        }

        String query = req.getParameter("query");
        String page  = req.getParameter("page");
        if (query == null || query.isBlank()) query = "ocean";
        if (page  == null || page.isBlank())  page  = "1";

        String apiUrl = "https://" + API_HOST + "/search?page="
                + URLEncoder.encode(page,  StandardCharsets.UTF_8)
                + "&query="
                + URLEncoder.encode(query, StandardCharsets.UTF_8);

        HttpURLConnection conn = null;
        try {
            conn = (HttpURLConnection) new URL(apiUrl).openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Content-Type",    "application/json");
            conn.setRequestProperty("x-rapidapi-host", API_HOST);
            conn.setRequestProperty("x-rapidapi-key",  RAPIDAPI_KEY);
            conn.setConnectTimeout(10_000);
            conn.setReadTimeout(10_000);

            int status = conn.getResponseCode();
            res.setContentType("application/json");
            res.setCharacterEncoding("UTF-8");
            res.setStatus(status);

            InputStream is = (status >= 200 && status < 300)
                    ? conn.getInputStream()
                    : conn.getErrorStream();

            if (is != null) {
                byte[] buf = new byte[8192];
                int read;
                while ((read = is.read(buf)) != -1) {
                    res.getOutputStream().write(buf, 0, read);
                }
            }
        } finally {
            if (conn != null) conn.disconnect();
        }
    }
}