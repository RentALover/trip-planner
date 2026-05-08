<template>
  <div class="draggable-list" ref="listRef">
    <template v-for="(item, index) in items" :key="item.id">
      <div class="item-wrapper" :data-id="item.id">
        <ItemCard :item="item" @edit="$emit('editItem', item)" @delete="$emit('deleteItem', $event)" />
      </div>
      <!-- Transport connector between items -->
      <div v-if="index < items.length - 1" class="between-items">
        <template v-if="getTransport(item.id, items[index + 1].id)">
          <TransportConnector
            :transport="getTransport(item.id, items[index + 1].id)!"
            @edit="$emit('editTransport', getTransport(item.id, items[index + 1].id)!)"
            @delete="$emit('deleteTransport', $event)"
          />
        </template>
        <div v-else class="add-transport-btn" @click="$emit('addTransport', item, items[index + 1])">
          <el-icon><Plus /></el-icon>
          <span>添加交通方式</span>
        </div>
      </div>
    </template>

    <div v-if="items.length === 0" class="empty-day">
      <p>这一天还没有行程项</p>
      <el-button type="primary" size="small" @click="$emit('addItem')">添加第一个行程项</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import Sortable from 'sortablejs'
import type { ItemData } from '@/api/item'
import type { TransportData } from '@/api/transport'
import ItemCard from './ItemCard.vue'
import TransportConnector from './TransportConnector.vue'

const props = defineProps<{ items: ItemData[]; transports: TransportData[] }>()
const emit = defineEmits([
  'addItem', 'editItem', 'deleteItem',
  'addTransport', 'editTransport', 'deleteTransport',
  'reorder'
])

const listRef = ref<HTMLElement>()

function getTransport(fromId: number, toId: number): TransportData | undefined {
  return props.transports.find(t => t.fromItemId === fromId && t.toItemId === toId)
}

let sortableInstance: Sortable | null = null

onMounted(() => {
  if (listRef.value) {
    sortableInstance = Sortable.create(listRef.value, {
      handle: '.drag-handle',
      draggable: '.item-wrapper',
      animation: 150,
      onEnd() {
        const reorderedItems = props.items.map((item, index) => ({
          id: item.id,
          sortOrder: (index + 1) * 1000
        }))
        emit('reorder', reorderedItems)
      }
    })
  }
})

watch(() => props.items.length, () => {
  // Sortable auto-updates; no action needed
})
</script>

<style scoped>
.draggable-list { min-height: 100px; }
.item-wrapper { margin-bottom: 2px; }
.between-items { position: relative; }
.add-transport-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  padding: 6px;
  margin: 2px 0 2px 20px;
  border: 1px dashed #DCDFE6;
  border-radius: 6px;
  color: #909399;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
}
.add-transport-btn:hover {
  border-color: #409EFF;
  color: #409EFF;
  background: #ECF5FF;
}
.empty-day {
  text-align: center;
  padding: 40px;
  color: #909399;
}
</style>
