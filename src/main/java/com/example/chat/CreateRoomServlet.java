package com.example.chat;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

// 映射路径 /createRoom
@WebServlet("/createRoom")
public class CreateRoomServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 从请求参数获取聊天室名
        String roomName = req.getParameter("roomName");

        if (roomName == null || roomName.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("聊天室名不能为空");
            return;
        }

        roomName = roomName.trim();

        // 这里调用你自己的聊天室管理类添加聊天室
        // 下面是示范调用，替换成你的实现
        boolean created = ChatRoomManager.addChatRoom(roomName);

        if (created) {
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write("聊天室创建成功");
        } else {
            resp.setStatus(HttpServletResponse.SC_CONFLICT);
            resp.getWriter().write("聊天室已存在");
        }
    }
}
