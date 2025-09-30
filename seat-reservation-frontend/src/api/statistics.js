import request from '@/utils/request'

export const statisticsApi = {
  // 获取数据看板统计信息
  getDashboardStats() {
    return request.get('/statistics/admin/dashboard')
  },

  // 获取预约趋势数据
  getReservationTrend(days = 7) {
    return request.get('/statistics/admin/reservation-trend', { params: { days } })
  },

  // 获取座位使用率统计
  getSeatUsageStats() {
    return request.get('/statistics/admin/seat-usage')
  },

  // 获取使用率热图数据
  getUsageHeatmap(days = 7) {
    return request.get('/statistics/admin/heatmap', { params: { days } })
  },

  // 获取用户活跃度统计
  getUserActivityStats() {
    return request.get('/statistics/admin/user-activity')
  },

  // 获取收入统计
  getRevenueStats(days = 30) {
    return request.get('/statistics/admin/revenue', { params: { days } })
  },

  // 获取热门时段统计
  getPeakHoursStats() {
    return request.get('/statistics/admin/peak-hours')
  },

  // 获取综合报表数据
  getComprehensiveReport(days = 30) {
    return request.get('/statistics/admin/comprehensive-report', { params: { days } })
  },

  // 获取座位类型分布
  getSeatTypeDistribution() {
    return request.get('/statistics/admin/seat-types')
  },

  // 获取最近预约记录
  getRecentReservations(limit = 10) {
    return request.get('/statistics/admin/recent-reservations', { params: { limit } })
  },

  // 获取座位使用排行
  getTopSeats(limit = 10) {
    return request.get('/statistics/admin/top-seats', { params: { limit } })
  },

  // 获取时段预约分析
  getHourlyReservations(date) {
    return request.get('/statistics/admin/hourly-reservations', { params: { date } })
  }
}