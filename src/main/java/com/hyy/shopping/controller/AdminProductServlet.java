package com.hyy.shopping.controller;

import com.hyy.shopping.dao.ProductDao;
import com.hyy.shopping.dao.ProductDaoImpl;
import com.hyy.shopping.model.Product;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/products")
public class AdminProductServlet extends HttpServlet {
    private final ProductDao productDao = new ProductDaoImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            List<Product> products = productDao.findAll();
            req.setAttribute("products", products);
        } catch (SQLException e) {
            req.setAttribute("error", "加载商品失败: " + e.getMessage());
        }
        try {
            req.getRequestDispatcher("/admin/admin-products.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new IOException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if (action == null) action = "add";

        try {
            if ("add".equals(action)) {
                Product p = new Product();
                p.setName(nullToEmpty(req.getParameter("name")));
                p.setDescription(nullToEmpty(req.getParameter("description")));
                p.setDescriptionLong(nullToEmpty(req.getParameter("descriptionLong")));

                String priceStr = req.getParameter("price");
                try {
                    p.setPrice(priceStr != null && !priceStr.trim().isEmpty() ? new BigDecimal(priceStr.trim()) : BigDecimal.ZERO);
                } catch (Exception ex) {
                    p.setPrice(BigDecimal.ZERO);
                }

                String stockStr = req.getParameter("stock");
                try {
                    p.setStock(stockStr != null && !stockStr.trim().isEmpty() ? Integer.parseInt(stockStr.trim()) : 0);
                } catch (Exception ex) {
                    p.setStock(0);
                }

                p.setCategory(nullToEmpty(req.getParameter("category")));
                p.setImageUrl(nullToEmpty(req.getParameter("imageUrl")));

                boolean ok = productDao.addProduct(p);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/products?message=added");
                    return;
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/products?error=add_failed");
                    return;
                }
            } else if ("delete".equals(action)) {
                String idStr = req.getParameter("id");
                if (idStr != null && !idStr.trim().isEmpty()) {
                    try {
                        Long id = Long.parseLong(idStr.trim());
                        boolean ok = productDao.delete(id);
                        if (ok) {
                            resp.sendRedirect(req.getContextPath() + "/admin/products?message=deleted");
                            return;
                        } else {
                            resp.sendRedirect(req.getContextPath() + "/admin/products?error=delete_failed");
                            return;
                        }
                    } catch (NumberFormatException ex) {
                        // fallthrough
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/admin/products?error=invalid_id");
                return;
            }
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/products?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            return;
        }

        // 默认重定向回列表
        resp.sendRedirect(req.getContextPath() + "/admin/products");
    }

    private String nullToEmpty(String s) {
        return s == null ? "" : s.trim();
    }
}
