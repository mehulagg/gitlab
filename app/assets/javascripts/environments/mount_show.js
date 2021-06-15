import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import EnvironmentsDetailHeader from './components/environments_detail_header.vue';
import environmentsMixin from './mixins/environments_mixin';

export const initHeader = () => {
  const el = document.getElementById('environments-detail-view-header');
  const container = document.getElementById('environments-detail-view');
  const dataset = JSON.parse(JSON.stringify(container.dataset));

  return new Vue({
    el,
    mixins: [environmentsMixin],
    data() {
      const environment = {
        name: dataset.name,
        id: Number(dataset.id),
        externalUrl: dataset.externalUrl,
        isAvailable: parseBoolean(dataset.isEnvironmentAvailable),
        hasTerminals: parseBoolean(dataset.hasTerminals),
        autoStopAt: dataset.autoStopAt,
        onSingleEnvironmentPage: true,
        // TODO: These two props are snake_case because the environments_mixin file uses
        // them and the mixin is imported in several files. It would be nice to conver them to camelCase.
        stop_path: dataset.environmentStopPath,
        delete_path: dataset.environmentDeletePath,
      };

      return {
        environment,
      };
    },
    render(createElement) {
      return createElement(EnvironmentsDetailHeader, {
        props: {
          environment: this.environment,
          canDestroyEnvironment: parseBoolean(dataset.canDestroyEnvironment),
          canUpdateEnvironment: parseBoolean(dataset.canUpdateEnvironment),
          canReadEnvironment: parseBoolean(dataset.canReadEnvironment),
          canStopEnvironment: parseBoolean(dataset.canStopEnvironment),
          canAdminEnvironment: parseBoolean(dataset.canAdminEnvironment),
          cancelAutoStopPath: dataset.environmentCancelAutoStopPath,
          terminalPath: dataset.environmentTerminalPath,
          metricsPath: dataset.environmentMetricsPath,
          updatePath: dataset.environmentEditPath,
        },
      });
    },
  });
};
