<template>
  <div class="journal-section">
    <div class="journal-header">
      <h3 class="section-title">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
        旅行日记
      </h3>
      <el-button v-if="journal" size="small" class="edit-btn" @click="openEditor">编辑</el-button>
    </div>

    <!-- Read mode -->
    <div v-if="journal && !showEditor" class="journal-content">
      <div class="journal-meta">
        <span v-if="journal.mood" class="meta-tag">心情：{{ journal.mood }}</span>
        <span v-if="journal.weather" class="meta-tag">天气：{{ journal.weather }}</span>
        <span class="meta-date">{{ formatDate(journal.updateTime || journal.createTime) }}</span>
      </div>
      <p class="journal-text">{{ journal.content }}</p>
    </div>

    <!-- Empty state -->
    <div v-if="!journal && !showEditor" class="journal-empty">
      <p>这一天还没有记录</p>
      <el-button type="primary" size="small" @click="openEditor">写日记</el-button>
    </div>

    <!-- Editor -->
    <div v-if="showEditor" class="journal-editor">
      <div class="editor-tags">
        <el-select v-model="form.mood" placeholder="心情" clearable size="small" style="width: 100px">
          <el-option v-for="m in moods" :key="m" :label="m" :value="m" />
        </el-select>
        <el-select v-model="form.weather" placeholder="天气" clearable size="small" style="width: 100px">
          <el-option v-for="w in weathers" :key="w" :label="w" :value="w" />
        </el-select>
      </div>
      <el-input v-model="form.content" type="textarea" :rows="5" placeholder="记录今天的旅行见闻..." />
      <div class="editor-actions">
        <el-button size="small" @click="handleCancelEdit">取消</el-button>
        <el-button v-if="journal" size="small" type="danger" :loading="deleting" @click="handleDelete">删除</el-button>
        <el-button size="small" type="primary" :loading="saving" @click="handleSave">保存</el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue'
import { journalApi, type JournalData } from '@/api/journal'
import { ElMessage, ElMessageBox } from 'element-plus'

const props = defineProps<{ dayId: number; readonly?: boolean }>()

const journal = ref<JournalData | null>(null)
const showEditor = ref(false)
const saving = ref(false)
const deleting = ref(false)

const moods = ['开心', '兴奋', '满足', '平静', '疲惫', '遗憾']
const weathers = ['晴', '多云', '阴', '雨', '雪', '风']

const form = reactive({ content: '', mood: '', weather: '' })

watch(() => props.dayId, async () => {
  journal.value = null
  showEditor.value = false
  form.content = ''
  form.mood = ''
  form.weather = ''
  journal.value = await journalApi.get(props.dayId)
}, { immediate: true })

function openEditor() {
  if (journal.value) {
    form.content = journal.value.content
    form.mood = journal.value.mood || ''
    form.weather = journal.value.weather || ''
  }
  showEditor.value = true
}

function handleCancelEdit() {
  showEditor.value = false
  if (!journal.value) {
    form.content = ''
    form.mood = ''
    form.weather = ''
  } else {
    form.content = journal.value.content
    form.mood = journal.value.mood || ''
    form.weather = journal.value.weather || ''
  }
}

async function handleSave() {
  if (!form.content.trim()) return
  saving.value = true
  try {
    const result = await journalApi.save(props.dayId, {
      content: form.content,
      mood: form.mood || undefined,
      weather: form.weather || undefined
    })
    journal.value = result
    showEditor.value = false
  } finally { saving.value = false }
}

async function handleDelete() {
  try {
    await ElMessageBox.confirm('确定删除这篇日记？', '确认删除', { type: 'warning' })
  } catch { return }
  deleting.value = true
  try {
    await journalApi.delete(props.dayId)
    journal.value = null
    showEditor.value = false
    form.content = ''
    ElMessage.success('已删除')
  } finally { deleting.value = false }
}

function formatDate(s: string) {
  return s ? s.substring(0, 16).replace('T', ' ') : ''
}
</script>

<style scoped>
.journal-section {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 20px 24px;
  margin-top: 20px;
}
.journal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
}
.section-title {
  margin: 0;
  font-family: var(--font-display);
  font-size: 16px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 6px;
}
.journal-meta {
  display: flex;
  gap: 10px;
  margin-bottom: 10px;
  flex-wrap: wrap;
}
.meta-tag {
  font-size: 12px;
  color: var(--color-text-secondary);
  background: var(--color-bg-muted);
  padding: 2px 10px;
  border-radius: 4px;
}
.meta-date {
  font-size: 12px;
  color: var(--color-text-placeholder);
  margin-left: auto;
}
.journal-text {
  margin: 0;
  font-size: 14px;
  line-height: 1.8;
  color: var(--color-text-regular);
  white-space: pre-wrap;
}
.journal-empty {
  text-align: center;
  padding: 20px;
  color: var(--color-text-secondary);
}
.journal-empty p { margin: 0 0 10px; font-size: 13px; }

.journal-editor {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.editor-tags {
  display: flex;
  gap: 8px;
}
.editor-actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
}
.edit-btn { border-radius: 8px; }
</style>
