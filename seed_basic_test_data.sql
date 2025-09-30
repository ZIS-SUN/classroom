-- 基础测试数据脚本（与当前表结构匹配）
-- 登录信息：
--   管理员 admin / admin123
--   学生     student001 / 123456, student002 / 123456

USE seat_reservation;

-- 1) 管理员账号（存在则忽略；若存在同名将更新密码）
INSERT INTO sys_user (username, password, real_name, phone, email, role, status)
SELECT 'admin', '$2a$10$N4VKaCI8m7XwlvGLfGz4aOKBOxk9FLLCXqT5t4v8QHgtsFLLp5x6a', 'Admin', '13800138000', 'admin@example.com', 'ADMIN', 'ACTIVE'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE username = 'admin');

-- 确保管理员密码重置为 admin123
UPDATE sys_user
SET password = '$2a$10$N4VKaCI8m7XwlvGLfGz4aOKBOxk9FLLCXqT5t4v8QHgtsFLLp5x6a', status = 'ACTIVE', role = 'ADMIN'
WHERE username = 'admin';

-- 2) 学生测试账号（不存在时插入）
INSERT INTO sys_user (username, password, real_name, phone, email, student_id, role, status)
SELECT 'student001', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', 'Student One', '13900139001', 'zhangsan@example.com', '2021001001', 'STUDENT', 'ACTIVE'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE username = 'student001');

INSERT INTO sys_user (username, password, real_name, phone, email, student_id, role, status)
SELECT 'student002', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', 'Student Two', '13900139002', 'lisi@example.com', '2021001002', 'STUDENT', 'ACTIVE'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE username = 'student002');

-- 3) 座位类型（仅在为空时批量插入）
INSERT INTO seat_type (type_name, description, hourly_rate)
SELECT * FROM (
  SELECT 'Standard' AS type_name, 'Basic seat' AS description, 0.00 AS hourly_rate
  UNION ALL SELECT 'Window',  'Near window', 1.00
  UNION ALL SELECT 'Private', 'Quiet room', 3.00
  UNION ALL SELECT 'Computer','With PC',     2.00
) t
WHERE (SELECT COUNT(*) FROM seat_type) = 0;

-- 若上一步未触发（表非空），补齐缺失的类型
INSERT INTO seat_type (type_name, description, hourly_rate)
SELECT 'Window', 'Near window', 1.00 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM seat_type WHERE type_name='Window');
INSERT INTO seat_type (type_name, description, hourly_rate)
SELECT 'Private', 'Quiet room', 3.00 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM seat_type WHERE type_name='Private');
INSERT INTO seat_type (type_name, description, hourly_rate)
SELECT 'Computer', 'With PC', 2.00 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM seat_type WHERE type_name='Computer');

-- 4) 座位（仅当 seat 表为空时插入 30 个样例）
INSERT INTO seat (seat_number, floor_number, area, seat_type_id, position_x, position_y, has_power, has_computer)
SELECT 'A001', 2, 'A', 1,  50,  50, TRUE,  FALSE FROM DUAL WHERE (SELECT COUNT(*) FROM seat) = 0 UNION ALL
SELECT 'A002', 2, 'A', 1, 100,  50, TRUE,  FALSE UNION ALL
SELECT 'A003', 2, 'A', 2, 150,  50, TRUE,  FALSE UNION ALL
SELECT 'A004', 2, 'A', 1, 200,  50, TRUE,  FALSE UNION ALL
SELECT 'A005', 2, 'A', 4, 250,  50, TRUE,   TRUE UNION ALL
SELECT 'A006', 2, 'A', 1, 300,  50, TRUE,  FALSE UNION ALL
SELECT 'A007', 2, 'A', 1, 350,  50, TRUE,  FALSE UNION ALL
SELECT 'A008', 2, 'A', 2, 400,  50, TRUE,  FALSE UNION ALL
SELECT 'A009', 2, 'A', 1, 450,  50, TRUE,  FALSE UNION ALL
SELECT 'A010', 2, 'A', 1, 500,  50, TRUE,  FALSE UNION ALL
SELECT 'A011', 2, 'A', 1,  50, 150, TRUE,  FALSE UNION ALL
SELECT 'A012', 2, 'A', 1, 100, 150, TRUE,  FALSE UNION ALL
SELECT 'A013', 2, 'A', 2, 150, 150, TRUE,  FALSE UNION ALL
SELECT 'A014', 2, 'A', 1, 200, 150, TRUE,  FALSE UNION ALL
SELECT 'A015', 2, 'A', 4, 250, 150, TRUE,   TRUE UNION ALL
SELECT 'A016', 2, 'A', 1, 300, 150, TRUE,  FALSE UNION ALL
SELECT 'A017', 2, 'A', 1, 350, 150, TRUE,  FALSE UNION ALL
SELECT 'A018', 2, 'A', 2, 400, 150, TRUE,  FALSE UNION ALL
SELECT 'A019', 2, 'A', 1, 450, 150, TRUE,  FALSE UNION ALL
SELECT 'A020', 2, 'A', 1, 500, 150, TRUE,  FALSE UNION ALL
SELECT 'A021', 2, 'A', 1,  50, 250, TRUE,  FALSE UNION ALL
SELECT 'A022', 2, 'A', 1, 100, 250, TRUE,  FALSE UNION ALL
SELECT 'A023', 2, 'A', 2, 150, 250, TRUE,  FALSE UNION ALL
SELECT 'A024', 2, 'A', 1, 200, 250, TRUE,  FALSE UNION ALL
SELECT 'A025', 2, 'A', 3, 250, 250, TRUE,  FALSE UNION ALL
SELECT 'A026', 2, 'A', 3, 300, 250, TRUE,  FALSE UNION ALL
SELECT 'A027', 2, 'A', 1, 350, 250, TRUE,  FALSE UNION ALL
SELECT 'A028', 2, 'A', 2, 400, 250, TRUE,  FALSE UNION ALL
SELECT 'A029', 2, 'A', 1, 450, 250, TRUE,  FALSE UNION ALL
SELECT 'A030', 2, 'A', 1, 500, 250, TRUE,  FALSE;

-- 5) 基础配置（仅在为空时）
INSERT INTO sys_config (config_key, config_value, config_desc)
SELECT 'system.reservation.max_hours', '8', 'max hours per reservation' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key='system.reservation.max_hours');
INSERT INTO sys_config (config_key, config_value, config_desc)
SELECT 'system.reservation.advance_days', '7', 'max days in advance' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key='system.reservation.advance_days');
INSERT INTO sys_config (config_key, config_value, config_desc)
SELECT 'system.reservation.cancel_hours', '2', 'cancel before hours' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key='system.reservation.cancel_hours');
INSERT INTO sys_config (config_key, config_value, config_desc)
SELECT 'system.open_time', '08:00', 'open time' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key='system.open_time');
INSERT INTO sys_config (config_key, config_value, config_desc)
SELECT 'system.close_time', '22:00', 'close time' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_config WHERE config_key='system.close_time');

-- 6) 示例预约记录（仅 seat 与用户存在时插入几条）
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, total_fee, remark)
SELECT u.id, s.id, CURDATE(), '09:00:00', '12:00:00', 'RESERVED', 0.00, '样例预约'
FROM sys_user u
JOIN seat s ON s.seat_number = 'A001'
WHERE u.username = 'student001' AND NOT EXISTS (
  SELECT 1 FROM reservation r WHERE r.user_id = u.id AND r.seat_id = s.id AND r.reservation_date = CURDATE() AND r.start_time = '09:00:00'
);

-- 验证输出
SELECT 'users' AS t, COUNT(*) AS c FROM sys_user
UNION ALL SELECT 'seat_type', COUNT(*) FROM seat_type
UNION ALL SELECT 'seat', COUNT(*) FROM seat
UNION ALL SELECT 'reservation', COUNT(*) FROM reservation;
