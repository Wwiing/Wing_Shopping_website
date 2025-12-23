package com.hyy.shopping.dao;

import com.hyy.shopping.model.User;
import java.sql.SQLException;
import java.util.List;

public interface UserDao {
    // 用户注册
    boolean register(User user) throws SQLException;

    // 根据用户名查找用户（用于登录和验证用户名是否存在）
    User findByUsername(String username) throws SQLException;

    // 根据用户ID查找用户
    User findById(Long id) throws SQLException;

    // 验证用户登录
    User login(String username, String password) throws SQLException;

    // 获取所有用户（管理员）
    List<User> findAllUsers() throws SQLException;
}