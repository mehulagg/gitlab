/* eslint-disable import/no-commonjs */
const GRAPHQL_SCHEMA_PATH = 'tmp/tests/graphql/gitlab_schema.graphql';
const GRAPHQL_SCHEMA_JOB = 'bundle exec rake gitlab:graphql:schema:dump';

const createErrorMessage = () => `
ERROR: Expected to find "${GRAPHQL_SCHEMA_PATH}" but file does not exist or could not be read. Try running:

    ${GRAPHQL_SCHEMA_JOB}
`;

const createError = (originalError = null) => {
  const error = new Error(createErrorMessage());
  error.originalError = originalError;
  return error;
};

const requireGitLabSchema = () => {
  try {
    // eslint-disable-next-line global-require, import/no-unresolved
    return require('../../../tmp/tests/graphql/gitlab_schema.graphql');
  } catch (e) {
    throw createError(e);
  }
};

module.exports = {
  requireGitLabSchema,
  createErrorMessage,
  GRAPHQL_SCHEMA_JOB,
  GRAPHQL_SCHEMA_PATH,
};
