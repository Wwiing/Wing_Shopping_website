<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>管理员 - 商品管理</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/site.css" />
    <style>
        .admin-container { max-width: 1000px; margin: 20px auto; }
        .form-box, .list-box { background: rgba(255,255,255,0.9); padding: 12px; border-radius:6px; margin-bottom:16px; }
        .row { display:flex; gap:10px; }
        .col { flex:1; }
        table { width:100%; border-collapse: collapse; }
        th, td { border:1px solid #ddd; padding:8px; text-align:left; }
        .msg-success { color: #155724; background: #d4edda; padding:8px; border-radius:4px; margin-bottom:8px; }
        .msg-error { color: #721c24; background: #f8d7da; padding:8px; border-radius:4px; margin-bottom:8px; }
        .small { font-size: 12px; color:#666; }
    </style>
</head>
<body>
<div class="admin-container">
    <h2>商品管理（写入数据库）</h2>
    <p><a href="${pageContext.request.contextPath}/admin/orders">返回订单管理</a></p>

    <!-- 显示来自 servlet 的消息或错误 -->
    <c:if test="${not empty param.message}">
        <div class="msg-success">
            <c:choose>
                <c:when test="${param.message == 'added'}">商品已成功添加。</c:when>
                <c:when test="${param.message == 'deleted'}">商品已成功删除（软删除）。</c:when>
                <c:otherwise>${param.message}</c:otherwise>
            </c:choose>
        </div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="msg-error">操作失败：<c:out value="${param.error}"/></div>
    </c:if>

    <div class="form-box">
        <h3><c:choose><c:when test="${not empty editProduct}">编辑商品</c:when><c:otherwise>添加商品</c:otherwise></c:choose></h3>
        <c:choose>
            <c:when test="${not empty editProduct}">
                <form method="post" action="${pageContext.request.contextPath}/admin/products" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="edit" />
                    <input type="hidden" name="id" value="${editProduct.id}" />
                    <div class="row">
                        <div class="col">
                            <label>名称</label>
                            <input type="text" name="name" required value="${editProduct.name}" />
                        </div>
                        <div class="col">
                            <label>价格（数字）</label>
                            <input type="text" name="price" value="${editProduct.price}" />
                        </div>
                        <div class="col">
                            <label>库存</label>
                            <input type="number" name="stock" value="${editProduct.stock}" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col">
                            <label>分类</label>
                            <input type="text" name="category" value="${editProduct.category}" />
                        </div>
                        <div class="col">
                            <label>替换图片（可选）</label>
                            <input type="file" name="imageFile" accept="image/*" />
                            <div class="small">当前: <c:out value="${editProduct.imageUrl}"/></div>
                        </div>
                    </div>
                    <label>简短描述</label>
                    <input type="text" name="description" value="${editProduct.description}" />
                    <label>详细描述</label>
                    <textarea name="descriptionLong" rows="3">${editProduct.descriptionLong}</textarea>
                    <div style="margin-top:8px;">
                        <button type="submit">保存修改</button>
                        <a href="${pageContext.request.contextPath}/admin/products">取消</a>
                    </div>
                </form>
            </c:when>
            <c:otherwise>
                <form method="post" action="${pageContext.request.contextPath}/admin/products" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="add" />
                    <div class="row">
                        <div class="col">
                            <label>名称</label>
                            <input type="text" name="name" required placeholder="例如：Stranger Under My Skin" />
                        </div>
                        <div class="col">
                            <label>价格（数字）</label>
                            <input type="text" name="price" value="0.00" placeholder="128.00" />
                        </div>
                        <div class="col">
                            <label>库存</label>
                            <input type="number" name="stock" value="0" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col">
                            <label>分类</label>
                            <input type="text" name="category" placeholder="例如：唱片" />
                        </div>
                        <div class="col">
                            <label>图片（本地上传）</label>
                            <input type="file" name="imageFile" accept="image/*" />
                            <div class="small">或填写 URL: <input type="text" name="imageUrl" placeholder="/static/images/goods/xxx.jpg"/></div>
                        </div>
                    </div>
                    <label>简短描述</label>
                    <input type="text" name="description" />
                    <label>详细描述</label>
                    <textarea name="descriptionLong" rows="3"></textarea>
                    <div style="margin-top:8px;">
                        <button type="submit">添加商品</button>
                    </div>
                    <div class="small">提示：添加后商品将写入数据库并对所有用户可见；删除为软删除（active=false）。</div>
                </form>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="list-box">
        <h3>当前商品列表</h3>
        <c:if test="${not empty error}">
            <div style="color:red">${error}</div>
        </c:if>
        <c:choose>
            <c:when test="${empty products}">
                <p>暂无商品</p>
            </c:when>
            <c:otherwise>
                <table>
                    <thead>
                    <tr><th>ID</th><th>名称</th><th>价格</th><th>库存</th><th>分类</th><th>图片</th><th>简短描述</th><th>操作</th></tr>
                    </thead>
                    <tbody>
                    <c:forEach var="p" items="${products}">
                        <tr>
                            <td>${p.id}</td>
                            <td>${p.name}</td>
                            <td>${p.price}</td>
                            <td>${p.stock}</td>
                            <td>${p.category}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty p.imageUrl}">
                                        <c:choose>
                                            <c:when test="${fn:startsWith(p.imageUrl, 'http')}">
                                                <img src="${p.imageUrl}" alt="img" style="height: 50px; object-fit: cover;" />
                                            </c:when>
                                            <c:when test="${fn:startsWith(p.imageUrl, '/')}">
                                                <img src="${pageContext.request.contextPath}${p.imageUrl}" alt="img" style="height: 50px; object-fit: cover;" />
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}/${p.imageUrl}" alt="img" style="height: 50px; object-fit: cover;" />
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>无图</c:otherwise>
                                </c:choose>
                            </td>
                            <td><c:out value="${p.description}" /></td>
                            <td>
                                <form method="post" action="${pageContext.request.contextPath}/admin/products" style="display:inline;">
                                    <input type="hidden" name="action" value="delete" />
                                    <input type="hidden" name="id" value="${p.id}" />
                                    <button type="submit" onclick="return confirm('确认删除商品 ID=${p.id} ?')">删除</button>
                                </form>
                                <a href="${pageContext.request.contextPath}/admin/products?editId=${p.id}">编辑</a>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</body>
</html>
