<template>
  <div class="page-container form-page" v-loading="loading">
    <h2>编辑行程</h2>
    <el-form v-if="form.tripName !== undefined" :model="form" ref="formRef" label-width="100px" class="trip-form">
      <el-form-item label="行程名称" prop="tripName"
        :rules="[{ required: true, message: '请输入行程名称', trigger: 'blur' }]">
        <el-input v-model="form.tripName" />
      </el-form-item>
      <el-form-item label="目的地" prop="destination"
        :rules="[{ required: true, message: '请输入目的地', trigger: 'blur' }]">
        <el-input v-model="form.destination" />
      </el-form-item>
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="出发日期">
            <el-date-picker v-model="form.startDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="返程日期">
            <el-date-picker v-model="form.endDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-form-item label="出行人数">
        <el-input-number v-model="form.numPeople" :min="1" :max="99" />
      </el-form-item>
      <el-form-item label="预算金额">
        <el-input-number v-model="form.totalBudget" :min="0" :precision="2" :controls="false" style="width: 200px" />
      </el-form-item>
      <el-form-item label="备注">
        <el-input v-model="form.notes" type="textarea" :rows="3" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" :loading="saving" @click="handleSave">保存</el-button>
        <el-button @click="$router.back()">取消</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { tripApi } from '@/api/trip'
import { ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()
const tripId = Number(route.params.id)
const loading = ref(false)
const saving = ref(false)
const formRef = ref()

const form = reactive({
  tripName: '' as string | undefined,
  destination: '' as string | undefined,
  startDate: '' as string | undefined,
  endDate: '' as string | undefined,
  numPeople: 1,
  totalBudget: null as number | null,
  notes: ''
})

onMounted(async () => {
  loading.value = true
  try {
    const trip = await tripApi.getById(tripId)
    Object.assign(form, {
      tripName: trip.tripName, destination: trip.destination,
      startDate: trip.startDate, endDate: trip.endDate,
      numPeople: trip.numPeople, totalBudget: trip.totalBudget,
      notes: trip.notes || ''
    })
  } finally {
    loading.value = false
  }
})

async function handleSave() {
  if (!form.tripName || !form.destination) {
    ElMessage.warning('请填写必填项')
    return
  }
  saving.value = true
  try {
    await tripApi.update(tripId, {
      tripName: form.tripName,
      destination: form.destination,
      startDate: form.startDate,
      endDate: form.endDate,
      numPeople: form.numPeople,
      totalBudget: form.totalBudget ?? undefined,
      notes: form.notes
    })
    ElMessage.success('保存成功')
    router.push(`/trips/${tripId}`)
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.form-page { max-width: 680px; }
.trip-form { margin-top: 20px; }
</style>
