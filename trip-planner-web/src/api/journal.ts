import api from './index'

export interface JournalData {
  id: number
  dayId: number
  tripId: number
  content: string
  mood: string
  weather: string
  imageUrls: string
  createTime: string
  updateTime: string
}

export interface JournalReq {
  content: string
  mood?: string
  weather?: string
  imageUrls?: string
}

export const journalApi = {
  get(dayId: number): Promise<JournalData | null> {
    return api.get(`/days/${dayId}/journal`)
  },
  save(dayId: number, data: JournalReq): Promise<JournalData> {
    return api.put(`/days/${dayId}/journal`, data)
  },
  delete(dayId: number): Promise<void> {
    return api.delete(`/days/${dayId}/journal`)
  }
}
