package com.example.chat;

import redis.clients.jedis.Jedis;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/createRoom")
public class CreateRoomServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String roomName = req.getParameter("roomName");
        if (roomName == null || roomName.trim().isEmpty()) {
            resp.sendError(400, "房间名不能为空");
            return;
        }
        try (Jedis jedis = RedisManager.getJedis()) {
            //检查聊天室是否已经存在
            if (jedis.sismember("chatrooms", roomName)) {
                resp.setStatus(HttpServletResponse.SC_CONFLICT); // 409 Conflict
                resp.setContentType("application/json;charset=UTF-8");
                PrintWriter out = resp.getWriter();
                out.write("{\"error\": \"该聊天室已存在，无法创建\"}");
                out.flush();
                return;
            }
            jedis.sadd("chatrooms", roomName);
        }
        resp.setStatus(200);
    }
}
