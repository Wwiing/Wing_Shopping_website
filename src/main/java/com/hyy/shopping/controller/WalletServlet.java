package com.hyy.shopping.controller;

import com.hyy.shopping.dao.WalletDao;
import com.hyy.shopping.dao.WalletDaoImpl;
import com.hyy.shopping.model.User;
import com.hyy.shopping.util.DatabaseUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/wallet")
public class WalletServlet extends HttpServlet {
    private WalletDao walletDao = new WalletDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp?message=请先登录");
            return;
        }

        try {
            // 获取最新余额
            BigDecimal balance = walletDao.getBalance(user.getId());
            user.setBalance(balance);
            session.setAttribute("user", user);

            request.getRequestDispatcher("/wallet.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=获取余额失败");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp?message=请先登录");
            return;
        }

        String action = request.getParameter("action");
        String amountStr = request.getParameter("amount");

        try {
            BigDecimal amount = new BigDecimal(amountStr);

            // 验证金额范围 (1-10000)
            if (amount.compareTo(BigDecimal.ONE) < 0 || amount.compareTo(new BigDecimal("10000")) > 0) {
                request.setAttribute("error", "充值金额必须在1-10000元之间");
                request.getRequestDispatcher("/wallet.jsp").forward(request, response);
                return;
            }

            if ("recharge".equals(action)) {
                // 充值
                boolean success = walletDao.recharge(user.getId(), amount);

                if (success) {
                    // 更新session中的用户余额
                    BigDecimal newBalance = walletDao.getBalance(user.getId());
                    user.setBalance(newBalance);
                    session.setAttribute("user", user);

                    request.setAttribute("message", "充值成功！当前余额: ¥" + newBalance);
                    request.setAttribute("balance", newBalance);
                } else {
                    request.setAttribute("error", "充值失败");
                }

                // 转发回钱包页面（不是重定向）
                request.getRequestDispatcher("/wallet.jsp").forward(request, response);

            } else if ("withdraw".equals(action)) {
                // 提现（可选功能）
                request.setAttribute("error", "暂不支持提现");
                request.getRequestDispatcher("/wallet.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "请输入有效的金额");
            request.getRequestDispatcher("/wallet.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "系统错误: " + e.getMessage());
            request.getRequestDispatcher("/wallet.jsp").forward(request, response);
        }
    }
}