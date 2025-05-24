package com.example.chat;

import redis.clients.jedis.Jedis;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

@WebServlet("/onlineCount")
public class OnlineCountServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String roomName = req.getParameter("roomName");

        resp.setContentType("application/json;charset=UTF-8");

        Map<String, Object> result = new HashMap<>();
        try (Jedis jedis = RedisManager.getJedis()) {
            if (roomName != null) {
                // 获取指定房间的在线人数
                int count = ChatWebSocket.getOnlineCount(roomName);
                result.put("count", count);
            } else {
                // 获取所有房间的在线人数
                Map<String, Integer> counts = new HashMap<>();
                // 从Redis获取所有聊天室名称
                Set<String> rooms = jedis.smembers("chatrooms");
                for (String room : rooms) {
                    counts.put(room, ChatWebSocket.getOnlineCount(room));
                }
                result.put("counts", counts);
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(500, "获取在线人数失败");
            return;
        }

        resp.getWriter().print(new com.google.gson.Gson().toJson(result));
    }
}