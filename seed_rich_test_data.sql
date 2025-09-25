-- 丰富测试数据脚本（公告、收藏、更多预约）
USE seat_reservation;

-- 0) 补充表结构（如不存在）
-- 公告表
CREATE TABLE IF NOT EXISTS sys_announcement (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'PK',
  title VARCHAR(200) NOT NULL COMMENT 'title',
  content TEXT NOT NULL COMMENT 'content',
  type VARCHAR(20) NOT NULL DEFAULT 'NOTICE' COMMENT 'NOTICE/ANNOUNCEMENT/URGENT',
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT/PUBLISHED/ARCHIVED',
  author_id BIGINT NOT NULL COMMENT 'author id',
  author_name VARCHAR(50) NOT NULL COMMENT 'author name',
  priority INT NOT NULL DEFAULT 2 COMMENT '1-LOW 2-MED 3-HIGH',
  publish_time DATETIME NULL,
  expire_time DATETIME NULL,
  view_count INT NOT NULL DEFAULT 0,
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='system announcement';

-- 座位收藏表
CREATE TABLE IF NOT EXISTS seat_favorite (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  seat_id BIGINT NOT NULL,
  favorite_name VARCHAR(50) DEFAULT NULL,
  created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_fav_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
  CONSTRAINT fk_fav_seat FOREIGN KEY (seat_id) REFERENCES seat(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_seat (user_id, seat_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 1) 公告（避免重复按标题去重）
INSERT INTO sys_announcement (title, content, type, status, author_id, author_name, priority, publish_time, expire_time)
SELECT 'System Online', 'Seat reservation system is now online.', 'ANNOUNCEMENT', 'PUBLISHED', u.id, u.username, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)
FROM sys_user u WHERE u.username='admin' AND NOT EXISTS (SELECT 1 FROM sys_announcement WHERE title='System Online');

INSERT INTO sys_announcement (title, content, type, status, author_id, author_name, priority, publish_time)
SELECT 'Usage Tips', 'Arrive on time. Cancel early if needed.', 'NOTICE', 'PUBLISHED', u.id, u.username, 1, NOW()
FROM sys_user u WHERE u.username='admin' AND NOT EXISTS (SELECT 1 FROM sys_announcement WHERE title='Usage Tips');

INSERT INTO sys_announcement (title, content, type, status, author_id, author_name, priority, publish_time, expire_time)
SELECT 'Planned Maintenance', 'Service maintenance tonight 23:00-06:00.', 'URGENT', 'PUBLISHED', u.id, u.username, 3, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY)
FROM sys_user u WHERE u.username='admin' AND NOT EXISTS (SELECT 1 FROM sys_announcement WHERE title='Planned Maintenance');

-- 2) 收藏（为 student001 和 student002 各加两个常用座位）
-- student001 收藏 A001, A005
INSERT INTO seat_favorite (user_id, seat_id, favorite_name)
SELECT u.id, s.id, 'Fav A001'
FROM sys_user u JOIN seat s ON s.seat_number='A001'
WHERE u.username='student001'
  AND NOT EXISTS (SELECT 1 FROM seat_favorite f WHERE f.user_id=u.id AND f.seat_id=s.id);

INSERT INTO seat_favorite (user_id, seat_id, favorite_name)
SELECT u.id, s.id, 'Fav A005'
FROM sys_user u JOIN seat s ON s.seat_number='A005'
WHERE u.username='student001'
  AND NOT EXISTS (SELECT 1 FROM seat_favorite f WHERE f.user_id=u.id AND f.seat_id=s.id);

-- student002 收藏 A002, A015
INSERT INTO seat_favorite (user_id, seat_id, favorite_name)
SELECT u.id, s.id, 'Fav A002'
FROM sys_user u JOIN seat s ON s.seat_number='A002'
WHERE u.username='student002'
  AND NOT EXISTS (SELECT 1 FROM seat_favorite f WHERE f.user_id=u.id AND f.seat_id=s.id);

INSERT INTO seat_favorite (user_id, seat_id, favorite_name)
SELECT u.id, s.id, 'Fav A015'
FROM sys_user u JOIN seat s ON s.seat_number='A015'
WHERE u.username='student002'
  AND NOT EXISTS (SELECT 1 FROM seat_favorite f WHERE f.user_id=u.id AND f.seat_id=s.id);

-- 3) 更多预约（今天、昨天、上周、未来），避免重复插入
-- 今天 student001 A001 09:00-12:00（若不存在）
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, total_fee, remark)
SELECT u.id, s.id, CURDATE(), '09:00:00', '12:00:00', 'RESERVED', 0.00, 'today sample'
FROM sys_user u JOIN seat s ON s.seat_number='A001'
WHERE u.username='student001'
  AND NOT EXISTS (
    SELECT 1 FROM reservation r WHERE r.user_id=u.id AND r.seat_id=s.id AND r.reservation_date=CURDATE() AND r.start_time='09:00:00'
  );

-- 昨天 student002 A002 14:00-17:00 已完成
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, check_in_time, check_out_time, total_fee, remark)
SELECT u.id, s.id, CURDATE()-INTERVAL 1 DAY, '14:00:00', '17:00:00', 'COMPLETED', NOW()-INTERVAL 1 DAY - INTERVAL 4 HOUR, NOW()-INTERVAL 1 DAY, 0.00, 'yesterday sample'
FROM sys_user u JOIN seat s ON s.seat_number='A002'
WHERE u.username='student002'
  AND NOT EXISTS (
    SELECT 1 FROM reservation r WHERE r.user_id=u.id AND r.seat_id=s.id AND r.reservation_date=CURDATE()-INTERVAL 1 DAY AND r.start_time='14:00:00'
  );

-- 上周 student001 A015 10:00-16:00 已完成
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, check_in_time, check_out_time, total_fee, remark)
SELECT u.id, s.id, CURDATE()-INTERVAL 7 DAY, '10:00:00', '16:00:00', 'COMPLETED', NOW()-INTERVAL 7 DAY - INTERVAL 6 HOUR, NOW()-INTERVAL 7 DAY, 0.00, 'last week sample'
FROM sys_user u JOIN seat s ON s.seat_number='A015'
WHERE u.username='student001'
  AND NOT EXISTS (
    SELECT 1 FROM reservation r WHERE r.user_id=u.id AND r.seat_id=s.id AND r.reservation_date=CURDATE()-INTERVAL 7 DAY AND r.start_time='10:00:00'
  );

-- 明天 student002 A005 13:00-18:00 已预约
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, total_fee, remark)
SELECT u.id, s.id, CURDATE()+INTERVAL 1 DAY, '13:00:00', '18:00:00', 'RESERVED', 0.00, 'tomorrow sample'
FROM sys_user u JOIN seat s ON s.seat_number='A005'
WHERE u.username='student002'
  AND NOT EXISTS (
    SELECT 1 FROM reservation r WHERE r.user_id=u.id AND r.seat_id=s.id AND r.reservation_date=CURDATE()+INTERVAL 1 DAY AND r.start_time='13:00:00'
  );

-- 补充：更多不同状态与时间的预约
-- 前天 student002 A008 15:00-19:00 已完成
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, check_in_time, check_out_time, total_fee, remark)
SELECT u.id, s.id, CURDATE()-INTERVAL 2 DAY, '15:00:00', '19:00:00', 'COMPLETED', NOW()-INTERVAL 2 DAY - INTERVAL 5 HOUR, NOW()-INTERVAL 2 DAY, 0.00, 'extra completed'
FROM sys_user u JOIN seat s ON s.seat_number='A008'
WHERE u.username='student002'
  AND NOT EXISTS (
    SELECT 1 FROM reservation r WHERE r.user_id=u.id AND r.seat_id=s.id AND r.reservation_date=CURDATE()-INTERVAL 2 DAY AND r.start_time='15:00:00'
  );

-- 今天 student002 A003 13:00-15:00 使用中
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, check_in_time, total_fee, remark)
SELECT u.id, s.id, CURDATE(), '13:00:00', '15:00:00', 'USING', NOW()-INTERVAL 1 HOUR, 0.00, 'using now'
FROM sys_user u JOIN seat s ON s.seat_number='A003'
WHERE u.username='student002'
  AND NOT EXISTS (
    SELECT 1 FROM reservation r WHERE r.user_id=u.id AND r.seat_id=s.id AND r.reservation_date=CURDATE() AND r.start_time='13:00:00'
  );

-- 昨天 student001 A007 09:00-10:00 过期（未签到）
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, total_fee, remark)
SELECT u.id, s.id, CURDATE()-INTERVAL 1 DAY, '09:00:00', '10:00:00', 'EXPIRED', 0.00, 'expired not checked in'
FROM sys_user u JOIN seat s ON s.seat_number='A007'
WHERE u.username='student001'
  AND NOT EXISTS (
    SELECT 1 FROM reservation r WHERE r.user_id=u.id AND r.seat_id=s.id AND r.reservation_date=CURDATE()-INTERVAL 1 DAY AND r.start_time='09:00:00'
  );

-- 后天 student001 A009 10:00-12:00 已取消
INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, total_fee, remark)
SELECT u.id, s.id, CURDATE()+INTERVAL 2 DAY, '10:00:00', '12:00:00', 'CANCELLED', 0.00, 'cancelled sample'
FROM sys_user u JOIN seat s ON s.seat_number='A009'
WHERE u.username='student001'
  AND NOT EXISTS (
    SELECT 1 FROM reservation r WHERE r.user_id=u.id AND r.seat_id=s.id AND r.reservation_date=CURDATE()+INTERVAL 2 DAY AND r.start_time='10:00:00'
  );

-- 4) 调整部分座位状态显示占用
UPDATE seat SET status='OCCUPIED' WHERE seat_number IN ('A003','A005','A009','A015');
UPDATE seat SET status='AVAILABLE' WHERE seat_number NOT IN ('A003','A005','A009','A015');

-- 5) 汇总展示
SELECT 'announcement' AS t, COUNT(*) AS c FROM sys_announcement
UNION ALL SELECT 'favorites', COUNT(*) FROM seat_favorite
UNION ALL SELECT 'reservations', COUNT(*) FROM reservation;
