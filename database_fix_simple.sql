-- 简化版数据库修复脚本
-- 只修复关键问题：创建公告表和更新用户密码

USE seat_reservation;

-- 1. 创建公告表（如果不存在）
CREATE TABLE IF NOT EXISTS sys_announcement (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'NOTICE',
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    author_id BIGINT NOT NULL,
    author_name VARCHAR(50) NOT NULL,
    priority INT NOT NULL DEFAULT 2,
    publish_time DATETIME NULL,
    expire_time DATETIME NULL,
    view_count INT NOT NULL DEFAULT 0,
    created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 插入示例公告数据
INSERT IGNORE INTO sys_announcement (title, content, type, status, author_id, author_name, priority, publish_time, view_count) VALUES
('系统上线通知', '座位预约系统现已正式上线，欢迎大家使用！', 'ANNOUNCEMENT', 'PUBLISHED', 1, '系统管理员', 3, NOW(), 10),
('使用须知', '请注意：预约后请按时到场，超时将自动取消预约。', 'NOTICE', 'PUBLISHED', 1, '系统管理员', 2, NOW(), 5),
('维护通知', '系统将定期维护，维护期间部分功能可能不可用。', 'MAINTENANCE', 'PUBLISHED', 1, '系统管理员', 2, NOW(), 2);

-- 3. 更新用户密码（修复登录问题）
-- 管理员密码：admin123
UPDATE sys_user SET password = '$2a$10$N4VKaCI8m7XwlvGLfGz4aOKBOxk9FLLCXqT5t4v8QHgtsFLLp5x6a' WHERE username = 'admin';

-- 学生测试账号密码：123456
UPDATE sys_user SET password = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.' WHERE username IN ('student001', 'student002');

-- 4. 验证修复结果
SELECT '==== 用户账号 ====' AS '修复验证';
SELECT id, username, real_name, role, status FROM sys_user;

SELECT '==== 公告数据 ====' AS '修复验证';
SELECT id, title, type, status, author_name, view_count FROM sys_announcement;

COMMIT; 