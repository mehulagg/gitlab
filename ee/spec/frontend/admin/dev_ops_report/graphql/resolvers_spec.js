import Api from 'ee/api';
import MockAdapter from 'axios-mock-adapter';
import { createMockClient } from 'mock-apollo-client';
import getGroupsQuery from 'ee/admin/dev_ops_report/graphql/queries/get_groups.query.graphql';
import { resolvers } from 'ee/admin/dev_ops_report/graphql';
import httpStatus from '~/lib/utils/http_status';
import axios from '~/lib/utils/axios_utils';
import { groupData, pageData, groupNodes, groupPageInfo } from '../mock_data';

const fetchGroupsUrl = Api.buildUrl(Api.groupsPath);

describe('DevOps GraphQL resolvers', () => {
  let mockAdapter;
  let mockClient;

  beforeEach(() => {
    mockAdapter = new MockAdapter(axios);
    mockClient = createMockClient({ resolvers });
  });

  afterEach(() => {
    mockAdapter.restore();
  });

  describe('groups query', () => {
    it('when receiving groups data', async () => {
      mockAdapter.onGet(fetchGroupsUrl).reply(httpStatus.OK, groupData, pageData);
      const result = await mockClient.query({ query: getGroupsQuery });

      expect(result.data).toEqual({
        groups: {
          __typename: 'Groups',
          nodes: groupNodes,
          pageInfo: groupPageInfo,
        },
      });
    });

    it('when receiving empty groups data', async () => {
      mockAdapter.onGet(fetchGroupsUrl).reply(httpStatus.OK, [], pageData);
      const result = await mockClient.query({ query: getGroupsQuery });

      expect(result.data).toEqual({
        groups: {
          __typename: 'Groups',
          nodes: [],
          pageInfo: groupPageInfo,
        },
      });
    });

    it('with no page information', async () => {
      mockAdapter.onGet(fetchGroupsUrl).reply(httpStatus.OK, [], {});
      const result = await mockClient.query({ query: getGroupsQuery });

      expect(result.data).toEqual({
        groups: {
          __typename: 'Groups',
          nodes: [],
          pageInfo: {},
        },
      });
    });
  });
});
