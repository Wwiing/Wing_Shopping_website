<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>用户管理</title>
    <style>
        .admin-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .user-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .user-table th, .user-table td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        .user-table th {
            background-color: #f5f5f5;
        }
    </style>
</head>
<body>
<div class="admin-container">
    <h1>用户管理</h1>

    <!-- 导航 -->
    <div style="margin-bottom: 20px;">
        <a href="../index.jsp">返回首页</a>
        <span style="margin: 0 10px;">|</span>
        <a href="${pageContext.request.contextPath}/admin/products">商品管理</a>
        <span style="margin: 0 10px;">|</span>
        <a href="${pageContext.request.contextPath}/admin/orders">订单管理</a>
        <span style="margin: 0 10px;">|</span>
        <a href="${pageContext.request.contextPath}/admin/sales-report">销售报表</a>
    </div>

    <!-- 错误消息 -->
    <c:if test="${not empty error}">
        <div style="color: red; margin-bottom: 15px;">${error}</div>
    </c:if>

    <!-- 用户列表 -->
    <c:if test="${not empty users}">
        <table class="user-table">
            <thead>
            <tr>
                <th>用户ID</th>
                <th>用户名</th>
                <th>邮箱</th>
                <th>电话</th>
                <th>角色</th>
                <th>注册时间</th>
                <th>操作</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="user" items="${users}">
                <tr>
                    <td>#${user.id}</td>
                    <td>${user.username}</td>
                    <td>${user.email}</td>
                    <td>${user.phone}</td>
                    <td>${user.role}</td>
                    <td>${user.createdAt}</td>
                    <td>
                        <a href="${pageContext.request.contextPath}/admin/user-purchase-history?userId=${user.id}">查看购买记录</a>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:if>

    <c:if test="${empty users and empty error}">
        <div style="text-align: center; padding: 40px;">
            <h3>暂无用户</h3>
        </div>
    </c:if>
</div>
</body>
</html>

