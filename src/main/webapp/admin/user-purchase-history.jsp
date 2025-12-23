<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>用户购买记录</title>
    <style>
        .admin-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .order-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .order-table th, .order-table td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        .order-table th {
            background-color: #f5f5f5;
        }
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
        }
        .status-pending { background-color: #ff9800; color: white; }
        .status-paid { background-color: #2196f3; color: white; }
        .status-shipped { background-color: #4caf50; color: white; }
        .status-delivered { background-color: #388e3c; color: white; }
        .status-cancelled { background-color: #f44336; color: white; }
    </style>
</head>
<body>
<div class="admin-container">
    <h1>用户购买记录 - ${customer.username}</h1>

    <!-- 导航 -->
    <div style="margin-bottom: 20px;">
        <a href="${pageContext.request.contextPath}/admin/user-management">返回用户管理</a>
    </div>

    <!-- 错误消息 -->
    <c:if test="${not empty error}">
        <div style="color: red; margin-bottom: 15px;">${error}</div>
    </c:if>

    <!-- 订单列表 -->
    <c:if test="${not empty orders}">
        <table class="order-table">
            <thead>
            <tr>
                <th>订单号</th>
                <th>金额</th>
                <th>状态</th>
                <th>下单时间</th>
                <th>收货地址</th>
                <th>操作</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="order" items="${orders}">
                <tr>
                    <td>#${order.id}</td>
                    <td>¥${order.totalAmount}</td>
                    <td>
                        <span class="status-badge status-${order.status.toLowerCase()}">
                            <c:choose>
                                <c:when test="${order.status == 'PENDING'}">待付款</c:when>
                                <c:when test="${order.status == 'PAID'}">已付款</c:when>
                                <c:when test="${order.status == 'SHIPPED'}">已发货</c:when>
                                <c:when test="${order.status == 'DELIVERED'}">已完成</c:when>
                                <c:when test="${order.status == 'CANCELLED'}">已取消</c:when>
                            </c:choose>
                        </span>
                    </td>
                    <td>${order.createdAt}</td>
                    <td>${order.shippingAddress}</td>
                    <td>
                        <a href="${pageContext.request.contextPath}/order?action=view&orderId=${order.id}">查看详情</a>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:if>

    <c:if test="${empty orders and empty error}">
        <div style="text-align: center; padding: 40px;">
            <h3>该用户暂无购买记录</h3>
        </div>
    </c:if>
</div>
</body>
</html>

