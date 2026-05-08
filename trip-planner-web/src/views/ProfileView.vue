<template>
  <div class="page-container form-page">
    <h2>个人信息</h2>
    <el-form v-if="profile" :model="profile" ref="formRef" label-width="100px" class="profile-form">
      <el-form-item label="用户名">
        <el-input :model-value="profile.username" disabled />
      </el-form-item>
      <el-form-item label="昵称">
        <el-input v-model="profile.nickname" />
      </el-form-item>
      <el-form-item label="邮箱">
        <el-input v-model="profile.email" />
      </el-form-item>
      <el-form-item label="手机号">
        <el-input v-model="profile.phone" />
      </el-form-item>
      <el-form-item label="个人简介">
        <el-input v-model="profile.bio" type="textarea" :rows="3" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" :loading="saving" @click="handleSave">保存</el-button>
      </el-form-item>
    </el-form>

    <el-divider />
    <h3>修改密码</h3>
    <el-form :model="passwordForm" ref="passwordFormRef" label-width="100px" class="password-form">
      <el-form-item label="原密码" prop="oldPassword"
        :rules="[{ required: true, message: '请输入原密码', trigger: 'blur' }]">
        <el-input v-model="passwordForm.oldPassword" type="password" show-password />
      </el-form-item>
      <el-form-item label="新密码" prop="newPassword"
        :rules="[{ required: true, message: '请输入新密码', trigger: 'blur' },
                 { min: 6, message: '密码至少6位', trigger: 'blur' }]">
        <el-input v-model="passwordForm.newPassword" type="password" show-password />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" :loading="changingPwd" @click="handleChangePassword">修改密码</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { userApi, type UserProfile } from '@/api/user'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const profile = ref<UserProfile | null>(null)
const saving = ref(false)
const passwordFormRef = ref()
const changingPwd = ref(false)

const passwordForm = reactive({ oldPassword: '', newPassword: '' })

onMounted(async () => {
  await userStore.fetchProfile()
  profile.value = userStore.profile
})

async function handleSave() {
  if (!profile.value) return
  saving.value = true
  try {
    await userApi.updateProfile({
      nickname: profile.value.nickname,
      email: profile.value.email,
      phone: profile.value.phone,
      bio: profile.value.bio
    })
    ElMessage.success('保存成功')
  } finally {
    saving.value = false
  }
}

async function handleChangePassword() {
  const valid = await passwordFormRef.value?.validate().catch(() => false)
  if (!valid) return
  changingPwd.value = true
  try {
    await userApi.changePassword(passwordForm)
    ElMessage.success('密码修改成功')
    passwordForm.oldPassword = ''
    passwordForm.newPassword = ''
  } finally {
    changingPwd.value = false
  }
}
</script>

<style scoped>
.form-page { max-width: 600px; }
.profile-form, .password-form { margin-top: 20px; }
</style>
