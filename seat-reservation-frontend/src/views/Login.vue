<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <h2>自习室座位预约</h2>
        <p class="subtitle">请登录您的账户</p>
      </div>
      
      <el-form ref="loginForm" :model="form" :rules="rules" size="large">
        <el-form-item prop="username">
          <el-input
            v-model="form.username"
            placeholder="请输入用户名"
            :prefix-icon="User"
            maxlength="50"
          />
        </el-form-item>
        
        <el-form-item prop="password">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="请输入密码"
            :prefix-icon="Lock"
            maxlength="50"
            @keyup.enter="handleLogin"
            show-password
          />
        </el-form-item>
        
        <el-form-item>
          <el-button 
            type="primary" 
            class="login-btn"
            :loading="loading"
            @click="handleLogin"
          >
            {{ loading ? '登录中...' : '登录' }}
          </el-button>
        </el-form-item>
        
        <div class="register-link">
          <span>还没有账户？</span>
          <el-link type="primary" @click="$router.push('/register')">立即注册</el-link>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import { authApi } from '@/api/auth'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const loginForm = ref(null)
const loading = ref(false)

const form = reactive({
  username: '',
  password: ''
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  try {
    const valid = await loginForm.value.validate()
    if (!valid) return

    loading.value = true
    const response = await authApi.login(form)
    
    userStore.setToken(response.token)
    userStore.setUser({
      id: response.id,
      username: response.username,
      realName: response.realName,
      role: response.role,
      email: response.email,
      phone: response.phone
    })
    
    ElMessage.success('登录成功')
    router.push('/seat-map')
    
  } catch (error) {
    console.error('登录失败:', error)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  padding: 20px;
  position: relative;
}

.login-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(255, 119, 48, 0.15) 0%, transparent 50%),
    radial-gradient(circle at 40% 40%, rgba(120, 119, 198, 0.15) 0%, transparent 50%);
}

.login-card {
  width: 100%;
  max-width: 420px;
  background: white;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  position: relative;
  z-index: 1;
}

.login-header {
  text-align: center;
  margin-bottom: 40px;
}

.login-header h2 {
  color: #2c3e50;
  margin: 0 0 12px 0;
  font-weight: 700;
  font-size: 28px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.subtitle {
  color: #7f8c8d;
  margin: 0;
  font-size: 16px;
  font-weight: 500;
}

:deep(.el-form-item) {
  margin-bottom: 24px;
}

:deep(.el-input__wrapper) {
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  border: 1px solid #e8eaed;
  transition: all 0.3s ease;
  padding: 8px 16px;
}

:deep(.el-input__wrapper:hover) {
  border-color: #667eea;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
}

:deep(.el-input__wrapper.is-focus) {
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

:deep(.el-input__inner) {
  font-size: 15px;
  color: #2c3e50;
}

.login-btn {
  width: 100%;
  height: 52px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.login-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.login-btn:hover::before {
  left: 100%;
}

.login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.register-link {
  text-align: center;
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid #f0f2f5;
  font-size: 14px;
  color: #7f8c8d;
}

.register-link span {
  margin-right: 8px;
}

:deep(.el-link) {
  font-weight: 600;
  text-decoration: none;
}

:deep(.el-link:hover) {
  text-decoration: underline;
}

/* 移动端响应式优化 */
@media (max-width: 768px) {
  .login-container {
    padding: 15px;
    min-height: 100vh;
  }
  
  .login-card {
    max-width: 100%;
    padding: 30px 25px;
    margin: 0;
  }
  
  .login-header h2 {
    font-size: 24px;
    margin-bottom: 8px;
  }
  
  .subtitle {
    font-size: 15px;
  }
  
  .login-header {
    margin-bottom: 30px;
  }
  
  :deep(.el-form-item) {
    margin-bottom: 20px;
  }
  
  :deep(.el-input__wrapper) {
    padding: 10px 14px;
  }
  
  :deep(.el-input__inner) {
    font-size: 16px; /* 防止iOS缩放 */
  }
  
  .login-btn {
    height: 48px;
    font-size: 16px;
    margin-top: 10px;
  }
  
  .register-link {
    margin-top: 20px;
    padding-top: 20px;
    font-size: 14px;
  }
}

@media (max-width: 480px) {
  .login-container {
    padding: 10px;
  }
  
  .login-card {
    padding: 25px 20px;
    border-radius: 12px;
  }
  
  .login-header h2 {
    font-size: 22px;
  }
  
  .subtitle {
    font-size: 14px;
  }
  
  .login-header {
    margin-bottom: 25px;
  }
  
  :deep(.el-form-item) {
    margin-bottom: 18px;
  }
  
  :deep(.el-input__wrapper) {
    padding: 9px 12px;
  }
  
  .login-btn {
    height: 44px;
    font-size: 15px;
  }
  
  .register-link {
    font-size: 13px;
  }
}

/* 横屏模式优化 */
@media (max-height: 600px) and (orientation: landscape) {
  .login-container {
    padding: 10px;
  }
  
  .login-card {
    padding: 20px;
    max-width: 420px;
  }
  
  .login-header {
    margin-bottom: 20px;
  }
  
  .login-header h2 {
    font-size: 20px;
    margin-bottom: 5px;
  }
  
  .subtitle {
    font-size: 13px;
  }
  
  :deep(.el-form-item) {
    margin-bottom: 15px;
  }
  
  .login-btn {
    height: 42px;
  }
  
  .register-link {
    margin-top: 15px;
    padding-top: 15px;
  }
}
</style>