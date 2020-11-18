/* eslint-disable global-require, import/no-unresolved */
import { memoize } from 'lodash';
import { readFileSync } from 'fs';
import { join } from 'path';

const DEFAULT_CONTENT = 'Bananas';

const withDefault = (fn, defaultValue) => () => {
  try {
    return fn();
  } catch {
    return defaultValue;
  }
};

export const getProject = () => require('test_fixtures/api/projects/get.json');
export const getEmptyProject = () => require('test_fixtures/api/projects/get_empty.json');
export const getBranch = () => require('test_fixtures/api/projects/branches/get.json');
export const getMergeRequests = () => require('test_fixtures/api/merge_requests/get.json');
export const getRepositoryFiles = () => require('test_fixtures/projects_json/files.json');

export const getBlobReadme = withDefault(
  () => readFileSync(require.resolve('test_fixtures/blob/text/README.md'), 'utf8'),
  DEFAULT_CONTENT,
);
export const getBlobZip = withDefault(
  () => readFileSync(require.resolve('test_fixtures/blob/binary/Gemfile.zip'), 'utf8'),
  DEFAULT_CONTENT,
);
export const getBlobImage = withDefault(
  () =>
    readFileSync(
      join(require.resolve('test_fixtures/blob/text/README.md'), '../..', 'images/logo-white.png'),
      'utf8',
    ),
  DEFAULT_CONTENT,
);

export const getPipelinesEmptyResponse = () =>
  require('test_fixtures/projects_json/pipelines_empty.json');
export const getCommit = memoize(() => getBranch().commit);
