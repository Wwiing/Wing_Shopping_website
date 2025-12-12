package com.hyy.shopping.test;

import com.hyy.shopping.util.DatabaseUtil;
import java.sql.Connection;

public class TestConnection {
    public static void main(String[] args) {
        try {
            Connection conn = DatabaseUtil.getConnection();
            System.out.println("✅ 数据库连接成功！");
            conn.close();
        } catch (Exception e) {
            System.out.println("❌ 数据库连接失败：" + e.getMessage());
            e.printStackTrace();
        }
    }
}