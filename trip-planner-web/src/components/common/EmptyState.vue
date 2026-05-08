<template>
  <div class="empty-state">
    <el-empty :description="description" :image-size="120">
      <el-button v-if="actionText" type="primary" @click="$emit('action')">
        {{ actionText }}
      </el-button>
    </el-empty>
  </div>
</template>

<script setup lang="ts">
defineProps({
  description: { type: String, default: '暂无数据' },
  actionText: { type: String, default: '' }
})
defineEmits(['action'])
</script>

<style scoped>
.empty-state {
  padding: 60px 0;
}
</style>
