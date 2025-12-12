package com.hyy.shopping.dao;

import com.hyy.shopping.util.DatabaseUtil;
import java.math.BigDecimal;
import java.sql.*;

public class WalletDaoImpl implements WalletDao {

    @Override
    public BigDecimal getBalance(Long userId) throws SQLException {
        String sql = "SELECT balance FROM users WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, userId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getBigDecimal("balance");
            }
            return BigDecimal.ZERO;
        }
    }

    @Override
    public boolean recharge(Long userId, BigDecimal amount) throws SQLException {
        String sql = "UPDATE users SET balance = balance + ? WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBigDecimal(1, amount);
            stmt.setLong(2, userId);

            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public boolean deduct(Long userId, BigDecimal amount) throws SQLException {
        // 先检查余额是否足够
        if (!hasSufficientBalance(userId, amount)) {
            return false;
        }

        String sql = "UPDATE users SET balance = balance - ? WHERE id = ?";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBigDecimal(1, amount);
            stmt.setLong(2, userId);

            return stmt.executeUpdate() > 0;
        }
    }

    @Override
    public boolean hasSufficientBalance(Long userId, BigDecimal amount) throws SQLException {
        BigDecimal balance = getBalance(userId);
        return balance != null && balance.compareTo(amount) >= 0;
    }
}