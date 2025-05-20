<%--
  Created by IntelliJ IDEA.
  User: HUAWEI
  Date: 2025/5/17
  Time: 12:08
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>首页</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding-top: 100px;
        }

        button {
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
        }

        /* 弹窗样式 */
        .modal {
            display: none; /* 默认隐藏 */
            position: fixed;
            z-index: 999;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.4);
        }

        .modal-content {
            background-color: #fff;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 300px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            border-radius: 8px;
        }

        .modal-content input {
            width: 100%;
            padding: 8px;
            margin-top: 10px;
            margin-bottom: 15px;
            box-sizing: border-box;
        }

        .modal-content button {
            width: 100%;
            padding: 10px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 14px;
        }

        .close {
            float: right;
            color: #aaa;
            font-size: 20px;
            cursor: pointer;
        }
    </style>
</head>
<body>
<h1>欢迎来到聊天室</h1>
<button onclick="openModal()">加入房间</button>
<h3>最近加入的房间</h3>
<ul id="roomList" style="list-style: none; padding: 0; width: 300px; margin: 0 auto;">
    <!-- 示例列表项 -->
     <li style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #ccc; padding: 8px 0;">
        <span>测试房间</span>
        <span>在线人数：2</span>
        <button onclick="joinExistingRoom('测试房间')">加入</button>
    </li> -->
</ul>

<!-- 弹窗 -->
<div id="myModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal()">&times;</span>
        <h3>请输入房间名称</h3>
        <input type="text" id="roomNameInput" placeholder="房间名称">
        <button onclick="joinRoom()">确认</button>
    </div>
</div>

<script>
    function openModal() {
        document.getElementById("myModal").style.display = "block";
    }

    function closeModal() {
        document.getElementById("myModal").style.display = "none";
    }

    function joinRoom() {
            const roomName = document.getElementById("roomNameInput").value.trim();
            if (roomName === "") {
                alert("请输入房间名称");
                return;
            }

            // 使用 Ajax 发送请求到服务器
            const xhr = new XMLHttpRequest();
            xhr.open("POST", "JoinRoomServlet", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    // 成功后跳转到聊天界面
                    window.location.href = "chat.jsp?room=" + encodeURIComponent(roomName);
                }
            };
            xhr.send("roomName=" + encodeURIComponent(roomName));

    }

    // 点击弹窗外区域关闭弹窗
    window.onclick = function(event) {
        const modal = document.getElementById("myModal");
        if (event.target == modal) {
            closeModal();
        }
    }
</script>
</body>
</html>
