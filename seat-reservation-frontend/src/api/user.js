import request from '@/utils/request'

export const userApi = {
  // ========== 管理员接口 ==========

  // 分页查询用户
  getUserPage(params) {
    return request.get('/user/admin/list', { params })
  },

  // 获取所有用户列表
  getUserList(params) {
    return request.get('/user/admin/list', { params })
  },

  // 获取用户详情
  getUserDetail(id) {
    return request.get(`/user/admin/${id}`)
  },

  // 创建用户
  createUser(data) {
    return request.post('/user/admin/create', data)
  },

  // 更新用户信息
  updateUser(id, data) {
    return request.put(`/user/admin/${id}`, data)
  },

  // 更新用户状态
  updateUserStatus(id, status) {
    return request.put(`/user/admin/${id}/status`, null, {
      params: { status }
    })
  },

  // 删除用户
  deleteUser(id) {
    return request.delete(`/user/admin/${id}`)
  },

  // 重置用户密码
  resetPassword(id) {
    return request.put(`/user/admin/${id}/reset-password`)
  }
}