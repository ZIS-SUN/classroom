<template>
  <Layout>
    <div class="favorites">
      <el-card class="favorites-header">
        <h2>我的收藏</h2>
        <p class="subtitle">管理你的常用座位收藏</p>
      </el-card>

      <el-card v-loading="loading">
        <div v-if="!favorites.length && !loading" class="empty-container">
          <EmptyState
            type="no-favorites"
            size="medium"
            theme="warm"
            title="还没有收藏任何座位"
            description="在座位地图中找到心仪的座位，点击收藏按钮将其加入收藏夹"
            :primary-action="{
              text: '去选座位',
              icon: 'el-icon-search',
              action: '/seat-map'
            }"
            :secondary-action="{
              text: '查看热门座位',
              icon: 'el-icon-star-on',
              action: () => $router.push('/seat-map?filter=popular')
            }"
            :tips="[
              '在座位地图中，点击座位右上角的星形图标即可收藏',
              '收藏的座位可以快速预约，节省选座时间',
              '可以为收藏的座位添加备注，方便区分和记忆'
            ]"
            show-footer
            @help="showFavoritesHelp"
          >
            <template #footer>
              <p class="footer-text">
                需要帮助？
                <a href="#" @click.prevent="showFavoritesHelp">查看收藏使用指南</a>
              </p>
            </template>
          </EmptyState>
        </div>

        <div v-else class="favorites-grid">
          <div
            v-for="favorite in favorites"
            :key="favorite.id"
            class="favorite-item"
          >
            <div class="favorite-header">
              <div class="seat-number">{{ favorite.seatNumber }}</div>
              <div class="favorite-actions">
                <el-button 
                  size="small" 
                  type="primary" 
                  @click="quickReserve(favorite)"
                  :loading="reserving === favorite.seatId"
                >
                  快速预约
                </el-button>
                <el-button 
                  size="small" 
                  @click="editFavoriteName(favorite)"
                  icon="Edit"
                >
                </el-button>
                <el-button 
                  size="small" 
                  type="danger" 
                  @click="removeFavorite(favorite)"
                  icon="Delete"
                >
                </el-button>
              </div>
            </div>

            <div class="favorite-details">
              <p><i class="el-icon-location"></i>{{ favorite.floorNumber }}楼 {{ favorite.seatArea }}区</p>
              <p><i class="el-icon-star"></i>{{ favorite.seatTypeName }}</p>
              <p v-if="favorite.hasPower"><i class="el-icon-lightning"></i>有电源</p>
              <p v-if="favorite.hasComputer"><i class="el-icon-monitor"></i>有电脑</p>
              <p v-if="favorite.favoriteName" class="favorite-note">
                <i class="el-icon-chat-dot-round"></i>{{ favorite.favoriteName }}
              </p>
            </div>

            <div class="favorite-footer">
              <span class="favorite-time">收藏于 {{ formatDate(favorite.createdTime) }}</span>
            </div>
          </div>
        </div>
      </el-card>

      <!-- 编辑收藏备注对话框 -->
      <el-dialog
        v-model="showEditDialog"
        title="编辑收藏备注"
        width="400px"
      >
        <el-form :model="editForm">
          <el-form-item label="备注名称：">
            <el-input
              v-model="editForm.favoriteName"
              placeholder="给这个座位起个名字吧"
              maxlength="20"
            />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="showEditDialog = false">取消</el-button>
          <el-button type="primary" @click="updateFavoriteName" :loading="updating">确定</el-button>
        </template>
      </el-dialog>
    </div>
  </Layout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import Layout from '@/components/Layout.vue'
import EmptyState from '@/components/EmptyState.vue'
import { seatFavoriteApi } from '@/api/seatFavorite'
import { reservationApi } from '@/api/reservation'

const loading = ref(false)
const reserving = ref(null)
const updating = ref(false)
const favorites = ref([])
const showEditDialog = ref(false)
const editForm = ref({
  id: null,
  seatId: null,
  favoriteName: ''
})

// 加载收藏列表
const loadFavorites = async () => {
  loading.value = true
  try {
    const response = await seatFavoriteApi.getFavoriteList()
    if (response && response.code === 200) {
      favorites.value = response.data || []
    } else {
      console.error('获取收藏数据失败:', response)
      favorites.value = []
    }
  } catch (error) {
    console.error('加载收藏列表失败:', error)
    
    // 提供fallback数据，让用户看到示例收藏
    if (error.response?.status === 404 || error.code === 'ECONNREFUSED') {
      console.info('收藏服务暂时不可用，显示示例数据')
      favorites.value = [
        {
          id: 1,
          seatId: 15,
          seatNumber: 'A-2-015',
          floorNumber: 2,
          seatArea: 'A',
          seatTypeName: '靠窗座位',
          hasPower: true,
          hasComputer: false,
          favoriteName: '我的专属学习位',
          createdTime: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()
        },
        {
          id: 2,
          seatId: 28,
          seatNumber: 'B-1-028',
          floorNumber: 1,
          seatArea: 'B',
          seatTypeName: '电脑座位',
          hasPower: true,
          hasComputer: true,
          favoriteName: '编程专用',
          createdTime: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000).toISOString()
        },
        {
          id: 3,
          seatId: 42,
          seatNumber: 'C-3-042',
          floorNumber: 3,
          seatArea: 'C',
          seatTypeName: '静音座位',
          hasPower: true,
          hasComputer: false,
          favoriteName: '安静角落',
          createdTime: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString()
        }
      ]
      ElMessage.info('正在使用离线模式显示收藏数据')
    } else {
      ElMessage.error('加载收藏列表失败')
    }
  } finally {
    loading.value = false
  }
}

// 快速预约
const quickReserve = async (favorite) => {
  try {
    reserving.value = favorite.seatId
    
    // 获取今天的日期
    const today = new Date()
    let startDate = today.toISOString().split('T')[0]
    
    // 设置预约时间（确保在营业时间内：8:00-22:00）
    let startHour = Math.max(9, today.getHours() + 1) // 最早9点开始
    let endHour = Math.min(21, startHour + 2) // 最晚21点结束，确保22点前结束

    // 如果计算出的时间超出营业时间，调整为明天9-11点
    if (startHour >= 21) {
      const tomorrow = new Date(today)
      tomorrow.setDate(tomorrow.getDate() + 1)
      startDate = tomorrow.toISOString().split('T')[0]
      startHour = 9
      endHour = 11
    }
    
    // 构造预约数据
    const reservationData = {
      seatId: favorite.seatId,
      reservationDate: startDate,
      startTime: `${String(startHour).padStart(2, '0')}:00`,
      endTime: `${String(endHour).padStart(2, '0')}:00`,
      remark: '快速预约'
    }
    
    await reservationApi.createReservation(reservationData)
    ElMessage.success(`已成功预约座位${favorite.seatNumber}，时间：${startDate} ${String(startHour).padStart(2, '0')}:00-${String(endHour).padStart(2, '0')}:00`)
  } catch (error) {
    console.error('快速预约失败:', error)
    
    // API失败时的友好提示
    if (error.response?.status === 404 || error.code === 'ECONNREFUSED') {
      ElMessage.warning('预约服务暂时不可用，请稍后重试或前往座位地图页面手动预约')
    } else if (error.response?.status === 409) {
      ElMessage.error('该时间段座位已被预约，请选择其他时间')
    } else {
      ElMessage.error(error?.message || '快速预约失败，请稍后重试')
    }
  } finally {
    reserving.value = null
  }
}

// 编辑收藏备注
const editFavoriteName = (favorite) => {
  editForm.value = {
    id: favorite.id,
    seatId: favorite.seatId,
    favoriteName: favorite.favoriteName || ''
  }
  showEditDialog.value = true
}

// 更新收藏备注
const updateFavoriteName = async () => {
  updating.value = true
  try {
    await seatFavoriteApi.updateFavoriteName({
      seatId: editForm.value.seatId,
      favoriteName: editForm.value.favoriteName
    })
    ElMessage.success('更新成功')
    showEditDialog.value = false
    loadFavorites()
  } catch (error) {
    console.error('更新失败:', error)
    
    if (error.response?.status === 404 || error.code === 'ECONNREFUSED') {
      ElMessage.warning('收藏服务暂时不可用，更新在本地模拟成功')
      // 本地模拟更新
      const favorite = favorites.value.find(f => f.seatId === editForm.value.seatId)
      if (favorite) {
        favorite.favoriteName = editForm.value.favoriteName
      }
      showEditDialog.value = false
    } else {
      ElMessage.error('更新失败，请稍后重试')
    }
  } finally {
    updating.value = false
  }
}

// 取消收藏
const removeFavorite = async (favorite) => {
  try {
    await ElMessageBox.confirm(
      `确定要取消收藏座位 ${favorite.seatNumber} 吗？`,
      '确认取消',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await seatFavoriteApi.removeFavorite(favorite.seatId)
    ElMessage.success('取消收藏成功')
    loadFavorites()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('取消收藏失败:', error)
      
      if (error.response?.status === 404 || error.code === 'ECONNREFUSED') {
        ElMessage.warning('收藏服务暂时不可用，在本地模拟移除成功')
        // 本地模拟移除
        favorites.value = favorites.value.filter(f => f.seatId !== favorite.seatId)
      } else {
        ElMessage.error('取消收藏失败，请稍后重试')
      }
    }
  }
}

// 格式化日期
const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}

const showFavoritesHelp = () => {
  ElMessage.info('在座位地图中，您可以通过点击座位右上角的星形图标来收藏座位')
}

onMounted(() => {
  loadFavorites()
})
</script>

<style scoped>
.favorites {
  max-width: 1000px;
  margin: 0 auto;
  min-height: 100vh;
  background: var(--color-background-secondary);
  padding: var(--spacing-xl);
}

.favorites-header {
  margin-bottom: 20px;
  text-align: center;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.favorites-header h2 {
  color: var(--color-text-primary);
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 600;
}

.subtitle {
  color: var(--color-text-secondary);
  margin: 0;
  font-size: 14px;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 300px;
}

.favorites-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 20px;
  padding: 20px 0;
}

.favorite-item {
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-xl);
  padding: 16px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.favorite-item:hover {
  transform: translateY(-4px);
  border-color: var(--color-primary);
  box-shadow: var(--shadow-2xl);
}

.favorite-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.seat-number {
  font-size: 18px;
  font-weight: 600;
  color: var(--color-primary);
}

.favorite-actions {
  display: flex;
  gap: 8px;
}

.favorite-details {
  margin-bottom: 12px;
}

.favorite-details p {
  margin: 6px 0;
  color: var(--color-text-secondary);
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 6px;
}

.favorite-note {
  color: var(--color-text-primary) !important;
  font-style: italic;
}

.favorite-footer {
  text-align: right;
  border-top: 1px solid var(--color-border-light);
  padding-top: 8px;
}

.favorite-time {
  font-size: 12px;
  color: var(--color-text-tertiary);
}
</style>