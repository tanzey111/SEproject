package com.example.chat.Servlet;

import com.example.chat.Item.User;
import com.example.chat.util.RedisUtil;
import org.mindrot.jbcrypt.BCrypt;
import redis.clients.jedis.Jedis;

import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;

@MultipartConfig
public class AlterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");
        String op = request.getParameter("op");

        if ("ChangeMsg".equals(op)) {
            changeUserInfo(request, response);
        } else if ("ChangePwd".equals(op)) {
            changePassword(request, response);
        }
    }

    private void changeUserInfo(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession();
        String oldUsername = (String) session.getAttribute("username"); // 旧用户名
        if (oldUsername == null) {
            response.sendRedirect("Sign.jsp");
            return;
        }

        User user = RedisUtil.getUserByUsername(oldUsername);
        if (user == null) {
            response.sendRedirect("Sign.jsp");
            return;
        }

        String originalEmail = user.getEmail();
        System.out.println("修改前邮箱: " + originalEmail);


        String newUsername = request.getParameter("name");
        String newEmail = request.getParameter("email");
        if (newUsername == null || newUsername.trim().isEmpty()) {
            request.setAttribute("error", "用户名不能为空");
            request.getRequestDispatcher("PersonInfo.jsp").forward(request, response);
            return;
        }
        if (!oldUsername.equals(newUsername) && RedisUtil.isUsernameExists(newUsername)) {
            request.setAttribute("error", "用户名已存在");
            request.getRequestDispatcher("PersonInfo.jsp").forward(request, response);
            return;
        }
        user.setName(newUsername);
        user.setEmail(newEmail);

        // 处理上传的头像文件
        Part filePart = request.getPart("imgfile");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = newUsername + "_" + System.currentTimeMillis() +
                    filePart.getSubmittedFileName().substring(filePart.getSubmittedFileName().lastIndexOf("."));

            String saveDir = getServletContext().getRealPath("/image");
            new File(saveDir).mkdirs();

            String savePath = saveDir + File.separator + fileName;
            filePart.write(savePath);
            System.out.println(savePath);

            user.setImg(fileName);
            System.out.println("新头像已保存: " + fileName);

        }

        boolean isUsernameChanged = !oldUsername.equals(newUsername);
        boolean updateSuccess;

        try (Jedis jedis = RedisUtil.RedisConfig.getConnection()) {
            if (isUsernameChanged) {
                updateSuccess = RedisUtil.changeUsername(jedis, oldUsername, newUsername, user);
            } else {
                updateSuccess = RedisUtil.updateUser(user);
            }
        }

        User updatedUser = RedisUtil.getUserByUsername(newUsername);
        System.out.println("修改后邮箱: " + updatedUser.getEmail());
        System.out.println(updatedUser.getName());
        System.out.println(updatedUser.getImg());

        if (updateSuccess) {
            session.invalidate();
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("username", newUsername);
            newSession.setAttribute("user", user);
            response.sendRedirect("PersonInfo.jsp?t=" + System.currentTimeMillis());
        } else {
            request.setAttribute("error", "更新失败，请重试");
            request.getRequestDispatcher("PersonInfo.jsp").forward(request, response);
        }
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        if (username == null) {
            response.sendRedirect("Sign.jsp");
            return;
        }

        User user = RedisUtil.getUserByUsername(username);
        if (user == null) {
            response.sendRedirect("Sign.jsp");
            return;
        }

        String oldPassword = request.getParameter("pwd1");
        String newPassword = request.getParameter("pwd2");
        String confirmPassword = request.getParameter("pwd3");

        if (!BCrypt.checkpw(oldPassword, user.getPassword())) {
            System.out.println("1:旧密码不正确");
            request.setAttribute("error", "旧密码不正确");
            request.getRequestDispatcher("PersonInfo.jsp").forward(request, response);
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            System.out.println("2:新密码和确认密码不一致");
            request.setAttribute("error", "新密码和确认密码不一致");
            request.getRequestDispatcher("PersonInfo.jsp").forward(request, response);
            return;
        }

        String hashedNewPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        user.setPassword(hashedNewPassword);

        System.out.println("=== 调试信息 ===");
        System.out.println("用户名: " + username);
        System.out.println("新密码 (明文): " + newPassword);
        System.out.println("新密码 (加密后): " + user.getPassword());

        boolean updateSuccess = RedisUtil.updateUser(user);

        // 立即从 Redis 查询，确认是否更新
        User debugUser = RedisUtil.getUserByUsername(username);
        System.out.println("Redis 中的密码: " + debugUser.getPassword());
        System.out.println("是否一致: " + debugUser.getPassword().equals(user.getPassword()));

        if (updateSuccess) {
            session.invalidate();
            response.sendRedirect("Sign.jsp");
        } else {
            request.setAttribute("error", "密码更新失败");
            request.getRequestDispatcher("PersonInfo.jsp").forward(request, response);
        }
    }
}