import Vue from 'vue';
import VueApollo from 'vue-apollo';
import IssuesListApp from '~/issues_list/components/issues_list_app.vue';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean, convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import IssuablesListApp from './components/issuables_list_app.vue';
import JiraIssuesImportStatusRoot from './components/jira_issues_import_status_app.vue';

function mountJiraIssuesListApp() {
  const el = document.querySelector('.js-jira-issues-import-status');

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
      return createComponent(JiraIssuesImportStatusRoot, {
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

  document.querySelectorAll('.js-issuables-list').forEach((el) => {
    const { canBulkEdit, emptyStateMeta = {}, scopedLabelsAvailable, ...data } = el.dataset;

    return new Vue({
      el,
      provide: {
        scopedLabelsAvailable: parseBoolean(scopedLabelsAvailable),
      },
      render(createElement) {
        return createElement(IssuablesListApp, {
          props: {
            ...data,
            emptyStateMeta:
              Object.keys(emptyStateMeta).length !== 0
                ? convertObjectPropsToCamelCase(JSON.parse(emptyStateMeta))
                : {},
            canBulkEdit: Boolean(canBulkEdit),
          },
        });
      },
    });
  });
}

export function initIssuesListApp() {
  const el = document.querySelector('.js-issues-list');

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    render: (createComponent) =>
      createComponent(IssuesListApp, {
        props: {
          endpoint: el.dataset.endpoint,
          fullPath: el.dataset.fullPath,
        },
      }),
  });
}

export default function initIssuablesList() {
  mountJiraIssuesListApp();
  mountIssuablesListApp();
}
