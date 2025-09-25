import request from '@/utils/request'

export const reservationApi = {
  // 创建预约
  createReservation(data) {
    return request.post('/reservation/create', data)
  },

  // 取消预约
  cancelReservation(id) {
    return request.post(`/reservation/cancel/${id}`)
  },

  // 签到
  checkIn(id) {
    return request.post(`/reservation/check-in/${id}`)
  },

  // 签退
  checkOut(id) {
    return request.post(`/reservation/check-out/${id}`)
  },

  // 获取用户预约列表
  getUserReservations(params) {
    return request.get('/reservation/my', { params })
  },

  // 获取预约详情
  getReservationDetail(id) {
    return request.get(`/reservation/${id}`)
  },

  // ========== 管理员接口 ==========

  // 管理员获取所有预约列表
  getAdminReservations(params) {
    return request.get('/reservation/admin/list', { params })
  },

  // 管理员获取预约详情
  getAdminReservationDetail(id) {
    return request.get(`/reservation/admin/${id}`)
  },

  // 管理员创建预约
  createReservationByAdmin(data) {
    return request.post('/reservation/admin/create', data)
  },

  // 管理员更新预约
  updateReservationByAdmin(id, data) {
    return request.put(`/reservation/admin/${id}`, data)
  },

  // 管理员取消预约
  cancelReservationByAdmin(id) {
    return request.post(`/reservation/admin/cancel/${id}`)
  }
}