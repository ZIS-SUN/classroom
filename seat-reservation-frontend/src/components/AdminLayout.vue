<template>
  <div class="admin-layout">
    <!-- 侧边栏 -->
    <div class="sidebar" :class="{ collapsed: isCollapsed }">
      <div class="sidebar-header">
        <div class="logo">
          <el-icon class="logo-icon"><Monitor /></el-icon>
          <span class="logo-text" v-show="!isCollapsed">管理后台</span>
        </div>
        <el-button 
          class="collapse-btn" 
          @click="toggleSidebar" 
          size="small" 
          type="text"
        >
          <el-icon><Menu /></el-icon>
        </el-button>
      </div>

      <div class="sidebar-content">
        <el-menu
          :default-active="activeMenu"
          class="admin-menu"
          :collapse="isCollapsed"
          @select="handleMenuSelect"
        >
          <el-menu-item index="dashboard">
            <el-icon><DataAnalysis /></el-icon>
            <span>数据看板</span>
          </el-menu-item>
          
          <el-menu-item index="seats">
            <el-icon><Grid /></el-icon>
            <span>座位管理</span>
          </el-menu-item>
          
          <el-menu-item index="reservations">
            <el-icon><Calendar /></el-icon>
            <span>预约管理</span>
          </el-menu-item>
          
          <el-menu-item index="users">
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </el-menu-item>
          
          <el-menu-item index="announcements">
            <el-icon><Bell /></el-icon>
            <span>公告管理</span>
          </el-menu-item>
          
          <el-menu-item index="reports">
            <el-icon><DocumentCopy /></el-icon>
            <span>报表统计</span>
          </el-menu-item>
          
          <el-menu-item index="settings">
            <el-icon><Setting /></el-icon>
            <span>系统设置</span>
          </el-menu-item>
        </el-menu>
      </div>
    </div>

    <!-- 主内容区 -->
    <div class="main-container">
      <!-- 顶部栏 -->
      <div class="top-bar">
        <div class="breadcrumb">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>管理后台</el-breadcrumb-item>
            <el-breadcrumb-item>{{ currentPageTitle }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        
        <div class="user-actions">
          <el-dropdown @command="handleUserAction">
            <span class="user-info">
              <el-avatar size="small" class="user-avatar">
                <el-icon><UserFilled /></el-icon>
              </el-avatar>
              <span class="username">{{ userInfo.username }}</span>
              <el-icon class="dropdown-icon"><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人信息</el-dropdown-item>
                <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>

      <!-- 页面内容 -->
      <div class="page-content">
        <router-view></router-view>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Monitor, Menu, DataAnalysis, Grid, Calendar, User, DocumentCopy,
  Setting, UserFilled, ArrowDown, Bell
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const isCollapsed = ref(false)
const activeMenu = ref('dashboard')

// 监听路由变化，更新活动菜单
watch(() => route.path, (newPath) => {
  const pathMap = {
    '/admin/dashboard': 'dashboard',
    '/admin/seats': 'seats',
    '/admin/reservations': 'reservations',
    '/admin/users': 'users',
    '/admin/announcements': 'announcements',
    '/admin/reports': 'reports',
    '/admin/settings': 'settings'
  }
  activeMenu.value = pathMap[newPath] || 'dashboard'
}, { immediate: true })

// 用户信息 - 从localStorage获取
const userInfo = computed(() => {
  const user = JSON.parse(localStorage.getItem('userInfo') || '{}')
  return {
    username: user.username || '管理员',
    realName: user.realName || '系统管理员'
  }
})

// 当前页面标题
const currentPageTitle = computed(() => {
  const menuTitles = {
    dashboard: '数据看板',
    seats: '座位管理',
    reservations: '预约管理',
    users: '用户管理',
    announcements: '公告管理',
    reports: '报表统计',
    settings: '系统设置'
  }
  return menuTitles[activeMenu.value] || '数据看板'
})

// 切换侧边栏折叠状态
const toggleSidebar = () => {
  isCollapsed.value = !isCollapsed.value
}

// 处理菜单选择
const handleMenuSelect = (key) => {
  router.push(`/admin/${key}`)
}

// 处理用户操作
const handleUserAction = async (command) => {
  if (command === 'logout') {
    try {
      await ElMessageBox.confirm(
        '确定要退出登录吗？',
        '提示',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )
      
      // 清除用户数据
      userStore.logout()
      
      // 清除本地存储
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
      
      ElMessage.success('已退出登录')
      
      // 强制跳转到登录页
      window.location.href = '/login'
    } catch {
      // 用户取消
    }
  } else if (command === 'profile') {
    ElMessage.info('个人信息功能开发中')
  }
}

</script>

<style scoped>
.admin-layout {
  display: flex;
  height: 100vh;
  background-color: #f5f5f5;
}

/* 侧边栏样式 */
.sidebar {
  width: 250px;
  background: linear-gradient(145deg, #2c3e50, #34495e);
  color: white;
  transition: width 0.3s ease;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
}

.sidebar.collapsed {
  width: 64px;
}

.sidebar-header {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  border-bottom: 1px solid #455a64;
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
  color: #fff;
}

.logo-icon {
  font-size: 24px;
  color: #3498db;
}

.logo-text {
  font-size: 18px;
  font-weight: 600;
}

.collapse-btn {
  color: #ecf0f1 !important;
  border: none !important;
  background: transparent !important;
}

.collapse-btn:hover {
  background: rgba(255, 255, 255, 0.1) !important;
  color: #3498db !important;
}

.sidebar-content {
  flex: 1;
  overflow-y: auto;
}

/* 菜单样式 */
.admin-menu {
  border-right: none;
  background: transparent;
}

:deep(.admin-menu .el-menu-item) {
  color: #ecf0f1;
  border-radius: 8px;
  margin: 4px 12px;
  padding-left: 20px;
  transition: all 0.3s ease;
}

:deep(.admin-menu .el-menu-item:hover) {
  background: rgba(52, 152, 219, 0.2);
  color: #3498db;
}

:deep(.admin-menu .el-menu-item.is-active) {
  background: linear-gradient(45deg, #3498db, #2980b9);
  color: white;
  box-shadow: 0 2px 8px rgba(52, 152, 219, 0.3);
}

:deep(.admin-menu .el-menu-item .el-icon) {
  margin-right: 8px;
  font-size: 18px;
}

/* 主容器样式 */
.main-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 顶部栏样式 */
.top-bar {
  height: 60px;
  background: white;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
}

.breadcrumb {
  display: flex;
  align-items: center;
}

:deep(.breadcrumb .el-breadcrumb__item) {
  font-weight: 500;
}

.user-actions {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.user-info:hover {
  background: #f8f9fa;
}

.user-avatar {
  background: linear-gradient(45deg, #3498db, #2980b9);
}

.username {
  font-weight: 500;
  color: #2c3e50;
}

.dropdown-icon {
  color: #7f8c8d;
  font-size: 12px;
}

/* 页面内容样式 */
.page-content {
  flex: 1;
  padding: 24px;
  overflow-y: auto;
  background: #f8f9fa;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .sidebar {
    width: 64px;
  }
  
  .sidebar.collapsed {
    width: 0;
    overflow: hidden;
  }
  
  .page-content {
    padding: 16px;
  }
  
  .top-bar {
    padding: 0 16px;
  }
  
  .username {
    display: none;
  }
}

/* 滚动条样式 */
.sidebar-content::-webkit-scrollbar {
  width: 4px;
}

.sidebar-content::-webkit-scrollbar-track {
  background: transparent;
}

.sidebar-content::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 2px;
}

.sidebar-content::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.3);
}

.page-content::-webkit-scrollbar {
  width: 6px;
}

.page-content::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.page-content::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.page-content::-webkit-scrollbar-thumb:hover {
  background: #a1a1a1;
}
</style>