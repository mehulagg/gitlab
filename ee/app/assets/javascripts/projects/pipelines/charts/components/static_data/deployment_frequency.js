import { helpPagePath } from '~/helpers/help_page_helper';
import { s__ } from '~/locale';

export * from './shared';

export const CHART_TITLE = s__('DORA4Metrics|Deployment frequency');

export const areaChartOptions = {
  xAxis: {
    name: s__('DORA4Metrics|Date'),
    type: 'category',
  },
  yAxis: {
    name: s__('DORA4Metrics|Number of deployments'),
    type: 'value',
    minInterval: 1,
  },
};

export const chartDescriptionText = s__(
  'DORA4Metrics|These charts display the frequency of deployments to the %{linkStart}production environment(s)%{linkEnd}, as part of the DORA 4 metrics.',
);

export const chartDocumentationHref = helpPagePath('user/analytics/ci_cd_analytics.html', {
  anchor: 'deployment-frequency-charts',
});
