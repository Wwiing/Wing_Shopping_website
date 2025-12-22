package com.hyy.shopping.controller;

import com.hyy.shopping.dao.ProductDao;
import com.hyy.shopping.dao.ProductDaoImpl;
import com.hyy.shopping.model.Product;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.util.List;

@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 5 * 1024 * 1024, maxRequestSize = 10 * 1024 * 1024)
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

        // 如果带有 editId 参数，则加载对应商品用于编辑表单
        String editId = req.getParameter("editId");
        if (editId != null && !editId.trim().isEmpty()) {
            try {
                Long id = Long.parseLong(editId.trim());
                try {
                    Product editProduct = productDao.findById(id);
                    if (editProduct != null) {
                        req.setAttribute("editProduct", editProduct);
                    } else {
                        req.setAttribute("error", "未找到要编辑的商品(ID=" + id + ")");
                    }
                } catch (SQLException ex) {
                    req.setAttribute("error", "加载编辑商品失败: " + ex.getMessage());
                }
            } catch (NumberFormatException ignored) {
                req.setAttribute("error", "无效的编辑商品 ID");
            }
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

                // 先尝试处理文件上传，如果没有文件则回退到 imageUrl 参数
                String imageUrl = nullToEmpty(req.getParameter("imageUrl"));
                try {
                    Part imagePart = req.getPart("imageFile");
                    if (imagePart != null && imagePart.getSize() > 0) {
                        String fileName = getSubmittedFileName(imagePart);
                        String ext = "";
                        int dot = fileName.lastIndexOf('.');
                        if (dot >= 0) ext = fileName.substring(dot);

                        String safeName = System.currentTimeMillis() + ext;
                        String imagesDir = req.getServletContext().getRealPath("/static/images/goods");
                        if (imagesDir == null) {
                            imagesDir = getServletContext().getRealPath("");
                            imagesDir = imagesDir + File.separator + "static" + File.separator + "images" + File.separator + "goods";
                        }
                        File dir = new File(imagesDir);
                        if (!dir.exists()) dir.mkdirs();

                        File out = new File(dir, safeName);
                        try (InputStream in = imagePart.getInputStream()) {
                            Files.copy(in, out.toPath(), StandardCopyOption.REPLACE_EXISTING);
                        }
                        imageUrl = "/static/images/goods/" + safeName;
                    }
                } catch (IllegalStateException ise) {
                    // 上传太大或其它问题，忽略并回退到 imageUrl 参数
                } catch (Exception ex) {
                    System.out.println("保存上传图片失败: " + ex.getMessage());
                }

                p.setImageUrl(imageUrl);

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
            } else if ("edit".equals(action)) {
                // 更新商品信息
                String idStr = req.getParameter("id");
                if (idStr == null || idStr.trim().isEmpty()) {
                    resp.sendRedirect(req.getContextPath() + "/admin/products?error=invalid_id");
                    return;
                }
                Long id = Long.parseLong(idStr.trim());
                Product p = productDao.findById(id);
                if (p == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/products?error=product_not_found");
                    return;
                }

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

                // 处理文件上传（如果有）并覆盖旧图片
                try {
                    Part imagePart = req.getPart("imageFile");
                    if (imagePart != null && imagePart.getSize() > 0) {
                        String fileName = getSubmittedFileName(imagePart);
                        String ext = "";
                        int dot = fileName.lastIndexOf('.');
                        if (dot >= 0) ext = fileName.substring(dot);

                        String safeName = System.currentTimeMillis() + ext;
                        String imagesDir = req.getServletContext().getRealPath("/static/images/goods");
                        if (imagesDir == null) {
                            imagesDir = getServletContext().getRealPath("");
                            imagesDir = imagesDir + File.separator + "static" + File.separator + "images" + File.separator + "goods";
                        }
                        File dir = new File(imagesDir);
                        if (!dir.exists()) dir.mkdirs();

                        File out = new File(dir, safeName);
                        try (InputStream in = imagePart.getInputStream()) {
                            Files.copy(in, out.toPath(), StandardCopyOption.REPLACE_EXISTING);
                        }
                        String newUrl = "/static/images/goods/" + safeName;
                        p.setImageUrl(newUrl);
                    } else {
                        // 如果没有上传文件，允许通过 imageUrl 参数手动改变（或保持原值）
                        String imageUrlParam = req.getParameter("imageUrl");
                        if (imageUrlParam != null && !imageUrlParam.trim().isEmpty()) {
                            p.setImageUrl(imageUrlParam.trim());
                        }
                    }
                } catch (Exception ex) {
                    System.out.println("编辑时保存上传图片失败: " + ex.getMessage());
                }

                boolean ok = productDao.update(p);
                if (ok) {
                    resp.sendRedirect(req.getContextPath() + "/admin/products?message=updated");
                    return;
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/products?error=update_failed");
                    return;
                }
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

    // Helper to get original filename in a portable way
    private String getSubmittedFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) return null;
        for (String cd : header.split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return fileName.substring(fileName.lastIndexOf(File.separator) + 1);
            }
        }
        return null;
    }
}
