package com.hyy.shopping.util;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;
import java.math.BigDecimal;

public class EmailUtil {

    // 邮件服务器配置
    private static final String SMTP_HOST = "smtp.qq.com";
    private static final int SMTP_PORT = 465; // SSL端口
    private static final String SMTP_USERNAME = "1057174179@qq.com"; // 替换为你的QQ邮箱
    private static final String SMTP_PASSWORD = "jovesrctqyeobaji"; // 替换为你的授权码
    private static final String FROM_EMAIL = "1057174179@qq.com";
    private static final String FROM_NAME = "购物网站";

    /**
     * 发送邮件
     */
    public static boolean sendEmail(String toEmail, String subject, String content) {
        System.out.println("开始发送邮件到: " + toEmail);

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.ssl.enable", "true"); // 使用SSL
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        props.put("mail.smtp.socketFactory.port", SMTP_PORT);

        // 创建会话
        Session session = Session.getInstance(props,
                new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
                    }
                });

        try {
            // 创建邮件
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);

            // 设置邮件内容（HTML格式）
            MimeBodyPart htmlPart = new MimeBodyPart();
            String htmlContent = "<html>"
                    + "<head><meta charset='UTF-8'></head>"
                    + "<body>"
                    + "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>"
                    + "<div style='background-color: #4CAF50; color: white; padding: 20px; text-align: center;'>"
                    + "<h1>购物网站</h1>"
                    + "</div>"
                    + "<div style='padding: 20px;'>"
                    + content.replace("\n", "<br>")
                    + "</div>"
                    + "<div style='background-color: #f5f5f5; padding: 15px; text-align: center; color: #666; font-size: 12px;'>"
                    + "<p>© 2024 购物网站. 版权所有.</p>"
                    + "<p>此邮件由系统自动发送，请勿直接回复。</p>"
                    + "</div>"
                    + "</div>"
                    + "</body>"
                    + "</html>";

            htmlPart.setContent(htmlContent, "text/html; charset=UTF-8");

            Multipart multipart = new MimeMultipart();
            multipart.addBodyPart(htmlPart);

            message.setContent(multipart);

            // 发送邮件
            Transport.send(message);

            System.out.println("邮件发送成功: " + toEmail);
            return true;

        } catch (Exception e) {
            System.out.println("邮件发送失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 发送订单创建邮件
     */
    public static boolean sendOrderCreatedEmail(String toEmail, Long orderId, BigDecimal totalAmount) {
        String subject = "订单创建成功 - 订单号 #" + orderId;
        String content = "尊敬的客户，<br><br>"
                + "您的订单已成功创建！<br><br>"
                + "<strong>订单信息:</strong><br>"
                + "订单号: #" + orderId + "<br>"
                + "订单金额: ¥" + totalAmount + "<br><br>"
                + "您可以在“我的订单”页面查看订单详情。<br><br>"
                + "感谢您的购买！<br>"
                + "购物网站团队";

        return sendEmail(toEmail, subject, content);
    }

    /**
     * 发送发货邮件
     */
    public static boolean sendShippingEmail(String toEmail, Long orderId, String trackingNumber, String carrier) {
        String subject = "您的订单已发货 - 订单号 #" + orderId;
        String content = "尊敬的客户，<br><br>"
                + "您的订单已经发货！<br><br>"
                + "<strong>发货信息:</strong><br>"
                + "订单号: #" + orderId + "<br>"
                + "物流公司: " + carrier + "<br>"
                + "运单号: " + trackingNumber + "<br><br>"
                + "您可以通过以上运单号查询物流信息。<br><br>"
                + "感谢您的购买！<br>"
                + "购物网站团队";

        return sendEmail(toEmail, subject, content);
    }

    /**
     * 测试邮件功能
     */
    public static void main(String[] args) {
        System.out.println("测试邮件发送...");
        boolean success = sendEmail("收件人邮箱@qq.com", "测试邮件", "这是一封测试邮件。");
        System.out.println("邮件发送结果: " + (success ? "成功" : "失败"));
    }
}