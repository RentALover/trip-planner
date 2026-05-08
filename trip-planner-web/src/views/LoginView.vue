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
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="10" r="3"/>
            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
          </svg>
        </div>
        <h1>行程DIY规划</h1>
        <p class="auth-subtitle">探索世界，从这里开始</p>
      </div>

      <el-form :model="form" :rules="rules" ref="formRef" label-width="0" class="auth-form">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="用户名" size="large" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="密码"
            size="large" show-password @keyup.enter="handleLogin" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" block size="large" class="auth-btn" @click="handleLogin">
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
  background: #f9f5ed;
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
  width: 600px;
  height: 600px;
  background: #c47b5a;
  top: -200px;
  right: -150px;
}
.bg-circle-2 {
  width: 400px;
  height: 400px;
  background: #3d6b6b;
  bottom: -100px;
  left: -100px;
}
.bg-line {
  position: absolute;
  top: 15%;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(196, 123, 90, 0.12), transparent);
}

.auth-card {
  position: relative;
  background: #fffdf7;
  padding: 48px 40px 36px;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(44, 36, 22, 0.08), 0 1px 4px rgba(44, 36, 22, 0.04);
  width: 400px;
  border: 1px solid #f2ebe0;
}

.auth-header {
  text-align: center;
  margin-bottom: 32px;
}
.auth-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 56px;
  height: 56px;
  border-radius: 14px;
  background: linear-gradient(135deg, #f0e6d3, #f9f2ee);
  color: #c47b5a;
  margin-bottom: 16px;
}
.auth-header h1 {
  font-family: var(--font-display);
  font-size: 22px;
  font-weight: 700;
  color: #2c2416;
  margin: 0 0 6px;
  letter-spacing: 0.04em;
}
.auth-subtitle {
  font-size: 14px;
  color: #8b7e6a;
  margin: 0;
}

.auth-form {
  margin-top: 8px;
}

.auth-btn {
  border-radius: 10px;
  font-weight: 600;
  letter-spacing: 0.03em;
  height: 44px;
}

.auth-footer {
  text-align: center;
  font-size: 14px;
  color: #8b7e6a;
  margin: 20px 0 0;
}
.auth-footer a {
  color: #c47b5a;
  font-weight: 500;
}
</style>
