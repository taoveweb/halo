const app = getApp();
const api = require('../../utils/api');

Page({
  data: { chats: [] },

  async onShow() {
    const ok = await app.ensureAuth();
    if (!ok) return;
    this.load();
  },

  async load() {
    try {
      const chats = await api.get('/chats');
      this.setData({ chats });
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },

  goDetail(e) {
    wx.navigateTo({ url: `/pages/message-detail/index?id=${e.currentTarget.dataset.id}` });
  },

  async togglePin(e) {
    const id = e.currentTarget.dataset.id;
    await api.post(`/chats/${id}/pin`, {});
    this.load();
  },
});
