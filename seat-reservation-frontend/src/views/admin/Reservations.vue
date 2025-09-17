<template>
  <div class="reservation-management">
    <div class="page-header">
      <h2>预约管理</h2>
      <div class="header-actions">
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
      >
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
        <el-table-column label="操作" width="180">
          <template #default="{ row }">
            <el-button size="small" @click="viewReservationDetail(row)">查看</el-button>
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
import { Download } from '@element-plus/icons-vue'
import request from '@/utils/request'

// 响应式数据
const reservationsLoading = ref(false)
const reservations = ref([])
const reservationTotal = ref(0)
const reservationPage = ref(1)
const reservationPageSize = ref(10)

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

// 导出数据
const exportReservations = async () => {
  try {
    ElMessage.info('导出功能开发中...')
  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('导出失败')
  }
}

// 组件挂载时加载数据
onMounted(() => {
  loadReservations()
})
</script>

<style scoped>
.reservation-management {
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