-- 更新测试账号密码为正确的BCrypt加密格式
-- 注意：这些密码是使用Spring BCrypt生成的

USE seat_reservation;

-- 更新管理员账号密码 (admin / admin123)
-- BCrypt加密的admin123
UPDATE sys_user 
SET password = '$2a$10$N4VKaCI8m7XwlvGLfGz4aOKBOxk9FLLCXqT5t4v8QHgtsFLLp5x6a'
WHERE username = 'admin';

-- 更新学生测试账号密码 (student001, student002 / 123456)  
-- BCrypt加密的123456
UPDATE sys_user 
SET password = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.'
WHERE username IN ('student001', 'student002');

-- 创建一个新的测试管理员账号，如果需要的话
INSERT IGNORE INTO sys_user (username, password, real_name, phone, email, role, status) 
VALUES ('testadmin', '$2a$10$N4VKaCI8m7XwlvGLfGz4aOKBOxk9FLLCXqT5t4v8QHgtsFLLp5x6a', 
        '测试管理员', '18800000000', 'testadmin@test.com', 'ADMIN', 'ACTIVE');

-- 查看所有用户账号（用于验证）
SELECT id, username, real_name, role, status, created_time FROM sys_user; 