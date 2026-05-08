<template>
  <div class="item-card">
    <div class="drag-handle" title="拖动排序">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="8" y1="6" x2="16" y2="6"/><line x1="8" y1="10" x2="16" y2="10"/><line x1="8" y1="14" x2="16" y2="14"/><line x1="8" y1="18" x2="16" y2="18"/></svg>
    </div>
    <div class="item-content">
      <div class="item-header">
        <span class="item-type-badge" :class="'type-' + item.itemType.toLowerCase()">
          {{ typeLabel }}
        </span>
        <span class="item-title">{{ item.title }}</span>
      </div>
      <div class="item-meta">
        <span v-if="item.startTime" class="meta-item">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
          {{ formatTime(item.startTime) }}
          <template v-if="item.endTime"> ~ {{ formatTime(item.endTime) }}</template>
        </span>
        <span v-if="item.location" class="meta-item">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="10" r="3"/><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/></svg>
          {{ item.location }}
        </span>
      </div>
      <div v-if="item.cost > 0" class="item-cost">¥{{ item.cost }}</div>
    </div>
    <div class="item-actions">
      <button class="icon-btn" title="编辑" @click="$emit('edit', item)">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
      </button>
      <button class="icon-btn danger" title="删除" @click="$emit('delete', item.id)">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { ItemData } from '@/api/item'
import { getItemTypeLabel } from '@/utils/currency'
import { formatTime } from '@/utils/date'

const props = defineProps<{ item: ItemData }>()
defineEmits(['edit', 'delete'])

const typeLabel = computed(() => getItemTypeLabel(props.item.itemType))
</script>

<style scoped>
.item-card {
  display: flex;
  align-items: flex-start;
  padding: 14px 16px;
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-light);
  border-radius: 10px;
  margin-bottom: 4px;
  transition: box-shadow 0.2s, border-color 0.2s;
}
.item-card:hover {
  border-color: var(--color-border);
  box-shadow: var(--shadow-sm);
}
.drag-handle {
  cursor: grab;
  padding: 2px 8px 0 0;
  color: #c8bdab;
  flex-shrink: 0;
  transition: color 0.15s;
}
.drag-handle:hover { color: var(--color-primary); }
.drag-handle:active { cursor: grabbing; }

.item-content { flex: 1; min-width: 0; }
.item-header { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; }

.item-type-badge {
  font-size: 11px;
  padding: 2px 8px;
  border-radius: 4px;
  font-weight: 500;
  flex-shrink: 0;
}
.type-transport { background: #ecf3f0; color: #3d6b6b; }
.type-accommodation { background: #e4eddb; color: #5a6e3a; }
.type-dining { background: #fcf3e0; color: #8b6914; }
.type-attraction { background: #f9f2ee; color: #a05d3f; }
.type-shopping { background: #fdf1f0; color: #9b3a36; }
.type-other { background: #f4efe4; color: #6b7d8b; }

.item-title { font-size: 14px; font-weight: 600; color: var(--color-text-primary); }
.item-meta { display: flex; flex-wrap: wrap; gap: 12px; }
.meta-item {
  display: flex;
  align-items: center;
  gap: 3px;
  font-size: 12px;
  color: var(--color-text-secondary);
}
.item-cost {
  font-size: 15px;
  color: var(--color-primary);
  font-weight: 600;
  margin-top: 6px;
  font-variant-numeric: tabular-nums;
}
.item-actions { display: flex; flex-direction: column; flex-shrink: 0; }
.icon-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 6px;
  border-radius: 6px;
  color: var(--color-text-placeholder);
  transition: all 0.15s;
  display: flex;
  align-items: center;
}
.icon-btn:hover { background: var(--color-bg-muted); color: var(--color-text-regular); }
.icon-btn.danger:hover { background: #fdf1f0; color: var(--color-danger); }
</style>
