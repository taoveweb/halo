Component({
  properties: {
    current: {
      type: String,
      value: 'home',
    },
  },

  data: {
    tabs: [
      { key: 'home', text: '首页', pagePath: '/pages/home/index', icon: '🏠' },
      { key: 'search', text: '搜索', pagePath: '/pages/search/index', icon: '🔍' },
      { key: 'communities', text: '社区', pagePath: '/pages/communities/index', icon: '👥' },
      { key: 'notifications', text: '通知', pagePath: '/pages/notifications/index', icon: '🔔' },
      { key: 'messages', text: '消息', pagePath: '/pages/messages/index', icon: '✉️' }
    ],
  },

  methods: {
    switchTab(event) {
      const target = event.currentTarget.dataset.path;
      if (!target || target === `/${getCurrentPages().slice(-1)[0]?.route}`) {
        return;
      }
      wx.redirectTo({
        url: target,
      });
    },
  },
});
