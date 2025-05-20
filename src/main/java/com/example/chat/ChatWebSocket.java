package com.example.chat;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPubSub;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;

@ServerEndpoint("/chat/{roomName}/{userName}")
public class ChatWebSocket {

    private Session session;
    private String roomName;
    private String userName;

    private Jedis subscriberJedis;
    private Thread subscriberThread;

    @OnOpen
    public void onOpen(Session session,
                       @PathParam("roomName") String roomName,
                       @PathParam("userName") String userName) throws IOException {
        this.session = session;
        this.roomName = roomName;
        this.userName = userName;

        // 启动Redis订阅线程，监听聊天室频道消息
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

        // 发送历史消息
        for (String msg : ChatRoomManager.getMessages(roomName)) {
            session.getBasicRemote().sendText(msg);
        }

        // 广播加入消息
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

    @OnError
    public void onError(Throwable error) {
        error.printStackTrace();
    }

    private void publishMessage(String message) {
        try (Jedis jedis = RedisManager.getJedis()) {
            jedis.publish("channel:chatroom:" + roomName, message);
        }
    }
}
