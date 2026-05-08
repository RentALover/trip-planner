import api from './index'

export interface LoginReq {
  username: string
  password: string
}

export interface RegisterReq {
  username: string
  password: string
  nickname?: string
  email?: string
}

export interface UserInfo {
  id: number
  username: string
  nickname: string
  avatarUrl: string
}

export interface LoginResp {
  token: string
  user: UserInfo
}

export const authApi = {
  login(data: LoginReq): Promise<LoginResp> {
    return api.post('/auth/login', data)
  },
  register(data: RegisterReq): Promise<LoginResp> {
    return api.post('/auth/register', data)
  },
  logout(): Promise<void> {
    return api.post('/auth/logout')
  }
}
