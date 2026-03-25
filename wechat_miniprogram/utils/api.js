const { getBaseUrl } = require('./config');

function request({ url, method = 'GET', data, auth = true }) {
  const token = wx.getStorageSync('token');
  return new Promise((resolve, reject) => {
    wx.request({
      url: `${getBaseUrl()}${url}`,
      method,
      data,
      header: {
        'content-type': 'application/json',
        ...(auth && token ? { Authorization: `Bearer ${token}` } : {}),
      },
      success(res) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(res.data);
          return;
        }
        reject(new Error(res.data?.message || `请求失败(${res.statusCode})`));
      },
      fail(err) {
        reject(new Error(err.errMsg || '网络异常'));
      },
    });
  });
}

module.exports = {
  get: (url, auth = true) => request({ url, method: 'GET', auth }),
  post: (url, data, auth = true) => request({ url, method: 'POST', data, auth }),
  patch: (url, data, auth = true) => request({ url, method: 'PATCH', data, auth }),
  del: (url, auth = true) => request({ url, method: 'DELETE', auth }),
};
