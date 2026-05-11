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
        <el-button class="nav-btn" @click="$router.push(`/trips/${tripId}/export`)">导出</el-button>
      </div>
    </div>

    <template v-if="trip">
      <div class="detail-card">
        <div class="detail-card-header">
          <h2>{{ trip.tripName }}</h2>
          <div class="detail-card-actions">
            <el-button class="edit-btn" size="small" @click="$router.push(`/trips/${tripId}/edit`)">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
              编辑信息
            </el-button>
            <el-button v-if="trip.status === 'CANCELLED'" class="activate-btn" size="small" :loading="changingStatus" @click="handleReactivate">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
              重新启用
            </el-button>
            <el-button v-else class="cancel-btn" size="small" :loading="changingStatus" @click="handleCancelTrip">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
              取消行程
            </el-button>
            <el-button class="delete-btn" size="small" :loading="deleting" @click="handleDelete">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
              删除
            </el-button>
          </div>
        </div>
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
        <h3 class="section-title">{{ sectionTitle }}</h3>
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
              :readonly="true"
            />
          </div>
        </div>
      </div>
      <div v-else-if="!planLoading" class="no-days">
        <p>还没有日程安排</p>
        <el-button type="primary" @click="$router.push(`/trips/${tripId}/planner`)">去规划行程</el-button>
      </div>

      <!-- Travel journal -- only during or after trip -->
      <JournalSection
        v-if="trip && activeDayId && (trip.status === 'IN_PROGRESS' || trip.status === 'COMPLETED')"
        :dayId="activeDayId"
      />

      <!-- Photo gallery -->
      <PhotoGallery v-if="trip" :tripId="tripId" :itineraryLocations="itineraryLocations" :tripDestination="trip.destination" />
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { usePlannerStore } from '@/stores/planner'
import { tripApi, type TripData } from '@/api/trip'
import { getStatusLabel } from '@/utils/currency'
import { ElMessage, ElMessageBox } from 'element-plus'
import DayTabs from '@/components/planner/DayTabs.vue'
import DraggableItemList from '@/components/planner/DraggableItemList.vue'
import DaySummary from '@/components/planner/DaySummary.vue'
import JournalSection from '@/components/planner/JournalSection.vue'
import PhotoGallery from '@/components/planner/PhotoGallery.vue'

const route = useRoute()
const router = useRouter()
const tripId = Number(route.params.id)
const plannerStore = usePlannerStore()

const trip = ref<TripData | null>(null)
const loading = ref(false)
const planLoading = ref(false)
const deleting = ref(false)
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

const itineraryLocations = computed(() => {
  const locs = new Set<string>()
  if (trip.value?.destination) locs.add(trip.value.destination)
  for (const item of currentItems.value) {
    if (item.location) locs.add(item.location)
  }
  return [...locs]
})

const statusLabel = computed(() => trip.value ? getStatusLabel(trip.value.status) : '')

const sectionTitle = computed(() => {
  if (!trip.value) return '行程预览'
  const map: Record<string, string> = {
    PLANNING: '行程预览', IN_PROGRESS: '行程进行中', COMPLETED: '行程回顾', CANCELLED: '行程概览'
  }
  return map[trip.value.status] || '行程预览'
})

const changingStatus = ref(false)

async function handleCancelTrip() {
  try {
    await ElMessageBox.confirm('确定取消此行程？', '确认取消', {
      confirmButtonText: '确定', cancelButtonText: '返回', type: 'warning'
    })
  } catch { return }
  changingStatus.value = true
  try {
    const updated = await tripApi.updateStatus(tripId, 'CANCELLED')
    if (trip.value) trip.value.status = updated.status
    ElMessage.success('行程已取消')
  } finally { changingStatus.value = false }
}

async function handleReactivate() {
  changingStatus.value = true
  try {
    const updated = await tripApi.updateStatus(tripId, 'PLANNING')
    if (trip.value) trip.value.status = updated.status
    ElMessage.success('行程已重新启用')
  } finally { changingStatus.value = false }
}

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

async function handleDelete() {
  try {
    await ElMessageBox.confirm('确定删除此行程？删除后不可恢复。', '确认删除', {
      confirmButtonText: '删除', cancelButtonText: '取消', type: 'warning'
    })
  } catch { return }
  deleting.value = true
  try {
    await tripApi.delete(tripId)
    ElMessage.success('已删除')
    router.push('/')
  } finally { deleting.value = false }
}

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
.detail-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
.detail-card-header h2 {
  margin: 0;
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 700;
}
.detail-card-actions { display: flex; gap: 8px; flex-shrink: 0; }
.edit-btn, .cancel-btn, .activate-btn, .delete-btn { border-radius: 8px; display: flex; align-items: center; gap: 4px; }
.cancel-btn { color: var(--color-warning); }
.activate-btn { color: var(--color-success); }
.delete-btn { color: var(--color-danger); }
.status-badge {
  font-size: 12px;
  padding: 2px 12px;
  border-radius: 20px;
  font-weight: 500;
}
.status-planning { background: #f0e6d3; color: #a05d3f; }
.status-in_progress { background: #dce8f5; color: #3d5a80; }
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
