const app = getApp();
const api = require('../../utils/api');

Page({
  data: {
    id: '',
    tweet: null,
    comments: [],
    content: '',
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
      await api.post(`/tweets/${this.data.id}/view`, {});
      const tweet = await api.get(`/tweets/${this.data.id}`);
      const comments = await api.get(`/tweets/${this.data.id}/comments`, false);
      this.setData({ tweet, comments });
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },

  onInput(e) {
    this.setData({ content: e.detail.value });
  },

  async comment() {
    if (!this.data.content.trim()) return;
    await api.post(`/tweets/${this.data.id}/comments`, { content: this.data.content.trim() });
    this.setData({ content: '' });
    this.load();
  },
});
