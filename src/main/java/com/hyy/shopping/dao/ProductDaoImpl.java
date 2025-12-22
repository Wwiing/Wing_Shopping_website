package com.hyy.shopping.dao;

import com.hyy.shopping.model.Product;
import com.hyy.shopping.model.SalesStatistic;
import com.hyy.shopping.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDaoImpl implements ProductDao {

    @Override
    public boolean addProduct(Product product) throws SQLException {
        // 支持可选的 description_long 字段
        String sql = "INSERT INTO products (name, description, description_long, price, stock, category, image_url) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, product.getName());
            stmt.setString(2, product.getDescription());
            stmt.setString(3, product.getDescriptionLong());
            stmt.setBigDecimal(4, product.getPrice());
            stmt.setInt(5, product.getStock());
            stmt.setString(6, product.getCategory());
            stmt.setString(7, product.getImageUrl());

            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public Product findById(Long productId) throws SQLException {
        String sql = "SELECT * FROM products WHERE id = ? AND active = TRUE";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, productId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractProductFromResultSet(rs);
            }
            return null;
        }
    }

    @Override
    public List<Product> findAll() throws SQLException {
        String sql = "SELECT * FROM products WHERE active = TRUE ORDER BY id DESC";
        List<Product> products = new ArrayList<>();

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                products.add(extractProductFromResultSet(rs));
            }
            return products;
        }
    }

    @Override
    public List<Product> findByCategory(String category) throws SQLException {
        String sql = "SELECT * FROM products WHERE category = ? AND active = TRUE ORDER BY id DESC";
        List<Product> products = new ArrayList<>();

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, category);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                products.add(extractProductFromResultSet(rs));
            }
            return products;
        }
    }

    @Override
    public List<Product> search(String keyword) throws SQLException {
        String sql = "SELECT * FROM products WHERE (name LIKE ? OR description LIKE ?) AND active = TRUE";
        List<Product> products = new ArrayList<>();

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            String searchTerm = "%" + keyword + "%";
            stmt.setString(1, searchTerm);
            stmt.setString(2, searchTerm);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                products.add(extractProductFromResultSet(rs));
            }
            return products;
        }
    }

    @Override
    public boolean update(Product product) throws SQLException {
        // 同样支持 description_long 更新
        String sql = "UPDATE products SET name=?, description=?, description_long=?, price=?, stock=?, category=?, image_url=? WHERE id=?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, product.getName());
            stmt.setString(2, product.getDescription());
            stmt.setString(3, product.getDescriptionLong());
            stmt.setBigDecimal(4, product.getPrice());
            stmt.setInt(5, product.getStock());
            stmt.setString(6, product.getCategory());
            stmt.setString(7, product.getImageUrl());
            stmt.setLong(8, product.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public boolean updateStock(Long productId, Integer newStock) throws SQLException {
        String sql = "UPDATE products SET stock = ? WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, newStock);
            stmt.setLong(2, productId);

            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public boolean delete(Long productId) throws SQLException {
        String sql = "UPDATE products SET active = FALSE WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, productId);
            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public int getProductCount(String category, String search) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products WHERE active = TRUE");
        List<Object> params = new ArrayList<>();
        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND category = ?");
            params.add(category);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (name LIKE ? OR description LIKE ?)");
            String q = "%" + search + "%";
            params.add(q);
            params.add(q);
        }

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    @Override
    public List<Product> findPaged(String category, String search, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM products WHERE active = TRUE");
        List<Object> params = new ArrayList<>();
        if (category != null && !category.trim().isEmpty()) {
            sql.append(" AND category = ?");
            params.add(category);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (name LIKE ? OR description LIKE ?)");
            String q = "%" + search + "%";
            params.add(q);
            params.add(q);
        }
        sql.append(" ORDER BY id DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<Product> products = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    products.add(extractProductFromResultSet(rs));
                }
            }
        }
        return products;
    }

    @Override
    public List<SalesStatistic> getSalesStatistics() throws SQLException {
        String sql = "SELECT p.*, SUM(oi.quantity) as total_quantity " +
                "FROM products p " +
                "JOIN order_items oi ON p.id = oi.product_id " +
                "GROUP BY p.id " +
                "ORDER BY total_quantity DESC";
        List<SalesStatistic> stats = new ArrayList<>();

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Product product = extractProductFromResultSet(rs);
                int totalQuantity = rs.getInt("total_quantity");
                stats.add(new SalesStatistic(product, totalQuantity));
            }
            return stats;
        }
    }

    private Product extractProductFromResultSet(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setId(rs.getLong("id"));
        product.setName(rs.getString("name"));
        product.setDescription(rs.getString("description"));
        product.setPrice(rs.getBigDecimal("price"));
        product.setStock(rs.getInt("stock"));
        product.setCategory(rs.getString("category"));

        String img = rs.getString("image_url");
        if (img != null) {
            img = img.trim();
            if (img.isEmpty()) img = null;
        }
        product.setImageUrl(img);

        // 可选的长描述列，如果数据库不存在该列，rs.getString 会返回 null
        try {
            String descLong = null;
            // 使用列名 description_long，如果数据库没有该列则捕获异常并忽略
            try {
                descLong = rs.getString("description_long");
            } catch (SQLException ex) {
                // 忽略 - 数据库表可能没有该列
            }
            product.setDescriptionLong(descLong);
        } catch (Exception ignored) {}

        product.setCreatedAt(rs.getTimestamp("created_at"));
        product.setActive(rs.getBoolean("active"));
        return product;
    }
}