package com.qst.entity;
import java.util.List;
import java.util.Set;

public class User {

    private String username;//用户姓名
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username == null ? null : username.trim();
    }

}
