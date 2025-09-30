import request from '@/utils/request'

// 获取公告列表（使用公开接口）
export const getAnnouncements = (params) => {
  return request({
    url: '/announcement/public/list',
    method: 'get',
    params
  })
}

// 获取公告详情（使用公开接口）
export const getAnnouncementById = (id) => {
  return request({
    url: `/announcement/public/${id}`,
    method: 'get'
  })
}

// 创建公告（管理员权限）
export const createAnnouncement = (data) => {
  return request({
    url: '/announcements',
    method: 'post',
    data
  })
}

// 更新公告（管理员权限）
export const updateAnnouncement = (id, data) => {
  return request({
    url: `/announcements/${id}`,
    method: 'put',
    data
  })
}

// 删除公告（管理员权限）
export const deleteAnnouncement = (id) => {
  return request({
    url: `/announcements/${id}`,
    method: 'delete'
  })
}

// 获取置顶公告
export const getTopAnnouncements = () => {
  return request({
    url: '/announcements/top',
    method: 'get'
  })
}