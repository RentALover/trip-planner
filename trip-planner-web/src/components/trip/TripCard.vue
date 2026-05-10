<template>
  <article class="trip-card card-hover" @click="$router.push(`/trips/${trip.id}`)">
    <div class="card-main">
      <div class="card-header">
        <h3 class="trip-name">{{ trip.tripName }}</h3>
        <span class="trip-status" :class="'status-' + trip.status.toLowerCase()">{{ statusLabel }}</span>
      </div>
      <div class="trip-meta">
        <span class="meta-item">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="10" r="3"/><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/></svg>
          {{ trip.destination }}
        </span>
        <span class="meta-item">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
          {{ trip.startDate }} ~ {{ trip.endDate }}
        </span>
      </div>
    </div>
  </article>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { TripData } from '@/api/trip'
import { getStatusLabel } from '@/utils/currency'

const props = defineProps<{ trip: TripData }>()

const statusLabel = computed(() => getStatusLabel(props.trip.status))
</script>

<style scoped>
.trip-card {
  display: flex;
  align-items: center;
  padding: 20px 24px;
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  margin-bottom: 12px;
  cursor: pointer;
}

.card-main { flex: 1; min-width: 0; }
.card-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}
.trip-name {
  margin: 0;
  font-family: var(--font-display);
  font-size: 17px;
  font-weight: 600;
  color: var(--color-text-primary);
  letter-spacing: 0.02em;
}
.trip-status {
  font-size: 11px;
  padding: 2px 10px;
  border-radius: 20px;
  font-weight: 500;
  flex-shrink: 0;
}
.status-planning { background: #f0e6d3; color: #a05d3f; }
.status-in_progress { background: #dce8f5; color: #3d5a80; }
.status-completed { background: #e4eddb; color: #5a6e3a; }
.status-cancelled { background: #f2ebe0; color: #8b7e6a; }

.trip-meta {
  display: flex;
  gap: 18px;
  flex-wrap: wrap;
}
.meta-item {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 13px;
  color: var(--color-text-secondary);
}

@media (max-width: 768px) {
  .trip-card { flex-direction: column; align-items: stretch; }
}
</style>
