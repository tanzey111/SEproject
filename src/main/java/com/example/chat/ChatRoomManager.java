package com.example.chat;

import redis.clients.jedis.Jedis;

import java.util.Set;

public class ChatRoomManager {
    private static final String CHATROOMS_KEY = "chatrooms";

    // 添加聊天室
    public static boolean addChatRoom(String roomName) {
        try (Jedis jedis = RedisManager.getJedis()) {
            return jedis.sadd(CHATROOMS_KEY, roomName) > 0;
        }
    }

    // 获取所有聊天室
    public static Set<String> getAllChatRooms() {
        try (Jedis jedis = RedisManager.getJedis()) {
            return jedis.smembers(CHATROOMS_KEY);
        }
    }

    // 存消息到聊天室历史 (保存最新100条)
    public static void saveMessage(String roomName, String message) {
        String key = "chatroom:" + roomName + ":messages";
        try (Jedis jedis = RedisManager.getJedis()) {
            jedis.lpush(key, message);
            jedis.ltrim(key, 0, 99);  // 保留最新100条
        }
    }

    // 读取聊天室历史消息
    public static java.util.List<String> getMessages(String roomName) {
        String key = "chatroom:" + roomName + ":messages";
        try (Jedis jedis = RedisManager.getJedis()) {
            return jedis.lrange(key, 0, -1);
        }
    }
}
