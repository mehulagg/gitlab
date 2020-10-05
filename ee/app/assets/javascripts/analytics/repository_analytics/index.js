import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import GroupRepositoryAnalytics from './components/group_repository_analytics.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient({
    Project: {
      /*
        The backend for adding `codeCoverage` the API is being worked on in parallel.
        This is a temporary client resolver for this data. This feature is behind
        a feature flag (:group_coverage_data_report)
      */
      codeCoverage: () => ({
        average: (Math.random() * 100).toFixed(2),
        count: Math.ceil(Math.random() * Math.floor(10)), // random number between 1 and 10
        lastUpdatedAt: '2020-09-29T21:42:00Z',
        __typename: 'CodeCoverage',
      }),
    },
  }),
});

export default () => {
  const el = document.querySelector('#js-group-repository-analytics');
  const { groupAnalyticsCoverageReportsPath, groupFullPath, coverageTableEmptyStateSvgPath } =
    el?.dataset || {};

  if (el) {
    // eslint-disable-next-line no-new
    new Vue({
      el,
      components: {
        GroupRepositoryAnalytics,
      },
      apolloProvider,
      provide: {
        coverageTableEmptyStateSvgPath,
        groupAnalyticsCoverageReportsPath,
        groupFullPath,
      },
      render(createElement) {
        return createElement('group-repository-analytics', {});
      },
    });
  }
};
