package com.example.chat;

import redis.clients.jedis.Jedis;

import java.util.List;

public class ChatRoomManager {
    private static final int MAX_HISTORY = 50;

    public static void saveMessage(String roomName, String message) {
        try (Jedis jedis = RedisManager.getJedis()) {
            String key = "chatroom:history:" + roomName;
            jedis.rpush(key, message);
            jedis.ltrim(key, -MAX_HISTORY, -1);
        }
    }

    public static List<String> getMessages(String roomName) {
        try (Jedis jedis = RedisManager.getJedis()) {
            String key = "chatroom:history:" + roomName;
            return jedis.lrange(key, 0, -1);
        }
    }
}
