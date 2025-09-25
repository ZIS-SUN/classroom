-- ========================================
-- 自习室座位预约系统 - 完整数据库初始化脚本
-- 版本：1.0
-- 包含所有表结构、外键关系、索引和基础数据
-- ========================================

-- 创建数据库
DROP DATABASE IF EXISTS seat_reservation;
CREATE DATABASE seat_reservation CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE seat_reservation;

-- ========================================
-- 表结构创建
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
    priority INT NOT NULL DEFAULT 2 COMMENT '优先级：1-低, 2-中, 3-高',
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

-- ========================================
-- 创建索引优化查询性能
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

-- 支付相关索引
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

-- ========================================
-- 基础数据插入
-- ========================================

-- 1. 插入座位类型数据
INSERT INTO seat_type (type_name, description, hourly_rate) VALUES
('普通座位', '基础学习座位', 0.00),
('靠窗座位', '采光良好的靠窗座位', 1.00),
('独立包间', '安静的独立学习包间', 3.00),
('电脑座位', '配备电脑的学习座位', 2.00);

-- 2. 插入管理员和测试用户（密码使用BCrypt加密）
-- 管理员密码: admin123
INSERT INTO sys_user (username, password, real_name, phone, email, role) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEIUi', '系统管理员', '13800138000', 'admin@example.com', 'ADMIN');

-- 测试学生账号密码: 123456
INSERT INTO sys_user (username, password, real_name, phone, email, student_id, role) VALUES
('student001', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '张三', '13900139001', 'zhangsan@example.com', '2021001001', 'STUDENT'),
('student002', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '李四', '13900139002', 'lisi@example.com', '2021001002', 'STUDENT'),
('student003', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '王五', '13900139003', 'wangwu@example.com', '2021001003', 'STUDENT'),
('student004', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '赵六', '13900139004', 'zhaoliu@example.com', '2021001004', 'STUDENT'),
('student005', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '钱七', '13900139005', 'qianqi@example.com', '2021001005', 'STUDENT');

-- 3. 插入座位数据（2楼A区和B区共60个座位）
-- A区座位 (1-30)
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

-- B区座位 (31-60)
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
('自习室座位预约系统正式上线', '亲爱的同学们，自习室座位预约系统已正式上线运行。大家可以通过系统提前预约座位，避免到馆后无座位的困扰。请合理使用预约功能，共同维护良好的学习环境。', 'ANNOUNCEMENT', 'PUBLISHED', 1, '系统管理员', 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 0),
('预约座位使用须知', '请各位同学注意：\n1. 预约后请按时到达，超过30分钟未签到将自动取消预约\n2. 离开座位超过2小时请记得签退\n3. 保持座位整洁，文明用座\n4. 如需取消预约，请提前在系统中操作', 'NOTICE', 'PUBLISHED', 1, '系统管理员', 2, NOW(), NULL, 0),
('系统功能介绍', '系统主要功能包括：\n- 实时座位状态查看\n- 在线座位预约\n- 钱包充值和支付\n- 座位收藏功能\n- 预约历史查询\n- 个人资料管理\n请大家充分利用这些功能，提高学习效率！', 'NOTICE', 'PUBLISHED', 1, '系统管理员', 1, NOW(), NULL, 0);

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

-- 8. 插入一些测试座位收藏
INSERT INTO seat_favorite (user_id, seat_id, favorite_name) VALUES
(2, 3, '我的靠窗位置'),
(2, 5, '常用电脑座位'),
(3, 25, '安静包间'),
(4, 8, '靠窗学习位'),
(5, 15, '电脑编程位');

-- ========================================
-- 数据完整性检查和总结
-- ========================================

-- 验证数据插入
SELECT
    '数据初始化完成' as status,
    (SELECT COUNT(*) FROM sys_user) as user_count,
    (SELECT COUNT(*) FROM seat_type) as seat_type_count,
    (SELECT COUNT(*) FROM seat) as seat_count,
    (SELECT COUNT(*) FROM user_wallet) as wallet_count,
    (SELECT COUNT(*) FROM sys_announcement) as announcement_count,
    (SELECT COUNT(*) FROM system_settings) as settings_count,
    (SELECT COUNT(*) FROM seat_favorite) as favorite_count;

-- 显示主要账号信息
SELECT
    username,
    real_name,
    role,
    email,
    '密码见注释' as password_hint
FROM sys_user
ORDER BY role DESC, id;

COMMIT;

-- ========================================
-- 使用说明
-- ========================================
--
-- 本脚本包含完整的自习室座位预约系统数据库结构：
--
-- 1. 12个核心数据表，包含完整的外键关系
-- 2. 优化的数据库索引，提高查询性能
-- 3. 基础测试数据：
--    - 管理员账号: admin / admin123
--    - 学生账号: student001-005 / 123456
--    - 60个座位（A区30个 + B区30个）
--    - 4种座位类型（普通/靠窗/包间/电脑）
--    - 用户钱包和收藏数据
--    - 系统配置和公告
--
-- 4. 支持的功能：
--    - 用户认证和权限管理
--    - 座位预约和管理
--    - 支付和钱包系统
--    - 座位收藏功能
--    - 系统公告和设置
--    - 操作日志记录
--
-- 导入方法：
-- mysql -u root -p < complete_database_init.sql
--
-- ========================================