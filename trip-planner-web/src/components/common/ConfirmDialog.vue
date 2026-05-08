<template>
  <el-dialog v-model="visible" :title="title" width="420px" @close="$emit('cancel')">
    <p>{{ message }}</p>
    <template #footer>
      <el-button @click="visible = false; $emit('cancel')">取消</el-button>
      <el-button type="primary" @click="visible = false; $emit('confirm')" :loading="loading">确认</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  title: { type: String, default: '确认操作' },
  message: { type: String, default: '确定要执行此操作吗？' },
  loading: { type: Boolean, default: false }
})

defineEmits(['confirm', 'cancel', 'update:modelValue'])

const visible = ref(props.modelValue)
watch(() => props.modelValue, v => visible.value = v)
watch(visible, v => { /* handled by dialog */ })
</script>
