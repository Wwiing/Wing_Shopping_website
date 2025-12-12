package com.hyy.shopping.dao;

import com.hyy.shopping.model.CartItem;
import com.hyy.shopping.model.Product;
import com.hyy.shopping.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDaoImpl implements CartDao {

    @Override
    public boolean addToCart(CartItem cartItem) throws SQLException {
        String updateSql = "UPDATE cart_items SET quantity = quantity + ? WHERE user_id = ? AND product_id = ?";
        String insertSql = "INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, ?)";

        Connection conn = null;
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setInt(1, cartItem.getQuantity());
                updateStmt.setLong(2, cartItem.getUserId());
                updateStmt.setLong(3, cartItem.getProductId());

                int rows = updateStmt.executeUpdate();
                if (rows > 0) {
                    conn.commit();
                    return true;
                }
            }

            // 尝试插入
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                insertStmt.setLong(1, cartItem.getUserId());
                insertStmt.setLong(2, cartItem.getProductId());
                insertStmt.setInt(3, cartItem.getQuantity());

                int rows = insertStmt.executeUpdate();
                if (rows > 0) {
                    try (ResultSet gen = insertStmt.getGeneratedKeys()) {
                        if (gen.next()) {
                            cartItem.setId(gen.getLong(1));
                        }
                    }
                    conn.commit();
                    return true;
                }
            } catch (SQLIntegrityConstraintViolationException ex) {
                // 可能因为并发插入导致唯一约束冲突，回退并尝试更新数量
                conn.rollback();
                try (PreparedStatement fallbackUpdate = conn.prepareStatement(updateSql)) {
                    fallbackUpdate.setInt(1, cartItem.getQuantity());
                    fallbackUpdate.setLong(2, cartItem.getUserId());
                    fallbackUpdate.setLong(3, cartItem.getProductId());
                    int rows2 = fallbackUpdate.executeUpdate();
                    if (rows2 > 0) {
                        conn.commit();
                        return true;
                    }
                }
            }

            conn.commit();
            return false;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignore) {}
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignore) {}
            }
        }
    }

    @Override
    public List<CartItem> getCartByUserId(Long userId) throws SQLException {
        String sql = "SELECT ci.*, p.name, p.price, p.image_url, p.stock, p.description, p.category " +
                "FROM cart_items ci " +
                "JOIN products p ON ci.product_id = p.id " +
                "WHERE ci.user_id = ? AND p.active = TRUE";

        List<CartItem> cartItems = new ArrayList<>();

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, userId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                CartItem cartItem = extractCartItemFromResultSet(rs);
                cartItems.add(cartItem);
            }
            return cartItems;
        }
    }

    @Override
    public boolean updateQuantity(Long cartItemId, Integer quantity) throws SQLException {
        if (quantity <= 0) {
            // 如果数量为0或负数，删除该商品
            return removeFromCart(cartItemId);
        }

        String sql = "UPDATE cart_items SET quantity = ? WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quantity);
            stmt.setLong(2, cartItemId);

            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public boolean removeFromCart(Long cartItemId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, cartItemId);
            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public boolean clearCart(Long userId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE user_id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, userId);
            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public CartItem findCartItem(Long userId, Long productId) throws SQLException {
        String sql = "SELECT ci.*, p.name, p.price, p.image_url, p.stock, p.description, p.category " +
                "FROM cart_items ci " +
                "JOIN products p ON ci.product_id = p.id " +
                "WHERE ci.user_id = ? AND ci.product_id = ? AND p.active = TRUE";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, userId);
            stmt.setLong(2, productId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractCartItemFromResultSet(rs);
            }
            return null;
        }
    }

    private CartItem extractCartItemFromResultSet(ResultSet rs) throws SQLException {
        CartItem cartItem = new CartItem();
        cartItem.setId(rs.getLong("id"));
        cartItem.setUserId(rs.getLong("user_id"));
        cartItem.setProductId(rs.getLong("product_id"));
        cartItem.setQuantity(rs.getInt("quantity"));
        cartItem.setCreatedAt(rs.getTimestamp("created_at"));

        // 设置完整的商品信息
        Product product = new Product();
        product.setId(rs.getLong("product_id"));
        product.setName(rs.getString("name"));
        product.setPrice(rs.getBigDecimal("price"));
        product.setImageUrl(rs.getString("image_url"));
        product.setStock(rs.getInt("stock")); // 重要：获取库存
        product.setDescription(rs.getString("description"));
        product.setCategory(rs.getString("category"));
        cartItem.setProduct(product);

        System.out.println("加载商品: " + product.getName() + ", 库存: " + product.getStock());

        return cartItem;
    }
}