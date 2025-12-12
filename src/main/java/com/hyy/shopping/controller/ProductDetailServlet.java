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
import java.io.PrintWriter;

@WebServlet("/product")
public class ProductDetailServlet extends HttpServlet {
    private final ProductDao productDao = new ProductDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        StringBuilder debug = new StringBuilder();
        debug.append("Requested id=").append(idStr).append("\n");

        String dbgParam = request.getParameter("dbg");

        if (idStr == null || idStr.trim().isEmpty()) {
            request.setAttribute("error", "未指定商品");
            debug.append("No id provided\n");
            request.setAttribute("debugInfo", debug.toString());
            if (dbgParam != null) {
                response.setContentType("text/plain;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) { out.print(debug.toString()); }
                return;
            }
            request.getRequestDispatcher("/product-detail.jsp").forward(request, response);
            return;
        }

        try {
            Long id = Long.parseLong(idStr);
            Product product = productDao.findById(id);
            if (product == null) {
                request.setAttribute("error", "未找到商品");
                debug.append("product == null for id ").append(id).append("\n");
                request.setAttribute("debugInfo", debug.toString());
                if (dbgParam != null) {
                    response.setContentType("text/plain;charset=UTF-8");
                    try (PrintWriter out = response.getWriter()) { out.print(debug.toString()); }
                    return;
                }
                request.getRequestDispatcher("/product-detail.jsp").forward(request, response);
                return;
            }

            debug.append("Found product: id=").append(product.getId())
                    .append(", name=").append(product.getName())
                    .append(", price=").append(product.getPrice())
                    .append(", stock=").append(product.getStock())
                    .append(", imageUrl=").append(product.getImageUrl())
                    .append(", descLong=").append(product.getDescriptionLong())
                    .append("\n");

            request.setAttribute("product", product);
            request.setAttribute("debugInfo", debug.toString());

            if (dbgParam != null) {
                response.setContentType("text/plain;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) { out.print(debug.toString()); }
                return;
            }

            request.getRequestDispatcher("/product-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "无效的商品ID");
            debug.append("NumberFormatException for idStr=").append(idStr).append("\n");
            request.setAttribute("debugInfo", debug.toString());
            if (dbgParam != null) {
                response.setContentType("text/plain;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) { out.print(debug.toString()); }
                return;
            }
            request.getRequestDispatcher("/product-detail.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "获取商品详情失败");
            debug.append("Exception: ").append(e.getMessage()).append("\n");
            request.setAttribute("debugInfo", debug.toString());
            if (dbgParam != null) {
                response.setContentType("text/plain;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) { out.print(debug.toString()); }
                return;
            }
            request.getRequestDispatcher("/product-detail.jsp").forward(request, response);
        }
    }
}
