package com.hyy.shopping.controller;

import com.hyy.shopping.dao.UserDao;
import com.hyy.shopping.dao.UserDaoImpl;
import com.hyy.shopping.dao.WalletDao;
import com.hyy.shopping.dao.WalletDaoImpl;
import com.hyy.shopping.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;

@WebServlet("/login")  // 配置登录Servlet的URL映射
public class LoginServlet extends HttpServlet {
    private UserDao userDao = new UserDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 显示登录页面
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            // 验证用户登录
            User user = userDao.login(username, password);

            if (user != null) {
                // 登录成功，创建会话
                HttpSession session = request.getSession();

                // 获取用户余额并设置到user对象
                WalletDao walletDao = new WalletDaoImpl();
                BigDecimal balance = walletDao.getBalance(user.getId());
                user.setBalance(balance);

                // 确保角色信息被设置（重要！）
                // 从数据库重新获取完整用户信息，确保角色正确
                User fullUser = userDao.findByUsername(username);
                if (fullUser != null) {
                    user.setRole(fullUser.getRole());
                }

                session.setAttribute("user", user);
                session.setAttribute("username", user.getUsername());
                session.setAttribute("userId", user.getId());
                session.setAttribute("userRole", user.getRole()); // 单独存储角色

                System.out.println("用户登录成功: " + username + ", 角色: " + user.getRole() + ", 余额: " + balance);

                // 根据角色跳转到不同页面
                if ("ADMIN".equals(user.getRole())) {
                    response.sendRedirect("admin/orders"); // 管理员跳转到管理页面
                } else {
                    response.sendRedirect("index.jsp"); // 普通用户跳转到首页
                }
            } else {
                // 登录失败
                request.setAttribute("error", "用户名或密码错误");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "系统错误: " + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}