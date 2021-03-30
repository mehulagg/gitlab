import MockAdapter from 'axios-mock-adapter';
import Api from '~/api';
import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';
import { resolvers } from '~/pipeline_editor/graphql/resolvers';
import {
  mockCiConfigPath,
  mockCiYml,
  mockDefaultBranch,
  mockLintResponse,
  mockProjectFullPath,
} from '../mock_data';

jest.mock('~/api', () => {
  return {
    getRawFile: jest.fn(),
  };
});

describe('~/pipeline_editor/graphql/resolvers', () => {
  describe('Query', () => {
    describe('blobContent', () => {
      beforeEach(() => {
        Api.getRawFile.mockResolvedValue({
          data: mockCiYml,
        });
      });

      afterEach(() => {
        Api.getRawFile.mockReset();
      });

      it('resolves lint data with type names', async () => {
        const result = resolvers.Query.blobContent(null, {
          projectPath: mockProjectFullPath,
          path: mockCiConfigPath,
          ref: mockDefaultBranch,
        });

        expect(Api.getRawFile).toHaveBeenCalledWith(mockProjectFullPath, mockCiConfigPath, {
          ref: mockDefaultBranch,
        });

        // eslint-disable-next-line no-underscore-dangle
        expect(result.__typename).toBe('BlobContent');
        await expect(result.rawData).resolves.toBe(mockCiYml);
      });
    });

    describe('project', () => {
      it('resolves project data with type names', async () => {
        const result = await resolvers.Query.project();

        // eslint-disable-next-line no-underscore-dangle
        expect(result.__typename).toBe('Project');
      });

      it('resolves project with available list of branches', async () => {
        const result = await resolvers.Query.project();

        expect(result.repository.branches).toHaveLength(5);
      });
    });
  });

  describe('Mutation', () => {
    describe('lintCI', () => {
      let mock;
      let result;

      const endpoint = '/ci/lint';

      beforeEach(async () => {
        mock = new MockAdapter(axios);
        mock.onPost(endpoint).reply(httpStatus.OK, mockLintResponse);

        result = await resolvers.Mutation.lintCI(null, {
          endpoint,
          content: 'content',
          dry_run: true,
        });
      });

      afterEach(() => {
        mock.restore();
      });

      /* eslint-disable no-underscore-dangle */
      it('lint data has correct type names', async () => {
        expect(result.__typename).toBe('CiLintContent');

        expect(result.jobs[0].__typename).toBe('CiLintJob');
        expect(result.jobs[1].__typename).toBe('CiLintJob');

        expect(result.jobs[1].only.__typename).toBe('CiLintJobOnlyPolicy');
      });
      /* eslint-enable no-underscore-dangle */

      it('lint data is as expected', () => {
        expect(result).toMatchSnapshot();
      });
    });
  });
});
