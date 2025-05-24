package com.example.chat;

import redis.clients.jedis.Jedis;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/deleteRoom")
public class DeleteRoomServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String roomName = req.getParameter("roomName");
        if (roomName == null || roomName.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "房间名不能为空");
            return;
        }

        try (Jedis jedis = RedisManager.getJedis()) {
            // 删除聊天室相关数据
            long result = jedis.srem("chatrooms", roomName);
            if (result == 0) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "聊天室不存在");
                return;
            }

            // 删除聊天消息历史
            jedis.del("chatroom:" + roomName + ":messages");

            // 删除在线用户集合
            jedis.del(String.format(ChatWebSocket.ONLINE_USERS_KEY, roomName));

            // 广播房间已删除消息
            String deleteMsg = "系统|聊天室已被删除|00:00:00";
            jedis.publish("channel:chatroom:" + roomName, deleteMsg);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "删除聊天室失败");
            return;
        }

        resp.setStatus(HttpServletResponse.SC_OK);
        resp.getWriter().write("聊天室已成功删除");
    }
}