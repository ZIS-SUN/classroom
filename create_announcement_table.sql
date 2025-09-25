-- 创建公告表
CREATE TABLE IF NOT EXISTS sys_announcement (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    title VARCHAR(200) NOT NULL COMMENT '公告标题',
    content TEXT NOT NULL COMMENT '公告内容',
    type VARCHAR(20) NOT NULL DEFAULT 'NOTICE' COMMENT '公告类型：NOTICE-通知, ANNOUNCEMENT-公告, URGENT-紧急',
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT' COMMENT '公告状态：DRAFT-草稿, PUBLISHED-已发布, ARCHIVED-已归档',
    author_id BIGINT NOT NULL COMMENT '作者ID',
    author_name VARCHAR(50) NOT NULL COMMENT '作者姓名',
    priority INT NOT NULL DEFAULT 2 COMMENT '优先级：1-低, 2-中, 3-高',
    publish_time DATETIME NULL COMMENT '发布时间',
    expire_time DATETIME NULL COMMENT '过期时间',
    view_count INT NOT NULL DEFAULT 0 COMMENT '浏览次数',
    created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统公告表';

-- 创建索引
CREATE INDEX idx_status_priority_publish_time ON sys_announcement (status, priority, publish_time);
CREATE INDEX idx_author_id ON sys_announcement (author_id);
CREATE INDEX idx_type_status ON sys_announcement (type, status);
CREATE INDEX idx_expire_time ON sys_announcement (expire_time);

-- 插入示例数据
INSERT INTO sys_announcement (title, content, type, status, author_id, author_name, priority, publish_time, expire_time, view_count) VALUES
('图书馆座位预约系统正式上线', '亲爱的同学们，图书馆座位预约系统已正式上线运行。大家可以通过系统提前预约座位，避免到馆后无座位的困扰。请合理使用预约功能，共同维护良好的学习环境。', 'ANNOUNCEMENT', 'PUBLISHED', 1, '系统管理员', 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 0),
('预约座位使用须知', '请各位同学注意：\n1. 预约后请按时到达，超过30分钟未签到将自动取消预约\n2. 离开座位超过2小时请记得签退\n3. 保持座位整洁，文明用座\n4. 如需取消预约，请提前在系统中操作', 'NOTICE', 'PUBLISHED', 1, '系统管理员', 2, NOW(), NULL, 0),
('紧急通知：系统维护公告', '由于系统升级需要，预约系统将于今晚23:00-次日6:00进行维护，期间无法使用预约功能。请各位同学提前安排，给您带来的不便深表歉意。', 'URGENT', 'PUBLISHED', 1, '系统管理员', 3, NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 0);