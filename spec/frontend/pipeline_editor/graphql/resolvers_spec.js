import MockAdapter from 'axios-mock-adapter';
import Api from '~/api';
import {
  mockCiConfigPath,
  mockCiYml,
  mockDefaultBranch,
  mockLintResponse,
  mockProjectPath,
} from '../mock_data';
import httpStatus from '~/lib/utils/http_status';
import axios from '~/lib/utils/axios_utils';
import resolvers from '~/pipeline_editor/graphql/resolvers';

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
          projectPath: mockProjectPath,
          path: mockCiConfigPath,
          ref: mockDefaultBranch,
        });

        expect(Api.getRawFile).toHaveBeenCalledWith(mockProjectPath, mockCiConfigPath, {
          ref: mockDefaultBranch,
        });

        // eslint-disable-next-line no-underscore-dangle
        expect(result.__typename).toBe('BlobContent');
        await expect(result.rawData).resolves.toBe(mockCiYml);
      });
    });
  });

  describe('Mutation', () => {
    describe('lintCI', () => {
      let mock;

      const endpoint = '/ci/lint';

      beforeEach(() => {
        mock = new MockAdapter(axios);
        mock.onPost(endpoint).reply(httpStatus.OK, mockLintResponse);
      });

      afterEach(() => {
        mock.restore();
      });

      it('resolves lint data with type names', async () => {
        const result = resolvers.Mutation.lintCI(null, {
          endpoint,
          content: 'content',
          dry_run: true,
        });

        await expect(result).resolves.toMatchSnapshot();
      });
    });
  });
});
