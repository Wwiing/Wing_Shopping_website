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

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private CartDao cartDao = new CartDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        System.out.println("=== Checkout Debug ===");
        System.out.println("User: " + (user != null ? user.getUsername() : "null"));

        if (user == null) {
            System.out.println("User not logged in, redirecting to login");
            response.sendRedirect("login.jsp?message=Please login first");
            return;
        }

        try {
            // 获取用户的购物车商品
            List<CartItem> cartItems = cartDao.getCartByUserId(user.getId());
            System.out.println("Cart items found: " + (cartItems != null ? cartItems.size() : "null"));

            if (cartItems == null || cartItems.isEmpty()) {
                System.out.println("Cart is empty, redirecting to cart");
                response.sendRedirect("cart?error=Your cart is empty");
                return;
            }

            // 计算总金额
            double totalAmount = 0.0;
            for (CartItem item : cartItems) {
                if (item.getProduct() != null) {
                    double itemTotal = item.getProduct().getPrice().doubleValue() * item.getQuantity();
                    totalAmount += itemTotal;
                    System.out.println("Cart item: " + item.getProduct().getName() + " x " + item.getQuantity() + " = " + itemTotal);
                } else {
                    System.out.println("Cart item has null product: " + item.getProductId());
                }
            }

            System.out.println("Total amount: " + totalAmount);

            request.setAttribute("cartItems", cartItems);
            request.setAttribute("totalAmount", totalAmount);
            request.setAttribute("user", user);

            System.out.println("Forwarding to checkout.jsp");
            request.getRequestDispatcher("/checkout.jsp").forward(request, response);

        } catch (Exception e) {
            System.out.println("Error in checkout: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("cart?error=Failed to load checkout page");
        }
    }
}