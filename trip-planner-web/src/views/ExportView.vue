<template>
  <div class="page-container form-page">
    <div class="page-header">
      <button class="back-btn" @click="$router.back()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
        返回
      </button>
      <h2>导出行程</h2>
    </div>

    <div class="content-card">
      <div class="card-icon">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
      </div>
      <h4>文本导出</h4>
      <p class="desc">导出为纯文本文件，包含完整的行程名称、日期、每日行程项和交通安排。</p>
      <el-button type="primary" class="export-btn" @click="handleExportText">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        下载文本文件
      </el-button>
    </div>

    <div class="content-card preview-card">
      <h4>预览</h4>
      <div v-loading="loadingText">
        <pre class="preview-text">{{ previewText || '点击上方按钮加载预览' }}</pre>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import { exportApi } from '@/api/export'

const route = useRoute()
const tripId = Number(route.params.id)
const previewText = ref('')
const loadingText = ref(false)

async function handleExportText() {
  loadingText.value = true
  try {
    const url = exportApi.getTextUrl(tripId)
    const response = await fetch(url, {
      headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
    })
    const text = await response.text()
    previewText.value = text

    const blob = new Blob([text], { type: 'text/plain;charset=UTF-8' })
    const downloadUrl = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = downloadUrl
    a.download = `trip-${tripId}.txt`
    a.click()
    URL.revokeObjectURL(downloadUrl)
  } catch (err) {
    console.error(err)
  } finally {
    loadingText.value = false
  }
}
</script>

<style scoped>
.form-page { max-width: 700px; }
.page-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
}
.page-header h2 {
  margin: 0;
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

.content-card {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 24px;
  margin-bottom: 16px;
}
.card-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  background: #f9f2ee;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-primary);
  margin-bottom: 14px;
}
.content-card h4 {
  margin: 0 0 8px;
  font-family: var(--font-display);
  font-size: 16px;
  font-weight: 600;
}
.desc {
  color: var(--color-text-secondary);
  font-size: 14px;
  margin: 0 0 16px;
  line-height: 1.5;
}
.export-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  border-radius: 8px;
}
.preview-card {
  margin-top: 16px;
}
.preview-text {
  background: var(--color-bg-muted);
  padding: 16px;
  border-radius: 8px;
  font-size: 13px;
  line-height: 1.7;
  white-space: pre-wrap;
  max-height: 500px;
  overflow-y: auto;
  color: var(--color-text-primary);
  font-family: var(--font-body);
  margin: 0;
  border: 1px solid var(--color-border-light);
}
</style>
