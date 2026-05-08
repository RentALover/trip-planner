import api from './index'

export interface BudgetSummary {
  totalBudget: number
  itemTotal: number
  transportTotal: number
  accommodationTotal: number
  diningTotal: number
  attractionTotal: number
  shoppingTotal: number
  otherTotal: number
  spentTotal: number
  remainingBudget: number
}

export interface BudgetByDay {
  dayId: number
  dayNumber: number
  date: string
  itemCost: number
  transportCost: number
  dayTotal: number
}

export interface BudgetByCategory {
  category: string
  count: number
  totalCost: number
  percentage: number
}

export const budgetApi = {
  getSummary(tripId: number): Promise<BudgetSummary> {
    return api.get(`/trips/${tripId}/budget`)
  },
  getByDay(tripId: number): Promise<BudgetByDay[]> {
    return api.get(`/trips/${tripId}/budget/by-day`)
  },
  getByCategory(tripId: number): Promise<BudgetByCategory[]> {
    return api.get(`/trips/${tripId}/budget/by-category`)
  }
}
