USE seat_reservation;

-- 创建座位收藏表
CREATE TABLE seat_favorite (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    seat_id BIGINT NOT NULL,
    favorite_name VARCHAR(50) DEFAULT NULL COMMENT '收藏备注名称',
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES seat(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_seat (user_id, seat_id) COMMENT '用户-座位唯一约束'
);

-- 添加索引优化查询
CREATE INDEX idx_user_id ON seat_favorite(user_id);
CREATE INDEX idx_seat_id ON seat_favorite(seat_id);

-- 插入一些测试数据
INSERT INTO seat_favorite (user_id, seat_id, favorite_name) VALUES
(1, 2, '我的常用座位'),
(1, 5, '靠窗位置');

-- 显示创建的表结构
DESCRIBE seat_favorite;