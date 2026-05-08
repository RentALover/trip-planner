<template>
  <div class="page-container form-page">
    <div class="page-header">
      <button class="back-btn" @click="$router.back()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
        返回
      </button>
      <h2>旅行备忘录</h2>
      <el-button class="preset-btn" @click="handleLoadPreset" :loading="loadingPreset">加载预设清单</el-button>
    </div>

    <div class="checklist-toolbar">
      <div class="add-input-wrap">
        <svg class="add-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        <input v-model="newItemTitle" placeholder="添加新事项..."
          class="add-input" @keyup.enter="handleAddItem" />
      </div>
      <el-button type="primary" @click="handleAddItem" :disabled="!newItemTitle.trim()">添加</el-button>
      <el-button @click="handleToggleAll(true)">全选</el-button>
      <el-button @click="handleToggleAll(false)">取消全选</el-button>
    </div>

    <div v-loading="loading" class="checklist-items">
      <template v-for="cat in groupedItems" :key="cat.category">
        <div class="checklist-category">
          <h4>{{ cat.label }} <span class="cat-count">{{ cat.items.length }}</span></h4>
          <div v-for="item in cat.items" :key="item.id" class="checklist-item"
            :class="{ checked: item.isChecked }">
            <label class="check-item-label">
              <span class="custom-checkbox" :class="{ checked: item.isChecked === 1 }">
                <svg v-if="item.isChecked === 1" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
              </span>
              <input type="checkbox" :checked="item.isChecked === 1"
                @change="handleToggle(item.id)" style="display:none" />
              <span class="item-title">{{ item.title }}</span>
            </label>
            <button class="delete-btn" @click="handleDelete(item.id)">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
            </button>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { checklistApi, type ChecklistData } from '@/api/checklist'
import { ElMessage } from 'element-plus'

const route = useRoute()
const tripId = Number(route.params.id)
const items = ref<ChecklistData[]>([])
const loading = ref(false)
const loadingPreset = ref(false)
const newItemTitle = ref('')

const categoryLabels: Record<string, string> = {
  DOCUMENT: '证件', LUGGAGE: '行李', ELECTRONICS: '电子设备',
  CLOTHING: '衣物', TOILETRY: '洗漱用品', MEDICAL: '医疗', OTHER: '其他'
}

const groupedItems = computed(() => {
  const map: Record<string, ChecklistData[]> = {}
  for (const item of items.value) {
    if (!map[item.category]) map[item.category] = []
    map[item.category].push(item)
  }
  return Object.entries(map).map(([category, items]) => ({
    category, label: categoryLabels[category] || category, items
  }))
})

async function fetchItems() {
  loading.value = true
  try { items.value = await checklistApi.list(tripId) }
  finally { loading.value = false }
}

async function handleAddItem() {
  if (!newItemTitle.value.trim()) return
  await checklistApi.create(tripId, { title: newItemTitle.value.trim() })
  newItemTitle.value = ''
  ElMessage.success('已添加')
  fetchItems()
}

async function handleToggle(id: number) {
  await checklistApi.toggle(tripId, id)
  fetchItems()
}

async function handleToggleAll(checked: boolean) {
  await checklistApi.toggleAll(tripId, checked)
  fetchItems()
}

async function handleDelete(id: number) {
  await checklistApi.delete(tripId, id)
  ElMessage.success('已删除')
  fetchItems()
}

async function handleLoadPreset() {
  loadingPreset.value = true
  try {
    items.value = await checklistApi.loadPreset(tripId)
    ElMessage.success('已加载预设清单')
  } finally { loadingPreset.value = false }
}

onMounted(fetchItems)
</script>

<style scoped>
.form-page { max-width: 700px; }
.page-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}
.page-header h2 {
  margin: 0;
  flex: 1;
  font-family: var(--font-display);
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 0.03em;
}
.back-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 6px 14px;
  font-size: 13px;
  color: var(--color-text-secondary);
  cursor: pointer;
  transition: all 0.2s;
  font-family: var(--font-body);
}
.back-btn:hover { border-color: var(--color-primary-light); color: var(--color-primary); }
.preset-btn { border-radius: 8px; }

.checklist-toolbar {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  align-items: center;
  flex-wrap: wrap;
}
.add-input-wrap {
  position: relative;
  flex: 1;
  min-width: 200px;
}
.add-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--color-text-placeholder);
  pointer-events: none;
}
.add-input {
  width: 100%;
  height: 38px;
  padding: 0 12px 0 36px;
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  font-size: 14px;
  color: var(--color-text-primary);
  outline: none;
  transition: border-color 0.2s;
  font-family: var(--font-body);
}
.add-input:focus { border-color: var(--color-primary); }
.add-input::placeholder { color: var(--color-text-placeholder); }

.checklist-category { margin-bottom: 24px; }
.checklist-category h4 {
  margin: 0 0 10px;
  font-size: 14px;
  font-weight: 600;
  color: var(--color-text-primary);
  padding-bottom: 8px;
  border-bottom: 1px solid var(--color-border-light);
  display: flex;
  align-items: center;
  gap: 6px;
}
.cat-count {
  font-size: 12px;
  color: var(--color-text-placeholder);
  font-weight: 400;
}

.checklist-item {
  display: flex;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid var(--color-border-light);
}
.checklist-item.checked .item-title { text-decoration: line-through; color: #c8bdab; }
.check-item-label {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
  cursor: pointer;
}
.custom-checkbox {
  width: 20px;
  height: 20px;
  border: 2px solid var(--color-border);
  border-radius: 5px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  transition: all 0.2s;
  flex-shrink: 0;
}
.custom-checkbox.checked {
  background: var(--color-accent);
  border-color: var(--color-accent);
}
.item-title { font-size: 14px; color: var(--color-text-primary); }
.delete-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 6px;
  border-radius: 6px;
  color: var(--color-text-placeholder);
  transition: all 0.15s;
  display: flex;
}
.delete-btn:hover { color: var(--color-danger); background: #fdf1f0; }
</style>
