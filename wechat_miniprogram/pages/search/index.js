const app = getApp();
const api = require('../../utils/api');

Page({
  data: {
    query: '',
    tweets: [],
    topics: [],
  },

  async onShow() {
    const ok = await app.ensureAuth();
    if (!ok) return;
    this.search();
  },

  onInput(e) {
    this.setData({ query: e.detail.value });
  },

  async search() {
    try {
      const { query } = this.data;
      const tweets = await api.get(`/tweets?feed=forYou${query ? `&query=${encodeURIComponent(query)}` : ''}`);
      const topics = await api.get(`/topics${query ? `?query=${encodeURIComponent(query)}` : ''}`);
      this.setData({ tweets, topics });
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },

  async toggleTopic(e) {
    const { id, active } = e.currentTarget.dataset;
    await api.post(`/topics/${id}/follow`, { active: !active });
    this.search();
  },

  goTweetDetail(e) {
    wx.navigateTo({ url: `/pages/tweet-detail/index?id=${e.currentTarget.dataset.id}` });
  },
});
