-- 为用户表添加头像字段
ALTER TABLE sys_user ADD COLUMN avatar_url VARCHAR(500) COMMENT '用户头像URL';

-- 为座位类型表添加图片字段（如果需要）
-- ALTER TABLE seat_type ADD COLUMN image_url VARCHAR(500) COMMENT '座位类型图片URL';

-- 创建自习室表（如果还没有的话）
CREATE TABLE IF NOT EXISTS study_room (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '自习室ID',
    room_name VARCHAR(100) NOT NULL COMMENT '自习室名称',
    room_number VARCHAR(50) NOT NULL COMMENT '自习室编号',
    floor_number INT NOT NULL COMMENT '楼层',
    description TEXT COMMENT '自习室描述',
    image_url VARCHAR(500) COMMENT '自习室图片URL',
    capacity INT DEFAULT 0 COMMENT '容量',
    status VARCHAR(20) DEFAULT 'AVAILABLE' COMMENT '状态：AVAILABLE-可用, MAINTENANCE-维护中, DISABLED-禁用',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT='自习室表';

-- 创建公告表
CREATE TABLE IF NOT EXISTS announcement (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '公告ID',
    title VARCHAR(200) NOT NULL COMMENT '公告标题',
    content TEXT NOT NULL COMMENT '公告内容',
    summary VARCHAR(500) COMMENT '公告摘要',
    is_top BOOLEAN DEFAULT FALSE COMMENT '是否置顶',
    status VARCHAR(20) DEFAULT 'PUBLISHED' COMMENT '状态：DRAFT-草稿, PUBLISHED-已发布, ARCHIVED-已归档',
    publish_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
    created_by BIGINT COMMENT '创建者ID',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_publish_time (publish_time),
    INDEX idx_status (status),
    INDEX idx_is_top (is_top)
) COMMENT='公告表';

-- 创建意见反馈表
CREATE TABLE IF NOT EXISTS feedback (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '反馈ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    type VARCHAR(20) NOT NULL COMMENT '反馈类型：SUGGESTION-建议, BUG-问题, COMPLAINT-投诉, OTHER-其他',
    content TEXT NOT NULL COMMENT '反馈内容',
    reply TEXT COMMENT '管理员回复',
    status VARCHAR(20) DEFAULT 'PENDING' COMMENT '状态：PENDING-待处理, REPLIED-已回复, CLOSED-已关闭',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    replied_time TIMESTAMP NULL COMMENT '回复时间',
    replied_by BIGINT COMMENT '回复者ID',
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_type (type),
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE
) COMMENT='意见反馈表';

-- 创建消息通知表
CREATE TABLE IF NOT EXISTS notification (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '通知ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    title VARCHAR(200) NOT NULL COMMENT '通知标题',
    content TEXT NOT NULL COMMENT '通知内容',
    type VARCHAR(20) NOT NULL COMMENT '通知类型：RESERVATION-预约相关, SYSTEM-系统通知, ANNOUNCEMENT-公告',
    is_read BOOLEAN DEFAULT FALSE COMMENT '是否已读',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    read_time TIMESTAMP NULL COMMENT '阅读时间',
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_type (type),
    INDEX idx_created_time (created_time),
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE
) COMMENT='消息通知表';