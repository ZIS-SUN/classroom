<template>
  <div class="wallet-balance">
    <div class="balance-card">
      <h3>我的钱包</h3>
      <div class="balance-info">
        <div class="balance-amount">
          <span class="currency">￥</span>
          <span class="amount">{{ balance }}</span>
        </div>
        <div class="balance-stats">
          <div class="stat-item">
            <span class="label">累计充值</span>
            <span class="value">￥{{ totalRecharge }}</span>
          </div>
          <div class="stat-item">
            <span class="label">累计消费</span>
            <span class="value">￥{{ totalConsume }}</span>
          </div>
        </div>
      </div>
      <div class="wallet-actions">
        <button @click="showRechargeDialog = true" class="recharge-btn">
          <i class="icon-plus">+</i>
          充值
        </button>
        <button @click="showRecordsDialog = true" class="records-btn">
          <i class="icon-list">≡</i>
          明细
        </button>
      </div>
    </div>

    <!-- 充值对话框 -->
    <div v-if="showRechargeDialog" class="modal-overlay" @click="showRechargeDialog = false">
      <div class="modal-dialog" @click.stop>
        <div class="modal-header">
          <h4>钱包充值</h4>
          <button @click="showRechargeDialog = false" class="close-btn">×</button>
        </div>
        <div class="modal-body">
          <div class="recharge-amounts">
            <div class="amount-options">
              <div 
                v-for="option in rechargeOptions" 
                :key="option.amount"
                :class="['amount-option', { selected: rechargeAmount === option.amount }]"
                @click="rechargeAmount = option.amount"
              >
                <span class="amount">￥{{ option.amount }}</span>
                <span v-if="option.bonus > 0" class="bonus">送{{ option.bonus }}元</span>
              </div>
            </div>
            <div class="custom-amount">
              <label>自定义金额:</label>
              <input 
                v-model="rechargeAmount" 
                type="number" 
                placeholder="请输入充值金额"
                min="1"
                max="10000"
              />
            </div>
          </div>
          <div class="payment-methods">
            <h5>选择支付方式</h5>
            <div class="method-options">
              <div 
                v-for="method in paymentMethods" 
                :key="method.value"
                :class="['method-option', { selected: paymentMethod === method.value }]"
                @click="paymentMethod = method.value"
              >
                <i :class="method.icon"></i>
                <span>{{ method.label }}</span>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button @click="showRechargeDialog = false" class="cancel-btn">取消</button>
          <button @click="handleRecharge" :disabled="!rechargeAmount || !paymentMethod || loading" class="confirm-btn">
            {{ loading ? '处理中...' : '确认充值' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 交易明细对话框 -->
    <div v-if="showRecordsDialog" class="modal-overlay" @click="showRecordsDialog = false">
      <div class="modal-dialog records-dialog" @click.stop>
        <div class="modal-header">
          <h4>交易明细</h4>
          <button @click="showRecordsDialog = false" class="close-btn">×</button>
        </div>
        <div class="modal-body">
          <div class="records-tabs">
            <button 
              :class="['tab-btn', { active: activeTab === 'payment' }]"
              @click="activeTab = 'payment'; loadPaymentRecords()"
            >支付记录</button>
            <button 
              :class="['tab-btn', { active: activeTab === 'recharge' }]"
              @click="activeTab = 'recharge'; loadRechargeRecords()"
            >充值记录</button>
          </div>
          <div class="records-content">
            <div v-if="activeTab === 'payment'" class="payment-records">
              <div v-if="paymentRecords.length === 0" class="empty-state">暂无支付记录</div>
              <div v-else class="record-list">
                <div v-for="record in paymentRecords" :key="record.id" class="record-item">
                  <div class="record-info">
                    <div class="record-title">座位预约支付</div>
                    <div class="record-time">{{ formatTime(record.createdTime) }}</div>
                    <div class="record-order">订单号: {{ record.orderNo }}</div>
                  </div>
                  <div class="record-amount">
                    <span class="amount">-￥{{ record.amount }}</span>
                    <span :class="['status', record.paymentStatus.toLowerCase()]">
                      {{ getPaymentStatusText(record.paymentStatus) }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
            <div v-if="activeTab === 'recharge'" class="recharge-records">
              <div v-if="rechargeRecords.length === 0" class="empty-state">暂无充值记录</div>
              <div v-else class="record-list">
                <div v-for="record in rechargeRecords" :key="record.id" class="record-item">
                  <div class="record-info">
                    <div class="record-title">钱包充值</div>
                    <div class="record-time">{{ formatTime(record.createdTime) }}</div>
                    <div class="record-order">订单号: {{ record.orderNo }}</div>
                  </div>
                  <div class="record-amount">
                    <span class="amount">+￥{{ record.amount }}</span>
                    <span v-if="record.bonusAmount > 0" class="bonus">+{{ record.bonusAmount }}元</span>
                    <span :class="['status', record.paymentStatus.toLowerCase()]">
                      {{ getPaymentStatusText(record.paymentStatus) }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { useUserStore } from '../stores/user'
import api from '@/utils/api'

export default {
  name: 'WalletBalance',
  setup() {
    const userStore = useUserStore()
    
    const balance = ref('0.00')
    const totalRecharge = ref('0.00')
    const totalConsume = ref('0.00')
    const showRechargeDialog = ref(false)
    const showRecordsDialog = ref(false)
    const loading = ref(false)
    
    const rechargeAmount = ref('')
    const paymentMethod = ref('')
    
    const activeTab = ref('payment')
    const paymentRecords = ref([])
    const rechargeRecords = ref([])
    
    const rechargeOptions = [
      { amount: 50, bonus: 5 },
      { amount: 100, bonus: 10 },
      { amount: 200, bonus: 30 },
      { amount: 500, bonus: 80 }
    ]
    
    const paymentMethods = [
      { value: 'WECHAT', label: '微信支付', icon: 'icon-wechat' },
      { value: 'ALIPAY', label: '支付宝', icon: 'icon-alipay' },
      { value: 'BANK_CARD', label: '银行卡', icon: 'icon-bank' }
    ]
    
    // 加载钱包信息
    const loadWalletInfo = async () => {
      try {
        const response = await api.get('/payment/wallet')
        if (response && response.code === 200) {
          const wallet = response.data
          balance.value = (wallet?.balance || 0).toFixed(2)
          totalRecharge.value = (wallet?.totalRecharge || 0).toFixed(2)
          totalConsume.value = (wallet?.totalConsume || 0).toFixed(2)
        } else {
          console.warn('钱包信息接口返回格式异常:', response)
          balance.value = '0.00'
          totalRecharge.value = '0.00'
          totalConsume.value = '0.00'
        }
      } catch (error) {
        console.error('加载钱包信息失败:', error)
        balance.value = '0.00'
        totalRecharge.value = '0.00'
        totalConsume.value = '0.00'
      }
    }
    
    // 处理充值
    const handleRecharge = async () => {
      if (!rechargeAmount.value || !paymentMethod.value) {
        alert('请输入充值金额并选择支付方式')
        return
      }
      
      if (parseFloat(rechargeAmount.value) < 1) {
        alert('充值金额不能少于1元')
        return
      }
      
      loading.value = true
      try {
        // 创建充值订单
        const createResponse = await api.post('/payment/recharge/create-order', {
          amount: parseFloat(rechargeAmount.value),
          paymentMethod: paymentMethod.value
        })
        
        if (createResponse && createResponse.code === 200) {
          // 处理充值
          const processResponse = await api.post('/payment/recharge/process', {
            orderNo: createResponse.data.orderNo,
            paymentMethod: paymentMethod.value
          })
          
          if (processResponse && processResponse.code === 200) {
            alert('充值成功！')
            showRechargeDialog.value = false
            rechargeAmount.value = ''
            paymentMethod.value = ''
            await loadWalletInfo()
          } else {
            alert('充值失败: ' + (processResponse?.message || '处理失败'))
          }
        } else {
          alert('创建充值订单失败: ' + (createResponse?.message || '创建失败'))
        }
      } catch (error) {
        console.error('充值失败:', error)
        alert('充值失败，请稍后重试')
      } finally {
        loading.value = false
      }
    }
    
    // 加载支付记录
    const loadPaymentRecords = async () => {
      try {
        const response = await api.get('/payment/records?current=1&size=20')
        if (response.code === 200) {
          paymentRecords.value = response.data
        }
      } catch (error) {
        console.error('加载支付记录失败:', error)
      }
    }
    
    // 加载充值记录
    const loadRechargeRecords = async () => {
      try {
        const response = await api.get('/payment/recharge/records?current=1&size=20')
        if (response.code === 200) {
          rechargeRecords.value = response.data
        }
      } catch (error) {
        console.error('加载充值记录失败:', error)
      }
    }
    
    const formatTime = (timeStr) => {
      return new Date(timeStr).toLocaleString('zh-CN')
    }
    
    const getPaymentStatusText = (status) => {
      const statusMap = {
        'PENDING': '处理中',
        'SUCCESS': '成功',
        'FAILED': '失败',
        'REFUNDED': '已退款'
      }
      return statusMap[status] || status
    }
    
    onMounted(() => {
      loadWalletInfo()
    })
    
    return {
      balance,
      totalRecharge,
      totalConsume,
      showRechargeDialog,
      showRecordsDialog,
      loading,
      rechargeAmount,
      paymentMethod,
      rechargeOptions,
      paymentMethods,
      activeTab,
      paymentRecords,
      rechargeRecords,
      handleRecharge,
      loadPaymentRecords,
      loadRechargeRecords,
      formatTime,
      getPaymentStatusText
    }
  }
}
</script>

<style scoped>
.wallet-balance {
  margin: 20px 0;
}

.balance-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(66,66,66,0.1);
}

.balance-card h3 {
  margin: 0 0 15px 0;
  font-size: 18px;
  font-weight: 500;
}

.balance-info {
  margin-bottom: 20px;
}

.balance-amount {
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 15px;
}

.currency {
  font-size: 24px;
  margin-right: 5px;
}

.balance-stats {
  display: flex;
  justify-content: space-between;
}

.stat-item {
  text-align: center;
}

.stat-item .label {
  display: block;
  font-size: 12px;
  opacity: 0.8;
  margin-bottom: 5px;
}

.stat-item .value {
  font-size: 16px;
  font-weight: 500;
}

.wallet-actions {
  display: flex;
  gap: 15px;
}

.recharge-btn, .records-btn {
  flex: 1;
  padding: 10px 15px;
  border: 1px solid rgba(255,255,255,0.3);
  background: rgba(255,255,255,0.1);
  color: white;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
  transition: all 0.3s ease;
}

.recharge-btn:hover, .records-btn:hover {
  background: rgba(255,255,255,0.2);
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(66,66,66,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-dialog {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 500px;
  max-height: 80vh;
  overflow-y: auto;
}

.records-dialog {
  max-width: 600px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #eee;
}

.modal-header h4 {
  margin: 0;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  color: #999;
  cursor: pointer;
}

.modal-body {
  padding: 20px;
}

.amount-options {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
  margin-bottom: 15px;
}

.amount-option {
  padding: 15px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
}

.amount-option.selected {
  border-color: #667eea;
  background: #f0f3ff;
}

.amount-option .amount {
  display: block;
  font-size: 18px;
  font-weight: bold;
  color: #333;
}

.amount-option .bonus {
  display: block;
  font-size: 12px;
  color: #ff6b6b;
  margin-top: 5px;
}

.custom-amount {
  margin: 15px 0;
}

.custom-amount label {
  display: block;
  margin-bottom: 8px;
  color: #666;
}

.custom-amount input {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 16px;
  box-sizing: border-box;
}

.payment-methods h5 {
  margin: 20px 0 10px 0;
  color: #333;
}

.method-options {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.method-option {
  padding: 15px 10px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
}

.method-option.selected {
  border-color: #667eea;
  background: #f0f3ff;
}

.method-option i {
  display: block;
  font-size: 24px;
  margin-bottom: 8px;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  padding: 20px;
  border-top: 1px solid #eee;
}

.cancel-btn, .confirm-btn {
  padding: 10px 20px;
  border: 1px solid #ddd;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
}

.cancel-btn {
  background: white;
  color: #666;
}

.confirm-btn {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.confirm-btn:disabled {
  background: #ccc;
  border-color: #ccc;
  cursor: not-allowed;
}

.records-tabs {
  display: flex;
  border-bottom: 1px solid #eee;
  margin-bottom: 15px;
}

.tab-btn {
  flex: 1;
  padding: 10px 15px;
  background: none;
  border: none;
  cursor: pointer;
  font-size: 14px;
  color: #666;
  border-bottom: 2px solid transparent;
}

.tab-btn.active {
  color: #667eea;
  border-bottom-color: #667eea;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: #999;
}

.record-list {
  max-height: 300px;
  overflow-y: auto;
}

.record-item {
  display: flex;
  justify-content: space-between;
  padding: 15px 0;
  border-bottom: 1px solid #f0f0f0;
}

.record-item:last-child {
  border-bottom: none;
}

.record-info {
  flex: 1;
}

.record-title {
  font-weight: 500;
  color: #333;
  margin-bottom: 5px;
}

.record-time, .record-order {
  font-size: 12px;
  color: #999;
  margin-bottom: 3px;
}

.record-amount {
  text-align: right;
}

.record-amount .amount {
  display: block;
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.record-amount .bonus {
  display: block;
  font-size: 12px;
  color: #ff6b6b;
  margin-bottom: 5px;
}

.record-amount .status {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 12px;
}

.status.success {
  background: #d4edda;
  color: #155724;
}

.status.pending {
  background: #fff3cd;
  color: #856404;
}

.status.failed {
  background: #f8d7da;
  color: #721c24;
}

.status.refunded {
  background: #d1ecf1;
  color: #0c5460;
}
</style>