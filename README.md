# Java Web 购物网站（Servlet + JSP）

---
## 学号：202330450672 姓名：黄颖怡

## 功能简介

### 前台功能（用户端）

- **用户注册与登录**
- **商品浏览**
  - 首页商品展示
  - 商品列表页：`products.jsp`
  - 商品详情页：`product-detail.jsp`
- **购物车管理**
  - 添加商品到购物车
  - 修改商品数量、删除商品
  - 查看购物车：`cart.jsp`
- **下单与结算**
  - 结算页面：`checkout.jsp`
  - 订单列表与详情：`orders.jsp`、`order-detail.jsp`
- **钱包 / 账户**
  - 钱包页面：`wallet.jsp`
  - 简单的余额显示与支付流程（可根据实际需求扩展）

### 后台功能（管理员端）

> 后台页面位于 `src/main/webapp/admin/` 目录

- 商品管理：`admin-products.jsp`
- 订单管理：`orders.jsp`
- 销售报表：`sales-report.jsp`
- 用户管理：`user-management.jsp`
- 用户购买历史：`user-purchase-history.jsp`

---

## 技术栈

### 后端

- **语言与框架**：
  - Java（推荐 JDK 8+）
  - Servlet + JSP + JSTL
- **构建工具**：Maven（`pom.xml`）
- **服务器**：Tomcat 8+/9+ 或其他兼容 Servlet 3.0+ 的应用服务器
- **数据库**：MySQL
- **连接池**：c3p0（配置文件：`src/main/resources/c3p0.properties`）

#### 主要依赖（示例）

| 依赖 | 用途 |
|------|------|
| `mysql-connector-j` | MySQL JDBC 驱动 |
| `jstl` | JSP 标准标签库 |
| `gson` | JSON 数据处理 |
| `javax.mail` | 邮件发送功能（可选） |
| `c3p0` + `mchange-commons-java` | 数据库连接池 |

### 前端

- **模板技术**：JSP + JSTL
- **样式**：HTML / CSS（主样式文件：`src/main/webapp/static/css/site.css`）
- **交互**：简单的 JavaScript
- **静态资源**：  
  - 图片路径：`src/main/webapp/static/images/`（含背景图、商品图片等）

---
### 项目结构（节选）
```
├─ pom.xml
├─ Dockerfile
└─ src
   └─ main
      ├─ java
      │  └─ com/hyy/shopping
      │     ├─ controller/   # Servlet 控制器
      │     ├─ dao/          # 数据访问层
      │     ├─ filter/       # 过滤器（登录拦截等）
      │     ├─ model/        # 实体类 / POJO
      │     └─ util/         # 工具类
      ├─ resources
      │  └─ c3p0.properties  # 数据库连接池配置
      └─ webapp
         ├─ index.jsp
         ├─ products.jsp
         ├─ product-detail.jsp
         ├─ cart.jsp
         ├─ checkout.jsp
         ├─ login.jsp
         ├─ register.jsp
         ├─ orders.jsp
         ├─ order-detail.jsp
         ├─ wallet.jsp
         ├─ admin/
         │  ├─ admin-products.jsp
         │  ├─ orders.jsp
         │  ├─ sales-report.jsp
         │  ├─ user-management.jsp
         │  └─ user-purchase-history.jsp
         ├─ static/
         │  ├─ css/
         │  │  └─ site.css
         │  └─ images/
         └─ WEB-INF
            └─ web.xml
```

## 快速开始

### 1. 环境准备

确保已安装以下工具：

- JDK 8 或更高版本
- Maven 3.6+
- MySQL 数据库
- Tomcat 8+/9+（或其他支持 Servlet 3.0+ 的服务器）

### 2. 配置数据库

1. 在 MySQL 中创建数据库（名称自定义）。
2. 编辑配置文件：`src/main/resources/c3p0.properties`，填入以下信息：
   - JDBC URL（格式：`jdbc:mysql://localhost:3306/your_db_name`）
   - 数据库用户名和密码
   - 连接池参数（如最大连接数等）
3. （可选）执行初始化 SQL 脚本（建表 + 测试数据）。

### 3. 使用 Maven 构建项目

在项目根目录执行以下命令：

```
cd D:\code\shopping_website
mvn clean package
```

### 4. 部署到 Tomcat

1. 将 `target/shopping_website.war` 拷贝到 Tomcat 的 `webapps` 目录。
2. 启动 Tomcat：
   - **Windows**：执行 `bin\startup.bat`
3. 在浏览器中访问（具体路径取决于 WAR 文件名）：
   - 如果文件名为 `shopping_website.war`：  
     [http://localhost:8080/shopping_website/](http://localhost:8080/shopping_website/)
   - 如果文件名为 `shopping_website_v1.war`：  
     [http://localhost:8080/shopping_website_v1/](http://localhost:8080/shopping_website_v1/)

---

## 后续优化方向

- 使用 **Spring / Spring Boot** 重构项目结构
- 使用 **MyBatis / JPA** 简化持久层
- 实现 **前后端分离**（例如：Vue / React + REST API）
- 完善非功能特性：
  - 权限控制
  - 操作日志
  - 安全性（如防 XSS、CSRF、SQL 注入等）
  - 统一异常处理机制
