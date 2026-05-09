<template>
  <div class="draggable-list" ref="listRef">
    <template v-for="(item, index) in items" :key="item.id">
      <div class="item-wrapper" :data-id="item.id">
        <ItemCard :item="item" :readonly="readonly" @edit="$emit('editItem', item)" @delete="$emit('deleteItem', $event)" />
      </div>
      <div v-if="index < items.length - 1" class="between-items">
        <div v-if="!readonly" class="insert-between" @click="$emit('insertItem', item, items[index + 1])" title="在此插入行程项">
          <div class="insert-line"></div>
          <div class="insert-btn">+</div>
          <div class="insert-line"></div>
        </div>
        <!-- Transport connector or add-transport button -->
        <template v-if="getTransport(item.id, items[index + 1].id)">
          <TransportConnector
            :transport="getTransport(item.id, items[index + 1].id)!"
            :readonly="readonly"
            @edit="$emit('editTransport', getTransport(item.id, items[index + 1].id)!)"
            @delete="$emit('deleteTransport', $event)"
          />
        </template>
        <div v-else-if="!readonly" class="add-transport-btn" @click="$emit('addTransport', item, items[index + 1])">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          <span>添加交通方式</span>
        </div>
      </div>
    </template>

    <div v-if="items.length === 0" class="empty-day">
      <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2"><circle cx="12" cy="10" r="3"/><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/></svg>
      <p>这一天还没有行程项</p>
      <el-button type="primary" @click="$emit('addItem')">添加第一个行程项</el-button>
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

const props = defineProps<{ items: ItemData[]; transports: TransportData[]; readonly?: boolean }>()
const emit = defineEmits([
  'addItem', 'editItem', 'deleteItem',
  'addTransport', 'editTransport', 'deleteTransport',
  'reorder', 'insertItem'
])

const listRef = ref<HTMLElement>()

function getTransport(fromId: number, toId: number): TransportData | undefined {
  return props.transports.find(t => t.fromItemId === fromId && t.toItemId === toId)
}

let sortableInstance: any = null

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
  // Sortable auto-updates
})
</script>

<style scoped>
.draggable-list { min-height: 100px; }
.item-wrapper { margin-bottom: 2px; }
.between-items { position: relative; }
.insert-between {
  display: flex;
  align-items: center;
  margin: 0 0 0 28px;
  cursor: pointer;
  opacity: 0;
  transition: opacity 0.15s;
}
.between-items:hover .insert-between { opacity: 1; }
.insert-line {
  flex: 1;
  height: 1px;
  background: var(--color-border);
}
.insert-btn {
  width: 22px;
  height: 22px;
  border-radius: 50%;
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  color: var(--color-text-placeholder);
  margin: 0 8px;
  transition: all 0.2s;
  flex-shrink: 0;
  line-height: 1;
}
.insert-between:hover .insert-btn {
  border-color: var(--color-primary);
  color: var(--color-primary);
  background: #fdfaf7;
  box-shadow: 0 1px 4px rgba(196, 123, 90, 0.15);
}

.add-transport-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 8px;
  margin: 2px 0 2px 28px;
  border: 1px dashed var(--color-border);
  border-radius: 8px;
  color: var(--color-text-placeholder);
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
}
.add-transport-btn:hover {
  border-color: var(--color-primary-light);
  color: var(--color-primary);
  background: #fdfaf7;
}
.empty-day {
  text-align: center;
  padding: 48px 20px;
  color: var(--color-text-secondary);
}
.empty-day svg {
  color: #c8bdab;
  margin-bottom: 12px;
}
.empty-day p {
  margin: 0 0 16px;
  font-size: 14px;
}
</style>
