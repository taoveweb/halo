const app = getApp();
const api = require('../../utils/api');

Page({
  data: {
    feed: 'forYou',
    tweets: [],
    loading: false,
  },

  async onShow() {
    const ok = await app.ensureAuth();
    if (!ok) return;
    this.loadTweets();
  },

  async loadTweets() {
    this.setData({ loading: true });
    try {
      const tweets = await api.get(`/tweets?feed=${this.data.feed}`);
      this.setData({ tweets });
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    } finally {
      this.setData({ loading: false });
    }
  },

  switchFeed(e) {
    const feed = e.currentTarget.dataset.feed;
    this.setData({ feed }, () => this.loadTweets());
  },

  goCompose() {
    wx.navigateTo({ url: '/pages/compose/index' });
  },

  goProfile() {
    wx.navigateTo({ url: '/pages/profile/index' });
  },

  goTweetDetail(e) {
    const id = e.currentTarget.dataset.id;
    wx.navigateTo({ url: `/pages/tweet-detail/index?id=${id}` });
  },

  async toggleAction(e) {
    const { id, action, active } = e.currentTarget.dataset;
    try {
      await api.post(`/tweets/${id}/${action}`, { active: !active });
      this.loadTweets();
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },
});
