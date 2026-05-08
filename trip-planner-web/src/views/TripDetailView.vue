<template>
  <div class="page-container" v-loading="loading">
    <div class="detail-header">
      <button class="back-btn" @click="$router.back()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
        返回
      </button>
      <div class="header-actions">
        <el-button class="nav-btn" @click="$router.push(`/trips/${tripId}/planner`)">日程规划</el-button>
        <el-button class="nav-btn" @click="$router.push(`/trips/${tripId}/budget`)">预算</el-button>
        <el-button class="nav-btn" @click="$router.push(`/trips/${tripId}/checklist`)">备忘录</el-button>
        <el-button class="nav-btn" @click="$router.push(`/trips/${tripId}/edit`)">编辑</el-button>
      </div>
    </div>

    <template v-if="trip">
      <div class="detail-card">
        <h2>{{ trip.tripName }}</h2>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="目的地">{{ trip.destination }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <span class="status-badge" :class="'status-' + trip.status.toLowerCase()">{{ statusLabel }}</span>
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

onMounted(async () => {
  loading.value = true
  try { trip.value = await tripApi.getById(tripId) }
  finally { loading.value = false }
})
</script>

<style scoped>
.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 12px;
}
.back-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 6px 14px;
  font-size: 13px;
  color: var(--color-text-secondary);
  cursor: pointer;
  transition: all 0.2s;
  font-family: var(--font-body);
}
.back-btn:hover { border-color: var(--color-primary-light); color: var(--color-primary); }
.header-actions { display: flex; gap: 8px; flex-wrap: wrap; }
.nav-btn { border-radius: 8px; }

.detail-card {
  background: var(--color-bg-surface);
  padding: 28px;
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border-light);
}
.detail-card h2 {
  margin: 0 0 22px;
  font-family: var(--font-display);
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 0.03em;
}
.status-badge {
  font-size: 12px;
  padding: 2px 12px;
  border-radius: 20px;
  font-weight: 500;
}
.status-planning { background: #f0e6d3; color: #a05d3f; }
.status-completed { background: #e4eddb; color: #5a6e3a; }
.status-cancelled { background: #f2ebe0; color: #8b7e6a; }
</style>
