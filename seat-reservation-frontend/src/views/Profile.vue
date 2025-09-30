<template>
  <Layout>
    <div class="profile">
      <el-row :gutter="20">
        <el-col :span="8">
          <!-- 钱包卡片 -->
          <el-card class="wallet-card">
            <WalletBalance />
          </el-card>
          
          <!-- 用户信息卡片 -->
          <el-card style="margin-top: 20px;">
            <div class="user-avatar">
              <div class="avatar-container">
                <el-avatar 
                  :size="80" 
                  :src="form.avatarUrl" 
                  :icon="UserFilled"
                  class="user-avatar-img"
                />
                <el-upload
                  action="/api/upload/avatar"
                  :headers="uploadHeaders"
                  :show-file-list="false"
                  :before-upload="beforeAvatarUpload"
                  :on-success="handleAvatarSuccess"
                  :on-error="handleUploadError"
                  class="avatar-uploader"
                  accept="image/*"
                >
                  <div class="avatar-overlay">
                    <el-icon><Camera /></el-icon>
                    <span>更换头像</span>
                  </div>
                </el-upload>
              </div>
              <h3>{{ userStore.user?.realName || userStore.user?.username }}</h3>
              <el-tag :type="userStore.isAdmin ? 'danger' : 'primary'" size="small">
                {{ userStore.isAdmin ? '管理员' : '普通用户' }}
              </el-tag>
            </div>
          </el-card>
        </el-col>
        
        <el-col :span="16">
          <el-card>
            <template #header>
              <div class="card-header">
                <span>个人信息</span>
                <el-button type="primary" size="small" @click="editMode = !editMode">
                  {{ editMode ? '取消编辑' : '编辑资料' }}
                </el-button>
              </div>
            </template>
            
            <el-form 
              ref="profileForm"
              :model="form" 
              :rules="rules"
              label-width="100px"
              :disabled="!editMode"
            >
              <el-form-item label="用户名：">
                <el-input v-model="form.username" disabled />
              </el-form-item>
              
              <el-form-item label="真实姓名：" prop="realName">
                <el-input v-model="form.realName" maxlength="20" />
              </el-form-item>
              
              <el-form-item label="学号：" prop="studentId">
                <el-input v-model="form.studentId" maxlength="20" placeholder="选填" />
              </el-form-item>
              
              <el-form-item label="手机号：" prop="phone">
                <el-input v-model="form.phone" maxlength="11" placeholder="选填" />
              </el-form-item>
              
              <el-form-item label="邮箱：" prop="email">
                <el-input v-model="form.email" maxlength="50" placeholder="选填" />
              </el-form-item>
              
              <el-form-item label="用户角色：">
                <el-input :value="userStore.isAdmin ? '管理员' : '普通用户'" disabled />
              </el-form-item>
              
              <el-form-item v-if="editMode">
                <el-button type="primary" @click="handleSave" :loading="saving">
                  保存修改
                </el-button>
                <el-button @click="resetForm">
                  重置
                </el-button>
              </el-form-item>
            </el-form>
          </el-card>
        </el-col>
      </el-row>
      
      <el-row style="margin-top: 20px;">
        <el-col :span="24">
          <el-card>
            <template #header>
              <span>密码修改</span>
            </template>
            
            <el-form 
              ref="passwordForm"
              :model="passwordData" 
              :rules="passwordRules"
              label-width="100px"
              style="max-width: 400px;"
            >
              <el-form-item label="当前密码：" prop="oldPassword">
                <el-input 
                  v-model="passwordData.oldPassword" 
                  type="password" 
                  show-password
                  maxlength="50"
                />
              </el-form-item>
              
              <el-form-item label="新密码：" prop="newPassword">
                <el-input 
                  v-model="passwordData.newPassword" 
                  type="password" 
                  show-password
                  maxlength="50"
                />
              </el-form-item>
              
              <el-form-item label="确认密码：" prop="confirmPassword">
                <el-input 
                  v-model="passwordData.confirmPassword" 
                  type="password" 
                  show-password
                  maxlength="50"
                />
              </el-form-item>
              
              <el-form-item>
                <el-button type="primary" @click="handleChangePassword" :loading="changingPassword">
                  修改密码
                </el-button>
                <el-button @click="resetPasswordForm">
                  重置
                </el-button>
              </el-form-item>
            </el-form>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </Layout>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { UserFilled, Camera } from '@element-plus/icons-vue'
import Layout from '@/components/Layout.vue'
import WalletBalance from '@/components/WalletBalance.vue'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const profileForm = ref(null)
const passwordForm = ref(null)
const editMode = ref(false)
const saving = ref(false)
const changingPassword = ref(false)

const form = reactive({
  username: '',
  realName: '',
  studentId: '',
  phone: '',
  email: '',
  avatarUrl: ''
})

// 头像上传相关
const uploadHeaders = reactive({
  Authorization: `Bearer ${userStore.token}`
})

const passwordData = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const validateConfirmPassword = (rule, value, callback) => {
  if (value !== passwordData.newPassword) {
    callback(new Error('两次输入密码不一致'))
  } else {
    callback()
  }
}

const rules = {
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '姓名长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ]
}

const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入当前密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 50, message: '密码长度在 6 到 50 个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const initForm = () => {
  const user = userStore.user
  if (user) {
    form.username = user.username || ''
    form.realName = user.realName || ''
    form.studentId = user.studentId || ''
    form.phone = user.phone || ''
    form.email = user.email || ''
    form.avatarUrl = user.avatarUrl || ''
  }
}

const resetForm = () => {
  initForm()
}

const resetPasswordForm = () => {
  passwordData.oldPassword = ''
  passwordData.newPassword = ''
  passwordData.confirmPassword = ''
  passwordForm.value?.clearValidate()
}

const handleSave = async () => {
  try {
    const valid = await profileForm.value.validate()
    if (!valid) return

    saving.value = true
    
    // 这里应该调用更新用户信息的API
    // await userApi.updateProfile(form)
    
    // 模拟API调用
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    // 更新store中的用户信息
    userStore.setUser({
      ...userStore.user,
      realName: form.realName,
      studentId: form.studentId,
      phone: form.phone,
      email: form.email
    })
    
    editMode.value = false
    ElMessage.success('个人信息更新成功')
    
  } catch (error) {
    console.error('更新个人信息失败:', error)
    ElMessage.error('更新失败，请重试')
  } finally {
    saving.value = false
  }
}

const handleChangePassword = async () => {
  try {
    const valid = await passwordForm.value.validate()
    if (!valid) return

    changingPassword.value = true
    
    // 这里应该调用修改密码的API
    // await userApi.changePassword(passwordData)
    
    // 模拟API调用
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    resetPasswordForm()
    ElMessage.success('密码修改成功')
    
  } catch (error) {
    console.error('修改密码失败:', error)
    ElMessage.error('修改密码失败，请检查当前密码是否正确')
  } finally {
    changingPassword.value = false
  }
}

// 头像上传相关方法
const beforeAvatarUpload = (rawFile) => {
  // 检查文件类型
  const isImage = ['image/jpeg', 'image/png', 'image/gif', 'image/jpg'].includes(rawFile.type)
  if (!isImage) {
    ElMessage.error('只能上传 JPG/PNG/GIF 格式的图片!')
    return false
  }
  
  // 检查文件大小 (5MB)
  const isLt5M = rawFile.size / 1024 / 1024 < 5
  if (!isLt5M) {
    ElMessage.error('图片大小不能超过 5MB!')
    return false
  }
  
  return true
}

const handleAvatarSuccess = (response) => {
  if (response.code === 200) {
    form.avatarUrl = response.data.fullUrl
    // 更新用户store中的头像
    userStore.setUser({
      ...userStore.user,
      avatarUrl: response.data.fullUrl
    })
    ElMessage.success('头像上传成功')
  } else {
    ElMessage.error(response.message || '上传失败')
  }
}

const handleUploadError = (error) => {
  console.error('头像上传失败:', error)
  ElMessage.error('头像上传失败，请重试')
}

onMounted(() => {
  initForm()
})
</script>

<style scoped>
.profile {
  max-width: 1000px;
  margin: 0 auto;
}

.user-avatar {
  text-align: center;
  padding: 20px 0;
}

.avatar-container {
  position: relative;
  display: inline-block;
  margin-bottom: 16px;
}

.user-avatar-img {
  display: block;
}

.avatar-uploader {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  overflow: hidden;
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(66, 66, 66, 0.5);
  color: white;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
  cursor: pointer;
  border-radius: 50%;
}

.avatar-container:hover .avatar-overlay {
  opacity: 1;
}

.avatar-overlay span {
  font-size: 12px;
  margin-top: 4px;
}

.user-avatar h3 {
  margin: 15px 0 10px 0;
  color: #333;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.el-form-item {
  margin-bottom: 20px;
}

.el-form-item:last-child {
  margin-bottom: 0;
}
</style>