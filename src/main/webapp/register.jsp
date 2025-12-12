<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>YY唱片店 - 注册</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            font-family: "Helvetica Neue", Arial, sans-serif;
            color: #fff; /* 字体颜色改为白色 */
        }
        body {
            background-image: linear-gradient(rgba(0,0,0,0.35), rgba(0,0,0,0.35)),
            url('<%= request.getContextPath() %>/static/images/bg-signin.jpg');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            color: #fff; /* 字体颜色改为白色 */
            min-height: 100vh;
        }
        .wrap {
            min-height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            box-sizing: border-box;
        }
        .card {
            width: 360px;
            max-width: calc(100% - 48px);
            background: rgba(255, 255, 255, 0.15); /* 透明度提高 */
            backdrop-filter: blur(10px); /* 毛玻璃效果 */
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(2,6,23,0.45);
            padding: 28px;
            box-sizing: border-box;
            border: 1px solid rgba(255, 255, 255, 0.2); /* 边框透明 */
        }
        .brand {
            text-align: center;
            margin-bottom: 18px;
        }
        .brand h1 {
            margin: 0;
            font-size: 20px;
            letter-spacing: 1px;
            color: #fff; /* 字体颜色改为白色 */
        }
        .brand p {
            margin: 6px 0 0;
            font-size: 13px;
            color: rgba(255, 255, 255, 0.8); /* 字体颜色改为白色，稍透明 */
        }
        .form-group {
            margin-bottom: 14px;
        }
        label {
            display: block;
            font-size: 13px;
            color: rgba(255, 255, 255, 0.9); /* 字体颜色改为白色 */
            margin-bottom: 6px;
        }
        input[type="text"], input[type="password"], input[type="email"] {
            width: 100%;
            padding: 10px 12px;
            background: rgba(255, 255, 255, 0.1); /* 输入框背景透明 */
            border: 1px solid rgba(255, 255, 255, 0.3); /* 边框透明 */
            border-radius: 8px;
            font-size: 14px;
            box-sizing: border-box;
            outline: none;
            transition: border-color .15s, box-shadow .15s;
            color: #fff; /* 输入文字颜色改为白色 */
        }
        input[type="text"]:focus, input[type="password"]:focus, input[type="email"]:focus {
            border-color: rgba(255, 255, 255, 0.6);
            box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.12);
        }
        input::placeholder {
            color: rgba(255, 255, 255, 0.6); /* 占位符颜色改为白色 */
        }
        .btn {
            width: 100%;
            padding: 10px 12px;
            background: rgba(255, 255, 255, 0.2); /* 按钮背景透明 */
            color: #fff;
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 8px;
            font-size: 15px;
            cursor: pointer;
            transition: background .15s;
        }
        .btn:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        .meta {
            text-align: center;
            margin-top: 14px;
            font-size: 13px;
            color: rgba(255, 255, 255, 0.8); /* 字体颜色改为白色 */
        }
        .meta a {
            color: rgba(255, 255, 255, 0.9); /* 链接颜色改为白色 */
            text-decoration: none;
            font-weight: 500;
        }
        .meta a:hover {
            text-decoration: underline;
        }
        .msg {
            padding: 8px 10px;
            margin-bottom: 12px;
            border-radius: 8px;
            font-size: 13px;
        }
        .msg.success {
            background: rgba(6, 95, 70, 0.3); /* 成功消息背景透明 */
            color: #bbf7d0;
            border: 1px solid rgba(187, 247, 208, 0.3);
        }
        .msg.error {
            background: rgba(153, 27, 27, 0.3); /* 错误消息背景透明 */
            color: #fca5a5;
            border: 1px solid rgba(252, 165, 165, 0.3);
        }
        @media (max-width: 420px) {
            .card { padding: 20px; }
        }
    </style>
</head>
<body>
<div class="wrap">
    <div class="card" role="main" aria-labelledby="registerTitle">
        <div class="brand">
            <h1 id="registerTitle">YY唱片店</h1>
            <p>创建新账户，开启你的音乐之旅</p>
        </div>

        <%-- 显示错误信息 --%>
        <% if (request.getAttribute("error") != null) { %>
        <div class="msg error"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="register" method="post" autocomplete="on">
            <div class="form-group">
                <label for="username">用户名</label>
                <input id="username" name="username" type="text" placeholder="请输入用户名" required autofocus>
            </div>
            <div class="form-group">
                <label for="password">密码</label>
                <input id="password" name="password" type="password" placeholder="请输入密码" required>
            </div>
            <div class="form-group">
                <label for="email">邮箱</label>
                <input id="email" name="email" type="email" placeholder="请输入邮箱" required>
            </div>
            <div class="form-group">
                <button class="btn" type="submit">注册</button>
            </div>
        </form>

        <div class="meta">
            已有账号？<a href="login.jsp">立即登录</a>
        </div>
    </div>
</div>
</body>
</html>