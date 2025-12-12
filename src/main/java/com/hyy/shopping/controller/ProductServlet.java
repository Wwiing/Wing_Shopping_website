package com.hyy.shopping.controller;

import com.hyy.shopping.dao.ProductDao;
import com.hyy.shopping.dao.ProductDaoImpl;
import com.hyy.shopping.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/products")
public class ProductServlet extends HttpServlet {
    private ProductDao productDao = new ProductDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String category = request.getParameter("category");
            String search = request.getParameter("search");

            // 处理分页参数
            String pageStr = request.getParameter("page");
            int page = 1;
            try {
                if (pageStr != null) page = Integer.parseInt(pageStr);
            } catch (NumberFormatException ignored) {
                page = 1;
            }
            if (page < 1) page = 1;

            final int pageSize = 10; // 每页显示10个
            int offset = (page - 1) * pageSize;

            // 获取总数和页数
            int totalCount = productDao.getProductCount(category, search);
            int totalPages = (totalCount + pageSize - 1) / pageSize;
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) {
                page = totalPages;
                offset = (page - 1) * pageSize;
            }

            // 分页查询
            List<Product> products = productDao.findPaged(category, search, offset, pageSize);

            // 设置属性以便 JSP 使用
            request.setAttribute("products", products);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalCount", totalCount);

            if (category != null && !category.trim().isEmpty()) {
                request.setAttribute("currentCategory", category);
            }
            if (search != null && !search.trim().isEmpty()) {
                request.setAttribute("searchKeyword", search);
            }

            // 添加调试信息
            System.out.println("Found products: " + products.size() + ", page=" + page + ", totalPages=" + totalPages + ", totalCount=" + totalCount);
            for (Product p : products) {
                System.out.println("Product: " + p.getName() + ", Price: " + p.getPrice());
            }

            request.getRequestDispatcher("/products.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "获取商品列表失败");
            request.getRequestDispatcher("/products.jsp").forward(request, response);
        }
    }
}