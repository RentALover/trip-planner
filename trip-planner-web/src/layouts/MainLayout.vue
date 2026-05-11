<template>
  <div class="main-layout">
    <header class="app-header">
      <div class="header-left">
        <router-link to="/" class="logo">
          <div class="logo-icon">
            <svg width="22" height="22" viewBox="0 0 64 64" fill="none">
              <circle cx="32" cy="32" r="30" fill="currentColor" opacity="0.12"/>
              <polygon points="32,14 25,36 32,31 39,36" fill="currentColor" opacity="0.9"/>
              <polygon points="32,50 25,32 32,37 39,32" fill="currentColor" opacity="0.5"/>
              <circle cx="32" cy="32" r="3" fill="currentColor"/>
            </svg>
          </div>
          <span class="logo-text">Wanderlog</span>
        </router-link>
      </div>
      <nav class="header-nav">
        <router-link to="/" class="nav-tab" :class="{ active: $route.path !== '/photos' }">我的行程</router-link>
        <router-link to="/photos" class="nav-tab" :class="{ active: $route.path === '/photos' }">旅行相册</router-link>
      </nav>
      <div class="header-right">
        <el-dropdown trigger="click" popper-class="header-dropdown">
          <span class="user-info">
            <el-avatar :size="34" :src="userStore.userInfo?.avatarUrl" class="user-avatar" />
            <span class="username">{{ userStore.userInfo?.nickname || userStore.userInfo?.username }}</span>
            <svg class="chevron" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="$router.push('/profile')">
                <el-icon><User /></el-icon>个人信息
              </el-dropdown-item>
              <el-dropdown-item divided @click="handleLogout">
                <el-icon><SwitchButton /></el-icon>退出登录
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </header>
    <main class="app-main">
      <router-view v-slot="{ Component }">
        <transition name="page-fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>
  </div>
</template>

<script setup lang="ts">
import { useUserStore } from '@/stores/user'
import { useRouter } from 'vue-router'

const userStore = useUserStore()
const router = useRouter()

function handleLogout() {
  userStore.logout()
}
</script>

<style scoped>
.main-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 28px;
  height: 60px;
  background: #1e2d3d;
  position: sticky;
  top: 0;
  z-index: 100;
  backdrop-filter: blur(12px);
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #f0e6d3;
  text-decoration: none;
}
.logo:hover { color: #f0e6d3; }
.logo-icon {
  display: flex;
  align-items: center;
  color: #d9a38b;
}
.logo-text {
  font-family: var(--font-display);
  font-size: 18px;
  font-weight: 600;
  letter-spacing: 0.03em;
}

.header-nav {
  display: flex;
  gap: 4px;
  margin-left: 32px;
}
.nav-tab {
  padding: 8px 18px;
  border-radius: 8px;
  color: #a89880;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
}
.nav-tab:hover { color: #f0e6d3; background: rgba(255,255,255,0.06); }
.nav-tab.active { color: #f0e6d3; background: rgba(255,255,255,0.1); }

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  color: #c8bdab;
  transition: color 0.2s;
}
.user-info:hover { color: #f0e6d3; }
.username {
  font-size: 14px;
  font-weight: 500;
}
.chevron {
  opacity: 0.5;
  transition: opacity 0.2s;
}
.user-info:hover .chevron { opacity: 0.8; }

.user-avatar {
  border: 2px solid #3d6b6b;
}

.app-main {
  flex: 1;
  display: flex;
  flex-direction: column;
}

/* Page transition */
.page-fade-enter-active,
.page-fade-leave-active {
  transition: opacity 0.2s ease;
}
.page-fade-enter-from,
.page-fade-leave-to {
  opacity: 0;
}

@media (max-width: 768px) {
  .app-header {
    padding: 0 16px;
  }
  .username {
    display: none;
  }
}
</style>
