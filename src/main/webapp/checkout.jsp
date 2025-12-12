<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>订单支付</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        /* 背景设置（按你要求：图片保持原始尺寸，两边白色） */
        body {
            background: url('<%= request.getContextPath() %>/static/images/bg-2.jpg') no-repeat center top;
            background-size: 100%;
            min-height: 100vh;
            padding-top: 20px;
        }
        /* 顶部导航栏（统一风格） */
        .top-nav {
            max-width: 900px;
            margin: 0 auto 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(0,0,0,0.8);
            color: #fff;
            padding: 15px 20px;
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
        /* 支付主容器 */
        .checkout-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 0 20px;
        }
        /* 支付模块样式 */
        .checkout-section {
            margin-bottom: 20px;
            padding: 25px;
            background: rgba(255,255,255,0.95);
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border: none;
        }
        .checkout-section h2 {
            font-size: 18px;
            margin-bottom: 20px;
            color: #333;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        /* 订单摘要样式 */
        .order-summary {
            background: rgba(249,249,249,0.95);
        }
        /* 表单样式 */
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
        }
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            box-sizing: border-box;
            resize: vertical;
            outline: none;
            transition: border-color 0.2s;
        }
        .form-group textarea:focus {
            border-color: #ff8800;
        }
        /* 订单商品项 */
        .order-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 0;
            border-bottom: 1px solid #eee;
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
        /* 余额提示区域 */
        .balance-info {
            margin-bottom: 20px;
            padding: 15px;
            background-color: #e8f5e9;
            border-radius: 8px;
            border-left: 4px solid #4caf50;
        }
        .balance-info p {
            margin-bottom: 8px;
            color: #333;
        }
        .balance-info .error-tip {
            color: #f44336;
            font-weight: bold;
        }
        /* 按钮样式 */
        .btn-recharge {
            padding: 8px 16px;
            background-color: #4caf50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.2s;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
        }
        .btn-recharge:hover {
            background-color: #43a047;
        }
        .btn-submit {
            padding: 12px 40px;
            font-size: 16px;
            background-color: #4caf50;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .btn-submit:hover {
            background-color: #43a047;
        }
        .btn-disabled {
            padding: 12px 40px;
            font-size: 16px;
            background-color: #ff9800;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: not-allowed;
        }
        /* 错误提示 */
        .error-msg {
            color: #e4393c;
            margin-bottom: 15px;
            padding: 10px;
            background: rgba(255,255,255,0.95);
            border-radius: 6px;
            border-left: 4px solid #e4393c;
        }
        /* 提交区域 */
        .submit-area {
            text-align: center;
            margin-top: 30px;
            padding: 20px;
            background: rgba(255,255,255,0.95);
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
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
                gap: 5px;
            }
            .total-section {
                text-align: left;
            }
            .btn-submit, .btn-disabled {
                width: 100%;
            }
        }
    </style>
</head>
<body>
<!-- 顶部导航栏 -->
<div class="top-nav">
    <h1>订单支付</h1>
    <div class="nav-links">
        <a href="cart">返回购物车</a> |
        <a href="products">继续购物</a>
    </div>
</div>

<div class="checkout-container">
    <%-- 错误提示 --%>
    <c:if test="${not empty param.error}">
        <div class="error-msg">${param.error}</div>
    </c:if>

    <form action="order" method="post">
        <input type="hidden" name="action" value="create">

        <%-- 收货信息 --%>
        <div class="checkout-section">
            <h2>收货信息</h2>
            <div class="form-group">
                <label for="shippingAddress">收货地址 *</label>
                <textarea id="shippingAddress" name="shippingAddress" rows="3" required
                          placeholder="请输入详细的收货地址（如：XX省XX市XX区XX街道XX号）"></textarea>
            </div>
        </div>

        <%-- 订单摘要 --%>
        <div class="checkout-section order-summary">
            <h2>订单摘要</h2>

            <!-- 余额显示 -->
            <div class="balance-info">
                <p><strong>当前余额:</strong> ¥${user.balance}</p>
                <p><strong>订单金额:</strong> ¥${totalAmount}</p>
                <c:if test="${user.balance < totalAmount}">
                    <p class="error-tip">余额不足，请先充值！</p>
                    <a href="wallet" class="btn-recharge">立即充值</a>
                </c:if>
            </div>

            <c:forEach var="item" items="${cartItems}">
                <div class="order-item">
                    <div>
                        <strong>${item.product.name}</strong>
                        <br>
                        <small>数量: ${item.quantity}</small>
                    </div>
                    <div>
                        ¥${item.product.price * item.quantity}
                    </div>
                </div>
            </c:forEach>

            <div class="total-section">
                <h2>订单总计 ¥${totalAmount}</h2>
            </div>
        </div>

        <%-- 提交按钮 --%>
        <div class="submit-area">
            <c:choose>
                <c:when test="${user.balance >= totalAmount}">
                    <button type="submit" class="btn-submit">
                        确认下单（从余额支付）
                    </button>
                </c:when>
                <c:otherwise>
                    <button type="button" onclick="alert('余额不足，请先充值！')" class="btn-disabled">
                        余额不足
                    </button>
                </c:otherwise>
            </c:choose>
        </div>
    </form>
</div>
</body>
</html>