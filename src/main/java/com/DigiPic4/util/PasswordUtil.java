package com.DigiPic4.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

public final class PasswordUtil {

    private PasswordUtil() {
    }

    public static String hashPassword(String plainPassword) {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);

        byte[] hash = sha256(salt, plainPassword);
        return Base64.getEncoder().encodeToString(salt) + ":" + Base64.getEncoder().encodeToString(hash);
    }

    public static boolean verifyPassword(String plainPassword, String storedPassword) {
        if (storedPassword == null || !storedPassword.contains(":")) {
            return false;
        }

        String[] parts = storedPassword.split(":", 2);
        byte[] salt = Base64.getDecoder().decode(parts[0]);
        byte[] expectedHash = Base64.getDecoder().decode(parts[1]);
        byte[] providedHash = sha256(salt, plainPassword);

        if (expectedHash.length != providedHash.length) {
            return false;
        }

        int result = 0;
        for (int i = 0; i < expectedHash.length; i++) {
            result |= expectedHash[i] ^ providedHash[i];
        }
        return result == 0;
    }

    private static byte[] sha256(byte[] salt, String plainPassword) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            digest.update(salt);
            return digest.digest(plainPassword.getBytes(StandardCharsets.UTF_8));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 algorithm is unavailable", e);
        }
    }
}
