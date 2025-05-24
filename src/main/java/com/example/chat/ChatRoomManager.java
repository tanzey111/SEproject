package com.example.chat;

import redis.clients.jedis.Jedis;

import java.util.List;

public class ChatRoomManager {
    private static final int MAX_HISTORY = 50;

    public static void saveMessage(String roomName, String message) {
        try (Jedis jedis = RedisManager.getJedis()) {
            // 使用Redis列表存储消息历史
            jedis.rpush("chatroom:" + roomName + ":messages", message);
            // 限制历史消息数量，避免占用过多内存
            jedis.ltrim("chatroom:" + roomName + ":messages", -100, -1);
        }
    }

    // 获取消息历史
    public static List<String> getMessages(String roomName) {
        try (Jedis jedis = RedisManager.getJedis()) {
            return jedis.lrange("chatroom:" + roomName + ":messages", 0, -1);
        }
    }
    // 检查聊天室是否存在
    public static boolean exists(String roomName) {
        try (Jedis jedis = RedisManager.getJedis()) {
            return jedis.sismember("chatrooms", roomName);
        }
    }
}
