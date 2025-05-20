<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>聊天室主页</title>
</head>
<body>
<h2>聊天室列表</h2>
<ul id="roomList"></ul>

<h3>创建聊天室</h3>
<input type="text" id="newRoomName" placeholder="聊天室名称">
<button onclick="createRoom()">创建</button>

<script>
    // 获取聊天室列表
    function fetchRooms() {
        fetch('<%=request.getContextPath()%>/chatrooms')   // 记得带应用上下文
            .then(res => res.json())
            .then(data => {
                const ul = document.getElementById('roomList');
                ul.innerHTML = '';
                data.forEach(room => {
                    const li = document.createElement('li');
                    const link = document.createElement('a');
                    link.href = `<%=request.getContextPath()%>/chat.jsp?room=${encodeURIComponent(room)}`;
                    link.textContent = room;
                    li.appendChild(link);
                    ul.appendChild(li);
                });
            });
    }
    // 创建聊天室
    function createRoom() {
        const roomName = document.getElementById('newRoomName').value.trim();
        if (!roomName) return alert('请输入聊天室名称');
        fetch('<%=request.getContextPath()%>/createRoom', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'roomName=' + encodeURIComponent(roomName)
        }).then(res => {
            if (res.ok) {
                // 创建成功后直接跳转
                window.location.href = `<%=request.getContextPath()%>/chat.jsp?room=${encodeURIComponent(roomName)}`;
            } else {
                alert('创建失败');
            }
        });
    }
    // 首次加载
    fetchRooms();
</script>
</body>
</html>