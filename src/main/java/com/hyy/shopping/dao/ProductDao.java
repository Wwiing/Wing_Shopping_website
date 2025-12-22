package com.hyy.shopping.dao;

import com.hyy.shopping.model.Product;
import java.sql.SQLException;
import java.util.List;

public interface ProductDao {
    // 添加商品
    boolean addProduct(Product product) throws SQLException;

    // 根据ID查找商品
    Product findById(Long productId) throws SQLException;

    // 获取所有商品
    List<Product> findAll() throws SQLException;

    // 根据分类获取商品
    List<Product> findByCategory(String category) throws SQLException;

    // 搜索商品
    List<Product> search(String keyword) throws SQLException;

    // 更新商品信息
    boolean update(Product product) throws SQLException;

    // 更新商品库存
    boolean updateStock(Long productId, Integer newStock) throws SQLException;

    // 删除商品
    boolean delete(Long productId) throws SQLException;

    // --- 新增： 分页与计数接口 ---
    // 获取符合条件的商品总数（用于计算总页数）
    int getProductCount(String category, String search) throws SQLException;

    // 按条件分页查询商品，offset 从0开始，limit 为每页大小
    List<Product> findPaged(String category, String search, int offset, int limit) throws SQLException;

    // 获取商品销售统计
    List<com.hyy.shopping.model.SalesStatistic> getSalesStatistics() throws SQLException;
}