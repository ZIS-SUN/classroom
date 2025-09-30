<template>
  <div class="reports-management">
    <div class="page-header">
      <h2>报表统计</h2>
      <div class="header-actions">
        <el-button @click="exportReport">
          <el-icon><Download /></el-icon>
          导出报表
        </el-button>
        <el-button @click="loadReportStats">
          <el-icon><Refresh /></el-icon>
          刷新数据
        </el-button>
      </div>
    </div>

    <!-- 统计概览卡片 -->
    <el-row :gutter="20" class="stats-cards">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon total-reservations">
              <el-icon><Calendar /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ reportStats.totalReservations }}</div>
              <div class="stat-label">总预约数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon seat-utilization">
              <el-icon><Grid /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ reportStats.seatUtilization }}%</div>
              <div class="stat-label">座位利用率</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon active-users">
              <el-icon><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">{{ reportStats.activeUserRate }}%</div>
              <div class="stat-label">用户活跃率</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon revenue">
              <el-icon><Money /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-number">¥{{ reportStats.totalRevenue }}</div>
              <div class="stat-label">总收入</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 时间选择器 -->
    <el-card class="filter-card">
      <el-form :inline="true" class="filter-form">
        <el-form-item label="统计时间">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            @change="handleDateRangeChange"
          />
        </el-form-item>

        <el-form-item label="统计维度">
          <el-radio-group v-model="timeDimension" @change="handleTimeDimensionChange">
            <el-radio-button label="day">按天</el-radio-button>
            <el-radio-button label="week">按周</el-radio-button>
            <el-radio-button label="month">按月</el-radio-button>
          </el-radio-group>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 图表展示 -->
    <el-row :gutter="20" class="charts-section">
      <!-- 预约趋势图 -->
      <el-col :xs="24" :lg="12">
        <el-card class="chart-card">
          <template #header>
            <h3>预约趋势分析</h3>
          </template>
          <div class="chart-container" v-loading="chartsLoading">
            <canvas ref="reservationTrendChart" width="400" height="300"></canvas>
          </div>
        </el-card>
      </el-col>

      <!-- 座位利用率图 -->
      <el-col :xs="24" :lg="12">
        <el-card class="chart-card">
          <template #header>
            <h3>座位利用率统计</h3>
          </template>
          <div class="chart-container" v-loading="chartsLoading">
            <canvas ref="utilizationChart" width="400" height="300"></canvas>
          </div>
        </el-card>
      </el-col>

      <!-- 收入统计图 -->
      <el-col :xs="24" :lg="12">
        <el-card class="chart-card">
          <template #header>
            <h3>收入统计分析</h3>
          </template>
          <div class="chart-container" v-loading="chartsLoading">
            <canvas ref="revenueChart" width="400" height="300"></canvas>
          </div>
        </el-card>
      </el-col>

      <!-- 用户活跃度图 -->
      <el-col :xs="24" :lg="12">
        <el-card class="chart-card">
          <template #header>
            <h3>用户活跃度分析</h3>
          </template>
          <div class="chart-container" v-loading="chartsLoading">
            <canvas ref="userActivityChart" width="400" height="300"></canvas>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 详细数据表格 -->
    <el-card class="table-card">
      <template #header>
        <h3>详细统计数据</h3>
      </template>

      <el-tabs v-model="activeReportTab" @tab-click="handleTabClick">
        <el-tab-pane label="预约统计" name="reservations">
          <el-table :data="reservationReportData" v-loading="tableLoading" stripe>
            <el-table-column prop="date" label="日期" />
            <el-table-column prop="totalReservations" label="总预约数" />
            <el-table-column prop="confirmedReservations" label="已确认" />
            <el-table-column prop="cancelledReservations" label="已取消" />
            <el-table-column prop="completedReservations" label="已完成" />
            <el-table-column prop="averageDuration" label="平均时长(小时)" />
            <el-table-column prop="revenue" label="收入(元)">
              <template #default="{ row }">
                ¥{{ row.revenue }}
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="座位统计" name="seats">
          <el-table :data="seatReportData" v-loading="tableLoading" stripe>
            <el-table-column prop="seatNumber" label="座位号" />
            <el-table-column prop="area" label="区域" />
            <el-table-column prop="totalUsageTime" label="总使用时长(小时)" />
            <el-table-column prop="utilizationRate" label="利用率(%)" />
            <el-table-column prop="totalRevenue" label="总收入(元)">
              <template #default="{ row }">
                ¥{{ row.totalRevenue }}
              </template>
            </el-table-column>
            <el-table-column prop="averageSessionDuration" label="平均使用时长(小时)" />
          </el-table>
        </el-tab-pane>

        <el-tab-pane label="用户统计" name="users">
          <el-table :data="userReportData" v-loading="tableLoading" stripe>
            <el-table-column prop="username" label="用户名" />
            <el-table-column prop="realName" label="真实姓名" />
            <el-table-column prop="totalReservations" label="总预约数" />
            <el-table-column prop="totalUsageTime" label="总使用时长(小时)" />
            <el-table-column prop="totalSpent" label="总消费(元)">
              <template #default="{ row }">
                ¥{{ row.totalSpent }}
              </template>
            </el-table-column>
            <el-table-column prop="lastReservationTime" label="最后预约时间" />
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { Download, Refresh, Calendar, Grid, User, Money } from '@element-plus/icons-vue'
import { statisticsApi } from '@/api/statistics'

// 响应式数据
const chartsLoading = ref(false)
const tableLoading = ref(false)
const dateRange = ref([])
const timeDimension = ref('day')
const activeReportTab = ref('reservations')

// 统计数据
const reportStats = reactive({
  totalReservations: 0,
  seatUtilization: 0,
  activeUserRate: 0,
  totalRevenue: 0
})

// 表格数据
const reservationReportData = ref([])
const seatReportData = ref([])
const userReportData = ref([])

// 图表引用
const reservationTrendChart = ref(null)
const utilizationChart = ref(null)
const revenueChart = ref(null)
const userActivityChart = ref(null)

// 加载报表统计数据
const loadReportStats = async () => {
  try {
    console.log('正在加载报表统计数据')
    const response = await statisticsApi.getDashboardStats()
    console.log('报表统计响应:', response)

    if (response && response.data) {
      Object.assign(reportStats, response.data)
    }
  } catch (error) {
    console.error('加载报表统计失败:', error)
    ElMessage.error('加载统计数据失败')
  }
}

// 加载图表数据
const loadChartData = async () => {
  chartsLoading.value = true
  try {
    console.log('正在加载图表数据')

    // 将字符串时间维度转换为数字参数
    const getDaysFromDimension = (dimension) => {
      switch (dimension) {
        case 'day': return 1
        case 'week': return 7
        case 'month': return 30
        default: return 7
      }
    }

    const days = getDaysFromDimension(timeDimension.value)

    // 并行加载所有图表数据
    const [trendData, utilizationData, revenueData, activityData] = await Promise.all([
      statisticsApi.getReservationTrend(days),
      statisticsApi.getSeatTypeDistribution(),
      statisticsApi.getDashboardStats(),
      statisticsApi.getDashboardStats()
    ])

    await nextTick()

    // 渲染图表 - 转换数据格式
    const trendChartData = trendData.data && trendData.data.trendData ? trendData.data.trendData : []
    const utilizationChartData = utilizationData.data && utilizationData.data.data ?
      utilizationData.data.data.map(item => ({
        name: item.typeName || item.name,
        value: item.usageRate || ((item.used || 0) / (item.total || 1) * 100)
      })) : []

    renderReservationTrendChart(trendChartData)
    renderUtilizationChart(utilizationChartData)
    renderRevenueChart(revenueData.data || [])
    renderUserActivityChart(activityData.data || [])

  } catch (error) {
    console.error('加载图表数据失败:', error)
    ElMessage.error('加载图表数据失败')
  } finally {
    chartsLoading.value = false
  }
}

// 加载表格数据
const loadTableData = async (tabName) => {
  tableLoading.value = true
  try {
    console.log('正在加载表格数据:', tabName)

    // 根据不同的tab加载不同的数据
    switch (tabName) {
      case 'reservations':
        // 模拟预约统计数据
        reservationReportData.value = [
          {
            date: '2024-01-15',
            totalReservations: 45,
            confirmedReservations: 40,
            cancelledReservations: 3,
            completedReservations: 37,
            averageDuration: 2.5,
            revenue: 1250
          },
          {
            date: '2024-01-14',
            totalReservations: 52,
            confirmedReservations: 48,
            cancelledReservations: 2,
            completedReservations: 46,
            averageDuration: 2.8,
            revenue: 1480
          }
        ]
        break

      case 'seats':
        // 模拟座位统计数据
        seatReportData.value = [
          {
            seatNumber: 'A101',
            area: 'A区',
            totalUsageTime: 48,
            utilizationRate: 85,
            totalRevenue: 960,
            averageSessionDuration: 2.4
          },
          {
            seatNumber: 'A102',
            area: 'A区',
            totalUsageTime: 42,
            utilizationRate: 78,
            totalRevenue: 840,
            averageSessionDuration: 2.1
          }
        ]
        break

      case 'users':
        // 模拟用户统计数据
        userReportData.value = [
          {
            username: 'student001',
            realName: '张三',
            totalReservations: 15,
            totalUsageTime: 38,
            totalSpent: 760,
            lastReservationTime: '2024-01-15 14:30:00'
          },
          {
            username: 'student002',
            realName: '李四',
            totalReservations: 12,
            totalUsageTime: 28,
            totalSpent: 560,
            lastReservationTime: '2024-01-14 16:45:00'
          }
        ]
        break
    }

  } catch (error) {
    console.error('加载表格数据失败:', error)
    ElMessage.error('加载表格数据失败')
  } finally {
    tableLoading.value = false
  }
}

// 渲染预约趋势图
const renderReservationTrendChart = (data) => {
  const canvas = reservationTrendChart.value
  if (!canvas || !data.length) return

  const ctx = canvas.getContext('2d')
  const width = canvas.width
  const height = canvas.height

  ctx.clearRect(0, 0, width, height)

  // 绘制简单的趋势线
  const maxValue = Math.max(...data.map(d => d.value))
  const step = width / (data.length - 1)

  ctx.strokeStyle = '#409EFF'
  ctx.lineWidth = 3
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

  // 绘制数据点
  ctx.fillStyle = '#409EFF'
  data.forEach((point, index) => {
    const x = index * step
    const y = height - (point.value / maxValue) * height * 0.8
    ctx.beginPath()
    ctx.arc(x, y, 4, 0, Math.PI * 2)
    ctx.fill()
  })
}

// 渲染利用率图
const renderUtilizationChart = (data) => {
  const canvas = utilizationChart.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  ctx.clearRect(0, 0, canvas.width, canvas.height)

  // 绘制简单的柱状图
  const barWidth = canvas.width / Math.max(data.length, 1) * 0.8
  const maxValue = Math.max(...data.map(d => d.count || 0), 1)

  data.forEach((item, index) => {
    const x = index * (canvas.width / data.length) + (canvas.width / data.length - barWidth) / 2
    const barHeight = (item.count / maxValue) * canvas.height * 0.8
    const y = canvas.height - barHeight

    ctx.fillStyle = `hsl(${index * 60}, 70%, 60%)`
    ctx.fillRect(x, y, barWidth, barHeight)
  })
}

// 渲染收入图
const renderRevenueChart = (data) => {
  const canvas = revenueChart.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  ctx.clearRect(0, 0, canvas.width, canvas.height)

  // 绘制简单的面积图
  ctx.fillStyle = 'rgba(64, 158, 255, 0.1)'
  ctx.strokeStyle = '#409EFF'
  ctx.lineWidth = 2

  ctx.beginPath()
  ctx.moveTo(0, canvas.height)
  ctx.lineTo(canvas.width * 0.2, canvas.height * 0.8)
  ctx.lineTo(canvas.width * 0.5, canvas.height * 0.6)
  ctx.lineTo(canvas.width * 0.8, canvas.height * 0.4)
  ctx.lineTo(canvas.width, canvas.height * 0.3)
  ctx.lineTo(canvas.width, canvas.height)
  ctx.closePath()
  ctx.fill()
  ctx.stroke()
}

// 渲染用户活跃度图
const renderUserActivityChart = (data) => {
  const canvas = userActivityChart.value
  if (!canvas) return

  const ctx = canvas.getContext('2d')
  ctx.clearRect(0, 0, canvas.width, canvas.height)

  // 绘制简单的饼图
  const centerX = canvas.width / 2
  const centerY = canvas.height / 2
  const radius = Math.min(centerX, centerY) * 0.8

  const segments = [
    { label: '活跃用户', value: 65, color: '#67C23A' },
    { label: '一般用户', value: 25, color: '#E6A23C' },
    { label: '不活跃用户', value: 10, color: '#F56C6C' }
  ]

  let startAngle = -Math.PI / 2
  const total = segments.reduce((sum, segment) => sum + segment.value, 0)

  segments.forEach(segment => {
    const sliceAngle = (segment.value / total) * 2 * Math.PI

    ctx.fillStyle = segment.color
    ctx.beginPath()
    ctx.moveTo(centerX, centerY)
    ctx.arc(centerX, centerY, radius, startAngle, startAngle + sliceAngle)
    ctx.fill()

    startAngle += sliceAngle
  })
}

// 事件处理
const handleDateRangeChange = (dates) => {
  console.log('日期范围变更:', dates)
  loadChartData()
  loadTableData(activeReportTab.value)
}

const handleTimeDimensionChange = (dimension) => {
  console.log('时间维度变更:', dimension)
  loadChartData()
}

const handleTabClick = (tab) => {
  console.log('切换到tab:', tab.props.name)
  loadTableData(tab.props.name)
}

// 导出报表
const exportReport = () => {
  ElMessage.info('导出功能开发中...')
}

// 组件挂载时加载数据
onMounted(() => {
  // 设置默认日期范围（最近30天）
  const today = new Date()
  const thirtyDaysAgo = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000)
  dateRange.value = [
    thirtyDaysAgo.toISOString().split('T')[0],
    today.toISOString().split('T')[0]
  ]

  loadReportStats()
  loadChartData()
  loadTableData('reservations')
})
</script>

<style scoped>
.reports-management {
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

/* 统计卡片样式 */
.stats-cards {
  margin-bottom: 24px;
}

.stat-card {
  border-radius: 12px;
  overflow: hidden;
}

.stat-content {
  display: flex;
  align-items: center;
  padding: 20px;
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
  font-size: 24px;
  color: white;
}

.total-reservations {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.seat-utilization {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.active-users {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.revenue {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 24px;
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #7f8c8d;
  font-weight: 500;
}

/* 筛选卡片样式 */
.filter-card {
  margin-bottom: 20px;
  border-radius: 8px;
}

.filter-form {
  margin: 0;
}

/* 图表区域样式 */
.charts-section {
  margin-bottom: 24px;
}

.chart-card {
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 20px;
}

.chart-card h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
}

.chart-container {
  padding: 20px;
  display: flex;
  justify-content: center;
  min-height: 300px;
}

/* 表格卡片样式 */
.table-card {
  border-radius: 12px;
  overflow: hidden;
}

.table-card h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
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

  .stat-content {
    padding: 16px;
  }

  .stat-icon {
    width: 40px;
    height: 40px;
    font-size: 20px;
    margin-right: 12px;
  }

  .stat-number {
    font-size: 20px;
  }
}
</style>