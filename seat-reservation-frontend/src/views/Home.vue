<template>
  <Layout>
    <div class="apple-home">
      <!-- Hero Section -->
      <section class="apple-hero">
        <div class="apple-hero-content">
          <div class="apple-hero-text apple-animate-fade-in">
            <h1 class="apple-hero-title">找到完美学习空间</h1>
            <p class="apple-hero-subtitle">智能预约系统，让每一次学习都有最佳座位</p>
          </div>

          <!-- Quick Booking Card -->
          <div class="apple-booking-card apple-animate-slide-up">
            <div class="apple-booking-header">
              <div class="apple-booking-icon">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                  <rect x="3" y="4" width="18" height="18" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                  <line x1="16" y1="2" x2="16" y2="6" stroke="currentColor" stroke-width="2"/>
                  <line x1="8" y1="2" x2="8" y2="6" stroke="currentColor" stroke-width="2"/>
                  <line x1="3" y1="10" x2="21" y2="10" stroke="currentColor" stroke-width="2"/>
                </svg>
              </div>
              <div class="apple-booking-title">
                <h3>快速预约</h3>
                <p>选择时间，即刻开始</p>
              </div>
            </div>

            <div class="apple-booking-form">
              <div class="apple-form-row">
                <div class="apple-input-group" :class="{ 'apple-input-error': formErrors.date }">
                  <label class="apple-input-label">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                      <rect x="3" y="4" width="18" height="18" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                      <line x1="16" y1="2" x2="16" y2="6" stroke="currentColor" stroke-width="2"/>
                      <line x1="8" y1="2" x2="8" y2="6" stroke="currentColor" stroke-width="2"/>
                      <line x1="3" y1="10" x2="21" y2="10" stroke="currentColor" stroke-width="2"/>
                    </svg>
                    选择日期
                  </label>
                  <el-date-picker
                    v-model="quickBooking.date"
                    type="date"
                    placeholder="选择您的预约日期"
                    format="YYYY-MM-DD"
                    value-format="YYYY-MM-DD"
                    size="large"
                    class="apple-input"
                    @change="validateField('date')"
                  />
                  <span v-if="formErrors.date" class="apple-input-error-message">{{ formErrors.date }}</span>
                </div>

                <div class="apple-input-group" :class="{ 'apple-input-error': formErrors.startTime }">
                  <label class="apple-input-label">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                      <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
                      <polyline points="12,6 12,12 16,14" stroke="currentColor" stroke-width="2"/>
                    </svg>
                    开始时间
                  </label>
                  <el-time-picker
                    v-model="quickBooking.startTime"
                    format="HH:mm"
                    placeholder="选择开始时间"
                    size="large"
                    class="apple-input"
                    @change="validateField('startTime')"
                  />
                  <span v-if="formErrors.startTime" class="apple-input-error-message">{{ formErrors.startTime }}</span>
                </div>

              </div>

              <div class="apple-form-row">
                <div class="apple-input-group" :class="{ 'apple-input-error': formErrors.duration }">
                  <label class="apple-input-label">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                      <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
                      <polyline points="12,6 12,12 16,14" stroke="currentColor" stroke-width="2"/>
                    </svg>
                    使用时长
                  </label>
                  <el-select
                    v-model="quickBooking.duration"
                    placeholder="选择使用时长"
                    size="large"
                    class="apple-input apple-select"
                    @change="validateField('duration')"
                  >
                    <el-option label="1小时" :value="1" />
                    <el-option label="2小时" :value="2" />
                    <el-option label="3小时" :value="3" />
                    <el-option label="4小时" :value="4" />
                    <el-option label="半天(6小时)" :value="6" />
                    <el-option label="全天(8小时)" :value="8" />
                  </el-select>
                  <span v-if="formErrors.duration" class="apple-input-error-message">{{ formErrors.duration }}</span>
                </div>

              </div>

              <div class="apple-booking-action">
                <button
                  class="apple-button apple-button-primary apple-button-large"
                  @click="findAvailableSeats"
                  :disabled="!isFormValid || searchLoading"
                >
                  <template v-if="!searchLoading">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                      <circle cx="11" cy="11" r="8" stroke="currentColor" stroke-width="2"/>
                      <path d="m21 21-4.35-4.35" stroke="currentColor" stroke-width="2"/>
                    </svg>
                    查找可用座位
                  </template>
                  <template v-else>
                    <div class="apple-spinner"></div>
                    正在搜索...
                  </template>
                </button>
                <p class="apple-booking-hint">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
                    <path d="12 16v-4" stroke="currentColor" stroke-width="2"/>
                    <path d="12 8h.01" stroke="currentColor" stroke-width="2"/>
                  </svg>
                  系统将智能推荐最适合的座位
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Statistics Section -->
      <section class="apple-stats-section">
        <div class="apple-stats-grid">
          <div class="apple-stat-card apple-animate-slide-up">
            <div class="apple-stat-icon apple-stat-icon-blue">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" stroke="currentColor" stroke-width="2" fill="none"/>
                <polyline points="9,22 9,12 15,12 15,22" stroke="currentColor" stroke-width="2"/>
              </svg>
            </div>
            <div class="apple-stat-content">
              <div class="apple-stat-number">{{ stats.totalSeats }}</div>
              <div class="apple-stat-label">总座位数</div>
            </div>
          </div>

          <div class="apple-stat-card apple-animate-slide-up" style="animation-delay: 0.1s">
            <div class="apple-stat-icon apple-stat-icon-green">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" stroke="currentColor" stroke-width="2" fill="none"/>
                <polyline points="22,4 12,14.01 9,11.01" stroke="currentColor" stroke-width="2"/>
              </svg>
            </div>
            <div class="apple-stat-content">
              <div class="apple-stat-number">{{ stats.availableSeats }}</div>
              <div class="apple-stat-label">可用座位</div>
            </div>
          </div>

          <div class="apple-stat-card apple-animate-slide-up" style="animation-delay: 0.2s">
            <div class="apple-stat-icon apple-stat-icon-orange">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <path d="M9 11H5a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7a2 2 0 0 0-2-2h-4" stroke="currentColor" stroke-width="2" fill="none"/>
                <rect x="9" y="7" width="6" height="6" rx="1" stroke="currentColor" stroke-width="2" fill="none"/>
              </svg>
            </div>
            <div class="apple-stat-content">
              <div class="apple-stat-number">{{ stats.myReservations }}</div>
              <div class="apple-stat-label">我的预约</div>
            </div>
          </div>
          
          <div class="apple-stat-card apple-usage-card apple-animate-slide-up" style="animation-delay: 0.3s">
            <div class="apple-usage-chart">
              <div class="apple-circular-progress">
                <svg width="100" height="100" viewBox="0 0 100 100">
                  <circle
                    cx="50" cy="50" r="45"
                    stroke="var(--apple-gray5)"
                    stroke-width="6"
                    fill="none"
                  />
                  <circle
                    cx="50" cy="50" r="45"
                    stroke="url(#appleGradient)"
                    stroke-width="6"
                    fill="none"
                    stroke-linecap="round"
                    :stroke-dasharray="circumference"
                    :stroke-dashoffset="dashOffset"
                    transform="rotate(-90 50 50)"
                    class="apple-progress-ring"
                  />
                  <defs>
                    <linearGradient id="appleGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" :stop-color="getUsageColor(occupancyRate).start" />
                      <stop offset="100%" :stop-color="getUsageColor(occupancyRate).end" />
                    </linearGradient>
                  </defs>
                </svg>
                <div class="apple-progress-center">
                  <div class="apple-progress-value">{{ occupancyRate }}%</div>
                  <div class="apple-progress-label">使用率</div>
                </div>
              </div>
            </div>
            <div class="apple-usage-details">
              <div class="apple-usage-item">
                <div class="apple-usage-dot" style="background: var(--apple-red)"></div>
                <span>已占用 {{ stats.totalSeats - stats.availableSeats }}</span>
              </div>
              <div class="apple-usage-item">
                <div class="apple-usage-dot" style="background: var(--apple-green)"></div>
                <span>可用 {{ stats.availableSeats }}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Recommended Seats -->
      <section class="apple-recommendations-section" v-loading="recommendationsLoading">
        <div class="apple-section-header">
          <h2 class="apple-section-title">精选推荐</h2>
          <p class="apple-section-subtitle">根据您的使用习惯智能推荐</p>
        </div>
        
        <div class="apple-recommendations-grid">
          <div
            class="apple-seat-card"
            v-for="(seat, index) in recommendedSeats"
            :key="seat.id"
            :class="{ 'apple-seat-featured': index === 0 }"
            @mouseenter="hoveringSeat = seat.id"
            @mouseleave="hoveringSeat = null"
          >
            <div class="apple-seat-header">
              <div class="apple-seat-badge" :class="getRankClass(index)">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                  <polygon points="12,2 15.09,8.26 22,9.27 17,14.14 18.18,21.02 12,17.77 5.82,21.02 7,14.14 2,9.27 8.91,8.26" stroke="currentColor" stroke-width="2" fill="currentColor"/>
                </svg>
                <span>{{ getRankText(index) }}</span>
              </div>
              <div class="apple-seat-status">
                <div class="apple-status-dot"></div>
                <span>可预约</span>
              </div>
            </div>

            <div class="apple-seat-content">
              <div class="apple-seat-title">
                <h3>{{ seat.seatNumber }}</h3>
                <span class="apple-seat-location">{{ seat.floorNumber }}层 {{ seat.area }}区</span>
              </div>

              <div class="apple-seat-features">
                <div class="apple-feature-tag" v-if="seat.hasPower">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                    <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" stroke="currentColor" stroke-width="2" fill="currentColor"/>
                  </svg>
                  电源
                </div>
                <div class="apple-feature-tag" v-if="seat.hasComputer">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                    <rect x="2" y="3" width="20" height="14" rx="2" ry="2" stroke="currentColor" stroke-width="2" fill="none"/>
                    <line x1="8" y1="21" x2="16" y2="21" stroke="currentColor" stroke-width="2"/>
                    <line x1="12" y1="17" x2="12" y2="21" stroke="currentColor" stroke-width="2"/>
                  </svg>
                  电脑
                </div>
                <div class="apple-feature-tag" v-if="seat.isQuiet">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                    <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z" stroke="currentColor" stroke-width="2" fill="none"/>
                  </svg>
                  安静
                </div>
                <div class="apple-feature-tag">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                    <path d="M5 12.55a11 11 0 0 1 14.08 0" stroke="currentColor" stroke-width="2" fill="none"/>
                    <path d="M1.42 9a16 16 0 0 1 21.16 0" stroke="currentColor" stroke-width="2" fill="none"/>
                    <path d="M8.53 16.11a6 6 0 0 1 6.95 0" stroke="currentColor" stroke-width="2" fill="none"/>
                    <line x1="12" y1="20" x2="12.01" y2="20" stroke="currentColor" stroke-width="2"/>
                  </svg>
                  WiFi
                </div>
              </div>
            </div>

            <div class="apple-seat-actions">
              <button
                class="apple-button apple-button-primary"
                @click="quickReserve(seat)"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                  <polyline points="20,6 9,17 4,12" stroke="currentColor" stroke-width="2"/>
                </svg>
                立即预约
              </button>
              <button
                class="apple-button apple-button-secondary"
                @click="addToFavorites(seat)"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                  <polygon points="12,2 15.09,8.26 22,9.27 17,14.14 18.18,21.02 12,17.77 5.82,21.02 7,14.14 2,9.27 8.91,8.26" stroke="currentColor" stroke-width="2"/>
                </svg>
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- Announcements -->
      <section class="apple-announcements-section" v-loading="announcementsLoading">
        <div class="apple-section-header">
          <div class="apple-header-content">
            <div class="apple-header-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9" stroke="currentColor" stroke-width="2" fill="none"/>
                <path d="M13.73 21a2 2 0 0 1-3.46 0" stroke="currentColor" stroke-width="2"/>
              </svg>
            </div>
            <div class="apple-header-text">
              <h2 class="apple-section-title">系统公告</h2>
              <p class="apple-section-subtitle">重要通知和更新信息</p>
            </div>
            <button class="apple-button apple-button-ghost apple-button-small" @click="viewAllAnnouncements">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                <circle cx="12" cy="12" r="1" stroke="currentColor" stroke-width="2"/>
                <circle cx="19" cy="12" r="1" stroke="currentColor" stroke-width="2"/>
                <circle cx="5" cy="12" r="1" stroke="currentColor" stroke-width="2"/>
              </svg>
              查看全部
            </button>
          </div>
        </div>

        <div class="apple-announcements-container">
          <div class="apple-announcements-list">
            <div
              v-for="(announcement, index) in announcements.slice(0, 3)"
              :key="announcement.id"
              class="apple-announcement-card"
              :class="{
                'apple-announcement-top': announcement.isTop,
                'apple-announcement-urgent': announcement.isUrgent
              }"
              @click="viewAnnouncement(announcement)"
            >
              <div class="apple-announcement-header">
                <div class="apple-announcement-badges">
                  <span v-if="announcement.isTop" class="apple-tag apple-tag-red">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                      <path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z" stroke="currentColor" stroke-width="2" fill="currentColor"/>
                    </svg>
                    置顶
                  </span>
                  <span v-if="announcement.isUrgent" class="apple-tag apple-tag-orange">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                      <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" stroke="currentColor" stroke-width="2" fill="none"/>
                      <line x1="12" y1="9" x2="12" y2="13" stroke="currentColor" stroke-width="2"/>
                      <line x1="12" y1="17" x2="12.01" y2="17" stroke="currentColor" stroke-width="2"/>
                    </svg>
                    紧急
                  </span>
                  <span class="apple-tag apple-tag-blue">{{ getAnnouncementCategory(announcement) }}</span>
                </div>
                <span class="apple-announcement-time">{{ formatTime(announcement.publishTime || announcement.createTime) }}</span>
              </div>

              <div class="apple-announcement-content">
                <h3 class="apple-announcement-title">{{ announcement.title }}</h3>
                <p class="apple-announcement-text">{{ announcement.content }}</p>
              </div>

              <div class="apple-announcement-footer">
                <div class="apple-announcement-stats">
                  <span class="apple-stat">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="currentColor" stroke-width="2" fill="none"/>
                      <circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="2" fill="none"/>
                    </svg>
                    {{ Math.floor(Math.random() * 500) + 100 }}
                  </span>
                  <span class="apple-stat">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                      <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="currentColor" stroke-width="2" fill="none"/>
                      <circle cx="12" cy="7" r="4" stroke="currentColor" stroke-width="2" fill="none"/>
                    </svg>
                    管理员
                  </span>
                </div>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" class="apple-announcement-arrow">
                  <line x1="5" y1="12" x2="19" y2="12" stroke="currentColor" stroke-width="2"/>
                  <polyline points="12,5 19,12 12,19" stroke="currentColor" stroke-width="2"/>
                </svg>
              </div>
            </div>
          </div>

          <!-- Empty State -->
          <div v-if="announcements.length === 0" class="apple-empty-announcements">
            <div class="apple-empty-icon">
              <svg width="48" height="48" viewBox="0 0 24 24" fill="none">
                <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9" stroke="currentColor" stroke-width="2" fill="none"/>
                <path d="M13.73 21a2 2 0 0 1-3.46 0" stroke="currentColor" stroke-width="2"/>
              </svg>
            </div>
            <h3>暂无公告</h3>
            <p>目前没有新的系统公告</p>
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
import EmptyState from '@/components/EmptyState.vue'
import { getAnnouncements } from '@/api/announcement'
import { seatApi } from '@/api/seat'

const router = useRouter()

// 响应式数据
const quickBooking = ref({
  date: new Date().toISOString().split('T')[0],
  startTime: '',
  duration: 2
})

const searchLoading = ref(false)
const formErrors = ref({})

const stats = ref({
  totalSeats: 120,
  availableSeats: 85,
  myReservations: 3
})

const recommendedSeats = ref([])

const announcements = ref([])

const recommendationsLoading = ref(false)
const announcementsLoading = ref(false)
const hoveringSeat = ref(null)

// 计算属性
const occupancyRate = computed(() => {
  if (stats.value.totalSeats === 0) return 0
  return Math.round((1 - stats.value.availableSeats / stats.value.totalSeats) * 100)
})

const circumference = computed(() => 2 * Math.PI * 45)
const dashOffset = computed(() => {
  const progress = occupancyRate.value / 100
  return circumference.value * (1 - progress)
})

// 计算属性
const isFormValid = computed(() => {
  return quickBooking.value.date &&
         quickBooking.value.startTime &&
         quickBooking.value.duration &&
         Object.keys(formErrors.value).length === 0
})

// 方法
const validateField = (field) => {
  formErrors.value = { ...formErrors.value }

  switch(field) {
    case 'date':
      if (!quickBooking.value.date) {
        formErrors.value.date = '请选择预约日期'
      } else {
        delete formErrors.value.date
      }
      break
    case 'startTime':
      if (!quickBooking.value.startTime) {
        formErrors.value.startTime = '请选择开始时间'
      } else {
        delete formErrors.value.startTime
      }
      break
    case 'duration':
      if (!quickBooking.value.duration) {
        formErrors.value.duration = '请选择使用时长'
      } else {
        delete formErrors.value.duration
      }
      break
  }
}

const findAvailableSeats = async () => {
  // 验证表单
  validateField('date')
  validateField('startTime')
  validateField('duration')

  if (!isFormValid.value) {
    ElMessage.warning('请完善表单信息')
    return
  }

  searchLoading.value = true

  try {
    // 模拟搜索延迟
    await new Promise(resolve => setTimeout(resolve, 800))

    ElMessage.success('搜索完成，正在跳转到座位地图')

    router.push({
      path: '/seat-map',
      query: {
        date: quickBooking.value.date,
        startTime: quickBooking.value.startTime,
        duration: quickBooking.value.duration
      }
    })
  } catch (error) {
    ElMessage.error('搜索失败，请重试')
  } finally {
    searchLoading.value = false
  }
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

const addToFavorites = (seat) => {
  ElMessage.success(`已将座位 ${seat.seatNumber} 添加到收藏`)
}

const getRankClass = (index) => {
  switch(index) {
    case 0: return 'gold'
    case 1: return 'silver'
    case 2: return 'bronze'
    default: return 'normal'
  }
}

const getRankIcon = (index) => {
  switch(index) {
    case 0: return 'el-icon-trophy'
    case 1: return 'el-icon-medal'
    case 2: return 'el-icon-star-on'
    default: return 'el-icon-check'
  }
}

const getRankText = (index) => {
  switch(index) {
    case 0: return '最佳推荐'
    case 1: return '热门选择'
    case 2: return '优质座位'
    default: return '推荐'
  }
}

const getSeatRating = (seat) => {
  // 根据座位特性计算评分
  let rating = 3
  if (seat.hasPower) rating += 0.5
  if (seat.hasComputer) rating += 0.5
  if (seat.isQuiet) rating += 1
  return Math.min(5, Math.floor(rating))
}

const formatTime = (time) => {
  return new Date(time).toLocaleDateString() + ' ' + new Date(time).toLocaleTimeString().slice(0, 5)
}

const getUsageColor = (rate) => {
  if (rate >= 80) {
    return { start: '#ef4444', end: '#dc2626' } // 红色 - 高使用率
  } else if (rate >= 60) {
    return { start: '#f59e0b', end: '#d97706' } // 橙色 - 中等使用率
  } else if (rate >= 40) {
    return { start: '#10b981', end: '#059669' } // 绿色 - 低使用率
  } else {
    return { start: '#3b82f6', end: '#2563eb' } // 蓝色 - 很低使用率
  }
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
        title: '系统维护通知',
        content: '系统将于今晚23:00-24:00进行例行维护，期间可能影响部分功能使用，请您合理安排时间，感谢理解。',
        publishTime: new Date().toISOString(),
        isTop: true,
        isUrgent: false
      },
      {
        id: 2,
        title: '新增座位预约功能',
        content: '系统新增了多人協作座位预约功能，现在您可以与同学一起预约相邻座位，提高学习效率。详情请查看使用指南。',
        publishTime: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
        isTop: false,
        isUrgent: false
      },
      {
        id: 3,
        title: '学习空间使用规则',
        content: '为了维护良好的学习环境，请各位同学遵守学习空间使用规则，包括保持安静、爱护设施、及时清理垃圾等。',
        publishTime: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
        isTop: false,
        isUrgent: false
      }
    ]
  } finally {
    announcementsLoading.value = false
  }
}

const viewAllAnnouncements = () => {
  router.push('/announcements')
}

const viewAnnouncement = (announcement) => {
  ElMessage.info(`正在查看公告: ${announcement.title}`)
}

const getAnnouncementType = (announcement) => {
  if (announcement.isUrgent) return 'urgent'
  if (announcement.isTop) return 'top'
  return 'normal'
}

const getAnnouncementTagType = (announcement) => {
  if (announcement.isUrgent) return 'danger'
  if (announcement.isTop) return 'warning'
  return 'info'
}

const getAnnouncementCategory = (announcement) => {
  if (announcement.title.includes('系统')) return '系统通知'
  if (announcement.title.includes('维护')) return '维护公告'
  if (announcement.title.includes('功能')) return '功能更新'
  if (announcement.title.includes('规则')) return '使用规则'
  return '一般公告'
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
.apple-home {
  min-height: 100vh;
  background: var(--color-background-secondary);
  font-family: var(--apple-font-family);
}

.apple-hero {
  padding: 60px 0 80px;
  background: var(--color-primary);
  color: white;
  position: relative;
  overflow: hidden;
}

.apple-hero::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.1);
  pointer-events: none;
}


.apple-hero-content {
  max-width: 1200px;
  margin: 0 auto;
  text-align: center;
  padding: 0 var(--apple-space-6);
  position: relative;
  z-index: 2;
}

.apple-hero-title {
  font-size: var(--apple-text-5xl);
  font-weight: var(--apple-weight-bold);
  margin-bottom: var(--apple-space-4);
  color: white;
  text-shadow: 0 4px 12px rgba(0,0,0,0.3);
  line-height: var(--apple-leading-tight);
  letter-spacing: -0.02em;
}

.apple-hero-subtitle {
  font-size: var(--apple-text-xl);
  color: rgba(255,255,255,0.9);
  margin-bottom: var(--apple-space-12);
  font-weight: var(--apple-weight-normal);
  line-height: var(--apple-leading-relaxed);
}

.apple-booking-card {
  background: var(--color-background-primary);
  padding: var(--apple-space-8);
  border-radius: var(--apple-radius-xl);
  border: 1px solid var(--color-border);
  box-shadow: var(--shadow-lg);
  transition: all var(--apple-transition-normal);
  position: relative;
  overflow: hidden;
  max-width: 600px;
  margin: 0 auto;
}

.apple-booking-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: var(--color-primary);
}

.apple-booking-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-xl);
}


.apple-booking-header {
  display: flex;
  align-items: center;
  gap: var(--apple-space-4);
  margin-bottom: var(--apple-space-8);
  padding-bottom: var(--apple-space-6);
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

.apple-booking-icon {
  width: 48px;
  height: 48px;
  background: var(--apple-gradient-blue);
  border-radius: var(--apple-radius-medium);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  box-shadow: var(--apple-shadow-medium);
  flex-shrink: 0;
}


.apple-booking-title h3 {
  font-size: var(--apple-text-xl);
  font-weight: var(--apple-weight-semibold);
  color: var(--apple-label);
  margin: 0 0 var(--apple-space-1) 0;
}

.apple-booking-title p {
  color: var(--apple-secondary-label);
  font-size: var(--apple-text-sm);
  margin: 0;
}

.apple-booking-form {
  display: flex;
  flex-direction: column;
  gap: var(--apple-space-6);
}

.apple-form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--apple-space-4);
}













.apple-booking-action {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--apple-space-3);
}








.apple-booking-hint {
  font-size: var(--apple-text-sm);
  color: var(--apple-tertiary-label);
  display: flex;
  align-items: center;
  gap: var(--apple-space-2);
  justify-content: center;
}


/* Statistics Section */
.apple-stats-section {
  padding: var(--apple-space-20) 0;
  background: var(--color-background-primary);
}

.apple-stats-grid {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 var(--apple-space-6);
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: var(--apple-space-6);
}




.apple-stat-card {
  background: var(--apple-card-bg);
  border: 1px solid var(--apple-card-border);
  border-radius: var(--apple-radius-large);
  padding: var(--apple-space-6);
  box-shadow: var(--apple-shadow-medium);
  transition: all var(--apple-transition-normal);
  display: flex;
  align-items: center;
  gap: var(--apple-space-4);
}



.apple-stat-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--apple-shadow-large);
}

.apple-stat-icon {
  width: 48px;
  height: 48px;
  border-radius: var(--apple-radius-medium);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.apple-stat-icon-blue {
  background: var(--apple-gradient-blue);
}

.apple-stat-icon-green {
  background: var(--apple-gradient-green);
}

.apple-stat-icon-orange {
  background: var(--apple-gradient-orange);
}

.apple-stat-content {
  flex: 1;
}

.apple-stat-number {
  font-size: var(--apple-text-3xl);
  font-weight: var(--apple-weight-bold);
  color: var(--apple-label);
  margin-bottom: var(--apple-space-1);
  line-height: 1;
}

.apple-stat-label {
  color: var(--apple-secondary-label);
  font-size: var(--apple-text-sm);
  font-weight: var(--apple-weight-medium);
}


/* Usage Card */
.apple-usage-card {
  flex-direction: column;
  gap: var(--apple-space-4);
  text-align: center;
}


.apple-usage-chart {
  display: flex;
  justify-content: center;
}

.apple-circular-progress {
  position: relative;
}

.apple-progress-ring {
  transition: stroke-dashoffset 1.5s cubic-bezier(0.4, 0, 0.2, 1);
}


.apple-progress-center {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
}

.apple-progress-value {
  font-size: var(--apple-text-lg);
  font-weight: var(--apple-weight-bold);
  color: var(--apple-label);
  line-height: 1;
}

.apple-progress-label {
  font-size: var(--apple-text-xs);
  color: var(--apple-secondary-label);
  font-weight: var(--apple-weight-medium);
}

.apple-usage-details {
  display: flex;
  flex-direction: column;
  gap: var(--apple-space-2);
}


.apple-usage-item {
  display: flex;
  align-items: center;
  gap: var(--apple-space-2);
  font-size: var(--apple-text-sm);
  color: var(--apple-secondary-label);
  justify-content: center;
}

.apple-usage-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}






/* Recommendations Section */
.apple-recommendations-section {
  padding: var(--apple-space-20) 0;
  background: var(--apple-system-grouped-background);
}



/* Announcements Section */
.apple-announcements-section {
  padding: var(--apple-space-20) 0;
  background: var(--apple-secondary-system-grouped-background);
}


.apple-section-header {
  text-align: center;
  margin-bottom: var(--apple-space-12);
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.apple-section-title {
  font-size: var(--apple-text-3xl);
  font-weight: var(--apple-weight-bold);
  color: var(--apple-label);
  margin: 0 0 var(--apple-space-2) 0;
  letter-spacing: -0.02em;
}

.apple-section-subtitle {
  font-size: var(--apple-text-base);
  color: var(--apple-secondary-label);
  margin: 0;
  line-height: var(--apple-leading-relaxed);
}

.apple-recommendations-grid {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 var(--apple-space-6);
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: var(--apple-space-6);
}

.apple-seat-card {
  background: var(--apple-card-bg);
  border: 1px solid var(--apple-card-border);
  border-radius: var(--apple-radius-large);
  padding: var(--apple-space-6);
  box-shadow: var(--apple-shadow-medium);
  transition: all var(--apple-transition-normal);
  position: relative;
  overflow: hidden;
}

.apple-seat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: var(--apple-gradient-blue);
}


.apple-seat-card:hover {
  transform: translateY(-6px);
  box-shadow: var(--apple-shadow-large);
  border-color: var(--apple-blue);
}













.apple-seat-featured {
  border: 2px solid var(--apple-blue);
  transform: scale(1.02);
  box-shadow: var(--apple-shadow-large), 0 0 0 4px rgba(0, 122, 255, 0.1);
}

.apple-seat-featured::before {
  background: var(--apple-gradient-blue);
  height: 4px;
}

.apple-seat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--apple-space-4);
}


.apple-seat-badge {
  display: inline-flex;
  align-items: center;
  gap: var(--apple-space-1);
  padding: var(--apple-space-1) var(--apple-space-2);
  border-radius: var(--apple-radius-small);
  font-size: var(--apple-text-xs);
  font-weight: var(--apple-weight-medium);
  color: white;
}

.apple-seat-badge.gold {
  background: var(--apple-gradient-orange);
}

.apple-seat-badge.silver {
  background: var(--apple-gray);
}

.apple-seat-badge.bronze {
  background: var(--apple-purple);
}

.apple-seat-badge.normal {
  background: var(--apple-gradient-blue);
}

.apple-seat-status {
  display: flex;
  align-items: center;
  gap: var(--apple-space-1);
  font-size: var(--apple-text-xs);
  color: var(--apple-green);
  font-weight: var(--apple-weight-medium);
}

.apple-status-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--apple-green);
  animation: apple-pulse 2s infinite;
}

@keyframes apple-pulse {
  0%, 100% {
    box-shadow: 0 0 0 2px rgba(52, 199, 89, 0.2);
  }
  50% {
    box-shadow: 0 0 0 6px rgba(52, 199, 89, 0);
  }
}
















.apple-seat-content {
  margin-bottom: var(--apple-space-4);
}

.apple-seat-title h3 {
  font-size: var(--apple-text-lg);
  font-weight: var(--apple-weight-semibold);
  color: var(--apple-label);
  margin: 0 0 var(--apple-space-1) 0;
}

.apple-seat-location {
  font-size: var(--apple-text-sm);
  color: var(--apple-secondary-label);
}

.apple-seat-features {
  display: flex;
  flex-wrap: wrap;
  gap: var(--apple-space-2);
  margin-top: var(--apple-space-3);
}

.apple-feature-tag {
  display: inline-flex;
  align-items: center;
  gap: var(--apple-space-1);
  padding: var(--apple-space-1) var(--apple-space-2);
  background: var(--apple-gray6);
  color: var(--apple-secondary-label);
  border-radius: var(--apple-radius-small);
  font-size: var(--apple-text-xs);
  font-weight: var(--apple-weight-medium);
}

.apple-seat-actions {
  display: flex;
  gap: var(--apple-space-2);
  margin-top: var(--apple-space-4);
}

.apple-seat-actions .apple-button:first-child {
  flex: 1;
}











/* Announcements */
.apple-header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 var(--apple-space-6);
}

.apple-header-icon {
  width: 48px;
  height: 48px;
  background: var(--apple-gradient-orange);
  border-radius: var(--apple-radius-medium);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  margin-right: var(--apple-space-4);
}

.apple-header-text {
  flex: 1;
}

.apple-announcements-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 var(--apple-space-6);
}

.apple-announcements-list {
  display: flex;
  flex-direction: column;
  gap: var(--apple-space-4);
}

.apple-announcement-card {
  background: var(--apple-card-bg);
  border: 1px solid var(--apple-card-border);
  border-radius: var(--apple-radius-large);
  padding: var(--apple-space-5);
  box-shadow: var(--apple-shadow-medium);
  transition: all var(--apple-transition-normal);
  cursor: pointer;
}

.apple-announcement-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--apple-shadow-large);
  border-color: var(--apple-orange);
}

.apple-announcement-top {
  border-left: 4px solid var(--apple-red);
}

.apple-announcement-urgent {
  border-left: 4px solid var(--apple-orange);
}

.apple-announcement-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: var(--apple-space-3);
}

.apple-announcement-badges {
  display: flex;
  gap: var(--apple-space-2);
  flex-wrap: wrap;
}

.apple-announcement-time {
  font-size: var(--apple-text-sm);
  color: var(--apple-tertiary-label);
  flex-shrink: 0;
}

.apple-announcement-content {
  margin-bottom: var(--apple-space-4);
}

.apple-announcement-title {
  font-size: var(--apple-text-lg);
  font-weight: var(--apple-weight-semibold);
  color: var(--apple-label);
  margin: 0 0 var(--apple-space-2) 0;
  line-height: var(--apple-leading-tight);
}

.apple-announcement-text {
  font-size: var(--apple-text-base);
  color: var(--apple-secondary-label);
  line-height: var(--apple-leading-relaxed);
  margin: 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.apple-announcement-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.apple-announcement-stats {
  display: flex;
  gap: var(--apple-space-4);
}

.apple-stat {
  display: flex;
  align-items: center;
  gap: var(--apple-space-1);
  font-size: var(--apple-text-sm);
  color: var(--apple-tertiary-label);
}

.apple-announcement-arrow {
  color: var(--apple-blue);
  transition: transform var(--apple-transition-fast);
}

.apple-announcement-card:hover .apple-announcement-arrow {
  transform: translateX(4px);
}

.apple-empty-announcements {
  text-align: center;
  padding: var(--apple-space-16) var(--apple-space-4);
}

.apple-empty-icon {
  margin: 0 auto var(--apple-space-4);
  color: var(--apple-tertiary-label);
  opacity: 0.5;
}

.apple-empty-announcements h3 {
  font-size: var(--apple-text-xl);
  font-weight: var(--apple-weight-semibold);
  color: var(--apple-secondary-label);
  margin: 0 0 var(--apple-space-2) 0;
}

.apple-empty-announcements p {
  color: var(--apple-tertiary-label);
  margin: 0;
}

/* Responsive Design */
@media (max-width: 1024px) {
  .apple-recommendations-grid {
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: var(--apple-space-5);
  }

  .apple-stats-grid {
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: var(--apple-space-4);
  }
}

@media (max-width: 768px) {
  .apple-hero {
    padding: 60px 0 80px;
  }

  .apple-hero-title {
    font-size: var(--apple-text-4xl);
  }

  .apple-hero-subtitle {
    font-size: var(--apple-text-lg);
  }

  .apple-booking-card {
    padding: var(--apple-space-6);
    margin: 0 var(--apple-space-4);
  }

  .apple-booking-header {
    flex-direction: column;
    text-align: center;
    gap: var(--apple-space-3);
  }

  .apple-form-row {
    grid-template-columns: 1fr;
    gap: var(--apple-space-4);
  }

  .apple-stats-grid {
    grid-template-columns: 1fr 1fr;
    gap: var(--apple-space-3);
  }

  .apple-usage-card {
    grid-column: 1 / -1;
  }

  .apple-recommendations-grid {
    grid-template-columns: 1fr;
    gap: var(--apple-space-4);
  }

  .apple-seat-featured {
    transform: none;
  }

  .apple-header-content {
    flex-direction: column;
    gap: var(--apple-space-4);
    text-align: center;
  }

  .apple-section-header {
    margin-bottom: var(--apple-space-8);
  }
}

@media (max-width: 480px) {
  .apple-hero {
    padding: 40px 0 60px;
  }

  .apple-hero-content {
    padding: 0 var(--apple-space-4);
  }

  .apple-hero-title {
    font-size: var(--apple-text-3xl);
  }

  .apple-booking-card {
    padding: var(--apple-space-5);
    margin: 0 var(--apple-space-3);
  }

  .apple-stats-grid {
    grid-template-columns: 1fr;
    gap: var(--apple-space-3);
  }

  .apple-seat-card {
    padding: var(--apple-space-4);
  }

  .apple-announcement-header {
    flex-direction: column;
    gap: var(--apple-space-2);
  }

  .apple-header-content {
    padding: 0 var(--apple-space-4);
  }

  .apple-announcements-container {
    padding: 0 var(--apple-space-4);
  }
}




























































</style>