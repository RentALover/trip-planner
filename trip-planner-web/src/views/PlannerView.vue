<template>
  <div class="planner-page">
    <div class="planner-header">
      <el-button text @click="$router.back()"><el-icon><ArrowLeft /></el-icon>返回</el-button>
      <h2 v-if="trip">{{ trip.tripName }} - 日程规划</h2>
      <div class="header-actions">
        <el-button @click="handleGenerateDays" :disabled="!trip">自动生成日程</el-button>
        <el-button @click="$router.push(`/trips/${tripId}/budget`)">查看预算</el-button>
      </div>
    </div>

    <div v-if="trip && plannerStore.days.length > 0" class="planner-body">
      <div class="planner-main">
        <DayTabs v-model="activeDayId" :days="plannerStore.days" @change="onDayChange" />

        <div v-loading="plannerStore.loading" class="day-content">
          <template v-if="currentItems.length > 0 || currentTransports.length > 0">
            <DraggableItemList
              :items="currentItems"
              :transports="currentTransports"
              @addItem="showItemDialog = true"
              @editItem="handleEditItem"
              @deleteItem="handleDeleteItem"
              @addTransport="handleAddTransportClick"
              @editTransport="handleEditTransport"
              @deleteTransport="handleDeleteTransport"
              @reorder="handleReorder"
            />
          </template>
          <div v-else class="empty-day-state">
            <el-empty description="这一天还没有行程项" :image-size="100">
              <el-button type="primary" @click="showItemDialog = true">添加行程项</el-button>
            </el-empty>
          </div>

          <div v-if="currentItems.length > 0" class="add-item-bottom">
            <el-button @click="showItemDialog = true">
              <el-icon><Plus /></el-icon>添加行程项
            </el-button>
          </div>
        </div>
      </div>

      <div class="planner-sidebar">
        <DaySummary
          :items="currentItems"
          :transports="currentTransports"
          @addItem="showItemDialog = true"
          @generateDays="handleGenerateDays"
        />
      </div>
    </div>

    <div v-else-if="trip" class="no-days">
      <el-empty description="还没有日程安排">
        <el-button type="primary" @click="handleGenerateDays">自动生成日程</el-button>
      </el-empty>
    </div>

    <!-- Dialogs -->
    <ItemFormDialog v-model="showItemDialog" :editItem="editingItem"
      @submit="handleItemSubmit" @cancel="editingItem = null" />
    <TransportFormDialog v-model="showTransportDialog" :editTransport="editingTransport"
      :fromTitle="transportFromTitle" :toTitle="transportToTitle"
      @submit="handleTransportSubmit" @cancel="editingTransport = null" />

    <!-- Delete confirm -->
    <el-dialog v-model="showDeleteConfirm" title="确认删除" width="360px">
      <p>{{ deleteMessage }}</p>
      <template #footer>
        <el-button @click="showDeleteConfirm = false">取消</el-button>
        <el-button type="danger" :loading="deleting" @click="confirmDelete">删除</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { usePlannerStore } from '@/stores/planner'
import { tripApi, type TripData } from '@/api/trip'
import type { ItemData, ItemCreateReq } from '@/api/item'
import type { TransportData, TransportCreateReq } from '@/api/transport'
import { ElMessage } from 'element-plus'
import DayTabs from '@/components/planner/DayTabs.vue'
import DraggableItemList from '@/components/planner/DraggableItemList.vue'
import DaySummary from '@/components/planner/DaySummary.vue'
import ItemFormDialog from '@/components/planner/ItemFormDialog.vue'
import TransportFormDialog from '@/components/planner/TransportFormDialog.vue'

const route = useRoute()
const tripId = Number(route.params.id)
const plannerStore = usePlannerStore()

const trip = ref<TripData | null>(null)
const activeDayId = ref<number | null>(null)

// Item dialog
const showItemDialog = ref(false)
const editingItem = ref<ItemData | null>(null)

// Transport dialog
const showTransportDialog = ref(false)
const editingTransport = ref<TransportData | null>(null)
const transportFromId = ref(0)
const transportToId = ref(0)
const transportFromTitle = ref('')
const transportToTitle = ref('')

// Delete confirm
const showDeleteConfirm = ref(false)
const deleteMessage = ref('')
const deleting = ref(false)
let deleteAction: (() => Promise<void>) | null = null

const currentDayData = computed(() => plannerStore.currentDay)
const currentItems = computed(() => currentDayData.value?.items || [])
const currentTransports = computed(() => currentDayData.value?.transports || [])

onMounted(async () => {
  trip.value = await tripApi.getById(tripId)
  await plannerStore.fetchDays(tripId)
  if (plannerStore.days.length > 0) {
    activeDayId.value = plannerStore.days[0].id
    await plannerStore.fetchDayDetail(tripId, activeDayId.value)
  }
})

async function onDayChange(dayId: number) {
  activeDayId.value = dayId
  await plannerStore.fetchDayDetail(tripId, dayId)
}

async function handleGenerateDays() {
  if (!trip.value) return
  await plannerStore.generateDays(tripId)
  if (plannerStore.days.length > 0) {
    activeDayId.value = plannerStore.days[0].id
    await plannerStore.fetchDayDetail(tripId, activeDayId.value)
  }
}

// Item handlers
function handleEditItem(item: ItemData) {
  editingItem.value = item
  showItemDialog.value = true
}

async function handleItemSubmit(data: any) {
  if (!activeDayId.value) return
  try {
    if (editingItem.value) {
      await plannerStore.addItem(activeDayId.value, data)
      // Refresh to get updated state
      await plannerStore.fetchDayDetail(tripId, activeDayId.value)
    } else {
      await plannerStore.addItem(activeDayId.value, data)
      await plannerStore.fetchDayDetail(tripId, activeDayId.value)
    }
    editingItem.value = null
  } catch { /* error handled by interceptor */ }
}

function handleDeleteItem(itemId: number) {
  deleteMessage.value = '删除此行程项将同时移除关联的交通方式，确定继续？'
  deleteAction = async () => {
    await plannerStore.deleteItem(activeDayId.value!, itemId)
    ElMessage.success('删除成功')
  }
  showDeleteConfirm.value = true
}

// Transport handlers
function handleAddTransportClick(fromItem: ItemData, toItem: ItemData) {
  transportFromId.value = fromItem.id
  transportToId.value = toItem.id
  transportFromTitle.value = fromItem.title
  transportToTitle.value = toItem.title
  editingTransport.value = null
  showTransportDialog.value = true
}

function handleEditTransport(transport: TransportData) {
  editingTransport.value = transport
  const fromItem = currentItems.value.find(i => i.id === transport.fromItemId)
  const toItem = currentItems.value.find(i => i.id === transport.toItemId)
  transportFromTitle.value = fromItem?.title || ''
  transportToTitle.value = toItem?.title || ''
  showTransportDialog.value = true
}

async function handleTransportSubmit(data: any) {
  if (!activeDayId.value) return
  try {
    if (editingTransport.value) {
      const { transportApi } = await import('@/api/transport')
      await transportApi.update(activeDayId.value, editingTransport.value.id, data)
      await plannerStore.fetchDayDetail(tripId, activeDayId.value)
    } else {
      await plannerStore.addTransport(activeDayId.value, {
        ...data,
        fromItemId: transportFromId.value,
        toItemId: transportToId.value
      } as TransportCreateReq)
      await plannerStore.fetchDayDetail(tripId, activeDayId.value)
    }
    editingTransport.value = null
  } catch { /* handled */ }
}

function handleDeleteTransport(transportId: number) {
  deleteMessage.value = '确定删除这段交通方式？'
  deleteAction = async () => {
    await plannerStore.deleteTransport(activeDayId.value!, transportId)
    ElMessage.success('删除成功')
  }
  showDeleteConfirm.value = true
}

async function handleReorder(sortItems: { id: number; sortOrder: number }[]) {
  if (!activeDayId.value) return
  await plannerStore.reorderItems(activeDayId.value, sortItems)
}

async function confirmDelete() {
  if (!deleteAction) return
  deleting.value = true
  try {
    await deleteAction()
  } finally {
    deleting.value = false
    showDeleteConfirm.value = false
  }
}
</script>

<style scoped>
.planner-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 12px 20px;
}
.planner-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
  flex-wrap: wrap;
}
.planner-header h2 { margin: 0; font-size: 18px; flex: 1; }
.header-actions { display: flex; gap: 8px; }
.planner-body {
  display: grid;
  grid-template-columns: 1fr 240px;
  gap: 20px;
}
.day-content { min-height: 200px; }
.add-item-bottom { margin-top: 12px; text-align: center; }
.empty-day-state { padding: 40px 0; }
.no-days { padding: 60px 0; }

@media (max-width: 1023px) {
  .planner-body {
    grid-template-columns: 1fr;
  }
  .planner-sidebar {
    order: -1;
    margin-bottom: 16px;
  }
}
</style>
