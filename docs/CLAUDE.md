# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个自习室座位预约系统，采用前后端分离架构：
- 后端：Spring Boot + MyBatis Plus + MySQL + Spring Security + JWT
- 前端：Vue 3 + Vite + Element Plus + Pinia + Vue Router

## 架构结构

### 后端架构 (seat-reservation-backend)
- **端口**: 8085
- **API 前缀**: `/api`
- **主要技术栈**: Spring Boot 2.7.18 + Java 8 + MySQL
- **认证方式**: JWT Token (Bearer Authentication)
- **数据库**: MySQL (端口 3306, 数据库名: seat_reservation)

**分层架构**:
```
controller/ - REST API 控制器层
├── AuthController - 登录注册认证
├── UserController - 用户管理
├── SeatController - 座位管理
├── ReservationController - 预约管理
├── StatisticsController - 统计分析
├── PaymentController - 支付功能
├── SeatFavoriteController - 座位收藏
└── AnnouncementController - 公告管理

service/ - 业务逻辑服务层
├── impl/ - 服务实现类

entity/ - 数据实体类
├── User - 用户实体 (角色: ADMIN/STUDENT)
├── Seat - 座位实体
├── Reservation - 预约实体
├── UserWallet - 用户钱包
├── PaymentRecord - 支付记录
└── Announcement - 公告实体

mapper/ - MyBatis 数据访问层
config/ - 配置类 (Security, CORS, MyBatis Plus)
filter/ - JWT 认证过滤器
utils/ - 工具类 (JWT, 密码加密, 响应结果)
```

### 前端架构 (seat-reservation-frontend)
- **端口**: 3000
- **主要技术栈**: Vue 3 + Vite + Element Plus
- **状态管理**: Pinia
- **路由**: Vue Router
- **API 代理**: localhost:8085/api

**目录结构**:
```
src/
├── views/ - 页面组件
│   ├── Login.vue - 登录页面
│   ├── Register.vue - 注册页面
│   ├── Home.vue - 首页
│   ├── SeatMap.vue - 座位地图
│   ├── Reservations.vue - 我的预约
│   ├── Profile.vue - 个人资料
│   ├── Favorites.vue - 座位收藏
│   └── admin/ - 管理员后台子页面
│       ├── Dashboard.vue - 数据看板
│       ├── Seats.vue - 座位管理
│       ├── Reservations.vue - 预约管理
│       ├── Users.vue - 用户管理
│       ├── Announcements.vue - 公告管理
│       ├── Reports.vue - 报表统计
│       └── Settings.vue - 系统设置
├── components/ - 通用组件
│   └── AdminLayout.vue - 管理员布局组件
├── router/ - 路由配置 (支持子路由)
├── api/ - API 接口封装
│   ├── seat.js - 座位相关API
│   ├── user.js - 用户相关API
│   ├── statistics.js - 统计相关API
│   └── seatFavorite.js - 座位收藏API
├── stores/ - Pinia状态管理
│   └── user.js - 用户状态
└── utils/ - 工具函数
```

## 常用开发命令

### 后端开发 (Windows CMD)
```cmd
# 进入后端目录
cd seat-reservation-backend

# 启动开发服务器
mvn spring-boot:run

# 编译项目
mvn clean compile

# 运行测试
mvn test

# 打包项目
mvn clean package
```

### 前端开发
```cmd
# 进入前端目录
cd seat-reservation-frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 预览构建结果
npm run preview
```

## 数据库配置

- **数据库**: MySQL 8.0
- **连接信息**: localhost:3306/seat_reservation
- **用户名**: root
- **密码**: 1234

## 测试账号

**管理员账号**:
- 用户名: admin
- 密码: admin123

**学生账号**:
- 用户名: student001
- 密码: 123456

## 重要配置

### JWT 配置
- Secret: seatReservationSecretKey2023ForJWTTokenGeneration256Bits
- 过期时间: 24小时
- Header: Authorization
- 前缀: "Bearer "

### 跨域配置
前端默认代理后端 API 到 `http://localhost:8085/api`

### 文件上传
- 上传目录: ./uploads
- 最大文件大小: 5MB

## 核心功能模块

1. **用户认证系统** - JWT + Spring Security
2. **座位管理** - 座位类型、状态管理
3. **预约系统** - 时间段预约、状态跟踪
4. **用户管理** - 学生/管理员权限控制
5. **统计分析** - 预约数据统计图表
6. **支付系统** - 钱包充值、预约付费
7. **公告系统** - 系统公告发布管理
8. **座位收藏** - 用户座位收藏功能

## 路由架构

### 管理员后台子路由
管理员后台已重构为子路由架构，提供更好的URL导航和用户体验：

```
/admin - AdminLayout 布局组件
├── /admin/dashboard - 数据看板 (真实API数据)
├── /admin/seats - 座位管理 (修复删除bug)
├── /admin/reservations - 预约管理 (完善详情功能)
├── /admin/users - 用户管理
├── /admin/announcements - 公告管理
├── /admin/reports - 报表统计
└── /admin/settings - 系统设置 (完整功能)
```

### 关键修复和改进
1. **座位删除bug修复**: 添加删除状态管理，改进错误处理
2. **数据看板真实API**: 替换硬编码数据，使用 statisticsApi
3. **预约详情完善**: 增加操作历史、详细信息展示
4. **系统设置完整**: 支持基础、预约、时间、支付、邮件、安全配置

## 开发注意事项

- 后端使用 MyBatis Plus 进行数据库操作
- 密码使用 BCrypt 加密存储
- 所有 API 需要 JWT Token 认证 (除登录注册外)
- 前后端通过 RESTful API 通信
- 使用枚举类型管理座位状态、用户角色等
- 数据库设计支持逻辑删除
- 前端使用 Element Plus 组件库
- 管理员功能需要 ADMIN 角色权限
- 使用子路由架构，每个管理模块都有独立的URL
- 数据看板使用真实API数据，支持图表渲染

## API 文档

开发环境 API 文档地址: http://localhost:8085/doc.html (如果配置了 Swagger)

## 部署信息

- 前端构建输出: `seat-reservation-frontend/dist/`
- 后端打包输出: `seat-reservation-backend/target/`
- 建议使用 Docker 或直接部署到服务器