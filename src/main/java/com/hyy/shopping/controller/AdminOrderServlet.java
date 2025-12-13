package com.hyy.shopping.controller;

import com.hyy.shopping.dao.OrderDao;
import com.hyy.shopping.dao.OrderDaoImpl;
import com.hyy.shopping.dao.UserDao;
import com.hyy.shopping.dao.UserDaoImpl;
import com.hyy.shopping.model.Order;
import com.hyy.shopping.model.User;
import com.hyy.shopping.util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/orders")
public class AdminOrderServlet extends HttpServlet {
    private OrderDao orderDao = new OrderDaoImpl();
    private UserDao userDao = new UserDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 检查是否为管理员
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendRedirect("../login.jsp?message=需要管理员权限");
            return;
        }

        try {
            List<Order> orders = orderDao.findAll();
            request.setAttribute("orders", orders);
            request.getRequestDispatcher("/admin/orders.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("../admin/orders.jsp?error=加载订单失败");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User adminUser = (User) session.getAttribute("user");

        // 检查是否为管理员
        if (adminUser == null || !"ADMIN".equals(adminUser.getRole())) {
            response.sendRedirect("../login.jsp?message=需要管理员权限");
            return;
        }

        String action = request.getParameter("action");
        String orderId = request.getParameter("orderId");
        String trackingNumber = request.getParameter("trackingNumber");
        String carrier = request.getParameter("carrier");

        try {
            Long orderIdLong = Long.parseLong(orderId);
            Order order = orderDao.findById(orderIdLong);

            if (order == null) {
                // 返回JSON错误
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().print("{\"success\":false, \"message\":\"订单不存在\"}");
                return;
            }

            switch (action) {
                case "ship":
                    shipOrder(orderIdLong, trackingNumber, carrier, order, response);
                    break;
                case "cancel":
                    cancelOrder(orderIdLong, response);
                    break;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().print("{\"success\":false, \"message\":\"操作失败: " + e.getMessage() + "\"}");
        }
    }

    private void shipOrder(Long orderId, String trackingNumber, String carrier, Order order, HttpServletResponse response)
            throws Exception {

        // 更新订单状态为已发货
        boolean updated = orderDao.updateStatus(orderId, "SHIPPED");

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (updated) {
            System.out.println("订单状态更新为已发货");

            // 获取用户信息
            User user = userDao.findById(order.getUserId());
            if (user != null && user.getEmail() != null) {
                // 获取订单项详情（包含商品信息）
                List<com.hyy.shopping.model.OrderItem> items = orderDao.findItemsByOrderId(orderId);

                // 发送发货邮件（包含商品详情）
                boolean emailSent = EmailUtil.sendShippingEmail(
                    user.getEmail(),
                    order.getId(),
                    trackingNumber,
                    carrier,
                    items,
                    order.getTotalAmount()
                );
                System.out.println("发货邮件发送结果: " + (emailSent ? "成功" : "失败"));
            }

            // 手动构建JSON
            String json = "{\"success\":true, \"message\":\"发货成功\"}";
            out.print(json);
        } else {
            // 手动构建JSON
            String json = "{\"success\":false, \"message\":\"发货失败\"}";
            out.print(json);
        }

        out.flush();
    }

    private void cancelOrder(Long orderId, HttpServletResponse response) throws Exception {
        boolean success = orderDao.updateStatus(orderId, "CANCELLED");

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (success) {
            out.print("{\"success\":true, \"message\":\"订单取消成功\"}");
        } else {
            out.print("{\"success\":false, \"message\":\"订单取消失败\"}");
        }
        out.flush();
    }
}