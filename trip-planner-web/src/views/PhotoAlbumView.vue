<template>
  <div class="album-page">
    <div class="album-hero">
      <h2 class="hero-title">旅行相册</h2>
      <p class="hero-sub">每一帧都是走过的路</p>
    </div>

    <div v-if="loading" class="album-loading" v-loading="true" />

    <template v-else-if="tripGroups.length > 0">
      <section v-for="group in tripGroups" :key="group.tripId" class="trip-section">
        <router-link :to="`/trips/${group.tripId}`" class="trip-section-header">
          <div class="trip-info">
            <h3 class="trip-name">{{ group.tripName }}</h3>
            <span class="trip-meta">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="10" r="3"/><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/></svg>
              {{ group.tripDestination }}
              <span class="sep">·</span>
              {{ formatDate(group.tripStartDate) }}
              <span class="sep">·</span>
              {{ group.photos.length }} 张照片
            </span>
          </div>
          <span class="trip-link">查看行程 →</span>
        </router-link>
        <div class="trip-photo-grid">
          <div v-for="p in group.photos" :key="p.id" class="grid-photo" @click="openLightbox(p)">
            <img :src="p.thumbnailUrl" loading="lazy" />
            <div class="grid-overlay">
              <span v-if="p.location" class="grid-loc">{{ p.location }}</span>
              <span v-if="p.isFeatured" class="grid-star">★</span>
            </div>
          </div>
        </div>
      </section>
    </template>

    <div v-else class="album-empty">
      <div class="empty-icon">
        <svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2"><rect x="2" y="2" width="20" height="20" rx="2.5"/><circle cx="8.5" cy="8.5" r="1.8"/><polyline points="22 14 16.5 9 4 20"/></svg>
      </div>
      <p class="empty-title">相册还是空的</p>
      <p class="empty-desc">行程中的照片会汇集到这里</p>
      <router-link to="/" class="empty-link">去看看行程</router-link>
    </div>

    <!-- Lightbox -->
    <Teleport to="body">
      <div v-if="lightboxVisible" class="lightbox-backdrop" @click="lightboxVisible = false">
        <div class="lightbox-container" @click.stop>
          <button class="lightbox-close" @click="lightboxVisible = false">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
          </button>
          <img :src="lightboxPhoto?.url" class="lightbox-img" />
          <div class="lightbox-caption">
            <span v-if="lightboxPhoto?.tripName">{{ lightboxPhoto?.tripName }}</span>
            <span v-if="lightboxPhoto?.location">{{ lightboxPhoto?.location }}</span>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { photoApi, type PhotoAlbumData } from '@/api/photo'

interface TripGroup {
  tripId: number
  tripName: string
  tripDestination: string
  tripStartDate: string
  photos: PhotoAlbumData[]
}

const photos = ref<PhotoAlbumData[]>([])
const loading = ref(false)
const lightboxVisible = ref(false)
const lightboxPhoto = ref<PhotoAlbumData | null>(null)

const tripGroups = computed(() => {
  const map = new Map<number, TripGroup>()
  for (const p of photos.value) {
    if (!map.has(p.tripId)) {
      map.set(p.tripId, {
        tripId: p.tripId,
        tripName: p.tripName,
        tripDestination: p.tripDestination,
        tripStartDate: p.tripStartDate,
        photos: []
      })
    }
    map.get(p.tripId)!.photos.push(p)
  }
  return [...map.values()]
})

onMounted(async () => {
  loading.value = true
  try { photos.value = await photoApi.listAll() }
  finally { loading.value = false }
})

function openLightbox(p: PhotoAlbumData) {
  lightboxPhoto.value = p
  lightboxVisible.value = true
}

function formatDate(s: string) {
  return s || ''
}
</script>

<style scoped>
.album-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 28px 24px;
  overflow-x: hidden;
}

/* Hero */
.album-hero {
  text-align: center;
  padding: 36px 0 32px;
}
.hero-title {
  margin: 0 0 6px;
  font-family: 'Noto Serif SC', var(--font-display), serif;
  font-size: 26px;
  font-weight: 700;
  color: #3d2e1e;
  letter-spacing: 0.04em;
}
.hero-sub {
  margin: 0;
  font-size: 14px;
  color: #a89880;
  letter-spacing: 0.05em;
}

/* Loading */
.album-loading { min-height: 300px; }

/* Trip sections */
.trip-section { margin-bottom: 32px; }
.trip-section-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 14px;
  padding-bottom: 10px;
  border-bottom: 1px solid #e8dfd0;
  text-decoration: none;
  transition: border-color 0.2s;
}
.trip-section-header:hover { border-color: #c47b5a; }
.trip-section-header:hover .trip-link { opacity: 1; }
.trip-link {
  font-size: 12px; color: #c47b5a; opacity: 0;
  transition: opacity 0.2s; white-space: nowrap;
}
.trip-name {
  margin: 0 0 4px;
  font-family: 'Noto Serif SC', var(--font-display), serif;
  font-size: 18px;
  font-weight: 600;
  color: #3d2e1e;
}
.trip-meta {
  font-size: 13px;
  color: #a89880;
  display: flex;
  align-items: center;
  gap: 4px;
}
.sep { margin: 0 4px; opacity: 0.5; }

/* Photo grid */
.trip-photo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 10px;
}
.grid-photo {
  position: relative;
  border-radius: 10px;
  overflow: hidden;
  aspect-ratio: 1;
  cursor: pointer;
  background: #f0ece6;
  box-shadow: 0 2px 8px rgba(92, 64, 51, 0.05);
  transition: transform 0.25s ease, box-shadow 0.25s ease;
}
.grid-photo:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 20px rgba(92, 64, 51, 0.12);
}
.grid-photo img {
  width: 100%; height: 100%;
  object-fit: cover; display: block;
  transition: transform 0.4s ease;
}
.grid-photo:hover img { transform: scale(1.04); }
.grid-overlay {
  position: absolute; bottom: 0; left: 0; right: 0;
  padding: 24px 8px 6px;
  background: linear-gradient(transparent, rgba(40, 25, 10, 0.5));
  display: flex; gap: 6px; pointer-events: none;
}
.grid-loc {
  font-size: 11px; color: #fff; font-weight: 500;
}
.grid-star { color: #f5c842; font-size: 14px; }

/* Empty */
.album-empty {
  text-align: center;
  padding: 80px 20px;
}
.empty-icon { color: #d4c8b5; margin-bottom: 16px; }
.empty-title {
  font-family: 'Noto Serif SC', var(--font-display), serif;
  font-size: 18px; color: #5c4033; margin: 0 0 6px;
}
.empty-desc { font-size: 14px; color: #a89880; margin: 0 0 20px; }
.empty-link {
  color: #c47b5a; text-decoration: none; font-weight: 500;
}
.empty-link:hover { text-decoration: underline; }

/* Lightbox */
.lightbox-backdrop {
  position: fixed; inset: 0;
  background: rgba(30, 18, 8, 0.94);
  z-index: 9999;
  display: flex; align-items: center; justify-content: center;
}
.lightbox-container { position: relative; }
.lightbox-img {
  max-width: 90vw; max-height: 85vh;
  object-fit: contain; border-radius: 6px;
  box-shadow: 0 20px 60px rgba(0,0,0,0.4);
}
.lightbox-close {
  position: fixed; top: 20px; right: 24px;
  background: rgba(255,255,255,0.1); border: none; border-radius: 50%;
  width: 40px; height: 40px; color: #fff; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
}
.lightbox-close:hover { background: rgba(255,255,255,0.2); }
.lightbox-caption {
  position: fixed; bottom: 28px; left: 50%; transform: translateX(-50%);
  display: flex; gap: 18px; color: rgba(255,255,255,0.8); font-size: 13px;
}
</style>
