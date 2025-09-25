USE seat_reservation;

-- 检查reservation表的status字段长度
DESCRIBE reservation;

-- 如果需要，扩展status字段长度  
ALTER TABLE reservation MODIFY COLUMN status VARCHAR(50) DEFAULT 'RESERVED';

-- 显示更新后的表结构
DESCRIBE reservation;