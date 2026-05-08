<template>
  <div class="page-container form-page">
    <div class="page-header">
      <el-button text @click="$router.back()"><el-icon><ArrowLeft /></el-icon>返回</el-button>
      <h2>导出行程</h2>
    </div>

    <el-card>
      <template #header>文本导出</template>
      <p class="desc">导出为纯文本文件，包含完整的行程名称、日期、每日行程项和交通安排。</p>
      <el-button type="primary" @click="handleExportText">
        <el-icon><Download /></el-icon>下载文本文件
      </el-button>
    </el-card>

    <el-card style="margin-top: 16px;">
      <template #header>预览</template>
      <div v-loading="loadingText">
        <pre class="preview-text">{{ previewText || '点击上方按钮加载预览' }}</pre>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import { exportApi } from '@/api/export'
import api from '@/api/index'

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

    // Download
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
.page-header { display: flex; align-items: center; gap: 8px; margin-bottom: 20px; }
.page-header h2 { margin: 0; }
.desc { color: #909399; font-size: 14px; }
.preview-text {
  background: #F5F7FA;
  padding: 16px;
  border-radius: 4px;
  font-size: 13px;
  line-height: 1.6;
  white-space: pre-wrap;
  max-height: 500px;
  overflow-y: auto;
}
</style>
