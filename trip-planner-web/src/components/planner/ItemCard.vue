<template>
  <div class="item-card">
    <div class="drag-handle">
      <el-icon><Rank /></el-icon>
    </div>
    <div class="item-content">
      <div class="item-header">
        <el-tag :type="typeTagColor" size="small">{{ typeLabel }}</el-tag>
        <span class="item-title">{{ item.title }}</span>
      </div>
      <div class="item-meta">
        <span v-if="item.startTime" class="meta-time">
          <el-icon><Clock /></el-icon>{{ formatTime(item.startTime) }}
          <template v-if="item.endTime"> ~ {{ formatTime(item.endTime) }}</template>
        </span>
        <span v-if="item.location" class="meta-loc">
          <el-icon><Location /></el-icon>{{ item.location }}
        </span>
      </div>
      <div v-if="item.cost > 0" class="item-cost">¥{{ item.cost }}</div>
    </div>
    <div class="item-actions">
      <el-button text @click="$emit('edit', item)"><el-icon><Edit /></el-icon></el-button>
      <el-button text type="danger" @click="$emit('delete', item.id)"><el-icon><Delete /></el-icon></el-button>
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

const typeTagColor = computed(() => {
  const map: Record<string, string> = {
    TRANSPORT: '', ACCOMMODATION: 'success', DINING: 'warning',
    ATTRACTION: 'primary', SHOPPING: 'danger', OTHER: 'info'
  }
  return map[props.item.itemType] || 'info'
})
</script>

<style scoped>
.item-card {
  display: flex;
  align-items: flex-start;
  padding: 12px;
  background: #fff;
  border: 1px solid #EBEEF5;
  border-radius: 8px;
  margin-bottom: 4px;
  transition: box-shadow 0.2s;
}
.item-card:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
.drag-handle { cursor: grab; padding: 4px 8px 0 0; color: #C0C4CC; }
.item-content { flex: 1; min-width: 0; }
.item-header { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; }
.item-title { font-size: 14px; font-weight: 500; }
.item-meta { display: flex; flex-wrap: wrap; gap: 8px; font-size: 12px; color: #909399; }
.meta-time, .meta-loc { display: flex; align-items: center; gap: 2px; }
.item-cost { font-size: 14px; color: #F56C6C; font-weight: 500; margin-top: 4px; }
.item-actions { display: flex; flex-direction: column; }
</style>
