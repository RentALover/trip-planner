import api from './index'

export interface TripCreateReq {
  tripName: string
  destination: string
  startDate: string
  endDate: string
  numPeople?: number
  notes?: string
  totalBudget?: number
}

export interface TripUpdateReq {
  tripName?: string
  destination?: string
  startDate?: string
  endDate?: string
  numPeople?: number
  notes?: string
  totalBudget?: number
}

export interface TripData {
  id: number
  tripName: string
  destination: string
  startDate: string
  endDate: string
  numPeople: number
  notes: string
  status: string
  totalBudget: number
  coverImageUrl: string
  daysCount: number
  createTime: string
  updateTime: string
}

export interface PageResult<T> {
  total: number
  page: number
  size: number
  records: T[]
}

export interface TripQuery {
  page?: number
  size?: number
  status?: string
  keyword?: string
  sortBy?: string
  sortDir?: string
}

export const tripApi = {
  create(data: TripCreateReq): Promise<TripData> {
    return api.post('/trips', data)
  },
  list(query: TripQuery): Promise<PageResult<TripData>> {
    return api.get('/trips', { params: query })
  },
  getById(id: number): Promise<TripData> {
    return api.get(`/trips/${id}`)
  },
  update(id: number, data: TripUpdateReq): Promise<TripData> {
    return api.put(`/trips/${id}`, data)
  },
  delete(id: number): Promise<void> {
    return api.delete(`/trips/${id}`)
  },
  copy(id: number): Promise<TripData> {
    return api.post(`/trips/${id}/copy`)
  },
  updateStatus(id: number, status: string): Promise<TripData> {
    return api.patch(`/trips/${id}/status`, { status })
  }
}
