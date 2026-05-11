<template>
  <div class="day-tabs">
    <button
      v-for="day in days"
      :key="day.id"
      :class="['day-tab', { active: String(day.id) === activeTab }]"
      @click="handleClick(String(day.id))"
    >
      <span class="tab-number">Day {{ day.dayNumber }}</span>
      <span class="tab-date">{{ formatDate(day.date) }}</span>
    </button>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import type { DayData } from '@/api/day'
import { formatDate } from '@/utils/date'

const props = defineProps<{ days: DayData[]; modelValue: number | null }>()
const emit = defineEmits(['change', 'update:modelValue'])

const activeTab = ref(props.modelValue ? String(props.modelValue) : '')

watch(() => props.modelValue, v => {
  if (v) activeTab.value = String(v)
})

function handleClick(id: string) {
  activeTab.value = id
  emit('update:modelValue', Number(id))
  emit('change', Number(id))
}
</script>

<style scoped>
.day-tabs {
  display: flex;
  gap: 8px;
  width: 100%;
  margin-bottom: 20px;
  overflow-x: auto;
  padding-bottom: 4px;
  scrollbar-width: none;
}
.day-tabs::-webkit-scrollbar { display: none; }

.day-tab {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 10px 20px;
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
  font-family: var(--font-body);
  white-space: nowrap;
  flex-shrink: 0;
}
.day-tab:hover {
  border-color: var(--color-primary-light);
  background: #fdfaf7;
}
.day-tab.active {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: #fff;
}
.tab-number {
  font-size: 14px;
  font-weight: 600;
}
.tab-date {
  font-size: 11px;
  opacity: 0.7;
  margin-top: 2px;
}
.day-tab.active .tab-date { opacity: 0.85; }
</style>
