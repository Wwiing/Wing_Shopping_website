Java Web 购物网站（Servlet + JSP）
这是一个基于 Java Servlet + JSP 的简单购物网站示例项目，包含前台购物流程和后台管理功能，适合作为 Java Web 课程设计 / 毕业设计 / 入门练习项目。
 
功能简介
前台功能（用户端）
用户注册、登录
商品浏览
首页商品展示
商品列表页：products.jsp
商品详情页：product-detail.jsp
购物车
添加商品到购物车
修改数量、删除商品
查看购物车：cart.jsp
下单与结算
结算页：checkout.jsp
订单列表与详情：orders.jsp、order-detail.jsp
钱包 / 账户
钱包页面：wallet.jsp
简单的余额 / 支付流程（可按实际实现补充）
后台功能（管理员端）
后台页面位于 src/main/webapp/admin/ 目录，主要包括：
商品管理：admin-products.jsp
订单管理：orders.jsp
销售报表：sales-report.jsp
用户管理：user-management.jsp
用户购买历史：user-purchase-history.jsp
 
技术栈
后端：
Java（推荐 JDK 8+）
Servlet + JSP + JSTL
Maven 构建（pom.xml）
Tomcat 8+/9+ 或兼容 Servlet 3.0+ 的应用服务器
MySQL 数据库
数据库连接池：c3p0（配置文件 src/main/resources/c3p0.properties）
主要依赖（示例）：
mysql-connector-j：MySQL JDBC 驱动
jstl：JSP 标签库
gson：JSON 处理
javax.mail：邮件发送（若项目中有使用）
c3p0、mchange-commons-java：连接池
前端：
JSP + JSTL
HTML / CSS（主样式：src/main/webapp/static/css/site.css）
简单的 JavaScript
静态资源：src/main/webapp/static/images/（背景图、商品图片等）
