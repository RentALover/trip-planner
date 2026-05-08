<template>
  <div class="transport-connector" :class="'transport-' + transport.transportType.toLowerCase()">
    <div class="connector-line"></div>
    <div class="connector-content">
      <span class="transport-type">{{ transportLabel }}</span>
      <span v-if="transport.estimatedDuration" class="transport-duration">
        {{ formatDuration(transport.estimatedDuration) }}
      </span>
      <span v-if="transport.cost > 0" class="transport-cost">¥{{ transport.cost }}</span>
      <span v-if="transport.routeInfo" class="transport-route">{{ transport.routeInfo }}</span>
    </div>
    <div class="connector-actions">
      <el-button text size="small" @click="$emit('edit', transport)">
        <el-icon><Edit /></el-icon>
      </el-button>
      <el-button text size="small" type="danger" @click="$emit('delete', transport.id)">
        <el-icon><Delete /></el-icon>
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { TransportData } from '@/api/transport'
import { getTransportLabel, getTransportColor } from '@/utils/currency'
import { formatDuration } from '@/utils/date'

const props = defineProps<{ transport: TransportData }>()
defineEmits(['edit', 'delete'])

const transportLabel = computed(() => getTransportLabel(props.transport.transportType))
const color = computed(() => getTransportColor(props.transport.transportType))
</script>

<style scoped>
.transport-connector {
  display: flex;
  align-items: center;
  padding: 8px 12px;
  margin: 2px 0 2px 20px;
  border-left: 2px solid #409EFF;
  background: #FAFAFA;
  border-radius: 0 6px 6px 0;
  font-size: 13px;
}
.connector-line { display: none; }
.connector-content { flex: 1; display: flex; gap: 12px; align-items: center; flex-wrap: wrap; }
.transport-type { font-weight: 500; }
.transport-duration, .transport-route { color: #909399; }
.transport-cost { color: #F56C6C; font-weight: 500; }
.connector-actions { display: flex; }
</style>
