<template>
  <Layout>
    <div class="seat-map">
      <!-- 智能筛选栏 -->
      <section class="filter-section">
        <!-- 主要筛选条件 -->
        <div class="primary-filters">
          <div class="date-time-group">
            <div class="filter-item">
              <el-icon class="filter-icon"><Calendar /></el-icon>
              <el-date-picker
                v-model="filters.date"
                type="date"
                placeholder="选择日期"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
                :disabled-date="disabledDate"
                @change="loadSeats"
                size="default"
              />
            </div>
            <div class="filter-item time-range">
              <el-icon class="filter-icon"><Clock /></el-icon>
              <el-time-picker
                v-model="filters.startTime"
                format="HH:mm"
                value-format="HH:mm"
                placeholder="开始"
                @change="loadSeats"
                size="default"
              />
              <span class="time-separator">—</span>
              <el-time-picker
                v-model="filters.endTime"
                format="HH:mm"
                value-format="HH:mm"
                placeholder="结束"
                @change="loadSeats"
                size="default"
              />
            </div>
          </div>
          
          <div class="quick-filters">
            <el-tag 
              v-for="tag in quickFilterTags" 
              :key="tag.key"
              :type="isFilterActive(tag) ? 'primary' : ''"
              :effect="isFilterActive(tag) ? 'dark' : 'plain'"
              @click="toggleQuickFilter(tag)"
              class="quick-filter-tag"
            >
              <el-icon><Lightning /></el-icon>
              {{ tag.label }}
              <span v-if="tag.count" class="tag-count">({{ tag.count }})</span>
            </el-tag>
          </div>
          
          <div class="filter-actions">
            <el-button @click="toggleAdvancedFilters" text>
              <el-icon><Setting /></el-icon>
              {{ showAdvancedFilters ? '简化筛选' : '高级筛选' }}
            </el-button>
            <el-button @click="resetFilters" v-if="hasActiveFilters">重置</el-button>
          </div>
        </div>
        
        <!-- 高级筛选选项 -->
        <el-collapse-transition>
          <div v-show="showAdvancedFilters" class="advanced-filters">
            <div class="filter-section">
              <label>楼层区域</label>
              <div class="filter-options">
                <el-select v-model="filters.floorNumber" placeholder="楼层" clearable @change="loadSeats">
                  <el-option label="1楼" :value="1" />
                  <el-option label="2楼" :value="2" />
                  <el-option label="3楼" :value="3" />
                </el-select>
                <el-select v-model="filters.area" placeholder="区域" clearable @change="loadSeats">
                  <el-option label="A区" value="A" />
                  <el-option label="B区" value="B" />
                  <el-option label="C区" value="C" />
                </el-select>
              </div>
            </div>
            
            <div class="filter-section">
              <label>座位设施</label>
              <div class="facility-filters">
                <el-checkbox-group v-model="filters.facilities" @change="loadSeats">
                  <el-checkbox label="hasPower">
                    <el-icon><Lightning /></el-icon>
                    电源插座
                  </el-checkbox>
                  <el-checkbox label="hasComputer">
                    <el-icon><Monitor /></el-icon>
                    配备电脑
                  </el-checkbox>
                  <el-checkbox label="isQuiet">
                    <el-icon><Mute /></el-icon>
                    安静区域
                  </el-checkbox>
                  <el-checkbox label="nearWindow">
                    <el-icon><Sunny /></el-icon>
                    靠近窗边
                  </el-checkbox>
                </el-checkbox-group>
              </div>
            </div>
          </div>
        </el-collapse-transition>
      </section>
      
      <!-- 楼层概览面板 -->
      <section class="floor-overview-section">
        <div class="overview-header">
          <h3>
            <el-icon><OfficeBuilding /></el-icon>
            楼层概览
          </h3>
          <div class="overview-stats">
            <span class="total-available">{{ totalAvailableSeats }}个可用</span>
            <el-button @click="autoRefresh = !autoRefresh" :type="autoRefresh ? 'primary' : ''" text size="small">
              <el-icon><Refresh /></el-icon>
              {{ autoRefresh ? '自动刷新已开启' : '开启自动刷新' }}
            </el-button>
          </div>
        </div>
        
        <div class="floor-overview-grid">
          <div 
            v-for="floor in floorStats" 
            :key="floor.floor"
            class="floor-item"
            :class="{ active: filters.floorNumber === floor.floor }"
            @click="selectFloor(floor.floor)"
          >
            <div class="floor-header">
              <span class="floor-name">{{ floor.floor }}楼</span>
              <span class="occupancy-rate" :class="getOccupancyClass(floor.occupancyRate)">
                {{ floor.occupancyRate }}%
              </span>
            </div>
            <div class="floor-stats">
              <div class="stat">
                <span class="number">{{ floor.available }}</span>
                <span class="label">可用</span>
              </div>
              <div class="stat">
                <span class="number">{{ floor.total }}</span>
                <span class="label">总计</span>
              </div>
            </div>
            <div class="floor-progress">
              <el-progress 
                :percentage="floor.occupancyRate" 
                :status="getProgressStatus(floor.occupancyRate)"
                :stroke-width="6"
                :show-text="false"
              />
            </div>
          </div>
        </div>
      </section>

      <!-- 座位图例 -->
      <section class="legend-section">
        <h4 class="legend-title">座位状态说明</h4>
        <div class="legend">
          <div class="legend-item">
            <div class="seat-demo available">
              <i class="el-icon-circle-check"></i>
            </div>
            <span>可预约</span>
          </div>
          <div class="legend-item">
            <div class="seat-demo occupied">
              <i class="el-icon-circle-close"></i>
            </div>
            <span>已预约</span>
          </div>
          <div class="legend-item">
            <div class="seat-demo selected">
              <i class="el-icon-check"></i>
            </div>
            <span>已选择</span>
          </div>
          <div class="legend-item">
            <div class="seat-demo disabled">
              <i class="el-icon-remove"></i>
            </div>
            <span>维护中</span>
          </div>
        </div>
      </section>

      <!-- 座位地图 -->
      <section class="seat-grid-section" v-loading="loading">
        <div v-if="!seats.length && !loading" class="empty-state">
          <el-empty description="暂无座位数据" />
        </div>
        
        <div v-else class="seat-grid">
          <el-tooltip
            v-for="seat in seats"
            :key="seat.id"
            :content="getSeatTooltip(seat)"
            placement="top"
            :show-arrow="false"
            :popper-class="'seat-tooltip'"
            :open-delay="300"
          >
            <div
              class="seat-item"
              :class="getSeatClass(seat)"
              @mouseenter="handleSeatHover(seat)"
              @mouseleave="handleSeatLeave(seat)"
            >
              <div class="seat-content" @click="handleSeatClick(seat)">
                <div class="seat-number">{{ seat.seatNumber }}</div>
                <div class="seat-info">{{ seat.seatTypeName }}</div>
                <div class="seat-features" v-if="seat.hasPower || seat.hasComputer">
                  <i v-if="seat.hasPower" class="feature-icon power" title="有电源">⚡</i>
                  <i v-if="seat.hasComputer" class="feature-icon computer" title="有电脑">💻</i>
                </div>
              </div>
            <div class="seat-actions" v-if="seat.status === 'AVAILABLE'">
              <el-button
                size="small"
                type="primary"
                @click.stop="quickReserve(seat)"
                :loading="seat.reserving"
                title="快速预约"
              >
                快约
              </el-button>
              <el-button
                size="small"
                :type="seat.isFavorited ? 'warning' : 'default'"
                :icon="seat.isFavorited ? 'StarFilled' : 'Star'"
                @click.stop="toggleFavorite(seat)"
                :loading="seat.favoriteLoading"
                circle
              />
            </div>
            </div>
          </el-tooltip>
        </div>
      </section>

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

      <!-- 支付对话框 -->
      <PaymentDialog
        :visible="showPaymentDialog"
        :seat-id="selectedSeat?.id"
        :seat-info="getSeatInfoString()"
        :reservation-time="getReservationTimeString()"
        :amount="calculatedFee"
        :reservation-id="currentReservationId"
        @success="handlePaymentSuccess"
        @error="handlePaymentError"
        @cancel="handlePaymentCancel"
      />
    </div>
  </Layout>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import Layout from '@/components/Layout.vue'
import PaymentDialog from '@/components/PaymentDialog.vue'
import { seatApi } from '@/api/seat'
import { reservationApi } from '@/api/reservation'
import { seatFavoriteApi } from '@/api/seatFavorite'
import {
  Calendar,
  Clock,
  Lightning,
  Setting,
  Monitor,
  Mute,
  Sunny,
  OfficeBuilding,
  Refresh
} from '@element-plus/icons-vue'

const route = useRoute()
const loading = ref(false)
const reserving = ref(false)
const seats = ref([])
const selectedSeat = ref(null)
const showReservationDialog = ref(false)
const showPaymentDialog = ref(false)
const currentReservationId = ref(null)
const showAdvancedFilters = ref(false)
const autoRefresh = ref(false)
const refreshInterval = ref(null)

const filters = reactive({
  date: new Date().toISOString().split('T')[0],
  startTime: '09:00',
  endTime: '17:00',
  floorNumber: null,
  area: null,
  facilities: []
})

const reservationForm = reactive({
  date: new Date().toISOString().split('T')[0],
  startTime: '09:00',
  endTime: '17:00',
  remark: ''
})

// 快速筛选标签
const quickFilterTags = ref([
  { key: 'hasPower', label: '有电源', count: 0 },
  { key: 'hasComputer', label: '有电脑', count: 0 },
  { key: 'isQuiet', label: '安静区', count: 0 },
  { key: 'nearWindow', label: '窗边', count: 0 }
])

// 楼层统计
const floorStats = ref([
  { floor: 1, total: 120, available: 45, occupancyRate: 63 },
  { floor: 2, total: 100, available: 28, occupancyRate: 72 },
  { floor: 3, total: 80, available: 52, occupancyRate: 35 }
])

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

// 计算总可用座位数
const totalAvailableSeats = computed(() => {
  return floorStats.value.reduce((total, floor) => total + floor.available, 0)
})

// 检查是否有活跃的筛选条件
const hasActiveFilters = computed(() => {
  return filters.floorNumber !== null || 
         filters.area !== null || 
         filters.facilities.length > 0
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
  
  if (seat.status === 'AVAILABLE') {
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

// 座位悬停事件
const handleSeatHover = (seat) => {
  // 可以在这里添加额外的悬停逻辑，比如预加载详情数据
  console.log('悬停座位:', seat.seatNumber)
}

const handleSeatLeave = (seat) => {
  // 悬停离开事件
}

// 获取座位tooltip内容
const getSeatTooltip = (seat) => {
  const statusMap = {
    'AVAILABLE': '可预约',
    'OCCUPIED': '已预约',
    'MAINTENANCE': '维护中',
    'DISABLED': '禁用'
  }
  
  const features = []
  if (seat.hasPower) features.push('有电源')
  if (seat.hasComputer) features.push('有电脑')
  
  const location = [seat.area, `${seat.floorNumber}楼`].filter(Boolean).join(' | ')
  
  return `${seat.seatNumber} - ${statusMap[seat.status] || seat.status}
位置: ${location}
类型: ${seat.seatTypeName || '标准座位'}${features.length ? '\n设施: ' + features.join('、') : ''}${seat.description ? '\n备注: ' + seat.description : ''}`
}

const handleSeatClick = (seat) => {
  console.log('座位点击事件触发:', seat)
  
  if (!seat) {
    ElMessage.warning('座位信息不存在')
    return
  }
  
  if (seat.status !== 'AVAILABLE') {
    ElMessage.warning('该座位不可预约')
    return
  }
  
  console.log('座位可预约，打开预约对话框')
  selectedSeat.value = seat
  reservationForm.date = filters.date
  reservationForm.startTime = filters.startTime
  reservationForm.endTime = filters.endTime
  reservationForm.remark = ''
  showReservationDialog.value = true
  
  console.log('预约对话框应该已打开:', showReservationDialog.value)
}

// 筛选相关功能函数
const toggleQuickFilter = (tag) => {
  const index = filters.facilities.indexOf(tag.key)
  if (index > -1) {
    filters.facilities.splice(index, 1)
  } else {
    filters.facilities.push(tag.key)
  }
  loadSeats()
}

const isFilterActive = (tag) => {
  return filters.facilities.includes(tag.key)
}

const toggleAdvancedFilters = () => {
  showAdvancedFilters.value = !showAdvancedFilters.value
}

const resetFilters = () => {
  filters.floorNumber = null
  filters.area = null
  filters.facilities = []
  loadSeats()
}

// 楼层选择功能
const selectFloor = (floorNumber) => {
  if (filters.floorNumber === floorNumber) {
    filters.floorNumber = null
  } else {
    filters.floorNumber = floorNumber
  }
  loadSeats()
}

const getOccupancyClass = (rate) => {
  if (rate >= 80) return 'high'
  if (rate >= 50) return 'medium'
  return 'low'
}

const getProgressStatus = (rate) => {
  if (rate >= 80) return 'exception'
  if (rate >= 50) return 'warning'
  return 'success'
}

// 更新楼层统计数据
const updateFloorStats = () => {
  const statsByFloor = {}
  
  seats.value.forEach(seat => {
    const floor = seat.floorNumber
    if (!statsByFloor[floor]) {
      statsByFloor[floor] = { total: 0, available: 0 }
    }
    statsByFloor[floor].total++
    if (seat.available) {
      statsByFloor[floor].available++
    }
  })
  
  floorStats.value = floorStats.value.map(floor => {
    const stats = statsByFloor[floor.floor] || { total: floor.total, available: 0 }
    const occupancyRate = stats.total > 0 ? Math.round((1 - stats.available / stats.total) * 100) : 0
    return {
      ...floor,
      total: stats.total,
      available: stats.available,
      occupancyRate
    }
  })
}

const loadSeats = async () => {
  if (!filters.date || !filters.startTime || !filters.endTime) {
    console.log('缺少必要的筛选条件:', filters)
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
    
    console.log('加载座位，参数:', params)
    const response = await seatApi.getSeatLayout(params)
    console.log('座位数据响应:', response)
    
    // 处理新的响应格式 {code, message, data}
    if (response && response.code === 200) {
      const rawSeats = Array.isArray(response.data) ? response.data : []
      // 确保每个座位都有 hourlyRate 字段
      seats.value = rawSeats.map(seat => ({
        ...seat,
        hourlyRate: seat.hourlyRate || 10.0,  // 默认10元/小时
        isFavorited: false,  // 初始化收藏状态
        favoriteLoading: false  // 初始化收藏加载状态
      }))

      // 检查每个座位的收藏状态
      await checkFavoriteStatus()
    } else {
      seats.value = []
      if (response?.message) {
        ElMessage.error(response.message)
      }
    }
    console.log('当前座位列表:', seats.value)

    updateFloorStats()
    updateQuickFilterCounts()
  } catch (error) {
    console.error('加载座位失败:', error)
    ElMessage.error('加载座位信息失败')
    seats.value = []
  } finally {
    loading.value = false
  }
}

// 更新快速筛选标签的数量
const updateQuickFilterCounts = () => {
  quickFilterTags.value.forEach(tag => {
    tag.count = seats.value.filter(seat => seat[tag.key] === true).length
  })
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
    
    const response = await reservationApi.createReservation(reservationData)
    
    // 处理新的响应格式
    if (response && response.code === 200) {
      currentReservationId.value = response.data.id
      showReservationDialog.value = false
      showPaymentDialog.value = true
      ElMessage.success('预约创建成功，请完成支付')
    } else {
      ElMessage.error(response?.message || '预约创建失败')
    }
    
  } catch (error) {
    console.error('预约失败:', error)
    ElMessage.error(error?.response?.data?.message || '预约失败，请稍后重试')
  } finally {
    reserving.value = false
  }
}

// 收藏功能
const toggleFavorite = async (seat) => {
  seat.favoriteLoading = true
  try {
    if (seat.isFavorited) {
      await seatFavoriteApi.removeFavorite(seat.id)
      seat.isFavorited = false
      ElMessage.success('取消收藏成功')
    } else {
      await seatFavoriteApi.addFavorite({
        seatId: seat.id,
        favoriteName: `座位${seat.seatNumber}`
      })
      seat.isFavorited = true
      ElMessage.success('收藏成功')
    }
  } catch (error) {
    console.error('收藏操作失败:', error)
    ElMessage.error('收藏操作失败')
  } finally {
    seat.favoriteLoading = false
  }
}

// 检查收藏状态
const checkFavoriteStatus = async () => {
  try {
    // 批量检查所有座位的收藏状态
    const favoriteChecks = seats.value.map(async (seat) => {
      try {
        const response = await seatFavoriteApi.checkFavorite(seat.id)
        if (response && response.code === 200) {
          seat.isFavorited = response.data || false
        }
      } catch (error) {
        // 静默处理错误，不影响用户体验
        console.log(`检查座位${seat.id}收藏状态失败:`, error.message)
        seat.isFavorited = false
      }
    })

    await Promise.all(favoriteChecks)
  } catch (error) {
    console.error('批量检查收藏状态失败:', error)
  }
}

// 快速预约
const quickReserve = async (seat) => {
  try {
    seat.reserving = true
    
    // 获取今天的日期
    const today = new Date()
    const startDate = today.toISOString().split('T')[0]
    
    // 设置预约时间（当前时间后1小时到当前时间后3小时）
    const startHour = today.getHours() + 1
    const endHour = startHour + 2
    
    // 构造预约数据
    const reservationData = {
      seatId: seat.id,
      reservationDate: startDate,
      startTime: `${String(startHour).padStart(2, '0')}:00`,
      endTime: `${String(endHour).padStart(2, '0')}:00`,
      remark: '快速预约'
    }
    
    const response = await reservationApi.createReservation(reservationData)
    
    // 处理新的响应格式
    if (response && response.code === 200) {
      // 快速预约成功后，设置选中座位并显示支付对话框
      selectedSeat.value = seat
      reservationForm.date = startDate
      reservationForm.startTime = `${String(startHour).padStart(2, '0')}:00`
      reservationForm.endTime = `${String(endHour).padStart(2, '0')}:00`
      reservationForm.remark = '快速预约'
      
      currentReservationId.value = response.data.id
      showPaymentDialog.value = true
      ElMessage.success('快速预约成功，请完成支付')
    } else {
      ElMessage.error(response?.message || '快速预约失败')
    }
    
  } catch (error) {
    console.error('快速预约失败:', error)
    ElMessage.error(error?.response?.data?.message || '快速预约失败')
  } finally {
    seat.reserving = false
  }
}

// 自动刷新功能
watch(autoRefresh, (newValue) => {
  if (newValue) {
    refreshInterval.value = setInterval(() => {
      loadSeats()
    }, 30000) // 每30秒刷新一次
    ElMessage.success('已开启自动刷新，每30秒更新一次座位状态')
  } else {
    if (refreshInterval.value) {
      clearInterval(refreshInterval.value)
      refreshInterval.value = null
    }
    ElMessage.info('已关闭自动刷新')
  }
})

// 组件销毁时清除定时器
const clearRefreshInterval = () => {
  if (refreshInterval.value) {
    clearInterval(refreshInterval.value)
    refreshInterval.value = null
  }
}

onMounted(() => {
  // 处理从首页传递的查询参数
  if (route.query.date) {
    filters.date = route.query.date
  }
  if (route.query.startTime) {
    filters.startTime = route.query.startTime
  }
  if (route.query.duration) {
    // 根据持续时间计算结束时间
    const startHour = parseInt(route.query.startTime)
    const duration = parseInt(route.query.duration)
    const endHour = startHour + duration
    filters.endTime = endHour < 24 ? `${endHour.toString().padStart(2, '0')}:00` : '23:59'
  }
  
  loadSeats()
})

// 组件卸载时清理
// 支付相关处理函数
const handlePaymentSuccess = (paymentInfo) => {
  ElMessage.success('支付成功！预约已生效')
  showPaymentDialog.value = false
  selectedSeat.value = null
  currentReservationId.value = null
  loadSeats()
}

const handlePaymentError = (error) => {
  ElMessage.error(error || '支付失败')
  // 支付失败时不关闭对话框，让用户可以重试
}

const handlePaymentCancel = () => {
  showPaymentDialog.value = false
  selectedSeat.value = null
  currentReservationId.value = null
  // 可以选择取消预约或保留预约
  ElMessage.info('已取消支付，预约已创建但需要支付后生效')
}

// 获取预约时间字符串
const getReservationTimeString = () => {
  if (!reservationForm.date || !reservationForm.startTime || !reservationForm.endTime) {
    return ''
  }
  return `${reservationForm.date} ${reservationForm.startTime} - ${reservationForm.endTime}`
}

// 获取座位信息字符串
const getSeatInfoString = () => {
  if (!selectedSeat.value) return ''
  return `${selectedSeat.value.floorNumber}楼${selectedSeat.value.area}区 ${selectedSeat.value.seatNumber}`
}

onUnmounted(() => {
  clearRefreshInterval()
})
</script>

<style scoped>
.seat-map {
  min-height: 100vh;
  background: linear-gradient(135deg, #f0fdf4 0%, #ffffff 100%);
}

/* 筛选栏样式 - 现代化 */
.filter-section {
  background: white;
  padding: 30px 0;
  border-bottom: 1px solid rgba(0,0,0,0.05);
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}

.primary-filters {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: flex;
  align-items: flex-start;
  gap: 20px;
  flex-wrap: wrap;
  margin-bottom: 16px;
}

.date-time-group {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.filter-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.filter-icon {
  color: var(--color-primary);
  font-size: 16px;
}

.time-range {
  display: flex;
  align-items: center;
  gap: 8px;
}

.quick-filters {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  flex: 1;
}

.quick-filter-tag {
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 4px;
  border-radius: var(--radius-base);
  font-size: 13px;
  padding: 6px 12px;
}

.quick-filter-tag:hover {
  transform: translateY(-1px);
  box-shadow: var(--shadow-sm);
}

.tag-count {
  font-size: 11px;
  opacity: 0.8;
  margin-left: 2px;
}

.filter-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.advanced-filters {
  padding-top: 16px;
  border-top: 1px solid var(--color-border-light);
  margin-top: 16px;
}

.filter-section {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 16px;
}

.filter-section:last-child {
  margin-bottom: 0;
}

.filter-section label {
  min-width: 80px;
  font-weight: 500;
  color: var(--color-text-primary);
  font-size: 14px;
}

.filter-options {
  display: flex;
  gap: 12px;
  align-items: center;
}

.facility-filters {
  display: flex;
  align-items: center;
}

.facility-filters .el-checkbox {
  margin-right: 16px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.facility-filters .el-checkbox__label {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
}

/* 楼层概览面板样式 */
.floor-overview-section {
  padding: 40px 0;
  background: rgba(5, 150, 105, 0.02);
}

.overview-header {
  max-width: 1200px;
  margin: 0 auto 30px;
  padding: 0 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.overview-header h3 {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: var(--color-text-primary);
  margin: 0;
}

.overview-stats {
  display: flex;
  align-items: center;
  gap: 12px;
}

.total-available {
  font-size: 14px;
  color: var(--color-success);
  font-weight: 500;
}

.floor-overview-grid {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 30px;
}

.floor-item {
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-lg);
  padding: 16px;
  background: var(--color-background-secondary);
  cursor: pointer;
  transition: all 0.2s ease;
}

.floor-item:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-sm);
  transform: translateY(-1px);
}

.floor-item.active {
  border-color: var(--color-primary);
  background: rgba(37, 99, 235, 0.05);
  box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.1);
}

.floor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.floor-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--color-text-primary);
}

.occupancy-rate {
  font-size: 14px;
  font-weight: 500;
  padding: 2px 8px;
  border-radius: var(--radius-sm);
}

.occupancy-rate.low {
  background: rgba(16, 185, 129, 0.1);
  color: var(--color-success);
}

.occupancy-rate.medium {
  background: rgba(217, 119, 6, 0.1);
  color: var(--color-warning);
}

.occupancy-rate.high {
  background: rgba(220, 38, 38, 0.1);
  color: var(--color-danger);
}

.floor-stats {
  display: flex;
  gap: 16px;
  margin-bottom: 12px;
}

.stat {
  text-align: center;
}

.stat .number {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-primary);
  display: block;
}

.stat .label {
  font-size: 12px;
  color: var(--color-text-secondary);
  margin-top: 2px;
}

.floor-progress {
  margin-top: 8px;
}

/* 旧版筛选样式（保留用于向后兼容） */
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
  color: var(--color-text-primary);
  font-size: 14px;
}

.time-separator {
  margin: 0 12px;
  color: var(--color-text-tertiary);
  font-size: 14px;
}

.legend-section {
  padding: 30px 0;
  background: white;
  border-bottom: 1px solid rgba(0,0,0,0.05);
}

.legend-title {
  max-width: 1200px;
  margin: 0 auto 20px;
  padding: 0 20px;
  color: var(--color-text-primary);
  font-size: 1.5rem;
  font-weight: 600;
  text-align: center;
}

.legend {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: flex;
  gap: 40px;
  justify-content: center;
  flex-wrap: wrap;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: var(--color-text-secondary);
  padding: 8px 12px;
  background: var(--color-background-primary);
  border-radius: var(--radius-base);
  border: 1px solid var(--color-border-light);
}

.seat-demo {
  width: 24px;
  height: 24px;
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
}

.seat-demo.available {
  background: var(--color-seat-available);
  border-color: var(--color-seat-available);
  color: #ffffff;
}

.seat-demo.occupied {
  background: var(--color-seat-occupied);
  border-color: var(--color-seat-occupied);
  color: #ffffff;
}

.seat-demo.selected {
  background: var(--color-seat-selected);
  border-color: var(--color-seat-selected);
  color: #ffffff;
}

.seat-demo.disabled {
  background: var(--color-seat-disabled);
  border-color: var(--color-border);
  color: var(--color-text-tertiary);
}

.seat-grid-section {
  min-height: 500px;
  padding: 40px 0 60px;
  background: linear-gradient(135deg, #f0fdf4 0%, #ecfdf5 25%, #ffffff 75%, #f8fafc 100%);
  position: relative;
}

.seat-grid-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at 30% 20%, rgba(16, 185, 129, 0.05) 0%, transparent 50%),
              radial-gradient(circle at 70% 80%, rgba(59, 130, 246, 0.05) 0%, transparent 50%);
  pointer-events: none;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 300px;
}

.seat-grid {
  max-width: 1200px;
  margin: 0 auto;
  padding: 30px 20px;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 24px;
  max-height: 700px;
  overflow-y: auto;
  background: rgba(255, 255, 255, 0.7);
  border-radius: 16px;
  backdrop-filter: blur(10px);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
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
  width: 120px;
  height: 100px;
  border: 2px solid transparent;
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  position: relative;
  background: linear-gradient(145deg, #ffffff, #f8fafc);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08), 0 2px 4px rgba(0, 0, 0, 0.04);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
  overflow: hidden;
}

.seat-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  font-size: 13px;
  padding: 8px;
  position: relative;
  z-index: 1;
}

.seat-actions {
  position: absolute;
  top: 4px;
  right: 4px;
  z-index: 2;
  display: flex;
  gap: 4px;
  align-items: center;
}

.seat-item.available {
  background: linear-gradient(145deg, #ecfdf5, #f0fdf4);
  border-color: #10b981;
  color: #047857;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.15), 0 2px 4px rgba(16, 185, 129, 0.08);
}

.seat-item.available:hover {
  background: linear-gradient(145deg, #d1fae5, #ecfdf5);
  border-color: #059669;
  box-shadow: 0 8px 20px rgba(16, 185, 129, 0.25), 0 4px 8px rgba(16, 185, 129, 0.15);
  transform: translateY(-3px) scale(1.02);
}

.seat-item.available::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, transparent 30%, rgba(16, 185, 129, 0.1) 50%, transparent 70%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.seat-item.available:hover::before {
  opacity: 1;
}

.seat-item.occupied {
  background: linear-gradient(145deg, #fef2f2, #fecaca);
  border-color: #ef4444;
  color: #dc2626;
  cursor: not-allowed;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.15), 0 2px 4px rgba(239, 68, 68, 0.08);
  opacity: 0.7;
}

.seat-item.occupied:hover {
  transform: none;
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.15), 0 2px 4px rgba(239, 68, 68, 0.08);
}

.seat-item.occupied::after {
  content: '✕';
  position: absolute;
  top: 6px;
  right: 6px;
  font-size: 12px;
  color: #dc2626;
  font-weight: bold;
}

.seat-item.selected {
  background: linear-gradient(145deg, #dbeafe, #bfdbfe);
  border-color: #3b82f6;
  color: #1d4ed8;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.3), 0 8px 20px rgba(59, 130, 246, 0.25);
  font-weight: 700;
  transform: translateY(-2px) scale(1.05);
}

.seat-item.selected::after {
  content: '✓';
  position: absolute;
  top: 6px;
  right: 6px;
  font-size: 14px;
  color: #1d4ed8;
  font-weight: bold;
}

.seat-item.disabled {
  background: var(--color-seat-disabled);
  border-color: var(--color-border);
  color: var(--color-text-tertiary);
  cursor: not-allowed;
  opacity: 0.7;
}

.seat-number {
  font-weight: 700;
  font-size: 16px;
  margin-bottom: 4px;
  color: inherit;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  letter-spacing: 0.5px;
}

.seat-info {
  font-size: 11px;
  color: inherit;
  opacity: 0.8;
  text-align: center;
  font-weight: 500;
  line-height: 1.2;
}

.seat-info-detail {
  background: var(--color-background-tertiary);
  padding: 16px;
  border-radius: var(--radius-base);
  margin-bottom: 20px;
  border: 1px solid var(--color-border-light);
}

.seat-info-detail p {
  margin: 6px 0;
  color: var(--color-text-secondary);
  font-size: 14px;
}

.total-fee {
  background: rgba(37, 99, 235, 0.05);
  border: 1px solid var(--color-primary);
  border-radius: var(--radius-base);
  padding: 12px 16px;
  margin: 16px 0;
  text-align: center;
}

.fee-amount {
  color: var(--color-primary);
  font-weight: 600;
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
  
  .filter-card.enhanced {
    margin-bottom: 15px;
  }
  
  /* 新版筛选移动端适配 */
  .primary-filters {
    flex-direction: column;
    gap: 15px;
    align-items: stretch;
  }
  
  .date-time-group {
    flex-direction: column;
    gap: 10px;
    align-items: stretch;
  }
  
  .filter-item {
    width: 100%;
  }
  
  .filter-item .el-date-picker,
  .filter-item .el-time-picker {
    width: 100%;
  }
  
  .time-range {
    flex-direction: column;
    gap: 8px;
    align-items: stretch;
  }
  
  .time-separator {
    align-self: center;
    margin: 5px 0;
  }
  
  .quick-filters {
    justify-content: flex-start;
    gap: 6px;
  }
  
  .quick-filter-tag {
    font-size: 12px;
    padding: 4px 8px;
  }
  
  .filter-actions {
    justify-content: center;
  }
  
  .filter-section {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }
  
  .filter-section label {
    min-width: auto;
    font-size: 13px;
  }
  
  .filter-options {
    flex-direction: column;
    gap: 8px;
  }
  
  .facility-filters .el-checkbox {
    margin-right: 12px;
  }
  
  /* 楼层概览移动端适配 */
  .floor-overview-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  
  .floor-item {
    padding: 12px;
  }
  
  .overview-header {
    flex-direction: column;
    gap: 8px;
    align-items: flex-start;
  }
  
  .overview-stats {
    align-self: stretch;
    justify-content: space-between;
  }
  
  /* 旧版筛选移动端兼容 */
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
    grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
    gap: 16px;
    padding: 20px;
    max-height: 500px;
    background: rgba(255, 255, 255, 0.8);
    border-radius: 12px;
  }
  
  .seat-item {
    width: 110px;
    height: 90px;
    border-radius: 12px;
    border-width: 1.5px;
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

/* 座位特性图标样式 */
.seat-features {
  position: absolute;
  top: -5px;
  right: -5px;
  display: flex;
  gap: 2px;
}

.feature-icon {
  font-size: 10px;
  line-height: 1;
  padding: 1px 2px;
  border-radius: 2px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(4px);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.feature-icon.power {
  color: #f59e0b;
}

.feature-icon.computer {
  color: #3b82f6;
}

/* 座位tooltip样式 */
:deep(.seat-tooltip) {
  --el-popover-padding: 12px;
  background: rgba(0, 0, 0, 0.85) !important;
  border: none !important;
  border-radius: 8px !important;
  backdrop-filter: blur(10px);
  color: white !important;
  font-size: 13px !important;
  line-height: 1.4 !important;
  max-width: 250px !important;
  white-space: pre-line !important;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3) !important;
}

:deep(.seat-tooltip .el-popper__arrow::before) {
  background: rgba(0, 0, 0, 0.85) !important;
  border: none !important;
}

/* 座位悬停增强效果 */
.seat-item {
  transition: all 0.2s ease;
  position: relative;
}

.seat-item:hover {
  transform: translateY(-2px) scale(1.05);
  z-index: 10;
}

.seat-item:hover .seat-content {
  box-shadow: 0 8px 25px rgba(34, 197, 94, 0.2);
}
</style>