<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>  <%-- 这一行非常重要！确保EL表达式启用 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品详情</title>
    <style>
        /* 全局样式统一背景 */
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background:  linear-gradient(rgba(0,0,0,0.35), rgba(0,0,0,0.35)),url('<%= request.getContextPath() %>/static/images/bg-10.jpg') no-repeat center fixed;
            background-size: cover;
            color: #000;
            min-height: 100vh;
        }
        /* 主容器卡片美化 */
        .container {
            max-width: 1000px;
            margin: 150px auto 0;
            background: rgba(255,255,255,0.95);
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            border: none;
        }
        /* 商品头部布局 */
        .product-header {
            display:flex;
            gap:30px;
            align-items: flex-start;
            margin-bottom: 30px;
        }
        /* 缩小图片尺寸 */
        .product-img {
            width: 280px;
            height: 280px;
            border-radius: 8px;
            overflow:hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .product-img img {
            width:100%;
            height:100%;
            object-fit:cover;
            transition: transform 0.3s ease;
        }
        .product-img img:hover {
            transform: scale(1.02);
        }
        /* 商品信息区域 */
        .product-info {
            flex:1;
            padding-top: 10px;
        }
        .product-info h1 {
            margin-bottom: 12px;
            font-size: 24px;
            color: #333;
            line-height: 1.3;
        }
        /* 价格样式 */
        .price {
            color: #e4393c;
            font-size: 26px;
            font-weight:bold;
            margin: 15px 0;
        }
        /* 元数据样式 */
        .meta {
            color:#666;
            margin-bottom: 15px;
            font-size: 14px;
        }
        /* 商品简介 */
        .product-info > div {
            color: #555;
            line-height: 1.6;
            margin-bottom: 20px;
            font-size: 14px;
        }
        /* 商品详情区域 */
        .long-desc {
            margin-top: 30px;
            line-height:1.7;
            color: #444;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        .long-desc h3 {
            font-size: 20px;
            margin-bottom: 15px;
            color: #333;
        }
        /* 返回链接 */
        .back-link {
            margin-top: 20px;
            display:inline-block;
            color: #2196f3;
            text-decoration: none;
            font-size: 14px;
            transition: color 0.2s;
        }
        .back-link:hover {
            color: #1976d2;
            text-decoration: underline;
        }
        /* 购物车表单 */
        .cart-form {
            margin-top: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .cart-form input[type="number"] {
            padding: 8px 10px;
            border: 1px solid #ddd;
            border-radius: 6px;
            width: 80px;
            outline: none;
            transition: border-color 0.2s;
        }
        .cart-form input[type="number"]:focus {
            border-color: #ff8800;
        }
        /* 按钮样式 */
        .cart-form button {
            padding: 9px 20px;
            border: none;
            border-radius: 6px;
            background-color: #ff8800;
            color: #fff;
            cursor: pointer;
            transition: background-color 0.2s;
            font-size: 14px;
        }
        .cart-form button:hover {
            background-color: #e67700;
        }
        /* 登录提示 */
        .cart-form p {
            color: #666;
            font-size: 14px;
        }
        .cart-form a {
            color: #2196f3;
            text-decoration: none;
        }
        .cart-form a:hover {
            text-decoration: underline;
        }
        /* 错误提示 */
        .error-tip {
            color: #e4393c;
            margin-bottom: 15px;
            padding: 10px;
            background: #fff3f3;
            border-radius: 6px;
            border-left: 4px solid #e4393c;
        }
        /* 移动端适配 */
        @media (max-width: 768px) {
            .product-header {
                flex-direction: column;
                gap: 20px;
            }
            .product-img {
                width: 100%;
                height: auto;
            }
            .cart-form {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            .cart-form button {
                width: 100%;
            }
        }
    </style>
</head>
<body>
<div class="container">

    <c:if test="${not empty error}">
        <div class="error-tip">${error}</div>
    </c:if>

    <c:if test="${empty product}">
        <p>未找到商品。</p>
        <p><a href="${pageContext.request.contextPath}/products" style="color: #2196f3;">返回商品列表</a></p>
    </c:if>

    <c:if test="${not empty product}">
    <div class="product-header">
        <div class="product-img">
            <c:choose>
                <c:when test="${not empty product.imageUrl}">
                    <c:choose>
                        <c:when test="${fn:startsWith(product.imageUrl,'http')}">
                            <img src="${product.imageUrl}" alt="${product.name}" />
                        </c:when>
                        <c:when test="${fn:startsWith(product.imageUrl,'/')}">
                            <img src="${pageContext.request.contextPath}${product.imageUrl}" alt="${product.name}" />
                        </c:when>
                        <c:otherwise>
                            <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.name}" />
                        </c:otherwise>
                    </c:choose>
                </c:when>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/static/images/ready.jpg" alt="${product.name}" />
                </c:otherwise>
            </c:choose>
        </div>

        <div class="product-info">
            <h1>${product.name}</h1>
            <div class="price">¥${product.price}</div>
            <div class="meta">分类: ${product.category} &nbsp;|&nbsp; 库存: ${product.stock}</div>
            <div>${product.description}</div>

            <div class="cart-form">
                <c:if test="${not empty sessionScope.user}">
                    <form action="${pageContext.request.contextPath}/cart" method="post">
                        <input type="hidden" name="action" value="add" />
                        <input type="hidden" name="productId" value="${product.id}" />
                        <label>数量:</label>
                        <input type="number" name="quantity" value="1" min="1" max="${product.stock}" />
                        <button type="submit">加入购物车</button>
                    </form>
                </c:if>
                <c:if test="${empty sessionScope.user}">
                    <p>请先 <a href="${pageContext.request.contextPath}/login.jsp">登录</a> 再加入购物车。</p>
                </c:if>
            </div>

            <a class="back-link" href="${pageContext.request.contextPath}/products">&laquo; 返回商品列表</a>
        </div>
    </div>


<c:if test="${not empty product.descriptionLong}">
    <div class="long-desc">
        <h3>商品详情</h3>
            <%-- 如果你希望支持 HTML 格式的商品详情，可以把 escapeXml 设为 false，注意 XSS 风险 --%>
        <c:out value="${product.descriptionLong}" escapeXml="false" />
    </div>
</c:if>
</c:if>
</div>
</body>
</html>