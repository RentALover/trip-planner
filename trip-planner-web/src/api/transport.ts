import api from './index'

export interface TransportData {
  id: number
  dayId: number
  tripId: number
  fromItemId: number
  toItemId: number
  transportType: string
  departureTime: string
  estimatedDuration: number
  cost: number
  transportNumber: string
  departureStation: string
  arrivalStation: string
  routeInfo: string
  notes: string
  sortOrder: number
}

export interface TransportCreateReq {
  fromItemId: number
  toItemId: number
  transportType: string
  departureTime?: string
  estimatedDuration?: number
  transportNumber?: string
  departureStation?: string
  arrivalStation?: string
  cost?: number
  routeInfo?: string
  notes?: string
}

export interface TransportUpdateReq {
  transportType?: string
  departureTime?: string
  estimatedDuration?: number
  transportNumber?: string
  departureStation?: string
  arrivalStation?: string
  cost?: number
  routeInfo?: string
  notes?: string
}

export interface TransportLookupResult {
  departureStation: string
  arrivalStation: string
  departureTime: string
  arrivalTime: string
  durationMinutes: number
  routeInfo: string
}

export const transportApi = {
  list(dayId: number): Promise<TransportData[]> {
    return api.get(`/days/${dayId}/transports`)
  },
  create(dayId: number, data: TransportCreateReq): Promise<TransportData> {
    return api.post(`/days/${dayId}/transports`, data)
  },
  getById(dayId: number, id: number): Promise<TransportData> {
    return api.get(`/days/${dayId}/transports/${id}`)
  },
  update(dayId: number, id: number, data: TransportUpdateReq): Promise<TransportData> {
    return api.put(`/days/${dayId}/transports/${id}`, data)
  },
  delete(dayId: number, id: number): Promise<void> {
    return api.delete(`/days/${dayId}/transports/${id}`)
  },
  getBetween(dayId: number, fromItemId: number, toItemId: number): Promise<TransportData | null> {
    return api.get(`/days/${dayId}/transports/between`, {
      params: { fromItemId, toItemId }
    })
  }
}

export function lookupTransport(type: string, number: string, date: string): Promise<TransportLookupResult> {
  return api.get('/transport-lookup', { params: { type, number, date } })
}
