package com.seatreservation.utils;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordGenerator {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // 生成 123456 的BCrypt哈希
        String password123456 = encoder.encode("123456");
        System.out.println("123456 的BCrypt哈希: " + password123456);
        
        // 生成 admin123 的BCrypt哈希
        String passwordAdmin123 = encoder.encode("admin123");
        System.out.println("admin123 的BCrypt哈希: " + passwordAdmin123);
        
        // 验证
        System.out.println("验证 123456: " + encoder.matches("123456", password123456));
        System.out.println("验证 admin123: " + encoder.matches("admin123", passwordAdmin123));
    }
}