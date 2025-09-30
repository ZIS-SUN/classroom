import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      redirect: '/home'
    },
    {
      path: '/home',
      name: 'Home',
      component: () => import('@/views/Home.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/Login.vue'),
      meta: { requiresAuth: false }
    },
    {
      path: '/register',
      name: 'Register',
      component: () => import('@/views/Register.vue'),
      meta: { requiresAuth: false }
    },
    {
      path: '/seat-map',
      name: 'SeatMap',
      component: () => import('@/views/SeatMap.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/reservations',
      name: 'Reservations',
      component: () => import('@/views/Reservations.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/favorites',
      name: 'Favorites',
      component: () => import('@/views/Favorites.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/profile',
      name: 'Profile',
      component: () => import('@/views/Profile.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/color-test',
      name: 'ColorTest',
      component: () => import('@/views/ColorTest.vue'),
      meta: { requiresAuth: false }
    },
    {
      path: '/admin',
      component: () => import('@/components/AdminLayout.vue'),
      meta: { requiresAuth: true, requiresAdmin: true },
      redirect: '/admin/dashboard',
      children: [
        {
          path: 'dashboard',
          name: 'AdminDashboard',
          component: () => import('@/views/admin/Dashboard.vue'),
          meta: { requiresAuth: true, requiresAdmin: true }
        },
        {
          path: 'seats',
          name: 'AdminSeats',
          component: () => import('@/views/admin/Seats.vue'),
          meta: { requiresAuth: true, requiresAdmin: true }
        },
        {
          path: 'reservations',
          name: 'AdminReservations',
          component: () => import('@/views/admin/Reservations.vue'),
          meta: { requiresAuth: true, requiresAdmin: true }
        },
        {
          path: 'users',
          name: 'AdminUsers',
          component: () => import('@/views/admin/Users.vue'),
          meta: { requiresAuth: true, requiresAdmin: true }
        },
        {
          path: 'announcements',
          name: 'AdminAnnouncements',
          component: () => import('@/views/admin/Announcements.vue'),
          meta: { requiresAuth: true, requiresAdmin: true }
        },
        {
          path: 'reports',
          name: 'AdminReports',
          component: () => import('@/views/admin/Reports.vue'),
          meta: { requiresAuth: true, requiresAdmin: true }
        },
        {
          path: 'settings',
          name: 'AdminSettings',
          component: () => import('@/views/admin/Settings.vue'),
          meta: { requiresAuth: true, requiresAdmin: true }
        }
      ]
    }
  ]
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()
  
  // 强制检查登录状态
  const isLoggedIn = !!userStore.token && !!userStore.user
  const isAdmin = userStore.user?.role === 'ADMIN'
  
  // 检查是否需要登录
  if (to.meta.requiresAuth && !isLoggedIn) {
    next('/login')
    return
  }
  
  // 检查是否需要管理员权限
  if (to.meta.requiresAdmin && (!isLoggedIn || !isAdmin)) {
    next('/login')
    return
  }
  
  // 如果用户已登录且访问登录/注册页面，重定向到相应界面
  if ((to.name === 'Login' || to.name === 'Register') && isLoggedIn) {
    if (isAdmin) {
      next('/admin')
    } else {
      next('/home')
    }
    return
  }
  
  // 管理员访问控制：管理员只能访问 /admin 和登录相关页面
  if (isLoggedIn && isAdmin) {
    // 管理员允许访问的路径
    const adminAllowedPaths = ['/admin', '/login', '/register']
    // 检查路径是否是 admin 子路径
    const isAdminSubPath = to.path.startsWith('/admin/')
    if (!adminAllowedPaths.includes(to.path) && !isAdminSubPath) {
      next('/admin')
      return
    }
  }
  
  // 普通用户访问控制：普通用户不能访问 /admin
  if (isLoggedIn && !isAdmin && to.path === '/admin') {
    next('/home')
    return
  }
  
  // 根路径重定向
  if (to.path === '/') {
    if (isLoggedIn) {
      if (isAdmin) {
        next('/admin')
      } else {
        next('/home')
      }
    } else {
      next('/login')
    }
    return
  }
  
  next()
})

export default router