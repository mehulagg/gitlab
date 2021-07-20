import BlockingMergeRequestsBody from 'ee/vue_merge_request_widget/components/blocking_merge_requests/blocking_merge_request_body.vue';
import PerformanceIssueBody from 'ee/vue_merge_request_widget/components/performance_issue_body.vue';
import StatusCheckIssueBody from 'ee/vue_merge_request_widget/components/status_check_issue_body.vue';
import LicenseIssueBody from 'ee/vue_shared/license_compliance/components/license_issue_body.vue';
import LicenseStatusIcon from 'ee/vue_shared/license_compliance/components/license_status_icon.vue';
import MetricsReportsIssueBody from 'ee/vue_shared/metrics_reports/components/metrics_reports_issue_body.vue';
import SecurityIssueBody from 'ee/vue_shared/security_reports/components/security_issue_body.vue';
import {
  components as componentsCE,
  componentNames as componentNamesCE,
  iconComponents as iconComponentsCE,
  iconComponentNames as iconComponentNamesCE,
} from '~/reports/components/issue_body';

export const components = {
  ...componentsCE,
  StatusCheckIssueBody,
  PerformanceIssueBody,
  LicenseIssueBody,
  SecurityIssueBody,
  MetricsReportsIssueBody,
  BlockingMergeRequestsBody,
};

export const componentNames = {
  ...componentNamesCE,
  StatusCheckIssueBody: StatusCheckIssueBody.name,
  PerformanceIssueBody: PerformanceIssueBody.name,
  LicenseIssueBody: LicenseIssueBody.name,
  SecurityIssueBody: SecurityIssueBody.name,
  MetricsReportsIssueBody: MetricsReportsIssueBody.name,
  BlockingMergeRequestsBody: BlockingMergeRequestsBody.name,
};

export const iconComponents = {
  ...iconComponentsCE,
  LicenseStatusIcon,
};

export const iconComponentNames = {
  ...iconComponentNamesCE,
  LicenseStatusIcon: LicenseStatusIcon.name,
};
