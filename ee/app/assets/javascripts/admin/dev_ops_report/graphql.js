import Vue from 'vue';
import VueApollo from 'vue-apollo';
import Api from 'ee/api';
import axios from '~/lib/utils/axios_utils';
import createDefaultClient from '~/lib/graphql';
import getGroupsQuery from './graphql/queries/get_groups.query.graphql';

Vue.use(VueApollo);

const resolvers = {
  Query: {
    groups(_, { search, nextPage }, { cache }) {
      const url = Api.buildUrl(Api.groupsPath);
      const params = {
        per_page: 2,
        search,
      };
      if (nextPage) {
        params.page = nextPage;
      }
      return axios.get(url, { params }).then(({ data, headers }) => {
        const pageInfo = {
          nextPage: headers['x-next-page'],
          previousPage: headers['x-prev-page'],
        };
        const groups = {
          // eslint-disable-next-line @gitlab/require-i18n-strings
          __typename: 'Groups',
          // eslint-disable-next-line @gitlab/require-i18n-strings
          nodes: data.map(group => ({ ...group, __typename: 'Group' })),
          pageInfo,
        };

        cache.writeQuery({ query: getGroupsQuery, data: groups });

        return groups;
      });
    },
  },
};

const defaultClient = createDefaultClient(resolvers);

export default new VueApollo({
  defaultClient,
});
