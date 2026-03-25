const app = getApp();
const api = require('../../utils/api');

Page({
  data: {
    me: null,
    name: '',
    handle: '',
    email: '',
    currentPassword: '',
    newPassword: '',
  },

  async onShow() {
    const ok = await app.ensureAuth();
    if (!ok) return;
    const me = await app.fetchMe();
    if (me) {
      this.setData({
        me,
        name: me.name,
        handle: me.handle,
        email: me.email,
      });
    }
  },

  onInput(e) {
    const key = e.currentTarget.dataset.key;
    this.setData({ [key]: e.detail.value });
  },

  async save() {
    const payload = {
      name: this.data.name,
      handle: this.data.handle,
      email: this.data.email,
    };
    if (this.data.currentPassword && this.data.newPassword) {
      payload.currentPassword = this.data.currentPassword;
      payload.newPassword = this.data.newPassword;
    }
    try {
      const me = await api.patch('/auth/profile', payload);
      app.globalData.me = me;
      wx.showToast({ title: '已更新', icon: 'success' });
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },

  async logout() {
    try {
      await api.post('/auth/logout', {});
    } catch (error) {
      // ignore
    }
    wx.removeStorageSync('token');
    app.globalData.me = null;
    wx.redirectTo({ url: '/pages/auth/index' });
  },
});
