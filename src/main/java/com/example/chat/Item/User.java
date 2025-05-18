package com.example.chat.Item;

import java.io.Serializable;

public class User implements Serializable {
    private String id;
    private String name;
    private String password;
    private String email;
    private String img;

    public User() {}

    public User(String id, String name, String email, String password,  String img) {
        this.id=id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.img = img;
    }

    public String getId() {
        return id;
    }

    public String getImg() {
        return img;
    }

    public String getName() {
        return name;
    }

    public String getPassword() {
        return password;
    }

    public String getEmail() {
        return email;
    }


    public void setImg(String img) {
        this.img = img;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
