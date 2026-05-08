<template>
  <div class="day-summary">
    <h4>当日概览</h4>
    <div class="summary-stats">
      <div class="stat-item">
        <span class="stat-label">行程项</span>
        <span class="stat-value">{{ itemCount }}个</span>
      </div>
      <div class="stat-item">
        <span class="stat-label">交通段</span>
        <span class="stat-value">{{ transportCount }}个</span>
      </div>
      <div class="stat-item">
        <span class="stat-label">当日费用</span>
        <span class="stat-value cost">¥{{ dayCost.toFixed(2) }}</span>
      </div>
    </div>
    <div class="summary-actions">
      <el-button size="small" @click="$emit('addItem')">
        <el-icon><Plus /></el-icon>添加行程项
      </el-button>
      <el-button size="small" @click="$emit('generateDays')">
        <el-icon><RefreshRight /></el-icon>重新生成日程
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { ItemData } from '@/api/item'
import type { TransportData } from '@/api/transport'

const props = defineProps<{ items: ItemData[]; transports: TransportData[] }>()
defineEmits(['addItem', 'generateDays'])

const itemCount = computed(() => props.items.length)
const transportCount = computed(() => props.transports.length)

const dayCost = computed(() => {
  const itemCost = props.items.reduce((s, i) => s + (i.cost || 0), 0)
  const transportCost = props.transports.reduce((s, t) => s + (t.cost || 0), 0)
  return itemCost + transportCost
})
</script>

<style scoped>
.day-summary {
  background: #fff;
  border-radius: 8px;
  padding: 16px;
  border: 1px solid #EBEEF5;
}
h4 { margin: 0 0 12px 0; font-size: 14px; color: #303133; }
.summary-stats { display: flex; flex-direction: column; gap: 8px; margin-bottom: 16px; }
.stat-item { display: flex; justify-content: space-between; font-size: 13px; }
.stat-label { color: #909399; }
.stat-value { font-weight: 500; }
.stat-value.cost { color: #F56C6C; }
.summary-actions { display: flex; flex-direction: column; gap: 8px; }
</style>
