package com.hyy.shopping.dao;

import com.hyy.shopping.model.CartItem;
import java.sql.SQLException;
import java.util.List;

public interface CartDao {
    // 添加商品到购物车
    boolean addToCart(CartItem cartItem) throws SQLException;

    // 获取用户的购物车商品
    List<CartItem> getCartByUserId(Long userId) throws SQLException;

    // 更新购物车商品数量
    boolean updateQuantity(Long cartItemId, Integer quantity) throws SQLException;

    // 从购物车删除商品
    boolean removeFromCart(Long cartItemId) throws SQLException;

    // 清空用户购物车
    boolean clearCart(Long userId) throws SQLException;

    // 检查商品是否已在购物车中
    CartItem findCartItem(Long userId, Long productId) throws SQLException;
}