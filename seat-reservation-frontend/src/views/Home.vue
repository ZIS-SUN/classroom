<template>
  <Layout>
    <div class="home">
      <!-- 欢迎区域 -->
      <section class="welcome-section">
        <div class="hero-content">
          <div class="hero-text">
            <h1>座位预订系统</h1>
            <p>请选择您需要的座位时间</p>
          </div>
          
          <!-- 快速预约表单 -->
          <div class="quick-booking-form">
            <div class="form-row">
              <div class="form-item">
                <label>选择日期</label>
                <el-date-picker
                  v-model="quickBooking.date"
                  type="date"
                  placeholder="今天"
                  format="YYYY-MM-DD"
                  value-format="YYYY-MM-DD"
                  size="large"
                />
              </div>
              
              <div class="form-item">
                <label>开始时间</label>
                <el-time-picker
                  v-model="quickBooking.startTime"
                  format="HH:mm"
                  placeholder="现在"
                  size="large"
                />
              </div>
              
              <div class="form-item">
                <label>时长</label>
                <el-select v-model="quickBooking.duration" placeholder="2小时" size="large">
                  <el-option label="1小时" :value="1" />
                  <el-option label="2小时" :value="2" />
                  <el-option label="3小时" :value="3" />
                  <el-option label="4小时" :value="4" />
                  <el-option label="半天" :value="6" />
                  <el-option label="全天" :value="8" />
                </el-select>
              </div>
              
              <div class="form-action">
                <el-button type="primary" size="large" @click="findAvailableSeats" class="find-seats-btn">
                  查看可用座位
                </el-button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 统计数据 -->
      <section class="stats-section">
        <div class="stats-grid">
          <div class="stat-item">
            <div class="stat-content">
              <div class="stat-number">{{ stats.totalSeats }}</div>
              <div class="stat-label">总座位数</div>
            </div>
          </div>
          
          <div class="stat-item">
            <div class="stat-content">
              <div class="stat-number">{{ stats.availableSeats }}</div>
              <div class="stat-label">可用座位</div>
            </div>
          </div>
          
          <div class="stat-item">
            <div class="stat-content">
              <div class="stat-number">{{ stats.myReservations }}</div>
              <div class="stat-label">我的预约</div>
            </div>
          </div>
          
          <div class="stat-item">
            <div class="stat-content">
              <div class="stat-number">{{ occupancyRate }}%</div>
              <div class="stat-label">使用率</div>
            </div>
          </div>
        </div>
      </section>

      <!-- 推荐座位 -->
      <section class="recommended-section" v-loading="recommendationsLoading">
        <div class="section-header">
          <h2>推荐座位</h2>
        </div>
        
        <div class="seats-grid">
          <div class="seat-card" v-for="seat in recommendedSeats" :key="seat.id">
            <div class="seat-info">
              <div class="seat-number">{{ seat.seatNumber }}</div>
              <div class="seat-details">
                <p>{{ seat.floorNumber }}层 {{ seat.area }}区</p>
                <p>预约率 {{ seat.bookingCount }}%</p>
              </div>
              <div class="seat-features">
                <el-tag v-if="seat.hasPower" size="small" type="success">有电源</el-tag>
                <el-tag v-if="seat.hasComputer" size="small" type="info">有电脑</el-tag>
                <el-tag v-if="seat.isQuiet" size="small" type="warning">安静区</el-tag>
              </div>
            </div>
            <el-button type="primary" size="small" @click="quickReserve(seat)" class="reserve-btn">
              立即预约
            </el-button>
          </div>
        </div>
      </section>

      <!-- 公告 -->
      <section class="announcements-section" v-loading="announcementsLoading">
        <div class="section-header">
          <h2>系统公告</h2>
        </div>
        
        <div class="announcements-list">
          <div v-for="announcement in announcements.slice(0, 3)" :key="announcement.id" class="announcement-item">
            <div class="announcement-title">
              <el-tag v-if="announcement.isTop" type="danger" size="small">置顶</el-tag>
              {{ announcement.title }}
            </div>
            <div class="announcement-content">{{ announcement.content }}</div>
            <div class="announcement-time">{{ formatTime(announcement.publishTime || announcement.createTime) }}</div>
          </div>
        </div>
      </section>
    </div>
  </Layout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
// 图标导入已移除，使用简洁设计
import Layout from '@/components/Layout.vue'
import { getAnnouncements } from '@/api/announcement'
import { seatApi } from '@/api/seat'

const router = useRouter()

// 响应式数据
const quickBooking = ref({
  date: new Date().toISOString().split('T')[0],
  startTime: '',
  duration: 2
})

const stats = ref({
  totalSeats: 120,
  availableSeats: 85,
  myReservations: 3
})

const recommendedSeats = ref([])

const announcements = ref([])

const recommendationsLoading = ref(false)
const announcementsLoading = ref(false)

// 计算属性
const occupancyRate = computed(() => {
  if (stats.value.totalSeats === 0) return 0
  return Math.round((1 - stats.value.availableSeats / stats.value.totalSeats) * 100)
})

// 方法
const findAvailableSeats = () => {
  router.push({
    path: '/seat-map',
    query: {
      date: quickBooking.value.date,
      startTime: quickBooking.value.startTime,
      duration: quickBooking.value.duration
    }
  })
}

const quickReserve = (seat) => {
  ElMessage.info(`正在为您预约座位 ${seat.seatNumber}...`)
  // 这里可以调用预约API
  setTimeout(() => {
    ElMessage.success(`座位 ${seat.seatNumber} 预约成功！`)
    stats.value.myReservations++
    stats.value.availableSeats--
  }, 1000)
}

const formatTime = (time) => {
  return new Date(time).toLocaleDateString() + ' ' + new Date(time).toLocaleTimeString().slice(0, 5)
}

// 加载推荐座位
const loadRecommendedSeats = async () => {
  try {
    recommendationsLoading.value = true
    // 获取当前日期和时间参数，获取可用座位作为推荐
    const today = new Date().toISOString().split('T')[0]
    const currentHour = new Date().getHours()
    const startTime = `${String(Math.max(9, currentHour + 1)).padStart(2, '0')}:00`
    const endTime = `${String(Math.min(21, currentHour + 3)).padStart(2, '0')}:00`

    const response = await seatApi.getSeatLayout({
      date: today,
      startTime: startTime,
      endTime: endTime
    })

    if (response && response.code === 200) {
      // 从可用座位中筛选推荐座位（有设施的座位优先推荐）
      const availableSeats = response.data.filter(seat => seat.status === 'AVAILABLE')
      const prioritySeats = availableSeats
        .filter(seat => seat.hasPower || seat.hasComputer || seat.isQuiet)
        .slice(0, 3)

      recommendedSeats.value = prioritySeats.length > 0 ? prioritySeats : availableSeats.slice(0, 3)
    }
  } catch (error) {
    console.error('加载推荐座位失败:', error)
    // 显示默认推荐座位
    recommendedSeats.value = [
      {
        id: 1,
        seatNumber: 'A-2-015',
        floorNumber: 2,
        area: 'A',
        hasPower: true,
        hasComputer: false,
        isQuiet: true
      },
      {
        id: 2,
        seatNumber: 'B-1-023',
        floorNumber: 1,
        area: 'B',
        hasPower: true,
        hasComputer: true,
        isQuiet: false
      },
      {
        id: 3,
        seatNumber: 'C-3-008',
        floorNumber: 3,
        area: 'C',
        hasPower: false,
        hasComputer: false,
        isQuiet: true
      }
    ]
  } finally {
    recommendationsLoading.value = false
  }
}

// 加载公告数据
const loadAnnouncements = async () => {
  try {
    announcementsLoading.value = true
    const response = await getAnnouncements({ limit: 3 })

    if (response && response.code === 200) {
      announcements.value = response.data || []
    } else {
      announcements.value = []
    }
    console.log('公告数据加载成功:', announcements.value)
  } catch (error) {
    console.error('加载公告失败:', error)
    // 如果API调用失败，显示默认公告
    announcements.value = [
      {
        id: 1,
        title: '系统公告',
        content: '暂无公告信息',
        publishTime: new Date().toISOString(),
        isTop: false
      }
    ]
  } finally {
    announcementsLoading.value = false
  }
}

// 生命周期
onMounted(() => {
  // 加载推荐座位数据
  loadRecommendedSeats()

  // 加载公告数据
  loadAnnouncements()
})
</script>

<style scoped>
.home {
  min-height: 100vh;
  background: #faf8f5; /* 60% 浅米色背景 */
}

.welcome-section {
  padding: 60px 0;
  background: linear-gradient(135deg, #ff6b35 0%, #ff8f65 100%); /* 10% 橙色渐变 */
  color: white;
  margin-bottom: 0;
}

.hero-content {
  max-width: 1200px;
  margin: 0 auto;
  text-align: center;
  padding: 0 20px;
}

.hero-text h1 {
  font-size: 3rem;
  margin-bottom: 20px;
  color: white;
  font-weight: 600;
  text-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.hero-text p {
  font-size: 1.2rem;
  color: rgba(255,255,255,0.9);
  margin-bottom: 40px;
}

.quick-booking-form {
  background: rgba(255,255,255,0.95);
  padding: 40px;
  border-radius: 12px;
  margin-top: 40px;
  backdrop-filter: blur(10px);
  box-shadow: 0 20px 60px rgba(0,0,0,0.1);
}

.form-row {
  display: flex;
  gap: 20px;
  align-items: end;
  justify-content: center;
  flex-wrap: wrap;
}

.form-item {
  display: flex;
  flex-direction: column;
  min-width: 150px;
}

.form-item label {
  margin-bottom: 8px;
  font-weight: 500;
  color: #333;
}

.form-action {
  display: flex;
  align-items: end;
}

.find-seats-btn {
  height: 50px;
  padding: 0 40px;
  font-size: 16px;
  font-weight: 600;
}

.stats-section {
  padding: 60px 0;
  background: rgba(255, 107, 53, 0.03); /* 10% 橙色半透明背景 */
}

.stats-grid {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 40px;
}

.stat-item {
  text-align: center;
  padding: 40px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.08);
  transition: transform 0.3s ease;
}

.stat-item:hover {
  transform: translateY(-5px);
}

.stat-content {
  padding: 0;
}

.stat-number {
  font-size: 3rem;
  font-weight: 700;
  color: #ff6b35; /* 10% 橙色强调数字 */
  margin-bottom: 12px;
}

.stat-label {
  color: #718096; /* 30% 深灰色 */
  font-size: 16px;
  font-weight: 500;
}

.recommended-section, .announcements-section {
  padding: 60px 0;
}

.recommended-section {
  background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
}

.announcements-section {
  background: rgba(249, 250, 251, 0.8);
}

.section-header {
  max-width: 1200px;
  margin: 0 auto 40px;
  padding: 0 20px;
}

.section-header h2 {
  font-size: 2.5rem;
  font-weight: 600;
  color: #2d3748; /* 30% 深灰色 */
  text-align: center;
  margin: 0;
}

.seats-grid {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 30px;
}

.seat-card {
  background: white;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.08);
  transition: transform 0.3s ease;
}

.seat-card:hover {
  transform: translateY(-5px);
}

.seat-info {
  margin-bottom: 20px;
}

.seat-number {
  font-size: 1.5rem;
  font-weight: 700;
  color: #ff6b35; /* 10% 橙色强调 */
  margin-bottom: 12px;
}

.seat-details {
  margin-bottom: 12px;
}

.seat-details p {
  margin: 6px 0;
  color: #718096; /* 30% 深灰色 */
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.seat-features {
  margin-bottom: 20px;
}

.seat-features .el-tag {
  margin-right: 8px;
  margin-bottom: 4px;
}

.reserve-btn {
  width: 100%;
  height: 45px;
  font-size: 16px;
  font-weight: 600;
}

.announcements-list {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: grid;
  gap: 20px;
}

.announcement-item {
  background: white;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.08);
  transition: transform 0.3s ease;
}

.announcement-item:hover {
  transform: translateY(-2px);
}

.announcement-title {
  font-weight: 600;
  font-size: 1.2rem;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
  color: #2d3748; /* 30% 深灰色 */
}

.announcement-content {
  color: #718096; /* 30% 深灰色 */
  margin-bottom: 12px;
  line-height: 1.6;
  font-size: 15px;
}

.announcement-time {
  color: #9ca3af; /* 30% 浅灰色 */
  font-size: 13px;
  font-weight: 500;
}

@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    align-items: stretch;
  }
  
  .form-item {
    min-width: auto;
  }
  
  .hero-text h1 {
    font-size: 1.5rem;
  }
  
  .stat-number {
    font-size: 1.2rem;
  }
}
</style>