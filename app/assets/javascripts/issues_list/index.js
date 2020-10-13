import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import {
  parseBoolean,
  convertObjectPropsToCamelCase,
} from '~/lib/utils/common_utils';
import JiraIssuesListRoot from './components/jira_issues_list_root.vue';
import IssuablesListApp from './components/issuables_list_app.vue';
import IssuesListEmptyState from './components/issues_list_empty_state.vue';
import { getJiraFilteredSearchOptions } from './filtered_search_init_helper'
import { IssuesListType } from './constants';

function mountJiraIssuesListApp() {
  const el = document.querySelector('.js-projects-issues-root');

  if (!el) {
    return false;
  }

  Vue.use(VueApollo);

  const defaultClient = createDefaultClient();
  const apolloProvider = new VueApollo({
    defaultClient,
  });

  return new Vue({
    el,
    apolloProvider,
    render(createComponent) {
      return createComponent(JiraIssuesListRoot, {
        props: {
          canEdit: parseBoolean(el.dataset.canEdit),
          isJiraConfigured: parseBoolean(el.dataset.isJiraConfigured),
          issuesPath: el.dataset.issuesPath,
          projectPath: el.dataset.projectPath,
        },
      });
    },
  });
}

function mountIssuablesListApp() {
  if (!gon.features?.vueIssuablesList && !gon.features?.jiraIssuesIntegration) {
    return;
  }

  document.querySelectorAll('.js-issuables-list').forEach(el => {
    const {
      projectPath,
      endpoint,
      canBulkEdit,
      type = '',
      sortKey,
      emptyStateMeta = {},
    } = el.dataset;

    return new Vue({
      el,
      components: {
        EmptyState: IssuesListEmptyState,
      },
      provide: {
        type,
        endpoint,
        canBulkEdit: Boolean(canBulkEdit),
        // Only jira issues list supports Vue filtered search bar
        // filteredSearchOptions is consumed by Vue filtered search bar (only jira issue lists uses it for now)
        filteredSearchOptions:
          type === IssuesListType.jira ? getJiraFilteredSearchOptions(projectPath) : null,
        emptyStateMeta:
          Object.keys(emptyStateMeta).length !== 0
            ? convertObjectPropsToCamelCase(JSON.parse(emptyStateMeta))
            : {},
      },
      render(createElement) {
        return createElement(IssuablesListApp, {
          props: {
            sortKey,
          },
        });
      },
    });
  });
}

export default function initIssuablesList() {
  mountJiraIssuesListApp();
  mountIssuablesListApp();
}
