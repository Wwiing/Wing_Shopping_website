<%--
  Created by IntelliJ IDEA.
  User: HYY
  Date: 2025/11/11
  Time: 15:13
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>购物车</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        /* 背景图（和商品列表统一） */
        body {
            background: url('<%= request.getContextPath() %>/static/images/bg-7.jpg') no-repeat center fixed;
            background-size: 35%;
        }
        /* 顶部导航栏（和其他页面统一风格） */
        .top-nav {
            max-width: 1000px;
            max-height: fit-content;
            margin: 0 auto 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-image: url("static/images/bg-4.jpg");
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
        /* 购物车主容器 */
        .cart-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 0 20px;
        }
        /* 购物车商品项卡片 */
        .cart-item {
            background: rgba(255,255,255,0.95);
            border: none;
            padding: 20px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            gap: 20px;
        }
        /* 商品图片样式 */
        .item-image {
            width: 100px;
            height: 100px;
            flex-shrink: 0;
            border-radius: 8px;
            overflow: hidden;
        }
        .item-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        /* 商品信息 */
        .item-info {
            flex: 2;
        }
        .item-info h3 {
            font-size: 18px;
            margin-bottom: 8px;
            color: #333;
        }
        .item-info p {
            color: #666;
            font-size: 14px;
        }
        /* 操作区域 */
        .item-actions {
            flex: 1;
            text-align: right;
        }
        .quantity-control {
            display: inline-block;
            margin: 0 10px;
        }
        /* 按钮样式美化 */
        input[type="number"] {
            padding: 6px 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            outline: none;
            transition: border-color 0.2s;
        }
        input[type="number"]:focus {
            border-color: #ff8800;
        }
        button {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.2s;
            font-size: 14px;
        }
        .btn-delete {
            color: #fff;
            background-color: #e4393c;
        }
        .btn-delete:hover {
            background-color: #d0282b;
        }
        .btn-clear {
            background-color: #999;
            color: #fff;
        }
        .btn-clear:hover {
            background-color: #777;
        }
        .btn-checkout {
            background-color: #ff8800;
            color: #fff;
            margin-left: 10px;
        }
        .btn-checkout:hover {
            background-color: #e67700;
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
        /* 总计区域 */
        .total-section {
            text-align: right;
            padding: 20px;
            background: rgba(255,255,255,0.95);
            border-radius: 10px;
            box-shadow: 0 4px 8px 2px rgba(0, 0, 0, 0.1);
        }
        .total-section h2 {
            color: #e4393c;
            margin-bottom: 15px;
            font-size: 22px;
        }
        /* 空购物车样式 */
        .empty-cart {
            text-align: center;
            padding: 60px 20px;
            background: rgba(255,255,255,0.95);
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .empty-cart h2 {
            color: #333;
            margin-bottom: 10px;
            font-size: 24px;
        }
        .empty-cart p {
            color: #666;
            margin-bottom: 20px;
            font-size: 16px;
        }
        /* 错误提示 */
        .error-msg {
            color: #e4393c;
            margin-bottom: 15px;
            padding: 10px;
            background: rgba(255,255,255,0.95);
            border-radius: 6px;
        }
        /* 移动端适配 */
        @media (max-width: 768px) {
            .cart-item {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            .item-actions {
                text-align: left;
                width: 100%;
                margin-top: 10px;
            }
            .total-section {
                text-align: center;
            }
            .top-nav {
                flex-direction: column;
                gap: 10px;
                text-align: center;
            }
            .item-image {
                width: 80px;
                height: 80px;
            }
        }
    </style>
</head>
<body>
<!-- 顶部导航栏（统一风格） -->
<div class="top-nav">
    <h1>我的购物车</h1>
    <div class="nav-links">
        <a href="products">继续购物</a> |
        <a href="index.jsp">首页</a>
    </div>
</div>

<div class="cart-container">
    <%-- Error Message --%>
    <c:if test="${not empty param.error}">
        <div class="error-msg">${param.error}</div>
    </c:if>

    <%-- Cart Items --%>
    <c:choose>
        <c:when test="${not empty cartItems && cartItems.size() > 0}">
            <c:forEach var="item" items="${cartItems}">
                <div class="cart-item">
                    <!-- 商品图片 -->
                    <div class="item-image">
                        <img src="${item.product.imageUrl}" alt="${item.product.name}">
                    </div>

                    <div class="item-info">
                        <h3>${item.product.name}</h3>
                        <p>单价：¥${item.product.price}</p>
                    </div>

                    <div class="item-actions">
                            <%-- Update Quantity Form --%>
                        <form action="cart" method="post" style="display: inline;">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="cartItemId" value="${item.id}">
                            <label>数量: </label>
                            <input type="number" name="quantity" value="${item.quantity}" min="1" max="100"
                                   style="width: 60px;" onchange="this.form.submit()">
                        </form>

                            <%-- Remove Item Form --%>
                        <form action="cart" method="post" style="display: inline; margin-left: 10px;">
                            <input type="hidden" name="action" value="remove">
                            <input type="hidden" name="cartItemId" value="${item.id}">
                            <button type="submit" class="btn-delete">删除</button>
                        </form>

                        <p style="margin-top: 8px;">
                            <strong>小计: ¥${item.product.price * item.quantity}</strong>
                        </p>
                    </div>
                </div>
            </c:forEach>

            <%-- Total Section --%>
            <div class="total-section">
                <h2>购物车总计： ¥${totalAmount}</h2>

                    <%-- Clear Cart --%>
                <form action="cart" method="post" style="display: inline; margin-right: 10px;">
                    <input type="hidden" name="action" value="clear">
                    <button type="submit" class="btn-clear">清空购物车</button>
                </form>

                    <%-- Checkout Button --%>
                <a href="checkout">
                    <button class="btn-checkout">去结算</button>
                </a>
            </div>
        </c:when>

        <c:otherwise>
            <div class="empty-cart">
                <h2>您的购物车空空如也</h2>
                <p>快去挑选心仪的商品吧！</p>
                <a href="products">
                    <button class="btn-shopping">立即购物</button>
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>