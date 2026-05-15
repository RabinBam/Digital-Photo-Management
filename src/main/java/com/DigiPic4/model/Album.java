package com.DigiPic4.model;


public class Album {
    private int albumId;
    private int userId;
    private String albumName;
    private String description;
    private String coverImageUrl;
    private int photoCount;

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

    public int getPhotoCount()                    { return photoCount; }
    public void setPhotoCount(int photoCount)     { this.photoCount = photoCount; }


}