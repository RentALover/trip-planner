<template>
  <div class="trip-filter">
    <el-input
      v-model="searchKeyword"
      placeholder="搜索行程名称或目的地"
      :prefix-icon="Search"
      clearable
      class="search-input"
      @change="$emit('search', searchKeyword)"
    />
    <el-select v-model="selectedStatus" placeholder="状态筛选" clearable @change="$emit('filter', selectedStatus)">
      <el-option label="规划中" value="PLANNING" />
      <el-option label="已完成" value="COMPLETED" />
      <el-option label="已取消" value="CANCELLED" />
    </el-select>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Search } from '@element-plus/icons-vue'

defineEmits(['search', 'filter'])

const searchKeyword = ref('')
const selectedStatus = ref('')
</script>

<style scoped>
.trip-filter {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
}
.search-input {
  width: 300px;
}
@media (max-width: 768px) {
  .trip-filter {
    flex-direction: column;
  }
  .search-input {
    width: 100%;
  }
}
</style>
