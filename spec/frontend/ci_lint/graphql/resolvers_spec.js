import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';

import resolvers from '~/ci_lint/graphql/resolvers';
import { mockLintResponse } from '../mock_data';

describe('~/ci_lint/graphql/resolvers', () => {
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
  });

  describe('Mutation', () => {
    describe('lintCI', () => {
      const endpoint = '/ci/lint';

      beforeEach(() => {
        mock.onPost(endpoint).reply(httpStatus.OK, mockLintResponse);
      });

      it('resolves lint data', async () => {
        const result = resolvers.Mutation.lintCI(null, {
          endpoint,
          content: 'content',
          dry_run: true,
        });

        await expect(result).resolves.toEqual({
          valid: true,
          errors: [],
          warnings: [],
          jobs: [
            {
              name: 'job_1',
              stage: 'test',
              beforeScript: ["echo 'before script 1'"],
              script: ["echo 'script 1'"],
              afterScript: ["echo 'after script 1"],
              tagList: ['tag 1'],
              environment: 'prd',
              when: 'on_success',
              allowFailure: false,
              only: null,
              except: {
                refs: ['master@gitlab-org/gitlab', '/^release/.*$/@gitlab-org/gitlab'],
              },
              __typename: 'CiLintJob',
            },
            {
              name: 'job_2',
              stage: 'test',
              beforeScript: ["echo 'before script 2'"],
              script: ["echo 'script 2'"],
              afterScript: ["echo 'after script 2"],
              tagList: ['tag 2'],
              environment: 'stg',
              when: 'on_success',
              allowFailure: true,
              only: {
                refs: ['web', 'chat', 'pushes'],
                __typename: 'CiLintJobOnlyPolicy',
              },
              except: {
                refs: ['master@gitlab-org/gitlab', '/^release/.*$/@gitlab-org/gitlab'],
              },
              __typename: 'CiLintJob',
            },
          ],
          __typename: 'CiLintContent',
        });
      });
    });
  });
});
