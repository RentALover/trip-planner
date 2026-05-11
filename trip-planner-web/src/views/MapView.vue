<template>
  <div class="map-page">
    <div class="map-header">
      <button class="back-btn" @click="$router.back()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
        返回
      </button>
      <h2>行程地图</h2>
    </div>

    <div v-if="loading" class="map-loading">加载地图中...</div>
    <div v-else-if="geoItems.length === 0" class="map-empty">
      <p>没有可展示的地点</p>
    </div>
    <div v-show="!loading && geoItems.length > 0" class="map-container" ref="mapContainer" />

    <div class="map-legend">
      <span v-for="t in legendTypes" :key="t.type" class="legend-item">
        <span class="legend-dot" :style="{ background: t.color }" /> {{ t.label }}
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

interface GeoItem {
  itemId: number; title: string; itemType: string
  location: string; lat: number; lng: number; dayNumber: number
}

const route = useRoute()
const tripId = Number(route.params.id)
const loading = ref(false)
const geoItems = ref<GeoItem[]>([])
const mapContainer = ref<HTMLElement>()

const markerColors: Record<string, string> = {
  DESTINATION: '#c47b5a', TRANSPORT: '#3d6b6b', ACCOMMODATION: '#7b8c4e',
  DINING: '#c4963e', ATTRACTION: '#b8453e', SHOPPING: '#6b7d8b', OTHER: '#8b7e6a'
}

const legendTypes = [
  { type: 'DESTINATION', label: '目的地', color: markerColors.DESTINATION },
  { type: 'ATTRACTION', label: '景点', color: markerColors.ATTRACTION },
  { type: 'DINING', label: '餐饮', color: markerColors.DINING },
  { type: 'ACCOMMODATION', label: '住宿', color: markerColors.ACCOMMODATION },
  { type: 'TRANSPORT', label: '交通', color: markerColors.TRANSPORT }
]

onMounted(async () => {
  loading.value = true
  try {
    const baseUrl = import.meta.env.VITE_API_BASE_URL || '/api/v1'
    const res = await fetch(`${baseUrl}/trips/${tripId}/geocode`, {
      headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
    })
    const body = await res.json()
    geoItems.value = body.data || []
    if (geoItems.value.length > 0) {
      await nextTick()
      setTimeout(() => initMap(), 50)
    }
  } finally { loading.value = false }
})

function initMap() {
  if (!mapContainer.value) return
  const map = L.map(mapContainer.value).setView([35, 105], 4)

  L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
    maxZoom: 18,
    attribution: '&copy; <a href="https://carto.com/">CARTO</a>'
  }).addTo(map)

  const bounds = L.latLngBounds([])

  for (const item of geoItems.value) {
    const color = markerColors[item.itemType] || '#8b7e6a'
    const icon = L.divIcon({
      className: 'custom-marker',
      html: `<div style="background:${color};width:28px;height:28px;border-radius:50%;border:2px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,0.2);display:flex;align-items:center;justify-content:center;font-size:12px">${getMarkerIcon(item.itemType)}</div>`,
      iconSize: [28, 28], iconAnchor: [14, 14]
    })
    const marker = L.marker([item.lat, item.lng], { icon }).addTo(map)
    marker.bindPopup(`<b>${item.title}</b><br/>${item.location}<br/>Day ${item.dayNumber}`)
    bounds.extend([item.lat, item.lng])
  }

  if (bounds.isValid()) map.fitBounds(bounds, { padding: [40, 40] })
  map.invalidateSize()
}

function getMarkerIcon(type: string): string {
  return {
    DESTINATION: '📍', TRANSPORT: '🚗', ACCOMMODATION: '🏨',
    DINING: '🍽️', ATTRACTION: '🏛️', SHOPPING: '🛍️'
  }[type] || '📍'
}
</script>

<style scoped>
.map-page {
  width: 100%;
  max-width: 1100px;
  margin: 0 auto;
  padding: 24px 20px;
}
.map-header {
  display: flex; align-items: center; gap: 12px; margin-bottom: 16px;
}
.map-header h2 {
  margin: 0;
  font-family: 'Noto Serif SC', var(--font-display), serif;
  font-size: 22px; font-weight: 700;
}
.back-btn {
  display: flex; align-items: center; gap: 6px;
  background: none; border: 1px solid var(--color-border);
  border-radius: 8px; padding: 6px 14px; font-size: 13px;
  color: var(--color-text-secondary); cursor: pointer;
  font-family: var(--font-body);
}
.back-btn:hover { border-color: var(--color-primary-light); color: var(--color-primary); }

.map-loading { text-align: center; padding: 100px 0; color: var(--color-text-secondary); }
.map-empty {
  text-align: center; padding: 100px 0; color: var(--color-text-secondary);
}

.map-container {
  width: 100%; height: 65vh; min-height: 420px;
  border-radius: 12px; border: 1px solid #e6dad0; background: #f0ece6;
  z-index: 1;
}

.map-legend {
  display: flex; gap: 18px; margin-top: 14px; flex-wrap: wrap; padding: 0 4px;
}
.legend-item { display: flex; align-items: center; gap: 5px; font-size: 12px; color: #8b7355; }
.legend-dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }
</style>
