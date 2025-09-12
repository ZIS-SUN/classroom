<template>
  <Layout>
    <div class="seat-map">
      <!-- 过滤条件 -->
      <el-card class="filter-card">
        <div class="filter-row">
          <div class="filter-group">
            <label>日期：</label>
            <el-date-picker
              v-model="filters.date"
              type="date"
              placeholder="选择日期"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
              :disabled-date="disabledDate"
              @change="loadSeats"
            />
          </div>
          
          <div class="filter-group">
            <label>时间：</label>
            <el-time-picker
              v-model="filters.startTime"
              format="HH:mm"
              value-format="HH:mm"
              placeholder="开始时间"
              @change="loadSeats"
            />
            <span class="time-separator">至</span>
            <el-time-picker
              v-model="filters.endTime"
              format="HH:mm"
              value-format="HH:mm"
              placeholder="结束时间"
              @change="loadSeats"
            />
          </div>
          
          <div class="filter-group">
            <label>楼层：</label>
            <el-select
              v-model="filters.floorNumber"
              placeholder="选择楼层"
              clearable
              @change="loadSeats"
            >
              <el-option label="1楼" :value="1" />
              <el-option label="2楼" :value="2" />
              <el-option label="3楼" :value="3" />
            </el-select>
          </div>
          
          <div class="filter-group">
            <label>区域：</label>
            <el-select
              v-model="filters.area"
              placeholder="选择区域"
              clearable
              @change="loadSeats"
            >
              <el-option label="A区" value="A" />
              <el-option label="B区" value="B" />
              <el-option label="C区" value="C" />
            </el-select>
          </div>
          
          <el-button type="primary" @click="loadSeats" :loading="loading">
            查询座位
          </el-button>
        </div>
      </el-card>

      <!-- 座位图例 -->
      <el-card class="legend-card">
        <div class="legend">
          <div class="legend-item">
            <div class="seat-demo available"></div>
            <span>可预约</span>
          </div>
          <div class="legend-item">
            <div class="seat-demo occupied"></div>
            <span>已预约</span>
          </div>
          <div class="legend-item">
            <div class="seat-demo selected"></div>
            <span>已选择</span>
          </div>
          <div class="legend-item">
            <div class="seat-demo disabled"></div>
            <span>不可用</span>
          </div>
        </div>
      </el-card>

      <!-- 座位地图 -->
      <el-card class="seat-grid-card" v-loading="loading">
        <div v-if="!seats.length && !loading" class="empty-state">
          <el-empty description="暂无座位数据" />
        </div>
        
        <div v-else class="seat-grid">
          <div
            v-for="seat in seats"
            :key="seat.id"
            class="seat"
            :class="getSeatClass(seat)"
            @click="handleSeatClick(seat)"
          >
            <div class="seat-number">{{ seat.seatNumber }}</div>
            <div class="seat-info">{{ seat.seatTypeName }}</div>
          </div>
        </div>
      </el-card>

      <!-- 预约对话框 -->
      <el-dialog
        v-model="showReservationDialog"
        title="预约座位"
        width="400px"
        :close-on-click-modal="false"
      >
        <div v-if="selectedSeat" class="reservation-form">
          <div class="seat-info-detail">
            <p><strong>座位：</strong>{{ selectedSeat.seatNumber }}</p>
            <p><strong>类型：</strong>{{ selectedSeat.seatTypeName }}</p>
            <p><strong>位置：</strong>{{ selectedSeat.floorNumber }}楼 {{ selectedSeat.area }}区</p>
            <p><strong>费用：</strong>{{ selectedSeat.hourlyRate }}元/小时</p>
            <p v-if="calculatedFee > 0" class="total-fee"><strong>预计费用：</strong><span class="fee-amount">¥{{ calculatedFee.toFixed(2) }}</span></p>
            <p v-if="reservationDuration > 0" class="duration"><strong>预约时长：</strong>{{ reservationDuration }}小时</p>
          </div>
          
          <el-form :model="reservationForm" label-width="80px">
            <el-form-item label="日期：">
              <el-date-picker
                v-model="reservationForm.date"
                type="date"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
                :disabled-date="disabledDate"
                style="width: 100%"
              />
            </el-form-item>
            
            <el-form-item label="时间：">
              <div class="time-range">
                <el-time-picker
                  v-model="reservationForm.startTime"
                  format="HH:mm"
                  value-format="HH:mm"
                  placeholder="开始时间"
                />
                <span>至</span>
                <el-time-picker
                  v-model="reservationForm.endTime"
                  format="HH:mm"
                  value-format="HH:mm"
                  placeholder="结束时间"
                />
              </div>
            </el-form-item>
            
            <el-form-item label="备注：">
              <el-input
                v-model="reservationForm.remark"
                type="textarea"
                placeholder="请输入备注信息（选填）"
                maxlength="100"
                show-word-limit
              />
            </el-form-item>
          </el-form>
        </div>
        
        <template #footer>
          <el-button @click="showReservationDialog = false">取消</el-button>
          <el-button 
            type="primary" 
            @click="confirmReservation"
            :loading="reserving"
          >
            确认预约
          </el-button>
        </template>
      </el-dialog>
    </div>
  </Layout>
</template>

<script setup>
import { ref, reactive, onMounted, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import Layout from '@/components/Layout.vue'
import { seatApi } from '@/api/seat'
import { reservationApi } from '@/api/reservation'

const loading = ref(false)
const reserving = ref(false)
const seats = ref([])
const selectedSeat = ref(null)
const showReservationDialog = ref(false)

const filters = reactive({
  date: new Date().toISOString().split('T')[0],
  startTime: '09:00',
  endTime: '17:00',
  floorNumber: null,
  area: null
})

const reservationForm = reactive({
  date: new Date().toISOString().split('T')[0],
  startTime: '09:00',
  endTime: '17:00',
  remark: ''
})

const disabledDate = (date) => {
  return date < new Date() || date > new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
}

// 计算预约时长（小时）
const reservationDuration = computed(() => {
  if (!reservationForm.startTime || !reservationForm.endTime) return 0
  
  const start = new Date(`2000-01-01 ${reservationForm.startTime}`)
  const end = new Date(`2000-01-01 ${reservationForm.endTime}`)
  
  if (end <= start) return 0
  
  return Math.round((end - start) / (1000 * 60 * 60) * 100) / 100 // 精确到小数点后两位
})

// 计算预约费用
const calculatedFee = computed(() => {
  if (!selectedSeat.value || reservationDuration.value <= 0) return 0
  return selectedSeat.value.hourlyRate * reservationDuration.value
})

// 监听时间变化，验证时长限制
watch([() => reservationForm.startTime, () => reservationForm.endTime], () => {
  if (reservationDuration.value > 8) {
    ElMessage.warning('单次预约最长不能超过8小时')
  }
  if (reservationDuration.value < 0.5 && reservationDuration.value > 0) {
    ElMessage.warning('最短预约时长为0.5小时')
  }
})

const getSeatClass = (seat) => {
  const classes = ['seat-item']
  
  if (seat.status === 'available') {
    if (seat.available) {
      classes.push('available')
    } else {
      classes.push('occupied')
    }
  } else {
    classes.push('disabled')
  }
  
  if (selectedSeat.value?.id === seat.id) {
    classes.push('selected')
  }
  
  return classes
}

const handleSeatClick = (seat) => {
  if (seat.status !== 'available' || !seat.available) {
    ElMessage.warning('该座位不可预约')
    return
  }
  
  selectedSeat.value = seat
  reservationForm.date = filters.date
  reservationForm.startTime = filters.startTime
  reservationForm.endTime = filters.endTime
  reservationForm.remark = ''
  showReservationDialog.value = true
}

const loadSeats = async () => {
  if (!filters.date || !filters.startTime || !filters.endTime) {
    return
  }
  
  loading.value = true
  try {
    const params = {
      date: filters.date,
      startTime: filters.startTime,
      endTime: filters.endTime,
      floorNumber: filters.floorNumber,
      area: filters.area
    }
    
    const response = await seatApi.getSeatLayout(params)
    seats.value = response || []
  } catch (error) {
    console.error('加载座位失败:', error)
    ElMessage.error('加载座位信息失败')
  } finally {
    loading.value = false
  }
}

const confirmReservation = async () => {
  if (!reservationForm.date || !reservationForm.startTime || !reservationForm.endTime) {
    ElMessage.error('请选择完整的预约时间')
    return
  }
  
  if (reservationForm.startTime >= reservationForm.endTime) {
    ElMessage.error('结束时间必须大于开始时间')
    return
  }
  
  // 验证时长限制
  if (reservationDuration.value > 8) {
    ElMessage.error('单次预约最长不能超过8小时')
    return
  }
  
  if (reservationDuration.value < 0.5) {
    ElMessage.error('最短预约时长为0.5小时')
    return
  }
  
  reserving.value = true
  try {
    const reservationData = {
      seatId: selectedSeat.value.id,
      reservationDate: reservationForm.date,
      startTime: reservationForm.startTime,
      endTime: reservationForm.endTime,
      remark: reservationForm.remark
    }
    
    await reservationApi.createReservation(reservationData)
    ElMessage.success('预约成功')
    showReservationDialog.value = false
    selectedSeat.value = null
    loadSeats()
  } catch (error) {
    console.error('预约失败:', error)
  } finally {
    reserving.value = false
  }
}

onMounted(() => {
  loadSeats()
})
</script>

<style scoped>
.seat-map {
  max-width: 1200px;
  margin: 0 auto;
}

.filter-card {
  margin-bottom: 20px;
}

.filter-row {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.filter-group label {
  white-space: nowrap;
  font-weight: 500;
  color: #666;
}

.time-separator {
  margin: 0 8px;
  color: #666;
}

.legend-card {
  margin-bottom: 20px;
}

.legend {
  display: flex;
  gap: 20px;
  align-items: center;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #666;
}

.seat-demo {
  width: 20px;
  height: 20px;
  border-radius: 4px;
  border: 1px solid #ddd;
}

.seat-demo.available {
  background: #e7f7ff;
  border-color: #409eff;
}

.seat-demo.occupied {
  background: #fdf2f2;
  border-color: #f56c6c;
}

.seat-demo.selected {
  background: #f0f9ff;
  border-color: #67c23a;
}

.seat-demo.disabled {
  background: #f5f5f5;
  border-color: #c0c4cc;
}

.seat-grid-card {
  min-height: 400px;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 300px;
}

.seat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
  gap: 18px;
  padding: 24px;
  max-height: 600px;
  overflow-y: auto;
}

.seat-grid::-webkit-scrollbar {
  width: 8px;
}

.seat-grid::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.seat-grid::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 4px;
}

.seat-grid::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

.seat-item {
  width: 110px;
  height: 90px;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  background: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.seat-item::before {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  border-radius: 12px;
  background: linear-gradient(135deg, transparent, transparent);
  z-index: -1;
  transition: all 0.3s ease;
  opacity: 0;
}

.seat-item.available {
  background: linear-gradient(135deg, #e8f5ff 0%, #f0f9ff 100%);
  border-color: #409eff;
  color: #2c5aa0;
  font-weight: 600;
}

.seat-item.available::before {
  background: linear-gradient(135deg, #409eff, #67c23a);
  opacity: 0;
}

.seat-item.available:hover {
  background: linear-gradient(135deg, #d4ebff 0%, #e1f3ff 100%);
  transform: translateY(-3px) scale(1.02);
  box-shadow: 0 8px 25px rgba(64, 158, 255, 0.25);
  border-color: #409eff;
}

.seat-item.available:hover::before {
  opacity: 1;
}

.seat-item.occupied {
  background: linear-gradient(135deg, #fff2f0 0%, #ffeaea 100%);
  border-color: #ff7875;
  color: #cf1322;
  cursor: not-allowed;
  font-weight: 500;
}

.seat-item.occupied:hover {
  background: linear-gradient(135deg, #fff2f0 0%, #ffeaea 100%);
  transform: none;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.seat-item.selected {
  background: linear-gradient(135deg, #f0f9ff 0%, #e6fffa 100%);
  border-color: #52c41a;
  color: #389e0d;
  box-shadow: 0 0 0 3px rgba(82, 196, 26, 0.2), 0 8px 25px rgba(82, 196, 26, 0.15);
  transform: translateY(-2px) scale(1.05);
  font-weight: 700;
}

.seat-item.selected::before {
  background: linear-gradient(135deg, #52c41a, #73d13d);
  opacity: 1;
}

.seat-item.disabled {
  background: linear-gradient(135deg, #f8f8f8 0%, #f0f0f0 100%);
  border-color: #d9d9d9;
  color: #8c8c8c;
  cursor: not-allowed;
  opacity: 0.6;
}

.seat-number {
  font-weight: 600;
  font-size: 16px;
  margin-bottom: 4px;
}

.seat-info {
  font-size: 12px;
  color: inherit;
  opacity: 0.8;
}

.seat-info-detail {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 6px;
  margin-bottom: 20px;
}

.seat-info-detail p {
  margin: 8px 0;
  color: #666;
}

.total-fee {
  background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
  border: 1px solid #0ea5e9;
  border-radius: 8px;
  padding: 10px 12px;
  margin: 12px 0;
}

.fee-amount {
  color: #0ea5e9;
  font-weight: 700;
  font-size: 18px;
}

.duration {
  background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
  border: 1px solid #22c55e;
  border-radius: 8px;
  padding: 8px 12px;
  margin: 8px 0;
  color: #15803d;
  font-weight: 600;
}

.time-range {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
}

.time-range span {
  color: #666;
}

/* 移动端响应式优化 */
@media (max-width: 768px) {
  .seat-map {
    margin: 0;
    padding: 0 10px;
  }
  
  .filter-card {
    margin-bottom: 15px;
  }
  
  .filter-row {
    flex-direction: column;
    gap: 15px;
    align-items: stretch;
  }
  
  .filter-group {
    width: 100%;
    flex-direction: column;
    gap: 5px;
    align-items: flex-start;
  }
  
  .filter-group label {
    font-size: 14px;
    margin-bottom: 3px;
  }
  
  .filter-group .el-select,
  .filter-group .el-date-picker,
  .filter-group .el-time-picker {
    width: 100%;
  }
  
  .time-separator {
    align-self: center;
    margin: 5px 0;
  }
  
  .legend-card {
    margin-bottom: 15px;
  }
  
  .legend {
    flex-wrap: wrap;
    gap: 15px;
    justify-content: center;
  }
  
  .legend-item {
    font-size: 13px;
  }
  
  .seat-grid {
    grid-template-columns: repeat(auto-fill, minmax(90px, 1fr));
    gap: 12px;
    padding: 15px;
    max-height: 500px;
  }
  
  .seat-item {
    width: 90px;
    height: 75px;
    border-radius: 10px;
  }
  
  .seat-number {
    font-size: 14px;
    margin-bottom: 2px;
  }
  
  .seat-info {
    font-size: 11px;
  }
  
  .reservation-form {
    padding: 0;
  }
  
  .seat-info-detail {
    padding: 12px;
    margin-bottom: 15px;
  }
  
  .seat-info-detail p {
    font-size: 14px;
    margin: 6px 0;
  }
  
  .total-fee {
    padding: 8px 10px;
    margin: 10px 0;
  }
  
  .fee-amount {
    font-size: 16px;
  }
  
  .duration {
    padding: 6px 10px;
    margin: 6px 0;
  }
  
  .time-range {
    flex-direction: column;
    gap: 8px;
  }
  
  .time-range .el-time-picker {
    width: 100%;
  }
  
  :deep(.el-form-item__label) {
    font-size: 14px;
    line-height: 1.4;
  }
  
  :deep(.el-dialog) {
    width: 95% !important;
    margin: 5vh auto;
  }
  
  :deep(.el-dialog__header) {
    padding: 15px 20px 0;
  }
  
  :deep(.el-dialog__body) {
    padding: 15px 20px;
  }
  
  :deep(.el-dialog__footer) {
    padding: 0 20px 20px;
  }
  
  :deep(.el-button) {
    min-height: 40px;
    font-size: 14px;
  }
}

@media (max-width: 480px) {
  .seat-grid {
    grid-template-columns: repeat(auto-fill, minmax(75px, 1fr));
    gap: 10px;
    padding: 12px;
  }
  
  .seat-item {
    width: 75px;
    height: 65px;
  }
  
  .seat-number {
    font-size: 13px;
  }
  
  .seat-info {
    font-size: 10px;
  }
  
  .legend {
    gap: 10px;
  }
  
  .legend-item {
    font-size: 12px;
  }
  
  .seat-demo {
    width: 16px;
    height: 16px;
  }
  
  .filter-group label {
    font-size: 13px;
  }
  
  :deep(.el-form-item__label) {
    font-size: 13px;
  }
  
  :deep(.el-dialog) {
    width: 98% !important;
    margin: 2vh auto;
  }
  
  .seat-info-detail p {
    font-size: 13px;
  }
  
  .fee-amount {
    font-size: 15px;
  }
}
</style>