import api from './index'

export interface PhotoData {
  id: number
  tripId: number
  url: string
  thumbnailUrl: string
  location: string
  photoType: string
  isFeatured: boolean
  sortOrder: number
  createTime: string
}

export interface PhotoAlbumData {
  id: number
  tripId: number
  tripName: string
  tripDestination: string
  tripStartDate: string
  url: string
  thumbnailUrl: string
  location: string
  photoType: string
  isFeatured: boolean
  sortOrder: number
  createTime: string
}

export const photoApi = {
  listAll(page = 1, size = 30): Promise<PhotoAlbumData[]> {
    return api.get('/photos', { params: { page, size } })
  },
  list(tripId: number, params?: { location?: string; photoType?: string; featured?: boolean }): Promise<PhotoData[]> {
    return api.get(`/trips/${tripId}/photos`, { params })
  },
  uploadBatch(tripId: number, files: File[], location?: string, photoType?: string): Promise<PhotoData[]> {
    const formData = new FormData()
    files.forEach(f => formData.append('files', f))
    if (location) formData.append('location', location)
    if (photoType) formData.append('photoType', photoType)
    return api.post(`/trips/${tripId}/photos/batch`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  },
  batchUpdate(tripId: number, ids: number[], data: { location?: string; photoType?: string; isFeatured?: boolean }): Promise<PhotoData[]> {
    return api.put(`/trips/${tripId}/photos/batch`, { ids, ...data })
  },
  batchDelete(tripId: number, ids: number[]): Promise<void> {
    return api.delete(`/trips/${tripId}/photos/batch`, { data: { ids } })
  },
  delete(tripId: number, photoId: number): Promise<void> {
    return api.delete(`/trips/${tripId}/photos/${photoId}`)
  },
  toggleFeatured(tripId: number, photoId: number): Promise<PhotoData> {
    return api.patch(`/trips/${tripId}/photos/${photoId}/featured`)
  }
}
