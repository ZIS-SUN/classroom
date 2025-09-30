<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <h2>自习室座位预定</h2>
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
    const result = await authApi.login(form)
    
    // 现在响应拦截器返回完整的 {code, message, data} 结构
    if (result && result.code === 200) {
      const response = result.data
      
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
      
      // 根据用户角色跳转到不同页面
      if (response.role === 'ADMIN') {
        router.push('/admin')
      } else {
        router.push('/seat-map')
      }
    } else {
      ElMessage.error(result?.message || '登录失败')
    }
    
  } catch (error) {
    console.error('登录失败:', error)
    ElMessage.error('登录失败，请检查网络连接')
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
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
  background: 
    radial-gradient(circle at 20% 50%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
    radial-gradient(circle at 80% 20%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
    radial-gradient(circle at 40% 80%, rgba(120, 119, 198, 0.2) 0%, transparent 50%);
  animation: float 6s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}

.login-card {
  width: 100%;
  max-width: 400px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 40px 32px;
  box-shadow: 
    0 20px 40px rgba(66, 66, 66, 0.1),
    0 0 0 1px rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  z-index: 1;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.login-card:hover {
  transform: translateY(-5px);
  box-shadow: 
    0 30px 60px rgba(66, 66, 66, 0.15),
    0 0 0 1px rgba(255, 255, 255, 0.3);
}

.login-header {
  text-align: center;
  margin-bottom: 32px;
}

.login-header h2 {
  color: var(--color-text-primary);
  margin: 0 0 8px 0;
  font-weight: 600;
  font-size: 24px;
  line-height: 1.2;
}

.subtitle {
  color: var(--color-text-secondary);
  margin: 0;
  font-size: 14px;
  font-weight: 400;
  line-height: 1.4;
}

:deep(.el-form-item) {
  margin-bottom: 20px;
}

:deep(.el-input__wrapper) {
  border-radius: var(--radius-base);
  box-shadow: none;
  border: 1px solid var(--color-border);
  transition: all 0.2s ease;
  padding: 12px 16px;
  background-color: var(--color-background-primary);
}

:deep(.el-input__wrapper:hover) {
  border-color: var(--color-border-dark);
  background-color: var(--color-background-primary);
}

:deep(.el-input__wrapper.is-focus) {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.1);
  background-color: var(--color-background-primary);
}

:deep(.el-input__inner) {
  font-size: 14px;
  color: var(--color-text-secondary);
  font-weight: 400;
}

:deep(.el-input__inner::placeholder) {
  color: var(--color-text-placeholder);
  font-weight: 400;
}

:deep(.el-input__prefix-inner) {
  color: var(--color-text-tertiary);
}

.login-btn {
  width: 100%;
  height: 48px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  transition: all 0.3s ease;
  margin-top: 12px;
  position: relative;
  overflow: hidden;
  color: white;
  letter-spacing: 0.5px;
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
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
}

.login-btn:active {
  transform: translateY(0);
  transition: transform 0.1s ease;
}

.register-link {
  text-align: center;
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid var(--color-border);
  font-size: 14px;
  color: var(--color-text-tertiary);
}

.register-link span {
  margin-right: 4px;
}

:deep(.el-link) {
  font-weight: 500;
  text-decoration: none;
  color: var(--color-primary);
}

:deep(.el-link:hover) {
  text-decoration: none;
  color: var(--color-primary-hover);
}

/* 移动端响应式优化 */
@media (max-width: 768px) {
  .login-container {
    padding: 16px;
    min-height: 100vh;
  }
  
  .login-card {
    max-width: 100%;
    padding: 40px 24px;
    margin: 0;
    border-radius: 16px;
  }
  
  .login-header h2 {
    font-size: 28px;
    margin-bottom: 6px;
  }
  
  .subtitle {
    font-size: 16px;
  }
  
  .login-header {
    margin-bottom: 28px;
  }
  
  :deep(.el-form-item) {
    margin-bottom: 18px;
  }
  
  :deep(.el-input__wrapper) {
    padding: 12px 16px;
  }
  
  :deep(.el-input__inner) {
    font-size: 17px; /* 防止iOS缩放 */
  }
  
  .login-btn {
    height: 48px;
    font-size: 17px;
    margin-top: 6px;
  }
  
  .register-link {
    margin-top: 20px;
    padding-top: 20px;
    font-size: 15px;
  }
}

@media (max-width: 480px) {
  .login-container {
    padding: 12px;
  }
  
  .login-card {
    padding: 32px 20px;
    border-radius: 16px;
  }
  
  .login-header h2 {
    font-size: 26px;
  }
  
  .subtitle {
    font-size: 15px;
  }
  
  .login-header {
    margin-bottom: 24px;
  }
  
  :deep(.el-form-item) {
    margin-bottom: 16px;
  }
  
  :deep(.el-input__wrapper) {
    padding: 12px 16px;
  }
  
  .login-btn {
    height: 48px;
    font-size: 17px;
  }
  
  .register-link {
    font-size: 14px;
  }
}

/* 横屏模式优化 */
@media (max-height: 600px) and (orientation: landscape) {
  .login-container {
    padding: 12px;
  }
  
  .login-card {
    padding: 24px;
    max-width: 380px;
  }
  
  .login-header {
    margin-bottom: 16px;
  }
  
  .login-header h2 {
    font-size: 24px;
    margin-bottom: 4px;
  }
  
  .subtitle {
    font-size: 15px;
  }
  
  :deep(.el-form-item) {
    margin-bottom: 12px;
  }
  
  .login-btn {
    height: 44px;
  }
  
  .register-link {
    margin-top: 12px;
    padding-top: 12px;
  }
}
</style>