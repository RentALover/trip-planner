import { defineStore } from 'pinia'
import { ref } from 'vue'
import { dayApi, type DayData, type DayDetailData } from '@/api/day'
import { itemApi, type ItemData, type ItemCreateReq, type ReorderResult } from '@/api/item'
import { transportApi, type TransportData, type TransportCreateReq } from '@/api/transport'
import { ElMessage } from 'element-plus'

export const usePlannerStore = defineStore('planner', () => {
  const days = ref<DayData[]>([])
  const currentDay = ref<DayDetailData | null>(null)
  const loading = ref(false)

  async function fetchDays(tripId: number) {
    days.value = await dayApi.list(tripId)
  }

  async function generateDays(tripId: number) {
    days.value = await dayApi.generate(tripId)
    ElMessage.success('日程已自动生成')
  }

  async function fetchDayDetail(tripId: number, dayId: number) {
    loading.value = true
    try {
      currentDay.value = await dayApi.getDetail(tripId, dayId)
    } finally {
      loading.value = false
    }
  }

  async function addItem(dayId: number, data: ItemCreateReq) {
    const item = await itemApi.create(dayId, data)
    if (currentDay.value && currentDay.value.id === dayId) {
      currentDay.value.items.push(item)
    }
    return item
  }

  async function deleteItem(dayId: number, itemId: number) {
    await itemApi.delete(dayId, itemId)
    if (currentDay.value && currentDay.value.id === dayId) {
      currentDay.value.items = currentDay.value.items.filter(i => i.id !== itemId)
      currentDay.value.transports = currentDay.value.transports.filter(
        t => t.fromItemId !== itemId && t.toItemId !== itemId
      )
    }
  }

  async function addTransport(dayId: number, data: TransportCreateReq) {
    const transport = await transportApi.create(dayId, data)
    if (currentDay.value && currentDay.value.id === dayId) {
      currentDay.value.transports.push(transport)
    }
    return transport
  }

  async function deleteTransport(dayId: number, transportId: number) {
    await transportApi.delete(dayId, transportId)
    if (currentDay.value && currentDay.value.id === dayId) {
      currentDay.value.transports = currentDay.value.transports.filter(t => t.id !== transportId)
    }
  }

  async function reorderItems(dayId: number, sortItems: { id: number; sortOrder: number }[]) {
    const result: ReorderResult = await itemApi.reorder(dayId, { items: sortItems })
    if (currentDay.value && currentDay.value.id === dayId) {
      currentDay.value.items = result.items
      currentDay.value.transports = result.transports
    }
    return result
  }

  return {
    days, currentDay, loading,
    fetchDays, generateDays, fetchDayDetail,
    addItem, deleteItem, addTransport, deleteTransport, reorderItems
  }
})
