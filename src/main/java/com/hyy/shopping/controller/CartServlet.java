package com.hyy.shopping.controller;

import com.hyy.shopping.dao.CartDao;
import com.hyy.shopping.dao.CartDaoImpl;
import com.hyy.shopping.model.CartItem;
import com.hyy.shopping.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private CartDao cartDao = new CartDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 查看购物车
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            // 用户未登录，跳转到登录页面
            response.sendRedirect("login.jsp?message=Please login first");
            return;
        }

        try {
            List<CartItem> cartItems = cartDao.getCartByUserId(user.getId());
            request.setAttribute("cartItems", cartItems);

            // 计算总价
            double totalAmount = 0.0;
            for (CartItem item : cartItems) {
                if (item.getProduct() != null) {
                    totalAmount += item.getProduct().getPrice().doubleValue() * item.getQuantity();
                }
            }
            request.setAttribute("totalAmount", totalAmount);

            request.getRequestDispatcher("/cart.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load cart");
            request.getRequestDispatcher("/cart.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 处理购物车操作（添加、更新、删除）
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp?message=Please login first");
            return;
        }

        String action = request.getParameter("action");

        try {
            switch (action) {
                case "add":
                    addToCart(request, user.getId());
                    break;
                case "update":
                    updateCartItem(request);
                    break;
                case "remove":
                    removeFromCart(request);
                    break;
                case "clear":
                    clearCart(user.getId());
                    break;
            }

            // 操作完成后重定向到购物车页面
            response.sendRedirect("cart");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("cart?error=Operation failed");
        }
    }

    private void addToCart(HttpServletRequest request, Long userId) throws Exception {
        Long productId = Long.parseLong(request.getParameter("productId"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));

        CartItem cartItem = new CartItem();
        cartItem.setUserId(userId);
        cartItem.setProductId(productId);
        cartItem.setQuantity(quantity);

        cartDao.addToCart(cartItem);
    }

    private void updateCartItem(HttpServletRequest request) throws Exception {
        Long cartItemId = Long.parseLong(request.getParameter("cartItemId"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));

        cartDao.updateQuantity(cartItemId, quantity);
    }

    private void removeFromCart(HttpServletRequest request) throws Exception {
        Long cartItemId = Long.parseLong(request.getParameter("cartItemId"));
        cartDao.removeFromCart(cartItemId);
    }

    private void clearCart(Long userId) throws Exception {
        cartDao.clearCart(userId);
    }
}