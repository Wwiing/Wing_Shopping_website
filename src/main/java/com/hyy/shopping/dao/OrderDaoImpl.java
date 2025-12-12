package com.hyy.shopping.dao;

import com.hyy.shopping.model.Order;
import com.hyy.shopping.model.OrderItem;
import com.hyy.shopping.model.Product;
import com.hyy.shopping.model.User;
import com.hyy.shopping.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDaoImpl implements OrderDao {

    @Override
    public boolean createOrder(Order order) throws SQLException {
        String sql = "INSERT INTO orders (user_id, total_amount, status, shipping_address, payment_method) VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet generatedKeys = null;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            System.out.println("开始数据库事务...");

            // 插入订单
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setLong(1, order.getUserId());
            stmt.setBigDecimal(2, order.getTotalAmount());
            stmt.setString(3, order.getStatus());
            stmt.setString(4, order.getShippingAddress());
            stmt.setString(5, order.getPaymentMethod());

            System.out.println("执行订单插入SQL...");
            int rowsAffected = stmt.executeUpdate();
            System.out.println("订单插入完成，影响行数: " + rowsAffected);

            if (rowsAffected > 0) {
                generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys != null && generatedKeys.next()) {
                    Long orderId = generatedKeys.getLong(1);
                    order.setId(orderId);
                    System.out.println("获取到订单ID: " + orderId);

                    // 插入订单项
                    System.out.println("开始插入订单项...");
                    boolean itemsSuccess = addOrderItems(conn, orderId, order.getOrderItems());
                    System.out.println("订单项插入结果: " + itemsSuccess);

                    if (itemsSuccess) {
                        conn.commit();
                        System.out.println("事务提交成功");
                        return true;
                    }
                } else {
                    System.out.println("无法获取生成的订单ID");
                }
            }

            conn.rollback();
            System.out.println("事务回滚");
            return false;

        } catch (SQLException e) {
            System.out.println("数据库操作异常: " + e.getMessage());
            System.out.println("SQL状态: " + e.getSQLState());
            System.out.println("错误代码: " + e.getErrorCode());
            e.printStackTrace();

            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            // 关闭资源
            if (generatedKeys != null) try { generatedKeys.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {}
        }
    }

    private boolean addOrderItems(Connection conn, Long orderId, List<OrderItem> orderItems) throws SQLException {
        String sql = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            for (OrderItem item : orderItems) {
                stmt.setLong(1, orderId);
                stmt.setLong(2, item.getProductId());
                stmt.setInt(3, item.getQuantity());
                stmt.setBigDecimal(4, item.getPrice());
                stmt.addBatch();
            }

            int[] results = stmt.executeBatch();
            return results.length == orderItems.size();
        }
    }

    @Override
    public Order findById(Long orderId) throws SQLException {
        String sql = "SELECT o.*, u.username, u.email " +
                "FROM orders o " +
                "JOIN users u ON o.user_id = u.id " +
                "WHERE o.id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, orderId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Order order = extractOrderFromResultSet(rs);
                order.setOrderItems(findItemsByOrderId(orderId));
                return order;
            }
            return null;
        }
    }

    @Override
    public List<Order> findByUserId(Long userId) throws SQLException {
        String sql = "SELECT o.*, u.username, u.email " +
                "FROM orders o " +
                "JOIN users u ON o.user_id = u.id " +
                "WHERE o.user_id = ? " +
                "ORDER BY o.created_at DESC";

        List<Order> orders = new ArrayList<>();

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, userId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Order order = extractOrderFromResultSet(rs);
                orders.add(order);
            }
            return orders;
        }
    }

    @Override
    public List<Order> findAll() throws SQLException {
        String sql = "SELECT o.*, u.username, u.email " +
                "FROM orders o " +
                "JOIN users u ON o.user_id = u.id " +
                "ORDER BY o.created_at DESC";

        List<Order> orders = new ArrayList<>();

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Order order = extractOrderFromResultSet(rs);
                orders.add(order);
            }
            return orders;
        }
    }

    @Override
    public boolean updateStatus(Long orderId, String status) throws SQLException {
        String sql = "UPDATE orders SET status = ?, updated_at = NOW() WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setLong(2, orderId);

            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public boolean addOrderItem(OrderItem orderItem) throws SQLException {
        String sql = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, orderItem.getOrderId());
            stmt.setLong(2, orderItem.getProductId());
            stmt.setInt(3, orderItem.getQuantity());
            stmt.setBigDecimal(4, orderItem.getPrice());

            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public List<OrderItem> findItemsByOrderId(Long orderId) throws SQLException {
        String sql = "SELECT oi.*, p.name, p.image_url, p.description " +
                "FROM order_items oi " +
                "JOIN products p ON oi.product_id = p.id " +
                "WHERE oi.order_id = ?";

        List<OrderItem> orderItems = new ArrayList<>();

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, orderId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                OrderItem item = extractOrderItemFromResultSet(rs);
                orderItems.add(item);
            }
            return orderItems;
        }
    }

    @Override
    public boolean deleteOrder(Long orderId) throws SQLException {
        // 软删除：将状态标记为已取消
        return updateStatus(orderId, "CANCELLED");
    }

    private Order extractOrderFromResultSet(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setId(rs.getLong("id"));
        order.setUserId(rs.getLong("user_id"));
        order.setTotalAmount(rs.getBigDecimal("total_amount"));
        order.setStatus(rs.getString("status"));
        order.setShippingAddress(rs.getString("shipping_address"));
        order.setPaymentMethod(rs.getString("payment_method"));
        order.setCreatedAt(rs.getTimestamp("created_at"));
        order.setUpdatedAt(rs.getTimestamp("updated_at"));

        // 设置用户信息
        User user = new User();
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        order.setUser(user);

        return order;
    }

    private OrderItem extractOrderItemFromResultSet(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem();
        item.setId(rs.getLong("id"));
        item.setOrderId(rs.getLong("order_id"));
        item.setProductId(rs.getLong("product_id"));
        item.setQuantity(rs.getInt("quantity"));
        item.setPrice(rs.getBigDecimal("price"));

        // 设置商品信息
        Product product = new Product();
        product.setName(rs.getString("name"));
        product.setImageUrl(rs.getString("image_url"));
        item.setProduct(product);

        return item;
    }
}