package com.example.chat.util;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public class RedisConfig {
    private static JedisPool jedisPool;

    static {
        JedisPoolConfig poolConfig = new JedisPoolConfig();
        poolConfig.setMaxTotal(128);
        poolConfig.setMaxIdle(32);
        poolConfig.setMinIdle(8);
        poolConfig.setTestOnBorrow(true);
        poolConfig.setTestOnReturn(true);
        poolConfig.setTestWhileIdle(true);
        jedisPool = new JedisPool(poolConfig, "localhost", 6379);
        // 测试连接
        try (Jedis jedis = jedisPool.getResource()) {
            System.out.println("Redis connection test: " + jedis.ping());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Jedis getConnection() {
        return jedisPool.getResource();
    }
}
