package com.DigiPic4.model;

<<<<<<< HEAD
public class Album {
    private int albumId;
    private int userId;
    private String albumName;
    private String description;
    private String coverImageUrl;

    public int getAlbumId()                       { return albumId; }
    public void setAlbumId(int albumId)           { this.albumId = albumId; }

    public int getUserId()                        { return userId; }
    public void setUserId(int userId)             { this.userId = userId; }

    public String getAlbumName()                  { return albumName; }
    public void setAlbumName(String albumName)    { this.albumName = albumName == null ? null : albumName.trim(); }

    public String getDescription()                { return description; }
    public void setDescription(String description){ this.description = description; }

    public String getCoverImageUrl()              { return coverImageUrl; }
    public void setCoverImageUrl(String url)      { this.coverImageUrl = url; }
=======

public class Album {
    private int id;
    private int userId;
    private String title;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }
>>>>>>> ef437becfd842209955dd0ce82dfeae595f55344
}