package com.DigiPic4.model;

public class Photo {
    private int photoId;
    private int albumId;
    private String title;
    private String filePath;
    private String aperture;
    private String shutterSpeed;
    private String iso;
    private String focalLength;
    private String locationTag;

    public int getPhotoId()                         { return photoId; }
    public void setPhotoId(int photoId)             { this.photoId = photoId; }

    public int getAlbumId()                         { return albumId; }
    public void setAlbumId(int albumId)             { this.albumId = albumId; }

    public String getTitle()                        { return title; }
    public void setTitle(String title)              { this.title = title; }

    public String getFilePath()                     { return filePath; }
    public void setFilePath(String filePath)        { this.filePath = filePath; }

    public String getAperture()                     { return aperture; }
    public void setAperture(String aperture)        { this.aperture = aperture; }

    public String getShutterSpeed()                 { return shutterSpeed; }
    public void setShutterSpeed(String shutterSpeed){ this.shutterSpeed = shutterSpeed; }

    public String getIso()                          { return iso; }
    public void setIso(String iso)                  { this.iso = iso; }

    public String getFocalLength()                  { return focalLength; }
    public void setFocalLength(String focalLength)  { this.focalLength = focalLength; }

    public String getLocationTag()                  { return locationTag; }
    public void setLocationTag(String locationTag)  { this.locationTag = locationTag; }
}