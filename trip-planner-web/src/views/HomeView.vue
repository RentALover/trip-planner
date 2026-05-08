<template>
  <div class="page-container">
    <div class="page-header">
      <h2>我的行程</h2>
      <el-button type="primary" @click="$router.push('/trips/create')">
        <el-icon><Plus /></el-icon>创建行程
      </el-button>
    </div>

    <TripFilter @search="handleSearch" @filter="handleFilter" />

    <div v-loading="loading">
      <template v-if="trips.length > 0">
        <TripCard v-for="trip in trips" :key="trip.id" :trip="trip"
          @delete="handleDelete(trip.id)" />
        <el-pagination
          v-if="total > pageSize"
          v-model:current-page="currentPage"
          :page-size="pageSize"
          :total="total"
          layout="prev, pager, next"
          @current-change="fetchTrips"
          style="margin-top: 20px; justify-content: center; display: flex;"
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
import { ElMessage, ElMessageBox } from 'element-plus'
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

async function handleDelete(id: number) {
  try {
    await ElMessageBox.confirm('确定删除这个行程吗？', '删除确认', { type: 'warning' })
    await tripApi.delete(id)
    ElMessage.success('删除成功')
    fetchTrips()
  } catch { /* cancelled */ }
}

onMounted(fetchTrips)
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.page-header h2 { margin: 0; }
</style>
