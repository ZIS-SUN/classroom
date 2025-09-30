USE seat_reservation;

-- 更新管理员密码为admin123的正确BCrypt哈希值
UPDATE sys_user 
SET password = '$2a$10$mWVFhP12Yq7RPsMhB5a.6uH0rXIg2/98o8poBDaklbCoUHGXxoC9u' 
WHERE username = 'admin';

-- 验证更新结果
SELECT id, username, password, real_name, role, status 
FROM sys_user 
WHERE username = 'admin';