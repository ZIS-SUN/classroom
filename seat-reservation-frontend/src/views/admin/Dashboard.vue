<template>
  <div class="dashboard">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stat-cards">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card today-reservations" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon><Calendar /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ dashboardStats.todayReservations || 0 }}</div>
              <div class="stat-label">今日预约</div>
            </div>
          </div>
          <div class="stat-trend">
            <span class="trend-value positive">+{{ dashboardStats.reservationGrowth || 0 }}%</span>
            <span class="trend-text">比昨日</span>
          </div>
          <div class="stat-pattern"></div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card total-seats" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon><Grid /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ dashboardStats.totalSeats || 0 }}</div>
              <div class="stat-label">总座位数</div>
            </div>
          </div>
          <div class="stat-trend">
            <span class="trend-value neutral">{{ dashboardStats.availableSeats || 0 }}</span>
            <span class="trend-text">可用座位</span>
          </div>
          <div class="stat-pattern"></div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card active-users" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ dashboardStats.activeUsers || 0 }}</div>
              <div class="stat-label">活跃用户</div>
            </div>
          </div>
          <div class="stat-trend">
            <span class="trend-value positive">+{{ dashboardStats.userGrowth || 0 }}%</span>
            <span class="trend-text">本周增长</span>
          </div>
          <div class="stat-pattern"></div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card revenue" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon><Money /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">¥{{ dashboardStats.todayRevenue || 0 }}</div>
              <div class="stat-label">今日收入</div>
            </div>
          </div>
          <div class="stat-trend">
            <span class="trend-value positive">+{{ dashboardStats.revenueGrowth || 0 }}%</span>
            <span class="trend-text">比昨日</span>
          </div>
          <div class="stat-pattern"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20" class="chart-section">
      <el-col :xs="24" :lg="16">
        <el-card class="chart-card">
          <template #header>
            <div class="chart-header">
              <h3>预约趋势分析</h3>
              <el-radio-group v-model="trendPeriod" size="small" @change="loadTrendData">
                <el-radio-button label="7d">近7天</el-radio-button>
                <el-radio-button label="30d">近30天</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div class="trend-chart">
            <canvas ref="trendChart" width="400" height="200"></canvas>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :lg="8">
        <el-card class="chart-card">
          <template #header>
            <h3>座位类型分布</h3>
          </template>
          <div class="pie-chart">
            <canvas ref="pieChart" width="300" height="200"></canvas>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 最近活动 -->
    <el-row :gutter="20" class="recent-section">
      <el-col :xs="24" :lg="12">
        <el-card class="activity-card">
          <template #header>
            <h3>最近预约</h3>
          </template>
          <div class="recent-reservations" v-loading="recentLoading">
            <div
              v-for="reservation in recentReservations"
              :key="reservation.id"
              class="reservation-item"
            >
              <div class="reservation-info">
                <div class="reservation-user">{{ reservation.userName }}</div>
                <div class="reservation-details">
                  {{ reservation.seatNumber }} · {{ reservation.time }}
                </div>
              </div>
              <el-tag :type="getStatusType(reservation.status)" size="small">
                {{ getStatusText(reservation.status) }}
              </el-tag>
            </div>
            <div v-if="recentReservations.length === 0" class="empty-state">
              暂无最近预约记录
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :lg="12">
        <el-card class="activity-card">
          <template #header>
            <h3>座位使用排行</h3>
          </template>
          <div class="seat-ranking" v-loading="rankingLoading">
            <div
              v-for="(seat, index) in topSeats"
              :key="seat.id"
              class="ranking-item"
            >
              <div class="ranking-number">{{ index + 1 }}</div>
              <div class="seat-info">
                <div class="seat-name">{{ seat.seatNumber }}</div>
                <div class="seat-usage">使用率: {{ seat.usage }}%</div>
              </div>
              <div class="usage-bar">
                <div class="usage-fill" :style="{ width: seat.usage + '%' }"></div>
              </div>
            </div>
            <div v-if="topSeats.length === 0" class="empty-state">
              暂无座位使用数据
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { Calendar, Grid, User, Money } from '@element-plus/icons-vue'
import { statisticsApi } from '@/api/statistics'

// 响应式数据
const dashboardStats = reactive({
  todayReservations: 0,
  totalSeats: 0,
  availableSeats: 0,
  activeUsers: 0,
  todayRevenue: 0,
  reservationGrowth: 0,
  userGrowth: 0,
  revenueGrowth: 0
})

const trendPeriod = ref('7d')
const recentReservations = ref([])
const topSeats = ref([])
const recentLoading = ref(false)
const rankingLoading = ref(false)

// 图表引用
const trendChart = ref(null)
const pieChart = ref(null)

// 状态处理函数
const getStatusType = (status) => {
  const typeMap = {
    'CONFIRMED': 'success',
    'PENDING': 'warning',
    'CANCELLED': 'danger',
    'COMPLETED': 'info'
  }
  return typeMap[status] || 'info'
}

const getStatusText = (status) => {
  const textMap = {
    'CONFIRMED': '已确认',
    'PENDING': '待确认',
    'CANCELLED': '已取消',
    'COMPLETED': '已完成'
  }
  return textMap[status] || status
}

// 加载数据看板统计
const loadDashboardStats = async () => {
  try {
    const response = await statisticsApi.getDashboardStats()
    Object.assign(dashboardStats, response.data || {})
  } catch (error) {
    console.error('加载统计数据失败:', error)
    ElMessage.error('加载统计数据失败')
  }
}

// 加载趋势数据
const loadTrendData = async () => {
  try {
    // 将字符串转换为数字参数
    const days = trendPeriod.value === '7d' ? 7 : 30
    const response = await statisticsApi.getReservationTrend(days)
    await nextTick()
    // 转换后端数据格式为前端需要的格式
    const chartData = response.data && response.data.trendData
      ? response.data.trendData
      : []
    renderTrendChart(chartData)
  } catch (error) {
    console.error('加载趋势数据失败:', error)
  }
}

// 加载座位类型分布
const loadSeatTypeDistribution = async () => {
  try {
    const response = await statisticsApi.getSeatTypeDistribution()
    await nextTick()
    // 转换后端数据格式为前端需要的格式
    const chartData = response.data && response.data.data
      ? response.data.data.map(item => ({
          name: item.typeName || item.name,
          count: item.total || item.value || 0
        }))
      : []
    renderPieChart(chartData)
  } catch (error) {
    console.error('加载座位类型分布失败:', error)
  }
}

// 加载最近预约
const loadRecentReservations = async () => {
  recentLoading.value = true
  try {
    const response = await statisticsApi.getRecentReservations()
    recentReservations.value = response.data || []
  } catch (error) {
    console.error('加载最近预约失败:', error)
    recentReservations.value = []
  } finally {
    recentLoading.value = false
  }
}

// 加载座位排行
const loadTopSeats = async () => {
  rankingLoading.value = true
  try {
    const response = await statisticsApi.getTopSeats()
    topSeats.value = response.data || []
  } catch (error) {
    console.error('加载座位排行失败:', error)
    topSeats.value = []
  } finally {
    rankingLoading.value = false
  }
}

// 渲染趋势图表
const renderTrendChart = (data) => {
  const canvas = trendChart.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  const width = canvas.width
  const height = canvas.height

  // 清空画布
  ctx.clearRect(0, 0, width, height)

  if (!data || data.length === 0) {
    ctx.fillStyle = '#999'
    ctx.font = '14px Arial'
    ctx.textAlign = 'center'
    ctx.fillText('暂无数据', width / 2, height / 2)
    return
  }

  // 绘制简单的趋势线图
  const maxValue = Math.max(...data.map(d => d.value))
  const step = width / (data.length - 1)

  ctx.strokeStyle = '#409EFF'
  ctx.lineWidth = 2
  ctx.beginPath()

  data.forEach((point, index) => {
    const x = index * step
    const y = height - (point.value / maxValue) * height * 0.8

    if (index === 0) {
      ctx.moveTo(x, y)
    } else {
      ctx.lineTo(x, y)
    }
  })

  ctx.stroke()
}

// 渲染饼图
const renderPieChart = (data) => {
  const canvas = pieChart.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  const centerX = canvas.width / 2
  const centerY = canvas.height / 2
  const radius = Math.min(centerX, centerY) - 20

  // 清空画布
  ctx.clearRect(0, 0, canvas.width, canvas.height)

  if (!data || data.length === 0) {
    ctx.fillStyle = '#999'
    ctx.font = '14px Arial'
    ctx.textAlign = 'center'
    ctx.fillText('暂无数据', centerX, centerY)
    return
  }

  const total = data.reduce((sum, item) => sum + item.count, 0)
  let startAngle = -Math.PI / 2

  const colors = ['#409EFF', '#67C23A', '#E6A23C', '#F56C6C', '#909399']

  data.forEach((item, index) => {
    const sliceAngle = (item.count / total) * 2 * Math.PI

    ctx.fillStyle = colors[index % colors.length]
    ctx.beginPath()
    ctx.moveTo(centerX, centerY)
    ctx.arc(centerX, centerY, radius, startAngle, startAngle + sliceAngle)
    ctx.fill()

    startAngle += sliceAngle
  })
}

// 组件挂载时加载数据
onMounted(() => {
  loadDashboardStats()
  loadTrendData()
  loadSeatTypeDistribution()
  loadRecentReservations()
  loadTopSeats()
})
</script>

<style scoped>
.dashboard {
  padding: 0;
}

/* 统计卡片样式 */
.stat-cards {
  margin-bottom: 24px;
}

.stat-card {
  position: relative;
  overflow: hidden;
  border: none;
  border-radius: 12px;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.stat-content {
  display: flex;
  align-items: center;
  padding: 20px;
  position: relative;
  z-index: 2;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
  font-size: 24px;
  color: white;
}

.today-reservations .stat-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.total-seats .stat-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.active-users .stat-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.revenue .stat-icon {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 28px;
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #7f8c8d;
  font-weight: 500;
}

.stat-trend {
  padding: 0 20px 15px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.trend-value {
  font-weight: 600;
  font-size: 12px;
}

.trend-value.positive {
  color: #27ae60;
}

.trend-value.neutral {
  color: #3498db;
}

.trend-text {
  font-size: 12px;
  color: #95a5a6;
}

.stat-pattern {
  position: absolute;
  right: -20px;
  top: -20px;
  width: 80px;
  height: 80px;
  opacity: 0.1;
  background: radial-gradient(circle, currentColor 2px, transparent 2px);
  background-size: 15px 15px;
}

/* 图表区域样式 */
.chart-section {
  margin-bottom: 24px;
}

.chart-card {
  border-radius: 12px;
  overflow: hidden;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
}

.trend-chart, .pie-chart {
  padding: 20px;
  display: flex;
  justify-content: center;
}

/* 最近活动样式 */
.recent-section {
  margin-bottom: 24px;
}

.activity-card {
  border-radius: 12px;
  overflow: hidden;
}

.activity-card h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
}

.recent-reservations, .seat-ranking {
  min-height: 200px;
  max-height: 400px;
  overflow-y: auto;
}

.reservation-item, .ranking-item {
  display: flex;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #f5f5f5;
}

.reservation-item:last-child, .ranking-item:last-child {
  border-bottom: none;
}

.reservation-info {
  flex: 1;
}

.reservation-user, .seat-name {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 4px;
}

.reservation-details, .seat-usage {
  font-size: 12px;
  color: #7f8c8d;
}

.ranking-number {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #3498db;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 12px;
  margin-right: 12px;
}

.seat-info {
  flex: 1;
  margin-right: 12px;
}

.usage-bar {
  width: 80px;
  height: 6px;
  background: #ecf0f1;
  border-radius: 3px;
  overflow: hidden;
}

.usage-fill {
  height: 100%;
  background: linear-gradient(90deg, #3498db, #2ecc71);
  transition: width 0.3s ease;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: #7f8c8d;
  font-size: 14px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .stat-content {
    padding: 16px;
  }

  .stat-icon {
    width: 48px;
    height: 48px;
    font-size: 20px;
    margin-right: 12px;
  }

  .stat-number {
    font-size: 24px;
  }

  .chart-header {
    flex-direction: column;
    gap: 12px;
    align-items: flex-start;
  }
}
</style>