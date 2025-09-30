-- 插入丰富的测试数据
-- 清空现有数据（除了管理员账户）
DELETE FROM reservation WHERE id > 0;
DELETE FROM seat WHERE id > 0;
DELETE FROM seat_favorite WHERE id > 0;
DELETE FROM announcement WHERE id > 0;
DELETE FROM `user` WHERE role != 'ADMIN';

-- 插入更多测试用户
INSERT INTO `user` (username, password, real_name, phone, email, role, status, created_time) VALUES
('zhangsan', '$2a$10$example.hash.for.password.test1', '张三', '13800138001', 'zhangsan@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 30 DAY)),
('lisi', '$2a$10$example.hash.for.password.test2', '李四', '13800138002', 'lisi@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 25 DAY)),
('wangwu', '$2a$10$example.hash.for.password.test3', '王五', '13800138003', 'wangwu@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 20 DAY)),
('zhaoliu', '$2a$10$example.hash.for.password.test4', '赵六', '13800138004', 'zhaoliu@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 15 DAY)),
('sunqi', '$2a$10$example.hash.for.password.test5', '孙七', '13800138005', 'sunqi@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 10 DAY)),
('zhouba', '$2a$10$example.hash.for.password.test6', '周八', '13800138006', 'zhouba@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 8 DAY)),
('wujiu', '$2a$10$example.hash.for.password.test7', '吴九', '13800138007', 'wujiu@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 6 DAY)),
('zhengshi', '$2a$10$example.hash.for.password.test8', '郑十', '13800138008', 'zhengshi@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 4 DAY)),
('chenyi', '$2a$10$example.hash.for.password.test9', '陈一', '13800138009', 'chenyi@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('liuer', '$2a$10$example.hash.for.password.test10', '刘二', '13800138010', 'liuer@example.com', 'USER', 'ACTIVE', NOW()),
('yangsan', '$2a$10$example.hash.for.password.test11', '杨三', '13800138011', 'yangsan@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 5 DAY)),
('huangsi', '$2a$10$example.hash.for.password.test12', '黄四', '13800138012', 'huangsi@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('linwu', '$2a$10$example.hash.for.password.test13', '林五', '13800138013', 'linwu@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 7 DAY)),
('xuliu', '$2a$10$example.hash.for.password.test14', '徐六', '13800138014', 'xuliu@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 12 DAY)),
('heqi', '$2a$10$example.hash.for.password.test15', '何七', '13800138015', 'heqi@example.com', 'USER', 'ACTIVE', DATE_SUB(NOW(), INTERVAL 18 DAY));

-- 插入更多座位数据（不同类型）
INSERT INTO seat (seat_number, seat_type_id, floor, room_name, location_detail, status, has_power, has_lamp, price_per_hour, created_time) VALUES
-- 1楼普通区域（座位类型1：普通座位）
('A001', 1, 1, '普通阅览区A', '第1排第1座', 'AVAILABLE', true, true, 2.5, NOW()),
('A002', 1, 1, '普通阅览区A', '第1排第2座', 'AVAILABLE', true, true, 2.5, NOW()),
('A003', 1, 1, '普通阅览区A', '第1排第3座', 'OCCUPIED', true, true, 2.5, NOW()),
('A004', 1, 1, '普通阅览区A', '第1排第4座', 'AVAILABLE', true, true, 2.5, NOW()),
('A005', 1, 1, '普通阅览区A', '第1排第5座', 'OCCUPIED', true, true, 2.5, NOW()),
('A006', 1, 1, '普通阅览区A', '第2排第1座', 'AVAILABLE', true, true, 2.5, NOW()),
('A007', 1, 1, '普通阅览区A', '第2排第2座', 'AVAILABLE', true, true, 2.5, NOW()),
('A008', 1, 1, '普通阅览区A', '第2排第3座', 'AVAILABLE', true, true, 2.5, NOW()),
('A009', 1, 1, '普通阅览区A', '第2排第4座', 'OCCUPIED', true, true, 2.5, NOW()),
('A010', 1, 1, '普通阅览区A', '第2排第5座', 'AVAILABLE', true, true, 2.5, NOW()),

-- 1楼靠窗区域（座位类型2：靠窗座位）
('B001', 2, 1, '靠窗阅览区B', '靠窗第1座', 'AVAILABLE', true, true, 3.0, NOW()),
('B002', 2, 1, '靠窗阅览区B', '靠窗第2座', 'OCCUPIED', true, true, 3.0, NOW()),
('B003', 2, 1, '靠窗阅览区B', '靠窗第3座', 'AVAILABLE', true, true, 3.0, NOW()),
('B004', 2, 1, '靠窗阅览区B', '靠窗第4座', 'OCCUPIED', true, true, 3.0, NOW()),
('B005', 2, 1, '靠窗阅览区B', '靠窗第5座', 'AVAILABLE', true, true, 3.0, NOW()),
('B006', 2, 1, '靠窗阅览区B', '靠窗第6座', 'AVAILABLE', true, true, 3.0, NOW()),
('B007', 2, 1, '靠窗阅览区B', '靠窗第7座', 'OCCUPIED', true, true, 3.0, NOW()),
('B008', 2, 1, '靠窗阅览区B', '靠窗第8座', 'AVAILABLE', true, true, 3.0, NOW()),

-- 2楼独立包间（座位类型3：独立包间）
('C001', 3, 2, '独立包间区C', '包间1', 'AVAILABLE', true, true, 8.0, NOW()),
('C002', 3, 2, '独立包间区C', '包间2', 'OCCUPIED', true, true, 8.0, NOW()),
('C003', 3, 2, '独立包间区C', '包间3', 'AVAILABLE', true, true, 8.0, NOW()),
('C004', 3, 2, '独立包间区C', '包间4', 'AVAILABLE', true, true, 8.0, NOW()),
('C005', 3, 2, '独立包间区C', '包间5', 'OCCUPIED', true, true, 8.0, NOW()),
('C006', 3, 2, '独立包间区C', '包间6', 'AVAILABLE', true, true, 8.0, NOW()),

-- 2楼电脑区域（座位类型4：电脑座位）
('D001', 4, 2, '电脑区D', '电脑桌1', 'AVAILABLE', true, true, 5.0, NOW()),
('D002', 4, 2, '电脑区D', '电脑桌2', 'OCCUPIED', true, true, 5.0, NOW()),
('D003', 4, 2, '电脑区D', '电脑桌3', 'AVAILABLE', true, true, 5.0, NOW()),
('D004', 4, 2, '电脑区D', '电脑桌4', 'OCCUPIED', true, true, 5.0, NOW()),
('D005', 4, 2, '电脑区D', '电脑桌5', 'AVAILABLE', true, true, 5.0, NOW()),
('D006', 4, 2, '电脑区D', '电脑桌6', 'AVAILABLE', true, true, 5.0, NOW()),
('D007', 4, 2, '电脑区D', '电脑桌7', 'OCCUPIED', true, true, 5.0, NOW()),
('D008', 4, 2, '电脑区D', '电脑桌8', 'AVAILABLE', true, true, 5.0, NOW()),
('D009', 4, 2, '电脑区D', '电脑桌9', 'AVAILABLE', true, true, 5.0, NOW()),
('D010', 4, 2, '电脑区D', '电脑桌10', 'OCCUPIED', true, true, 5.0, NOW());

-- 插入历史预约记录（让统计数据更丰富）
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, total_amount, payment_status, created_time) VALUES
-- 最近30天的预约记录
(2, 1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '09:00:00', '12:00:00', 'COMPLETED', 7.5, 'PAID', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(3, 2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '14:00:00', '18:00:00', 'COMPLETED', 10.0, 'PAID', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(4, 11, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '10:00:00', '16:00:00', 'COMPLETED', 18.0, 'PAID', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(5, 21, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '13:00:00', '17:00:00', 'COMPLETED', 32.0, 'PAID', DATE_SUB(NOW(), INTERVAL 1 DAY)),

(2, 3, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '08:30:00', '11:30:00', 'COMPLETED', 7.5, 'PAID', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(6, 4, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '15:00:00', '19:00:00', 'COMPLETED', 10.0, 'PAID', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(7, 12, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '09:00:00', '15:00:00', 'COMPLETED', 18.0, 'PAID', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(8, 22, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '14:00:00', '18:00:00', 'COMPLETED', 32.0, 'PAID', DATE_SUB(NOW(), INTERVAL 2 DAY)),

(9, 5, DATE_SUB(CURDATE(), INTERVAL 3 DAY), '10:00:00', '13:00:00', 'COMPLETED', 7.5, 'PAID', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(10, 6, DATE_SUB(CURDATE(), INTERVAL 3 DAY), '16:00:00', '20:00:00', 'COMPLETED', 10.0, 'PAID', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(11, 13, DATE_SUB(CURDATE(), INTERVAL 3 DAY), '11:00:00', '17:00:00', 'COMPLETED', 18.0, 'PAID', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(12, 31, DATE_SUB(CURDATE(), INTERVAL 3 DAY), '12:00:00', '16:00:00', 'COMPLETED', 20.0, 'PAID', DATE_SUB(NOW(), INTERVAL 3 DAY)),

(13, 7, DATE_SUB(CURDATE(), INTERVAL 4 DAY), '09:30:00', '12:30:00', 'COMPLETED', 7.5, 'PAID', DATE_SUB(NOW(), INTERVAL 4 DAY)),
(14, 8, DATE_SUB(CURDATE(), INTERVAL 4 DAY), '14:30:00', '18:30:00', 'COMPLETED', 10.0, 'PAID', DATE_SUB(NOW(), INTERVAL 4 DAY)),
(15, 14, DATE_SUB(CURDATE(), INTERVAL 4 DAY), '10:30:00', '16:30:00', 'COMPLETED', 18.0, 'PAID', DATE_SUB(NOW(), INTERVAL 4 DAY)),
(16, 32, DATE_SUB(CURDATE(), INTERVAL 4 DAY), '13:30:00', '17:30:00', 'COMPLETED', 20.0, 'PAID', DATE_SUB(NOW(), INTERVAL 4 DAY)),

(2, 9, DATE_SUB(CURDATE(), INTERVAL 5 DAY), '08:00:00', '12:00:00', 'COMPLETED', 10.0, 'PAID', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(3, 10, DATE_SUB(CURDATE(), INTERVAL 5 DAY), '15:00:00', '19:00:00', 'COMPLETED', 10.0, 'PAID', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(4, 15, DATE_SUB(CURDATE(), INTERVAL 5 DAY), '09:00:00', '15:00:00', 'COMPLETED', 18.0, 'PAID', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(5, 33, DATE_SUB(CURDATE(), INTERVAL 5 DAY), '14:00:00', '18:00:00', 'COMPLETED', 20.0, 'PAID', DATE_SUB(NOW(), INTERVAL 5 DAY)),

(6, 16, DATE_SUB(CURDATE(), INTERVAL 6 DAY), '10:00:00', '14:00:00', 'COMPLETED', 12.0, 'PAID', DATE_SUB(NOW(), INTERVAL 6 DAY)),
(7, 17, DATE_SUB(CURDATE(), INTERVAL 6 DAY), '16:00:00', '20:00:00', 'COMPLETED', 12.0, 'PAID', DATE_SUB(NOW(), INTERVAL 6 DAY)),
(8, 34, DATE_SUB(CURDATE(), INTERVAL 6 DAY), '11:00:00', '17:00:00', 'COMPLETED', 24.0, 'PAID', DATE_SUB(NOW(), INTERVAL 6 DAY)),
(9, 35, DATE_SUB(CURDATE(), INTERVAL 6 DAY), '13:00:00', '19:00:00', 'COMPLETED', 24.0, 'PAID', DATE_SUB(NOW(), INTERVAL 6 DAY)),

(10, 18, DATE_SUB(CURDATE(), INTERVAL 7 DAY), '09:00:00', '13:00:00', 'COMPLETED', 12.0, 'PAID', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(11, 19, DATE_SUB(CURDATE(), INTERVAL 7 DAY), '15:00:00', '19:00:00', 'COMPLETED', 12.0, 'PAID', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(12, 36, DATE_SUB(CURDATE(), INTERVAL 7 DAY), '10:00:00', '16:00:00', 'COMPLETED', 24.0, 'PAID', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(13, 37, DATE_SUB(CURDATE(), INTERVAL 7 DAY), '14:00:00', '20:00:00', 'COMPLETED', 24.0, 'PAID', DATE_SUB(NOW(), INTERVAL 7 DAY)),

-- 今日预约记录
(2, 1, CURDATE(), '09:00:00', '12:00:00', 'ACTIVE', 7.5, 'PAID', NOW()),
(3, 5, CURDATE(), '14:00:00', '18:00:00', 'ACTIVE', 10.0, 'PAID', NOW()),
(4, 12, CURDATE(), '10:00:00', '16:00:00', 'ACTIVE', 18.0, 'PAID', NOW()),
(5, 22, CURDATE(), '13:00:00', '17:00:00', 'ACTIVE', 20.0, 'PAID', NOW()),
(6, 27, CURDATE(), '15:00:00', '19:00:00', 'ACTIVE', 20.0, 'PAID', NOW()),
(7, 32, CURDATE(), '11:00:00', '17:00:00', 'ACTIVE', 24.0, 'PAID', NOW()),
(8, 37, CURDATE(), '12:00:00', '18:00:00', 'ACTIVE', 24.0, 'PAID', NOW());

-- 插入座位收藏记录
INSERT INTO seat_favorite (user_id, seat_id, created_time) VALUES
(2, 1, DATE_SUB(NOW(), INTERVAL 5 DAY)),
(2, 11, DATE_SUB(NOW(), INTERVAL 4 DAY)),
(3, 2, DATE_SUB(NOW(), INTERVAL 3 DAY)),
(3, 12, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(4, 21, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(5, 31, NOW()),
(6, 5, DATE_SUB(NOW(), INTERVAL 6 DAY)),
(7, 15, DATE_SUB(NOW(), INTERVAL 7 DAY)),
(8, 25, DATE_SUB(NOW(), INTERVAL 8 DAY)),
(9, 35, DATE_SUB(NOW(), INTERVAL 9 DAY));

-- 插入公告数据
INSERT INTO announcement (title, content, type, priority, status, start_time, end_time, created_by, created_time) VALUES
('系统维护通知', '本自习室将于本周六晚上22:00-24:00进行系统维护，期间可能影响预约服务，敬请谅解。', 'MAINTENANCE', 'HIGH', 'PUBLISHED', NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), 1, DATE_SUB(NOW(), INTERVAL 2 DAY)),
('新增座位区域', '二楼新增独立包间区域，提供更安静的学习环境，现已开放预约！', 'ANNOUNCEMENT', 'MEDIUM', 'PUBLISHED', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, DATE_SUB(NOW(), INTERVAL 5 DAY)),
('春节放假通知', '春节期间（2月10日-2月17日）自习室正常营业，欢迎大家来学习。', 'NOTICE', 'MEDIUM', 'PUBLISHED', NOW(), DATE_ADD(NOW(), INTERVAL 45 DAY), 1, DATE_SUB(NOW(), INTERVAL 10 DAY)),
('优惠活动开始', '充值满100元送20元，充值满200元送50元，活动期间有效！', 'ANNOUNCEMENT', 'HIGH', 'PUBLISHED', NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), 1, DATE_SUB(NOW(), INTERVAL 3 DAY)),
('学习氛围提醒', '请保持安静，不要在阅览区接打电话，共同维护良好的学习环境。', 'NOTICE', 'LOW', 'PUBLISHED', NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 1, DATE_SUB(NOW(), INTERVAL 1 DAY)),
('Wi-Fi密码更新', '自习室Wi-Fi密码已更新为：StudyRoom2024，请及时更新连接。', 'NOTICE', 'MEDIUM', 'PUBLISHED', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, NOW());

-- 为了让统计更丰富，再添加一些较早的预约记录
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, total_amount, payment_status, created_time) VALUES
-- 8-15天前的预约
(2, 3, DATE_SUB(CURDATE(), INTERVAL 8 DAY), '09:00:00', '15:00:00', 'COMPLETED', 15.0, 'PAID', DATE_SUB(NOW(), INTERVAL 8 DAY)),
(3, 13, DATE_SUB(CURDATE(), INTERVAL 8 DAY), '10:00:00', '16:00:00', 'COMPLETED', 18.0, 'PAID', DATE_SUB(NOW(), INTERVAL 8 DAY)),
(4, 23, DATE_SUB(CURDATE(), INTERVAL 9 DAY), '14:00:00', '18:00:00', 'COMPLETED', 20.0, 'PAID', DATE_SUB(NOW(), INTERVAL 9 DAY)),
(5, 33, DATE_SUB(CURDATE(), INTERVAL 10 DAY), '11:00:00', '17:00:00', 'COMPLETED', 24.0, 'PAID', DATE_SUB(NOW(), INTERVAL 10 DAY)),
(6, 4, DATE_SUB(CURDATE(), INTERVAL 11 DAY), '09:30:00', '13:30:00', 'COMPLETED', 10.0, 'PAID', DATE_SUB(NOW(), INTERVAL 11 DAY)),
(7, 14, DATE_SUB(CURDATE(), INTERVAL 12 DAY), '15:30:00', '19:30:00', 'COMPLETED', 12.0, 'PAID', DATE_SUB(NOW(), INTERVAL 12 DAY)),
(8, 24, DATE_SUB(CURDATE(), INTERVAL 13 DAY), '12:00:00', '16:00:00', 'COMPLETED', 20.0, 'PAID', DATE_SUB(NOW(), INTERVAL 13 DAY)),
(9, 34, DATE_SUB(CURDATE(), INTERVAL 14 DAY), '13:00:00', '19:00:00', 'COMPLETED', 24.0, 'PAID', DATE_SUB(NOW(), INTERVAL 14 DAY)),
(10, 5, DATE_SUB(CURDATE(), INTERVAL 15 DAY), '08:00:00', '14:00:00', 'COMPLETED', 15.0, 'PAID', DATE_SUB(NOW(), INTERVAL 15 DAY));

-- 更新座位状态（让一些座位显示为被占用）
UPDATE seat SET status = 'OCCUPIED' WHERE id IN (3, 5, 9, 12, 14, 22, 25, 27, 32, 37);
UPDATE seat SET status = 'AVAILABLE' WHERE id NOT IN (3, 5, 9, 12, 14, 22, 25, 27, 32, 37);