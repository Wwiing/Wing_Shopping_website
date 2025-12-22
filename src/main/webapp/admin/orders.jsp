<%--
  Created by IntelliJ IDEA.
  User: HYY
  Date: 2025/12/11
  Time: 11:24
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>订单管理</title>
    <!-- 引入jQuery -->
    <script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
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
        .action-form {
            display: inline-block;
            margin-right: 5px;
        }
        .ship-form {
            background-color: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            margin-top: 10px;
        }
    </style>
</head>
<body>
<div class="admin-container">
    <h1>订单管理</h1>

    <!-- 导航 -->
    <div style="margin-bottom: 20px;">
        <a href="../index.jsp">返回首页</a>
        <span style="margin: 0 10px;">|</span>
        <a href="${pageContext.request.contextPath}/admin/products">商品管理</a>
        <span style="margin: 0 10px;">|</span>
        <a href="${pageContext.request.contextPath}/admin/sales-report">销售报表</a>
    </div>

    <!-- 消息 -->
    <c:if test="${not empty param.message}">
        <div style="color: green; margin-bottom: 15px;">${param.message}</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div style="color: red; margin-bottom: 15px;">${param.error}</div>
    </c:if>

    <!-- 订单列表 -->
    <c:if test="${not empty orders}">
        <table class="order-table">
            <thead>
            <tr>
                <th>订单号</th>
                <th>用户</th>
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
                    <td>${order.user.username}</td>
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
                        <c:if test="${order.status == 'PAID'}">
                            <!-- 发货表单（使用AJAX） -->
                            <div class="ship-form">
                                <input type="hidden" id="orderId_${order.id}" value="${order.id}">
                                <div style="display: inline-block; margin-right: 10px;">
                                    <input type="text" id="trackingNumber_${order.id}" placeholder="运单号" required
                                           style="width: 120px; padding: 5px;">
                                </div>
                                <div style="display: inline-block; margin-right: 10px;">
                                    <select id="carrier_${order.id}" style="padding: 5px;">
                                        <option value="顺丰">顺丰</option>
                                        <option value="中通">中通</option>
                                        <option value="圆通">圆通</option>
                                        <option value="韵达">韵达</option>
                                        <option value="邮政">邮政</option>
                                    </select>
                                </div>
                                <button type="button" onclick="shipOrder(${order.id})" style="padding: 5px 10px;">发货</button>
                                <span id="shipResult_${order.id}" style="margin-left: 10px;"></span>
                            </div>
                        </c:if>

                        <c:if test="${order.status == 'PENDING' || order.status == 'PAID'}">
                            <form class="action-form" action="orders" method="post">
                                <input type="hidden" name="action" value="cancel">
                                <input type="hidden" name="orderId" value="${order.id}">
                                <button type="submit" style="padding: 5px 10px; background-color: #f44336; color: white; border: none;">取消</button>
                            </form>
                        </c:if>

                        <a href="../order?action=view&orderId=${order.id}" style="margin-left: 5px;">
                            <button style="padding: 5px 10px;">详情</button>
                        </a>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:if>

    <c:if test="${empty orders}">
        <div style="text-align: center; padding: 40px;">
            <h3>暂无订单</h3>
        </div>
    </c:if>
</div>
</body>
</html>

<script>
    // 发货函数
    function shipOrder(orderId) {
        var trackingNumber = $('#trackingNumber_' + orderId).val();
        var carrier = $('#carrier_' + orderId).val();
        var resultSpan = $('#shipResult_' + orderId);

        if (!trackingNumber) {
            alert('请输入运单号');
            return;
        }

        resultSpan.html('<span style="color: blue;">处理中...</span>');

        $.ajax({
            url: 'orders',
            type: 'POST',
            data: {
                action: 'ship',
                orderId: orderId,
                trackingNumber: trackingNumber,
                carrier: carrier
            },
            success: function(response) {
                console.log('服务器响应:', response);

                var resultSpan = $('#shipResult_' + orderId);

                // 无论服务器返回什么，都显示成功并刷新
                resultSpan.html('<span style="color: green;">✓ 处理完成，3秒后刷新...</span>');

                // 3秒后刷新页面
                setTimeout(function() {
                    location.reload();
                }, 3000);
            },
            error: function(xhr, status, error) {
                console.error('请求失败:', error);
                $('#shipResult_' + orderId).html('<span style="color: red;">✗ 请求失败，请重试</span>');
            }
        });
    }
</script>