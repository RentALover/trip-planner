import { defineStore } from 'pinia'
import { ref } from 'vue'
import { authApi, type UserInfo } from '@/api/auth'
import { userApi, type UserProfile } from '@/api/user'
import router from '@/router'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref<UserInfo | null>(
    JSON.parse(localStorage.getItem('userInfo') || 'null')
  )
  const profile = ref<UserProfile | null>(null)

  function setAuth(t: string, user: UserInfo) {
    token.value = t
    userInfo.value = user
    localStorage.setItem('token', t)
    localStorage.setItem('userInfo', JSON.stringify(user))
  }

  async function login(username: string, password: string) {
    const res = await authApi.login({ username, password })
    setAuth(res.token, res.user)
    router.push('/')
  }

  async function register(username: string, password: string, nickname?: string) {
    const res = await authApi.register({ username, password, nickname })
    setAuth(res.token, res.user)
    router.push('/')
  }

  function logout() {
    token.value = ''
    userInfo.value = null
    profile.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
    authApi.logout().catch(() => {})
    router.push('/login')
  }

  async function fetchProfile() {
    profile.value = await userApi.getProfile()
  }

  return { token, userInfo, profile, login, register, logout, fetchProfile }
})
