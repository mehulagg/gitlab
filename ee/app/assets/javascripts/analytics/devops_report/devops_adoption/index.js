import Vue from 'vue';
import { convertToGraphQLId, TYPE_GROUP } from '~/graphql_shared/utils';
import DevopsReportApp from './components/devops_report_app.vue';
import { createApolloProvider } from './graphql';

export default () => {
  const el = document.querySelector('.js-devops-report-app');

  if (!el) return false;

  const {
    emptyStateSvgPath,
    groupId,
    devopsScoreMetrics,
    devopsReportDocsPath,
    noDataImagePath,
  } = el.dataset;

  const isGroup = Boolean(groupId);

  return new Vue({
    el,
    apolloProvider: createApolloProvider(groupId),
    provide: {
      emptyStateSvgPath,
      isGroup,
      groupGid: isGroup ? convertToGraphQLId(TYPE_GROUP, groupId) : null,
      devopsScoreMetrics: isGroup ? null : JSON.parse(devopsScoreMetrics),
      devopsReportDocsPath,
      noDataImagePath,
    },
    render(h) {
      return h(DevopsReportApp);
    },
  });
};
