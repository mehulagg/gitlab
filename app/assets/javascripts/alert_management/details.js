import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { defaultDataIdFromObject } from 'apollo-cache-inmemory';
import sidebarCollapsedQuery from './graphql/queries/sidebar_collapsed.query.graphql';
import AlertDetails from './components/alert_details.vue';

Vue.use(VueApollo);

export default selector => {
  const domEl = document.querySelector(selector);
  const { alertId, projectPath, newIssuePath } = domEl.dataset;

  const resolvers = {
    Mutation: {
      updateSidebarCollapsed: (_, { id = null, source }, { cache }) => {
        const data = cache.readQuery({ query: sidebarCollapsedQuery });
        data.sidebarToggle = {
          __typename: 'SidebarToggle',
          id,
          source,
        };
        cache.writeQuery({ query: sidebarCollapsedQuery, data });
      },
    },
  };

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(
      resolvers,
      {
        cacheConfig: {
          dataIdFromObject: object => {
            // eslint-disable-next-line no-underscore-dangle
            if (object.__typename === 'AlertManagementAlert') {
              return object.iid;
            }
            return defaultDataIdFromObject(object);
          },
        },
      },
    ),
  });

  // eslint-disable-next-line no-new
  new Vue({
    el: selector,
    apolloProvider,
    components: {
      AlertDetails,
    },
    render(createElement) {
      return createElement('alert-details', {
        props: {
          alertId,
          projectPath,
          newIssuePath,
        },
      });
    },
  });
};
