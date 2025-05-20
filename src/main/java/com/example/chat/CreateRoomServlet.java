package com.example.chat;

import redis.clients.jedis.Jedis;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/createRoom")
public class CreateRoomServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String roomName = req.getParameter("roomName");
        if (roomName == null || roomName.trim().isEmpty()) {
            resp.sendError(400, "房间名不能为空");
            return;
        }
        try (Jedis jedis = RedisManager.getJedis()) {
            jedis.sadd("chatrooms", roomName);
        }
        resp.setStatus(200);
    }
}
