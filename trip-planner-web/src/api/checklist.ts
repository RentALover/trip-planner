import api from './index'

export interface ChecklistData {
  id: number
  tripId: number
  title: string
  category: string
  isChecked: number
  sortOrder: number
}

export interface ChecklistItemReq {
  title: string
  category?: string
}

export const checklistApi = {
  list(tripId: number, category?: string): Promise<ChecklistData[]> {
    return api.get(`/trips/${tripId}/checklist`, { params: { category } })
  },
  create(tripId: number, data: ChecklistItemReq): Promise<ChecklistData> {
    return api.post(`/trips/${tripId}/checklist`, data)
  },
  update(tripId: number, id: number, data: ChecklistItemReq): Promise<ChecklistData> {
    return api.put(`/trips/${tripId}/checklist/${id}`, data)
  },
  delete(tripId: number, id: number): Promise<void> {
    return api.delete(`/trips/${tripId}/checklist/${id}`)
  },
  toggle(tripId: number, id: number): Promise<ChecklistData> {
    return api.patch(`/trips/${tripId}/checklist/${id}/toggle`)
  },
  toggleAll(tripId: number, isChecked: boolean): Promise<ChecklistData[]> {
    return api.patch(`/trips/${tripId}/checklist/toggle-all`, { isChecked })
  },
  loadPreset(tripId: number): Promise<ChecklistData[]> {
    return api.post(`/trips/${tripId}/checklist/preset`)
  }
}
