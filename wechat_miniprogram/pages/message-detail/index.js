const app = getApp();
const api = require('../../utils/api');

Page({
  data: {
    id: '',
    chat: null,
    text: '',
  },

  onLoad(options) {
    this.setData({ id: options.id });
  },

  async onShow() {
    const ok = await app.ensureAuth();
    if (!ok) return;
    this.load();
  },

  async load() {
    try {
      await api.post(`/chats/${this.data.id}/open`, {});
      const chat = await api.get(`/chats/${this.data.id}`);
      this.setData({ chat });
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },

  onInput(e) {
    this.setData({ text: e.detail.value });
  },

  async send() {
    if (!this.data.text.trim()) return;
    await api.post(`/chats/${this.data.id}/messages`, { text: this.data.text.trim() });
    this.setData({ text: '' });
    this.load();
  },
});
