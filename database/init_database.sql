-- ========================================
-- 自习室座位预约系统 - 统一数据库初始化脚本
-- 版本：2.0
-- 功能：完整的数据库结构 + 扩展功能 + 测试数据
-- 使用方法：mysql -u root -p < init_database.sql
-- ========================================

-- ========================================
-- 第一部分：数据库创建
-- ========================================

-- 删除已存在的数据库（谨慎使用）
DROP DATABASE IF EXISTS seat_reservation;

-- 创建数据库，使用UTF8MB4字符集
CREATE DATABASE seat_reservation CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE seat_reservation;

-- ========================================
-- 第二部分：核心数据表创建
-- ========================================

-- 1. 用户表
CREATE TABLE sys_user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码(BCrypt加密)',
    real_name VARCHAR(50) NOT NULL COMMENT '真实姓名',
    phone VARCHAR(20) UNIQUE COMMENT '手机号',
    email VARCHAR(100) UNIQUE COMMENT '邮箱',
    student_id VARCHAR(20) UNIQUE COMMENT '学号',
    role ENUM('STUDENT', 'ADMIN') DEFAULT 'STUDENT' COMMENT '用户角色',
    status ENUM('ACTIVE', 'DISABLED') DEFAULT 'ACTIVE' COMMENT '账号状态',
    avatar_url VARCHAR(255) COMMENT '头像URL',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT='用户表';

-- 2. 座位类型表
CREATE TABLE seat_type (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL COMMENT '座位类型名称',
    description VARCHAR(200) COMMENT '描述',
    hourly_rate DECIMAL(5,2) DEFAULT 0.00 COMMENT '每小时费率',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) COMMENT='座位类型表';

-- 3. 座位表
CREATE TABLE seat (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    seat_number VARCHAR(20) NOT NULL UNIQUE COMMENT '座位编号',
    floor_number INT NOT NULL COMMENT '楼层',
    area VARCHAR(50) NOT NULL COMMENT '区域',
    seat_type_id INT NOT NULL COMMENT '座位类型ID',
    position_x INT COMMENT 'X坐标(用于座位图显示)',
    position_y INT COMMENT 'Y坐标(用于座位图显示)',
    status ENUM('AVAILABLE', 'OCCUPIED', 'MAINTENANCE', 'DISABLED') DEFAULT 'AVAILABLE' COMMENT '座位状态',
    has_power BOOLEAN DEFAULT TRUE COMMENT '是否有电源',
    has_computer BOOLEAN DEFAULT FALSE COMMENT '是否有电脑',
    description VARCHAR(200) COMMENT '座位描述',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (seat_type_id) REFERENCES seat_type(id)
) COMMENT='座位表';

-- 4. 预约表
CREATE TABLE reservation (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    seat_id BIGINT NOT NULL COMMENT '座位ID',
    reservation_date DATE NOT NULL COMMENT '预约日期',
    start_time TIME NOT NULL COMMENT '开始时间',
    end_time TIME NOT NULL COMMENT '结束时间',
    status ENUM('RESERVED', 'USING', 'COMPLETED', 'CANCELLED', 'EXPIRED') DEFAULT 'RESERVED' COMMENT '预约状态',
    check_in_time TIMESTAMP NULL COMMENT '签到时间',
    check_out_time TIMESTAMP NULL COMMENT '签退时间',
    total_fee DECIMAL(8,2) DEFAULT 0.00 COMMENT '总费用',
    remark VARCHAR(500) COMMENT '备注',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES seat(id),
    UNIQUE KEY uk_seat_datetime (seat_id, reservation_date, start_time, end_time)
) COMMENT='预约表';

-- 5. 系统配置表
CREATE TABLE sys_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键',
    config_value VARCHAR(500) NOT NULL COMMENT '配置值',
    config_desc VARCHAR(200) COMMENT '配置描述',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT='系统配置表';

-- 6. 操作日志表
CREATE TABLE operation_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT COMMENT '操作用户ID',
    operation_type VARCHAR(50) NOT NULL COMMENT '操作类型',
    operation_desc VARCHAR(500) COMMENT '操作描述',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_url VARCHAR(200) COMMENT '请求URL',
    ip_address VARCHAR(50) COMMENT 'IP地址',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES sys_user(id)
) COMMENT='操作日志表';

-- ========================================
-- 第三部分：支付相关表
-- ========================================

-- 7. 用户钱包表
CREATE TABLE user_wallet (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    balance DECIMAL(10,2) DEFAULT 0.00 COMMENT '余额',
    total_recharge DECIMAL(10,2) DEFAULT 0.00 COMMENT '累计充值',
    total_consume DECIMAL(10,2) DEFAULT 0.00 COMMENT '累计消费',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE
) COMMENT='用户钱包表';

-- 8. 充值记录表
CREATE TABLE recharge_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    order_no VARCHAR(64) NOT NULL UNIQUE COMMENT '充值订单号',
    amount DECIMAL(10,2) NOT NULL COMMENT '充值金额',
    bonus_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT '赠送金额',
    payment_method VARCHAR(20) NOT NULL COMMENT '支付方式：WECHAT, ALIPAY, BANK_CARD',
    payment_status VARCHAR(20) DEFAULT 'PENDING' COMMENT '支付状态：PENDING, SUCCESS, FAILED, CANCELLED',
    third_party_order_no VARCHAR(128) COMMENT '第三方订单号',
    remark TEXT COMMENT '备注',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE
) COMMENT='充值记录表';

-- 9. 支付记录表
CREATE TABLE payment_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    reservation_id BIGINT NOT NULL,
    order_no VARCHAR(64) NOT NULL UNIQUE COMMENT '支付订单号',
    amount DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    payment_method VARCHAR(20) NOT NULL COMMENT '支付方式：WALLET, WECHAT, ALIPAY, BANK_CARD',
    payment_status VARCHAR(20) DEFAULT 'PENDING' COMMENT '支付状态：PENDING, SUCCESS, FAILED, CANCELLED, REFUNDED',
    third_party_order_no VARCHAR(128) COMMENT '第三方订单号',
    refund_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT '退款金额',
    refund_time TIMESTAMP NULL COMMENT '退款时间',
    remark TEXT COMMENT '备注',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
    FOREIGN KEY (reservation_id) REFERENCES reservation(id) ON DELETE CASCADE
) COMMENT='支付记录表';

-- ========================================
-- 第四部分：扩展功能表
-- ========================================

-- 10. 座位收藏表
CREATE TABLE seat_favorite (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    seat_id BIGINT NOT NULL,
    favorite_name VARCHAR(50) DEFAULT NULL COMMENT '收藏备注名称',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES seat(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_seat (user_id, seat_id) COMMENT '用户-座位唯一约束'
) COMMENT='座位收藏表';

-- 11. 系统公告表
CREATE TABLE sys_announcement (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    title VARCHAR(200) NOT NULL COMMENT '公告标题',
    content TEXT NOT NULL COMMENT '公告内容',
    type VARCHAR(20) NOT NULL DEFAULT 'NOTICE' COMMENT '公告类型：NOTICE-通知, ANNOUNCEMENT-公告, URGENT-紧急',
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT' COMMENT '公告状态：DRAFT-草稿, PUBLISHED-已发布, ARCHIVED-已归档',
    author_id BIGINT NOT NULL COMMENT '作者ID',
    author_name VARCHAR(50) NOT NULL COMMENT '作者姓名',
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM' COMMENT '优先级：LOW-低, MEDIUM-中, HIGH-高',
    publish_time TIMESTAMP NULL COMMENT '发布时间',
    expire_time TIMESTAMP NULL COMMENT '过期时间',
    view_count INT NOT NULL DEFAULT 0 COMMENT '浏览次数',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (author_id) REFERENCES sys_user(id)
) COMMENT='系统公告表';

-- 12. 系统设置表
CREATE TABLE system_settings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    setting_key VARCHAR(100) NOT NULL COMMENT '设置键名',
    setting_value TEXT COMMENT '设置值(JSON格式)',
    setting_type VARCHAR(50) NOT NULL COMMENT '设置类型(basic/reservation/schedule/payment/email/security)',
    description VARCHAR(255) COMMENT '设置描述',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_setting_key_type (setting_key, setting_type)
) COMMENT='系统设置表';

-- 13. 自习室表（用于多自习室管理）
CREATE TABLE study_room (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '自习室ID',
    room_name VARCHAR(100) NOT NULL COMMENT '自习室名称',
    room_number VARCHAR(50) NOT NULL COMMENT '自习室编号',
    floor_number INT NOT NULL COMMENT '楼层',
    description TEXT COMMENT '自习室描述',
    image_url VARCHAR(500) COMMENT '自习室图片URL',
    capacity INT DEFAULT 0 COMMENT '容量',
    status VARCHAR(20) DEFAULT 'AVAILABLE' COMMENT '状态：AVAILABLE-可用, MAINTENANCE-维护中, DISABLED-禁用',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT='自习室表';

-- 14. 意见反馈表
CREATE TABLE feedback (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '反馈ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    type VARCHAR(20) NOT NULL COMMENT '反馈类型：SUGGESTION-建议, BUG-问题, COMPLAINT-投诉, OTHER-其他',
    content TEXT NOT NULL COMMENT '反馈内容',
    reply TEXT COMMENT '管理员回复',
    status VARCHAR(20) DEFAULT 'PENDING' COMMENT '状态：PENDING-待处理, REPLIED-已回复, CLOSED-已关闭',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    replied_time TIMESTAMP NULL COMMENT '回复时间',
    replied_by BIGINT COMMENT '回复者ID',
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE
) COMMENT='意见反馈表';

-- 15. 消息通知表
CREATE TABLE notification (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '通知ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    title VARCHAR(200) NOT NULL COMMENT '通知标题',
    content TEXT NOT NULL COMMENT '通知内容',
    type VARCHAR(20) NOT NULL COMMENT '通知类型：RESERVATION-预约相关, SYSTEM-系统通知, ANNOUNCEMENT-公告',
    is_read BOOLEAN DEFAULT FALSE COMMENT '是否已读',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    read_time TIMESTAMP NULL COMMENT '阅读时间',
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE
) COMMENT='消息通知表';

-- ========================================
-- 第五部分：数据库索引优化
-- ========================================

-- 用户表索引
CREATE INDEX idx_user_username ON sys_user(username);
CREATE INDEX idx_user_student_id ON sys_user(student_id);
CREATE INDEX idx_user_email ON sys_user(email);
CREATE INDEX idx_user_phone ON sys_user(phone);

-- 座位表索引
CREATE INDEX idx_seat_number ON seat(seat_number);
CREATE INDEX idx_seat_floor_area ON seat(floor_number, area);
CREATE INDEX idx_seat_status ON seat(status);
CREATE INDEX idx_seat_type ON seat(seat_type_id);

-- 预约表索引
CREATE INDEX idx_reservation_user ON reservation(user_id);
CREATE INDEX idx_reservation_seat ON reservation(seat_id);
CREATE INDEX idx_reservation_date ON reservation(reservation_date);
CREATE INDEX idx_reservation_status ON reservation(status);
CREATE INDEX idx_reservation_datetime ON reservation(reservation_date, start_time, end_time);

-- 钱包和支付索引
CREATE INDEX idx_user_wallet_user_id ON user_wallet(user_id);
CREATE INDEX idx_recharge_user_id ON recharge_record(user_id);
CREATE INDEX idx_recharge_order_no ON recharge_record(order_no);
CREATE INDEX idx_recharge_status ON recharge_record(payment_status);
CREATE INDEX idx_payment_user_id ON payment_record(user_id);
CREATE INDEX idx_payment_reservation_id ON payment_record(reservation_id);
CREATE INDEX idx_payment_order_no ON payment_record(order_no);
CREATE INDEX idx_payment_status ON payment_record(payment_status);

-- 收藏表索引
CREATE INDEX idx_seat_favorite_user ON seat_favorite(user_id);
CREATE INDEX idx_seat_favorite_seat ON seat_favorite(seat_id);

-- 公告表索引
CREATE INDEX idx_announcement_status_priority ON sys_announcement(status, priority, publish_time);
CREATE INDEX idx_announcement_author ON sys_announcement(author_id);
CREATE INDEX idx_announcement_type_status ON sys_announcement(type, status);
CREATE INDEX idx_announcement_expire_time ON sys_announcement(expire_time);

-- 系统设置索引
CREATE INDEX idx_setting_type ON system_settings(setting_type);

-- 操作日志索引
CREATE INDEX idx_operation_log_user ON operation_log(user_id);
CREATE INDEX idx_operation_log_time ON operation_log(created_time);

-- 反馈表索引
CREATE INDEX idx_feedback_user_id ON feedback(user_id);
CREATE INDEX idx_feedback_status ON feedback(status);
CREATE INDEX idx_feedback_type ON feedback(type);

-- 通知表索引
CREATE INDEX idx_notification_user_id ON notification(user_id);
CREATE INDEX idx_notification_is_read ON notification(is_read);
CREATE INDEX idx_notification_type ON notification(type);
CREATE INDEX idx_notification_created_time ON notification(created_time);

-- ========================================
-- 第六部分：基础数据初始化
-- ========================================

-- 1. 插入座位类型数据
INSERT INTO seat_type (type_name, description, hourly_rate) VALUES
('普通座位', '基础学习座位', 0.00),
('靠窗座位', '采光良好的靠窗座位', 1.00),
('独立包间', '安静的独立学习包间', 3.00),
('电脑座位', '配备电脑的学习座位', 2.00);

-- 2. 插入管理员和测试用户
-- 管理员账号：admin / admin123
-- BCrypt加密密码: $2a$10$aj0.DKdRT7r3VCJCjkJC8OKpbImydBgQe9ACXj1p3/eKYk0dk0Tta
INSERT INTO sys_user (username, password, real_name, phone, email, role, status) VALUES
('admin', '$2a$10$aj0.DKdRT7r3VCJCjkJC8OKpbImydBgQe9ACXj1p3/eKYk0dk0Tta', '系统管理员', '13800138000', 'admin@example.com', 'ADMIN', 'ACTIVE');

-- 学生测试账号：student001-005 / 123456
-- BCrypt加密密码: $2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.
INSERT INTO sys_user (username, password, real_name, phone, email, student_id, role, status) VALUES
('student001', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '张三', '13900139001', 'zhangsan@example.com', '2021001001', 'STUDENT', 'ACTIVE'),
('student002', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '李四', '13900139002', 'lisi@example.com', '2021001002', 'STUDENT', 'ACTIVE'),
('student003', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '王五', '13900139003', 'wangwu@example.com', '2021001003', 'STUDENT', 'ACTIVE'),
('student004', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '赵六', '13900139004', 'zhaoliu@example.com', '2021001004', 'STUDENT', 'ACTIVE'),
('student005', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '钱七', '13900139005', 'qianqi@example.com', '2021001005', 'STUDENT', 'ACTIVE');

-- 3. 插入座位数据（2楼A区和B区共60个座位）
-- A区座位 (1-30号)
INSERT INTO seat (seat_number, floor_number, area, seat_type_id, position_x, position_y, has_power, has_computer) VALUES
-- A区第一排 (1-10号)
('A001', 2, 'A区', 1, 50, 50, TRUE, FALSE),
('A002', 2, 'A区', 1, 100, 50, TRUE, FALSE),
('A003', 2, 'A区', 2, 150, 50, TRUE, FALSE),  -- 靠窗
('A004', 2, 'A区', 1, 200, 50, TRUE, FALSE),
('A005', 2, 'A区', 4, 250, 50, TRUE, TRUE),   -- 电脑座位
('A006', 2, 'A区', 1, 300, 50, TRUE, FALSE),
('A007', 2, 'A区', 1, 350, 50, TRUE, FALSE),
('A008', 2, 'A区', 2, 400, 50, TRUE, FALSE),  -- 靠窗
('A009', 2, 'A区', 1, 450, 50, TRUE, FALSE),
('A010', 2, 'A区', 1, 500, 50, TRUE, FALSE),

-- A区第二排 (11-20号)
('A011', 2, 'A区', 1, 50, 150, TRUE, FALSE),
('A012', 2, 'A区', 1, 100, 150, TRUE, FALSE),
('A013', 2, 'A区', 2, 150, 150, TRUE, FALSE), -- 靠窗
('A014', 2, 'A区', 1, 200, 150, TRUE, FALSE),
('A015', 2, 'A区', 4, 250, 150, TRUE, TRUE),  -- 电脑座位
('A016', 2, 'A区', 1, 300, 150, TRUE, FALSE),
('A017', 2, 'A区', 1, 350, 150, TRUE, FALSE),
('A018', 2, 'A区', 2, 400, 150, TRUE, FALSE), -- 靠窗
('A019', 2, 'A区', 1, 450, 150, TRUE, FALSE),
('A020', 2, 'A区', 1, 500, 150, TRUE, FALSE),

-- A区第三排 (21-30号)
('A021', 2, 'A区', 1, 50, 250, TRUE, FALSE),
('A022', 2, 'A区', 1, 100, 250, TRUE, FALSE),
('A023', 2, 'A区', 2, 150, 250, TRUE, FALSE), -- 靠窗
('A024', 2, 'A区', 1, 200, 250, TRUE, FALSE),
('A025', 2, 'A区', 3, 250, 250, TRUE, FALSE), -- 独立包间
('A026', 2, 'A区', 3, 300, 250, TRUE, FALSE), -- 独立包间
('A027', 2, 'A区', 1, 350, 250, TRUE, FALSE),
('A028', 2, 'A区', 2, 400, 250, TRUE, FALSE), -- 靠窗
('A029', 2, 'A区', 1, 450, 250, TRUE, FALSE),
('A030', 2, 'A区', 1, 500, 250, TRUE, FALSE),

-- B区座位 (31-60号)
('B001', 2, 'B区', 1, 600, 50, TRUE, FALSE),
('B002', 2, 'B区', 1, 650, 50, TRUE, FALSE),
('B003', 2, 'B区', 2, 700, 50, TRUE, FALSE),  -- 靠窗
('B004', 2, 'B区', 1, 750, 50, TRUE, FALSE),
('B005', 2, 'B区', 4, 800, 50, TRUE, TRUE),   -- 电脑座位
('B006', 2, 'B区', 1, 850, 50, TRUE, FALSE),
('B007', 2, 'B区', 1, 900, 50, TRUE, FALSE),
('B008', 2, 'B区', 2, 950, 50, TRUE, FALSE),  -- 靠窗
('B009', 2, 'B区', 1, 1000, 50, TRUE, FALSE),
('B010', 2, 'B区', 1, 1050, 50, TRUE, FALSE),
('B011', 2, 'B区', 1, 600, 150, TRUE, FALSE),
('B012', 2, 'B区', 1, 650, 150, TRUE, FALSE),
('B013', 2, 'B区', 2, 700, 150, TRUE, FALSE), -- 靠窗
('B014', 2, 'B区', 1, 750, 150, TRUE, FALSE),
('B015', 2, 'B区', 4, 800, 150, TRUE, TRUE),  -- 电脑座位
('B016', 2, 'B区', 1, 850, 150, TRUE, FALSE),
('B017', 2, 'B区', 1, 900, 150, TRUE, FALSE),
('B018', 2, 'B区', 2, 950, 150, TRUE, FALSE), -- 靠窗
('B019', 2, 'B区', 1, 1000, 150, TRUE, FALSE),
('B020', 2, 'B区', 1, 1050, 150, TRUE, FALSE),
('B021', 2, 'B区', 1, 600, 250, TRUE, FALSE),
('B022', 2, 'B区', 1, 650, 250, TRUE, FALSE),
('B023', 2, 'B区', 2, 700, 250, TRUE, FALSE), -- 靠窗
('B024', 2, 'B区', 1, 750, 250, TRUE, FALSE),
('B025', 2, 'B区', 3, 800, 250, TRUE, FALSE), -- 独立包间
('B026', 2, 'B区', 3, 850, 250, TRUE, FALSE), -- 独立包间
('B027', 2, 'B区', 1, 900, 250, TRUE, FALSE),
('B028', 2, 'B区', 2, 950, 250, TRUE, FALSE), -- 靠窗
('B029', 2, 'B区', 1, 1000, 250, TRUE, FALSE),
('B030', 2, 'B区', 1, 1050, 250, TRUE, FALSE);

-- 4. 插入系统配置
INSERT INTO sys_config (config_key, config_value, config_desc) VALUES
('system.reservation.max_hours', '8', '单次预约最大小时数'),
('system.reservation.advance_days', '7', '最多提前预约天数'),
('system.reservation.cancel_hours', '2', '预约前多少小时可以取消'),
('system.open_time', '08:00', '自习室开放时间'),
('system.close_time', '22:00', '自习室关闭时间'),
('system.name', '智慧自习室座位预约系统', '系统名称'),
('system.version', '1.0.0', '系统版本'),
('system.description', '基于Spring Boot的智能座位预约管理系统', '系统描述');

-- 5. 为所有用户创建钱包
INSERT INTO user_wallet (user_id, balance, total_recharge)
SELECT id,
       CASE
           WHEN id = 1 THEN 1000.00  -- 管理员账户
           WHEN id <= 3 THEN 100.00  -- 前几个用户有余额
           WHEN id <= 5 THEN 50.00   -- 中间用户有少量余额
           ELSE 20.00                -- 其他用户少量余额
       END as balance,
       CASE
           WHEN id = 1 THEN 1000.00
           WHEN id <= 3 THEN 100.00
           WHEN id <= 5 THEN 50.00
           ELSE 20.00
       END as total_recharge
FROM sys_user;

-- 6. 插入示例公告
INSERT INTO sys_announcement (title, content, type, status, author_id, author_name, priority, publish_time, expire_time, view_count) VALUES
('自习室座位预约系统正式上线', '亲爱的同学们，自习室座位预约系统已正式上线运行。大家可以通过系统提前预约座位，避免到馆后无座位的困扰。请合理使用预约功能，共同维护良好的学习环境。', 'ANNOUNCEMENT', 'PUBLISHED', 1, '系统管理员', 'HIGH', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 0),
('预约座位使用须知', '请各位同学注意：\n1. 预约后请按时到达，超过30分钟未签到将自动取消预约\n2. 离开座位超过2小时请记得签退\n3. 保持座位整洁，文明用座\n4. 如需取消预约，请提前在系统中操作', 'NOTICE', 'PUBLISHED', 1, '系统管理员', 'MEDIUM', NOW(), NULL, 0),
('系统功能介绍', '系统主要功能包括：\n- 实时座位状态查看\n- 在线座位预约\n- 钱包充值和支付\n- 座位收藏功能\n- 预约历史查询\n- 个人资料管理\n请大家充分利用这些功能，提高学习效率！', 'NOTICE', 'PUBLISHED', 1, '系统管理员', 'LOW', NOW(), NULL, 0);

-- 7. 插入系统设置（详细配置）
INSERT INTO system_settings (setting_key, setting_value, setting_type, description) VALUES
-- 基础设置
('systemName', '"智慧自习室座位预约系统"', 'basic', '系统名称'),
('systemDescription', '"基于Spring Boot的智能化座位预约管理系统"', 'basic', '系统描述'),
('systemVersion', '"1.0.0"', 'basic', '系统版本'),
('contactEmail', '"admin@seatreservation.com"', 'basic', '联系邮箱'),
('contactPhone', '"400-123-4567"', 'basic', '联系电话'),
('systemEnabled', 'true', 'basic', '系统状态'),
('maintenanceMode', 'false', 'basic', '维护模式'),

-- 预约设置
('maxHours', '8', 'reservation', '最大预约时长(小时)'),
('advanceDays', '7', 'reservation', '提前预约天数'),
('cancelHours', '2', 'reservation', '取消预约时限(小时)'),
('autoConfirm', 'false', 'reservation', '自动确认预约'),
('allowDuplicate', 'false', 'reservation', '允许重复预约'),
('enableReminder', 'true', 'reservation', '预约提醒'),
('reminderMinutes', '30', 'reservation', '提醒时间(分钟)'),

-- 时间设置
('openTime', '"08:00"', 'schedule', '开放时间'),
('closeTime', '"22:00"', 'schedule', '关闭时间'),
('restDays', '[]', 'schedule', '休息日'),
('holidayMode', 'false', 'schedule', '节假日模式'),
('holidays', '[]', 'schedule', '节假日时间'),

-- 支付设置
('enablePayment', 'true', 'payment', '启用支付功能'),
('defaultHourlyRate', '5.0', 'payment', '默认费率(元/小时)'),
('minimumAmount', '1.0', 'payment', '最低消费金额(元)'),
('enableWallet', 'true', 'payment', '钱包功能'),
('freeTrialMinutes', '30', 'payment', '免费试用时长(分钟)'),
('paymentMethods', '["wallet", "alipay", "wechat"]', 'payment', '支付方式'),

-- 邮件设置
('enableEmail', 'false', 'email', '启用邮件'),
('smtpHost', '""', 'email', 'SMTP服务器'),
('smtpPort', '587', 'email', 'SMTP端口'),
('senderEmail', '""', 'email', '发送邮箱'),
('senderPassword', '""', 'email', '邮箱密码'),
('enableSSL', 'true', 'email', '启用SSL'),
('template', '"default"', 'email', '邮件模板'),

-- 安全设置
('maxLoginAttempts', '5', 'security', '登录失败次数限制'),
('lockoutMinutes', '30', 'security', '账户锁定时间(分钟)'),
('minPasswordLength', '6', 'security', '密码最小长度'),
('passwordRequirements', '["lowercase", "numbers"]', 'security', '密码复杂度'),
('sessionTimeout', '120', 'security', '会话超时(分钟)'),
('enableCaptcha', 'false', 'security', '启用验证码'),
('enableIPWhitelist', 'false', 'security', 'IP白名单模式'),
('allowedIPs', '""', 'security', '允许的IP地址');

-- 8. 插入测试座位收藏
INSERT INTO seat_favorite (user_id, seat_id, favorite_name) VALUES
(2, 3, '我的靠窗位置'),
(2, 5, '常用电脑座位'),
(3, 25, '安静包间'),
(4, 8, '靠窗学习位'),
(5, 15, '电脑编程位');

-- 9. 插入测试充值记录
INSERT INTO recharge_record (user_id, order_no, amount, bonus_amount, payment_method, payment_status, third_party_order_no, created_time) VALUES
(2, 'RCH202409130001', 100.00, 0.00, 'WECHAT', 'SUCCESS', 'WX2024091312345678901', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(3, 'RCH202409130002', 100.00, 0.00, 'ALIPAY', 'SUCCESS', 'ALI2024091312345678901', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(4, 'RCH202409130003', 50.00, 0.00, 'WECHAT', 'SUCCESS', 'WX2024091312345678902', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 10. 插入示例自习室数据
INSERT INTO study_room (room_name, room_number, floor_number, description, capacity, status) VALUES
('A区自习室', 'A-201', 2, '安静的学习环境，配备空调和饮水机', 30, 'AVAILABLE'),
('B区自习室', 'B-201', 2, '宽敞明亮，适合长时间学习', 30, 'AVAILABLE'),
('C区电脑室', 'C-301', 3, '配备高性能电脑，适合编程学习', 20, 'AVAILABLE');

-- 11. 插入测试预约记录（覆盖多种状态和时间段）
-- 过去30天的预约记录
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, check_in_time, check_out_time, total_fee, created_time) VALUES
-- 已完成的预约（30天前到7天前）
(2, 1, DATE_SUB(CURDATE(), INTERVAL 30 DAY), '09:00:00', '12:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 30 DAY) + INTERVAL 9 HOUR, DATE_SUB(NOW(), INTERVAL 30 DAY) + INTERVAL 12 HOUR, 15.00, DATE_SUB(NOW(), INTERVAL 31 DAY)),
(2, 3, DATE_SUB(CURDATE(), INTERVAL 28 DAY), '14:00:00', '18:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 28 DAY) + INTERVAL 14 HOUR, DATE_SUB(NOW(), INTERVAL 28 DAY) + INTERVAL 18 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 29 DAY)),
(3, 5, DATE_SUB(CURDATE(), INTERVAL 25 DAY), '08:00:00', '12:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 25 DAY) + INTERVAL 8 HOUR, DATE_SUB(NOW(), INTERVAL 25 DAY) + INTERVAL 12 HOUR, 24.00, DATE_SUB(NOW(), INTERVAL 26 DAY)),
(3, 8, DATE_SUB(CURDATE(), INTERVAL 23 DAY), '13:00:00', '17:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 23 DAY) + INTERVAL 13 HOUR, DATE_SUB(NOW(), INTERVAL 23 DAY) + INTERVAL 17 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 24 DAY)),
(4, 10, DATE_SUB(CURDATE(), INTERVAL 20 DAY), '09:00:00', '16:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 20 DAY) + INTERVAL 9 HOUR, DATE_SUB(NOW(), INTERVAL 20 DAY) + INTERVAL 16 HOUR, 35.00, DATE_SUB(NOW(), INTERVAL 21 DAY)),
(4, 15, DATE_SUB(CURDATE(), INTERVAL 18 DAY), '10:00:00', '14:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 18 DAY) + INTERVAL 10 HOUR, DATE_SUB(NOW(), INTERVAL 18 DAY) + INTERVAL 14 HOUR, 24.00, DATE_SUB(NOW(), INTERVAL 19 DAY)),
(5, 20, DATE_SUB(CURDATE(), INTERVAL 15 DAY), '08:00:00', '12:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 15 DAY) + INTERVAL 8 HOUR, DATE_SUB(NOW(), INTERVAL 15 DAY) + INTERVAL 12 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 16 DAY)),
(5, 25, DATE_SUB(CURDATE(), INTERVAL 14 DAY), '14:00:00', '20:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 14 DAY) + INTERVAL 14 HOUR, DATE_SUB(NOW(), INTERVAL 14 DAY) + INTERVAL 20 HOUR, 36.00, DATE_SUB(NOW(), INTERVAL 15 DAY)),
(2, 12, DATE_SUB(CURDATE(), INTERVAL 12 DAY), '09:00:00', '13:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 12 DAY) + INTERVAL 9 HOUR, DATE_SUB(NOW(), INTERVAL 12 DAY) + INTERVAL 13 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 13 DAY)),
(3, 18, DATE_SUB(CURDATE(), INTERVAL 10 DAY), '10:00:00', '15:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 10 DAY) + INTERVAL 10 HOUR, DATE_SUB(NOW(), INTERVAL 10 DAY) + INTERVAL 15 HOUR, 25.00, DATE_SUB(NOW(), INTERVAL 11 DAY)),
(4, 22, DATE_SUB(CURDATE(), INTERVAL 9 DAY), '08:00:00', '11:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 9 DAY) + INTERVAL 8 HOUR, DATE_SUB(NOW(), INTERVAL 9 DAY) + INTERVAL 11 HOUR, 15.00, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(5, 28, DATE_SUB(CURDATE(), INTERVAL 8 DAY), '13:00:00', '18:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 8 DAY) + INTERVAL 13 HOUR, DATE_SUB(NOW(), INTERVAL 8 DAY) + INTERVAL 18 HOUR, 25.00, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(2, 30, DATE_SUB(CURDATE(), INTERVAL 7 DAY), '09:00:00', '14:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 7 DAY) + INTERVAL 9 HOUR, DATE_SUB(NOW(), INTERVAL 7 DAY) + INTERVAL 14 HOUR, 25.00, DATE_SUB(NOW(), INTERVAL 8 DAY)),

-- 最近7天的预约（更多数据）
(3, 2, DATE_SUB(CURDATE(), INTERVAL 6 DAY), '08:00:00', '12:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 6 DAY) + INTERVAL 8 HOUR, DATE_SUB(NOW(), INTERVAL 6 DAY) + INTERVAL 12 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(4, 6, DATE_SUB(CURDATE(), INTERVAL 6 DAY), '14:00:00', '18:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 6 DAY) + INTERVAL 14 HOUR, DATE_SUB(NOW(), INTERVAL 6 DAY) + INTERVAL 18 HOUR, 24.00, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(2, 11, DATE_SUB(CURDATE(), INTERVAL 5 DAY), '09:00:00', '13:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 5 DAY) + INTERVAL 9 HOUR, DATE_SUB(NOW(), INTERVAL 5 DAY) + INTERVAL 13 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(3, 13, DATE_SUB(CURDATE(), INTERVAL 5 DAY), '14:00:00', '19:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 5 DAY) + INTERVAL 14 HOUR, DATE_SUB(NOW(), INTERVAL 5 DAY) + INTERVAL 19 HOUR, 25.00, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(5, 17, DATE_SUB(CURDATE(), INTERVAL 4 DAY), '08:00:00', '12:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 4 DAY) + INTERVAL 8 HOUR, DATE_SUB(NOW(), INTERVAL 4 DAY) + INTERVAL 12 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(4, 23, DATE_SUB(CURDATE(), INTERVAL 4 DAY), '13:00:00', '17:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 4 DAY) + INTERVAL 13 HOUR, DATE_SUB(NOW(), INTERVAL 4 DAY) + INTERVAL 17 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(2, 26, DATE_SUB(CURDATE(), INTERVAL 3 DAY), '09:00:00', '15:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 3 DAY) + INTERVAL 9 HOUR, DATE_SUB(NOW(), INTERVAL 3 DAY) + INTERVAL 15 HOUR, 36.00, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(3, 33, DATE_SUB(CURDATE(), INTERVAL 3 DAY), '10:00:00', '14:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 3 DAY) + INTERVAL 10 HOUR, DATE_SUB(NOW(), INTERVAL 3 DAY) + INTERVAL 14 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(4, 38, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '08:00:00', '12:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 8 HOUR, DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 12 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(5, 43, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '14:00:00', '18:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 14 HOUR, DATE_SUB(NOW(), INTERVAL 2 DAY) + INTERVAL 18 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(2, 48, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '09:00:00', '13:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 1 DAY) + INTERVAL 9 HOUR, DATE_SUB(NOW(), INTERVAL 1 DAY) + INTERVAL 13 HOUR, 20.00, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(3, 52, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '14:00:00', '19:00:00', 'COMPLETED', DATE_SUB(NOW(), INTERVAL 1 DAY) + INTERVAL 14 HOUR, DATE_SUB(NOW(), INTERVAL 1 DAY) + INTERVAL 19 HOUR, 25.00, DATE_SUB(NOW(), INTERVAL 2 DAY)),

-- 今天的预约（包括各种状态）
(2, 4, CURDATE(), '09:00:00', '13:00:00', 'USING', NOW() - INTERVAL 2 HOUR, NULL, 20.00, NOW() - INTERVAL 5 HOUR),
(3, 7, CURDATE(), '10:00:00', '14:00:00', 'USING', NOW() - INTERVAL 1 HOUR, NULL, 20.00, NOW() - INTERVAL 4 HOUR),
(4, 14, CURDATE(), '08:00:00', '12:00:00', 'COMPLETED', NOW() - INTERVAL 4 HOUR, NOW() - INTERVAL 30 MINUTE, 24.00, NOW() - INTERVAL 5 HOUR),
(5, 19, CURDATE(), '14:00:00', '18:00:00', 'RESERVED', NULL, NULL, 20.00, NOW() - INTERVAL 2 HOUR),
(2, 24, CURDATE(), '15:00:00', '20:00:00', 'RESERVED', NULL, NULL, 30.00, NOW() - INTERVAL 1 HOUR),

-- 未来的预约
(3, 9, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '09:00:00', '13:00:00', 'RESERVED', NULL, NULL, 20.00, NOW()),
(4, 16, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:00:00', '18:00:00', 'RESERVED', NULL, NULL, 24.00, NOW()),
(5, 21, DATE_ADD(CURDATE(), INTERVAL 2 DAY), '08:00:00', '12:00:00', 'RESERVED', NULL, NULL, 20.00, NOW()),
(2, 27, DATE_ADD(CURDATE(), INTERVAL 2 DAY), '13:00:00', '17:00:00', 'RESERVED', NULL, NULL, 24.00, NOW()),
(3, 31, DATE_ADD(CURDATE(), INTERVAL 3 DAY), '09:00:00', '14:00:00', 'RESERVED', NULL, NULL, 25.00, NOW()),

-- 取消和过期的预约
(4, 35, DATE_SUB(CURDATE(), INTERVAL 5 DAY), '09:00:00', '13:00:00', 'CANCELLED', NULL, NULL, 0.00, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(5, 40, DATE_SUB(CURDATE(), INTERVAL 3 DAY), '14:00:00', '18:00:00', 'CANCELLED', NULL, NULL, 0.00, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(2, 45, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '08:00:00', '12:00:00', 'EXPIRED', NULL, NULL, 0.00, DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 12. 插入支付记录（对应已完成的预约）
INSERT INTO payment_record (user_id, reservation_id, order_no, amount, payment_method, payment_status, third_party_order_no, created_time) VALUES
-- 钱包支付
(2, 1, 'PAY202409010001', 15.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 30 DAY)),
(2, 2, 'PAY202409030001', 20.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 28 DAY)),
(3, 3, 'PAY202409060001', 24.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 25 DAY)),
(3, 4, 'PAY202409080001', 20.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 23 DAY)),
(4, 5, 'PAY202409110001', 35.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 20 DAY)),
-- 微信支付
(4, 6, 'PAY202409130001', 24.00, 'WECHAT', 'SUCCESS', 'WX2024091398765432101', DATE_SUB(NOW(), INTERVAL 18 DAY)),
(5, 7, 'PAY202409160001', 20.00, 'WECHAT', 'SUCCESS', 'WX2024091698765432102', DATE_SUB(NOW(), INTERVAL 15 DAY)),
-- 支付宝支付
(5, 8, 'PAY202409170001', 36.00, 'ALIPAY', 'SUCCESS', 'ALI2024091798765432101', DATE_SUB(NOW(), INTERVAL 14 DAY)),
(2, 9, 'PAY202409190001', 20.00, 'ALIPAY', 'SUCCESS', 'ALI2024091998765432102', DATE_SUB(NOW(), INTERVAL 12 DAY)),
-- 继续钱包支付
(3, 10, 'PAY202409210001', 25.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 10 DAY)),
(4, 11, 'PAY202409220001', 15.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 9 DAY)),
(5, 12, 'PAY202409230001', 25.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(2, 13, 'PAY202409240001', 25.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(3, 14, 'PAY202409250001', 20.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(4, 15, 'PAY202409250002', 24.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(2, 16, 'PAY202409260001', 20.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(3, 17, 'PAY202409260002', 25.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(5, 18, 'PAY202409270001', 20.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(4, 19, 'PAY202409270002', 20.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(2, 20, 'PAY202409280001', 36.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(3, 21, 'PAY202409280002', 20.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(4, 22, 'PAY202409290001', 20.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 23, 'PAY202409290002', 20.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(2, 24, 'PAY202409300001', 20.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(3, 25, 'PAY202409300002', 25.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
-- 今天的支付
(4, 26, 'PAY202410010001', 24.00, 'WALLET', 'SUCCESS', NULL, NOW() - INTERVAL 5 HOUR),
-- 待支付
(2, 27, 'PAY202410010002', 20.00, 'WALLET', 'PENDING', NULL, NOW() - INTERVAL 2 HOUR),
(3, 28, 'PAY202410010003', 20.00, 'WALLET', 'PENDING', NULL, NOW() - INTERVAL 4 HOUR);

-- 13. 更新用户钱包余额（扣除支付金额）
UPDATE user_wallet SET
    balance = balance - 195.00,
    total_consume = 195.00
WHERE user_id = 2;

UPDATE user_wallet SET
    balance = balance - 154.00,
    total_consume = 154.00
WHERE user_id = 3;

UPDATE user_wallet SET
    balance = balance - 138.00,
    total_consume = 138.00
WHERE user_id = 4;

UPDATE user_wallet SET
    balance = balance - 121.00,
    total_consume = 121.00
WHERE user_id = 5;

-- 14. 插入更多充值记录
INSERT INTO recharge_record (user_id, order_no, amount, bonus_amount, payment_method, payment_status, third_party_order_no, created_time) VALUES
-- 成功的充值
(2, 'RCH202409010001', 50.00, 5.00, 'WECHAT', 'SUCCESS', 'WX2024090112345678901', DATE_SUB(NOW(), INTERVAL 30 DAY)),
(3, 'RCH202409050001', 100.00, 10.00, 'ALIPAY', 'SUCCESS', 'ALI2024090512345678901', DATE_SUB(NOW(), INTERVAL 26 DAY)),
(4, 'RCH202409100001', 50.00, 5.00, 'WECHAT', 'SUCCESS', 'WX2024091012345678901', DATE_SUB(NOW(), INTERVAL 21 DAY)),
(5, 'RCH202409120001', 30.00, 2.00, 'ALIPAY', 'SUCCESS', 'ALI2024091212345678901', DATE_SUB(NOW(), INTERVAL 19 DAY)),
(2, 'RCH202409200001', 100.00, 10.00, 'WECHAT', 'SUCCESS', 'WX2024092012345678901', DATE_SUB(NOW(), INTERVAL 11 DAY)),
(3, 'RCH202409220001', 50.00, 5.00, 'ALIPAY', 'SUCCESS', 'ALI2024092212345678901', DATE_SUB(NOW(), INTERVAL 9 DAY)),
(4, 'RCH202409250001', 100.00, 10.00, 'WECHAT', 'SUCCESS', 'WX2024092512345678901', DATE_SUB(NOW(), INTERVAL 6 DAY)),
(5, 'RCH202409270001', 50.00, 5.00, 'ALIPAY', 'SUCCESS', 'ALI2024092712345678901', DATE_SUB(NOW(), INTERVAL 4 DAY)),
-- 待处理的充值
(2, 'RCH202409300001', 50.00, 5.00, 'WECHAT', 'PENDING', 'WX2024093012345678901', NOW() - INTERVAL 2 HOUR),
-- 失败的充值
(3, 'RCH202409280001', 100.00, 10.00, 'ALIPAY', 'FAILED', 'ALI2024092812345678901', DATE_SUB(NOW(), INTERVAL 3 DAY));

-- 15. 插入意见反馈
INSERT INTO feedback (user_id, type, content, reply, status, replied_time, replied_by, created_time) VALUES
(2, 'SUGGESTION', '希望能增加座位预约时间的灵活性，比如可以按半小时预约', '感谢您的建议，我们会在下一版本中考虑增加更灵活的时间选择功能', 'REPLIED', DATE_SUB(NOW(), INTERVAL 5 DAY), 1, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(3, 'BUG', '有时候签到按钮点击没有反应，需要刷新页面', '感谢反馈，我们已经修复了这个问题，请更新到最新版本', 'REPLIED', DATE_SUB(NOW(), INTERVAL 3 DAY), 1, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(4, 'SUGGESTION', '建议增加座位环境照片，方便选择', '好的建议，我们正在收集各座位的实景照片', 'REPLIED', DATE_SUB(NOW(), INTERVAL 2 DAY), 1, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(5, 'COMPLAINT', 'A025座位的电源插座有问题，无法正常使用', '非常抱歉给您带来不便，我们已经安排维修人员处理', 'REPLIED', DATE_SUB(NOW(), INTERVAL 1 DAY), 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(2, 'SUGGESTION', '希望能增加学习时长统计功能', NULL, 'PENDING', NULL, NULL, NOW() - INTERVAL 1 DAY),
(3, 'OTHER', '系统整体体验很好，希望能继续优化', NULL, 'PENDING', NULL, NULL, NOW() - INTERVAL 12 HOUR);

-- 16. 插入通知记录
INSERT INTO notification (user_id, title, content, type, is_read, read_time, created_time) VALUES
-- 预约相关通知
(2, '预约成功', '您已成功预约座位A004，时间：' || CURDATE() || ' 09:00-13:00，请准时到达', 'RESERVATION', TRUE, NOW() - INTERVAL 4 HOUR, NOW() - INTERVAL 5 HOUR),
(3, '预约成功', '您已成功预约座位A007，时间：' || CURDATE() || ' 10:00-14:00，请准时到达', 'RESERVATION', TRUE, NOW() - INTERVAL 3 HOUR, NOW() - INTERVAL 4 HOUR),
(4, '签到提醒', '您的预约即将开始，座位：A014，时间：08:00-12:00，请尽快签到', 'RESERVATION', TRUE, NOW() - INTERVAL 5 HOUR, NOW() - INTERVAL 5 HOUR + INTERVAL 30 MINUTE),
(5, '预约成功', '您已成功预约座位A019，时间：' || CURDATE() || ' 14:00-18:00，请准时到达', 'RESERVATION', FALSE, NULL, NOW() - INTERVAL 2 HOUR),
(2, '预约成功', '您已成功预约座位A024，时间：' || CURDATE() || ' 15:00-20:00，请准时到达', 'RESERVATION', FALSE, NULL, NOW() - INTERVAL 1 HOUR),
-- 系统通知
(2, '系统维护通知', '系统将于本周日凌晨2:00-4:00进行维护升级，期间无法使用，请提前安排', 'SYSTEM', TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
(3, '系统维护通知', '系统将于本周日凌晨2:00-4:00进行维护升级，期间无法使用，请提前安排', 'SYSTEM', TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
(4, '系统维护通知', '系统将于本周日凌晨2:00-4:00进行维护升级，期间无法使用，请提前安排', 'SYSTEM', FALSE, NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(5, '系统维护通知', '系统将于本周日凌晨2:00-4:00进行维护升级，期间无法使用，请提前安排', 'SYSTEM', FALSE, NULL, DATE_SUB(NOW(), INTERVAL 3 DAY)),
-- 公告通知
(2, '新公告发布', '自习室座位预约系统正式上线', 'ANNOUNCEMENT', TRUE, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY)),
(3, '新公告发布', '自习室座位预约系统正式上线', 'ANNOUNCEMENT', TRUE, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY)),
(4, '新公告发布', '自习室座位预约系统正式上线', 'ANNOUNCEMENT', TRUE, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY)),
(5, '新公告发布', '自习室座位预约系统正式上线', 'ANNOUNCEMENT', FALSE, NULL, DATE_SUB(NOW(), INTERVAL 6 DAY));

-- 17. 插入操作日志
INSERT INTO operation_log (user_id, operation_type, operation_desc, request_method, request_url, ip_address, created_time) VALUES
(1, 'LOGIN', '管理员登录系统', 'POST', '/auth/login', '192.168.1.100', NOW() - INTERVAL 2 HOUR),
(1, 'CREATE', '创建公告：自习室座位预约系统正式上线', 'POST', '/announcement/admin/create', '192.168.1.100', DATE_SUB(NOW(), INTERVAL 6 DAY)),
(1, 'UPDATE', '更新系统设置', 'PUT', '/settings/update', '192.168.1.100', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(2, 'LOGIN', '用户登录系统', 'POST', '/auth/login', '192.168.1.101', NOW() - INTERVAL 5 HOUR),
(2, 'CREATE', '创建预约记录', 'POST', '/reservation/create', '192.168.1.101', NOW() - INTERVAL 5 HOUR),
(2, 'CHECKIN', '签到：座位A004', 'POST', '/reservation/checkin', '192.168.1.101', NOW() - INTERVAL 4 HOUR),
(3, 'LOGIN', '用户登录系统', 'POST', '/auth/login', '192.168.1.102', NOW() - INTERVAL 4 HOUR),
(3, 'CREATE', '创建预约记录', 'POST', '/reservation/create', '192.168.1.102', NOW() - INTERVAL 4 HOUR),
(3, 'CHECKIN', '签到：座位A007', 'POST', '/reservation/checkin', '192.168.1.102', NOW() - INTERVAL 3 HOUR),
(4, 'LOGIN', '用户登录系统', 'POST', '/auth/login', '192.168.1.103', NOW() - INTERVAL 6 HOUR),
(4, 'CREATE', '创建预约记录', 'POST', '/reservation/create', '192.168.1.103', NOW() - INTERVAL 5 HOUR),
(4, 'CHECKIN', '签到：座位A014', 'POST', '/reservation/checkin', '192.168.1.103', NOW() - INTERVAL 5 HOUR),
(4, 'CHECKOUT', '签退：座位A014', 'POST', '/reservation/checkout', '192.168.1.103', NOW() - INTERVAL 30 MINUTE),
(5, 'LOGIN', '用户登录系统', 'POST', '/auth/login', '192.168.1.104', NOW() - INTERVAL 2 HOUR),
(5, 'CREATE', '创建预约记录', 'POST', '/reservation/create', '192.168.1.104', NOW() - INTERVAL 2 HOUR);

-- ========================================
-- 第七部分：统计视图和报表功能
-- ========================================

-- 1. 创建每日统计视图
CREATE OR REPLACE VIEW daily_statistics AS
SELECT
    DATE(r.created_time) as stat_date,
    COUNT(DISTINCT r.id) as total_reservations,
    COUNT(DISTINCT CASE WHEN r.status = 'COMPLETED' THEN r.id END) as completed_count,
    COUNT(DISTINCT CASE WHEN r.status = 'CANCELLED' THEN r.id END) as cancelled_count,
    COUNT(DISTINCT CASE WHEN r.status = 'EXPIRED' THEN r.id END) as expired_count,
    COUNT(DISTINCT r.user_id) as active_users,
    COALESCE(SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN p.amount ELSE 0 END), 0) as total_revenue,
    COALESCE(AVG(CASE WHEN r.status = 'COMPLETED' THEN
        TIMESTAMPDIFF(MINUTE, r.check_in_time, r.check_out_time) / 60.0
    END), 0) as avg_usage_hours
FROM reservation r
LEFT JOIN payment_record p ON r.id = p.reservation_id
GROUP BY DATE(r.created_time)
ORDER BY stat_date DESC;

-- 2. 创建座位使用率统计视图
CREATE OR REPLACE VIEW seat_utilization AS
SELECT
    s.id as seat_id,
    s.seat_number,
    s.area,
    st.type_name,
    COUNT(DISTINCT r.id) as total_bookings,
    COUNT(DISTINCT CASE WHEN r.status = 'COMPLETED' THEN r.id END) as completed_bookings,
    COALESCE(SUM(CASE WHEN r.status = 'COMPLETED' THEN
        TIMESTAMPDIFF(MINUTE, r.check_in_time, r.check_out_time) / 60.0
    END), 0) as total_usage_hours,
    ROUND(COUNT(DISTINCT CASE WHEN r.status = 'COMPLETED' THEN r.id END) * 100.0 /
        NULLIF(COUNT(DISTINCT r.id), 0), 2) as completion_rate
FROM seat s
LEFT JOIN seat_type st ON s.seat_type_id = st.id
LEFT JOIN reservation r ON s.id = r.seat_id
GROUP BY s.id, s.seat_number, s.area, st.type_name
ORDER BY total_bookings DESC;

-- 3. 创建用户活跃度统计视图
CREATE OR REPLACE VIEW user_activity AS
SELECT
    u.id as user_id,
    u.username,
    u.real_name,
    COUNT(DISTINCT r.id) as total_reservations,
    COUNT(DISTINCT CASE WHEN r.status = 'COMPLETED' THEN r.id END) as completed_reservations,
    COUNT(DISTINCT CASE WHEN r.status = 'CANCELLED' THEN r.id END) as cancelled_reservations,
    COALESCE(SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN p.amount ELSE 0 END), 0) as total_spending,
    COALESCE(w.balance, 0) as current_balance,
    COALESCE(w.total_recharge, 0) as total_recharge,
    MAX(r.created_time) as last_reservation_time
FROM sys_user u
LEFT JOIN reservation r ON u.id = r.user_id
LEFT JOIN payment_record p ON r.id = p.reservation_id
LEFT JOIN user_wallet w ON u.id = w.user_id
WHERE u.role = 'STUDENT'
GROUP BY u.id, u.username, u.real_name, w.balance, w.total_recharge
ORDER BY total_reservations DESC;

-- 4. 创建收入统计视图
CREATE OR REPLACE VIEW revenue_statistics AS
SELECT
    DATE(p.created_time) as revenue_date,
    COUNT(DISTINCT p.id) as payment_count,
    SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN p.amount ELSE 0 END) as daily_revenue,
    SUM(CASE WHEN p.payment_method = 'WALLET' AND p.payment_status = 'SUCCESS' THEN p.amount ELSE 0 END) as wallet_revenue,
    SUM(CASE WHEN p.payment_method = 'WECHAT' AND p.payment_status = 'SUCCESS' THEN p.amount ELSE 0 END) as wechat_revenue,
    SUM(CASE WHEN p.payment_method = 'ALIPAY' AND p.payment_status = 'SUCCESS' THEN p.amount ELSE 0 END) as alipay_revenue,
    COUNT(DISTINCT p.user_id) as paying_users
FROM payment_record p
GROUP BY DATE(p.created_time)
ORDER BY revenue_date DESC;

-- 5. 创建时段热度统计视图
CREATE OR REPLACE VIEW time_slot_popularity AS
SELECT
    HOUR(r.start_time) as hour_slot,
    COUNT(DISTINCT r.id) as booking_count,
    COUNT(DISTINCT CASE WHEN r.status = 'COMPLETED' THEN r.id END) as completed_count,
    ROUND(AVG(CASE WHEN r.status = 'COMPLETED' THEN
        TIMESTAMPDIFF(MINUTE, r.check_in_time, r.check_out_time) / 60.0
    END), 2) as avg_duration_hours
FROM reservation r
GROUP BY HOUR(r.start_time)
ORDER BY hour_slot;

-- ========================================
-- 第八部分：数据验证和总结
-- ========================================

-- 显示数据初始化统计
SELECT
    '数据初始化完成' as status,
    (SELECT COUNT(*) FROM sys_user) as user_count,
    (SELECT COUNT(*) FROM seat_type) as seat_type_count,
    (SELECT COUNT(*) FROM seat) as seat_count,
    (SELECT COUNT(*) FROM reservation) as reservation_count,
    (SELECT COUNT(*) FROM payment_record) as payment_count,
    (SELECT COUNT(*) FROM recharge_record) as recharge_count,
    (SELECT COUNT(*) FROM user_wallet) as wallet_count,
    (SELECT COUNT(*) FROM sys_announcement) as announcement_count,
    (SELECT COUNT(*) FROM system_settings) as settings_count,
    (SELECT COUNT(*) FROM seat_favorite) as favorite_count,
    (SELECT COUNT(*) FROM feedback) as feedback_count,
    (SELECT COUNT(*) FROM notification) as notification_count,
    (SELECT COUNT(*) FROM operation_log) as log_count,
    (SELECT COUNT(*) FROM study_room) as study_room_count;

-- 显示统计视图
SELECT '=== 最近7天每日统计 ===' as info;
SELECT * FROM daily_statistics WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) ORDER BY stat_date;

SELECT '=== 热门座位TOP10 ===' as info;
SELECT * FROM seat_utilization WHERE total_bookings > 0 LIMIT 10;

SELECT '=== 用户活跃度 ===' as info;
SELECT * FROM user_activity ORDER BY total_reservations DESC;

SELECT '=== 收入统计（最近7天） ===' as info;
SELECT * FROM revenue_statistics WHERE revenue_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) ORDER BY revenue_date;

SELECT '=== 时段热度统计 ===' as info;
SELECT
    CONCAT(hour_slot, ':00-', hour_slot+1, ':00') as time_range,
    booking_count,
    completed_count,
    avg_duration_hours
FROM time_slot_popularity
WHERE booking_count > 0
ORDER BY hour_slot;

-- 显示主要测试账号信息
SELECT
    username AS '用户名',
    real_name AS '姓名',
    role AS '角色',
    email AS '邮箱',
    CASE
        WHEN username = 'admin' THEN 'admin123'
        ELSE '123456'
    END AS '密码'
FROM sys_user
ORDER BY role DESC, id;

COMMIT;

-- ========================================
-- 使用说明
-- ========================================
--
-- 本脚本包含完整的自习室座位预约系统数据库：
--
-- 【核心表结构】
-- 1. sys_user           - 用户表（学生和管理员）
-- 2. seat_type          - 座位类型表（普通/靠窗/包间/电脑）
-- 3. seat               - 座位表（60个座位：A区30个 + B区30个）
-- 4. reservation        - 预约表
-- 5. sys_config         - 系统配置表
-- 6. operation_log      - 操作日志表
--
-- 【支付系统】
-- 7. user_wallet        - 用户钱包表
-- 8. recharge_record    - 充值记录表
-- 9. payment_record     - 支付记录表
--
-- 【扩展功能】
-- 10. seat_favorite     - 座位收藏表
-- 11. sys_announcement  - 系统公告表
-- 12. system_settings   - 系统设置表
-- 13. study_room        - 自习室表
-- 14. feedback          - 意见反馈表
-- 15. notification      - 消息通知表
--
-- 【测试账号】
-- 管理员：admin / admin123
-- 学生1：student001 / 123456
-- 学生2：student002 / 123456
-- 学生3：student003 / 123456
-- 学生4：student004 / 123456
-- 学生5：student005 / 123456
--
-- 【测试数据】（覆盖近30天的完整业务场景）
-- - 4种座位类型
-- - 60个座位（2楼A区和B区）
-- - 6个用户（1个管理员 + 5个学生）
-- - 40+条预约记录（包含各种状态：已完成、使用中、已预约、已取消、已过期）
-- - 28条支付记录（钱包、微信、支付宝多种支付方式）
-- - 13条充值记录（成功、待处理、失败多种状态）
-- - 所有用户都有钱包账户及交易记录
-- - 5条座位收藏记录
-- - 3条系统公告
-- - 6条意见反馈（包含建议、BUG、投诉等）
-- - 13条通知记录（预约、系统、公告等类型）
-- - 14条操作日志
-- - 完整的系统设置配置（6大类40+项配置）
-- - 3个自习室信息
--
-- 【统计视图】（用于报表和数据分析）
-- - daily_statistics      : 每日统计（预约数、收入、活跃用户等）
-- - seat_utilization      : 座位使用率统计（预订次数、完成率等）
-- - user_activity         : 用户活跃度统计（预约次数、消费金额等）
-- - revenue_statistics    : 收入统计（按日期、支付方式分组）
-- - time_slot_popularity  : 时段热度统计（各时段预约情况）
--
-- 【导入方法】
-- Windows CMD:
--   cd /d C:\path\to\database
--   mysql -u root -p < init_database.sql
--
-- Mac/Linux Terminal:
--   cd /path/to/database
--   mysql -u root -p < init_database.sql
--
-- 或在MySQL命令行中：
--   SOURCE /path/to/init_database.sql;
--
-- 【统计视图使用示例】
-- 1. 查询最近7天的预约和收入趋势：
--    SELECT * FROM daily_statistics WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);
--
-- 2. 查询最受欢迎的座位TOP10：
--    SELECT * FROM seat_utilization ORDER BY total_bookings DESC LIMIT 10;
--
-- 3. 查询最活跃用户TOP5：
--    SELECT * FROM user_activity ORDER BY total_reservations DESC LIMIT 5;
--
-- 4. 查询本月总收入：
--    SELECT SUM(daily_revenue) as monthly_revenue FROM revenue_statistics
--    WHERE revenue_date >= DATE_FORMAT(NOW(), '%Y-%m-01');
--
-- 5. 查询最热门的预约时段：
--    SELECT * FROM time_slot_popularity ORDER BY booking_count DESC LIMIT 5;
--
-- 【修复脚本】
-- 如遇到问题，可使用以下修复脚本：
-- - fix_admin_password.sql       : 修复管理员密码
-- - fix_announcement_priority.sql: 修复公告优先级字段类型
--
-- ========================================