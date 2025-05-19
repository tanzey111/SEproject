package com.example.chat;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

public class RedisManager {
    private static JedisPool jedisPool = new JedisPool("localhost", 6379);

    public static Jedis getJedis() {
        return jedisPool.getResource();
    }

    public static void close(Jedis jedis) {
        if (jedis != null) jedis.close();
    }
}
