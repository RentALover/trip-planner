import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginView.vue'),
    meta: { public: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/RegisterView.vue'),
    meta: { public: true }
  },
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    children: [
      {
        path: '',
        name: 'Home',
        component: () => import('@/views/HomeView.vue')
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('@/views/ProfileView.vue')
      },
      {
        path: 'trips/create',
        name: 'TripCreate',
        component: () => import('@/views/TripCreateView.vue')
      },
      {
        path: 'trips/:id',
        name: 'TripDetail',
        component: () => import('@/views/TripDetailView.vue')
      },
      {
        path: 'trips/:id/edit',
        name: 'TripEdit',
        component: () => import('@/views/TripEditView.vue')
      },
      {
        path: 'trips/:id/planner',
        name: 'Planner',
        component: () => import('@/views/PlannerView.vue')
      },
      {
        path: 'trips/:id/budget',
        name: 'Budget',
        component: () => import('@/views/BudgetView.vue')
      },
      {
        path: 'trips/:id/checklist',
        name: 'Checklist',
        component: () => import('@/views/ChecklistView.vue')
      },
      {
        path: 'trips/:id/export',
        name: 'Export',
        component: () => import('@/views/ExportView.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, _from, next) => {
  const token = localStorage.getItem('token')
  if (!to.meta.public && !token) {
    next('/login')
  } else if (to.path === '/login' && token) {
    next('/')
  } else {
    next()
  }
})

export default router
