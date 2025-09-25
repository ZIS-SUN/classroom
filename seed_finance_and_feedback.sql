-- 支付/钱包/反馈 测试数据脚本（匹配当前表结构）
SET NAMES utf8mb4;
USE seat_reservation;

-- 1) 表结构（如不存在则创建）
-- 用户钱包
CREATE TABLE IF NOT EXISTS user_wallet (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL UNIQUE,
  balance DECIMAL(10,2) DEFAULT 0.00,
  total_recharge DECIMAL(10,2) DEFAULT 0.00,
  total_consume DECIMAL(10,2) DEFAULT 0.00,
  created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_wallet_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 充值记录
CREATE TABLE IF NOT EXISTS recharge_record (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  order_no VARCHAR(64) NOT NULL UNIQUE,
  amount DECIMAL(10,2) NOT NULL,
  bonus_amount DECIMAL(10,2) DEFAULT 0.00,
  payment_method VARCHAR(20) NOT NULL,
  payment_status VARCHAR(20) DEFAULT 'PENDING',
  third_party_order_no VARCHAR(128),
  remark TEXT,
  created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_recharge_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
  INDEX idx_recharge_user (user_id),
  INDEX idx_recharge_status (payment_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 支付记录
CREATE TABLE IF NOT EXISTS payment_record (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  reservation_id BIGINT NOT NULL,
  order_no VARCHAR(64) NOT NULL UNIQUE,
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(20) NOT NULL,
  payment_status VARCHAR(20) DEFAULT 'PENDING',
  third_party_order_no VARCHAR(128),
  refund_amount DECIMAL(10,2) DEFAULT 0.00,
  refund_time DATETIME NULL,
  remark TEXT,
  created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
  CONSTRAINT fk_payment_reservation FOREIGN KEY (reservation_id) REFERENCES reservation(id) ON DELETE CASCADE,
  INDEX idx_payment_user (user_id),
  INDEX idx_payment_res (reservation_id),
  INDEX idx_payment_status (payment_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 反馈表
CREATE TABLE IF NOT EXISTS feedback (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  type VARCHAR(20) NOT NULL,
  content TEXT NOT NULL,
  reply TEXT NULL,
  status VARCHAR(20) DEFAULT 'PENDING',
  created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  replied_time DATETIME NULL,
  replied_by BIGINT NULL,
  INDEX idx_feedback_user (user_id),
  INDEX idx_feedback_status (status),
  INDEX idx_feedback_type (type),
  CONSTRAINT fk_feedback_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 统一这些表的字符集与排序规则，避免联表比较时报错
ALTER TABLE user_wallet CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE recharge_record CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE payment_record CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE feedback CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2) 为现有用户创建/初始化钱包
INSERT IGNORE INTO user_wallet (user_id, balance, total_recharge, total_consume)
SELECT id,
       CASE WHEN username='admin' THEN 500.00 WHEN username='student001' THEN 120.00 WHEN username='student002' THEN 80.00 ELSE 0.00 END,
       CASE WHEN username='admin' THEN 500.00 WHEN username='student001' THEN 150.00 WHEN username='student002' THEN 100.00 ELSE 0.00 END,
       0.00
FROM sys_user;

-- 3) 充值记录（只为 admin/student001/student002 插入示例，避免重复）
INSERT INTO recharge_record (user_id, order_no, amount, bonus_amount, payment_method, payment_status, third_party_order_no, created_time)
SELECT u.id, CONCAT('RCHA-',u.username,'-001'), 100.00, 10.00, 'WECHAT', 'SUCCESS', CONCAT('WX-',u.username,'-A'), NOW()-INTERVAL 7 DAY
FROM sys_user u WHERE u.username IN ('admin','student001','student002')
AND NOT EXISTS (SELECT 1 FROM recharge_record r WHERE r.order_no=CONCAT('RCHA-',u.username,'-001'));

INSERT INTO recharge_record (user_id, order_no, amount, bonus_amount, payment_method, payment_status, third_party_order_no, created_time)
SELECT u.id, CONCAT('RCHB-',u.username,'-002'), 50.00, 5.00, 'ALIPAY', 'SUCCESS', CONCAT('ALI-',u.username,'-B'), NOW()-INTERVAL 3 DAY
FROM sys_user u WHERE u.username IN ('admin','student001','student002')
AND NOT EXISTS (SELECT 1 FROM recharge_record r WHERE r.order_no=CONCAT('RCHB-',u.username,'-002'));

-- 4) 支付记录（绑定到已存在的预约）
-- 为 student001 今日 A001 09-12 的预约生成支付记录（钱包支付，假设金额 9.00）
INSERT INTO payment_record (user_id, reservation_id, order_no, amount, payment_method, payment_status, remark)
SELECT u.id, r.id, CONCAT('PAY-',u.username,'-A001-TODAY-0900'), 9.00, 'WALLET', 'SUCCESS', 'auto paid'
FROM sys_user u
JOIN seat s ON s.seat_number='A001'
JOIN reservation r ON r.user_id=u.id AND r.seat_id=s.id AND r.reservation_date=CURDATE() AND r.start_time='09:00:00'
WHERE u.username='student001'
AND NOT EXISTS (SELECT 1 FROM payment_record p WHERE p.order_no=CONCAT('PAY-',u.username,'-A001-TODAY-0900'));

-- 为 student002 昨日 A002 14-17 的预约生成支付记录（微信支付 12.00）
INSERT INTO payment_record (user_id, reservation_id, order_no, amount, payment_method, payment_status, third_party_order_no, remark)
SELECT u.id, r.id, CONCAT('PAY-',u.username,'-A002-YEST-1400'), 12.00, 'WECHAT', 'SUCCESS', CONCAT('WX-P-',u.username,'-Y'), 'paid yesterday'
FROM sys_user u
JOIN seat s ON s.seat_number='A002'
JOIN reservation r ON r.user_id=u.id AND r.seat_id=s.id AND r.reservation_date=CURDATE()-INTERVAL 1 DAY AND r.start_time='14:00:00'
WHERE u.username='student002'
AND NOT EXISTS (SELECT 1 FROM payment_record p WHERE p.order_no=CONCAT('PAY-',u.username,'-A002-YEST-1400'));

-- 为 student001 上周 A015 10-16 的预约生成支付记录（支付宝 18.00）
INSERT INTO payment_record (user_id, reservation_id, order_no, amount, payment_method, payment_status, third_party_order_no, remark)
SELECT u.id, r.id, CONCAT('PAY-',u.username,'-A015-LW-1000'), 18.00, 'ALIPAY', 'SUCCESS', CONCAT('ALI-P-',u.username,'-LW'), 'paid last week'
FROM sys_user u
JOIN seat s ON s.seat_number='A015'
JOIN reservation r ON r.user_id=u.id AND r.seat_id=s.id AND r.reservation_date=CURDATE()-INTERVAL 7 DAY AND r.start_time='10:00:00'
WHERE u.username='student001'
AND NOT EXISTS (SELECT 1 FROM payment_record p WHERE p.order_no=CONCAT('PAY-',u.username,'-A015-LW-1000'));

-- 5) 同步钱包累计消费与余额
UPDATE user_wallet w
JOIN (
  SELECT user_id, IFNULL(SUM(amount),0) AS paid
  FROM payment_record
  WHERE payment_status='SUCCESS'
  GROUP BY user_id
) p ON p.user_id=w.user_id
SET w.total_consume = p.paid;

UPDATE user_wallet SET balance = GREATEST(total_recharge - total_consume, 0.00);

-- 6) 添加反馈示例
INSERT INTO feedback (user_id, type, content, status, created_time)
SELECT u.id, 'SUGGESTION', '建议：支持自定义常用时间段快速预约', 'PENDING', NOW()-INTERVAL 2 DAY
FROM sys_user u WHERE u.username='student001'
AND NOT EXISTS (SELECT 1 FROM feedback f WHERE f.user_id=u.id AND f.type='SUGGESTION');

INSERT INTO feedback (user_id, type, content, status, created_time)
SELECT u.id, 'BUG', '问题：某些浏览器下座位图缩放异常', 'PENDING', NOW()-INTERVAL 1 DAY
FROM sys_user u WHERE u.username='student002'
AND NOT EXISTS (SELECT 1 FROM feedback f WHERE f.user_id=u.id AND f.type='BUG');

-- 管理员回复第一条反馈
UPDATE feedback f
JOIN sys_user admin ON admin.username='admin'
SET f.reply='已记录，后续版本将加入快捷预约模板', f.status='REPLIED', f.replied_by=admin.id, f.replied_time=NOW()
WHERE f.type='SUGGESTION' AND f.reply IS NULL;

-- 汇总展示
SELECT 'wallets' AS t, COUNT(*) AS c FROM user_wallet
UNION ALL SELECT 'recharge', COUNT(*) FROM recharge_record
UNION ALL SELECT 'payments', COUNT(*) FROM payment_record
UNION ALL SELECT 'feedback', COUNT(*) FROM feedback;
