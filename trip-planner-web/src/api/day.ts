import api from './index'
import type { ItemData } from './item'
import type { TransportData } from './transport'

export interface DayData {
  id: number
  tripId: number
  dayNumber: number
  date: string
  notes: string
  itemCount: number
}

export interface DayDetailData {
  id: number
  tripId: number
  dayNumber: number
  date: string
  notes: string
  items: ItemData[]
  transports: TransportData[]
}

export interface DayCreateReq {
  date: string
  notes?: string
}

export const dayApi = {
  list(tripId: number): Promise<DayData[]> {
    return api.get(`/trips/${tripId}/days`)
  },
  create(tripId: number, data: DayCreateReq): Promise<DayData> {
    return api.post(`/trips/${tripId}/days`, data)
  },
  generate(tripId: number): Promise<DayData[]> {
    return api.post(`/trips/${tripId}/days/generate`)
  },
  getDetail(tripId: number, dayId: number): Promise<DayDetailData> {
    return api.get(`/trips/${tripId}/days/${dayId}`)
  },
  update(tripId: number, dayId: number, data: DayCreateReq): Promise<DayData> {
    return api.put(`/trips/${tripId}/days/${dayId}`, data)
  },
  delete(tripId: number, dayId: number): Promise<void> {
    return api.delete(`/trips/${tripId}/days/${dayId}`)
  }
}
