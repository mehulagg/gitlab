const fs = require('fs');
const path = require('path');
const {
  createErrorMessage,
  GRAPHQL_SCHEMA_PATH,
} = require('../../spec/frontend/__helpers__/require_gitlab_schema_graphql');
const isESLint = require('./is_eslint');

const shouldIgnoreWarnings = JSON.parse(process.env.GL_IGNORE_WARNINGS || '0');

const failCheck = (message) => {
  console.error(message);

  if (!shouldIgnoreWarnings) {
    process.exit(1);
  }
};

const checkGraphqlSchema = () => {
  const shcemaPath = path.resolve(__dirname, '../../', GRAPHQL_SCHEMA_PATH);

  if (!fs.existsSync(shcemaPath)) {
    failCheck(createErrorMessage());
  }
};

const check = () => {
  if (isESLint(module)) {
    return;
  }

  checkGraphqlSchema();
};

module.exports = check;
