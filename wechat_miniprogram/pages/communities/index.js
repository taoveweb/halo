const app = getApp();
const api = require('../../utils/api');

Page({
  data: { communities: [] },

  async onShow() {
    const ok = await app.ensureAuth();
    if (!ok) return;
    this.load();
  },

  async load() {
    try {
      const communities = await api.get('/communities');
      this.setData({ communities });
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },

  async toggleJoin(e) {
    const { id, active } = e.currentTarget.dataset;
    try {
      await api.post(`/communities/${id}/join`, { active: !active });
      this.load();
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },
});
