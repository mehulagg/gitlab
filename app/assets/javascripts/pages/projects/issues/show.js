import initIssuableSidebar from '~/init_issuable_sidebar';
import Issue from '~/issue';
import ShortcutsIssuable from '~/behaviors/shortcuts/shortcuts_issuable';
import ZenMode from '~/zen_mode';
import '~/notes/index';
import { store } from '~/notes/stores';
import initIssueApp from '~/issue_show/issue';
import initIncidentApp from '~/issue_show/incident';
import initIssuableHeaderWarning from '~/vue_shared/components/issuable/init_issuable_header_warning';
import initSentryErrorStackTraceApp from '~/sentry_error_stack_trace';
import initRelatedMergeRequestsApp from '~/related_merge_requests';
import initVueIssuableSidebarApp from '~/issuable_sidebar/sidebar_bundle';
import { parseIssuableData } from '~/issue_show/utils/parse_data';

export default function() {
  const { issueType, ...issuableData } = parseIssuableData();

  if (issueType === 'incident') {
    initIncidentApp(issuableData);
  } else {
    initIssueApp(issuableData);
  }

  initIssuableHeaderWarning(store);
  initSentryErrorStackTraceApp();
  initRelatedMergeRequestsApp();

  // This will be removed when we remove the `design_management_moved` feature flag
  // See https://gitlab.com/gitlab-org/gitlab/-/issues/223197
  import(/* webpackChunkName: 'design_management' */ '~/design_management_legacy')
    .then(module => module.default())
    .catch(() => {});

  import(/* webpackChunkName: 'design_management' */ '~/design_management')
    .then(module => module.default())
    .catch(() => {});

  new Issue(); // eslint-disable-line no-new
  new ShortcutsIssuable(); // eslint-disable-line no-new
  new ZenMode(); // eslint-disable-line no-new
  if (gon.features && gon.features.vueIssuableSidebar) {
    initVueIssuableSidebarApp();
  } else {
    initIssuableSidebar();
  }
}
