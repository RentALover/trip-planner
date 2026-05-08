<template>
  <div class="page-container form-page">
    <h2>创建新行程</h2>
    <el-form :model="form" :rules="rules" ref="formRef" label-width="100px" class="trip-form">
      <el-form-item label="行程名称" prop="tripName">
        <el-input v-model="form.tripName" placeholder="例如：北京三日游" />
      </el-form-item>
      <el-form-item label="目的地" prop="destination">
        <el-input v-model="form.destination" placeholder="例如：北京" />
      </el-form-item>
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="出发日期" prop="startDate">
            <el-date-picker v-model="form.startDate" type="date" placeholder="选择日期"
              value-format="YYYY-MM-DD" style="width: 100%" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="返程日期" prop="endDate">
            <el-date-picker v-model="form.endDate" type="date" placeholder="选择日期"
              value-format="YYYY-MM-DD" style="width: 100%" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-form-item label="出行人数">
        <el-input-number v-model="form.numPeople" :min="1" :max="99" />
      </el-form-item>
      <el-form-item label="预算金额">
        <el-input-number v-model="form.totalBudget" :min="0" :precision="2"
          :controls="false" placeholder="可选" style="width: 200px" />
      </el-form-item>
      <el-form-item label="备注">
        <el-input v-model="form.notes" type="textarea" :rows="3" placeholder="可选备注" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" :loading="loading" @click="handleCreate">创建行程</el-button>
        <el-button @click="$router.back()">取消</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { tripApi } from '@/api/trip'
import { ElMessage } from 'element-plus'

const router = useRouter()
const formRef = ref()
const loading = ref(false)

const form = reactive({
  tripName: '', destination: '',
  startDate: '', endDate: '',
  numPeople: 1, totalBudget: null as number | null,
  notes: ''
})

const rules = {
  tripName: [{ required: true, message: '请输入行程名称', trigger: 'blur' }],
  destination: [{ required: true, message: '请输入目的地', trigger: 'blur' }],
  startDate: [{ required: true, message: '请选择出发日期', trigger: 'change' }],
  endDate: [{ required: true, message: '请选择返程日期', trigger: 'change' }]
}

async function handleCreate() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    const trip = await tripApi.create({
      tripName: form.tripName,
      destination: form.destination,
      startDate: form.startDate,
      endDate: form.endDate,
      numPeople: form.numPeople,
      totalBudget: form.totalBudget ?? undefined,
      notes: form.notes
    })
    ElMessage.success('行程创建成功')
    router.push(`/trips/${trip.id}/planner`)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.form-page {
  max-width: 680px;
}
.trip-form {
  margin-top: 20px;
}
</style>
