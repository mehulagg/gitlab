import LoadingSkeleton from 'ee/threat_monitoring/components/loading_skeleton.vue';
import StatisticsHistory from 'ee/threat_monitoring/components/statistics_history.vue';
import StatisticsSummary from 'ee/threat_monitoring/components/statistics_summary.vue';
import ThreatMonitoringSection from 'ee/threat_monitoring/components/threat_monitoring_section.vue';
import createStore from 'ee/threat_monitoring/store';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

import { mockNominalHistory, mockAnomalousHistory } from '../mocks/mock_data';

describe('ThreatMonitoringSection component', () => {
  let store;
  let wrapper;

  const title = 'Test Title';

  const timeRange = {
    from: new Date(Date.UTC(2020, 2, 6)).toISOString(),
    to: new Date(Date.UTC(2020, 2, 13)).toISOString(),
  };

  const factory = ({ propsData, state } = {}) => {
    store = createStore();
    Object.assign(store.state.threatMonitoringNetworkPolicy, {
      isLoadingStatistics: false,
      statistics: {
        total: 100,
        anomalous: 0.2,
        history: {
          nominal: mockNominalHistory,
          anomalous: mockAnomalousHistory,
        },
      },
      timeRange,
      ...state,
    });

    jest.spyOn(store, 'dispatch').mockImplementation(() => Promise.resolve());

    wrapper = shallowMountExtended(ThreatMonitoringSection, {
      propsData: {
        storeNamespace: 'threatMonitoringNetworkPolicy',
        title,
        subtitle: 'Requests',
        nominalTitle: 'Total Requests',
        anomalousTitle: 'Anomalous Requests',
        yLegend: 'Requests',
        chartEmptyStateTitle: 'Empty Title',
        chartEmptyStateText: 'Empty Text',
        chartEmptyStateSvgPath: 'svg_path',
        documentationPath: 'documentation_path',
        documentationAnchor: 'anchor',
        ...propsData,
      },
      store,
    });
  };

  const findLoadingSkeleton = () => wrapper.findComponent(LoadingSkeleton);
  const findStatisticsHistory = () => wrapper.findComponent(StatisticsHistory);
  const findStatisticsSummary = () => wrapper.findComponent(StatisticsSummary);
  const findChartEmptyState = () => wrapper.findByTestId('chartEmptyState');
  const findChartTitle = () => wrapper.findByTestId('chartTitle');
  const findChartSubtitle = () => wrapper.findByTestId('chartSubtitle');

  afterEach(() => {
    wrapper.destroy();
  });

  describe('given there is data to display', () => {
    beforeEach(() => {
      factory({});
    });

    it('shows the chart title', () => {
      const chartTitle = findChartTitle();
      expect(chartTitle.exists()).toBe(true);
      expect(chartTitle.text()).toBe(title);
    });

    it.each`
      component               | status                | findComponent            | state
      ${'loading skeleton'}   | ${'does not display'} | ${findLoadingSkeleton}   | ${false}
      ${'chart subtitle'}     | ${'does display'}     | ${findChartSubtitle}     | ${true}
      ${'statistics summary'} | ${'does display'}     | ${findStatisticsSummary} | ${true}
      ${'statistics history'} | ${'does display'}     | ${findStatisticsHistory} | ${true}
      ${'chart empty state'}  | ${'does not display'} | ${findChartEmptyState}   | ${false}
    `('$status the $component', async ({ findComponent, state }) => {
      expect(findComponent().exists()).toBe(state);
    });

    it('sets data to the summary', () => {
      const summary = findStatisticsSummary();
      expect(summary.exists()).toBe(true);

      expect(summary.props('data')).toStrictEqual({
        anomalous: {
          title: 'Anomalous Requests',
          value: 0.2,
        },
        nominal: {
          title: 'Total Requests',
          value: 100,
        },
      });
    });

    it('sets data to the chart', () => {
      const chart = findStatisticsHistory();
      expect(chart.exists()).toBe(true);

      expect(chart.props('data')).toStrictEqual({
        anomalous: { title: 'Anomalous Requests', values: mockAnomalousHistory },
        nominal: { title: 'Total Requests', values: mockNominalHistory },
        ...timeRange,
      });
      expect(chart.props('yLegend')).toEqual('Requests');
    });

    it('fetches statistics', () => {
      expect(store.dispatch).toHaveBeenCalledWith('threatMonitoringNetworkPolicy/fetchStatistics');
    });

    it('fetches statistics on environment change', async () => {
      store.dispatch.mockReset();
      await store.commit('threatMonitoring/SET_CURRENT_ENVIRONMENT_ID', 2);

      expect(store.dispatch).toHaveBeenCalledWith('threatMonitoringNetworkPolicy/fetchStatistics');
    });

    it('fetches statistics on time window change', async () => {
      store.dispatch.mockReset();
      await store.commit('threatMonitoring/SET_CURRENT_TIME_WINDOW', 'hour');

      expect(store.dispatch).toHaveBeenCalledWith('threatMonitoringNetworkPolicy/fetchStatistics');
    });
  });

  describe('given the statistics are loading', () => {
    beforeEach(() => {
      factory({
        state: { isLoadingStatistics: true },
      });
    });

    it.each`
      component               | status                | findComponent            | state
      ${'loading skeleton'}   | ${'does display'}     | ${findLoadingSkeleton}   | ${true}
      ${'chart subtitle'}     | ${'does not display'} | ${findChartSubtitle}     | ${false}
      ${'statistics summary'} | ${'does not display'} | ${findStatisticsSummary} | ${false}
      ${'statistics history'} | ${'does not display'} | ${findStatisticsHistory} | ${false}
      ${'chart empty state'}  | ${'does not display'} | ${findChartEmptyState}   | ${false}
    `('$status the $component', async ({ findComponent, state }) => {
      expect(findComponent().exists()).toBe(state);
    });
  });

  describe('given there is a default environment with no data to display', () => {
    beforeEach(() => {
      factory({
        state: {
          statistics: {
            total: 100,
            anoumalous: 0.2,
            history: { nominal: [], anomalous: [] },
          },
        },
      });
    });

    it.each`
      component               | status                | findComponent            | state
      ${'loading skeleton'}   | ${'does not display'} | ${findLoadingSkeleton}   | ${false}
      ${'chart subtitle'}     | ${'does not display'} | ${findChartSubtitle}     | ${false}
      ${'statistics summary'} | ${'does not display'} | ${findStatisticsSummary} | ${false}
      ${'statistics history'} | ${'does not display'} | ${findStatisticsHistory} | ${false}
      ${'chart empty state'}  | ${'does not display'} | ${findChartEmptyState}   | ${true}
    `('$status the $component', async ({ findComponent, state }) => {
      expect(findComponent().exists()).toBe(state);
    });
  });
});
