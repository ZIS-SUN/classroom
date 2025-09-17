-- 适配实际表结构的测试数据
-- 清除现有数据 (保留admin用户)
DELETE FROM reservation WHERE id > 0;
DELETE FROM seat WHERE id > 0;
DELETE FROM seat_type WHERE id > 0;
DELETE FROM sys_user WHERE id > 1; -- 保留admin用户

-- 重置自增ID
ALTER TABLE sys_user AUTO_INCREMENT = 2;
ALTER TABLE seat_type AUTO_INCREMENT = 1;
ALTER TABLE seat AUTO_INCREMENT = 1;
ALTER TABLE reservation AUTO_INCREMENT = 1;

-- 插入座位类型
INSERT INTO seat_type (type_name, hourly_rate, description) VALUES
('普通座位', 2.00, '基础座位，适合一般学习'),
('靠窗座位', 3.00, '靠窗位置，采光好，视野开阔'),
('电脑座位', 5.00, '配备电脑的座位，适合编程学习'),
('包间座位', 8.00, '独立包间，安静私密'),
('沙发座位', 4.00, '舒适沙发座位，适合长时间学习'),
('讨论座位', 6.00, '适合小组讨论的座位区域');

-- 插入大量用户数据
INSERT INTO sys_user (username, password, real_name, student_id, phone, email, role, status, balance, created_time, updated_time) VALUES
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

-- 查看数据统计
SELECT '用户总数' as 统计项, COUNT(*) as 数量 FROM sys_user WHERE role = 'STUDENT'
UNION ALL
SELECT '座位总数', COUNT(*) FROM seat
UNION ALL
SELECT '可用座位', COUNT(*) FROM seat WHERE status = 'AVAILABLE'
UNION ALL
SELECT '预约总数', COUNT(*) FROM reservation
UNION ALL
SELECT '今日预约', COUNT(*) FROM reservation WHERE reservation_date = CURDATE(); 