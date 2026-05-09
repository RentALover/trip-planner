<template>
  <div class="transport-connector" :class="'transport-' + transport.transportType.toLowerCase()">
    <div class="connector-dot"></div>
    <div class="connector-content">
      <span class="transport-type">{{ transportLabel }}</span>
      <span v-if="transport.transportNumber" class="transport-number">{{ transport.transportNumber }}</span>
      <span v-if="transport.estimatedDuration" class="transport-duration">
        {{ formatDuration(transport.estimatedDuration) }}
      </span>
      <span v-if="transport.routeInfo" class="transport-route">{{ transport.routeInfo }}</span>
      <span v-if="transport.cost > 0" class="transport-cost">¥{{ transport.cost }}</span>
    </div>
    <div class="connector-actions">
      <button class="icon-btn" @click="$emit('edit', transport)">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
      </button>
      <button class="icon-btn danger" @click="$emit('delete', transport.id)">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { TransportData } from '@/api/transport'
import { getTransportLabel } from '@/utils/currency'
import { formatDuration } from '@/utils/date'

const props = defineProps<{ transport: TransportData }>()
defineEmits(['edit', 'delete'])

const transportLabel = computed(() => getTransportLabel(props.transport.transportType))
</script>

<style scoped>
.transport-connector {
  display: flex;
  align-items: center;
  padding: 8px 12px;
  margin: 0 0 0 28px;
  border-left: 2px dashed var(--color-border);
  background: var(--color-bg-muted);
  border-radius: 0 8px 8px 0;
  font-size: 13px;
  transition: border-color 0.2s;
}
.connector-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--color-border);
  margin-left: -17px;
  margin-right: 12px;
  flex-shrink: 0;
}
.connector-content { flex: 1; display: flex; gap: 12px; align-items: center; flex-wrap: wrap; }
.transport-type { font-weight: 600; font-size: 13px; }
.transport-number { font-weight: 700; color: var(--color-accent); font-size: 13px; }
.transport-duration { color: var(--color-text-secondary); font-size: 12px; }
.transport-route { color: var(--color-text-secondary); font-size: 12px; }
.transport-cost { color: var(--color-primary); font-weight: 600; font-size: 13px; margin-left: auto; }
.connector-actions { display: flex; margin-left: 8px; }
.icon-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  color: var(--color-text-placeholder);
  transition: all 0.15s;
  display: flex;
  align-items: center;
}
.icon-btn:hover { color: var(--color-text-regular); }
.icon-btn.danger:hover { color: var(--color-danger); }
</style>
