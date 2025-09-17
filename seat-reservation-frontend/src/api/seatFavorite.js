import request from '@/utils/request'

export const seatFavoriteApi = {
  // 获取收藏列表
  getFavoriteList() {
    return request({
      url: '/seat-favorite/list',
      method: 'get'
    })
  },

  // 添加收藏
  addFavorite(data) {
    return request({
      url: '/seat-favorite/add',
      method: 'post',
      data
    })
  },

  // 取消收藏
  removeFavorite(seatId) {
    return request({
      url: `/seat-favorite/remove/${seatId}`,
      method: 'delete'
    })
  },

  // 检查是否已收藏
  checkFavorite(seatId) {
    return request({
      url: `/seat-favorite/check/${seatId}`,
      method: 'get'
    })
  },

  // 更新收藏备注
  updateFavoriteName(data) {
    return request({
      url: '/seat-favorite/update',
      method: 'put',
      data
    })
  }
}