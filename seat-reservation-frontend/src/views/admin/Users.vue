<template>
  <div class="user-management">
    <div class="page-header">
      <h2>用户管理</h2>
      <div class="header-actions">
        <el-button type="primary" @click="handleAddUser">
          <el-icon><Plus /></el-icon>
          添加用户
        </el-button>
        <el-button @click="exportUsers">
          <el-icon><Download /></el-icon>
          导出数据
        </el-button>
      </div>
    </div>

    <el-card class="filter-card">
      <el-form :inline="true" :model="userFilter" class="filter-form">
        <el-form-item label="用户角色">
          <el-select v-model="userFilter.role" placeholder="选择角色" clearable>
            <el-option label="学生" value="STUDENT" />
            <el-option label="管理员" value="ADMIN" />
          </el-select>
        </el-form-item>

        <el-form-item label="账号状态">
          <el-select v-model="userFilter.status" placeholder="选择状态" clearable>
            <el-option label="正常" value="ACTIVE" />
            <el-option label="禁用" value="DISABLED" />
          </el-select>
        </el-form-item>

        <el-form-item label="关键词">
          <el-input
            v-model="userFilter.keyword"
            placeholder="搜索用户名、姓名或手机号"
            clearable
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
        <el-table-column prop="phone" label="手机号" />
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
        <el-table-column prop="createTime" label="注册时间" />
        <el-table-column prop="lastLoginTime" label="最后登录" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" @click="editUser(row)">编辑</el-button>
            <el-button size="small" type="warning" @click="resetPassword(row)">重置密码</el-button>
            <el-button
              size="small"
              :type="row.status === 'ACTIVE' ? 'danger' : 'success'"
              @click="toggleUserStatus(row)"
            >
              {{ row.status === 'ACTIVE' ? '禁用' : '启用' }}
            </el-button>
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

    <!-- 用户表单对话框 -->
    <el-dialog
      v-model="userFormVisible"
      :title="isEditUser ? '编辑用户' : '添加用户'"
      width="500px"
    >
      <el-form
        v-if="selectedUser"
        :model="selectedUser"
        :rules="userFormRules"
        ref="userFormRef"
        label-width="80px"
      >
        <el-form-item label="用户名" prop="username">
          <el-input
            v-model="selectedUser.username"
            placeholder="请输入用户名"
            :disabled="isEditUser"
          />
        </el-form-item>

        <el-form-item label="真实姓名" prop="realName">
          <el-input v-model="selectedUser.realName" placeholder="请输入真实姓名" />
        </el-form-item>

        <el-form-item label="手机号" prop="phone">
          <el-input v-model="selectedUser.phone" placeholder="请输入手机号" />
        </el-form-item>

        <el-form-item label="邮箱">
          <el-input v-model="selectedUser.email" placeholder="请输入邮箱" />
        </el-form-item>

        <el-form-item label="角色" prop="role">
          <el-select v-model="selectedUser.role" style="width: 100%">
            <el-option label="学生" value="STUDENT" />
            <el-option label="管理员" value="ADMIN" />
          </el-select>
        </el-form-item>

        <el-form-item label="状态" prop="status">
          <el-select v-model="selectedUser.status" style="width: 100%">
            <el-option label="正常" value="ACTIVE" />
            <el-option label="禁用" value="DISABLED" />
          </el-select>
        </el-form-item>

        <el-form-item v-if="!isEditUser" label="密码" prop="password">
          <el-input
            v-model="selectedUser.password"
            type="password"
            placeholder="请输入密码"
            show-password
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleUserFormCancel">取消</el-button>
          <el-button type="primary" @click="handleUserFormSubmit" :loading="submitLoading">
            {{ isEditUser ? '更新' : '创建' }}
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Download } from '@element-plus/icons-vue'
import { userApi } from '@/api/user'

// 响应式数据
const usersLoading = ref(false)
const users = ref([])
const userTotal = ref(0)
const userPage = ref(1)
const userPageSize = ref(10)
const submitLoading = ref(false)

const userFilter = reactive({
  role: null,
  status: null,
  keyword: null
})

const userFormVisible = ref(false)
const isEditUser = ref(false)
const selectedUser = ref(null)
const userFormRef = ref(null)

// 表单验证规则
const userFormRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度为3-20个字符', trigger: 'blur' }
  ],
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为6-20个字符', trigger: 'blur' }
  ]
}

// 加载用户数据
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

    console.log('正在查询用户数据，参数:', params)
    const response = await userApi.getUserPage(params)
    console.log('用户数据响应:', response)

    if (response && response.code === 200) {
      const data = response.data
      users.value = data.records || []
      userTotal.value = data.total || 0
    } else {
      ElMessage.error('数据格式异常')
    }
  } catch (error) {
    console.error('加载用户数据失败:', error)
    ElMessage.error('加载数据失败: ' + (error.message || '未知错误'))
  } finally {
    usersLoading.value = false
  }
}

// 重置筛选条件
const resetUserFilter = () => {
  Object.keys(userFilter).forEach(key => {
    userFilter[key] = null
  })
  loadUsers()
}

// 用户操作
const editUser = (user) => {
  selectedUser.value = { ...user }
  userFormVisible.value = true
  isEditUser.value = true
}

const toggleUserStatus = async (user) => {
  const action = user.status === 'ACTIVE' ? '禁用' : '启用'
  const newStatus = user.status === 'ACTIVE' ? 'DISABLED' : 'ACTIVE'

  try {
    await ElMessageBox.confirm(`确定要${action}用户 ${user.username} 吗？`)

    console.log(`正在${action}用户:`, user.id, '新状态:', newStatus)
    const response = await userApi.updateUserStatus(user.id, newStatus)
    console.log('更新用户状态响应:', response)

    ElMessage.success(`${action}成功`)
    await loadUsers()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('更新用户状态失败:', error)
      ElMessage.error('操作失败: ' + (error.message || '未知错误'))
    }
  }
}

const resetPassword = async (user) => {
  try {
    await ElMessageBox.confirm(
      `确定要重置用户 ${user.username} 的密码吗？重置后密码为：123456`,
      '重置密码',
      { type: 'warning' }
    )

    console.log('正在重置密码:', user.id)
    const response = await userApi.resetPassword(user.id)
    console.log('重置密码响应:', response)

    ElMessage.success('密码重置成功，新密码为：123456')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('重置密码失败:', error)
      ElMessage.error('重置失败: ' + (error.message || '未知错误'))
    }
  }
}

// 用户表单操作
const handleAddUser = () => {
  selectedUser.value = {
    username: '',
    realName: '',
    phone: '',
    email: '',
    role: 'STUDENT',
    status: 'ACTIVE',
    password: ''
  }
  userFormVisible.value = true
  isEditUser.value = false
}

const handleUserFormSubmit = async () => {
  try {
    await userFormRef.value.validate()

    submitLoading.value = true

    console.log('正在保存用户:', selectedUser.value)

    if (isEditUser.value) {
      const response = await userApi.updateUser(selectedUser.value.id, selectedUser.value)
      console.log('更新用户响应:', response)
      ElMessage.success('用户更新成功')
    } else {
      const response = await userApi.createUser(selectedUser.value)
      console.log('创建用户响应:', response)
      ElMessage.success('用户创建成功')
    }

    userFormVisible.value = false
    await loadUsers()

  } catch (error) {
    console.error('保存用户失败:', error)
    ElMessage.error('保存失败: ' + (error.message || '未知错误'))
  } finally {
    submitLoading.value = false
  }
}

const handleUserFormCancel = () => {
  userFormVisible.value = false
  selectedUser.value = null
}

// 导出数据
const exportUsers = async () => {
  try {
    ElMessage.info('导出功能开发中...')
  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('导出失败')
  }
}

// 组件挂载时加载数据
onMounted(() => {
  loadUsers()
})
</script>

<style scoped>
.user-management {
  padding: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #2c3e50;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.filter-card {
  margin-bottom: 20px;
  border-radius: 8px;
}

.filter-form {
  margin: 0;
}

.table-card {
  border-radius: 8px;
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }

  .header-actions {
    justify-content: center;
  }

  .filter-form {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .filter-form .el-form-item {
    margin-right: 0;
    margin-bottom: 0;
  }
}
</style>