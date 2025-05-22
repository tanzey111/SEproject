<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>聊天室主页</title>
    <!-- 明确指定不使用 favicon -->
    <link rel="icon" href="data:;base64,iVBORw0KGgo=">
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
                        light: '#f8f9fa'
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
            .content-auto { content-visibility: auto; }
            .card-hover { transition: all 0.3s ease; }
            .card-hover:hover { transform: translateY(-5px); box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1); }
            .online-count {
                background-color: rgba(67, 97, 238, 0.1);
                color: #4361ee;
                padding: 2px 8px;
                border-radius: 9999px;
                font-size: 12px;
                font-weight: 500;
                margin-right: 8px;
            }
            /* 新增布局样式 */
            .layout-container {
                display: grid;
                grid-template-columns: minmax(250px, 30%) 1fr;
                gap: 1.5rem;
                min-height: calc(100vh - 64px);
            }
            .chat-list {
                position: sticky;
                top: 64px;
                max-height: calc(100vh - 128px);
                overflow-y: auto;
                background-color: #ffffff;
                border-radius: 16px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.05);
                padding: 40px 32px;
            }
            .room-item {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 16px 24px;
                background-color: #f8fafc;
                border-radius: 12px;
                margin-bottom: 12px;
                transition: all 0.2s ease;
            }
            .room-item:hover {
                background-color: #edf2f7;
                transform: translateX(4px);
            }
            .room-name {
                flex-grow: 1;
                margin-left: 16px;
                white-space: normal;
                overflow: hidden;
                text-overflow: ellipsis;
                max-height: 48px;
            }
            .join-btn {
                white-space: nowrap;
            }
            .delete-btn {
                background-color: #4361ee;
                color: white;
                border: none;
                padding: 4px 8px;
                border-radius: 4px;
                cursor: pointer;
                transition: background-color 0.2s ease;
            }
            .delete-btn:hover {
                background-color: #4361ee;
            }
            .create-room-input {
                width: 100%;
                max-width: 300px;
            }
            .chat-room {
                display: none;
                height: 100%;
            }
            .chat-room.active {
                display: block;
            }
        }
    </style>
</head>
<body class="font-inter bg-gray-50 min-h-screen flex flex-col">
<!-- 顶部导航栏 -->
<header class="bg-white shadow-sm sticky top-0 z-10">
    <div class="container mx-auto px-4 py-3 flex items-center justify-between">
        <div class="flex items-center space-x-3">
            <a href="Sign.jsp" class="flex items-center">
                <i class="fa fa-arrow-left text-gray-600 hover:text-primary transition-colors"></i>
            </a>
            <h1 class="text-xl font-semibold text-gray-800 hidden sm:block">实时聊天室</h1>
        </div>
        <!-- 用户头像区域 -->
        <div class="flex items-center space-x-4">
            <div class="relative group">
                <a href="<%= request.getContextPath() %>/Sign.jsp" class="flex items-center space-x-2 avatar-hover">
                    <div class="w-9 h-9 rounded-full bg-primary/10 flex items-center justify-center overflow-hidden">
                        <%
                            String username = (String) session.getAttribute("username");
                            if (username != null) {
                                // 用户已登录，显示用户头像
                                com.example.chat.Item.User user = com.example.chat.util.RedisUtil.getUserByUsername(username);
                                if (user != null && user.getImg() != null && !user.getImg().isEmpty()) {
                        %>
                        <img src="image/<%= user.getImg() %>" alt="用户头像" class="w-full h-full object-cover">
                        <% } else { %>
                        <i class="fa fa-user text-primary"></i>
                        <% } %>
                        <% } else { %>
                        <!-- 用户未登录，显示默认头像 -->
                        <i class="fa fa-user text-primary"></i>
                        <% } %>
                    </div>
                    <span class="hidden md:inline-block text-sm font-medium text-gray-700">
                            <%= username != null? username : "登录/注册" %>
                        </span>
                </a>
                <!-- 下拉菜单（已登录状态） -->
                <% if (username != null) { %>
                <div class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-50 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 transform origin-top-right scale-95 group-hover:scale-100">
                    <a href="PersonInfo.jsp" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                        <i class="fa fa-user-circle mr-2"></i>个人中心
                    </a>
                    <a href="javascript:void(0)" onclick="logout()" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                        <i class="fa fa-sign-out-alt mr-2"></i>退出登录
                    </a>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</header>
<!-- 主内容区 -->
<main class="flex-1 container mx-auto px-4 py-8 layout-container">
    <!-- 左侧聊天室列表 -->
    <div class="chat-list">
        <div class="mb-8">
            <h2 class="text-xl font-semibold text-gray-800 mb-4">创建聊天室</h2>
            <div class="flex flex-col sm:flex-row sm:items-center gap-4">
                <div class="create-room-input">
                    <input type="text" id="newRoomName" placeholder="输入聊天室名称..."
                           class="w-full px-4 py-3 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all duration-200">
                </div>
                <button id="createRoomBtn"
                        class="bg-primary hover:bg-secondary text-white px-6 py-2 rounded-lg transition-colors whitespace-nowrap">
                    <i class="fa fa-plus mr-2"></i> 创建聊天室
                </button>
            </div>
        </div>
        <div>
            <h2 class="text-xl font-semibold text-gray-800 mb-6">可用聊天室</h2>
            <ul id="roomList" class="space-y-4">
                <!-- 聊天室列表将通过JS动态加载 -->
                <li class="text-center py-10 text-gray-500">
                    <i class="fa fa-spinner fa-spin text-2xl mb-3"></i>
                    <p>加载中...</p>
                </li>
            </ul>
        </div>
    </div>
    <!-- 右侧聊天室界面（初始隐藏） -->
    <div id="chatRoomContainer" class="chat-room bg-white rounded-xl shadow-sm p-6">
        <!-- 聊天室内容将通过iframe动态加载 -->
    </div>
</main>
<footer class="bg-white border-t border-gray-200 py-6">
    <div class="container mx-auto px-4 text-center text-gray-500 text-sm">
        <p>© 2025 实时聊天室. 保留所有权利.</p>
    </div>
</footer>
<script>
    const contextPath = '<%= request.getContextPath() %>';
    const chatRoomContainer = document.getElementById('chatRoomContainer');

    // 获取聊天室列表
    function fetchRooms() {
        fetch(contextPath + '/chatrooms')
            .then(res => res.json())
            .then(data => {
                const ul = document.getElementById('roomList');
                ul.innerHTML = '';
                if (data.length === 0) {
                    ul.innerHTML = `
                        <li class="text-center py-10 text-gray-500">
                            <i class="fa fa-inbox text-4xl mb-3 opacity-30"></i>
                            <p>暂无可用聊天室，请创建一个新的聊天室</p>
                        </li>
                    `;
                    return;
                }

                // 批量获取所有房间的在线人数
                fetch(contextPath + '/onlineCount')
                    .then(res => res.json())
                    .then(countData => {
                        const counts = countData.counts || {};

                        data.forEach(room => {
                            const li = document.createElement('li');
                            li.className = 'room-item card-hover';
                            const link = document.createElement('a');
                            link.href = "#";
                            link.className = 'flex items-center w-full';
                            link.dataset.room = room;

                            const roomInfo = document.createElement('div');
                            roomInfo.className = 'flex items-center';

                            const icon = document.createElement('div');
                            icon.className = 'w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center mr-4';
                            icon.innerHTML = '<i class="fa fa-comments text-primary"></i>';

                            const roomName = document.createElement('div');
                            roomName.className = 'room-name';

                            // 添加在线人数显示
                            const onlineCount = document.createElement('span');
                            onlineCount.className = 'online-count';

                            // 使用JavaScript变量和字符串拼接，避免JSP解析问题
                            const countValue = counts[room] !== undefined ? counts[room] : 0;
                            onlineCount.innerHTML = '<i class="fa fa-user mr-1"></i> ' + countValue;

                            const nameText = document.createElement('span');
                            nameText.textContent = room;

                            roomName.appendChild(onlineCount);
                            roomName.appendChild(nameText);

                            roomInfo.appendChild(icon);
                            roomInfo.appendChild(roomName);

                            const joinBtn = document.createElement('button');
                            joinBtn.className = 'join-btn bg-primary hover:bg-secondary text-white px-4 py-1.5 rounded-lg text-sm transition-colors';
                            joinBtn.innerHTML = '<i class="fa fa-arrow-right mr-1"></i> 进入';

                            // 创建删除按钮
                            const deleteBtn = document.createElement('button');
                            deleteBtn.className = 'delete-btn';
                            deleteBtn.innerHTML = '<i class="fa fa-trash"></i> 删除';
                            deleteBtn.addEventListener('click', async () => {
                                if (confirm('确定要删除该聊天室吗？此操作将移除所有聊天记录！')) {
                                    try {
                                        // 在删除前再次验证房间是否存在
                                        const exists = await checkRoomExists(room);
                                        if (!exists) {
                                            alert('该聊天室已不存在，可能已被其他用户删除。');
                                            fetchRooms(); // 刷新房间列表
                                            return;
                                        }

                                        // 执行删除操作
                                        const res = await fetch(contextPath + '/deleteRoom', {
                                            method: 'POST',
                                            headers: {
                                                'Content-Type': 'application/x-www-form-urlencoded'
                                            },
                                            body: 'roomName=' + encodeURIComponent(room)
                                        });

                                        if (res.ok) {
                                            const msg = await res.text();
                                            alert(msg);
                                            fetchRooms(); // 刷新房间列表

                                            // 关闭已删除的房间
                                            const activeIframe = document.querySelector('#chatRoomContainer iframe');
                                            if (activeIframe && activeIframe.src.includes('room=' + encodeURIComponent(room))) {
                                                document.getElementById('chatRoomContainer').innerHTML = '';
                                                document.getElementById('chatRoomContainer').classList.remove('active');
                                            }
                                        } else {
                                            const msg = await res.text();
                                            alert('删除失败: ' + msg);
                                        }
                                    } catch (error) {
                                        console.error('删除聊天室失败:', error);
                                        alert('删除失败，请重试');
                                    }
                                }
                            });

                            link.appendChild(roomInfo);
                            link.appendChild(joinBtn);
                            link.appendChild(deleteBtn);
                            li.appendChild(link);
                            ul.appendChild(li);

                            link.addEventListener('click', () => {
                                loadChatRoom(room);
                            });
                        });
                    })
                    .catch(error => {
                        console.error('获取在线人数失败:', error);
                        // 继续显示房间列表，但不显示在线人数
                        data.forEach(room => {
                            // 房间项创建代码保持不变...
                        });
                    });
            })
            .catch(error => {
                console.error('获取聊天室列表失败:', error);
                document.getElementById('roomList').innerHTML = `
                    <li class="text-center py-10 text-gray-500">
                        <i class="fa fa-exclamation-triangle text-2xl mb-3 text-red-400"></i>
                        <p>加载聊天室列表失败，请刷新页面重试</p>
                    </li>
                `;
            });
    }

    // 定时刷新在线人数
    setInterval(fetchRooms, 5000); // 每5秒刷新一次

    // 加载聊天室界面
    function loadChatRoom(roomName) {
        chatRoomContainer.innerHTML = '';
        const iframe = document.createElement('iframe');
        iframe.src = contextPath + '/chat.jsp?room=' + encodeURIComponent(roomName);
        iframe.className = 'w-full h-full border-0';
        iframe.style.minHeight = '600px';
        chatRoomContainer.classList.add('active');
        chatRoomContainer.appendChild(iframe);
    }

    // 创建聊天室
    function createRoom() {
        const roomName = document.getElementById('newRoomName').value.trim();
        if (!roomName) {
            alert('请输入聊天室名称');
            return;
        }
        fetch(contextPath + '/createRoom', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: 'roomName=' + encodeURIComponent(roomName)
        })
            .then(res => {
                if (res.ok) {
                    fetchRooms();
                    loadChatRoom(roomName);
                    document.getElementById('newRoomName').value = '';
                } else {
                    res.text().then(msg => {
                        alert('创建失败: ' + msg);
                    });
                }
            })
            .catch(error => {
                console.error('创建聊天室失败:', error);
                alert('创建失败，请重试');
            });
    }

    // 登出功能
    function logout() {
        if (confirm('确定要退出登录吗？')) {
            fetch(contextPath + '/LogoutServlet', {
                method: 'POST'
            }).then(response => {
                if (response.ok) {
                    window.location.href = contextPath + '/Sign.jsp';
                } else {
                    alert('登出失败，请重试');
                }
            }).catch(error => {
                console.error('登出请求失败:', error);
                alert('登出失败，请重试');
            });
        }
    }

    // 检查聊天室是否存在
    async function checkRoomExists(roomName) {
        try {
            const res = await fetch(contextPath + '/checkRoomExists', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'roomName=' + encodeURIComponent(roomName)
            });

            if (res.ok) {
                const data = await res.json();
                return data.exists;
            }

            return false;
        } catch (error) {
            console.error('检查房间存在失败:', error);
            return false;
        }
    }

    // 页面加载事件
    document.addEventListener('DOMContentLoaded', function() {
        fetchRooms();
        const urlParams = new URLSearchParams(window.location.search);
        const room = urlParams.get('room');
        if (room) loadChatRoom(room);
        document.getElementById('createRoomBtn').addEventListener('click', createRoom);
    });
</script>
</body>
</html>