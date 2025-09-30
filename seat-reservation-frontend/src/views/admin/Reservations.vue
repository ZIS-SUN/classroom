<template>
  <div class="reservation-management">
    <div class="page-header">
      <h2>预约管理</h2>
      <div class="header-actions">
        <el-button v-if="selectedReservationIds.length > 0" type="danger" @click="batchCancelReservations">
          <el-icon><Delete /></el-icon>
          批量取消 ({{ selectedReservationIds.length }})
        </el-button>
        <el-button v-if="selectedReservationIds.length > 0" type="success" @click="batchConfirmReservations">
          <el-icon><Check /></el-icon>
          批量确认 ({{ selectedReservationIds.length }})
        </el-button>
        <el-button @click="exportReservations">
          <el-icon><Download /></el-icon>
          导出数据
        </el-button>
      </div>
    </div>

    <el-card class="filter-card">
      <el-form :inline="true" :model="reservationFilter" class="filter-form">
        <el-form-item label="预约状态">
          <el-select v-model="reservationFilter.status" placeholder="选择状态" clearable>
            <el-option label="待确认" value="PENDING" />
            <el-option label="已确认" value="CONFIRMED" />
            <el-option label="已取消" value="CANCELLED" />
            <el-option label="已完成" value="COMPLETED" />
          </el-select>
        </el-form-item>

        <el-form-item label="预约日期">
          <el-date-picker
            v-model="reservationFilter.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>

        <el-form-item label="用户搜索">
          <el-input
            v-model="reservationFilter.keyword"
            placeholder="搜索用户名或座位号"
            clearable
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="loadReservations">查询</el-button>
          <el-button @click="resetReservationFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="table-card">
      <el-table
        :data="reservations"
        v-loading="reservationsLoading"
        stripe
        style="width: 100%"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="id" label="预约ID" width="80" />
        <el-table-column prop="userName" label="用户" />
        <el-table-column prop="seatNumber" label="座位号" />
        <el-table-column prop="reservationDate" label="预约日期" />
        <el-table-column label="预约时间">
          <template #default="{ row }">
            {{ row.startTime }} - {{ row.endTime }}
          </template>
        </el-table-column>
        <el-table-column prop="duration" label="时长(小时)" />
        <el-table-column prop="totalCost" label="费用">
          <template #default="{ row }">
            ¥{{ row.totalCost }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getReservationStatusType(row.status)" size="small">
              {{ getReservationStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" />
        <el-table-column label="操作" width="240">
          <template #default="{ row }">
            <el-button size="small" @click="viewReservationDetail(row)">查看</el-button>
            <el-button
              v-if="['PENDING', 'CONFIRMED'].includes(row.status)"
              size="small"
              type="primary"
              @click="editReservation(row)"
            >
              编辑
            </el-button>
            <el-button
              v-if="row.status === 'PENDING'"
              size="small"
              type="success"
              @click="confirmReservation(row)"
            >
              确认
            </el-button>
            <el-button
              v-if="['PENDING', 'CONFIRMED'].includes(row.status)"
              size="small"
              type="danger"
              @click="cancelReservation(row)"
            >
              取消
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="reservationPage"
          v-model:page-size="reservationPageSize"
          :total="reservationTotal"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="loadReservations"
          @current-change="loadReservations"
        />
      </div>
    </el-card>

    <!-- 预约详情对话框 -->
    <el-dialog v-model="reservationDetailVisible" title="预约详情" width="600px">
      <el-descriptions :column="2" border v-if="selectedReservation">
        <el-descriptions-item label="预约ID">{{ selectedReservation.id }}</el-descriptions-item>
        <el-descriptions-item label="用户姓名">{{ selectedReservation.userName }}</el-descriptions-item>
        <el-descriptions-item label="用户手机">{{ selectedReservation.userPhone || '未提供' }}</el-descriptions-item>
        <el-descriptions-item label="座位信息">
          {{ selectedReservation.seatNumber }} ({{ selectedReservation.seatArea }})
        </el-descriptions-item>
        <el-descriptions-item label="预约日期">{{ selectedReservation.reservationDate }}</el-descriptions-item>
        <el-descriptions-item label="预约时间">
          {{ selectedReservation.startTime }} - {{ selectedReservation.endTime }}
        </el-descriptions-item>
        <el-descriptions-item label="持续时长">{{ selectedReservation.duration }} 小时</el-descriptions-item>
        <el-descriptions-item label="费用">¥{{ selectedReservation.totalCost }}</el-descriptions-item>
        <el-descriptions-item label="预约状态">
          <el-tag :type="getReservationStatusType(selectedReservation.status)" size="small">
            {{ getReservationStatusText(selectedReservation.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="支付状态">
          <el-tag :type="selectedReservation.paymentStatus === 'PAID' ? 'success' : 'warning'" size="small">
            {{ selectedReservation.paymentStatus === 'PAID' ? '已支付' : '未支付' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ selectedReservation.createTime }}</el-descriptions-item>
        <el-descriptions-item label="更新时间">{{ selectedReservation.updateTime }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">
          {{ selectedReservation.remark || '无' }}
        </el-descriptions-item>
        <el-descriptions-item label="取消原因" :span="2" v-if="selectedReservation.cancelReason">
          {{ selectedReservation.cancelReason }}
        </el-descriptions-item>
      </el-descriptions>

      <!-- 预约操作历史 -->
      <div class="reservation-history" v-if="selectedReservation.history?.length">
        <h4>操作历史</h4>
        <el-timeline>
          <el-timeline-item
            v-for="record in selectedReservation.history"
            :key="record.id"
            :timestamp="record.operateTime"
            placement="top"
          >
            <div class="history-item">
              <strong>{{ record.operateType }}</strong>
              <span class="operator">by {{ record.operatorName }}</span>
              <p v-if="record.remark">{{ record.remark }}</p>
            </div>
          </el-timeline-item>
        </el-timeline>
      </div>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="reservationDetailVisible = false">关闭</el-button>
          <el-button
            v-if="selectedReservation?.status === 'PENDING'"
            type="success"
            @click="confirmReservation(selectedReservation)"
          >
            确认预约
          </el-button>
          <el-button
            v-if="['PENDING', 'CONFIRMED'].includes(selectedReservation?.status)"
            type="danger"
            @click="cancelReservation(selectedReservation)"
          >
            取消预约
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 编辑预约对话框 -->
    <el-dialog v-model="editReservationVisible" title="编辑预约" width="600px">
      <el-form :model="editForm" :rules="editFormRules" ref="editFormRef" label-width="100px">
        <el-form-item label="预约日期" prop="reservationDate">
          <el-date-picker
            v-model="editForm.reservationDate"
            type="date"
            placeholder="选择日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="开始时间" prop="startTime">
          <el-time-select
            v-model="editForm.startTime"
            start="08:00"
            step="00:30"
            end="22:00"
            placeholder="选择开始时间"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="结束时间" prop="endTime">
          <el-time-select
            v-model="editForm.endTime"
            start="08:00"
            step="00:30"
            end="22:00"
            placeholder="选择结束时间"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="备注">
          <el-input
            v-model="editForm.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注信息"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="editReservationVisible = false">取消</el-button>
          <el-button type="primary" @click="submitEditReservation" :loading="editFormLoading">保存</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 取消原因对话框 -->
    <el-dialog v-model="cancelReasonVisible" title="取消预约" width="400px">
      <el-form :model="cancelForm" label-width="80px">
        <el-form-item label="取消原因" required>
          <el-select v-model="cancelForm.reason" style="width: 100%">
            <el-option label="用户主动取消" value="USER_CANCEL" />
            <el-option label="座位维护" value="SEAT_MAINTENANCE" />
            <el-option label="系统问题" value="SYSTEM_ISSUE" />
            <el-option label="违规使用" value="VIOLATION" />
            <el-option label="其他原因" value="OTHER" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input
            v-model="cancelForm.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入详细说明"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="cancelReasonVisible = false">取消</el-button>
          <el-button type="danger" @click="submitCancelReservation">确认取消</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Download, Delete, Check } from '@element-plus/icons-vue'
import request from '@/utils/request'

// 响应式数据
const reservationsLoading = ref(false)
const reservations = ref([])
const reservationTotal = ref(0)
const reservationPage = ref(1)
const reservationPageSize = ref(10)
const selectedReservationIds = ref([])

const reservationFilter = reactive({
  status: null,
  dateRange: null,
  keyword: null
})

const reservationDetailVisible = ref(false)
const selectedReservation = ref(null)
const cancelReasonVisible = ref(false)
const cancelForm = reactive({
  reason: '',
  remark: ''
})

const editReservationVisible = ref(false)
const editFormRef = ref(null)
const editFormLoading = ref(false)
const editForm = reactive({
  id: null,
  reservationDate: '',
  startTime: '',
  endTime: '',
  remark: ''
})

const editFormRules = {
  reservationDate: [
    { required: true, message: '请选择预约日期', trigger: 'change' }
  ],
  startTime: [
    { required: true, message: '请选择开始时间', trigger: 'change' }
  ],
  endTime: [
    { required: true, message: '请选择结束时间', trigger: 'change' }
  ]
}

// 状态处理函数
const getReservationStatusType = (status) => {
  const typeMap = {
    'PENDING': 'warning',
    'CONFIRMED': 'success',
    'CANCELLED': 'danger',
    'COMPLETED': 'info'
  }
  return typeMap[status] || 'info'
}

const getReservationStatusText = (status) => {
  const textMap = {
    'PENDING': '待确认',
    'CONFIRMED': '已确认',
    'CANCELLED': '已取消',
    'COMPLETED': '已完成'
  }
  return textMap[status] || status
}

// 加载预约数据
const loadReservations = async () => {
  reservationsLoading.value = true
  try {
    const params = {
      current: reservationPage.value,
      size: reservationPageSize.value,
      status: reservationFilter.status,
      keyword: reservationFilter.keyword
    }

    // 处理日期范围
    if (reservationFilter.dateRange?.length === 2) {
      params.startDate = reservationFilter.dateRange[0]
      params.endDate = reservationFilter.dateRange[1]
    }

    console.log('正在查询预约数据，参数:', params)
    const response = await request.get('/reservation/admin/list', { params })
    console.log('预约数据响应:', response)

    if (response && response.code === 200) {
      const data = response.data
      reservations.value = data.records || []
      reservationTotal.value = data.total || 0
    } else {
      ElMessage.error('数据格式异常')
    }
  } catch (error) {
    console.error('加载预约数据失败:', error)
    ElMessage.error('加载数据失败: ' + (error.message || '未知错误'))
  } finally {
    reservationsLoading.value = false
  }
}

// 重置筛选条件
const resetReservationFilter = () => {
  Object.keys(reservationFilter).forEach(key => {
    reservationFilter[key] = null
  })
  loadReservations()
}

// 查看预约详情
const viewReservationDetail = async (reservation) => {
  try {
    console.log('正在获取预约详情:', reservation.id)

    // 获取完整的预约详情
    const response = await request.get(`/reservation/admin/${reservation.id}`)
    console.log('预约详情响应:', response)

    if (response && response.code === 200) {
      selectedReservation.value = response.data
      reservationDetailVisible.value = true
    } else {
      throw new Error(response?.message || '获取详情失败')
    }
  } catch (error) {
    console.error('获取预约详情失败:', error)
    ElMessage.error('获取详情失败: ' + (error.message || '未知错误'))
  }
}

// 编辑预约
const editReservation = (reservation) => {
  editForm.id = reservation.id
  editForm.reservationDate = reservation.reservationDate
  editForm.startTime = reservation.startTime
  editForm.endTime = reservation.endTime
  editForm.remark = reservation.remark || ''
  editReservationVisible.value = true
}

// 提交编辑预约
const submitEditReservation = async () => {
  try {
    await editFormRef.value.validate()

    editFormLoading.value = true

    console.log('正在更新预约:', editForm)
    const response = await request.put(`/reservation/admin/${editForm.id}`, {
      reservationDate: editForm.reservationDate,
      startTime: editForm.startTime,
      endTime: editForm.endTime,
      remark: editForm.remark
    })
    console.log('更新预约响应:', response)

    if (response && response.code === 200) {
      ElMessage.success('预约更新成功')
      editReservationVisible.value = false
      await loadReservations()
    } else {
      throw new Error(response?.message || '更新失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('更新预约失败:', error)
      ElMessage.error('更新失败: ' + (error.message || '未知错误'))
    }
  } finally {
    editFormLoading.value = false
  }
}

// 确认预约
const confirmReservation = async (reservation) => {
  try {
    await ElMessageBox.confirm(
      `确定要确认预约 ${reservation.id} 吗？`,
      '确认预约',
      { type: 'warning' }
    )

    console.log('正在确认预约:', reservation.id)
    const response = await request.put(`/reservation/admin/${reservation.id}/confirm`)
    console.log('确认预约响应:', response)

    if (response && response.code === 200) {
      ElMessage.success('预约确认成功')
      await loadReservations()
      if (reservationDetailVisible.value) {
        reservationDetailVisible.value = false
      }
    } else {
      throw new Error(response?.message || '确认失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('确认预约失败:', error)
      ElMessage.error('确认失败: ' + (error.message || '未知错误'))
    }
  }
}

// 取消预约
const cancelReservation = (reservation) => {
  selectedReservation.value = reservation
  cancelForm.reason = ''
  cancelForm.remark = ''
  cancelReasonVisible.value = true
}

// 提交取消预约
const submitCancelReservation = async () => {
  if (!cancelForm.reason) {
    ElMessage.error('请选择取消原因')
    return
  }

  try {
    const params = {
      reason: cancelForm.reason,
      remark: cancelForm.remark
    }

    console.log('正在取消预约:', selectedReservation.value.id, params)
    const response = await request.put(`/reservation/admin/${selectedReservation.value.id}/cancel`, params)
    console.log('取消预约响应:', response)

    if (response && response.code === 200) {
      ElMessage.success('预约取消成功')
      cancelReasonVisible.value = false
      if (reservationDetailVisible.value) {
        reservationDetailVisible.value = false
      }
      await loadReservations()
    } else {
      throw new Error(response?.message || '取消失败')
    }
  } catch (error) {
    console.error('取消预约失败:', error)
    ElMessage.error('取消失败: ' + (error.message || '未知错误'))
  }
}


// 处理表格选择变化
const handleSelectionChange = (selections) => {
  selectedReservationIds.value = selections.map(item => item.id)
}

// 批量确认预约
const batchConfirmReservations = async () => {
  try {
    await ElMessageBox.confirm(
      `确定要批量确认 ${selectedReservationIds.value.length} 个预约吗？`,
      '批量确认预约',
      { type: 'warning' }
    )

    console.log('正在批量确认预约:', selectedReservationIds.value)
    const response = await request.put('/reservation/admin/batch-confirm', {
      ids: selectedReservationIds.value
    })
    console.log('批量确认响应:', response)

    if (response && response.code === 200) {
      ElMessage.success(`成功确认 ${selectedReservationIds.value.length} 个预约`)
      selectedReservationIds.value = []
      await loadReservations()
    } else {
      throw new Error(response?.message || '批量确认失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('批量确认失败:', error)
      ElMessage.error('批量确认失败: ' + (error.message || '未知错误'))
    }
  }
}

// 批量取消预约
const batchCancelReservations = async () => {
  try {
    await ElMessageBox.confirm(
      `确定要批量取消 ${selectedReservationIds.value.length} 个预约吗？此操作不可撤销。`,
      '批量取消预约',
      { type: 'warning' }
    )

    console.log('正在批量取消预约:', selectedReservationIds.value)
    const response = await request.put('/reservation/admin/batch-cancel', {
      ids: selectedReservationIds.value,
      reason: 'ADMIN_CANCEL',
      remark: '管理员批量取消'
    })
    console.log('批量取消响应:', response)

    if (response && response.code === 200) {
      ElMessage.success(`成功取消 ${selectedReservationIds.value.length} 个预约`)
      selectedReservationIds.value = []
      await loadReservations()
    } else {
      throw new Error(response?.message || '批量取消失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('批量取消失败:', error)
      ElMessage.error('批量取消失败: ' + (error.message || '未知错误'))
    }
  }
}

// 导出预约数据
const exportReservations = async () => {
  try {
    ElMessage.info('正在导出数据...')

    const params = {
      status: reservationFilter.status,
      keyword: reservationFilter.keyword
    }

    if (reservationFilter.dateRange?.length === 2) {
      params.startDate = reservationFilter.dateRange[0]
      params.endDate = reservationFilter.dateRange[1]
    }

    const response = await request.get('/reservation/admin/export', {
      params,
      responseType: 'blob'
    })

    const blob = new Blob([response], {
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    })

    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `预约数据_${new Date().toISOString().split('T')[0]}.xlsx`
    link.click()
    window.URL.revokeObjectURL(url)

    ElMessage.success('数据导出成功')
  } catch (error) {
    console.error('导出数据失败:', error)
    ElMessage.error('导出数据失败: ' + (error.message || '未知错误'))
  }
}

// 组件挂载时加载数据
onMounted(() => {
  loadReservations()
})
</script>

<style scoped>
.reservation-management {
  padding: 24px;
  background: #f5f7fa;
  min-height: calc(100vh - 60px);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 20px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.page-header h2 {
  margin: 0;
  color: #fff;
  font-size: 24px;
  font-weight: 600;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.header-actions .el-button {
  border-radius: 8px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.header-actions .el-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(66, 66, 66, 0.15);
}

.filter-card {
  margin-bottom: 20px;
  border-radius: 12px;
  border: none;
  box-shadow: 0 2px 12px rgba(66, 66, 66, 0.08);
  overflow: hidden;
}

.filter-card :deep(.el-card__body) {
  padding: 20px 24px;
}

.filter-form {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  align-items: end;
  margin: 0;
}

.filter-form .el-form-item {
  margin-bottom: 0;
}

.table-card {
  border-radius: 12px;
  border: none;
  box-shadow: 0 2px 12px rgba(66, 66, 66, 0.08);
  overflow: hidden;
}

.table-card :deep(.el-card__body) {
  padding: 0;
}

.table-card :deep(.el-table) {
  border-radius: 0;
}

.table-card :deep(.el-table__header) {
  background: linear-gradient(90deg, #f8fafc 0%, #e2e8f0 100%);
}

.table-card :deep(.el-table__header th) {
  background: transparent;
  border-bottom: 2px solid #e2e8f0;
  font-weight: 600;
  color: #475569;
}

.table-card :deep(.el-table__body tr:hover) {
  background: #f8fafc;
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.reservation-history {
  margin-top: 24px;
  border-top: 1px solid #ebeef5;
  padding-top: 20px;
}

.reservation-history h4 {
  margin: 0 0 16px 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
}

.history-item {
  background: #f8f9fa;
  padding: 12px;
  border-radius: 6px;
  margin-bottom: 8px;
}

.history-item strong {
  color: #2c3e50;
  margin-right: 8px;
}

.operator {
  color: #7f8c8d;
  font-size: 12px;
}

.history-item p {
  margin: 8px 0 0 0;
  color: #5a6c7d;
  font-size: 14px;
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