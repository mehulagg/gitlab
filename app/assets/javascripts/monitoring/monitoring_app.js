import Vue from 'vue';
import { GlToast } from '@gitlab/ui';
import { parseBoolean } from '~/lib/utils/common_utils';
import { getParameterValues } from '~/lib/utils/url_utility';
import { createStore } from './stores';
import createRouter from './router';

Vue.use(GlToast);

export default (props = {}) => {
  const el = document.getElementById('prometheus-graphs');

  if (el && el.dataset) {
    const [currentDashboard] = getParameterValues('dashboard');

    const {
      deploymentsEndpoint,
      dashboardEndpoint,
      dashboardsEndpoint,
      projectPath,
      logsPath,
      currentEnvironmentName,
      dashboardTimezone,
      metricsDashboardBasePath,
      customDashboardBasePath,
      ...dataProps
    } = el.dataset;

    const store = createStore({
      currentDashboard,
      deploymentsEndpoint,
      dashboardEndpoint,
      dashboardsEndpoint,
      dashboardTimezone,
      projectPath,
      logsPath,
      currentEnvironmentName,
      customDashboardBasePath,
    });

    // HTML attributes are always strings, parse other types.
    dataProps.hasMetrics = parseBoolean(dataProps.hasMetrics);
    dataProps.customMetricsAvailable = parseBoolean(dataProps.customMetricsAvailable);
    dataProps.prometheusAlertsAvailable = parseBoolean(dataProps.prometheusAlertsAvailable);

    const router = createRouter(metricsDashboardBasePath);

    // eslint-disable-next-line no-new
    new Vue({
      el,
      store,
      router,
      data() {
        return {
          dashboardProps: { ...dataProps, ...props },
        };
      },
      template: `<router-view :dashboardProps="dashboardProps"/>`,
    });
  }
};
