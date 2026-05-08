<template>
  <div class="page-container">
    <div class="page-header">
      <el-button text @click="$router.back()"><el-icon><ArrowLeft /></el-icon>返回</el-button>
      <h2>预算统计</h2>
    </div>

    <div v-loading="loading">
      <template v-if="summary">
        <el-row :gutter="20" class="budget-cards">
          <el-col :xs="12" :sm="6"><el-card shadow="hover"><div class="stat"><div class="stat-num">¥{{ summary.totalBudget || 0 }}</div><div class="stat-label">总预算</div></div></el-card></el-col>
          <el-col :xs="12" :sm="6"><el-card shadow="hover"><div class="stat"><div class="stat-num spent">¥{{ summary.spentTotal }}</div><div class="stat-label">已花费</div></div></el-card></el-col>
          <el-col :xs="12" :sm="6"><el-card shadow="hover"><div class="stat"><div class="stat-num">¥{{ summary.remainingBudget }}</div><div class="stat-label">剩余</div></div></el-card></el-col>
          <el-col :xs="12" :sm="6"><el-card shadow="hover"><div class="stat"><div class="stat-num">¥{{ summary.transportTotal }}</div><div class="stat-label">交通费</div></div></el-card></el-col>
        </el-row>

        <el-row :gutter="20" style="margin-top: 20px;">
          <el-col :span="24">
            <el-card>
              <template #header>分类统计</template>
              <div v-for="cat in categories" :key="cat.category" class="category-row">
                <span class="cat-name">{{ cat.category }}</span>
                <el-progress :percentage="Number(cat.percentage)" :color="cat.color" style="flex:1; margin: 0 12px;" />
                <span class="cat-cost">¥{{ cat.totalCost }} ({{ cat.count }}项)</span>
              </div>
            </el-card>
          </el-col>
        </el-row>

        <el-card style="margin-top: 20px;">
          <template #header>按天预算</template>
          <div v-for="day in byDay" :key="day.dayId" class="day-row">
            <span class="day-label">Day {{ day.dayNumber }} ({{ day.date }})</span>
            <span class="day-costs">行程项 ¥{{ day.itemCost }} + 交通 ¥{{ day.transportCost }}</span>
            <span class="day-total">= ¥{{ day.dayTotal }}</span>
          </div>
        </el-card>
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

const catColors = ['#409EFF', '#67C23A', '#E6A23C', '#F56C6C', '#909399', '#26C6DA']

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
.page-header { display: flex; align-items: center; gap: 8px; margin-bottom: 20px; }
.page-header h2 { margin: 0; }
.stat { text-align: center; padding: 8px 0; }
.stat-num { font-size: 24px; font-weight: 600; color: #303133; }
.stat-num.spent { color: #F56C6C; }
.stat-label { font-size: 12px; color: #909399; margin-top: 4px; }
.category-row { display: flex; align-items: center; margin-bottom: 12px; }
.cat-name { width: 60px; font-size: 13px; }
.cat-cost { width: 140px; text-align: right; font-size: 13px; color: #606266; }
.day-row { display: flex; align-items: center; padding: 8px 0; border-bottom: 1px solid #F2F6FC; font-size: 13px; }
.day-label { width: 180px; font-weight: 500; }
.day-costs { flex: 1; color: #909399; }
.day-total { font-weight: 500; color: #F56C6C; }
</style>
