<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>YY唱片店 - 登录</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            font-family: "Helvetica Neue", Arial, sans-serif;
            color: #fff;
        }
        body {
            background-image: linear-gradient(rgba(0,0,0,0.35), rgba(0,0,0,0.35)),
            url('<%= request.getContextPath() %>/static/images/bg-signin.jpg');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            color: #fff;
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
            background: #fff;
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
            color: #899ebb;
        }
        .brand p {
            margin: 6px 0 0;
            font-size: 13px;
            color: #e4e6ea;
        }
        .form-group {
            margin-bottom: 14px;
        }
        label {
            display: block;
            font-size: 13px;
            color: #a3baeb;
            margin-bottom: 6px;
        }
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 14px;
            box-sizing: border-box;
            outline: none;
            transition: border-color .15s, box-shadow .15s;
        }
        input[type="text"]:focus, input[type="password"]:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59,130,246,0.12);
        }
        .btn {
            width: 100%;
            padding: 10px 12px;
            background: linear-gradient(180deg,#2563eb,#1e40af);
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            cursor: pointer;
        }
        .meta {
            text-align: center;
            margin-top: 14px;
            font-size: 13px;
            color: #6b7280;
        }
        .meta a {
            color: #e4e6ea;
            text-decoration: none;
        }
        .msg {
            padding: 8px 10px;
            margin-bottom: 12px;
            border-radius: 8px;
            font-size: 13px;
        }
        .msg.success { background: #ecfdf5; color: #065f46; border: 1px solid #bbf7d0; }
        .msg.error { background: #fff1f2; color: #991b1b; border: 1px solid #fca5a5; }
        @media (max-width: 420px) {
            .card { padding: 20px; }
        }
    </style>
</head>
<body>
<div class="wrap">
    <div class="card" role="main" aria-labelledby="loginTitle">
        <div class="brand">
            <h1 id="loginTitle">YY唱片店</h1>
            <p>欢迎回来，请登录</p>
        </div>

        <%-- 显示注册成功消息 --%>
        <% if (request.getParameter("message") != null) { %>
        <div class="msg success"><%= request.getParameter("message") %></div>
        <% } %>

        <%-- 显示错误信息 --%>
        <% if (request.getAttribute("error") != null) { %>
        <div class="msg error"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="login" method="post" autocomplete="on">
            <div class="form-group">
                <label for="username">用户名</label>
                <input id="username" name="username" type="text" placeholder="请输入用户名" required autofocus>
            </div>
            <div class="form-group">
                <label for="password">密码</label>
                <input id="password" name="password" type="password" placeholder="请输入密码" required>
            </div>
            <div class="form-group">
                <button class="btn" type="submit">登录</button>
            </div>
        </form>

        <div class="meta">
            没有账号？<a href="register.jsp">立即注册</a>
        </div>
    </div>
</div>
</body>
</html>
