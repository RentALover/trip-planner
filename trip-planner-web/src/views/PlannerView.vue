<template>
  <div class="planner-page">
    <div class="planner-header">
      <button class="back-btn" @click="$router.back()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
        返回
      </button>
      <h2 v-if="trip" class="planner-title">{{ trip.tripName }}</h2>
      <div class="header-actions">
        <el-button class="action-btn" @click="handleGenerateDays" :disabled="!trip">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>
          自动生成日程
        </el-button>
        <el-button class="action-btn" @click="$router.push(`/trips/${tripId}/budget`)">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
          查看预算
        </el-button>
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
              @insertItem="handleInsertItem"
            />
          </template>
          <div v-else class="empty-day-state">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2"><circle cx="12" cy="10" r="3"/><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/></svg>
            <p>这一天还没有行程项</p>
            <el-button type="primary" @click="showItemDialog = true">添加行程项</el-button>
          </div>

          <div v-if="currentItems.length > 0" class="add-item-bottom">
            <el-button @click="showItemDialog = true">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
              添加行程项
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
      <svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2"><circle cx="12" cy="10" r="3"/><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/></svg>
      <p>还没有日程安排</p>
      <el-button type="primary" size="large" @click="handleGenerateDays">自动生成日程</el-button>
    </div>

    <!-- Dialogs -->
    <ItemFormDialog v-model="showItemDialog" :editItem="editingItem"
      :suggestedStartTime="suggestedStartTime"
      @submit="handleItemSubmit" @cancel="editingItem = null; suggestedStartTime = undefined" />
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
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { usePlannerStore } from '@/stores/planner'
import { tripApi, type TripData } from '@/api/trip'
import type { ItemData } from '@/api/item'
import type { TransportData, TransportCreateReq } from '@/api/transport'
import { ElMessage, ElMessageBox } from 'element-plus'
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

const showItemDialog = ref(false)
const editingItem = ref<ItemData | null>(null)

const showTransportDialog = ref(false)
const editingTransport = ref<TransportData | null>(null)
const transportFromId = ref(0)
const transportToId = ref(0)
const transportFromTitle = ref('')
const transportToTitle = ref('')

const showDeleteConfirm = ref(false)
const deleteMessage = ref('')
const deleting = ref(false)
let deleteAction: (() => Promise<void>) | null = null

// Suggested startTime for inserting between existing items
const suggestedStartTime = ref<string | undefined>(undefined)

// Time utility helpers
function timeToMinutes(time: string): number {
  const [h, m] = time.split(':').map(Number)
  return h * 60 + m
}

function minutesToTime(minutes: number): string {
  const h = Math.floor(minutes / 60) % 24
  const m = minutes % 60
  return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`
}

function findOverlap(items: ItemData[], newStart: string, newEnd: string, excludeId?: number): ItemData | null {
  for (const item of items) {
    if (excludeId !== undefined && item.id === excludeId) continue
    if (!item.startTime || !item.endTime) continue
    if (newStart < item.endTime && newEnd > item.startTime) {
      return item
    }
  }
  return null
}

const currentDayData = computed(() => plannerStore.currentDay)

// Sort items by startTime ascending; items without startTime go to the end (sorted by sortOrder)
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

function handleEditItem(item: ItemData) {
  editingItem.value = item
  showItemDialog.value = true
}

function handleInsertItem(prevItem: ItemData, nextItem: ItemData) {
  editingItem.value = null
  suggestedStartTime.value = prevItem.endTime || undefined
  showItemDialog.value = true
}

async function handleItemSubmit(data: any) {
  if (!activeDayId.value) return
  const newStart: string | undefined = data.startTime
  const newEnd: string | undefined = data.endTime

  try {
    // Check for time conflicts if both times are provided
    if (newStart && newEnd) {
      const excludeId = editingItem.value?.id
      const overlap = findOverlap(currentItems.value, newStart, newEnd, excludeId)

      if (overlap) {
        try {
          await ElMessageBox.confirm(
            `时间段与「${overlap.title}」(${overlap.startTime}-${overlap.endTime}) 冲突，是否自动顺延后续行程？`,
            '时间冲突',
            { confirmButtonText: '自动顺延', cancelButtonText: '取消', type: 'warning' }
          )

          // Calculate shift and cascade
          const shiftMs = timeToMinutes(newEnd) - timeToMinutes(overlap.startTime!)
          if (shiftMs > 0) {
            const toShift = currentItems.value.filter(item => {
              if (excludeId !== undefined && item.id === excludeId) return false
              if (!item.startTime || !item.endTime) return false
              return timeToMinutes(item.startTime) >= timeToMinutes(overlap.startTime!)
            })

            if (toShift.length > 0) {
              const batchItems = toShift.map(item => ({
                id: item.id,
                startTime: minutesToTime(timeToMinutes(item.startTime!) + shiftMs),
                endTime: minutesToTime(timeToMinutes(item.endTime!) + shiftMs)
              }))
              await plannerStore.batchUpdateItemTimes(activeDayId.value!, { items: batchItems })
            }
          }
        } catch {
          // User cancelled the dialog
          return
        }
      }
    }

    // Proceed with save
    if (editingItem.value) {
      const { itemType, ...updateData } = data
      await plannerStore.updateItem(activeDayId.value, editingItem.value.id, updateData)
    } else {
      await plannerStore.addItem(activeDayId.value, data)
    }
    await plannerStore.fetchDayDetail(tripId, activeDayId.value)
    editingItem.value = null
    suggestedStartTime.value = undefined
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
  padding: 16px 20px;
}

/* Header */
.planner-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
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
.back-btn:hover {
  border-color: var(--color-primary-light);
  color: var(--color-primary);
  background: #fdfaf7;
}
.planner-title {
  margin: 0;
  font-family: var(--font-display);
  font-size: 20px;
  font-weight: 700;
  flex: 1;
  letter-spacing: 0.02em;
}
.header-actions {
  display: flex;
  gap: 8px;
}
.action-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  border-radius: 8px;
}

/* Grid layout */
.planner-body {
  display: grid;
  grid-template-columns: 1fr 260px;
  gap: 24px;
}
.planner-sidebar {
  position: sticky;
  top: 76px;
  align-self: start;
}

/* Day content */
.day-content { min-height: 200px; }
.add-item-bottom {
  margin-top: 16px;
  text-align: center;
}
.add-item-bottom .el-button {
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 6px;
}

/* Empty states */
.empty-day-state {
  text-align: center;
  padding: 56px 20px;
  color: var(--color-text-secondary);
}
.empty-day-state svg { color: #c8bdab; margin-bottom: 12px; }
.empty-day-state p { margin: 0 0 16px; font-size: 14px; }

.no-days {
  text-align: center;
  padding: 80px 0;
  color: var(--color-text-secondary);
}
.no-days svg { color: #c8bdab; margin-bottom: 16px; }
.no-days p { margin: 0 0 20px; font-size: 15px; }

@media (max-width: 1023px) {
  .planner-body {
    grid-template-columns: 1fr;
  }
  .planner-sidebar {
    order: -1;
    margin-bottom: 16px;
    position: static;
  }
}
</style>
