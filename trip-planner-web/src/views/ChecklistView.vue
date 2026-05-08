<template>
  <div class="page-container form-page">
    <div class="page-header">
      <el-button text @click="$router.back()"><el-icon><ArrowLeft /></el-icon>返回</el-button>
      <h2>旅行备忘录</h2>
      <el-button @click="handleLoadPreset" :loading="loadingPreset">加载预设清单</el-button>
    </div>

    <div class="checklist-toolbar">
      <el-input v-model="newItemTitle" placeholder="添加新事项" style="width: 300px"
        @keyup.enter="handleAddItem" />
      <el-button type="primary" @click="handleAddItem" :disabled="!newItemTitle.trim()">添加</el-button>
      <el-button @click="handleToggleAll(true)">全选</el-button>
      <el-button @click="handleToggleAll(false)">取消全选</el-button>
    </div>

    <div v-loading="loading" class="checklist-items">
      <template v-for="cat in groupedItems" :key="cat.category">
        <div class="checklist-category">
          <h4>{{ cat.label }} ({{ cat.items.length }})</h4>
          <div v-for="item in cat.items" :key="item.id" class="checklist-item"
            :class="{ checked: item.isChecked }">
            <el-checkbox :model-value="item.isChecked === 1"
              @change="handleToggle(item.id)" />
            <span class="item-title">{{ item.title }}</span>
            <el-button text type="danger" size="small" @click="handleDelete(item.id)">
              <el-icon><Delete /></el-icon>
            </el-button>
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
  try {
    items.value = await checklistApi.list(tripId)
  } finally {
    loading.value = false
  }
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
  } finally {
    loadingPreset.value = false
  }
}

onMounted(fetchItems)
</script>

<style scoped>
.form-page { max-width: 700px; }
.page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }
.page-header h2 { margin: 0; flex: 1; }
.checklist-toolbar { display: flex; gap: 8px; margin-bottom: 20px; align-items: center; flex-wrap: wrap; }
.checklist-category { margin-bottom: 20px; }
.checklist-category h4 { margin: 0 0 8px 0; font-size: 14px; color: #606266; padding-bottom: 4px; border-bottom: 1px solid #EBEEF5; }
.checklist-item { display: flex; align-items: center; padding: 8px 0; border-bottom: 1px solid #F2F6FC; }
.checklist-item.checked .item-title { text-decoration: line-through; color: #C0C4CC; }
.item-title { flex: 1; margin: 0 12px; font-size: 14px; }
</style>
