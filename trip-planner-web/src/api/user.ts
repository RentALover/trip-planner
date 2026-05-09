import api from './index'

export interface UserProfile {
  id: number
  username: string
  nickname: string
  email: string
  phone: string
  avatarUrl: string
  bio: string
  createTime: string
}

export interface UserUpdateReq {
  nickname?: string
  email?: string
  phone?: string
  avatarUrl?: string
  bio?: string
}

export interface PasswordChangeReq {
  oldPassword: string
  newPassword: string
}

export const userApi = {
  getProfile(): Promise<UserProfile> {
    return api.get('/user/profile')
  },
  updateProfile(data: UserUpdateReq): Promise<UserProfile> {
    return api.put('/user/profile', data)
  },
  changePassword(data: PasswordChangeReq): Promise<void> {
    return api.put('/user/password', data)
  },
  uploadAvatar(file: File): Promise<string> {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/upload/avatar', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
}
