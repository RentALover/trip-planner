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
    <div class="card-actions" @click.stop>
      <el-button class="action-btn primary" @click="$router.push(`/trips/${trip.id}/planner`)">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="5 3 19 12 5 21 5 3"/></svg>
        规划
      </el-button>
      <el-button class="action-btn" @click="$router.push(`/trips/${trip.id}/edit`)">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
        编辑
      </el-button>
      <el-button class="action-btn danger" @click="$emit('delete', trip.id)">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
        删除
      </el-button>
    </div>
  </article>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { TripData } from '@/api/trip'
import { getStatusLabel } from '@/utils/currency'

const props = defineProps<{ trip: TripData }>()
defineEmits(['delete'])

const statusLabel = computed(() => getStatusLabel(props.trip.status))
</script>

<style scoped>
.trip-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  margin-bottom: 12px;
  cursor: pointer;
  gap: 16px;
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

.card-actions {
  display: flex;
  gap: 4px;
  flex-shrink: 0;
}
.action-btn {
  padding: 6px 12px;
  border: none;
  background: transparent;
  color: var(--color-text-secondary);
  font-size: 13px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: all 0.15s;
}
.action-btn:hover { background: var(--color-bg-muted); color: var(--color-text-primary); }
.action-btn.primary:hover { background: #f9f2ee; color: var(--color-primary); }
.action-btn.danger:hover { background: #fdf1f0; color: var(--color-danger); }

@media (max-width: 768px) {
  .trip-card { flex-direction: column; align-items: stretch; }
  .card-actions { border-top: 1px solid var(--color-border-light); padding-top: 12px; margin-top: 4px; justify-content: flex-end; }
}
</style>
