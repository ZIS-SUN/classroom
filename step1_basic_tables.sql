USE seat_reservation;

-- 清理测试表
DROP TABLE IF EXISTS test_table;

-- 1. 用户表
CREATE TABLE sys_user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    real_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    student_id VARCHAR(20),
    role VARCHAR(20) DEFAULT 'STUDENT',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    avatar_url VARCHAR(255),
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. 座位类型表
CREATE TABLE seat_type (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    hourly_rate DECIMAL(5,2) DEFAULT 0.00,
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. 座位表  
CREATE TABLE seat (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    seat_number VARCHAR(20) NOT NULL UNIQUE,
    floor_number INT NOT NULL,
    area VARCHAR(50) NOT NULL,
    seat_type_id INT NOT NULL,
    position_x INT,
    position_y INT, 
    status VARCHAR(20) DEFAULT 'AVAILABLE',
    has_power BOOLEAN DEFAULT TRUE,
    has_computer BOOLEAN DEFAULT FALSE,
    description VARCHAR(200),
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 4. 预约表
CREATE TABLE reservation (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    seat_id BIGINT NOT NULL,
    reservation_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status VARCHAR(20) DEFAULT 'RESERVED',
    check_in_time TIMESTAMP NULL,
    check_out_time TIMESTAMP NULL,
    total_fee DECIMAL(8,2) DEFAULT 0.00,
    remark VARCHAR(500),
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 5. 系统配置表
CREATE TABLE sys_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL UNIQUE,
    config_value VARCHAR(500) NOT NULL,
    config_desc VARCHAR(200),
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 6. 操作日志表
CREATE TABLE operation_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    operation_type VARCHAR(50) NOT NULL,
    operation_desc VARCHAR(500),
    request_method VARCHAR(10),
    request_url VARCHAR(200),
    ip_address VARCHAR(50),
    created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);