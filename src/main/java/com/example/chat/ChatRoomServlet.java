package com.example.chat;

import redis.clients.jedis.Jedis;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Set;
import com.google.gson.Gson;

@WebServlet("/chatrooms")
public class ChatRoomServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try (Jedis jedis = RedisManager.getJedis()) {
            Set<String> rooms = jedis.smembers("chatrooms");
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print(new Gson().toJson(rooms));
            out.flush();
        }
    }
}
