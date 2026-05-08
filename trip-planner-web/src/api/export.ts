import api from './index'

export const exportApi = {
  getTextUrl(tripId: number): string {
    const baseUrl = import.meta.env.VITE_API_BASE_URL || '/api/v1'
    const token = localStorage.getItem('token')
    return `${baseUrl}/trips/${tripId}/export/text?token=${token}`
  },
  exportJson(tripId: number): Promise<string> {
    return api.get(`/trips/${tripId}/export/json`)
  }
}
