<template>
  <div class="empty-state">
    <div class="empty-icon">
      <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="10" r="3"/>
        <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
        <line x1="2" y1="22" x2="22" y2="22"/>
      </svg>
    </div>
    <p class="empty-desc">{{ description }}</p>
    <el-button v-if="actionText" class="empty-action" @click="$emit('action')">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
      {{ actionText }}
    </el-button>
  </div>
</template>

<script setup lang="ts">
defineProps({
  description: { type: String, default: '暂无数据' },
  actionText: { type: String, default: '' }
})
defineEmits(['action'])
</script>

<style scoped>
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 64px 0;
}
.empty-icon {
  color: #c8bdab;
  margin-bottom: 16px;
}
.empty-desc {
  font-size: 14px;
  color: var(--color-text-secondary);
  margin: 0 0 20px;
}
.empty-action {
  display: flex;
  align-items: center;
  gap: 6px;
}
</style>
