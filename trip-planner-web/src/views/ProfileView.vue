<template>
  <div class="page-container form-page">
    <h2 class="page-title">个人信息</h2>

    <div class="content-card">
      <!-- Avatar section -->
      <div class="avatar-section">
        <el-avatar :size="80" :src="profile?.avatarUrl" class="profile-avatar" />
        <div class="avatar-actions">
          <el-button :loading="uploading" @click="triggerUpload">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
            更换头像
          </el-button>
          <input ref="fileInput" type="file" accept="image/*" hidden @change="handleFileChange" />
        </div>
      </div>

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
    </div>

    <el-divider />

    <h3>修改密码</h3>
    <div class="content-card">
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
const uploading = ref(false)
const fileInput = ref<HTMLInputElement>()
const passwordFormRef = ref()
const changingPwd = ref(false)

const passwordForm = reactive({ oldPassword: '', newPassword: '' })

onMounted(async () => {
  await userStore.fetchProfile()
  profile.value = userStore.profile
})

function triggerUpload() {
  fileInput.value?.click()
}

async function handleFileChange(e: Event) {
  const target = e.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return
  uploading.value = true
  try {
    const url = await userStore.updateAvatar(file)
    if (profile.value) profile.value.avatarUrl = url
    ElMessage.success('头像已更新')
  } catch {
    ElMessage.error('头像上传失败')
  } finally {
    uploading.value = false
    target.value = ''
  }
}

async function handleSave() {
  if (!profile.value) return
  saving.value = true
  try {
    await userApi.updateProfile({
      nickname: profile.value.nickname,
      email: profile.value.email,
      phone: profile.value.phone,
      bio: profile.value.bio,
      avatarUrl: profile.value.avatarUrl
    })
    ElMessage.success('保存成功')
  } finally { saving.value = false }
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
  } finally { changingPwd.value = false }
}
</script>

<style scoped>
.form-page { max-width: 600px; }
.page-title {
  font-family: var(--font-display);
  font-size: 22px;
  font-weight: 700;
  margin: 0 0 20px;
  letter-spacing: 0.03em;
}
h3 {
  font-family: var(--font-display);
  font-size: 18px;
  font-weight: 600;
  margin: 0 0 16px;
}
.content-card {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 24px;
}
.profile-form, .password-form { margin: 0; }

.avatar-section {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 1px solid var(--color-border-light);
}
.profile-avatar {
  border: 2px solid var(--color-primary-light);
  flex-shrink: 0;
}
.avatar-actions {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.avatar-actions .el-button {
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 6px;
}
</style>
