<template>
  <div class="trip-filter">
    <div class="search-wrapper">
      <svg class="search-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      <input
        v-model="searchKeyword"
        placeholder="搜索行程名称或目的地"
        class="search-input"
        @input="$emit('search', searchKeyword)"
      />
      <button v-if="searchKeyword" class="clear-btn" @click="searchKeyword = ''; $emit('search', '')">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>
    <el-select v-model="selectedStatus" placeholder="状态筛选" clearable
      class="status-select"
      @change="$emit('filter', selectedStatus)">
      <el-option label="规划中" value="PLANNING" />
      <el-option label="已完成" value="COMPLETED" />
      <el-option label="已取消" value="CANCELLED" />
    </el-select>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

defineEmits(['search', 'filter'])

const searchKeyword = ref('')
const selectedStatus = ref('')
</script>

<style scoped>
.trip-filter {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
}

.search-wrapper {
  position: relative;
  flex: 1;
  max-width: 360px;
}
.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--color-text-placeholder);
  pointer-events: none;
}
.search-input {
  width: 100%;
  height: 40px;
  padding: 0 36px 0 38px;
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border);
  border-radius: 10px;
  font-size: 14px;
  color: var(--color-text-primary);
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  font-family: var(--font-body);
}
.search-input:focus {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(196, 123, 90, 0.1);
}
.search-input::placeholder { color: var(--color-text-placeholder); }

.clear-btn {
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  cursor: pointer;
  color: var(--color-text-placeholder);
  padding: 4px;
  display: flex;
  align-items: center;
}
.clear-btn:hover { color: var(--color-text-secondary); }

.status-select {
  width: 140px;
}

@media (max-width: 768px) {
  .trip-filter {
    flex-direction: column;
  }
  .search-wrapper {
    max-width: none;
  }
  .status-select {
    width: 100%;
  }
}
</style>
