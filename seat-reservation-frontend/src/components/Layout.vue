<template>
  <div class="layout">
    <el-header class="header">
      <div class="header-left">
        <div class="logo">
          <div class="logo-icon">
            <el-icon><Grid /></el-icon>
          </div>
          <span class="logo-text">StudySpace</span>
        </div>
      </div>

      <div class="header-right">
        <nav class="navigation">
          <el-menu
            mode="horizontal"
            :default-active="$route.path"
            @select="handleMenuSelect"
            class="header-menu"
          >
          <!-- 管理员菜单 -->
          <template v-if="userStore.isAdmin">
            <el-menu-item index="/admin">
              <el-icon><Setting /></el-icon>
              管理后台
            </el-menu-item>
          </template>
          
          <!-- 普通用户菜单 -->
          <template v-else>
            <el-menu-item index="/home">
              <el-icon><HomeFilled /></el-icon>
              首页
            </el-menu-item>
            
            <el-menu-item index="/seat-map">
              <el-icon><Grid /></el-icon>
              座位地图
            </el-menu-item>
            
            <el-menu-item index="/reservations">
              <el-icon><Calendar /></el-icon>
              我的预定
            </el-menu-item>

            <el-menu-item index="/favorites">
              <el-icon><Star /></el-icon>
              我的收藏
            </el-menu-item>
            
            <el-menu-item index="/profile">
              <el-icon><User /></el-icon>
              个人信息
            </el-menu-item>
          </template>
          </el-menu>
        </nav>

        <div class="user-section">
          <el-dropdown @command="handleCommand" trigger="click">
            <div class="user-avatar">
              <div class="avatar-icon">
                <el-icon><UserFilled /></el-icon>
              </div>
              <div class="user-details">
                <span class="user-name">{{ userStore.user?.realName || userStore.user?.username }}</span>
                <span class="user-role">{{ userStore.isAdmin ? '管理员' : '学生' }}</span>
              </div>
              <el-icon class="dropdown-arrow"><ArrowDown /></el-icon>
            </div>

            <template #dropdown>
              <el-dropdown-menu class="user-dropdown">
                <el-dropdown-item command="profile" class="dropdown-item">
                  <el-icon><User /></el-icon>
                  <span>个人资料</span>
                </el-dropdown-item>
                <el-dropdown-item command="logout" divided class="dropdown-item logout">
                  <el-icon><SwitchButton /></el-icon>
                  <span>退出登录</span>
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </el-header>
    
    <el-main class="main">
      <slot />
    </el-main>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { HomeFilled, Grid, Calendar, User, Setting, UserFilled, Star, ArrowDown, SwitchButton } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const handleMenuSelect = (index) => {
  if (index !== router.currentRoute.value.path) {
    router.push(index)
  }
}

const handleCommand = async (command) => {
  if (command === 'profile') {
    router.push('/profile')
  } else if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      
      // 清除用户数据
      userStore.logout()
      
      // 直接使用 window.location 强制跳转
      window.location.href = '/login'
    } catch {
      // 用户取消
    }
  }
}
</script>

<style scoped>
/* 新的米色+黑色+橙色主题配色 */
.layout {
  min-height: 100vh;
  background: #faf8f5; /* 60% 浅米色背景 */
}

.header {
  background: #ffffff;
  border-bottom: 1px solid #e8e4df; /* 浅米色边框 */
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32px;
  height: 64px;
  box-shadow: 0 1px 3px 0 rgba(66, 66, 66, 0.08);
  position: relative;
  z-index: 100;
}

/* Logo样式 */
.logo {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #ff6b35 0%, #ff8f65 100%); /* 10% 橙色渐变 */
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 16px;
}

.logo-text {
  font-size: 20px;
  font-weight: 600;
  color: #2d3748; /* 30% 深灰色文字 */
  letter-spacing: -0.025em;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 24px;
}

.navigation {
  display: flex;
  align-items: center;
}

.header-menu {
  border: none;
  background: transparent;
  height: auto;
}

.header-menu .el-menu-item {
  border-bottom: none !important;
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  color: #718096; /* 30% 深灰色 */
  border-radius: 8px;
  margin: 0 4px;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  height: auto;
  line-height: 1.5;
  position: relative;
}

.header-menu .el-menu-item:hover {
  color: #2d3748; /* 30% 深灰色 */
  background: #f7f4f0; /* 60% 浅米色悬停 */
}

.header-menu .el-menu-item.is-active {
  color: #ff6b35; /* 10% 橙色强调 */
  background: rgba(255, 107, 53, 0.1); /* 橙色半透明背景 */
}

.header-menu .el-menu-item .el-icon {
  margin-right: 8px;
  font-size: 16px;
}

/* 用户头像区域 */
.user-section {
  position: relative;
}

.user-avatar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 12px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid #e8e4df; /* 浅米色边框 */
  background: #ffffff;
}

.user-avatar:hover {
  background: #faf8f5; /* 60% 浅米色悬停背景 */
  border-color: #d4c5b9; /* 更深的米色边框 */
  box-shadow: 0 2px 8px 0 rgba(66, 66, 66, 0.08);
}

.avatar-icon {
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #ff6b35 0%, #ff8f65 100%); /* 10% 橙色渐变 */
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 14px;
}

.user-details {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.user-name {
  font-size: 14px;
  font-weight: 600;
  color: #2d3748; /* 30% 深灰色 */
  line-height: 1;
}

.user-role {
  font-size: 12px;
  color: #718096; /* 30% 深灰色 */
  line-height: 1;
}

.dropdown-arrow {
  color: #9ca3af;
  font-size: 12px;
  transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.user-avatar:hover .dropdown-arrow {
  transform: rotate(180deg);
}

/* 下拉菜单样式 */
:deep(.user-dropdown) {
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  box-shadow: 0 10px 25px -5px rgba(66, 66, 66, 0.1), 0 4px 6px -2px rgba(66, 66, 66, 0.05);
  overflow: hidden;
  padding: 6px;
}

:deep(.dropdown-item) {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 12px;
  border-radius: 8px;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  font-size: 14px;
  color: #374151;
}

:deep(.dropdown-item:hover) {
  background: #f3f4f6;
  color: #1f2937;
}

:deep(.dropdown-item.logout) {
  color: #dc2626;
}

:deep(.dropdown-item.logout:hover) {
  background: #fef2f2;
  color: #dc2626;
}

.main {
  padding: 32px;
  background: #faf8f5; /* 60% 浅米色背景 */
  min-height: calc(100vh - 64px);
  position: relative;
}

/* 移动端响应式优化 */
@media (max-width: 768px) {
  .header {
    padding: 0 16px;
    flex-direction: column;
    gap: 12px;
    height: auto;
    min-height: 60px;
  }
  
  .header-left h3 {
    font-size: 20px;
    text-align: center;
    margin-bottom: 4px;
  }
  
  .header-right {
    width: 100%;
    flex-direction: column;
    gap: 8px;
  }
  
  .header-menu {
    width: 100%;
    justify-content: center;
  }
  
  .header-menu .el-menu-item {
    padding: 0 12px;
    font-size: 15px;
    min-width: 80px;
    justify-content: center;
  }
  
  .user-info {
    align-self: center;
    font-size: 14px;
    padding: 6px 12px;
  }
  
  .main {
    padding: 16px;
    min-height: calc(100vh - 120px);
  }
}

@media (max-width: 480px) {
  .header {
    padding: 0 12px;
    gap: 8px;
  }
  
  .header-left h3 {
    font-size: 18px;
  }
  
  .header-menu .el-menu-item {
    padding: 0 8px;
    font-size: 14px;
    min-width: 60px;
  }
  
  .header-menu .el-menu-item .el-icon {
    font-size: 18px;
  }
  
  .user-info {
    font-size: 13px;
    padding: 6px 10px;
  }
  
  .main {
    padding: 12px;
  }
}

/* 隐藏移动端不必要的图标文字 */
@media (max-width: 480px) {
  .header-menu .el-menu-item span {
    display: none;
  }
  
  .header-menu .el-menu-item {
    min-width: 48px;
    padding: 0 6px;
  }
}
</style>