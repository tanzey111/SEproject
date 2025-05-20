<%@ page import="com.example.chat.Item.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>个人信息</title>
    <style>
        /* 基础样式 */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
            display: flex;
            justify-content: center;
        }

        /* 用户信息容器 */
        .profile-container {
            width: 100%;
            max-width: 500px;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            text-align: center;
        }

        /* 头像样式 */
        .avatar {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            margin: 0 auto 20px;
            display: block;
            border: 3px solid #4361ee;
        }

        /* 用户信息样式 */
        .user-info {
            margin-bottom: 30px;
        }

        .user-info h1 {
            color: #333;
            margin-bottom: 5px;
        }

        .user-info p {
            color: #666;
            margin: 5px 0;
        }

        /* 按钮样式 */
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .btn {
            padding: 12px 20px;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-edit {
            background-color: #4361ee;
            color: white;
        }

        .btn-edit:hover {
            background-color: #3a56d4;
        }

        .btn-logout {
            background-color: #f72585;
            color: white;
        }

        .btn-logout:hover {
            background-color: #e51e7a;
        }

        /* 模态框样式 */
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.4);
        }

        .modal-content {
            background-color: #fefefe;
            margin: 10% auto;
            padding: 25px;
            border: none;
            width: 90%;
            max-width: 500px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }

        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }

        .close:hover {
            color: #333;
        }

        /* 表单样式 */
        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #555;
        }

        .form-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
        }

        .form-group input:focus {
            border-color: #4361ee;
            outline: none;
            box-shadow: 0 0 0 2px rgba(67, 97, 238, 0.2);
        }

        .form-actions {
            margin-top: 25px;
        }

        .btn-submit {
            background-color: #4361ee;
            color: white;
            width: 100%;
            padding: 12px;
            font-size: 16px;
        }

        .btn-submit:hover {
            background-color: #3a56d4;
        }

        /* Toast 通知样式 */
        #toast {
            visibility: hidden;
            min-width: 250px;
            background-color: #f72585;
            color: white;
            text-align: center;
            border-radius: 4px;
            padding: 16px;
            position: fixed;
            z-index: 1000;
            right: 20px;
            top: 20px;
            font-size: 14px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            opacity: 0;
            transition: opacity 0.3s, visibility 0.3s;
        }

        #toast.show {
            visibility: visible;
            opacity: 1;
        }
    </style>
</head>
<body>

<div class="profile-container">
    <%
        User user = null;
        String username = (String) session.getAttribute("username");
        if (username != null) {
             user = com.example.chat.util.RedisUtil.getUserByUsername(username);
            if (user != null) {
                String imgUrl = "image/" + user.getImg();
                System.out.println(user.getImg());
                System.out.println(imgUrl);
    %>
    <!-- 头像 -->
    <img src="<%=imgUrl%>" alt="用户头像" class="avatar">
    <!-- 用户信息 -->
    <div class="user-info">
        <h1><%=user.getName()%></h1>
        <p><%=user.getEmail()%></p>
    </div>

    <!-- 操作按钮 -->
    <div class="action-buttons">
        <button class="btn btn-edit" onclick="toggleModal()">修改个人信息</button>
        <button class="btn btn-edit" onclick="togglePasswordModal()">修改密码</button>
        <button id="logoutbtn" class="btn btn-logout">登出</button>
    </div>
    <%
            }
        }
    %>
</div>

<!-- 修改密码弹窗 -->
<div id="passwordModal" class="modal">
    <div class="modal-content">
        <span onclick="togglePasswordModal()" class="close">&times;</span>
        <h2>修改密码</h2>
        <form id="passwordForm" action="AlterServlet" method="post">
            <div class="form-group">
                <label for="oldPassword">旧密码:</label>
                <input type="password" id="oldPassword" name="pwd1" required>
            </div>

            <div class="form-group">
                <label for="newPassword">新密码:</label>
                <input type="password" id="newPassword" name="pwd2" required>
            </div>

            <div class="form-group">
                <label for="confirmPassword">确认新密码:</label>
                <input type="password" id="confirmPassword" name="pwd3" required>
            </div>

            <input type="hidden" name="op" value="ChangePwd">
            <div class="form-actions">
                <button type="submit" class="btn btn-submit">保存新密码</button>
            </div>
        </form>
    </div>
</div>

<!-- 修改信息弹窗 -->
<div id="modifyModal" class="modal">
    <div class="modal-content">
        <span onclick="toggleModal()" class="close">&times;</span>
        <h2>修改个人信息</h2>
        <form action="AlterServlet" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label for="profilePic">头像:</label>
                <input type="file" id="profilePic" name="imgfile" accept="image/*">
            </div>

            <div class="form-group">
                <label for="nickname">姓名:</label>
                <input type="text" id="nickname" name="name" required>
            </div>

            <div class="form-group">
                <label for="email">邮箱:</label>
                <input type="email" id="email" name="email" required>
            </div>

            <input type="hidden" name="op" value="ChangeMsg">
            <div class="form-actions">
                <button type="submit" class="btn btn-submit">保存修改</button>
            </div>
        </form>
    </div>
</div>
<!-- Toast通知 -->
<div id="toast">
    <span id="toastMessage"></span>
</div>

<script>
    // 显示/隐藏模态框
    function toggleModal() {
        const modal = document.getElementById('modifyModal');
        modal.style.display = modal.style.display === 'block' ? 'none' : 'block';

        // 如果是显示模态框，则填充当前用户信息
        if (modal.style.display === 'block') {
            <%
            if (username != null && user != null) {
            %>
            document.getElementById('nickname').value = '<%=user.getName()%>';
            document.getElementById('email').value = '<%=user.getEmail()%>';
            <%
            }
            %>
        }
    }

    function togglePasswordModal() {
        const modal = document.getElementById('passwordModal');
        modal.style.display = modal.style.display === 'block' ? 'none' : 'block';
    }

    // 登出功能
    document.getElementById('logoutbtn').addEventListener('click', function() {
        fetch('LogoutServlet', {
            method: 'POST',
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('登出失败');
                }
                window.location.href = 'Sign.jsp';
            })
            .catch(error => {
                console.error('登出请求失败:', error);
                alert('登出失败，请重试');
            });
    });

    // 关闭模态框当点击外面
    window.onclick = function(event) {
        const modal = document.getElementById('modifyModal');
        const passwordModal = document.getElementById('passwordModal');
        if (event.target === modal) {
            modal.style.display = 'none';
        }
        if (event.target === passwordModal) {
            passwordModal.style.display = 'none';
        }
    }
    // 显示Toast通知
    function showToast(message) {
        const toast = document.getElementById("toast");
        const toastMessage = document.getElementById("toastMessage");

        toastMessage.textContent = message;
        toast.classList.add("show");

        setTimeout(() => {
            toast.classList.remove("show");
        }, 3500);
    }

    window.addEventListener('load', function() {
        <% if (request.getAttribute("error") != null) { %>
        showToast("<%= request.getAttribute("error") %>");
        <% } %>
    });
</script>
</body>
</html>