import Vue from 'vue';

import { IssuableStates } from '~/issuable_list/constants';
import { urlParamsToObject, convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

import JiraIssuesListApp from './components/jira_issues_list_root.vue';
import apolloProvider from './graphql';

export default function initJiraIssuesList({ mountPointSelector }) {
  const mountPointEl = document.querySelector(mountPointSelector);

  if (!mountPointEl) {
    return null;
  }

  const {
    page = 1,
    initialState = IssuableStates.Opened,
    initialSortBy = 'created_desc',
  } = mountPointEl.dataset;

  const initialFilterParams = Object.assign(
    convertObjectPropsToCamelCase(urlParamsToObject(window.location.search.substring(1)), {
      dropKeys: ['scope', 'utf8', 'state', 'sort'], // These keys are unsupported/unnecessary
    }),
  );

  return new Vue({
    el: mountPointEl,
    provide: {
      ...mountPointEl.dataset,
      page: parseInt(page, 10),
      initialState,
      initialSortBy,
    },
    apolloProvider,
    render: (createElement) =>
      createElement(JiraIssuesListApp, {
        props: {
          initialFilterParams,
        },
      }),
  });
}
