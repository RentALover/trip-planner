<template>
  <div class="day-tabs">
    <el-tabs v-model="activeTab" type="card" @tab-change="$emit('change', $event)">
      <el-tab-pane
        v-for="day in days" :key="day.id"
        :label="'Day ' + day.dayNumber"
        :name="String(day.id)"
      >
        <template #label>
          <span class="tab-label">
            Day {{ day.dayNumber }}
            <span class="tab-date">{{ formatDate(day.date) }}</span>
          </span>
        </template>
      </el-tab-pane>
    </el-tabs>
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

watch(activeTab, v => emit('update:modelValue', Number(v)))
</script>

<style scoped>
.day-tabs { margin-bottom: 12px; }
.tab-label { display: flex; align-items: center; gap: 4px; }
.tab-date { font-size: 11px; color: #909399; }
</style>
