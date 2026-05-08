<template>
  <el-dialog v-model="visible" :title="isEdit ? '编辑行程项' : '添加行程项'" width="520px"
    class="item-dialog"
    @close="$emit('cancel')">
    <el-form :model="form" :rules="rules" ref="formRef" label-width="80px">
      <el-form-item label="类型" prop="itemType">
        <el-select v-model="form.itemType" style="width: 100%">
          <el-option v-for="t in types" :key="t.value" :label="t.label" :value="t.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="标题" prop="title">
        <el-input v-model="form.title" :placeholder="titlePlaceholder" />
      </el-form-item>
      <el-row :gutter="12">
        <el-col :span="12">
          <el-form-item label="开始时间">
            <el-time-picker v-model="form.startTime" format="HH:mm" value-format="HH:mm"
              placeholder="开始时间" style="width: 100%" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="结束时间">
            <el-time-picker v-model="form.endTime" format="HH:mm" value-format="HH:mm"
              placeholder="结束时间" style="width: 100%" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-form-item label="地点">
        <el-input v-model="form.location" placeholder="地点或地址" />
      </el-form-item>
      <el-form-item label="费用">
        <el-input-number v-model="form.cost" :min="0" :precision="2" :controls="false"
          placeholder="费用" style="width: 100%" />
      </el-form-item>
      <el-form-item label="备注">
        <el-input v-model="form.description" type="textarea" :rows="2" placeholder="备注" />
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
import type { ItemData } from '@/api/item'

const props = defineProps<{ modelValue: boolean; editItem?: ItemData | null }>()
const emit = defineEmits(['submit', 'cancel', 'update:modelValue'])

const visible = ref(props.modelValue)
watch(() => props.modelValue, v => {
  visible.value = v
  if (v && props.editItem) {
    form.itemType = props.editItem.itemType
    form.title = props.editItem.title
    form.startTime = props.editItem.startTime || ''
    form.endTime = props.editItem.endTime || ''
    form.location = props.editItem.location || ''
    form.cost = props.editItem.cost || 0
    form.description = props.editItem.description || ''
    form.itemDetails = props.editItem.itemDetails || ''
  } else if (v) {
    form.itemType = 'ATTRACTION'
    form.title = ''
    form.startTime = ''
    form.endTime = ''
    form.location = ''
    form.cost = 0
    form.description = ''
    form.itemDetails = ''
  }
})
watch(visible, v => emit('update:modelValue', v))

const isEdit = computed(() => !!props.editItem)

const types = [
  { label: '交通', value: 'TRANSPORT' }, { label: '住宿', value: 'ACCOMMODATION' },
  { label: '餐饮', value: 'DINING' }, { label: '景点/游玩', value: 'ATTRACTION' },
  { label: '购物', value: 'SHOPPING' }, { label: '其他', value: 'OTHER' }
]

const titlePlaceholder = computed(() => {
  const map: Record<string, string> = {
    TRANSPORT: '如：CA1234航班', ACCOMMODATION: '如：锦江之星',
    DINING: '如：全聚德烤鸭店', ATTRACTION: '如：故宫博物院',
    SHOPPING: '如：王府井百货', OTHER: '行程项标题'
  }
  return map[form.itemType] || '行程项标题'
})

const form = reactive({
  itemType: 'ATTRACTION', title: '', startTime: '', endTime: '',
  location: '', cost: 0, description: '', itemDetails: ''
})

const rules = {
  itemType: [{ required: true, message: '请选择类型', trigger: 'change' }],
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }]
}

const formRef = ref()
const saving = ref(false)

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  saving.value = true
  emit('submit', {
    itemType: form.itemType, title: form.title,
    startTime: form.startTime || undefined,
    endTime: form.endTime || undefined,
    location: form.location || undefined,
    cost: form.cost || undefined,
    description: form.description || undefined,
    itemDetails: form.itemDetails || undefined
  })
  saving.value = false
  visible.value = false
}
</script>
