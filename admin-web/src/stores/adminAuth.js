import { defineStore } from 'pinia';

import http from '../api/http';

export const useAdminAuthStore = defineStore('adminAuth', {
  state: () => ({
    token: localStorage.getItem('halo_admin_token') || '',
    username: ''
  }),
  getters: {
    isLoggedIn: (state) => Boolean(state.token)
  },
  actions: {
    async login(payload) {
      const { data } = await http.post('/admin/auth/login', payload);
      this.token = data.token;
      this.username = data.admin.username;
      localStorage.setItem('halo_admin_token', data.token);
    },
    async fetchMe() {
      if (!this.token) {
        return;
      }
      const { data } = await http.get('/admin/auth/me');
      this.username = data.username;
    },
    async logout() {
      if (this.token) {
        try {
          await http.post('/admin/auth/logout');
        } catch {
          // noop
        }
      }
      this.token = '';
      this.username = '';
      localStorage.removeItem('halo_admin_token');
    }
  }
});
