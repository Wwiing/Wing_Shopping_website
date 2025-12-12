package com.hyy.shopping.dao;

import java.math.BigDecimal;
import java.sql.SQLException;

public interface WalletDao {
    // 获取用户余额
    BigDecimal getBalance(Long userId) throws SQLException;

    // 充值
    boolean recharge(Long userId, BigDecimal amount) throws SQLException;

    // 扣款
    boolean deduct(Long userId, BigDecimal amount) throws SQLException;

    // 检查余额是否足够
    boolean hasSufficientBalance(Long userId, BigDecimal amount) throws SQLException;
}