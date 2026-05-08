<template>
  <div class="page-container" v-loading="loading">
    <div class="detail-header">
      <el-button text @click="$router.back()">
        <el-icon><ArrowLeft /></el-icon>返回
      </el-button>
      <div class="header-actions">
        <el-button @click="$router.push(`/trips/${tripId}/planner`)">日程规划</el-button>
        <el-button @click="$router.push(`/trips/${tripId}/budget`)">预算</el-button>
        <el-button @click="$router.push(`/trips/${tripId}/checklist`)">备忘录</el-button>
        <el-button @click="$router.push(`/trips/${tripId}/edit`)">编辑</el-button>
      </div>
    </div>

    <template v-if="trip">
      <div class="detail-card">
        <h2>{{ trip.tripName }}</h2>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="目的地">{{ trip.destination }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="statusType">{{ statusLabel }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="日期">
            {{ trip.startDate }} ~ {{ trip.endDate }}
          </el-descriptions-item>
          <el-descriptions-item label="人数">{{ trip.numPeople }}人</el-descriptions-item>
          <el-descriptions-item label="预算">
            {{ trip.totalBudget ? '¥' + trip.totalBudget : '未设定' }}
          </el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ trip.createTime }}</el-descriptions-item>
          <el-descriptions-item v-if="trip.notes" label="备注" :span="2">
            {{ trip.notes }}
          </el-descriptions-item>
        </el-descriptions>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { tripApi, type TripData } from '@/api/trip'
import { getStatusLabel } from '@/utils/currency'

const route = useRoute()
const tripId = Number(route.params.id)
const trip = ref<TripData | null>(null)
const loading = ref(false)

const statusLabel = computed(() => trip.value ? getStatusLabel(trip.value.status) : '')
const statusType = computed(() => {
  const map: Record<string, string> = { PLANNING: '', COMPLETED: 'success', CANCELLED: 'info' }
  return trip.value ? map[trip.value.status] || '' : ''
})

onMounted(async () => {
  loading.value = true
  try {
    trip.value = await tripApi.getById(tripId)
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 8px;
}
.header-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}
.detail-card {
  background: #fff;
  padding: 24px;
  border-radius: 8px;
}
.detail-card h2 { margin-top: 0; margin-bottom: 20px; }
</style>
