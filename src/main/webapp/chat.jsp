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
    const urlParams = new URLSearchParams(window.location.search);
    const roomName = urlParams.get('room');
    const userName = prompt("请输入你的昵称") || '匿名';

    document.getElementById('roomTitle').textContent = '聊天室：' + roomName;

    const ws = new WebSocket(`ws://${location.host}/chat/${roomName}/${userName}`);

    ws.onmessage = function(event) {
        const chatBox = document.getElementById('chatBox');
        chatBox.innerHTML += '<div>' + event.data + '</div>';
        chatBox.scrollTop = chatBox.scrollHeight;
    };

    ws.onopen = function() {
        console.log('WebSocket已连接');
    };

    ws.onclose = function() {
        alert('连接关闭');
    };

    function sendMessage() {
        const input = document.getElementById('msgInput');
        if (!input.value.trim()) return;
        ws.send(input.value);
        input.value = '';
    }
</script>
</body>
</html>
