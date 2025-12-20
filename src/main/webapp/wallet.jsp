<%--
  Created by IntelliJ IDEA.
  User: HYY
  Date: 2025/12/10
  Time: 23:50
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>我的钱包</title>
    <style>
        .wallet-container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .balance-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 30px;
        }
        .balance-amount {
            font-size: 48px;
            font-weight: bold;
            margin: 20px 0;
        }
        .recharge-form {
            background-color: #f9f9f9;
            padding: 25px;
            border-radius: 8px;
            margin-top: 20px;
        }
        .amount-buttons {
            display: flex;
            justify-content: space-between;
            margin: 15px 0;
        }
        .amount-btn {
            flex: 1;
            margin: 0 5px;
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 5px;
            background: white;
            cursor: pointer;
        }
        .amount-btn:hover {
            border-color: #667eea;
        }
        .amount-btn.active {
            border-color: #667eea;
            background-color: #667eea;
            color: white;
        }
    </style>
</head>
<body>
<div class="wallet-container">
    <h1>我的钱包</h1>

    <!-- 导航 -->
    <div style="margin-bottom: 20px;">
        <a href="index.jsp">首页</a> |
        <a href="order">我的订单</a> |
        <a href="products">继续购物</a> |
        <a href="cart">返回购物车</a>
    </div>

    <!-- 消息 -->
    <c:if test="${not empty param.message}">
        <div style="color: green; margin-bottom: 15px;">${param.message}</div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div style="color: red; margin-bottom: 15px;">${param.error}</div>
    </c:if>

    <!-- 余额显示 -->
    <div class="balance-card">
        <h2>账户余额</h2>
        <div class="balance-amount">¥${user.balance}</div>
        <p>可用于购物支付</p>
    </div>

    <!-- 充值表单 -->
    <div class="recharge-form">
        <h2>充值</h2>
        <form action="wallet" method="post">
            <input type="hidden" name="action" value="recharge">

            <div style="margin-bottom: 15px;">
                <label style="display: block; margin-bottom: 8px; font-weight: bold;">选择充值金额</label>
                <div class="amount-buttons">
                    <button type="button" class="amount-btn" onclick="setAmount(50)">50元</button>
                    <button type="button" class="amount-btn" onclick="setAmount(100)">100元</button>
                    <button type="button" class="amount-btn" onclick="setAmount(200)">200元</button>
                    <button type="button" class="amount-btn" onclick="setAmount(500)">500元</button>
                    <button type="button" class="amount-btn" onclick="setAmount(1000)">1000元</button>
                </div>
            </div>

            <div style="margin-bottom: 15px;">
                <label style="display: block; margin-bottom: 8px; font-weight: bold;">或输入其他金额</label>
                <input type="number" id="amount" name="amount" min="1" max="10000" step="0.01"
                       placeholder="输入1-10000之间的金额" required
                       style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px;">
            </div>

            <div style="text-align: center;">
                <button type="submit" style="padding: 12px 40px; background-color: #667eea; color: white; border: none; border-radius: 5px; font-size: 16px;">
                    立即充值
                </button>
            </div>
        </form>
    </div>

    <!-- 充值说明 -->
    <div style="margin-top: 20px; padding: 15px; background-color: #f0f8ff; border-radius: 5px;">
        <h3>充值说明</h3>
        <ul>
            <li>充值金额范围：1元 - 10,000元</li>
            <li>充值后余额可用于支付订单</li>
            <li>本系统为演示系统，充值仅用于功能测试</li>
            <li>如需测试支付功能，请先充值足够金额</li>
        </ul>
    </div>
</div>

<script>
    function setAmount(amount) {
        document.getElementById('amount').value = amount;

        // 更新按钮样式
        var buttons = document.querySelectorAll('.amount-btn');
        buttons.forEach(function(btn) {
            btn.classList.remove('active');
            if (btn.textContent.includes(amount + '元')) {
                btn.classList.add('active');
            }
        });
    }
</script>
</body>
</html>
