import { helpPagePath } from '~/helpers/help_page_helper';
import { s__ } from '~/locale';

export * from './shared';

export const CHART_TITLE = s__('DORA4Metrics|Deployments');

export const areaChartOptions = {
  xAxis: {
    name: s__('DORA4Metrics|Date'),
    type: 'category',
  },
  yAxis: {
    name: s__('DORA4Metrics|Deployments'),
    type: 'value',
    minInterval: 1,
  },
};

export const chartDescriptionText = s__(
  'DORA4Metrics|These charts display the frequency of deployments to the production environment, as part of the DORA 4 metrics. The environment must be named %{codeStart}production%{codeEnd} for its data to appear in these charts.',
);

export const chartDocumentationHref = helpPagePath('user/analytics/ci_cd_analytics.html', {
  anchor: 'deployment-frequency-charts',
});
