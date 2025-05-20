<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>聊天室</title>
</head>
<body>
<h2 id="roomTitle"></h2>
<div id="chatBox" style="height: 300px; border: 1px solid #ccc; overflow-y: scroll;"></div>

<input type="text" id="msgInput" placeholder="输入消息" style="width: 80%;" />
<button onclick="sendMessage()">发送</button>

<script>
    // JSP变量写入JS字符串（避免EL解析冲突）
    var contextPath = '<%= request.getContextPath() %>';

    // 从URL中获取room参数
    var urlParams = new URLSearchParams(window.location.search);
    var roomName = urlParams.get('room');

    // 用户昵称弹窗输入，默认“匿名”
    var userName = prompt("请输入你的昵称") || '匿名';

    // 设置聊天室标题
    document.getElementById('roomTitle').textContent = '聊天室：' + roomName;

    // 拼接WebSocket地址，注意用普通字符串拼接避免JSP EL干扰
    var wsUrl = 'ws://' + location.host + contextPath + '/chat/'
        + encodeURIComponent(roomName) + '/' + encodeURIComponent(userName);

    console.log("WebSocket连接地址:", wsUrl);

    // 创建WebSocket连接
    var ws = new WebSocket(wsUrl);

    // 接收到服务器消息，显示到聊天框
    ws.onmessage = function(event) {
        var chatBox = document.getElementById('chatBox');
        chatBox.innerHTML += '<div>' + event.data + '</div>';
        chatBox.scrollTop = chatBox.scrollHeight;
    };

    ws.onopen = function() {
        console.log('WebSocket已连接');
    };

    ws.onclose = function() {
        alert('连接关闭');
    };

    ws.onerror = function(error) {
        console.error('WebSocket错误:', error);
    };

    // 发送消息函数
    function sendMessage() {
        var input = document.getElementById('msgInput');
        if (!input.value.trim()) return;
        ws.send(input.value);
        input.value = '';
    }
</script>
</body>
</html>
