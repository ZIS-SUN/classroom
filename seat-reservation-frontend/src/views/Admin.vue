<template>
  <AdminLayout @menu-change="handleMenuChange">
    <!-- 数据看板 -->
    <div v-if="currentView === 'dashboard'" class="dashboard">
      <!-- 统计卡片 - 现代化设计 -->
      <el-row :gutter="20" class="stat-cards">
        <el-col :xs="24" :sm="12" :md="6">
          <el-card class="stat-card today-reservations" shadow="hover">
            <div class="stat-content">
              <div class="stat-icon">
                <el-icon><Calendar /></el-icon>
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ animatedNumbers.todayReservations }}</div>
                <div class="stat-label">今日预约</div>
              </div>
            </div>
            <div class="stat-trend">
              <span class="trend-value positive">+12%</span>
              <span class="trend-text">比昨日</span>
            </div>
            <div class="stat-pattern"></div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :sm="12" :md="6">
          <el-card class="stat-card total-seats" shadow="hover">
            <div class="stat-content">
              <div class="stat-icon">
                <el-icon><Grid /></el-icon>
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ animatedNumbers.totalSeats }}</div>
                <div class="stat-label">总座位数</div>
              </div>
            </div>
            <div class="stat-trend">
              <span class="trend-value neutral">{{ animatedNumbers.availableSeats }}</span>
              <span class="trend-text">可用座位</span>
            </div>
            <div class="stat-pattern"></div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :sm="12" :md="6">
          <el-card class="stat-card active-users" shadow="hover">
            <div class="stat-content">
              <div class="stat-icon">
                <el-icon><User /></el-icon>
              </div>
              <div class="stat-info">
                <div class="stat-number">{{ animatedNumbers.activeUsers }}</div>
                <div class="stat-label">活跃用户</div>
              </div>
            </div>
            <div class="stat-trend">
              <span class="trend-value positive">+8%</span>
              <span class="trend-text">本周增长</span>
            </div>
            <div class="stat-pattern"></div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :sm="12" :md="6">
          <el-card class="stat-card revenue" shadow="hover">
            <div class="stat-content">
              <div class="stat-icon">
                <el-icon><Money /></el-icon>
              </div>
              <div class="stat-info">
                <div class="stat-number">¥{{ animatedNumbers.revenue }}</div>
                <div class="stat-label">今日收入</div>
              </div>
            </div>
            <div class="stat-trend">
              <span class="trend-value positive">+15%</span>
              <span class="trend-text">比昨日</span>
            </div>
            <div class="stat-pattern"></div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 图表区域 -->
      <el-row :gutter="20" class="chart-section">
        <el-col :xs="24" :lg="16">
          <el-card class="chart-card">
            <template #header>
              <div class="chart-header">
                <h3>预约趋势分析</h3>
                <el-radio-group v-model="trendPeriod" size="small">
                  <el-radio-button label="7d">近7天</el-radio-button>
                  <el-radio-button label="30d">近30天</el-radio-button>
                </el-radio-group>
              </div>
            </template>
            <div class="trend-chart">
              <canvas ref="trendChart" width="400" height="200"></canvas>
            </div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :lg="8">
          <el-card class="chart-card">
            <template #header>
              <h3>座位类型分布</h3>
            </template>
            <div class="pie-chart">
              <canvas ref="pieChart" width="300" height="200"></canvas>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 使用率热图 -->
      <el-row class="heatmap-section">
        <el-col :span="24">
          <el-card class="chart-card">
            <template #header>
              <div class="chart-header">
                <h3>座位使用率热图</h3>
                <span class="chart-subtitle">本周各时间段座位使用情况</span>
              </div>
            </template>
            <div class="usage-heatmap">
              <div class="heatmap-grid">
                <div class="heatmap-labels">
                  <div class="time-labels">
                    <div v-for="hour in hours" :key="hour" class="time-label">{{ hour }}</div>
                  </div>
                  <div class="day-labels">
                    <div v-for="day in days" :key="day" class="day-label">{{ day }}</div>
                  </div>
                </div>
                <div class="heatmap-cells">
                  <div 
                    v-for="(cell, index) in heatmapData" 
                    :key="index"
                    class="heatmap-cell"
                    :class="getHeatmapClass(cell.value)"
                    :title="`${cell.day} ${cell.hour}: ${cell.value}% 使用率`"
                  ></div>
                </div>
              </div>
              <div class="heatmap-legend">
                <span>使用率:</span>
                <div class="legend-scale">
                  <div class="legend-item low">0%</div>
                  <div class="legend-item medium">50%</div>
                  <div class="legend-item high">100%</div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 最近活动 -->
      <el-row :gutter="20" class="recent-section">
        <el-col :xs="24" :lg="12">
          <el-card class="activity-card">
            <template #header>
              <h3>最近预约</h3>
            </template>
            <div class="recent-reservations">
              <div 
                v-for="reservation in recentReservations" 
                :key="reservation.id"
                class="reservation-item"
              >
                <div class="reservation-info">
                  <div class="reservation-user">{{ reservation.userName }}</div>
                  <div class="reservation-details">
                    {{ reservation.seatNumber }} · {{ reservation.time }}
                  </div>
                </div>
                <el-tag :type="getStatusType(reservation.status)" size="small">
                  {{ getStatusText(reservation.status) }}
                </el-tag>
              </div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :xs="24" :lg="12">
          <el-card class="activity-card">
            <template #header>
              <h3>座位使用排行</h3>
            </template>
            <div class="seat-ranking">
              <div 
                v-for="(seat, index) in topSeats" 
                :key="seat.id"
                class="ranking-item"
              >
                <div class="ranking-number">{{ index + 1 }}</div>
                <div class="seat-info">
                  <div class="seat-name">{{ seat.seatNumber }}</div>
                  <div class="seat-usage">使用率: {{ seat.usage }}%</div>
                </div>
                <div class="usage-bar">
                  <div class="usage-fill" :style="{ width: seat.usage + '%' }"></div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 座位管理 -->
    <div v-else-if="currentView === 'seats'" class="seat-management">
      <div class="page-header">
        <h2>座位管理</h2>
        <el-button type="primary" @click="handleAddSeat">
          <el-icon><Plus /></el-icon>
          添加座位
        </el-button>
      </div>

      <el-card class="filter-card">
        <el-form :inline="true" :model="seatFilter" class="filter-form">
          <el-form-item label="楼层">
            <el-select v-model="seatFilter.floorNumber" placeholder="选择楼层" clearable>
              <el-option label="1楼" :value="1" />
              <el-option label="2楼" :value="2" />
              <el-option label="3楼" :value="3" />
            </el-select>
          </el-form-item>
          
          <el-form-item label="区域">
            <el-select v-model="seatFilter.area" placeholder="选择区域" clearable>
              <el-option label="A区" value="A区" />
              <el-option label="B区" value="B区" />
              <el-option label="C区" value="C区" />
            </el-select>
          </el-form-item>
          
          <el-form-item label="状态">
            <el-select v-model="seatFilter.status" placeholder="选择状态" clearable>
              <el-option label="可用" value="AVAILABLE" />
              <el-option label="占用中" value="OCCUPIED" />
              <el-option label="维护中" value="MAINTENANCE" />
              <el-option label="已禁用" value="DISABLED" />
            </el-select>
          </el-form-item>
          
          <el-form-item>
            <el-button type="primary" @click="loadSeats">查询</el-button>
            <el-button @click="resetSeatFilter">重置</el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <el-card class="table-card">
        <el-table 
          :data="seats" 
          v-loading="seatsLoading"
          stripe
          style="width: 100%"
        >
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="seatNumber" label="座位号" />
          <el-table-column prop="area" label="区域" />
          <el-table-column prop="floorNumber" label="楼层" />
          <el-table-column prop="seatTypeName" label="座位类型" />
          <el-table-column prop="hourlyRate" label="费用">
            <template #default="{ row }">
              ¥{{ row.hourlyRate }}/小时
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态">
            <template #default="{ row }">
              <el-tag :type="getSeatStatusType(row.status)" size="small">
                {{ getSeatStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200">
            <template #default="{ row }">
              <el-button size="small" @click="editSeat(row)">编辑</el-button>
              <el-button size="small" type="warning" @click="toggleSeatStatus(row)">
                {{ row.status === 'AVAILABLE' ? '禁用' : '启用' }}
              </el-button>
              <el-button size="small" type="danger" @click="deleteSeat(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>

        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="seatPage"
            v-model:page-size="seatPageSize"
            :total="seatTotal"
            :page-sizes="[10, 20, 50, 100]"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="loadSeats"
            @current-change="loadSeats"
          />
        </div>
      </el-card>
    </div>

    <!-- 预约管理 -->
    <div v-else-if="currentView === 'reservations'" class="reservation-management">
      <div class="page-header">
        <h2>预约管理</h2>
        <div class="header-actions">
          <el-button @click="exportReservations">
            <el-icon><Download /></el-icon>
            导出数据
          </el-button>
        </div>
      </div>

      <el-card class="filter-card">
        <el-form :inline="true" :model="reservationFilter" class="filter-form">
          <el-form-item label="状态">
            <el-select v-model="reservationFilter.status" placeholder="选择状态" clearable>
              <el-option label="已预约" value="RESERVED" />
              <el-option label="使用中" value="USING" />
              <el-option label="已完成" value="COMPLETED" />
              <el-option label="已取消" value="CANCELLED" />
            </el-select>
          </el-form-item>
          
          <el-form-item label="日期">
            <el-date-picker
              v-model="reservationFilter.dateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
            />
          </el-form-item>
          
          <el-form-item>
            <el-button type="primary" @click="loadReservations">查询</el-button>
            <el-button @click="resetReservationFilter">重置</el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <el-card class="table-card">
        <el-table 
          :data="reservations" 
          v-loading="reservationsLoading"
          stripe
          style="width: 100%"
        >
          <el-table-column prop="id" label="预约ID" width="80" />
          <el-table-column prop="userName" label="用户" />
          <el-table-column prop="userRealName" label="姓名" />
          <el-table-column prop="seatNumber" label="座位" />
          <el-table-column label="位置">
            <template #default="{ row }">
              {{ row.floorNumber }}楼 {{ row.seatArea }}
            </template>
          </el-table-column>
          <el-table-column prop="reservationDate" label="日期" />
          <el-table-column label="时间">
            <template #default="{ row }">
              {{ row.startTime }} - {{ row.endTime }}
            </template>
          </el-table-column>
          <el-table-column prop="totalFee" label="费用">
            <template #default="{ row }">
              ¥{{ row.totalFee }}
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态">
            <template #default="{ row }">
              <el-tag :type="getReservationStatusType(row.status)" size="small">
                {{ getReservationStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="150">
            <template #default="{ row }">
              <el-button size="small" @click="viewReservation(row)">查看</el-button>
              <el-button 
                v-if="row.status === 'RESERVED'" 
                size="small" 
                type="danger" 
                @click="cancelReservation(row)"
              >
                取消
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="reservationPage"
            v-model:page-size="reservationPageSize"
            :total="reservationTotal"
            :page-sizes="[10, 20, 50, 100]"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="loadReservations"
            @current-change="loadReservations"
          />
        </div>
      </el-card>
    </div>

    <!-- 用户管理 -->
    <div v-else-if="currentView === 'users'" class="user-management">
      <div class="page-header">
        <h2>用户管理</h2>
        <div class="header-actions">
          <el-button type="primary" @click="showCreateUserDialog">
            <el-icon><Plus /></el-icon>
            新增用户
          </el-button>
          <el-button @click="exportUsers">
            <el-icon><Download /></el-icon>
            导出用户
          </el-button>
        </div>
      </div>

      <el-card class="filter-card">
        <el-form :inline="true" :model="userFilter" class="filter-form">
          <el-form-item label="角色">
            <el-select v-model="userFilter.role" placeholder="选择角色" clearable>
              <el-option label="学生" value="STUDENT" />
              <el-option label="管理员" value="ADMIN" />
            </el-select>
          </el-form-item>
          
          <el-form-item label="状态">
            <el-select v-model="userFilter.status" placeholder="选择状态" clearable>
              <el-option label="正常" value="ACTIVE" />
              <el-option label="禁用" value="DISABLED" />
            </el-select>
          </el-form-item>
          
          <el-form-item label="搜索">
            <el-input 
              v-model="userFilter.keyword" 
              placeholder="用户名/姓名/手机号"
              @keyup.enter="loadUsers"
              style="width: 200px"
            />
          </el-form-item>
          
          <el-form-item>
            <el-button type="primary" @click="loadUsers">查询</el-button>
            <el-button @click="resetUserFilter">重置</el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <el-card class="table-card">
        <el-table 
          :data="users" 
          v-loading="usersLoading"
          stripe
          style="width: 100%"
        >
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="username" label="用户名" />
          <el-table-column prop="realName" label="真实姓名" />
          <el-table-column prop="studentId" label="学号" />
          <el-table-column prop="phone" label="手机号" />
          <el-table-column prop="email" label="邮箱" />
          <el-table-column prop="role" label="角色">
            <template #default="{ row }">
              <el-tag :type="row.role === 'ADMIN' ? 'danger' : 'primary'" size="small">
                {{ row.role === 'ADMIN' ? '管理员' : '学生' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态">
            <template #default="{ row }">
              <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'danger'" size="small">
                {{ row.status === 'ACTIVE' ? '正常' : '禁用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createdTime" label="注册时间">
            <template #default="{ row }">
              {{ formatDateTime(row.createdTime) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="240">
            <template #default="{ row }">
              <el-button size="small" @click="viewUser(row)">查看</el-button>
              <el-button size="small" @click="showEditUserDialog(row)">编辑</el-button>
              <el-button 
                size="small" 
                :type="row.status === 'ACTIVE' ? 'warning' : 'success'" 
                @click="toggleUserStatus(row)"
              >
                {{ row.status === 'ACTIVE' ? '禁用' : '启用' }}
              </el-button>
              <el-dropdown @command="(command) => handleUserAction(command, row)">
                <el-button size="small" type="info">
                  更多<el-icon class="el-icon--right"><ArrowDown /></el-icon>
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item command="reset-password">重置密码</el-dropdown-item>
                    <el-dropdown-item command="delete" v-if="row.role !== 'ADMIN'" divided>删除用户</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </template>
          </el-table-column>
        </el-table>

        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="userPage"
            v-model:page-size="userPageSize"
            :total="userTotal"
            :page-sizes="[10, 20, 50, 100]"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="loadUsers"
            @current-change="loadUsers"
          />
        </div>
      </el-card>
    </div>

    <!-- 报表统计 -->
    <div v-else-if="currentView === 'reports'" class="reports-management">
      <div class="page-header">
        <h2>报表统计</h2>
        <div class="header-actions">
          <el-button @click="exportReports">
            <el-icon><Download /></el-icon>
            导出报表
          </el-button>
        </div>
      </div>

      <!-- 统计概览 -->
      <el-row :gutter="20" class="report-cards">
        <el-col :span="8">
          <el-card class="report-stat-card">
            <div class="report-stat">
              <h3>预约统计</h3>
              <div class="report-number">{{ reportStats.totalReservations }}</div>
              <div class="report-desc">总预约次数</div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="report-stat-card">
            <div class="report-stat">
              <h3>座位利用率</h3>
              <div class="report-number">{{ reportStats.seatUtilization }}%</div>
              <div class="report-desc">平均利用率</div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="report-stat-card">
            <div class="report-stat">
              <h3>用户活跃度</h3>
              <div class="report-number">{{ reportStats.activeUserRate }}%</div>
              <div class="report-desc">活跃用户比例</div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 详细统计图表 -->
      <el-row :gutter="20" class="report-charts">
        <el-col :span="12">
          <el-card>
            <template #header>
              <h3>预约趋势统计</h3>
            </template>
            <div id="reservation-trend-chart" style="height: 300px;"></div>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card>
            <template #header>
              <h3>座位使用率统计</h3>
            </template>
            <div id="seat-usage-chart" style="height: 300px;"></div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 公告管理 -->
    <div v-else-if="currentView === 'announcements'" class="announcement-management">
      <div class="page-header">
        <h2>公告管理</h2>
        <div class="header-actions">
          <el-button type="primary" @click="showCreateAnnouncementDialog">
            <el-icon><Plus /></el-icon>
            新增公告
          </el-button>
        </div>
      </div>

      <el-card class="filter-card">
        <el-form :inline="true" :model="announcementFilter" class="filter-form">
          <el-form-item label="状态">
            <el-select v-model="announcementFilter.status" placeholder="选择状态" clearable>
              <el-option label="草稿" value="DRAFT" />
              <el-option label="已发布" value="PUBLISHED" />
              <el-option label="已归档" value="ARCHIVED" />
            </el-select>
          </el-form-item>
          
          <el-form-item label="类型">
            <el-select v-model="announcementFilter.type" placeholder="选择类型" clearable>
              <el-option label="通知" value="NOTICE" />
              <el-option label="公告" value="ANNOUNCEMENT" />
              <el-option label="维护" value="MAINTENANCE" />
            </el-select>
          </el-form-item>
          
          <el-form-item>
            <el-button type="primary" @click="loadAnnouncements">查询</el-button>
            <el-button @click="resetAnnouncementFilter">重置</el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <el-card class="table-card">
        <el-table 
          :data="announcements" 
          :loading="announcementsLoading"
          stripe
          style="width: 100%"
        >
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="title" label="标题" min-width="200" />
          <el-table-column prop="type" label="类型" width="100">
            <template #default="{ row }">
              <el-tag :type="getAnnouncementTypeColor(row.type)">
                {{ getAnnouncementTypeText(row.type) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getAnnouncementStatusColor(row.status)">
                {{ getAnnouncementStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="authorName" label="发布者" width="120" />
          <el-table-column prop="viewCount" label="浏览次数" width="120" />
          <el-table-column prop="createdTime" label="创建时间" width="180">
            <template #default="{ row }">
              {{ formatDateTime(row.createdTime) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button size="small" @click="editAnnouncement(row)">编辑</el-button>
              <el-button 
                v-if="row.status === 'DRAFT'" 
                size="small" 
                type="primary" 
                @click="publishAnnouncement(row)"
              >
                发布
              </el-button>
              <el-button 
                v-if="row.status === 'PUBLISHED'" 
                size="small" 
                type="warning" 
                @click="archiveAnnouncement(row)"
              >
                归档
              </el-button>
              <el-button size="small" type="danger" @click="deleteAnnouncement(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>

        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="announcementPage"
            v-model:page-size="announcementPageSize"
            :total="announcementTotal"
            :page-sizes="[10, 20, 50, 100]"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="loadAnnouncements"
            @current-change="loadAnnouncements"
          />
        </div>
      </el-card>
    </div>

    <!-- 系统设置 -->
    <div v-else-if="currentView === 'settings'" class="settings-management">
      <div class="page-header">
        <h2>系统设置</h2>
      </div>

      <el-card>
        <el-form :model="systemSettings" label-width="120px">
          <el-form-item label="系统名称">
            <el-input v-model="systemSettings.systemName" />
          </el-form-item>
          <el-form-item label="开放时间">
            <el-time-picker v-model="systemSettings.openTime" />
          </el-form-item>
          <el-form-item label="关闭时间">
            <el-time-picker v-model="systemSettings.closeTime" />
          </el-form-item>
          <el-form-item label="最大预约时长">
            <el-input-number v-model="systemSettings.maxReservationHours" :min="1" :max="24" />
            <span style="margin-left: 8px;">小时</span>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="saveSystemSettings">保存设置</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>

    <!-- 用户详情对话框 -->
    <el-dialog v-model="userDetailVisible" title="用户详情" width="600px">
      <el-descriptions :column="2" border v-if="selectedUser">
        <el-descriptions-item label="ID">{{ selectedUser.id }}</el-descriptions-item>
        <el-descriptions-item label="用户名">{{ selectedUser.username }}</el-descriptions-item>
        <el-descriptions-item label="真实姓名">{{ selectedUser.realName }}</el-descriptions-item>
        <el-descriptions-item label="学号">{{ selectedUser.studentId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ selectedUser.phone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{ selectedUser.email || '-' }}</el-descriptions-item>
        <el-descriptions-item label="角色">
          <el-tag :type="selectedUser.role === 'ADMIN' ? 'danger' : 'primary'">
            {{ selectedUser.role === 'ADMIN' ? '管理员' : '学生' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="selectedUser.status === 'ACTIVE' ? 'success' : 'danger'">
            {{ selectedUser.status === 'ACTIVE' ? '正常' : '禁用' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="注册时间" span="2">
          {{ formatDateTime(selectedUser.createdTime) }}
        </el-descriptions-item>
        <el-descriptions-item label="更新时间" span="2">
          {{ formatDateTime(selectedUser.updatedTime) }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 创建用户对话框 -->
    <el-dialog v-model="createUserVisible" title="新增用户" width="600px">
      <el-form :model="createUserForm" :rules="userRules" ref="createUserFormRef" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="createUserForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="真实姓名" prop="realName">
          <el-input v-model="createUserForm.realName" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="学号" prop="studentId">
          <el-input v-model="createUserForm.studentId" placeholder="请输入学号" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="createUserForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="createUserForm.email" type="email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="createUserForm.role" placeholder="请选择角色" style="width: 100%">
            <el-option label="学生" value="STUDENT" />
            <el-option label="管理员" value="ADMIN" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="createUserForm.status" placeholder="请选择状态" style="width: 100%">
            <el-option label="正常" value="ACTIVE" />
            <el-option label="禁用" value="DISABLED" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="createUserVisible = false">取消</el-button>
          <el-button type="primary" @click="submitCreateUser">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 编辑用户对话框 -->
    <el-dialog v-model="editUserVisible" title="编辑用户" width="600px">
      <el-form :model="editUserForm" :rules="userRules" ref="editUserFormRef" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="editUserForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="真实姓名" prop="realName">
          <el-input v-model="editUserForm.realName" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="学号" prop="studentId">
          <el-input v-model="editUserForm.studentId" placeholder="请输入学号" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="editUserForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="editUserForm.email" type="email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="editUserForm.role" placeholder="请选择角色" style="width: 100%">
            <el-option label="学生" value="STUDENT" />
            <el-option label="管理员" value="ADMIN" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="editUserForm.status" placeholder="请选择状态" style="width: 100%">
            <el-option label="正常" value="ACTIVE" />
            <el-option label="禁用" value="DISABLED" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="editUserVisible = false">取消</el-button>
          <el-button type="primary" @click="submitEditUser">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 座位表单对话框 -->
    <el-dialog 
      v-model="seatFormVisible" 
      :title="isEditSeat ? '编辑座位' : '添加座位'" 
      width="600px"
    >
      <el-form 
        v-if="selectedSeat" 
        :model="selectedSeat" 
        label-width="100px"
        @submit.prevent="handleSeatFormSubmit"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="座位号" required>
              <el-input v-model="selectedSeat.seatNumber" placeholder="请输入座位号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="楼层">
              <el-select v-model="selectedSeat.floorNumber" style="width: 100%">
                <el-option label="1楼" :value="1" />
                <el-option label="2楼" :value="2" />
                <el-option label="3楼" :value="3" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="区域">
              <el-select v-model="selectedSeat.area" style="width: 100%">
                <el-option label="A区" value="A区" />
                <el-option label="B区" value="B区" />
                <el-option label="C区" value="C区" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="座位类型">
              <el-select v-model="selectedSeat.seatTypeId" placeholder="选择座位类型" style="width: 100%">
                <el-option 
                  v-for="type in seatTypes" 
                  :key="type.id" 
                  :label="type.typeName" 
                  :value="type.id" 
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="X坐标">
              <el-input-number v-model="selectedSeat.positionX" :min="0" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Y坐标">
              <el-input-number v-model="selectedSeat.positionY" :min="0" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="状态">
              <el-select v-model="selectedSeat.status" style="width: 100%">
                <el-option label="可用" value="AVAILABLE" />
                <el-option label="维护中" value="MAINTENANCE" />
                <el-option label="已禁用" value="DISABLED" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="设施">
              <el-checkbox v-model="selectedSeat.hasPower">有电源</el-checkbox>
              <el-checkbox v-model="selectedSeat.hasComputer">有电脑</el-checkbox>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="描述">
          <el-input 
            v-model="selectedSeat.description" 
            type="textarea" 
            :rows="3" 
            placeholder="请输入座位描述" 
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleSeatFormCancel">取消</el-button>
          <el-button type="primary" @click="handleSeatFormSubmit">
            {{ isEditSeat ? '更新' : '创建' }}
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 预约详情对话框 -->
    <el-dialog v-model="reservationDetailVisible" title="预约详情" width="600px">
      <el-descriptions :column="2" border v-if="selectedReservation">
        <el-descriptions-item label="预约ID">{{ selectedReservation.id }}</el-descriptions-item>
        <el-descriptions-item label="用户名">{{ selectedReservation.userName }}</el-descriptions-item>
        <el-descriptions-item label="真实姓名">{{ selectedReservation.userRealName }}</el-descriptions-item>
        <el-descriptions-item label="座位号">{{ selectedReservation.seatNumber }}</el-descriptions-item>
        <el-descriptions-item label="位置">
          {{ selectedReservation.floorNumber }}楼 {{ selectedReservation.seatArea }}
        </el-descriptions-item>
        <el-descriptions-item label="座位类型">{{ selectedReservation.seatTypeName }}</el-descriptions-item>
        <el-descriptions-item label="预约日期">{{ selectedReservation.reservationDate }}</el-descriptions-item>
        <el-descriptions-item label="时间段">
          {{ selectedReservation.startTime }} - {{ selectedReservation.endTime }}
        </el-descriptions-item>
        <el-descriptions-item label="费用">¥{{ selectedReservation.totalFee }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getReservationStatusType(selectedReservation.status)">
            {{ getReservationStatusText(selectedReservation.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建时间" span="2">
          {{ formatDateTime(selectedReservation.createdTime) }}
        </el-descriptions-item>
        <el-descriptions-item label="更新时间" span="2">
          {{ formatDateTime(selectedReservation.updatedTime) }}
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 创建公告对话框 -->
    <el-dialog v-model="createAnnouncementVisible" title="新增公告" width="800px">
      <el-form :model="createAnnouncementForm" :rules="announcementRules" ref="createAnnouncementFormRef" label-width="80px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="createAnnouncementForm.title" placeholder="请输入公告标题" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="createAnnouncementForm.type" placeholder="选择类型">
            <el-option label="通知" value="NOTICE" />
            <el-option label="公告" value="ANNOUNCEMENT" />
            <el-option label="维护" value="MAINTENANCE" />
          </el-select>
        </el-form-item>
        <el-form-item label="优先级" prop="priority">
          <el-select v-model="createAnnouncementForm.priority" placeholder="选择优先级">
            <el-option label="低" :value="1" />
            <el-option label="中" :value="2" />
            <el-option label="高" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="过期时间">
          <el-date-picker
            v-model="createAnnouncementForm.expireTime"
            type="datetime"
            placeholder="选择过期时间（可选）"
          />
        </el-form-item>
        <el-form-item label="内容" prop="content">
          <el-input
            v-model="createAnnouncementForm.content"
            type="textarea"
            :rows="6"
            placeholder="请输入公告内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="createAnnouncementVisible = false">取消</el-button>
          <el-button type="primary" @click="submitCreateAnnouncement">保存草稿</el-button>
          <el-button type="success" @click="submitCreateAnnouncementAndPublish">发布</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 编辑公告对话框 -->
    <el-dialog v-model="editAnnouncementVisible" title="编辑公告" width="800px">
      <el-form :model="editAnnouncementForm" :rules="announcementRules" ref="editAnnouncementFormRef" label-width="80px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="editAnnouncementForm.title" placeholder="请输入公告标题" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="editAnnouncementForm.type" placeholder="选择类型">
            <el-option label="通知" value="NOTICE" />
            <el-option label="公告" value="ANNOUNCEMENT" />
            <el-option label="维护" value="MAINTENANCE" />
          </el-select>
        </el-form-item>
        <el-form-item label="优先级" prop="priority">
          <el-select v-model="editAnnouncementForm.priority" placeholder="选择优先级">
            <el-option label="低" :value="1" />
            <el-option label="中" :value="2" />
            <el-option label="高" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="过期时间">
          <el-date-picker
            v-model="editAnnouncementForm.expireTime"
            type="datetime"
            placeholder="选择过期时间（可选）"
          />
        </el-form-item>
        <el-form-item label="内容" prop="content">
          <el-input
            v-model="editAnnouncementForm.content"
            type="textarea"
            :rows="6"
            placeholder="请输入公告内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="editAnnouncementVisible = false">取消</el-button>
          <el-button type="primary" @click="submitEditAnnouncement">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </AdminLayout>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Calendar, Grid, User, Money, Plus, Download, ArrowDown
} from '@element-plus/icons-vue'
import AdminLayout from '@/components/AdminLayout.vue'
import { seatApi } from '@/api/seat'
import { reservationApi } from '@/api/reservation'
import { userApi } from '@/api/user'
import request from '@/utils/request'

const currentView = ref('dashboard')

// 统计数据
const statistics = reactive({
  todayReservations: 0,
  totalSeats: 0,
  availableSeats: 0,
  activeUsers: 0,
  revenue: 0
})

// 动画数字显示
const animatedNumbers = reactive({
  todayReservations: 0,
  totalSeats: 0,
  availableSeats: 0,
  activeUsers: 0,
  revenue: 0
})

// 数字动画函数
const animateNumber = (targetValue, currentValue, key, duration = 1000) => {
  const startTime = performance.now()
  const startValue = currentValue
  
  const animate = (currentTime) => {
    const elapsed = currentTime - startTime
    const progress = Math.min(elapsed / duration, 1)
    
    // 使用easeOut缓动效果
    const easeOut = 1 - Math.pow(1 - progress, 3)
    const value = Math.round(startValue + (targetValue - startValue) * easeOut)
    
    animatedNumbers[key] = value
    
    if (progress < 1) {
      requestAnimationFrame(animate)
    }
  }
  
  requestAnimationFrame(animate)
}

// 图表相关
const trendChart = ref(null)
const pieChart = ref(null)
const trendPeriod = ref('7d')

// 热图数据
const hours = ['08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00']
const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
const heatmapData = ref([])

// 最近活动数据
const recentReservations = ref([])
const topSeats = ref([])

// 座位管理
const seatsLoading = ref(false)
const seats = ref([])
const seatTotal = ref(0)
const seatPage = ref(1)
const seatPageSize = ref(10)
const seatFilter = reactive({
  floorNumber: null,
  area: null,
  status: null
})
const showAddSeat = ref(false)
const seatFormVisible = ref(false)
const isEditSeat = ref(false)
const selectedSeat = ref(null)
const seatTypes = ref([])

// 预约管理
const reservationsLoading = ref(false)
const reservations = ref([])
const reservationTotal = ref(0)
const reservationPage = ref(1)
const reservationPageSize = ref(10)
const reservationFilter = reactive({
  status: null,
  dateRange: null
})

// 用户管理
const usersLoading = ref(false)
const users = ref([])
const userTotal = ref(0)
const userPage = ref(1)
const userPageSize = ref(10)
const userFilter = reactive({
  role: null,
  status: null,
  keyword: null
})
const userDetailVisible = ref(false)
const selectedUser = ref(null)

// 创建用户对话框
const createUserVisible = ref(false)
const createUserForm = reactive({
  username: '',
  realName: '',
  studentId: '',
  phone: '',
  email: '',
  role: 'STUDENT',
  status: 'ACTIVE'
})
const createUserFormRef = ref()

// 编辑用户对话框
const editUserVisible = ref(false)
const editUserForm = reactive({
  id: null,
  username: '',
  realName: '',
  studentId: '',
  phone: '',
  email: '',
  role: 'STUDENT',
  status: 'ACTIVE'
})
const editUserFormRef = ref()

// 用户表单验证规则
const userRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在3到20个字符', trigger: 'blur' }
  ],
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' }
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
}

// 菜单切换
const handleMenuChange = (menu) => {
  currentView.value = menu
  if (menu === 'seats' && seats.value.length === 0) {
    loadSeats()
  } else if (menu === 'reservations' && reservations.value.length === 0) {
    loadReservations()
  } else if (menu === 'users' && users.value.length === 0) {
    loadUsers()
  } else if (menu === 'reports') {
    loadReportStats()
  } else if (menu === 'announcements' && announcements.value.length === 0) {
    loadAnnouncements()
  } else if (menu === 'settings') {
    loadSystemSettings()
  }
}

// 座位状态处理函数
const getSeatStatusText = (status) => {
  const seatStatusMap = {
    'AVAILABLE': '可用',
    'OCCUPIED': '占用中',
    'MAINTENANCE': '维护中',
    'DISABLED': '已禁用'
  }
  return seatStatusMap[status] || status
}

const getSeatStatusType = (status) => {
  const seatStatusTypeMap = {
    'AVAILABLE': 'success',
    'OCCUPIED': 'danger',
    'MAINTENANCE': 'warning',
    'DISABLED': 'info'
  }
  return seatStatusTypeMap[status] || 'info'
}

// 预约状态处理函数
const getReservationStatusText = (status) => {
  const statusMap = {
    'RESERVED': '已预约',
    'USING': '使用中',
    'COMPLETED': '已完成',
    'CANCELLED': '已取消',
    'EXPIRED': '已过期'
  }
  return statusMap[status] || status
}

const getReservationStatusType = (status) => {
  const statusTypeMap = {
    'RESERVED': 'primary',
    'USING': 'success',
    'COMPLETED': 'info',
    'CANCELLED': 'danger',
    'EXPIRED': 'warning'
  }
  return statusTypeMap[status] || 'info'
}

// 通用状态处理函数（兼容旧代码）
const getStatusText = (status) => {
  return getReservationStatusText(status)
}

const getStatusType = (status) => {
  return getReservationStatusType(status)
}

// 时间格式化函数
const formatDateTime = (dateTime) => {
  if (!dateTime) return '-'
  return new Date(dateTime).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 热图样式类
const getHeatmapClass = (value) => {
  if (value < 30) return 'low'
  if (value < 70) return 'medium'
  return 'high'
}

// 加载统计数据
const loadStatistics = async () => {
  try {
    const response = await request.get('/statistics/admin/dashboard')
    console.log('统计数据响应:', response)

    // 处理新的响应格式 {code, message, data}
    if (response && response.code === 200) {
      // 更新统计数据并触发动画
      Object.keys(statistics).forEach(key => {
        const oldValue = statistics[key]
        const newValue = response.data[key] || 0
        statistics[key] = newValue

        // 触发数字动画
        animateNumber(newValue, animatedNumbers[key], key, 1200)
      })
    } else {
      console.error('统计数据获取失败:', response)
      ElMessage.error(response.message || '加载统计数据失败')
      // 使用默认值
      statistics.todayReservations = 0
      statistics.totalSeats = 0
      statistics.availableSeats = 0
      statistics.activeUsers = 0
      statistics.revenue = 0
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
    ElMessage.error('加载统计数据失败')
    // 使用默认值
    statistics.todayReservations = 0
    statistics.totalSeats = 0
    statistics.availableSeats = 0
    statistics.activeUsers = 0
    statistics.revenue = 0
  }
}

// 加载座位数据
const loadSeats = async () => {
  seatsLoading.value = true
  try {
    const params = {
      current: seatPage.value,
      size: seatPageSize.value,
      floorNumber: seatFilter.floorNumber,
      area: seatFilter.area,
      status: seatFilter.status
    }

    const response = await seatApi.getSeatPage(params)
    console.log('座位数据响应:', response)

    // 处理新的响应格式 {code, message, data}
    if (response && response.code === 200) {
      seats.value = response.data.records || []
      seatTotal.value = response.data.total || 0

      // 更新统计数据
      statistics.totalSeats = seatTotal.value
      statistics.availableSeats = seats.value.filter(s => s.status === 'AVAILABLE').length
    } else {
      console.error('座位数据获取失败:', response)
      ElMessage.error(response.message || '加载座位信息失败')
      seats.value = []
      seatTotal.value = 0
    }
  } catch (error) {
    console.error('加载座位信息失败:', error)
    ElMessage.error('加载座位信息失败')
    seats.value = []
    seatTotal.value = 0
  } finally {
    seatsLoading.value = false
  }
}

// 加载预约数据
const loadReservations = async () => {
  reservationsLoading.value = true
  try {
    const params = {
      current: reservationPage.value,
      size: reservationPageSize.value,
      status: reservationFilter.status
    }

    // 处理日期范围
    if (reservationFilter.dateRange && reservationFilter.dateRange.length === 2) {
      params.startDate = reservationFilter.dateRange[0].toISOString().split('T')[0]
      params.endDate = reservationFilter.dateRange[1].toISOString().split('T')[0]
    }

    const response = await reservationApi.getAdminReservations(params)
    console.log('预约数据响应:', response)

    // 处理新的响应格式 {code, message, data}
    if (response && response.code === 200) {
      reservations.value = response.data.records || []
      reservationTotal.value = response.data.total || 0
    } else {
      console.error('预约数据获取失败:', response)
      ElMessage.error(response.message || '加载预约记录失败')
      reservations.value = []
      reservationTotal.value = 0
    }
  } catch (error) {
    console.error('加载预约记录失败:', error)
    ElMessage.error('加载预约记录失败')
    reservations.value = []
    reservationTotal.value = 0
  } finally {
    reservationsLoading.value = false
  }
}

// 重置筛选条件
const resetSeatFilter = () => {
  Object.keys(seatFilter).forEach(key => {
    seatFilter[key] = null
  })
  loadSeats()
}

const resetReservationFilter = () => {
  Object.keys(reservationFilter).forEach(key => {
    reservationFilter[key] = null
  })
  loadReservations()
}

// 座位操作
const editSeat = (seat) => {
  selectedSeat.value = { ...seat }
  seatFormVisible.value = true
  isEditSeat.value = true
}

const toggleSeatStatus = async (seat) => {
  const action = seat.status === 'AVAILABLE' ? '禁用' : '启用'
  const newStatus = seat.status === 'AVAILABLE' ? 'DISABLED' : 'AVAILABLE'
  
  try {
    await ElMessageBox.confirm(`确定要${action}座位 ${seat.seatNumber} 吗？`)
    await seatApi.updateSeatStatus(seat.id, newStatus)
    ElMessage.success(`${action}成功`)
    loadSeats()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('更新座位状态失败:', error)
      ElMessage.error('操作失败')
    }
  }
}

const deleteSeat = async (seat) => {
  try {
    await ElMessageBox.confirm(`确定要删除座位 ${seat.seatNumber} 吗？`, '警告', {
      type: 'warning'
    })
    await seatApi.deleteSeat(seat.id)
    ElMessage.success('删除成功')
    loadSeats()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除座位失败:', error)
      ElMessage.error('删除失败')
    }
  }
}

// 座位表单操作
const handleAddSeat = () => {
  selectedSeat.value = {
    seatNumber: '',
    floorNumber: 1,
    area: 'A区',
    seatTypeId: null,
    positionX: 0,
    positionY: 0,
    status: 'AVAILABLE',
    hasPower: false,
    hasComputer: false,
    description: ''
  }
  seatFormVisible.value = true
  isEditSeat.value = false
}

const handleSeatFormSubmit = async () => {
  try {
    if (isEditSeat.value) {
      await seatApi.updateSeat(selectedSeat.value.id, selectedSeat.value)
      ElMessage.success('座位更新成功')
    } else {
      await seatApi.createSeat(selectedSeat.value)
      ElMessage.success('座位创建成功')
    }
    seatFormVisible.value = false
    loadSeats()
  } catch (error) {
    console.error('保存座位失败:', error)
    ElMessage.error('保存失败')
  }
}

const handleSeatFormCancel = () => {
  seatFormVisible.value = false
  selectedSeat.value = null
}

// 加载座位类型
const loadSeatTypes = async () => {
  try {
    seatTypes.value = await seatApi.getSeatTypes()
  } catch (error) {
    console.error('加载座位类型失败:', error)
  }
}

// 预约操作
const selectedReservation = ref(null)
const reservationDetailVisible = ref(false)

const viewReservation = async (reservation) => {
  try {
    const detail = await reservationApi.getAdminReservationDetail(reservation.id)
    selectedReservation.value = detail
    reservationDetailVisible.value = true
  } catch (error) {
    console.error('获取预约详情失败:', error)
    ElMessage.error('获取预约详情失败')
  }
}

const cancelReservation = async (reservation) => {
  try {
    await ElMessageBox.confirm(`确定要取消预约 ${reservation.id} 吗？`)
    await reservationApi.cancelReservationByAdmin(reservation.id)
    ElMessage.success('取消成功')
    loadReservations()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('取消预约失败:', error)
      ElMessage.error('取消失败')
    }
  }
}

const exportReservations = () => {
  ElMessage.info('导出功能开发中')
}

// 用户管理操作
const loadUsers = async () => {
  usersLoading.value = true
  try {
    const params = {
      current: userPage.value,
      size: userPageSize.value,
      role: userFilter.role,
      status: userFilter.status,
      keyword: userFilter.keyword
    }

    const response = await userApi.getUserList(params)
    console.log('用户数据响应:', response)

    // 处理新的响应格式 {code, message, data}
    if (response && response.code === 200) {
      users.value = response.data.records || []
      userTotal.value = response.data.total || 0
    } else {
      console.error('用户数据获取失败:', response)
      ElMessage.error(response.message || '加载用户列表失败')
      users.value = []
      userTotal.value = 0
    }
  } catch (error) {
    console.error('加载用户列表失败:', error)
    ElMessage.error('加载用户列表失败')
    users.value = []
    userTotal.value = 0
  } finally {
    usersLoading.value = false
  }
}

const resetUserFilter = () => {
  Object.keys(userFilter).forEach(key => {
    userFilter[key] = null
  })
  loadUsers()
}

const viewUser = async (user) => {
  try {
    const response = await userApi.getUserDetail(user.id)
    selectedUser.value = response
    userDetailVisible.value = true
  } catch (error) {
    console.error('获取用户详情失败:', error)
    ElMessage.error('获取用户详情失败')
  }
}

const toggleUserStatus = async (user) => {
  const action = user.status === 'ACTIVE' ? '禁用' : '启用'
  const newStatus = user.status === 'ACTIVE' ? 'DISABLED' : 'ACTIVE'
  
  try {
    await ElMessageBox.confirm(`确定要${action}用户 ${user.username} 吗？`)
    await userApi.updateUserStatus(user.id, newStatus)
    ElMessage.success(`${action}成功`)
    loadUsers()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('更新用户状态失败:', error)
      ElMessage.error('操作失败')
    }
  }
}

const handleUserAction = async (command, user) => {
  if (command === 'reset-password') {
    try {
      await ElMessageBox.confirm(`确定要重置用户 ${user.username} 的密码吗？`)
      await userApi.resetPassword(user.id)
      ElMessage.success('密码重置成功，新密码为：123456')
    } catch (error) {
      if (error !== 'cancel') {
        console.error('重置密码失败:', error)
        ElMessage.error('重置密码失败')
      }
    }
  } else if (command === 'delete') {
    try {
      await ElMessageBox.confirm(`确定要删除用户 ${user.username} 吗？`, '警告', {
        type: 'warning'
      })
      await userApi.deleteUser(user.id)
      ElMessage.success('删除成功')
      loadUsers()
    } catch (error) {
      if (error !== 'cancel') {
        console.error('删除用户失败:', error)
        ElMessage.error('删除失败')
      }
    }
  }
}

const exportUsers = () => {
  ElMessage.info('导出用户功能开发中')
}

// 显示创建用户对话框
const showCreateUserDialog = () => {
  // 重置表单
  Object.keys(createUserForm).forEach(key => {
    if (key === 'role') {
      createUserForm[key] = 'STUDENT'
    } else if (key === 'status') {
      createUserForm[key] = 'ACTIVE'
    } else {
      createUserForm[key] = ''
    }
  })
  createUserVisible.value = true
}

// 显示编辑用户对话框
const showEditUserDialog = (user) => {
  editUserForm.id = user.id
  editUserForm.username = user.username
  editUserForm.realName = user.realName
  editUserForm.studentId = user.studentId || ''
  editUserForm.phone = user.phone || ''
  editUserForm.email = user.email || ''
  editUserForm.role = user.role
  editUserForm.status = user.status
  editUserVisible.value = true
}

// 提交创建用户
const submitCreateUser = async () => {
  if (!createUserFormRef.value) return
  
  try {
    await createUserFormRef.value.validate()
    const response = await userApi.createUser(createUserForm)
    ElMessage.success('用户创建成功')
    createUserVisible.value = false
    loadUsers()
  } catch (error) {
    if (typeof error === 'object') {
      console.error('创建用户失败:', error)
      ElMessage.error('创建用户失败')
    }
  }
}

// 提交编辑用户
const submitEditUser = async () => {
  if (!editUserFormRef.value) return
  
  try {
    await editUserFormRef.value.validate()
    const { id, ...updateData } = editUserForm
    const response = await userApi.updateUser(id, updateData)
    ElMessage.success('用户更新成功')
    editUserVisible.value = false
    loadUsers()
  } catch (error) {
    if (typeof error === 'object') {
      console.error('更新用户失败:', error)
      ElMessage.error('更新用户失败')
    }
  }
}

// 初始化热图数据
const initHeatmapData = () => {
  heatmapData.value = []
  days.forEach(day => {
    hours.forEach(hour => {
      heatmapData.value.push({
        day,
        hour,
        value: Math.floor(Math.random() * 100)
      })
    })
  })
}

// 初始化模拟数据
const initMockData = () => {
  // 最近预约数据
  recentReservations.value = [
    { id: 1, userName: '张三', seatNumber: 'A001', time: '09:00-12:00', status: 'USING' },
    { id: 2, userName: '李四', seatNumber: 'A002', time: '14:00-17:00', status: 'RESERVED' },
    { id: 3, userName: '王五', seatNumber: 'B003', time: '10:00-15:00', status: 'COMPLETED' }
  ]
  
  // 座位使用排行
  topSeats.value = [
    { id: 1, seatNumber: 'A001', usage: 92 },
    { id: 2, seatNumber: 'B005', usage: 88 },
    { id: 3, seatNumber: 'A003', usage: 85 },
    { id: 4, seatNumber: 'C002', usage: 82 },
    { id: 5, seatNumber: 'B001', usage: 78 }
  ]
}

// 初始化图表
const initCharts = () => {
  nextTick(() => {
    initTrendChart()
    initPieChart()
  })
}

const initTrendChart = () => {
  if (!trendChart.value) return
  
  const ctx = trendChart.value.getContext('2d')
  const gradient = ctx.createLinearGradient(0, 0, 0, 200)
  gradient.addColorStop(0, 'rgba(52, 152, 219, 0.8)')
  gradient.addColorStop(1, 'rgba(52, 152, 219, 0.1)')
  
  // 简单的图表绘制（实际项目中建议使用Chart.js等图表库）
  ctx.clearRect(0, 0, 400, 200)
  ctx.fillStyle = gradient
  
  const data = [30, 45, 60, 80, 75, 90, 85]
  const width = 400 / data.length
  
  data.forEach((value, index) => {
    const height = (value / 100) * 180
    ctx.fillRect(index * width + 10, 200 - height - 10, width - 20, height)
  })
}

const initPieChart = () => {
  if (!pieChart.value) return
  
  const ctx = pieChart.value.getContext('2d')
  const centerX = 150
  const centerY = 100
  const radius = 80
  
  const data = [
    { label: '普通座位', value: 40, color: '#3498db' },
    { label: '靠窗座位', value: 30, color: '#e74c3c' },
    { label: '电脑座位', value: 20, color: '#f39c12' },
    { label: '包间座位', value: 10, color: '#2ecc71' }
  ]
  
  ctx.clearRect(0, 0, 300, 200)
  
  let currentAngle = 0
  data.forEach(item => {
    const sliceAngle = (item.value / 100) * 2 * Math.PI
    
    ctx.beginPath()
    ctx.arc(centerX, centerY, radius, currentAngle, currentAngle + sliceAngle)
    ctx.lineTo(centerX, centerY)
    ctx.fillStyle = item.color
    ctx.fill()
    
    currentAngle += sliceAngle
  })
}

onMounted(() => {
  loadStatistics()
  loadSeats()
  loadSeatTypes()
  initHeatmapData()
  initMockData()
  initCharts()
})

// 报表统计
const reportStats = reactive({
  totalReservations: 0,
  seatUtilization: 0,
  activeUserRate: 0
})

// 公告管理
const announcementsLoading = ref(false)
const announcements = ref([])
const announcementTotal = ref(0)
const announcementPage = ref(1)
const announcementPageSize = ref(10)
const announcementFilter = reactive({
  status: null,
  type: null
})
const createAnnouncementVisible = ref(false)
const editAnnouncementVisible = ref(false)
const selectedAnnouncement = ref(null)

// 系统设置
const systemSettings = reactive({
  systemName: '智慧自习室座位预约系统',
  openTime: null,
  closeTime: null,
  maxReservationHours: 8
})

// 报表统计相关方法
const loadReportStats = async () => {
  try {
    const [reservationTrend, seatUsage, userActivity] = await Promise.all([
      request.get('/statistics/admin/reservation-trend'),
      request.get('/statistics/admin/seat-usage'),
      request.get('/statistics/admin/user-activity')
    ])
    
    // 处理预约趋势数据
    const trendData = reservationTrend.data?.trend || []
    let totalReservations = 0
    trendData.forEach(item => totalReservations += item.count)
    
    // 处理座位使用率数据
    const seatTypeUsage = seatUsage.data?.seatTypeUsage || []
    let totalSeats = 0
    let totalUsed = 0
    seatTypeUsage.forEach(item => {
      totalSeats += item.total
      totalUsed += item.used
    })
    const seatUtilization = totalSeats > 0 ? Math.round((totalUsed / totalSeats) * 100) : 0
    
    // 处理用户活跃度数据
    const userActivityData = userActivity.data || {}
    const activeUserRate = userActivityData.totalUsers > 0 
      ? Math.round((userActivityData.activeUsers / userActivityData.totalUsers) * 100) 
      : 0
    
    // 更新统计数据
    reportStats.totalReservations = totalReservations
    reportStats.seatUtilization = seatUtilization
    reportStats.activeUserRate = activeUserRate
    
    // 绘制图表
    await nextTick()
    drawReportCharts(trendData, seatTypeUsage)
    
  } catch (error) {
    console.error('加载报表统计失败:', error)
    ElMessage.error('加载报表统计失败')
  }
}

const exportReports = () => {
  ElMessage.info('报表导出功能开发中...')
}

// 绘制报表图表
const drawReportCharts = (trendData, seatTypeUsage) => {
  // 绘制预约趋势图表
  const trendChart = document.getElementById('reservation-trend-chart')
  if (trendChart) {
    const canvas = document.createElement('canvas')
    trendChart.innerHTML = ''
    trendChart.appendChild(canvas)
    
    const ctx = canvas.getContext('2d')
    canvas.width = trendChart.offsetWidth
    canvas.height = 300
    
    // 简单的折线图绘制
    const padding = 40
    const chartWidth = canvas.width - 2 * padding
    const chartHeight = canvas.height - 2 * padding
    
    if (trendData.length > 0) {
      const maxCount = Math.max(...trendData.map(d => d.count))
      const stepX = chartWidth / (trendData.length - 1)
      
      // 绘制坐标轴
      ctx.strokeStyle = '#e5e7eb'
      ctx.lineWidth = 1
      ctx.beginPath()
      ctx.moveTo(padding, padding)
      ctx.lineTo(padding, padding + chartHeight)
      ctx.lineTo(padding + chartWidth, padding + chartHeight)
      ctx.stroke()
      
      // 绘制数据线
      ctx.strokeStyle = '#059669'
      ctx.lineWidth = 2
      ctx.beginPath()
      
      trendData.forEach((data, index) => {
        const x = padding + index * stepX
        const y = padding + chartHeight - (data.count / maxCount) * chartHeight
        
        if (index === 0) {
          ctx.moveTo(x, y)
        } else {
          ctx.lineTo(x, y)
        }
        
        // 绘制数据点
        ctx.fillStyle = '#059669'
        ctx.beginPath()
        ctx.arc(x, y, 4, 0, 2 * Math.PI)
        ctx.fill()
      })
      ctx.stroke()
      
      // 绘制标签
      ctx.fillStyle = '#6b7280'
      ctx.font = '12px sans-serif'
      ctx.textAlign = 'center'
      trendData.forEach((data, index) => {
        const x = padding + index * stepX
        ctx.fillText(data.date, x, canvas.height - 10)
      })
    }
  }
  
  // 绘制座位使用率饼图
  const usageChart = document.getElementById('seat-usage-chart')
  if (usageChart && seatTypeUsage.length > 0) {
    const canvas = document.createElement('canvas')
    usageChart.innerHTML = ''
    usageChart.appendChild(canvas)
    
    const ctx = canvas.getContext('2d')
    canvas.width = usageChart.offsetWidth
    canvas.height = 300
    
    const centerX = canvas.width / 2
    const centerY = canvas.height / 2
    const radius = Math.min(centerX, centerY) - 40
    
    const colors = ['#059669', '#10b981', '#34d399', '#6ee7b7', '#a7f3d0']
    let currentAngle = 0
    
    seatTypeUsage.forEach((usage, index) => {
      const sliceAngle = (usage.usageRate / 100) * 2 * Math.PI
      
      ctx.fillStyle = colors[index % colors.length]
      ctx.beginPath()
      ctx.moveTo(centerX, centerY)
      ctx.arc(centerX, centerY, radius, currentAngle, currentAngle + sliceAngle)
      ctx.closePath()
      ctx.fill()
      
      // 绘制标签
      const labelAngle = currentAngle + sliceAngle / 2
      const labelX = centerX + Math.cos(labelAngle) * (radius + 20)
      const labelY = centerY + Math.sin(labelAngle) * (radius + 20)
      
      ctx.fillStyle = '#374151'
      ctx.font = '12px sans-serif'
      ctx.textAlign = 'center'
      ctx.fillText(`${usage.typeName}`, labelX, labelY)
      ctx.fillText(`${usage.usageRate}%`, labelX, labelY + 15)
      
      currentAngle += sliceAngle
    })
  }
}

// 公告管理相关方法
const loadAnnouncements = async () => {
  announcementsLoading.value = true
  try {
    const params = {
      current: announcementPage.value,
      size: announcementPageSize.value,
      status: announcementFilter.status,
      type: announcementFilter.type
    }

    const response = await request.get('/announcement/admin/list', { params })
    console.log('公告数据响应:', response)

    // 处理新的响应格式 {code, message, data}
    if (response && response.code === 200) {
      announcements.value = response.data.records || []
      announcementTotal.value = response.data.total || 0
    } else {
      console.error('公告数据获取失败:', response)
      ElMessage.error(response.message || '加载公告列表失败')
      announcements.value = []
      announcementTotal.value = 0
    }
  } catch (error) {
    console.error('加载公告列表失败:', error)
    ElMessage.error('加载公告列表失败')
    announcements.value = []
    announcementTotal.value = 0
  } finally {
    announcementsLoading.value = false
  }
}

const resetAnnouncementFilter = () => {
  Object.keys(announcementFilter).forEach(key => {
    announcementFilter[key] = null
  })
  loadAnnouncements()
}

const showCreateAnnouncementDialog = () => {
  // 重置表单
  Object.keys(createAnnouncementForm).forEach(key => {
    if (key === 'type') {
      createAnnouncementForm[key] = 'NOTICE'
    } else if (key === 'priority') {
      createAnnouncementForm[key] = 2
    } else {
      createAnnouncementForm[key] = null
    }
  })
  createAnnouncementVisible.value = true
}

const editAnnouncement = (announcement) => {
  editAnnouncementForm.id = announcement.id
  editAnnouncementForm.title = announcement.title
  editAnnouncementForm.content = announcement.content
  editAnnouncementForm.type = announcement.type
  editAnnouncementForm.priority = announcement.priority
  editAnnouncementForm.expireTime = announcement.expireTime ? new Date(announcement.expireTime) : null
  editAnnouncementVisible.value = true
}

const submitCreateAnnouncement = async () => {
  if (!createAnnouncementFormRef.value) return
  
  try {
    await createAnnouncementFormRef.value.validate()
    
    const formData = {
      ...createAnnouncementForm,
      status: 'DRAFT',
      expireTime: createAnnouncementForm.expireTime ? createAnnouncementForm.expireTime.toISOString() : null
    }
    
    await request.post('/announcement/admin/create', formData)
    ElMessage.success('公告保存成功')
    createAnnouncementVisible.value = false
    loadAnnouncements()
  } catch (error) {
    if (typeof error === 'object') {
      console.error('创建公告失败:', error)
      ElMessage.error('创建公告失败')
    }
  }
}

const submitCreateAnnouncementAndPublish = async () => {
  if (!createAnnouncementFormRef.value) return
  
  try {
    await createAnnouncementFormRef.value.validate()
    
    const formData = {
      ...createAnnouncementForm,
      status: 'PUBLISHED',
      publishTime: new Date().toISOString(),
      expireTime: createAnnouncementForm.expireTime ? createAnnouncementForm.expireTime.toISOString() : null
    }
    
    await request.post('/announcement/admin/create', formData)
    ElMessage.success('公告发布成功')
    createAnnouncementVisible.value = false
    loadAnnouncements()
  } catch (error) {
    if (typeof error === 'object') {
      console.error('发布公告失败:', error)
      ElMessage.error('发布公告失败')
    }
  }
}

const submitEditAnnouncement = async () => {
  if (!editAnnouncementFormRef.value) return
  
  try {
    await editAnnouncementFormRef.value.validate()
    
    const { id, ...formData } = editAnnouncementForm
    formData.expireTime = formData.expireTime ? formData.expireTime.toISOString() : null
    
    await request.put(`/announcement/admin/${id}`, formData)
    ElMessage.success('公告更新成功')
    editAnnouncementVisible.value = false
    loadAnnouncements()
  } catch (error) {
    if (typeof error === 'object') {
      console.error('更新公告失败:', error)
      ElMessage.error('更新公告失败')
    }
  }
}

const getAnnouncementTypeText = (type) => {
  const typeMap = {
    'NOTICE': '通知',
    'ANNOUNCEMENT': '公告',
    'MAINTENANCE': '维护'
  }
  return typeMap[type] || type
}

const getAnnouncementTypeColor = (type) => {
  const colorMap = {
    'NOTICE': 'primary',
    'ANNOUNCEMENT': 'success',
    'MAINTENANCE': 'warning'
  }
  return colorMap[type] || 'info'
}

const getAnnouncementStatusText = (status) => {
  const statusMap = {
    'DRAFT': '草稿',
    'PUBLISHED': '已发布',
    'ARCHIVED': '已归档'
  }
  return statusMap[status] || status
}

const getAnnouncementStatusColor = (status) => {
  const colorMap = {
    'DRAFT': 'info',
    'PUBLISHED': 'success',
    'ARCHIVED': 'warning'
  }
  return colorMap[status] || 'info'
}

// 系统设置相关方法
const loadSystemSettings = async () => {
  try {
    // TODO: 实现系统设置加载API
    ElMessage.info('系统设置功能开发中...')
  } catch (error) {
    console.error('加载系统设置失败:', error)
    ElMessage.error('加载系统设置失败')
  }
}

const saveSystemSettings = async () => {
  try {
    // TODO: 实现系统设置保存API
    ElMessage.success('设置保存成功')
  } catch (error) {
    console.error('保存系统设置失败:', error)
    ElMessage.error('保存系统设置失败')
  }
}

// 创建公告表单
const createAnnouncementForm = reactive({
  title: '',
  content: '',
  type: 'NOTICE',
  priority: 2,
  expireTime: null
})
const createAnnouncementFormRef = ref()

// 编辑公告表单
const editAnnouncementForm = reactive({
  id: null,
  title: '',
  content: '',
  type: 'NOTICE',
  priority: 2,
  expireTime: null
})
const editAnnouncementFormRef = ref()

// 公告表单验证规则
const announcementRules = {
  title: [
    { required: true, message: '请输入公告标题', trigger: 'blur' },
    { min: 2, max: 200, message: '标题长度在2到200个字符', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入公告内容', trigger: 'blur' },
    { min: 10, message: '内容长度不能少于10个字符', trigger: 'blur' }
  ],
  type: [
    { required: true, message: '请选择公告类型', trigger: 'change' }
  ],
  priority: [
    { required: true, message: '请选择优先级', trigger: 'change' }
  ]
}

// 座位状态处理函数
const publishAnnouncement = async (announcement) => {
  try {
    await request.post(`/announcement/admin/${announcement.id}/publish`)
    ElMessage.success('公告发布成功')
    loadAnnouncements()
  } catch (error) {
    console.error('发布公告失败:', error)
    ElMessage.error('发布公告失败')
  }
}

const archiveAnnouncement = async (announcement) => {
  try {
    await request.post(`/announcement/admin/${announcement.id}/archive`)
    ElMessage.success('公告归档成功')
    loadAnnouncements()
  } catch (error) {
    console.error('归档公告失败:', error)
    ElMessage.error('归档公告失败')
  }
}

const deleteAnnouncement = async (announcement) => {
  try {
    await ElMessageBox.confirm('确定要删除这条公告吗？', '确认删除', {
      type: 'warning'
    })
    
    await request.delete(`/announcement/admin/${announcement.id}`)
    ElMessage.success('删除成功')
    loadAnnouncements()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除公告失败:', error)
      ElMessage.error('删除公告失败')
    }
  }
}

// 座位状态处理函数
</script>

<style scoped>
/* 数据看板样式 */
.dashboard {
  padding: 0;
}

.stat-cards {
  margin-bottom: 24px;
}

.stat-card {
  border: none;
  box-shadow: 0 2px 12px rgba(66, 66, 66, 0.08);
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(66, 66, 66, 0.12);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 12px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
}

.today-reservations .stat-icon {
  background: linear-gradient(45deg, #22c55e, #16a34a);
}

.total-seats .stat-icon {
  background: linear-gradient(45deg, #3b82f6, #2563eb);
}

.active-users .stat-icon {
  background: linear-gradient(45deg, #f59e0b, #d97706);
}

.revenue .stat-icon {
  background: linear-gradient(45deg, #ef4444, #dc2626);
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 28px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #6b7280;
  font-weight: 500;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
}

.trend-value {
  font-weight: 600;
  padding: 2px 6px;
  border-radius: 4px;
}

.trend-value.positive {
  color: #059669;
  background: #d1fae5;
}

.trend-value.negative {
  color: #dc2626;
  background: #fee2e2;
}

.trend-value.neutral {
  color: #374151;
  background: #f3f4f6;
}

.trend-text {
  color: #6b7280;
}

/* 图表样式 */
.chart-section {
  margin-bottom: 24px;
}

.chart-card {
  border: none;
  box-shadow: 0 2px 12px rgba(66, 66, 66, 0.08);
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-header h3 {
  margin: 0;
  font-size: 18px;
  color: #1f2937;
}

.chart-subtitle {
  color: #6b7280;
  font-size: 14px;
}

.trend-chart, .pie-chart {
  padding: 20px;
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 热图样式 */
.heatmap-section {
  margin-bottom: 24px;
}

.usage-heatmap {
  padding: 20px;
}

.heatmap-grid {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.heatmap-labels {
  display: flex;
  flex-direction: column;
}

.time-labels {
  display: flex;
  flex-direction: column;
  gap: 2px;
  margin-right: 12px;
}

.time-label {
  height: 20px;
  font-size: 12px;
  color: #6b7280;
  display: flex;
  align-items: center;
}

.day-labels {
  display: flex;
  gap: 2px;
  writing-mode: vertical-lr;
  text-orientation: mixed;
}

.day-label {
  width: 20px;
  font-size: 12px;
  color: #6b7280;
  display: flex;
  align-items: center;
  justify-content: center;
}

.heatmap-cells {
  display: grid;
  grid-template-columns: repeat(14, 20px);
  grid-template-rows: repeat(7, 20px);
  gap: 2px;
}

.heatmap-cell {
  border-radius: 2px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.heatmap-cell:hover {
  transform: scale(1.1);
}

.heatmap-cell.low {
  background: #e5f3ff;
}

.heatmap-cell.medium {
  background: #93c5fd;
}

.heatmap-cell.high {
  background: #3b82f6;
}

.heatmap-legend {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 14px;
  color: #6b7280;
}

.legend-scale {
  display: flex;
  align-items: center;
  gap: 8px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
}

.legend-item::before {
  content: '';
  width: 12px;
  height: 12px;
  border-radius: 2px;
}

.legend-item.low::before {
  background: #e5f3ff;
}

.legend-item.medium::before {
  background: #93c5fd;
}

.legend-item.high::before {
  background: #3b82f6;
}

/* 最近活动样式 */
.recent-section {
  margin-bottom: 24px;
}

.activity-card {
  border: none;
  box-shadow: 0 2px 12px rgba(66, 66, 66, 0.08);
  height: 400px;
}

.recent-reservations {
  max-height: 300px;
  overflow-y: auto;
}

.reservation-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
  border-bottom: 1px solid #f3f4f6;
}

.reservation-item:last-child {
  border-bottom: none;
}

.reservation-info {
  flex: 1;
}

.reservation-user {
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 4px;
}

.reservation-details {
  font-size: 14px;
  color: #6b7280;
}

.seat-ranking {
  max-height: 300px;
  overflow-y: auto;
}

.ranking-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid #f3f4f6;
}

.ranking-item:last-child {
  border-bottom: none;
}

.ranking-number {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #f3f4f6;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  color: #374151;
  font-size: 14px;
}

.seat-info {
  flex: 1;
}

.seat-name {
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 4px;
}

.seat-usage {
  font-size: 14px;
  color: #6b7280;
}

.usage-bar {
  width: 60px;
  height: 8px;
  background: #f3f4f6;
  border-radius: 4px;
  overflow: hidden;
}

.usage-fill {
  height: 100%;
  background: linear-gradient(90deg, #3b82f6, #2563eb);
  border-radius: 4px;
  transition: width 0.5s ease;
}

/* 管理页面样式 */
.seat-management,
.reservation-management,
.user-management {
  padding: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 20px 0;
}

.page-header h2 {
  margin: 0;
  color: #1f2937;
  font-size: 24px;
  font-weight: 600;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.filter-card,
.table-card {
  border: none;
  box-shadow: 0 2px 12px rgba(66, 66, 66, 0.08);
  margin-bottom: 24px;
}

.filter-form {
  margin: 0;
}

.filter-form :deep(.el-form-item) {
  margin-bottom: 0;
}

.pagination-wrapper {
  margin-top: 20px;
  text-align: center;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .chart-section .el-col {
    margin-bottom: 20px;
  }
  
  .recent-section .el-col {
    margin-bottom: 20px;
  }
  
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
  
  .header-actions {
    width: 100%;
    justify-content: flex-end;
  }
  
  .filter-form {
    flex-direction: column;
  }
  
  .filter-form .el-form-item {
    width: 100%;
    margin-bottom: 16px;
  }
  
  .heatmap-grid {
    flex-direction: column;
  }
  
  .heatmap-cells {
    grid-template-columns: repeat(7, 20px);
    grid-template-rows: repeat(14, 20px);
  }
}

@media (max-width: 480px) {
  .stat-content {
    gap: 12px;
  }
  
  .stat-icon {
    width: 40px;
    height: 40px;
    font-size: 20px;
  }
  
  .stat-number {
    font-size: 24px;
  }
  
  .chart-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .heatmap-cells {
    grid-template-columns: repeat(7, 16px);
    grid-template-rows: repeat(14, 16px);
  }
  
  .heatmap-cell {
    border-radius: 1px;
  }
}
</style>