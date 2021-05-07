import Vue from 'vue';
import VueApollo from 'vue-apollo';
import Api from 'ee/api';
import createDefaultClient from '~/lib/graphql';
import axios from '~/lib/utils/axios_utils';

Vue.use(VueApollo);

export const createResolvers = (groupId) => ({
  Query: {
    groups(_, { search, nextPage }) {
      const url = groupId
        ? Api.buildUrl(Api.subgroupsPath).replace(':id', groupId)
        : Api.buildUrl(Api.groupsPath);
      const params = {
        per_page: Api.DEFAULT_PER_PAGE,
        search,
      };
      if (nextPage) {
        params.page = nextPage;
      }

      return axios.get(url, { params }).then(({ data, headers }) => {
        const pageInfo = {
          nextPage: headers['x-next-page'],
        };
        const groups = {
          // eslint-disable-next-line @gitlab/require-i18n-strings
          __typename: 'Groups',
          // eslint-disable-next-line @gitlab/require-i18n-strings
          nodes: data.map((group) => ({ ...group, __typename: 'Group' })),
          pageInfo,
        };

        return groups;
      });
    },
  },
});

export const createApolloProvider = (groupId) =>
  new VueApollo({
    defaultClient: createDefaultClient(createResolvers(groupId)),
  });
