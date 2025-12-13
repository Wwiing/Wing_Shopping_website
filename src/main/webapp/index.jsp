<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.hyy.shopping.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<html>
<head>
    <meta charset="UTF-8">
    <title>YY唱片店</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        body {
            background-image: linear-gradient(rgba(0,0,0,0.35), rgba(0,0,0,0.35)),
            url('<%= request.getContextPath() %>/static/images/bg-index.jpg');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            color: #fff; /* 字体颜色改为白色 */
            min-height: 100vh;
        }
        /* 顶部信息栏 */
        .top-bar {
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: rgba(0,0,0,0.2);
        }
        .user-info p {
            margin-bottom: 5px;
        }
        .admin-tag {
            color: #ff4444;
            font-weight: bold;
            margin-left: 8px;
        }
        .nav-links a {
            color: #fff;
            text-decoration: none;
            margin: 0 8px;
            transition: color 0.2s;
        }
        .nav-links a:hover {
            color: #ff8800;
        }
        .admin-link {
            color: #ff4444 !important;
            font-weight: bold;
        }
        /* 主内容区 */
        .main-content {
            display: flex;
            align-items: center;
            justify-content: space-around;
            padding: 50px 20px;
            max-width: 1200px;
            margin: 0 auto;
            gap: 30px;
        }
        .main-image img {
            max-width: 400px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        }
        .content-text {
            max-width: 400px;
        }
        .content-text h2 {
            font-size: 28px;
            margin-bottom: 30px;
            line-height: 1.5;
        }
        .content-text h4.down{
            margin-bottom: 30px;
            line-height: 1.5;
        }
        .btn-browse {
            background-color: #ff8800;
            color: #fff;
            border: none;
            padding: 12px 24px;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .btn-browse:hover {
            background-color: #e67700;
        }
        /* 未登录样式 */
        .auth-links {
            padding: 20px;
            text-align: center;
        }
        .auth-links a {
            color: #ff8800;
            text-decoration: none;
            margin: 0 10px;
        }
    </style>
</head>
<body>
<%-- 顶部信息栏 --%>
<div class="top-bar">
    <% if (session.getAttribute("user") != null) {
        User user = (User) session.getAttribute("user");
        String role = (String) session.getAttribute("userRole");
        if (role == null && user != null) {
            role = user.getRole();
        }
    %>
    <div class="user-info">
        <p>欢迎, <%= session.getAttribute("username") %>!
            <% if ("ADMIN".equals(role)) { %>
            <span class="admin-tag">[管理员]</span>
            <% } %>
        </p>
        <p>钱包余额: ¥<%= user.getBalance() != null ? user.getBalance() : "0.00" %></p>
    </div>
    <div class="nav-links">
        <a href="wallet">充值</a> |
        <a href="products">浏览商品</a> |
        <a href="cart">查看购物车</a> |
        <a href="order">我的订单</a>
        <% if ("ADMIN".equals(role)) { %>
        | <a href="admin/orders" class="admin-link">订单管理</a>
        <% } %>
        | <a href="login">退出登录</a>
    </div>
    <% } %>
</div>

<% if (session.getAttribute("user") != null) { %>
<%-- 已登录主内容区 --%>
<div class="main-content">
    <div class="main-image">
        <img src="static/images/bg-eason1.jpg" alt="背景图">
    </div>
    <div class="content-text">
        <h2>Grateful that there are always songs to lay bare the state of the heart</h2>
        <h4>With the crystallization of countless hearts</h4>
        <h4 class="down">Forging into the brightest voice of the era</h4>
        <button class="btn-browse" onclick="location.href='products'">Start a music travel</button>
    </div>
</div>
<% } else { %>
<%-- 未登录状态 --%>
<div class="auth-links">
    <a href="register.jsp">注册</a> | <a href="login.jsp">登录</a>
</div>
<% } %>
</body>
</html>