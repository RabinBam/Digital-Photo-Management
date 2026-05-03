CREATE DATABASE IF NOT EXISTS digipic_db;
USE digipic_db;

CREATE TABLE IF NOT EXISTS users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(30) DEFAULT 'user'
);

CREATE TABLE IF NOT EXISTS albums (
  album_id INT PRIMARY KEY AUTO_INCREMENT,
  album_name VARCHAR(255) NOT NULL,
  description TEXT,
  cover_image_url VARCHAR(255),
  user_id INT,
  CONSTRAINT fk_albums_user FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS photos (
  photo_id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255),
  file_path VARCHAR(500),
  album_id INT,
  aperture VARCHAR(50),
  shutter_speed VARCHAR(50),
  iso VARCHAR(50),
  focal_length VARCHAR(50),
  location_tag VARCHAR(255),
  CONSTRAINT fk_photos_album FOREIGN KEY (album_id) REFERENCES albums(album_id)
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS audit_logs (
  log_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  action_details VARCHAR(500),
  log_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE SET NULL ON UPDATE CASCADE
);

-- Safe migration helpers for older schemas
ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(30) DEFAULT 'user';
