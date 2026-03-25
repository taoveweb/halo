const env = {
  dev: 'http://127.0.0.1:3000/api',
  test: 'http://127.0.0.1:3000/api',
  prod: 'http://127.0.0.1:3000/api',
};

const appEnv = wx.getAccountInfoSync ? 'dev' : 'dev';

function getBaseUrl() {
  return env[appEnv] || env.dev;
}

module.exports = {
  getBaseUrl,
};
