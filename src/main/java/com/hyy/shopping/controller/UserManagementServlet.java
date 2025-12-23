package com.hyy.shopping.controller;

import com.hyy.shopping.dao.UserDao;
import com.hyy.shopping.dao.UserDaoImpl;
import com.hyy.shopping.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/user-management")
public class UserManagementServlet extends HttpServlet {
    private UserDao userDao = new UserDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User adminUser = (User) session.getAttribute("user");

        if (adminUser == null || !"ADMIN".equals(adminUser.getRole())) {
            response.sendRedirect("../login.jsp?message=需要管理员权限");
            return;
        }

        try {
            List<User> users = userDao.findAllUsers();
            request.setAttribute("users", users);
            request.getRequestDispatcher("/admin/user-management.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "加载用户列表失败");
            request.getRequestDispatcher("/admin/user-management.jsp").forward(request, response);
        }
    }
}

