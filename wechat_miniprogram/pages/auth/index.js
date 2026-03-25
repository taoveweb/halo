const api = require('../../utils/api');

Page({
  data: {
    mode: 'login',
    form: {
      name: '',
      handle: '',
      email: '',
      password: '',
    },
  },

  switchMode(e) {
    this.setData({ mode: e.currentTarget.dataset.mode });
  },

  onInput(e) {
    const key = e.currentTarget.dataset.key;
    this.setData({ [`form.${key}`]: e.detail.value });
  },

  async submit() {
    const { mode, form } = this.data;
    try {
      const payload = mode === 'login'
        ? await api.post('/auth/login', { email: form.email, password: form.password }, false)
        : await api.post('/auth/register', form, false);
      wx.setStorageSync('token', payload.token);
      wx.showToast({ title: mode === 'login' ? '登录成功' : '注册成功', icon: 'success' });
      wx.switchTab({ url: '/pages/home/index' });
    } catch (error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  },
});
