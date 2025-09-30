-- 创建支付相关数据表

-- 用户钱包表
CREATE TABLE IF NOT EXISTS user_wallet (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE,
    balance DECIMAL(10,2) DEFAULT 0.00 COMMENT '余额',
    total_recharge DECIMAL(10,2) DEFAULT 0.00 COMMENT '累计充值',
    total_consume DECIMAL(10,2) DEFAULT 0.00 COMMENT '累计消费',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) COMMENT='用户钱包表';

-- 充值记录表
CREATE TABLE IF NOT EXISTS recharge_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    order_no VARCHAR(64) NOT NULL UNIQUE COMMENT '充值订单号',
    amount DECIMAL(10,2) NOT NULL COMMENT '充值金额',
    bonus_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT '赠送金额',
    payment_method VARCHAR(20) NOT NULL COMMENT '支付方式：WECHAT, ALIPAY, BANK_CARD',
    payment_status VARCHAR(20) DEFAULT 'PENDING' COMMENT '支付状态：PENDING, SUCCESS, FAILED, CANCELLED',
    third_party_order_no VARCHAR(128) COMMENT '第三方订单号',
    remark TEXT COMMENT '备注',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_order_no (order_no),
    INDEX idx_payment_status (payment_status)
) COMMENT='充值记录表';

-- 支付记录表
CREATE TABLE IF NOT EXISTS payment_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    reservation_id BIGINT NOT NULL,
    order_no VARCHAR(64) NOT NULL UNIQUE COMMENT '支付订单号',
    amount DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    payment_method VARCHAR(20) NOT NULL COMMENT '支付方式：WALLET, WECHAT, ALIPAY, BANK_CARD',
    payment_status VARCHAR(20) DEFAULT 'PENDING' COMMENT '支付状态：PENDING, SUCCESS, FAILED, CANCELLED, REFUNDED',
    third_party_order_no VARCHAR(128) COMMENT '第三方订单号',
    refund_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT '退款金额',
    refund_time DATETIME COMMENT '退款时间',
    remark TEXT COMMENT '备注',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE,
    FOREIGN KEY (reservation_id) REFERENCES reservation(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_reservation_id (reservation_id),
    INDEX idx_order_no (order_no),
    INDEX idx_payment_status (payment_status)
) COMMENT='支付记录表';

-- 添加一些初始钱包数据（为现有用户创建钱包）
INSERT IGNORE INTO user_wallet (user_id, balance, total_recharge) 
SELECT id, 
       CASE 
           WHEN id = 1 THEN 1000.00  -- 管理员账户
           WHEN id <= 5 THEN 100.00  -- 前几个用户有余额
           WHEN id <= 10 THEN 50.00  -- 中间用户有少量余额
           ELSE 0.00                 -- 其他用户无余额
       END as balance,
       CASE 
           WHEN id = 1 THEN 1000.00
           WHEN id <= 5 THEN 100.00
           WHEN id <= 10 THEN 50.00
           ELSE 0.00
       END as total_recharge
FROM `user`;

-- 插入一些测试充值记录
INSERT INTO recharge_record (user_id, order_no, amount, bonus_amount, payment_method, payment_status, third_party_order_no, created_time) VALUES
(2, 'RCH202409130001', 100.00, 10.00, 'WECHAT', 'SUCCESS', 'WX2024091312345678901', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(3, 'RCH202409130002', 50.00, 5.00, 'ALIPAY', 'SUCCESS', 'ALI2024091312345678901', DATE_SUB(NOW(), INTERVAL 5 DAY)),
(4, 'RCH202409130003', 200.00, 30.00, 'BANK_CARD', 'SUCCESS', 'BANK2024091312345678901', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(5, 'RCH202409130004', 30.00, 0.00, 'WECHAT', 'SUCCESS', 'WX2024091312345678902', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(6, 'RCH202409130005', 100.00, 10.00, 'ALIPAY', 'SUCCESS', 'ALI2024091312345678902', DATE_SUB(NOW(), INTERVAL 1 DAY));

-- 插入一些测试支付记录
INSERT INTO payment_record (user_id, reservation_id, order_no, amount, payment_method, payment_status, third_party_order_no, created_time) VALUES
(2, 1, 'PAY202409130001', 7.50, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(3, 2, 'PAY202409130002', 10.00, 'WECHAT', 'SUCCESS', 'WX_PAY2024091312345678901', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(4, 3, 'PAY202409130003', 18.00, 'ALIPAY', 'SUCCESS', 'ALI_PAY2024091312345678901', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(5, 4, 'PAY202409130004', 32.00, 'WALLET', 'SUCCESS', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY));