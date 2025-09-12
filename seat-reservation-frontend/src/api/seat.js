import request from '@/utils/request'

export const seatApi = {
  // 分页查询座位
  getSeatPage(params) {
    return request.get('/seat/page', { params })
  },

  // 获取座位类型
  getSeatTypes() {
    return request.get('/seat/types')
  },

  // 查询可用座位
  getAvailableSeats(params) {
    return request.get('/seat/available', { params })
  },

  // 获取座位布局
  getSeatLayout(params) {
    return request.get('/seat/layout', { params })
  },

  // 获取座位详情
  getSeatDetail(id) {
    return request.get(`/seat/${id}`)
  },

  // ========== 管理员接口 ==========

  // 创建座位
  createSeat(data) {
    return request.post('/seat/admin/create', data)
  },

  // 更新座位
  updateSeat(id, data) {
    return request.put(`/seat/admin/${id}`, data)
  },

  // 删除座位
  deleteSeat(id) {
    return request.delete(`/seat/admin/${id}`)
  },

  // 更新座位状态
  updateSeatStatus(id, status) {
    return request.put(`/seat/admin/${id}/status`, null, {
      params: { status }
    })
  }
}