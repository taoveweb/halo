const api = require('./utils/api');

App({
  globalData: {
    me: null,
  },

  isAuthed() {
    return Boolean(wx.getStorageSync('token'));
  },

  async ensureAuth() {
    if (!this.isAuthed()) {
      wx.navigateTo({ url: '/pages/auth/index' });
      return false;
    }
    return true;
  },

  async fetchMe() {
    if (!this.isAuthed()) {
      this.globalData.me = null;
      return null;
    }
    try {
      const user = await api.get('/auth/me');
      this.globalData.me = user;
      return user;
    } catch (error) {
      wx.removeStorageSync('token');
      this.globalData.me = null;
      return null;
    }
  },
});
