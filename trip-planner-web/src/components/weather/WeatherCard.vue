<template>
  <div :class="['weather-strip', { inline: inline }]" v-if="forecasts.length > 0">
    <template v-if="inline">
      <div v-for="f in forecasts" :key="f.date" class="strip-day">
        <span class="strip-date">{{ shortDate(f.date) }}</span>
        <span class="strip-icon">{{ f.icon }}</span>
        <span class="strip-temp">{{ Math.round(f.tempMax) }}°</span>
      </div>
    </template>
    <template v-else>
      <div class="weather-header">
        <span class="weather-title">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
          天气预报 · {{ city }}
        </span>
      </div>
      <div class="weather-forecast">
        <div v-for="f in forecasts" :key="f.date" class="forecast-day">
          <span class="day-label">{{ formatDay(f.date) }}</span>
          <span class="day-icon">{{ f.icon }}</span>
          <span class="day-temp">{{ Math.round(f.tempMin) }}° ~ {{ Math.round(f.tempMax) }}°</span>
          <span class="day-precip" v-if="f.precipitationProbability > 20">💧{{ f.precipitationProbability }}%</span>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

interface DailyForecast {
  date: string; weatherCode: number; weatherDesc: string
  tempMax: number; tempMin: number; precipitationProbability: number; icon: string
}

const props = defineProps<{ city: string; startDate: string; endDate: string; inline?: boolean }>()
const forecasts = ref<DailyForecast[]>([])

onMounted(async () => {
  try {
    const baseUrl = import.meta.env.VITE_API_BASE_URL || '/api/v1'
    const url = `${baseUrl}/weather/forecast?city=${encodeURIComponent(props.city)}&start=${props.startDate}&end=${props.endDate}`
    const res = await fetch(url, {
      headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
    })
    if (res.ok) {
      const body = await res.json()
      forecasts.value = body.data || []
    }
  } catch { /* weather is optional */ }
})

function shortDate(dateStr: string) {
  const d = new Date(dateStr)
  return `${d.getMonth() + 1}/${d.getDate()}`
}

function formatDay(dateStr: string) {
  const d = new Date(dateStr)
  const week = ['周日','周一','周二','周三','周四','周五','周六']
  return `${d.getMonth()+1}/${d.getDate()} ${week[d.getDay()]}`
}
</script>

<style scoped>
.weather-strip { display: none; }

.weather-strip.inline {
  display: flex;
  gap: 2px;
  align-items: center;
  padding: 4px 10px;
  background: #fefcf7;
  border: 1px solid #e8dfd0;
  border-radius: 10px;
  flex-shrink: 0;
}
.strip-day {
  display: flex; flex-direction: column; align-items: center; gap: 1px;
  padding: 3px 7px; min-width: 46px;
}
.strip-date { font-size: 10px; color: #8b7355; font-weight: 500; }
.strip-icon { font-size: 16px; }
.strip-temp { font-size: 11px; font-weight: 600; color: #3d2e1e; }

/* Full card mode */
.weather-strip:not(.inline) {
  display: block;
  background: #fdfaf6;
  border: 1px solid #e6dad0;
  border-radius: 12px;
  padding: 16px 20px;
  margin-top: 20px;
}
.weather-header { margin-bottom: 12px; }
.weather-title {
  font-family: var(--font-display);
  font-size: 14px; font-weight: 600;
  color: #5c4033;
  display: flex; align-items: center; gap: 6px;
}
.weather-forecast {
  display: flex; gap: 14px; overflow-x: auto; padding-bottom: 4px;
}
.forecast-day {
  display: flex; flex-direction: column; align-items: center; gap: 4px;
  min-width: 72px; padding: 8px 6px;
  background: #fff; border-radius: 10px; border: 1px solid #efe8dc;
}
.day-label { font-size: 11px; color: #8b7355; }
.day-icon { font-size: 22px; }
.day-temp { font-size: 12px; font-weight: 600; color: #3d2e1e; white-space: nowrap; }
.day-precip { font-size: 10px; color: #5c8bb0; }
</style>
