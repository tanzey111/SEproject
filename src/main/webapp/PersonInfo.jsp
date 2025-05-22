<%@ page import="com.example.chat.Item.User" %>
<%@ page import="com.example.chat.util.RedisUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>个人信息</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #4361ee;
            --primary-dark: #3a56d4;
            --secondary: #f72585;
            --secondary-dark: #e51e7a;
            --light: #f8f9fa;
            --dark: #212529;
            --gray: #6c757d;
            --light-gray: #e9ecef;
            --border-radius: 12px;
            --box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            --transition: all 0.3s ease;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            color: var(--dark);
            line-height: 1.6;
        }

        .profile-container {
            width: 100%;
            max-width: 480px;
            background: white;
            padding: 40px;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            text-align: center;
            position: relative;
            overflow: hidden;
            transition: var(--transition);
        }

        .profile-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 8px;
            background: linear-gradient(90deg, var(--primary), var(--secondary));
        }

        .avatar-container {
            position: relative;
            width: 150px;
            height: 150px;
            margin: 0 auto 25px;
        }

        .avatar {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            border: 5px solid white;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            transition: var(--transition);
        }

        .avatar-container:hover .avatar {
            transform: scale(1.05);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }

        .user-info {
            margin-bottom: 30px;
        }

        .user-info h1 {
            color: var(--dark);
            margin-bottom: 8px;
            font-size: 28px;
            font-weight: 600;
        }

        .user-info p {
            color: var(--gray);
            margin: 5px 0;
            font-size: 16px;
        }

        .user-info .email {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: var(--primary);
        }

        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .btn {
            padding: 12px 20px;
            border: none;
            border-radius: var(--border-radius);
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn i {
            font-size: 18px;
        }

        .btn-edit {
            background-color: var(--primary);
            color: white;
        }

        .btn-edit:hover {
            background-color: var(--primary-dark);
            transform: translateY(-2px);
        }

        .btn-logout {
            background-color: var(--secondary);
            color: white;
        }

        .btn-logout:hover {
            background-color: var(--secondary-dark);
            transform: translateY(-2px);
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 100;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.5);
            backdrop-filter: blur(5px);
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .modal.show {
            opacity: 1;
        }

        .modal-content {
            background-color: white;
            margin: 10% auto;
            padding: 30px;
            width: 90%;
            max-width: 500px;
            border-radius: var(--border-radius);
            box-shadow: 0 15px 40px rgba(0,0,0,0.2);
            transform: translateY(-20px);
            transition: transform 0.3s ease;
        }

        .modal.show .modal-content {
            transform: translateY(0);
        }

        .close {
            color: var(--gray);
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            transition: var(--transition);
        }

        .close:hover {
            color: var(--dark);
            transform: rotate(90deg);
        }

        .modal h2 {
            margin-bottom: 25px;
            color: var(--dark);
            text-align: center;
            font-size: 24px;
        }

        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--dark);
        }

        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid var(--light-gray);
            border-radius: var(--border-radius);
            font-size: 16px;
            font-family: inherit;
            transition: var(--transition);
        }

        .form-group input:focus {
            border-color: var(--primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.2);
        }

        .form-actions {
            margin-top: 25px;
        }

        .btn-submit {
            background-color: var(--primary);
            color: white;
            width: 100%;
            padding: 14px;
            font-size: 16px;
            font-weight: 500;
        }

        .btn-submit:hover {
            background-color: var(--primary-dark);
        }

        .file-input-wrapper {
            position: relative;
            overflow: hidden;
            display: inline-block;
            width: 100%;
        }

        .file-input-button {
            border: 1px dashed var(--light-gray);
            border-radius: var(--border-radius);
            padding: 30px;
            text-align: center;
            cursor: pointer;
            transition: var(--transition);
            width: 100%;
        }

        .file-input-button:hover {
            border-color: var(--primary);
            background-color: rgba(67, 97, 238, 0.05);
        }

        .file-input-button i {
            font-size: 24px;
            color: var(--primary);
            margin-bottom: 10px;
            display: block;
        }

        .file-input-button span {
            color: var(--gray);
            font-size: 14px;
        }

        .file-input {
            position: absolute;
            left: 0;
            top: 0;
            opacity: 0;
            width: 100%;
            height: 100%;
            cursor: pointer;
        }

        #toast {
            visibility: hidden;
            min-width: 280px;
            background-color: var(--secondary);
            color: white;
            text-align: center;
            border-radius: var(--border-radius);
            padding: 16px;
            position: fixed;
            z-index: 1000;
            right: 30px;
            top: 30px;
            font-size: 15px;
            box-shadow: 0 10px 25px rgba(247, 37, 133, 0.3);
            opacity: 0;
            transition: opacity 0.3s, visibility 0.3s, transform 0.3s;
            transform: translateX(20px);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        #toast.show {
            visibility: visible;
            opacity: 1;
            transform: translateX(0);
        }

        #toast i {
            font-size: 20px;
        }

        @media (max-width: 576px) {
            .profile-container {
                padding: 30px 20px;
            }

            .modal-content {
                padding: 25px 20px;
            }
        }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>

<div class="profile-container">
    <%
        User user = null;
        String username = (String) session.getAttribute("username");
        if (username != null) {
            user = RedisUtil.getUserByUsername(username);
            if (user != null) {
                String imgUrl = "image/" + user.getImg();
                System.out.println(imgUrl);
    %>
    <!-- 头像 -->
    <div class="avatar-container">
        <img src="<%=imgUrl%>" alt="用户头像" class="avatar">
    </div>

    <!-- 用户信息 -->
    <div class="user-info">
        <h1><%=user.getName()%></h1>
        <p class="email">
            <i class="fas fa-envelope"></i> <%=user.getEmail()%>
        </p>
    </div>

    <!-- 操作按钮 -->
    <div class="action-buttons">
        <button class="btn btn-edit" onclick="toggleModal()">
            <i class="fas fa-user-edit"></i> 修改个人信息
        </button>
        <button class="btn btn-edit" onclick="togglePasswordModal()">
            <i class="fas fa-key"></i> 修改密码
        </button>
        <button id="logoutbtn" class="btn btn-logout">
            <i class="fas fa-sign-out-alt"></i> 登出
        </button>
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
        <h2><i class="fas fa-key"></i> 修改密码</h2>
        <form id="passwordForm" action="AlterServlet" method="post">
            <div class="form-group">
                <label for="oldPassword"><i class="fas fa-lock"></i> 旧密码:</label>
                <input type="password" id="oldPassword" name="pwd1" required placeholder="请输入当前密码">
            </div>

            <div class="form-group">
                <label for="newPassword"><i class="fas fa-lock-open"></i> 新密码:</label>
                <input type="password" id="newPassword" name="pwd2" required placeholder="请输入新密码">
            </div>

            <div class="form-group">
                <label for="confirmPassword"><i class="fas fa-check-circle"></i> 确认新密码:</label>
                <input type="password" id="confirmPassword" name="pwd3" required placeholder="请再次输入新密码">
            </div>

            <input type="hidden" name="op" value="ChangePwd">
            <div class="form-actions">
                <button type="submit" class="btn btn-submit">
                    <i class="fas fa-save"></i> 保存新密码
                </button>
            </div>
        </form>
    </div>
</div>

<!-- 修改信息弹窗 -->
<div id="modifyModal" class="modal">
    <div class="modal-content">
        <span onclick="toggleModal()" class="close">&times;</span>
        <h2><i class="fas fa-user-cog"></i> 修改个人信息</h2>
        <form id="modifyForm" action="AlterServlet" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label for="profilePic"> <i class="fas fa-cloud-upload-alt"></i> 头像:</label>
                <input type="file" id="profilePic" name="imgfile" accept="image/*">
            </div>

            <div class="form-group">
                <label for="nickname"><i class="fas fa-user"></i> 姓名:</label>
                <input type="text" id="nickname" name="name" required placeholder="请输入您的姓名">
            </div>

            <div class="form-group">
                <label for="email"><i class="fas fa-envelope"></i> 邮箱:</label>
                <input type="email" id="email" name="email" required placeholder="请输入您的邮箱">
            </div>

            <input type="hidden" name="op" value="ChangeMsg">
            <div class="form-actions">
                <button type="submit" class="btn btn-submit">
                    <i class="fas fa-save"></i> 保存修改
                </button>
            </div>
        </form>
    </div>
</div>
<!-- Toast通知 -->
<div id="toast">
    <i class="fas fa-exclamation-circle"></i>
    <span id="toastMessage"></span>
</div>

<script>
    // 显示/隐藏模态框
    function toggleModal() {
        const modal = document.getElementById('modifyModal');
        if (modal.style.display === 'block') {
            modal.classList.remove('show');
            setTimeout(() => {
                modal.style.display = 'none';
            }, 300);
        } else {
            modal.style.display = 'block';
            setTimeout(() => {
                modal.classList.add('show');
            }, 10);

            // 填充当前用户信息
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
        if (modal.style.display === 'block') {
            modal.classList.remove('show');
            setTimeout(() => {
                modal.style.display = 'none';
            }, 300);
        } else {
            modal.style.display = 'block';
            setTimeout(() => {
                modal.classList.add('show');
            }, 10);
        }
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
                window.location.href = 'home.jsp';
            })
            .catch(error => {
                console.error('登出请求失败:', error);
                showToast('登出失败，请重试');
            });
    });

    // 关闭模态框当点击外面
    window.onclick = function(event) {
        const modal = document.getElementById('modifyModal');
        const passwordModal = document.getElementById('passwordModal');
        if (event.target === modal) {
            modal.classList.remove('show');
            setTimeout(() => {
                modal.style.display = 'none';
            }, 300);
        }
        if (event.target === passwordModal) {
            passwordModal.classList.remove('show');
            setTimeout(() => {
                passwordModal.style.display = 'none';
            }, 300);
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

        // 添加动画效果
        document.querySelector('.profile-container').style.opacity = '0';
        document.querySelector('.profile-container').style.transform = 'translateY(20px)';
        setTimeout(() => {
            document.querySelector('.profile-container').style.opacity = '1';
            document.querySelector('.profile-container').style.transform = 'translateY(0)';
            document.querySelector('.profile-container').style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        }, 100);
    });
</script>
</body>
</html>