-- 修复管理员密码
-- 密码：admin123
-- 新的BCrypt哈希

USE seat_reservation;

UPDATE sys_user
SET password = '$2a$10$aj0.DKdRT7r3VCJCjkJC8OKpbImydBgQe9ACXj1p3/eKYk0dk0Tta'
WHERE username = 'admin';

SELECT username, real_name, role, '密码已重置为: admin123' as note
FROM sys_user
WHERE username = 'admin';