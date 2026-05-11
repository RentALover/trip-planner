<template>
  <div class="export-page">
    <div class="export-header">
      <button class="back-btn" @click="$router.back()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
        返回
      </button>
      <h2>导出行程</h2>
      <el-button type="primary" class="download-btn" @click="handleDownloadMd">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
        下载 Markdown
      </el-button>
    </div>

    <div class="export-card">
      <div class="card-intro">
        <div class="intro-icon">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
        </div>
        <h3>Markdown 格式行程单</h3>
        <p>包含完整日程安排、交通衔接、费用信息。可在 Typora / VS Code / 备忘录中打开，方便分享打印。</p>
      </div>

      <div v-loading="loading" class="preview-section">
        <div v-if="previewText" class="markdown-preview" v-html="renderedPreview" />
        <div v-else-if="!loading" class="preview-empty">点击右上角按钮加载预览并下载</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { exportApi } from '@/api/export'

const route = useRoute()
const tripId = Number(route.params.id)
const previewText = ref('')
const loading = ref(false)

const renderedPreview = computed(() => {
  if (!previewText.value) return ''
  return previewText.value
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/^### (.*)$/gm, '<h4>$1</h4>')
    .replace(/^## (.*)$/gm, '<h3>$1</h3>')
    .replace(/^# (.*)$/gm, '<h2>$1</h2>')
    .replace(/^---$/gm, '<hr>')
    .replace(/^> (.*)$/gm, '<blockquote>$1</blockquote>')
    .replace(/^\- (.*)$/gm, '<li>$1</li>')
    .replace(/^\*\*(.*)\*\*$/gm, '<strong>$1</strong>')
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    .replace(/\n\n/g, '<br><br>')
})

async function loadPreview() {
  loading.value = true
  try {
    const url = exportApi.getTextUrl(tripId)
    const response = await fetch(url, {
      headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
    })
    previewText.value = await response.text()
  } finally { loading.value = false }
}

async function handleDownloadMd() {
  await loadPreview()
  if (!previewText.value) return
  const blob = new Blob([previewText.value], { type: 'text/markdown;charset=UTF-8' })
  const a = document.createElement('a')
  a.href = URL.createObjectURL(blob)
  a.download = `trip-${tripId}.md`
  a.click()
}
</script>

<style scoped>
.export-page {
  max-width: 780px;
  margin: 0 auto;
  padding: 24px 20px;
}
.export-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
}
.export-header h2 {
  margin: 0;
  font-family: 'Noto Serif SC', var(--font-display), serif;
  font-size: 22px;
  font-weight: 700;
  flex: 1;
}
.back-btn {
  display: flex; align-items: center; gap: 6px;
  background: none; border: 1px solid var(--color-border);
  border-radius: 8px; padding: 6px 14px; font-size: 13px;
  color: var(--color-text-secondary); cursor: pointer;
  transition: all 0.2s; font-family: var(--font-body);
}
.back-btn:hover { border-color: var(--color-primary-light); color: var(--color-primary); }
.download-btn { border-radius: 8px; display: flex; align-items: center; gap: 6px; }

.export-card {
  background: #fdfaf6;
  border: 1px solid #e6dad0;
  border-radius: 14px;
  padding: 28px;
}
.card-intro { text-align: center; margin-bottom: 24px; }
.intro-icon {
  width: 52px; height: 52px; border-radius: 14px;
  background: #f4ede4; color: #c47b5a;
  display: flex; align-items: center; justify-content: center;
  margin: 0 auto 14px;
}
.card-intro h3 {
  margin: 0 0 6px;
  font-family: 'Noto Serif SC', var(--font-display), serif;
  font-size: 18px; font-weight: 600;
}
.card-intro p {
  margin: 0; font-size: 13px; color: #a89880; line-height: 1.6;
}

.preview-section { min-height: 200px; }
.preview-empty {
  text-align: center; padding: 48px; color: #a89880; font-size: 14px;
}

.markdown-preview {
  background: #fff;
  border: 1px solid #e8dfd0;
  border-radius: 10px;
  padding: 24px 28px;
  font-size: 14px;
  line-height: 1.8;
  color: #3d2e1e;
  font-family: var(--font-body);
  max-height: 560px;
  overflow-y: auto;
}
.markdown-preview :deep(h2) {
  margin: 0 0 8px;
  font-family: 'Noto Serif SC', var(--font-display), serif;
  font-size: 22px; font-weight: 700;
}
.markdown-preview :deep(h3) {
  margin: 24px 0 8px;
  font-family: 'Noto Serif SC', var(--font-display), serif;
  font-size: 17px; font-weight: 600;
  color: #5c4033;
}
.markdown-preview :deep(h4) {
  margin: 14px 0 4px;
  font-size: 15px; font-weight: 600;
}
.markdown-preview :deep(hr) { border: none; border-top: 1px solid #e8dfd0; margin: 16px 0; }
.markdown-preview :deep(blockquote) {
  margin: 8px 0 8px 12px; padding: 6px 14px;
  border-left: 3px solid #c47b5a; background: #fdf8f4;
  border-radius: 0 6px 6px 0; color: #6b5540; font-size: 13px;
}
.markdown-preview :deep(li) { list-style: disc; margin-left: 16px; color: #6b5540; }
.markdown-preview :deep(code) {
  background: #f4ede4; padding: 1px 6px; border-radius: 4px;
  font-size: 13px; color: #c47b5a;
}
.markdown-preview :deep(strong) { font-weight: 600; }
</style>
