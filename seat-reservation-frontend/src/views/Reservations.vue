<template>
  <Layout>
    <div class="reservations">
      <el-card class="header-card">
        <div class="page-header">
          <h2>我的预约</h2>
          <p class="subtitle">管理您的座位预约记录</p>
        </div>
      </el-card>

      <el-card v-loading="loading">
        <div class="reservation-list">
          <div v-if="!reservations.length && !loading" class="empty-container">
            <EmptyState
              type="no-reservations"
              size="medium"
              theme="cool"
              title="暂无预约记录"
              description="您还没有任何座位预约，现在就去选择合适的座位吧"
              :primary-action="{
                text: '去预约座位',
                icon: 'el-icon-calendar-plus',
                action: '/seat-map'
              }"
              :secondary-action="{
                text: '查看我的收藏',
                icon: 'el-icon-star-on',
                action: '/favorites'
              }"
              :tips="[
                '在座位地图中选择您喜欢的座位和时间段',
                '预约成功后，记得按时签到和签退',
                '可以提前最多7天预约座位',
                '建议先收藏常用座位，方便快速预约'
              ]"
              show-footer
              @help="showReservationHelp"
            >
              <template #footer>
                <p class="footer-text">
                  需要帮助？
                  <a href="#" @click.prevent="showReservationHelp">查看预约指南</a>
                </p>
              </template>
            </EmptyState>
          </div>

          <div v-else class="reservation-grid">
            <div 
              v-for="reservation in reservations" 
              :key="reservation.id"
              class="reservation-card"
            >
              <div class="card-header">
                <div class="seat-info">
                  <h4>{{ reservation.seatNumber }}</h4>
                  <span class="location">{{ reservation.floorNumber }}楼 {{ reservation.seatArea }}区</span>
                </div>
                <el-tag 
                  :type="getStatusType(reservation.status)" 
                  size="small"
                >
                  {{ getStatusText(reservation.status) }}
                </el-tag>
              </div>

              <div class="card-body">
                <div class="info-row">
                  <div class="info-item">
                    <el-icon><Calendar /></el-icon>
                    <span>{{ reservation.reservationDate }}</span>
                  </div>
                  <div class="info-item">
                    <el-icon><Clock /></el-icon>
                    <span>{{ reservation.startTime }} - {{ reservation.endTime }}</span>
                  </div>
                </div>
                
                <div class="info-row">
                  <div class="info-item">
                    <el-icon><Timer /></el-icon>
                    <span>{{ reservation.duration }}小时</span>
                  </div>
                  <div class="info-item" v-if="reservation.totalFee">
                    <el-icon><Money /></el-icon>
                    <span>¥{{ reservation.totalFee }}</span>
                  </div>
                </div>

                <div v-if="reservation.remark" class="remark">
                  <small>备注：{{ reservation.remark }}</small>
                </div>
              </div>

              <div class="card-actions">
                <el-button
                  v-if="reservation.status === 'UNPAID'"
                  type="primary"
                  size="small"
                  @click="handlePayment(reservation)"
                >
                  立即支付
                </el-button>
                
                <el-button
                  v-if="reservation.canCancel"
                  type="danger"
                  size="small"
                  plain
                  :loading="actionLoading && actionReservationId === reservation.id && actionType === 'cancel'"
                  @click="handleCancel(reservation)"
                >
                  取消预约
                </el-button>
                
                <el-button
                  v-if="reservation.canCheckIn"
                  type="success"
                  size="small"
                  :loading="actionLoading && actionReservationId === reservation.id && actionType === 'checkin'"
                  @click="handleCheckIn(reservation)"
                >
                  签到
                </el-button>
                
                <el-button
                  v-if="reservation.canCheckOut"
                  type="warning"
                  size="small"
                  :loading="actionLoading && actionReservationId === reservation.id && actionType === 'checkout'"
                  @click="handleCheckOut(reservation)"
                >
                  签退
                </el-button>
                
                <el-button
                  size="small"
                  plain
                  @click="showDetail(reservation)"
                >
                  详情
                </el-button>
              </div>
            </div>
          </div>

          <!-- 分页 -->
          <div class="pagination-wrapper" v-if="total > 0">
            <el-pagination
              v-model:current-page="currentPage"
              v-model:page-size="pageSize"
              :total="total"
              :page-sizes="[10, 20, 50]"
              layout="total, sizes, prev, pager, next, jumper"
              @size-change="loadReservations"
              @current-change="loadReservations"
            />
          </div>
        </div>
      </el-card>

      <!-- 详情对话框 -->
      <el-dialog
        v-model="showDetailDialog"
        title="预约详情"
        width="500px"
      >
        <div v-if="selectedReservation" class="detail-content">
          <div class="detail-group">
            <h4>座位信息</h4>
            <div class="detail-items">
              <div class="detail-item">
                <span class="label">座位号：</span>
                <span>{{ selectedReservation.seatNumber }}</span>
              </div>
              <div class="detail-item">
                <span class="label">位置：</span>
                <span>{{ selectedReservation.floorNumber }}楼 {{ selectedReservation.seatArea }}区</span>
              </div>
            </div>
          </div>

          <div class="detail-group">
            <h4>预约信息</h4>
            <div class="detail-items">
              <div class="detail-item">
                <span class="label">日期：</span>
                <span>{{ selectedReservation.reservationDate }}</span>
              </div>
              <div class="detail-item">
                <span class="label">时间：</span>
                <span>{{ selectedReservation.startTime }} - {{ selectedReservation.endTime }}</span>
              </div>
              <div class="detail-item">
                <span class="label">时长：</span>
                <span>{{ selectedReservation.duration }}小时</span>
              </div>
              <div class="detail-item" v-if="selectedReservation.totalFee">
                <span class="label">费用：</span>
                <span>¥{{ selectedReservation.totalFee }}</span>
              </div>
              <div class="detail-item">
                <span class="label">状态：</span>
                <el-tag :type="getStatusType(selectedReservation.status)" size="small">
                  {{ getStatusText(selectedReservation.status) }}
                </el-tag>
              </div>
            </div>
          </div>

          <div class="detail-group" v-if="selectedReservation.checkInTime || selectedReservation.checkOutTime">
            <h4>签到记录</h4>
            <div class="detail-items">
              <div class="detail-item" v-if="selectedReservation.checkInTime">
                <span class="label">签到时间：</span>
                <span>{{ formatDateTime(selectedReservation.checkInTime) }}</span>
              </div>
              <div class="detail-item" v-if="selectedReservation.checkOutTime">
                <span class="label">签退时间：</span>
                <span>{{ formatDateTime(selectedReservation.checkOutTime) }}</span>
              </div>
            </div>
          </div>

          <div class="detail-group" v-if="selectedReservation.remark">
            <h4>备注</h4>
            <div class="remark-text">{{ selectedReservation.remark }}</div>
          </div>
        </div>
        
        <template #footer>
          <el-button @click="showDetailDialog = false">关闭</el-button>
        </template>
      </el-dialog>
      
      <!-- 支付对话框 -->
      <PaymentDialog
        :visible="showPaymentDialog"
        :reservation-id="paymentReservation?.id"
        :seat-info="paymentReservation ? `${paymentReservation.seatNumber} (${paymentReservation.floorNumber}楼 ${paymentReservation.seatArea}区)` : ''"
        :reservation-time="paymentReservation ? `${paymentReservation.reservationDate} ${paymentReservation.startTime}-${paymentReservation.endTime}` : ''"
        :amount="paymentReservation?.totalFee || 0"
        @success="handlePaymentSuccess"
        @cancel="handlePaymentCancel"
        @error="handlePaymentError"
      />
    </div>
  </Layout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Calendar, Clock, Timer, Money } from '@element-plus/icons-vue'
import Layout from '@/components/Layout.vue'
import EmptyState from '@/components/EmptyState.vue'
import PaymentDialog from '@/components/PaymentDialog.vue'
import { reservationApi } from '@/api/reservation'

const loading = ref(false)
const reservations = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const showDetailDialog = ref(false)
const selectedReservation = ref(null)
const showPaymentDialog = ref(false)
const paymentReservation = ref(null)
const actionLoading = ref(false)
const actionReservationId = ref(null)
const actionType = ref('')

const statusTextMap = {
  'UNPAID': '未支付',
  'RESERVED': '已预约',
  'USING': '使用中',
  'COMPLETED': '已完成',
  'CANCELLED': '已取消',
  // 兼容可能出现的历史状态
  'PENDING': '待支付',
  'ACTIVE': '已预约'
}

const statusTypeMap = {
  'UNPAID': 'danger',
  'RESERVED': 'primary',
  'USING': 'success',
  'COMPLETED': 'info',
  'CANCELLED': 'danger',
  'PENDING': 'warning',
  'ACTIVE': 'primary'
}

const getStatusText = (status) => {
  return statusTextMap[status] || status
}

const getStatusType = (status) => {
  return statusTypeMap[status] || 'info'
}

const formatDateTime = (datetime) => {
  return new Date(datetime).toLocaleString('zh-CN')
}

const loadReservations = async () => {
  loading.value = true
  try {
    const params = {
      current: currentPage.value,
      size: pageSize.value
    }
    
    const response = await reservationApi.getUserReservations(params)
    if (response && response.code === 200) {
      reservations.value = response.data.records || []
      total.value = response.data.total || 0
    } else {
      console.error('获取预约数据失败:', response)
      reservations.value = []
      total.value = 0
    }
  } catch (error) {
    console.error('加载预约记录失败:', error)
    ElMessage.error('加载预约记录失败')
  } finally {
    loading.value = false
  }
}

const handlePayment = (reservation) => {
  paymentReservation.value = reservation
  showPaymentDialog.value = true
}

const handlePaymentSuccess = () => {
  showPaymentDialog.value = false
  paymentReservation.value = null
  ElMessage.success('支付成功')
  loadReservations()
}

const handlePaymentCancel = () => {
  showPaymentDialog.value = false
  paymentReservation.value = null
}

const handlePaymentError = (error) => {
  ElMessage.error(error || '支付失败')
}

const handleCancel = async (reservation) => {
  try {
    actionLoading.value = true
    actionReservationId.value = reservation.id
    actionType.value = 'cancel'
    await ElMessageBox.confirm(
      '确定要取消这个预约吗？取消后将无法恢复。',
      '确认取消',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await reservationApi.cancelReservation(reservation.id)
    ElMessage.success('预约已取消，如已支付费用将自动退回钱包')
    loadReservations()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('取消预约失败:', error)
      ElMessage.error('取消预约失败')
    }
  } finally {
    actionLoading.value = false
    actionReservationId.value = null
    actionType.value = ''
  }
}

const handleCheckIn = async (reservation) => {
  try {
    actionLoading.value = true
    actionReservationId.value = reservation.id
    actionType.value = 'checkin'
    await reservationApi.checkIn(reservation.id)
    ElMessage.success('签到成功')
    loadReservations()
  } catch (error) {
    console.error('签到失败:', error)
  } finally {
    actionLoading.value = false
    actionReservationId.value = null
    actionType.value = ''
  }
}

const handleCheckOut = async (reservation) => {
  try {
    await ElMessageBox.confirm(
      '确定要签退吗？签退后将结束本次使用。',
      '确认签退',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'info'
      }
    )
    
    actionLoading.value = true
    actionReservationId.value = reservation.id
    actionType.value = 'checkout'
    await reservationApi.checkOut(reservation.id)
    ElMessage.success('签退成功')
    loadReservations()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('签退失败:', error)
    }
  } finally {
    actionLoading.value = false
    actionReservationId.value = null
    actionType.value = ''
  }
}

const showDetail = (reservation) => {
  selectedReservation.value = reservation
  showDetailDialog.value = true
}

const showReservationHelp = () => {
  ElMessage.info('预约流程：选择座位和时间 → 确认预约 → 支付费用 → 按时签到')
}

onMounted(() => {
  loadReservations()
})
</script>

<style scoped>
.reservations {
  max-width: 1000px;
  margin: 0 auto;
  min-height: 100vh;
  background: var(--color-background-secondary);
  padding: var(--spacing-xl);
}

.header-card {
  margin-bottom: 20px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.page-header h2 {
  margin: 0 0 8px 0;
  color: var(--color-text-primary);
  font-weight: 600;
}

.subtitle {
  margin: 0;
  color: var(--color-text-secondary);
  font-size: 14px;
}

.reservation-list {
  min-height: 400px;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 300px;
}

.reservation-grid {
  display: grid;
  gap: 20px;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
}

.reservation-card {
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-xl);
  padding: 20px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.reservation-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-2xl);
  border-color: var(--color-primary);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 15px;
}

.seat-info h4 {
  margin: 0 0 4px 0;
  color: var(--color-text-primary);
  font-size: 18px;
  font-weight: 600;
}

.location {
  color: var(--color-text-secondary);
  font-size: 14px;
}

.card-body {
  margin-bottom: 15px;
}

.info-row {
  display: flex;
  gap: 20px;
  margin-bottom: 10px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--color-text-secondary);
  font-size: 14px;
}

.info-item .el-icon {
  font-size: 16px;
  color: var(--color-text-tertiary);
}

.remark {
  margin-top: 10px;
  padding: 8px 12px;
  background: var(--color-background-secondary);
  border-radius: var(--radius-base);
  color: var(--color-text-secondary);
  font-size: 13px;
}

.card-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.pagination-wrapper {
  margin-top: 30px;
  text-align: center;
}

.detail-content {
  max-height: 500px;
  overflow-y: auto;
}

.detail-group {
  margin-bottom: 20px;
}

.detail-group h4 {
  margin: 0 0 10px 0;
  color: #333;
  font-size: 16px;
  border-bottom: 1px solid #e6e6e6;
  padding-bottom: 5px;
}

.detail-items {
  padding-left: 10px;
}

.detail-item {
  display: flex;
  margin-bottom: 8px;
  align-items: center;
}

.detail-item .label {
  width: 80px;
  color: #666;
  font-weight: 500;
}

.remark-text {
  padding: 10px;
  background: #f8f9fa;
  border-radius: 4px;
  color: #666;
  line-height: 1.5;
}
</style>
