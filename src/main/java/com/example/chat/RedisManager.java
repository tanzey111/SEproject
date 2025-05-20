package com.example.chat;

import redis.clients.jedis.Jedis;

public class RedisManager {
    private static final String REDIS_HOST = "localhost";
    private static final int REDIS_PORT = 6379;

    public static Jedis getJedis() {
        return new Jedis(REDIS_HOST, REDIS_PORT);
    }
}
