# SEproject Chat Platform

一个基于 Java Servlet 与 WebSocket 的实时聊天室示例项目，支持多聊天室管理、用户注册登录、Redis 数据存储以及 JWT 鉴权。项目以 Maven 构建，默认打包为 `war` 供 Tomcat 等容器部署。

## 核心特性
- **实时通信**：基于 `javax.websocket` 的长连接，消息通过 Redis Pub/Sub 即时广播。
- **聊天室管理**：支持聊天室创建、删除、在线人数统计以及历史消息回放。
- **用户体系**：注册与登录使用 BCrypt 加密密码；JWT + 过滤器保护受限资源。
- **持久层支持**：Redis 保存聊天室状态与用户信息，MySQL 预留接口供业务扩展。
- **日志与监控**：使用 Logback 输出运行日志，便于排查问题。

## 技术栈
- Java 21（`maven-compiler-plugin` 使用 `release 21`，建议使用 JDK 21）
- Servlet 4.0、JSP
- WebSocket API 1.1
- Redis（Jedis 3.6.0）
- MySQL 8（通过 `com.qst.util.JDBCUtil` 访问）
- Gson、Jackson、JWT、BCrypt、SLF4J/Logback

## 环境准备
1. **JDK**：安装 JDK 21 并设置 `JAVA_HOME`。
2. **Maven**：建议 Maven 3.8+，确保 `mvn -v` 正常。
3. **Redis**：安装并在本地 `6379` 端口启动，或修改 `RedisManager` / `redis-chat.properties` 指向正确实例。
4. **MySQL（可选）**：默认连接信息位于 `src/main/java/com/qst/util/JDBCUtil.java`，需要时创建名为 `rich` 的数据库或修改连接配置。
5. **Servlet 容器**：Tomcat 9+ 或任意兼容 Servlet 4.0 的容器。

## 快速开始
```bash
# 1. 安装依赖并打包
mvn clean package

# 2. 将生成的 WAR 部署到容器（示例：Tomcat webapps 目录）
copy target/demo_maven.war <TOMCAT_HOME>/webapps/

# 3. 启动容器（以 Tomcat 为例）
<TOMCAT_HOME>/bin/startup.sh  # Windows 请执行 startup.bat
```

部署成功后，可通过以下页面访问：
- 注册 / 登录：`http://<host>:<port>/demo_maven/Sign.jsp`
- 个人信息：`http://<host>:<port>/demo_maven/PersonInfo.jsp`
- 聊天室：`http://<host>:<port>/demo_maven/home.jsp`

WebSocket 终端默认暴露在 `/chat/{roomName}/{userName}`。

## 常用配置
- `src/main/resources/redis-chat.properties`：Redis 连接池参数。
- `src/main/java/com/example/chat/RedisManager.java`：WebSocket 相关 Redis 简易工厂。
- `src/main/java/com/example/chat/util/RedisUtil.java`：用户信息在 Redis 中的键结构。
- `src/main/java/com/qst/util/JDBCUtil.java`：MySQL 连接 URL 与凭据。

## 项目结构
```text
src/
  main/
    java/
      com/example/chat/        # 聊天室核心业务、WebSocket、Servlet
      com/example/chat/util/   # Redis、JWT 等工具类
      com/qst/...              # MySQL 工具与额外实体
    resources/                 # 日志与 Redis 配置
    webapp/                    # JSP 前端与 web.xml
```

## 开发生命周期
- 修改配置后建议执行 `mvn clean` 清理旧构建。
- 引入新依赖时同步更新 `pom.xml`。
- 本地调试可使用 IDE 的 Tomcat/Jetty 集成或 `mvn clean package` 后在外部容器运行。

## 常见问题
- **Redis 未启动**：WebSocket 无法推送消息或聊天室列表为空，请确认 Redis 连接。
- **JWT 失效**：`AuthFilter` 会将未验证请求重定向至 `/auth/login.jsp`，请确保 Cookie 携带 `auth_token`。
- **JDK 版本不匹配**：若使用 JDK 8 构建，可将 `pom.xml` 中 `maven-compiler-plugin` 的 `<release>` 调整为 8，并确保依赖兼容。

## 后续优化建议
- 增加基于数据库的消息持久化与检索。
- 引入前端构建工具优化聊天界面交互体验。
- 通过 Docker 编排 Redis、MySQL、Tomcat 以简化部署。
- 编写自动化测试与健康检查脚本，保障稳定性。

--
