# 数据库初始化和统计功能说明

## 📁 文件说明

### 主要脚本
- **init_database.sql** - 完整的数据库初始化脚本（包含表结构、测试数据、统计视图）
- **fix_admin_password.sql** - 修复管理员密码脚本
- **fix_announcement_priority.sql** - 修复公告优先级字段类型脚本

## 🚀 快速开始

### 1. 初始化数据库

**方式一：命令行导入**
```bash
# Windows
cd /d C:\path\to\database
mysql -u root -p < init_database.sql

# Mac/Linux
cd /path/to/database
mysql -u root -p < init_database.sql
```

**方式二：MySQL客户端**
```sql
SOURCE /path/to/init_database.sql;
```

### 2. 测试账号

| 角色 | 用户名 | 密码 | 说明 |
|------|--------|------|------|
| 管理员 | admin | admin123 | 系统管理员账号 |
| 学生 | student001 | 123456 | 测试学生账号1 |
| 学生 | student002 | 123456 | 测试学生账号2 |
| 学生 | student003 | 123456 | 测试学生账号3 |
| 学生 | student004 | 123456 | 测试学生账号4 |
| 学生 | student005 | 123456 | 测试学生账号5 |

## 📊 统计视图详解

系统提供了5个统计视图，用于数据分析和报表生成：

### 1. daily_statistics - 每日统计
**字段说明：**
- `stat_date` - 统计日期
- `total_reservations` - 当日预约总数
- `completed_count` - 已完成预约数
- `cancelled_count` - 已取消预约数
- `expired_count` - 已过期预约数
- `active_users` - 活跃用户数
- `total_revenue` - 当日总收入
- `avg_usage_hours` - 平均使用时长（小时）

**使用示例：**
```sql
-- 查询最近7天的统计数据
SELECT * FROM daily_statistics
WHERE stat_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY stat_date DESC;

-- 查询本月的总预约数和收入
SELECT
    SUM(total_reservations) as month_reservations,
    SUM(total_revenue) as month_revenue,
    AVG(active_users) as avg_daily_users
FROM daily_statistics
WHERE stat_date >= DATE_FORMAT(NOW(), '%Y-%m-01');
```

### 2. seat_utilization - 座位使用率统计
**字段说明：**
- `seat_id` - 座位ID
- `seat_number` - 座位编号
- `area` - 所属区域
- `type_name` - 座位类型
- `total_bookings` - 总预订次数
- `completed_bookings` - 完成次数
- `total_usage_hours` - 总使用时长
- `completion_rate` - 完成率（%）

**使用示例：**
```sql
-- 查询最受欢迎的座位TOP10
SELECT * FROM seat_utilization
WHERE total_bookings > 0
ORDER BY total_bookings DESC
LIMIT 10;

-- 查询A区的座位使用情况
SELECT * FROM seat_utilization
WHERE area = 'A区'
ORDER BY completion_rate DESC;

-- 查询使用率低的座位（可能需要优化位置）
SELECT * FROM seat_utilization
WHERE total_bookings > 0
ORDER BY completion_rate ASC
LIMIT 10;
```

### 3. user_activity - 用户活跃度统计
**字段说明：**
- `user_id` - 用户ID
- `username` - 用户名
- `real_name` - 真实姓名
- `total_reservations` - 总预约次数
- `completed_reservations` - 完成次数
- `cancelled_reservations` - 取消次数
- `total_spending` - 总消费金额
- `current_balance` - 当前余额
- `total_recharge` - 累计充值
- `last_reservation_time` - 最后预约时间

**使用示例：**
```sql
-- 查询最活跃用户TOP10
SELECT * FROM user_activity
ORDER BY total_reservations DESC
LIMIT 10;

-- 查询高消费用户
SELECT * FROM user_activity
WHERE total_spending > 100
ORDER BY total_spending DESC;

-- 查询余额不足的用户（可能需要充值提醒）
SELECT * FROM user_activity
WHERE current_balance < 20
ORDER BY current_balance ASC;

-- 查询流失用户（超过7天未预约）
SELECT * FROM user_activity
WHERE last_reservation_time < DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY last_reservation_time ASC;
```

### 4. revenue_statistics - 收入统计
**字段说明：**
- `revenue_date` - 收入日期
- `payment_count` - 支付笔数
- `daily_revenue` - 当日总收入
- `wallet_revenue` - 钱包支付收入
- `wechat_revenue` - 微信支付收入
- `alipay_revenue` - 支付宝支付收入
- `paying_users` - 付费用户数

**使用示例：**
```sql
-- 查询最近30天的收入趋势
SELECT * FROM revenue_statistics
WHERE revenue_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY revenue_date DESC;

-- 查询本月各支付方式占比
SELECT
    SUM(daily_revenue) as total,
    SUM(wallet_revenue) as wallet,
    SUM(wechat_revenue) as wechat,
    SUM(alipay_revenue) as alipay,
    ROUND(SUM(wallet_revenue) / SUM(daily_revenue) * 100, 2) as wallet_percent,
    ROUND(SUM(wechat_revenue) / SUM(daily_revenue) * 100, 2) as wechat_percent,
    ROUND(SUM(alipay_revenue) / SUM(daily_revenue) * 100, 2) as alipay_percent
FROM revenue_statistics
WHERE revenue_date >= DATE_FORMAT(NOW(), '%Y-%m-01');

-- 查询收入最高的一天
SELECT * FROM revenue_statistics
ORDER BY daily_revenue DESC
LIMIT 1;
```

### 5. time_slot_popularity - 时段热度统计
**字段说明：**
- `hour_slot` - 时段（小时）
- `booking_count` - 预订次数
- `completed_count` - 完成次数
- `avg_duration_hours` - 平均使用时长

**使用示例：**
```sql
-- 查询最热门的时段TOP5
SELECT
    CONCAT(hour_slot, ':00-', hour_slot+1, ':00') as time_range,
    booking_count,
    completed_count,
    avg_duration_hours
FROM time_slot_popularity
WHERE booking_count > 0
ORDER BY booking_count DESC
LIMIT 5;

-- 查询上午时段（8:00-12:00）的预约情况
SELECT
    CONCAT(hour_slot, ':00-', hour_slot+1, ':00') as time_range,
    booking_count,
    completed_count,
    ROUND(completed_count * 100.0 / booking_count, 2) as completion_rate
FROM time_slot_popularity
WHERE hour_slot BETWEEN 8 AND 11
ORDER BY hour_slot;

-- 查询冷门时段（可考虑优惠策略）
SELECT * FROM time_slot_popularity
WHERE booking_count > 0
ORDER BY booking_count ASC
LIMIT 5;
```

## 📈 综合统计查询示例

### 1. 系统总览仪表板
```sql
SELECT
    '总用户数' as metric, COUNT(*) as value FROM sys_user WHERE role = 'STUDENT'
UNION ALL
SELECT '总预约数', COUNT(*) FROM reservation
UNION ALL
SELECT '已完成预约', COUNT(*) FROM reservation WHERE status = 'COMPLETED'
UNION ALL
SELECT '总收入', ROUND(SUM(amount), 2) FROM payment_record WHERE payment_status = 'SUCCESS'
UNION ALL
SELECT '活跃座位数', COUNT(DISTINCT seat_id) FROM reservation WHERE status = 'COMPLETED'
UNION ALL
SELECT '平均座位使用率', ROUND(AVG(completion_rate), 2) FROM seat_utilization WHERE total_bookings > 0;
```

### 2. 本周运营数据对比
```sql
-- 本周 vs 上周
SELECT
    '本周' as period,
    COUNT(*) as reservations,
    COUNT(DISTINCT user_id) as active_users,
    COALESCE(SUM(total_fee), 0) as revenue
FROM reservation
WHERE created_time >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY)

UNION ALL

SELECT
    '上周' as period,
    COUNT(*) as reservations,
    COUNT(DISTINCT user_id) as active_users,
    COALESCE(SUM(total_fee), 0) as revenue
FROM reservation
WHERE created_time >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 7 DAY)
  AND created_time < DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY);
```

### 3. 用户行为分析
```sql
-- 用户分层统计
SELECT
    CASE
        WHEN total_reservations >= 20 THEN '高频用户'
        WHEN total_reservations >= 10 THEN '中频用户'
        WHEN total_reservations >= 5 THEN '低频用户'
        ELSE '新用户'
    END as user_level,
    COUNT(*) as user_count,
    AVG(total_spending) as avg_spending,
    SUM(total_spending) as total_spending
FROM user_activity
GROUP BY user_level
ORDER BY AVG(total_reservations) DESC;
```

### 4. 座位类型偏好分析
```sql
SELECT
    st.type_name,
    COUNT(DISTINCT r.id) as booking_count,
    AVG(st.hourly_rate) as avg_rate,
    SUM(p.amount) as total_revenue
FROM seat s
JOIN seat_type st ON s.seat_type_id = st.id
LEFT JOIN reservation r ON s.id = r.seat_id
LEFT JOIN payment_record p ON r.id = p.reservation_id AND p.payment_status = 'SUCCESS'
GROUP BY st.type_name, st.hourly_rate
ORDER BY booking_count DESC;
```

## 🛠️ 常见问题

### Q1: 管理员密码忘记了怎么办？
A: 执行 `fix_admin_password.sql` 脚本，密码将重置为 `admin123`

### Q2: 公告创建失败，提示 priority 字段错误？
A: 执行 `fix_announcement_priority.sql` 脚本修复字段类型

### Q3: 如何清空测试数据但保留表结构？
```sql
-- 禁用外键检查
SET FOREIGN_KEY_CHECKS = 0;

-- 清空数据（保留表结构）
TRUNCATE TABLE reservation;
TRUNCATE TABLE payment_record;
TRUNCATE TABLE recharge_record;
TRUNCATE TABLE user_wallet;
TRUNCATE TABLE seat_favorite;
TRUNCATE TABLE feedback;
TRUNCATE TABLE notification;
TRUNCATE TABLE operation_log;
TRUNCATE TABLE sys_announcement;

-- 只保留管理员账号
DELETE FROM sys_user WHERE role = 'STUDENT';

-- 启用外键检查
SET FOREIGN_KEY_CHECKS = 1;
```

### Q4: 如何备份数据库？
```bash
# 备份整个数据库
mysqldump -u root -p seat_reservation > backup_$(date +%Y%m%d).sql

# 只备份表结构
mysqldump -u root -p --no-data seat_reservation > structure_only.sql

# 只备份数据
mysqldump -u root -p --no-create-info seat_reservation > data_only.sql
```

## 📝 更新日志

### Version 2.0 (2024-09-30)
- ✅ 修复管理员密码哈希问题
- ✅ 修复公告优先级字段类型（INT → VARCHAR）
- ✅ 添加40+条测试预约记录（覆盖30天）
- ✅ 添加28条支付记录（多种支付方式）
- ✅ 添加13条充值记录（多种状态）
- ✅ 添加6条意见反馈
- ✅ 添加13条通知记录
- ✅ 添加14条操作日志
- ✅ 新增5个统计视图（用于报表分析）
- ✅ 完善测试数据和文档说明

### Version 1.0 (2024-09-01)
- 初始版本，包含基础表结构和少量测试数据

## 📞 技术支持

如有问题，请查看：
- 项目文档：`/docs` 目录
- 数据库ER图：`/docs/database_design.md`
- API文档：`/docs/api.md`

---

**注意：** 本数据库脚本仅用于开发和测试环境，生产环境部署前请务必修改默认密码并调整安全配置！