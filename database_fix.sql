-- Database Fix Script for Seat Reservation System
-- Execute this script in MySQL to fix the issues

USE seat_reservation;

-- 1. Create announcement table
CREATE TABLE IF NOT EXISTS sys_announcement (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary Key',
    title VARCHAR(200) NOT NULL COMMENT 'Title',
    content TEXT NOT NULL COMMENT 'Content',
    type VARCHAR(20) NOT NULL DEFAULT 'NOTICE' COMMENT 'Type: NOTICE, ANNOUNCEMENT, MAINTENANCE',
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT' COMMENT 'Status: DRAFT, PUBLISHED, ARCHIVED',
    author_id BIGINT NOT NULL COMMENT 'Author ID',
    author_name VARCHAR(50) NOT NULL COMMENT 'Author Name',
    priority INT NOT NULL DEFAULT 2 COMMENT 'Priority: 1-Low, 2-Medium, 3-High',
    publish_time DATETIME NULL COMMENT 'Publish Time',
    expire_time DATETIME NULL COMMENT 'Expire Time',
    view_count INT NOT NULL DEFAULT 0 COMMENT 'View Count',
    created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created Time',
    updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated Time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Announcement Table';

-- 2. Create indexes for announcement table (MySQL compatible syntax)
-- Drop indexes if they exist, then create them
DROP INDEX IF EXISTS idx_status_priority_publish_time ON sys_announcement;
CREATE INDEX idx_status_priority_publish_time ON sys_announcement (status, priority, publish_time);

DROP INDEX IF EXISTS idx_author_id ON sys_announcement;
CREATE INDEX idx_author_id ON sys_announcement (author_id);

DROP INDEX IF EXISTS idx_type_status ON sys_announcement;
CREATE INDEX idx_type_status ON sys_announcement (type, status);

DROP INDEX IF EXISTS idx_expire_time ON sys_announcement;
CREATE INDEX idx_expire_time ON sys_announcement (expire_time);

-- 3. Insert sample announcement data
INSERT IGNORE INTO sys_announcement (title, content, type, status, author_id, author_name, priority, publish_time, expire_time, view_count) VALUES
('System Online Notice', 'The seat reservation system is now online. You can reserve seats in advance to avoid no available seats when you arrive. Please use the reservation feature reasonably and maintain a good learning environment.', 'ANNOUNCEMENT', 'PUBLISHED', 1, 'System Admin', 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 15),
('Seat Usage Rules', 'Please note:\n1. Please arrive on time after reservation, automatic cancellation after 30 minutes\n2. Please check out if you leave for more than 2 hours\n3. Keep the seat clean and use it civilly\n4. Please cancel in advance if you need to cancel the reservation', 'NOTICE', 'PUBLISHED', 1, 'System Admin', 2, NOW(), NULL, 8),
('Maintenance Notice', 'Due to system upgrade needs, the reservation system will undergo routine maintenance every Sunday from 2:00-4:00 AM, during which some functions may not be available. Please arrange in advance, we apologize for any inconvenience.', 'MAINTENANCE', 'PUBLISHED', 1, 'System Admin', 2, NOW(), NULL, 3);

-- 4. Update user passwords (fix login issues)
-- Admin password: admin123
UPDATE sys_user SET password = '$2a$10$N4VKaCI8m7XwlvGLfGz4aOKBOxk9FLLCXqT5t4v8QHgtsFLLp5x6a' WHERE username = 'admin';

-- Student test account password: 123456
UPDATE sys_user SET password = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.' WHERE username IN ('student001', 'student002');

-- 5. Verify data
SELECT 'User Accounts:' AS info;
SELECT id, username, real_name, role, status, created_time FROM sys_user;

SELECT 'Announcement Data:' AS info;
SELECT id, title, type, status, author_name, view_count, created_time FROM sys_announcement;

SELECT 'Seat Data:' AS info;
SELECT COUNT(*) AS total_seats, 
       SUM(CASE WHEN status = 'AVAILABLE' THEN 1 ELSE 0 END) AS available_seats,
       SUM(CASE WHEN status = 'OCCUPIED' THEN 1 ELSE 0 END) AS occupied_seats
FROM seat;

COMMIT; 