const IS_EE = require('./config/helpers/is_ee_env');
const getBaseConfig = require('./jest.config.base');

const baseConfig = getBaseConfig('spec/frontend_integration');

const moduleNameMapperIntegration = {
  '^test_helpers(/.*)$': '<rootDir>/spec/frontend_integration/test_helpers$1',
  '^ee_else_ce_test_helpers(/.*)$': '<rootDir>/spec/frontend_integration/test_helpers$1',
};

if (IS_EE) {
  Object.assign(moduleNameMapperIntegration, {
    '^ee_else_ce_test_helpers(/.*)$': '<rootDir>/ee/spec/frontend_integration/test_helpers$1',
  });
}

module.exports = {
  ...baseConfig,
  moduleNameMapper: {
    ...baseConfig.moduleNameMapper,
    ...moduleNameMapperIntegration,
  },
};
