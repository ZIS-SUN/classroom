<template>
  <div class="announcement-management">
    <div class="page-header">
      <h2>公告管理</h2>
      <div class="header-actions">
        <el-button type="primary" @click="handleAddAnnouncement">
          <el-icon><Plus /></el-icon>
          发布公告
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

        <el-form-item label="关键词">
          <el-input
            v-model="announcementFilter.keyword"
            placeholder="搜索公告标题或内容"
            clearable
          />
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
        v-loading="announcementsLoading"
        stripe
        style="width: 100%"
      >
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="title" label="标题" />
        <el-table-column prop="content" label="内容" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.content.substring(0, 50) + (row.content.length > 50 ? '...' : '') }}
          </template>
        </el-table-column>
        <el-table-column prop="priority" label="优先级">
          <template #default="{ row }">
            <el-tag :type="getPriorityType(row.priority)" size="small">
              {{ getPriorityText(row.priority) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getAnnouncementStatusType(row.status)" size="small">
              {{ getAnnouncementStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" />
        <el-table-column prop="publishTime" label="发布时间" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" @click="viewAnnouncement(row)">查看</el-button>
            <el-button size="small" @click="editAnnouncement(row)">编辑</el-button>
            <el-button
              v-if="row.status === 'DRAFT'"
              size="small"
              type="success"
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
            <el-button
              size="small"
              type="danger"
              @click="deleteAnnouncement(row)"
            >
              删除
            </el-button>
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

    <!-- 公告表单对话框 -->
    <el-dialog
      v-model="announcementFormVisible"
      :title="isEditAnnouncement ? '编辑公告' : '发布公告'"
      width="800px"
    >
      <el-form
        v-if="selectedAnnouncement"
        :model="selectedAnnouncement"
        :rules="announcementFormRules"
        ref="announcementFormRef"
        label-width="100px"
      >
        <el-form-item label="公告标题" prop="title">
          <el-input v-model="selectedAnnouncement.title" placeholder="请输入公告标题" />
        </el-form-item>

        <el-form-item label="公告内容" prop="content">
          <el-input
            v-model="selectedAnnouncement.content"
            type="textarea"
            :rows="8"
            placeholder="请输入公告内容"
          />
        </el-form-item>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="优先级" prop="priority">
              <el-select v-model="selectedAnnouncement.priority" style="width: 100%">
                <el-option label="低" value="LOW" />
                <el-option label="中" value="MEDIUM" />
                <el-option label="高" value="HIGH" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-select v-model="selectedAnnouncement.status" style="width: 100%">
                <el-option label="草稿" value="DRAFT" />
                <el-option label="发布" value="PUBLISHED" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="生效时间">
          <el-date-picker
            v-model="selectedAnnouncement.effectiveTime"
            type="datetime"
            placeholder="选择生效时间"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="失效时间">
          <el-date-picker
            v-model="selectedAnnouncement.expireTime"
            type="datetime"
            placeholder="选择失效时间"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="是否置顶">
          <el-switch v-model="selectedAnnouncement.isPinned" />
        </el-form-item>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleAnnouncementFormCancel">取消</el-button>
          <el-button type="primary" @click="handleAnnouncementFormSubmit" :loading="submitLoading">
            {{ isEditAnnouncement ? '更新' : '发布' }}
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 公告查看对话框 -->
    <el-dialog v-model="announcementDetailVisible" title="公告详情" width="600px">
      <div v-if="selectedAnnouncement" class="announcement-detail">
        <div class="detail-header">
          <h3>{{ selectedAnnouncement.title }}</h3>
          <div class="detail-meta">
            <el-tag :type="getPriorityType(selectedAnnouncement.priority)" size="small">
              {{ getPriorityText(selectedAnnouncement.priority) }}
            </el-tag>
            <el-tag :type="getAnnouncementStatusType(selectedAnnouncement.status)" size="small">
              {{ getAnnouncementStatusText(selectedAnnouncement.status) }}
            </el-tag>
            <span v-if="selectedAnnouncement.isPinned" class="pinned-badge">置顶</span>
          </div>
        </div>

        <div class="detail-content">
          <p>{{ selectedAnnouncement.content }}</p>
        </div>

        <div class="detail-info">
          <p><strong>创建时间：</strong>{{ selectedAnnouncement.createTime }}</p>
          <p v-if="selectedAnnouncement.publishTime"><strong>发布时间：</strong>{{ selectedAnnouncement.publishTime }}</p>
          <p v-if="selectedAnnouncement.effectiveTime"><strong>生效时间：</strong>{{ selectedAnnouncement.effectiveTime }}</p>
          <p v-if="selectedAnnouncement.expireTime"><strong>失效时间：</strong>{{ selectedAnnouncement.expireTime }}</p>
          <p><strong>创建者：</strong>{{ selectedAnnouncement.creatorName }}</p>
        </div>
      </div>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="announcementDetailVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import request from '@/utils/request'

// 响应式数据
const announcementsLoading = ref(false)
const announcements = ref([])
const announcementTotal = ref(0)
const announcementPage = ref(1)
const announcementPageSize = ref(10)
const submitLoading = ref(false)

const announcementFilter = reactive({
  status: null,
  keyword: null
})

const announcementFormVisible = ref(false)
const announcementDetailVisible = ref(false)
const isEditAnnouncement = ref(false)
const selectedAnnouncement = ref(null)
const announcementFormRef = ref(null)

// 表单验证规则
const announcementFormRules = {
  title: [
    { required: true, message: '请输入公告标题', trigger: 'blur' },
    { max: 100, message: '标题长度不能超过100个字符', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入公告内容', trigger: 'blur' },
    { max: 2000, message: '内容长度不能超过2000个字符', trigger: 'blur' }
  ],
  priority: [
    { required: true, message: '请选择优先级', trigger: 'change' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
}

// 状态处理函数
const getAnnouncementStatusType = (status) => {
  const typeMap = {
    'DRAFT': 'info',
    'PUBLISHED': 'success',
    'ARCHIVED': 'warning'
  }
  return typeMap[status] || 'info'
}

const getAnnouncementStatusText = (status) => {
  const textMap = {
    'DRAFT': '草稿',
    'PUBLISHED': '已发布',
    'ARCHIVED': '已归档'
  }
  return textMap[status] || status
}

const getPriorityType = (priority) => {
  const typeMap = {
    'LOW': 'info',
    'MEDIUM': 'warning',
    'HIGH': 'danger'
  }
  return typeMap[priority] || 'info'
}

const getPriorityText = (priority) => {
  const textMap = {
    'LOW': '低',
    'MEDIUM': '中',
    'HIGH': '高'
  }
  return textMap[priority] || priority
}

// 加载公告数据
const loadAnnouncements = async () => {
  announcementsLoading.value = true
  try {
    const params = {
      current: announcementPage.value,
      size: announcementPageSize.value,
      status: announcementFilter.status,
      keyword: announcementFilter.keyword
    }

    console.log('正在查询公告数据，参数:', params)
    const response = await request.get('/announcement/admin/list', { params })
    console.log('公告数据响应:', response)

    if (response && response.code === 200) {
      const data = response.data
      announcements.value = data.records || []
      announcementTotal.value = data.total || 0
    } else {
      ElMessage.error('数据格式异常')
    }
  } catch (error) {
    console.error('加载公告数据失败:', error)
    ElMessage.error('加载数据失败: ' + (error.message || '未知错误'))
  } finally {
    announcementsLoading.value = false
  }
}

// 重置筛选条件
const resetAnnouncementFilter = () => {
  Object.keys(announcementFilter).forEach(key => {
    announcementFilter[key] = null
  })
  loadAnnouncements()
}

// 公告操作
const viewAnnouncement = (announcement) => {
  selectedAnnouncement.value = announcement
  announcementDetailVisible.value = true
}

const editAnnouncement = (announcement) => {
  selectedAnnouncement.value = { ...announcement }
  announcementFormVisible.value = true
  isEditAnnouncement.value = true
}

const publishAnnouncement = async (announcement) => {
  try {
    await ElMessageBox.confirm(`确定要发布公告"${announcement.title}"吗？`)

    console.log('正在发布公告:', announcement.id)
    const response = await request.put(`/announcement/admin/${announcement.id}/publish`)
    console.log('发布公告响应:', response)

    ElMessage.success('公告发布成功')
    await loadAnnouncements()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('发布公告失败:', error)
      ElMessage.error('发布失败: ' + (error.message || '未知错误'))
    }
  }
}

const archiveAnnouncement = async (announcement) => {
  try {
    await ElMessageBox.confirm(`确定要归档公告"${announcement.title}"吗？`)

    console.log('正在归档公告:', announcement.id)
    const response = await request.post(`/announcement/admin/${announcement.id}/archive`)
    console.log('归档公告响应:', response)

    ElMessage.success('公告归档成功')
    await loadAnnouncements()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('归档公告失败:', error)
      ElMessage.error('归档失败: ' + (error.message || '未知错误'))
    }
  }
}

const deleteAnnouncement = async (announcement) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除公告"${announcement.title}"吗？此操作不可撤销。`,
      '删除确认',
      { type: 'warning' }
    )

    console.log('正在删除公告:', announcement.id)
    const response = await request.delete(`/announcement/admin/${announcement.id}`)
    console.log('删除公告响应:', response)

    ElMessage.success('删除成功')
    await loadAnnouncements()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除公告失败:', error)
      ElMessage.error('删除失败: ' + (error.message || '未知错误'))
    }
  }
}

// 公告表单操作
const handleAddAnnouncement = () => {
  selectedAnnouncement.value = {
    title: '',
    content: '',
    type: 'ANNOUNCEMENT',
    priority: 'MEDIUM',
    status: 'DRAFT',
    publishTime: null,
    expireTime: null
  }
  announcementFormVisible.value = true
  isEditAnnouncement.value = false
}

const handleAnnouncementFormSubmit = async () => {
  try {
    await announcementFormRef.value.validate()

    submitLoading.value = true

    console.log('正在保存公告:', selectedAnnouncement.value)

    if (isEditAnnouncement.value) {
      const response = await request.put(`/announcement/admin/${selectedAnnouncement.value.id}`, selectedAnnouncement.value)
      console.log('更新公告响应:', response)
      ElMessage.success('公告更新成功')
    } else {
      const response = await request.post('/announcement/admin/create', selectedAnnouncement.value)
      console.log('创建公告响应:', response)
      ElMessage.success('公告创建成功')
    }

    announcementFormVisible.value = false
    await loadAnnouncements()

  } catch (error) {
    console.error('保存公告失败:', error)
    ElMessage.error('保存失败: ' + (error.message || '未知错误'))
  } finally {
    submitLoading.value = false
  }
}

const handleAnnouncementFormCancel = () => {
  announcementFormVisible.value = false
  selectedAnnouncement.value = null
}

// 组件挂载时加载数据
onMounted(() => {
  loadAnnouncements()
})
</script>

<style scoped>
.announcement-management {
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

.announcement-detail {
  padding: 20px 0;
}

.detail-header {
  margin-bottom: 20px;
  border-bottom: 1px solid #ebeef5;
  padding-bottom: 16px;
}

.detail-header h3 {
  margin: 0 0 12px 0;
  font-size: 20px;
  font-weight: 600;
  color: #2c3e50;
}

.detail-meta {
  display: flex;
  gap: 8px;
  align-items: center;
}

.pinned-badge {
  background: #f56c6c;
  color: white;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.detail-content {
  margin-bottom: 20px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 6px;
  line-height: 1.6;
}

.detail-info {
  font-size: 14px;
  color: #5a6c7d;
}

.detail-info p {
  margin: 8px 0;
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