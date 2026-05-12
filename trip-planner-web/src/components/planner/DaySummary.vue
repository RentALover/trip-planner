<template>
  <div class="day-summary">
    <h4>当日概览</h4>
    <div class="summary-stats">
      <div class="stat-item">
        <span class="stat-label">行程项</span>
        <span class="stat-value">{{ itemCount }} 个</span>
      </div>
      <div class="stat-item">
        <span class="stat-label">交通段</span>
        <span class="stat-value">{{ transportCount }} 个</span>
      </div>
      <div class="stat-item highlight">
        <span class="stat-label">当日费用</span>
        <span class="stat-value cost">¥{{ dayCost.toFixed(2) }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { ItemData } from '@/api/item'
import type { TransportData } from '@/api/transport'

const props = defineProps<{ items: ItemData[]; transports: TransportData[]; readonly?: boolean }>()
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
  background: var(--color-bg-surface);
  border-radius: var(--radius-md);
  padding: 18px;
  border: 1px solid var(--color-border-light);
}
h4 {
  margin: 0 0 14px 0;
  font-family: var(--font-display);
  font-size: 15px;
  font-weight: 600;
  color: var(--color-text-primary);
  letter-spacing: 0.02em;
}
.summary-stats {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 18px;
  padding-bottom: 14px;
  border-bottom: 1px solid var(--color-border-light);
}
.stat-item {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
}
.stat-item.highlight {
  padding-top: 8px;
  border-top: 1px solid var(--color-border-light);
}
.stat-label { color: var(--color-text-secondary); }
.stat-value { font-weight: 600; color: var(--color-text-primary); }
.stat-value.cost {
  color: var(--color-primary);
  font-size: 16px;
  font-family: var(--font-display);
}
.summary-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.action-btn {
  justify-content: flex-start !important;
  display: flex !important;
  align-items: center;
  gap: 6px;
  border-radius: 8px;
  font-weight: 500;
  width: 100% !important;
  padding-left: 12px;
  margin-left: 0 !important;
  margin-right: 0 !important;
  box-sizing: border-box;
}
.action-btn :deep(svg) {
  flex-shrink: 0;
  width: 15px;
}
</style>
