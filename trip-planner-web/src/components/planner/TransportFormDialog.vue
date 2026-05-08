<template>
  <el-dialog v-model="visible" :title="isEdit ? '编辑交通方式' : '添加交通方式'"
    width="480px" class="transport-dialog" @close="$emit('cancel')">
    <div v-if="!isEdit" class="from-to-hint">
      从 <strong>{{ fromTitle }}</strong> 到 <strong>{{ toTitle }}</strong>
    </div>
    <el-form :model="form" :rules="rules" ref="formRef" label-width="80px" class="transport-form">
      <el-form-item label="交通方式" prop="transportType">
        <el-select v-model="form.transportType" style="width: 100%">
          <el-option v-for="t in transportTypes" :key="t.value" :label="t.label" :value="t.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="出发时间">
        <el-time-picker v-model="form.departureTime" format="HH:mm" value-format="HH:mm"
          placeholder="出发时间" style="width: 100%" />
      </el-form-item>
      <el-form-item label="预计耗时">
        <el-input v-model.number="form.estimatedDuration" placeholder="分钟" type="number" />
      </el-form-item>
      <el-form-item label="费用">
        <el-input-number v-model="form.cost" :min="0" :precision="2" :controls="false"
          placeholder="费用" style="width: 100%" />
      </el-form-item>
      <el-form-item label="路线信息">
        <el-input v-model="form.routeInfo" placeholder="如：地铁1号线、公交XX路" />
      </el-form-item>
      <el-form-item label="备注">
        <el-input v-model="form.notes" type="textarea" :rows="2" placeholder="备注" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="visible = false; $emit('cancel')">取消</el-button>
      <el-button type="primary" :loading="saving" @click="handleSubmit">
        {{ isEdit ? '保存' : '添加' }}
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, watch, computed } from 'vue'
import type { TransportData } from '@/api/transport'

const props = defineProps<{
  modelValue: boolean
  editTransport?: TransportData | null
  fromTitle?: string
  toTitle?: string
}>()
const emit = defineEmits(['submit', 'cancel', 'update:modelValue'])

const visible = ref(props.modelValue)
watch(() => props.modelValue, v => {
  visible.value = v
  if (v && props.editTransport) {
    form.transportType = props.editTransport.transportType
    form.departureTime = props.editTransport.departureTime || ''
    form.estimatedDuration = props.editTransport.estimatedDuration || null
    form.cost = props.editTransport.cost || 0
    form.routeInfo = props.editTransport.routeInfo || ''
    form.notes = props.editTransport.notes || ''
  } else if (v) {
    form.transportType = 'SUBWAY'
    form.departureTime = ''
    form.estimatedDuration = null
    form.cost = 0
    form.routeInfo = ''
    form.notes = ''
  }
})
watch(visible, v => emit('update:modelValue', v))

const isEdit = computed(() => !!props.editTransport)

const transportTypes = [
  { label: '步行', value: 'WALK' }, { label: '公交', value: 'BUS' },
  { label: '地铁', value: 'SUBWAY' }, { label: '出租车', value: 'TAXI' },
  { label: '网约车', value: 'RIDE_HAIL' }, { label: '自驾', value: 'SELF_DRIVE' },
  { label: '共享单车', value: 'BIKE' }
]

const form = reactive({
  transportType: 'SUBWAY', departureTime: '', estimatedDuration: null as number | null,
  cost: 0, routeInfo: '', notes: ''
})

const rules = {
  transportType: [{ required: true, message: '请选择交通方式', trigger: 'change' }]
}

const formRef = ref()
const saving = ref(false)

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  saving.value = true
  emit('submit', {
    transportType: form.transportType,
    departureTime: form.departureTime || undefined,
    estimatedDuration: form.estimatedDuration ?? undefined,
    cost: form.cost || undefined,
    routeInfo: form.routeInfo || undefined,
    notes: form.notes || undefined
  })
  saving.value = false
  visible.value = false
}
</script>

<style scoped>
.from-to-hint {
  padding: 10px 14px;
  background: #f9f2ee;
  border-radius: 8px;
  margin-bottom: 18px;
  font-size: 13px;
  color: var(--color-primary);
  border-left: 3px solid var(--color-primary-light);
}
.transport-form { margin-top: 8px; }
</style>
