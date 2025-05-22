<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
  <title>账号中心</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    :root {
      --primary: #4361ee;
      --secondary: #3f37c9;
      --light: #f8f9fa;
      --dark: #212529;
      --success: #4cc9f0;
      --danger: #f72585;
    }

    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Inter', sans-serif;
      background-color: #f5f7ff;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      overflow-x: hidden;
    }

    .auth-container {
      display: flex;
      width: 1000px;
      height: 600px;
      background: white;
      border-radius: 20px;
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1);
      overflow: hidden;
      position: relative;
    }

    /* 左侧装饰面板 */
    .auth-panel {
      flex: 1;
      background: linear-gradient(135deg, var(--primary), var(--secondary));
      padding: 60px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      color: white;
      position: relative;
      z-index: 1;
    }

    .auth-panel::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveAspectRatio="none"><path fill="white" opacity="0.05" d="M0,0 L100,0 L100,100 Q50,80 0,100 Z"></path></svg>');
      background-size: cover;
      z-index: -1;
    }

    .panel-content {
      max-width: 320px;
    }

    .panel-title {
      font-size: 28px;
      font-weight: 700;
      margin-bottom: 10px;
      display: flex;
      align-items: center;
    }

    .panel-title:before {
      content: "💬";
      margin-right: 12px;
      font-size: 32px;
    }
    .panel-text {
      font-size: 15px;
      line-height: 1.6;
      opacity: 0.9;
      margin-bottom: 30px;
    }

    /* 右侧表单区域 */
    .auth-forms {
      flex: 1;
      padding: 60px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      position: relative;
    }

    .form-container {
      width: 100%;
      max-width: 360px;
      margin: 0 auto;
    }

    .form-header {
      text-align: center;
      margin-bottom: 40px;
    }

    .form-title {
      font-size: 28px;
      font-weight: 600;
      color: var(--dark);
      margin-bottom: 10px;
    }

    .form-subtitle {
      color: #6c757d;
      font-size: 14px;
    }

    .auth-form {
      display: flex;
      flex-direction: column;
      gap: 20px;
    }

    .form-group {
      display: flex;
      flex-direction: column;
    }

    .form-label {
      font-size: 14px;
      font-weight: 500;
      color: var(--dark);
      margin-bottom: 8px;
    }

    .form-input {
      padding: 14px 16px;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      font-size: 15px;
      transition: all 0.2s;
      background-color: #f8fafc;
    }

    .form-input:focus {
      border-color: var(--primary);
      box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.1);
      background-color: white;
      outline: none;
    }

    .form-actions {
      display: flex;
      flex-direction: column;
      gap: 15px;
      margin-top: 10px;
    }

    .btn {
      padding: 14px;
      border-radius: 10px;
      font-size: 15px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
      text-align: center;
      border: none;
    }

    .btn-primary {
      background-color: var(--primary);
      box-shadow: 0 4px 12px rgba(67, 97, 238, 0.2);
      color: white;
    }

    .btn-primary:hover {
      background-color: var(--secondary);
      transform: translateY(-2px);
      box-shadow: 0 6px 16px rgba(67, 97, 238, 0.2);
    }

    .btn-link {
      color: var(--primary);
      background: none;
      text-decoration: none;
      font-size: 14px;
    }

    .btn-link:hover {
      text-decoration: underline;
    }

    /* 表单切换效果 */
    #loginForm, #registerForm {
      transition: all 0.4s ease;
    }

    #registerForm {
      position: absolute;
      top: 60px;
      left: 60px;
      right: 60px;
      opacity: 0;
      pointer-events: none;
      transform: translateX(20px);
    }

    .show-register #loginForm {
      opacity: 0;
      pointer-events: none;
      transform: translateX(-20px);
    }

    .show-register #registerForm {
      opacity: 1;
      pointer-events: all;
      transform: translateX(0);
    }
    .show-register .form-container {
      opacity: 0;
      transform: translateX(-20px);
    }

    /* Toast通知 */
    .toast {
      position: fixed;
      top: 30px;
      right: 30px;
      padding: 16px 24px;
      background: var(--danger);
      color: white;
      border-radius: 8px;
      box-shadow: 0 10px 25px rgba(247, 37, 133, 0.2);
      display: flex;
      align-items: center;
      gap: 12px;
      z-index: 1000;
      transform: translateX(150%);
      transition: transform 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
    }

    .toast.show {
      transform: translateX(0);
    }

    .toast-icon {
      width: 24px;
      height: 24px;
      background: white;
      border-radius: 50%;
      color: var(--danger);
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: bold;
      flex-shrink: 0;
    }

    /* 聊天泡泡装饰 */
    .chat-bubble {
      position: absolute;
      background: white;
      border-radius: 50%;
      opacity: 0.1;
    }

    .bubble-1 {
      width: 120px;
      height: 120px;
      top: -30px;
      left: -30px;
    }

    .bubble-2 {
      width: 80px;
      height: 80px;
      bottom: 20px;
      right: 40px;
    }

    /* 响应式设计 */
    @media (max-width: 1024px) {
      .auth-container {
        width: 90%;
        height: auto;
        flex-direction: column;
      }

      .auth-panel, .auth-forms {
        padding: 40px;
      }

      .panel-content {
        max-width: 100%;
        text-align: center;
        margin-bottom: 40px;
      }

      #registerForm {
        position: static;
        opacity: 1;
        pointer-events: all;
        transform: none;
      }

      .show-register #loginForm {
        display: none;
      }
      .show-register .form-container {
        opacity: 0;
        transform: translateX(-20px);
      }
    }
    /* 错误提示样式 */
    .error-message {
      color: var(--danger);
      font-size: 12px;
      margin-top: 4px;
      display: none;
    }

    .input-error {
      border-color: var(--danger) !important;
      box-shadow: 0 0 0 3px rgba(247, 37, 133, 0.1) !important;
    }

  </style>
</head>
<body>
<div class="auth-container" id="authContainer">
  <!-- 左侧装饰面板 -->
  <div class="auth-panel">
    <div class="panel-content">
      <h2 class="panel-title">实时聊天室</h2>
      <p class="panel-text">连接世界，畅所欲言</p>
       </div>

    <div class="chat-bubble bubble-1"></div>
    <div class="chat-bubble bubble-2"></div>
  </div>

  <!-- 右侧表单区域 -->
  <div class="auth-forms">
    <div class="form-container">
      <!-- 登录表单标题 -->
      <div class="form-header">
        <h3 class="form-title">欢迎回来</h3>
        <p class="form-subtitle">请输入您的账号信息登录系统</p>
      </div>
    </div>

      <!-- 登录表单 -->
      <form class="auth-form" action="./UserServlet" method="post" id="loginForm">
        <div class="form-group">
          <label class="form-label" for="login_name">用户名</label>
          <input class="form-input" id="login_name" name="login_name" type="text" required>
        </div>

        <div class="form-group">
          <label class="form-label" for="login_password">密码</label>
          <input class="form-input" id="login_password" name="login_password" type="password" required>
        </div>

        <div class="form-actions">
          <button class="btn btn-primary" type="submit">登录</button>
          <button class="btn btn-link" type="button" onclick="showRegisterForm()">没有账号？立即注册</button>
        </div>
        <input type="hidden" name="op" value="login">
      </form>

      <!-- 注册表单 -->
      <form class="auth-form" action="./UserServlet" method="post" id="registerForm">
        <div class="form-group">
          <label class="form-label" for="name">用户名</label>
          <input class="form-input" id="name" name="name" type="text" required>
        </div>

        <div class="form-group">
          <label class="form-label" for="email">电子邮箱</label>
          <input class="form-input" id="email" name="email" type="email" required>
        </div>

        <div class="form-group">
          <label class="form-label" for="password">密码</label>
          <input class="form-input" id="password" name="password" type="password" required>
        </div>

        <div class="form-group">
          <label class="form-label" for="cnfpwd">确认密码</label>
          <input class="form-input" id="cnfpwd" name="cnfpwd" type="password" required>
        </div>

        <div class="form-actions">
          <button class="btn btn-primary" type="submit">注册</button>
          <button class="btn btn-link" type="button" onclick="showLoginForm()">已有账号？立即登录</button>
        </div>
        <input type="hidden" name="op" value="register">
      </form>
    </div>
  </div>
</div>

<!-- Toast通知 -->
<div id="toast" class="toast">
  <div class="toast-icon">!</div>
  <div class="toast-message" id="toastMessage"></div>
</div>

<script>
  // 显示Toast通知
  function showToast(message) {
    const toast = document.getElementById("toast");
    const toastMessage = document.getElementById("toastMessage");

    toastMessage.textContent = message;
    toast.classList.add("show");

    setTimeout(() => {
      toast.classList.remove("show");
    }, 3500);
  }

  // 邮箱验证函数
  function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
  }
  const emailInput = document.getElementById('email');
  const emailError = document.createElement('div');
  emailError.className = 'error-message';
  emailError.textContent = '请输入有效的电子邮件地址（需包含@和域名）';
  emailInput.parentNode.appendChild(emailError);

  emailInput.addEventListener('input', function() {
    if (this.value.length > 0) {
      if (!validateEmail(this.value)) {
        this.classList.add('input-error');
        emailError.style.display = 'block';
      } else {
        this.classList.remove('input-error');
        emailError.style.display = 'none';
      }
    } else {
      this.classList.remove('input-error');
      emailError.style.display = 'none';
    }
  });

  function showRegisterForm() {
    document.getElementById('authContainer').classList.add('show-register');
  }

  function showLoginForm() {
    document.getElementById('authContainer').classList.remove('show-register');
  }

  document.getElementById('loginForm').addEventListener('submit', function(e) {
    const btn = this.querySelector('.btn-primary');
    btn.textContent = '登录中...';
    btn.disabled = true;
  });

  document.getElementById('registerForm').addEventListener('submit', function(e) {
    const email = emailInput.value;
    const btn = this.querySelector('.btn-primary');

    if (!validateEmail(email)) {
      e.preventDefault();
      emailInput.classList.add('input-error');
      emailError.style.display = 'block';
      showToast('请输入有效的电子邮件地址');
      return false;
    }

    btn.textContent = '注册中...';
    btn.disabled = true;
  });

  // 显示错误信息
  window.onload = function() {
    <% if (request.getAttribute("loginError") != null) { %>
    showToast("<%= request.getAttribute("loginError") %>");
    <% } %>

    <% if (request.getAttribute("registerError") != null) { %>
    showToast("<%= request.getAttribute("registerError") %>");
    <% } %>
  };
</script>
<script>
  document.getElementById('loginForm').addEventListener('submit', function(e) {
    const btn = this.querySelector('.btn-primary');
    btn.textContent = '登录中...';
    btn.disabled = true;

    // 修改登录成功后的跳转
    this.action = '<%=request.getContextPath()%>/UserServlet?op=login';
  });
</script>
</body>
</html>