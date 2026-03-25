const app = getApp();
const api = require('../../utils/api');

Page({
  data: {
    content: '',
  },

  async onShow() {
    await app.ensureAuth();
  },

  onInput(e) {
    this.setData({ content: e.detail.value });
  },

  async submit() {
    if (!this.data.content.trim()) {
      wx.showToast({ title: '内容不能为空', icon: 'none' });
      return;
    }
    try {
      await api.post('/tweets', { content: this.data.content.trim(), media: [] });
      wx.showToast({ title: '发布成功', icon: 'success' });
      wx.navigateBack();
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },
});
