const app = getApp();
const api = require('../../utils/api');

Page({
  data: { notifications: [] },

  async onShow() {
    const ok = await app.ensureAuth();
    if (!ok) return;
    this.load();
  },

  async load() {
    try {
      const notifications = await api.get('/notifications');
      this.setData({ notifications });
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },

  async markRead(e) {
    const id = e.currentTarget.dataset.id;
    try {
      await api.post(`/notifications/${id}/read`, {});
      this.load();
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },

  async readAll() {
    await api.post('/notifications/read-all', {});
    this.load();
  },
});
