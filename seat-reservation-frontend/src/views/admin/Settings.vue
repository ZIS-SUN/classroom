<template>
  <div class="settings-management">
    <div class="page-header">
      <h2>系统设置</h2>
    </div>

    <el-tabs v-model="activeSettingTab" tab-position="left" class="settings-tabs">
      <!-- 基础设置 -->
      <el-tab-pane label="基础设置" name="basic">
        <el-card class="setting-card">
          <template #header>
            <h3>系统基础配置</h3>
          </template>

          <el-form :model="basicSettings" label-width="120px" class="setting-form">
            <el-form-item label="系统名称">
              <el-input v-model="basicSettings.systemName" placeholder="请输入系统名称" />
            </el-form-item>

            <el-form-item label="系统描述">
              <el-input
                v-model="basicSettings.systemDescription"
                type="textarea"
                :rows="3"
                placeholder="请输入系统描述"
              />
            </el-form-item>

            <el-form-item label="系统版本">
              <el-input v-model="basicSettings.systemVersion" placeholder="请输入系统版本" />
            </el-form-item>

            <el-form-item label="联系邮箱">
              <el-input v-model="basicSettings.contactEmail" placeholder="请输入联系邮箱" />
            </el-form-item>

            <el-form-item label="联系电话">
              <el-input v-model="basicSettings.contactPhone" placeholder="请输入联系电话" />
            </el-form-item>

            <el-form-item label="系统状态">
              <el-switch
                v-model="basicSettings.systemEnabled"
                active-text="启用"
                inactive-text="禁用"
              />
            </el-form-item>

            <el-form-item label="维护模式">
              <el-switch
                v-model="basicSettings.maintenanceMode"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="saveBasicSettings" :loading="saving">
                保存设置
              </el-button>
              <el-button @click="resetBasicSettings">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>

      <!-- 预约设置 -->
      <el-tab-pane label="预约设置" name="reservation">
        <el-card class="setting-card">
          <template #header>
            <h3>预约规则配置</h3>
          </template>

          <el-form :model="reservationSettings" label-width="150px" class="setting-form">
            <el-form-item label="最大预约时长(小时)">
              <el-input-number
                v-model="reservationSettings.maxHours"
                :min="1"
                :max="24"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item label="提前预约天数">
              <el-input-number
                v-model="reservationSettings.advanceDays"
                :min="1"
                :max="30"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item label="取消预约时限(小时)">
              <el-input-number
                v-model="reservationSettings.cancelHours"
                :min="1"
                :max="72"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item label="自动确认预约">
              <el-switch
                v-model="reservationSettings.autoConfirm"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>

            <el-form-item label="允许重复预约">
              <el-switch
                v-model="reservationSettings.allowDuplicate"
                active-text="允许"
                inactive-text="禁止"
              />
            </el-form-item>

            <el-form-item label="预约提醒">
              <el-switch
                v-model="reservationSettings.enableReminder"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>

            <el-form-item label="提醒时间(分钟)">
              <el-input-number
                v-model="reservationSettings.reminderMinutes"
                :min="5"
                :max="120"
                :disabled="!reservationSettings.enableReminder"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="saveReservationSettings" :loading="saving">
                保存设置
              </el-button>
              <el-button @click="resetReservationSettings">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>

      <!-- 时间设置 -->
      <el-tab-pane label="时间设置" name="schedule">
        <el-card class="setting-card">
          <template #header>
            <h3>开放时间配置</h3>
          </template>

          <el-form :model="scheduleSettings" label-width="120px" class="setting-form">
            <el-form-item label="开放时间">
              <el-time-picker
                v-model="scheduleSettings.openTime"
                format="HH:mm"
                value-format="HH:mm"
                placeholder="选择开放时间"
              />
            </el-form-item>

            <el-form-item label="关闭时间">
              <el-time-picker
                v-model="scheduleSettings.closeTime"
                format="HH:mm"
                value-format="HH:mm"
                placeholder="选择关闭时间"
              />
            </el-form-item>

            <el-form-item label="休息日">
              <el-checkbox-group v-model="scheduleSettings.restDays">
                <el-checkbox label="1">周一</el-checkbox>
                <el-checkbox label="2">周二</el-checkbox>
                <el-checkbox label="3">周三</el-checkbox>
                <el-checkbox label="4">周四</el-checkbox>
                <el-checkbox label="5">周五</el-checkbox>
                <el-checkbox label="6">周六</el-checkbox>
                <el-checkbox label="0">周日</el-checkbox>
              </el-checkbox-group>
            </el-form-item>

            <el-form-item label="节假日模式">
              <el-switch
                v-model="scheduleSettings.holidayMode"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>

            <el-form-item label="节假日时间" v-if="scheduleSettings.holidayMode">
              <el-date-picker
                v-model="scheduleSettings.holidays"
                type="dates"
                placeholder="选择节假日"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
              />
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="saveScheduleSettings" :loading="saving">
                保存设置
              </el-button>
              <el-button @click="resetScheduleSettings">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>

      <!-- 支付设置 -->
      <el-tab-pane label="支付设置" name="payment">
        <el-card class="setting-card">
          <template #header>
            <h3>支付配置</h3>
          </template>

          <el-form :model="paymentSettings" label-width="150px" class="setting-form">
            <el-form-item label="启用支付功能">
              <el-switch
                v-model="paymentSettings.enablePayment"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>

            <el-form-item label="默认费率(元/小时)">
              <el-input-number
                v-model="paymentSettings.defaultHourlyRate"
                :min="0"
                :step="0.1"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item label="最低消费金额(元)">
              <el-input-number
                v-model="paymentSettings.minimumAmount"
                :min="0"
                :step="0.1"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item label="钱包功能">
              <el-switch
                v-model="paymentSettings.enableWallet"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>

            <el-form-item label="免费试用时长(分钟)">
              <el-input-number
                v-model="paymentSettings.freeTrialMinutes"
                :min="0"
                :max="120"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item label="支付方式">
              <el-checkbox-group v-model="paymentSettings.paymentMethods">
                <el-checkbox label="wallet">钱包余额</el-checkbox>
                <el-checkbox label="alipay">支付宝</el-checkbox>
                <el-checkbox label="wechat">微信支付</el-checkbox>
                <el-checkbox label="bank">银行卡</el-checkbox>
              </el-checkbox-group>
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="savePaymentSettings" :loading="saving">
                保存设置
              </el-button>
              <el-button @click="resetPaymentSettings">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>

      <!-- 邮件设置 -->
      <el-tab-pane label="邮件设置" name="email">
        <el-card class="setting-card">
          <template #header>
            <h3>邮件服务配置</h3>
          </template>

          <el-form :model="emailSettings" label-width="120px" class="setting-form">
            <el-form-item label="启用邮件">
              <el-switch
                v-model="emailSettings.enableEmail"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>

            <el-form-item label="SMTP服务器">
              <el-input v-model="emailSettings.smtpHost" placeholder="请输入SMTP服务器地址" />
            </el-form-item>

            <el-form-item label="SMTP端口">
              <el-input-number
                v-model="emailSettings.smtpPort"
                :min="1"
                :max="65535"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item label="发送邮箱">
              <el-input v-model="emailSettings.senderEmail" placeholder="请输入发送邮箱" />
            </el-form-item>

            <el-form-item label="邮箱密码">
              <el-input
                v-model="emailSettings.senderPassword"
                type="password"
                placeholder="请输入邮箱密码"
                show-password
              />
            </el-form-item>

            <el-form-item label="启用SSL">
              <el-switch
                v-model="emailSettings.enableSSL"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>

            <el-form-item label="邮件模板">
              <el-select v-model="emailSettings.template" placeholder="选择邮件模板">
                <el-option label="默认模板" value="default" />
                <el-option label="简洁模板" value="simple" />
                <el-option label="商务模板" value="business" />
              </el-select>
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="saveEmailSettings" :loading="saving">
                保存设置
              </el-button>
              <el-button @click="testEmail" :loading="testing">测试邮件</el-button>
              <el-button @click="resetEmailSettings">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>

      <!-- 安全设置 -->
      <el-tab-pane label="安全设置" name="security">
        <el-card class="setting-card">
          <template #header>
            <h3>安全策略配置</h3>
          </template>

          <el-form :model="securitySettings" label-width="150px" class="setting-form">
            <el-form-item label="登录失败次数限制">
              <el-input-number
                v-model="securitySettings.maxLoginAttempts"
                :min="3"
                :max="10"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item label="账户锁定时间(分钟)">
              <el-input-number
                v-model="securitySettings.lockoutMinutes"
                :min="5"
                :max="1440"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item label="密码最小长度">
              <el-input-number
                v-model="securitySettings.minPasswordLength"
                :min="6"
                :max="20"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item label="密码复杂度">
              <el-checkbox-group v-model="securitySettings.passwordRequirements">
                <el-checkbox label="uppercase">包含大写字母</el-checkbox>
                <el-checkbox label="lowercase">包含小写字母</el-checkbox>
                <el-checkbox label="numbers">包含数字</el-checkbox>
                <el-checkbox label="symbols">包含特殊符号</el-checkbox>
              </el-checkbox-group>
            </el-form-item>

            <el-form-item label="会话超时(分钟)">
              <el-input-number
                v-model="securitySettings.sessionTimeout"
                :min="30"
                :max="480"
                controls-position="right"
              />
            </el-form-item>

            <el-form-item label="启用验证码">
              <el-switch
                v-model="securitySettings.enableCaptcha"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>

            <el-form-item label="IP白名单模式">
              <el-switch
                v-model="securitySettings.enableIPWhitelist"
                active-text="开启"
                inactive-text="关闭"
              />
            </el-form-item>

            <el-form-item label="允许的IP地址" v-if="securitySettings.enableIPWhitelist">
              <el-input
                v-model="securitySettings.allowedIPs"
                type="textarea"
                :rows="3"
                placeholder="请输入允许的IP地址，每行一个"
              />
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="saveSecuritySettings" :loading="saving">
                保存设置
              </el-button>
              <el-button @click="resetSecuritySettings">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

// 响应式数据
const activeSettingTab = ref('basic')
const saving = ref(false)
const testing = ref(false)

// 各种设置对象
const basicSettings = reactive({
  systemName: '自习室座位预约系统',
  systemDescription: '智能化的自习室座位预约管理系统',
  systemVersion: '1.0.0',
  contactEmail: 'admin@seatreservation.com',
  contactPhone: '400-123-4567',
  systemEnabled: true,
  maintenanceMode: false
})

const reservationSettings = reactive({
  maxHours: 8,
  advanceDays: 7,
  cancelHours: 2,
  autoConfirm: false,
  allowDuplicate: false,
  enableReminder: true,
  reminderMinutes: 30
})

const scheduleSettings = reactive({
  openTime: '08:00',
  closeTime: '22:00',
  restDays: [],
  holidayMode: false,
  holidays: []
})

const paymentSettings = reactive({
  enablePayment: true,
  defaultHourlyRate: 5.0,
  minimumAmount: 1.0,
  enableWallet: true,
  freeTrialMinutes: 30,
  paymentMethods: ['wallet', 'alipay', 'wechat']
})

const emailSettings = reactive({
  enableEmail: false,
  smtpHost: '',
  smtpPort: 587,
  senderEmail: '',
  senderPassword: '',
  enableSSL: true,
  template: 'default'
})

const securitySettings = reactive({
  maxLoginAttempts: 5,
  lockoutMinutes: 30,
  minPasswordLength: 6,
  passwordRequirements: ['lowercase', 'numbers'],
  sessionTimeout: 120,
  enableCaptcha: false,
  enableIPWhitelist: false,
  allowedIPs: ''
})

// 加载系统设置
const loadSystemSettings = async () => {
  try {
    console.log('正在加载系统设置')
    const response = await request.get('/system/settings')
    console.log('系统设置响应:', response)

    if (response && response.code === 200) {
      const data = response.data
      // 更新各种设置
      if (data.basic) Object.assign(basicSettings, data.basic)
      if (data.reservation) Object.assign(reservationSettings, data.reservation)
      if (data.schedule) Object.assign(scheduleSettings, data.schedule)
      if (data.payment) Object.assign(paymentSettings, data.payment)
      if (data.email) Object.assign(emailSettings, data.email)
      if (data.security) Object.assign(securitySettings, data.security)
    }
  } catch (error) {
    console.error('加载系统设置失败:', error)
    ElMessage.error('加载设置失败，使用默认设置')
  }
}

// 保存设置的通用方法
const saveSettings = async (settingsType, settings) => {
  saving.value = true
  try {
    console.log(`正在保存${settingsType}设置:`, settings)
    const response = await request.put(`/system/settings/${settingsType}`, settings)
    console.log(`${settingsType}设置保存响应:`, response)

    if (response && response.code === 200) {
      ElMessage.success('设置保存成功')
    } else {
      throw new Error(response?.message || '保存失败')
    }
  } catch (error) {
    console.error(`保存${settingsType}设置失败:`, error)
    ElMessage.error('保存失败: ' + (error.message || '未知错误'))
  } finally {
    saving.value = false
  }
}

// 各种设置的保存方法
const saveBasicSettings = () => saveSettings('basic', basicSettings)
const saveReservationSettings = () => saveSettings('reservation', reservationSettings)
const saveScheduleSettings = () => saveSettings('schedule', scheduleSettings)
const savePaymentSettings = () => saveSettings('payment', paymentSettings)
const saveEmailSettings = () => saveSettings('email', emailSettings)
const saveSecuritySettings = () => saveSettings('security', securitySettings)

// 重置设置的方法
const resetBasicSettings = () => {
  Object.assign(basicSettings, {
    systemName: '自习室座位预约系统',
    systemDescription: '智能化的自习室座位预约管理系统',
    systemVersion: '1.0.0',
    contactEmail: 'admin@seatreservation.com',
    contactPhone: '400-123-4567',
    systemEnabled: true,
    maintenanceMode: false
  })
}

const resetReservationSettings = () => {
  Object.assign(reservationSettings, {
    maxHours: 8,
    advanceDays: 7,
    cancelHours: 2,
    autoConfirm: false,
    allowDuplicate: false,
    enableReminder: true,
    reminderMinutes: 30
  })
}

const resetScheduleSettings = () => {
  Object.assign(scheduleSettings, {
    openTime: '08:00',
    closeTime: '22:00',
    restDays: [],
    holidayMode: false,
    holidays: []
  })
}

const resetPaymentSettings = () => {
  Object.assign(paymentSettings, {
    enablePayment: true,
    defaultHourlyRate: 5.0,
    minimumAmount: 1.0,
    enableWallet: true,
    freeTrialMinutes: 30,
    paymentMethods: ['wallet', 'alipay', 'wechat']
  })
}

const resetEmailSettings = () => {
  Object.assign(emailSettings, {
    enableEmail: false,
    smtpHost: '',
    smtpPort: 587,
    senderEmail: '',
    senderPassword: '',
    enableSSL: true,
    template: 'default'
  })
}

const resetSecuritySettings = () => {
  Object.assign(securitySettings, {
    maxLoginAttempts: 5,
    lockoutMinutes: 30,
    minPasswordLength: 6,
    passwordRequirements: ['lowercase', 'numbers'],
    sessionTimeout: 120,
    enableCaptcha: false,
    enableIPWhitelist: false,
    allowedIPs: ''
  })
}

// 测试邮件
const testEmail = async () => {
  testing.value = true
  try {
    console.log('正在测试邮件发送')
    const response = await request.post('/system/settings/email/test')
    console.log('测试邮件响应:', response)

    if (response && response.code === 200) {
      ElMessage.success('测试邮件发送成功')
    } else {
      throw new Error(response?.message || '测试邮件发送失败')
    }
  } catch (error) {
    console.error('测试邮件失败:', error)
    ElMessage.error('测试邮件失败: ' + (error.message || '未知错误'))
  } finally {
    testing.value = false
  }
}

// 组件挂载时加载设置
onMounted(() => {
  loadSystemSettings()
})
</script>

<style scoped>
.settings-management {
  padding: 0;
}

.page-header {
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #2c3e50;
}

.settings-tabs {
  min-height: 600px;
}

.setting-card {
  border-radius: 8px;
  margin-bottom: 20px;
}

.setting-card h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
}

.setting-form {
  padding: 20px;
}

.setting-form .el-form-item {
  margin-bottom: 24px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .settings-tabs {
    min-height: auto;
  }

  :deep(.el-tabs--left .el-tabs__header) {
    width: 120px;
  }

  :deep(.el-tabs--left .el-tabs__content) {
    padding-left: 140px;
  }

  .setting-form {
    padding: 16px;
  }

  .setting-form .el-form-item {
    margin-bottom: 20px;
  }
}

@media (max-width: 480px) {
  :deep(.el-tabs--left) {
    display: block;
  }

  :deep(.el-tabs--left .el-tabs__header) {
    width: 100%;
    margin-bottom: 20px;
  }

  :deep(.el-tabs--left .el-tabs__content) {
    padding-left: 0;
  }

  :deep(.el-tabs--left .el-tabs__nav-wrap) {
    margin-bottom: 0;
  }
}
</style>