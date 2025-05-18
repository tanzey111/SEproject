package com.example.chat;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPubSub;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint("/chat/{roomName}/{userName}")
public class ChatWebSocket{

private static Map<String, Map<Session, String>> roomSessions = new ConcurrentHashMap<>();
    private Session session;
    private String roomName;
    private String userName;
    private Jedis subscriberJedis;
    private Thread subscriberThread;

    @OnOpen
    public void onOpen(Session session, @PathParam("roomName") String roomName, @PathParam("userName") String userName) {
        this.session = session;
        this.roomName = roomName;
        this.userName = userName;

        roomSessions.putIfAbsent(roomName, new ConcurrentHashMap<>());
        roomSessions.get(roomName).put(session, userName);

        // 订阅Redis频道，启动线程监听
        subscriberJedis = RedisManager.getJedis();
        subscriberThread = new Thread(() -> {
            subscriberJedis.subscribe(new JedisPubSub() {
                @Override
                public void onMessage(String channel, String message) {
                    try {
                        synchronized (session) {
                            session.getBasicRemote().sendText(message);
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }, "channel:chatroom:" + roomName);
        });
        subscriberThread.start();

        // 发送历史消息给客户端
        for (String msg : ChatRoomManager.getMessages(roomName)) {
            try {
                session.getBasicRemote().sendText(msg);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        // 广播用户加入消息
        String joinMsg = userName + " 加入聊天室";
        ChatRoomManager.saveMessage(roomName, joinMsg);
        publishMessage(joinMsg);
    }

    @OnMessage
    public void onMessage(String message) {
        String msgToSend = userName + ": " + message;
        ChatRoomManager.saveMessage(roomName, msgToSend);
        publishMessage(msgToSend);
    }

    @OnClose
    public void onClose() {
        if (roomSessions.containsKey(roomName)) {
            roomSessions.get(roomName).remove(session);
        }
        String leaveMsg = userName + " 离开聊天室";
        ChatRoomManager.saveMessage(roomName, leaveMsg);
        publishMessage(leaveMsg);

        if (subscriberJedis != null) {
            subscriberJedis.close();
        }
        if (subscriberThread != null) {
            subscriberThread.interrupt();
        }
    }

    private void publishMessage(String message) {
        try (Jedis jedis = RedisManager.getJedis()) {
            jedis.publish("channel:chatroom:" + roomName, message);
        }
    }

    @OnError
    public void onError(Throwable error) {
        error.printStackTrace();
    }
}
