import { stateAndPropsFromDataset } from '~/monitoring/utils';
import { mapToDashboardViewModel } from '~/monitoring/stores/utils';
import { metricStates } from '~/monitoring/constants';
import { convertObjectProps } from '~/lib/utils/common_utils';
import { convertToCamelCase } from '~/lib/utils/text_utility';

import { metricsResult } from './mock_data';

// Use globally available `getJSONFixture` so this file can be imported by both karma and jest specs
export const metricsDashboardResponse = getJSONFixture(
  'metrics_dashboard/environment_metrics_dashboard.json',
);

export const metricsDashboardPayload = metricsDashboardResponse.dashboard;

const datasetState = stateAndPropsFromDataset(
  // It's preferable to have props in snake_case, this will be addressed at:
  // https://gitlab.com/gitlab-org/gitlab/-/merge_requests/33574
  convertObjectProps(
    // Some props use kebab-case, convert to snake_case first
    key => convertToCamelCase(key.replace(/-/g, '_')),
    metricsDashboardResponse.metrics_data,
  ),
);

// new properties like addDashboardDocumentationPath prop and alertsEndpoint
// was recently added to dashboard.vue component this needs to be
// added to fixtures data
// https://gitlab.com/gitlab-org/gitlab/-/issues/229256
export const dashboardProps = {
  ...datasetState.dataProps,
  alertsEndpoint: null,
};

export const metricsDashboardViewModel = mapToDashboardViewModel(metricsDashboardPayload);

export const metricsDashboardPanelCount = 22;

// Graph data

const firstPanel = metricsDashboardViewModel.panelGroups[0].panels[0];

export const graphData = {
  ...firstPanel,
  metrics: firstPanel.metrics.map(metric => ({
    ...metric,
    result: metricsResult,
    state: metricStates.OK,
  })),
};

export const graphDataEmpty = {
  ...firstPanel,
  metrics: firstPanel.metrics.map(metric => ({
    ...metric,
    result: [],
    state: metricStates.NO_DATA,
  })),
};
