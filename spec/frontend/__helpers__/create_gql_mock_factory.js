import { mockServer, mockList, defaultAutomocks, automockScalars } from 'graphql-mock-factory';
import { isString } from 'lodash';
import { requireGitLabSchema } from './require_gitlab_schema_graphql';

const createMockedServer = ({ mocks, automocks } = {}) => {
  const gitlabSchema = requireGitLabSchema();

  return mockServer(gitlabSchema.loc.source.body, mocks, [
    ...defaultAutomocks,
    automockScalars({ UntrustedRegexp: () => '^test$' }),
    ...automocks,
  ]);
};

const createQuerier = (mockedServer) => {
  const query = (queryArg, variables, ...args) => {
    const queryStr = isString(queryArg) ? queryArg : queryArg.loc.source.body;

    return mockedServer(queryStr, variables, ...args);
  };

  query.resolve = (...args) => Promise.resolve(query(...args));
  query.reject = (...args) => Promise.reject(query(...args));

  return query;
};

const createGqlMockFactory = ({ mocks = {}, automocks = [] } = {}) => {
  const mockedServer = createMockedServer({ mocks, automocks });

  return createQuerier(mockedServer);
};

export { mockList, createGqlMockFactory };
