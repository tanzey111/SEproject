package com.example.chat.util;

import com.example.chat.Item.User;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import redis.clients.jedis.Jedis;

import java.io.IOException;


public class RedisUtil {
    private static final String USER_KEY_PREFIX = "user:";
    public static com.example.chat.util.RedisConfig RedisConfig;

    public static void saveUser(User user) {
        try (Jedis jedis = RedisConfig.getConnection()) {
            jedis.hset("users", user.getName(), serialize(user));
            jedis.set("user:email:" + user.getEmail(), user.getName());
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize user", e);
        }
    }

    public static User getUserByUsername(String username) {
        try (Jedis jedis = RedisConfig.getConnection()) {
            String userData = jedis.hget("users", username);
            if (userData == null) {
                return null;
            }
            return deserialize(userData);
        } catch (IOException e) {
            throw new RuntimeException("Failed to deserialize user data", e);
        }
    }

    public static User getUserByEmail(String email) {
        try (Jedis jedis = RedisConfig.getConnection()) {
            String username = jedis.get("user:email:" + email);
            if (username == null) {
                return null;
            }
            return getUserByUsername(username);
        }
    }

    public static boolean updateUser(User user) {
        try (Jedis jedis = RedisConfig.getConnection()) {
            String userJson = serialize(user);
            jedis.hset("users", user.getName(), userJson);
            User oldUser = getUserByUsername(user.getName());
            if (oldUser != null && !oldUser.getEmail().equals(user.getEmail())) {
                jedis.del("user:email:" + oldUser.getEmail());
                jedis.set("user:email:" + user.getEmail(), user.getName());
            }

            String savedJson = jedis.hget("users", user.getName());
            return savedJson != null && savedJson.equals(userJson);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    public static boolean changeUsername(Jedis jedis, String oldUsername, String newUsername, User user) {
        try {
            jedis.hdel("users", oldUsername);
            String userJson = serialize(user);
            jedis.hset("users", newUsername, userJson);

            String email = user.getEmail();
            if (jedis.exists("user:email:" + email)) {
                jedis.del("user:email:" + email);
            }
            jedis.set("user:email:" + email, newUsername);

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    public static boolean isUsernameExists(String username) {
        try (Jedis jedis = RedisConfig.getConnection()) {
            return jedis.hexists("users", username);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    private static String serialize(User user) throws JsonProcessingException {
        ObjectMapper mapper = new ObjectMapper();
        return mapper.writeValueAsString(user);
    }

    private static User deserialize(String data) throws IOException {
        if (data == null) {
            return null;
        }
        ObjectMapper mapper = new ObjectMapper();
        return mapper.readValue(data, User.class);
    }
}