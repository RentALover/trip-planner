import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { TripData } from '@/api/trip'

export const useTripStore = defineStore('trip', () => {
  const currentTrip = ref<TripData | null>(null)

  function setCurrentTrip(trip: TripData) {
    currentTrip.value = trip
  }

  function clearCurrentTrip() {
    currentTrip.value = null
  }

  return { currentTrip, setCurrentTrip, clearCurrentTrip }
})
