package com.hyy.shopping.util;

import com.mchange.v2.c3p0.ComboPooledDataSource;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

public class DatabaseUtil {
    private static DataSource dataSource;

    static {
        // 使用c3p0连接池
        dataSource = new ComboPooledDataSource();
    }

    // 获取数据库连接
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }
}