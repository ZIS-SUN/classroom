import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  const user = ref(null)
  const token = ref(localStorage.getItem('token'))
  
  const isLoggedIn = computed(() => !!token.value && !!user.value)
  const isAdmin = computed(() => user.value?.role === 'ADMIN')

  function setUser(userData) {
    user.value = userData
  }

  function setToken(newToken) {
    token.value = newToken
    if (newToken) {
      localStorage.setItem('token', newToken)
    } else {
      localStorage.removeItem('token')
    }
  }

  function logout() {
    user.value = null
    token.value = null
    localStorage.removeItem('token')
  }

  // 初始化时如果有token，解析用户信息
  if (token.value) {
    try {
      const payload = JSON.parse(atob(token.value.split('.')[1]))
      if (payload.exp * 1000 > Date.now()) {
        // token未过期，这里可以调用API获取用户信息
        user.value = { id: payload.sub, username: payload.username, role: payload.role }
      } else {
        // token过期，清除
        logout()
      }
    } catch (error) {
      logout()
    }
  }

  return {
    user,
    token,
    isLoggedIn,
    isAdmin,
    setUser,
    setToken,
    logout
  }
})