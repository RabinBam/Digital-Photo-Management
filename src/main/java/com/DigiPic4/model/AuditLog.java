package com.DigiPic4.model;

import java.sql.Timestamp;

public class AuditLog {
    private int logId;
    private int userId;
    private String userEmail;   // joined from users table
    private String actionDetails;
    private Timestamp logTime;

    public int getLogId()                          { return logId; }
    public void setLogId(int logId)                { this.logId = logId; }

    public int getUserId()                         { return userId; }
    public void setUserId(int userId)              { this.userId = userId; }

    public String getUserEmail()                   { return userEmail; }
    public void setUserEmail(String userEmail)     { this.userEmail = userEmail; }

    public String getActionDetails()               { return actionDetails; }
    public void setActionDetails(String actionDetails){ this.actionDetails = actionDetails; }

    public Timestamp getLogTime()                  { return logTime; }
    public void setLogTime(Timestamp logTime)      { this.logTime = logTime; }
}