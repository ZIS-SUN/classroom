-- 创建系统设置表
CREATE TABLE IF NOT EXISTS `system_settings` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    `setting_key` VARCHAR(100) NOT NULL COMMENT '设置键名',
    `setting_value` TEXT COMMENT '设置值(JSON格式)',
    `setting_type` VARCHAR(50) NOT NULL COMMENT '设置类型(basic/reservation/schedule/payment/email/security)',
    `description` VARCHAR(255) COMMENT '设置描述',
    `created_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_setting_key_type` (`setting_key`, `setting_type`),
    INDEX `idx_setting_type` (`setting_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统设置表';

-- 插入默认系统设置
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `description`) VALUES
-- 基础设置
('systemName', '"自习室座位预约系统"', 'basic', '系统名称'),
('systemDescription', '"智能化的自习室座位预约管理系统"', 'basic', '系统描述'),
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