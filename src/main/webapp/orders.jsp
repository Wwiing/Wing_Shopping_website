<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的订单</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        /* 背景设置（保持图片原始尺寸，两边白色） */
        body {
            background: url('<%= request.getContextPath() %>/static/images/bg-3.jpg') no-repeat center fixed;
            background-size: cover; /* 关键：保持图片原始尺寸，不缩放 */
            min-height: 100vh;
            padding-top: 20px;
        }
        /* 顶部导航栏（统一风格） */
        .top-nav {
            max-width: 1100px;
            margin: 0 auto 20px;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(0,0,0,0.8);
            color: #fff;
            border-radius: 8px;
        }
        .top-nav h1 {
            font-size: 20px;
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
        /* 订单主容器 */
        .orders-container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 0 20px;
        }
        /* 订单卡片样式 */
        .order-card {
            border: none;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 20px;
            background: rgba(255,255,255,0.95);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        /* 订单头部 */
        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        .order-header h3 {
            font-size: 18px;
            color: #333;
        }
        .order-header p {
            color: #666;
            font-size: 14px;
            margin-top: 5px;
        }
        .order-header .total-amount {
            font-size: 16px;
            color: #333;
            margin-top: 8px;
        }
        /* 订单状态样式 */
        .status-pending { color: #ff9800; font-weight: bold; font-size: 14px; }
        .status-paid { color: #2196f3; font-weight: bold; font-size: 14px; }
        .status-shipped { color: #4caf50; font-weight: bold; font-size: 14px; }
        .status-delivered { color: #388e3c; font-weight: bold; font-size: 14px; }
        .status-cancelled { color: #f44336; font-weight: bold; font-size: 14px; }
        /* 订单信息 */
        .order-info {
            margin: 15px 0;
            padding: 10px 0;
            color: #666;
        }
        .order-info p {
            margin-bottom: 8px;
            font-size: 14px;
        }
        /* 订单商品列表 */
        .order-items {
            margin: 20px 0;
        }
        .order-items h4 {
            font-size: 16px;
            color: #333;
            margin-bottom: 15px;
        }
        .order-item {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #f5f5f5;
            font-size: 14px;
        }
        .order-item:last-child {
            border-bottom: none;
        }
        .order-item span:last-child {
            color: #e4393c;
            font-weight: bold;
        }
        /* 订单操作区域 */
        .order-actions {
            text-align: right;
            margin-top: 20px;
        }
        /* 按钮样式统一 */
        button {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: background-color 0.2s;
            font-size: 14px;
            margin-left: 8px;
        }
        .btn-view {
            background-color: #2196f3;
            color: #fff;
        }
        .btn-view:hover {
            background-color: #1976d2;
        }
        .btn-cancel {
            background-color: #f44336;
            color: #fff;
        }
        .btn-cancel:hover {
            background-color: #d32f2f;
        }
        .btn-confirm {
            background-color: #4caf50;
            color: #fff;
        }
        .btn-confirm:hover {
            background-color: #388e3c;
        }
        .btn-shopping {
            background-color: #ff8800;
            color: #fff;
            padding: 10px 20px;
            font-size: 16px;
        }
        .btn-shopping:hover {
            background-color: #e67700;
        }
        /* 空订单样式 */
        .empty-orders {
            text-align: center;
            padding: 60px 20px;
            background: rgba(255,255,255,0.95);
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .empty-orders h2 {
            color: #333;
            margin-bottom: 10px;
            font-size: 24px;
        }
        .empty-orders p {
            color: #666;
            margin-bottom: 20px;
            font-size: 16px;
        }
        /* 消息提示样式 */
        .msg-success {
            color: #4caf50;
            margin-bottom: 15px;
            padding: 10px;
            background: rgba(255,255,255,0.95);
            border-radius: 6px;
            border-left: 4px solid #4caf50;
        }
        .msg-error {
            color: #e4393c;
            margin-bottom: 15px;
            padding: 10px;
            background: rgba(255,255,255,0.95);
            border-radius: 6px;
            border-left: 4px solid #e4393c;
        }
        /* 移动端适配 */
        @media (max-width: 768px) {
            .top-nav {
                flex-direction: column;
                gap: 10px;
                text-align: center;
            }
            .order-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            .order-actions {
                text-align: left;
            }
            button {
                margin: 5px 0;
                width: 100%;
            }
            .order-item {
                flex-direction: column;
                gap: 5px;
            }
        }
    </style>
</head>
<body>
<!-- 顶部导航栏 -->
<div class="top-nav">
    <h1>我的订单</h1>
    <div class="nav-links">
        <a href="products">继续购物</a> |
        <a href="index.jsp">首页</a>
    </div>
</div>

<div class="orders-container">
    <!-- 消息显示 -->
    <c:if test="${not empty param.message}">
        <div class="msg-success">${param.message}</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="msg-error">${param.error}</div>
    </c:if>

    <!-- 订单列表 -->
    <c:choose>
        <c:when test="${not empty orders && orders.size() > 0}">
            <c:forEach var="order" items="${orders}">
                <div class="order-card">
                    <div class="order-header">
                        <div>
                            <h3>订单 #${order.id}</h3>
                            <p>下单时间: ${order.createdAt}</p>
                        </div>
                        <div>
                                <span class="status-${order.status.toLowerCase()}">
                                    <c:choose>
                                        <c:when test="${order.status == 'PENDING'}">待付款</c:when>
                                        <c:when test="${order.status == 'PAID'}">已付款</c:when>
                                        <c:when test="${order.status == 'SHIPPED'}">已发货</c:when>
                                        <c:when test="${order.status == 'DELIVERED'}">已完成</c:when>
                                        <c:when test="${order.status == 'CANCELLED'}">已取消</c:when>
                                        <c:otherwise>${order.status}</c:otherwise>
                                    </c:choose>
                                </span>
                            <br>
                            <strong class="total-amount">总计: ¥${order.totalAmount}</strong>
                        </div>
                    </div>

                    <div class="order-info">
                        <p><strong>收货地址:</strong> ${order.shippingAddress}</p>
                        <p><strong>支付方式:</strong> ${order.paymentMethod}</p>
                    </div>

                    <div class="order-items">
                        <h4>商品列表:</h4>
                        <c:forEach var="item" items="${order.orderItems}">
                            <div class="order-item">
                                <span>${item.product.name} × ${item.quantity}</span>
                                <span>¥${item.price * item.quantity}</span>
                            </div>
                        </c:forEach>
                    </div>

                    <div class="order-actions">
                        <a href="order?action=view&orderId=${order.id}">
                            <button class="btn-view">查看详情</button>
                        </a>

                        <c:if test="${order.status == 'PENDING'}">
                            <form action="order" method="post" style="display: inline;">
                                <input type="hidden" name="action" value="cancel">
                                <input type="hidden" name="orderId" value="${order.id}">
                                <button type="submit" class="btn-cancel">取消订单</button>
                            </form>
                        </c:if>

                        <c:if test="${order.status == 'SHIPPED'}">
                            <form action="order" method="post" style="display: inline;">
                                <input type="hidden" name="action" value="confirm">
                                <input type="hidden" name="orderId" value="${order.id}">
                                <button type="submit" class="btn-confirm">确认收货</button>
                            </form>
                        </c:if>
                    </div>
                </div>
            </c:forEach>
        </c:when>

        <c:otherwise>
            <div class="empty-orders">
                <h2>您还没有订单</h2>
                <p>快去挑选心仪的商品，创建您的第一个订单吧！</p>
                <a href="products">
                    <button class="btn-shopping">去购物</button>
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>