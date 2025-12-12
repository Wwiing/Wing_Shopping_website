<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <!-- 使用CDN引入jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>订单详情</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        /* 背景设置（固定+铺满，滚动不消失） */
        body {
            background: url('<%= request.getContextPath() %>/static/images/bg-3.jpg') no-repeat center fixed;
            background-size: cover;
            min-height: 100vh;
            padding-top: 20px;
            color: #333;
        }
        /* 顶部导航栏（统一风格） */
        .top-nav {
            max-width: 900px;
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
        /* 详情主容器 */
        .order-detail-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 0 20px;
        }
        /* 订单模块样式 */
        .order-section {
            margin-bottom: 20px;
            padding: 25px;
            background: rgba(255,255,255,0.95);
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border: none;
        }
        .order-section h2 {
            font-size: 18px;
            margin-bottom: 20px;
            color: #333;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        /* 订单信息样式 */
        .order-section p {
            margin-bottom: 12px;
            font-size: 14px;
            line-height: 1.6;
        }
        .order-section p strong {
            color: #333;
            min-width: 80px;
            display: inline-block;
        }
        /* 订单状态样式 */
        .status-pending { color: #ff9800; font-weight: bold; font-size: 14px; }
        .status-paid { color: #2196f3; font-weight: bold; font-size: 14px; }
        .status-shipped { color: #4caf50; font-weight: bold; font-size: 14px; }
        .status-delivered { color: #388e3c; font-weight: bold; font-size: 14px; }
        .status-cancelled { color: #f44336; font-weight: bold; font-size: 14px; }
        /* 订单商品项 */
        .order-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 0;
            border-bottom: 1px solid #f5f5f5;
        }
        .order-item:last-child {
            border-bottom: none;
        }
        .order-item div:first-child {
            color: #333;
        }
        .order-item div:last-child {
            color: #e4393c;
            font-weight: bold;
            font-size: 16px;
        }
        .order-item small {
            color: #666;
            font-size: 12px;
        }
        /* 总计区域 */
        .total-section {
            text-align: right;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 2px solid #eee;
        }
        .total-section h2 {
            font-size: 20px;
            color: #e4393c;
            border: none;
            padding: 0;
            margin: 0;
        }
        /* 按钮样式统一 */
        button {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: background-color 0.2s;
            font-size: 14px;
            margin: 0 8px;
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
        .btn-back {
            background-color: #2196f3;
            color: #fff;
        }
        .btn-back:hover {
            background-color: #1976d2;
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
        /* 空订单/订单不存在样式 */
        .empty-order {
            text-align: center;
            padding: 60px 20px;
            background: rgba(255,255,255,0.95);
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .empty-order h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 24px;
        }
        /* 移动端适配 */
        @media (max-width: 768px) {
            .top-nav {
                flex-direction: column;
                gap: 10px;
                text-align: center;
            }
            .order-item {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            .order-section {
                padding: 20px 15px;
            }
            button {
                margin: 8px 0;
                width: 100%;
            }
            .total-section {
                text-align: left;
            }
        }
    </style>
</head>
<body>
<!-- 顶部导航栏 -->
<div class="top-nav">
    <h1>订单详情</h1>
    <div class="nav-links">
        <a href="order">返回订单列表</a> |
        <a href="products">继续购物</a>
    </div>
</div>

<div class="order-detail-container">
    <!-- 消息 -->
    <c:if test="${not empty param.message}">
        <div class="msg-success">${param.message}</div>
    </c:if>

    <c:if test="${not empty order}">
        <!-- 订单信息 -->
        <div class="order-section">
            <h2>订单信息</h2>
            <p><strong>订单号:</strong> #${order.id}</p>
            <p><strong>下单时间:</strong> ${order.createdAt}</p>
            <p><strong>状态:</strong>
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
            </p>
            <p><strong>订单金额:</strong> ¥${order.totalAmount}</p>
        </div>

        <!-- 收货信息 -->
        <div class="order-section">
            <h2>收货信息</h2>
            <p><strong>收货地址:</strong> ${order.shippingAddress}</p>
            <p><strong>支付方式:</strong> 余额支付</p>
        </div>

        <!-- 订单商品 -->
        <div class="order-section">
            <h2>订单商品</h2>
            <c:forEach var="item" items="${order.orderItems}">
                <div class="order-item">
                    <div>
                        <strong>${item.product.name}</strong>
                        <br>
                        <small>数量: ${item.quantity}</small>
                        <br>
                        <small>单价: ¥${item.price}</small>
                    </div>
                    <div>
                        <strong>¥${item.price * item.quantity}</strong>
                    </div>
                </div>
            </c:forEach>

            <div class="total-section">
                <h2>订单总计: ¥${order.totalAmount}</h2>
            </div>
        </div>

        <!-- 订单操作 -->
        <div class="order-section" style="text-align: center;">
            <c:if test="${order.status == 'PENDING'}">
                <form action="order" method="post" style="display: inline;">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="orderId" value="${order.id}">
                    <button type="submit" class="btn-cancel">取消订单</button>
                </form>
            </c:if>

            <c:if test="${order.status == 'SHIPPED'}">
                <button type="button" onclick="confirmReceipt(${order.id})" class="btn-confirm">
                    确认收货
                </button>
            </c:if>

            <a href="order">
                <button class="btn-back">返回订单列表</button>
            </a>
        </div>
    </c:if>

    <c:if test="${empty order}">
        <div class="empty-order">
            <h2>订单不存在</h2>
            <a href="orders">
                <button class="btn-back">返回订单列表</button>
            </a>
        </div>
    </c:if>
</div>
</body>
</html>

<script>
    // 确认收货函数
    function confirmReceipt(orderId) {
        if (!confirm('确定要确认收货吗？')) {
            return;
        }

        $.ajax({
            url: 'order',
            type: 'POST',
            data: {
                action: 'confirm',
                orderId: orderId
            },
            success: function(response) {
                // 解析服务器返回的JSON
                var result = JSON.parse(response);

                if (result.success) {
                    alert('确认收货成功！');
                    // 更新页面状态显示
                    $('.status-shipped').text('已完成').removeClass('status-shipped').addClass('status-delivered');
                    // 隐藏确认收货按钮
                    $('button[onclick^="confirmReceipt"]').hide();
                    // 刷新页面保证状态同步
                    location.reload();
                } else {
                    alert('操作失败: ' + result.message);
                }
            },
            error: function() {
                alert('网络错误，请重试');
            }
        });
    }
</script>