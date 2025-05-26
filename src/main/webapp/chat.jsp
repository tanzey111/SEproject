<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>聊天室</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: '#4361ee',
                        secondary: '#3f37c9',
                        accent: '#4cc9f0',
                        danger: '#f72585',
                        dark: '#212529',
                        light: '#f8f9fa',
                        success: '#4CAF50',
                        warning: '#FFC107',
                        info: '#17a2b8',
                        muted: '#6c757d'
                    },
                    fontFamily: {
                        inter: ['Inter', 'sans-serif'],
                    },
                }
            }
        }
    </script>
    <style type="text/tailwindcss">
        @layer utilities {
            /* 遮罩层样式 */
            .modal-backdrop {
                @apply fixed top-0 left-0 w-full h-full bg-black/50 flex justify-center items-center z-50;
            }

            /* 弹窗样式 */
            .modal-content {
                @apply bg-white p-6 rounded-xl shadow-lg w-[300px] text-center;
            }

            /* 按钮通用样式 */
            .modal-content button {
                @apply my-2.5 px-4 py-2 w-full cursor-pointer border-none rounded border-gray-300 transition-colors duration-300;
            }

            /* 匿名按钮样式 */
            #anonymousBtn {
                @apply bg-gray-200 hover:bg-gray-300 text-gray-700;
            }

            /* 预设用户名按钮样式 */
            #presetNameBtn {
                @apply bg-primary hover:bg-blue-600 text-white;
            }

            /* 确认自定义名称按钮样式 */
            #confirmCustomNameBtn {
                @apply bg-accent hover:bg-cyan-500 text-white;
            }

            /* 自定义昵称输入框样式 */
            #customNameInput {
                @apply w-full px-4 py-2 mb-2.5 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-primary;
            }
        }
        @layer utilities {
            .content-auto {
                content-visibility: auto;
            }
            .scrollbar-hide::-webkit-scrollbar {
                display: none;
            }
            .scrollbar-hide {
                -ms-overflow-style: none;
                scrollbar-width: none;
            }
            .message-in {
                animation: fadeIn 0.3s ease forwards;
            }
            .user-join {
                animation: slideUp 0.5s ease forwards;
            }
            .user-leave {
                animation: fadeOut 0.5s ease forwards;
            }
            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(10px); }
                to { opacity: 1; transform: translateY(0); }
            }
            @keyframes slideUp {
                from { opacity: 0; transform: translateY(20px); }
                to { opacity: 1; transform: translateY(0); }
            }
            @keyframes fadeOut {
                from { opacity: 1; }
                to { opacity: 0.7; }
            }
        }
    </style>
</head>
<body class="font-inter bg-gray-50 min-h-screen flex flex-col">
<!-- 顶部导航栏 -->
<header class="bg-white shadow-sm sticky top-0 z-10">
    <div class="container mx-auto px-4 py-3 flex items-center justify-between">
        <h1 id="roomTitle" class="text-xl font-semibold text-gray-800">聊天室</h1>
    </div>
</header>

<!-- 主内容区 -->
<main class="flex-1 container mx-auto px-4 py-6">
    <div class="bg-white rounded-xl shadow-sm overflow-hidden h-[calc(100vh-120px)] flex flex-col max-w-4xl mx-auto">
        <!-- 聊天室标题 -->
        <div class="border-b border-gray-200 p-4 flex justify-between items-center">
            <h2 id="roomName" class="font-semibold text-gray-800"></h2>
        </div>

        <!-- 聊天内容区 -->
        <div id="chatBox" class="flex-1 overflow-y-auto p-4 space-y-4 scrollbar-hide">
            <!-- 系统消息 -->
            <div class="text-center my-2">
                    <span id="welcomeMsg" class="bg-gray-100 text-gray-500 text-xs px-3 py-1 rounded-full">
                        欢迎信息将由JS动态添加
                    </span>
            </div>

            <!-- 消息将通过JS动态添加 -->
        </div>

        <!-- 输入区域 -->
        <div class="border-t border-gray-200 p-4">
            <div class="flex items-center space-x-2">
                <input type="text" id="msgInput" placeholder="输入消息..."
                       class="flex-1 px-4 py-2 rounded-full border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all duration-200">
                <button id="sendBtn" onclick="sendMessage()"
                        class="bg-primary hover:bg-secondary text-white px-4 py-2 rounded-full transition-colors flex items-center">
                    <i class="fa fa-paper-plane"></i>
                </button>
            </div>
        </div>
    </div>
</main>

<script>
    // JSP变量写入JS字符串
    var contextPath = '<%= request.getContextPath() %>';

    // 从URL中获取room参数
    var urlParams = new URLSearchParams(window.location.search);
    var roomName = urlParams.get('room');

    // 用户昵称弹窗输入，默认“匿名”
    //var userName = prompt("请输入你的昵称") || '匿名';
    //var userName = '匿名';
    var defaultUserName = "<%=session.getAttribute("username") != null ? session.getAttribute("username") : "匿名"%>";
    var ws;
    document.addEventListener('DOMContentLoaded', function () {
        // 创建遮罩层和模态框
        const backdrop = document.createElement('div');
        backdrop.className = 'modal-backdrop';
        document.body.appendChild(backdrop);

        const modalContent = document.createElement('div');
        modalContent.className = 'modal-content';

        modalContent.innerHTML = `
        <h2 class="mb-4">请选择或输入您的昵称</h2>
        <div class="flex items-center mb-4 space-x-2">
            <input type="text" id="customNameInput" placeholder="自定义昵称..." class="px-4 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-primary">
            <button id="confirmCustomNameBtn" class="flex-1 px-4 py-2 bg-accent hover:bg-cyan-500 text-white rounded"><i class="fa-solid fa-check"></i></button>
        </div>
        <div class="flex space-x-2">
            <button id="anonymousBtn" class="flex-1 py-2 px-4 bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-lg">匿名</button>
            <button id="presetNameBtn" class="flex-1 py-2 px-4 bg-primary hover:bg-blue-600 text-white rounded-lg">使用用户名</button>
        </div>
    `;

        backdrop.appendChild(modalContent);

        // 获取必要的DOM元素
        const anonymousBtn = document.getElementById('anonymousBtn');
        const presetNameBtn = document.getElementById('presetNameBtn');
        const customNameInput = document.getElementById('customNameInput');
        const confirmCustomNameBtn = document.getElementById('confirmCustomNameBtn');

        var userName = '匿名'; // 默认值为匿名

        // 匿名按钮点击事件
        anonymousBtn.addEventListener('click', () => {
            userName = '匿名';
            initChat(userName);
            closeModal();
        });

        // 使用预设用户名按钮点击事件
        presetNameBtn.addEventListener('click', () => {
            userName = defaultUserName; // 示例预设用户名
            initChat(userName);
            closeModal();
        });

        // 确认自定义用户名按钮点击事件
        confirmCustomNameBtn.addEventListener('click', () => {
            const customName = customNameInput.value.trim();
            if (customName) {
                userName = customName;
                initChat(userName);
                closeModal();
            } else {
                alert('请输入有效的昵称');
            }
        });

        function initChat(name){
            // 关闭模态框函数
            backdrop.remove();
            // 拼接WebSocket地址
            var wsUrl = 'ws://' + location.host + contextPath + '/chat/'
                + encodeURIComponent(roomName) + '/' + encodeURIComponent(userName);

            console.log("WebSocket连接地址:", wsUrl);

            // 创建WebSocket连接
            ws = new WebSocket(wsUrl);

            // 处理接收到的消息
            ws.onmessage = function(event) {
                try {
                    // 尝试解析JSON格式的消息
                    var data = JSON.parse(event.data);

                    if (data.type === 'message') {
                        // 普通消息：区分自己和他人的消息
                        addMessage(data.sender, data.content, data.time, data.sender === userName);
                    } else if (data.type === 'system') {
                        // 系统消息：统一格式显示
                        addSystemMessage(data.content);
                    } else if (data.type === 'join') {
                        // 用户加入消息
                        addJoinMessage(data.user, data.time);
                        updateOnlineCount(data.onlineCount);
                    } else if (data.type === 'leave') {
                        // 用户离开消息
                        addLeaveMessage(data.user, data.time);
                        updateOnlineCount(data.onlineCount);
                    }
                } catch (e) {
                    // 处理"username|content|time"格式的消息
                    var parts = event.data.split('|');
                    if (parts.length >= 2) {
                        var sender = parts[0];
                        var content = parts[1];
                        var time = parts.length > 2 ? parts[2] : new Date().toLocaleTimeString();

                        // 判断是否是系统消息
                        if (sender === '系统') {
                            // 检查是否是用户加入或离开的消息
                            if (content.includes('加入了聊天室')) {
                                addJoinMessage(content.split(' ')[0], time);
                                updateOnlineCountFromMessage(content);
                            } else if (content.includes('离开了聊天室')) {
                                addLeaveMessage(content.split(' ')[0], time);
                                updateOnlineCountFromMessage(content);
                            } else {
                                addSystemMessage(content);
                            }
                        } else {
                            addMessage(sender, content, time, sender === userName);
                        }
                    } else {
                        // 格式不匹配，作为系统消息显示
                        addMessage('系统', event.data, new Date().toLocaleTimeString(), false);
                    }
                }
            };
            ws.onopen = function() {
                console.log('WebSocket已连接');
                addSystemMessage('你已加入聊天室');
            };

            ws.onclose = function() {
                addSystemMessage('连接已关闭');
                document.getElementById('sendBtn').disabled = true;
                document.getElementById('sendBtn').classList.add('opacity-50', 'cursor-not-allowed');
            };

            ws.onerror = function(error) {
                console.error('WebSocket错误:', error);
                addSystemMessage('连接发生错误');
            };
        }
    });
    // 设置聊天室标题（纯JavaScript实现）
    document.getElementById('roomTitle').textContent = '聊天室：' + roomName;
    document.getElementById('roomName').textContent = roomName;
    document.getElementById('welcomeMsg').textContent = '欢迎来到 ' + roomName;



    // 页面加载时获取初始在线人数
    document.addEventListener('DOMContentLoaded', function() {
        if (roomName) {
            fetch(contextPath + '/onlineCount?roomName=' + encodeURIComponent(roomName))
                .then(res => res.json())
                .then(data => {
                    if (data.count !== undefined) {
                        document.getElementById('countValue').textContent = data.count;
                    }
                })
                .catch(error => {
                    console.error('获取在线人数失败:', error);
                });
        }
    });

    // 添加消息到聊天框 - 完全避免JSP EL表达式
    function addMessage(sender, content, time, isSelf) {
        const chatBox = document.getElementById('chatBox');
        const messageDiv = document.createElement('div');

        // 设置消息方向（自己的消息靠右，他人消息靠左）
        messageDiv.className = 'message-in flex ' + (isSelf ? 'justify-end' : 'justify-start');

        // 设置消息气泡样式
        const bubbleClass = isSelf
            ? 'bg-primary text-white rounded-tl-lg rounded-tr-lg rounded-bl-lg'
            : 'bg-gray-100 text-gray-800 rounded-tl-lg rounded-tr-lg rounded-br-lg';

        // 设置文本颜色类
        const nameColorClass = isSelf ? 'text-white/80' : 'text-gray-600';
        const timeColorClass = isSelf ? 'text-white/60' : 'text-gray-400';

        // 创建DOM元素而非使用字符串模板
        const bubbleDiv = document.createElement('div');
        bubbleDiv.className = bubbleClass + ' p-3 max-w-[80%] shadow-sm';

        const headerDiv = document.createElement('div');
        headerDiv.className = 'flex items-center mb-1';

        const senderSpan = document.createElement('span');
        senderSpan.className = 'font-medium text-sm ' + nameColorClass;
        senderSpan.textContent = sender;

        const timeSpan = document.createElement('span');
        timeSpan.className = 'ml-2 text-xs ' + timeColorClass;
        timeSpan.textContent = time;

        const contentPara = document.createElement('p');
        contentPara.className = 'text-sm';
        contentPara.textContent = content; // 先设置文本内容，避免XSS

        // 构建DOM树
        headerDiv.appendChild(senderSpan);
        headerDiv.appendChild(timeSpan);

        bubbleDiv.appendChild(headerDiv);
        bubbleDiv.appendChild(contentPara);

        messageDiv.appendChild(bubbleDiv);

        // 添加到聊天框
        chatBox.appendChild(messageDiv);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    // 添加系统消息
    function addSystemMessage(content) {
        const chatBox = document.getElementById('chatBox');
        const messageDiv = document.createElement('div');
        messageDiv.className = 'text-center my-2';

        const span = document.createElement('span');
        span.className = 'bg-gray-100 text-gray-500 text-xs px-3 py-1 rounded-full';
        span.textContent = content;

        messageDiv.appendChild(span);
        chatBox.appendChild(messageDiv);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    // 添加用户加入消息
    function addJoinMessage(user, time) {
        const chatBox = document.getElementById('chatBox');
        const messageDiv = document.createElement('div');
        messageDiv.className = 'user-join text-center my-2';

        const span = document.createElement('span');
        span.className = 'bg-success/10 text-success text-xs px-3 py-1 rounded-full inline-flex items-center';

        const icon = document.createElement('i');
        icon.className = 'fa fa-user-plus mr-1';

        const text = document.createTextNode(`${user} 加入了聊天室`);

        span.appendChild(icon);
        span.appendChild(text);
        messageDiv.appendChild(span);

        chatBox.appendChild(messageDiv);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    // 添加用户离开消息
    function addLeaveMessage(user, time) {
        const chatBox = document.getElementById('chatBox');
        const messageDiv = document.createElement('div');
        messageDiv.className = 'user-leave text-center my-2';

        const span = document.createElement('span');
        span.className = 'bg-danger/10 text-danger text-xs px-3 py-1 rounded-full inline-flex items-center';

        const icon = document.createElement('i');
        icon.className = 'fa fa-user-minus mr-1';

        const text = document.createTextNode(`${user} 离开了聊天室`);

        span.appendChild(icon);
        span.appendChild(text);
        messageDiv.appendChild(span);

        chatBox.appendChild(messageDiv);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    // 更新在线人数
    function updateOnlineCount(count) {
        document.getElementById('countValue').textContent = count;
    }

    // 从系统消息中提取在线人数并更新
    function updateOnlineCountFromMessage(message) {
        const countMatch = message.match(/当前在线人数: (\d+)/);
        if (countMatch) {
            document.getElementById('countValue').textContent = countMatch[1];
        }
    }

    // 发送消息函数
    function sendMessage() {
        const input = document.getElementById('msgInput');
        const content = input.value.trim();
        if (!content) return;

        // 发送消息
        ws.send(content);

        // 清空输入框
        input.value = '';
    }

    // 转义HTML特殊字符 - 纯JavaScript实现
    function escapeHtml(text) {
        if (!text) return '';
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    // 支持按Enter发送消息
    document.getElementById('msgInput').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            sendMessage();
        }
    });
</script>
</body>
</html>