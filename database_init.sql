-- 自习室座位预约系统数据库初始化脚本
-- 创建数据库
DROP DATABASE IF EXISTS seat_reservation;
CREATE DATABASE seat_reservation CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE seat_reservation;

-- 1. 用户表
CREATE TABLE sys_user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码(加密)',
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

-- 插入初始数据

-- 插入座位类型
INSERT INTO seat_type (type_name, description, hourly_rate) VALUES 
('普通座位', '基础学习座位', 0.00),
('靠窗座位', '采光良好的靠窗座位', 1.00),
('独立包间', '安静的独立学习包间', 3.00),
('电脑座位', '配备电脑的学习座位', 2.00);

-- 插入管理员账号 (密码: admin123)
INSERT INTO sys_user (username, password, real_name, phone, email, role) VALUES 
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEIUi', '系统管理员', '13800138000', 'admin@example.com', 'ADMIN');

-- 插入测试学生账号 (密码: 123456)
INSERT INTO sys_user (username, password, real_name, phone, email, student_id, role) VALUES 
('student001', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '张三', '13900139001', 'zhangsan@example.com', '2021001001', 'STUDENT'),
('student002', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', '李四', '13900139002', 'lisi@example.com', '2021001002', 'STUDENT');

-- 插入座位数据 (模拟2楼A区30个座位)
INSERT INTO seat (seat_number, floor_number, area, seat_type_id, position_x, position_y, has_power, has_computer) VALUES
-- 第一排 (1-10号)
('A001', 2, 'A区', 1, 50, 50, TRUE, FALSE),
('A002', 2, 'A区', 1, 100, 50, TRUE, FALSE),
('A003', 2, 'A区', 2, 150, 50, TRUE, FALSE), -- 靠窗
('A004', 2, 'A区', 1, 200, 50, TRUE, FALSE),
('A005', 2, 'A区', 4, 250, 50, TRUE, TRUE),  -- 电脑座位
('A006', 2, 'A区', 1, 300, 50, TRUE, FALSE),
('A007', 2, 'A区', 1, 350, 50, TRUE, FALSE),
('A008', 2, 'A区', 2, 400, 50, TRUE, FALSE), -- 靠窗
('A009', 2, 'A区', 1, 450, 50, TRUE, FALSE),
('A010', 2, 'A区', 1, 500, 50, TRUE, FALSE),

-- 第二排 (11-20号)
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

-- 第三排 (21-30号)
('A021', 2, 'A区', 1, 50, 250, TRUE, FALSE),
('A022', 2, 'A区', 1, 100, 250, TRUE, FALSE),
('A023', 2, 'A区', 2, 150, 250, TRUE, FALSE), -- 靠窗
('A024', 2, 'A区', 1, 200, 250, TRUE, FALSE),
('A025', 2, 'A区', 3, 250, 250, TRUE, FALSE), -- 独立包间
('A026', 2, 'A区', 3, 300, 250, TRUE, FALSE), -- 独立包间
('A027', 2, 'A区', 1, 350, 250, TRUE, FALSE),
('A028', 2, 'A区', 2, 400, 250, TRUE, FALSE), -- 靠窗
('A029', 2, 'A区', 1, 450, 250, TRUE, FALSE),
('A030', 2, 'A区', 1, 500, 250, TRUE, FALSE);

-- 插入系统配置
INSERT INTO sys_config (config_key, config_value, config_desc) VALUES
('system.reservation.max_hours', '8', '单次预约最大小时数'),
('system.reservation.advance_days', '7', '最多提前预约天数'),
('system.reservation.cancel_hours', '2', '预约前多少小时可以取消'),
('system.open_time', '08:00', '自习室开放时间'),
('system.close_time', '22:00', '自习室关闭时间'),
('system.name', '智慧自习室座位预约系统', '系统名称');

-- 创建索引优化查询性能
CREATE INDEX idx_user_username ON sys_user(username);
CREATE INDEX idx_user_student_id ON sys_user(student_id);
CREATE INDEX idx_seat_number ON seat(seat_number);
CREATE INDEX idx_seat_floor_area ON seat(floor_number, area);
CREATE INDEX idx_reservation_user ON reservation(user_id);
CREATE INDEX idx_reservation_seat ON reservation(seat_id);
CREATE INDEX idx_reservation_date ON reservation(reservation_date);
CREATE INDEX idx_reservation_status ON reservation(status);
CREATE INDEX idx_operation_log_user ON operation_log(user_id);
CREATE INDEX idx_operation_log_time ON operation_log(created_time);

COMMIT;