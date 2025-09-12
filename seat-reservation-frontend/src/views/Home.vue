<template>
  <Layout>
    <div class="home">
      <!-- 轮播横幅 -->
      <el-card class="banner-card">
        <div class="banner">
          <h1>欢迎使用智能座位预约系统</h1>
          <p>高效便捷的自习室座位预约平台，为您提供舒适的学习环境</p>
          <div class="banner-actions">
            <el-button type="primary" size="large" @click="goToSeatMap">
              <el-icon><Calendar /></el-icon>
              立即预约座位
            </el-button>
            <el-button size="large" @click="viewMyReservations">
              <el-icon><List /></el-icon>
              我的预约
            </el-button>
          </div>
        </div>
      </el-card>

      <el-row :gutter="20">
        <!-- 公告栏 -->
        <el-col :xs="24" :md="16">
          <el-card class="announcement-card">
            <template #header>
              <div class="card-header">
                <h3>
                  <el-icon><Bell /></el-icon>
                  系统公告
                </h3>
                <el-button text size="small" @click="viewAllAnnouncements">查看全部</el-button>
              </div>
            </template>
            
            <div class="announcements" v-loading="announcementsLoading">
              <div 
                v-for="announcement in announcements" 
                :key="announcement.id"
                class="announcement-item"
                @click="viewAnnouncement(announcement)"
              >
                <div class="announcement-content">
                  <h4>{{ announcement.title }}</h4>
                  <p>{{ announcement.summary }}</p>
                  <div class="announcement-meta">
                    <span class="date">{{ formatDate(announcement.publishTime) }}</span>
                    <el-tag v-if="announcement.isTop" type="danger" size="small">置顶</el-tag>
                  </div>
                </div>
              </div>
              
              <div v-if="announcements.length === 0" class="no-announcements">
                暂无公告
              </div>
            </div>
          </el-card>
        </el-col>

        <!-- 快捷功能 -->
        <el-col :xs="24" :md="8">
          <el-card class="quick-actions-card">
            <template #header>
              <h3>
                <el-icon><Star /></el-icon>
                快捷功能
              </h3>
            </template>
            
            <div class="quick-actions">
              <div class="action-item" @click="goToSeatMap">
                <el-icon size="24"><Grid /></el-icon>
                <span>座位地图</span>
              </div>
              <div class="action-item" @click="viewMyReservations">
                <el-icon size="24"><Document /></el-icon>
                <span>我的预约</span>
              </div>
              <div class="action-item" @click="goToProfile">
                <el-icon size="24"><User /></el-icon>
                <span>个人中心</span>
              </div>
              <div class="action-item" @click="showFeedback">
                <el-icon size="24"><ChatDotRound /></el-icon>
                <span>意见反馈</span>
              </div>
              <div class="action-item" @click="showHelp">
                <el-icon size="24"><QuestionFilled /></el-icon>
                <span>帮助中心</span>
              </div>
              <div class="action-item" @click="showRules">
                <el-icon size="24"><Reading /></el-icon>
                <span>自习规则</span>
              </div>
            </div>
          </el-card>

          <!-- 统计信息 -->
          <el-card class="stats-card">
            <template #header>
              <h3>
                <el-icon><DataAnalysis /></el-icon>
                实时数据
              </h3>
            </template>
            
            <div class="stats">
              <div class="stat-item">
                <div class="stat-number">{{ stats.totalSeats }}</div>
                <div class="stat-label">总座位数</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">{{ stats.availableSeats }}</div>
                <div class="stat-label">可用座位</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">{{ stats.todayReservations }}</div>
                <div class="stat-label">今日预约</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">{{ stats.myReservations }}</div>
                <div class="stat-label">我的预约</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 公告详情对话框 -->
      <el-dialog v-model="announcementDetailVisible" title="公告详情" width="600px">
        <div v-if="selectedAnnouncement">
          <h3>{{ selectedAnnouncement.title }}</h3>
          <div class="announcement-meta">
            <span>发布时间: {{ formatDateTime(selectedAnnouncement.publishTime) }}</span>
            <el-tag v-if="selectedAnnouncement.isTop" type="danger" size="small">置顶</el-tag>
          </div>
          <div class="announcement-content" v-html="selectedAnnouncement.content"></div>
        </div>
      </el-dialog>

      <!-- 反馈对话框 -->
      <el-dialog v-model="feedbackVisible" title="意见反馈" width="500px">
        <el-form :model="feedbackForm" label-width="80px">
          <el-form-item label="反馈类型">
            <el-select v-model="feedbackForm.type" placeholder="请选择反馈类型">
              <el-option label="功能建议" value="SUGGESTION" />
              <el-option label="问题反馈" value="BUG" />
              <el-option label="投诉举报" value="COMPLAINT" />
              <el-option label="其他" value="OTHER" />
            </el-select>
          </el-form-item>
          <el-form-item label="反馈内容">
            <el-input
              v-model="feedbackForm.content"
              type="textarea"
              :rows="5"
              placeholder="请详细描述您的问题或建议"
              maxlength="500"
              show-word-limit
            />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="feedbackVisible = false">取消</el-button>
          <el-button type="primary" @click="submitFeedback">提交反馈</el-button>
        </template>
      </el-dialog>

      <!-- 帮助对话框 -->
      <el-dialog v-model="helpVisible" title="帮助中心" width="600px">
        <div class="help-content">
          <el-collapse v-model="activeHelp">
            <el-collapse-item title="如何预约座位？" name="1">
              <p>1. 点击"座位地图"进入预约页面</p>
              <p>2. 选择日期和时间段</p>
              <p>3. 点击可用座位进行预约</p>
              <p>4. 确认预约信息并提交</p>
            </el-collapse-item>
            <el-collapse-item title="如何取消预约？" name="2">
              <p>1. 进入"我的预约"页面</p>
              <p>2. 找到要取消的预约记录</p>
              <p>3. 点击"取消"按钮</p>
              <p>4. 确认取消操作</p>
            </el-collapse-item>
            <el-collapse-item title="预约规则说明" name="3">
              <p>1. 每人每天最多预约2个时段</p>
              <p>2. 预约后请按时到场，逾期未到视为违约</p>
              <p>3. 连续违约3次将暂时限制预约权限</p>
              <p>4. 可提前取消预约，但请尽早操作</p>
            </el-collapse-item>
            <el-collapse-item title="联系我们" name="4">
              <p>如有问题请联系管理员：</p>
              <p>电话：123-4567-8900</p>
              <p>邮箱：admin@library.edu</p>
              <p>或通过"意见反馈"功能向我们反馈问题</p>
            </el-collapse-item>
          </el-collapse>
        </div>
      </el-dialog>

      <!-- 规则对话框 -->
      <el-dialog v-model="rulesVisible" title="自习室使用规则" width="600px">
        <div class="rules-content">
          <h4>一、预约规则</h4>
          <ol>
            <li>用户需实名注册并完善个人信息</li>
            <li>每人每天最多可预约2个时段</li>
            <li>预约成功后，请按时到场使用</li>
            <li>临时有事可提前取消预约</li>
          </ol>

          <h4>二、使用规则</h4>
          <ol>
            <li>保持安静，不得大声喧哗</li>
            <li>不得占用多个座位</li>
            <li>保持座位和环境整洁</li>
            <li>不得在座位上用餐</li>
            <li>离开时请带走个人物品</li>
          </ol>

          <h4>三、违规处理</h4>
          <ol>
            <li>连续3次预约未到场，将暂停预约权限7天</li>
            <li>违反使用规则者，将视情况给予警告或暂停权限</li>
            <li>恶意占座、破坏设施等行为将被永久限制使用</li>
          </ol>
        </div>
      </el-dialog>
    </div>
  </Layout>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { 
  Calendar, List, Bell, Star, Grid, Document, User, ChatDotRound,
  QuestionFilled, Reading, DataAnalysis
} from '@element-plus/icons-vue'
import Layout from '@/components/Layout.vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

// 数据
const announcementsLoading = ref(false)
const announcements = ref([])
const selectedAnnouncement = ref(null)
const announcementDetailVisible = ref(false)

const stats = reactive({
  totalSeats: 120,
  availableSeats: 85,
  todayReservations: 67,
  myReservations: 2
})

// 对话框状态
const feedbackVisible = ref(false)
const helpVisible = ref(false)
const rulesVisible = ref(false)
const activeHelp = ref(['1'])

// 反馈表单
const feedbackForm = reactive({
  type: '',
  content: ''
})

// 方法
const formatDate = (dateTime) => {
  if (!dateTime) return ''
  return new Date(dateTime).toLocaleDateString('zh-CN')
}

const formatDateTime = (dateTime) => {
  if (!dateTime) return ''
  return new Date(dateTime).toLocaleString('zh-CN')
}

const goToSeatMap = () => {
  router.push('/seat-map')
}

const viewMyReservations = () => {
  router.push('/reservations')
}

const goToProfile = () => {
  router.push('/profile')
}

const viewAllAnnouncements = () => {
  ElMessage.info('公告列表功能开发中')
}

const viewAnnouncement = (announcement) => {
  selectedAnnouncement.value = announcement
  announcementDetailVisible.value = true
}

const showFeedback = () => {
  feedbackVisible.value = true
}

const showHelp = () => {
  helpVisible.value = true
}

const showRules = () => {
  rulesVisible.value = true
}

const submitFeedback = async () => {
  if (!feedbackForm.type || !feedbackForm.content.trim()) {
    ElMessage.warning('请填写完整的反馈信息')
    return
  }

  try {
    const response = await fetch('/api/feedback/submit', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${userStore.token}`
      },
      body: JSON.stringify({
        type: feedbackForm.type,
        content: feedbackForm.content.trim()
      })
    })

    const result = await response.json()
    if (result.code === 200) {
      ElMessage.success('反馈提交成功，感谢您的建议！')
      feedbackVisible.value = false
      feedbackForm.type = ''
      feedbackForm.content = ''
    } else {
      ElMessage.error(result.message || '提交失败')
    }
  } catch (error) {
    console.error('提交反馈失败:', error)
    ElMessage.error('提交失败，请稍后重试')
  }
}

const loadAnnouncements = async () => {
  announcementsLoading.value = true
  try {
    // TODO: 调用公告API
    // 模拟数据
    announcements.value = [
      {
        id: 1,
        title: '系统维护通知',
        summary: '系统将于今晚22:00-24:00进行维护升级...',
        content: '亲爱的用户，为了提供更好的服务，系统将于今晚22:00-24:00进行维护升级，届时将暂停服务。请大家提前做好安排，感谢理解与支持！',
        publishTime: new Date(Date.now() - 2 * 60 * 60 * 1000),
        isTop: true
      },
      {
        id: 2,
        title: '新增3楼自习区域',
        summary: '图书馆3楼新增100个座位，欢迎大家预约使用...',
        content: '图书馆3楼新增100个座位，配备了更舒适的桌椅和更好的照明设备。新区域已开放预约，欢迎大家使用！',
        publishTime: new Date(Date.now() - 24 * 60 * 60 * 1000),
        isTop: false
      },
      {
        id: 3,
        title: '预约规则更新',
        summary: '为了更好地服务广大学生，预约规则有所调整...',
        content: '为了更好地服务广大学生，现调整预约规则：每人每天可预约时段增加至3个，但请大家合理使用，按时到场。',
        publishTime: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
        isTop: false
      }
    ]
  } catch (error) {
    console.error('加载公告失败:', error)
  } finally {
    announcementsLoading.value = false
  }
}

const loadStats = async () => {
  try {
    // TODO: 调用统计API
    // 当前使用模拟数据
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

onMounted(() => {
  loadAnnouncements()
  loadStats()
})
</script>

<style scoped>
.home {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.banner-card {
  margin-bottom: 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
}

.banner-card :deep(.el-card__body) {
  padding: 40px;
  text-align: center;
}

.banner h1 {
  margin: 0 0 16px 0;
  font-size: 2.5rem;
  font-weight: 600;
}

.banner p {
  margin: 0 0 32px 0;
  font-size: 1.2rem;
  opacity: 0.9;
}

.banner-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  flex-wrap: wrap;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h3 {
  margin: 0;
  display: flex;
  align-items: center;
  gap: 8px;
  color: #303133;
}

.announcements {
  max-height: 400px;
  overflow-y: auto;
}

.announcement-item {
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 12px;
  background: #fafafa;
  cursor: pointer;
  transition: all 0.3s ease;
}

.announcement-item:hover {
  background: #f0f9ff;
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.announcement-content h4 {
  margin: 0 0 8px 0;
  color: #303133;
  font-weight: 600;
}

.announcement-content p {
  margin: 0 0 12px 0;
  color: #606266;
  line-height: 1.5;
}

.announcement-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: #909399;
}

.no-announcements {
  text-align: center;
  color: #909399;
  padding: 40px 0;
}

.quick-actions {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.action-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-item:hover {
  background: #e3f2fd;
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.action-item span {
  margin-top: 8px;
  font-size: 14px;
  color: #606266;
}

.stats {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.stat-item {
  text-align: center;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
}

.stat-number {
  font-size: 2rem;
  font-weight: 600;
  color: #409eff;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: #909399;
}

.announcement-card,
.quick-actions-card,
.stats-card {
  margin-bottom: 20px;
}

.help-content,
.rules-content {
  line-height: 1.6;
}

.rules-content h4 {
  color: #303133;
  margin: 20px 0 10px 0;
}

.rules-content ol {
  margin-bottom: 20px;
}

.rules-content li {
  margin-bottom: 8px;
  color: #606266;
}

@media (max-width: 768px) {
  .home {
    padding: 16px;
  }
  
  .banner h1 {
    font-size: 2rem;
  }
  
  .banner p {
    font-size: 1rem;
  }
  
  .banner-actions {
    flex-direction: column;
  }
  
  .quick-actions {
    grid-template-columns: repeat(3, 1fr);
  }
  
  .stats {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media (max-width: 480px) {
  .quick-actions {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .stats {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>