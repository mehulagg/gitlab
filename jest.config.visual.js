const baseConfig = require('./jest.config.base');

const DEBUG_MODE = process.argv.includes('--debug');

module.exports = {
  ...baseConfig('spec/frontend_visual', false),
  // do overwrites here
  preset: 'jest-puppeteer',
};
