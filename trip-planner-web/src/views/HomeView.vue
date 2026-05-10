<template>
  <div class="page-container">
    <div class="page-header">
      <div class="header-text">
        <h2>我的行程</h2>
        <p class="header-sub">规划你的下一次冒险</p>
      </div>
      <el-button type="primary" size="large" class="create-btn" @click="$router.push('/trips/create')">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        创建行程
      </el-button>
    </div>

    <TripFilter @search="handleSearch" @filter="handleFilter" />

    <div v-loading="loading">
      <template v-if="trips.length > 0">
        <TransitionGroup name="trip-list" tag="div">
          <TripCard v-for="trip in trips" :key="trip.id" :trip="trip" />
        </TransitionGroup>
        <el-pagination
          v-if="total > pageSize"
          v-model:current-page="currentPage"
          :page-size="pageSize"
          :total="total"
          layout="prev, pager, next"
          @current-change="fetchTrips"
          class="pagination-wrap"
        />
      </template>
      <EmptyState v-else description="还没有行程，快来创建第一个吧"
        action-text="创建行程" @action="$router.push('/trips/create')" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { tripApi, type TripData } from '@/api/trip'
import { ElMessage } from 'element-plus'
import TripCard from '@/components/trip/TripCard.vue'
import TripFilter from '@/components/trip/TripFilter.vue'
import EmptyState from '@/components/common/EmptyState.vue'

const trips = ref<TripData[]>([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = 10
const total = ref(0)
const keyword = ref('')
const status = ref('')

async function fetchTrips() {
  loading.value = true
  try {
    const res = await tripApi.list({
      page: currentPage.value, size: pageSize,
      keyword: keyword.value, status: status.value
    })
    trips.value = res.records
    total.value = res.total
  } finally {
    loading.value = false
  }
}

function handleSearch(val: string) {
  keyword.value = val
  currentPage.value = 1
  fetchTrips()
}

function handleFilter(val: string) {
  status.value = val
  currentPage.value = 1
  fetchTrips()
}

onMounted(fetchTrips)
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}
.header-text h2 {
  margin: 0;
  font-family: var(--font-display);
  font-size: 24px;
  font-weight: 700;
  color: var(--color-text-primary);
  letter-spacing: 0.03em;
}
.header-sub {
  margin: 4px 0 0;
  font-size: 14px;
  color: var(--color-text-secondary);
}
.create-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  border-radius: 10px;
  padding: 10px 22px;
  font-weight: 600;
}

.pagination-wrap {
  margin-top: 24px;
  justify-content: center;
  display: flex;
}

.trip-list-enter-active,
.trip-list-leave-active {
  transition: all 0.3s ease;
}
.trip-list-enter-from {
  opacity: 0;
  transform: translateY(12px);
}
.trip-list-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}
</style>
