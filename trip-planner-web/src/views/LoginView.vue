<template>
  <div class="auth-page">
    <!-- Decorative background elements -->
    <div class="auth-bg">
      <div class="bg-circle bg-circle-1"></div>
      <div class="bg-circle bg-circle-2"></div>
      <div class="bg-line"></div>
    </div>

    <div class="auth-card">
      <div class="auth-header">
        <div class="auth-icon">
          <svg width="48" height="48" viewBox="0 0 64 64" fill="none">
            <circle cx="32" cy="32" r="30" fill="currentColor" opacity="0.12"/>
            <polygon points="32,14 25,36 32,31 39,36" fill="currentColor" opacity="0.9"/>
            <polygon points="32,50 25,32 32,37 39,32" fill="currentColor" opacity="0.5"/>
            <circle cx="32" cy="32" r="3" fill="currentColor"/>
          </svg>
        </div>
        <h1>Wanderlog</h1>
        <p class="auth-subtitle">Plan your journey, record your story</p>
      </div>

      <el-form :model="form" :rules="rules" ref="formRef" label-width="0" class="auth-form">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="用户名" size="large" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="密码"
            size="large" show-password @keyup.enter="handleLogin" />
        </el-form-item>
        <el-form-item class="auth-btn-wrapper">
          <el-button type="primary" :loading="loading" size="large" class="auth-btn" @click="handleLogin">
            登录
          </el-button>
        </el-form-item>
      </el-form>

      <p class="auth-footer">
        还没有账号？<router-link to="/register">立即注册</router-link>
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const formRef = ref()
const loading = ref(false)

const form = reactive({ username: '', password: '' })
const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function handleLogin() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    await userStore.login(form.username, form.password)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg-page);
  overflow: hidden;
  position: relative;
}

.auth-bg {
  position: absolute;
  inset: 0;
  pointer-events: none;
}
.bg-circle {
  position: absolute;
  border-radius: 50%;
  opacity: 0.06;
}
.bg-circle-1 {
  width: 600px; height: 600px;
  background: var(--color-primary);
  top: -200px; right: -150px;
}
.bg-circle-2 {
  width: 400px; height: 400px;
  background: var(--color-accent);
  bottom: -100px; left: -100px;
}
.bg-line {
  position: absolute;
  top: 15%; left: 0; right: 0; height: 1px;
  background: linear-gradient(90deg, transparent, var(--color-primary), transparent);
  opacity: 0.12;
}

.auth-card {
  position: relative;
  background: var(--color-bg-surface);
  padding: 48px 40px 36px;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md), var(--shadow-sm);
  width: 400px;
  border: 1px solid var(--color-border-light);
}

.auth-header {
  text-align: center;
  margin-bottom: 32px;
}
.auth-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 56px; height: 56px;
  border-radius: 14px;
  background: linear-gradient(135deg, #f0e6d3, #f9f2ee);
  color: var(--color-primary);
  margin-bottom: 16px;
}
.auth-header h1 {
  font-family: var(--font-display);
  font-size: 22px; font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 6px;
  letter-spacing: 0.04em;
}
.auth-subtitle {
  font-size: 14px;
  color: var(--color-text-secondary);
  margin: 0;
}

.auth-form {
  margin-top: 8px;
}

.auth-btn-wrapper :deep(.el-form-item__content) {
  justify-content: center;
}
.auth-btn {
  border-radius: 10px;
  font-weight: 600;
  letter-spacing: 0.03em;
  height: 44px;
  padding: 0 48px;
}

.auth-footer {
  text-align: center;
  font-size: 14px;
  color: var(--color-text-secondary);
  margin: 20px 0 0;
}
.auth-footer a {
  color: var(--color-primary);
  font-weight: 500;
}
</style>
