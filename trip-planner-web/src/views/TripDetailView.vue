<template>
  <div class="detail-page" v-loading="loading">
    <div class="detail-header">
      <button class="back-btn" @click="$router.back()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
        返回
      </button>
      <div class="header-actions">
        <el-button class="nav-btn" type="primary" @click="$router.push(`/trips/${tripId}/planner`)">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="5 3 19 12 5 21 5 3"/></svg>
          进入规划
        </el-button>
        <el-button class="nav-btn" @click="$router.push(`/trips/${tripId}/budget`)">预算</el-button>
        <el-button class="nav-btn" @click="$router.push(`/trips/${tripId}/checklist`)">备忘录</el-button>
        <el-button class="nav-btn" @click="$router.push(`/trips/${tripId}/edit`)">编辑</el-button>
      </div>
    </div>

    <template v-if="trip">
      <div class="detail-card">
        <h2>{{ trip.tripName }}</h2>
        <el-descriptions :column="2" border size="small">
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

      <!-- Day-by-day itinerary preview -->
      <div v-if="plannerStore.days.length > 0" class="itinerary-section">
        <h3 class="section-title">行程预览</h3>
        <div class="itinerary-body">
          <div class="itinerary-main">
            <DayTabs v-model="activeDayId" :days="plannerStore.days" @change="onDayChange" />
            <div class="day-preview">
              <DraggableItemList
                v-if="currentItems.length > 0 || currentTransports.length > 0"
                :items="currentItems"
                :transports="currentTransports"
                :readonly="true"
              />
              <div v-else class="empty-day">
                <p>这一天还没有行程安排</p>
              </div>
            </div>
          </div>
          <div class="itinerary-sidebar">
            <DaySummary
              :items="currentItems"
              :transports="currentTransports"
            />
          </div>
        </div>
      </div>
      <div v-else-if="!planLoading" class="no-days">
        <p>还没有日程安排</p>
        <el-button type="primary" @click="$router.push(`/trips/${tripId}/planner`)">去规划行程</el-button>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { usePlannerStore } from '@/stores/planner'
import { tripApi, type TripData } from '@/api/trip'
import { getStatusLabel } from '@/utils/currency'
import DayTabs from '@/components/planner/DayTabs.vue'
import DraggableItemList from '@/components/planner/DraggableItemList.vue'
import DaySummary from '@/components/planner/DaySummary.vue'

const route = useRoute()
const tripId = Number(route.params.id)
const plannerStore = usePlannerStore()

const trip = ref<TripData | null>(null)
const loading = ref(false)
const planLoading = ref(false)
const activeDayId = ref<number | null>(null)

const currentDayData = computed(() => plannerStore.currentDay)
const currentItems = computed(() => {
  const items = currentDayData.value?.items || []
  return [...items].sort((a, b) => {
    if (a.startTime && b.startTime) return a.startTime.localeCompare(b.startTime)
    if (a.startTime) return -1
    if (b.startTime) return 1
    return (a.sortOrder || 0) - (b.sortOrder || 0)
  })
})
const currentTransports = computed(() => currentDayData.value?.transports || [])

const statusLabel = computed(() => trip.value ? getStatusLabel(trip.value.status) : '')

onMounted(async () => {
  loading.value = true
  planLoading.value = true
  try {
    trip.value = await tripApi.getById(tripId)
    await plannerStore.fetchDays(tripId)
    if (plannerStore.days.length > 0) {
      activeDayId.value = plannerStore.days[0].id
      await plannerStore.fetchDayDetail(tripId, activeDayId.value)
    }
  } finally {
    loading.value = false
    planLoading.value = false
  }
})

async function onDayChange(dayId: number) {
  activeDayId.value = dayId
  await plannerStore.fetchDayDetail(tripId, dayId)
}
</script>

<style scoped>
.detail-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 16px 20px;
}
.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
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
  padding: 24px 28px;
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border-light);
  margin-bottom: 24px;
}
.detail-card h2 {
  margin: 0 0 16px;
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 700;
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

/* Itinerary section */
.itinerary-section {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 24px 28px;
}
.section-title {
  margin: 0 0 16px;
  font-family: var(--font-display);
  font-size: 17px;
  font-weight: 600;
}
.itinerary-body {
  display: grid;
  grid-template-columns: 1fr 220px;
  gap: 24px;
}
.itinerary-sidebar {
  position: sticky;
  top: 76px;
  align-self: start;
}
.day-preview {
  min-height: 120px;
}
.empty-day {
  text-align: center;
  padding: 40px 20px;
  color: var(--color-text-secondary);
}
.empty-day p { margin: 0; }

.no-days {
  text-align: center;
  padding: 48px;
  color: var(--color-text-secondary);
}
.no-days p { margin: 0 0 16px; }

@media (max-width: 1023px) {
  .itinerary-body {
    grid-template-columns: 1fr;
  }
  .itinerary-sidebar {
    order: -1;
    position: static;
  }
}
</style>
