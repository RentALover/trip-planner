<template>
  <el-card class="trip-card card-hover" shadow="hover" @click="$router.push(`/trips/${trip.id}`)">
    <div class="card-body">
      <div class="card-main">
        <h3 class="trip-name">{{ trip.tripName }}</h3>
        <div class="trip-meta">
          <el-icon><Location /></el-icon>
          <span>{{ trip.destination }}</span>
        </div>
        <div class="trip-meta">
          <el-icon><Calendar /></el-icon>
          <span>{{ trip.startDate }} ~ {{ trip.endDate }}</span>
        </div>
        <el-tag :type="statusType" size="small">{{ statusLabel }}</el-tag>
      </div>
      <div class="card-actions" @click.stop>
        <el-button text type="primary" @click="$router.push(`/trips/${trip.id}/planner`)">
          规划
        </el-button>
        <el-button text @click="$router.push(`/trips/${trip.id}/edit`)">
          编辑
        </el-button>
        <el-button text type="danger" @click="$emit('delete', trip.id)">
          删除
        </el-button>
      </div>
    </div>
  </el-card>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { TripData } from '@/api/trip'
import { getStatusLabel } from '@/utils/currency'

const props = defineProps<{ trip: TripData }>()
defineEmits(['delete'])

const statusLabel = computed(() => getStatusLabel(props.trip.status))
const statusType = computed(() => {
  const map: Record<string, string> = { PLANNING: 'primary', COMPLETED: 'success', CANCELLED: 'info' }
  return map[props.trip.status] || 'info'
})
</script>

<style scoped>
.trip-card {
  cursor: pointer;
  margin-bottom: 12px;
}
.card-body {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}
.trip-name {
  margin: 0 0 8px 0;
  font-size: 16px;
}
.trip-meta {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: #909399;
  margin-bottom: 4px;
}
.card-actions {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
</style>
