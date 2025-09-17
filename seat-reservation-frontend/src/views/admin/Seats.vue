<template>
  <div class="seat-management">
    <div class="page-header">
      <h2>座位管理</h2>
      <el-button type="primary" @click="handleAddSeat">
        <el-icon><Plus /></el-icon>
        添加座位
      </el-button>
    </div>

    <el-card class="filter-card">
      <el-form :inline="true" :model="seatFilter" class="filter-form">
        <el-form-item label="楼层">
          <el-select v-model="seatFilter.floorNumber" placeholder="选择楼层" clearable>
            <el-option label="1楼" :value="1" />
            <el-option label="2楼" :value="2" />
            <el-option label="3楼" :value="3" />
          </el-select>
        </el-form-item>

        <el-form-item label="区域">
          <el-select v-model="seatFilter.area" placeholder="选择区域" clearable>
            <el-option label="A区" value="A区" />
            <el-option label="B区" value="B区" />
            <el-option label="C区" value="C区" />
          </el-select>
        </el-form-item>

        <el-form-item label="状态">
          <el-select v-model="seatFilter.status" placeholder="选择状态" clearable>
            <el-option label="可用" value="AVAILABLE" />
            <el-option label="占用中" value="OCCUPIED" />
            <el-option label="维护中" value="MAINTENANCE" />
            <el-option label="已禁用" value="DISABLED" />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="loadSeats">查询</el-button>
          <el-button @click="resetSeatFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="table-card">
      <el-table
        :data="seats"
        v-loading="seatsLoading"
        stripe
        style="width: 100%"
      >
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="seatNumber" label="座位号" />
        <el-table-column prop="area" label="区域" />
        <el-table-column prop="floorNumber" label="楼层" />
        <el-table-column prop="seatTypeName" label="座位类型" />
        <el-table-column prop="hourlyRate" label="费用">
          <template #default="{ row }">
            ¥{{ row.hourlyRate }}/小时
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getSeatStatusType(row.status)" size="small">
              {{ getSeatStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" @click="editSeat(row)">编辑</el-button>
            <el-button size="small" type="warning" @click="toggleSeatStatus(row)">
              {{ row.status === 'AVAILABLE' ? '禁用' : '启用' }}
            </el-button>
            <el-button
              size="small"
              type="danger"
              @click="handleDeleteSeat(row)"
              :loading="deleteLoading === row.id"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="seatPage"
          v-model:page-size="seatPageSize"
          :total="seatTotal"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="loadSeats"
          @current-change="loadSeats"
        />
      </div>
    </el-card>

    <!-- 座位表单对话框 -->
    <el-dialog
      v-model="seatFormVisible"
      :title="isEditSeat ? '编辑座位' : '添加座位'"
      width="600px"
    >
      <el-form
        v-if="selectedSeat"
        :model="selectedSeat"
        label-width="100px"
        ref="seatFormRef"
        :rules="seatFormRules"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="座位号" prop="seatNumber">
              <el-input v-model="selectedSeat.seatNumber" placeholder="请输入座位号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="楼层" prop="floorNumber">
              <el-select v-model="selectedSeat.floorNumber" style="width: 100%">
                <el-option label="1楼" :value="1" />
                <el-option label="2楼" :value="2" />
                <el-option label="3楼" :value="3" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="区域" prop="area">
              <el-select v-model="selectedSeat.area" style="width: 100%">
                <el-option label="A区" value="A区" />
                <el-option label="B区" value="B区" />
                <el-option label="C区" value="C区" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="座位类型" prop="seatTypeId">
              <el-select v-model="selectedSeat.seatTypeId" style="width: 100%">
                <el-option
                  v-for="type in seatTypes"
                  :key="type.id"
                  :label="type.typeName"
                  :value="type.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="X坐标">
              <el-input-number v-model="selectedSeat.positionX" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="Y坐标">
              <el-input-number v-model="selectedSeat.positionY" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="状态">
              <el-select v-model="selectedSeat.status" style="width: 100%">
                <el-option label="可用" value="AVAILABLE" />
                <el-option label="维护中" value="MAINTENANCE" />
                <el-option label="已禁用" value="DISABLED" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="配置">
              <el-checkbox v-model="selectedSeat.hasPower">电源插座</el-checkbox>
              <el-checkbox v-model="selectedSeat.hasComputer">配备电脑</el-checkbox>
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="描述">
          <el-input
            v-model="selectedSeat.description"
            type="textarea"
            :rows="3"
            placeholder="请输入座位描述"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleSeatFormCancel">取消</el-button>
          <el-button
            type="primary"
            @click="handleSeatFormSubmit"
            :loading="submitLoading"
          >
            {{ isEditSeat ? '更新' : '创建' }}
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { seatApi } from '@/api/seat'

// 响应式数据
const seatsLoading = ref(false)
const seats = ref([])
const seatTotal = ref(0)
const seatPage = ref(1)
const seatPageSize = ref(10)
const deleteLoading = ref(null) // 记录正在删除的座位ID
const submitLoading = ref(false)

const seatFilter = reactive({
  floorNumber: null,
  area: null,
  status: null
})

const seatFormVisible = ref(false)
const isEditSeat = ref(false)
const selectedSeat = ref(null)
const seatTypes = ref([])
const seatFormRef = ref(null)

// 表单验证规则
const seatFormRules = {
  seatNumber: [
    { required: true, message: '请输入座位号', trigger: 'blur' }
  ],
  floorNumber: [
    { required: true, message: '请选择楼层', trigger: 'change' }
  ],
  area: [
    { required: true, message: '请选择区域', trigger: 'change' }
  ],
  seatTypeId: [
    { required: true, message: '请选择座位类型', trigger: 'change' }
  ]
}

// 状态处理函数
const getSeatStatusType = (status) => {
  const typeMap = {
    'AVAILABLE': 'success',
    'OCCUPIED': 'warning',
    'MAINTENANCE': 'info',
    'DISABLED': 'danger'
  }
  return typeMap[status] || 'info'
}

const getSeatStatusText = (status) => {
  const textMap = {
    'AVAILABLE': '可用',
    'OCCUPIED': '占用中',
    'MAINTENANCE': '维护中',
    'DISABLED': '已禁用'
  }
  return textMap[status] || status
}

// 加载座位数据
const loadSeats = async () => {
  seatsLoading.value = true
  try {
    const params = {
      current: seatPage.value,
      size: seatPageSize.value,
      floorNumber: seatFilter.floorNumber,
      area: seatFilter.area,
      status: seatFilter.status
    }

    console.log('正在查询座位数据，参数:', params)
    const response = await seatApi.getSeatPage(params)
    console.log('座位数据响应:', response)

    // 处理响应格式
    if (response && response.code === 200) {
      const data = response.data
      seats.value = data.records || []
      seatTotal.value = data.total || 0
    } else {
      console.error('座位数据响应格式异常:', response)
      ElMessage.error('数据格式异常')
    }
  } catch (error) {
    console.error('加载座位数据失败:', error)
    ElMessage.error('加载数据失败: ' + (error.message || '未知错误'))
  } finally {
    seatsLoading.value = false
  }
}

// 重置筛选条件
const resetSeatFilter = () => {
  Object.keys(seatFilter).forEach(key => {
    seatFilter[key] = null
  })
  loadSeats()
}

// 座位操作
const editSeat = (seat) => {
  selectedSeat.value = { ...seat }
  seatFormVisible.value = true
  isEditSeat.value = true
}

const toggleSeatStatus = async (seat) => {
  const action = seat.status === 'AVAILABLE' ? '禁用' : '启用'
  const newStatus = seat.status === 'AVAILABLE' ? 'DISABLED' : 'AVAILABLE'

  try {
    await ElMessageBox.confirm(`确定要${action}座位 ${seat.seatNumber} 吗？`)

    console.log(`正在${action}座位:`, seat.id, '新状态:', newStatus)
    await seatApi.updateSeatStatus(seat.id, newStatus)

    ElMessage.success(`${action}成功`)
    loadSeats()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('更新座位状态失败:', error)
      ElMessage.error('操作失败: ' + (error.message || '未知错误'))
    }
  }
}

// 修复删除逻辑
const handleDeleteSeat = async (seat) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除座位 ${seat.seatNumber} 吗？此操作不可撤销。`,
      '删除确认',
      {
        type: 'warning',
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        confirmButtonClass: 'el-button--danger'
      }
    )

    // 设置删除loading状态
    deleteLoading.value = seat.id

    console.log('正在删除座位:', seat.id, seat.seatNumber)

    // 调用删除API
    const response = await seatApi.deleteSeat(seat.id)
    console.log('删除座位响应:', response)

    // 检查删除结果
    if (response && (response.code === 200 || response.success)) {
      ElMessage.success('删除成功')
      // 重新加载数据
      await loadSeats()
    } else {
      throw new Error(response?.message || '删除失败')
    }

  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除座位失败:', error)
      ElMessage.error('删除失败: ' + (error.message || '未知错误'))
    }
  } finally {
    deleteLoading.value = null
  }
}

// 座位表单操作
const handleAddSeat = () => {
  selectedSeat.value = {
    seatNumber: '',
    floorNumber: 1,
    area: 'A区',
    seatTypeId: null,
    positionX: 0,
    positionY: 0,
    status: 'AVAILABLE',
    hasPower: false,
    hasComputer: false,
    description: ''
  }
  seatFormVisible.value = true
  isEditSeat.value = false
}

const handleSeatFormSubmit = async () => {
  try {
    // 表单验证
    await seatFormRef.value.validate()

    submitLoading.value = true

    console.log('正在保存座位:', selectedSeat.value)

    if (isEditSeat.value) {
      const response = await seatApi.updateSeat(selectedSeat.value.id, selectedSeat.value)
      console.log('更新座位响应:', response)
      ElMessage.success('座位更新成功')
    } else {
      const response = await seatApi.createSeat(selectedSeat.value)
      console.log('创建座位响应:', response)
      ElMessage.success('座位创建成功')
    }

    seatFormVisible.value = false
    await loadSeats()

  } catch (error) {
    console.error('保存座位失败:', error)
    ElMessage.error('保存失败: ' + (error.message || '未知错误'))
  } finally {
    submitLoading.value = false
  }
}

const handleSeatFormCancel = () => {
  seatFormVisible.value = false
  selectedSeat.value = null
}

// 加载座位类型
const loadSeatTypes = async () => {
  try {
    const response = await seatApi.getSeatTypes()
    seatTypes.value = response.data || response || []
  } catch (error) {
    console.error('加载座位类型失败:', error)
  }
}

// 组件挂载时加载数据
onMounted(() => {
  loadSeats()
  loadSeatTypes()
})
</script>

<style scoped>
.seat-management {
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