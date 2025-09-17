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