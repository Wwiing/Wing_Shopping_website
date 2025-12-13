//订单处理Servlet
package com.hyy.shopping.controller;

import com.hyy.shopping.dao.*;
import com.hyy.shopping.model.*;
import com.hyy.shopping.util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/order")
public class OrderServlet extends HttpServlet {
    private OrderDao orderDao = new OrderDaoImpl();
    private CartDao cartDao = new CartDaoImpl();
    private ProductDao productDao = new ProductDaoImpl();
    private WalletDao walletDao = new WalletDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp?message=Please login first");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("view".equals(action)) {
                // 查看订单详情
                viewOrder(request, response, user);
            } else {
                // 查看订单列表
                viewOrderList(request, response, user);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("orders.jsp?error=Failed to load orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp?message=Please login first");
            return;
        }

        String action = request.getParameter("action");

        try {
            switch (action) {
                case "create":
                    createOrder(request, response, user);
                    break;
                case "cancel":
                    cancelOrder(request, response, user);
                    break;
                case "confirm":
                    confirmOrder(request, response, user);
                    break;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("orders.jsp?error=Operation failed");
        }
    }

    private void createOrder(HttpServletRequest request, HttpServletResponse response, User user)
            throws Exception {

        System.out.println("=== 订单创建调试 ===");
        // 设置请求编码为UTF-8（解决中文乱码）
        request.setCharacterEncoding("UTF-8");

        try {
            // 获取表单数据
            String shippingAddress = request.getParameter("shippingAddress");
            String paymentMethod = request.getParameter("paymentMethod");

            System.out.println("收货地址: " + shippingAddress);
            System.out.println("支付方式: " + paymentMethod);

            if (shippingAddress == null || shippingAddress.trim().isEmpty()) {
                System.out.println("收货地址为空");
                response.sendRedirect("checkout?error=请填写收货地址");
                return;
            }

            // 获取购物车商品
            List<CartItem> cartItems = cartDao.getCartByUserId(user.getId());
            System.out.println("购物车商品数量: " + (cartItems != null ? cartItems.size() : "null"));

            if (cartItems == null || cartItems.isEmpty()) {
                System.out.println("购物车为空");
                response.sendRedirect("cart?error=您的购物车为空");
                return;
            }

            // 计算总金额并创建订单项
            BigDecimal totalAmount = BigDecimal.ZERO;
            List<OrderItem> orderItems = new ArrayList<>();

            // 在创建订单的循环中修改库存检查部分：
            for (CartItem cartItem : cartItems) {
                if (cartItem.getProduct() != null) {
                    Integer stock = cartItem.getProduct().getStock();
                    System.out.println("处理商品: " + cartItem.getProduct().getName() +
                            ", 数量: " + cartItem.getQuantity() +
                            ", 库存: " + stock);

                    // 安全的库存检查
                    if (stock == null) {
                        System.out.println("商品库存为null: " + cartItem.getProduct().getName());
                        response.sendRedirect("cart?error=商品库存信息异常: " + cartItem.getProduct().getName());
                        return;
                    }

                    if (stock < cartItem.getQuantity()) {
                        System.out.println("库存不足: " + cartItem.getProduct().getName());
                        response.sendRedirect("cart?error=库存不足: " + cartItem.getProduct().getName());
                        return;
                    }

                    // 计算小计
                    BigDecimal subtotal = cartItem.getProduct().getPrice().multiply(
                            BigDecimal.valueOf(cartItem.getQuantity()));
                    totalAmount = totalAmount.add(subtotal);

                    // 创建订单项
                    OrderItem orderItem = new OrderItem();
                    orderItem.setProductId(cartItem.getProductId());
                    orderItem.setQuantity(cartItem.getQuantity());
                    orderItem.setPrice(cartItem.getProduct().getPrice());
                    orderItems.add(orderItem);
                }
            }

            System.out.println("订单总金额: " + totalAmount);
            System.out.println("订单项数量: " + orderItems.size());

            // 检查账户余额是否足够
            if (!walletDao.hasSufficientBalance(user.getId(), totalAmount)) {
                System.out.println("账户余额不足");
                response.sendRedirect("checkout?error=账户余额不足，请先充值");
                return;
            }

            // 创建订单（状态保持英文）
            Order order = new Order();
            order.setUserId(user.getId());
            order.setTotalAmount(totalAmount);
            order.setStatus("PENDING"); // 保持英文
            order.setShippingAddress(shippingAddress);
            order.setPaymentMethod(paymentMethod);
            order.setOrderItems(orderItems);

            System.out.println("准备调用orderDao.createOrder()");

            // 保存订单
            boolean success = orderDao.createOrder(order);

            System.out.println("订单创建结果: " + success);

            if (success) {
                System.out.println("订单创建成功，订单ID: " + order.getId());

                // 从余额扣款
                boolean deducted = walletDao.deduct(user.getId(), totalAmount);
                if (!deducted) {
                    System.out.println("扣款失败");
                    // 如果扣款失败，可能需要回滚订单
                    response.sendRedirect("checkout?error=支付失败");
                    return;
                }
                System.out.println("扣款成功，订单金额: " + totalAmount);

                // 立即更新订单状态为"已付款"
                boolean statusUpdated = orderDao.updateStatus(order.getId(), "PAID");
                if (statusUpdated) {
                    System.out.println("订单状态更新为已付款");
                }

                // 更新session中的用户余额
                BigDecimal newBalance = walletDao.getBalance(user.getId());
                user.setBalance(newBalance);
                request.getSession().setAttribute("user", user);

                // 移除订单创建邮件发送逻辑
                // try {
                //     EmailUtil.sendOrderCreatedEmail(user.getEmail(), order.getId(), order.getTotalAmount());
                //     System.out.println("订单创建邮件发送成功");
                // } catch (Exception e) {
                //     System.out.println("邮件发送失败: " + e.getMessage());
                // }


                // 清空购物车
                cartDao.clearCart(user.getId());
                System.out.println("购物车已清空");

                // 更新商品库存
                for (CartItem cartItem : cartItems) {
                    int newStock = cartItem.getProduct().getStock() - cartItem.getQuantity();
                    productDao.updateStock(cartItem.getProductId(), newStock);
                    System.out.println("更新库存: " + cartItem.getProduct().getName() + " -> " + newStock);
                }

                String encodedMessage = java.net.URLEncoder.encode("订单创建成功", "UTF-8");
                response.sendRedirect("order?action=view&orderId=" + order.getId() + "&message=" + encodedMessage);
            } else {
                System.out.println("订单创建失败");
                response.sendRedirect("checkout?error=创建订单失败");
            }

        } catch (Exception e) {
            System.out.println("创建订单过程中出现异常: " + e.getMessage());
            e.printStackTrace(); // 打印完整异常信息
            response.sendRedirect("checkout?error=系统错误: " + e.getMessage());
        }
    }

    private void viewOrderList(HttpServletRequest request, HttpServletResponse response, User user)
            throws Exception {

        List<Order> orders = orderDao.findByUserId(user.getId());

        // 为每个订单加载订单项和商品信息
        for (Order order : orders) {
            List<OrderItem> orderItems = orderDao.findItemsByOrderId(order.getId());

            // 为每个订单项加载商品信息
            for (OrderItem item : orderItems) {
                // 获取商品详细信息
                Product product = productDao.findById(item.getProductId());
                if (product != null) {
                    item.setProduct(product);
                }
            }

            order.setOrderItems(orderItems);
        }

        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/orders.jsp").forward(request, response);
    }

    private void viewOrder(HttpServletRequest request, HttpServletResponse response, User user)
            throws Exception {

        Long orderId = Long.parseLong(request.getParameter("orderId"));
        Order order = orderDao.findById(orderId);

        // 检查订单是否属于当前用户
        if (order == null || !order.getUserId().equals(user.getId())) {
            response.sendRedirect("orders.jsp?error=Order not found");
            return;
        }

        request.setAttribute("order", order);
        request.getRequestDispatcher("/order-detail.jsp").forward(request, response);
    }

    private void cancelOrder(HttpServletRequest request, HttpServletResponse response, User user)
            throws Exception {

        Long orderId = Long.parseLong(request.getParameter("orderId"));
        Order order = orderDao.findById(orderId);

        // 检查订单是否属于当前用户且可以取消
        if (order == null || !order.getUserId().equals(user.getId())) {
            response.sendRedirect("orders.jsp?error=Order not found");
            return;
        }

        if (!"PENDING".equals(order.getStatus())) {
            response.sendRedirect("orders.jsp?error=Order cannot be cancelled");
            return;
        }

        boolean success = orderDao.updateStatus(orderId, "CANCELLED");

        if (success) {
            // 恢复库存
            for (OrderItem item : order.getOrderItems()) {
                ProductDao productDao = new ProductDaoImpl();
                int currentStock = productDao.findById(item.getProductId()).getStock();
                productDao.updateStock(item.getProductId(), currentStock + item.getQuantity());
            }

            response.sendRedirect("order?message=订单取消成功");
        } else {
            response.sendRedirect("order?error=取消订单失败");
        }
    }

    private void confirmOrder(HttpServletRequest request, HttpServletResponse response, User user)
            throws Exception {

        Long orderId = Long.parseLong(request.getParameter("orderId"));
        Order order = orderDao.findById(orderId);

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 创建JSON响应对象
        Map<String, Object> result = new HashMap<>();

        try {
            // 检查订单是否属于当前用户且可以确认收货
            if (order == null || !order.getUserId().equals(user.getId())) {
                result.put("success", false);
                result.put("message", "订单不存在");
                out.print(new com.google.gson.Gson().toJson(result));
                return;
            }

            if (!"SHIPPED".equals(order.getStatus())) {
                result.put("success", false);
                result.put("message", "订单无法确认收货");
                out.print(new com.google.gson.Gson().toJson(result));
                return;
            }

            boolean success = orderDao.updateStatus(orderId, "DELIVERED");

            if (success) {
                result.put("success", true);
                result.put("message", "确认收货成功");
            } else {
                result.put("success", false);
                result.put("message", "确认收货失败");
            }

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "系统错误: " + e.getMessage());
        }

        out.print(new com.google.gson.Gson().toJson(result));
        out.flush();
    }
}