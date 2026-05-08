import api from './index'
import type { TransportData } from './transport'

export interface ItemData {
  id: number
  dayId: number
  tripId: number
  itemType: string
  title: string
  description: string
  startTime: string
  endTime: string
  location: string
  cost: number
  itemDetails: string
  sortOrder: number
  imageUrl: string
}

export interface ItemCreateReq {
  itemType: string
  title: string
  description?: string
  startTime?: string
  endTime?: string
  location?: string
  cost?: number
  itemDetails?: string
  sortOrder?: number
}

export interface ItemUpdateReq {
  title?: string
  description?: string
  startTime?: string
  endTime?: string
  location?: string
  cost?: number
  itemDetails?: string
}

export interface ItemSortReq {
  items: { id: number; sortOrder: number }[]
}

export interface ReorderResult {
  items: ItemData[]
  transports: TransportData[]
}

export interface ItemMoveReq {
  targetDayId: number
  sortOrder?: number
}

export interface BatchTimeEntry {
  id: number
  startTime: string
  endTime: string
}

export interface ItemBatchTimeUpdateReq {
  items: BatchTimeEntry[]
}

export const itemApi = {
  list(dayId: number): Promise<ItemData[]> {
    return api.get(`/days/${dayId}/items`)
  },
  create(dayId: number, data: ItemCreateReq): Promise<ItemData> {
    return api.post(`/days/${dayId}/items`, data)
  },
  getById(dayId: number, itemId: number): Promise<ItemData> {
    return api.get(`/days/${dayId}/items/${itemId}`)
  },
  update(dayId: number, itemId: number, data: ItemUpdateReq): Promise<ItemData> {
    return api.put(`/days/${dayId}/items/${itemId}`, data)
  },
  delete(dayId: number, itemId: number): Promise<void> {
    return api.delete(`/days/${dayId}/items/${itemId}`)
  },
  reorder(dayId: number, data: ItemSortReq): Promise<ReorderResult> {
    return api.put(`/days/${dayId}/items/reorder`, data)
  },
  batchCreate(dayId: number, items: ItemCreateReq[]): Promise<ItemData[]> {
    return api.post(`/days/${dayId}/items/batch`, { items })
  },
  moveToDay(dayId: number, itemId: number, data: ItemMoveReq): Promise<ItemData> {
    return api.patch(`/days/${dayId}/items/${itemId}/move`, data)
  },
  batchUpdateTimes(dayId: number, data: ItemBatchTimeUpdateReq): Promise<ItemData[]> {
    return api.put(`/days/${dayId}/items/batch-times`, data)
  }
}
