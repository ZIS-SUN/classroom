<template>
  <div v-if="visible" class="modal-overlay" @click="handleCancel">
    <div class="payment-dialog" @click.stop>
      <div class="dialog-header">
        <h3>确认支付</h3>
        <button @click="handleCancel" class="close-btn">×</button>
      </div>
      
      <div class="dialog-body">
        <!-- 订单信息 -->
        <div class="order-info">
          <h4>预约信息</h4>
          <div class="info-item">
            <span class="label">座位：</span>
            <span class="value">{{ seatInfo }}</span>
          </div>
          <div class="info-item">
            <span class="label">时间：</span>
            <span class="value">{{ reservationTime }}</span>
          </div>
          <div class="info-item">
            <span class="label">金额：</span>
            <span class="value amount">￥{{ amount }}</span>
          </div>
        </div>
        
        <!-- 钱包余额 -->
        <div class="wallet-info">
          <div class="balance-display">
            <span class="label">钱包余额：</span>
            <span class="balance">￥{{ walletBalance }}</span>
          </div>
          <div v-if="walletBalance < amount" class="insufficient-balance">
            余额不足，请充值后再支付
          </div>
        </div>
        
        <!-- 支付方式选择 -->
        <div class="payment-methods">
          <h4>选择支付方式</h4>
          <div class="method-list">
            <div 
              :class="['method-item', { 
                selected: selectedMethod === 'WALLET',
                disabled: walletBalance < amount 
              }]"
              @click="selectMethod('WALLET')"
            >
              <div class="method-icon wallet-icon">💳</div>
              <div class="method-info">
                <div class="method-name">钱包支付</div>
                <div class="method-desc">余额: ￥{{ walletBalance }}</div>
              </div>
              <div class="method-radio">
                <input 
                  type="radio" 
                  :checked="selectedMethod === 'WALLET'"
                  :disabled="walletBalance < amount"
                />
              </div>
            </div>
            
            <div 
              :class="['method-item', { selected: selectedMethod === 'WECHAT' }]"
              @click="selectMethod('WECHAT')"
            >
              <div class="method-icon wechat-icon">💬</div>
              <div class="method-info">
                <div class="method-name">微信支付</div>
                <div class="method-desc">使用微信安全支付</div>
              </div>
              <div class="method-radio">
                <input type="radio" :checked="selectedMethod === 'WECHAT'" />
              </div>
            </div>
            
            <div 
              :class="['method-item', { selected: selectedMethod === 'ALIPAY' }]"
              @click="selectMethod('ALIPAY')"
            >
              <div class="method-icon alipay-icon">🅰️</div>
              <div class="method-info">
                <div class="method-name">支付宝</div>
                <div class="method-desc">支付宝安全快捷支付</div>
              </div>
              <div class="method-radio">
                <input type="radio" :checked="selectedMethod === 'ALIPAY'" />
              </div>
            </div>
            
            <div 
              :class="['method-item', { selected: selectedMethod === 'BANK_CARD' }]"
              @click="selectMethod('BANK_CARD')"
            >
              <div class="method-icon bank-icon">🏦</div>
              <div class="method-info">
                <div class="method-name">银行卡支付</div>
                <div class="method-desc">支持各大银行储蓄卡</div>
              </div>
              <div class="method-radio">
                <input type="radio" :checked="selectedMethod === 'BANK_CARD'" />
              </div>
            </div>
          </div>
        </div>
        
        <!-- 支付协议 -->
        <div class="payment-agreement">
          <label class="agreement-checkbox">
            <input type="checkbox" v-model="agreeTerms" />
            <span class="checkmark"></span>
            我已阅读并同意<a href="#" @click.prevent>《支付服务协议》</a>
          </label>
        </div>
      </div>
      
      <div class="dialog-footer">
        <button @click="handleCancel" class="cancel-btn">取消</button>
        <button 
          @click="handleConfirm" 
          :disabled="!selectedMethod || !agreeTerms || loading"
          class="confirm-btn"
        >
          {{ loading ? '支付中...' : `确认支付 ￥${amount}` }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch } from 'vue'
import api from '@/utils/api'

export default {
  name: 'PaymentDialog',
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    seatId: {
      type: Number,
      required: true
    },
    seatInfo: {
      type: String,
      required: true
    },
    reservationTime: {
      type: String,
      required: true
    },
    amount: {
      type: Number,
      required: true
    },
    reservationId: {
      type: Number,
      default: null
    }
  },
  emits: ['cancel', 'success', 'error'],
  setup(props, { emit }) {
    const selectedMethod = ref('')
    const agreeTerms = ref(false)
    const loading = ref(false)
    const walletBalance = ref(0)
    
    // 加载钱包余额
    const loadWalletBalance = async () => {
      try {
        const response = await api.get('/payment/wallet')
        if (response && response.code === 200) {
          walletBalance.value = response.data.balance || 0
        } else {
          console.warn('钱包余额接口返回格式异常:', response)
          walletBalance.value = 0
        }
      } catch (error) {
        console.error('加载钱包余额失败:', error)
        walletBalance.value = 0
      }
    }
    
    // 选择支付方式
    const selectMethod = (method) => {
      if (method === 'WALLET' && walletBalance.value < props.amount) {
        return
      }
      selectedMethod.value = method
    }
    
    // 确认支付
    const handleConfirm = async () => {
      if (!selectedMethod.value || !agreeTerms.value) {
        return
      }
      
      loading.value = true
      try {
        let paymentOrder = null
        
        // 检查预约ID是否存在
        if (!props.reservationId) {
          console.error('预约ID为空，无法创建支付订单')
          emit('error', '预约信息异常，请重新预约座位')
          return
        }
        
        // 创建支付订单
        const createResponse = await api.post('/payment/create-order', {
          reservationId: props.reservationId,
          amount: props.amount,
          paymentMethod: selectedMethod.value
        })
        
        if (!createResponse || createResponse.code !== 200) {
          emit('error', '创建支付订单失败: ' + (createResponse?.message || '服务器错误'))
          return
        }
        
        paymentOrder = createResponse.data
        
        // 处理支付
        const processResponse = await api.post('/payment/process', {
          orderNo: paymentOrder.orderNo,
          paymentMethod: selectedMethod.value
        })
        
        if (processResponse && processResponse.code === 200) {
          emit('success', {
            orderNo: paymentOrder.orderNo,
            amount: props.amount,
            paymentMethod: selectedMethod.value
          })
        } else {
          emit('error', '支付失败: ' + (processResponse?.message || '支付处理异常'))
        }
        
      } catch (error) {
        console.error('支付处理失败:', error)
        emit('error', '支付处理失败，请稍后重试')
      } finally {
        loading.value = false
      }
    }
    
    // 取消支付
    const handleCancel = () => {
      emit('cancel')
    }
    
    // 监听对话框显示状态
    watch(() => props.visible, (newVal) => {
      if (newVal) {
        loadWalletBalance()
        selectedMethod.value = ''
        agreeTerms.value = false
      }
    })
    
    return {
      selectedMethod,
      agreeTerms,
      loading,
      walletBalance,
      selectMethod,
      handleConfirm,
      handleCancel
    }
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(66, 66, 66, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.payment-dialog {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 480px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(66, 66, 66, 0.3);
}

.dialog-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 20px 15px;
  border-bottom: 1px solid #f0f0f0;
}

.dialog-header h3 {
  margin: 0;
  color: #333;
  font-size: 18px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  color: #999;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  color: #666;
}

.dialog-body {
  padding: 20px;
}

.order-info {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.order-info h4 {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 16px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.info-item:last-child {
  margin-bottom: 0;
}

.info-item .label {
  color: #666;
}

.info-item .value {
  color: #333;
  font-weight: 500;
}

.info-item .amount {
  color: #f56c6c;
  font-size: 18px;
  font-weight: bold;
}

.wallet-info {
  background: #e8f5e8;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.balance-display {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.balance-display .label {
  color: #666;
}

.balance-display .balance {
  color: #67c23a;
  font-weight: bold;
  font-size: 16px;
}

.insufficient-balance {
  color: #f56c6c;
  font-size: 14px;
  margin-top: 8px;
  text-align: center;
}

.payment-methods h4 {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 16px;
}

.method-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.method-item {
  display: flex;
  align-items: center;
  padding: 15px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.method-item:hover:not(.disabled) {
  border-color: #409eff;
  background: #f0f8ff;
}

.method-item.selected {
  border-color: #409eff;
  background: #f0f8ff;
}

.method-item.disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background: #f5f5f5;
}

.method-icon {
  font-size: 24px;
  margin-right: 12px;
  width: 40px;
  text-align: center;
}

.method-info {
  flex: 1;
}

.method-name {
  font-weight: 500;
  color: #333;
  margin-bottom: 4px;
}

.method-desc {
  font-size: 12px;
  color: #999;
}

.method-radio {
  margin-left: 12px;
}

.method-radio input[type="radio"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

.payment-agreement {
  margin: 20px 0;
  text-align: center;
}

.agreement-checkbox {
  display: inline-flex;
  align-items: center;
  cursor: pointer;
  font-size: 14px;
  color: #666;
}

.agreement-checkbox input[type="checkbox"] {
  margin-right: 8px;
}

.agreement-checkbox a {
  color: #409eff;
  text-decoration: none;
}

.agreement-checkbox a:hover {
  text-decoration: underline;
}

.dialog-footer {
  display: flex;
  justify-content: space-between;
  gap: 15px;
  padding: 15px 20px 20px;
  border-top: 1px solid #f0f0f0;
}

.cancel-btn, .confirm-btn {
  flex: 1;
  padding: 12px 0;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.cancel-btn {
  background: #f5f5f5;
  color: #666;
}

.cancel-btn:hover {
  background: #e0e0e0;
}

.confirm-btn {
  background: #409eff;
  color: white;
}

.confirm-btn:hover:not(:disabled) {
  background: #337ecc;
}

.confirm-btn:disabled {
  background: #c0c4cc;
  cursor: not-allowed;
}

/* 图标样式 */
.wallet-icon { color: #67c23a; }
.wechat-icon { color: #1aad19; }
.alipay-icon { color: #1677ff; }
.bank-icon { color: #e6a23c; }
</style>