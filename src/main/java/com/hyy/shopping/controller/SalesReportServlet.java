package com.hyy.shopping.controller;

import com.hyy.shopping.dao.ProductDao;
import com.hyy.shopping.dao.ProductDaoImpl;
import com.hyy.shopping.model.SalesStatistic;
import com.hyy.shopping.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/sales-report")
public class SalesReportServlet extends HttpServlet {
    private ProductDao productDao = new ProductDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendRedirect("../login.jsp?message=需要管理员权限");
            return;
        }

        try {
            List<SalesStatistic> salesStatistics = productDao.getSalesStatistics();
            request.setAttribute("salesStatistics", salesStatistics);
            request.getRequestDispatcher("/admin/sales-report.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "加载销售报表失败");
            request.getRequestDispatcher("/admin/sales-report.jsp").forward(request, response);
        }
    }
}

