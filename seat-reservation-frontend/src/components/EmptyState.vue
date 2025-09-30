<template>
  <div class="empty-state" :class="[size, theme]">
    <div class="empty-illustration">
      <div class="empty-icon">
        <i v-if="customIcon" :class="customIcon"></i>
        <component v-else :is="iconComponent" />
      </div>
      <div class="empty-background"></div>
    </div>

    <div class="empty-content">
      <h3 class="empty-title">{{ title || defaultTitle }}</h3>
      <p class="empty-description">{{ description || defaultDescription }}</p>

      <div v-if="showActions" class="empty-actions">
        <el-button
          v-if="primaryAction"
          type="primary"
          :size="actionSize"
          @click="handlePrimaryAction"
          class="primary-action"
        >
          <i v-if="primaryAction.icon" :class="primaryAction.icon"></i>
          {{ primaryAction.text }}
        </el-button>

        <el-button
          v-if="secondaryAction"
          :size="actionSize"
          @click="handleSecondaryAction"
          class="secondary-action"
        >
          <i v-if="secondaryAction.icon" :class="secondaryAction.icon"></i>
          {{ secondaryAction.text }}
        </el-button>
      </div>

      <div v-if="tips && tips.length" class="empty-tips">
        <h4>您可以尝试：</h4>
        <ul class="tips-list">
          <li v-for="(tip, index) in tips" :key="index" class="tip-item">
            <i class="el-icon-lightbulb"></i>
            <span>{{ tip }}</span>
          </li>
        </ul>
      </div>
    </div>

    <div v-if="showFooter" class="empty-footer">
      <slot name="footer">
        <p class="footer-text">需要帮助？ <a href="#" @click.prevent="showHelp">查看使用指南</a></p>
      </slot>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const props = defineProps({
  // 空状态类型
  type: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'no-data', 'no-search', 'no-favorites', 'no-reservations', 'no-seats', 'network-error', 'permission-denied'].includes(value)
  },
  // 自定义图标
  customIcon: {
    type: String,
    default: ''
  },
  // 标题
  title: {
    type: String,
    default: ''
  },
  // 描述
  description: {
    type: String,
    default: ''
  },
  // 尺寸
  size: {
    type: String,
    default: 'medium',
    validator: (value) => ['small', 'medium', 'large'].includes(value)
  },
  // 主题
  theme: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'warm', 'cool', 'minimal'].includes(value)
  },
  // 主要操作
  primaryAction: {
    type: Object,
    default: null
  },
  // 次要操作
  secondaryAction: {
    type: Object,
    default: null
  },
  // 提示信息
  tips: {
    type: Array,
    default: () => []
  },
  // 是否显示操作按钮
  showActions: {
    type: Boolean,
    default: true
  },
  // 是否显示底部
  showFooter: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['primary-action', 'secondary-action', 'help'])

// 根据类型获取默认配置
const typeConfig = {
  'default': {
    icon: 'el-icon-document',
    title: '暂无数据',
    description: '当前没有可显示的内容'
  },
  'no-data': {
    icon: 'el-icon-folder-opened',
    title: '暂无数据',
    description: '还没有任何记录，快去添加一些内容吧'
  },
  'no-search': {
    icon: 'el-icon-search',
    title: '没有找到相关内容',
    description: '请尝试调整搜索条件或关键词'
  },
  'no-favorites': {
    icon: 'el-icon-star-off',
    title: '还没有收藏任何座位',
    description: '发现心仪的座位时，点击收藏按钮将其加入收藏夹'
  },
  'no-reservations': {
    icon: 'el-icon-calendar',
    title: '暂无预约记录',
    description: '您还没有任何座位预约，快去选择合适的座位吧'
  },
  'no-seats': {
    icon: 'el-icon-office-building',
    title: '暂无可用座位',
    description: '当前时间段没有可用座位，请尝试选择其他时间'
  },
  'network-error': {
    icon: 'el-icon-warning-outline',
    title: '网络连接异常',
    description: '请检查网络连接后重试'
  },
  'permission-denied': {
    icon: 'el-icon-lock',
    title: '权限不足',
    description: '您没有访问此内容的权限'
  }
}

const config = computed(() => typeConfig[props.type] || typeConfig.default)

const iconComponent = computed(() => props.customIcon || config.value.icon)
const defaultTitle = computed(() => config.value.title)
const defaultDescription = computed(() => config.value.description)

const actionSize = computed(() => {
  const sizeMap = {
    small: 'small',
    medium: 'default',
    large: 'large'
  }
  return sizeMap[props.size] || 'default'
})

const handlePrimaryAction = () => {
  if (props.primaryAction?.action) {
    if (typeof props.primaryAction.action === 'string') {
      router.push(props.primaryAction.action)
    } else if (typeof props.primaryAction.action === 'function') {
      props.primaryAction.action()
    }
  }
  emit('primary-action')
}

const handleSecondaryAction = () => {
  if (props.secondaryAction?.action) {
    if (typeof props.secondaryAction.action === 'string') {
      router.push(props.secondaryAction.action)
    } else if (typeof props.secondaryAction.action === 'function') {
      props.secondaryAction.action()
    }
  }
  emit('secondary-action')
}

const showHelp = () => {
  emit('help')
}
</script>

<style scoped>
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: var(--spacing-2xl);
  min-height: 300px;
  position: relative;
}

.empty-state.small {
  min-height: 200px;
  padding: var(--spacing-xl);
}

.empty-state.large {
  min-height: 400px;
  padding: var(--spacing-3xl);
}

/* 主题样式 */
.empty-state.warm {
  background: linear-gradient(135deg, rgba(251, 191, 36, 0.03) 0%, rgba(245, 158, 11, 0.03) 100%);
}

.empty-state.cool {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.03) 0%, rgba(16, 185, 129, 0.03) 100%);
}

.empty-state.minimal {
  background: transparent;
}

/* 插图区域 */
.empty-illustration {
  position: relative;
  margin-bottom: var(--spacing-xl);
}

.empty-icon {
  width: 120px;
  height: 120px;
  margin: 0 auto;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--color-background-secondary) 0%, var(--color-background-tertiary) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 48px;
  color: var(--color-text-tertiary);
  position: relative;
  z-index: 2;
  box-shadow: 0 8px 32px rgba(66, 66, 66, 0.06);
  transition: var(--transition-base);
}

.empty-state.small .empty-icon {
  width: 80px;
  height: 80px;
  font-size: 32px;
}

.empty-state.large .empty-icon {
  width: 160px;
  height: 160px;
  font-size: 64px;
}

.empty-background {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 200px;
  height: 200px;
  background: radial-gradient(circle, rgba(var(--color-primary-rgb, 102, 126, 234), 0.05) 0%, transparent 70%);
  border-radius: 50%;
  animation: pulse 3s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: translate(-50%, -50%) scale(1);
    opacity: 0.5;
  }
  50% {
    transform: translate(-50%, -50%) scale(1.1);
    opacity: 0.3;
  }
}

/* 内容区域 */
.empty-content {
  max-width: 400px;
  width: 100%;
}

.empty-title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text-primary);
  margin: 0 0 var(--spacing-base) 0;
  line-height: var(--line-height-tight);
}

.empty-state.small .empty-title {
  font-size: var(--font-size-lg);
}

.empty-state.large .empty-title {
  font-size: var(--font-size-2xl);
}

.empty-description {
  font-size: var(--font-size-base);
  color: var(--color-text-secondary);
  margin: 0 0 var(--spacing-xl) 0;
  line-height: var(--line-height-relaxed);
}

.empty-state.small .empty-description {
  font-size: var(--font-size-sm);
}

/* 操作按钮 */
.empty-actions {
  display: flex;
  gap: var(--spacing-base);
  justify-content: center;
  margin-bottom: var(--spacing-xl);
  flex-wrap: wrap;
}

.primary-action {
  min-width: 120px;
  height: 40px;
  border-radius: var(--radius-md);
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
  border: none;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  transition: var(--transition-base);
}

.primary-action:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.primary-action i {
  margin-right: var(--spacing-xs);
}

.secondary-action {
  min-width: 100px;
  height: 40px;
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border);
  background: var(--color-background-primary);
  transition: var(--transition-base);
}

.secondary-action:hover {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

.secondary-action i {
  margin-right: var(--spacing-xs);
}

/* 提示信息 */
.empty-tips {
  margin: var(--spacing-xl) 0;
  text-align: left;
  background: var(--color-background-secondary);
  border-radius: var(--radius-lg);
  padding: var(--spacing-lg);
  border: 1px solid var(--color-border);
}

.empty-tips h4 {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-primary);
  margin: 0 0 var(--spacing-base) 0;
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
}

.empty-tips h4::before {
  content: '💡';
  font-size: 16px;
}

.tips-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.tip-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  margin-bottom: var(--spacing-sm);
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  line-height: var(--line-height-relaxed);
}

.tip-item:last-child {
  margin-bottom: 0;
}

.tip-item i {
  color: var(--color-warning);
  font-size: 14px;
  flex-shrink: 0;
}

/* 底部区域 */
.empty-footer {
  margin-top: var(--spacing-xl);
  padding-top: var(--spacing-lg);
  border-top: 1px solid var(--color-border);
  width: 100%;
  max-width: 400px;
}

.footer-text {
  font-size: var(--font-size-sm);
  color: var(--color-text-tertiary);
  margin: 0;
}

.footer-text a {
  color: var(--color-primary);
  text-decoration: none;
  transition: var(--transition-base);
}

.footer-text a:hover {
  text-decoration: underline;
  color: var(--color-primary-dark);
}

/* 动画效果 */
.empty-state {
  animation: fadeInUp 0.6s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .empty-state {
    padding: var(--spacing-lg);
    min-height: 250px;
  }

  .empty-icon {
    width: 80px;
    height: 80px;
    font-size: 32px;
  }

  .empty-title {
    font-size: var(--font-size-lg);
  }

  .empty-description {
    font-size: var(--font-size-sm);
  }

  .empty-actions {
    flex-direction: column;
    align-items: center;
  }

  .primary-action,
  .secondary-action {
    width: 100%;
    max-width: 200px;
  }

  .empty-tips {
    padding: var(--spacing-base);
  }
}

@media (max-width: 480px) {
  .empty-state {
    padding: var(--spacing-base);
  }

  .empty-icon {
    width: 60px;
    height: 60px;
    font-size: 24px;
  }

  .empty-title {
    font-size: var(--font-size-base);
  }

  .empty-description {
    font-size: var(--font-size-xs);
  }
}

/* 特殊类型样式 */
.empty-state[data-type="network-error"] .empty-icon {
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.1) 0%, rgba(220, 38, 38, 0.1) 100%);
  color: var(--color-danger);
}

.empty-state[data-type="permission-denied"] .empty-icon {
  background: linear-gradient(135deg, rgba(245, 158, 11, 0.1) 0%, rgba(217, 119, 6, 0.1) 100%);
  color: var(--color-warning);
}

.empty-state[data-type="no-favorites"] .empty-icon {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(124, 58, 237, 0.1) 100%);
  color: var(--color-secondary);
}
</style>