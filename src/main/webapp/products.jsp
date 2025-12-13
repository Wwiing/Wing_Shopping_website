<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <meta charset="UTF-8">
    <title>商品列表</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        /* 背景图设置 */
        body {
            background:  linear-gradient(rgba(0,0,0,0.35), rgba(0,0,0,0.35)),url('<%= request.getContextPath() %>/static/images/bg-10.jpg') no-repeat center fixed;
            background-size: cover;
            min-height: 100vh;
            padding-top: 80px; /* 给顶部栏留空间 */
        }
        /* 顶部栏（和index统一逻辑） */
        .top-bar {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-image: url("static/images/bg-12.jpg");
            color: #fff;
            z-index: 999;
        }
        .top-bar h1 {
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
        /* 搜索区域 */
        .search-area {
            max-width: 1400px;
            margin: 20px auto;
            padding: 0 15px;
        }
        .search-area form {
            display: flex;
            gap: 8px;
        }
        .search-area input {
            flex: 1;
            max-width: 300px;
            padding: 8px;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
        .search-area button {
            padding: 8px 16px;
            border: none;
            background-color: #ff8800;
            color: #fff;
            border-radius: 4px;
            cursor: pointer;
        }
        /* 商品网格 */
        .product-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 15px;
        }
        .product-grid {
            display: grid;
            /* 核心：自动填充列数，每列最小宽度200px（可调整），最大占满1fr */
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 35px;
            padding: 15px 0;
            /* 可选：限制网格最大宽度，保证100%缩放时刚好5列 */
            max-width: 1400px; /* 200px(列宽) *5 + 25px(间距)*4 = 1100px，留余量 */
            margin: 0 auto; /* 网格居中，和卡片间距匹配 */
        }
        .product-card {
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 5px;
            text-align: center;
            background: rgba(255,255,255,0.9); /* 半透明白底 */
            display: flex;
            flex-direction: column;
            align-items: center;
            /* 可选：给卡片加最小高度，避免内容少的卡片过短 */
            min-height: 280px;
        }
        /* 统一图片缩放 */
        .product-card img {
            width: 100%;
            height: 200px; /* 固定图片高度 */
            object-fit: cover; /* 保持图片比例，裁剪多余部分 */
            border-radius: 4px;
            margin-bottom: 10px;
        }
        .product-price {
            color: #e4393c;
            font-size: 18px;
            font-weight: bold;
            margin: 8px 0;
        }
        .product-stock {
            color: #666;
            font-size: 14px;
        }
        .product-card h3 {
            margin: 0;
            font-size: 16px;
            line-height: 1.3;
            height: 40px; /* 固定标题高度，防止卡片高度不一致 */
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .product-card p {
            margin: 0;
            font-size: 14px;
            line-height: 1.4;
        }
        /* 分页样式 */
        .pagination {
            text-align: center;
            margin: 20px 0;
            padding-bottom: 30px;
        }
        .pagination a, .pagination span {
            display: inline-block;
            margin: 0 4px;
            padding: 6px 10px;
            border-radius: 4px;
            text-decoration: none;
            color: #333;
            border: 1px solid #ddd;
            background: rgba(255,255,255,0.9);
        }
        .pagination a:hover {
            background: #f5f5f5;
        }
        .pagination .current {
            background: #e4393c;
            color: white;
            border-color: #e4393c;
        }
        /* 错误信息 */
        .error {
            color: #e4393c;
            padding: 0 20px;
            max-width: 1200px;
            margin: 0 auto;
        }
        /* 总数显示 */
        .total-count {
            padding: 0 20px;
            max-width: 1400px;
            margin: 0 auto;
            color: #fff;
            text-shadow: 0 0 4px rgba(0,0,0,0.5);
        }
    </style>
</head>
<body>
<%-- 顶部栏（和index统一） --%>
<div class="top-bar">
    <h1>商品列表</h1>
    <div class="nav-links">
        <a href="index.jsp">首页</a> |
        <a href="products">所有商品</a> |
        <a href="products?category=专辑">专辑</a> |
        <a href="products?category=演唱会">演唱会</a> |
        <a href="products?category=其他">其他</a>
    </div>
</div>

<%-- 搜索框 --%>
<div class="search-area">
    <form action="products" method="get">
        <input type="text" name="search" placeholder="搜索商品..." value="${param.search}">
        <button type="submit">搜索</button>
    </form>
</div>

<%-- 错误信息 --%>
<c:if test="${not empty error}">
    <div class="error">${error}</div>
</c:if>

<%-- 总数显示 --%>
<c:if test="${not empty totalCount}">
    <div class="total-count">共 ${totalCount} 件商品</div>
</c:if>

<%-- 商品列表容器 --%>
<div class="product-container">
    <div class="product-grid">
        <c:forEach var="product" items="${products}">
            <div class="product-card">
                <!-- 可点击区域：跳转到商品详情页 -->
                <a class="product-link" href="${pageContext.request.contextPath}/product?id=${product.id}" style="text-decoration:none;color:inherit;width:100%;">
                    <!-- 商品图片（统一缩放） -->
                    <c:choose>
                        <c:when test="${not empty product.imageUrl}">
                            <c:choose>
                                <c:when test="${fn:startsWith(product.imageUrl, 'http')}">
                                    <img src="${product.imageUrl}" alt="${product.name}">
                                </c:when>
                                <c:when test="${fn:startsWith(product.imageUrl, '/')}">
                                    <img src="${pageContext.request.contextPath}${product.imageUrl}" alt="${product.name}">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.name}">
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <img src="${pageContext.request.contextPath}/static/images/ready.jpg" alt="${product.name}">
                        </c:otherwise>
                    </c:choose>
                    <h3 style="margin-top:8px">${product.name}</h3>
                    <p class="product-price">¥${product.price}</p>
                    <p class="product-stock">库存: ${product.stock}</p>
                    <p style="color:#666; font-size:13px; height:36px; overflow:hidden;">${product.description}</p>
                </a>

                <%-- 添加到购物车按钮 放在链接外部，避免嵌套表单问题 --%>
                <c:if test="${not empty sessionScope.user}">
                    <form action="cart" method="post" style="margin-top: 10px; width: 100%;">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="productId" value="${product.id}">
                        <input type="number" name="quantity" value="1" min="1" max="${product.stock}" style="width: 60px;">
                        <button type="submit">加入购物车</button>
                    </form>
                </c:if>
            </div>
        </c:forEach>
    </div>

    <%-- 如果没有商品 --%>
    <c:if test="${empty products}">
        <p style="text-align: center; padding: 30px; color: #fff; text-shadow: 0 0 4px rgba(0,0,0,0.5);">没有找到商品</p>
    </c:if>

    <%-- 分页控件 --%>
    <c:if test="${totalPages > 1}">
        <c:set var="qSearch" value="${fn:escapeXml(param.search)}" />
        <c:set var="qCategory" value="${fn:escapeXml(param.category)}" />
        <div class="pagination">
            <c:if test="${currentPage > 1}">
                <a href="${pageContext.request.contextPath}/products?page=${currentPage-1}&amp;search=${qSearch}&amp;category=${qCategory}">上一页</a>
            </c:if>

            <c:forEach begin="1" end="${totalPages}" var="p">
                <c:choose>
                    <c:when test="${p == currentPage}">
                        <span class="current">${p}</span>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/products?page=${p}&amp;search=${qSearch}&amp;category=${qCategory}">${p}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>

            <c:if test="${currentPage < totalPages}">
                <a href="${pageContext.request.contextPath}/products?page=${currentPage+1}&amp;search=${qSearch}&amp;category=${qCategory}">下一页</a>
            </c:if>
        </div>
    </c:if>
</div>
</body>
</html>