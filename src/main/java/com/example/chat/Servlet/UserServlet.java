package com.example.chat.Servlet;
import com.example.chat.Item.User;
import com.example.chat.util.JwtUtil;
import com.example.chat.util.RedisUtil;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.UUID;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



public class UserServlet extends HttpServlet{
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.getWriter().append("Served at: ").append(request.getContextPath());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        String op = request.getParameter("op");
        if (op.equals("register")) {
            // 接收表单数据
            String username = request.getParameter("name");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("cnfpwd");
            String email = request.getParameter("email");

            System.out.println(username);
            System.out.println(password);
            System.out.println(confirmPassword);
            System.out.println(email);

            // 1. 检查密码一致性
            if (!password.equals(confirmPassword)) {
                request.setAttribute("registerError", "两次输入的密码不一致");
                request.getRequestDispatcher("/Sign.jsp").forward(request, response);
                return;
            }

            // 2. 检查用户名是否已存在
            if (RedisUtil.getUserByUsername(username) != null) {
                request.setAttribute("registerError", "用户名已存在");
                request.getRequestDispatcher("/Sign.jsp").forward(request, response);
                return;
            }

            // 3. 检查邮箱是否已存在
            if (RedisUtil.getUserByEmail(email) != null) {
                request.setAttribute("registerError", "该邮箱已被注册");
                request.getRequestDispatcher("/Sign.jsp").forward(request, response);
                return;
            }
            // 4. 创建新用户
            User user = new User();
            user.setName(username);
            user.setEmail(email);
            user.setPassword(BCrypt.hashpw(password, BCrypt.gensalt()));
            user.setId(UUID.randomUUID().toString());
            user.setImg("moren_image.jpg");

            try {
                RedisUtil.saveUser(user);
                request.getSession().setAttribute("username", username);
                response.sendRedirect("PersonInfo.jsp");  //跳转到首页
            } catch (Exception e) {
                request.setAttribute("error", "注册失败: " + e.getMessage());
                request.getRequestDispatcher("/Sign.jsp").forward(request, response);
            }

        } else if (op.equals("login")) {
            // 接收登录表单数据
            String username = request.getParameter("login_name");
            String password = request.getParameter("login_password");

            // 1. 检查用户是否存在
            User user = RedisUtil.getUserByUsername(username);

            if (user == null) {
                // 用户不存在
                request.setAttribute("loginError", "用户不存在，请检查用户名或注册");
                request.getRequestDispatcher("/Sign.jsp").forward(request, response);
            } else if (!BCrypt.checkpw(password, user.getPassword())) {
                // 用户存在，但密码错误
                request.setAttribute("loginError", "密码错误，请重试");
                request.getRequestDispatcher("/Sign.jsp").forward(request, response);
            } else {
                // 登录成功，生成 Token 并跳转
                String token = JwtUtil.generateToken(username);
                Cookie tokenCookie = new Cookie("auth_token", token);
                tokenCookie.setHttpOnly(true);
                tokenCookie.setMaxAge(24 * 60 * 60); // 24小时
                response.addCookie(tokenCookie);
                request.getSession().setAttribute("username", user.getName());
                response.sendRedirect("home.jsp"); // 跳转到首页
            }
        }
    }
}
