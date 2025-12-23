package com.hyy.shopping.controller;

import com.hyy.shopping.dao.OrderDao;
import com.hyy.shopping.dao.OrderDaoImpl;
import com.hyy.shopping.dao.UserDao;
import com.hyy.shopping.dao.UserDaoImpl;
import com.hyy.shopping.model.Order;
import com.hyy.shopping.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/user-purchase-history")
public class UserPurchaseHistoryServlet extends HttpServlet {
    private OrderDao orderDao = new OrderDaoImpl();
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

        String userIdStr = request.getParameter("userId");
        if (userIdStr == null || userIdStr.isEmpty()) {
            response.sendRedirect("user-management?error=用户ID不能为空");
            return;
        }

        try {
            long userId = Long.parseLong(userIdStr);
            User user = userDao.findById(userId);
            if (user == null) {
                response.sendRedirect("user-management?error=用户不存在");
                return;
            }

            List<Order> orders = orderDao.findByUserId(userId);
            request.setAttribute("orders", orders);
            request.setAttribute("customer", user);
            request.getRequestDispatcher("/admin/user-purchase-history.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "加载用户购买记录失败");
            request.getRequestDispatcher("/admin/user-purchase-history.jsp").forward(request, response);
        }
    }
}

