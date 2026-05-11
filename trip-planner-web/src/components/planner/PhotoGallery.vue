<template>
  <div class="photo-album">
    <!-- Header -->
    <div class="album-header">
      <div class="album-title-row">
        <div class="album-icon">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><rect x="2" y="2" width="20" height="20" rx="2.5"/><circle cx="8.5" cy="8.5" r="1.8"/><polyline points="22 14 16.5 9 4 20"/></svg>
        </div>
        <h3>旅行相册</h3>
      </div>
      <el-button class="upload-trigger" @click="uploadVisible = true">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        添加照片
      </el-button>
    </div>

    <!-- Filters -->
    <div class="album-filters">
      <div class="filter-row">
        <el-select v-model="filterLocation" placeholder="所有地点" clearable size="small" class="filter-select" @change="fetchPhotos">
          <el-option v-for="loc in allLocations" :key="loc" :label="loc" :value="loc" />
        </el-select>
        <div class="type-pills">
          <button :class="['pill', { active: filterType === '' }]" @click="filterType = ''; fetchPhotos()">全部</button>
          <button v-for="t in photoTypes" :key="t.value" :class="['pill', { active: filterType === t.value }]" @click="filterType = t.value; fetchPhotos()">
            {{ t.label }}
          </button>
        </div>
        <button :class="['pill', 'featured-pill', { active: filterFeatured }]" @click="filterFeatured = !filterFeatured; fetchPhotos()">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="currentColor" stroke="none"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
          精选
        </button>
      </div>
      <!-- Batch actions -->
      <div v-if="selectedIds.length > 0" class="batch-actions">
        <span class="batch-count">已选 {{ selectedIds.length }} 张</span>
        <el-button size="small" @click="batchEditVisible = true">编辑标签</el-button>
        <el-button size="small" type="danger" plain @click="batchDelete">删除选中</el-button>
        <el-button size="small" @click="selectedIds = []">取消</el-button>
      </div>
    </div>

    <!-- Photo Grid -->
    <div v-if="photos.length > 0" class="photo-masonry">
      <div v-for="(p, idx) in photos" :key="p.id"
        :class="['masonry-item', { selected: selectedIds.includes(p.id), featured: p.isFeatured }]"
        :style="{ animationDelay: idx * 0.03 + 's' }"
        @click="openLightbox(idx)">
        <div class="masonry-img-wrap">
          <img :src="p.thumbnailUrl" loading="lazy" />
          <div class="masonry-overlay">
            <span v-if="p.location" class="loc-tag">{{ p.location }}</span>
            <span class="type-tag">{{ getPhotoTypeLabel(p.photoType) }}</span>
          </div>
          <div v-if="p.isFeatured" class="star-badge">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" stroke="none"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
          </div>
          <div class="select-check" @click.stop="toggleSelect(p.id)">
            <div :class="['check-circle', { on: selectedIds.includes(p.id) }]">
              <svg v-if="selectedIds.includes(p.id)" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
            </div>
          </div>
        </div>
        <div class="masonry-actions">
          <button class="mini-btn" title="设为精选" @click.stop="toggleFeatured(p)">
            <svg width="14" height="14" viewBox="0 0 24 24" :fill="p.isFeatured ? 'currentColor' : 'none'" stroke="currentColor" stroke-width="1.5"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
          </button>
          <button class="mini-btn" title="编辑标签" @click.stop="openEditDialog(p)">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
          </button>
          <button class="mini-btn danger" title="删除" @click.stop="deleteSingle(p.id)">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Empty -->
    <div v-else class="album-empty">
      <div class="empty-illustration">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2"><rect x="2" y="2" width="20" height="20" rx="2.5"/><circle cx="8.5" cy="8.5" r="1.8"/><polyline points="22 14 16.5 9 4 20"/></svg>
      </div>
      <p class="empty-title">相册还是空的</p>
      <p class="empty-desc">上传旅途中拍下的美好瞬间</p>
    </div>

    <!-- Upload Dialog -->
    <el-dialog v-model="uploadVisible" width="500px" class="upload-dialog" @close="uploadFiles = []">
      <template #header>
        <span class="dialog-title">添加旅行照片</span>
      </template>

      <div class="upload-dropzone" @click="triggerFileInput" @dragover.prevent @drop.prevent="handleDrop">
        <input ref="fileInputRef" type="file" accept="image/*" multiple hidden @change="handleFilesSelected" />
        <template v-if="uploadFiles.length === 0">
          <div class="dropzone-icon">
            <svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.4"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
          </div>
          <p class="dropzone-text">点击或拖拽照片到此处</p>
          <p class="dropzone-hint">支持 JPG、PNG，可一次选择多张</p>
        </template>
        <div v-else class="preview-strip">
          <div v-for="(f, i) in uploadFiles.slice(0, 8)" :key="i" class="strip-item">
            <img :src="previewUrl(f)" />
            <button class="strip-remove" @click.stop="uploadFiles.splice(i,1)">×</button>
          </div>
          <div v-if="uploadFiles.length > 8" class="strip-more">+{{ uploadFiles.length - 8 }}</div>
        </div>
      </div>

      <div class="upload-meta-fields">
        <el-select v-model="uploadLocation" placeholder="拍摄地点" clearable filterable allow-create size="small" class="meta-field">
          <el-option v-for="loc in allLocations" :key="loc" :label="loc" :value="loc" />
        </el-select>
        <el-select v-model="uploadType" placeholder="照片类型" size="small" style="width:120px">
          <el-option v-for="t in photoTypes" :key="t.value" :label="t.label" :value="t.value" />
        </el-select>
      </div>

      <template #footer>
        <el-button class="dialog-cancel" @click="uploadVisible = false">取消</el-button>
        <el-button class="dialog-confirm" type="primary" :loading="uploading" :disabled="uploadFiles.length === 0" @click="doUpload">
          上传 {{ uploadFiles.length > 0 ? '(' + uploadFiles.length + ')' : '' }}
        </el-button>
      </template>
    </el-dialog>

    <!-- Edit single photo -->
    <el-dialog v-model="editVisible" title="编辑标签" width="400px">
      <div class="edit-preview">
        <img v-if="editPhoto" :src="editPhoto.thumbnailUrl" />
      </div>
      <div class="edit-fields">
        <el-select v-model="editLocation" placeholder="拍摄地点" clearable filterable allow-create size="small" style="width:100%">
          <el-option v-for="loc in allLocations" :key="loc" :label="loc" :value="loc" />
        </el-select>
        <el-select v-model="editType" placeholder="照片类型" size="small" style="width:100%">
          <el-option v-for="t in photoTypes" :key="t.value" :label="t.label" :value="t.value" />
        </el-select>
      </div>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" :loading="editSaving" @click="saveEdit">保存</el-button>
      </template>
    </el-dialog>

    <!-- Batch edit -->
    <el-dialog v-model="batchEditVisible" title="批量编辑标签" width="400px">
      <p class="batch-edit-desc">将 {{ selectedIds.length }} 张照片统一设置标签</p>
      <div class="edit-fields">
        <el-select v-model="batchEditLocation" placeholder="拍摄地点（留空不变）" clearable filterable allow-create size="small" style="width:100%">
          <el-option v-for="loc in allLocations" :key="loc" :label="loc" :value="loc" />
        </el-select>
        <el-select v-model="batchEditType" placeholder="照片类型（留空不变）" clearable size="small" style="width:100%">
          <el-option v-for="t in photoTypes" :key="t.value" :label="t.label" :value="t.value" />
        </el-select>
      </div>
      <template #footer>
        <el-button @click="batchEditVisible = false">取消</el-button>
        <el-button type="primary" :loading="editSaving" @click="saveBatchEdit">保存</el-button>
      </template>
    </el-dialog>

    <!-- Lightbox -->
    <Teleport to="body">
      <div v-if="lightboxVisible" class="lightbox-backdrop" @click="lightboxVisible = false">
        <div class="lightbox-container" @click.stop>
          <button class="lightbox-close" @click="lightboxVisible = false">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
          </button>
          <button class="lightbox-nav prev" @click="prevPhoto" :disabled="lightboxIndex <= 0">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><polyline points="15 18 9 12 15 6"/></svg>
          </button>
          <img :src="photos[lightboxIndex]?.url" class="lightbox-img" :key="lightboxIndex" />
          <button class="lightbox-nav next" @click="nextPhoto" :disabled="lightboxIndex >= photos.length - 1">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><polyline points="9 18 15 12 9 6"/></svg>
          </button>
          <div class="lightbox-caption">
            <span v-if="photos[lightboxIndex]?.location" class="cap-loc">{{ photos[lightboxIndex].location }}</span>
            <span class="cap-type">{{ getPhotoTypeLabel(photos[lightboxIndex]?.photoType) }}</span>
            <span class="cap-idx">{{ lightboxIndex + 1 }} / {{ photos.length }}</span>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { photoApi, type PhotoData } from '@/api/photo'
import { ElMessage, ElMessageBox } from 'element-plus'

const props = defineProps<{ tripId: number; itineraryLocations?: string[]; tripDestination?: string }>()

const photos = ref<PhotoData[]>([])
const selectedIds = ref<number[]>([])
const filterLocation = ref('')
const filterType = ref('')
const filterFeatured = ref(false)
const uploading = ref(false)
const uploadVisible = ref(false)
const uploadFiles = ref<File[]>([])
const uploadLocation = ref('')
const uploadType = ref('')
// Pre-fill upload location with trip destination
const tripLoc = computed(() => props.tripDestination || '')
const fileInputRef = ref<HTMLInputElement>()
const lightboxVisible = ref(false)
const lightboxIndex = ref(-1)

// Edit state
const editVisible = ref(false)
const editPhoto = ref<PhotoData | null>(null)
const editLocation = ref('')
const editType = ref('')
const editSaving = ref(false)
const batchEditVisible = ref(false)
const batchEditLocation = ref('')
const batchEditType = ref('')

const photoTypes = [
  { label: '风光', value: 'LANDSCAPE' },
  { label: '人像', value: 'PORTRAIT' },
  { label: '美食', value: 'FOOD' },
  { label: '其他', value: 'OTHER' }
]

const photoLocations = computed(() => {
  const set = new Set<string>()
  photos.value.forEach(p => { if (p.location) set.add(p.location) })
  return [...set]
})

const allLocations = computed(() => {
  const set = new Set<string>()
  if (props.itineraryLocations) props.itineraryLocations.forEach(l => {
    // Exclude the trip destination itself
    if (l !== props.tripDestination) set.add(l)
  })
  photoLocations.value.forEach(l => set.add(l))
  return [...set]
})

function getPhotoTypeLabel(t: string) {
  return photoTypes.find(x => x.value === t)?.label || t
}

async function fetchPhotos() {
  photos.value = await photoApi.list(props.tripId, {
    location: filterLocation.value || undefined,
    photoType: filterType.value || undefined,
    featured: filterFeatured.value || undefined
  })
}

watch(() => props.tripId, fetchPhotos, { immediate: true })

function toggleSelect(id: number) {
  const idx = selectedIds.value.indexOf(id)
  if (idx >= 0) selectedIds.value.splice(idx, 1)
  else selectedIds.value.push(id)
}

function openLightbox(idx: number) {
  lightboxIndex.value = idx
  lightboxVisible.value = true
}
function prevPhoto() { if (lightboxIndex.value > 0) lightboxIndex.value-- }
function nextPhoto() { if (lightboxIndex.value < photos.value.length - 1) lightboxIndex.value++ }

async function toggleFeatured(p: PhotoData) {
  const updated = await photoApi.toggleFeatured(props.tripId, p.id)
  Object.assign(p, updated)
}

async function deleteSingle(id: number) {
  try { await ElMessageBox.confirm('确定删除这张照片？', '', { type: 'warning', confirmButtonText: '删除', cancelButtonText: '取消' }) } catch { return }
  await photoApi.delete(props.tripId, id)
  photos.value = photos.value.filter(p => p.id !== id)
  ElMessage.success('已删除')
}

async function batchDelete() {
  if (selectedIds.value.length === 0) return
  try { await ElMessageBox.confirm(`确定删除 ${selectedIds.value.length} 张照片？`, '', { type: 'warning', confirmButtonText: '删除', cancelButtonText: '取消' }) } catch { return }
  await photoApi.batchDelete(props.tripId, selectedIds.value)
  photos.value = photos.value.filter(p => !selectedIds.value.includes(p.id))
  selectedIds.value = []
  ElMessage.success('已删除')
}

function previewUrl(file: File) { return URL.createObjectURL(file) }
function triggerFileInput() { fileInputRef.value?.click() }
function handleFilesSelected(e: Event) {
  const target = e.target as HTMLInputElement
  if (target.files) uploadFiles.value = Array.from(target.files)
}
function handleDrop(e: DragEvent) {
  if (e.dataTransfer?.files) uploadFiles.value = Array.from(e.dataTransfer.files)
}

function openEditDialog(p: PhotoData) {
  editPhoto.value = p
  editLocation.value = p.location || ''
  editType.value = p.photoType || ''
  editVisible.value = true
}

async function saveEdit() {
  if (!editPhoto.value) return
  editSaving.value = true
  try {
    await photoApi.batchUpdate(props.tripId, [editPhoto.value.id], {
      location: editLocation.value || undefined,
      photoType: editType.value || undefined
    })
    editPhoto.value.location = editLocation.value
    editPhoto.value.photoType = editType.value
    editVisible.value = false
    ElMessage.success('标签已更新')
  } finally { editSaving.value = false }
}

async function saveBatchEdit() {
  if (selectedIds.value.length === 0) return
  editSaving.value = true
  try {
    await photoApi.batchUpdate(props.tripId, selectedIds.value, {
      location: batchEditLocation.value || undefined,
      photoType: batchEditType.value || undefined
    })
    for (const p of photos.value) {
      if (selectedIds.value.includes(p.id)) {
        if (batchEditLocation.value) p.location = batchEditLocation.value
        if (batchEditType.value) p.photoType = batchEditType.value
      }
    }
    batchEditVisible.value = false
    batchEditLocation.value = ''
    batchEditType.value = ''
    selectedIds.value = []
    ElMessage.success('标签已批量更新')
  } finally { editSaving.value = false }
}

async function doUpload() {
  if (uploadFiles.value.length === 0) return
  uploading.value = true
  try {
    await photoApi.uploadBatch(props.tripId, uploadFiles.value,
      uploadLocation.value || tripLoc.value || undefined,
      uploadType.value || undefined)
    ElMessage.success(`已上传 ${uploadFiles.value.length} 张照片`)
    uploadVisible.value = false
    uploadFiles.value = []
    uploadLocation.value = ''
    uploadType.value = ''
    await fetchPhotos()
  } finally { uploading.value = false }
}
</script>

<style scoped>
/* ========== Album Container ========== */
.photo-album {
  background: #fdfaf6;
  border: 1px solid #e6dad0;
  border-radius: 14px;
  padding: 22px 26px;
  margin-top: 20px;
  position: relative;
  overflow: hidden;
}
.photo-album::before {
  content: '';
  position: absolute;
  inset: 0;
  background: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.03'/%3E%3C/svg%3E");
  pointer-events: none;
  z-index: 0;
}

/* ========== Header ========== */
.album-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 18px;
  position: relative;
  z-index: 1;
}
.album-title-row {
  display: flex;
  align-items: center;
  gap: 10px;
}
.album-title-row h3 {
  margin: 0;
  font-family: 'Noto Serif SC', var(--font-display), serif;
  font-size: 17px;
  font-weight: 600;
  color: #3d2e1e;
  letter-spacing: 0.03em;
}
.album-icon {
  width: 34px;
  height: 34px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f4ede4;
  border-radius: 10px;
  color: #c47b5a;
}
.upload-trigger {
  display: flex;
  align-items: center;
  gap: 5px;
  border-radius: 20px;
  padding: 7px 18px;
  background: linear-gradient(135deg, #f4ede4, #efe5d6);
  border: 1px solid #e0d3c0;
  color: #5c4033;
  font-weight: 500;
  font-size: 13px;
  transition: all 0.2s;
}
.upload-trigger:hover {
  background: linear-gradient(135deg, #efe5d6, #e8d9c5);
  border-color: #c47b5a;
  color: #c47b5a;
}

/* ========== Filters ========== */
.album-filters {
  margin-bottom: 20px;
  position: relative;
  z-index: 1;
}
.filter-row {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}
.filter-select {
  width: 140px;
}
.type-pills {
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
}
.pill {
  padding: 5px 14px;
  border-radius: 20px;
  border: 1px solid #e0d3c0;
  background: transparent;
  color: #8b7355;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
  font-family: inherit;
  white-space: nowrap;
}
.pill:hover { border-color: #c47b5a; color: #c47b5a; }
.pill.active { background: #c47b5a; color: #fff; border-color: #c47b5a; }
.featured-pill {
  display: flex; align-items: center; gap: 4px;
  color: #c4953e;
}
.featured-pill.active { background: #c4953e; color: #fff; border-color: #c4953e; }

.batch-actions {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 12px;
  padding: 10px 14px;
  background: #fef5ee;
  border-radius: 10px;
  border: 1px solid #f0dcc8;
}
.batch-count {
  font-size: 13px;
  font-weight: 600;
  color: #c47b5a;
}

/* ========== Masonry Grid ========== */
.photo-masonry {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
  gap: 12px;
  position: relative;
  z-index: 1;
}
.masonry-item {
  position: relative;
  border-radius: 10px;
  overflow: hidden;
  background: #f0ece6;
  box-shadow: 0 2px 8px rgba(92, 64, 51, 0.06);
  transition: transform 0.25s ease, box-shadow 0.25s ease;
  animation: fadeUp 0.4s ease both;
  cursor: pointer;
}
.masonry-item:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(92, 64, 51, 0.12);
}
.masonry-item.selected {
  box-shadow: 0 0 0 3px #c47b5a;
}
.masonry-item.featured {
  box-shadow: 0 0 0 2px #e0c080, 0 2px 8px rgba(92, 64, 51, 0.06);
}
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}

.masonry-img-wrap {
  position: relative;
  aspect-ratio: 1;
  overflow: hidden;
  background: #e8e2d8;
}
.masonry-img-wrap img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  transition: transform 0.4s ease;
}
.masonry-item:hover .masonry-img-wrap img {
  transform: scale(1.04);
}

.masonry-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 28px 8px 6px;
  background: linear-gradient(transparent, rgba(40, 25, 10, 0.55));
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
  pointer-events: none;
}
.loc-tag {
  font-size: 10px; color: #fff; font-weight: 500;
}
.type-tag {
  font-size: 10px; color: rgba(255,255,255,0.85);
  background: rgba(255,255,255,0.18);
  padding: 1px 7px; border-radius: 3px;
}

.star-badge {
  position: absolute;
  top: 8px;
  left: 8px;
  color: #e8b84b;
  filter: drop-shadow(0 1px 2px rgba(0,0,0,0.2));
}

.select-check {
  position: absolute;
  top: 8px;
  right: 8px;
}
.check-circle {
  width: 22px; height: 22px;
  border-radius: 50%;
  border: 2px solid rgba(255,255,255,0.8);
  background: rgba(0,0,0,0.15);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  color: #fff;
}
.check-circle.on {
  background: #c47b5a;
  border-color: #c47b5a;
}

.masonry-actions {
  display: flex;
  justify-content: flex-end;
  gap: 2px;
  padding: 6px 8px;
  opacity: 0;
  transition: opacity 0.2s;
}
.masonry-item:hover .masonry-actions { opacity: 1; }
.mini-btn {
  width: 28px; height: 28px;
  border: none;
  background: transparent;
  border-radius: 6px;
  color: #8b7355;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.15s;
}
.mini-btn:hover { background: #f4ede4; color: #c47b5a; }
.mini-btn.danger:hover { background: #fdf1f0; color: #b8453e; }

/* ========== Edit dialog ========== */
.edit-preview { margin-bottom: 14px; }
.edit-preview img {
  width: 100%; max-height: 200px; object-fit: cover;
  border-radius: 8px;
}
.edit-fields {
  display: flex; flex-direction: column; gap: 10px;
}
.batch-edit-desc {
  font-size: 13px; color: var(--color-text-secondary); margin: 0 0 14px;
}

/* ========== Empty ========== */
.album-empty {
  text-align: center;
  padding: 48px 20px;
  position: relative;
  z-index: 1;
}
.empty-illustration { color: #d4c8b5; margin-bottom: 14px; }
.empty-title {
  font-family: 'Noto Serif SC', var(--font-display), serif;
  font-size: 16px;
  color: #5c4033;
  margin: 0 0 6px;
}
.empty-desc {
  font-size: 13px;
  color: #a89880;
  margin: 0;
}

/* ========== Upload Dialog ========== */
.upload-dropzone {
  border: 2px dashed #e0d3c0;
  border-radius: 12px;
  padding: 40px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s;
  background: #fdfaf6;
}
.upload-dropzone:hover { border-color: #c47b5a; background: #fef9f3; }
.dropzone-icon { color: #d4c8b5; margin-bottom: 10px; }
.dropzone-text {
  font-size: 15px;
  font-weight: 500;
  color: #5c4033;
  margin: 0 0 4px;
}
.dropzone-hint {
  font-size: 12px;
  color: #a89880;
  margin: 0;
}

.preview-strip {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  justify-content: center;
}
.strip-item {
  position: relative;
  width: 72px; height: 72px;
  border-radius: 8px;
  overflow: hidden;
}
.strip-item img {
  width: 100%; height: 100%;
  object-fit: cover;
}
.strip-remove {
  position: absolute; top: 2px; right: 2px;
  width: 18px; height: 18px;
  border-radius: 50%;
  border: none;
  background: rgba(0,0,0,0.5);
  color: #fff;
  font-size: 13px;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
}
.strip-more {
  width: 72px; height: 72px;
  display: flex; align-items: center; justify-content: center;
  background: #f4ede4; border-radius: 8px;
  font-size: 14px; color: #8b7355; font-weight: 600;
}

.upload-meta-fields {
  display: flex;
  gap: 12px;
  margin-top: 16px;
}
.meta-field { flex: 1; }

/* ========== Lightbox ========== */
.lightbox-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(30, 18, 8, 0.94);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fadeIn 0.2s ease;
}
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

.lightbox-container {
  position: relative;
  max-width: 90vw;
  max-height: 90vh;
  display: flex;
  align-items: center;
  justify-content: center;
}
.lightbox-img {
  max-width: 90vw;
  max-height: 85vh;
  object-fit: contain;
  border-radius: 6px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.4);
}
.lightbox-close {
  position: fixed;
  top: 20px; right: 24px;
  background: rgba(255,255,255,0.1);
  border: none;
  border-radius: 50%;
  width: 40px; height: 40px;
  color: #fff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s;
}
.lightbox-close:hover { background: rgba(255,255,255,0.2); }
.lightbox-nav {
  position: fixed;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255,255,255,0.08);
  border: none;
  border-radius: 50%;
  width: 48px; height: 48px;
  color: #fff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s;
}
.lightbox-nav:hover { background: rgba(255,255,255,0.18); }
.lightbox-nav:disabled { opacity: 0.2; cursor: default; }
.lightbox-nav.prev { left: 24px; }
.lightbox-nav.next { right: 24px; }
.lightbox-caption {
  position: fixed;
  bottom: 28px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 18px;
  color: rgba(255,255,255,0.8);
  font-size: 13px;
}
.cap-loc { font-weight: 500; }
.cap-type { opacity: 0.7; }
.cap-idx { opacity: 0.5; }
</style>
