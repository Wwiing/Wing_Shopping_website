<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>销售统计报表</title>
    <style>
        .admin-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .report-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .report-table th, .report-table td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        .report-table th {
            background-color: #f5f5f5;
        }
    </style>
</head>
<body>
<div class="admin-container">
    <h1>销售统计报表</h1>

    <!-- 导航 -->
    <div style="margin-bottom: 20px;">
        <a href="../index.jsp">返回首页</a>
        <span style="margin: 0 10px;">|</span>
        <a href="${pageContext.request.contextPath}/admin/products">商品管理</a>
        <span style="margin: 0 10px;">|</span>
        <a href="${pageContext.request.contextPath}/admin/orders">订单管理</a>
    </div>

    <!-- 错误消息 -->
    <c:if test="${not empty error}">
        <div style="color: red; margin-bottom: 15px;">${error}</div>
    </c:if>

    <!-- 报表内容 -->
    <c:if test="${not empty salesStatistics}">
        <table class="report-table">
            <thead>
            <tr>
                <th>商品ID</th>
                <th>商品名称</th>
                <th>总销量</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="stat" items="${salesStatistics}">
                <tr>
                    <td>#${stat.product.id}</td>
                    <td>${stat.product.name}</td>
                    <td>${stat.totalQuantity}</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:if>

    <c:if test="${empty salesStatistics and empty error}">
        <div style="text-align: center; padding: 40px;">
            <h3>暂无销售数据</h3>
        </div>
    </c:if>
</div>
</body>
</html>

