<template>
  <Layout>
    <div class="color-test">
      <h1>色彩系统测试页面</h1>

      <!-- 主色调测试 -->
      <section class="color-section">
        <h2>主色调系统</h2>
        <div class="color-grid">
          <div class="color-item">
            <div class="color-block" style="background: var(--color-primary)"></div>
            <p>Primary</p>
            <span>#4C6FFF</span>
          </div>
          <div class="color-item">
            <div class="color-block" style="background: var(--color-primary-light)"></div>
            <p>Primary Light</p>
            <span>#6B8AFF</span>
          </div>
          <div class="color-item">
            <div class="color-block" style="background: var(--color-primary-dark)"></div>
            <p>Primary Dark</p>
            <span>#3754DB</span>
          </div>
        </div>
      </section>

      <!-- 功能色测试 -->
      <section class="color-section">
        <h2>功能色</h2>
        <div class="color-grid">
          <div class="color-item">
            <div class="color-block" style="background: var(--color-success)"></div>
            <p>Success</p>
            <span>#059669</span>
          </div>
          <div class="color-item">
            <div class="color-block" style="background: var(--color-warning)"></div>
            <p>Warning</p>
            <span>#F59E0B</span>
          </div>
          <div class="color-item">
            <div class="color-block" style="background: var(--color-danger)"></div>
            <p>Danger</p>
            <span>#D94747</span>
          </div>
        </div>
      </section>

      <!-- 背景色测试 -->
      <section class="color-section">
        <h2>背景色系统</h2>
        <div class="color-grid">
          <div class="color-item">
            <div class="color-block" style="background: var(--color-background-primary); border: 1px solid var(--color-border)"></div>
            <p>Primary BG</p>
            <span>#FFFFFF</span>
          </div>
          <div class="color-item">
            <div class="color-block" style="background: var(--color-background-secondary)"></div>
            <p>Secondary BG</p>
            <span>#F9FAFB</span>
          </div>
          <div class="color-item">
            <div class="color-block" style="background: var(--color-background-tertiary)"></div>
            <p>Tertiary BG</p>
            <span>#F3F4F6</span>
          </div>
        </div>
      </section>

      <!-- 按钮测试 -->
      <section class="color-section">
        <h2>按钮样式</h2>
        <div class="button-grid">
          <el-button type="primary">主要按钮</el-button>
          <el-button type="success">成功按钮</el-button>
          <el-button type="warning">警告按钮</el-button>
          <el-button type="danger">危险按钮</el-button>
          <el-button>默认按钮</el-button>
        </div>
      </section>

      <!-- 座位状态色测试 -->
      <section class="color-section">
        <h2>座位状态颜色</h2>
        <div class="seat-grid">
          <div class="seat-demo available">
            <span>可用</span>
          </div>
          <div class="seat-demo occupied">
            <span>占用</span>
          </div>
          <div class="seat-demo selected">
            <span>选中</span>
          </div>
          <div class="seat-demo disabled">
            <span>禁用</span>
          </div>
          <div class="seat-demo premium">
            <span>高级</span>
          </div>
        </div>
      </section>
    </div>
  </Layout>
</template>

<script setup>
import Layout from '@/components/Layout.vue'
</script>

<style scoped>
.color-test {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
  background: var(--color-background-secondary);
  min-height: 100vh;
}

h1 {
  color: var(--color-text-primary);
  margin-bottom: 40px;
  text-align: center;
  font-size: 32px;
}

.color-section {
  background: var(--color-background-primary);
  border-radius: 12px;
  padding: 30px;
  margin-bottom: 30px;
  box-shadow: var(--shadow-md);
}

.color-section h2 {
  color: var(--color-text-primary);
  margin-bottom: 20px;
  font-size: 20px;
}

.color-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 20px;
}

.color-item {
  text-align: center;
}

.color-block {
  height: 100px;
  border-radius: 8px;
  margin-bottom: 10px;
  box-shadow: var(--shadow-sm);
}

.color-item p {
  color: var(--color-text-primary);
  font-weight: 600;
  margin: 5px 0;
}

.color-item span {
  color: var(--color-text-secondary);
  font-size: 12px;
}

.button-grid {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.seat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 15px;
  margin-top: 20px;
}

.seat-demo {
  padding: 20px;
  border-radius: 8px;
  text-align: center;
  font-weight: 500;
  border: 2px solid;
  transition: all 0.3s ease;
}

.seat-demo:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}

.seat-demo.available {
  background: var(--color-seat-available-bg);
  border-color: var(--color-seat-available-border);
  color: var(--color-seat-available);
}

.seat-demo.occupied {
  background: var(--color-seat-occupied-bg);
  border-color: var(--color-seat-occupied-border);
  color: var(--color-seat-occupied);
}

.seat-demo.selected {
  background: var(--color-seat-selected-bg);
  border-color: var(--color-seat-selected-border);
  color: var(--color-seat-selected);
}

.seat-demo.disabled {
  background: var(--color-seat-disabled-bg);
  border-color: var(--color-seat-disabled-border);
  color: var(--color-seat-disabled);
}

.seat-demo.premium {
  background: var(--color-seat-premium-bg);
  border-color: var(--color-seat-premium-border);
  color: var(--color-seat-premium);
}
</style>