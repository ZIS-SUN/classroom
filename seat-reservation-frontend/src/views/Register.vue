<template>
  <div class="register-container">
    <div class="register-card">
      <div class="register-header">
        <h2>注册新账户</h2>
        <p class="subtitle">创建您的自习室预约账户</p>
      </div>
      
      <el-form ref="registerForm" :model="form" :rules="rules" size="large">
        <el-form-item prop="username">
          <el-input
            v-model="form.username"
            placeholder="用户名"
            :prefix-icon="User"
            maxlength="20"
          />
        </el-form-item>
        
        <el-form-item prop="realName">
          <el-input
            v-model="form.realName"
            placeholder="真实姓名"
            :prefix-icon="UserFilled"
            maxlength="20"
          />
        </el-form-item>
        
        <el-form-item prop="password">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="密码"
            :prefix-icon="Lock"
            maxlength="50"
            show-password
          />
        </el-form-item>
        
        <el-form-item prop="confirmPassword">
          <el-input
            v-model="form.confirmPassword"
            type="password"
            placeholder="确认密码"
            :prefix-icon="Lock"
            maxlength="50"
            show-password
          />
        </el-form-item>
        
        <el-form-item prop="studentId">
          <el-input
            v-model="form.studentId"
            placeholder="学号（选填）"
            :prefix-icon="Stamp"
            maxlength="20"
          />
        </el-form-item>
        
        <el-form-item prop="phone">
          <el-input
            v-model="form.phone"
            placeholder="手机号（选填）"
            :prefix-icon="Phone"
            maxlength="11"
          />
        </el-form-item>
        
        <el-form-item prop="email">
          <el-input
            v-model="form.email"
            placeholder="邮箱（选填）"
            :prefix-icon="Message"
            maxlength="50"
          />
        </el-form-item>
        
        <el-form-item>
          <el-button 
            type="primary" 
            class="register-btn"
            :loading="loading"
            @click="handleRegister"
          >
            {{ loading ? '注册中...' : '注册' }}
          </el-button>
        </el-form-item>
        
        <div class="login-link">
          <span>已有账户？</span>
          <el-link type="primary" @click="$router.push('/login')">立即登录</el-link>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, UserFilled, Lock, Stamp, Phone, Message } from '@element-plus/icons-vue'
import { authApi } from '@/api/auth'

const router = useRouter()
const registerForm = ref(null)
const loading = ref(false)

const form = reactive({
  username: '',
  realName: '',
  password: '',
  confirmPassword: '',
  studentId: '',
  phone: '',
  email: ''
})

const validateConfirmPassword = (rule, value, callback) => {
  if (value !== form.password) {
    callback(new Error('两次输入密码不一致'))
  } else {
    callback()
  }
}

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在 3 到 20 个字符', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9_]+$/, message: '用户名只能包含字母、数字和下划线', trigger: 'blur' }
  ],
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '姓名长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 50, message: '密码长度在 6 到 50 个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ]
}

const handleRegister = async () => {
  try {
    const valid = await registerForm.value.validate()
    if (!valid) return

    loading.value = true
    
    const registerData = {
      username: form.username,
      realName: form.realName,
      password: form.password,
      studentId: form.studentId || null,
      phone: form.phone || null,
      email: form.email || null
    }
    
    const result = await authApi.register(registerData)
    
    // 处理新的响应格式
    if (result && result.code === 200) {
      ElMessage.success('注册成功，请登录')
      router.push('/login')
    } else {
      ElMessage.error(result?.message || '注册失败')
    }
    
  } catch (error) {
    console.error('注册失败:', error)
    ElMessage.error('注册失败，请检查网络连接')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.register-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.register-card {
  width: 100%;
  max-width: 400px;
  background: white;
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 15px 35px rgba(66, 66, 66, 0.1);
}

.register-header {
  text-align: center;
  margin-bottom: 30px;
}

.register-header h2 {
  color: #333;
  margin: 0 0 8px 0;
  font-weight: 600;
}

.subtitle {
  color: #666;
  margin: 0;
  font-size: 14px;
}

.register-btn {
  width: 100%;
  height: 44px;
  font-size: 16px;
  font-weight: 500;
}

.login-link {
  text-align: center;
  margin-top: 20px;
  font-size: 14px;
  color: #666;
}

.login-link span {
  margin-right: 8px;
}
</style>