import redis.clients.jedis.Jedis;

public class RedisTest111 {
    public static void main(String[] args) {
        Jedis jedis = new Jedis("localhost", 6379);
        try {
            // 发送消息
            String key = "testMessage";
            String messageToSend = "Hello, Redis!";
            jedis.set(key, messageToSend);
            System.out.println("发送的消息: " + messageToSend);

            // 接收消息
            String receivedMessage = jedis.get(key);
            System.out.println("接收的消息: " + receivedMessage);

            // 验证连接
            if (messageToSend.equals(receivedMessage)) {
                System.out.println("连接验证成功！");
            } else {
                System.out.println("连接验证失败！");
            }
        } catch (Exception e) {
            System.err.println("发生错误: " + e.getMessage());
        } finally {
            // 关闭连接
            if (jedis != null) {
                jedis.close();
            }
        }
    }
}
