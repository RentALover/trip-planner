<template>
  <div class="page-container">
    <div class="page-header">
      <button class="back-btn" @click="$router.back()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></svg>
        返回
      </button>
      <h2>预算统计</h2>
    </div>

    <div v-loading="loading">
      <template v-if="summary">
        <div class="stat-grid">
          <div class="stat-card">
            <div class="stat-num">¥{{ summary.totalBudget || 0 }}</div>
            <div class="stat-label">总预算</div>
          </div>
          <div class="stat-card spend">
            <div class="stat-num">¥{{ summary.spentTotal }}</div>
            <div class="stat-label">已花费</div>
          </div>
          <div class="stat-card remain">
            <div class="stat-num">¥{{ summary.remainingBudget }}</div>
            <div class="stat-label">剩余</div>
          </div>
          <div class="stat-card transport">
            <div class="stat-num">¥{{ summary.transportTotal }}</div>
            <div class="stat-label">交通费</div>
          </div>
        </div>

        <div class="content-card" style="margin-top: 20px;">
          <h4>分类统计</h4>
          <div v-for="cat in categories" :key="cat.category" class="category-row">
            <span class="cat-name">{{ cat.category }}</span>
            <div class="cat-progress">
              <div class="cat-bar" :style="{ width: cat.percentage + '%', background: cat.color }"></div>
            </div>
            <span class="cat-pct">{{ cat.percentage }}%</span>
            <span class="cat-cost">¥{{ cat.totalCost }}</span>
          </div>
        </div>

        <div class="content-card" style="margin-top: 16px;">
          <h4>按天预算</h4>
          <div v-for="day in byDay" :key="day.dayId" class="day-row">
            <span class="day-label">Day {{ day.dayNumber }} · {{ day.date }}</span>
            <span class="day-breakdown">行程项 ¥{{ day.itemCost }} + 交通 ¥{{ day.transportCost }}</span>
            <span class="day-total">¥{{ day.dayTotal }}</span>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { budgetApi, type BudgetSummary, type BudgetByDay, type BudgetByCategory } from '@/api/budget'

const route = useRoute()
const tripId = Number(route.params.id)
const loading = ref(false)
const summary = ref<BudgetSummary | null>(null)
const byDay = ref<BudgetByDay[]>([])
const categories = ref<(BudgetByCategory & { color: string })[]>([])

const catColors = ['#c47b5a', '#3d6b6b', '#7b8c4e', '#c4963e', '#6b7d8b', '#8b7e6a']

onMounted(async () => {
  loading.value = true
  try {
    summary.value = await budgetApi.getSummary(tripId)
    byDay.value = await budgetApi.getByDay(tripId)
    const cats = await budgetApi.getByCategory(tripId)
    categories.value = cats.map((c, i) => ({ ...c, color: catColors[i % catColors.length] }))
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
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

.stat-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
}
.stat-card {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 20px;
  text-align: center;
}
.stat-num {
  font-family: var(--font-display);
  font-size: 26px;
  font-weight: 700;
  color: var(--color-text-primary);
}
.stat-card.spend .stat-num { color: var(--color-primary); }
.stat-card.remain .stat-num { color: var(--color-accent); }
.stat-card.transport .stat-num { color: #6b7d8b; }
.stat-label {
  font-size: 12px;
  color: var(--color-text-secondary);
  margin-top: 4px;
}

.content-card {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 20px;
}
.content-card h4 {
  margin: 0 0 16px;
  font-family: var(--font-display);
  font-size: 15px;
  font-weight: 600;
}

.category-row {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  gap: 12px;
}
.cat-name { width: 70px; font-size: 13px; font-weight: 500; flex-shrink: 0; }
.cat-progress {
  flex: 1;
  height: 6px;
  background: var(--color-bg-muted);
  border-radius: 3px;
  overflow: hidden;
}
.cat-bar { height: 100%; border-radius: 3px; transition: width 0.5s ease; }
.cat-pct { width: 36px; font-size: 12px; text-align: right; color: var(--color-text-secondary); }
.cat-cost { width: 90px; text-align: right; font-size: 13px; font-weight: 500; color: var(--color-text-primary); }

.day-row {
  display: flex;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid var(--color-border-light);
  font-size: 13px;
}
.day-row:last-child { border-bottom: none; }
.day-label { width: 180px; font-weight: 500; }
.day-breakdown { flex: 1; color: var(--color-text-secondary); }
.day-total { font-weight: 600; color: var(--color-primary); }

@media (max-width: 768px) {
  .stat-grid { grid-template-columns: repeat(2, 1fr); }
  .day-row { flex-direction: column; align-items: flex-start; gap: 4px; }
  .day-label { width: auto; }
}
</style>
