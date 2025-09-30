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
  background: var(--color-background-secondary);
  font-family: var(--font-family-base);
}

/* 侧边栏样式 */
.sidebar {
  width: 280px;
  background: var(--color-background-primary);
  border-right: 1px solid var(--color-border);
  transition: all var(--transition-slow);
  position: relative;
  z-index: 100;
  box-shadow: var(--shadow-xl);
  overflow: hidden;
}

.sidebar::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
}

.sidebar.collapsed {
  width: 80px;
}

.sidebar-header {
  height: 72px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 var(--spacing-lg);
  border-bottom: 1px solid var(--color-border);
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
  position: relative;
}

.logo {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  transition: var(--transition-base);
}

.logo-icon {
  width: 44px;
  height: 44px;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
  color: white;
  font-size: 20px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: var(--shadow-md);
  transition: var(--transition-base);
}

.logo-icon:hover {
  transform: scale(1.05);
  box-shadow: var(--shadow-lg);
}

.logo-text {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text-primary);
  transition: var(--transition-base);
}

.collapse-btn {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-base);
  border: 1px solid var(--color-border);
  background: var(--color-background-primary);
  color: var(--color-text-secondary);
  transition: var(--transition-base);
  display: flex;
  align-items: center;
  justify-content: center;
}

.collapse-btn:hover {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
  transform: rotate(180deg);
}

.sidebar-content {
  height: calc(100vh - 72px);
  overflow-y: auto;
  padding: var(--spacing-base) 0;
}

/* 菜单样式 */
.admin-menu {
  border: none;
  background: transparent;
  padding: 0 var(--spacing-base);
}

:deep(.admin-menu .el-menu-item) {
  margin: var(--spacing-xs) 0;
  border-radius: var(--radius-md);
  transition: var(--transition-base);
  font-weight: var(--font-weight-medium);
  height: 48px;
  line-height: 48px;
  position: relative;
  overflow: hidden;
  color: var(--color-text-secondary);
}

:deep(.admin-menu .el-menu-item::before) {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 0;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
  transition: width var(--transition-base);
}

:deep(.admin-menu .el-menu-item:hover) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  color: var(--color-primary);
  transform: translateX(4px);
}

:deep(.admin-menu .el-menu-item:hover::before) {
  width: 4px;
}

:deep(.admin-menu .el-menu-item.is-active) {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
  color: white;
  box-shadow: var(--shadow-md);
  transform: translateX(8px);
}

:deep(.admin-menu .el-menu-item.is-active::before) {
  width: 4px;
  background: rgba(255, 255, 255, 0.3);
}

:deep(.admin-menu .el-menu-item .el-icon) {
  margin-right: var(--spacing-base);
  font-size: 18px;
  transition: var(--transition-base);
}

:deep(.admin-menu .el-menu-item.is-active .el-icon) {
  transform: scale(1.1);
}

/* 主容器样式 */
.main-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
}

/* 顶部栏样式 */
.top-bar {
  height: 72px;
  background: var(--color-background-primary);
  border-bottom: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 var(--spacing-xl);
  box-shadow: var(--shadow-sm);
  position: relative;
  z-index: 10;
}

.top-bar::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent 0%, var(--color-primary) 50%, transparent 100%);
  opacity: 0.3;
}

.breadcrumb {
  color: var(--color-text-secondary);
  font-weight: var(--font-weight-medium);
}

:deep(.el-breadcrumb__item:last-child .el-breadcrumb__inner) {
  color: var(--color-primary);
  font-weight: var(--font-weight-semibold);
}

.user-actions {
  display: flex;
  align-items: center;
  gap: var(--spacing-lg);
}

.notification-btn {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-full);
  border: 1px solid var(--color-border);
  background: var(--color-background-primary);
  color: var(--color-text-secondary);
  transition: var(--transition-base);
  position: relative;
}

.notification-btn:hover {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
  transform: translateY(-1px);
  box-shadow: var(--shadow-md);
}

.notification-badge {
  position: absolute;
  top: -4px;
  right: -4px;
  width: 16px;
  height: 16px;
  background: var(--color-danger);
  color: white;
  border-radius: 50%;
  font-size: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: var(--font-weight-bold);
}

.user-info {
  display: flex;
  align-items: center;
  gap: var(--spacing-base);
  cursor: pointer;
  padding: var(--spacing-sm) var(--spacing-base);
  border-radius: var(--radius-md);
  transition: var(--transition-base);
  border: 1px solid var(--color-border);
  background: var(--color-background-primary);
}

.user-info:hover {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  border-color: var(--color-primary);
  transform: translateY(-1px);
  box-shadow: var(--shadow-md);
}

.user-avatar {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
  color: white;
  box-shadow: var(--shadow-sm);
}

.username {
  font-size: var(--font-size-sm);
  color: var(--color-text-primary);
  font-weight: var(--font-weight-semibold);
}

.user-role {
  font-size: var(--font-size-xs);
  color: var(--color-text-tertiary);
  font-weight: var(--font-weight-medium);
}

.user-details {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.dropdown-icon {
  color: var(--color-text-tertiary);
  font-size: 12px;
  transition: var(--transition-base);
}

.user-info:hover .dropdown-icon {
  color: var(--color-primary);
  transform: rotate(180deg);
}

/* 页面内容样式 */
.page-content {
  flex: 1;
  overflow-y: auto;
  padding: var(--spacing-xl);
  background: var(--color-background-secondary);
  position: relative;
}

.page-content::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background:
    radial-gradient(circle at 20% 20%, rgba(102, 126, 234, 0.03) 0%, transparent 50%),
    radial-gradient(circle at 80% 80%, rgba(118, 75, 162, 0.03) 0%, transparent 50%);
  pointer-events: none;
}

/* 自定义滚动条 */
.sidebar-content::-webkit-scrollbar {
  width: 6px;
}

.sidebar-content::-webkit-scrollbar-track {
  background: transparent;
}

.sidebar-content::-webkit-scrollbar-thumb {
  background: var(--color-border-dark);
  border-radius: var(--radius-full);
}

.sidebar-content::-webkit-scrollbar-thumb:hover {
  background: var(--color-primary);
}

.page-content::-webkit-scrollbar {
  width: 8px;
}

.page-content::-webkit-scrollbar-track {
  background: var(--color-background-secondary);
  border-radius: var(--radius-base);
}

.page-content::-webkit-scrollbar-thumb {
  background: var(--color-border-dark);
  border-radius: var(--radius-base);
  transition: var(--transition-base);
}

.page-content::-webkit-scrollbar-thumb:hover {
  background: var(--color-text-tertiary);
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .sidebar {
    width: 260px;
  }

  .top-bar {
    padding: 0 var(--spacing-lg);
  }

  .page-content {
    padding: var(--spacing-lg);
  }
}

@media (max-width: 768px) {
  .sidebar {
    position: fixed;
    top: 0;
    left: 0;
    height: 100vh;
    z-index: 1000;
    transform: translateX(-100%);
    transition: transform var(--transition-slow);
    width: 280px;
  }

  .sidebar.show {
    transform: translateX(0);
  }

  .sidebar.collapsed {
    transform: translateX(0);
    width: 280px;
  }

  .main-container {
    margin-left: 0;
    width: 100%;
  }

  .top-bar {
    padding: 0 var(--spacing-base);
  }

  .page-content {
    padding: var(--spacing-base);
  }

  .user-details {
    display: none;
  }
}

@media (max-width: 480px) {
  .sidebar-header {
    padding: 0 var(--spacing-base);
  }

  .logo-text {
    font-size: var(--font-size-lg);
  }

  .admin-menu {
    padding: 0 var(--spacing-sm);
  }

  .top-bar {
    height: 60px;
    padding: 0 var(--spacing-sm);
  }

  .user-actions {
    gap: var(--spacing-sm);
  }

  .notification-btn {
    width: 36px;
    height: 36px;
  }
}

/* 侧边栏动画效果 */
@keyframes slideInLeft {
  from {
    transform: translateX(-100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.sidebar.show {
  animation: slideInLeft var(--transition-slow);
}

/* Menu项目动画 */
:deep(.admin-menu .el-menu-item) {
  animation: fadeInUp 0.3s ease forwards;
}

:deep(.admin-menu .el-menu-item:nth-child(1)) { animation-delay: 0.1s; }
:deep(.admin-menu .el-menu-item:nth-child(2)) { animation-delay: 0.15s; }
:deep(.admin-menu .el-menu-item:nth-child(3)) { animation-delay: 0.2s; }
:deep(.admin-menu .el-menu-item:nth-child(4)) { animation-delay: 0.25s; }
:deep(.admin-menu .el-menu-item:nth-child(5)) { animation-delay: 0.3s; }
:deep(.admin-menu .el-menu-item:nth-child(6)) { animation-delay: 0.35s; }
:deep(.admin-menu .el-menu-item:nth-child(7)) { animation-delay: 0.4s; }

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 暗色模式适配 */
@media (prefers-color-scheme: dark) {
  .sidebar::before {
    opacity: 0.8;
  }

  .logo-text {
    filter: brightness(1.2);
  }

  .page-content::before {
    opacity: 0.5;
  }
}

/* 管理员页面卡片样式增强 */
.admin-card {
  background: var(--color-background-primary);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-lg);
  border: 1px solid var(--color-border);
  transition: var(--transition-base);
  position: relative;
  overflow: hidden;
}

.admin-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
}

.admin-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-2xl);
  border-color: var(--color-primary);
}

.admin-card-header {
  padding: var(--spacing-lg);
  border-bottom: 1px solid var(--color-border);
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.02) 0%, rgba(118, 75, 162, 0.02) 100%);
}

.admin-card-title {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-primary);
  margin: 0;
}

.admin-card-body {
  padding: var(--spacing-lg);
}

/* 管理员表格样式增强 */
.admin-table-container {
  background: var(--color-background-primary);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  border: 1px solid var(--color-border);
  overflow: hidden;
}

:deep(.admin-table .el-table__header) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
}

:deep(.admin-table .el-table__header th) {
  background: transparent !important;
  color: var(--color-text-secondary);
  font-weight: var(--font-weight-semibold);
  border-bottom: 2px solid var(--color-border);
}

:deep(.admin-table .el-table__row) {
  transition: var(--transition-base);
}

:deep(.admin-table .el-table__row:hover) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.03) 0%, rgba(118, 75, 162, 0.03) 100%);
}

/* 操作按钮样式增强 */
.admin-action-btn {
  border-radius: var(--radius-base);
  font-weight: var(--font-weight-medium);
  transition: var(--transition-base);
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-xs);
}

.admin-action-btn:hover {
  transform: translateY(-1px);
  box-shadow: var(--shadow-md);
}

.admin-action-btn.primary {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
  border: none;
  color: white;
}

.admin-action-btn.danger:hover {
  background: #dc2626;
  border-color: #dc2626;
}
</style>