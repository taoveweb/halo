import { createRouter, createWebHistory } from 'vue-router';

import AdminLayout from '../layout/AdminLayout.vue';
import { useAdminAuthStore } from '../stores/adminAuth';
import DashboardView from '../views/DashboardView.vue';
import LoginView from '../views/LoginView.vue';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      component: LoginView,
      meta: {
        public: true
      }
    },
    {
      path: '/',
      component: AdminLayout,
      children: [
        {
          path: '',
          name: 'dashboard',
          component: DashboardView
        }
      ]
    }
  ]
});

router.beforeEach(async (to) => {
  const authStore = useAdminAuthStore();

  if (to.meta.public && authStore.isLoggedIn) {
    return '/';
  }

  if (!to.meta.public && !authStore.isLoggedIn) {
    return '/login';
  }

  if (!to.meta.public && authStore.isLoggedIn && !authStore.username) {
    try {
      await authStore.fetchMe();
    } catch {
      await authStore.logout();
      return '/login';
    }
  }

  return true;
});

export default router;
