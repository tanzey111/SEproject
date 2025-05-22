package com.example.chat;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPubSub;
import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.TimeZone;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

@ServerEndpoint("/chat/{roomName}/{userName}")
public class ChatWebSocket {
    // 使用 Redis 集合存储房间在线用户（替代内存 Map）
    static final String ONLINE_USERS_KEY = "chatroom:%s:users";
    // 使用线程安全的 Map 存储所有会话
    private static final ConcurrentHashMap<String, Session> sessions = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, ConcurrentHashMap<String, Session>> roomSessions = new ConcurrentHashMap<>();
    private Session session;
    private String roomName;
    private String userName;
    private Jedis subscriberJedis;
    private Thread subscriberThread;
    private final AtomicBoolean isConnected = new AtomicBoolean(false);
    private final AtomicBoolean isClosed = new AtomicBoolean(false);


    @OnOpen
    public void onOpen(Session session,
                       @PathParam("roomName") String roomName,
                       @PathParam("userName") String userName) {
        this.session = session;
        this.roomName = roomName;
        this.userName = userName;
        this.isConnected.set(true);
        // 检查聊天室是否存在
        if (!ChatRoomManager.exists(roomName)) {
            try {
                session.close(new CloseReason(CloseReason.CloseCodes.VIOLATED_POLICY, "聊天室不存在"));
                return;
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        // 将会话添加到全局会话列表
        sessions.put(session.getId(), session);

        // 添加用户到房间会话集合
        roomSessions.computeIfAbsent(roomName, k -> new ConcurrentHashMap<>())
                .put(session.getId(), session);
        // 更新在线用户
        try (Jedis jedis = RedisManager.getJedis()) {
            jedis.sadd(String.format(ONLINE_USERS_KEY, roomName), userName);
        }

        // 启动Redis订阅线程，监听聊天室频道消息
        startRedisSubscriber();

        // 发送历史消息
        sendHistoryMessages();

        // 广播加入消息
        String joinMsg = formatSystemMessage(userName + " 加入聊天室");
        ChatRoomManager.saveMessage(roomName, joinMsg);
        publishMessage(joinMsg);

        // 更新在线人数
        updateOnlineCount();
    }

    @OnMessage
    public void onMessage(String message) {
        if (isClosed.get() || !isConnected.get()) return;

        String formattedMsg = formatUserMessage(userName, message);
        ChatRoomManager.saveMessage(roomName, formattedMsg);
        publishMessage(formattedMsg);

    }

    @OnClose
    public void onClose(CloseReason reason) {
        if (!isClosed.getAndSet(true)) {
            cleanupResources();
        }
    }

    @OnError
    public void onError(Throwable error) {
        System.err.println("WebSocket错误: " + error.getMessage());
        if (!(error instanceof IOException)) {
            error.printStackTrace();
        }

        // 发生错误时尝试清理资源
        if (!isClosed.getAndSet(true)) {
            cleanupResources();
        }
    }

    private void startRedisSubscriber() {
        try {
            subscriberJedis = RedisManager.getJedis();

            subscriberThread = new Thread(() -> {
                try {
                    // 创建匿名内部类处理Redis消息
                    JedisPubSub pubSubListener = new JedisPubSub() {
                        @Override
                        public void onMessage(String channel, String message) {
                            // 检查会话状态和连接状态
                            if (session.isOpen() && isConnected.get()) {
                                try {
                                    // 使用异步方式发送消息，避免阻塞
                                    session.getAsyncRemote().sendText(message);
                                } catch (Exception e) {
                                    if (isConnected.get()) {
                                        System.err.println("发送消息失败: " + e.getMessage());
                                    }
                                }
                            }
                        }
                    };

                    // 订阅Redis频道
                    subscriberJedis.subscribe(pubSubListener, "channel:chatroom:" + roomName);

                } catch (Exception e) {
                    // 只有当连接未正常关闭时才打印错误
                    if (isConnected.get()) {
                        System.err.println("Redis订阅线程异常: " + e.getMessage());
                    }
                }
            });

            subscriberThread.setDaemon(true);
            subscriberThread.start();

        } catch (Exception e) {
            System.err.println("启动Redis订阅线程失败: " + e.getMessage());
        }
    }

    private void sendHistoryMessages() {
        try {
            for (String msg : ChatRoomManager.getMessages(roomName)) {
                if (session.isOpen()) {
                    session.getBasicRemote().sendText(msg);
                }
            }
        } catch (Exception e) {
            System.err.println("发送历史消息失败: " + e.getMessage());
        }
    }

    private void publishMessage(String message) {
        try (Jedis jedis = RedisManager.getJedis()) {
            jedis.publish("channel:chatroom:" + roomName, message);
        } catch (Exception e) {
            System.err.println("发布消息到Redis失败: " + e.getMessage());
            sendSystemMessage("消息发送失败，请稍后再试");
        }
    }

    private void sendSystemMessage(String content) {
        try {
            if (session.isOpen()) {
                session.getAsyncRemote().sendText(formatSystemMessage(content));
            }
        } catch (Exception e) {
            System.err.println("发送系统消息失败: " + e.getMessage());
        }
    }

    private String formatUserMessage(String username, String content) {
        return String.format("%s|%s|%s",
                username,
                content,
                getCurrentTime()
        );
    }

    private String formatSystemMessage(String content) {
        return String.format("系统|%s|%s",
                content,
                getCurrentTime()
        );
    }

    private String getCurrentTime() {
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
        sdf.setTimeZone(TimeZone.getTimeZone("Asia/Shanghai"));
        return sdf.format(new Date());
    }

    private void cleanupResources() {
        try {
            // 更新连接状态
            isConnected.set(false);

            // 从房间会话集合中移除
            if (roomSessions.containsKey(roomName)) {
                roomSessions.get(roomName).remove(session.getId());
                // 如果房间空了，从全局集合中移除
                if (roomSessions.get(roomName).isEmpty()) {
                    roomSessions.remove(roomName);
                } else {
                    // 否则更新在线人数
                    updateOnlineCount();
                }
            }
            // 更新在线用户
            try (Jedis jedis = RedisManager.getJedis()) {
                jedis.srem(String.format(ONLINE_USERS_KEY, roomName), userName);
            }


            // 发送离开通知
            String leaveMsg = formatSystemMessage(userName + " 离开聊天室");
            ChatRoomManager.saveMessage(roomName, leaveMsg);
            publishMessage(leaveMsg);
        } catch (Exception e) {
            System.err.println("发送离开消息失败: " + e.getMessage());
        }

        // 关闭Redis订阅
        try {
            if (subscriberJedis != null) {
                // 使用安全的方式取消订阅
                if (subscriberThread != null && subscriberThread.isAlive()) {
                    subscriberJedis.close(); // 关闭连接会导致subscribe方法退出
                    subscriberThread.join(2000); // 等待线程结束
                }
            }
        } catch (Exception e) {
            System.err.println("关闭Redis订阅失败: " + e.getMessage());
        }

        // 中断订阅线程
        try {
            if (subscriberThread != null && subscriberThread.isAlive()) {
                subscriberThread.interrupt();
            }
        } catch (Exception e) {
            System.err.println("中断订阅线程失败: " + e.getMessage());
        }
    }

    // 更新在线人数
    private void updateOnlineCount() {
        int count = roomSessions.getOrDefault(roomName, new ConcurrentHashMap<>()).size();
        String countMsg = formatSystemMessage("当前在线人数: " + count);
        publishMessage(countMsg);
    }

    // 获取房间在线人数
    public static int getOnlineCount(String roomName) {
        return roomSessions.getOrDefault(roomName, new ConcurrentHashMap<>()).size();
    }
}