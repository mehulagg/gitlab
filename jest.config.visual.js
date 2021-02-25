const baseConfig = require('./jest.config.base');

const DEBUG_MODE = process.argv.includes('--debug');

// console.log(baseConfig('spec/frontend_visual', false));

module.exports = {
  ...baseConfig('spec/frontend_visual', false),
  // do overwrites here
  preset: 'jest-puppeteer',
};
