package com.hyy.shopping.controller;

import com.hyy.shopping.dao.UserDao;
import com.hyy.shopping.dao.UserDaoImpl;
import com.hyy.shopping.model.User;
import com.hyy.shopping.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserDao userDao = new UserDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get form parameters
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");

        try {
            // Check if username already exists
            if (userDao.findByUsername(username) != null) {
                request.setAttribute("error", "Username already exists");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            // Create user object
            User user = new User();
            user.setUsername(username);
            user.setPassword(PasswordUtil.encrypt(password));
            user.setEmail(email);
            user.setRole("CUSTOMER");
            user.setBalance(BigDecimal.ZERO);

            boolean success = userDao.register(user);

            if (success) {
                response.sendRedirect("login.jsp?message=Registration successful, please login");
            } else {
                request.setAttribute("error", "Registration failed, please try again");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "System error: " + e.getMessage());
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}