<template>
  <div class="layout">
    <el-header class="header">
      <div class="header-left">
        <h3>自习室座位预约</h3>
      </div>
      
      <div class="header-right">
        <el-menu
          mode="horizontal"
          :default-active="$route.path"
          @select="handleMenuSelect"
          class="header-menu"
        >
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
            我的预约
          </el-menu-item>
          
          <el-menu-item index="/profile">
            <el-icon><User /></el-icon>
            个人信息
          </el-menu-item>
          
          <el-menu-item 
            v-if="userStore.isAdmin" 
            index="/admin"
          >
            <el-icon><Setting /></el-icon>
            管理后台
          </el-menu-item>
        </el-menu>
        
        <el-dropdown @command="handleCommand">
          <span class="user-info">
            <el-icon><UserFilled /></el-icon>
            {{ userStore.user?.realName || userStore.user?.username }}
          </span>
          
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">个人资料</el-dropdown-item>
              <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
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
import { HomeFilled, Grid, Calendar, User, Setting, UserFilled } from '@element-plus/icons-vue'
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
      
      userStore.logout()
      ElMessage.success('已退出登录')
      router.push('/login')
    } catch {
      // 用户取消
    }
  }
}
</script>

<style scoped>
.layout {
  min-height: 100vh;
}

.header {
  background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
  border-bottom: 1px solid #e9ecef;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 30px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(10px);
  position: relative;
}

.header-left h3 {
  margin: 0;
  color: #2c3e50;
  font-weight: 700;
  font-size: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.header-menu {
  border: none;
  background: transparent;
}

.header-menu .el-menu-item {
  border-bottom: none !important;
  padding: 0 15px;
}

.header-menu .el-menu-item:hover,
.header-menu .el-menu-item.is-active {
  color: #409eff;
  background: transparent;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #666;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 6px;
  transition: all 0.3s;
}

.user-info:hover {
  background: #f5f5f5;
  color: #333;
}

.main {
  padding: 24px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  min-height: calc(100vh - 60px);
  position: relative;
}

.main::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 85% 1%, rgba(255, 119, 48, 0.05) 0%, transparent 50%),
    radial-gradient(circle at 15% 90%, rgba(120, 119, 198, 0.08) 0%, transparent 50%);
  pointer-events: none;
}

/* 移动端响应式优化 */
@media (max-width: 768px) {
  .header {
    padding: 0 15px;
    flex-direction: column;
    gap: 15px;
    height: auto;
    min-height: 60px;
  }
  
  .header-left h3 {
    font-size: 18px;
    text-align: center;
    margin-bottom: 5px;
  }
  
  .header-right {
    width: 100%;
    flex-direction: column;
    gap: 10px;
  }
  
  .header-menu {
    width: 100%;
    justify-content: center;
  }
  
  .header-menu .el-menu-item {
    padding: 0 10px;
    font-size: 14px;
    min-width: 80px;
    justify-content: center;
  }
  
  .user-info {
    align-self: center;
    font-size: 14px;
    padding: 6px 10px;
  }
  
  .main {
    padding: 15px;
    min-height: calc(100vh - 120px);
  }
}

@media (max-width: 480px) {
  .header {
    padding: 0 10px;
    gap: 10px;
  }
  
  .header-left h3 {
    font-size: 16px;
  }
  
  .header-menu .el-menu-item {
    padding: 0 8px;
    font-size: 13px;
    min-width: 70px;
  }
  
  .header-menu .el-menu-item .el-icon {
    font-size: 16px;
  }
  
  .user-info {
    font-size: 13px;
    padding: 5px 8px;
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
    min-width: 50px;
    padding: 0 5px;
  }
}
</style>