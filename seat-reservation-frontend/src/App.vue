<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'PingFang SC', 'Microsoft YaHei', 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
  background-color: #ffffff;
  color: #333333;
  font-size: 14px;
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#app {
  min-height: 100vh;
  background: linear-gradient(135deg, #f8fafc 0%, #ffffff 50%, #f1f5f9 100%);
}

/* 自习室专用配色方案 - 自然、平和、专注 */
:root {
  /* 主色：深绿色 - 自然专注 */
  --color-primary: #059669;
  --color-primary-hover: #047857;
  --color-primary-light: #86efac;
  
  /* 功能色 */
  --color-success: #059669; /* 深绿：成功预约 */
  --color-warning: #fbbf24; /* 温暖黄：警告提示 */
  --color-danger: #dc2626;  /* 沉稳红：错误状态 */
  --color-info: #3b82f6;    /* 蓝色：信息提示 */
  
  /* 文字颜色 */
  --color-text-primary: #1f2937;   /* 主要标题 */
  --color-text-secondary: #4b5563; /* 正文内容 */
  --color-text-tertiary: #999999;  /* 辅助信息 */
  --color-text-placeholder: #cccccc; /* 占位文字 */
  
  /* 背景颜色 */
  --color-background-primary: #ffffff;   /* 卡片背景 */
  --color-background-secondary: #f0fdf4; /* 页面背景 - 极浅绿色调 */
  --color-background-tertiary: #e5e7eb;  /* 区域背景 - 原木色 */
  --color-background-hover: rgba(110, 231, 183, 0.1);     /* 悬停背景 - 淡绿色 */
  
  /* 边框颜色 */
  --color-border-light: #f0f0f0;   /* 浅边框 */
  --color-border: #e5e5e5;         /* 常规边框 */
  --color-border-dark: #d0d0d0;    /* 深边框 */
  
  /* 座位状态专用色 */
  --color-seat-available: #10b981;     /* 可预约：清新绿 */
  --color-seat-selected: #059669;      /* 已选中：主色绿 */
  --color-seat-occupied: #6b7280;      /* 已占用：中性灰 */
  --color-seat-disabled: #e5e7eb;      /* 不可用：浅灰 */
  --color-seat-premium: #86efac;       /* 特殊座位：浅绿色 */
  
  /* 圆角 */
  --radius-xs: 4px;
  --radius-sm: 6px;
  --radius-base: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  
  /* 阴影 */
  --shadow-xs: 0 1px 2px rgba(66, 66, 66, 0.04);
  --shadow-sm: 0 1px 3px rgba(66, 66, 66, 0.06);
  --shadow-base: 0 4px 6px rgba(66, 66, 66, 0.04);
  --shadow-lg: 0 10px 15px rgba(66, 66, 66, 0.08);
}

/* Element Plus 组件样式优化 - 现代扁平风格 */
.el-button {
  border-radius: 4px !important;
  font-weight: 500 !important;
  font-size: 14px !important;
  padding: 12px 24px !important;
  transition: all 0.3s ease !important;
  border: none !important;
  box-shadow: none !important;
}

.el-button--primary {
  background-color: var(--color-primary) !important;
  color: #ffffff !important;
}

.el-button--primary:hover {
  background-color: var(--color-primary-hover) !important;
  transform: translateY(-1px);
}

.el-button--success {
  background-color: var(--color-success) !important;
}

.el-button--warning {
  background-color: var(--color-warning) !important;
}

.el-button--danger {
  background-color: var(--color-danger) !important;
}

.el-button--default {
  background-color: #f8f9fa !important;
  color: var(--color-text-secondary) !important;
  border: 1px solid var(--color-border) !important;
}

.el-button--default:hover {
  background-color: #e9ecef !important;
  transform: translateY(-1px);
}

.el-card {
  border-radius: 0 !important;
  border: none !important;
  box-shadow: none !important;
  background-color: transparent !important;
}

.el-card:hover {
  box-shadow: none !important;
}

.el-dialog {
  border-radius: 8px !important;
  background-color: var(--color-background-primary) !important;
  border: none !important;
  box-shadow: 0 20px 60px rgba(66, 66, 66, 0.1) !important;
}

.el-table {
  border-radius: 0 !important;
  border: none !important;
  background-color: transparent !important;
  border-top: 2px solid var(--color-primary) !important;
}

.el-table th.el-table__cell {
  background-color: transparent !important;
  color: var(--color-text-primary) !important;
  font-weight: 600 !important;
  border-bottom: 1px solid var(--color-border) !important;
}

.el-input__wrapper {
  border-radius: 4px !important;
  border: 1px solid var(--color-border) !important;
  box-shadow: none !important;
  transition: all 0.3s ease !important;
  background-color: #ffffff !important;
}

.el-input__wrapper:hover {
  border-color: var(--color-border-dark) !important;
}

.el-input__wrapper.is-focus {
  border-color: var(--color-primary) !important;
  box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.1) !important;
}

.el-input__inner {
  color: var(--color-text-secondary) !important;
}

.el-input__inner::placeholder {
  color: var(--color-text-placeholder) !important;
}

.el-select .el-input__wrapper {
  cursor: pointer;
}

.el-pagination .btn-next,
.el-pagination .btn-prev {
  border-radius: var(--radius-sm) !important;
  border: 1px solid var(--color-border) !important;
}

.el-pagination .el-pager li {
  border-radius: var(--radius-sm) !important;
  border: 1px solid var(--color-border-light) !important;
  margin: 0 2px !important;
}

.el-pagination .el-pager li.is-active {
  background-color: var(--color-primary) !important;
  border-color: var(--color-primary) !important;
  color: #ffffff !important;
}

/* 消息提示样式 */
.el-message {
  border-radius: var(--radius-base) !important;
  box-shadow: var(--shadow-base) !important;
}

.el-message--success {
  background-color: var(--color-success) !important;
  border-color: var(--color-success) !important;
}

.el-message--warning {
  background-color: var(--color-warning) !important;
  border-color: var(--color-warning) !important;
}

.el-message--error {
  background-color: var(--color-danger) !important;
  border-color: var(--color-danger) !important;
}
</style>