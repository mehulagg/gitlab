const fs = require('fs');
const baseConfig = require('./jest.config.base');

const GRAPHQL_SCHEMA_PATH = 'tmp/tests/graphql/gitlab_schema.graphql';
const GRAPHQL_SCHEMA_JOB = 'bundle exec rake gitlab:graphql:schema:dump';

const shouldIgnoreWarnings = JSON.parse(process.env.GL_IGNORE_WARNINGS || '0');

const failCheck = (message) => {
  console.error(message);

  if (!shouldIgnoreWarnings) {
    process.exit(1);
  }
};

const checkGraphqlSchema = () => {
  if (!fs.existsSync(GRAPHQL_SCHEMA_PATH)) {
    const message = `
ERROR: Expected to find "${GRAPHQL_SCHEMA_PATH}" but file does not exist. Try running:

    ${GRAPHQL_SCHEMA_JOB}
`;

    failCheck(message);
  }
};

checkGraphqlSchema();

module.exports = {
  ...baseConfig('spec/frontend_integration', {
    moduleNameMapper: {
      '^test_helpers(/.*)$': '<rootDir>/spec/frontend_integration/test_helpers$1',
      '^ee_else_ce_test_helpers(/.*)$': '<rootDir>/spec/frontend_integration/test_helpers$1',
    },
    moduleNameMapperEE: {
      '^ee_else_ce_test_helpers(/.*)$': '<rootDir>/ee/spec/frontend_integration/test_helpers$1',
    },
  }),
};
