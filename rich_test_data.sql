-- 丰富的测试数据
-- 清除现有数据
DELETE FROM reservation WHERE id > 0;
DELETE FROM seat_favorite WHERE id > 0;
DELETE FROM payment_record WHERE id > 0;
DELETE FROM recharge_record WHERE id > 0;
DELETE FROM announcement WHERE id > 0;
DELETE FROM seat WHERE id > 0;
DELETE FROM seat_type WHERE id > 0;
DELETE FROM user WHERE id > 1; -- 保留admin用户

-- 重置自增ID
ALTER TABLE user AUTO_INCREMENT = 2;
ALTER TABLE seat_type AUTO_INCREMENT = 1;
ALTER TABLE seat AUTO_INCREMENT = 1;
ALTER TABLE reservation AUTO_INCREMENT = 1;
ALTER TABLE seat_favorite AUTO_INCREMENT = 1;
ALTER TABLE payment_record AUTO_INCREMENT = 1;
ALTER TABLE recharge_record AUTO_INCREMENT = 1;
ALTER TABLE announcement AUTO_INCREMENT = 1;

-- 插入座位类型
INSERT INTO seat_type (type_name, hourly_rate, description) VALUES
('普通座位', 2.00, '基础座位，适合一般学习'),
('靠窗座位', 3.00, '靠窗位置，采光好，视野开阔'),
('电脑座位', 5.00, '配备电脑的座位，适合编程学习'),
('包间座位', 8.00, '独立包间，安静私密'),
('沙发座位', 4.00, '舒适沙发座位，适合长时间学习'),
('讨论座位', 6.00, '适合小组讨论的座位区域');

-- 插入大量用户数据
INSERT INTO user (username, password, real_name, student_id, phone, email, role, status, balance, created_time, updated_time) VALUES
-- 学生用户
('zhangsan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '张三', '2021001', '13800138001', 'zhangsan@student.edu.cn', 'STUDENT', 'ACTIVE', 50.00, NOW() - INTERVAL 30 DAY, NOW()),
('lisi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '李四', '2021002', '13800138002', 'lisi@student.edu.cn', 'STUDENT', 'ACTIVE', 75.50, NOW() - INTERVAL 28 DAY, NOW()),
('wangwu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '王五', '2021003', '13800138003', 'wangwu@student.edu.cn', 'STUDENT', 'ACTIVE', 120.00, NOW() - INTERVAL 25 DAY, NOW()),
('zhaoliu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '赵六', '2021004', '13800138004', 'zhaoliu@student.edu.cn', 'STUDENT', 'ACTIVE', 88.25, NOW() - INTERVAL 22 DAY, NOW()),
('sunqi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '孙七', '2021005', '13800138005', 'sunqi@student.edu.cn', 'STUDENT', 'ACTIVE', 95.75, NOW() - INTERVAL 20 DAY, NOW()),
('zhouba', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '周八', '2021006', '13800138006', 'zhouba@student.edu.cn', 'STUDENT', 'ACTIVE', 65.00, NOW() - INTERVAL 18 DAY, NOW()),
('wujiu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '吴九', '2021007', '13800138007', 'wujiu@student.edu.cn', 'STUDENT', 'ACTIVE', 110.50, NOW() - INTERVAL 15 DAY, NOW()),
('zhengshi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '郑十', '2021008', '13800138008', 'zhengshi@student.edu.cn', 'STUDENT', 'ACTIVE', 42.25, NOW() - INTERVAL 12 DAY, NOW()),
('chenyuan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '陈远', '2021009', '13800138009', 'chenyuan@student.edu.cn', 'STUDENT', 'ACTIVE', 78.00, NOW() - INTERVAL 10 DAY, NOW()),
('liufang', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '刘芳', '2021010', '13800138010', 'liufang@student.edu.cn', 'STUDENT', 'ACTIVE', 135.75, NOW() - INTERVAL 8 DAY, NOW()),
('yangming', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '杨明', '2021011', '13800138011', 'yangming@student.edu.cn', 'STUDENT', 'ACTIVE', 56.50, NOW() - INTERVAL 6 DAY, NOW()),
('huangli', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '黄丽', '2021012', '13800138012', 'huangli@student.edu.cn', 'STUDENT', 'ACTIVE', 92.00, NOW() - INTERVAL 5 DAY, NOW()),
('xuwei', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '徐伟', '2021013', '13800138013', 'xuwei@student.edu.cn', 'STUDENT', 'ACTIVE', 67.25, NOW() - INTERVAL 4 DAY, NOW()),
('linjun', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '林军', '2021014', '13800138014', 'linjun@student.edu.cn', 'STUDENT', 'ACTIVE', 83.75, NOW() - INTERVAL 3 DAY, NOW()),
('gaohong', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '高红', '2021015', '13800138015', 'gaohong@student.edu.cn', 'STUDENT', 'ACTIVE', 101.50, NOW() - INTERVAL 2 DAY, NOW()),
('dingqiang', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '丁强', '2021016', '13800138016', 'dingqiang@student.edu.cn', 'STUDENT', 'ACTIVE', 74.00, NOW() - INTERVAL 1 DAY, NOW()),
('songhua', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '宋华', '2021017', '13800138017', 'songhua@student.edu.cn', 'STUDENT', 'ACTIVE', 89.25, NOW(), NOW()),
('tangjie', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '唐杰', '2021018', '13800138018', 'tangjie@student.edu.cn', 'STUDENT', 'ACTIVE', 55.75, NOW(), NOW()),
-- 研究生用户
('fenglei', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '冯磊', '2022G001', '13800138019', 'fenglei@grad.edu.cn', 'STUDENT', 'ACTIVE', 150.00, NOW() - INTERVAL 15 DAY, NOW()),
('hemin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '何敏', '2022G002', '13800138020', 'hemin@grad.edu.cn', 'STUDENT', 'ACTIVE', 180.50, NOW() - INTERVAL 12 DAY, NOW()),
-- 几个禁用用户
('disabled1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '违规用户1', '2020999', '13800138099', 'disabled1@student.edu.cn', 'STUDENT', 'DISABLED', 0.00, NOW() - INTERVAL 60 DAY, NOW()),
('disabled2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyqZRaD3oNKMNlmKDa4qFXsZu0i', '违规用户2', '2020998', '13800138098', 'disabled2@student.edu.cn', 'STUDENT', 'DISABLED', 0.00, NOW() - INTERVAL 45 DAY, NOW());

-- 插入座位数据（3个楼层，每层3个区域）
INSERT INTO seat (seat_number, floor_number, area, seat_type_id, position_x, position_y, status, has_power, has_computer, description, created_time, updated_time) VALUES
-- 1楼A区 (普通座位为主)
('A101', 1, 'A区', 1, 1, 1, 'AVAILABLE', 1, 0, '1楼A区第1排第1座', NOW(), NOW()),
('A102', 1, 'A区', 1, 1, 2, 'AVAILABLE', 1, 0, '1楼A区第1排第2座', NOW(), NOW()),
('A103', 1, 'A区', 2, 1, 3, 'AVAILABLE', 1, 0, '1楼A区第1排第3座，靠窗', NOW(), NOW()),
('A104', 1, 'A区', 1, 1, 4, 'OCCUPIED', 1, 0, '1楼A区第1排第4座', NOW(), NOW()),
('A105', 1, 'A区', 1, 1, 5, 'AVAILABLE', 1, 0, '1楼A区第1排第5座', NOW(), NOW()),
('A201', 1, 'A区', 1, 2, 1, 'AVAILABLE', 1, 0, '1楼A区第2排第1座', NOW(), NOW()),
('A202', 1, 'A区', 2, 2, 2, 'OCCUPIED', 1, 0, '1楼A区第2排第2座，靠窗', NOW(), NOW()),
('A203', 1, 'A区', 1, 2, 3, 'AVAILABLE', 1, 0, '1楼A区第2排第3座', NOW(), NOW()),
('A204', 1, 'A区', 1, 2, 4, 'AVAILABLE', 1, 0, '1楼A区第2排第4座', NOW(), NOW()),
('A205', 1, 'A区', 2, 2, 5, 'AVAILABLE', 1, 0, '1楼A区第2排第5座，靠窗', NOW(), NOW()),

-- 1楼B区 (电脑座位为主)
('B101', 1, 'B区', 3, 1, 1, 'AVAILABLE', 1, 1, '1楼B区电脑座位1', NOW(), NOW()),
('B102', 1, 'B区', 3, 1, 2, 'OCCUPIED', 1, 1, '1楼B区电脑座位2', NOW(), NOW()),
('B103', 1, 'B区', 3, 1, 3, 'AVAILABLE', 1, 1, '1楼B区电脑座位3', NOW(), NOW()),
('B104', 1, 'B区', 3, 1, 4, 'MAINTENANCE', 1, 1, '1楼B区电脑座位4，维护中', NOW(), NOW()),
('B105', 1, 'B区', 3, 1, 5, 'AVAILABLE', 1, 1, '1楼B区电脑座位5', NOW(), NOW()),
('B201', 1, 'B区', 3, 2, 1, 'OCCUPIED', 1, 1, '1楼B区电脑座位6', NOW(), NOW()),
('B202', 1, 'B区', 3, 2, 2, 'AVAILABLE', 1, 1, '1楼B区电脑座位7', NOW(), NOW()),
('B203', 1, 'B区', 3, 2, 3, 'AVAILABLE', 1, 1, '1楼B区电脑座位8', NOW(), NOW()),

-- 1楼C区 (沙发座位)
('C101', 1, 'C区', 5, 1, 1, 'AVAILABLE', 1, 0, '1楼C区沙发座位1', NOW(), NOW()),
('C102', 1, 'C区', 5, 1, 2, 'OCCUPIED', 1, 0, '1楼C区沙发座位2', NOW(), NOW()),
('C103', 1, 'C区', 5, 1, 3, 'AVAILABLE', 1, 0, '1楼C区沙发座位3', NOW(), NOW()),
('C104', 1, 'C区', 6, 1, 4, 'AVAILABLE', 1, 0, '1楼C区讨论座位1', NOW(), NOW()),
('C105', 1, 'C区', 6, 1, 5, 'AVAILABLE', 1, 0, '1楼C区讨论座位2', NOW(), NOW()),

-- 2楼A区 (靠窗座位为主)
('A301', 2, 'A区', 2, 1, 1, 'AVAILABLE', 1, 0, '2楼A区靠窗座位1', NOW(), NOW()),
('A302', 2, 'A区', 2, 1, 2, 'OCCUPIED', 1, 0, '2楼A区靠窗座位2', NOW(), NOW()),
('A303', 2, 'A区', 2, 1, 3, 'AVAILABLE', 1, 0, '2楼A区靠窗座位3', NOW(), NOW()),
('A304', 2, 'A区', 1, 1, 4, 'AVAILABLE', 1, 0, '2楼A区普通座位1', NOW(), NOW()),
('A305', 2, 'A区', 1, 1, 5, 'AVAILABLE', 1, 0, '2楼A区普通座位2', NOW(), NOW()),
('A401', 2, 'A区', 2, 2, 1, 'AVAILABLE', 1, 0, '2楼A区靠窗座位4', NOW(), NOW()),
('A402', 2, 'A区', 2, 2, 2, 'AVAILABLE', 1, 0, '2楼A区靠窗座位5', NOW(), NOW()),
('A403', 2, 'A区', 1, 2, 3, 'OCCUPIED', 1, 0, '2楼A区普通座位3', NOW(), NOW()),

-- 2楼B区 (包间座位)
('B301', 2, 'B区', 4, 1, 1, 'AVAILABLE', 1, 1, '2楼B区包间1', NOW(), NOW()),
('B302', 2, 'B区', 4, 1, 2, 'OCCUPIED', 1, 1, '2楼B区包间2', NOW(), NOW()),
('B303', 2, 'B区', 4, 1, 3, 'AVAILABLE', 1, 1, '2楼B区包间3', NOW(), NOW()),
('B304', 2, 'B区', 4, 1, 4, 'AVAILABLE', 1, 1, '2楼B区包间4', NOW(), NOW()),

-- 2楼C区 (混合座位)
('C301', 2, 'C区', 1, 1, 1, 'AVAILABLE', 1, 0, '2楼C区普通座位1', NOW(), NOW()),
('C302', 2, 'C区', 3, 1, 2, 'OCCUPIED', 1, 1, '2楼C区电脑座位1', NOW(), NOW()),
('C303', 2, 'C区', 5, 1, 3, 'AVAILABLE', 1, 0, '2楼C区沙发座位1', NOW(), NOW()),

-- 3楼A区 (高端座位)
('A501', 3, 'A区', 4, 1, 1, 'AVAILABLE', 1, 1, '3楼A区高端包间1', NOW(), NOW()),
('A502', 3, 'A区', 4, 1, 2, 'AVAILABLE', 1, 1, '3楼A区高端包间2', NOW(), NOW()),
('A503', 3, 'A区', 4, 1, 3, 'OCCUPIED', 1, 1, '3楼A区高端包间3', NOW(), NOW()),
('A504', 3, 'A区', 2, 1, 4, 'AVAILABLE', 1, 0, '3楼A区靠窗座位1', NOW(), NOW()),
('A505', 3, 'A区', 2, 1, 5, 'AVAILABLE', 1, 0, '3楼A区靠窗座位2', NOW(), NOW()),

-- 3楼B区 (讨论区)
('B501', 3, 'B区', 6, 1, 1, 'AVAILABLE', 1, 0, '3楼B区讨论座位1', NOW(), NOW()),
('B502', 3, 'B区', 6, 1, 2, 'AVAILABLE', 1, 0, '3楼B区讨论座位2', NOW(), NOW()),
('B503', 3, 'B区', 6, 1, 3, 'OCCUPIED', 1, 0, '3楼B区讨论座位3', NOW(), NOW()),

-- 3楼C区 (VIP区)
('C501', 3, 'C区', 4, 1, 1, 'AVAILABLE', 1, 1, '3楼C区VIP包间1', NOW(), NOW()),
('C502', 3, 'C区', 4, 1, 2, 'AVAILABLE', 1, 1, '3楼C区VIP包间2', NOW(), NOW()),
-- 一些禁用座位
('A999', 1, 'A区', 1, 9, 9, 'DISABLED', 0, 0, '已禁用座位', NOW(), NOW());

-- 插入预约记录（包含各种状态）
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, total_fee, status, created_time, updated_time) VALUES
-- 今天的预约
(2, 4, CURDATE(), '09:00:00', '12:00:00', 6.00, 'USING', NOW() - INTERVAL 2 HOUR, NOW()),
(3, 12, CURDATE(), '10:00:00', '15:00:00', 25.00, 'USING', NOW() - INTERVAL 1 HOUR, NOW()),
(4, 16, CURDATE(), '14:00:00', '18:00:00', 20.00, 'RESERVED', NOW() - INTERVAL 30 MINUTE, NOW()),
(5, 20, CURDATE(), '08:00:00', '11:00:00', 12.00, 'COMPLETED', NOW() - INTERVAL 8 HOUR, NOW() - INTERVAL 5 HOUR),
(6, 24, CURDATE(), '13:00:00', '17:00:00', 12.00, 'RESERVED', NOW() - INTERVAL 15 MINUTE, NOW()),

-- 昨天的预约
(2, 1, CURDATE() - INTERVAL 1 DAY, '09:00:00', '12:00:00', 6.00, 'COMPLETED', NOW() - INTERVAL 1 DAY - INTERVAL 3 HOUR, NOW() - INTERVAL 1 DAY + INTERVAL 3 HOUR),
(3, 7, CURDATE() - INTERVAL 1 DAY, '14:00:00', '18:00:00', 12.00, 'COMPLETED', NOW() - INTERVAL 1 DAY - INTERVAL 4 HOUR, NOW() - INTERVAL 1 DAY),
(4, 11, CURDATE() - INTERVAL 1 DAY, '10:00:00', '16:00:00', 30.00, 'COMPLETED', NOW() - INTERVAL 1 DAY - INTERVAL 6 HOUR, NOW() - INTERVAL 1 DAY + INTERVAL 2 HOUR),
(5, 15, CURDATE() - INTERVAL 1 DAY, '08:00:00', '10:00:00', 4.00, 'CANCELLED', NOW() - INTERVAL 1 DAY - INTERVAL 8 HOUR, NOW() - INTERVAL 1 DAY - INTERVAL 7 HOUR),
(7, 19, CURDATE() - INTERVAL 1 DAY, '15:00:00', '19:00:00', 16.00, 'COMPLETED', NOW() - INTERVAL 1 DAY - INTERVAL 5 HOUR, NOW() - INTERVAL 1 DAY + INTERVAL 1 HOUR),

-- 前天的预约
(8, 2, CURDATE() - INTERVAL 2 DAY, '09:00:00', '13:00:00', 8.00, 'COMPLETED', NOW() - INTERVAL 2 DAY - INTERVAL 4 HOUR, NOW() - INTERVAL 2 DAY),
(9, 8, CURDATE() - INTERVAL 2 DAY, '14:00:00', '17:00:00', 15.00, 'COMPLETED', NOW() - INTERVAL 2 DAY - INTERVAL 3 HOUR, NOW() - INTERVAL 2 DAY + INTERVAL 3 HOUR),
(10, 13, CURDATE() - INTERVAL 2 DAY, '10:00:00', '12:00:00', 8.00, 'COMPLETED', NOW() - INTERVAL 2 DAY - INTERVAL 6 HOUR, NOW() - INTERVAL 2 DAY - INTERVAL 4 HOUR),

-- 本周其他日期的预约
(11, 3, CURDATE() - INTERVAL 3 DAY, '11:00:00', '15:00:00', 12.00, 'COMPLETED', NOW() - INTERVAL 3 DAY - INTERVAL 4 HOUR, NOW() - INTERVAL 3 DAY),
(12, 9, CURDATE() - INTERVAL 4 DAY, '09:00:00', '12:00:00', 15.00, 'COMPLETED', NOW() - INTERVAL 4 DAY - INTERVAL 3 HOUR, NOW() - INTERVAL 4 DAY),
(13, 17, CURDATE() - INTERVAL 5 DAY, '13:00:00', '18:00:00', 15.00, 'COMPLETED', NOW() - INTERVAL 5 DAY - INTERVAL 5 HOUR, NOW() - INTERVAL 5 DAY),
(14, 21, CURDATE() - INTERVAL 6 DAY, '08:00:00', '11:00:00', 9.00, 'COMPLETED', NOW() - INTERVAL 6 DAY - INTERVAL 3 HOUR, NOW() - INTERVAL 6 DAY),

-- 上周的一些预约
(15, 5, CURDATE() - INTERVAL 8 DAY, '10:00:00', '14:00:00', 8.00, 'COMPLETED', NOW() - INTERVAL 8 DAY - INTERVAL 4 HOUR, NOW() - INTERVAL 8 DAY),
(16, 14, CURDATE() - INTERVAL 9 DAY, '15:00:00', '19:00:00', 20.00, 'COMPLETED', NOW() - INTERVAL 9 DAY - INTERVAL 4 HOUR, NOW() - INTERVAL 9 DAY),
(17, 18, CURDATE() - INTERVAL 10 DAY, '09:00:00', '17:00:00', 40.00, 'COMPLETED', NOW() - INTERVAL 10 DAY - INTERVAL 8 HOUR, NOW() - INTERVAL 10 DAY),

-- 一些取消的预约
(18, 6, CURDATE() + INTERVAL 1 DAY, '14:00:00', '17:00:00', 9.00, 'CANCELLED', NOW() - INTERVAL 2 HOUR, NOW() - INTERVAL 1 HOUR),
(19, 10, CURDATE() - INTERVAL 1 DAY, '16:00:00', '20:00:00', 20.00, 'CANCELLED', NOW() - INTERVAL 1 DAY - INTERVAL 6 HOUR, NOW() - INTERVAL 1 DAY - INTERVAL 5 HOUR),

-- 未来的预约
(20, 22, CURDATE() + INTERVAL 1 DAY, '09:00:00', '12:00:00', 9.00, 'RESERVED', NOW(), NOW()),
(21, 25, CURDATE() + INTERVAL 1 DAY, '14:00:00', '18:00:00', 32.00, 'RESERVED', NOW(), NOW()),
(2, 26, CURDATE() + INTERVAL 2 DAY, '10:00:00', '15:00:00', 40.00, 'RESERVED', NOW(), NOW());

-- 插入座位收藏记录
INSERT INTO seat_favorite (user_id, seat_id, created_time) VALUES
(2, 1, NOW() - INTERVAL 10 DAY),
(2, 7, NOW() - INTERVAL 8 DAY),
(2, 11, NOW() - INTERVAL 5 DAY),
(3, 3, NOW() - INTERVAL 15 DAY),
(3, 12, NOW() - INTERVAL 12 DAY),
(4, 16, NOW() - INTERVAL 7 DAY),
(4, 20, NOW() - INTERVAL 3 DAY),
(5, 24, NOW() - INTERVAL 6 DAY),
(6, 2, NOW() - INTERVAL 9 DAY),
(7, 8, NOW() - INTERVAL 4 DAY),
(8, 13, NOW() - INTERVAL 11 DAY),
(9, 17, NOW() - INTERVAL 2 DAY),
(10, 21, NOW() - INTERVAL 14 DAY);

-- 插入充值记录
INSERT INTO recharge_record (user_id, amount, payment_method, transaction_id, status, created_time, updated_time) VALUES
(2, 50.00, 'ALIPAY', 'ALI202312010001', 'SUCCESS', NOW() - INTERVAL 30 DAY, NOW() - INTERVAL 30 DAY),
(3, 100.00, 'WECHAT', 'WX202312010001', 'SUCCESS', NOW() - INTERVAL 28 DAY, NOW() - INTERVAL 28 DAY),
(4, 200.00, 'ALIPAY', 'ALI202312020001', 'SUCCESS', NOW() - INTERVAL 25 DAY, NOW() - INTERVAL 25 DAY),
(5, 80.00, 'WECHAT', 'WX202312030001', 'SUCCESS', NOW() - INTERVAL 22 DAY, NOW() - INTERVAL 22 DAY),
(6, 120.00, 'ALIPAY', 'ALI202312040001', 'SUCCESS', NOW() - INTERVAL 20 DAY, NOW() - INTERVAL 20 DAY),
(7, 150.00, 'WECHAT', 'WX202312050001', 'SUCCESS', NOW() - INTERVAL 18 DAY, NOW() - INTERVAL 18 DAY),
(8, 60.00, 'ALIPAY', 'ALI202312060001', 'SUCCESS', NOW() - INTERVAL 15 DAY, NOW() - INTERVAL 15 DAY),
(9, 90.00, 'WECHAT', 'WX202312070001', 'SUCCESS', NOW() - INTERVAL 12 DAY, NOW() - INTERVAL 12 DAY),
(10, 180.00, 'ALIPAY', 'ALI202312080001', 'SUCCESS', NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 10 DAY),
(11, 70.00, 'WECHAT', 'WX202312090001', 'SUCCESS', NOW() - INTERVAL 8 DAY, NOW() - INTERVAL 8 DAY),
(12, 110.00, 'ALIPAY', 'ALI202312100001', 'SUCCESS', NOW() - INTERVAL 6 DAY, NOW() - INTERVAL 6 DAY),
(13, 85.00, 'WECHAT', 'WX202312110001', 'SUCCESS', NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 5 DAY),
(14, 95.00, 'ALIPAY', 'ALI202312120001', 'SUCCESS', NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 4 DAY),
(15, 130.00, 'WECHAT', 'WX202312130001', 'SUCCESS', NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 3 DAY),
(16, 75.00, 'ALIPAY', 'ALI202312140001', 'SUCCESS', NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 2 DAY),
(17, 100.00, 'WECHAT', 'WX202312150001', 'SUCCESS', NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 1 DAY),
(18, 65.00, 'ALIPAY', 'ALI202312160001', 'SUCCESS', NOW(), NOW());

-- 插入支付记录
INSERT INTO payment_record (user_id, reservation_id, amount, payment_method, transaction_id, status, created_time, updated_time) VALUES
(2, 1, 6.00, 'BALANCE', 'BAL202312160001', 'SUCCESS', NOW() - INTERVAL 2 HOUR, NOW() - INTERVAL 2 HOUR),
(3, 2, 25.00, 'BALANCE', 'BAL202312160002', 'SUCCESS', NOW() - INTERVAL 1 HOUR, NOW() - INTERVAL 1 HOUR),
(4, 3, 20.00, 'BALANCE', 'BAL202312160003', 'SUCCESS', NOW() - INTERVAL 30 MINUTE, NOW() - INTERVAL 30 MINUTE),
(5, 4, 12.00, 'BALANCE', 'BAL202312160004', 'SUCCESS', NOW() - INTERVAL 8 HOUR, NOW() - INTERVAL 8 HOUR),
(6, 5, 12.00, 'BALANCE', 'BAL202312160005', 'SUCCESS', NOW() - INTERVAL 15 MINUTE, NOW() - INTERVAL 15 MINUTE),
(2, 6, 6.00, 'BALANCE', 'BAL202312150001', 'SUCCESS', NOW() - INTERVAL 1 DAY - INTERVAL 3 HOUR, NOW() - INTERVAL 1 DAY - INTERVAL 3 HOUR),
(3, 7, 12.00, 'BALANCE', 'BAL202312150002', 'SUCCESS', NOW() - INTERVAL 1 DAY - INTERVAL 4 HOUR, NOW() - INTERVAL 1 DAY - INTERVAL 4 HOUR),
(4, 8, 30.00, 'BALANCE', 'BAL202312150003', 'SUCCESS', NOW() - INTERVAL 1 DAY - INTERVAL 6 HOUR, NOW() - INTERVAL 1 DAY - INTERVAL 6 HOUR),
(7, 10, 16.00, 'BALANCE', 'BAL202312150004', 'SUCCESS', NOW() - INTERVAL 1 DAY - INTERVAL 5 HOUR, NOW() - INTERVAL 1 DAY - INTERVAL 5 HOUR);

-- 插入公告数据
INSERT INTO announcement (title, content, type, priority, status, author_id, view_count, expire_time, created_time, updated_time) VALUES
('系统维护通知', '系统将于本周六凌晨2:00-4:00进行维护升级，期间可能影响正常使用，请提前做好安排。维护期间如有紧急情况，请联系管理员。', 'MAINTENANCE', 3, 'PUBLISHED', 1, 156, NOW() + INTERVAL 7 DAY, NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 2 DAY),
('新增座位类型说明', '为了更好地服务同学们，我们新增了讨论座位和沙发座位类型。讨论座位适合小组学习讨论，沙发座位更加舒适，适合长时间学习。欢迎大家体验！', 'ANNOUNCEMENT', 2, 'PUBLISHED', 1, 89, NULL, NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 5 DAY),
('座位预约规则更新', '为了提高座位使用效率，现对预约规则进行如下调整：\n1. 每人每天最多预约8小时\n2. 迟到超过30分钟自动取消预约\n3. 连续3次爽约将被暂停预约权限7天\n请大家遵守规则，共同维护良好的学习环境。', 'NOTICE', 3, 'PUBLISHED', 1, 234, NULL, NOW() - INTERVAL 7 DAY, NOW() - INTERVAL 7 DAY),
('图书馆开放时间调整', '根据学校安排，图书馆开放时间调整如下：\n周一至周五：7:00-22:00\n周六周日：8:00-21:00\n请大家注意时间安排。', 'NOTICE', 2, 'PUBLISHED', 1, 178, NOW() + INTERVAL 30 DAY, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 10 DAY),
('期末考试期间座位安排', '期末考试期间（12月25日-1月15日），为保证同学们有良好的复习环境，将增加临时座位，延长开放时间至23:00。具体安排请关注后续通知。', 'ANNOUNCEMENT', 3, 'PUBLISHED', 1, 312, NOW() + INTERVAL 20 DAY, NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 3 DAY),
('座位设备故障报修指南', '如发现座位设备故障（电源、电脑、灯具等），请通过以下方式报修：\n1. 扫描座位上的二维码在线报修\n2. 拨打维修电话：400-123-4567\n3. 到服务台现场报修\n我们会在24小时内处理，感谢配合！', 'NOTICE', 1, 'PUBLISHED', 1, 67, NULL, NOW() - INTERVAL 8 DAY, NOW() - INTERVAL 8 DAY),
('充值优惠活动', '本月充值享受优惠：\n充值100元送10元\n充值200元送25元\n充值500元送80元\n活动时间：即日起至月底，数量有限，先到先得！', 'ANNOUNCEMENT', 2, 'PUBLISHED', 1, 145, NOW() + INTERVAL 15 DAY, NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 1 DAY),
('违规行为处理公告', '近期发现部分用户存在恶意占座、代人预约等违规行为，现公告如下：\n1. 恶意占座者将被扣除信用分\n2. 代人预约一经发现立即封号\n3. 破坏座位设备需照价赔偿\n请大家自觉遵守规则，共建文明学习环境。', 'NOTICE', 3, 'PUBLISHED', 1, 98, NULL, NOW() - INTERVAL 6 DAY, NOW() - INTERVAL 6 DAY),
-- 一些草稿和归档的公告
('新功能开发中', '我们正在开发座位预约小程序，敬请期待...', 'ANNOUNCEMENT', 1, 'DRAFT', 1, 0, NULL, NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 1 DAY),
('过期公告测试', '这是一个已过期的公告', 'NOTICE', 1, 'ARCHIVED', 1, 23, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 15 DAY, NOW() - INTERVAL 12 DAY);

-- 更新用户钱包余额（基于充值和消费记录）
UPDATE user SET balance = (
    SELECT COALESCE(
        (SELECT SUM(amount) FROM recharge_record WHERE user_id = user.id AND status = 'SUCCESS'), 0
    ) - COALESCE(
        (SELECT SUM(amount) FROM payment_record WHERE user_id = user.id AND status = 'SUCCESS'), 0
    )
) WHERE id > 1;

-- 插入一些用户钱包记录
INSERT INTO user_wallet (user_id, balance, total_recharge, total_consumption, created_time, updated_time) 
SELECT 
    id,
    balance,
    COALESCE((SELECT SUM(amount) FROM recharge_record WHERE user_id = user.id AND status = 'SUCCESS'), 0) as total_recharge,
    COALESCE((SELECT SUM(amount) FROM payment_record WHERE user_id = user.id AND status = 'SUCCESS'), 0) as total_consumption,
    created_time,
    NOW()
FROM user WHERE id > 1
ON DUPLICATE KEY UPDATE
    balance = VALUES(balance),
    total_recharge = VALUES(total_recharge),
    total_consumption = VALUES(total_consumption),
    updated_time = NOW();

-- 查看数据统计
SELECT '用户总数' as 统计项, COUNT(*) as 数量 FROM user WHERE role = 'STUDENT'
UNION ALL
SELECT '座位总数', COUNT(*) FROM seat
UNION ALL
SELECT '可用座位', COUNT(*) FROM seat WHERE status = 'AVAILABLE'
UNION ALL
SELECT '预约总数', COUNT(*) FROM reservation
UNION ALL
SELECT '今日预约', COUNT(*) FROM reservation WHERE reservation_date = CURDATE()
UNION ALL
SELECT '公告总数', COUNT(*) FROM announcement
UNION ALL
SELECT '充值记录', COUNT(*) FROM recharge_record
UNION ALL
SELECT '收藏记录', COUNT(*) FROM seat_favorite; 