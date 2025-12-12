package com.hyy.shopping.dao;

import com.hyy.shopping.model.Order;
import com.hyy.shopping.model.OrderItem;
import java.sql.SQLException;
import java.util.List;

public interface OrderDao {
    // 创建订单
    boolean createOrder(Order order) throws SQLException;

    // 根据订单ID查找订单
    Order findById(Long orderId) throws SQLException;

    // 根据用户ID查找订单
    List<Order> findByUserId(Long userId) throws SQLException;

    // 获取所有订单（管理员）
    List<Order> findAll() throws SQLException;

    // 更新订单状态
    boolean updateStatus(Long orderId, String status) throws SQLException;

    // 添加订单项
    boolean addOrderItem(OrderItem orderItem) throws SQLException;

    // 根据订单ID获取订单项
    List<OrderItem> findItemsByOrderId(Long orderId) throws SQLException;

    // 删除订单（软删除）
    boolean deleteOrder(Long orderId) throws SQLException;
}