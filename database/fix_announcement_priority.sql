-- 修复公告表 priority 字段类型
USE seat_reservation;

-- 1. 修改 priority 字段类型从 INT 改为 VARCHAR
ALTER TABLE sys_announcement
MODIFY COLUMN priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM' COMMENT '优先级：LOW-低, MEDIUM-中, HIGH-高';

-- 2. 更新现有数据，将数字转换为字符串
UPDATE sys_announcement
SET priority = CASE
    WHEN priority = '1' THEN 'LOW'
    WHEN priority = '2' THEN 'MEDIUM'
    WHEN priority = '3' THEN 'HIGH'
    ELSE priority
END
WHERE priority IN ('1', '2', '3');

-- 3. 验证修改结果
SELECT
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT,
    COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'seat_reservation'
  AND TABLE_NAME = 'sys_announcement'
  AND COLUMN_NAME = 'priority';

-- 4. 显示现有公告数据
SELECT id, title, priority, status FROM sys_announcement;