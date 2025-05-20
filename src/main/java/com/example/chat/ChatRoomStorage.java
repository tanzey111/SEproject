package com.example.chat;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

public class ChatRoomStorage {
    private static final Set<String> rooms = Collections.synchronizedSet(new HashSet<>());

    public static void addRoom(String roomName) {
        rooms.add(roomName);
    }

    public static Set<String> getRoomNames() {
        return rooms;
    }

    public static String toJsonArray(Set<String> set) {
        StringBuilder sb = new StringBuilder("[");
        for (String item : set) {
            sb.append("\"").append(item).append("\",");
        }
        if (sb.length() > 1) sb.setLength(sb.length() - 1); // 去掉最后的逗号
        sb.append("]");
        return sb.toString();
    }
}
