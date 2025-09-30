import request from './request'

const api = {
  // 通用请求方法
  get: (url, params) => request.get(url, { params }),
  post: (url, data) => request.post(url, data),
  put: (url, data) => request.put(url, data),
  delete: (url) => request.delete(url),
  patch: (url, data) => request.patch(url, data)
}

export default api